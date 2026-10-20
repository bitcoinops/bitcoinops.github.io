---
title: 'Bulletin Hebdomadaire Bitcoin Optech #418'
permalink: /fr/newsletters/2026/08/14/
name: 2026-08-14-newsletter-fr
slug: 2026-08-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un protocole de contrat proposé pour atténuer le brouillage de canaux sur le Lightning Network, signale
la disponibilité de binaires statiques de Bitcoin Core pour les tests, et résume un changement remplaçant la limitation du débit de
transactions par pair de Bitcoin Core par une approche globale. Sont également incluses nos sections régulières annonçant de nouvelles
versions et versions candidates, et décrivant des changements notables dans les logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Contrat de transfert conditionnel de message pour résoudre le brouillage** : Antoine Riard a [publié][chan jam del] sur Delving Bitcoin
  une nouvelle approche pour atténuer le [brouillage de canaux][topic channel jamming attacks] sur le Lightning Network. Le brouillage est
  une attaque par déni de service dans laquelle l'attaquant envoie des [HTLCs][topic htlc] ou des [PTLCs][topic PTLC], puis les laisse sans
  résolution, immobilisant ainsi la liquidité du canal le long d'une route sans coût pour lui-même. La proposition de Riard rend la
  rétention coûteuse en facturant des frais de retenue proportionnels à la durée pendant laquelle un paiement est retenu, transformant une
  attaque actuellement gratuite en une attaque coûteuse.

  Le mécanisme est un contrat de transfert conditionnel de message (CMTC), qui est une construction Bitcoin Script permettant à deux
  contreparties d'un canal de prouver plus tard si un message spécifique (tel qu'une préimage de paiement) a été échangé entre elles avant
  une hauteur de bloc donnée, que Riard traite comme une horloge universelle. Les parties s'accordent sur une fenêtre temporelle et
  assignent un point adaptateur à chaque instant dans cette fenêtre, afin que les frais de retenue puissent être réglés en fonction du
  moment où le message a été livré. Le contrat offre trois chemins de règlement :

  - **Succès du transfert de message :** la préimage est livrée de Bob à Alice et reconnue cryptographiquement, et les deux se partagent les
    frais de retenue en fonction du moment de la livraison.

  - **Défi de vivacité :** si Alice est hors ligne et ne peut pas contre-signer, Bob peut sortir du contrat et récupérer les fonds
    verrouillés moins des frais de pénalité d'équilibre.

  - **Échec du transfert de message :** si Bob est hors ligne ou échoue d'une autre manière à transférer le message, Alice peut sortir et
    récupérer les frais de retenue.

  Riard note que la solution proposée nécessite une analyse plus approfondie, tant de sa correction cryptographique que de ses incitations,
  et qu'il reste à déterminer si cette approche, ou une extension de celle-ci, pourrait résoudre d'autres types de problèmes dans Bitcoin.

