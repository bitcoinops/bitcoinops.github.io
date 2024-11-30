---
title: 'Bulletin Hebdomadaire Bitcoin Optech #331'
permalink: /fr/newsletters/2024/11/29/
name: 2024-11-29-newsletter
slug: 2024-11-29-newsletter
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume plusieurs discussions récentes sur un
dialecte Lisp pour le scripting Bitcoin et inclut nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Dialecte Lisp pour le scripting Bitcoin :** Anthony Towns a fait plusieurs
  publications sur la continuation de son [travail][topic bll] sur la création d'un
  dialecte Lisp pour Bitcoin qui pourrait être ajouté à Bitcoin dans un
  soft fork.

  - *bll, symbll, bllsh :* Towns [note][towns bllsh1] qu'il a passé beaucoup
    de temps à réfléchir aux conseils du développeur de Chia Lisp, Art Yerkes,
    sur l'assurance d'une bonne correspondance entre le code de haut niveau (ce que
    les programmeurs écrivent typiquement) et le code de bas niveau (ce qui est réellement exécuté,
    généralement créé à partir du code de haut niveau par les compilateurs). Il
    a décidé d'adopter une approche similaire à [miniscript][topic miniscript] où
    "vous traitez le langage de haut niveau comme une variation amicale du
    langage de bas niveau (comme le fait miniscript avec script)". Le résultat est
    deux langages et un outil :

    - *Basic Bitcoin Lisp language (bll)* est le langage de bas niveau
      qui pourrait être ajouté à Bitcoin dans un soft fork. Towns dit que bll est
      similaire à BTC Lisp selon sa dernière mise à jour (voir le [Bulletin
      #294][news294 btclisp]).

    - *Symbolic bll (symbll)* est le langage de haut niveau qui est
      converti en bll. Il devrait être relativement facile pour quiconque
      déjà familier avec la programmation fonctionnelle.

    - *Bll shell (bllsh)* est un [REPL][] qui permet à un utilisateur de tester
      des scripts en bll et symbll, de compiler de symbll à bll, et d'exécuter
      du code avec des capacités de débogage.

  - *Implémenter des signatures résistantes aux quantiques dans symbll versus GSR :* Towns
    [lie][towns wots] à un [post Twitter][nick wots] de Jonas Nick
    sur l'implémentation des signatures Winternitz One Time (WOTS+) en utilisant
    les opcodes existants et les opcodes spécifiés dans la proposition de _great script restoration_
    (GSR) [proposé par][russell gsr] de Rusty Russell. Towns
    compare ensuite l'implémentation de WOTS en utilisant symbll dans bllsh. Cela réduit
    la quantité de données qui devraient être placées onchain d'au moins
    83 % et potentiellement de plus de 95 %. Cela pourrait permettre l'utilisation de
    [signatures résistantes aux quantiques][topic quantum resistance] à un coût seulement
    30 fois supérieur à celui des sorties P2WPKH.

  - *Marquages flexibles de pièces :* Towns [décrit][towns earmarks] une
    construction générique compatible avec symbll (et probablement
    [Simplicity][topic simplicity]) qui permet de partitionner un UTXO en
    montants spécifiques et conditions de dépense. Si une condition de dépense
    est remplie, le montant associé peut être dépensé et le reste
    de la valeur du UTXO est retournée à un nouveau UTXO avec les conditions restantes. Une condition
    alternative peut également être satisfaite pour permettre de dépenser l'intégralité du UTXO ; par
    exemple, cela pourrait permettre à toutes les parties de convenir de mettre à jour certaines des
    conditions. C'est un type flexible de mécanisme de [covenant][topic covenants], similaire à la
    proposition précédente de Towns pour `OP_TAP_LEAF_UPDATE_VERIFY` (TLUV, voir le [Bulletin
    #166][news166 tluv]), mais Towns a [écrit précédemment][towns badcov] qu'il pense que _covenants_
    n'est "pas un terme précis ou utile".

    Plusieurs exemples d'utilisation de ces _pièces de monnaie flexibles affectées à un usage particulier_
    sont fournis, incluant des
    améliorations dans la sécurité et l'usabilité des canaux LN (incluant les canaux basés sur
    [LN-Symmetry][topic eltoo]), une alternative à la version [BIP345][] de [coffre-forts][topic vaults], et
    un design de [pool de paiements][topic joinpools] similaire à celui envisagé pour une utilisation avec
    TLUV mais qui évite les problèmes que cette proposition avait avec les [clés publiques x-only][topic
    x-only public keys].

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions - ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les plus votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Comment ColliderScript améliore-t-il Bitcoin et quelles fonctionnalités permet-il ?]({{bse}}124690)
  Victor Kolobov liste les utilisations potentielles pour ColliderScript (voir le [Bulletin
  #330][news330 cs] et le [Podcast #330][pod330 cs]) incluant les [covenants][topic covenants],
  [coffre-forts][topic vaults], l'émulation de [CSFS][topic op_checksigfromstack], et les rollups de
  validité (voir le [Bulletin #222][news222 validity rollups]) tout en notant les coûts computationnels
  élevés de telles transactions.

- [Pourquoi les règles de standardité limitent-elles le poids des transactions ?]({{bse}}124636)
  Murch fournit des arguments pour et contre les limites de poids de standardité de Bitcoin Core et
  décrit comment la demande économique pour des transactions plus grandes pourrait éroder l'efficacité
  de la [politique][policy series].

- [Le scriptSig dépensant une sortie PayToAnchor est-il toujours censé être vide ?]({{bse}}124615)
  Pieter Wuille souligne que, en raison de la manière dont les sorties [pay-to-anchor (P2A)][topic
  ephemeral anchors] sont [construites][news326 p2a], elles doivent adhérer aux conditions de dépense
  segwit, incluant un scriptSig vide.

- [Que se passe-t-il avec les sorties P2A inutilisées ?]({{bse}}124617)
  Instagibbs note que les sorties P2A inutilisées seront finalement balayées lorsque le taux de frais
  d'inclusion dans un bloc sera suffisamment bas pour rendre le balayage rentable, les retirant ainsi
  de l'ensemble UTXO. Il continue en référençant
  la récente fusion du PR [de poussière éphémère][news330 ed] qui permet une sortie unique en dessous du
  seuil de poussière dans une transaction sans frais, à condition qu'une [transaction enfant][topic
  cpfp] la dépense immédiatement.

- [Pourquoi l'algorithme PoW de Bitcoin n'utilise-t-il pas une chaîne de hachages de difficulté inférieure ?]({{bse}}124777)
  Pieter Wuille et Vojtěch Strnad décrivent la pression vers la centralisation du minage qui se
  produirait si la propriété d'absence de progrès du minage de Bitcoin était violée avec une telle approche.

- [Clarification sur la valeur fausse dans Script]({{bse}}124673)
  Pieter Wuille précise les trois valeurs qui sont évaluées comme fausses dans le Script Bitcoin : un
  tableau vide, un tableau de bytes 0x00, et un tableau de bytes 0x00 avec un 0x80 à la fin. Il note
  que toutes les autres valeurs sont évaluées comme vraies.

- [Qu'est-ce que cette étrange microtransaction dans mon portefeuille ?]({{bse}}124744)
  Vojtěch Strnad explique les mécanismes d'une attaque par empoisonnement d'adresse et les moyens de
  mitiger de telles attaques.

- [Existe-t-il des UTXOs qui ne peuvent pas être dépensés ?]({{bse}}124865)
  Pieter Wuille fournit deux exemples de sorties qui sont inexploitables indépendamment de la
  violation des hypothèses cryptographiques : les sorties `OP_RETURN` et les sorties avec un
  scriptPubKey de plus de 10 000 bytes.

- [Pourquoi BIP34 n'a-t-il pas été implémenté via le locktime ou nSequence de la transaction coinbase ?]({{bse}}75987)
  Antoine Poinsot revient sur cette question plus ancienne pour souligner que la valeur `nLockTime` de
  la transaction coinbase ne peut pas être définie à la hauteur du bloc actuel parce que le
  [locktime][topic timelocks] représente le dernier bloc auquel une transaction est *invalidée*.

## Mises à jour et versions candidates

_Nouvelles mises-à-jours et candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles mises-à-jour ou d'aider à tester les versions candidates._

- [Core Lightning 24.11rc2][] est un candidat à la sortie pour la prochaine version majeure de cette
  implémentation populaire de LN.

- [BDK 0.30.0][] est une sortie de cette bibliothèque pour construire des portefeuilles et d'autres
  applications activées par Bitcoin. Elle inclut plusieurs corrections de bugs mineurs et prépare pour
  la mise à niveau anticipée à la version 1.0 de la bibliothèque.

- [LDK 0.18.4-beta.rc1][] est un candidat à la sortie pour une version mineure de cette
  implémentation populaire de LN.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31122][] implémente une interface `changeset` pour le mempool,
  permettant à un nœud de calculer l'impact d'un ensemble proposé de changements sur l'état du
  mempool. Par exemple, vérifier si les limites d'ancêtre/descendant/[TRUC][topic v3 transaction
  relay] (et les limites de cluster futur) sont violées lorsqu'une transaction ou un paquet est
  accepté, ou déterminer si une majoration des frais [RBF][topic RBF] améliore l'état du mempool.
  Cette PR fait partie du projet de [mempool en cluster][topic cluster mempool].

- [Core Lightning #7852][] restaure la compatibilité avec les versions antérieures à 24.08 pour le
  plugin `pyln-client` (une bibliothèque cliente Python) en réintroduisant un champ de description.

- [Core Lightning #7740][] améliore le solveur de flux de coût minimum (MCF) du plugin `askrene`
  (voir le [Bulletin #316][news316 askrene]) en fournissant une API qui abstrait la complexité de la
  résolution MCF pour permettre une intégration plus facile des algorithmes de calcul de flux basés
  sur des graphes récemment ajoutés. Le solveur adopte la même linéarisation de la fonction de coût de
  canal que `renepay`(voir le [Bulletin #263][news263 renepay]), ce qui améliore la fiabilité de la
  recherche de chemin, et introduit le support pour des unités personnalisables au-delà des msats,
  permettant une plus grande scalabilité pour les paiements importants. Cette PR ajoute les méthodes
  `simple_feasibleflow`, `get_augmenting_flow`, `augment_flow`, et `node_balance` pour améliorer
  l'efficacité des calculs de flux.

- [Core Lightning #7719][] réalise l'interopérabilité avec Eclair pour le [splicing][topic
  splicing], permettant l'exécution de splices entre les deux implémentations. Cette PR introduit
  plusieurs changements pour s'aligner sur l'implémentation d'Eclair, y compris le support pour la
  rotation des clés de financement à distance, l'ajout de `batch_size` pour les messages signés
  d'engagement, empêchant la transmission des transactions de financement précédentes en raison des
  limites de taille de paquet, supprimant les blockhashes des messages, et ajustant les soldes de
  sortie de financement prédéfinis.

- [Eclair #2935][] ajoute une notification à l'opérateur du nœud en cas de force close d'un canal
  initié par un pair du canal.

- [LDK #3137][] ajoute le support pour l'acceptation de canaux à double financement initiés par des
  pairs, bien que le financement ou la création de tels canaux ne soit pas encore pris en charge. Si
  `manually_accept_inbound_channels` est réglé sur false, les canaux sont automatiquement acceptés,
  tandis que la fonction `ChannelManager::accept_inbound_channel()` permet une acceptation manuelle.
  Un nouveau champ `channel_negotiation_type` est introduit pour distinguer entre les demandes
  entrantes pour les canaux à double financement et ceux sans double financement. Les canaux à double
  financement [Zero-conf][topic zero-conf channels] et la majoration des frais [RBF][topic rbf] des
  transactions de financement ne sont pas pris en charge.

- [LND #8337][] introduit le package `protofsm`, un cadre réutilisable pour créer des machines à
  états finis (FSM) protocolaires pilotées par événements dans LND. Au lieu d'écrire du code standard
  pour gérer les états, les transitions et les événements, les développeurs peuvent définir les états,
  ce qui déclenche les événements, et les règles pour passer entre eux, et l'interface `State`
  encapsulera le comportement, gérera les événements, et déterminera les états terminaux, tandis que
  les adaptateurs de daemon gèrent les effets secondaires comme la diffusion de transactions et
  l'envoi de messages aux pairs.

{% include references.md %}
{% include linkers/issues.md v=2 issues="31122,7852,7740,7719,2935,3137,8337" %}
[news294 btclisp]: /fr/newsletters/2024/03/20/#apercu-de-btc-lisp
[russell gsr]: https://github.com/rustyrussell/bips/pull/1
[towns bllsh1]: https://delvingbitcoin.org/t/debuggable-lisp-scripts/1224
[repl]: https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
[towns wots]: https://delvingbitcoin.org/t/winternitz-one-time-signatures-contrasting-between-lisp-and-script/1255
[nick wots]: https://x.com/n1ckler/status/1854552545084977320
[towns earmarks]: https://delvingbitcoin.org/t/flexible-coin-earmarks/1275
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[towns badcov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[core lightning 24.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc2
[bdk 0.30.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.0
[ldk 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 askrene]: /fr/newsletters/2024/08/16/#core-lightning-7517
[news263 renepay]: /fr/newsletters/2023/08/09/#core-lightning-6376
[news330 cs]: /fr/newsletters/2024/11/22/#covenants-bases-sur-la-rectification-plutot-que-sur-des-changements-de-consensus
[pod330 cs]: /en/podcast/2024/11/26/#covenants-based-on-grinding-rather-than-consensus-changes
[news222 validity rollups]: /fr/newsletters/2022/10/19/#recherche-sur-les-rollups-de-validite
[policy series]: /fr/blog/waiting-for-confirmation/
[news326 p2a]: /fr/newsletters/2024/10/25/#comment-la-structure-du-pay-to-anchor-a-t-elle-ete-decidee
[news330 ed]: /fr/newsletters/2024/11/22/#bitcoin-core-30239