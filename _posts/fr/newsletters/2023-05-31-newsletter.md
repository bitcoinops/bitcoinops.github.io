---
title: 'Bulletin Hebdomadaire Bitcoin Optech #253'
permalink: /fr/newsletters/2023/05/31/
name: 2023-05-31-newsletter-fr
slug: 2023-05-31-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin d'information de cette semaine décrit une proposition pour un nouveau protocole
de gestion de joinpool et résume une idée pour relayer les transactions en utilisant le protocole Nostr.
Vous y trouverez également une autre partie de notre série hebdomadaire limitée sur la politique mempool,
ainsi que nos sections régulières résumant les principales questions et réponses postées sur le Bitcoin Stack Exchange,
listant les nouvelles versions de logiciels et les versions candidates,
et décrivant les changements notables apportés aux principaux logiciels de l'infrastructure Bitcoin.

## Nouvelles

- **Proposition d'un protocole de gestion des joinpool :** Cette semaine,
  Burak Keceli a [posté][keceli ark] sur la liste de diffusion Bitcoin-Dev une idée pour _Ark_,
  un nouveau protocole de type [joinpool][topic joinpools] où les propriétaires de bitcoins
  choisissent d'utiliser une contrepartie comme cosignataire pour toutes les transactions
  pendant une certaine période de temps. Les propriétaires peuvent soit retirer unilatéralement
  leurs bitcoins sur la chaîne après l'expiration du délai, soit les transférer instantanément
  et en toute confiance hors de la chaîne à la contrepartie avant l'expiration du délai.

    Comme tout utilisateur de Bitcoin, la contrepartie peut diffuser à tout moment une transaction
    onchain qui ne dépense que ses propres fonds. Si une sortie de cette transaction est utilisée
    comme entrée dans la transaction offchain qui transfère des fonds du propriétaire à la contrepartie,
    le transfert offchain devient invalide à moins que la transaction onchain ne soit confirmée dans
    un délai raisonnable. Dans ce cas, la contrepartie ne signera pas sa transaction onchain tant
    qu'elle n'aura pas reçu la transaction offchain signée. Il s'agit d'un protocole de transfert
    atomique sans confiance, à un seul saut et dans une seule direction, entre le propriétaire et
    la contrepartie. Keceli décrit trois utilisations de ce protocole de transfert atomique :

    - *Mélange de pièces :* plusieurs utilisateurs du joinpool peuvent tous, avec la coopération
      de la contrepartie, procéder à des échanges atomiques de leurs valeurs offchain actuelles
      contre un montant équivalent de nouvelles valeurs offchain. Cette opération peut être réalisée
      rapidement, car une défaillance de la composante onchain annulera simplement l'échange, ce qui
      ramènera tous les fonds à leur point de départ. Un protocole d'aveuglement similaire à ceux
      utilisés par certaines implémentations existantes de [coinjoin][topic coinjoin] peut empêcher
      tout utilisateur ou la contrepartie de déterminer quel utilisateur s'est retrouvé avec quels bitcoins.

    - *Effectuer des transferts internes :* un utilisateur peut transférer ses fonds hors chaîne
      à un autre utilisateur avec la même contrepartie. L'atomicité garantit que le destinataire
      recevra son argent ou que le prêteur sera remboursé. Un destinataire qui ne fait pas confiance
      à l'émetteur et à la contrepartie devra attendre autant de confirmations qu'il le ferait pour
      une transaction onchain normale.

        Keceli et un commentateur [link][keceli reply0] à une recherche [précédente][harding reply0]
        décrivant comment un paiement zéro-conf peut être rendu non profitable à la double dépense en
        l'associant à une liaison de fidélité qui peut être réclamée par tout mineur qui a observé
        les deux versions de la transaction doublement dépensée. Cela pourrait permettre aux destinataires
        d'accepter un paiement en quelques secondes même s'ils n'ont pas confiance dans les autres
        parties individuelles.

    - *Paiement des factures LN :* un utilisateur peut rapidement s'engager à verser ses fonds hors
      chaîne à la contrepartie si cette dernière connaît un secret, ce qui permet à l'utilisateur de
      payer des factures de type LN [HTLC][topic HTLC] par l'intermédiaire de la contrepartie.

        Comme dans le cas des virements internes, un utilisateur ne peut pas recevoir des fonds en
        toute confiance. Il ne doit donc pas révéler un secret avant qu'un paiement ait reçu un nombre
        suffisant de confirmations ou qu'il soit garanti par une clause de fidélité qu'il juge convaincante.

    M. Keceli affirme que le protocole de base peut être mis en œuvre sur Bitcoin aujourd'hui en utilisant
    une interaction fréquente entre les membres du groupe. Si une proposition de [covenant][topic covenants]
    comme [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify], [SIGHASH_ANYPREVOUT][topic sighash_anyprevout],
    ou [OP_CAT + OP_CHEKSIGFROMSTACK][topic op_checksigfromstack] est mise en œuvre, les membres du joinpool
    n'auront besoin d'interagir avec la contrepartie que lorsqu'ils participeront à un coinjoin, qu'ils
    effectueront un paiement, ou qu'ils se rendront à une réunion de l'équipe, les membres du joinpool
    n'auront besoin d'interagir avec la contrepartie que lorsqu'ils participeront à un coinjoin, effectueront
    un paiement, ou rafraîchiront le timelock sur leurs fonds offchain.

    Chaque coinjoin, paiement ou rafraîchissement nécessite la publication d'un engagement dans une transaction
    onchain, bien qu'un nombre pratiquement illimité d'opérations puisse être regroupé dans la même petite transaction.
    Pour permettre aux opérations de se terminer rapidement, Keceli suggère qu'une transaction onchain soit effectuée
    toutes les cinq secondes environ, afin que les utilisateurs n'aient pas à attendre plus longtemps. Chaque transaction
    est séparée---il n'est pas possible de combiner les engagements de plusieurs transactions en utilisant
    [replace-by-fee][topic rbf] sans rompre les engagements ou exiger la participation de tous les utilisateurs
    impliqués dans les tours précédents---de sorte que plus de 6,3 millions de transactions pourraient devoir être
    confirmées chaque année pour une contrepartie, bien que les transactions individuelles soient relativement petites.

    Les commentaires sur le protocole envoyés à la liste de diffusion sont les suivants :

    - *Une demande de documentation supplémentaire :* au [moins][stone reply] deux [répondants][dryja reply]
      ont demandé une documentation supplémentaire sur le fonctionnement du système, estimant qu'il était difficile
      de l'analyser à partir de la description de haut niveau fournie à la liste de diffusion. Keceli a depuis
      commencé à publier des [projets de spécifications][arc specs].

    - *Inquiétude quant à la lenteur de la réception par rapport au LN :* [Plusieurs personnes][dryja reply]
      ont [noté][harding reply1] que, dans la conception initiale, il n'est pas possible de recevoir en toute
      confiance un paiement du joinpool (que ce soit offchain ou onchain) sans attendre un nombre suffisant de
      confirmations. Cela peut prendre des heures, alors que de nombreux paiements LN s'effectuent actuellement
      en moins d'une seconde. Même avec des bons de fidélité, le LN serait plus rapide en moyenne.

    - *Inquiétude quant à l'importance de l'empreinte onchain :* Une [réponse][jk_14] a noté qu'à raison d'une
      transaction toutes les cinq secondes, environ 200 contreparties de ce type consommeraient la totalité de
      l'espace de chaque bloc. Une autre [réponse][harding reply0] a supposé que chacune des transactions onchain
      de la contrepartie sera à peu près de la taille d'une transaction d'ouverture ou de fermeture coopérative
      de canal LN, de sorte qu'une contrepartie avec un million d'utilisateurs qui crée 6,3 millions de transactions
      onchain par an utiliserait une quantité d'espace équivalente à chacun de ces utilisateurs ouvrant ou fermant
      en moyenne 6,3 canaux chacun par an ; ainsi, les coûts onchain de LN pourraient être inférieurs à l'utilisation
      de la contrepartie jusqu'à ce qu'elle ait atteint une échelle massive.

    - *Inquiétude au sujet d'un grand hot wallet et des coûts d'investissement :* Une [réponse][harding reply0]
      a estimé que la contrepartie devrait conserver un montant de bitcoins (probablement dans un "hot wallet")
      égal au montant que les utilisateurs pourraient dépenser dans un avenir proche. Après une dépense, la contrepartie
      ne recevrait pas ses bitcoins pendant une période pouvant aller jusqu'à 28 jours selon la proposition de conception
      actuelle. Si la contrepartie appliquait un taux d'intérêt faible de 1,5 % par an à son capital, cela équivaudrait
      à une charge de 0,125 % sur le montant de chaque transaction effectuée avec la participation de la contrepartie
      (y compris les coinjoins, les transferts internes et les paiements LN). À titre de comparaison, les
      [statistiques publiques][1ml stats] disponibles au moment de la rédaction (collectées par 1ML) indiquent un taux
      médian par saut pour les transferts LN de 0,0026 %, soit près de 50 fois moins.

    Plusieurs commentaires sur la liste étaient également enthousiastes quant à la proposition et attendaient avec impatience
    de voir Keceli et d'autres explorer l'espace de conception des "managed joinpools".

