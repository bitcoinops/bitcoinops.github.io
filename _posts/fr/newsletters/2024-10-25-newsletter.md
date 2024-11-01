---
title: 'Bulletin Hebdomadaire Bitcoin Optech #326'
permalink: /fr/newsletters/2024/10/25/
name: 2024-10-25-newsletter-fr
slug: 2024-10-25-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume les mises à jour d'une proposition pour de nouvelles annonces
de canaux LN et décrit un BIP pour envoyer des paiements silencieux avec des PSBTs. Il comprend également nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et de
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Mises à jour de la proposition d'annonces de canal version 1.75 :** Elle Mouton a
  [publié][mouton chanann] sur Delving Bitcoin une description de plusieurs changements proposés au
  protocole de [nouvelles annonces de canal][topic channel announcements] qui prendront en charge la publicité
  des [canaux taproot simples][topic simple taproot channels]. Le changement planifié le plus
  significatif est de permettre aux messages d'annoncer également les canaux P2WSH actuels ; cela
  permettra aux nœuds de "commencer à désactiver le protocole ancien [...] lorsque la majorité du
  réseau semble avoir été mise à niveau".

  Un autre ajout, récemment discuté (voir le [Bulletin #325][news325 chanann]), est de permettre
  aux annonces d'inclure une preuve SPV afin que tout client disposant de tous les en-têtes de la blockchain
  avec le plus de preuve de travail puisse vérifier que la transaction de financement du canal a été
  incluse dans un bloc. Actuellement, les clients légers doivent télécharger un bloc entier pour
  effectuer le même niveau de vérification d'une annonce de canal.

  Le post de Mouton évoque également brièvement la possibilité d'autoriser l'annonce facultative de canaux taproot
  simples existants. En raison de l'absence actuelle de prise en charge des annonces de canaux non-P2WSH,
  tous les canaux taproot existants sont [non annoncés][topic unannounced channels]. Une
  fonctionnalité possible, qui peut être ajoutée à la proposition, permettra aux nœuds de signaler à
  leurs pairs qu'ils souhaitent convertir un canal non annoncé en un canal public.

- **Proposition de BIP pour envoyer des paiements silencieux avec des PSBTs :** Andrew Toth a
  [publié][toth sp-psbt] sur la liste de diffusion Bitcoin-Dev une proposition de BIP permettant aux
  portefeuilles et aux dispositifs de signature d'utiliser des [PSBTs][topic psbt] pour coordonner la
  création d'un [paiement silencieux][topic silent payments]. Cela continue la discussion précédente
  sur une itération antérieure de proposition de BIP, voir les Bulletins [#304][news304 sp] et
  [#308][news308 sp]. Comme mentionné dans ces newsletters antérieures, une exigence spéciale des
  paiements silencieux par rapport à la plupart des autres transactions coordonnées par PSBT est que
  tout changement apporté aux entrées d'une transaction non entièrement signée nécessite de réviser
  les sorties.

  La proposition ne traite que de la situation la plus courante attendue où un signataire a accès aux
  clés privées pour toutes les entrées d'une transaction. Pour la situation moins courante de
  signataires multiples, Toth écrit que "cela sera spécifié dans un BIP suivant".

# Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Le Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs
d'Optech cherchent des réponses à leurs questions - ou quand nous avons quelques moments libres pour
aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière
certaines des questions et réponses les plus votées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Blocs en double dans les fichiers blk*.dat ?]({{bse}}124368)
  Pieter Wuille explique qu'en plus de la chaîne actuelle des meilleurs blocs, les fichiers de données
  de blocs peuvent également inclure des blocs obsolètes ou des données de bloc en double.

- [Comment la structure du pay-to-anchor a-t-elle été décidée ?]({{bse}}124383)
  Antoine Poinsot décrit la structure des sorties [pay-to-anchor (P2A)][topic ephemeral anchors]
  incluses dans les [changements de politique][bcc28 guide] de Bitcoin Core 28.0. Le programme témoin
  v1 encodé en [bech32m][topic bech32], de longueur 2 octets, a été choisi comme une adresse de vanité
  `bc1pfeessrawgf`.

- [Quels sont les avantages des paquets leurre dans le BIP324 ?]({{bse}}124301)
  Pieter Wuille détaille les décisions de conception concernant [l'inclusion de paquets leurre][bip324
  decoy packets] dans la spécification [BIP324][]. Les paquets leurre optionnels peuvent être utilisés
  pour masquer les schémas de trafic afin d'éviter la reconnaissance par les observateurs pendant les
  phases d'échange de clés, d'application et de négociation de version du protocole.

- [Pourquoi la limite d'opcode est-elle de 201 ?]({{bse}}124465)
  Vojtěch Strnad souligne les changements de code effectués par Satoshi en 2010 qui visaient à
  introduire une limite d'opcode de 200, mais en raison d'une erreur de mise en œuvre, ont en fait
  introduit une limite de 201.

- [Mon nœud relayera-t-il une transaction si elle est en dessous de mon frais de relais minimum pour les transactions ?]({{bse}}124387)
  Murch note qu'un nœud ne relayera que les transactions qu'il accepte dans son propre mempool. Bien
  qu'un utilisateur puisse diminuer la valeur de `minTxRelayFee` de son nœud pour permettre
  l'acceptation locale dans le mempool, l'inclusion d'une transaction avec des frais de relais
  inférieurs dans un bloc nécessiterait toujours qu'un mineur applique un paramètre similaire et que
  les frais moyens diminuent vers ces frais inférieurs.

- [Pourquoi le portefeuille Bitcoin Core ne prend-il pas en charge le BIP69 ?]({{bse}}124382)
  Murch convient qu'une mise en œuvre universelle de la spécification d'ordonnancement des
  entrées/sorties de transaction du [BIP69][] aiderait à atténuer le [fingerprinting de
  portefeuille][ishaana fingerprinting], mais souligne qu'étant donné la faible probabilité d'une
  adoption universelle, l'implémentation du BIP69 constitue en elle-même une vulnérabilité de
  fingerprinting.

- [Comment puis-je activer testnet4 en utilisant Bitcoin Core 28.0 ?]({{bse}}124443)
  Pieter Wuille mentionne deux options de configuration qui activent [testnet4][topic testnet] du
  [BIP94][] : `chain=testnet4` et `testnet4=1`.

- [Quels sont les risques de diffuser une transaction qui révèle un `scriptPubKey` utilisant une clé à faible entropie ?]({{bse}}124296)
  L'utilisateur Quuxplusone fait référence à une transaction récente associée à une série de
  ["puzzles"][puzzle bitcointalk] de mouture de clés Bitcoin de 2015.
  On [suppose][puzzle stackernews] qu’elle a été [remplacée][topic rbf] par un bot surveillant
  le mempool à la recherche de clés à faible entropie. 

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates à la sortie pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [Core Lightning 24.08.2][] est une version de maintenance de cette populaire implémentation de LN
  qui contient "quelques correctifs de plantage et inclut une amélioration pour mémoriser et mettre à jour
  les indices de canal pour les paiements". {% assign timestamp="52:12" %}

## Changements notables de code et de documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [Eclair #2925][] introduit le support pour l'utilisation de [RBF][topic rbf] avec
  les transactions de [splicing][topic splicing] via la nouvelle commande API `rbfsplice`,
  qui déclenche un échange de messages `tx_init_rbf` et `tx_ack_rbf` pour que les pairs
  acceptent de remplacer la transaction. Cette fonctionnalité est uniquement activée pour
  les canaux non-[zero-conf][topic zero-conf channels], pour prévenir le vol potentiel
  de fonds sur les canaux zero-conf. Les chaînes de transactions de splice non confirmées sont
  autorisées sur les canaux zero-conf, mais pas sur les canaux non-zero-conf. De plus,
  le RBF est bloqué sur les transactions d'achat de liquidité via le protocole de [publicité de
  liquidité][topic liquidity advertisements], pour éviter les cas limites
  où les vendeurs pourraient ajouter de la liquidité à un canal sans recevoir de paiement.

- [LND #9172][] ajoute un nouveau drapeau `mac_root_key` aux commandes `lncli create` et `lncli createwatchonly`
  pour la génération déterministe de macaroon (jeton d'authentification),
  permettant d'intégrer des clés externes dans un nœud LND avant même qu'il soit
  initialisé. Cela est particulièrement utile en combinaison avec la configuration de signataire
  distant inversé suggérée dans [LND #8754][] (voir le [Bulletin #172][news172 remote]).

- [Rust Bitcoin #2960][] transforme l'algorithme d'encryption authentifiée
  [ChaCha20-Poly1305][rfc8439] avec des données associées (AEAD) en son propre paquet, permettant
  son utilisation au-delà du [protocole de transport v2][topic v2 p2p transport]
  spécifié dans [BIP324][], tel que pour [payjoin V2][topic payjoin]. Le code a été optimisé pour
  prendre en charge des instructions Single Instruction, Multiple Data (SIMD) afin d'améliorer la performance à
  travers divers cas d'utilisation (voir le [Bulletin #264][news264 chacha]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2925,9172,2960,8754" %}
[mouton chanann]: https://delvingbitcoin.org/t/updates-to-the-gossip-1-75-proposal-post-ln-summit-meeting/1202/
[news325 chanann]: /en/newsletters/2024/10/18/#gossip-upgrade
[toth sp-psbt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cde77c84-b576-4d66-aa80-efaf4e50468fn@googlegroups.com/
[news304 sp]: /fr/newsletters/2024/05/24/#discussion-sur-les-psbt-pour-les-paiements-silencieux
[news308 sp]: /fr/newsletters/2024/06/21/#discussion-continue-sur-les-psbt-pour-les-paiements-silencieux
[core lightning 24.08.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.2
[news172 remote]: /en/newsletters/2021/10/27/#lnd-5689
[rfc8439]: https://datatracker.ietf.org/doc/html/rfc8439
[news264 chacha]: /fr/newsletters/2023/08/16/#bitcoin-core-28008
[bcc28 guide]: /fr/bitcoin-core-28-wallet-integration-guide/
[bip324 decoy packets]: https://github.com/bitcoin/bips/blob/22660ad3078ee9bd106e64d44662a59a1967c4bd/bip-0324.mediawiki?plain=1#L126
[ishaana fingerprinting]: https://ishaana.com/blog/wallet_fingerprinting/
[puzzle bitcointalk]: https://bitcointalk.org/index.php?topic=1306983.0
[puzzle stackernews]: https://stacker.news/items/683489
