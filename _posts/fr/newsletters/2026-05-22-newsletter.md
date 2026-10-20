---
title: 'Bulletin Hebdomadaire Bitcoin Optech #406'
permalink: /fr/newsletters/2026/05/22/
name: 2026-05-22-newsletter-fr
slug: 2026-05-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine renvoie vers une discussion sur des mises à jour du format générique de message signé de BIP322 et décrit une
idée d'utiliser le perforage de trous TCP pour aider les nœuds Bitcoin derrière des NAT à accepter des connexions entrantes. Sont également
incluses nos sections régulières décrivant les changements récents dans les services et logiciels clients et résumant les changements
notables apportés aux logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Mises à jour importantes du format générique de message signé BIP322** : Oliver Gugger a [publié][guggero bip322 ml] sur la liste de
  diffusion Bitcoin-Dev ses idées sur la manière de compléter [BIP322][topic generic signmessage]. Comme Gugger avait été en train
  d'implémenter la prise en charge dans btcd, il avait remarqué plusieurs questions ouvertes et lacunes dans la proposition. Il a proposé
  trois amendements majeurs à la proposition :

  - Des préfixes lisibles par l'humain pour distinguer les trois variantes de signature.

  - L'inclusion des informations UTXO dans la variante "Proof of Funds".

  - La prise en charge de la signature de messages basée sur PSBT.

  Après quelques discussions et l'intégration des retours sur la construction PSBT, la mise à jour de BIP322 a été publiée (voir le
  [Bulletin #405][news405 bip322]). Gugger a fait passer BIP322 à Complete, indiquant que la spécification est désormais considérée comme
  stable et prête pour l'implémentation. Depuis cette mise à jour, il est réapparu que Coldcard avait [livré la prise en charge][cc 322] de
  BIP322 en mars.

  Les projets qui avaient précédemment implémenté la prise en charge de versions antérieures de [BIP322][] devraient vérifier leur
  compatibilité avec la spécification mise à jour, qui a introduit des changements incompatibles, notamment un nouveau préfixe lisible par
  l'humain et un format révisé de signature de preuve de fonds. {% assign timestamp="1:17" %}

- **Perforage de trous TCP pour les nœuds Bitcoin derrière des NAT** : 0xB10C a [publié][hole punch del] sur Delving Bitcoin une idée pour
  faire en sorte qu'un plus grand nombre de nœuds derrière un NAT de routeur domestique acceptent des connexions entrantes. Le concept
  initial provient de l'observation que définir `-natpmp=1` par défaut à partir de [Bitcoin Core v30.0][] n'a pas augmenté le nombre de
  nœuds joignables chez les FAI résidentiels comme prévu.

  L'idée exploite le perforage de trous, une technique qui permet à deux hôtes derrière certains types de NAT de se connecter directement,
  sans relayer le trafic via un serveur. Le processus fonctionne ainsi : deux hôtes injoignables, Alice et Bob, échangent leurs points de
  terminaison publics (c.-à-d. adresse IP et port) par l'intermédiaire d'un tiers et initient simultanément une connexion l'un vers l'autre.
  Cela crée un mappage dans les NAT, permettant aux hôtes de terminer la poignée de main et d'établir une connexion. Comme la technique
  proposée fonctionne sur TCP, qui nécessite une synchronisation précise entre les nœuds, elle produit des taux d'échec plus élevés qu'une
  technique similaire utilisant UDP.

  0xB10C a mentionné plusieurs approches pour une implémentation utilisant le protocole P2P de Bitcoin. Un premier ensemble nécessite un
  pont, appelé serveur de rendez-vous, pour permettre à Alice et Bob d'échanger les informations de point de terminaison. Le serveur
  pourrait soit fournir un service de mise en relation, pour permettre aux hôtes injoignables d'offrir leurs emplacements de connexion, soit
  décider de transférer l'une de ses connexions existantes à un autre pair au lieu de l'expulser en raison d'un manque d'emplacements
  entrants libres. Il a aussi décrit une manière d'effectuer directement le perforage de trous sous [Tor/I2P][topic anonymity networks], en
  contournant le besoin d'un serveur tiers pour établir la connexion. Dans cette approche, Alice commencerait à écouter sur un point de
  terminaison Tor/I2P dédié, auquel Bob se connecterait et lancerait le processus de perforage de trous.

  La proposition n'a pas encore été formalisée, et de nombreuses questions restent sans réponse. 0xB10C a demandé des retours de la
  communauté et a invité à la discussion pour traiter de nombreux points ouverts, tels que la manière de classifier les connexions par
  perforage de trous, la fiabilité du perforage de trous TCP, les attaques possibles et les efforts d'implémentation. {% assign
  timestamp="17:39" %}

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des portefeuilles et services Bitcoin.*

- **Annonce d'Ibis Wallet :** [Ibis Wallet][ibis wallet] est un portefeuille Android construit sur BDK prenant en charge le coin control, la
  gestion des frais [RBF][topic rbf] et [CPFP][topic cpfp], le multisig, l'intégration de dispositifs matériels de signature à l'aide de
  codes QR, les [silent payments][topic silent payments], et l'intégration de [Tor][topic anonymity networks]. Il prend également en charge
  des couches secondaires optionnelles, notamment Spark, Liquid et, à l'avenir, [Ark][topic ark]. {% assign timestamp="40:15" %}

