---
title: Miniscript

## Requis. Au moins une catégorie à laquelle ce sujet appartient. Voir
## le schéma pour les options
categories:
  - Scripts et adresses
  - Outils de collaboration de portefeuille
  - Outils de développement

## Requis. Utilisez le format Markdown. Un seul paragraphe. Aucun lien autorisé.
excerpt: >
  **Miniscript** permet au logiciel d'analyser automatiquement un script,
  y compris de déterminer quelles données de témoin doivent être générées pour dépenser des bitcoins
  protégés par ce script. Avec miniscript indiquant au portefeuille ce qu'il doit faire,
  les développeurs de portefeuille n'ont pas besoin d'écrire de nouveau code lorsqu'ils passent
  d'un modèle de script à un autre.

## Optionnel. Produit un lien Markdown avec soit "[title][]" ou
## "[title](link)"
primary_sources:
    - title: Démo interactive de miniscript
      link: http://bitcoin.sipa.be/miniscript/

## Optionnel. Chaque entrée nécessite "title", "url" et "date". Peut également utiliser "feature:
## true" pour mettre en gras l'entrée
optech_mentions:
  - title: Présentation de Miniscript
    url: /en/newsletters/2019/02/05/#miniscript

  - title: Pile finale vide, aperçus du développement de Miniscript
    url: /en/newsletters/2019/05/29/#final-stack-empty

  - title: Demande de commentaires sur Miniscript
    url: /en/newsletters/2019/08/28/#miniscript-request-for-comments

  - title: "Bilan de l'année 2019 : Miniscript"
    url: /en/newsletters/2019/12/28/#miniscript

  - title: Question sur une spécification pour Miniscript
    url: /en/newsletters/2020/03/25/#where-can-i-find-the-miniscript-policy-language-specification

  - title: "Minsc : un nouveau langage de politique de dépense basé sur Miniscript"
    url: /en/newsletters/2020/08/05/#new-spending-policy-language

  - title: "La spécification PSBT mise à jour pour améliorer la compatibilité avec Miniscript"
    url: /en/newsletters/2020/08/26/#bips-955

  - title: "Miniscript pour avertir ou échouer pour des raisons de sécurité lorsque des verrous de temps/hauteur sont utilisés"
    url: /en/newsletters/2020/09/23/#research-into-conflicts-between-timelocks-and-heightlocks

  - title: "Spécification formelle de Miniscript"
    url: /en/newsletters/2020/12/02/#formal-specification-of-miniscript

  - title: Specter-DIY v1.5.0 ajoute la prise en charge de Miniscript
    url: /en/newsletters/2021/04/21/#specter-diy-v1-5-0

  - title: "Bitcoin Core #24147 ajoute la prise en charge en arrière-plan de Miniscript"
    url: /en/newsletters/2022/04/13/#bitcoin-core-24147

  - title: "Adaptation des descripteurs et de Miniscript pour les appareils de signature matérielle"
    url: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices

  - title: "Club de révision PR sur la prise en charge de Miniscript pour les descripteurs"
    url: /en/newsletters/2022/06/08/#bitcoin-core-pr-review-club

- title: "Bitcoin Core #24148 ajoute la prise en charge en lecture seule pour les descripteurs contenant des miniscripts"
    url: /en/newsletters/2022/07/20/#bitcoin-core-24148

  - title: "Bilan de l'année 2022 : descripteurs de miniscripts dans Bitcoin Core"
    url: /en/newsletters/2022/12/21/#miniscript-descriptors

  - title: "Bitcoin Core #24149 ajoute la prise en charge de la signature pour les descripteurs de sortie basés sur P2WSH et miniscripts"
    url: /en/newsletters/2023/02/22/#bitcoin-core-24149

  - title: "MyCitadel v1.3.0 ajoute une prise en charge plus avancée des miniscripts"
    url: /en/newsletters/2023/05/24/#mycitadel-wallet-ajoute-une-prise-en-charge-améliorée-des-miniscripts

  - title: "Bitcoin Core #26567 calcule le poids de l'entrée pour l'estimation des frais en utilisant miniscript et descripteurs"
    url: /en/newsletters/2023/09/13/#bitcoin-core-26567

## Facultatif. Même format que "primary_sources" ci-dessus
voir_aussi:
  - title: "Miniscript : scripting Bitcoin simplifié"
    link: https://medium.com/blockstream/miniscript-bitcoin-scripting-3aeff3853620
---
La représentation structurée des scripts Bitcoin fournie par miniscript permet aux portefeuilles d'être beaucoup plus dynamiques quant
aux scripts qu'ils utilisent. En soutien à cette dynamique, des miniscripts peuvent être créés à l'aide d'un langage de politique facile
à écrire. Les politiques sont composables, ce qui permet à toute sous-expression valide d'être remplacée par une autre sous-expression
valide (dans certaines limites imposées par le système Bitcoin).

{% include references.md %}