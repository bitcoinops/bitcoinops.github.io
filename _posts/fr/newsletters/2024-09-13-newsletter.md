---
title: 'Bulletin Hebdomadaire  Bitcoin Optech #320'
permalink: /fr/newsletters/2024/09/13/
name: 2024-09-13-newsletter-fr
slug: 2024-09-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce un nouvel outil de test pour Bitcoin Core et
décrit brièvement un contrat de prêt basé sur les Discret Log Contract. Sont également inclus nos
sections habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
il annonce les mises à jour avec les versions candidates, et présente les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Test de mutation pour Bitcoin Core :** Bruno Garcia a [publié][garcia announce] sur
  Delving Bitcoin pour annoncer un [outil][mutation-core] qui modifierait
  automatiquement (muter) le code modifié dans une PR ou un commit pour
  déterminer si les mutations font échouer les tests existants. Chaque fois
  que des modifications aléatoires du code ne produisent pas d'échec, cela indique que la couverture
  des tests peut être incomplète. L'outil de mutation automatique de Garcia ignore
  les commentaires de code et d'autres lignes de code qui ne seraient pas censées
  produire des changements.

- **Exécution de contrat de prêt basé sur DLC :** Shehzan Maredia
  a [publié][maredia post] sur Delving Bitcoin pour annoncer [Lava Loans][], un
  contrat de prêt qui utilise des oracles [DLC][topic dlc] pour la découverte de prix
  des prêts garantis par bitcoin. Par exemple, Alice propose à Bob
  100 000 USD si Bob garde au moins 2x 100 000 USD en BTC dans une adresse de dépôt.
  Les oracles, en qui Alice et Bob ont confiance, publient périodiquement
  des signatures s'engageant sur le prix actuel BTC/USD. Si la garantie en BTC de Bob
  tombe en dessous du montant convenu, Alice peut saisir
  100 000 USD de son BTC au montant le plus élevé signé par l'oracle.
  Alternativement, Bob peut fournir une preuve onchain qu'il a remboursé le prêt
  (sous forme de préimage de hachage révélée par Alice) pour récupérer sa
  garantie. D'autres résolutions du contrat sont disponibles si les
  parties ne coopèrent pas ou si une partie devient non réactive. Comme
  pour tout DLC, les oracles de prix ne peuvent pas accéder aux
  détails du contrat ni être informés que leurs données de prix sont utilisées dans un contrat.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une réunion récente du [Bitcoin Core PR Review
Club][], en soulignant certaines des questions et réponses importantes. Cliquez sur une question
ci-dessous pour voir un résumé de la réponse de
la réunion.*

[Tester les versions candidates de Bitcoin Core 28.0][review club
v28-rc-testing] était une réunion du club de révision qui n'a pas examiné une
PR particulier, mais était plutôt un effort de test de groupe.

Avant chaque [sortie majeure de Bitcoin Core][], des tests approfondis par la
communauté sont considérés comme essentiels. Pour cette raison, un volontaire rédige un
guide de test pour une [version candidate][] afin que le plus grand nombre de personnes possible
puisse tester de manière productive sans avoir à déterminer indépendamment ce qui est nouveau ou
modifié dans la version, et réinventer les différentes étapes de configuration pour tester ces
fonctionnalités ou changements.

Tester peut être difficile car lorsqu'on rencontre un comportement inattendu, il est souvent
incertain si c'est dû à un véritable bug ou si le
testeur fait une erreur. Cela fait perdre du temps aux développeurs de signaler des bugs qui ne sont
pas de réels bugs. Pour atténuer ces problèmes et promouvoir les efforts de test, une réunion du
Review Club est tenue pour une version candidate particuliere, dans ce cas, 28.0rc1.

Le [guide de test de la version candidate 28.0][28.0 testing] a été écrit par
rkrux, qui a également animé la réunion du club de révision.
Les participants ont également été encouragés à obtenir des idées de tests en lisant les [notes de
version 28.0][].

