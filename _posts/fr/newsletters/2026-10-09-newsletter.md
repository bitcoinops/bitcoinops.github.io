---
title: 'Bulletin Hebdomadaire Bitcoin Optech #426'
permalink: /fr/newsletters/2026/10/09/
name: 2026-10-09-newsletter-fr
slug: 2026-10-09-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine renvoie vers un projet de BIP permettant aux pairs de choisir leurs propres identifiants de type de message sur
un octet via le transport P2P version 2, résume une discussion sur la question de savoir si les BIP devraient inclure leur numéro dans les
tags de hachage étiqueté, et décrit un métaprotocole proposé pour des transferts onchain privés ne nécessitant aucune modification du
consensus. Sont également incluses nos sections habituelles annonçant les nouvelles versions et versions candidates et décrivant les
changements notables dans les logiciels populaires de l'infrastructure Bitcoin.

## Nouvelles

- **Identifiants dynamiques de type de message sur un octet pour BIP324 :** Anthony Towns a [publié][towns set324alias] sur la liste de
  diffusion Bitcoin-Dev un projet de BIP qui permet à chaque pair de choisir ses propres identifiants de type de message sur un octet pour
  les messages qu'il envoie via le [transport P2P v2][topic v2 p2p transport]. [BIP324][] attribue des identifiants sur un octet à partir
  d'une table fixe, de sorte que tout nouveau message nécessite une entrée coordonnée globalement (voir le [Bulletin #392][news392 bip324
  ids]) ou doit utiliser son nom complet sur 12 octets. Avec un nouveau message `set324alias`, un nœud annonce ses propres alias au moment
  de la connexion, de sorte que de nouveaux messages peuvent être déployés et expérimentés au niveau P2P sans cette coordination. Towns a
  également [noté][towns set324alias savings] que l'économie d'espace va jusqu'à 66 % sur une connexion ne transportant que des pings, à
  environ 5 % sur une connexion typique, et est nulle tant que de nouveaux messages sans identifiant existant sur un octet ne sont pas
  déployés.

- **Discussion sur les conventions pour les tags de hachage étiqueté dans les BIP :** Fabian Jahr a [publié][jahr tagged hash] sur la liste
  de diffusion Bitcoin-Dev pour demander si les BIP qui utilisent les hachages étiquetés de [BIP340][] devraient inclure le numéro du BIP
  dans le tag. Les BIP 324, 340, 352, 374 et 445 le font, tandis que BIP327 et BIP341 utilisent des noms descriptifs tels que "TapLeaf". Un
  numéro garantit l'unicité, mais modifier les tags d'un brouillon lorsqu'un numéro est attribué casse les implémentations et vecteurs de
  test existants, ce que Jahr a constaté après avoir fait passer son brouillon [DahLIAS][news415 dahlias] (BIP459) à la forme numérotée.
  Sjors Provoost a [répondu][provoost tagged hash] que BIP138 incluait son numéro et que régénérer ses vecteurs de test avait eu un coût
  mineur.

