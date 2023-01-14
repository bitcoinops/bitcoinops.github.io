---
title: 'Bulletin hebdomadaire Bitcoin Optech #233'
permalink: /fr/newsletters/2023/01/11/
name: 2023-01-11-newsletter-fr
slug: 2023-01-11-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin d'information de cette semaine décrit une idée pour permettre aux nœuds LN
hors ligne de recevoir des fonds sur la chaîne qu'ils pourront ensuite utiliser
hors chaîne sans délai supplémentaire. Vous trouverez également nos sections
habituelles avec des résumés des nouvelles versions de logiciels et des versions
candidates, ainsi que des descriptions de changements significatifs dans les
logiciels d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Engagements d'ouvertures non interactifs du canal LN:** Les développeurs ZmnSCPxj
  et Jesse Posner ont [posté][zp potentiam] sur la liste de diffusion Lightning-Dev
  une proposition de nouvelle technique pour ouvrir des canaux LN, qu'ils appellent
  *swap-in-potentiam*. Les méthodes existantes pour ouvrir un canal LN exigent que
  chaque participant signe une transaction de remboursement avant que des fonds ne
  soient déposés dans le canal. Pour créer un remboursement, les détails concernant
  le financement doivent être connus, de sorte que les techniques existantes
  d'ouverture de canaux LN nécessitent une interaction : le bailleur de fonds doit
  informer sa contrepartie du financement qu'il prévoit de fournir ; la contrepartie
  doit créer et signer une transaction de remboursement ; puis le bailleur de fonds
  doit signer et diffuser une transaction de financement.

    Les auteurs notent que cela est problématique pour certains portefeuilles,
    en particulier les portefeuilles sur les appareils mobiles qui peuvent ne
    pas être en ligne ou en mesure d'agir tout le temps. Pour ces portefeuilles,
    il serait raisonnable de générer une adresse onchain de secours à laquelle
    ils peuvent recevoir des fonds si leur nœud LN ne peut être atteint.
    Lorsque le porte-monnaie est à nouveau en ligne, il peut utiliser les fonds
    onchain pour ouvrir un canal LN. Cependant, les nouveaux canaux LN doivent
    être confirmés à un niveau raisonnable (par exemple 6 confirmations) avant
    que le fournisseur de fonds ne puisse transmettre les paiements pour le
    destinataire en toute sécurité et en toute confiance. Cela signifie qu'un
    utilisateur de portefeuille mobile qui reçoit un paiement alors que son nœud
    est hors ligne devra peut-être attendre six blocs après sa remise en ligne
    avant de pouvoir utiliser cet argent pour envoyer un nouveau paiement sur LN.

    Les auteurs proposent une alternative : l'utilisateur Alice choisit à l'avance
    une contrepartie (Bob) dont elle pense que le nœud sera toujours disponible
    (par exemple, un fournisseur de service Lightning, LSP). Alice et Bob coopèrent
    pour créer une adresse onchain pour un script qui permet de dépenser avec une
    signature d'Alice plus une signature de Bob ou l'expiration d'un délai de
    plusieurs semaines (par exemple 6 000 blocs),pour [exemple][potentiam minsc] :

    ```hack
    pk(A) && (pk(B) || older(6000))
    ```

    Cette adresse peut recevoir un paiement qui commence à accumuler des
    confirmations pendant qu'Alice est hors ligne. Tant que le paiement
    n'a pas atteint le nombre de confirmations prévu, Bob doit cosigner
    toute tentative de dépense de l'argent. Si Bob choisit de ne signer
    qu'une seule tentative de dépense qu'Alice signe également, Bob peut
    être sûr qu'Alice ne pourra pas dépenser deux fois cet argent avant
    l'expiration. Le seul moyen pour qu'une dépense d'Alice devienne
    invalide est que le paiement qui lui a été versé précédemment soit
    également dépensé deux fois. Si ce paiement a fait l'objet de
    nombreuses confirmations avant qu'Alice ne se connecte et ne lance
    sa dépense, une double dépense devrait être improbable.

    Cela permet à Alice de recevoir un paiement alors que son portefeuille
    est hors ligne, de se connecter après que le paiement a reçu au moins
    6 confirmations (mais beaucoup moins que 6 000 confirmations), et de
    cosigner immédiatement une transaction pour ouvrir un canal LN dont Bob
    sait qu'il ne peut pas être dépensé deux fois. Avant même que cette
    transaction de création de canal ne soit confirmée, Bob peut commencer
    à transmettre des paiements pour Alice en toute sécurité et en toute
    confiance. Ou, si Alice et Bob ont déjà tous deux des canaux LN (soit
    l'un avec l'autre, soit avec des pairs distincts), Bob peut envoyer
    un paiement LN à Alice, que celle-ci peut réclamer en dépensant ses fonds
    onchain pour Bob. Par ailleurs, si le portefeuille d'Alice est en ligne
    et qu'elle décide de faire un paiement régulier onchain, il lui
    suffit que le portefeuille de Bob cosigne la dépense. Dans le pire des cas,
    si Bob ne coopère pas, Alice peut simplement attendre quelques semaines
    pour dépenser son argent sans sa participation.

    En plus de permettre aux portefeuilles hors ligne de recevoir des fonds pour LN,
    les auteurs expliquent pourquoi l'idée pourrait bien se combiner avec les
    [paiements asynchrones][topic async payments] pour permettre aux LSP (fournisseur
    de service de liquidité) de préparer les opérations de rééquilibrage
    des canaux à l'avance pour le moment où un client hors ligne revient en ligne,
    permettant à ces opérations de rééquilibrage de se produire sans aucun retard
    pour l'utilisateur. Par exemple, si Carole envoie un paiement
    asynchrone LN à Alice pour un montant supérieur à la capacité actuelle du
    canal d'Alice, Bob peut envoyer un paiement au script `pk(B) && (pk(A) || older(6000))`.
    Ce script alternatif inverse les rôles pour Alice et Bob. Si le paiement
    de Bob reçoit un nombre suffisant de confirmations au moment où Alice
    se connecte à nouveau, Alice peut immédiatement transférer ce paiement
    sur un nouveau canal LN et demander à Bob de transmettre le paiement
    asynchrone sur ce nouveau canal, en conservant les propriétés habituelles
    de sécurité et de fiabilité de LN.

    L'idée a fait l'objet d'une discussion modérée sur la liste de diffusion
    au moment de la rédaction de cet article, avec plusieurs commentaires
    demandant des éclaircissements sur certains aspects de l'idée et
    au moins un [commentaire][fournier potentiam] soutenant fortement
    le concept général.

## Mises à jour et version candidate

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [BDK 0.26.0][] est une nouvelle version de cette bibliothèque pour
  la création de portefeuilles.

- [HWI 2.2.0-rc1][] est une version candidate de cette application qui
  permet aux portefeuilles logiciels de s'interfacer avec des dispositifs
  de signature matériels.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Eclair #2455][] implémente le support des messages d'échec pour le flux
  en oignon optionnel Type-Length-Value (TLV) [récemment introduit][bolts #1021]
  dans BOLT 04. Le flux TLV permet aux nœuds de signaler des détails
  supplémentaires sur les échecs de routage et peut être utilisé pour
  le schéma proposé [fat errors][news224 fat] afin de combler le fossé
  dans l'attribution des erreurs.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2455,1021" %}
[bdk 0.26.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0
[hwi 2.2.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0-rc.1
[zp potentiam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003810.html
[potentiam minsc]: https://min.sc/#c=pk%28A%29%20%26%26%20%28pk%28B%29%20%7C%7C%20older%286000%29%29
[fournier potentiam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003813.html
[news224 fat]: /fr/newsletters/2022/11/02/#attribution-de-l-echec-du-routage-ln
