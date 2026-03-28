---
title: 'Bulletin Hebdomadaire Bitcoin Optech #397'
permalink: /fr/newsletters/2026/03/20/
name: 2026-03-20-newsletter-fr
slug: 2026-03-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine inclut nos sections régulières résumant les changements récents apportés aux clients
et services, les annonces de nouvelles versions et de candidats à la publication, et les résumés des
modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

*Aucune nouvelle significative cette semaine n'a été trouvée dans aucune de nos [sources].*

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Cake Wallet ajoute le support de Lightning :**
  Cake Wallet a [annoncé][cake ln post] le support du Lightning Network en utilisant le
  SDK Breez et une intégration [Spark][topic statechains], incluant les adresses Lightning.

- **Sparrow 2.4.0 et 2.4.2 disponibles :**
  Sparrow [2.4.0][sparrow 2.4.0] ajoute les champs [BIP375][] [PSBT][topic psbt] pour
  le support des portefeuilles matériels [silent payment][topic silent payments] et ajoute un
  importateur [Codex32][topic codex32]. Sparrow [2.4.2][sparrow 2.4.2] ajoute le support des [transactions v3][topic v3 transaction relay].

- **Blockstream Jade ajoute Lightning via Liquid :**
  Blockstream a [annoncé][jade ln blog] que le portefeuille matériel Jade (via l'application Green
  5.2.0) peut maintenant interagir avec Lightning en utilisant les [submarine swaps][topic submarine
  swaps] qui convertissent les paiements Lightning en Bitcoin [Liquid][topic sidechains]
  (L-BTC), tout en gardant les clés hors ligne.

- **Lightning Labs lance des outils pour agents :**
  Lightning Labs a [lancé][ll agent tools] une boîte à outils open-source permettant aux agents IA
  d'opérer sur Lightning sans intervention humaine ni clés API en utilisant
  le [protocole L402][blip 26].

- **Tether lance MiningOS :**
  Tether a [lancé][tether mos] MiningOS, un système d'exploitation open-source pour
  gérer les opérations de minage de Bitcoin. Le logiciel sous licence Apache 2.0 est
  indépendant du matériel avec une architecture modulaire, P2P.

- **Réactivation du réseau FIBRE :**
  Localhost Research a [annoncé][fibre blog] la réactivation de FIBRE (Fast
  Internet Bitcoin Relay Engine), précédemment arrêté en 2017.
  Le redémarrage inclut une base Bitcoin Core v30 et une suite de surveillance,
  avec six nœuds publics déployés globalement. FIBRE complète les [relais de blocs compacts][topic compact block relay]
  pour la propagation de blocs à faible latence.

- **TUI pour Bitcoin Core lancé :**
  [Bitcoin-tui][btctui tweet], une interface terminal pour Bitcoin Core, se connecte
  via JSON-RPC pour afficher les données de la blockchain et du réseau, avec surveillance du mempool,
  recherche et diffusion de transactions, et gestion des pairs.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 31.0rc1][] est un candidat à la version pour la prochaine version majeure de l'implémentation de nœud complet prédominante.
  Un [guide de test][bcc31 testing] est disponible.

