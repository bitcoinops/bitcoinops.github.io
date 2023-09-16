---
title: Validation côté client

## Optionnel. Nom plus court à utiliser pour les liens de style de référence, par exemple "foo"
## permettra d'utiliser le lien [sujet foo][]. Non sensible à la casse
# shortname: foo

## Optionnel. Une entrée sera ajoutée à l'index des sujets pour chaque alias
aliases:
  - RGB
  - Taro
  - Actifs Taproot

## Requis. Au moins une catégorie à laquelle ce sujet appartient. Voir
## le schéma pour les options
categories:
  - Protocoles de contrat

## Optionnel. Produit un lien Markdown avec soit "[titre][]" ou
## "[titre](lien)"
#primary_sources:
#    - title: Exemple
#      link: https://example.com

## Optionnel. Chaque entrée nécessite "title" et "url". Peut également utiliser "feature:
## true" pour mettre en gras l'entrée et "date"
optech_mentions:
  - title: "Schéma de jeton transférable Taro"
    url: /fr/newsletters/2022/04/13/#schéma-de-jeton-transférable

  - title: "Mise à jour sur RGB"
    url: /fr/newsletters/2023/04/19/#mise-à-jour-rgb

  - title: "Spécifications publiées pour les actifs Taproot"
    url:  /fr/newsletters/2023/09/13/#spécifications-pour-les-actifs-taproot

## Optionnel. Même format que "primary_sources" ci-dessus
see_also:
  - title: "Pay to Contract (P2C)"
    link: sujet p2c

## Optionnel. Forcer l'affichage (true) ou la non-affichage (false) de l'avis de sujet ébauche.
## Par défaut, il s'affiche si le contenu de la page est inférieur à un certain nombre de mots
#stub: false

## Requis. Utilisez le formatage Markdown. Un seul paragraphe. Aucun lien autorisé.
## Doit contenir moins de 500 caractères
excerpt: >
  Les **protocoles de validation côté client** permettent à une transaction Bitcoin de
  s'engager sur des données dont la validité est déterminée séparément de la
  validité de la transaction selon les règles de consensus de Bitcoin. La
  validation côté client peut tirer parti des règles de consensus, telles que
  n'autoriser qu'une sortie à être dépensée une seule fois dans une chaîne de blocs valide,
  mais elle peut également imposer des règles supplémentaires connues uniquement de ceux intéressés
  par la validation.

---
Un protocole de validation côté client conceptuellement simple pourrait associer un
jeton à une UTXO particulière. Seul l'ensemble des validateurs a besoin de connaître
cette association ; elle n'a pas besoin d'être publiée dans la chaîne de blocs
ou ailleurs de manière publique. Lorsque l'UTXO est dépensée, la
transaction de dépense associe le jeton à une nouvelle UTXO. Si Alice
contrôle actuellement l'UTXO associée au jeton et que Bob souhaite
l'acheter, elle peut lui fournir une preuve de l'association originale
et il peut ensuite utiliser sa copie validée de la chaîne de blocs
ainsi que la validation côté client pour vérifier l'historique de chaque transfert du
jeton menant à Alice. Il peut également vérifier qu'une transaction
créée par Alice est correctement formatée pour attribuer le jeton à une UTXO
que Bob contrôle.

**[RGB][]** est un protocole de validation côté client qui utilise
[pay-to-contract][sujet p2c] pour permettre aux transactions de s'engager sur
des données supplémentaires, telles que des transferts. Le protocole a été conçu pour
être très flexible.

**[Actifs Taproot][]**, anciennement appelé **Taro**, est un protocole fortement
inspiré par RGB qui utilise l'engagement de [taproot][sujet taproot].
La structure permet aux transactions de s'engager envers des données supplémentaires. La construction de Taproot elle-même découle du pay-to-contract. Comme son nom l'indique, le développement initial du protocole est spécifiquement axé sur le transfert d'actifs (c'est-à-dire des jetons numériques représentant des actifs).

Les deux protocoles sont conçus pour être compatibles avec les transactions hors chaîne, telles que les paiements LN. Tout comme le cycle de vie d'un canal LN, une transaction de configuration sur chaîne est publiée, qui engage les jetons au contrôle mutuel des parties impliquées ; une série de transactions hors chaîne s'engage chacune envers l'allocation actuelle des jetons entre les parties ; et une transaction contenant l'engagement final est publiée sur chaîne.

Seuls les portefeuilles qui souhaitent prendre en charge les actifs RGB ou Taproot doivent comprendre le protocole, et seul un portefeuille qui souhaite envoyer ou recevoir un jeton spécifique ou un contrat de validation côté client doit connaître ce contrat. Pour tous les autres, les transactions créées avec les actifs RGB et Taproot ressemblent à des transactions Bitcoin régulières.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[rgb]: https://rgb.tech/
[taproot assets]: https://docs.lightning.engineering/the-lightning-network/taproot-assets/