- **Relais de transaction sur Nostr :** Joost Jager a [posté][jager nostr] sur la liste de diffusion Bitcoin-Dev pour
  demander des commentaires sur l'idée de Ben Carman d'utiliser le protocole [Nostr][] pour relayer les transactions
  qui pourraient ne pas bien se propager sur le réseau P2P des nœuds complets Bitcoin qui fournissent des services de relais.

    En particulier, Jager examine la possibilité d'utiliser Nostr pour le relais des paquets de transactions, comme le relais
    d'une transaction ancestrale avec un taux inférieur à la valeur minimale acceptée en l'associant à un descendant qui paie
    des frais suffisamment élevés pour compenser la déficience de son ancêtre. Cela rend la substitution de frais
    [CPFP][topic cpfp] plus fiable et plus efficace, et c'est une fonctionnalité appelée [package relay][topic package relay]
    que les développeurs de Bitcoin Core ont travaillé à mettre en œuvre pour le réseau P2P de Bitcoin. L'un des défis de
    l'examen de la conception et de la mise en œuvre du relais de paquet est de s'assurer que les nouvelles méthodes de
    relais ne créent pas de nouvelles vulnérabilités de déni de service (DoS) contre des nœuds et des mineurs individuels
    (ou le réseau en général).

    Jager note que les relais Nostr ont la possibilité d'utiliser facilement d'autres types de protection contre les dénis
    de service à partir du réseau de relais P2P, par exemple en exigeant un petit paiement pour relayer une transaction.
    Selon lui, cela peut permettre de relayer des paquets ou d'autres transactions alternatives, même si une transaction
    ou un paquet malveillant peut entraîner le gaspillage d'une petite quantité de ressources du nœud.

    Le message de M. Jager contenait un lien vers une [vidéo][jager video] où il faisait une démonstration de la fonction.
    À l'heure où nous écrivons ces lignes, son message n'a reçu que quelques réponses, toutes positives.

