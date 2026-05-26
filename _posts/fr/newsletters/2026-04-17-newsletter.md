---
title: 'Bulletin Hebdomadaire Bitcoin Optech #401'
permalink: /fr/newsletters/2026/04/17/
name: 2026-04-17-newsletter-fr
slug: 2026-04-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une idée de nœuds Lightning MuSig2 imbriqués et résume un projet vérifiant formellement la
multiplication scalaire modulaire de secp256k1. Sont également incluses nos sections régulières décrivant les changements récents dans les
services et logiciels clients, annonçant de nouvelles versions et versions candidates, et résumant les changements notables apportés aux
logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Discussion sur l'utilisation de MuSig2 imbriqué dans le Lightning Network** : ZmnSCPxj [a posté][kofn post del] sur Delving Bitcoin à
  propos de l'idée de créer des nœuds Lightning multisignatures k-sur-n en tirant parti de MuSig2 imbriqué comme discuté dans un récent
  [article][nmusig2 paper].

  Selon ZmnSCPxj, le besoin d'un schéma de signature k-sur-n dans Lightning découle du fait que de grands détenteurs souhaitent fournir leur
  liquidité au réseau en échange de frais. Ces grands détenteurs peuvent avoir besoin de fortes garanties quant à la sécurité de leurs
  fonds, ce qu'une seule clé peut ne pas offrir. À la place, un schéma k-sur-n fournirait la sécurité requise tant que moins de k clés sont
  compromises.

  À ce jour, les spécifications BOLTs ne permettent pas de manière sûre d'implémenter un schéma multisig k-sur-n, le principal obstacle
  étant la clé de révocation. Selon les BOLTs, la clé de révocation est créée à l'aide d'une shachain, qui, en raison de ses
  caractéristiques, n'est pas adaptée à une utilisation avec des schémas multisig k-sur-n.

  ZmnSCPxj propose une modification des spécifications BOLTs pour rendre facultative pour les nœuds la validation shachain des clés de
  révocation des parties du canal en signalant une nouvelle paire de bits de fonctionnalité, nommée `no_more_shachains`, dans
  `globalfeatures` et `localfeatures`. Un bit impair signalerait que le nœud n'effectuera pas de validation shachain sur la contrepartie,
  tout en fournissant encore des clés de révocation valides selon shachain afin de conserver la compatibilité avec les nœuds historiques. Un
  bit pair signalerait que le nœud ne validera ni ne fournira de clés de révocation valides selon shachain. Le premier bit serait utilisé
  par les nœuds passerelles, tels que définis par ZmnSCPxj, qui connecteraient le reste du réseau aux nœuds k-sur-n, ceux qui utilisent le
  bit pair.

  Enfin, ZmnSCPxj souligne comment cette proposition présenterait un compromis majeur, à savoir les besoins de stockage pour les clés de
  révocation. En effet, les nœuds devraient stocker des clés de révocation individuelles au lieu de la représentation compacte shachain,
  triplant effectivement l'espace disque nécessaire.

- **Vérification formelle de la multiplication scalaire modulaire de secp256k1** : Remix7531 [a posté][topic secp formalization] sur la
  liste de diffusion Bitcoin-Dev à propos de la vérification formelle de la multiplication scalaire modulaire de secp256k1. Le projet
  démontre que la vérification formelle d'un sous-ensemble de bitcoin-core/secp256k1 est pratique.

  Dans le [code source secp256k1-scalar-fv-test][secp verification codebase], Remix7531 prend du vrai code C de la bibliothèque et prouve sa
  correction par rapport à une spécification mathématique formelle à l'aide de Rocq et du Verified Software Toolchain (VST). La
  formalisation avec Rocq peut prouver l'absence d'erreurs mémoire, la correction par rapport à une spécification, et la terminaison.

  Il prévoit de porter la preuve existante de multiplication scalaire vers RefinedC, ce qui fournirait une comparaison directe des deux
  frameworks sur le même code vérifié. En outre, du côté de la vérification, la prochaine cible est l'algorithme de Pippenger pour la
  multiplication multi-scalaire, qui est utilisé pour la vérification par lot des signatures.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des portefeuilles et services Bitcoin.*

- **Coldcard 6.5.0 ajoute MuSig2 et miniscript :** Coldcard [6.5.0][coldcard 6.5.0] ajoute la prise en charge de la signature [MuSig2][topic
  musig], des capacités de preuve de réserve [BIP322][], et des fonctionnalités supplémentaires [miniscript][topic miniscript] et
  [taproot][topic taproot], y compris la prise en charge de [tapscript][topic tapscript] pour jusqu'à huit feuilles.

