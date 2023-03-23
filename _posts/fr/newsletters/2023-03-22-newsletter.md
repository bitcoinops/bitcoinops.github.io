---
title: 'Bulletin Bitcoin Optech #243'
permalink: /fr/newsletters/2023/03/22/
name: 2023-03-22-newsletter-fr
slug: 2023-03-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend nos sections habituelles avec des descriptions
des changements apportés aux services et aux logiciels clients, ainsi que des résumés
des changements notables apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

*Aucune nouvelle significative n'a été trouvée cette semaine sur les
listes de diffusion Bitcoin-Dev ou Lightning-Dev.*

## Changes to services and client software

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et des services Bitcoin.*

- **Xapo Bank prend en charge Lightning :**
  Xapo Bank [a annoncé][xapo lightning blog] que ses clients peuvent désormais envoyer
  des paiements Lightning sortants à partir des applications mobiles de Xapo Bank, en
  utilisant l'infrastructure sous-jacente de Lightspark.

- **Publication d'une bibliothèque TypeScript pour les descripteurs miniscript :**
  La [bibliothèque des descripteurs Bitcoin][github descriptors library] basée sur
  TypeScript prend en charge les [PSBT][topic psbt], les [descripteurs][topic descriptors],
  et les [miniscript][topic miniscript]. Cela inclut la prise en charge de la
  signature directe ou lors de l'utilisation de certains dispositifs de
  signature matérielle.

- **Annonce du SDK Lightning de Breez :**
  Dans un récent [billet de blog][breez blog], Breez a annoncé le [Breez SDK][github
  breez sdk] open source pour les développeurs mobiles qui souhaitent intégrer les
  paiements Bitcoin et Lightning. Le SDK comprend la prise en charge de [Greenlight][blockstream
  greenlight], des fonctionnalités du fournisseur de services Lightning (LSP) et d'autres services.

- **Lancement de la bourse OpenOrdex basée sur PSBT :**
  Le logiciel d'échange [open source][github openordex] permet aux vendeurs de créer un
  carnet d'ordres de satoshis ordinaux en utilisant des [PSBT][topic psbt] et aux acheteurs
  de signer et de diffuser pour réaliser la transaction.

- **Lancement du plugin coinjoin du serveur BTCPay :**
  Le portefeuille Wasabi [annonce][wasabi blog] indique que tout marchand
  du serveur BTCPay peut activer le plugin optionnel qui prend en charge le
  protocole [WabiSabi][news102 wabisabi] pour les [coinjoins][topic coinjoin].

- **l'explorateur mempool.space améliore le support CPFP :**
  L'[explorateur][topic block explorers] mempool.space a annoncé le [support
  additionnel][mempool tweet] pour les transactions liées au [CPFP][topic cpfp]

- **Mise à jour de Sparrow v1.7.3 :**
  La [version v1.7.3][sparrow v1.7.3] de Sparrow inclut la prise en charge de
  [BIP129][] pour les portefeuilles multisig (voir [Bulletin #136][news136 bsms])
  et la prise en charge de l'explorateur de blocs personnalisé, entre
  autres fonctionnalités.

- **Stack Wallet ajoute le contrôle des pièces, BIP47:**
  Les versions récentes du [Stack Wallet][github stack wallet] ajoutent
  des fonctionnalités de [contrôle des pièces][topic coin selection] et
  la prise en charge de [BIP47][].

- **Sortie de Wasabi Wallet v2.0.3 :**
  La version [v2.0.3][Wasabi v2.0.3] de Wasabi comprend la signature taproot
  coinjoin et les changements de sorties taproot, le contrôle manuel des pièces
  par opt-in pour l'envoi, l'amélioration de la vitesse de chargement du
  portefeuille et plus encore.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [LND v0.16.0-beta.rc3][] est une version candidate pour une nouvelle version
majeure de cette implémentation populaire de LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [LND #7448][] ajoute une nouvelle interface de rediffusion pour
  soumettre à nouveau les transactions non confirmées, en particulier
  pour adresser les transactions qui ont été expulsées des mempools.
  Lorsqu'elle est activée, l'interface de rediffusion soumettra les
  transactions non confirmées au nœud complet attaché une fois par bloc
  jusqu'à ce qu'elles soient confirmées. Le LND rediffusait déjà des
  transactions d'une manière similaire lorsqu'il fonctionnait en mode
  Neutrino. Comme indiqué dans une question-réponse de Stack Exchange,
  [Bitcoin Core ne rediffuse actuellement pas les transactions][no rebroadcast],
  bien qu'il serait souhaitable pour la confidentialité et la fiabilité
  que le comportement des nœuds complets soit modifié pour rediffuser
  toutes les transactions que le nœud s'attendait à voir incluses dans
  le bloc précédent. En attendant, il incombe à chaque portefeuille de
  s'assurer de la présence des transactions qui l'intéressent dans les
  pools de mémoire.

- Le [BDK #793][] est une restructuration majeure de la bibliothèque basée
  sur le travail du [sous-projet bdk_core][].  Selon la description du PR,
  il "maintient l'API du portefeuille existant autant que possible et ajoute
  très peu de choses".  Trois points d'extrémité de l'API avec des changements
  apparemment mineurs sont listés dans la description du PR.

{% include references.md %}
{% include linkers/issues.md v=2 issues="7448,793" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[sous-projet bdk_core]: https://bitcoindevkit.org/blog/bdk-core-pt1/
[no rebroadcast]: /en/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools
[xapo lightning blog]: https://www.xapobank.com/blog/another-first-xapo-bank-now-supports-lightning-network-payments
[github descriptors library]: https://github.com/bitcoinerlab/descriptors
[breez blog]: https://medium.com/breez-technology/lightning-for-everyone-in-any-app-lightning-as-a-service-via-the-breez-sdk-41d899057a1d
[github breez sdk]: https://github.com/breez/breez-sdk
[blockstream greenlight]: https://blockstream.com/lightning/greenlight/
[github openordex]: https://github.com/orenyomtov/openordex
[wasabi blog]: https://blog.wasabiwallet.io/wasabiwalletxbtcpayserver/
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[mempool tweet]: https://twitter.com/mempool/status/1630196989370712066
[news136 bsms]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[sparrow v1.7.3]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.3
[github stack wallet]: https://github.com/cypherstack/stack_wallet
[Wasabi v2.0.3]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.3