- **Annonce de LDK Server :** Spiral a annoncé [LDK Server][ldk server], un démon de nœud Lightning orienté API construit sur LDK Node pour
  les processeurs de paiement et les fournisseurs de portefeuilles. Il fournit une interface gRPC, un portefeuille intégré basé sur BDK, et
  un serveur Model Context Protocol (MCP) pour les interactions d'agents IA avec le nœud. {% assign timestamp="41:10" %}

- **Publication de Mempool.space v3.3.0 :** Mempool [v3.3.0][mempool v3.3.0] ajoute des visualisations d'arbres de scripts [taproot][topic
  taproot], des aperçus [PSBT][topic psbt] mis à jour, des améliorations de l'[estimation des frais][topic fee estimation], la prise en
  charge de l'[ephemeral dust][topic ephemeral anchors], des comparaisons de blocs périmés, des icônes sighash, et une API de preuve de
  Merkle, entre autres fonctionnalités. {% assign timestamp="42:06" %}

- **Outils de surveillance P2P peer-observer :** 0xB10C a [présenté][peer-observer delving] certains composants open source utilisés par sa
  plateforme [peer-observer][peer-observer site], y compris une infrastructure pour extraire des événements des nœuds Bitcoin Core en
  utilisant des sources IPC, journaux, P2P et RPC. Il décrit également le développement en cours autour de l'archivage, de la détection
  d'anomalies et des outils d'alerte. {% assign timestamp="32:28" %}

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #29136][] ajoute une RPC `addhdkey` qui importe une clé privée étendue [BIP32][] spécifiée, ou en génère une si aucune n'est
  spécifiée, sans l'utiliser pour produire de scripts de sortie. Cela permet à un portefeuille de stocker une clé de signature pour un usage
  futur (p. ex. pour un script multisig), sans générer immédiatement d'adresses à partir de celle-ci. La PR ajoute également un nouveau type
  de [descripteur][topic descriptors] `unused(KEY)`, qui est renvoyé par `listdescriptors`, afin que la clé stockée puisse être incluse dans
  les sauvegardes du portefeuille. {% assign timestamp="43:27" %}

- [Bitcoin Core #34893][] met à jour la RPC `combinepsbt` afin de préserver les champs propriétaires de [BIP174][] (voir les Bulletins
  [#72][news72 psbt] et [#181][news181 psbt]) lors de la combinaison de [PSBT][topic psbt]. Auparavant, `combinepsbt` supprimait
  silencieusement les champs propriétaires, entraînant la perte des métadonnées PSBT spécifiques à l'application. La RPC `decodepsbt`
  analyse déjà, sérialise et affiche correctement ces champs. {% assign timestamp="47:24" %}

- [Bitcoin Core #34860][] supprime l'option `include_dummy_extranonce` de la méthode `CreateNewBlock()` (voir le Bulletin [#392][news392
  mining]). Bitcoin Core ajoute désormais toujours un remplissage factice au coinbase interne `scriptSig` lors de la création de blocs aux
  hauteurs 0 à 16, où l'encodage de hauteur [BIP34][] seul est trop court pour satisfaire la longueur minimale de consensus du `scriptSig`.
  Cependant, le remplissage n'est pas inclus dans le champ `scriptSigPrefix` de la structure `CoinbaseTx` exposée aux clients [Stratum
  V2][topic pooled mining] connectés via l'interface Mining IPC (voir les Bulletins [#310][news310 ipc] et [#388][news388 ipc]). {% assign
  timestamp="48:20" %}

