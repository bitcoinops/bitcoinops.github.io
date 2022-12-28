---
title: 'Bitcoin Optech Newsletter #230'
permalink: /fr/newsletters/2022/12/14/
name: 2022-12-14-newsletter-fr
slug: 2022-12-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine résume une proposition de version
modifiée de LN qui pourrait améliorer la compatibilité avec les
usines à canaux, décrit un logiciel permettant d'atténuer certains
effets des attaques de brouillage de canaux sans modifier le protocole
LN, et propose des liens vers un site Web permettant de suivre les
remplacements de transactions non signalées. Nous avons également
inclus nos sections habituelles avec des annonces de nouveaux logiciels
clients et de services, des résumés des questions et réponses
intéressantes sur le Bitcoin Stack Exchange, et des descriptions
de changements significatifs dans les logiciels d'infrastructure
Bitcoin les plus répandus.

## Nouvelles

- **Proposition d'optimisation du protocole d'usines à canaux LN :**
  John Law a [posté][law factory] sur la liste de diffusion Lightning-Dev
  la description d'un protocole optimisé pour la création d' [usines à canaux][topic channel factories].
  Les usines à canaux permettent à plusieurs utilisateurs d'ouvrir
  en toute confiance plusieurs canaux entre des paires d'utilisateurs
  avec une seule transaction onchain. Par exemple, 20 utilisateurs
  pourraient opérer pour créer une transaction onchain environ 10 fois
  plus grande qu'une ouverture normale à deux parties mais qui ouvrirait
  un total de 190 canaux<!-- n=20 ; n*(n - 1)/2 -->.

    Law note que le protocole de canal LN existant (communément appelé
    pénalité-LN) crée deux problèmes pour les canaux ouverts depuis
    l'intérieur d'une usine :

    - *Les expirations HTLC requises sont longues :* L'absence de confiance
      exige que tout participant à une usine puisse en sortir et reprendre
      le contrôle exclusif de ses fonds sur la chaîne.  Ceci est accompli
      par le participant qui publie l'état actuel des soldes dans l'usine
      onchain.  Cependant, un mécanisme est nécessaire pour empêcher le
      participant de publier un état antérieur, par exemple un état où il
      contrôlait une plus grande quantité d'argent. La proposition originale
      de l'usine accomplit cela en utilisant une ou plusieurs transactions
      verrouillées dans le temps qui garantissent que les états plus récents
      peuvent être confirmés plus rapidement que les états périmés.

        La conséquence de ceci, décrite par Law, est que tout paiement LN ([HTLC][topic htlc])
        qui est acheminé par un canal dans une usine à canaux doit prévoir
        suffisamment de temps pour que le dernier timelock d'état expire afin
        que l'usine puisse être unilatéralement fermée. Pire encore, cela s'applique
        chaque fois qu'un paiement est acheminé par une usine. Par exemple,
        si un paiement est transmis par 10 usines ayant chacune une expiration
        d'un jour, il est possible qu'un paiement soit [brouillé][topic channel jamming attacks]
        par accident ou volontairement pendant 10 jours (ou plus, selon d'autres
        paramètres HTLC).

    - *Tout ou rien :* pour que les usines atteignent vraiment leur meilleure
      efficacité, tous leurs canaux doivent également être fermés de manière
      coopérative dans une seule transaction onchain.  Les fermetures coopératives
      ne sont pas possibles si l'un des participants initiaux ne répond plus---et la
      probabilité qu'un participant ne réponde plus s'approche de 100 % lorsque
      le nombre de participants augmente, ce qui limite le bénéfice maximal que
      les usines peuvent fournir.

        Law cite des travaux antérieurs visant à permettre aux usines de rester
        opérationnelles même si l'un des participants veut partir ou, à l'inverse,
        si l'un des participants ne répond plus, comme les propositions pour
        `OP_TAPLEAF_UPDATE_VERIFY` et `OP_EVICT` (voir la lettre d'information [#166][news166 tluv]
        et [#189][news189 evict]).

    Trois propositions de protocoles sont présentées par Law pour répondre à ces
    préoccupations. Tous découlent d'une proposition précédente de Law [posted][law tp]
    en octobre pour des *pénalités ajustables*---la capacité de séparer la gestion
    du mécanisme d'exécution (des pénalités) de la gestion d'autres fonds. Cette
    précédente proposition  n'a pas encore été discutée sur la liste de diffusion
    Lightning-Dev. Au moment où nous écrivons ces lignes, la nouvelle proposition
    de Law n'a pas non plus fait l'objet de discussions. Si ces propositions sont
    valables, elles auraient l'avantage, par rapport à d'autres propositions, de
    ne nécessiter aucune modification des règles de consensus de Bitcoin.

- **Brouillage local pour éviter le brouillage à distance :** Joost Jager a
  [posté][jager jam] sur la liste de diffusion Lightning-Dev un lien et une
  explication pour son projet, [CircuitBreaker][]. Ce programme, conçu pour
  être compatible avec LND, impose des limites au nombre de paiements en attente
  ([HTLCs][topic htlc]) que le nœud local transmettra pour le compte de chacun
  de ses pairs. Par exemple, considérons le pire cas d'attaque par brouillage HTLC :

    ![Illustration de deux attaques par brouillage différentes](/img/posts/2020-12-ln-jamming-attacks.png)

    Avec l'actuel protocole LN, Alice est fondamentalement limitée à la transmission
    simultanée d'un maximum de [483 HTLC en attente][]. Si, au lieu de cela, elle
    utilise CircuitBreaker pour limiter son canal avec Mallory à 10 transferts
    simultanés de HTLC en attente, son canal en aval avec Bob (non visualisé) et
    tous les autres canaux de ce circuit seront protégés de tous les HTLC sauf
    les 10 premiers que Mallory garde en attente. Cela peut réduire considérablement
    l'efficacité de l'attaque de Mallory en l'obligeant à ouvrir beaucoup plus
    de canaux pour bloquer le même nombre d'emplacements HTLC, ce qui peut augmenter
    le coût de l'attaque en l'obligeant à payer plus de frais onchain.

    Bien que CircuitBreaker ait été implémenté à l'origine pour refuser tout HTLC dans
    un canal qui dépassait sa limite, Jager note qu'il a récemment implémenté un mode
    supplémentaire optionnel qui place tous les HTLC dans une file d'attente au lieu de
    les refuser ou de les transférer immédiatement.  Lorsque le nombre de HTLC en attente
    dans un canal tombe en dessous de la limite du canal, CircuitBreaker transmet le HTLC
    le plus ancien et non expiré de la file d'attente.  Jager décrit deux avantages de
    cette approche :

    - *Contre-pression :* si un nœud au milieu d'un circuit refuse un HTLC,
      tous les nœuds du circuit (pas seulement ceux qui se trouvent plus bas
      dans le circuit) peuvent utiliser l'emplacement et les fonds de ce HTLC
      pour transmettre d'autres paiements.  Cela signifie qu'Alice a peu
      d'intérêt à refuser plus de 10 HTLC de Mallory - elle peut simplement
      espérer qu'un nœud ultérieur du circuit exécutera CircuitBreaker ou un
      logiciel équivalent.

        Cependant, si un nœud ultérieur (disons Bob) utilise CircuitBreaker
        pour mettre en file d'attente les HTLC excédentaires, alors Alice
        pourrait toujours voir ses créneaux HTLC ou ses fonds drainés par
        Mallory, même si Bob et les nœuds ultérieurs du circuit conservent
        les mêmes avantages que maintenant (à l'exception d'une augmentation
        possible des coûts de fermeture du canal pour Bob dans certains cas;
        voir le courriel de Jager ou la documentation de CircuitBreaker pour
        plus de détails). Cela pousse doucement Alice à utiliser CircuitBreaker
        ou quelque chose de similaire.

    - *Attribution des défaillances :* le protocole LN actuel permet (dans de nombreux cas)
      à un opérateur d'identifier le canal qui a refusé de transmettre un HTLC.
      Certains logiciels d'envoi essaient d'éviter d'utiliser ces canaux dans les
      futurs HTLC pendant un certain temps. Dans le cas du refus des HTLC
      d'acteurs malveillants comme Mallory, cela n'a évidemment pas d'importance,
      mais si un nœud exécutant CircuitBreaker refuse les HTLC de payeurs
      honnêtes, cela peut non seulement réduire ses revenus provenant de ces
      HTLC refusés, mais aussi les revenus qu'il aurait reçus des tentatives
      de paiement ultérieures.

        Cependant, le protocole LN ne dispose pas actuellement d'un moyen
        largement déployé pour déterminer quel canal a retardé un HTLC, il
        est donc moins conséquent à cet égard de retarder l'envoi d'un HTLC
        que de refuser purement et simplement de l'envoyer. Jager note que
        cette situation est en train de changer en raison des nombreuses
        implémentations LN qui travaillent à la prise en charge de messages
        d'erreur plus détaillés sur le routage en oignon (voir le [bulletin
        d'information #224][news224 fat]), cet avantage pourrait donc
        disparaître un jour.

    Pour Jager, CircuitBreaker est "un moyen simple mais imparfait de lutter contre
    le brouillage des canaux et le pollupostage". Les travaux se poursuivent pour
    trouver et déployer un changement au niveau du protocole qui atténuera de
    manière plus complète les préoccupations relatives aux attaques par brouillage,
    mais CircuitBreaker se distingue comme une solution apparemment raisonnable,
    compatible avec le protocole LN actuel et que tout utilisateur de LND peut
    déployer immédiatement sur son nœud de transmission. CircuitBreaker est sous
    licence MIT et conceptuellement simple, il devrait donc être possible de
    l'adapter ou de le porter pour d'autres implémentations LN.

- **Suivi des remplacements par full-RBF :** Le développeur 0xB10C a [posté][0xb10c rbf]
  sur la liste de diffusion Bitcoin-Dev qu'il a commencé à fournir un suivi [accessible au public][rbf mpo]
  des placements de transactions dans le mempool de son nœud Bitcoin Core qui ne contiennent
  pas le signal BIP125. Leur nœud permet le remplacement complet des RBF en utilisant
  l'option de configuration `mempoolfullrbf` (voir [le bulletin d'information #208][news208 rbf]).

    Les utilisateurs et les services peuvent utiliser le site Web comme un indicateur
    pour savoir quels grands pools miniers pourraient actuellement confirmer des
    transactions de remplacement non signées (si certains le font).  Cependant, nous
    rappelons aux lecteurs que les paiements reçus dans le cadre de transactions
    non confirmées ne peuvent être garantis, même si les mineurs ne semblent pas
    actuellement exploiter des remplacements non signalés.

## Changements principaux dans le code et la documentation

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour intéressantes
des portefeuilles et services Bitcoin.*

- **Lily Wallet ajoute une sélection de pièces :**
  Lily Wallet [v1.2.0][lily v1.2.0] ajoute une fonctionnalités [de sélection de pièces][topic coin selection].

- **Le logiciel Vortex crée des canaux LN à partir des transactions collaboratives :**
  Grâce aux transactions [taproot][topic taproot] et aux transactions collaboratives [coinjoin][topic coinjoin],
  les utilisateurs ont [ouvert des canaux LN][vortex tweet] sur le réseau principal Bitcoin
  en utilisant le logiciel [Vortex][vortex github].

- **Mutiny intègre un nœud LN dans un navigateur de démonstration :**
  À l'aide de WASM et de LDK, les développeurs ont fait la [démonstration][mutiny tweet]
  d'une mise en œuvre d'une [preuve de concept][mutiny github] d'un nœud LN fonctionnant
  dans le navigateur d'un téléphone mobile.

- **Coinkite lance BinaryWatch.org:**
  Le site Web [BinaryWatch.org][] vérifie les binaires des projets liés à Bitcoin et
  surveille tout changement. La société gère également [bitcoinbinary.org][] un
  service qui archive les [builds reproductibles][topic reproducible builds] des
  projets liés à Bitcoin.

## Selection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les
collaborateurs d'Optech cherchent des réponses à leurs questions---ou lorsqu'ils
ont quelques moments libres, aident les utilisateurs curieux ou perdus.
Dans cette rubrique mensuelle, nous mettons en évidence certaines des questions
et réponses les plus populaires depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi la connexion au réseau Bitcoin exclusivement par Tor est-elle considérée comme une mauvaise pratique ?]({{bse}}116146)
  Plusieurs réponses expliquent qu'en raison du coût moins élevé de la génération d'un grand nombre
  d'adresses Tor par rapport aux adresses IPv4 et IPv6, un opérateur de nœuds Bitcoin utilisant
  exclusivement le réseau Tor pourrait plus facilement être [attaqué par éclipse][topic eclipse attacks] par rapport
  à un opérateur utilisant uniquement le réseau clair ou une combinaison de [réseaux d'anonymat][topic anonymity networks].

- [Pourquoi n'est-il pas possible, de manière réaliste, d'avoir trois canaux (ou plus) dans Lightning aujourd'hui ?]({{bse}}116257)
  Murch explique que puisque les canaux LN utilisent actuellement le mécanisme de pénalité LN qui
  alloue *tous* les fonds du canal à une seule contrepartie en cas de violation, étendre la
  pénalité LN pour gérer plusieurs destinataires d'une transaction de justice pourrait être trop
  compliqué et impliquer des frais généraux excessifs à mettre en œuvre. Il explique ensuite le
  mécanisme [eltoo] [topic eltoo] et comment il pourrait gérer les canaux multipartites.

- [Avec la dépréciation des anciens portefeuilles, Bitcoin Core sera-t-il capable de signer des messages pour une adresse ?]({{bse}}116187)
  Pieter Wuille fait la distinction entre la [dépréciation des anciens portefeuilles][news125 legacy descriptor wallets]
  de Bitcoin Core et le maintien du support des anciens types d'adresses comme les adresses P2PKH,
  même dans les nouveaux [descripteurs][topic descriptors] de portefeuilles. Bien que la signature
  des messages ne soit actuellement possible que pour les adresses P2PKH, les efforts autour de
  [BIP322][topic generic signmessage] pourraient permettre la signature des messages pour d'autres
  types d'adresses.

- [Comment mettre en place un multisigging à décélération temporelle ?]({{bse}}116035)
  L'utilisateur Yoda demande comment configurer un multisig qui se désintègre dans le temps,
  un UTXO qui peut être dépensé avec un ensemble de pubkeys de plus en plus large au fil du temps.
  Michael Folkson fournit un exemple utilisant [policy][news74 policy miniscript] et [miniscript][topic miniscript],
  des liens vers des ressources connexes, et note le manque d'options conviviales actuellement.

- [Quand une solution miniscript est-elle malléable ?]({{bse}}116275)
  Antoine Poinsot définit ce que signifie la malléabilité dans le contexte de miniscript,
  décrit l'analyse statique de la malléabilité dans miniscript, et parcourt l'exemple de
  malléabilité de la question originale.

## Mises à jour et version candidate

*Nouvelles versions et versions candidates pour les principaux projets d'infrastructure Bitcoin.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les versions candidates.*

- [Bitcoin Core 24.0.1][] est une version majeure du logiciel de nœud complet le plus largement utilisé.
  Ses nouvelles fonctionnalités comprennent une option pour configurer la politique [Replace-By-Fee][topic rbf]
  (RBF) du noeud, un nouveau RPC `sendall` pour dépenser facilement tous les fonds d'un portefeuille en
  une seule transaction (ou pour créer des transactions sans sortie de changement), un RPC `simulaterawtransaction`
  qui peut être utilisé pour vérifier comment une transaction affectera un portefeuille (par ex, pour
  s'assurer qu'une transaction coinjoin ne diminue la valeur d'un porte-monnaie que par des frais),
  la possibilité de créer des [descripteurs][topic descriptors] de veille uniquement contenant des
  expressions [miniscript][topic miniscript] pour améliorer la compatibilité avec d'autres logiciels,
  et l'application automatique de certains changements de paramètres effectués dans l'interface graphique
  aux actions basées sur les RPC. Voir les [notes de version][bcc rn] pour la liste complète des nouvelles
  fonctionnalités et des corrections de bogues.

    Note : une version 24.0 a été marquée et ses binaires ont été publiés,
    mais les mainteneurs du projet ne l'ont jamais annoncée et ont plutôt
    travaillé avec d'autres contributeurs pour résoudre [quelques problèmes
    de dernière minute][bcc milestone 24.0.1], faisant de cette version 24.0.1
    la première version annoncée de la branche 24.x.

- [libsecp256k1 0.2.0][] est la première version balisée de cette bibliothèque
  largement utilisée pour les opérations cryptographiques liées à Bitcoin. Une
  [annonce][libsecp256k1 announce] de la version indique que "pendant longtemps,
  le développement de libsecp256k1 n'avait qu'une branche principale, ce qui créait
  un flou sur la compatibilité et la stabilité de l'API. À l'avenir, nous créerons
  des versions marquées lorsque des améliorations pertinentes seront fusionnées,
  en suivant un schéma de version sémantique. [...] Nous sautons la version 0.1.0
  car ce numéro de version a été défini dans nos scripts de construction autotools
  pendant des années, et n'identifie pas de manière unique un ensemble de fichiers
  source. Nous ne créerons pas de versions binaires, mais nous tiendrons compte des
  problèmes de compatibilité ABI attendus pour les notes de version et le versionnage."

- [Core Lightning 22.11.1][] est une version mineure qui réintroduit temporairement
  certaines fonctionnalités qui ont été dépréciées dans la version 22.11, à la demande
  de certains développeurs en aval.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25934][] ajoute un argument facultatif `label` à la RPC
  `listsinceblock`. Seules les transactions correspondant à l'étiquette
  seront retournées lorsqu'une étiquette est spécifiée.

- [LND #7159][] met à jour les RPCs `ListInvoiceRequest` et `ListPaymentsRequest`
  avec les nouveaux champs `creation_date_start` et `creation_date_end` qui
  peuvent être utilisés pour filtrer les factures et les paiements avant ou
  après la date et l'heure indiquées.

- [LDK #1835][] ajoute un faux espace de noms Short Channel IDentifier (SCID) pour
  les HTLC interceptés, permettant aux fournisseurs de services Lightning (LSP) de
  créer un canal [just-in-time][topic jit routing] (JIT) pour que les utilisateurs
  finaux reçoivent un paiement éclair. Pour ce faire, de fausses indications d'itinéraire
  sont incluses dans les factures des utilisateurs finaux, signalant à LDK qu'il
  s'agit d'un transfert intercepté, similaire aux [paiements fantômes][LDK phantom payments]
  (voir [Bulletin d'information n°188][news188 phantom]). LDK génère alors un événement,
  donnant au LSP la possibilité d'ouvrir le canal JIT. Le LSP peut alors transmettre
  le paiement sur le canal nouvellement ouvert ou l'échouer.

- [BOLTs #1021][] permet aux messages d'erreur de routage en oignon de contenir un flux [TLV][],
  qui pourra être utilisé à l'avenir pour inclure des informations supplémentaires sur l'échec.
  Il s'agit d'une première étape vers la mise en œuvre de [fat errors][news224 fat] comme
  proposé dans [BOLTs #1044][].

## Bonnes vacances!

Ceci est le dernier bulletin régulier de Bitcoin Optech de l'année. Le mercredi 21 décembre,
nous publierons notre cinquième bulletin annuel de bilan de l'année. La publication régulière
reprendra le mercredi 4 janvier.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25934,7159,1835,1021,1044" %}
[bitcoin core 24.0.1]: https://bitcoincore.org/bin/bitcoin-core-24.0.1/
[bcc rn]: https://bitcoincore.org/en/releases/24.0.1/
[bcc milestone 24.0.1]: https://github.com/bitcoin/bitcoin/milestone/59?closed=1
[libsecp256k1 0.2.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.2.0
[libsecp256k1 announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021271.html
[core lightning 22.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v22.11.1
[news224 fat]: /fr/newsletters/2022/11/02/#attribution-de-l'échec-du-routage-ln
[law factory]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003782.html
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[news189 evict]: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership
[law tp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[jager jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003781.html
[circuitbreaker]: https://github.com/lightningequipment/circuitbreaker
[0xb10c rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021258.html
[rbf mpo]: https://fullrbf.mempool.observer/
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[tlv]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[483 HTLC en attente]: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md#rationale-7
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[LDK phantom payments]: https://lightningdevkit.org/blog/introducing-phantom-node-payments/
[news125 legacy descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news74 policy miniscript]: /en/newsletters/2019/11/27/#what-is-the-difference-between-bitcoin-policy-language-and-miniscript
[lily v1.2.0]: https://github.com/Lily-Technologies/lily-wallet/releases/tag/v1.2.0
[vortex tweet]: https://twitter.com/benthecarman/status/1590886577940889600
[vortex github]: https://github.com/ln-vortex/ln-vortex
[mutiny tweet]: https://twitter.com/benthecarman/status/1595395624010190850
[mutiny github]: https://github.com/BitcoinDevShop/mutiny-web-poc
[BinaryWatch.org]: https://binarywatch.org/
[bitcoinbinary.org]: https://bitcoinbinary.org/
