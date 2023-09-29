---
title: 'Bulletin Hebdomadaire Bitcoin Optech #270'
permalink: /fr/newsletters/2023/09/27/
name: 2023-09-27-newsletter-fr
slug: 2023-09-27-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition d'utilisation de covenants pour améliorer considérablement la scalabilité de LN.
Elle comprend également nos rubriques habituelles avec des questions et réponses populaires de la communauté Bitcoin Stack Exchange,
des annonces de nouvelles versions et versions candidates, ainsi que les changements apportés aux principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Utilisation de covenants pour améliorer la scalabilité de LN:** John Law a [publié][law cov post] sur les listes de diffusion
  Bitcoin-Dev et Lightning-Dev le résumé d'un [article][law cov paper] qu'il a écrit sur la création de très grandes [usines à
  canaux][topic channel factories] en utilisant des [covenants][topic covenants] et la gestion des canaux résultants en utilisant
  des adaptations de plusieurs protocoles précédents qu'il a décrits (voir les bulletins [#221][news221 law], [#230][news230 law] et
  [#244][news244 law]).

    Il commence par décrire un problème de scalabilité avec les protocoles basés sur les signatures qui nécessitent la participation
    d'un grand nombre d'utilisateurs, tels que les [coinjoins][topic coinjoin] ou les conceptions précédentes d'usines : si 1 000
    utilisateurs acceptent de participer au protocole mais que l'un d'entre eux devient indisponible pendant la signature, les 999
    autres signatures sont inutiles. Si, lors de la prochaine tentative, un autre utilisateur individuel devient indisponible, les 998
    autres signatures collectées lors de la deuxième tentative sont inutiles. Il propose les covenants tels que
    [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] et [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] comme solution à ce
    problème : ils permettent à une seule petite transaction de restreindre ses fonds à être dépensés uniquement dans une ou plusieurs
    transactions enfants prédéfinies ultérieures. Les transactions ultérieures peuvent également être limitées par un covenant.

    Law utilise ce mécanisme pour créer un _arbre de temporisation_ où une _transaction de financement_ paie un arbre de transactions
    enfants prédéfinies qui sont finalement dépensées hors chaîne dans un grand nombre de canaux de paiement séparés. Un mécanisme
    similaire à celui utilisé par Ark (voir le [Bulletin #253][news253 ark]) permet à chacun des canaux de paiement d'être éventuellement
    mis sur la chaîne, mais il permet également au financeur de l'usine de récupérer les fonds de tout canal qui n'a pas été mis onchain
    après expiration. Cela peut être extrêmement efficace : un arbre de temporisation hors chaîne finançant des millions de canaux peut
    être créé à l'aide d'une seule petite transaction onchain. Après expiration, les fonds peuvent être récupérés par le financeur de
    l'usine dans une autre petite transaction onchain, les utilisateurs individuels retirant leurs fonds via LN vers leurs autres canaux
    avant la date d'expiration de l'usine.

    Le modèle ci-dessus est compatible avec la construction de canaux LN-Penalty actuellement utilisée ainsi qu'avec le mécanisme
    proposé [LN-Symmetry][topic eltoo]. Cependant, le reste de l'article de Law examine une proposition demodification de son protocole
    Fully Factory Optimized Watchtower Free (FFO-WF) qui offre plusieurs avantages pour la conception d'une usine basée sur les
    covenants. En plus des avantages décrits dans les bulletins précédents, tels que la nécessité uniquement d'utilisateurs
    _occasionnels_ pour aller en ligne pendant quelques minutes tous les quelques mois et permettre aux utilisateurs dédiés d'utiliser
    leur capital à travers différents canaux de manière plus efficace, un nouvel avantage de la construction mise à jour permet au
    financeur de l'usine de déplacer des fonds pour les utilisateurs occasionnels d'une usine (basée sur une transaction onchain
    particulière) vers une autre usine (ancrée dans une transaction onchain différente) sans nécessiter d'interaction de l'utilisateur.
    Cela signifie que l'utilisateur occasionnel Alice, qui sait qu'elle doit se connecter avant l'expiration de 6 mois d'une usine,
    peut se connecter au mois 5 pour découvrir que ses fonds ont déjà été transférés vers une nouvelle usine avec plusieurs mois
    supplémentaires avant l'expiration. Alice n'a rien à faire ; elle conserve un contrôle complet et sans confiance de ses fonds.
    Cela réduit la possibilité qu'Alice se connecte très près de l'expiration, découvre que le financeur de l'usine est temporairement
    indisponible et soit obligée de mettre sa part de l'arbre de temporisation onchain, ce qui entraîne des frais de transaction et
    réduit la scalabilité globale du réseau.

    Anthony Towns a répondu avec une préoccupation qu'il a appelée le problème du "troupeau tonitruant" (appelé "spam d'expiration
    forcée" dans le document LN original) où l'échec délibéré ou accidentel d'un grand utilisateur dédié nécessite à de nombreux
    autres utilisateurs de mettre de nombreuses transactions sensibles au temps onchain en même temps. Par exemple, une usine avec un
    million d'utilisateurs peut nécessiter une confirmation sensible au temps jusqu'à un million de transactions plus une confirmation
    non sensible au temps jusqu'à deux millions de transactions supplémentaires pour que ces utilisateurs replacent ces fonds dans de
    nouveaux canaux. Il faut actuellement environ une semaine au réseau pour confirmer trois millions de transactions, donc les
    utilisateurs d'une usine d'un million d'utilisateurs peuvent souhaiter qu'une usine renouvelle leurs fonds quelques semaines avant
    l'expiration, ou peut-être plusieurs mois à l'avance s'ils sont préoccupés par le fait que plusieurs usines de plusieurs millions
    d'utilisateurs rencontrent des problèmes simultanément.

    Une version du document LN original suggérait que ce problème pourrait être résolu en utilisant une idée de Gregory Maxwell qui
    retarderait l'expiration lorsque "les blocs sont pleins" (par exemple, les frais sont supérieurs au montant normal). Dans sa
    réponse à Towns, Law a noté qu'il travaille sur une conception spécifique pour une solution de ce type qu'il publiera une fois
    qu'il aura fini d'y réfléchir. {% assign timestamp="2:07" %}

##  Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
  questions, ou lorsque nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique
  mensuelle, nous mettons en évidence certaines des questions et réponses les plus votées publiées depuis notre dernière mise
  à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Comment fonctionnait la découverte des pairs dans Bitcoin v0.1 ?]({{bse}}119507)
  Pieter Wuille décrit l'évolution des mécanismes de découverte des pairs dans Bitcoin Core, depuis la recherche de pairs basée sur
  IRC dans la version 0.1 jusqu'aux adresses IP codées en dur et au semis de pairs DNS actuellement utilisés.
  {% assign timestamp="20:42" %}

- [Est-ce qu'une série de réorganisations pourrait causer la rupture de Bitcoin en raison de la restriction de différence de temps de bloc de 2 heures ?]({{bse}}119677)
  L'utilisateur fiatjaf demande si une série de réorganisations de la chaîne de blocs, potentiellement le résultat du
  [tir ciblé de frais][topic fee sniping], pourrait causer des problèmes avec les restrictions de temps de bloc de Bitcoin. Antoine
  Poinsot et Pieter Wuille décrivent les deux restrictions de temps de bloc (doivent être supérieures au [temps médian passé
  (MTP)][news146 mtp] et ne pas dépasser deux heures dans le futur selon l'heure locale du nœud) et concluent que les conditions des
  deux restrictions ne sont pas exacerbées par une réorg. {% assign timestamp="22:48" %}

- [Existe-t-il un moyen de télécharger les blocs à partir de zéro sans télécharger d'abord les en-têtes de bloc ?]({{bse}}119503)
  Pieter Wuille confirme qu'il est possible de télécharger les blocs sans les en-têtes, mais souligne que le désavantage est que le
  nœud ne saurait pas s'il est sur la meilleure chaîne avant d'avoir téléchargé et traité tous les blocs. Il compare cette approche
  avec [la synchronisation des en-têtes en premier][headers first pr] et décrit les messages P2P échangés pour chaque approche.
  {% assign timestamp="26:56" %}

- [Où est indiqué le plafond dur de 21 millions de bitcoins dans le code source de Bitcoin ?]({{bse}}119475)
  Pieter Wuille explique la fonction `GetBlockSubsidy` de Bitcoin Core qui définit le calendrier d'émission des subventions. Il renvoie
  également à une discussion précédente sur Stack Exchange concernant la limite de 20 999 999,9769 BTC de Bitcoin et pointe vers la
  constante `MAX_MONEY` qui est utilisée comme vérification de cohérence dans le code de validation du consensus.
  {% assign timestamp="28:56" %}

- [Les blocs contenant des transactions non standard sont-ils relayés à travers le réseau ou non, comme c'est le cas pour les transactions non standard ?]({{bse}}119693)
  L'utilisateur fiatjaf répond que bien que les transactions non standard selon [la politique][policy series] ne soient pas relayées
  par défaut sur le réseau P2P, les blocs contenant des transactions non standard sont toujours relayés, à condition que le bloc
  respecte les règles de consensus.
  {% assign timestamp="31:50" %}

- [Quand Bitcoin Core vous permet-il d'"abandonner une transaction" ?]({{bse}}119771)
  Murch détaille les trois conditions requises pour pouvoir [abandonner][rpc abandontransaction] une transaction dans Bitcoin Core :
  {% assign timestamp="35:47" %}

  - la transaction n'a pas été abandonnée précédemment
  - ni la transaction ni une transaction en conflit ne sont confirmées
  - la transaction n'est pas dans le mempool du nœud

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LND v0.17.0-beta.rc5][] est un candidat aux versions pour la prochaine version majeure de cette implémentation populaire de nœud LN.
  Une nouvelle fonctionnalité expérimentale majeure prévue pour cette version, qui pourrait bénéficier de tests, est la prise en charge
  des "canaux taproot simples". {% assign timestamp="39:07" %}

## Modifications de code et de documentation notables

*Modifications notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware WalletInterface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo]
[Lightning BOLTs][bolts repo], et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28492][] met à jour le RPC `descriptorprocesspsbt` pour inclure la transaction sérialisée complète si le traitement du
  [PSBT][topic psbt] aboutit à une transaction diffusable. Voir [le bulletin de la semaine dernière][news269 psbt] pour un PR fusionné
  similaire. {% assign timestamp="39:54" %}

- [Bitcoin Core GUI #119][] met à jour la liste des transactions dans l'interface graphique pour ne plus fournir de catégorie spéciale
  pour "paiement à vous-même". Maintenant, les transactions qui ont à la fois des entrées et des sorties qui affectent le portefeuille
  sont affichées sur des lignes séparées pour les dépenses et les réceptions. Cela peut améliorer la clarté pour les
  [coinjoins][topic coinjoin] et les [payjoins][topic payjoin], bien que Bitcoin Core ne supporte actuellement aucun de ces types de
  transactions par lui-même. {% assign timestamp="41:13" %}

- [Bitcoin Core GUI #738][] ajoute une option de menu permettant de migrer un portefeuille hérité basé sur des clés et des types de
  script de sortie implicites stockés dans BerkeleyDB (BDB) vers un portefeuille moderne qui utilise des [descripteurs][topic descriptors]
  stockés dans SQLite. {% assign timestamp="42:49" %}

- [Bitcoin Core #28246][] met à jour la façon dont le portefeuille Bitcoin Core détermine internement quel script de sortie
  (scriptPubKey) une transaction doit payer. Auparavant, les transactions payaient simplement le script de sortie spécifié par
  l'utilisateur, mais si le support des [paiements silencieux][topic silent payments] est ajouté à Bitcoin Core, le script de sortie
  devra être dérivé en fonction des données des entrées sélectionnées pour la transaction. Cette mise à jour rend cela beaucoup plus
  simple. {% assign timestamp="44:18" %}

- [Core Lightning #6311][] supprime l'option de construction `--developer` qui produisait des binaires avec des options supplémentaires
  par rapport aux binaires CLN standard. Maintenant, les fonctionnalités expérimentales et non par défaut peuvent être accessibles en
  démarrant `lightningd` avec l'option de configuration d'exécution `--developer`. Une option de construction `--enable-debug` produira
  toujours un binaire légèrement différent avec certaines modifications bénéfiques pour les tests. {% assign timestamp="46:30" %}

- [Core Lightning #6617][] met à jour le RPC `showrunes` pour fournir un nouveau champ de résultats, `last_used`, qui affiche la dernière
  fois que le _rune_ (jeton d'authentification) a été utilisé. {% assign timestamp="47:23" %}

- [Core Lightning #6686][] ajoute des en-têtes de stratégie de sécurité du contenu (CSP) et de partage des ressources entre origines
  (CORS) configurables pour l'interface REST de l'API de CLN. {% assign timestamp="47:55" %}

- [Eclair #2613][] permet à Eclair de gérer toutes ses propres clés privées et d'utiliser Bitcoin Core avec seulement un portefeuille
  en mode surveillance (un portefeuille avec des clés publiques mais sans clés privées). Cela peut être particulièrement utile si Eclair
  est exécuté dans un environnement plus sécurisé que Bitcoin Core.
  Pour plus de détails, consultez la [documentation][eclair keys] ajoutée dans cette PR. {% assign timestamp="48:44" %}

- [LND #7994][] ajoute la prise en charge de l'interface RPC du signataire distant pour l'ouverture de canaux taproot, ce qui nécessite
  de spécifier une clé publique et le nonce en deux parties [MuSig2][topic musig]. {% assign timestamp="50:18" %}

- [LDK #2547][] met à jour le code de recherche de chemin probabiliste en supposant qu'il est plus probable que les canaux distants
  aient la plupart de leur liquidité poussée d'un côté du canal. Par exemple, dans un canal distant de 1,00 BTC entre Alice et Bob,
  l'état le moins probable du canal est que Alice et Bob aient chacun 0,50 BTC. Il est plus probable que l'un d'entre eux ait 0,90
  BTC---et encore plus probable que l'un d'entre eux ait 0,99 BTC. {% assign timestamp="51:10" %}

- [LDK #2534][] ajoute la méthode `ChannelManager::send_preflight_probes` pour sonder les chemins de paiement avant d'essayer d'envoyer
  un paiement. Une sonde est générée par un expéditeur comme un paiement LN régulier, mais la valeur de son préimage [HTLC][topic htlc]
  est définie sur une valeur inutilisable (par exemple, une valeur connue uniquement de l'expéditeur) ; lorsqu'elle atteint sa
  destination, le destinataire ne connaît pas le préimage et le rejette, renvoyant une erreur. Si cette erreur est reçue, le sondeur
  sait que le chemin de paiement avait suffisamment de liquidité pour prendre en charge le paiement lorsqu'il a été envoyé, et qu'un
  paiement réel envoyé le long du même chemin pour le même montant réussira probablement. Si une autre erreur est reçue, telle qu'une
  erreur indiquant que l'un des sauts le long du chemin ne pouvait pas transmettre le paiement, un nouveau chemin peut être sondé avant
  d'envoyer le paiement réel.

   La sonde préalable au paiement ("prévol") peut être utile avec de petites sommes d'argent pour trouver des sauts qui rencontrent des
   problèmes pouvant causer des retards. Si quelques centaines de sats (ou moins) restent bloqués pendant quelques heures, ce n'est pas
   grave pour la plupart des dépensiers---mais si le montant total d'un paiement représentant une partie importante du capital d'un nœud
   reste bloqué, cela peut être très ennuyeux. Il est également possible de sonder plusieurs chemins simultanément et d'utiliser les
   résultats pour choisir le meilleur chemin quelques instants plus tard lors de l'envoi d'un paiement. {% assign timestamp="53:01" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="28492,119,738,28246,6311,6617,6686,2613,7994,2547,2534" %}
[LND v0.17.0-beta.rc5]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc5
[news253 ark]: /fr/newsletters/2023/05/31/#proposition-d-un-protocole-de-gestion-des-joinpool
[maxwell clock stop]: https://www.reddit.com/r/Bitcoin/comments/37fxqd/it_looks_like_blockstream_is_working_on_the/crmr5p2/
[law cov post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004092.html
[law cov paper]: https://github.com/JohnLaw2/ln-scaling-covenants[towns cov]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004095.html
[ln paper]: https://lightning.network/lightning-network-paper.pdf
[law fee stop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004102.html
[news221 law]: /fr/newsletters/2022/10/12/#ln-avec-une-proposition-de-hors-ligne-long
[news230 law]: /fr/newsletters/2022/12/14/#proposition-d-optimisation-du-protocole-d-usines-à-canaux-ln
[news244 law]: /fr/newsletters/2023/03/29/#prevenir-les-pertes-de-capitaux-grace-aux-usines-a-canaux-channel-factories-et-aux-canaux-multipartites
[eclair keys]: https://github.com/ACINQ/eclair/blob/d3ac58863fbb76f4a44a779a52a6893b43566b29/docs/ManagingBitcoinCoreKeys.md
[news269 psbt]: /fr/newsletters/2023/09/20/#bitcoin-core-28414
[news146 mtp]: /en/newsletters/2021/04/28/#what-are-the-different-contexts-where-mtp-is-used-in-bitcoin
[headers first pr]: https://github.com/bitcoin/bitcoin/pull/4468
[policy series]: /fr/blog/waiting-for-confirmation/