- **Frigate 1.4.0 publié :** Frigate [v1.4.0][frigate blog], un serveur Electrum expérimental pour le balayage de [silent payments][topic
  silent payments] (voir le [bulletin #389][news389 frigate]), utilise désormais la bibliothèque
  UltrafastSecp256k1 conjointement avec des calculs GPU modernes pour réduire le temps de balayage de quelques mois de blocs d'une heure à
  une demi-seconde.

- **Mises à jour de Bitcoin Backbone :** Bitcoin Backbone a [publié][backbone ml 1] plusieurs [mises à jour][backbone ml 2] ajoutant la
  prise en charge de [compact block][topic compact block relay] [BIP152][], des améliorations de la gestion des transactions et des
  adresses, ainsi que les bases d'une interface multiprocessus (voir le [bulletin #368][news368 backbone]). L'annonce propose également
  des extensions de l'API Bitcoin Kernel pour la vérification autonome des en-têtes et la validation des transactions.

- **Utreexod 0.5 publié :** Utreexod [v0.5][utreexod blog] introduit l'IBD en utilisant [SwiftSync][news349 swiftsync], qui utilise
  l'agrégation cryptographique pour éliminer le besoin de télécharger et vérifier les preuves d'inclusion de l'accumulateur pendant l'IBD,
  et élimine les données supplémentaires téléchargées par les nœuds à état compact pendant l'IBD de 1,4 To à ~200 Go, avec d'autres
  réductions possibles grâce à la mise en cache des preuves.

- **Floresta 0.9.0 publié :** Floresta [v0.9.0][floresta v0.9.0] aligne son réseau P2P avec le [BIP183][news366 utreexo bips] pour l'échange
  de preuves UTXO, et remplace libbitcoinconsensus par Bitcoin Kernel pour une validation des scripts environ 15x plus rapide, parmi
  d'autres changements.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 31.0rc4][] est une version candidate pour la prochaine version majeure de l'implémentation de nœud complet prédominante. Un
  [guide de test][bcc31 testing] est disponible.

- [Core Lightning 26.04rc3][] est la plus récente version candidate pour la prochaine version majeure de ce nœud LN populaire, poursuivant
  les mises à jour de splicing et les corrections de bogues des candidats précédents.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #34401][] étend la prise en charge de `btck_BlockHeader` ajoutée à l'API C `libbitcoinkernel` (voir les bulletins
  [#380][news380 kernel] et [#390][news390 header]) en ajoutant une méthode pour sérialiser un en-tête de bloc dans son encodage standard en
  octets. Cela permet aux programmes externes utilisant l'API C de stocker, transmettre ou comparer des en-têtes sérialisés sans avoir
  besoin de code de sérialisation séparé.

- [Bitcoin Core #35032][] cesse de stocker dans `addrman`, le gestionnaire d'adresses de pairs de Bitcoin Core, les adresses réseau apprises
  lors de l'utilisation de l'option `privatebroadcast` (voir le [bulletin
  #388][news388 private]) avec le RPC `sendrawtransaction`. L'option
  `privatebroadcast` permet aux utilisateurs de diffuser des transactions via des connexions [Tor][topic anonymity networks] ou I2P de
  courte durée, ou via le proxy Tor vers des pairs IPv4/IPv6.

- [Core Lightning #9021][] active le [splicing][topic splicing] par défaut en le retirant de son statut expérimental, à la suite de
  l'intégration du protocole de splicing dans la spécification BOLTs (voir le [bulletin
  #398][news398 splicing]).

- [Core Lightning #9046][] augmente la valeur supposée de `final_cltv_expiry` (le [delta d'expiration CLTV][topic cltv expiry delta] pour le
  dernier saut) pour les [paiements keysend][topic spontaneous payments] de 22 à 42 blocs afin de correspondre à la valeur de LDK,
  restaurant l'interopérabilité.

- [LDK #4515][] fait passer les canaux à [engagement sans frais][topic v3 commitments] (voir le [bulletin
  #371][news371 0fc]) du bit de fonctionnalité expérimental au bit de
  fonctionnalité de production. Les canaux à engagement sans frais remplacent les deux [sorties d'ancrage][topic anchor outputs] par une
  sortie partagée [Pay-to-Anchor (P2A)][topic ephemeral anchors], plafonnée à une valeur de 240 sats.

- [LDK #4558][] applique aux [paiements multipath][topic multipath payments] [keysend payments][topic spontaneous payments] le délai
  d'expiration côté destinataire existant pour les paiements incomplets. Auparavant, les MPP keysend incomplets pouvaient rester en attente
  jusqu'à l'expiration CLTV, immobilisant des emplacements [HTLC][topic htlc] au lieu d'échouer après la période normale d'expiration.

- [LND #9985][] ajoute une prise en charge de bout en bout pour les [simple taproot channels][topic simple taproot channels] de production
  avec un type d'engagement distinct (`SIMPLE_TAPROOT_FINAL`) et les bits de fonctionnalité de production 80/81. La version de production
  utilise des [tapscripts][topic tapscript] optimisés qui préfèrent `OP_CHECKSIGVERIFY` à `OP_CHECKSIG`+`OP_DROP`, et ajoute une gestion des
  nonces basée sur une map dans `revoke_and_ack`, indexée par txid de financement, comme base pour un futur [splicing][topic splicing].

- [BTCPay Server #7250][] ajoute la prise en charge de [LUD-21][] en introduisant un point de terminaison optionnel non authentifié nommé
  `verify` qui permet à des services externes de vérifier si une facture [BOLT11][] créée via [LNURL-pay][topic lnurl] a été réglée.

- [BIPs #2089][] publie [BIP376][], qui définit de nouveaux champs par entrée [PSBTv2][topic psbt] pour transporter les données de tweak
  [BIP352][] nécessaires pour signer et dépenser des sorties de [silent payment][topic silent payments], ainsi qu'un champ optionnel de
  dérivation de clé de dépense [BIP32][topic bip32] compatible avec les clés de dépense de 33 octets de BIP352. Cela complète [BIP375][],
  qui spécifie comment créer des sorties de silent payment à l'aide de PSBTs (voir le [bulletin #337][news337 bip375]).

{% include snippets/recap-ad.md when="2026-04-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34401,35032,9021,9046,4515,4558,9985,7250,2089" %}

[coldcard 6.5.0]: https://coldcard.com/docs/upgrade/#edge-version-650xqx-musig2-miniscript-and-taproot-support
[frigate blog]: https://damus.io/nevent1qqsrg3xsjwpt4d9g05rqy4vkzx5ysdffm40qtxntfr47y3annnfwpzgpp4mhxue69uhkummn9ekx7mqpz3mhxue69uhkummnw3ezummcw3ezuer9wcq3samnwvaz7tmjv4kxz7fwwdhx7un59eek7cmfv9kqz9rhwden5te0wfjkccte9ejxzmt4wvhxjmczyzl85553k5ew3wgc7twfs9yffz3n60sd5pmc346pdaemf363fuywvqcyqqqqqqgmgu9ev
[news389 frigate]: /fr/newsletters/2026/01/23/#serveur-electrum-pour-tester-les-paiements-silencieux
[news368 backbone]: /fr/newsletters/2025/08/22/#noeud-base-sur-le-noyau-bitcoin-core-annonce
[backbone ml 1]: https://groups.google.com/g/bitcoindev/c/D6nhUXx7Gnw/m/q1Bx4vAeAgAJ
[backbone ml 2]: https://groups.google.com/g/bitcoindev/c/ViIOYc76CjU/m/cFOAYKHJAgAJ
[news349 swiftsync]: /fr/newsletters/2025/04/11/#acceleration-swiftsync-pour-le-telechargement-initial-des-blocs
[utreexod blog]: https://delvingbitcoin.org/t/new-utreexo-releases/2371
[floresta v0.9.0]: https://www.getfloresta.org/blog/release-v0.9.0
[news366 utreexo bips]: /fr/newsletters/2025/08/08/#bips-en-version-draft-proposes-pour-utreexo
[kofn post del]: https://delvingbitcoin.org/t/towards-a-k-of-n-lightning-network-node/2395
[nmusig2 paper]: https://eprint.iacr.org/2026/223
[bitcoin core 31.0rc4]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc4/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[Core Lightning 26.04rc3]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc3
[news380 kernel]: /fr/newsletters/2025/11/14/#bitcoin-core-30595
[news390 header]: /fr/newsletters/2026/01/30/#bitcoin-core-33822
[news388 private]: /fr/newsletters/2026/01/16/#bitcoin-core-29415
[news398 splicing]: /fr/newsletters/2026/03/27/#bolts-1160
[news371 0fc]: /fr/newsletters/2025/09/12/#ldk-4053
[news337 bip375]: /fr/newsletters/2025/01/17/#bips-1687
[BIP376]: https://github.com/bitcoin/bips/blob/master/bip-0376.mediawiki
[LUD-21]: https://github.com/lnurl/luds/blob/luds/21.md
[topic secp formalization]: https://groups.google.com/g/bitcoindev/c/l7AdGAKd1Oo
[secp verification codebase]: https://github.com/remix7531/secp256k1-scalar-fv-test
