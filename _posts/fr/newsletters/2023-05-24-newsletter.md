---
title: 'Bulletin Hebdomadaire Bitcoin Optech #252'
permalink: /fr/newsletters/2023/05/24/
name: 2023-05-24-newsletter-fr
slug: 2023-05-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin d'information de cette semaine décrit la recherche sur les preuves de validité à connaissance nulle pour Bitcoin et les
protocoles connexes. Vous y trouverez également une nouvelle contribution à notre série hebdomadaire limitée sur la politique du
mempool, ainsi que nos sections régulières décrivant les mises à jour des clients et des services, les nouvelles versions et les
versions candidates, ainsi que les changements apportés aux principaux projets d'infrastructure de Bitcoin.

## Nouvelles

- **Compression d'états avec preuves de validité à connaissance nulle :** Robin Linus
  a [posté][linus post] sur la liste de diffusion Bitcoin-Dev un [article][lg paper]
  qu'il a co-écrit avec Lukas George sur l'utilisation des preuves de validité pour
  réduire la quantité d'état qu'un client doit télécharger afin de vérifier sans confiance
  les opérations futures dans un système. Ils appliquent d'abord leur système à Bitcoin.
  Ils indiquent qu'ils disposent d'un prototype qui prouve la quantité cumulative de
  preuves de travail dans une chaîne d'en-têtes de blocs et permet à un client de
  vérifier qu'un en-tête de bloc particulier fait partie de cette chaîne.
  Cela permet à un client qui reçoit plusieurs preuves de déterminer laquelle démontre
  la plus grande preuve de travail.

    Ils disposent également d'un prototype sous-optimal qui prouve que tous les
    changements d'état des transactions de la chaîne de blocs respectent les règles
    monétaires (par exemple, le nombre de bitcoins pouvant être créés par un nouveau
    bloc, le fait que chaque transaction non basée sur les bitcoins ne doit pas créer
    d'UTXO ayant une valeur supérieure à celle des bitcoins qu'elle détruit (dépense),
    et qu'un mineur peut réclamer toute différence entre les UTXO détruits dans un
    bloc et ceux qui ont été créés). Un client recevant cette preuve et une copie de
    l'ensemble d'UTXO actuel serait en mesure de vérifier que l'ensemble est exact et
    complet. Ils appellent cela une preuve _assumevalid_, d'après la [fonctionnalité
    de Bitcoin Core][assumevalid] qui permet de ne pas vérifier les scripts des anciens
    blocs lorsque de nombreux contributeurs s'accordent à dire que leurs nœuds ont tous
    validé ces blocs avec succès.

    Pour minimiser la complexité de leur preuve, ils utilisent une version de [utreexo][topic utreexo]
    avec une fonction de hachage optimisée pour leur système. Ils suggèrent séparément que
    la combinaison de leur preuve avec un client utreexo permettra à ce dernier de commencer
    à fonctionner comme un nœud complet presque immédiatement après avoir téléchargé une très
    petite quantité de données.

    En ce qui concerne la facilité d'utilisation de leurs prototypes, ils écrivent que
    "nous avons mis en œuvre la preuve de la chaîne d'en-tête et la preuve de l'état
    supposé valide en tant que prototypes. Il est possible de prouver la première, tandis
    que la seconde nécessite encore des améliorations de performance pour prouver des blocs
    de taille raisonnable". Ils travaillent également sur la validation de blocs complets,
    y compris les scripts, mais affirment qu'ils ont besoin d'une augmentation de la vitesse
    d'au moins 40 fois pour que cela soit viable.

    Outre la compression de l'état de la chaîne de blocs Bitcoin, ils décrivent également
    un protocole qui peut être utilisé pour un protocole de jetons à validation côté client
    similaire à celui utilisé pour les actifs Taproot de Lightning Labs et certaines utilisations
    de RGB (voir les lettres d'information [#195][news195 taro] et [#247][news247 rgb]).
    Lorsque Alice transfère à Bob une certaine quantité de jetons, Bob doit vérifier l'historique
    de tous les transferts précédents de ces jetons spécifiques depuis leur création. Dans
    un scénario idéal, cet historique croît linéairement avec le nombre de transferts. Mais
    si Bob veut payer à Carole un montant supérieur à celui qu'il a reçu d'Alice, il devra
    combiner certains des jetons qu'il a reçus d'Alice avec d'autres jetons qu'il a reçus
    lors d'une autre transaction. Carol devra alors vérifier à la fois l'historique de la
    transaction avec Alice et l'historique des autres jetons de Bob. C'est ce qu'on appelle
    une fusion. Si les fusions sont fréquentes, la taille de l'historique qui doit être vérifié
    approche la taille de l'historique de chaque transfert de ce jeton entre les utilisateurs.
    En termes comparatifs, dans Bitcoin, chaque nœud complet vérifie chaque transaction effectuée
    par chaque utilisateur ; dans les protocoles de jetons utilisant la validation côté client,
    cela n'est pas strictement nécessaire mais finit par le devenir si les fusions sont fréquentes.

    Cela signifie qu'un protocole capable de comprimer l'état du bitcoin peut également
    être adapté pour comprimer l'état de l'historique d'un jeton, même si les fusions sont
    fréquentes. Les auteurs décrivent comment ils y parviendraient. Leur objectif est de
    produire une preuve que chaque transfert précédent du jeton a suivi les règles du jeton,
    y compris en utilisant leurs preuves pour Bitcoin afin de prouver que chaque transfert
    précédent a été ancré dans la chaîne de blocs. Alice pourrait alors transférer les jetons
    à Bob et lui donner une courte preuve de validité de taille constante ; Bob pourrait
    vérifier la preuve pour savoir que le transfert a eu lieu à une certaine hauteur de bloc
    et payer son portefeuille de jetons, ce qui lui donnerait le contrôle exclusif des jetons.

    Bien que le document mentionne fréquemment des recherches et des développements supplémentaires,
    nous estimons qu'il s'agit d'un progrès encourageant vers une [fonctionnalité][coinwitness] que
    les développeurs de Bitcoin souhaitent depuis plus d'une décennie.

## En attente de confirmation #2 : Mesures d'incitation

Une série hebdomadaire limitée sur le relais de transaction, l'inclusion dans le mempool et la
sélection des transactions minières---y compris pourquoi Bitcoin Core a une politique plus
restrictive que celle autorisée par le consensus et comment les portefeuilles peuvent utiliser
cette politique de la manière la plus efficace.

{% include specials/policy/en/02-cache-utility.md %}

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Sortie du firmware 2.1.1 de Passport :**
  Le [dernier micrologiciel][passport 2.1.1] pour le dispositif de signature matérielle
  Passport prend en charge l'envoi aux adresses [taproot][topic taproot], les fonctionnalités
  [BIP85][] et les améliorations apportées à la gestion des configurations [PSBT][topic psbt] et multisig.

- **MuSig wallet Munstr released:**
  The beta [Munstr software][munstr github] uses the [nostr protocol][] in order
  to facilitate the rounds of communication required for signing [MuSig][topic musig]
  multisignature transactions.

- **CLN plugin manager Coffee released:**
  [Coffee][coffee github] is a CLN plugin manager that improves aspects of
  installation, configuration, dependency management, and upgrading of [CLN plugins][news22 plugins].

- **Electrum 4.4.3 released:**
  The [latest][electrum release notes] Electrum versions contain coin control
  improvements, a UTXO privacy analysis tool, and support for Short Channel
  Identifiers (SCIDs), among other fixes and improvements.

- **Trezor Suite adds coinjoin support:**
  The Trezor Suite software [announced][trezor blog] support for
  [coinjoins][topic coinjoin] that use the zkSNACKs coinjoin coordinator.

- **Lightning Loop defaults to MuSig2:**
  [Lightning Loop][news53 loop] now uses [MuSig2][topic musig] as the default
  swap protocol resulting in lower fees and better privacy.

- **Mutinynet announces new signet for testing:**
  [Mutinynet][mutinynet blog] is a custom signet with 30-second block times that
  provides testing infrastructure including a [block explorer][topic block
  explorers], faucet, as well as test LN nodes and LSPs running on the network.

- **Nunchuk adds coin control, BIP329 support:**
  The latest Android and iOS versions of Nunchuk add [coin control][nunchuk blog] and
  [BIP329][] wallet label export features.

- **MyCitadel Wallet adds enhanced miniscript support:**
  The [v1.3.0][mycitadel v1.3.0] release adds more complicated
  [miniscript][topic miniscript] capabilities including [timelocks][topic timelocks].

- **Edge Firmware for Coldcard announced:**
  Coinkite [announced][coinkite blog] experimental firmware for the Coldcard
  hardware signer that is designed for wallet developers and power users to
  experiment with newer features. The initial 6.0.0X release includes taproot
  keysend payments, [tapscript][topic tapscript] multisig payments, and
  [BIP129][] support.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.05][] is a release of the newest version of this LN
  implementation.  It includes support for [blinded payments][topic rv
  routing], version 2 [PSBTs][topic psbt], and more flexible feerate
  management among many other improvements.