- **Proposition de transferts privés onchain de bitcoins sans modification du consensus** : Misha Komarov a [publié][shield del] sur Delving
  Bitcoin une proposition pour un nouveau métaprotocole construit au-dessus de Bitcoin, appelé Shielded Bitcoin, qui permettrait des
  transferts privés tout en ne nécessitant aucune modification du consensus. Komarov, avec Clara Shikhelman et Aleksei Moskvin, a récemment
  publié un [article][shield paper] complet décrivant le protocole.

  L'objectif du métaprotocole proposé est de transférer des bitcoins de manière privée, sans révéler ni le montant transféré ni les
  contreparties impliquées dans la transaction. Il vise à y parvenir sans nécessiter d'opérateurs de confiance, d'interactivité ou de
  dépendances de vivacité. Shielded Bitcoin nécessite un moyen d'entrer et de sortir du métaprotocole. Le processus sera détaillé dans un
  article compagnon qui devrait être publié bientôt, mais Komarov a noté qu'il sera basé sur un schéma de chiffrement de témoin appelé PIPEs
  (voir le [Bulletin #393][news393 pipes]).

  Les transferts Shielded Bitcoin sont fondés sur un objet de propriété appelé une note, qui joue un rôle similaire à celui d'un UTXO
  Bitcoin. Les notes sont des enregistrements chiffrés qui stockent des informations telles que le montant et le matériel de clé du
  destinataire. Lorsqu'un transfert est effectué, Alice publie une transaction Bitcoin contenant les nouvelles notes chiffrées, un nombre
  unique appelé nullifier pour chaque note dépensée, et une preuve qui affirme que les notes existent, qu'elle est autorisée à les dépenser,
  et que les montants en entrée sont égaux à ceux en sortie. Ces preuves sont vérifiées par un programme externe, appelé indexeur, qui
  s'assure qu'aucune des notes n'a déjà été dépensée. Si la preuve est valide, les nouvelles notes sont ajoutées à la liste et les
  nullifiers sont enregistrés comme utilisés. N'importe qui peut exécuter un indexeur, il n'est donc pas nécessaire de s'appuyer sur un
  service centralisé pour valider les preuves.

  Le métaprotocole est non dépositaire. Un portefeuille dérive différentes clés à partir d'une seule graine, chacune ayant sa propre tâche
  spécifique, comme une clé de dépense, une clé en lecture seule pour les transferts entrants, et une pour les sortants. Seule une clé de
  dépense valide accorde l'autorité de transférer une note et aucun tiers, tel que des mineurs, des indexeurs ou un observateur extérieur,
  ne peut voler les fonds.

  Komarov a également fourni un aperçu de ce qu'un observateur extérieur peut voir, comme le nombre de notes créées, les frais, la taille et
  le moment des données publiées, et le fait qu'un transfert protégé a eu lieu. Komarov a décrit les limites et compromis, tels que la
  nécessité d'une cérémonie d'initialisation unique, qui rend les garanties de sécurité valides dès lors qu'au moins une partie honnête est
  impliquée, et le fait que l'entrée et la sortie du protocole laissent une trace visible. Komarov a également comparé la conception à
  d'autres protocoles proposés de confidentialité onchain, tels que les [coinjoins][topic coinjoin] et les [payjoins][topic payjoin],
  Shielded CSV (désormais Glass Coins), qui utilise une approche fondée sur la [validation côté client][topic client-side validation], et
  Zcash, la conception la plus proche, qui utilise sa propre chaîne.

  Dans la discussion qui a suivi, ZmnSCPxj a noté qu'un service externe pourrait réduire les données qu'un appareil aux ressources limitées
  doit analyser pour récupérer des fonds, au prix d'une perte de confidentialité similaire à Electrum si une clé de visualisation est donnée
  au service. Il a également demandé si les sorties unilatérales nécessitent une preuve SPV exprimée comme condition du schéma de
  chiffrement de témoin. La coautrice Clara Shikhelman a répondu que les sorties utilisent des dénominations fixes et que toutes les
  informations sur les sorties seront détaillées dans l'article à venir.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 32.0rc3][] est une version candidate pour la prochaine version majeure de l'implémentation de nœud complet prédominante. Un
  [guide de test][bcc32 testing] est disponible.

- [Core Lightning 26.06.9][] est une version de sécurité de cette implémentation populaire de nœud LN. Elle corrige des vulnérabilités dans
  le rétablissement de canal, la gestion du [splicing][topic splicing], des [HTLC][topic htlc], et des contrôles d'accès, entre autres. Elle
  corrige également une régression de la version 26.06.8 qui pouvait retarder le trafic des canaux en limitant incorrectement les pairs pour
  le [gossip][topic channel announcements] ordinaire, les pings et les [messages onion][topic onion messages]. Bien que les tests pour les
  correctifs de sécurité soient temporairement retenus afin de rendre plus difficile leur transformation en exploits fonctionnels, le code
  source est disponible immédiatement. Le projet recommande fortement de mettre à niveau.

- [LDK v0.3-rc3][] est la troisième version candidate pour la prochaine version majeure de cette bibliothèque permettant de construire des
  portefeuilles et applications compatibles LN. Elle ajoute l'augmentation des frais par [RBF][topic rbf] pour les [splices][topic splicing]
  en attente et la prise en charge de l'ajout et du retrait de fonds dans le même splice. Elle négocie également les [canaux anchor][topic
  anchor outputs] par défaut et oblige les applications à accepter explicitement les canaux entrants. La mise à niveau invalide les factures
  [BOLT11][] précédemment émises contenant des métadonnées de paiement. Les développeurs devraient examiner les [changements d'API et de
  compatibilité ascendante][ldk 0.3 notes] avant de tester.

- [LDK v0.2.7][] et [v0.1.13][ldk v0.1.13] sont des versions de sécurité pour les branches 0.2 et 0.1 de cette bibliothèque permettant de
  construire des portefeuilles et applications compatibles LN. Les deux incluent le correctif contre le vol de fonds lors du rétablissement
  de canal décrit ci-dessous ainsi qu'un correctif DoS pour la synchronisation basée sur Electrum. La version 0.2.7 inclut en plus les
  correctifs de validation du montant [LSPS2][BLIP52] et d'état de canal périmé décrits ci-dessous. La version 0.1.13 corrige également un
  échec de désérialisation du gestionnaire de canaux déclenché par des [HTLC][topic htlc] invalides, précédemment corrigé dans la version
  0.2.6.

- [BTCPay Server 2.4.5][] est une version de sécurité de ce processeur de paiement auto-hébergé. Elle bloque par défaut les destinations de
  réseau privé pour les requêtes HTTP sortantes utilisées par les connexions Lightning, [LNURL][topic lnurl], les notifications de facture
  et les webhooks afin d'empêcher les falsifications de requêtes côté serveur. Elle renforce également les permissions sur les factures et
  remboursements et accélère la création des factures. Les changements Docker associés rendent Tor optionnel par choix explicite, y compris
  pour les déploiements existants, et suppriment plusieurs intégrations non maintenues. Les administrateurs sont encouragés à mettre à
  niveau et à examiner les [changements de déploiement][btcpay 2.4.5 announcement].

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #36277][] corrige une fuite potentielle de [confidentialité de l'origine des transactions][topic transaction origin privacy]
  dans la fonctionnalité expérimentale et optionnelle de diffusion privée (voir les Bulletins [#388][news388 private broadcast] et
  [#425][news425 private broadcast]). Auparavant, recevoir une transaction en retour via le réseau annulait les tentatives initiales
  restantes de diffusion privée. Un attaquant contrôlant l'un des pairs de diffusion privée pouvait exploiter ce comportement en retardant
  sa requête sur cette connexion tout en relayant la transaction en retour vers le nœud soupçonné d'en être l'origine via une connexion
  séparée. Si le nœud fermait alors la connexion privée en attente au lieu de répondre à la requête, l'attaquant pouvait déduire que le nœud
  avait créé la transaction. Bitcoin Core termine maintenant les trois tentatives initiales de diffusion privée via Tor ou I2P même si la
  transaction s'est déjà propagée, tout en permettant aux nouvelles tentatives ultérieures de s'arrêter lorsque c'est approprié.

- [Bitcoin Core #36365][] corrige deux problèmes de l'[estimateur de frais basé sur le mempool][topic fee estimation] (voir le [Bulletin
  #420][news420 fee estimation]). Auparavant, l'estimateur combiné renvoyait une erreur si l'estimateur basé sur le mempool n'était pas
  disponible, même si l'estimateur existant basé sur les confirmations disposait d'une estimation valide. Désormais, il se rabat sur cette
  estimation tout en continuant à sélectionner la plus basse des deux lorsque les deux sont disponibles. La PR empêche également
  l'utilisation de l'estimateur basé sur le mempool immédiatement après un redémarrage si le mempool ne parvient pas à se charger.
  Auparavant, les statistiques de santé sauvegardées pouvaient conduire à considérer un mempool vide comme sain, entraînant des estimations
  de frais artificiellement basses. Elle renomme aussi la valeur par défaut `fee_rate_estimator` du RPC `estimatesmartfee` de `none` à
  `auto` et rejette les valeurs non reconnues.

- [Bitcoin Core #36338][] corrige un bogue dans son implémentation de [BIP352][] [silent payments][topic silent payments] qui pouvait amener
  un portefeuille à manquer des paiements lorsqu'une transaction contient une entrée P2PKH modifiée mais toujours valide au niveau du
  consensus (voir le [Bulletin #425][news425 silent payments]). Un attaquant pouvait insérer une signature invalide et une branche
  conditionnelle contenant une clé publique différente dans le `scriptSig` de l'entrée sans invalider la transaction. Auparavant, Bitcoin
  Core évaluait `scriptSig` en utilisant un vérificateur de signature factice qui acceptait la signature invalide, exécutait la branche et
  extrayait la mauvaise clé publique, ce qui pouvait faire manquer un paiement au scanner. Le correctif recherche désormais dans `scriptSig`
  une clé publique compressée valide dont le HASH160 correspond au hachage engagé dans la sortie dépensée. Cette implémentation n'est pas
  encore intégrée au portefeuille.

- [Bitcoin Core #32895][] prépare le portefeuille à de futures mises à niveau automatiques en enregistrant la version et les fonctionnalités
  prises en charge par le dernier client qui l'a ouvert. Sans ce suivi, mettre à niveau un portefeuille, le rouvrir avec une ancienne
  version de Bitcoin Core, puis le remettre à niveau pourrait entraîner une combinaison d'anciens et de nouveaux enregistrements de
  portefeuille. Par exemple, l'ancienne version pourrait créer de nouveaux enregistrements dans l'ancien format, mais une version plus
  récente supposerait que le portefeuille a déjà été mis à niveau et ignorerait la migration. Les nouvelles métadonnées permettront aux
  futures versions d'identifier ces scénarios mise à niveau-rétrogradation-mise à niveau et d'effectuer les migrations nécessaires. Elles
  enregistrent séparément les fonctionnalités du dernier client à déchiffrer le portefeuille, car certaines mises à niveau nécessitent
  l'accès aux clés privées.

- [Core Lightning #9582][] reporte 77 commits contenant des correctifs de sécurité et de fiabilité depuis la version v26.06.8 (voir le
  [Bulletin
  #424][news424 cln release]) vers la branche master. Un correctif empêche que
  des fermetures forcées après un [splice][topic splicing] terminé diffusent une transaction d'engagement obsolète qui peut avoir été
  révoquée par des mises à jour ultérieures du canal, permettant à la contrepartie de réclamer les fonds comme [pénalité][topic ln-penalty].
  Un autre corrige la résolution onchain des [HTLC][topic htlc] en faisant correspondre les sorties à la fois sur le script et sur le
  montant. Auparavant, des HTLC ayant le même hachage de paiement et la même expiration mais des montants différents pouvaient être
  confondus, ce qui pouvait amener CLN à échouer un HTLC entrant alors que le HTLC sortant correspondant restait réclamable onchain. La PR
  corrige également une vulnérabilité d'escalade de privilèges dans laquelle un appelant autorisé à utiliser le RPC `makesecret` pouvait
  dériver le secret cryptographique de la rune maître et forger des jetons d'autorisation RPC sans restriction. CLN bloque désormais la
  dérivation de ce secret réservé. Des correctifs supplémentaires traitent des risques de DoS liés au [gossip][topic channel announcements],
  de la gestion du [dual-funding][topic dual funding] et du splice-[RBF][topic rbf], des calculs de frais [anchor][topic anchor outputs], du
  traitement des [paiements multiparties][topic multipath payments], de la validation et de la mise sur liste noire des runes, de la gestion
  des messages [BOLT11][] et [BOLT12][topic offers], du routage onion, et des vulnérabilités d'épuisement des ressources de l'API REST.

- [Eclair #3390][] et [#3388][eclair #3388] comblent des lacunes dans les protections contre des frais de minage excessifs durant le [dual
  funding][topic dual funding] et le [splicing][topic splicing] (voir le [Bulletin #423][news423 eclair fees]). Le premier protège contre un
  backend Bitcoin Core compromis, qui construit les transactions pendant qu'Eclair détient les clés, et qui pourrait déclarer de faux frais
  ou manipuler les sorties de transaction, amenant Eclair à signer des transactions qui paient plus que prévu. Eclair vérifie désormais
  indépendamment les frais réels et s'assure que les transactions de financement reconstruites respectent les montants attendus. Le second
  empêche un pair de canal malveillant d'imposer un taux de frais [RBF][topic rbf] excessivement élevé lorsqu'Eclair apporte des fonds à une
  transaction de remplacement de dual funding ou de splice. Eclair rejette désormais les propositions au-dessus de son maximum calculé
  localement, sauf lorsque le pair paie les frais via un [achat de liquidité][topic liquidity advertisements].

- [LDK #5057][] corrige une vulnérabilité qui pourrait permettre à un pair de canal malveillant de voler la valeur d'un [HTLC][topic htlc]
  transféré. Pendant une reconnexion, un pair pouvait prétendre à tort dans un message `channel_reestablish` qu'il avait manqué un
  engagement qu'il avait déjà reconnu avec `revoke_and_ack`. LDK pouvait alors accepter incorrectement cette affirmation et signer une
  nouvelle transaction d'engagement valide sans l'enregistrer dans son `ChannelMonitor`. Le pair pouvait ensuite publier la transaction
  onchain. Si LDK réglait ensuite le paiement transféré, il pouvait échouer à réclamer le HTLC entrant correspondant, même s'il connaissait
  la préimage. Cela permettrait au pair malveillant de récupérer ces fonds après l'expiration du HTLC. LDK n'autorise désormais la
  retransmission d'engagement que lorsque l'accusé de réception du pair est encore en attente ; sinon, il force la fermeture du canal.

- [LDK #5042][] corrige un bogue qui pourrait amener un LSP à perdre des fonds lors du traitement d'un paiement de [canal
  juste-à-temps][topic jit channels] [LSPS2][BLIP52]. Auparavant, le LSP faisait confiance au montant de transfert spécifié dans la charge
  utile onion du payeur sans vérifier le montant du HTLC entrant. Un payeur malveillant pouvait demander un paiement sortant plus élevé tout
  en envoyant moins, obligeant le LSP à couvrir la différence avec ses propres fonds. Désormais, les gestionnaires `htlc_intercepted` de
  LSPS2 vérifient que le montant sortant demandé ne dépasse pas le montant réel du HTLC entrant. Si cette condition n'est pas remplie, LDK
  fait échouer le HTLC en retour avant d'ouvrir un canal ou de transférer des fonds.

- [LDK #5046][] corrige un bogue qui pourrait amener un nœud de transfert à perdre des fonds lors d'un redémarrage avec un état
  `ChannelManager` plus ancien que son `ChannelMonitor`. Bien que LDK force correctement la fermeture des canaux dans cette situation, il
  peut traiter incorrectement un [HTLC][topic htlc] sortant comme n'ayant jamais été engagé en aval et faire échouer en retour le HTLC
  entrant correspondant vers le pair amont. Le pair aval pourrait alors réclamer le HTLC sortant onchain, laissant LDK couvrir la perte. LDK
  vérifie désormais quelles mises à jour de moniteur précédemment bloquées ont déjà été appliquées avant de forcer la fermeture,
  garantissant que les HTLC engagés en aval sont laissés au moniteur pour résolution au lieu d'échouer incorrectement en amont.

- [LDK #5028][] fait du transfert en mode alias SCID uniquement le comportement par défaut lors de l'ouverture de nouveaux [canaux non
  annoncés][topic unannounced channels] avec des pairs qui le prennent en charge. Cela évite de révéler la sortie de financement du canal
  via des factures ou des sondes de transfert en utilisant son SCID réel. Auparavant, les applications devaient activer le paramètre
  `negotiate_scid_privacy`, qui est maintenant supprimé. La négociation se rabat toujours sur un canal sans cette protection si le pair ne
  la prend pas en charge ou ne l'accepte pas. Les canaux existants conservent leur comportement négocié.

- [LND #11290][] corrige un bogue de débordement lors de la construction de factures [BOLT11][] contenant des [chemins de paiement
  aveuglés][topic rv routing] (voir le [Bulletin #315][news315 lnd blinded]). Auparavant, LND utilisait une arithmétique sur 32 bits pour
  agréger les frais de transfert des sauts cachés, ce qui pouvait déborder avec des frais relativement faibles (autour de 4 295 msat ou 4
  295 ppm). Cela amenait les factures à annoncer des frais plus faibles que ceux réellement facturés par les sauts cachés, ce qui pouvait
  provoquer l'échec des paiements parce que le destinataire recevrait moins que le montant facturé. LND utilise désormais une arithmétique
  vérifiée sur 64 bits pour calculer les frais agrégés et exclut les chemins dont les frais dépassent les limites du format de facture.

{% include snippets/recap-ad.md when="2026-10-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="36277,36365,36338,32895,9582,3390,3388,5057,5042,5046,5028,11290" %}

[towns set324alias]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes
[news392 bip324 ids]: /fr/newsletters/2026/02/13/#bips-2092
[towns set324alias savings]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes/m/JHCPpVWaBAAJ
[jahr tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg
[news415 dahlias]: /fr/newsletters/2026/07/24/#projet-de-bip-pour-l-agregation-complete-des-signatures-bip340
[provoost tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg/m/OHPZw92DCQAJ
[shield del]: https://delvingbitcoin.org/t/shielded-bitcoin-private-transfers-on-the-bitcoin-l1/2912
[shield paper]: https://www.allocinit.xyz/uploads/shielded-bitcoin.pdf
[news393 pipes]: /fr/newsletters/2026/02/20/#bitcoin-pipes-v2
[Bitcoin Core 32.0rc3]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc3/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[Core Lightning 26.06.9]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.9
[LDK v0.3-rc3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.3-rc3
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc3/CHANGELOG.md
[LDK v0.2.7]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.7
[LDK v0.1.13]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.13
[BTCPay Server 2.4.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.5
[btcpay 2.4.5 announcement]: https://blog.btcpayserver.org/btcpay-server-2-4-5/
[ldk #5057]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5057
[ldk #5042]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5042
[ldk #5046]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5046
[ldk #5028]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5028
[BLIP52]: https://github.com/lightning/blips/blob/master/blip-0052.md
[news388 private broadcast]: /fr/newsletters/2026/01/16/#bitcoin-core-29415
[news425 private broadcast]: /fr/newsletters/2026/10/02/#bitcoin-core-36312
[news420 fee estimation]: /fr/newsletters/2026/08/28/#bitcoin-core-34075
[news425 silent payments]: /fr/newsletters/2026/10/02/#bitcoin-core-35301
[news424 cln release]: /fr/newsletters/2026/09/25/#core-lightning-26-06-8
[news423 eclair fees]: /fr/newsletters/2026/09/18/#eclair-3376
[news315 lnd blinded]: /fr/newsletters/2024/08/09/#lnd-8735
