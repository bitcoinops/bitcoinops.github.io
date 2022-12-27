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

- [Why is connecting to the Bitcoin network exclusively over Tor considered a bad practice?]({{bse}}116146)
  Several answers explain that due to the lower cost of being able to generate many
  Tor addresses as compared to IPv4 and IPv6 addresses, a Bitcoin node operator
  exclusively using the Tor network could more easily be [eclipse attacked][topic eclipse
  attacks] when compared to operating only on clearnet or with a
  combination of [anonymity networks][topic anonymity networks].

- [Why aren't 3 party (or more) channels realistically possible in Lightning today?]({{bse}}116257)
  Murch explains that since LN channels currently use the LN penalty mechanism
  that allocates *all* channel funds to a single counterparty in the event of a
  breach, extending LN penalty to handle multiple recipients of a justice
  transaction may be overly complicated and involve excessive overhead to
  implement. He then explains [eltoo's][topic eltoo] mechanism and how it might
  handle multiparty channels.

- [With legacy wallets deprecated, will Bitcoin Core be able to sign messages for an address?]({{bse}}116187)
  Pieter Wuille distinguishes between Bitcoin Core [deprecating legacy
  wallets][news125 legacy descriptor wallets] and the continued support for
  older address types like P2PKH addresses even in newer [descriptor][topic
  descriptors] wallets. While message signing is currently only possible for
  P2PKH addresses, efforts around [BIP322][topic generic signmessage] could
  allow for message signing across other address types.

- [How do I set up a time-decay multisig?]({{bse}}116035)
  User Yoda asks how to set up a time-decaying multisig, a UTXO that is spendable
  with a broadening set of pubkeys over time. Michael Folkson provides an
  example using [policy][news74 policy miniscript] and [miniscript][topic
  miniscript], links to related resources, and notes the lack of user-friendly
  options currently.

- [When is a miniscript solution malleable?]({{bse}}116275)
  Antoine Poinsot defines what malleability means in the context of
  miniscript, describes static analysis of malleability in miniscript, and walks
  through the original question's malleability example.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 24.0.1][] is a major release of the mostly widely used
  full node software.  Its new features include an option for
  configuring the node's [Replace-By-Fee][topic rbf] (RBF) policy, a new
  `sendall` RPC for easily spending all of a wallet's funds in a single
  transaction (or for otherwise creating transactions with no change
  output), a `simulaterawtransaction` RPC that can be used to verify how
  a transaction will effect a wallet (e.g., for ensuring a coinjoin
  transaction only decreases the value of a wallet by fees), the ability
  to create watch-only [descriptors][topic descriptors] containing
  [miniscript][topic miniscript] expressions for improved forward
  compatibility with other software, and the automatic application of
  certain setting changes made in the GUI to RPC-based actions.  See the
  [release notes][bcc rn] for the full list of new features and bug
  fixes.

    Note: a version 24.0 was tagged and had its binaries released, but
    project maintainers never announced it and instead worked with other
    contributors to resolve [some last-minute issues][bcc milestone
    24.0.1], making this release of 24.0.1 the first announced release
    of the 24.x branch.

- [libsecp256k1 0.2.0][] is the first tagged release of this widely-used
  library for Bitcoin-related cryptographic operations.  An
  [announcement][libsecp256k1 announce] of the release states, "for a
  long time, libsecp256k1's development only had a master branch,
  creating unclarity about API compatibility and stability. Going
  forward, we will be creating tagged releases when relevant
  improvements are merged, following a semantic versioning scheme. [...]
  We're skipping version 0.1.0 because this version number was set in
  our autotools build scripts for years, and does not uniquely identify
  a set of source files. We will not be creating binary releases, but
  will take expected ABI compatibility issues into account for release
  notes and versioning."

- [Core Lightning 22.11.1][] is a minor release that temporarily
  reintroduces some features that were deprecated in 22.11, as requested
  by some downstream developers.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25934][] adds an optional `label` argument to the
  `listsinceblock` RPC. Only transactions matching the label will be returned
  when a label is specified.

- [LND #7159][] updates the `ListInvoiceRequest` and
  `ListPaymentsRequest` RPCs with new `creation_date_start` and
  `creation_date_end` fields that can be used to filter out invoices and
  payments before or after the indicated date and time.

- [LDK #1835][] adds a fake Short Channel IDentifier (SCID) namespace for intercepted HTLCs, enabling
  Lightning Service Providers (LSPs) to create a [just-in-time][topic jit routing]
  (JIT) channel for end users to receive a lightning payment. This is done
  by including fake route hints in end-user invoices that signal to LDK
  that this is an intercept forward, similar to
  [phantom payments][LDK phantom payments] (see [Newsletter #188][news188 phantom]). LDK then generates an event,
  allowing the LSP the opportunity to open the JIT channel. The LSP can
  then forward the payment over the newly opened channel or fail it.

- [BOLTs #1021][] allows onion-routing error messages to contain a
  [TLV][] stream, which may be used in the future to include additional
  information about the failure.  This is a first step towards
  implementing [fat errors][news224 fat] as proposed in [BOLTs #1044][].

## Happy holidays!

This is Bitcoin Optech's final regular newsletter of the year.  On
Wednesday, December 21st, we'll publish our fifth annual year-in-review
newsletter.  Regular publication will resume on Wednesday, January 4th.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25934,7159,1835,1021,1044" %}
[bitcoin core 24.0.1]: https://bitcoincore.org/bin/bitcoin-core-24.0.1/
[bcc rn]: https://bitcoincore.org/en/releases/24.0.1/
[bcc milestone 24.0.1]: https://github.com/bitcoin/bitcoin/milestone/59?closed=1
[libsecp256k1 0.2.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.2.0
[libsecp256k1 announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021271.html
[core lightning 22.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v22.11.1
[news224 fat]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
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
