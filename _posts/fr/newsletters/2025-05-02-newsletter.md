---
title: 'Bulletin Hebdomadaire Bitcoin Optech #352'
permalink: /fr/newsletters/2025/05/02/
name: 2025-05-02-newsletter-fr
slug: 2025-05-02-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine propose des comparaisons entre différentes techniques de
linéarisation de clusters et résume brièvement les discussions sur l'augmentation ou la suppression
de la limite de taille `OP_RETURN` de Bitcoin Core. Sont également incluses nos sections régulières
annonçant de nouvelles versions et versions candidates, ainsi que le résumé des
modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Comparaison des techniques de linéarisation de clusters :**
  Pieter Wuille a [publié][wuille clustrade] sur Delving Bitcoin à propos de certains des compromis
  fondamentaux entre trois différentes techniques de linéarisation de clusters, en suivant avec des
  [benchmarks][wuille clusbench] des implémentations de chacune. Plusieurs autres développeurs ont
  discuté des résultats et posé des questions de clarification, auxquelles Wuille a répondu.

- **Augmentation ou suppression de la limite de taille `OP_RETURN` de Bitcoin Core :**
  dans un fil de discussion sur Bitcoin-Dev, plusieurs développeurs ont discuté de la modification ou
  de la suppression de la limite par défaut de Bitcoin Core pour les sorties de porteur de données
  `OP_RETURN`. Une [pull request][bitcoin core #32359] ultérieure de Bitcoin Core a vu une discussion
  supplémentaire. Plutôt que de tenter de résumer l'ensemble de la discussion volumineuse, nous
  résumerons ce que nous pensions être l'argument le plus convaincant pour et contre le changement.

- *Pour augmenter (ou éliminer) la limite :* Pieter Wuille a [fait valoir][wuille opr] que la
  politique de standardisation des transactions est peu susceptible d'empêcher de manière significative la
  confirmation de transactions portant des données créées par des organisations bien financées qui
  feront les efforts nécessaires pour envoyer les transactions directement aux mineurs. Il
  ajoute que les blocs sont généralement pleins, qu'ils contiennent ou non des transactions portant
  des données, donc la quantité totale de données qu'un nœud doit stocker est à peu près la même dans
  les deux cas.

- *Contre l'augmentation de la limite :* Jason Hughes a [argumenté][hughes opr] qu'augmenter la
  limite rendrait plus facile le stockage de données arbitraires sur les ordinateurs exécutant des
  nœuds complets, et que certaines de ces données pourraient être hautement contestables (y compris
  illégales dans la plupart des juridictions). Même si le nœud chiffre les données sur le disque (voir
  le [Bulletin #316][news316 blockxor]), le stockage des données et la capacité de les récupérer en
  utilisant les RPC de Bitcoin Core pourraient poser problème à de nombreux utilisateurs.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [LND 0.19.0-beta.rc3][] est un candidat à la version pour ce nœud LN populaire. L'une des
  principales améliorations qui pourrait probablement nécessiter des tests est le nouveau bumping de
  frais basé sur RBF pour les fermetures coopératives.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Propositions (BIPs)][bips repo], [Lightning BOLTs][bolts repo],[Lightning BLIPs][blips repo],
[Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31250][] désactive la création et le chargement des portefeuilles hérités,
  complétant ainsi la migration vers les portefeuilles [descriptor][topic descriptors] qui sont
  devenus le standard depuis octobre 2021 (voir le Bulletin [#172][news172 descriptors]). Les fichiers
  Berkeley DB utilisés par les portefeuilles hérités ne peuvent plus être chargés, et tous les tests
  unitaires et fonctionnels pour ces portefeuilles sont supprimés. Certains codes de portefeuille
  hérité restent, mais seront retirés dans des PRs de suivi. Bitcoin Core est toujours capable de
  migrer les portefeuilles hérités vers le nouveau format de portefeuille descriptor (voir le [Bulletin
  #305][news305 bdbro]).

- [Eclair #3064][] refactorise la gestion des clés de canal en introduisant une classe
  `ChannelKeys`. Chaque canal possède désormais son propre objet `ChannelKeys` qui, avec les points
  d'engagement, dérive un ensemble `CommitmentKeys` pour signer les transactions d'engagement
  remote/local et [HTLC][topic htlc]. La logique de fermeture forcée et la création de script/témoin
  sont également mises à jour pour dépendre de `CommitmentKeys`. Auparavant, la génération de clés
  était dispersée à travers plusieurs parties du code pour supporter les signataires externes, ce qui
  pouvait provoquer des erreurs car elle reposait sur des noms plutôt que sur des types pour assurer que
  la pubkey correcte était fournie.

- [BTCPay Server #6684][] ajoute le support pour un sous-ensemble de politiques de portefeuille
  [BIP388][] [descriptors][topic descriptors], permettant aux utilisateurs d'importer et d'exporter
  à la fois des portefeuilles à signature unique et k-de-n. Il inclut les formats pris en charge par Sparrow tels
  que P2PKH, P2WPKH, P2SH-P2WPKH, et P2TR, avec les variantes multisig correspondantes, à l'exception
  de P2TR. L'amélioration de l'utilisation des portefeuilles multisig est l'objectif visé par ce PR.

- [BIPs #1555][] fusionne [BIP321][], qui propose un schéma d'URI pour décrire les instructions de
  paiement en bitcoin qui modernise et étend [BIP21][]. Il conserve le chemin d'adresse hérité mais
  standardise l'utilisation des paramètres de requête en rendant les nouvelles méthodes de paiement
  identifiables par leurs propres paramètres, et permet de laisser le champ d'adresse vide si au moins
  une instruction apparaît dans un paramètre de requête. Une extension optionnelle permet de
  fournir une preuve de paiement, avec des recommandations
  d’intégration.

{% include snippets/recap-ad.md when="2025-05-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31250,3064,6684,1555,32359" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[wuille clusbench]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/73
[hughes opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f4f6831a-d6b8-4f32-8a4e-c0669cc0a7b8n@googlegroups.com/
[wuille opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/QMywWcEgJgWmiQzASR17Dt42oLGgG-t3bkf0vzGemDVNVnvVaD64eM34nOQHlBLv8nDmeBEyTXvBUkM2hZEfjwMTrzzoLl1_62MYPz8ZThs=@wuille.net/
[news316 blockxor]: /fr/newsletters/2024/08/16/#bitcoin-core-28052
[news172 descriptors]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[news305 bdbro]: /fr/newsletters/2024/05/31/#bitcoin-core-26606