- **Binaires statiques de Bitcoin Core disponibles pour les tests** : Michael Ford (fanquake) a [publié][fanquake static ml] sur la liste de
  diffusion Bitcoin-Dev l'annonce de compilations de test de binaires de publication statiques de Bitcoin Core produites à l'aide de
  l'infrastructure existante du projet [Guix][topic reproducible builds]. Des binaires de test sont disponibles pour `bitcoind` et les
  autres utilitaires en ligne de commande sur Linux x86_64 et aarch64, avec davantage de plateformes prévues. Le binaire d'interface
  graphique `bitcoin-qt` est inchangé.

  Les binaires Linux actuels de publication de Bitcoin Core sont liés dynamiquement, ce qui signifie qu'ils contiennent la majeure partie du
  code dont ils ont besoin mais dépendent de la bibliothèque C (glibc) et de quelques bibliothèques associées fournies par le système
  d'exploitation de l'utilisateur. Ces bibliothèques sont localisées et chargées à chaque démarrage du programme, une dépendance qui
  comporte certains risques. Les binaires ne s'exécutent que sur des systèmes qui fournissent une glibc compatible (actuellement version
  2.31 ou ultérieure), leur comportement peut varier selon les bibliothèques de l'hôte, et une partie du code que le nœud exécute réellement
  se trouve en dehors du binaire que les compilations reproductibles permettent aux utilisateurs de vérifier. Un binaire statique inclut à
  la place tout le code dont il a besoin, de sorte que le même exécutable vérifié s'exécute de la même manière sur presque n'importe quel
  système Linux, y compris des versions plus anciennes, des distributions construites sur une bibliothèque C différente comme Alpine Linux,
  et des images de conteneur minimales ne fournissant aucune bibliothèque système. Les nouveaux binaires restent des exécutables
  indépendants de la position, préservant l'atténuation d'exploitation ASLR des versions actuelles, et ne sont plus gros que d'environ 1 Mo.

  Le message sur la liste de diffusion prolonge des années de travail dans [Bitcoin Core #25573][], que Ford a ouvert en 2022. Les progrès
  ont nécessité des modifications du compilateur GCC et de glibc elle-même, y compris des correctifs du code de résolution de noms de glibc,
  historiquement le principal danger de l'édition de liens statique avec glibc. Certains changements préparatoires du processus de
  compilation Guix (voir [Bitcoin Core #35537][]) ont été fusionnés, mais la PR principale reste ouverte et en cours de revue. Les lecteurs
  qui exécutent Bitcoin Core sur Linux sont encouragés à essayer les [binaires de test][static test bins] et à signaler tout problème, ou
  succès, à la liste de diffusion ou à la PR.

- **Remplacement de la limitation du débit de transactions par pair par des limites globales** : Anthony Towns a [publié][peer queue del]
  sur Delving Bitcoin l'annonce de la fusion de [Bitcoin Core #34628][], qui remplace la limitation du débit de transactions par pair par
  une approche globale.

  Pour chacun de ses pairs, un nœud conserve une file des annonces de transactions qu'il a l'intention d'envoyer à ce pair, appelée
  `m_tx_inventory_to_send`, trie ces annonces par taux de frais des ancêtres, et envoie d'abord les meilleures. Pour limiter la bande
  passante et rendre plus difficile la cartographie de la topologie de relais, un nœud n'annonce pas plus d'environ 7 transactions par
  seconde à chaque pair. En temps normal, ce débit suffit à vider la file, mais une brusque rafale de transactions peut la remplir plus vite
  que la limite ne permet de la vider. Parce que le nœud retrie la file croissante à chaque annonce, cela peut consommer une quantité
  excessive de CPU, un vecteur de déni de service (DoS) décrit précédemment dans [Bulletin #324][news324 dos].

  La PR de Towns remplace la limitation par pair par une limite de débit globale, en utilisant deux seaux à jetons qui mesurent les annonces
  totales par nombre (nombre de transactions) et par taille (taille sérialisée avec témoins). S'il y a suffisamment de capacité, une
  transaction entrante est relayée immédiatement, sinon elle est ajoutée à un unique arriéré global trié par taux de frais et selon les
  règles de [cluster mempool][topic cluster mempool]. Les transactions sélectionnées dans cet arriéré sont ensuite placées dans une petite
  file par pair utilisée pour le regroupement confidentiel. Trier un arriéré partagé au lieu d'une file séparée par pair évite les tris
  répétés par pair qui faisaient du design d'origine un vecteur de DoS.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [BTCPay Server 2.4.2][] est une version de sécurité qui corrige une vulnérabilité critique affectant toutes les versions antérieures à
  2.4.2. Un attaquant distant non authentifié pouvait obtenir les fichiers d'identification `.macaroon` d'un nœud LND et les utiliser pour
  prendre le contrôle du nœud et déplacer des fonds. Le projet [signale][btcpay 2.4.2 advisory] que la vulnérabilité a été exploitée et que
  des fonds ont été volés. Les opérateurs de BTCPay Server utilisant LND devraient mettre à jour immédiatement vers 2.4.2 et LND 0.21.1,
  auditer leur nœud afin de détecter toute activité non autorisée, et faire tourner leurs identifiants macaroon, puisqu'un attaquant peut
  les avoir déjà obtenus. Les portefeuilles onchain de BTCPay Server et les déploiements utilisant d'autres implémentations Lightning ne
  sont pas exposés à ce risque spécifique.

- [LND v0.21.2-beta][] est une version de maintenance de cette populaire implémentation de nœud LN. Elle corrige deux échecs de migration de
  base de données, borne l'utilisation mémoire pendant la synchronisation du graphe des canaux, et corrige des bogues affectant les messages
  onion, les fermetures coopératives RBF, les mises à jour de factures, le transfert de paiements [blinded][topic rv routing], et la
  résolution des [HTLC][topic htlc].

- [LND v0.20.3-beta][] est une version de maintenance de la branche de publication 0.20 de LND. Elle rétroporte plusieurs correctifs
  également inclus dans 0.21.2-beta, y compris des bornes sur l'utilisation mémoire pendant la synchronisation du graphe des canaux et des
  correctifs pour les fermetures coopératives, les mises à jour de factures, le transfert de paiements blinded et la résolution des HTLC.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35493][] corrige un faux avertissement indiquant que des clés privées manquaient lors de l'importation de
  [descripteurs][topic descriptors] [MuSig2][topic musig] (voir le [Bulletin #366][news366 musig descriptors]) avec toutes les clés privées
  requises. Auparavant, le RPC `importdescriptors` vérifiait la présence d'une clé privée correspondante pour chaque clé publique produite
  lors de l'expansion du descripteur, y compris la clé agrégée MuSig, qui n'a pas de clé privée autonome. Cela pouvait conduire à ce qu'un
  descripteur contenant toutes les clés privées de ses participants soit signalé comme incomplet. La vérification de complétude tient
  désormais compte des clés des participants MuSig, de sorte que les descripteurs complets s'importent sans avertissement, tandis que ceux
  auxquels il manque des clés privées de participants déclenchent toujours un avertissement.

- [Core Lightning #9150][] introduit `impressions`, un nouveau type d'information de liquidité qui enregistre les paiements réussis à
  travers un canal et permet à la commande RPC `askrene` (voir le [Bulletin #316][news316 askrene]) d'ajuster ses estimations de liquidité pour
  les tentatives de routage ultérieures. En outre, la commande RPC `getroutes` est mise à jour pour fournir des messages d'erreur plus
  spécifiques lorsqu'un routage échoue, par exemple lorsque la source dispose de fonds insuffisants ou que la destination a une capacité
  entrante insuffisante. De plus, la PR limite par défaut à 10 minutes l'expiration des factures générées à partir d'offres [BOLT12][topic
  offers] libellées dans une autre devise afin de tenir compte des fluctuations du taux de change.

- [BIPs #2248][] met à jour [BIP3][] pour retirer Luke Dashjr de la liste des éditeurs de BIP, à la suite d'une [discussion][luke removal
  ml] sur la liste de diffusion Bitcoin-Dev. Voir le [Bulletin #299][news299 bip editors] pour la couverture précédente de l'ensemble des
  éditeurs.

- [BIPs #2225][] et [#2245][bips #2245] mettent à jour [BIP110][] (voir le [Bulletin #412][news412 bip110]) à la suite de sa tentative d'activation infructueuse.
  [#2245][bips #2245] change son statut en Closed. [#2225][bips #2225] transforme en exigence de consensus la règle de politique de
  [BIP433][] imposant que les dépenses [pay-to-anchor (P2A)][topic ephemeral anchors] comportent une pile witness vide.

- [Eclair #3346][] corrige un plantage et apporte plusieurs améliorations de gestion onchain et des canaux. Il vérifie désormais que les
  échecs de paiement déchiffrés correspondent à une position intermédiaire valide dans la route de paiement avant de les utiliser comme
  information de routage, empêchant ainsi des échecs malformés ou malicieusement conçus par le destinataire de déclencher un accès hors
  limites susceptible de faire planter l'acteur du cycle de vie du paiement. Il commence également à réessayer les diffusions de
  transactions onchain lorsqu'il reçoit de Bitcoin Core des messages d'erreur qu'il ne peut pas classifier, au lieu d'abandonner
  potentiellement une transaction sensible au temps. Lors de l'utilisation de [CPFP][topic cpfp] pour augmenter les frais de l'[engagement
  sans frais][topic v3 commitments] d'un pair, il prend désormais en compte le poids complet du [package][topic package relay] parent-enfant
  au lieu du seul poids du parent. Enfin, Eclair utilise désormais le nonce [MuSig2][topic musig] associé à la tentative de financement
  [RBF][topic rbf] qui a effectivement confirmé lors de l'envoi de `channel_ready`, au lieu de supposer que sa dernière tentative RBF est
  celle qui a confirmé.

- [Eclair #3341][] se prépare à relayer de futurs [messages gossip][topic channel announcements] `channel_update` qui utilisent des
  `message_flags` ou `channel_flags` actuellement non définis dans [BOLT7][]. Auparavant, si Eclair recevait une mise à jour avec un bit
  d'indicateur inconnu défini à un, il rejetait cette valeur et encodait le bit à zéro lors du transfert de la mise à jour. Cela modifiait
  le message signé et invalidait sa signature. Désormais, Eclair préserve les valeurs d'indicateurs inconnues lors du décodage et du
  réencodage des messages `channel_update`, permettant aux nœuds Eclair de relayer des mises à jour contenant des indicateurs qu'ils ne
  comprennent pas encore.

- [LND #11019][] corrige une compétition de données dans l'ancienne machine à états de fermeture coopérative, qui pouvait se produire
  lorsque la goroutine du lien (qui suit l'état des HTLC et de l'engagement du canal) et la goroutine du pair (qui traite les messages de
  fermeture du pair distant) progressaient concurremment. Désormais, au lieu de faire progresser le fermeur lui-même, le lien signale au
  gestionnaire de canaux du pair lorsqu'un canal a été purgé (les HTLC en attente ont été vidés), garantissant que toutes les transitions de
  la machine à états de fermeture s'exécutent sur une seule goroutine. La PR garantit également que le chemin de fermeture coopérative RBF
  (voir le [Bulletin #347][news347 rbf coop]) vérifie la présence du script de réception du pair
  et qu'il utilise un type de sortie accepté, même lorsqu'aucun script upfront shutdown n'a été négocié (voir le [Bulletin #76][news76 upfront]).

- [LND #11023][] modifie la gestion de `update_fee` pour correspondre au modèle d'état remplaçable de [BOLT2][] et empêcher que des mises à
  jour de frais redondantes non engagées ne fassent grossir le journal des mises à jour. Si une mise à jour de frais plus récente arrive
  avant que la précédente n'ait été incluse dans la transaction d'engagement de l'une ou l'autre des parties, LND remplace désormais la
  valeur de frais précédente sur place. La PR limite également les boîtes aux lettres de canal à 1 000 messages en file d'attente et 4 Mio
  de données sérialisées. Si un message ne peut pas être accepté, LND déconnecte le pair au lieu d'abandonner le message et de traiter les
  messages suivants dans le désordre. Cela permet de récupérer l'état ordonné du canal lors de la reconnexion.

- [Libsecp256k1 #1904][] renforce l'auto-test de démarrage pour les applications qui fournissent leur propre fonction de compression SHA256
  (voir le [Bulletin #396][news396 sha256]). Auparavant, l'auto-test hachait un unique message de 63 octets,
  ce qui pouvait détecter des implémentations généralement incorrectes mais pas celles qui échouaient lors du traitement de plusieurs blocs,
  d'une entrée non alignée, ou d'un état SHA256 autre que l'état initial. Le nouveau test utilise différentes longueurs de message et
  différents alignements d'entrée. Il rejette une fonction de compression fournie si ses résultats diffèrent des résultats SHA256 attendus,
  permettant de détecter des implémentations défectueuses pendant l'initialisation plutôt que de produire ultérieurement des résultats
  incorrects.

- [HWI #839][] corrige plusieurs problèmes d'analyse [PSBT][topic psbt] et de reconstruction de transaction révélés lors de l'ajout des
  suites complètes de vecteurs de test [BIP174][] et [BIP370][]. Lors de la reconstruction d'une transaction à partir de PSBTv2, HWI
  applique désormais le [locktime][topic timelock] calculé au lieu de le laisser à zéro et utilise la valeur finale de séquence spécifiée
  (0xffffffff) lorsqu'une entrée omet `PSBT_IN_SEQUENCE`. Pour PSBTv0, [HWI][topic hwi] rejette les champs d'entrée et de sortie réservés à
  v2 et analyse strictement la transaction non signée globale en utilisant une sérialisation sans witness, tout en reconnaissant
  correctement qu'une transaction non signée vide est présente. La PR valide également que les locktimes requis basés sur la hauteur et le
  temps se situent dans les plages spécifiées et ajoute des tests pour la détermination du locktime de BIP370.

{% include snippets/recap-ad.md when="2026-08-18 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="25573,35537,34628,35493,9150,2248,2225,2245,3346,3341,11019,11023,1904,839" %}

[chan jam del]: https://delvingbitcoin.org/t/conditional-message-transfer-contract-to-solve-jamming/2772
[fanquake static ml]: https://groups.google.com/g/bitcoindev/c/UgGHs-_YGvw
[static test bins]: https://github.com/fanquake/bitcoin/releases/tag/static_bitcoind_ff01e5af948d
[peer queue del]: https://delvingbitcoin.org/t/transaction-rate-limiting/2744
[news324 dos]: /fr/newsletters/2024/10/11/#dos-par-ensembles-d-inventaire-importants
[luke removal ml]: https://groups.google.com/g/bitcoindev/c/knbv3MFwlvU
[topic timelock]: /en/topics/timelocks/
[BTCPay Server 2.4.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.2
[btcpay 2.4.2 advisory]: https://blog.btcpayserver.org/security-advisory-btcpay-server-2-4-2/
[LND v0.21.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.2-beta
[LND v0.20.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.3-beta
[news366 musig descriptors]: /fr/newsletters/2025/08/08/#bitcoin-core-31244
[news316 askrene]: /fr/newsletters/2024/08/16/#core-lightning-7517
[news299 bip editors]: /fr/newsletters/2024/04/24/#mise-a-jour-des-editeurs-bip
[news412 bip110]: /fr/newsletters/2026/07/03/#bips-2201
[news347 rbf coop]: /fr/newsletters/2025/03/28/#lnd-8453
[news76 upfront]: /en/newsletters/2019/12/11/#lnd-3655
[news396 sha256]: /fr/newsletters/2026/03/13/#libsecp256k1-1777
