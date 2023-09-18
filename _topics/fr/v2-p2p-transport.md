---
title: Version 2 P2P transport
shortname: v2 transport P2P

## Requis. Au moins une catégorie à laquelle ce sujet appartient. Voir
## le schéma pour les options
categories:
  - Protocole réseau P2P
  - Améliorations de la confidentialité

aliases:
  - BIP151
  - BIP324

## Requis. Utilisez le format Markdown. Un seul paragraphe. Aucun lien autorisé.
excerpt: >
  **Version 2 (v2) transport P2P** est une proposition permettant aux nœuds Bitcoin
  de communiquer entre eux via des connexions chiffrées.

## Optionnel. Produit un lien Markdown avec "[title][]" ou
## "[title](link)"
primary_sources:
    - title: v2 Encrypted Transport Protocol proposed BIP
      link: https://github.com/bitcoin/bips/issues/1378

## Optionnel. Chaque entrée nécessite "title", "url" et "date". Peut également utiliser "feature:
## true" pour mettre en gras l'entrée
optech_mentions:
  - title: Continuing work on P2P protocol encryption
    url: /en/newsletters/2018/08/21/#p2p-protocol-encryption

  - title: PR opened for initial BIP151 support
    url: /en/newsletters/2018/08/28/#pr-opened-for-initial-bip151-support

  - title: Criticism and defense of BIP151 choices
    url: /en/newsletters/2018/09/11/#bip151-discussion

  - title: Announcement of v2 P2P transport proposal
    url: /en/newsletters/2019/03/26/#version-2-p2p-transport-proposal

  - title: "CoreDev.tech discussion of v2 P2P transport proposal"
    url: /en/newsletters/2019/06/12/#v2-p2p

  - title: "Update on BIP324 v2 encrypted transport protocol"
    url: /en/newsletters/2022/10/19/#bip324-update

  - title: "CoreDev.tech discussion of v2 P2P encrypted transport proposal"
    url: /en/newsletters/2022/10/26/#transport-encryption

  - title: "Request for feedback on message identifiers for v2 P2P encrypted transport"
    url: /en/newsletters/2022/11/02/#bip324-message-identifiers

  - title: "2022 year-in-review: encrypted v2 transport protocol"
    url: /en/newsletters/2022/12/21/#v2-transport

  - title: "Libsecp256k1 #1129 implements the ElligatorSwift technique for establishing v2 P2P connections"
    url: /en/newsletters/2023/06/28/#libsecp256k1-1129

  - title: "Bitcoin Core #28008 adds encryption and decryption routines for v2 transport protocol encryption"
    url: /en/newsletters/2023/08/16/#bitcoin-core-28008

  - title: "Bitcoin Core PR Review Club summary about internal serialization changes for BIP324"
    url: /en/newsletters/2023/09/13/#bitcoin-core-pr-review-club

## Optionnel. Même format que "primary_sources" ci-dessus
see_also:
  - title: BIP151
  - title: Countersign
    link: topic countersign
---
D'autres changements du protocole de communication sont également suggérés,
telles que permettre aux commandes de protocole fréquemment utilisées d'être aliasées en séquences de bytes raccourcies pour réduire la
bande passante.

Cette proposition remplace la précédente proposition [BIP151][].

{% include references.md %}