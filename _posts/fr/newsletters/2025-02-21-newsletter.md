---
title: 'Bulletin Hebdomadaire Bitcoin Optech #342'
permalink: /fr/newsletters/2025/02/21/
name: 2025-02-21-newsletter-fr
slug: 2025-02-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une technique permettant aux portefeuilles mobiles de configurer des
canaux LN sans UTXO supplémentaire et résume la discussion en cours sur l'ajout d'un indicateur de
qualité de service pour le routage de chemin LN. Sont également incluses nos sections habituelles
décrivant les changements récents apportés aux principaux clients, services et logiciels d'infrastructure
Bitcoin.

## Nouvelles

- **Permettre aux portefeuilles mobiles de régler les canaux sans UTXO supplémentaire :**
  Bastien Teinturier a [publié][teinturier mobileclose] sur Delving Bitcoin un article présentant une variante
  optionnelle des [engagements v3][topic v3 commitments] (*commitements*) pour les canaux LN qui permettrait aux
  portefeuilles mobiles de fermer les canaux en utilisant les fonds du canal pour tous
  les cas où un vol est possible. Ils n'auraient pas besoin de conserver une UTXO on-chain en réserve
  pour payer les frais de clôture.

  Il présente d'abord les quatre cas qui nécessitent qu'un portefeuille mobile diffuse une
  transaction :

  1. Leur pair diffuse une transaction d'engagement révoquée dans le cas, par exemple, où son homologue tente de voler des
     fonds. Dans ce cas, le portefeuille mobile a immédiatement la capacité de dépenser tous les
     fonds du canal, lui permettant d'utiliser ces fonds pour payer les frais.

  2. Le portefeuille mobile a envoyé un paiement qui n'a pas encore été réglé. Le vol est impossible
     dans ce cas, car leur pair distant ne peut réclamer le paiement qu'en fournissant la préimage
     [HTLC][topic htlc] (c'est-à-dire, la preuve que le destinataire final a été payé). Puisque le vol
     n'est pas possible, le portefeuille mobile peut prendre son temps pour trouver un UTXO pour payer
     les frais de clôture.

  3. Il n'y a pas de paiements en attente mais le pair distant ne répond pas. Là encore, le vol n'est
     pas possible, donc le portefeuille mobile peut prendre son temps pour clôturer.

  4. Le portefeuille mobile reçoit un HTLC. Dans ce cas, le pair distant peut accepter la préimage
     HTLC (lui permettant de réclamer des fonds de ses pairs en amont) mais ne pas mettre à jour le solde
     du canal réglé et révoquer l'HTLC. Dans ce cas, le portefeuille mobile ne dispose que de peu de blocs pour forcer la fermeture du
     canal. C'est le cas abordé dans le reste du post.

  Bastien Teinturier propose que le pair distant signe deux versions différentes de chaque HTLC payant le
  portefeuille mobile : une version sans frais conforme à la politique par défaut pour les engagements sans
  frais et une version payant des frais à un taux qui permettra une confirmation rapide.
  Les frais sont déduits de la valeur HTLC payée au portefeuille mobile, donc cela ne coûte rien au
  pair distant d'offrir cette option et le portefeuille mobile a intérêt à l'utiliser seulement si
  vraiment nécessaire. Teinturier [note][teinturier mobileclose2] qu'il y a certaines considérations
  de sécurité pour le pair distant payant trop de frais, mais il s'attend à ce qu'elles soient faciles
  à adresser.

- **Discussion continue sur un drapeau de qualité de service LN :** Joost Jager a [poursuivi][jager
  lnqos] sur Delving Bitcoin la discussion
  sur l'ajout d'un indicateur de qualité de service (QoS) au protocole LN pour permettre aux
  nœuds de signaler que l'un de leurs canaux était hautement disponible (HA)---capable de transférer
  des paiements jusqu'à un montant spécifié avec une fiabilité de 100% (voir le [Bulletin #239][news239
  qos]). Si l'utilisateur choisit un canal HA et que le paiement échoue sur ce canal, alors
  il pénalisera l'opérateur en n'utilisant plus jamais ce canal. Depuis la précédente
  discussion, Jager a proposé un signal au niveau du nœud (peut-être simplement en ajoutant "HA" à
  l'alias textuel du nœud).Il a également noté que les messages d’erreur actuels du protocole ne garantissent pas
  l’identification du canal où un paiement a échoué. Il suggère enfin que cet indicateur ne peut pas
  être à la fois signalé et utilisé de manière totalement facultative---son adoption nécessiterait donc
  un large consensus---cela implique une spécification pour la compatibilité même si très peu de
  nœuds dépensiers et de transfert finissent par l'utiliser.

  Matt Corallo [a répondu][corallo lnqos] que le routage LN fonctionne actuellement bien et a fourni un lien vers un
  [document détaillé][ldk path] décrivant l'approche de LDK pour le routage, qui étend l'approche
  initialement décrite par René Pickhardt et Stefan Richter (voir le [Bulletin #163][news163 pr paper]
  et [deux éléments][news270 ldk2547] dans le [Bulletin #270][news270 ldk2534]). Cependant, il est
  préoccupé par le fait qu'un indicateur QoS encouragera les futurs logiciels à mettre en œuvre un
  routage moins fiable et à simplement préférer utiliser uniquement des canaux HA. Dans ce cas, les
  nœuds les plus importants peuvent signer des accords avec leurs principaux homoloques pour utiliser temporairement une
  liquidité basée sur la confiance lorsque un canal est épuisé, mais les petits nœuds dépendant de
  canaux sans confiance devront utiliser un [rééquilibrage JIT][topic jit routing] coûteux qui rendra
  leurs canaux moins rentables (s'ils absorbent le coût) ou moins désirables (s'ils répercutent le
  coût sur les utilisateurs).

  Jager et Corallo ont continué à discuter sans parvenir à une résolution claire.

## Changements dans les services et les logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles Bitcoin et des services.*

- **Ark Wallet SDK publié :**
  Le [SDK du wallet Ark][ark sdk github] est une bibliothèque TypeScript pour construire des
  portefeuilles qui prennent en charge à la fois Bitcoin on-chain et le protocole [Ark][topic ark] sur
  [testnet][topic testnet], [signet][topic signet], [Mutinynet][new252 mutinynet], et le mainnet
  (actuellement non recommandé).

- **Zaprite ajoute le support de BTCPay Server :**
  L'intégrateur de paiement Bitcoin et Lightning [Zaprite][zaprite website] ajoute BTCPay Server à
  leur liste de connexions de portefeuille prises en charge.

- **Iris Wallet pour desktop publié :**
  [Iris Wallet][iris github] prend en charge l'envoi, la réception et l'émission d'actifs en utilisant
  le protocole [RGB][topic client-side validation].

- **Sparrow 2.1.0 publié :**
  La version [2.1.0 de Sparrow][sparrow 2.1.0] remplace l'implémentation [HWI][topic hwi] précédente
  par [Lark][news333 lark] et ajoute le support de [PSBTv2][topic psbt], parmi d'autres mises à jour.

- **Scure-btc-signer 1.6.0 publié :**
  [Scure-btc-signer][scure-btc-signer github] dans sa version [1.6.0][scure-btc-signer 1.6.0] ajoute
  la prise en charge des transactions de version 3 ([TRUC][topic v3 transaction relay]) et les [paiements
  vers des ancres (P2A)][topic ephemeral anchors]. Scure-btc-signer fait partie de la suite de
  bibliothèques [scure][scure website].

- **Py-bitcoinkernel alpha :**
  [Py-bitcoinkernel][py-bitcoinkernel github] est une bibliothèque Python pour interagir avec
  [libbitcoinkernel][Bitcoin Core #27587], une bibliothèque [encapsulant la logique de validation de
  Bitcoin Core][kernel blog].

- **Bibliothèque Rust-bitcoinkernel :**
  [Rust-bitcoinkernel][rust-bitcoinkernel github] est une bibliothèque Rust expérimentale pour
  utiliser libbitcoinkernel afin de lire les données des blocs et de valider les sorties de
  transactions et les blocs.

- **Bibliothèque BIP32 cbip32 :**
  La [bibliothèque cbip32][cbip32 library] implémente [BIP32][] en C en utilisant libsecp256k1 et
  libsodium.

- **Lightning Loop passe à MuSig2 :**
  Le service d'échange Lightning Loop utilise désormais [MuSig2][topic musig] comme décrit dans un
  [article de blog récent][loop blog].

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur
BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #27432][] introduit un script Python qui convertit l'ensemble UTXO compact sérialisé
  généré par la commande RPC `dumptxoutset` (conçue spécifiquement pour les instantanés
  [AssumeUTXO][topic assumeutxo]) en une base de données SQLite3. Bien que l'extension de la commande
  RPC `dumptxoutset` elle-même pour sortir une base de données SQLite3 ait été considérée, elle a
  finalement été rejetée en raison de l'augmentation de la charge de maintenance. Le script n'ajoute
  aucune dépendance supplémentaire et la base de données résultante est environ deux fois la taille de
  l'ensemble UTXO compact sérialisé.

- [Bitcoin Core #30529][] corrige le traitement des options négatives telles que `noseednode`,
  `nobind`, `nowhitebind`, `norpcbind`, `norpcallowip`, `norpcwhitelist`, `notest`, `noasmap`,
  `norpcwallet`, `noonlynet`, et `noexternalip` pour se comporter comme prévu. Auparavant, l'annulation
  de ces options provoquait des effets secondaires déroutants et non documentés, mais maintenant cela
  efface simplement les paramètres spécifiés pour restaurer le comportement par défaut.

- [Bitcoin Core #31384][] résout un problème où les 4 000 unités de poids (WU)
  réservé pour l'en-tête de bloc, le nombre de transactions et la transaction coinbase ont été
  appliqués par inadvertance deux fois, réduisant la taille maximale du modèle de bloc de 4 000 WU à 3
  992 000 WU (voir le Bulletin [#336][news336 weightbug]). Cette correction consolide le poids réservé
  en une seule instance et introduit une nouvelle option de démarrage `-blockreservedweight` pour
  permettre aux utilisateurs de personnaliser le poids réservé. Des vérifications de sécurité sont
  ajoutées pour s'assurer que le poids réservé est défini sur une valeur entre 2 000 WU et 4 000 000
  WU, sinon Bitcoin Core échouera au démarrage.

- [Core Lightning #8059][] implémente la suppression des paiements multipath [multipath
  payments][topic multipath payments] (MPP) sur le plugin `xpay` (voir le Bulletin [#330][news330
  xpay]) lors du paiement d'une facture [BOLT11][] qui ne prend pas en charge cette fonctionnalité. La
  même logique sera étendue aux factures [BOLT12][topic offers], mais devra attendre la prochaine
  version, car ce PR permet également de faire de la publicité sur les fonctionnalités BOLT12 aux
  plugins, autorisant explicitement le paiement des factures BOLT12 avec MPP.

- [Core Lightning #7985][] ajoute la prise en charge du paiement des factures [BOLT12][topic offers]
  dans le plugin `renepay` (voir le Bulletin [#263][news263 renepay]) en permettant le routage à
  travers des [chemins masqués][topic rv routing] et en remplaçant l'utilisation interne de renepay de
  la commande RPC `sendpay` par `sendonion`.

- [Core Lightning #7887][] ajoute la prise en charge de la gestion des nouveaux champs [BIP353][] pour la
  résolution du Nom Lisible par l'Homme (HRN) pour se conformer aux dernières mises à jour des BOLTs
  (voir les Bulletins [#290][news290 hrn] et [#333][news333 hrn]). Le PR ajoute également le champ
  `invreq_bip_353_name` aux factures, impose des restrictions sur les champs de nom BIP353 entrants,
  et permet aux utilisateurs de spécifier des noms BIP353 sur la commande RPC `fetchinvoice`, ainsi
  que des changements de formulation.

- [Eclair #2967][] ajoute la prise en charge de protocole `option_simple_close` tel que spécifié dans
  [BOLTs #1205][]. Cette variante simplifiée du protocole de fermeture mutuelle est une condition
  préalable pour les [canaux taproot simples][topic simple taproot channels], car elle permet aux
  nœuds d'échanger en toute sécurité des nonces pendant les phases `shutdown`, `closing_complete` et
  `closing_sig`, ce qui est nécessaire pour dépenser une sortie de canal [MuSig2][topic musig].

- [Eclair #2979][] ajoute une étape de vérification pour confirmer qu'un nœud prend en charge les
  notifications de réveil (voir le Bulletin [#319][news319 wakeup]) avant d'initier le flux de réveil
  pour relayer un paiement [trampoline][topic trampoline payments]. Pour les paiements de canal
  standard, cette vérification est inutile car la facture [BOLT11][] ou [BOLT12][topic offers] indique
  déjà le support pour les notifications de réveil.

- [Eclair #3002][] introduit un mécanisme secondaire pour traiter les blocs et leurs transactions
  confirmées afin de déclencher des surveillances, pour une sécurité accrue. Cela est particulièrement
  utile lorsqu'un canal est dépensé mais que la transaction de dépense n'a pas été détectée dans le
  mempool. Alors que le topic ZMQ `rawtx` gère cela, il peut être peu fiable et peut supprimer silencieusement
  des événements lors de l'utilisation d'une instance de `bitcoind` à distance.
  Chaque fois qu'un nouveau bloc est trouvé, le système secondaire récupère les derniers N
  blocs (6 par défaut) et retraite leurs transactions.

- [LDK #3575][] implémente le protocole [peer storage][topic peer storage] comme une fonctionnalité
  permettant aux nœuds de distribuer et de stocker des sauvegardes pour les pairs de canaux. Il
  introduit deux nouveaux types de messages, `PeerStorageMessage` et `PeerStorageRetrievalMessage`,
  ainsi que leurs gestionnaires respectifs, pour permettre l'échange de ces sauvegardes entre nœuds.
  Les données des pairs sont stockées de manière persistante dans `PeerState` dans le
  `ChannelManager`.

- [LDK #3562][] introduit un nouveau système de notation (voir le Bulletin [#308][news308 scorer])
  qui fusionne les benchmarks de notation basés sur le [sondage][topic payment probes] fréquent de
  véritables chemins de paiement à partir d'une source externe. Cela permet aux nœuds légers, qui ont
  généralement une vue limitée du réseau, d'améliorer les taux de succès des paiements en incorporant
  des données externes telles que les scores fournis par un Lightning Service Provider (LSP). Le score
  externe peut soit être combiné avec, soit remplacer le score local.

- [BOLTs #1205][] fusionne le protocole `option_simple_close`, qui est une variante simplifiée du
  protocole de fermeture mutuelle requis pour les [canaux taproot simples][topic simple taproot
  channels]. Des modifications sont apportées à [BOLT2][] et [BOLT3][].

{% include snippets/recap-ad.md when="2025-02-25 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27432,30529,31384,8059,7985,7887,2967,2979,3002,3575,3562,1205,27587" %}
[news239 qos]: /fr/newsletters/2023/02/22/#indicateur-de-qualite-de-service-ln
[news163 pr paper]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news270 ldk2547]: /fr/newsletters/2023/09/27/#ldk-2547
[news270 ldk2534]: /fr/newsletters/2023/09/27/#ldk-2534
[teinturier mobileclose]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453
[teinturier mobileclose2]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453/3
[jager lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438
[corallo lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438/4
[ldk path]: https://lightningdevkit.org/blog/ldk-pathfinding/
[news330 xpay]: /fr/newsletters/2024/11/22/#core-lightning-7799
[news263 renepay]: /fr/newsletters/2023/08/09/#core-lightning-6376
[news290 hrn]: /fr/newsletters/2024/02/21/#instructions-de-paiement-bitcoin-lisibles-par-l-homme-basees-sur-dns
[news333 hrn]: /fr/newsletters/2024/12/13/#bolts-1180
[news319 wakeup]: /fr/newsletters/2024/09/06/#eclair-2865
[news308 scorer]: /fr/newsletters/2024/06/21/#ldk-3103
[news336 weightbug]: /fr/newsletters/2025/01/10/#enquete-sur-le-comportement-des-pools-de-minage-avant-de-corriger-un-bug-de-bitcoin-core
[ark sdk github]: https://github.com/arklabshq/wallet-sdk
[new252 mutinynet]: /fr/newsletters/2023/05/24/#mutinynet-annonce-un-nouveau-signet-pour-les-tests
[zaprite website]: https://zaprite.com
[iris github]: https://github.com/RGB-Tools/iris-wallet-desktop
[sparrow 2.1.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.1.0
[news333 lark]: /fr/newsletters/2024/12/13/#hwi-base-sur-java-publie
[scure-btc-signer github]: https://github.com/paulmillr/scure-btc-signer
[scure-btc-signer 1.6.0]: https://github.com/paulmillr/scure-btc-signer/releases
[scure website]: https://paulmillr.com/noble/#scure
[py-bitcoinkernel github]: https://github.com/stickies-v/py-bitcoinkernel
[rust-bitcoinkernel github]: https://github.com/TheCharlatan/rust-bitcoinkernel
[kernel blog]: https://thecharlatan.ch/Kernel/
[cbip32 library]: https://github.com/jamesob/cbip32
[loop blog]: https://lightning.engineering/posts/2025-02-13-loop-musig2/
