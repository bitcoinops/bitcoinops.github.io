---
title: 'Bulletin Hebdomadaire Bitcoin Optech #389'
permalink: /fr/newsletters/2026/01/23/
name: 2026-01-23-newsletter-fr
slug: 2026-01-23-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine inclut un lien vers un article sur l'étude des réseaux de canaux de
paiement.
Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Actualités

- **Une théorie mathématique des réseaux de canaux de paiement** : René Pickhardt a
  [publié][channels post] sur Delving Bitcoin à propos de la publication de son nouvel
  [article][channels paper] intitulé "A Mathematical Theory of Payment Channel Network". Dans cet
  article, Pickhardt regroupe plusieurs observations, recueillies pendant des années de recherche,
  sous un seul cadre géométrique. En particulier, l'article vise à analyser des phénomènes communs,
  tels que l'épuisement des canaux (voir le [Bulletin #333][news333 depletion]) et les inefficacités en
  capital des canaux à deux parties, en évaluant comment ils sont interconnectés et pourquoi ils sont
  vrais.

  Les principales contributions de l'article sont les suivantes :

  - Un modèle pour les distributions de richesse réalisables des utilisateurs sur le réseau Lightning,
    étant donné un graphe de canaux

  - Une formule pour estimer la limite supérieure de la bande passante de paiement pour les paiements

  - Une méthode pour estimer la probabilité qu'un paiement soit réalisable (voir le [Bulletin
    #309][news309 feasibility])

  - Une analyse sur différentes
  [stratégies d'atténuation][mitigation post] pour l'épuisement des canaux

  - La conclusion que les canaux à deux parties imposent de fortes contraintes à la capacité de la
    liquidité à circuler entre les pairs du réseau

  Selon Pickhardt, les idées issues de sa recherche ont été la motivation derrière son récent post sur
  l'utilisation d'Ark comme une fabrique de canaux (voir le [Bulletin #387][new387 ark]). Pickhardt a
  également fourni sa [collection][pickhardt gh] de code, de cahiers et d'articles qui ont servi de
  base à sa recherche.

  Enfin, Pickhardt a ouvert la discussion sur son travail à des questions et des retours de la
  communauté des développeurs LN sur la manière dont la conception du protocole pourrait être
  influencée par sa recherche et sur la meilleure utilisation pour les canaux multi-parties.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Serveur Electrum pour tester les paiements silencieux :**
  [Frigate Electrum Server][frigate gh] implémente le service de [scanner à distance][bip352 remote
  scanner] de [BIP352][] pour fournir une analyse de [paiements silencieux][topic silent payments]
  pour les applications clientes. Frigate utilise également le calcul GPU moderne pour réduire le
  temps d'analyse, ce qui est utile pour fournir des instances multi-utilisateurs qui gèrent de
  nombreuses demandes d'analyse simultanées.

- **Bibliothèque BDK WASM :**
  La bibliothèque [bdk-wasm][bdk-wasm gh], initialement développée et [utilisée][metamask blog] par
  l'organisation MetaMask, offre un accès aux fonctionnalités de BDK dans les environnements qui
  prennent en charge WebAssembly (WASM).

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 25.12.1][] est une version de maintenance qui corrige un bug critique où les nœuds
  créés avec la v25.12 ne pouvaient pas dépenser des fonds envoyés à des adresses non-[P2TR][topic
  taproot] (voir ci-dessous). Elle corrige également les problèmes de compatibilité avec la récupération
  et `hsmtool` avec le nouveau format basé sur un mnémonique `hsm_secret` introduit dans
  la v25.12 (voir le [Bulletin #388][news388 cln]).

- [LND 0.20.1-beta.rc1][] est un candidat à la version pour une version mineure qui ajoute une
  récupération de panique pour le traitement des messages de gossip, améliore la protection contre les
  réorganisations, implémente des heuristiques de détection LSP, et corrige de multiples bugs et
  conditions de concurrence. Voir les [notes de version][] pour plus de détails.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de
Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo],
[Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32471][] corrige un bug où appeler le RPC `listdescriptors` avec le paramètre
  `private=true` (voir les Bulletins [#134][news134 descriptor] et [#162][news162 descriptor]) échouait
  si un [descripteur][topic descriptors] avait une clé privée manquante. Ce problème affectait les
  portefeuilles contenant à la fois des descripteurs non seulement en observation seulement et des descripteurs
  simples, ainsi que des descripteurs multisig sans toutes les clés privées. Ce PR garantit que
  le RPC retourne correctement les clés privées disponibles, permettant aux utilisateurs de les
  sauvegarder correctement. Appeler `listdescriptors private=true` sur un portefeuille strictement en
  observation échoue toujours.

- [Bitcoin Core #34146][] améliore la propagation des adresses en envoyant la première auto-annonce
  d'un nœud dans son propre message P2P. Auparavant, l'auto-annonce était regroupée avec plusieurs
  autres adresses en réponse à une demande `getaddr` d'un pair, ce qui pourrait causer son rejet ou
  déplacer d'autres adresses.

- [Core Lightning #8831][] corrige un bug critique où les nœuds créés avec la v25.12 ne pouvaient
  pas dépenser des fonds envoyés à des adresses non-[P2TR][topic taproot]. Bien que tous les types
  d'adresses aient été dérivés basés sur [BIP86][] pour ces nœuds, le code de signature utilisait
  uniquement [BIP86][] pour les adresses P2TR. Ce PR garantit que la signature utilise la dérivation
  [BIP86][] pour tous les types d'adresses.

- [LDK #4261][] ajoute le support pour le [splicing][topic splicing] en mode mixte, permettant un
  splice-in et un splice-out simultanés dans la même transaction. L'entrée de financement paie les
  frais appropriés, comme dans le cas du splice-in. La valeur nette contribuée peut être négative si
  plus de valeur est splicée out que splicée in.

- [LDK #4152][] ajoute le support pour les sauts fictifs sur les chemins de paiement
  [aveuglés][topic rv routing], parallèlement à la fonctionnalité pour les chemins de messages
  aveuglés ajoutée dans le [Bulletin #370][news370 dummy]. Ajouter des sauts supplémentaires rend
  significativement plus difficile de déterminer la distance ou l'identité du nœud récepteur. Voir
  le [Bulletin #381][news381 dummy] pour les travaux précédents permettant cela.

- [LND #10488][] corrige un bug où les canaux ouverts avec l'option `fundMax` (voir le [Bulletin
  #246][news246 fundmax]) étaient limités en taille par le paramètre `maxChanSize` configuré par
  l'utilisateur (voir le [Bulletin #116][news116 maxchan]), qui est censé limiter uniquement les
  demandes de canaux entrants. Ce PR garantit que l'option `fundMax` utilise la taille maximale de
  canal au niveau du protocole, selon que l'utilisateur et le pair prennent en charge [les grands
  canaux][topic large channels].

- [LND #10331][] améliore la manière dont les fermetures de canaux gèrent les réorganisations de la
  blockchain en utilisant des exigences de confirmation échelonnées basées sur la taille du canal, où
  le minimum est de 1 et le maximum est de 6 confirmations. Le surveillant de chaîne est remanié avec
  l'introduction d'une machine à états pour mieux détecter les réorganisations de la blockchain et
  suivre les transactions de fermeture de canal concurrentes dans de tels scénarios. Le PR ajoute
  également une surveillance pour les confirmations négatives (lorsqu'une transaction confirmée est
  plus tard sortie par réorganisation), bien que la manière de les gérer reste non résolue. Ce PR
  aborde le [plus ancien problème ouvert][lnd issue] de LND datant de 2016.

- [Rust Bitcoin #5402][] ajoute une validation lors du décodage pour rejeter les transactions avec
  des entrées dupliquées, en relation avec le [CVE-2018-17144][topic cve-2018-17144]. Les transactions
  contenant plusieurs entrées dépensant le même point de sortie sont invalides par consensus.

- [BIPs #1820][] met à jour [BIP3][] au statut `Déployé`, remplaçant [BIP2][] comme la directive
  pour le processus de Proposition d'Amélioration de Bitcoin (BIP). Voir le [Bulletin #388][news388
  bip3] pour plus de détails.

- [BOLTs #1306][] clarifie dans la spécification [BOLT12][] que [les offres][topic offers] avec un
  champ `offer_chains` vide doivent être rejetées. Une offre avec ce champ présent mais contenant zéro
  hash de chaîne rend les demandes de facture impossibles puisque le payeur ne peut pas satisfaire
  l'exigence de définir `invreq_chain` à l'un des `offer_chains`.

- [BLIPs #59][] met à jour [BLIP51][], également connu sous le nom de LSPS1, pour ajouter le support
  pour [les offres BOLT12][topic offers] comme une option pour payer les Fournisseurs de Services
  Lightning (LSPs), aux côtés des options [BOLT11][] et on-chain existantes. Cela a été précédemment
  implémenté dans LDK (voir le [Bulletin #347][news347 lsp]).

{% include snippets/recap-ad.md when="2026-01-27 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32471,34146,8831,4261,4152,10488,10331,5402,1820,1306,59" %}

[channels post]: https://delvingbitcoin.org/t/a-mathematical-theory-of-payment-channel-networks/2204
[channels paper]: https://arxiv.org/pdf/2601.04835
[news309 feasibility]: /fr/newsletters/2024/06/28/#estimation-de-la-probabilite-qu-un-paiement-ln-soit-realisable
[mitigation post]: https://delvingbitcoin.org/t/mitigating-channel-depletion-in-the-lightning-network-a-survey-of-potential-solutions/1640/1
[news333 depletion]: /fr/newsletters/2024/12/13/#apercus-sur-l-epuisement-des-canaux
[new387 ark]: /fr/newsletters/2026/01/09/#utiliser-ark-comme-une-fabrique-de-canaux
[pickhardt gh]: https://github.com/renepickhardt/Lightning-Network-Limitations
[frigate gh]: https://github.com/sparrowwallet/frigate
[bip352 remote scanner]: https://github.com/silent-payments/BIP0352-index-server-specification/blob/main/README.md#remote-scanner-ephemeral
[bdk-wasm gh]: https://github.com/bitcoindevkit/bdk-wasm
[metamask blog]: https://metamask.io/news/bitcoin-on-metamask-btc-wallet
[Core Lightning 25.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12.1
[LND 0.20.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta.rc1
[news388 cln]: /fr/newsletters/2026/01/16/#core-lightning-8830
[notes de version]: https://github.com/lightningnetwork/lnd/blob/v0.20.x-branch/docs/release-notes/release-notes-0.20.1.md
[news134 descriptor]: /en/newsletters/2021/02/03/#bitcoin-core-20226
[news162 descriptor]: /en/newsletters/2021/08/18/#bitcoin-core-21500
[news370 dummy]: /fr/newsletters/2025/09/05/#ldk-3726
[news381 dummy]: /fr/newsletters/2025/11/21/#ldk-4126
[news246 fundmax]: /fr/newsletters/2023/04/26/#lnd-6903
[news116 maxchan]: /en/newsletters/2020/09/23/#lnd-4567
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/53
[news388 bip3]: /fr/newsletters/2026/01/16/#processus-bip-mis-a-jour
[news347 lsp]: /fr/newsletters/2025/03/28/#ldk-3649