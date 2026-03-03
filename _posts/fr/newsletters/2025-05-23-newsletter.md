---
title: 'Bulletin Hebdomadaire Bitcoin Optech #355'
permalink: /fr/newsletters/2025/05/23/
name: 2025-05-23-newsletter-fr
slug: 2025-05-23-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine inclut nos sections habituelles décrivant les changements apportés
aux services et aux logiciels clients, annonçant des mises à jour et des versions candidates, et
résumant les changements récents apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

*Aucune nouvelle significative cette semaine n'a été trouvée dans aucune de nos [sources][].*

## Changements dans les services et les logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Cake Wallet a ajouté le support de payjoin v2 :**
  Cake Wallet [v4.28.0][cake wallet 4.28.0] ajoute [la capacité][cake blog] de
  recevoir des paiements en utilisant le protocole [payjoin][topic payjoin] v2.

- **Sparrow ajoute des fonctionnalités pay-to-anchor :**
  Sparrow [2.2.0][sparrow 2.2.0] affiche et peut envoyer des sorties [pay-to-anchor
  (P2A)][topic ephemeral anchors].

- **Safe Wallet 1.3.0 publié :**
  [Safe Wallet][safe wallet github] est un portefeuille multisig de bureau avec support de dispositif
  de signature matériel qui a ajouté le bumping de frais [CPFP][topic cpfp] pour les transactions
  entrantes dans [1.3.0][safe wallet 1.3.0].

- **COLDCARD Q v1.3.2 publié :**
  La version [v1.3.2 de COLDCARD Q][coldcard blog] inclut un support de politique de dépense multisig
  supplémentaire et de nouvelles fonctionnalités pour [partager des données sensibles][coldcard kt].

- **Regroupement de transactions utilisant payjoin :**
  [Private Pond][private pond post] est une [implémentation expérimentale][private
  pond github] d'un service de [regroupement de transactions][topic payment
  batching] qui utilise payjoin pour générer des transactions plus petites qui paient moins de frais.

- **Simulateur de Fidelity Bond JoinMarket :**
  Le [JoinMarket Fidelity Bond Simulator][jmfbs github] fournit des outils pour les participants de
  JoinMarket pour simuler leur performance sur le marché basée sur les [fidelity bonds][news161 fb].

- **Documentation des opcodes Bitcoin :**
  Le site web [Opcode Explained][opcode explained website] documente chaque opcode du script Bitcoin.

- **Code de Bitkey rendu open source :**
  Le dispositif de signature matériel Bitkey [a annoncé][bitkey blog] que leur [code source][bitkey
  github] est open-source pour des usages non commerciaux.

## Mises à jour et versions candidates

_Nouvelles versions et candidates à la sortie pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les candidates
à la sortie._

- [LND 0.19.0-beta][] est la dernière version majeure de ce nœud LN populaire. Elle contient de
  nombreuses [améliorations][lnd rn] et corrections de bugs, y compris le nouveau bumping de frais
  basé sur RBF pour les fermetures coopératives.

- [Core Lightning 25.05rc1][] est un candidat à la sortie pour la prochaine version majeure de
  cette implémentation de nœud LN populaire.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware WalletInterface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana
repo]._