- [Bitcoin Core 23.2][] is a maintenance release for the previous
  major version of Bitcoin Core.

- [Bitcoin Core 24.1][] is a maintenance release for the current
  version of Bitcoin Core.

- [Bitcoin Core 25.0rc2][] is a release candidate for the next major
  version of Bitcoin Core.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27021][] adds an interface for calculating how much it
  would cost to bring an output's unconfirmed ancestor transactions up
  to a given feerate, a value known as their _fee deficit_.  When [coin
  selection][topic coin selection] is considering using a particular
  output at a particular feerate, its ancestors' fee deficit for that
  feerate is calculated and the result is deducted from its effective
  value.  That discourages the wallet from choosing highly deficient
  outputs for a new transaction when other spendable outputs are
  available.  In a [follow-up PR][bitcoin core #26152], the interface
  will also be used to allow the wallet to pay the extra fees (called
  _bump fees_) if it has to select deficient outputs anyway, ensuring
  the new transaction pays the effective feerate the user requested.

  The algorithm is capable of assessing bump fees for any
  ancestor constellation by evaluating the unconfirmed UTXO’s entire
  related cluster of unconfirmed transactions and pruning the
  transactions that will have been picked into a block at the target
  feerate. A second method provides an aggregate bump fee across
  multiple unconfirmed outputs to correct for potential overlapping
  ancestries.

- [LND #7668][] adds the ability to associate up to 500 characters of
  private text with a channel when opening it and allows the operator to
  retrieve that information later, which may help them recall why they
  opened that particular channel.

- [LDK #2204][] adds the ability to set custom feature bits for
  announcing to peers, or for use when attempting to parse a peer's
  announcement.

- [LDK #1841][] implements a version of a security recommendation
  previously added to the LN specification (see [Newsletter
  #128][news128 bolts803]) where a node using [anchor outputs][topic
  anchor outputs] should not attempt to batch together inputs controlled
  by multiple parties when the transaction needs to be confirmed
  promptly.  This prevents other parties from being able to delay
  confirmation.

- [BIPs #1412][] updates [BIP329][] for [wallet label export][topic
  wallet labels] with a field to store key origin information.
  Additionally, the specification now suggests a label length limit of
  255 characters.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27021,7668,2204,1841,1412,26152" %}
[Core Lightning 23.05]: https://github.com/ElementsProject/lightning/releases/tag/v23.05
[bitcoin core 23.2]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021679.html
[lg paper]: https://zerosync.org/zerosync.pdf
[news128 bolts803]: /en/newsletters/2020/12/16/#bolts-803
[news247 rgb]: /en/newsletters/2023/04/19/#rgb-update
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[coinwitness]: https://bitcointalk.org/index.php?topic=277389.0
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[passport 2.1.1]: https://foundationdevices.com/2023/05/passport-version-2-1-0-is-now-live/
[munstr github]: https://github.com/0xBEEFCAF3/munstr
[nostr protocol]: https://github.com/nostr-protocol/nostr
[coffee github]: https://github.com/coffee-tools/coffee
[news22 plugins]: /en/newsletters/2018/11/20/#c-lightning-2075
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[trezor blog]: https://blog.trezor.io/coinjoin-privacy-for-bitcoin-11aaf291f23
[mutinynet blog]: https://blog.mutinywallet.com/mutinynet/
[news53 loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[nunchuk blog]: https://nunchuk.io/blog/coin-control
[mycitadel v1.3.0]: https://github.com/mycitadel/mycitadel-desktop/releases/tag/v1.3.0
[coinkite blog]: https://blog.coinkite.com/edge-firmware/
