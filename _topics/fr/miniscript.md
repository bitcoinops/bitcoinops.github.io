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

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Interactive miniscript demo
      link: http://bitcoin.sipa.be/miniscript/

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Présentation de Miniscript
    url: /en/newsletters/2019/02/05/#miniscript

  - title: Final stack empty, insights from miniscript development
    url: /en/newsletters/2019/05/29/#final-stack-empty

  - title: Miniscript request for comments
    url: /en/newsletters/2019/08/28/#miniscript-request-for-comments

  - title: "2019 year-in-review: miniscript"
    url: /en/newsletters/2019/12/28/#miniscript

  - title: Question about a specification for miniscript
    url: /en/newsletters/2020/03/25/#where-can-i-find-the-miniscript-policy-language-specification

  - title: "Minsc: a new spending policy language based on miniscript"
    url: /en/newsletters/2020/08/05/#new-spending-policy-language

  - title: "PSBT specification updated to improve miniscript compatibility"
    url: /en/newsletters/2020/08/26/#bips-955

  - title: "Miniscript to warn or fail for safety when mixed time/height locks used"
    url: /en/newsletters/2020/09/23/#research-into-conflicts-between-timelocks-and-heightlocks

  - title: "Formal specification of miniscript"
    url: /en/newsletters/2020/12/02/#formal-specification-of-miniscript

  - title: Specter-DIY v1.5.0 adds support for miniscript
    url: /en/newsletters/2021/04/21/#specter-diy-v1-5-0

  - title: "Bitcoin Core #24147 adds backend support for miniscript"
    url: /en/newsletters/2022/04/13/#bitcoin-core-24147

  - title: "Adapting descriptors and miniscript for hardware signing devices"
    url: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices

  - title: "PR Review Club about miniscript support for descriptors"
    url: /en/newsletters/2022/06/08/#bitcoin-core-pr-review-club

  - title: "Bitcoin Core #24148 adds watch-only support for descriptors containing miniscript"
    url: /en/newsletters/2022/07/20/#bitcoin-core-24148

  - title: "2022 year-in-review: miniscript descriptors in Bitcoin Core"
    url: /en/newsletters/2022/12/21/#miniscript-descriptors

  - title: "Bitcoin Core #24149 adds signing support for P2WSH-based miniscript-based output descriptors"
    url: /en/newsletters/2023/02/22/#bitcoin-core-24149

  - title: "MyCitadel v1.3.0 adds more advanced support for miniscript"
    url: /en/newsletters/2023/05/24/#mycitadel-wallet-adds-enhanced-miniscript-support

  - title: "Bitcoin Core #26567 computes input weight for fee estimation using miniscript and descriptors"
    url: /en/newsletters/2023/09/13/#bitcoin-core-26567

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Miniscript: streamlined Bitcoin scripting"
    link: https://medium.com/blockstream/miniscript-bitcoin-scripting-3aeff3853620
---
La représentation structurée des scripts Bitcoin fournie par miniscript permet aux portefeuilles d'être beaucoup plus dynamiques quant
aux scripts qu'ils utilisent. En soutien à cette dynamique, des miniscripts peuvent être créés à l'aide d'un langage de politique facile
à écrire. Les politiques sont composables, ce qui permet à toute sous-expression valide d'être remplacée par une autre sous-expression
valide (dans certaines limites imposées par le système Bitcoin).

{% include references.md %}