- [Bitcoin Core #32423][] supprime l'avis de dépréciation pour `rpcuser/rpcpassword` et le remplace
  par un avertissement de sécurité concernant le stockage des identifiants en clair dans le fichier de
  configuration. Cette option avait été initialement dépréciée lorsque `rpcauth` a été introduit dans
  [Bitcoin Core #7044][], qui prend en charge plusieurs utilisateurs RPC et hache son cookie. La PR
  ajoute également un grain de sel aléatoire de 16 octets aux identifiants des deux méthodes et les
  hash avant qu'ils ne soient stockés en mémoire.

- [Bitcoin Core #31444][] étend la classe `TxGraph` (voir le Bulletin [#348][news348 txgraph]) avec
  trois nouvelles fonctions d'aide : `GetMainStagingDiagrams()` retourne les divergences de clusters
  entre les diagrammes de taux de frais principaux et de mise en scène, `GetBlockBuilder()` itère à
  travers des morceaux de graphique (groupements triés par taux de frais en sous-cluster) du plus
  élevé au plus bas taux de frais pour une construction de bloc optimisée, et `GetWorstMainChunk()`
  identifie le morceau au taux de frais le plus bas pour les décisions d'éviction. Cette PR est l'un
  des derniers éléments de construction de l'implémentation initiale complète du projet de [mempool en
  cluster][topic cluster mempool].

- [Core Lightning #8140][] active le [stockage par les pairs][topic peer storage] des
  sauvegardes de canaux par défaut (voir le Bulletin [#238][news238 storage]), le rendant viable pour
  les grands nœuds en limitant le stockage aux pairs ayant des canaux actuels ou passés, en mettant en
  cache les sauvegardes et les listes de pairs en mémoire au lieu de faire des appels répétés à
  `listdatastore`/`listpeerchannels`, en plafonnant les téléchargements de sauvegarde concurrents à
  deux pairs, en sautant les sauvegardes de plus de 65 kB, et en randomisant la sélection des pairs
  lors de l'envoi.

- [Core Lightning #8136][] met à jour l'échange de signatures d'annonce pour qu'il se produise
  lorsque le canal est prêt plutôt qu'après six blocs, pour s'aligner sur la récente mise à jour de la
  spécification [BOLTs #1215][]. Il est toujours nécessaire d'attendre six blocs pour [annoncer le
  canal][topic channel announcements].

- [Core Lightning #8266][] ajoute une commande `update` au gestionnaire de plugins Reckless (voir
  le Bulletin [#226][news226 reckless]) qui met à jour un plugin spécifié ou tous les plugins installés
  si aucun n'est spécifié, à l'exception de ceux installés à partir d'un tag Git fixe ou d'un commit.
  Cette PR étend également la commande `install` pour prendre un chemin source ou une URL en plus d'un
  nom de plugin.

- [Core Lightning #8021][] finalise l'interopérabilité de [splicing][topic splicing] avec Eclair
  (voir le Bulletin [#331][news331 interop]) en corrigeant la rotation des clés de financement à
  distance, en renvoyant `splice_locked` lors du réétablissement du canal pour couvrir les cas où
  il était initialement manqué (voir le Bulletin [#345][news345 splicing]), en assouplissant l'exigence
  que les messages signés d'engagement arrivent dans
  un ordre particulier, permettant de recevoir et d'initier des transactions de raccordement
  [RBF][topic rbf], convertissant automatiquement les [PSBTs][topic psbt] sortants en version 2
  lorsque nécessaire, ainsi que d'autres modifications de refactoring.

- [Core Lightning #8226][] implémente [BIP137][] en ajoutant une nouvelle commande RPC
  `signmessagewithkey` qui permet aux utilisateurs de signer des messages avec n'importe quelle clé du
  portefeuille en spécifiant une adresse Bitcoin. Auparavant, signer un message avec une clé Core
  Lightning nécessitait de trouver le xpriv et l'index de la clé, de dériver la clé privée avec une
  bibliothèque externe, puis de signer le message avec Bitcoin Core.

- [LND #9801][] ajoute une nouvelle option `--no-disconnect-on-pong-failure`, qui contrôle si un
  pair est déconnecté si une réponse pong est tardive ou ne correspond pas. Cette option est définie
  sur false par défaut, préservant le comportement actuel de LND qui se déconnecte d'un pair en cas
  d'échec du message pong (voir le Bulletin [#275][news275 ping]) ; autrement, LND ne ferait que
  consigner l'événement. La PR refactorise le chien de garde ping pour continuer sa boucle lorsque la
  déconnexion est supprimée.

{% include snippets/recap-ad.md when="2025-05-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32423,31444,8140,8136,8266,8021,8226,9801,7044,1215" %}
[lnd 0.19.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[sources]: /en/internal/sources/
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.19.0.md
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[news348 txgraph]: /fr/newsletters/2025/04/04/#bitcoin-core-31363
[news238 storage]: /fr/newsletters/2023/02/15/#core-lightning-5361
[news226 reckless]: /fr/newsletters/2022/11/16/#core-lightning-5647
[news331 interop]: /fr/newsletters/2024/11/29/#core-lightning-7719
[news345 splicing]: /fr/newsletters/2025/03/14/#eclair-3007
[news275 ping]: /fr/newsletters/2023/11/01/#lnd-7828
[cake wallet 4.28.0]: https://github.com/cake-tech/cake_wallet/releases/tag/v4.28.0
[cake blog]: https://blog.cakewallet.com/bitcoin-privacy-takes-a-leap-forward-cake-wallet-introduces-payjoin-v2/
[sparrow 2.2.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.2.0
[safe wallet github]: https://github.com/andreasgriffin/bitcoin-safe
[safe wallet 1.3.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.3.0
[coldcard blog]: https://blog.coinkite.com/ccc-and-keyteleport/
[coldcard ccc]: https://coldcard.com/docs/coldcard-cosigning/
[coldcard kt]: https://github.com/Coldcard/firmware/blob/master/docs/key-teleport.md
[private pond post]: https://njump.me/naddr1qvzqqqr4gupzqg42s9gsae3lu2cketskuzfp778fh2vg9c5x3elx8ttdpzhfkk25qq2nv5nzddgxxdjtd4u9vwrdv939vmnswfzk6j85dxk
[private pond github]: https://github.com/Kukks/PrivatePond
[jmfbs github]: https://github.com/m0wer/joinmarket-fidelity-bond-simulator
[news161 fb]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[opcode explained website]: https://opcodeexplained.com/
[bitkey blog]: https://x.com/BEN0WHERE/status/1918073429791785086
[bitkey github]: https://github.com/proto-at-block/bitkey
