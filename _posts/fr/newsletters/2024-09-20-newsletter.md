---
title: 'Bulletin Hebdomadaire Bitcoin Optech #321'
permalink: /fr/newsletters/2024/09/20/
name: 2024-09-20-newsletter-fr
slug: 2024-09-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine inclut un lien vers une implémentation de preuve de concept pour
prouver en connaissance nulle qu'une sortie fait partie de l'ensemble des UTXOs,
décrit une nouvelle proposition et deux propositions précédentes pour permettre les paiements LN
hors ligne,
et résume une recherche sur le seeding DNS pour des adresses de réseau non-IP. Sont également inclus nos
sections habituelles annoncant les mises à jour avec les versions candidates, et présente les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Prouver l'inclusion dans l'ensemble UTXO en connaissance nulle :** Johan Halseth
  a [posté][halseth utxozk] sur Delving Bitcoin pour annoncer un
  outil de preuve de concept qui permet à quelqu'un de prouver qu'il contrôle
  une des sorties dans l'ensemble des UTXOs actuel sans révéler quelle
  sortie. L'objectif final est de permettre aux co-propriétaires d'une sortie de financement LN de
  prouver qu'ils contrôlent un canal sans révéler aucune information spécifique sur leurs transactions
  onchain. Cette preuve peut être attachée aux [messages d'annonce de canal][topic
  channel announcements] de nouvelle génération qui sont utilisés pour construire des informations de
  routage décentralisées pour LN.

  La méthode utilisée diffère de la méthode aut-ct décrite dans
  la [Newsletter #303][news303 aut-ct], et une partie de la discussion a porté
  sur la clarification des différences. Des recherches supplémentaires sont nécessaires, avec
  Halseth décrivant plusieurs problèmes ouverts.

- **Paiements LN hors ligne :** Andy Schroder a [posté][schroder lnoff] sur
  Delving Bitcoin pour esquisser un processus de communication qu'un portefeuille LN pourrait
  utiliser pour générer des jetons qui pourraient être fournis à un portefeuille connecté à Internet
  afin de le payer. Par exemple, le portefeuille d'Alice serait normalement
  connecté à un nœud LN toujours en ligne qu'elle contrôle ou qui est
  contrôlé par un _fournisseur de services Lightning_ (LSP). En ligne,
  Alice pré-générera des jetons d'authentification.

  Plus tard, lorsque le nœud d'Alice est hors ligne et qu'elle souhaite payer Bob, elle
  donne à Bob un jeton d'authentification qui lui permet de se connecter à son
  nœud toujours en ligne ou au LSP et de retirer un montant indiqué par Alice.
  Elle peut fournir le jeton d'authentification à Bob en utilisant le [NFC][] ou
  un autre protocole de transfert de données largement disponible qui ne nécessite pas
  qu'Alice accède à Internet, gardant le protocole simple et facilitant
  son implémentation sur des appareils aux ressources informatiques limitées (comme
  les cartes intelligentes).

  Le développeur ZmnSCPxj a [mentionné][zmn lnoff] une approche alternative qu'il
  avait précédemment décrite et Bastien Teinurier a [référencé][t-bast
  lnoff] une méthode de contrôle à distance de nœud qu'il a conçue pour ce type de
  situation (voir le [Bulletin #271][news271 noderc]).

- **Seeding DNS pour des adresses non-IP :** le développeur Virtu a [publié][virtu seed]
  sur Delving Bitcoin un sondage sur la disponibilité de nœuds de semence sur
  les [réseaux d'anonymat][topic anonymity networks] et a discuté des méthodes
  permettant aux nouveaux nœuds qui utilisent exclusivement ces réseaux d'en savoir
  plus sur leurs pairs à travers des seeders DNS.

  Pour contextualiser, un nœud Bitcoin ou un client P2P a besoin de connaître les
  adresses réseau de pairs auprès desquels il peut télécharger des données. Les nouveaux
  logiciels installés, ou logiciels qui ont été hors ligne pendant longtemps, peuvent ne pas connaître
  l'adresse réseau de pairs actifs. Normalement, les nœuds Bitcoin Core résolvent cela en interrogeant
  une graîne DNS qui retourne les adresses IPv4 ou IPv6 de plusieurs pairs susceptibles d'être
  disponibles. Si le DNS seeding échoue, ou s'il n'est pas disponible (comme pour les réseaux
  d'anonymat qui n'utilisent pas d'adresses IPv4 ou IPv6), Bitcoin Core inclut les adresses réseau de
  pairs qui étaient disponibles lors de la sortie du logiciel ; ces pairs sont utilisés comme _seed
  nodes_ (nœuds de semence), où le nœud demande des adresses de pairs supplémentaires au nœud de
  semence et les utilise comme pairs potentiels. Les graînes DNS sont préférés aux nœuds de semence car
  leurs informations sont généralement plus actuelles et l'infrastructure de mise en cache DNS globale
  peut empêcher une graîne DNS d'apprendre l'adresse réseau de chaque nœud demandeur.

  Virtu a examiné les nœuds d'amorçage listés dans les quatre dernières versions majeures de Bitcoin
  Core et a trouvé qu'un nombre satisfaisant d'entre eux étaient encore disponibles, indiquant que les
  utilisateurs de réseaux anonymes devraient être capables de trouver des pairs. Lui et d'autres
  participants à la discussion ont également examiné la possibilité de modifier Bitcoin Core pour lui
  permettre d'utiliser le DNS seeding pour les réseaux anonymes via soit des enregistrements DNS
  `NULL` soit l'encodage d'adresses réseau alternatives dans des adresses pseudo-IPv6.

## Changements notables dans le code et la documentation

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Strike ajoute le support de BOLT12 :**
  Strike [a annoncé][strike blog] le support pour les [offres BOLT12][topic offers], incluant
  l'utilisation d'offres avec des instructions de paiement DNS [BIP353][].

- **BitBox02 ajoute le support du paiement silencieux :**
  BitBox02 [a annoncé][bitbox blog sp] le support pour les [paiements silencieux][topic silent
  payments] et une implémentation des [demandes de paiement][bitbox blog pr].

- **La sortie de Mempool Open Source Project v3.0.0 :**
  La [version v3.0.0][mempool github 3.0.0] inclut de nouveaux calculs de frais [CPFP][topic cpfp],
  des fonctionnalités [RBF][topic rbf] supplémentaires incluant le support complet de fullrbf, le
  support P2PK, et de nouvelles fonctionnalités d'analyse de mempool et de blockchain, parmi d'autres
  changements.

- **ZEUS v0.9.0 sorti :**
  Le [post v0.9.0][zeus blog 0.9.0] décrit des fonctionnalités LSP supplémentaires, des portefeuilles
  en lecture seule, le support des dispositifs de signature matérielle, le support pour le
  [batching][scaling payment batching] de transactions incluant les transactions d'ouverture de canal,
  et d'autres fonctionnalités.

- **Live Wallet ajoute le support de la consolidation :**
  L'application Live Wallet analyse le coût de dépense d'un ensemble d'UTXOs à différents taux de
  frais, y compris la détermination de sorties étant [non économiques][topic uneconomical
  outputs] à dépenser. La [version 0.7.0][live wallet github 0.7.0] inclut des fonctionnalités pour
  simuler des transactions de [consolidation][consolidate info] et générer des [PSBTs][topic psbt] de
  consolidation.

- **Bisq ajoute le support de Lightning :**
  [Bisq v2.1.0][bisq github v2.1.0] ajoute la capacité pour les utilisateurs de régler des échanges en
  utilisant le Lightning Network.

## Nouvelles versions et versions candidates

*Nouvelles sorties et candidats à la sortie pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les
candidats à la publication.*

- [HWI 3.1.0][] est une version du prochain package fournissant une interface commune à plusieurs
  dispositifs de signature matérielle différents. Cette version ajoute le support pour le Trezor Safe
  5 et apporte plusieurs autres améliorations et corrections de bugs.

- [Core Lightning 24.08.1][] est une version de maintenance qui corrige des plantages et d'autres
  bugs découverts dans la récente version 24.08.

- [BDK 1.0.0-beta.4][] est un candidat à la publication pour cette bibliothèque destinée à la
  construction de portefeuilles et d'autres applications activées par Bitcoin. Le paquet Rust original
  `bdk` a été renommé en `bdk_wallet` et les modules de couche inférieure ont été extraits dans leurs
  propres paquets, incluant `bdk_chain`, `bdk_electrum`, `bdk_esplora`, et `bdk_bitcoind_rpc`. Le paquet
  `bdk_wallet` "est la première version à offrir une API stable 1.0.0."

- [Bitcoin Core 28.0rc2][] est un candidat à la publication pour la prochaine version majeure de
  l'implémentation de nœud complet prédominante. Un [guide de test][bcc testing] est disponible.

## Changements notables dans le code et la documentation

_Changes récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

_Note : les commits sur Bitcoin Core mentionnés ci-dessous s'appliquent à sa branche de
développement master, donc ces changements ne seront probablement pas publiés avant environ six mois
après la sortie de la version 28 à venir._

- [Bitcoin Core #28358][] supprime la limite de `dbcache` car la limite précédente de 16 Go n'était
  plus suffisante pour compléter un Téléchargement Initial de Bloc (IBD) sans vider l'ensemble UTXO de
  la RAM vers le disque, ce qui peut [fournir][lopp cache] environ 25% d'accélération. Il a été décidé
  de supprimer la limite plutôt que de l'augmenter car il n'y avait pas de valeur optimale qui serait
  à l'épreuve du temps et pour donner aux utilisateurs une flexibilité complète.

- [Bitcoin Core #30286][] optimise l'algorithme de recherche de candidats utilisé dans les
  linéarisations de clusters, basé sur le cadre exposé dans la Section 2 de ce [post Delving
  Bitcoin][delving cluster], mais avec quelques modifications. Ces optimisations minimisent les
  itérations pour améliorer la performance de linéarisation, mais peuvent augmenter les coûts de
  démarrage et de pré-itération. Cela fait partie du projet [cluster mempool][topic cluster mempool].
  Voir le Bulletin [#315][news315 cluster].

- [Bitcoin Core #30807][] change le signal d'un nœud [assumeUTXO][topic assumeutxo] qui synchronise
  la chaîne d'arrière-plan de `NODE_NETWORK` à `NODE_NETWORK_LIMITED` afin que les nœuds pairs ne
  demandent pas de blocs plus anciens qu'environ une semaine. Ceci
  corrige un bug où un pair demandait un bloc historique et ne recevait aucune réponse, ce qui le
  conduisait à se déconnecter du nœud assumeUTXO.

- [LND #8981][] refactorise le type `paymentDescriptor` pour l'utiliser uniquement dans le package
  `lnwallet`. Ceci afin de remplacer plus tard `paymentDescriptor` par une nouvelle structure appelée
  `LogUpdate` pour simplifier la manière dont les mises à jour sont enregistrées et gérées, dans le
  cadre d'une série de PRs mettant en œuvre des engagements dynamiques, un type de [mise à niveau de
  l'engagement de canal][topic channel commitment upgrades].

- [LDK #3140][] ajoute le support pour payer des factures statiques [BOLT12][topic offers] pour
  envoyer des [paiements asynchrones][topic async payments] en tant qu'expéditeur toujours en ligne
  tel que défini dans [BOLTs #1149][], mais sans inclure la demande de facture dans le [message onion][topic onion messages] de paiement. Envoyer en tant qu'expéditeur souvent hors ligne ou recevoir
  des paiements asynchrones n'est pas encore possible, donc le flux ne peut pas encore être testé de
  bout en bout.

- [LDK #3163][] met à jour le flux de messages [offres][topic offers] en introduisant un
  `reply_path` dans les factures BOLT12. Cela permet au payeur d'envoyer le message d'erreur au payeur
  en cas d'erreur de facture.

- [LDK #3010][] ajoute une fonctionnalité pour qu'un nœud puisse réessayer d'envoyer une demande de
  facture à un chemin de réponse d'[offre][topic offers] s'il n'a pas encore reçu la facture
  correspondante. Auparavant, si un message de demande de facture sur une seule offre de chemin de
  réponse échouait en raison d'une déconnexion réseau, il n'était pas réessayé.

- [BDK #1581][] introduit des changements dans l'algorithme de [sélection de pièces][topic coin
  selection] en permettant un algorithme de repli personnalisable dans la stratégie
  `BranchAndBoundCoinSelection`. La signature de la méthode `coin_select` est mise à jour pour
  permettre de passer directement un générateur de nombres aléatoires à l'algorithme de sélection de
  pièces. Ce PR inclut également des refactorisations supplémentaires, une gestion des solutions de
  repli internes et une simplification de la gestion des erreurs.

- [BDK #1561][] supprime le paquet `bdk_hwi` du projet, pour simplifier les dépendances et
  l'intégration continue. Le paquet `bdk_hwi` contenait `HWISigner`, qui a maintenant été déplacé vers
  le projet `rust_hwi`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28358,30286,30807,8981,3140,3163,3010,1581,1561,1149" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[halseth utxozk]: https://delvingbitcoin.org/t/proving-utxo-set-inclusion-in-zero-knowledge/1142/
[schroder lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/
[virtu seed]: https://delvingbitcoin.org/t/hardcoded-seeds-dns-seeds-and-darknet-nodes/1123
[news303 aut-ct]: /fr/newsletters/2024/05/17/#jetons-d-utilisation-anonymes
[nfc]: https://en.wikipedia.org/wiki/Near-field_communication
[zmn lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/2
[t-bast lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/4
[news271 noderc]: /fr/newsletters/2023/10/04/#controle-a-distance-securise-des-noeuds-ln
[hwi 3.1.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.1.0
[core lightning 24.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.1
[delving cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303#h-2-finding-high-feerate-subsets-5
[lopp cache]: https://github.com/bitcoin/bitcoin/pull/28358#issuecomment-2186630679
[news315 cluster]: /fr/newsletters/2024/08/02/#bitcoin-core-30126
[strike blog]: https://strike.me/blog/bolt12-offers/
[bitbox blog sp]: https://bitbox.swiss/blog/understanding-silent-payments-part-one/
[bitbox blog pr]: https://bitbox.swiss/blog/using-payment-requests-to-securely-send-bitcoin-to-an-exchange/
[mempool github 3.0.0]: https://github.com/mempool/mempool/releases/tag/v3.0.0
[zeus blog 0.9.0]: https://blog.zeusln.com/new-release-zeus-v0-9-0/
[live wallet github 0.7.0]: https://github.com/Jwyman328/LiveWallet/releases/tag/0.7.0
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[bisq github v2.1.0]: https://github.com/bisq-network/bisq2/releases/tag/v2.1.0
