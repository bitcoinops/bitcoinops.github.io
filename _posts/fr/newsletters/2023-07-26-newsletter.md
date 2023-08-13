---
title: 'Bulletin Hebdomadaire Bitcoin Optech #261'
permalink: /fr/newsletters/2023/07/26/
name: 2023-07-26-newsletter-fr
slug: 2023-07-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un protocole visant à simplifier la communication liée à la fermeture mutuelle des canaux LN
et résume les notes d'une récente réunion des développeurs LN. Sont également incluses nos rubriques habituelles avec des questions
et réponses populaires de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et versions candidates, ainsi
que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Protocole de fermeture LN simplifié :** Rusty Russell a [publié][russell closing]
  sur la liste de diffusion Lightning-Dev une proposition visant à simplifier le processus de fermeture mutuelle d'un canal LN
  partagé par deux nœuds. Avec le nouveau protocole de fermeture, l'un des nœuds informe son pair qu'il souhaite fermer le canal
  et indique le montant des frais de transaction qu'il paiera. L'initiateur de la fermeture sera responsable de l'intégralité des
  frais, bien que les deux sorties d'une transaction de fermeture mutuelle typique soient immédiatement dépensables, de sorte que
  chaque partie puisse utiliser [l'augmentation des frais CPFP][topic cpfp] dans le cas normal. Le nouveau protocole est également
  compatible avec l'échange d'informations pour les [multisignatures sans script basées sur MuSig2][topic multisignature], qui font
  partie des mises à niveau en cours de développement pour LN et qui amélioreront la confidentialité et réduiront les frais onchain.

    Aucun commentaire sur la proposition de Russell n'avait été publié sur la liste de diffusion à l'heure de la rédaction de cet
    article, mais quelques commentaires initiaux avaient été publiés sur sa [demande de PR][bolts #1096] avec la proposition
    complète. {% assign timestamp="1:03" %}

- **Notes du sommet LN:** Carla Kirk-Cohen a [publié][kc notes] sur la liste de diffusion Lightning-Dev un résumé de plusieurs
  discussions de la récente réunion des développeurs LN à New York. Certaines des discussions ont porté sur les sujets suivants :
  {% assign timestamp="10:48" %}

    - *Confirmation fiable des transactions :* [relais de paquets][topic package relay], [relais de transactions
      v3][topic v3 transaction relay], [points d'ancrage éphémères][topic ephemeral anchors], [mempool en
      grappe][topic cluster mempool] et d'autres sujets liés au relais de transactions et à l'extraction minière ont été discutés
      dans le contexte dont ils permettront de confirmer de manière plus fiable les transactions LN onchain, sans la
      menace d'épinglage de [transaction][topic transaction pinning] ou la nécessité de payer des frais excessifs lors de
      l'utilisation de [CPFP][topic cpfp] ou de [RBF][topic rbf] pour augmenter les frais. Nous recommandons vivement aux lecteurs
      intéressés par la politique de relais de transactions, qui affecte presque tous les protocoles de deuxième couche, de lire
      les notes pour les commentaires éclairés fournis par les développeurs LN sur plusieurs initiatives en cours.

    - *Canaux Taproot et MuSig2 :* une brève discussion sur l'avancement des canaux utilisant des sorties [P2TR][topic taproot]
      et des signatures [MuSig2][topic musig]. Une partie importante des notes de cette discussion portait sur un protocole de
      fermeture mutuelle simplifié ; voir l'article précédent pour l'un des résultats de cette discussion.

    - *Annonces de canaux mises à jour :* le protocole de diffusion LN ne relaie actuellement les annonces de nouveaux canaux ou
      de canaux mis à jour que si ces canaux ont été financés à l'aide d'une sortie P2WSH qui s'est engagée à un script
      `OP_CHECKMULTISIG` 2-sur-2. Pour passer aux sorties [P2TR][topic taproot] avec des engagements de [multisignature sans
      script][topic multisignature] basés sur [MuSig2][topic musig], le protocole de diffusion devra être mis à jour. Un
      [sujet][topic channel announcements] a également été discuté lors de la précédente réunion en personne des développeurs LN
      (voir [Newsletter #204][news204 gossip]) pour savoir s'il convient de faire une mise à jour minimale du protocole (appelée
      v1.5 gossip) qui ajoute simplement la prise en charge des sorties P2TR, ou une mise à jour plus générale du protocole
      (appelée v2.0) qui permet plus largement l'utilisation d'une signature valide pour n'importe quelle UTXO de n'importe quel
      type pour les annonces. Permettre l'utilisation de n'importe quelle sortie signifie que la sortie utilisée pour annoncer
      le canal est moins susceptible qu'aujourd'hui d'être la sortie réellement utilisée pour exploiter le canal, rompant ainsi
      le lien public entre les sorties et le financement du canal.

      Une autre considération discutée était de savoir si une UTXO d'une valeur de _n_ devrait être autorisée à annoncer un canal
      d'une capacité supérieure à _n_. Cela permettrait aux participants du canal de garder certaines de leurs transactions de
      financement privées. Par exemple, Alice et Bob pourraient ouvrir deux canaux distincts entre eux ; ils pourraient utiliser
      un canal pour créer une annonce d'une valeur supérieure à celle du canal, indiquant ainsi qu'ils pourraient transférer
      des paiements LN d'une valeur supérieure à la capacité de ce canal en utilisant leur autre canal qui n'avait pas été
      associé à une UTXO et qui était donc plus privé. Cela contribuerait à augmenter la plausibilité que n'importe quelle
      sortie sur le réseau, même une qui n'aurait jamais été divulguée dans LN, soit utilisée pour un canal LN.

      Les notes indiquent une décision de compromis, "v1.75 gossip", qui semblait permettre l'utilisation de n'importe quel script
      mais sans multiplicateur de valeur disponible.

    - *PTLCs et surpaiement redondant* : d'après les notes, l'ajout de la prise en charge des [PTLCs][topic ptlc] dans le protocole
      a été brièvement discuté, principalement en relation avec les [adaptateurs de signature][topic adaptor signatures]. Les notes
      étaient notamment consacrées à une amélioration qui affecterait des parties similaires du protocole : la possibilité de
      [surpayer de manière redondante][topic redundant overpayments] une facture et de recevoir un remboursement pour la plupart ou
      la totalité du surpaiement. Par exemple, Alice souhaite finalement payer Bob 1 BTC. Elle envoie initialement à Bob
      20 paiements [multipath][topic multipath payments] d'une valeur de 0,1 BTC chacun. En utilisant soit des mathématiques (via une technique appelée _Boomerang_, voir [Newsletter #86][news86 boomerang]) soit des engagements en couches et un tour de communication supplémentaire (appelé _Spear_), Bob ne peut réclamer qu'un maximum de 10 des paiements ; tous les autres qui arrivent à son nœud sont rejetés. L'avantage de cette approche est que jusqu'à 10 des fragments MPP d'Alice peuvent ne pas parvenir à Bob sans retarder le paiement. Les inconvénients semblent être une complexité supplémentaire et éventuellement (dans le cas de Spear) une vitesse plus lente qu'aujourd'hui dans le meilleur des cas où chaque fragment atteint Bob. Les participants ont discuté de la possibilité d'apporter des modifications qui pourraient aider à prendre en charge les surpaiements redondants en même temps que les modifications nécessaires pour les PTLCs.

   -  *Propositions d'atténuation des attaques de saturation des canaux* : une partie importante des notes résumait la discussion
      sur les propositions visant à atténuer les [attaques de saturation des canaux][topic channel jamming attacks]. La discussion
      a commencé par l'affirmation qu'aucune solution unique connue (comme la réputation ou les frais préalables) ne peut résoudre de manière satisfaisante le problème sans produire d'inconvénients inacceptables. La réputation à elle seule doit tenir compte des nouveaux nœuds sans réputation et du taux naturel d'échec des HTLC, des dispositions que l'attaquant peut utiliser pour causer un certain niveau de préjudice, même s'il est inférieur à ce qu'il pourrait faire aujourd'hui. Les frais préalables seuls doivent être fixés suffisamment élevés pour dissuader les attaquants, mais cela pourrait être suffisamment élevé pour dissuader également les utilisateurs honnêtes et créer une incitation perverse pour que les nœuds échouent délibérément à transférer un paiement. Au lieu de cela, il a été proposé que l'utilisation de plusieurs méthodes ensemble puisse permettre d'obtenir les avantages sans produire les coûts les plus élevés.

      Après avoir examiné la compréhension actuelle, les notes de discussion se sont concentrées sur les détails concernant
      les tests du schéma de réputation locale décrit dans [Newsletter #226][news226 jamming] et la préparation d'une future mise en œuvre de frais préalables réduits pour l'accompagner. D'après les notes, il semblait que les participants soutenaient l'idée de voir la proposition testée.

   - *Engagements simplifiés* : les participants ont discuté de l'idée de protocole d'engagements simplifiés (voir
     [Newsletter #120][news120 commitments]), qui définit lequel des pairs est responsable de proposer la prochaine modification
     de la transaction d'engagement plutôt que de permettre à chaque pair de proposer une nouvelle transaction d'engagement à tout moment. Le fait de confier cette responsabilité à un pair élimine la complexité liée à l'envoi simultané de deux propositions, par exemple si Alice et Bob veulent tous deux ajouter un [HTLC][topic htlc] en même temps. Une complication particulière discutée dans les notes était les cas où l'un des pairs ne voulait pas accepter la proposition de l'autre pair, une situation difficile à résoudre dans le protocole actuel. Un inconvénient de l'approche des engagements simplifiés est qu'elle peut augmenter la latence dans certains cas, car le pair qui n'est pas actuellement responsable de proposer la prochaine modification devra demander ce privilège à son homologue avant de procéder. Les notes n'indiquaient pas de résolution claire à cette discussion.

    - *Le processus de spécification* : les participants ont discuté de diverses idées pour améliorer le processus de spécification
      et les documents qu'il gère, y compris les BOLTs et BLIPs actuels ainsi que d'autres idées de documentation. La discussion semblait très variée et aucune conclusion claire n'était apparente d'après les notes.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
  questions, ou lorsque nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique
  mensuelle, nous mettons en évidence certaines des questions et réponses les plus votées publiées depuis notre dernière mise
  à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Comment puis-je calculer manuellement (sur papier) une clé publique Bitcoin à partir d'une clé privée ?]({{bse}}118933)
  Andrew Poelstra donne un aperçu des techniques de vérification par calcul manuel, comme [codex32][news239 codex32], avant de
  décrire comment une clé publique pourrait être dérivée à la main à partir d'une clé privée, un processus qu'il estime prendre
  au moins 1500 heures, même avec des optimisations du processus. {% assign timestamp="57:18" %}

- [Pourquoi y a-t-il 17 versions natives segwit ?]({{bse}}118974)
  Murch explique que [segwit][topic segwit] a défini 17 valeurs (0-16) pour le champ de [version témoin][bip141 witness program] en
  raison de la disponibilité existante des opcodes constants OP_0...OP_16 dans [Script][wiki script]. Il note que des nombres
  supplémentaires nécessiteraient l'utilisation d'opcodes `OP_PUSHDATA` moins efficaces en termes de données. {% assign
  timestamp="59:43" %}

- [Est-ce que `0 OP_CSV` force la transaction de dépense à signaler la remplaçabilité BIP125 ?]({{bse}}115586)
  Murch fait référence à une [discussion][rbf csv discussion] confirmant que puisque à la fois le [verrouillage
  temporel][topic timelocks] `OP_CHECKSEQUENCEVERIFY` (CSV) et le remplacement par frais ([RBF][topic rbf]) sont
  [appliqués]({{bse}}87376) en utilisant le champ `nSequence`, une sortie avec `0 OP_CSV` nécessite que la transaction
  de dépense signale la remplaçabilité [BIP125][]. {% assign timestamp="1:03:04" %}

- [Comment les indices de route affectent-ils la recherche de chemin ?]({{bse}}118755)
  Christian Decker explique deux raisons pour lesquelles un destinataire LN fournirait des indices de route à un expéditeur.
  Une raison est si le destinataire utilise des [canaux non annoncés][topic unannounced channels] et que des indices sont
  nécessaires pour aider à trouver un chemin. L'autre raison est de fournir à l'expéditeur une liste de canaux ayant un solde
  suffisant pour effectuer le paiement, une technique qu'il appelle "route boost". {% assign timestamp="1:08:23" %}

- [Que signifie que la sécurité de l'ECDSA 256 bits, et donc des clés Bitcoin, est de 128 bits ?]({{bse}}118928)
  Pieter Wuille précise que, en raison d'algorithmes qui peuvent dériver une clé privée à partir d'une clé publique de manière
  plus efficace qu'une recherche par force brute, l'ECDSA 256 bits ne fournit qu'une sécurité de 128 bits. Il souligne ensuite
  la différence entre la sécurité des clés individuelles et la sécurité des [semences][topic bip32].
  {% assign timestamp="1:12:26" %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [HWI 2.3.0][] est une version intermédiaire de cette interface qui permet aux portefeuilles logiciels de communiquer avec des
  dispositifs de signature matériels. Elle ajoute la prise en charge des dispositifs Jade DIY et un binaire pour exécuter le
  programme principal `hwi` sur du matériel Apple Silicon avec MacOS 12.0+. {% assign timestamp="1:15:09" %}

- [LDK 0.0.116][] est une version de cette bibliothèque permettant de créer des logiciels compatibles LN. Elle inclut la prise
  en charge des [sorties d'ancrage][topic anchor outputs] et des [paiements multipath][topic multipath payments] avec
  [keysend][topic spontaneous payments]. {% assign timestamp="1:16:37" %}

## Modifications de code et de documentation notables

*Modifications notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille
Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core GUI #740][] met à jour la boîte de dialogue des opérations [PSBT][topic psbt] pour marquer les sorties payant
  votre propre portefeuille avec "adresse propre". Cela facilite l'évaluation du résultat d'un PSBT importé, en particulier
  lorsque la transaction renvoie de la monnaie au destinataire. {% assign timestamp="1:17:18" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="740,1096" %}
[russell closing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004013.html
[kc notes]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004014.html
[news193 gossip]: /en/newsletters/2022/03/30/#continued-discussion-about-updated-ln-gossip-protocol
[news204 gossip]: /en/newsletters/2022/06/15/#gossip-network-updates
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[news226 jamming]: /fr/newsletters/2022/11/16/#document-sur-les-attaques-par-brouillage-de-canaux
[news120 commitments]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[hwi 2.3.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.0
[ldk 0.0.116]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.116
[news239 codex32]: /fr/newsletters/2023/02/22/#proposition-de-bip-pour-le-systeme-d-encodage-des-semences-codex32
[bip141 witness program]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#witness-program
[wiki script]: https://en.bitcoin.it/wiki/Script#Constants
[rbf csv discussion]: https://twitter.com/SomsenRuben/status/1683056160373391360