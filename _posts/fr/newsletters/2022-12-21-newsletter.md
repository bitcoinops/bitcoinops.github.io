---
title: 'Lettre d'informaton Bitcoin Optech #231: Spéciale Revue annuelle 2022'
permalink: /fr/newsletters/2022/12/21/
name: 2022-12-21-newsletter-fr
slug: 2022-12-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr

excerpt: >
  Cette édition spéciale de la lettre d'information Optech résume les faits     marquants l'évolution du bitcoin pendant toute l'année 2022.
---
{{page.excerpt}}  C'est la suite de nos résumés des années précédentes [2018][yirs
2018], [2019][yirs 2019], [2020][yirs 2020], and [2021][yirs 2021].

## Contenus

* Janvier
  * [factures apatrides](#stateless-invoices)
  * [fond de defense juridique](#defense-fund)
* Fevrier
  * [Parrainage de frais](#fee-sponsorship)
  * [Paiements pour les noeuds fantômes](#phantom-node-payments)
* Mars
  * [LN pathfinding](#ln-pathfinding)
  * [Canaux Zero-conf](#zero-conf-channels)
* Avril
  * [Paiements silencieux](#silent-payments)
  * [Taro](#taro)
  * [Échange de clés à sécurité quantique](#quantum-safe-keys)
* Mai
  * [MuSig2](#musig2)
  * [Package relay](#package-relay)
  * [librairie du noyau Bitcoin](#libbitcoinkernel)
* Juin
  * [Réunion des développeurs du protocole LN](#ln-meet)
* Juillet
  * [Limitation du débit des messages Onion](#onion-message-limiting)
  * [Descripteurs Miniscript](#miniscript-descriptors)
* Aout
  * [LN interactive et double financement](#dual-funding)
  * [Atténuation des attaques de brouillage des canaux](#jamming)
  * [Signatures BLS pour les DLC](#dlc-bls)
* Septembre
  * [Fee ratecards](#fee-ratecards)
* Octobre
  * [Version 3 des relais de transaction](#v3-tx-relay)
  * [Paiements asynchrones](#async-payments)
  * [bogues dans l'analyse syntaxique des blocs](#parsing-bugs)
  * [ZK rollups](#zk-rollups)
  * [Protocole de transport crypté version 2](#v2-transport)
  * [Réunion des développeurs du protocole Bitcoin](#core-meet)
* Novembre
  * [Messages d'erreur Fat](#fat-errors)
* Decembre
  * [Modifier le protocole LN](#ln-mod)
* Résumés en vedette
  * [Replace-By-Fee](#rbf)
  * [Major releases of popular infrastructure projects](#releases)
  * [Bitcoin Optech](#optech)
  * [Soft fork proposals](#softforks)

## Janvier

{:#stateless-invoices}
En janvier, LDK a [fusionné][news181 ldk1177] une implémentation de [factures sans état][topic factures sans état],
qui lui permet de générer un nombre infini de factures sans stocker aucune donnée à leur sujet,
sauf si le paiement est réussi. Les factures apatrides ont déjà été proposées en septembre 2021
et la mise en œuvre de LDK diffère de la méthode suggérée, bien qu'elle accomplisse le même objectif
et ne nécessite aucun changement de protocole LN. Plus tard dans le mois, une [mise à jour][news182 bolts912]
de la spécification LN a été fusionnée pour permettre d'autres types de factures apatrides, avec
un support au moins partiel ajouté à [Eclair][news183 stateless], [Core Lightning][news195 stateless] et [LND][news196 stateless].

{:#defense-fund}
En janvier également, un fonds de défense juridique Bitcoin a été [annoncé][news183 defense fund]
par Jack Dorsey, Alex Morcos et Martin White. Il fournit "une entité à but non lucratif
qui vise à minimiser les maux de tête juridiques qui découragent les développeurs de
logiciels de développer activement Bitcoin et les projets connexes."

## Fevrier

{:#fee-sponsorship}
Une [discussion][news182 accounts] en janvier sur la possibilité d'ajouter plus facilement des frais
aux transactions présignées a conduit à une [nouvelle discussion][news188 sponsorship] en février sur
l'idée de Jeremy Rubin de [parrainage des frais de transaction][topic fee sponsorship] de 2020.
Plusieurs défis à sa mise en œuvre ont été mentionnés. Bien que la discussion immédiate n'ait pas
beaucoup progressée, une technique permettant d'atteindre des objectifs similaires---mais qui,
contrairement au parrainage, ne nécessitait pas de soft fork---a été [proposée][news231 v3relay] en octobre.

{:#phantom-node-payments}
Prise en charge précoce par LDK des [factures apatrides][topic stateless invoices]
lui a permis d'ajouter une méthode nouvelle et [simple][news188 ldk1199] pour le chargement
équilibrant un nœud LN appelé *paiements de nœuds fantômes*.

{:.center}
![Illustration of phantom node payment path](/img/posts/2022-02-phantom-node-payments.dot.png)

## Mars

{:#ln-pathfinding}
The LN pathfinding algorithm first published in 2021 by René Pickhardt
and Stefan Richter received an [update][news192 pp] in March with
Pickhardt noting an improvement that made it much more computationally
efficient.

{:#zero-conf-channels}
A consistent method for allowing [zero-conf channels][topic zero-conf
channels] was [specified][news203 zero-conf] and began seeing
implementation support, starting with LDK's [addition][news192 ldk1311]
in March of support for the related Short Channel IDentifier (SCID)
*alias* field, followed by [Eclair][news205 scid],
[Core Lightning][news208 scid cln], and
[LND][news208 scid lnd].

{:.center}
![Illustration of zero-conf channels](/img/posts/2021-07-zeroconf-channels.png)

<div markdown="1" class="callout" id="rbf">
### 2022 summary<br>Replace-By-Fee

This year saw much discussion, and some significant actions, related to
[Replace By Fee][topic rbf] (RBF).  Our January newsletter
[summarized][news181 rbf] a proposal by Jeremy Rubin to allow any
transaction to be replaced by a higher fee alternative for a brief while
after the original transaction was first seen by a node.  After that time had passed, the
existing rules would apply---only allowing replacement of transactions
opting in to [BIP125][].   This could allow merchants to accept
unconfirmed transactions like they do now after the replacement time
elapsed. More importantly, it may allow protocols that depend on
replaceability for security to not have to worry about non-opt-in
transactions as long as a protocol node or watchtower has a reasonable opportunity to
respond soon after first learning of a transaction.

At the end of January, Gloria Zhao started a fresh discussion about RBF
by [posting][news186 rbf] background on the current RBF policy,
enumerating several problems discovered with it over the years (such
as [pinning attacks][topic transaction pinning]), an examination of how
the policy affects wallet user interfaces, and the description of
several possible improvements.  In early March, Zhao followed up with
the [summary][news191 rbf] of two discussions about RBF between many
developers, one discussion in person and the other online.

Also in March, Larry Ruane raised [questions][news193 witrep] related to
RBF about replacing transaction witnesses without changing the parts
of a transaction from which its txid is derived.

In June, Antoine Riard [opened][news205 rbf] a pull request to Bitcoin
Core to add a `mempoolfullrbf` configuration option to Bitcoin Core.
The option defaulted to Bitcoin Core's previous behavior of only
allowing unconfirmed transactions to be replaced if they contained the
[BIP125][] signal.  Nodes which were configured with the option set to
its alternative value would accept transactions for relay and mining
even if they replaced transactions that did not contain the BIP125
opt-in signal.  Riard also started a thread on the Bitcoin-Dev mailing
list to discuss the change.  Almost all pull request comments were
positive and most mailing list discussion was about unrelated topics, so
it was unsurprising that the pull request was [merged][news208 rbf]
about a month after it was opened.

In October, the Bitcoin Core project began distributing release
candidates for version 24.0, which would be the first to include the
`mempoolfullrbf` configuration option.  Dario Sneidermanis saw the draft
release notes about the option and [posted][news222 rbf] to the
Bitcoin-Dev mailing list that too many users and miners enabling the
option would make unsignaled replacement reliable.  More reliable
unsignaled replacement would also make it more reliable to steal from
services that accept unconfirmed transactions as final, requiring those
services to change their behavior.  Discussion [continued][news223 rbf]
the next week and the [week after][news224 rbf].  A month after
Sneidermanis raised the initial concern on the mailing list, Suhas
Daftuar [summarized][news225 rbf] some of the arguments against the
option and opened a pull request to remove it from Bitcoin Core.
Other similar pull requests were opened previously or subsequently, but
Daftuar's pull request became the focus for discussion about possibly
permanently removing the option.

Many counterarguments in favor of keeping the `mempoolfullrbf` option
were made on Daftuar's pull request.  Those included several wallet developers noting that
they sometimes encounter users who want to make replacements even though
those users didn't opt in to BIP125.

By the end of November, Daftuar closed his PR and the Bitcoin Core
project released version 24.0 with the `mempoolfullrbf` option.  In
December, developer 0xB10C [released][news230 rbf] a website for
monitoring transaction replacements which did not contain the BIP125
signal, indicating that any of those transactions which became confirmed
may have been processed by a miner using the `mempoolfullrbf` option to
enable full-RBF (or a similar feature in other software).  At the end of
the year, full-RBF was still being discussed in other Bitcoin Core PRs
and on the mailing list.

</div>

## April

{:#silent-payments}
In April, Ruben Somsen [proposed][news194 sp] the idea of [silent
payments][topic silent payments], which would allow someone to pay a
public identifier ("address") without using that identifier onchain. This
would help prevent [address reuse][topic output linking].  For example,
Alice would be able to post a public identifier on her website that Bob
can transform into a new unique Bitcoin address from which only Alice
will be able to spend.  If Carol later goes to Alice’s website and
reuses Alice’s public identifier, she would derive a different address
to pay Alice, an address which neither Bob nor any other third party
could directly determine belonged to Alice.  Later, developer W0ltx
would create a [proposed implementation][news202 sp] of silent payments for Bitcoin Core,
making [significant updates][news214 sp] to it later in the year.

{:#taro}
Lightning Labs [announced][news195 taro] Taro, a proposed protocol
(based on previous proposals) for allowing users to commit to the creation
and transfer of non-bitcoin tokens on Bitcoin’s block chain.  Taro is
intended to be used with LN for routable offchain transfers.  Similar to
previous proposals for cross-asset transfers on LN, intermediate nodes
that just forward payments won’t need to be aware of the Taro protocol or
the details of the assets being transferred---they’ll just transfer bitcoins
using the same protocol as any other LN payment.

{:#quantum-safe-keys}
April also saw [discussion][news196 qc] about quantum-safe key
exchange, allowing users to receive bitcoins secured by keys that are
[resistant][topic quantum resistance] to attacks by fast quantum
computers that may exist in the future.

## May

{:#musig2}
The [MuSig2][topic musig] protocol for creating [schnorr
multisignatures][topic multisignature] saw several developments in 2022.
A [proposed BIP][news195 musig2] received significant [feedback][news198
musig2] in May.  Later, in October, Yannick Seurin, Tim
Ruffing, Elliott Jin, and Jonas Nick discovered a
[vulnerability][news222 musig2] in some ways the protocol could be used,
which the researchers announced that they planned to fix in an updated version.

{:#package-relay}
A draft BIP for [package relay][topic package relay] was
[posted][news201 package relay] by Gloria Zhao in May.  Package relay
fixes a significant problem with Bitcoin Core's [CPFP fee bumping][topic
cpfp] where individual nodes will only accept a fee-bumping child
transaction if its parent transaction pays a feerate above the node's
dynamic minimum mempool fee.  This makes CPFP insufficiently reliable
for protocols depending on presigned transactions, such as many contract
protocols (including the current LN protocol).  Package relay allows a
parent and child transaction to be evaluated as a single unit,
eliminating the problem---although not eliminating other related
problems such as [transaction pinning][topic transaction pinning].
Additional discussion of package relay [occurred][news204 package relay]
in June.

{:#libbitcoinkernel}
May also saw the [first merge][news198 lbk] for the Bitcoin Kernel
Library Project (libbitcoinkernel), an attempt to separate out as much
of Bitcoin Core's consensus code as possible into a separate library,
even if that code still has some non-consensus code attached.
Long-term, the goal is to trim down libbitcoinkernel until it contains
only consensus code, making it easy for other projects to use that code
or for auditors to analyze changes to Bitcoin Core's consensus logic.
Several additional libbitcoinkernel PRs would be merged through the
year.

<div markdown="1" class="callout" id="releases">
### 2022 summary<br>Major releases of popular infrastructure projects

- [Eclair 0.7.0][news185 eclair] added support for [anchor
  outputs][topic anchor outputs], relaying [onion messages][topic onion
  messages], and using the PostgreSQL database in production.

- [BTCPay Server 1.4][news189 btcpay] added support for [CPFP fee
  bumping][topic cpfp], the ability to use additional features of LN
  URLs, plus multiple UI improvements.

- [LDK 0.0.105][news190 ldk] added support for phantom node payments and
  better probabalistic payment pathfinding.

- [BDK 0.17.0][news193 bdk] made it easier to derive addresses even when
  the wallet is offline.

- [Bitcoin Core 23.0][news197 bcc] provided [descriptor][topic
  descriptors] wallets by default for new wallets and also allowed
  descriptor wallets to easily support receiving to [bech32m][topic
  bech32] addresses using [taproot][topic taproot].  It also increased
  its support for using non-default TCP/IP ports and began allowing use
  of the [CJDNS][] network overlay.

- [Core Lightning 0.11.0][news197 cln] added support for multiple active
  channels to the same peer and paying [stateless invoices][topic
  stateless invoices].

- [Rust Bitcoin 0.28][news197 rb] added support for [taproot][topic
  taproot] and improved related APIs, such as those for [PSBTs][topic
  psbt].

- [BTCPay Server 1.5.1][news198 btcpay] added a new main-page dashboard,
  a new transfer processors feature, and the ability to allow pull
  payments and refunds to be automatically approved.

- [LDK 0.0.108 and 0.0.107][news205 ldk] added support for [large
  channels][topic large channels] and [zero-conf channels][topic
  zero-conf channels] in addition to providing code that allows mobile
  clients to sync network routing information (gossip) from a server.

- [BDK 0.19.0][news205 bdk] added experimental support for
  [taproot][topic taproot] through [descriptors][topic descriptors],
  [PSBTs][topic psbt], and other sub-systems. It also added a new [coin
  selection][topic coin selection] algorithm.

- [LND 0.15.0-beta][news206 lnd] added support for invoice metadata
  which can be used by other programs (and potentially future versions
  of LND) for [stateless invoices][topic stateless invoices] and adds
  support to the internal wallet for receiving and spending bitcoins to
  [P2TR][topic taproot] keyspend outputs, along with experimental
  [MuSig2][topic musig] support.

- [Rust Bitcoin 0.29][news213 rb] added [compact block relay][topic
  compact block relay] data structures ([BIP152][]) and improvements to
  [taproot][topic taproot] and [PSBT][topic psbt] support.

- [Core Lightning 0.12.0][news214 cln] added a new `bookkeeper` plugin,
  a `commando` plugin, and support for [static channel backups][topic
  static channel backups], plus explicitly began allowing peers the
  ability to open [zero-conf channels][topic zero-conf channels] to your
  node.

- [LND 0.15.1-beta][news215 lnd] added support for [zero-conf
  channels][topic zero-conf channels], channel aliases, and began using
  [taproot][topic taproot] addresses everywhere.

- [LDK 0.0.111][news217 ldk] adds support for creating, receiving, and
  relaying [onion messages][topic onion messages].

- [Core Lightning 22.11][news229 cln] began using a new version
  numbering scheme and added a new plugin manager.

- [libsecp256k1 0.2.0][news230 libsecp] was the first tagged release of
  this widely-used library for Bitcoin-related cryptographic operations.

- [Bitcoin Core 24.0.1][news230 bcc] added an option for configuring the
  node's [Replace-By-Fee][topic rbf] (RBF) policy, a new `sendall` RPC
  for easily spending all of a wallet's funds in a single transaction, a
  `simulaterawtransaction` RPC that can be used to verify how a
  transaction will affect a wallet, and the ability to create watch-only
  [descriptors][topic descriptors] containing [miniscript][topic
  miniscript] expressions for improved forward compatibility with other
  software.

</div>

## June

{:#ln-meet}
In June, LN developers [met][news204 ln] to discuss the future of
protocol development.  Topics discussed included [taproot][topic
taproot]-based LN channels, [tapscript][topic tapscript] and
[MuSig2][topic musig] (including recursive MuSig2), updating the gossip
protocol for announcing new and changed channels, [onion messages][topic
onion messages], [blinded paths][topic rv routing], probing and balance
sharing, [trampoline routing][topic trampoline payments], and the
[offers][topic offers] and LNURL protocols.

## July

{:#onion-message-limiting}
In July, Bastien Teinturier [posted][news207 onion] a summary of an idea
he attributes to Rusty Russell for rate limiting [onion messages][topic
onion messages] in order to prevent denial-of-service attacks.  However,
Olaoluwa Osuntokun suggested reconsideration of his March
[proposal][news190 onion] for preventing abuse of onion messages by
charging for data relay.  It seemed that most developers in the
discussion preferred to attempt rate limiting before adding additional
fees to the protocol.

{:#miniscript-descriptors}
This month Bitcoin Core also [merged a pull request][news209 miniscript]
adding watch-only support for [output script descriptors][topic
descriptors] written in [miniscript][topic miniscript].  A future PR is
expected to allow the wallet to create signatures for spending
miniscript-based descriptors.  As other wallets and signing devices
implement miniscript support, it should become easier for policies to be
transferred between wallets or for multiple wallets to cooperate in
spending bitcoins, such as multisig policies or policies involving
different signers for different occasions (e.g. fallback signers).

## August

{:#dual-funding}
In August, Eclair [merged support][news213 dual funding] for the
interactive funding protocol, a dependency for the [dual funding
protocol][topic dual funding] that allows either (or both) of two nodes
to contribute funds to a new LN channel.  Later that month, another
[merge][news215 dual funding] brought Eclair experimental support for
dual funding.  An open protocol for dual funding can help ensure
merchants have access to channels that allow them to immediately receive
payments from customers.

{:#jamming}
Antoine Riard and Gleb Naumenko [published][news214 jam] a guide
to [channel jamming attacks][topic channel jamming attacks] and
several proposed solutions.  For every channel an attacker controls,
they can make more than a dozen other channels unusable by sending
payments that never complete---meaning the attacker doesn't need to pay
any direct costs.  The problem has been known since 2015 but no
previously proposed solution has gained widespread acceptance.  In
November, Clara Shikhelman and Sergei Tikhomirov would publish their own
[paper][news226 jam] with analysis and a proposed solution based on
small upfront fees and automated reputation-based referrals.
Subsequently, Riard [published][news228 jam] an alternative solution
involving non-tradable node-specific tokens.  In December, Joost Jager
would [announce][news230 jam] a "simple but imperfect" utility that
could help nodes mitigate some problems with jamming without requiring
any changes to the LN protocol.

{:.center}
![Illustration of the two types of channel jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

{:#dlc-bls}
Lloyd Fournier [wrote][news213 bls] about the benefits of having
[DLC][topic dlc] oracles make their attestations using Boneh-Lynn-Shacham
([BLS][]) signatures.  Bitcoin does not support BLS signatures and a
soft fork would be required to add them, but Fournier links to a paper
he co-authored that describes how information can be securely extracted
from a BLS signature and used with Bitcoin-compatible [signature
adaptors][topic adaptor signatures] without any changes to Bitcoin.
This would allow "stateless" oracles where the parties to a contract
(but not the oracle) could privately agree on what information they
wanted the oracle to attest to, e.g. by specifying a program written in
any programming language they knew the oracle would run. They could then
allocate their deposit funds according to the contract without even
telling the oracle that they were planning to use it. When it came time
to settle the contract, each of the parties could run the program
themselves and, if they all agreed on the outcome, settle the contract
cooperatively without involving the oracle at all.  If they didn’t
agree, any one of them could send the program to the oracle (perhaps
with a small payment for its service) and receive back a BLS attestation
to the program source code and the value returned by running it. The
attestation could be transformed into signatures that would allow
settling the DLC on chain. As with current DLC contracts, the oracle
would not know which onchain transactions were based on its BLS
signatures.

<div markdown="1" class="callout" id="optech">
### 2022 summary<br>Bitcoin Optech

In Optech's fifth year, we published 51 weekly [newsletters][] and added 11
new pages to our [topics index][].  Altogether, Optech published over
70,000 words about Bitcoin software research and development this year,
the rough equivalent of a 200-page book. <!-- wc -w
_posts/en/newsletters/2022-* ; a typical book has about 350 words per page -->

</div>

## September

{:#fee-ratecards}
Lisa Neigut [posted][news219 ratecards] to the Lightning-Dev mailing
list a proposal for fee ratecards that would allow a node to advertise
four tiered rates for forwarding fees.  Better advertisement of
forwarding fees, including the ability to set negative fees in some
cases, could help ensure forwarding nodes had enough capacity to relay
payments towards their ultimate destination.  Developer ZmnSCPxj, who
had [posted][news204 lnfees] his own fee-based solution for improving
routing earlier in the year, described a simple way to use ratecards,
"you can model a rate card as four separate channels between the same
two nodes, with different costs each. If the path at the lowest cost
fails, you just try another route that may have more hops but lower
effective cost, or else try the same channel at a higher cost."  An
alternative method for payment flow control was [suggested][news220 flow
control] by René Pickhardt.

## October

{:#v3-tx-relay}
In October, Gloria Zhao [proposed][news220 v3] allowing transactions that
used version number 3 to use a modified set of transaction relay
policies.  These policies are based on experience using [CPFP][topic
cpfp] and [RBF][topic rbf], plus ideas for [package relay][topic package
relay], and are designed to help preventing [pinning attacks][topic
transaction pinning] against two-party contract protocols like LN---ensuring
that users can promptly get transactions confirmed for closing channels,
settling payments ([HTLCs][topic htlc]), and enforcing misbehavior
penalties.  Greg Sanders would [follow up][news223 ephemeral] later in
the month with an additional proposal for *ephemeral anchors*, a
simplified form of the [anchor outputs][topic anchor outputs] already
usable with most LN implementations.

{:#async-payments}
Eclair added [support][news220 async] for a basic form of async payments
when [trampoline relay][topic trampoline payments] is used. Async
payments would allow paying an offline node (such as a mobile wallet)
without trusting a third-party with the funds. The ideal mechanism for
async payments depends on [PTLCs][topic ptlc], but a partial
implementation just requires a third party to delay forwarding the funds
until the offline node comes back online. Trampoline nodes can provide
that delay and so this PR makes use of them to allow experimentation
with async payments.

{:#parsing-bugs}
October also saw the [first][news222 bug] of two block parsing bugs that
affected multiple applications.  An accidentally triggered bug in BTCD
prevented it and downstream program LND from processing the latest
blocks.  This could have led to users losing funds, although no such
problems were reported.  A [second][news225 bug] related bug, this time
deliberately triggered, affected BTCD and LND again, along with users of some
versions of Rust-Bitcoin.  Again, there was a potential for users to
lose money, although we are unaware of any reported incidents.

{:#zk-rollups}
John Light [posted][news222 rollups] a research report he prepared about
validity rollups---a type of sidechain where the current sidechain state
is compactly stored on the mainchain. An owner of sidechain bitcoins can
use the state stored on the mainchain to prove how many sidechain
bitcoins they control. By submitting a mainchain transaction with a
validity proof, they can withdraw bitcoins they own from the sidechain
even if the operators or miners of the sidechain try to prevent the
withdrawal.  Light's research describes validity rollups in depth, looks
at how support for them could be added to Bitcoin, and examines various
concerns with their implementation.

{:#v2-transport}
The [BIP324][] proposal for an [encrypted v2 P2P transport
protocol][news222 v2trans] received an update and mailing list
discussion for the first time in three years.  Encrypting the transport
of unconfirmed transactions can help hide their origin from eavesdroppers
who control many internet relays (e.g. large ISPs and governments).  It
can also help detect tampering and possibly make [eclipse attacks][topic
eclipse attacks] more difficult.

{:#core-meet}
A meeting of Bitcoin protocol developers had several sessions
[transcribed][news223 xscribe] by Bryan Bishop, including discussions
about [transport encryption][topic v2 p2p transport], transaction fees
and [economic security][topic fee sniping], the FROST [threshold
signature][topic threshold signature] scheme, the sustainability of
using GitHub for source code and development discussion hosting,
including provable specifications in BIPs, [package relay][topic package
relay] and [v3 transaction relay][topic v3 transaction relay], the
Stratum version 2 mining protocol, and getting code merged into Bitcoin
Core and other free software projects.

<div markdown="1" class="callout" id="softforks">
### 2022 summary<br>Soft fork proposals

January began with Jeremy Rubin [holding][news183a ctv] the first of
several IRC meetings to review and discuss the
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) soft fork
proposal.  Meanwhile, Peter Todd [posted][news183b ctv] several concerns
with the proposal to the Bitcoin-Dev mailing list, most notably
expressing concern that it didn't seem to benefit nearly all Bitcoin
users, as he believes previously soft forks have done.

Lloyd Fournier [posted][news185 ctv] to the DLC-Dev and Bitcoin-Dev
mailing lists about how the CTV opcode could radically reduce the number
of signatures required to create certain [Discreet Log Contracts][topic
dlc] (DLCs), as well as reduce the number of some other operations.
Jonas Nick noted that a similar optimization is also possible using the
proposed [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO) signature
hash mode.

Russell O'Connor [proposed][news185 txhash] an alternative to both CTV
and APO---a soft fork adding an `OP_TXHASH` opcode and an
[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) opcode.  The
TXHASH opcode would specify which parts of a spending transaction should
be serialized and hashed, with the hash digest being put on the
evaluation stack for later opcodes to use. The CSFS opcode would specify
a public key and require a corresponding signature over particular data
on the stack---such as the computed digest of the transaction created by
TXHASH.  This would allow emulation of CTV and APO in a way that might
be simpler, more flexible, and easier to extend through other
subsequent soft forks.

In February, Rusty Russell would [propose][news187 optx] `OP_TX`, an
even simpler version of `OP_TXHASH`.  Meanwhile, Jeremy Rubin
[published][news188 ctv] parameters and code for a [signet][topic signet] with CTV
activated. This simplifies public experimentation with the proposed
opcode and makes it much easier to test compatibility between different
software using the code.  Also in February, developer ZmnSCPxj proposed
a new `OP_EVICT` opcode as an alternative to the
`OP_TAPLEAF_UPDATE_VERIFY` (TLUV) opcode proposed in 2021. Like TLUV,
EVICT is focused on use cases where more than two users share ownership
of a single UTXO, such as [joinpools][topic joinpools], [channel
factories][topic channel factories], and certain [covenants][topic
covenants].  ZmnSCPxj would later [propose][news191 fold] a different new opcode,
`OP_FOLD`, as a more general construct from which EVICT-like behavior
could be built (though that would require some other Script language
changes).

By March, the discussion about CTV and newer opcode proposals led to a
[discussion][news190 recov] about limiting the expressiveness of
Bitcoin's Script language, mainly to prevent *recursive
covenants*---conditions that would need to be fulfilled in every
transaction re-spending those bitcoins or any bitcoins merged with it
for perpetuity.   Concerns included a loss of censorship resistance,
enabling [drivechains][topic sidechains], encouraging unnecessary
computation, and making it possible for users to accidentally lose coins
to recursive covenants.

March also saw yet another idea for a soft fork change to Bitcoin's
Script language, this time to allow future transactions to opt-in to a
completely different language based on Lisp.  Anthony Towns
[proposed][news191 btc-script] the idea and described how it might be
better than both Script and a previously-proposed replacement:
[Simplicity][topic simplicity].

In April, Jeremy Rubin [posted][news197 ctv] to the Bitcoin-Dev mailing
list his plan to release software that will allow miners to begin
signaling whether they intend to enforce the [BIP119][] rules for the
proposed CTV opcode.  This spurred discussion about CTV and similar
proposals, such as APO.  Rubin later announced he wouldn't be releasing
compiled software for activating CTV at the present time as he and other
CTV supporters evaluated the feedback they'd received.

In May, Rusty Russell [updated][news200 ctv] his `OP_TX` proposal.  The
original proposal would allow recursive covenants, which elicited the
concerns mentioned earlier in this section.  Instead, Russell proposed
an initial version of TX that was limited to permitting the behavior of
CTV, which had been specifically designed to prevent recursive
covenants.  This new version of TX could be incrementally updated in the
future to provide additional features, making it more powerful but also
allowing those new features to be independently analyzed.  Additional
discussion in May [examined][news200 cat] the `OP_CAT` opcode (removed
from Bitcoin in 2010), which some developers occasionally suggest might
be a candidate for adding back in the future.

In September, Jeremy Rubin [described][news218 apo] how a trusted setup
procedure could be combined with the proposed APO feature to implement
behavior similar to that proposed by [drivechains][topic sidechains].
Preventing the implementation of drivechains on Bitcoin was one of the
reasons developer ZmnSCPxj suggested earlier in the year that full node
operators might want to oppose soft forks that enable recursive
covenants.

Also in September, Anthony Towns [announced][news219 inquisition] a
Bitcoin implementation designed specifically for testing soft forks on
[signet][topic signet].  Based on Bitcoin Core, Towns's code will
enforce rules for soft fork proposals with high-quality specifications
and implementations, making it simpler for users to experiment with the
proposed changes---including comparing changes to each other or seeing
how they interact.  Towns also plans to include proposed major changes
to transaction relay policy (such as [package relay][topic package
relay]).

In November, Salvatore Ingala [posted][news226 matt] to the Bitcoin-Dev
mailing list a proposal for a new type of covenant (requiring a soft
fork) that would allow using merkle trees to create smart contracts that
can carry state from one onchain transaction to another.  This would be
similar in capability to smart contracts used on some other
cryptocurrency systems but would be compatible with Bitcoin's existing
UTXO-based system.

</div>
## November

{:#fat-errors}
November saw Joost Jager [update][news224 fat] a proposal from 2019 to
improve error reporting in LN for failed payments.  The error would
report the identity of a channel where a payment failed to be forwarded
by a node so that the spender could avoid using channels involving that
node for a limited time.  Several LN implementations would update their
code to support the proposal, even if they didn't immediately begin
using it themselves, including [Eclair][news225 fat] and [Core
Lightning][news226 fat].

## December

{:#ln-mod}
In December, protocol developer John Law posted to the Lightning-Dev
mailing list his third major proposal for the year.  Like his previous
two proposals, he suggested new ways LN offchain transactions could be
designed to enable new features without requiring any changes to
Bitcoin's consensus code.  Altogether, Law proposed ways casual LN users
could [remain offline][news221 ln-mod] for potentially months at a time,
[separating][law tunable] the enforcement for specific payments from the
management of all settled funds to improve compatibility with
[watchtowers][topic watchtowers], and [optimizing][news230 ln-mod] LN
channels for use in [channel factories][topic channel factories] that
could significantly decrease the onchain costs to use LN.

*We thank all of the Bitcoin contributors named above, plus the many
others whose work was just as important, for another incredible year of
Bitcoin development.  The Optech newsletter will return to its regular
Wednesday publication schedule on January 4th.*

{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[bls]: https://en.wikipedia.org/wiki/BLS_digital_signature
[cjdns]: https://github.com/cjdelisle/cjdns
[law tunable]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[news181 ldk1177]: /en/newsletters/2022/01/05/#rust-lightning-1177
[news181 rbf]: /en/newsletters/2022/01/05/#brief-full-rbf-then-opt-in-rbf
[news182 accounts]: /en/newsletters/2022/01/12/#fee-accounts
[news182 bolts912]: /en/newsletters/2022/01/12/#bolts-912
[news183a ctv]: /en/newsletters/2022/01/19/#irc-meeting
[news183b ctv]: /en/newsletters/2022/01/19/#mailing-list-discussion
[news183 defense fund]: /en/newsletters/2022/01/19/#bitcoin-and-ln-legal-defense-fund
[news183 stateless]: /en/newsletters/2022/01/19/#eclair-2063
[news185 ctv]: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script
[news185 eclair]: /en/newsletters/2022/02/02/#eclair-0-7-0
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news186 rbf]: /en/newsletters/2022/02/09/#discussion-about-rbf-policy
[news187 optx]: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[news188 ctv]: /en/newsletters/2022/02/23/#ctv-signet
[news188 ldk1199]: /en/newsletters/2022/02/23/#ldk-1199
[news188 sponsorship]: /en/newsletters/2022/02/23/#fee-bumping-and-transaction-fee-sponsorship
[news189 btcpay]: /en/newsletters/2022/03/02/#btcpay-server-1-4-6
[news189 evict]: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership
[news190 ldk]: /en/newsletters/2022/03/09/#ldk-0-0-105
[news190 onion]: /en/newsletters/2022/03/09/#paying-for-onion-messages
[news190 recov]: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness
[news191 btc-script]: /en/newsletters/2022/03/16/#using-chia-lisp
[news191 fold]: /en/newsletters/2022/03/16/#looping-folding
[news191 rbf]: /en/newsletters/2022/03/16/#ideas-for-improving-rbf-policy
[news192 ldk1311]: /en/newsletters/2022/03/23/#ldk-1311
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[news193 bdk]: /en/newsletters/2022/03/30/#bdk-0-17-0
[news193 witrep]: /en/newsletters/2022/03/30/#transaction-witness-replacement
[news194 sp]: /en/newsletters/2022/04/06/#delinked-reusable-addresses
[news195 musig2]: /en/newsletters/2022/04/13/#musig2-proposed-bip
[news195 stateless]: /en/newsletters/2022/04/13/#core-lightning-5086
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[news196 qc]: /en/newsletters/2022/04/20/#quantum-safe-key-exchange
[news196 stateless]: /en/newsletters/2022/04/20/#lnd-5810
[news197 bcc]: /en/newsletters/2022/04/27/#bitcoin-core-23-0
[news197 cln]: /en/newsletters/2022/04/27/#core-lightning-0-11-0
[news197 ctv]: /en/newsletters/2022/04/27/#discussion-about-activating-ctv
[news197 rb]: /en/newsletters/2022/04/27/#rust-bitcoin-0-28
[news198 btcpay]: /en/newsletters/2022/05/04/#btcpay-server-1-5-1
[news198 lbk]: /en/newsletters/2022/05/04/#bitcoin-core-24322
[news198 musig2]: /en/newsletters/2022/05/04/#musig2-implementation-notes
[news200 cat]: /en/newsletters/2022/05/18/#when-would-enabling-op-cat-allow-recursive-covenants
[news200 ctv]: /en/newsletters/2022/05/18/#updated-op-tx-proposal
[news201 package relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[news202 sp]: /en/newsletters/2022/06/01/#experimentation-with-silent-payments
[news203 zero-conf]: /en/newsletters/2022/06/08/#bolts-910
[news204 ln]: /en/newsletters/2022/06/15/#summary-of-ln-developer-meeting
[news204 lnfees]: /en/newsletters/2022/06/15/#using-routing-fees-to-signal-liquidity
[news204 package relay]: /en/newsletters/2022/06/15/#continued-package-relay-bip-discussion
[news205 bdk]: /en/newsletters/2022/06/22/#bdk-0-19-0
[news205 ldk]: /en/newsletters/2022/06/22/#ldk-0-0-108
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news205 scid]: /en/newsletters/2022/06/22/#eclair-2224
[news206 lnd]: /en/newsletters/2022/06/29/#lnd-0-15-0-beta
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news208 scid cln]: /en/newsletters/2022/07/13/#core-lightning-5275
[news208 scid lnd]: /en/newsletters/2022/07/13/#lnd-5955
[news209 miniscript]: /en/newsletters/2022/07/20/#bitcoin-core-24148
[news213 bls]: /en/newsletters/2022/08/17/#using-bitcoin-compatible-bls-signatures-for-dlcs
[news213 dual funding]: /en/newsletters/2022/08/17/#eclair-2273
[news213 rb]: /en/newsletters/2022/08/17/#rust-bitcoin-0-29
[news214 cln]: /en/newsletters/2022/08/24/#core-lightning-0-12-0
[news214 jam]: /en/newsletters/2022/08/24/#overview-of-channel-jamming-attacks-and-mitigations
[news214 sp]: /en/newsletters/2022/08/24/#updated-silent-payments-pr
[news215 dual funding]: /en/newsletters/2022/08/31/#eclair-2275
[news215 lnd]: /en/newsletters/2022/08/31/#lnd-0-15-1-beta
[news217 ldk]: /en/newsletters/2022/09/14/#ldk-0-0-111
[news218 apo]: /en/newsletters/2022/09/21/#creating-drivechains-with-apo-and-a-trusted-setup
[news219 inquisition]: /en/newsletters/2022/09/28/#bitcoin-implementation-designed-for-testing-soft-forks-on-signet
[news219 ratecards]: /en/newsletters/2022/09/28/#ln-fee-ratecards
[news220 async]: /en/newsletters/2022/10/05/#eclair-2435
[news220 flow control]: /en/newsletters/2022/10/05/#ln-flow-control
[news220 v3]: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty
[news221 ln-mod]: /en/newsletters/2022/10/12/#ln-with-long-timeouts-proposal
[news222 bug]: /en/newsletters/2022/10/19/#block-parsing-bug-affecting-btcd-and-lnd
[news222 musig2]: /en/newsletters/2022/10/19/#musig2-security-vulnerability
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news222 rollups]: /en/newsletters/2022/10/19/#validity-rollups-research
[news222 v2trans]: /en/newsletters/2022/10/19/#bip324-update
[news223 ephemeral]: /en/newsletters/2022/10/26/#ephemeral-anchors
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news223 xscribe]: /en/newsletters/2022/10/26/#coredev-tech-transcripts
[news224 fat]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[news225 bug]: /en/newsletters/2022/11/09/#block-parsing-bug-affecting-multiple-software
[news225 fat]: /en/newsletters/2022/11/09/#eclair-2441
[news225 rbf]: /en/newsletters/2022/11/09/#continued-discussion-about-enabling-full-rbf
[news226 fat]: /en/newsletters/2022/11/16/#core-lightning-5698
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news226 matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news228 jam]: /en/newsletters/2022/11/30/#reputation-credentials-proposal-to-mitigate-ln-jamming-attacks
[news229 cln]: /en/newsletters/2022/12/07/#core-lightning-22-11
[news230 bcc]: /en/newsletters/2022/12/14/#bitcoin-core-24-0-1
[news230 jam]: /en/newsletters/2022/12/14/#local-jamming-to-prevent-remote-jamming
[news230 libsecp]: /en/newsletters/2022/12/14/#libsecp256k1-0-2-0
[news230 ln-mod]: /en/newsletters/2022/12/14/#factory-optimized-ln-protocol-proposal
[news230 rbf]: /en/newsletters/2022/12/14/#monitoring-of-full-rbf-replacements
[news231 v3relay]: /en/newsletters/2022/12/21/#v3-tx-relay
[newsletters]: /en/newsletters/
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /en/newsletters/2021/12/22/
