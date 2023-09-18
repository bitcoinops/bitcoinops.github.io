---
title: Contrats verrouillés dans le temps (PTLC)

## Optionnel. Nom plus court à utiliser pour les liens de style de référence, par exemple "foo"
## permettra d'utiliser le lien [sujet foo][]. Non sensible à la casse
shortname: ptlc

## Optionnel. Une entrée sera ajoutée à l'index des sujets pour chaque alias
#aliases:
#  - Foo

## Requis. Au moins une catégorie à laquelle ce sujet appartient. Voir
## le schéma pour les options
categories:
  - Protocoles de contrat
  - Réseau Lightning
  - Améliorations de la confidentialité

## Requis. Utilisez le format Markdown. Un seul paragraphe. Aucun lien autorisé.
## Doit comporter moins de 500 caractères
excerpt: >
  **Les contrats verrouillés dans le temps (PTLC)** sont des paiements conditionnels qui
  peuvent remplacer l'utilisation des HTLC dans les canaux de paiement LN, les échanges de pièces de même chaîne,
  certains échanges atomiques entre chaînes et d'autres contrats
  protocoles. Par rapport aux HTLC, ils peuvent être plus privés et utiliser moins
  d'espace de bloc.

## Optionnel. Produit un lien Markdown avec soit "[titre][]" ou
## "[titre](lien)"
primary_sources:
    - title: Verrous multi-sauts à partir de scripts sans script
      link: https://github.com/ElementsProject/scriptless-scripts/blob/master/md/multi-hop-locks.md

## Optionnel. Chaque entrée nécessite "titre", "url" et "date". Peut également utiliser "feature:
## true" pour mettre en gras l'entrée
optech_mentions:
  - title: Parler de la mise en œuvre de 2p-ECDSA pour le financement LN et les PTLC
    url: /en/newsletters/2018/10/09/#multiparty-ecdsa-for-scriptless-lightning-network-payment-channels

  - title: Signatures adaptatives ECDSA simplifiées pour les PTLC dans les canaux LN
    url: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures

  - title: Utilisation de canaux de paiement asymétriques de témoin pour passer des HTLC aux PTLC
    url: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels

  - title: Proposition de canaux asymétriques de témoin mise à jour pour passer des HTLC aux PTLC
    url: /en/newsletters/2020/10/14/#updated-witness-asymmetric-payment-channel-proposal

  - title: "Bilan de l'année 2020 : passage de LN des HTLC aux PTLC"
    url: /en/newsletters/2020/12/23/#ptlcs

  - title: "Technique pour mettre en œuvre un OU logique sur LN en utilisant des PTLC"
    url: /en/newsletters/2021/02/17/#escrow-over-ln

  - title: "Préparation pour Taproot : PTLC"
    url: /en/newsletters/2021/08/25/#preparing-for-taproot-10-ptlcs

  - title: "Mise à jour de LN pour Taproot : des HTLC aux PTLC"
    url: /en/newsletters/2021/09/01/#preparing-for-taproot-11-ln-with-taproot

  - title: "Proposition de mise à niveau de LN pour utiliser des PTLC"
    url: /en/newsletters/2021/10/13/#multiple-proposed-ln-improvements

  - title: "Utilisation des PTLC pour la réception hors ligne sans garde"
    url: /en/newsletters/2021/10/20/#paying-offline-ln-nodes

  - title: "Résumé de la conférence des développeurs LN, y compris la discussion sur les PTLC"
    url: /en/newsletters/2021/11/10/#ln-summit-2021-notes

  - title: "Discussion sur les changements de protocole LN nécessaires pour prendre en charge les PTLC"
    url: /en/newsletters/2021/12/15/#preparing-ln-for-ptlcs

  - title: "Récapitulatif de l'année 2021 : PTLC pour LN"
    url: /en/newsletters/2021/12/22/#ptlcsx

  - title: Utilisation des adaptateurs de signature avec les PTLC pour prouver l'acceptation d'un paiement LN asynchrone
    url: /en/newsletters/2023/02/01/#ln-async-proof-of-payment

  - title: "Résumé des changements de messagerie LN proposés pour les PTLC"
    url: /en/newsletters/2023/09/13/#ln-messaging-changes-for-ptlcs

## Facultatif. Même format que "primary_sources" ci-dessus
see_also:
  - title: Contrat verrouillé par hachage (HTLC)
    link: topic htlc

  - title: Signatures d'adaptateur
    link: topic adaptor signatures
---
Les PTLC diffèrent des [HTLC][topic htlc] par leur méthode de verrouillage et de déverrouillage principale :

- **Verrouillage par hachage HTLC :** est verrouillé à l'aide d'un hachage digestif et déverrouillé en fournissant le préimage
  correspondant. La fonction de hachage la plus couramment utilisée est SHA256, qui produit un digest de 256 bits (32 octets) généré
  à partir d'un préimage de 32 octets.

    Lorsqu'il est utilisé pour sécuriser plusieurs paiements (par exemple, un paiement LN routé ou un échange atomique), tous les
    paiements utilisent le même préimage et verrouillage par hachage. Cela crée un lien entre ces paiements s'ils sont publiés sur
    la chaîne ou s'ils sont routés hors chaîne via des nœuds de surveillance.

- **Verrouillage par point PTLC :** est verrouillé à l'aide d'une clé publique (un *point* sur la courbe elliptique de Bitcoin) et
  déverrouillé en fournissant une signature correspondante provenant d'un [adaptateur de signature][topic adaptor signatures] satisfait.
  Pour une construction de [signature schnorr][topic schnorr signatures] proposée, la clé serait de 32 octets et la signature de
  64 octets. Cependant, en utilisant soit ECDSA multiparty, soit l'agrégation et la signature de clé schnorr, les clés et la signature
  peuvent être combinées avec d'autres clés et signatures nécessaires pour autoriser toute dépense, permettant aux verrouillages par
  point d'utiliser zéro octet d'espace de bloc distinct.

    Chaque verrouillage par point peut utiliser des clés et des signatures différentes, de sorte qu'il n'y a rien dans le verrouillage
    par point qui corréle différents paiements, que ce soit sur la chaîne ou lorsqu'ils sont routés hors chaîne via des nœuds de
    surveillance.

L'implémentation des PTLC dans Bitcoin nécessite la création d'[adaptateurs de signature][topic adaptor signatures] qui seront plus
faciles à combiner avec des signatures numériques lorsque les [signatures schnorr][topic schnorr signatures] auront été implémentées
sur Bitcoin. Pour cette raison, le développement des PTLC dans Bitcoin a principalement été un sujet de discussion plutôt que quelque
chose sur lequel on travaille activement. L'indisponibilité des signatures schnorr dans les cryptomonnaies alternatives peut également
empêcher l'utilisation des PTLC dans certains contrats inter-chaînes, bien qu'il soit toujours techniquement possible d'utiliser des PTLC
avec uniquement des clés et des signatures ECDSA.

{% include references.md %}