- [BTCPay Server 2.3.6][] est une version mineure de cette solution de paiement auto-hébergée qui ajoute un filtrage par étiquette
  dans la barre de recherche de portefeuille, inclut les données de méthode de paiement dans le point de terminaison de l'API des factures,
  et permet aux plugins de définir des politiques de permission personnalisées. Elle comprend également plusieurs corrections de bugs.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31560][] étend le RPC `dumptxoutset` (voir le [Bulletin #72][news72 dump]), permettant à l'instantané du set UTXO
  d'être écrit dans un pipe nommé. Cela permet de diffuser la sortie directement vers un autre processus, évitant la nécessité d'écrire
  le dump complet sur disque. Cela se combine bien avec l'outil `utxo_to_sqlite.py` (voir le [Bulletin #342][news342 sqlite]),
  permettant de créer une base de données SQLite du set UTXO à la volée.

- [Bitcoin Core #31774][] commence à protéger le matériel de clé de chiffrement AES-256 utilisé pour le chiffrement du portefeuille
  avec `secure_allocator` pour l'empêcher d'être échangé sur disque par le système d'exploitation lorsqu'il manque de mémoire,
  et le supprime de la mémoire lorsqu'il n'est plus utilisé. Lorsqu'un utilisateur chiffre ou déverrouille son portefeuille,
  la phrase secrète est utilisée pour dériver une clé AES qui chiffre ou déchiffre les clés privées du portefeuille. Auparavant,
  ce matériel de clé était alloué en utilisant l'allocateur standard, ce qui signifie qu'il pourrait être échangé sur disque ou rester en mémoire.

- [Core Lightning #8817][] corrige plusieurs problèmes d'interopérabilité de [splice][topic splicing] avec Eclair qui ont été découverts
  lors de tests d'interopérabilité entre implémentations (voir les Bulletins [#331][news331 interop] et [#355][news355 interop]
  pour les travaux d'interopérabilité précédents). CLN gère maintenant les messages `channel_ready` qu'Eclair peut envoyer pendant
  le réétablissement du splice avant de reprendre la négociation, corrige la gestion des erreurs RPC qui pourrait causer un crash,
  et implémente la retransmission de signature d'annonce via de nouveaux TLVs `channel_reestablish`.

- [Eclair #3265][] et [LDK #4324][] commencent à rejeter les [offres BOLT12][topic offers] où `offer_amount` est fixé à zéro,
  pour s'aligner avec les derniers changements dans la spécification BOLT (voir le [Bulletin #396][news396 amount]).

- [LDK #4427][] ajoute le support pour le bumping de frais [RBF][topic rbf] des transactions de financement [splice][topic splicing]
  qui ont été négociées mais pas encore verrouillées, en réentrante dans l'état de [quiescence][topic channel commitment upgrades].
  Lorsque les deux pairs tentent de RBF simultanément, le perdant du tie-breaker de quiescence peut contribuer en tant qu'accepteur.
  Les contributions antérieures sont automatiquement réutilisées lorsque la contrepartie initie un RBF, empêchant ainsi l'augmentation
  des frais d'éliminer silencieusement les fonds de splice d'un pair. Voir le [Bulletin #396][news396 splice] pour le support
  de contribution de l'accepteur de splice de base sur lequel cela se construit.

- [LDK #4484][] augmente la limite acceptée maximale de [poussière][topic uneconomical outputs] des canaux à 10 000 satoshis
  pour les canaux [ancre][topic anchor outputs] avec des [HTLCs][topic htlc] sans frais, incluant les [canaux zéro-conf][topic zero-conf channels].
  Cela met en œuvre la recommandation de [BOLTs #1301][] (voir le [Bulletin #395][news395 dust]).

- [BIPs #1974][] publie [BIP446][] et [BIP448][] en tant que brouillons de BIP.
  [BIP446][] spécifie `OP_TEMPLATEHASH`, un nouvel opcode [tapscript][topic tapscript] qui pousse un hash de la transaction de dépense
  sur la pile (voir le [Bulletin #365][news365 op] pour la proposition initiale). [BIP448][] regroupe `OP_TEMPLATEHASH` avec
  [OP_INTERNALKEY][BIP349] et [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] pour proposer des "Transactions (Re)liables natives de Taproot".
  Ce bundle de [covenant][topic covenants] permettrait [LN-Symmetry][topic eltoo] ainsi que de réduire l'interactivité et de simplifier
  d'autres protocoles de seconde couche.

{% include snippets/recap-ad.md when="2026-03-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31560,31774,8817,3265,4324,4427,4484,1974,1301" %}
[sources]: /en/internal/sources/
[cake ln post]: https://blog.cakewallet.com/our-lightning-journey/
[sparrow 2.4.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.0
[sparrow 2.4.2]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.2
[jade ln blog]: https://blog.blockstream.com/jade-lightning-payments-are-here/
[ll agent tools]: https://github.com/lightninglabs/lightning-agent-tools
[blip 26]: https://github.com/lightning/blips/pull/26
[x402 blog]: https://blog.cloudflare.com/x402/
[tether mos]: https://mos.tether.io/
[fibre blog]: https://lclhost.org/blog/fibre-resurrected/
[btctui tweet]: https://x.com/_jan__b/status/2031741548098896272
[bitcoin core 31.0rc1]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[BTCPay Server 2.3.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.6
[news72 dump]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news342 sqlite] : /fr/newsletters/2025/02/21/#bitcoin-core-27432
[news331 interop] : /fr/newsletters/2024/11/29/#core-lightning-7719
[news355 interop] : /fr/newsletters/2025/05/23/#core-lightning-8021
[news396 amount] : /fr/newsletters/2026/03/13/#bolts-1316
[news396 splice] : /fr/newsletters/2026/03/13/#ldk-4416
[news395 dust] : /fr/newsletters/2026/03/06/#bolts-1301
[news365 op] : /fr/newsletters/2025/08/01/#proposition-de-op-templatehash-natif-a-taproot