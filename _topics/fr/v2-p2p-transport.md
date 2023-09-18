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
    - title: Proposition de protocole de transport chiffré v2 BIP
      link: https://github.com/bitcoin/bips/issues/1378

## Optionnel. Chaque entrée nécessite "title", "url" et "date". Peut également utiliser "feature:
## true" pour mettre en gras l'entrée
optech_mentions:
  - title: Poursuite des travaux sur le chiffrement du protocole P2P
    url: /fr/newsletters/2018/08/21/#chiffrement-du-protocole-p2p

  - title: PR ouverte pour le support initial de BIP151
    url: /fr/newsletters/2018/08/28/#pr-ouverte-pour-le-support-initial-de-bip151

  - title: Critique et défense des choix de BIP151
    url: /fr/newsletters/2018/09/11/#discussion-sur-bip151

  - title: Annonce de la proposition de transport P2P v2
    url: /fr/newsletters/2019/03/26/#proposition-de-transport-p2p-version-2

  - title: "Discussion sur CoreDev.tech de la proposition de transport P2P v2"
    url: /fr/newsletters/2019/06/12/#transport-p2p-v2

  - title: "Mise à jour sur BIP324, protocole de transport chiffré v2"
    url: /fr/newsletters/2022/10/19/#mise-a-jour-bip324

  - title: "Discussion sur CoreDev.tech de la proposition de transport chiffré P2P v2"
    url: /fr/newsletters/2022/10/26/#chiffrement-du-transport

  - title: "Demande de commentaires sur les identifiants de message pour le transport chiffré P2P v2"
    url: /fr/newsletters/2022/11/02/#identifiants-de-message-bip324

  - title: "Récapitulatif de l'année 2022 : protocole de transport chiffré v2"
    url: /fr/newsletters/2022/12/21/#transport-v2

  - title: "Libsecp256k1 #1129 implémente la technique ElligatorSwift pour établir des connexions P2P v2"
    url: /fr/newsletters/2023/06/28/#libsecp256k1-1129

  - title: "Bitcoin Core #28008 ajoute des routines de chiffrement et de déchiffrement pour le chiffrement du protocole de transport v2"
    url: /fr/newsletters/2023/08/16/#bitcoin-core-28008

  - title: "Résumé du Bitcoin Core PR Review Club sur les modifications internes de sérialisation pour BIP324"
    url: /fr/newsletters/2023/09/13/#bitcoin-core-pr-review-club

## Optionnel. Même format que "primary_sources" ci-dessus
see_also:
  - title: BIP151
  - title: Countersign
    link: topic countersign
---
D'autres changements du protocole de communication sont également suggérés,
telles que permettre aux commandes de protocole fréquemment utilisées d'être aliasées en séquences de bytes raccourcies pour réduire la bande passante.

Cette proposition remplace la précédente proposition [BIP151][].

{% include references.md %}