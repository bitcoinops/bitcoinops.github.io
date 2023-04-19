---
title: 'Bulletin Hebdomadaire Bitcoin Optech #246'
permalink: /fr/newsletters/2023/04/12/
name: 2023-04-12-newsletter-fr
slug: 2023-04-12-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine rapporte une discussion à propos du splicing
sur LN et une proposition de BIP sur la terminologie des
transactions. Vous y trouverez également nos sections
habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
des annonces de nouvelles versions et de versions candidates---y compris
une mise à jour de sécurité pour libsecp256k1---et des descriptions de
changements notables apportés aux principaux logiciels de
l'infrastructure Bitcoin.

## Nouvelles

- **Discussions sur les spécifications du splicing :** Plusieurs développeurs LN ont
  posté sur la liste de diffusion Lightning-Dev cette semaine à propos du
  travail en cours sur le [projet de spécification][bolts #863] pour le
  [splicing][topic splicing], qui permet à certains fonds dans un canal
  LN hors chaîne d'être dépensés sur la chaîne (splice-out) ou à des fonds
  sur la chaîne d'être ajoutés à un canal hors chaîne (splice-in). Le canal
  peut continuer à fonctionner pendant qu'une transaction splicée sur
  la chaîne attend un nombre suffisant de confirmations.

  {:.center}
  ![Splicing transaction flow](/img/posts/2023-04-splicing1.dot.png)

  Les discussions de cette semaine ont portées sur les sujets suivants :

  - *Quelles signatures d'engagement envoyer :* lorsqu'un splicing est créé,
    un nœud contient des transactions d'engagement parallèles, une qui dépense
    à partir de la sortie de financement originale et une qui dépense à partir
    de chaque nouvelle sortie de financement pour tous les splicing en attente.
    Chaque fois que l'état du canal est mis à jour, toutes les transactions
    d'engagements parallèles doivent être mises à jour. La façon la plus simple
    de gérer cela est d'envoyer les mêmes messages que ceux qui seraient envoyés
    pour une transaction d'engagement individuelle, mais en les répétant, un
    pour chaque transaction d'engagement parallèle.

    C'est ce qui a été fait dans le projet initial de spécifications pour le
    splicing (voir les bulletins [#17][news17 splice] et [#146][news146 splice]).
    Cependant, comme Lisa Neigut l'a [expliqué][neigut splice] cette semaine, la
    création d'un nouveau splicie nécessite la signature de la nouvelle
    transaction d'engagement dérivée. Dans le projet de spécification actuel,
    l'envoi d'une signature nécessite l'envoi des signatures pour toutes les
    autres transactions d'engagement en cours. C'est redondant : les signatures
    de ces autres transactions d'engagement ont déjà été envoyées. En outre,
    dans le protocole LN actuel, chaque partie reconnaît avoir reçu une signature
    de sa contrepartie en envoyant le point de révocation de la transaction
    d'engagement précédente. Là encore, cette information a déjà été envoyée.
    Il n'est pas dangereux de renvoyer les signatures et les anciens points de
    révocation, mais cela nécessite une bande passante et un traitement
    supplémentaires. L'avantage est que l'exécution de la même opération dans
    tous les cas contribue à la simplicité de la spécification, ce qui peut
    réduire la complexité de la mise en œuvre et des tests.

    L'autre solution consiste à n'envoyer que le nombre minimum de signatures
    pour la nouvelle transaction d'engagement lorsqu'un nouveau fractionnement
    est négocié, ainsi qu'un accusé de réception. Cette solution est beaucoup
    plus efficace, même si elle ajoute un peu de complexité. Il convient de
    noter que les nœuds LN ne doivent gérer des transactions d'engagement
    parallèles que jusqu'à ce qu'une transaction de jonction ait été confirmée
    à un niveau suffisant pour que les deux contreparties la considèrent
    comme sûre. Ensuite, ils peuvent revenir à une transaction
    d'engagement unique.

  - *Quantités relatives et splicing zéro-conf :* Bastien Teinturier
    [a posté][teinturier splice] à propos de plusieurs propositions de mise à jour
    de la spécification. En plus de la modification des signatures d'engagement
    mentionnée ci-dessus, il recommande également que les propositions des
    splicing utilisent des quantités relatives, par exemple "200 000 sats"
    indique qu'Alice veut séparer cette quantité et "-50 000 sats" indique
    qu'elle veut joindre cette quantité. Il mentionne également un
    problème concernant les splicing "zero-conf", mais n'entre pas dans
    les détails.

- **Proposition de BIP pour la terminologie des transactions :** Mark "Murch"
  Erhardt [a posté][erhardt terms] le projet d'un [BIP informatif][terms bip]
  sur la liste de diffusion Bitcoin-Dev qui suggère un vocabulaire à utiliser
  pour se référer aux parties des transactions et aux concepts qui s'y rapportent.
  À l'heure où nous écrivons ces lignes, toutes les réponses à la proposition
  sont favorables à l'effort.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Ne pas télécharger de témoins pour les blocs supposés valides lorsque l'on fonctionne en mode "prune"][review club 27050]
est un PR de Niklas Gögge (dergoegge) qui améliore les performances du
téléchargement de bloc initial (IBD) en ne téléchargeant pas les données
témoins sur les nœuds qui sont configurés à la fois pour [élaguer les données
des blocs][docs pruning] et pour utiliser [assumevalid][docs assume valid].
Cette optimisation a été discutée dans une récente [question sur stack exchange][se117057].

{% include functions/details-list.md
  q0="Si assume-valid est activé mais pas l'élagage, pourquoi le nœud doit-il
  télécharger des données de témoins (non récentes), étant donné que le nœud ne
  vérifiera pas ces données ? Cette PR devrait-elle également désactiver le
  téléchargement des témoins dans ce cas de non-élagage ?"
  a0="Les données témoins sont nécessaires car les pairs peuvent nous
  demander des blocs non récents (nous nous annonçons comme non élagués)."
  a0link="https://bitcoincore.reviews/27050#l-31"

  q1="Quelle quantité de bande passante cette amélioration pourrait-elle
  permettre d'économiser au cours d'un IBD ? En d'autres termes, quelle est
  la taille cumulée de toutes les données témoins jusqu'à un bloc récent
  (par exemple, la hauteur 781213) ?"
  a1="110,6 Go, ce qui représente environ 25 % de l'ensemble des données du bloc.
  Un participant a souligné que 110 Go représentent environ 10 % de la limite
  mensuelle de téléchargement de son fournisseur d'accès, ce qui constitue donc
  une réduction significative. Les participants s'attendent également à ce que
  le pourcentage d'économie augmente avec l'utilisation récemment élargie
  des données témoins."
  a1link="https://bitcoincore.reviews/27050#l-52"

  q2="Cette amélioration permettrait-elle de réduire la quantité de données
  téléchargées de tous les blocs vers le bloc Genesis ?"
  a2="Non, seulement depuis l'activation de segwit (hauteur de bloc 481824);
  les blocs antérieurs à segwit n'ont pas de données de témoins."
  a2link="https://bitcoincore.reviews/27050#l-73"

  q3="Ce PR met en œuvre deux changements principaux, l'un concernant la
  logique de demande de bloc et l'autre la validation des blocs. Quels sont
  ces changements en détail ?"
  a3="Dans la validation, lorsque les vérifications de scripts sont ignorées,
  il faut également ignorer les vérifications des témoins de l'arbre de merkle.
  Dans la logique de demande de bloc, supprimer `MSG_WITNESS_FLAG` des drapeaux
  de récupération afin que nos pairs ne nous envoient pas les données des témoins."
  a3link="https://bitcoincore.reviews/27050#l-83"

  q4="Sans ce PR, la validation des scripts est ignorée sous assume-valid,
  mais les autres contrôles qui impliquent des données témoins ne sont pas
  ignorés. Quelles sont les vérifications que cette PR fera ignorer ?"
  a4="La coinbase de l'arbre de merkle, les tailles des témoins, le nombre
  maximum d'éléments de la liste de témoins, et le poids du bloc."
  a4link="https://bitcoincore.reviews/27050#l-91"

  q5="Le PR n'inclut pas de modification explicite du code permettant d'ignorer
  toutes les vérifications supplémentaires mentionnées dans la question
  précédente. Pourquoi cela fonctionne-t-il ?"
  a5="Il s'avère que toutes les vérifications supplémentaires sont acceptées
  lorsqu'il n'y a pas de témoins.
  C'est logique si l'on considère que segwit était un embranchement convergent.
  Avec le PR, nous faisons essentiellement semblant d'être un nœud pré-segwit
  (jusqu'au point assume-valid)."
  a5link="https://bitcoincore.reviews/27050#l-117"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Libsecp256k1 0.3.1][] est une **version de sécurité** qui corrige un
  problème lié au code qui devrait s'exécuter en temps constant mais qui
  ne l'était pas lorsqu'il était compilé avec Clang version 14 ou supérieure.
  La vulnérabilité peut rendre les applications affectées vulnérables à des
  [attaques par canal latéral][topic side channels]. Les auteurs recommandent
  fortement de mettre à jour les applications concernées.

- [BDK 1.0.0-alpha.0][] est une version de test des principaux changements
  apportés au BDK et décrits dans le [Bulletin #243][news243 bdk]. Les
  développeurs des projets en aval sont encouragés à commencer les tests
  d'intégration.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6012][] met en œuvre plusieurs améliorations significatives
  dans la bibliothèque Python pour écrire des plugins CLN (voir [Bulletin
  #26][news26 pyln-client]) qui lui permettent de mieux fonctionner avec le
  gossip store de CLN. Les changements permettent de construire de
  meilleurs outils d'analyse pour les gossip et faciliteront le
  développement de plugins qui utilisent les données des gossips.

- [Core Lightning #6124][] ajoute la possibilité de blacklister les runes
  avec [commando][commando plugin] et de maintenir une liste de toutes les
  runes, ce qui est utile pour traquer et désactiver celles qui sont compromises.

- [Eclair #2607][] ajoute une nouvelle RPC `listreceivedpayments` qui liste
  tous les paiements reçus par le noeud.

- [LND #7437][] ajoute la prise en charge de la sauvegarde d'un seul canal
  dans un fichier.

- [LND #7069][] permet à un client d'envoyer un message à sa [tour de
  garde][topic watchtowers] pour demander la suppression d'une session.
  Cela permet à la tour de garde d'arrêter de surveiller les transactions
  sur la chaîne qui ferment le canal dans un état révoqué. Cela réduit les
  besoins de stockage et de CPU pour la tour de garde et le client.

- [BIPs #1372][] attribue le [BIP327][] au protocole [MuSig2][topic musig]
  pour la création de [multisignatures][topic multisignature] qui peut être
  utilisé avec [taproot][topic taproot] et d'autres systèmes de [signature
  schnorr][topic schnorr signatures] compatibles avec le [BIP340][]. Comme
  décrit dans le BIP, les avantages comprennent l'agrégation non interactive
  des clés et l'exigence de seulement deux tours de communication pour
  compléter la signature. La signature non interactive est également possible
  avec une configuration supplémentaire entre les participants. Le protocole
  est compatible avec tous les avantages d'un système de signature multiple,
  comme la réduction significative des données sur la chaîne et l'amélioration
  de la confidentialité, à la fois pour les participants et pour les utilisateurs
  du réseau en général.

{% include references.md %}
{% include linkers/issues.md v=2 issues="6012,6124,2607,7437,7069,1372,863" %}
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[news243 bdk]: /fr/newsletters/2023/03/22/#bdk-793
[neigut splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003894.html
[teinturier splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003895.html
[erhardt terms]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021550.html
[terms bip]: https://github.com/Xekyo/bips/pull/1
[news26 pyln-client]: /en/newsletters/2018/12/18/#c-lightning-2161
[news17 splice]: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[news146 splice]: /en/newsletters/2021/04/28/#draft-specification-for-ln-splicing
[libsecp256k1 0.3.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.1
[review club 27050]: https://bitcoincore.reviews/27050
[docs pruning]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.11.0.md#block-file-pruning
[docs assume valid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[se117057]: https://bitcoin.stackexchange.com/questions/117057/why-is-witness-data-downloaded-during-ibd-in-prune-mode
[commando plugin]: /en/newsletters/2022/07/27/#core-lightning-5370
