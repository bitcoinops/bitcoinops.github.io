---
title: 'Bulletin Hebdomadaire Bitcoin Optech #287'
permalink: /fr/newsletters/2024/01/31/
name: 2024-01-31-newsletter-fr
slug: 2024-01-31-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition visant à permettre le remplacement des transactions v3 en utilisant les règles RBF
pour faciliter la transition vers le mempool en cluster et résume un argument contre `OP_CHECKTEMPLATEVERIFY` basé sur le fait qu'il
nécessite généralement des frais exogènes. Sont également incluses nos sections régulières résumant les principales questions et réponses
de Bitcoin Stack Exchange, annonçant de nouvelles versions et des versions candidates, et décrivant les principaux changements apportés
aux projets d'infrastructure Bitcoin.

## Nouvelles

- **Remplacement par frais de parenté :** Gloria Zhao [a posté][zhao v3kindred] sur Delving Bitcoin pour permettre à une transaction
  de remplacer une transaction connexe dans le mempool même s'il n'y a pas de conflit entre les deux transactions. Deux transactions
  sont considérées comme _conflictuelles_ lorsqu'elles ne peuvent pas toutes deux exister dans la même chaîne de blocs valide,
  généralement parce qu'elles essaient toutes deux de dépenser la même UTXO, en violation de la règle contre le double dépense.
  Les règles pour [RBF][topic rbf] comparent une transaction dans le mempool à une nouvelle transaction reçue qui entre en conflit avec
  elle. Zhao suggère une façon idéalisée de penser à une politique de conflits : si un nœud de relais a deux transactions mais ne peut
  en accepter qu'une seule, il ne devrait pas choisir celle qui arrive en premier---mais celle qui convient le mieux aux objectifs de
  l'opérateur du nœud (comme maximiser les revenus des mineurs sans permettre de relais effectivement gratuits). Les règles RBF tentent
  de le faire pour les conflits ; Zhao, dans son article, étend l'idée aux transactions connexes plutôt qu'aux seuls conflits.

  Bitcoin Core impose des limites _politiques_ sur le nombre et la taille des transactions connexes autorisées simultanément dans le
  mempool. Cela atténue plusieurs attaques DoS, mais signifie qu'il peut rejeter la transaction B parce qu'il a précédemment reçu la
  transaction connexe A, qui a atteint les limites. Cela viole le principe de Zhao : au lieu de cela, Bitcoin Core devrait accepter
  celle de A ou B qui est réellement la meilleure pour ses objectifs.

  Les règles proposées pour [la transmission des transactions v3][topic v3 transaction relay] n'autorisent qu'un parent v3 non confirmé
  à avoir une seule transaction enfant dans le mempool. Comme aucune des transactions ne peut avoir d'ancêtres ou de dépendants dans le
  mempool, il est facile d'appliquer les règles RBF existantes aux remplacements d'une transaction enfant v3 et Zhao l'a
  [implémenté][zhao kindredimpl]. Si, comme décrit dans [le bulletin de la semaine dernière][news286 imbued], les transactions de
  commitment LN existantes utilisant [les sorties d'ancrage][topic anchor outputs] sont automatiquement inscrites dans la politique v3,
  cela garantirait que chaque partie peut toujours augmenter les frais de la transaction de commitment :

  - Alice peut envoyer la transaction de commitment avec une transaction enfant pour payer les frais.

  - Alice peut ensuite RBF sa transaction enfant existante pour augmenter les frais.

  - Bob peut utiliser le remplacement par parenté pour expulser la transaction enfant d'Alice en envoyant sa propre transaction enfant
    qui paie des frais plus élevés.

  - Alice peut ensuite utiliser le remplacement par parenté sur la transaction enfant de Bob en envoyant sa propre transaction enfant
    avec des frais encore plus élevés (en supprimant la transaction enfant de Bob).

  L'ajout de cette politique et son application automatique aux ancres LN actuelles permettra de supprimer la [règle de dérogation
  CPFP][topic cpfp carve out],
  ce qui est nécessaire pour mettre en œuvre le [cluster mempool][topic cluster mempool], ce qui devrait permettre de rendre les
  remplacements de toutes sortes plus incitatifs à l'avenir.

  Au moment de la rédaction de cet article, il n'y avait aucune objection à cette idée sur le forum. Une question notable concernait la
  nécessité des [ancres éphémères][topic ephemeral anchors], mais l'auteur de cette proposition (Gregory Sanders) a répondu : "Je n'ai
  pas l'intention d'abandonner
  le travail sur les ancres éphémères. Les sorties à zéro satoshi ont plusieurs cas d'utilisation importants en dehors de LN."

