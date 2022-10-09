---
title: 'Bitcoin Optech Newsletter #220'
permalink: /fr/newsletters/2022/10/05/
name: 2022-10-05-newsletter-fr
slug: 2022-10-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La lettre d'information de cette semaine décrit une proposition de nouvelles
règles de relais de transaction opt-in et résume la recherche visant à aider
les canaux LN à rester équilibrés. Vous trouverez également nos sections
habituelles énumérant les nouvelles versions logicielles et les release
candidate, ainsi que les principaux changements apportés aux projets
d'infrastructure Bitcoin.

## Nouvelles

- **Proposition de nouvelle politique de relai de transaction conçue pour les pénalités sur LN:**
  Gloria Zhao [a postée][zhao tx3] à la liste de diffusion Bitcoin-Dev
  une proposition visant à permettre aux transactions d'accepter un ensemble
  modifié de politiques de relais de transaction. Toute transaction qui définit
  son paramètre de version à `3` sera:

    - Etre remplaçable tant qu'elle n'est pas confirmée par une transaction payant
      un taux plus élevé et des frais totaux plus élevés (l'actuelle principale
      [RBF][topic rbf] rules)

    - Exiger que tous ses descendants soient également des transactions v3 tant
    qu'il reste non confirmé. Les descendants qui ne respectent pas cette règle
    ne seront pas relayés ou minés par défaut.

    - Être rejeté si l'un de ses ancêtres v3 non confirmés a déjà d'autres
      descendants dans le mempool (ou dans un [package][topic package relay]
      contenant cette transaction)

    - Doit être de 1 000 vbytes ou moins si l'un de ses ancêtres v3 ne sont pas
      confirmés

    Les règles de relais proposées s'accompagnent d'une simplification des règles
      de relais des paquets précédemment proposées. (voir la [Newsletter #167]
      [news167 packages]).

    Ensemble, les règles de relais v3 et de relais de paquets actualisés sont
    conçues pour pour permettre aux transactions d'engagement LN de n'inclure
    que des frais minimaux (ou potentiallement même des frais nuls) et que leurs
    honoraires réels soient payés par une transaction enfant, tout en empêchant
    le [pinning][topic transaction pinning]. Presque tous les nœuds LN utilisent
    déjà un mécanisme de ce type, [anchor outputs][topic anchor outputs], mais
    la mise à niveau proposée devrait rendre la confirmation des opérations
    d'engagement plus simple et plus solide.

    Greg Sanders [a répondu][sanders tx3] avec deux suggestions:

    - *Ephemeral dust:* toutes les transactions avec paiement d'une valeur zéro
    (ou autrement *non rentable*) devrait être exemptée de la [dust policy]
    [topic uneconomical outputs] si cette transaction fait partie d'un paquet
    qui dépense la poussière en sortie.

    - *Standard OP_TRUE:* que les sorties payant une sortie constituée entièrement
      de `OP_TRUE` doivent être relayées par défaut. Une telle sortie peut être
      dépensée par n'importe qui--elle n'a aucune sécurité. Il est donc facile
      pour l'une ou l'autre des parties d'un canal LN (ou même pour des tiers)
      de faire payer une transaction qui dépense cette sortie `OP_TRUE`. Aucune
      donnée n'a besoin d'être mise sur la pile pour dépenser une sortie `OP_TRUE`,
      ce qui rend sa dépense rentable.

    Aucun de ces éléments ne doit être réalisé en même temps que la mise en œuvre
    du relais des transactions v3, mais plusieurs personnes ayant répondu au fil
    de discussion semblaient être en faveur de tous les changements proposés.

- **LN flow control:** Rene Pickhardt [a posté][pickhardt ml valve] à la liste de
  diffusion Lightning-Dev un résumé de sa [recherche récente][pickhardt bitmex valve]
  il a réalisé une étude sur l'utilisation du paramètre `htlc_maximum_msat` comme
  valve de contrôle du débit. Comme [défini précédemment][bolt7 htlc_max] dans BOLT7,
  `htlc_maximum_msat` est la valeur maximale qu'un nœud transmettra au prochain saut
  dans un canal particulier pour une partie de paiement individuelle
  ([HTLC][topic htlc]). 
  Pickhardt aborde le problème d'un canal dans lequel plus de valeur circule dans une
  direction que dans l'autre--ce qui finit par laisser le canal sans assez de fonds
  pour transférer dans la direction sur-utilisée. Il suggère que le canal peut être
  maintenu en équilibre en limitant la valeur maximale dans la direction sur-utilisée.
  Par exemple, si un canal commence par autoriser le transfert de 1,000 sat dans les
  deux sens, mais qu'il devient déséquilibré, essayez de réduire à 800 le montant
  maximum par paiement transféré dans le sens sur-utilisé. Les recherches de Pickhardt
  fournissent plusieurs extraits de code qui peuvent être utilisés pour calculer les
  valeurs `htlc_maximum_msat` appropriées. 

    Dans un [autre courriel][pickhardt ratecards], Pickhardt suggère également
    que l'idée précédente de *fee ratecards* (voir la [newsletter de la semaine dernière]
    [news219 ratecards]) pourraient plutôt devenir des
    *maximum amount per-forward ratecards*, où un dépensier se verrait facturer
    un feerate plus bas pour envoyer de petits paiements et un feerate plus élevé
    pour envoyer des paiements plus importants.  A la différence de la proposition
    originale de ratecards, il s'agirait de montants absolus et non relatifs au
    solde actuel du canal. Anthony Towns [a décrit][towns ratecards]
    plusieurs défis avec l'idée originale des cartes de taux qui ne seraient pas
    des problèmes pour le contrôle de flux basé sur l'ajustement de `htlc_maximum_msat`.

    ZmnSCPxj [a critiqué][zmnscpxj valve] plusieurs aspects de l'idée, y compris
    le fait que les dépensiers pourraient toujours envoyer la même quantité de
    valeur par le biais d'un canal à taux maximum inférieur, ce qui aurait pour
    conséquence de le déséquilibrer à nouveau, simplement en divisant un paiement
    global en petites parties supplémentaires. Towns a suggéré que ce problème
    pourrait être résolu en limitant le taux.

    La discussion semblait être en cours au moment où ce résumé a été écrit, mais
    nous nous attendons à ce que plusieurs nouveaux aperçus viennent dans les
    semaines et les mois suivants, alors que les opérateurs de nœuds commencent
    à expérimenter avec leurs paramètres `htlc_maximum_msat`.