## Attente de la confirmation #3 : Enchères pour l'achat d'un bloc d'espace

_Une [série][policy series] hebdomadaire limitée sur le relais de transaction, l'inclusion dans le mempool et la sélection
des transactions minières---y compris pourquoi Bitcoin Core a une politique plus restrictive que celle permise par le
consensus et comment les portefeuilles peuvent utiliser cette politique de la manière la plus efficace._

{% include specials/policy/en/03-bidding-for-block-space.md %}

## Selection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits
où les collaborateurs d'Optech cherchent des réponses à leurs questions---ou,
lorsqu'ils ont quelques moments libres, aident les utilisateurs
curieux ou confus. Dans cette rubrique mensuelle, nous mettons en avant
certaines des questions et réponses les plus populaires depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Tester la logique d'élagage avec bitcoind]({{bse}}118159)
  Lightlike signale l'option de configuration `-fastprune`, réservée au débogage, qui utilise des fichiers de blocs plus
  petits et une hauteur d'élagage minimale plus petite à des fins de test.

- [Quelle est la raison d'être de la limite de taille des descendants ?]({{bse}}118160)
  Sdaftuar explique qu'étant donné que les algorithmes d'extraction et d'éviction (voir [Newsletter #252][news252 incentives])
  prennent un temps quadratique, O(n²) en fonction du nombre d'ancêtres ou de descendants, des [limites politiques
  conservatrices][morcos limits] ont été mises en place.