- **Opposition à CTV basée sur le besoin courant de frais exogènes :**
  Peter Todd a [publié][pt ctv] sur la liste de diffusion Bitcoin-Dev une adaptation de son argument contre les [frais exogènes][topic
  fee sourcing] (voir le [Bulletin #284][news284 ptexogenous]) appliqué à la proposition
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]. Il note que, "dans de nombreux (si ce n'est tous) cas d'utilisationde CTV
  destinés à permettre à plusieurs parties de partager une seule UTXO, il est difficile, voire impossible, de permettre suffisamment
  de variantes de CTV pour couvrir tous les taux de frais possibles. On s'attend à ce que CTV soit généralement utilisé avec des [sorties
  d'ancrage][topic ephemeral anchors] pour payer les frais [...] ou éventuellement, via un soft-fork de [parrainage de transaction][topic
  fee sponsorship]. [...] Cette exigence pour que tous les utilisateurs aient une UTXO pour payer les frais annule l'efficacité des
  schémas de partage d'UTXO utilisant CTV [...] la seule alternative réaliste est d'utiliser un tiers pour payer l'UTXO, par exemple via
  un paiement LN, mais à ce stade, il serait plus efficace de payer des [frais miniers hors bande][topic out-of-band fees].
  Cela est bien sûr très indésirable d'un point de vue de la centralisation minière." (Liens ajoutés par Optech.) Il recommande
  d'abandonner CTV et de travailler plutôt sur des [schémas de convenants][topic covenants] compatibles avec [RBF][topic rbf].

  John Law a répondu que les délais dépendant des frais (voir le [Bulletin #283][news283 fdt]) pourraient rendre l'utilisation de CTV
  sûre avec des frais endogènes dans les cas où des versions particulières d'une transaction devaient être confirmées avant une date
  limite, bien que les délais dépendant des frais puissent retarder certains règlements de contrat pendant une durée indéterminée.

##  Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
  questions, ou lorsque nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique
  mensuelle, nous mettons en évidence certaines des questions et réponses les plus votées publiées depuis notre dernière mise
  à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Comment fonctionne la synchronisation des blocs dans Bitcoin Core aujourd'hui ?]({{bse}}121292)
  Pieter Wuille décrit l'arbre des en-têtes de bloc, les données des blocs et les structures de données de la chaîne de blocs chaintip
  active, puis explique la synchronisation des en-têtes, des blocs de synchronisation et les processus d'activation de bloc qui agissent
  sur eux.

- [Comment la méthode headers-first prévient-elle les attaques de remplissage de disque?]({{bse}}76018)
  Pieter Wuille fait suite à une ancienne question pour expliquer la plus récente IBD
  "Headers Presync" (voir le [Bulletin #216][news216 headers presync]) les mesures d'atténuation du spam d'en-tête
  ajoutées à Bitcoin Core dans la version 24.0.

- [Le transport BIP324 v2 est-il redondant sur les connexions Tor et I2P?]({{bse}}121360)
  Pieter Wuille admet un manque d'avantages de chiffrement [v2 transport][topic v2 p2p transport]
  lors de l'utilisation de [réseaux d'anonymat][topic anonymity networks]
  mais note des améliorations potentielles en termes de calcul par rapport au transport non chiffré v1.

- [Quelle règle empirique pour définir le nombre maximum de connexions?]({{bse}}121088)
  Pieter Wuille fait la distinction entre les connexions sortantes et entrantes
  et énumère les considérations liées à la définition de valeurs plus élevées pour `-maxconnections`.

- [Pourquoi la limite supérieure (+2h) sur le timestamp du bloc n'est-elle pas définie en tant que règle de consensus?]({{bse}}121248)
  Dans cette question et [d'autres]({{bse}}121247) [questions]({{bse}}121253) connexes, Pieter
  Wuille explique l'exigence selon laquelle le timestamp d'un nouveau bloc ne doit pas être postérieur
  à deux heures dans le futur, l'importance de cette exigence et pourquoi "les règles de consensus ne peuvent dépendre que des informations qui sont confirmées par les hachages de bloc".

- [Comptage des sigop et son influence sur la sélection des transactions?]({{bse}}121355)
  L'utilisateur Cosmik Debris demande comment la limite des opérations de vérification de signature, "sigops", affecte la construction
  du modèle de bloc des mineurs et l'[estimation des frais][topic fee estimation] basée sur le mempool. L'utilisateur mononaut explique
  la rareté des sigops en tant que facteur limitant dans la construction du modèle de bloc et discute de l'option `-bytespersigop`.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [HWI 2.4.0][] est une version de la prochaine version de ce
  package fournissant une interface commune à plusieurs dispositifs de
  signature matérielle différents. La nouvelle version ajoute la prise en charge de Trezor Safe 3 et
  contient plusieurs améliorations mineures.

## Modifications notables du code et de la documentation

_Modifications notables récentes dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille
matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'amélioration
Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana
repo]._

- [Bitcoin Core #29291][] ajoute un test qui échouera si une transaction exécutant un opcode `OP_CHECKSEQUENCEVERIFY` semble avoir un
  numéro de version négatif.  Ce test, s'il avait été exécuté par des implémentations alternatives de consensus, aurait détecté le bug
  d'échec du consensus mentionné dans [la bulletin de la semaine dernière][news286 bip68ver].

- [Eclair #2811][], [#2813][eclair #2813] et [#2814][eclair #2814] ajoutent la possibilité pour un [paiement de trampoline][topic
  trampoline payments] d'utiliser un [chemin aveugle][topic rv routing] pour le destinataire final. Le routage du trampoline lui-même
  continue d'utiliser des identifiants de nœud chiffrés par oignon réguliers, c'est-à-dire que chaque nœud trampoline apprend
  l'identifiant du prochain nœud trampoline. Cependant, si un chemin aveugle est utilisé, le dernier nœud trampoline n'apprendra
  désormais que l'identifiant du nœud d'introduction dans le chemin aveugle; il n'apprendra pas l'identifiant du destinataire final.

  Auparavant, la confidentialité du trampoline fort dépendait de l'utilisation de plusieurs expéditeurs de trampoline de sorte que
  aucun des expéditeurs ne pouvait être sûr d'être le dernier expéditeur. L'inconvénient de cette approche est qu'elle utilisait des
  chemins plus longs qui augmentaient la probabilité d'échec de l'acheminement et nécessitaient le paiement de frais d'acheminement
  supplémentaires pour réussir. Maintenant, le fait de faire transiter les paiements par un seul nœud trampoline peut empêcher ce nœud
  d'apprendre le destinataire final.

- [LND #8167][] permet à un nœud LND de fermer mutuellement un canal qui a encore un ou plusieurs paiements en attente
  ([HTLC][topic htlc]). La spécification [BOLT2][] indique que la procédure appropriée consiste pour une partie à envoyer un message
  `shutdown`, après quoi aucun nouveau HTLC ne sera accepté. Une fois que tous les HTLC en attente sont résolus off-chain, les deux
  parties négocient et signent une transaction de fermeture mutuelle. Auparavant, lorsque LND recevait un message `shutdown`, il forçait
  la fermeture du canal, ce qui nécessitait des transactions et des frais supplémentaires pour régler.

- [LND #7733][] met à jour la prise en charge des [tour de guets][topic watchtowers] pour permettre la sauvegarde et l'application de la
  fermeture correcte des [canaux simples taproot][topic simple taproot channels] qui sont maintenant pris en charge de manière
  expérimentale par LND.

- [LND #8275][] commence à exiger que les pairs prennent en charge certaines fonctionnalités universellement déployées telles que
  spécifiées dans [BOLTs #1092][] (voir le [Bulletin #259][news259 lncleanup]).

- [Rust Bitcoin #2366][] déprécie la méthode `.txid()` sur les objets `Transaction` et commence à fournir une méthode de remplacement
  nommée `.compute_txid()`. Chaque fois que la méthode `.txid()` est appelée, l'identifiant de transaction est calculé, ce qui consomme
  suffisamment de CPU pour être préoccupant pour toute personne exécutant la fonction sur de grandes transactions ou de nombreuses
  transactions plus petites. On espère que le nouveau nom de la méthode aidera les programmeurs en aval à réaliser ses coûts potentiels.
  Les méthodes `.wtxid()` et `.ntxid()` (respectivement basées sur [BIP141][] et [BIP140][]) sont également renommées en
  `.compute_wtxid()` et `.compute_ntxid()`.

- [HWI #716][] ajoute la prise en charge du dispositif de signature matérielle Trezor Safe 3.

- [BDK #1172][] ajoute une API bloc par bloc pour le portefeuille. Un utilisateur ayant accès à une séquence de blocs peut itérer sur
  ces blocs pour mettre à jour le portefeuille en fonction des transactions dans ces blocs. Cela peut être utilisé pour synchroniser
  un portefeuille avec la blockchain et mettre à jour les soldes et les transactions. Cela permet une intégration plus étroite entre
  le portefeuille et la blockchain, offrant une meilleure expérience utilisateur. Cela peut simplement être utilisés pour itérer sur
  chaque bloc d'une chaîne. Alternativement, le logiciel peut utiliser une sorte de méthode de filtrage (par exemple, [filtres de bloc
  compacts][topic compact block filters]) pour trouver uniquement les blocs susceptibles de contenir des transactions affectant le
  portefeuille, et itérer sur ce sous-ensemble de blocs.

- [BINANAs #3][] ajoute [BIN24-5][] avec une liste de référentiels de spécifications liés à Bitcoin, tels que BIPs, BOLTs, BLIPs, SLIPs,
  LNPBPs et spécifications DLC. Certains référentiels de spécifications pour d'autres projets connexes sont également répertoriés.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29291,2811,2813,2814,8167,7733,8275,1092,2366,716,1172,3" %}
[hwi 2.4.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0
[news286 bip68ver]: /fr/newsletters/2024/01/24/#divulgation-de-la-defaillance-de-consensus-corrigee-dans-btcd
[trezor safe 3]: https://trezor.io/trezor-safe-3
[news283 fdt]: /fr/newsletters/2024/01/03/#timelocks-dependant-des-frais
[zhao v3kindred]: https://delvingbitcoin.org/t/sibling-eviction-for-v3-transactions/472
[news259 lncleanup]: /fr/newsletters/2023/07/12/#proposition-de-nettoyage-de-la-specification-ln
[news284 ptexogenous]: /fr/newsletters/2024/01/10/#l-utilisation-frequente-de-frais-exogenes-peut-compromettre-la-decentralisation-du-minage
[zhao kindredimpl]: https://github.com/bitcoin/bitcoin/pull/29306
[pt ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022309.html
[news286 imbued]: /fr/newsletters/2024/01/24/#logique-imbriquee-v3
[news216 headers presync]: /fr/newsletters/2022/09/07/#bitcoin-core-25717