- [Bitcoin Core #31298][] met à jour la RPC `combinerawtransaction` afin de rejeter les transactions sans rapport, au lieu de renvoyer
  silencieusement la première sans signaler qu'elles ne pouvaient pas être fusionnées. Bitcoin Core retire désormais les scriptSigs et
  témoins d'entrée de chaque transaction, compare les hachages de transaction non signée résultants, et renvoie une erreur s'ils ne
  correspondent pas. {% assign timestamp="53:52" %}

- [Bitcoin Core #28802][] ajoute la prise en charge d'options spécifiques aux commandes à `ArgsManager`, l'analyseur d'arguments CLI de
  Bitcoin Core. Les commandes peuvent désormais déclarer quelles options s'appliquent à elles, permettant à `ArgsManager` de lister ces
  options dans la sortie d'aide de la commande concernée et de rejeter automatiquement les combinaisons commande-option invalides. La PR
  applique cela à l'option `-dumpfile` de `bitcoin-wallet` (voir le [Bulletin #32][news32 dump]), qui est maintenant enregistrée uniquement
  pour les commandes `dump` et `createfromdump`. {% assign timestamp="57:04" %}

- [Eclair #3298][] met à jour sa logique interne [RBF][topic rbf] pour suivre la nouvelle règle d'augmentation de feerate de [BOLT2][], qui
  est conçue pour garantir la conformité avec les règles de remplacement de [BIP125][] à faibles feerates. Au lieu d'appliquer seulement le
  multiplicateur de feerate précédent de 25/24, Eclair utilise désormais le plus grand des deux : ce multiplicateur ou 25 sat/kw
  supplémentaires. Cela correspond au comportement de LDK couvert dans le Bulletin [#400][news400 rbf] et à la mise à jour de la
  spécification BOLT couverte dans le Bulletin [#404][news404 rbf]. {% assign timestamp="58:52" %}

- [LDK #4575][] ajoute une API `splice_in_inputs` qui permet aux utilisateurs de sélectionner manuellement des UTXO lors de l'ajout de fonds
  par [splicing][topic splicing] dans un canal. Les UTXO sélectionnés sont entièrement consommés, leur valeur moins les frais étant ajoutée
  au canal, et aucune sortie de monnaie n'est créée. Cela complète le flux existant d'ajout par montant, dans lequel l'appelant spécifie le
  montant à ajouter et le portefeuille sélectionne les entrées. Cependant, les deux flux de sélection d'entrées ne peuvent pas être mélangés
  dans la même contribution de financement. {% assign timestamp="1:02:08" %}

- [LND #10814][] supprime les points de terminaison obsolètes `SendPayment`, `SendPaymentSync`, `SendToRoute`, `SendToRouteSync`, et
  `TrackPayment`, dont la suppression était prévue pour la version 0.21 (voir le Bulletin [#340][news340 lnd]). Les appelants devraient
  utiliser les remplacements V2 : `SendPaymentV2`, `SendToRouteV2`, et `TrackPaymentV2`. La PR supprime également le champ obsolète de canal
  unique `outgoing_chan_id`, exigeant des appelants qu'ils utilisent le champ multicanal `outgoing_chan_ids` (voir le [Bulletin #33][news33
  lnd]). {% assign timestamp="1:03:13" %}

- [Rust Bitcoin #6191][] ajoute la prise en charge de l'encodage et du décodage du message P2P `sendtxrcncl` utilisé pour la réconciliation
  des transactions [Erlay][topic erlay]. Bitcoin Core a ajouté la prise en charge de ce message comme première partie de la prise en charge
  d'Erlay (voir le Bulletin [#223][news223 erlay]). Cependant, la réconciliation complète des transactions Erlay n'est pas encore
  implémentée. {% assign timestamp="1:04:35" %}

- [BLIPs #42][] ajoute [BLIP42][], une spécification pour les contacts [BOLT12][]. Comme les [offres BOLT12][topic offers] peuvent être
  réutilisées comme instructions statiques de paiement Lightning, les portefeuilles peuvent stocker les offres comme contacts. Le BLIP
  définit des champs optionnels `invoice_request` que les payeurs peuvent inclure lors de paiements sortants vers un contact, tels qu'un
  secret de contact, leur propre offre, ou un nom [BIP353][]. Cela permet aux destinataires de reconnaître les paiements de contacts connus,
  d'ajouter de nouveaux contacts, et de renvoyer des fonds au payeur sans interaction supplémentaire. {% assign timestamp="1:06:20" %}

{% include snippets/recap-ad.md when="2026-05-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29136,34893,34860,31298,28802,3298,4575,10814,6191,42" %}
[ibis wallet]: https://github.com/aeonBTC/IbisWallet
[ldk server]: https://github.com/lightningdevkit/ldk-server
[mempool v3.3.0]: https://github.com/mempool/mempool/releases/tag/v3.3.0
[peer-observer delving]: https://delvingbitcoin.org/t/peer-observer-a-tool-and-infrastructure-for-monitoring-the-bitcoin-p2p-network-for-attacks-and-anomalies/1988/4
[peer-observer site]: https://public.peer.observer/
[news72 psbt]: /en/newsletters/2019/11/13/#bips-849
[news181 psbt]: /en/newsletters/2022/01/05/#bitcoin-core-17034
[news392 mining]: /fr/newsletters/2026/02/13/#bitcoin-core-32420
[news310 ipc]: /fr/newsletters/2024/07/05/#bitcoin-core-30200
[news388 ipc]: /fr/newsletters/2026/01/16/#bitcoin-core-33819
[news32 dump]: /en/newsletters/2019/02/05/#bitcoin-core-13926
[news400 rbf]: /fr/newsletters/2026/04/10/#ldk-4494
[news404 rbf]: /fr/newsletters/2026/05/08/#bolts-1327
[news340 lnd]: /fr/newsletters/2025/02/07/#lnd-9456
[news33 lnd]: /en/newsletters/2019/02/12/#lnd-2572
[news223 erlay]: /fr/newsletters/2022/10/26/#bitcoin-core-23443
[hole punch del]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497
[Bitcoin Core v30.0]: https://bitcoincore.org/en/releases/30.0/
[guggero bip322 ml]: https://groups.google.com/g/bitcoindev/c/qd6BNz9gxCk/m/k1fHq4RKAQAJ
[cc 322]: https://blog.coinkite.com/bip322-wif/
[news405 bip322]: /en/newsletters/2026/05/15/#bips-2141