## Mises à jour et release candidate

*Nouvelles versions et release candidate pour le principal projets d'infrastructure
Bitcoin. Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider
à tester les release candidate.*

- [Bitcoin Core 24.0 RC1][] est la première release candidate de la prochaine version
de l'implémentation de nœuds complets la plus largement utilisée sur le réseau.
Un [guide pour tester][bcc testing] est disponible.

## Changements notables dans le code et la documentation

*Changement notable cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Eclair #2435][] ajoute un support optionnel pour une forme de base de *async
  payments* quand le [trampoline relay][topic trampoline payments] est utilisé.
  Comme décrit dans la [Newsletter #171][news171 async], Les paiements asynchrones
  permettrait de payer un nœud hors ligne (tel qu'un portefeuille mobile) sans
  confier les fonds à un tiers. Le mécanisme idéal pour des paiements asynchrones
  est dépendant de [PTLCs][topic ptlc], mais une mise en œuvre partielle nécessite
  simplement qu'une tierce partie retarde l'envoi des fonds jusqu'à ce que le
  nœud hors ligne revienne en ligne. Les nœuds Trampoline peuvent fournir ce délai
  et ce PR les utilise donc pour permettre l'expérimentation des paiements
  asynchrones.

- [BOLTs #962][] supprime le support de la prise en charge du format original de
données en oignon à longueur fixe.  Le format amélioré à longueur variable a été
ajouté à la spécification il y a plus de trois ans et les résultats des tests
mentionnés dans le message de validation indiquent que presque personne n'utilise
plus l'ancien format.

- [BIPs #1370][] revoit [BIP330][] ([Erlay][topic erlay] pour les annonces de
transactions d'annonces de transactions basées sur le rapprochement) pour refléter
la mise en œuvre actuelle proposée. Les changements incluent :

  - Suppression des IDs de transaction tronqués en faveur de l'utilisation de
  transaction wtxids. Cela signifie également que les noeuds peuvent utiliser
  les messages `inv` et `getdata` existants, donc les messages `invtx` et `gettx`
  ont été supprimés.

  - Renommage `sendrecon` en `sendtxrcncl`,
  `reqreconcil` pour `reqrecon`, et `reqbisec` en `reqsketchtext`.

  - Ajout de détails pour la négociation du soutien en utilisant `sendtxrcncl`.

- [BIPs #1367][] simplifie [BIP118][] avec une description de
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] en se référant aux BIPs
  [340][bip340] et [341][bip341] autant que possible.

- [BIPs #1349][] ajoute [BIP351][] intitulé “Private Payments”,
  décrivant un protocole cryptographique inspiré par
  [BIP47][bip47] et [Silent Payments][topic silent payments]. Le BIP introduit
  un nouveau format de code de paiement par lequel les participants spécifient
  les types de sortie supportés à côté de leur clé publique.  Comme dans le BIP47,
  un expéditeur utilise une transaction de notification pour établir un secret
  partagé avec le destinataire sur la base du code de paiement de ce dernier.
  L'expéditeur peut ensuite envoyer plusieurs paiements à des adresses uniques
  dérivées du secret partagé que le destinataire peut dépenser en utilisant les
  informations de la transaction de notification. Là où BIP47 avait plusieurs
  expéditeurs réutilisant la même adresse de notification par récepteur, cette
  proposition utilise des sorties OP_RETURN étiquetées avec la clé de recherche
  `PP` et un code de notification spécifique à la paire expéditeur-récepteur pour
  attirer l'attention du récepteur et établir le secret partagé pour une meilleure
  confidentialité.

- [BIPs #1293][] ajoute [BIP372][] intitulé "Pay-to-contract tweak fields for PSBT".
Ce BIP propose un standard pour inclure le champs additionel [PSBT][topic psbt] qui
fournissent aux dispositifs de signature les données d'engagement contractuel
nécessaires pour participer à l'initiative du protocole [Pay-to-Contract][topic p2c]
(voir la [Newsletter #184][news184 psbt]).

- [BIPs #1364][] ajoute des détails supplémentaires au texte pour le
  [BIP300][] des spécifications de [drivechains][topic sidechains]. La
  spécification connexe de [BIP301][] pour l'application des règles d'extraction
  par fusion aveugle de drivechain est également mise à jour.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2435,962,1370,1367,1349,1293,1364" %}
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bolt7 htlc_max]: https://github.com/lightning/bolts/blob/48fed66e26b80031d898c6492434fa9926237d64/07-routing-gossip.md#requirements-3
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[zhao tx3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020937.html
[news167 packages]: /en/newsletters/2021/09/22/#package-mempool-acceptance-and-package-rbf
[sanders tx3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020938.html
[pickhardt ml valve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003686.html
[pickhardt bitmex valve]: https://blog.bitmex.com/the-power-of-htlc_maximum_msat-as-a-control-valve-for-better-flow-control-improved-reliability-and-lower-expected-payment-failure-rates-on-the-lightning-network/
[pickhardt ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003696.html
[news219 ratecards]: /en/newsletters/2022/09/28/#ln-fee-ratecards
[towns ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003695.html
[zmnscpxj valve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003703.html
[news171 async]: /en/newsletters/2021/10/20/#paying-offline-ln-nodes
[news184 psbt]: /en/newsletters/2022/01/26/#psbt-extension-for-p2c-fields