- [Quelle est la contribution au réseau Bitcoin lorsque je fais fonctionner un nœud avec un mempool plus grand que celui par défaut ?]({{bse}}118137)
  Andrew Chow et Murch notent les inconvénients potentiels d'un pool de mémoire plus grand que la valeur par défaut,
  notamment la propagation de la rediffusion des transactions et la propagation du remplacement des transactions sans
  signalisation.

- [Quel est le nombre maximum d'entrées/sorties qu'une transaction peut avoir ?]({{bse}}118452)
  Murch fournit des chiffres d'entrée et de sortie de l'activation post-taproot montrant un maximum de 3223 (P2WPKH)
  en sortie ou un maximum de 1738 (P2TR keypath) en entrée.

- [Peut-on récupérer 2 des 3 fonds multisig sans l'un des xpubs ?]({{bse}}118201)
  Murch explique pour que les configurations multisig qui n'utilisent pas le multisig vide, à moins que le même script de sortie
  multisig n'ait été utilisé précédemment, toutes les clés publiques sont nécessaires pour pouvoir dépenser. Il indique qu'"une
  stratégie de sauvegarde pour un portefeuille multisig doit à la fois préserver les clés privées et les scripts de condition des
  sorties" et recommande les [descripteurs][topic descriptors] comme méthode de sauvegarde des scripts de condition.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Bitcoin Core 25.0][] est une version pour la prochaine version majeure de Bitcoin Core.  Cette version ajoute une nouvelle RPC
`scanblocks`, simplifie l'utilisation de `bitcoin-cli`, ajoute le support [miniscript][topic miniscript] à la RPC `finalizepsbt`,
réduit l'utilisation de la mémoire par défaut avec l'option de configuration `blocksonly`, et accélère les rescans de portefeuilles
lorsque les [filtres de blocs compacts][topic compact block filters] sont activés---parmi beaucoup d'autres nouvelles
fonctionnalités, améliorations de performance, et corrections de bugs. Voir les [notes de version][bcc rn] pour plus de détails.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27469][] accélère le téléchargement du bloc initial (IBD) lorsqu'un ou plusieurs portefeuilles sont utilisés.
  Avec ce changement, un bloc ne sera analysé pour les transactions correspondant à un portefeuille particulier que s'il a été miné
  après la date de naissance du portefeuille, c'est-à-dire la date enregistrée dans le portefeuille comme étant celle de sa création.

- [Bitcoin Core #27626][] permet à un pair qui a demandé à notre nœud de fournir un [relais de bloc compact][topic compact block
  relay] en mode large bande passante de faire jusqu'à trois demandes de transactions à partir du dernier bloc que nous lui avons
  annoncé. Notre nœud répondra à la demande même si nous ne lui avons pas fourni de bloc compact au départ. Cela permet à un pair
  qui reçoit un bloc compact de l'un de ses autres pairs de nous demander les transactions manquantes, ce qui peut s'avérer utile si cet autre pair ne répond plus. Cela peut aider notre pair à valider le bloc plus rapidement, ce qui peut également l'aider à
  l'utiliser plus tôt dans des fonctions critiques, telles que l'exploitation minière.

- [Bitcoin Core #25796][] ajoute un nouveau `descriptorprocesspsbt` qui peut être utilisé pour mettre à jour un [PSBT][topic psbt]
  avec des informations qui l'aideront plus tard à être signé ou finalisé. Un [descripteur][topic descriptors] fourni à la RPC sera
  utilisé pour récupérer les informations du mempool et de l'ensemble UTXO (et, si disponible, les transactions complètes confirmées
  lorsque le noeud a été démarré avec l'option de configuration `txindex`). Les informations récupérées seront ensuite utilisées
  pour remplir le PSBT.

- [Eclair #2668][] empêche Eclair d'essayer de payer plus de frais pour réclamer un [HTLC][topic htlc] sur la chaîne que la valeur
  qu'il recevra en résolvant avec succès ce HTLC.

- [Eclair #2666][] permet à un pair distant recevant un [HTLC][topic htlc] de l'accepter même si les frais de transaction
  qui devraient être payés pour l'accepter réduisent le solde du pair en dessous de la réserve minimale du canal. La réserve
  de canal existe pour garantir qu'un pair perdra au moins une petite somme d'argent s'il tente de fermer un canal dans un état
  obsolète, ce qui le décourage de tenter un vol. Cependant, si l'homologue distant accepte un HTLC qui le paiera en cas de
  succès, il aura de toute façon plus en jeu que la réserve. En cas d'échec, son solde reviendra au montant précédent,
  qui aura été supérieur à la réserve.

    Il s'agit d'une mesure d'atténuation d'un *problème de fonds bloqués*, qui se produit lorsqu'un paiement oblige la partie
    responsable du paiement des frais à payer une valeur supérieure à son solde disponible actuel, même s'il s'agit de la partie
    qui reçoit le paiement. Pour une discussion précédente sur ce problème, voir [Newsletter #85][news85 stuck funds].

- [BTCPay Server 97e7e][] commence à définir le paramètre [BIP78][] `minfeerate` (" taux de frais minimum ") pour les paiements
  [payjoin][topic payjoin]. Voir aussi le [rapport de bug][btcpay server #4689] qui a conduit à ce commit.

- [BIPs #1446][] apporte une petite modification et un certain nombre d'ajouts à la spécification [BIP340][] des
  [signatures schnorr][topic schnorr signatures] pour les protocoles liés à Bitcoin. Le changement consiste à permettre au message
  à signer d'être d'une longueur arbitraire ; les versions précédentes du BIP exigeaient que le message soit exactement de
  32 octets. Voir une modification connexe de la bibliothèque Libsecp256k1 décrite dans le [Bulletin n°157][news157 libsecp].
  Cette modification n'a aucun effet sur l'utilisation de BIP340 dans les applications de consensus, car les signatures utilisées
  avec [taproot][topic taproot] et [tapscript][topic tapscript] (respectivement, BIPs [341][bip341] et [342][bip342]) utilisent des
  messages de 32 octets.

    Les ajouts décrivent comment utiliser efficacement des messages de longueur arbitraire, recommandent l'utilisation d'un préfixe
    de balise haché et fournissent des recommandations pour accroître la sécurité lors de l'utilisation de la même clé dans
    différents domaines (tels que la signature de transactions ou la signature de messages en texte clair).

{% include references.md %}
{% include linkers/issues.md v=2 issues="27469,27626,25796,2668,2666,4689,1446" %}
[policy series]: /fr/blog/attente-de-la-confirmation/
[bitcoin core 25.0]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[1ml stats]: https://1ml.com/statistics
[arc specs]: https://github.com/ark-network/specs
[keceli ark]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021694.html
[keceli reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021720.html
[harding reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021721.html
[harding reply1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021714.html
[stone reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021708.html
[dryja reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021713.html
[jk_14]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021717.html
[jager nostr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021700.html
[jager video]: https://twitter.com/joostjgr/status/1658487013237211155
[news85 stuck funds]: /en/newsletters/2020/02/19/#c-lightning-3500
[btcpay server 97e7e]: https://github.com/btcpayserver/btcpayserver/commit/97e7e60ceae2b73d63054ee38ea54ed265cc5b8e
[news157 libsecp]: /en/newsletters/2021/07/14/#libsecp256k1-844
[bcc rn]: https://bitcoincore.org/en/releases/25.0/
[news252 incentives]: /fr/newsletters/2023/05/24/#en-attente-de-confirmation-2--mesures-dincitation
[morcos limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-October/011401.html