Ce club de révision a couvert l'introduction de [testnet4][topic testnet]
([Bitcoin Core #29775][]), les transactions [TRUC (v3)][topic v3
transaction relay] ([Bitcoin Core #28948][]), le [package RBF][topic
rbf] ([Bitcoin Core #28984][]) et les transactions en conflit dans la mempool
([Bitcoin Core #27307][]). D'autres sujets dans le guide, mais
non abordés lors de la réunion incluent `mempoolfullrbf` par défaut ([Bitcoin
Core #30493][]), dépenses [`PayToAnchor`][topic ephemeral anchors]
([Bitcoin Core #30352][]), et un nouveau format `dumptxoutset` ([Bitcoin
Core #29612][]).

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates.*'

- [LND v0.18.3-beta][] est une sortie mineure de correction de bugs
  pour cette implémentation populaire de nœud LN.

- [BDK 1.0.0-beta.2][] est un candidat pour cette bibliothèque afin de
  construire des portefeuilles et d'autres applications activées par Bitcoin. Le paquet `bdk` original
  a été renommé en `bdk_wallet` et les modules de couche inférieure ont été extraits dans leurs
  propres paquets, incluant
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, et `bdk_bitcoind_rpc`.
  Le paquet `bdk_wallet` "est la première version à offrir une API stable 1.0.0."

- [Bitcoin Core 28.0rc1][] est un candidat pour la prochaine version majeure
  de l'implémentation de nœud complet prédominante. Un [guide de test][bcc testing] est disponible.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

_Note : les commits sur Bitcoin Core mentionnés ci-dessous s'appliquent à sa branche de
développement principale, donc ces changements ne seront probablement pas publiés avant environ six
mois après la sortie de la version 28 à venir._

- [Bitcoin Core #30509][] ajoute une option `-ipcbind` à `bitcoin-node` pour permettre
  à d'autres processus de se connecter et de contrôler le nœud via une socket unix. En
  combinaison avec la PR à venir [Bitcoin Core #30510][], cela permettra à un
  service de minage externe [Stratum v2][topic pooled mining] de créer, gérer,
  et soumettre des modèles de blocs. Cela fait partie du [projet multiprocessus][multiprocess project]
  de Bitcoin Core. Voir les Bulletins [#99][news99 multi] et [#147][news147 multi].

- [Bitcoin Core #29605][] modifie la découverte de pairs pour prioriser les pairs provenant du
  gestionnaire d'adresses local plutôt que de récupérer ceux des nœuds de semence, afin de réduire
  l'influence de ces derniers sur la sélection des pairs et diminuer le partage d'informations
  inutiles. Par défaut, les nœuds de semence sont une solution de secours au cas où toutes les graines DNS
  seraient inaccessibles (ce qui est très rare sur le mainnet) ; cependant, les utilisateurs de
  réseaux de test ou de nœuds personnalisés peuvent manuellement ajouter des nœuds de semence pour
  trouver des nœuds configurés de manière similaire. Avant cette PR, l'ajout d'un nœud de semence
  entraînerait sa consultation pour de nouvelles adresses presque à chaque démarrage du nœud, lui
  permettant potentiellement d'influencer la sélection des pairs et de recommander uniquement des
  pairs partageant des données avec lui. Avec cette PR, seulement lorsque le gestionnaire d'adresses est
  vide, ou après une période de tentatives d'adresses infructueuses, les nœuds de semence seront
  ajoutés à la file d'attente de récupération d'adresses dans un ordre aléatoire. Voir le Bulletin
  [#301][news301 seednode] pour plus d'informations sur les nœuds de semence.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30509,29605,30510,29775,28948,28984,27307,30493,30352,29612" %}
[LND v0.18.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[garcia announce]: https://delvingbitcoin.org/t/mutation-core-a-mutation-testing-tool-for-bitcoin-core/1119
[mutation-core]: https://github.com/brunoerg/mutation-core
[maredia post]: https://delvingbitcoin.org/t/lava-loans-trust-minimized-bitcoin-secured-loans/1112
[lava loans]: https://github.com/lava-xyz/loans-paper/blob/960b91af83513f6a17d87904457e7a9e786b21e0/loans_v2.pdf
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news99 multi]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 multi]: /en/newsletters/2021/05/05/#bitcoin-core-19160
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news301 seednode]: /fr/newsletters/2024/05/08/#bitcoin-core-28016
[review club v28-rc-testing]: https://bitcoincore.reviews/v28-rc-testing
[sortie majeure de Bitcoin Core]: https://bitcoincore.org/en/lifecycle/#major-releases
[notes de version 28.0]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Notes-Draft
[version candidate]: https://bitcoincore.org/en/lifecycle/#versioning
[28.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide