---
title: 'Bitcoin Optech Newsletter #282: 2023 Year-in-Review Special'
permalink: /en/newsletters/2023/12/20/
name: 2023-12-20-newsletter
slug: 2023-12-20-newsletter
type: newsletter
layout: newsletter
lang: en

excerpt: >
  This special edition of the Optech Newsletter summarizes notable
  developments in Bitcoin during all of 2023.
---
{{page.excerpt}}  It’s the sequel to our summaries from [2018][yirs
2018], [2019][yirs 2019], [2020][yirs 2020], [2021][yirs 2021], and
[2022][yirs 2022].

## Contents

* January
  * [Bitcoin Inquisition](#inquisition)
  * [Swap-in-potentiam](#potentiam)
  * [BIP329 wallet label export format](#bip329)
* February
  * [Ordinals and inscriptions](#ordinals)
  * [Bitcoin Search, ChatBTC, and TL;DR](#chatbtc)
  * [Peer storage backups](#peer-storage)
  * [LN quality of service](#ln-qos)
  * [HTLC endorsement](#htlc-endorsement)
  * [Codex32](#codex32)
* March
  * [Hierarchical channels](#mpchan)
* April
  * [Watchtower accountability proofs](#watchaccount)
  * [Route blinding](#route-blinding)
  * [MuSig2](#musig2)
  * [RGB and Taproot Assets](#clientvalidation)
  * [Channel splicing](#splicing)
* May
  * [LSP specifications](#lspspec)
  * [Payjoin](#payjoin)
  * [Ark](#ark)
* June
  * [Silent payments](#silentpayments)
* July
  * [Validating Lightning Signer](#vls)
  * [LN developer meeting](#ln-meeting)
* August
  * [Onion messages](#onion-messages)
  * [Outdated backup proofs](#backup-proofs)
  * [Simple taproot channels](#tapchan)
* September
  * [Compressed Bitcoin transactions](#compressed-txes)
* October
  * [Payment switching and splitting](#pss)
  * [Sidepools](#sidepools)
  * [AssumeUTXO](#assumeutxo)
  * [Version 2 P2P transport](#p2pv2)
  * [Miniscript](#miniscript)
  * [State compression and BitVM](#statebitvm)
* November
  * [Offers](#offers)
  * [Liquidity advertisements](#liqad)
* December
  * [Cluster mempool](#clustermempool)
  * [Warnet](#warnet)
* Featured summaries
  * [Soft fork proposals](#softforks)
  * [Security disclosures](#security)
  * [Major releases of popular infrastructure projects](#releases)
  * [Bitcoin Optech](#optech)

## January

{:#inquisition}
- **Bitcoin Inquisition:** Anthony Towns [announced][jan inquisition] Bitcoin Inquisition, a
software fork of Bitcoin Core designed to be used on the default signet
for testing proposed soft forks and other significant protocol changes.
By the end of the year, it contained support for several proposals:
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout],
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify], and basic
[ephemeral anchors][topic ephemeral anchors], with pull requests open in
its repository to add support for [OP_CAT][], `OP_VAULT`, and the
[restriction against 64-byte transactions][topic consensus cleanup]. {% assign timestamp="10:59" %}

{:#potentiam}
- **Swap-in-potentiam:** ZmnSCPxj and Jesse Posner [proposed][jan potentiam] _swap-in-potentiam_,
a non-interactive method for opening Lightning Network channels,
addressing challenges faced by often-offline wallets like those on
mobile devices.  A client can receive funds in an onchain transaction
while it is offline.  The transaction can receive enough confirmations
to make it immediately safe to open a channel with a pre-selected peer
when the client comes back online---without placing any trust in that
peer.  Within a few months of the proposal, at least one popular LN
wallet <!-- Phoenix --> was using an implementation of the idea. {% assign timestamp="14:03" %}

{:#bip329}
- **BIP329 wallet label export format:** A standard format for [wallet label][topic wallet labels] export and
import was [assigned][jan bip329] the identifier [BIP329][].  Not only
does the standard make it easier to back up important wallet data that
can't be recovered from a [BIP32 seed][topic bip32], but it also makes
it much easier to copy transaction metadata into non-wallet programs,
such as accounting software.  By the end of the year, several wallets
had implemented BIP329 export. {% assign timestamp="19:32" %}

## February

{:#ordinals}
- **Ordinals and inscriptions:** February saw the [beginning][feb ord1] of a [discussion][feb ord2] that
would continue for the rest of the year about Ordinals and Inscriptions,
two related protocols for associating meaning and data with transaction
outputs.  Andrew Poelstra summarized the position of many protocol
developers: "there is no sensible way to prevent people from storing
arbitrary data in witnesses without incentivizing even worse behavior
and/or breaking legitimate use cases." Given the method used by
Inscriptions allows storing large amounts of data, Christopher Allen
suggested increasing Bitcoin Core's 83-byte limit for data storage in
outputs prefixed by `OP_RETURN`; a proposal that was also [advanced][aug
opreturn] by Peter Todd later in the year. {% assign timestamp="20:22" %}

{:#chatbtc}
- **Bitcoin Search, ChatBTC, and TL;DR:** BitcoinSearch.xyz was [launched][feb bitcoinsearch] early in the year,
providing a search engine for Bitcoin technical documentation and
discussions.  By the end of the year, the site offered a [chat
interface][chatbtc] and [summaries][tldr] of recent discussions. {% assign timestamp="41:50" %}

{:#peer-storage}
- **Peer storage backups:** Core Lightning [added][feb storage] experimental support for peer
storage backups, which allow a node to store a small encrypted backup
file for its peers. If a peer later needs to reconnect, perhaps after
losing data, it can request the backup file.  The peer can use a key
derived from its wallet seed to decrypt the file and use the contents to
recover the latest state of all of its channels. {% assign timestamp="43:40" %}

{:#ln-qos}
- **LN quality of service:** Joost Jager [proposed][feb lnflag] a "high availability" flag for LN
channels, allowing the channel to signal it offered reliable payment
forwarding.  Christian Decker noted challenges in creating reputation
systems, such as infrequent node encounters. A previously proposed
alternative approach was also mentioned: [overpayment with
recovery][topic redundant overpayments] (previously termed boomerang or
refundable overpayments), where payments are split and sent via multiple
routes, reducing reliance on highly available channels. {% assign timestamp="44:10" %}

- **HTLC endorsement:** Ideas from a [paper][jamming paper] posted last year became a particular
focus of the 2023 effort to mitigate [LN channel jamming][topic channel
jamming attacks].  In February, Carla Kirk-Cohen and the paper's
co-author Clara Shikhelman began [asking][feb htlcendo] for feedback on
the suggested parameters to use when implementing one of the ideas from
the paper, [HTLC endorsement][topic htlc endorsement].  In April, they
[posted][apr htlcendo] a draft specification for their testing plans.
In July, the idea and the proposal were [discussed][jul htlcendo] at the
LN development meeting, which led to some mailing list discussion about
an [alternative approach][aug antidos] to make the costs paid by both
attackers and honest users reflect the underlying costs paid by the node
operators providing the service; that way, a node operator who is
earning a reasonable return on providing services to honest users will
continue earning reasonable returns if attackers begin using those
services.  In August, it was [announced][aug htlcendo] developers
associated with Eclair, Core Lightning, and LND were all implementing
parts of the HTLC endorsement protocol in order to begin collecting data
related to it. {% assign timestamp="47:31" %}

- **Codex32:** Russell O'Connor and Andrew Poelstra [proposed][feb codex32] a new BIP
for backing up and restoring [BIP32][] seeds called [codex32][topic
codex32].  Similar to SLIP39, it allows creating several shares using
Shamir’s Secret Sharing Scheme with configurable threshold requirements.
An attacker who obtains less than the threshold number of shares will
learn nothing about the seed. Unlike other recovery codes that use a
wordlist, codex32 uses the same alphabet as [bech32][topic bech32]
addresses. The main advantage of codex32 over existing schemes is its
ability to perform all operations manually using pen, paper,
instructions, and paper cutouts, including generating an encoded seed
(with dice), protecting it with a checksum, creating checksummed shares,
verifying checksums, and recovering the seed. This allows users to
periodically verify the integrity of individual shares without relying
on trusted computing devices. {% assign timestamp="48:33" %}

## March

{:#mpchan}
- **Hierarchical channels:** In March, pseudonymous developer John Law [published][mar mpchan] a
paper describing a way to create a hierarchy of channels for multiple
users from a single onchain transaction.  The design can allow
all online users to spend their funds even when some of their channel
counterparties are offline, which is not currently possible in LN.  This
optimization would allow always-online users to use their capital more
efficiently, likely reducing the costs for other users of LN.  The proposal
depends on Law's tunable penalty protocol, which has not seen any
public software development since it was proposed in 2022. {% assign timestamp="50:57" %}

![Tunable Penalty Protocol](/img/posts/2023-03-tunable-commitment.dot.png)

<div markdown="1" class="callout" id="softforks">

### Summary 2023: Soft fork proposals

{% assign timestamp="54:22" %}

A [proposal][jan op_vault] for a new `OP_VAULT` opcode was posted in
January by James O'Beirne, [followed][feb op_vault] in February by a
draft BIP an implementation for Bitcoin Inquisition.  This was further
followed a few weeks later by a [proposal][feb op_vault2] for an
alternative design for `OP_VAULT` by Gregory Sanders.

The merklize all the things (MATT) proposal first described last year saw
activity again this year. Salvatore Ingala [showed][may
matt] how it could provide most of the features of the proposed
`OP_VAULT` opcodes.  Johan Torås Halseth [further demonstrated][jun
matt] how one of the opcodes from the MATT proposal could replicate
key functions of the `OP_CHECKTEMPLATEVERIFY` proposed opcode, although the
MATT version was less space efficient.  Halseth also used the
opportunity to introduce readers to a tool he'd built, [tapsim][], which
allows debugging Bitcoin transactions and [tapscripts][topic tapscript].

In June, Robin Linus [described][jun specsf] how users could timelock funds today,
use them on a sidechain for a long time, and then allow
the receivers of the funds on the sidechain to effectively withdraw them
on Bitcoin at a later point---but only if Bitcoin users eventually
decide to change the consensus rules in a certain way.  This could allow
users willing to take a financial risk to immediately begin using their
funds with new consensus features they desire, while providing a path
for those funds to later return to Bitcoin's mainnet.

In August, Brandon Black [proposed][aug combo] a version of `OP_TXHASH`
combined with [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] that
would provide most of the features of [OP_CHECKTEMPLATEVERIFY][topic
op_checktemplateverify] (CTV) and [SIGHASH_ANYPREVOUT][topic
sighash_anyprevout] (APO) without much additional onchain cost over
those individual proposals.

In September, John Law [suggested][sep lnscale] enhancing LN
scalability using covenants. He uses a construction similar to [channel
factories][topic channel factories] and the proposed Ark protocol to
potentially fund millions of channels offchain, which can be reclaimed
by the factory funder after an expiry, with users withdrawing their
funds over LN beforehand. The model allows funds to be moved between
factories without user interaction, reducing the risk of last-minute
onchain congestion and transaction fees. Anthony Towns raised concerns
about the _forced expiration flood_ problem, where the failure of a
large user could force many time-sensitive onchain transactions
simultaneously. Law replied to note that he is working on a solution to
delay expiry during high transaction fee periods.

October started with Steven Roose [posting][oct txhash] a draft BIP for
a new OP_TXHASH opcode. The idea for the opcode has been discussed
before but this is the first specification of the idea. In addition to
describing exactly how the opcode would work, it examined some
downsides, such as full nodes potentially needing to hash up to several
megabytes of data every time the opcode is invoked. The BIP draft
included a sample implementation of the opcode.

Also in October, Rusty Russell [researched][oct generic] generic
covenants with minimal changes to Bitcoin's scripting language and Ethan
Heilman [published][oct op_cat] a draft BIP to add an [OP_CAT][op_cat]
opcode that would concatenate two elements on the stack.  The discussion
for both of those topics would [continue][nov cov] into November.

Before the end of the year, Johan Torås Halseth would also [suggest][nov
htlcagg] that covenant-style soft forks could allow aggregation
of multiple [HTLCs][topic htlc] into a single output that could be spent
all at once if a party knew all the preimages. If a party only knew some
of the preimages, they could claim just those and then the remaining
balance could be refunded to the other party. This would be more
efficient onchain and could make it more difficult to perform certain
types of [channel jamming attacks][topic channel jamming attacks].

</div>

## April

{:#watchaccount}
- **Watchtower accountability proofs:** Sergi Delgado Segura [proposed][apr watchtower] an accountability
mechanism for [watchtowers][topic watchtowers] for cases where they fail to respond to
protocol breaches that they were capable of detecting. For example,
Alice provides a watchtower with data for detecting and responding to
the confirmation of an old LN channel state; later, that state is
confirmed but the watchtower fails to respond. Alice would like to be
able to hold the watchtower operator accountable by publicly proving it
failed to respond appropriately.  Delgado suggests a mechanism based on
cryptographic accumulators that watchtowers can use for creating
commitments, which users can later use to produce accountability proofs
if a breach occurs. {% assign timestamp="1:04:24" %}

- **Route blinding:** [Route blinding][topic rv routing], first described three years earlier,
was [added][apr blinding] to the LN specification in April.  It allows a
receiver to provide a spender with the identifier of a particular
forwarding node and an onion-encrypted path from that node to the
receiver's own node.  The spender forwards a payment and the encrypted
path information to the selected forwarding node; the forwarding node
decrypts information for the next hop; that next hop decrypts the hop
after it; and so on, until the payment arrives at the receiver's node
with neither the spender nor any of the forwarding nodes ever learning
(for sure) which node belonged to the receiver.  It significantly
improves the privacy of receiving money using LN. {% assign timestamp="1:05:58" %}

- **MuSig2:** [BIP327][] was [assigned][apr musig2] to the [MuSig2][topic musig]
protocol for creating [scriptless multisignatures][topic multisignature]
in April.  This protocol would be implemented in multiple programs and
systems over the year, including LND's [signrpc][apr signrpc] RPC, <!-- sic -->
Lightning Lab's [Loop][apr loop] service, BitGo's [multisignature
service][apr bitgo], LND's experimental [simple taproot channels][apr
taproot channels], and a [draft BIP][apr musig2 psbt] for extending
[PSBTs][topic psbt]. {% assign timestamp="1:08:36" %}

{:#clientvalidation}
- **RGB and Taproot Assets:** Maxim Orlovsky [announced][apr rgb] the release of RGB v0.10 in April, a
new version of this protocol for allowing the creation and transfer of
tokens (among other things) using contracts that are defined and
[validated][topic client-side validation] offchain.
Changes to the contract state (e.g. transfers) are associated with
onchain transactions in a way that uses no additional block space over a
typical transaction and which can keep all information about the
contract state (including its existence) completely private from third
parties.  Later in the year, the Taproot Assets protocol, which is
partly derived from RGB, released [specifications][sept tapassets]
intended to become BIPs. {% assign timestamp="1:12:47" %}

{:#splicing}
- **Channel splicing:** April also saw significant [discussion][apr splicing] about the
proposed protocol for [splicing][topic splicing], which allows nodes to
continue using a channel while funds are added to it or removed from it.
This is especially useful for keeping funds in a channel while still
allowing instant onchain payments to be made from that balance, allowing
a wallet user interface to show users a single balance from which they
can make either onchain or offchain payments.  By the end of the year,
both Core Lightning and Eclair would support splicing. {% assign timestamp="1:16:06" %}

![Splicing](/img/posts/2023-04-splicing1.dot.png)

## May

{:#lspspec}
- **LSP specifications:** A set of draft specifications for Lightning Service Providers (LSPs) was
[released][may lsp] in May.  Standards make it easy for a client to
connect to multiple LSPs, which will prevent vendor lock-in and improve
privacy.  The first specification released describes an API for allowing
a client to purchase a channel from an LSP, achieving a functionality
similar to [liquidity advertisements][topic liquidity advertisements].
The second describes an API for setting up and managing [just-in-time
(JIT) channels][topic jit channels]. {% assign timestamp="1:21:10" %}

- **Payjoin:** Dan Gould spent a significant part of the year working on enhancements
to the [payjoin][topic payjoin] protocol, a privacy-enhancing technique
that makes it much more difficult for a third party to reliably
associate inputs and outputs in a transaction with either the spender or
receiver.  In February, he [proposed][feb payjoin] a serverless payjoin
protocol that can be used even if the receiver doesn't operate an
always-on HTTPS server on a public network interface.  In May, he
[discussed][may payjoin] several advanced applications using payjoin,
including variations of payment cut-through; for example, rather than
Alice paying Bob, Alice instead pays Bob’s vendor (Carol), reducing a
debt he owes her (or pre-paying for an expected future bill)---this
saves block space and further improves privacy over standard payjoin.
In August, he posted a [draft BIP][aug payjoin] for serverless payjoin
which doesn't require the spender and receiver to be online at
the same time (although each of them will need to come online at least
once after the transaction is initiated before it can be broadcast).
Throughout the year, he was a top contributor to the [payjoin
development kit][jul pdk] (PDK) as well as the [payjoin-cli][dec
payjoin] project that provides an add-on for creating payjoins with
Bitcoin Core. {% assign timestamp="1:23:07" %}

- **Ark:** Burak Keceli [proposed][may ark] a new [joinpool][topic joinpools]-style protocol called
Ark, where Bitcoin owners can opt-in to use a counterparty as a
co-signer on all transactions within a certain time period. Owners can
either withdraw their bitcoins onchain after the expiry of the timelock
or instantly and trustlessly transfer them offchain to the counterparty
before the timelock expires. The protocol provides a trustless
single-hop, single-direction atomic transfer protocol from the owner to
the counterparty for various uses such as mixing coins, making internal
transfers, and paying LN invoices.  Concerns were raised about the high
onchain footprint and the need for the operator to keep a large amount
of funds in a hot wallet compared to LN.  However, several
developers remained enthusiastic about the proposed protocol and its
potential to provide a simple and trustless experience for its users. {% assign timestamp="1:27:40" %}

## June

{:#silentpayments}
- **Silent payments:** Josie Baker and Ruben Somsen [posted][jun sp] a draft BIP for [silent
payments][topic silent payments], a type of reusable payment code that
will produce a unique onchain address each time it is used, preventing
[output linking][topic output linking].  Output linking can
significantly reduce the privacy of users (including users not directly
involved in a transaction). The draft goes into detail about the
benefits of the proposal, its tradeoffs, and how software can
effectively use it.  Ongoing work implementing silent payments for
Bitcoin Core was also [discussed][aug sp] during a Bitcoin Core PR
Review Club meeting. {% assign timestamp="1:30:33" %}

<div markdown="1" class="callout" id="security">

### Summary 2023: Security disclosures

{% assign timestamp="1:32:34" %}

Optech reported on three significant security vulnerabilities this year:

- [Milk Sad vulnerability in Libbitcoin `bx`][aug milksad]: a widely
  undocumented lack of entropy in a command suggested for creating
  wallets ultimately led to the theft of a significant number of
  bitcoins across multiple wallets.

- [Fake funding denial-of-service against LN nodes][aug fundingdos]: a
  denial-of-service attack was privately discovered and [responsibly
  disclosed][topic responsible disclosures] reported by Matt Morehouse.
  All affected nodes were able to update and, as of this writing, we are
  unaware of the vulnerability being exploited.

- [Replacement cycling against HTLCs][oct cycling]: a fund-stealing
  attack against [HTLCs][topic htlc] used in LN and possibly other
  protocols was privately discovered and responsibly disclosed by
  Antoine Riard.  All LN implementations tracked by Optech deployed
  mitigations, although the effectiveness of those mitigations was a
  subject of discussion and other mitigations have been proposed.

</div>

## July

{:#vls}
- **Validating Lightning Signer:** The Validating Lightning Signer (VLS) project [released][jul vls] their
first beta version in July.  The project allows the separation of an LN
node from the keys that control its funds. An LN node running with VLS
will route signing requests to a remote signing device instead of local
keys. The beta release supports CLN and LDK, layer-1 and layer-2
validation rules, backup and recovery capabilities, and provides a
reference implementation. {% assign timestamp="1:36:10" %}

{:#ln-meeting}
- **LN developer meeting:** An LN developer [meeting][jul summit] held in July discussed a variety
of topics, including reliable transaction confirmation at the base
layer, [taproot][topic taproot] and [MuSig2][topic musig] channels,
updated channel announcements, [PTLCs][topic ptlc] and [redundant
overpayment][topic redundant overpayments], [channel jamming mitigation
proposals][topic channel jamming attacks], simplified commitments, and
the specification process.  Other LN discussions around the same time
included a [clean up][jul cleanup] of the LN specification to remove unused legacy
features and a [simplified protocol][jul lnclose] for closing channels. {% assign timestamp="1:38:00" %}

## August

- **Onion messages:** [Support][aug onion] for [onion messages][topic onion messages] was
added to the LN specification in August.  Onion messages allow sending
one-way messages across the network. Like payments ([HTLCs][topic
htlc]), the messages use onion encryption so that each forwarding node
only knows what peer it received the message from and what peer should
next receive the message. Message payloads are also encrypted so that
only the ultimate receiver can read it.  Onion messages use [blinded
paths][topic rv routing], which were added to the LN specification in
April, and onion messages are themselves used by the proposed [offers
protocol][topic offers]. {% assign timestamp="1:38:28" %}

{:#backup-proofs}
- **Outdated backup proofs:** Thomas Voegtlin [proposed][aug fraud] a protocol that would allow
penalizing providers for offering outdated backup states to users. This
service involves a simple mechanism where a user, Alice, backs up data
with a version number and signature to Bob. Bob adds a nonce and commits
to the complete data with a time-stamped signature. If Bob provides
outdated data, Alice can generate a fraud proof showing Bob previously
signed a higher version number.  This mechanism isn't Bitcoin-specific,
but incorporating certain Bitcoin opcodes could enable its use onchain.
In a Lightning Network (LN) channel, that would allow Alice to claim all
channel funds if Bob provided an outdated backup, thus reducing the risk
of Bob deceiving Alice and stealing her balance.  The proposal sparked
significant discussion.  Peter Todd pointed out its versatility beyond
LN and suggested a simpler mechanism without fraud proofs, while Ghost43
highlighted the importance of such proofs when dealing with anonymous
peers. {% assign timestamp="1:41:52" %}

{:#tapchan}
- **Simple taproot channels:** LND added [experimental support][aug lnd taproot] for "simple taproot
channels", allowing LN funding and commitment transactions to use
[P2TR][topic taproot] with support for [MuSig2][topic musig]-style
[scriptless multisignature signing][topic multisignature] when both
parties are cooperating.  This reduces transaction weight and
improves privacy when channels are closed cooperatively. LND continues
to exclusively use [HTLCs][topic htlc], allowing payments starting in a
taproot channel to continue to be forwarded through other LN nodes that
don’t support taproot channels. {% assign timestamp="1:44:39" %}

## September

{:#compressed-txes}
- **Compressed Bitcoin transactions:** In September, Tom Briar [published][sept compress] a draft specification
and implementation of compressed Bitcoin transactions. The proposal
addresses the challenge of compressing uniformly distributed data in
Bitcoin transactions by replacing integer representations with
variable-length integers, using block height and location to reference
transactions instead of their outpoint txid, and omitting public keys
from P2WPKH transactions. While the compressed format saves space,
converting it back into a usable format requires more CPU, memory, and
I/O than processing regular serialized transactions, which is an
acceptable tradeoff in situations such as broadcast by satellite or
steganographic transfer. {% assign timestamp="1:46:40" %}

<div markdown="1" class="callout" id="releases">

### Summary 2023: Major releases of popular infrastructure projects

 {% assign timestamp="1:48:19" %}

- [Eclair 0.8.0][jan eclair] added support for [zero-conf
  channels][topic zero-conf channels] and Short Channel IDentifier
  (SCID) aliases.

- [HWI 2.2.0][jan hwi] added support for [P2TR][topic taproot] keypath
  spends using the BitBox02 hardware signing device.

- [Core Lightning 23.02][mar cln] added experimental support for peer
  storage of backup data and updated experimental support for [dual
  funding][topic dual funding] and [offers][topic offers].

- [Rust Bitcoin 0.30.0][mar rb] provided a large number of API changes,
  along with the announcement of a new website.

- [LND v0.16.0-beta][apr lnd] provided a new major version of this
  popular LN implementation.

- [Libsecp256k1 0.3.1][apr secp] fixed an issue related to code that
  should have run in constant time but did not when compiled with Clang
  version 14 or higher.

- [LDK 0.0.115][apr ldk] included more support for the experimental
  [offers protocol][topic offers] and improved security and privacy.

- [Core Lightning 23.05][may cln] included support for [blinded
  payments][topic rv routing], version 2 [PSBTs][topic psbt], and more
  flexible feerate management.

- [Bitcoin Core 25.0][may bcc] added a new `scanblocks` RPC, simplified
  the use of `bitcoin-cli`, added [miniscript][topic miniscript] support
  to the `finalizepsbt` RPC, reduced default memory use with the
  `blocksonly` configuration option, and sped up wallet rescans when
  [compact block filters][topic compact block filters] are enabled.

- [Eclair v0.9.0][jun eclair] was a release that "contains a lot of
  preparatory work for important (and complex) lightning features:
  [dual-funding][topic dual funding], [splicing][topic splicing], and
  BOLT12 [offers][topic offers]."

- [HWI 2.3.0][jul hwi] added support for DIY Jade devices and a binary
  for running the main hwi program on Apple Silicon hardware with MacOS
  12.0+.

- [LDK 0.0.116][jul ldk] included support for [anchor outputs][topic
  anchor outputs] and [multipath payments][topic multipath payments]
  with [keysend][topic spontaneous payments].

- [BTCPay Server 1.11.x][aug btcpay] included improvements to invoice
  reporting, additional upgrades to the checkout process, and new
  features for the point-of-sale terminal.

- [BDK 0.28.1][aug bdk] added a template for using [BIP86][] derivation
  paths for [P2TR][topic taproot] in [descriptors][topic descriptors].

- [Core Lightning 23.08][aug cln] included the ability to change several node
  configuration settings without restarting the node, support for
  [codex32][topic codex32]-formatted seed backup and restore, a new
  experimental plugin for improved payment pathfinding, experimental
  support for [splicing][topic splicing], and the ability to pay
  locally-generated invoices.

- [Libsecp256k1 0.4.0][sep secp] added a module with an implementation
  of ElligatorSwift encoding, which would later be used for the [v2 P2P
  transport protocol][topic v2 p2p transport].

- [LND v0.17.0-beta][oct lnd] included experimental support for “simple
  taproot channels”, which allows using [unannounced channels][topic
  unannounced channels] funded onchain using a [P2TR][topic taproot]
  output. This is the first step towards adding other features to LND’s
  channels, such as support for Taproot Assets and [PTLCs][topic ptlc].
  The release also includes a significant performance improvement for
  users of the Neutrino backend, which uses [compact block
  filters][topic compact block filters], as well as improvements to
  LND’s built-in [watchtower][topic watchtowers] functionality.

- [LDK 0.0.117][oct ldk] included security bug fixes related to the
  [anchor outputs][topic anchor outputs] features included in the
  immediately prior release. The release also improved pathfinding,
  improved [watchtower][topic watchtowers] support, and enabled
  [batch][topic payment batching] funding of new channels.

- [LDK 0.0.118][nov ldk] included partial experimental support for the
  [offers protocol][topic offers].

- [Core Lightning 23.11][nov cln] provided additional flexibility to the
  _rune_ authentication mechanism, improved backup verification, and new
  features for plugins.

- [Bitcoin Core 26.0][dec bcc] included experimental support for the
  [version 2 transport protocol][topic v2 p2p transport], support for
  [taproot][topic taproot] in [miniscript][topic miniscript], new RPCs
  for working with states for [assumeUTXO][topic assumeutxo], and an
  experimental RPC for submitting [packages of transactions][topic
  package relay] to the local node's mempool.

</div>

## October

{:#pss}
- **Payment switching and splitting:** Gijs van Dam posted [research results and code][oct pss] about _payment
splitting and switching_ (PSS). His code allows nodes to split incoming
payments into [multiple parts][topic multipath payments], which can take
different routes before reaching the final recipient. For instance, a
payment from Alice to Bob could be partly routed through Carol. This
technique significantly hinders balance discovery attacks, where
attackers probe channel balances to track payments across the network.
Van Dam's research showed a 62% decrease in information gained by
attackers using PSS.  Additionally, PSS offers increased Lightning
Network throughput and may help mitigate [channel jamming attacks][topic
channel jamming attacks]. {% assign timestamp="1:49:46" %}

- **Sidepools:** Developer ZmnSCPxj [proposed][oct sidepool] a concept called _sidepools_
that aims to enhance LN's liquidity management. Sidepools involve
multiple forwarding nodes depositing funds into a multiparty offchain
state contract similar to LN channels. This allows funds to be
redistributed among participants offchain. For instance, if Alice, Bob,
and Carol each start with 1 BTC, the state can be updated so that Alice
has 2 BTC, Bob 0 BTC, and Carol 1 BTC.  Participants would still use and
advertise regular LN channels, and if those channels became imbalanced,
a rebalancing can be done through an offchain peerswap within the state
contract. This method is private to participants, requires less onchain
space, and likely eliminates offchain rebalancing fees, thus improving
revenue potential for forwarding nodes and reliability for LN payments.
However, it requires a multiparty state contract, which is untested in
production.  ZmnSCPxj suggests building on [LN-Symmetry][topic eltoo]
or duplex payment channels, both of which have advantages and
disadvantages. {% assign timestamp="1:51:30" %}

- **AssumeUTXO:** October saw the [completion][oct assumeutxo] of the first phase of the
[assumeUTXO project][topic assumeutxo], containing all the remaining
changes necessary to both use an assumedvalid snapshot chainstate and do
a full validation sync in the background. It makes UTXO snapshots
loadable via an RPC.  Although the feature set is not yet directly
usable by inexperienced users, this merge marked the culmination of a
multi-year effort. The project, proposed in 2018 and formalized in 2019,
will significantly improve the user experience of new full nodes first
coming onto the network. {% assign timestamp="1:55:28" %}

{:#p2pv2}
- **Version 2 P2P transport:** Also [accomplished][oct p2pv2] by the Bitcoin Core project in October was the
addition of support for [version 2 encrypted P2P transport][topic v2 p2p
transport] as specified in [BIP324][]. The feature is currently disabled
by default but can be enabled using the `-v2transport` option.
Encrypted transport helps improve the privacy of Bitcoin users by
preventing passive observers (such as ISPs) from directly determining
which transactions nodes relay to their peers. It’s also possible to use
encrypted transport to detect active man-in-the-middle observers by
comparing session identifiers. In the future, the addition of [other
features][topic countersign] may make it convenient for a lightweight
client to securely connect to a trusted node over a P2P encrypted
connection. {% assign timestamp="1:55:51" %}

- **Miniscript:** Miniscript descriptor support saw several additional improvements in
Bitcoin Core throughout the year.  February saw the
[ability][feb miniscript] to create miniscript descriptors for P2WSH
output scripts.  October saw miniscript support [updated][oct
miniscript] to support taproot, including miniscript descriptors for
tapscript. {% assign timestamp="1:57:18" %}

{:#statebitvm}
- **State compression and BitVM:** A method for state compression in Bitcoin using zero-knowledge validity
proofs was [described][may state] by Robin Linus and Lukas George in
May.  This massively reduces the amount of state that a client needs to
download in order to trustlessly verify future operations in a system,
for example starting a new full node with only a relatively small
validity proof rather than validating every already confirmed
transaction on the block chain.  In October, Robin Linus
[introduced][oct bitvm] BitVM, a method enabling bitcoins to be paid
contingent on the successful execution of an arbitrary program, without
requiring a consensus change in Bitcoin.  BitVM requires substantial
offchain data exchange but needs only a single onchain transaction for
agreement, or a small number of onchain transactions if there's a
dispute. BitVM makes complex trustless contracts possible even in
adversarial scenarios, which has caught the attention of several
developers. {% assign timestamp="2:00:07" %}

## November

- **Offers:** With the final specification of [blinded paths][topic rv routing] and
[onion messages][topic onion messages], and their implementation in
multiple popular LN nodes, a significant amount of progress was made
through this year in the development of the [offers protocol][topic offers]
that depends on them.  Offers allow a receiver's wallet to generate a
short _offer_ that can be shared with a spender's wallet.  The spender's
wallet can use the offer to contact the receiver's wallet over the LN
protocol to request a specific invoice, which it can then pay in the
usual way.  This allows the creation of reusable offers that can each
produce a different invoice, invoices that can be updated with current
information (e.g. the exchange rate) just seconds before they're paid,
and offers that can be paid by the same wallet more than once (e.g. a
subscription), among other features.  Existing experimental
implementations of offers in [Core Lightning][feb cln offers] and
[Eclair][feb eclair offers] were updated during the year, and support
for offers was added to [LDK][sept ldk offers].  Additionally, November
saw a [discussion][nov offers] about creating an updated version of
Lightning Addresses that is compatible with offers. {% assign timestamp="2:05:53" %}

{:#liqad}
- **Liquidity advertisements:** November also saw an [update][nov liqad] to the specification for
[liquidity advertisements][topic liquidity advertisements] that allow a
node to announce that it's willing to contribute some of its funds to a
new [dual-funded channel][topic dual funding] in exchange for a fee,
allowing the requesting node to quickly begin receiving incoming LN
payments.  The updates were mostly minor, although there was discussion
that [continued][dec liqad] into December about whether channels created
from a liquidity advertisement should contain a time lock.  A time lock
could give an incentive-based assurance to the buyer that they would
actually receive the liquidity they paid for, but the time lock could
also be used by a malicious or inconsiderate buyer to lock up an excess
amount of the provider's capital. {% assign timestamp="2:08:26" %}

<div markdown="1" class="callout" id="optech">

### Summary 2023: Bitcoin Optech

{% comment %}<!-- commands to help me create this summary for next year

wc -w _posts/en/newsletters/2023-* _includes/specials/policy/en/*
(1 book page = 350 words)

git log --diff-filter=A --since='1 year ago' --name-only --pretty=format: _topics/en | sort -u | wc -l

wget https://anchor.fm/s/d9918154/podcast/rss
Note: use vim to delete all podcasts before this year
grep duration rss | sed 's!^.*>\([0-9].*\):..</.*$!\1!' | sed 's/:/ * 60 + /' | bc -l | numsum | echo $(cat) / 60 | bc -l
-->{% endcomment %}

<style>
#optech ul {
    max-width: 800px;
    display: flex;
    flex-wrap: wrap;
    list-style: none;
    padding: 0;
    margin: 0;
    justify-content: center;
}

#optech li {
    flex: 1 0 180px;
    max-width: 180px;
    box-sizing: border-box;
    padding: 5px; /* Adjust as needed */
    margin: 5px; /* Adjust as needed */
    /* Additional styling here */
}

@media (max-width: 720px) {
    #optech li {
        flex-basis: calc(50% - 10px); /* 2 columns */
    }
}

@media (max-width: 360px) {
    #optech li {
        flex-basis: calc(100% - 10px); /* 1 column */
    }
}
</style>

{% assign timestamp="1:11" %}

In Optech's sixth year, we published 51 weekly [newsletters][],
published a 10-part [series about mempool policy][policy series], and
added 15 new pages to our [topics index][].  Altogether, Optech
published over 86,000 English words about Bitcoin software research and
development this year, the rough equivalent of a 250-page book.

In addition, every newsletter this year was accompanied by a [podcast][]
episode, totaling over 50 hours in audio form and 450,000 words in
transcript form.  Many of Bitcoin's top contributors were guests on the
show---some of them on more than one episode---with a total of 62
different unique guests in 2023:

- Abubakar Ismail
- Adam Gibson
- Alekos Filini
- Alex Myers
- Anthony Towns
- Antoine Poinsot
- Armin Sabouri
- Bastien Teinturier
- Brandon Black
- Burak Keceli
- Calvin Kim
- Carla Kirk-Cohen
- Christian Decker
- Clara Shikhelman
- Dan Gould
- Dave Harding
- Dusty Daemon
- Eduardo Quintana
- Ethan Heilman
- Fabian Jahr
- Gijs van Dam
- Gloria Zhao
- Gregory Sanders
- Henrik Skogstrøm
- Jack Ronaldi
- James O’Beirne
- Jesse Posner
- Johan Torås Halseth
- Joost Jager
- Josie Baker
- Ken Sedgwick
- Larry Ruane
- Lisa Neigut
- Lukas George
- Martin Zumsande
- Matt Corallo
- Matthew Zipkin
- Max Edwards
- Maxim Orlovsky
- Nick Farrow
- Niklas Gögge
- Olaoluwa Osuntokun
- Pavlenex
- Peter Todd
- Pieter Wuille
- Robin Linus
- Ruben Somsen
- Russell O’Connor
- Salvatore Ingala
- Sergi Delgado Segura
- Severin Bühler
- Steve Lee
- Steven Roose
- Thomas Hartman
- Thomas Voegtlin
- Tom Briar
- Tom Trevethan
- Valentine Wallace
- Vivek Kasarabada
- Will Clark
- Yuval Kogman
- ZmnSCPxj

Optech also published two contributed field reports from the business
community: one from Brandon Black at BitGo about [implementing
MuSig2][] for reducing fee costs and improving privacy, and a second
report from Antoine Poinsot at Wizardsardine about [building software
with miniscript][].

[implementing musig2]: /en/bitgo-musig2/
[building software with miniscript]: /en/wizardsardine-miniscript/

</div>

## December

{:#clustermempool}
- **Cluster mempool:** Several Bitcoin Core developers [began][may cluster] working on a new
[cluster mempool][topic cluster mempool] design to
simplify mempool operations while maintaining the necessary transaction
ordering, where parent transactions must be confirmed before their
children.  Transactions are grouped into clusters, then split into
feerate-sorted chunks, ensuring that high feerate chunks are confirmed
first.  This allows the creation of block templates by simply choosing the
highest feerate chunks in the mempool, and eviction of transactions by
dropping the lowest feerate chunks.  This fixes some existing
undesirable behavior (e.g., where miners might lose out on fee revenue
due to suboptimal evictions) and may be able to improve other aspects of
mempool management and transaction relay in the future.  Archives of
their discussions were [published][dec cluster] in early December. {% assign timestamp="2:11:10" %}

- **Warnet:** December also saw the public [announcement][dec warnet announce] of a new
tool for launching a large number of Bitcoin nodes with a defined set of
connections between them (usually on a test network).  This can be used
to test behavior that's difficult to replicate using small numbers of nodes
or which would cause problems on public networks, such as known attacks
and propagation of gossiped information.  One [public example][dec
zipkin warnet] of using the tool was measuring the memory consumption of
Bitcoin Core before and after a proposed change. {% assign timestamp="2:13:12" %}

*We thank all of the Bitcoin contributors named above, plus the many
others whose work was just as important, for another incredible year of
Bitcoin development.  The Optech newsletter will return to its regular
Wednesday publication schedule on January 3rd.*

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[apr bitgo]: /en/bitgo-musig2/
[apr blinding]: /en/newsletters/2023/04/05/#bolts-765
[apr htlcendo]: /en/newsletters/2023/05/17/#testing-htlc-endorsement
[apr ldk]: /en/newsletters/2023/04/26/#ldk-0-0-115
[apr lnd]: /en/newsletters/2023/04/05/#lnd-v0-16-0-beta
[apr loop]: /en/newsletters/2023/05/24/#lightning-loop-defaults-to-musig2
[apr musig2 psbt]: /en/newsletters/2023/10/18/#proposed-bip-for-musig2-fields-in-psbts
[apr musig2]: /en/newsletters/2023/04/12/#bips-1372
[apr rgb]: /en/newsletters/2023/04/19/#rgb-update
[apr secp]: /en/newsletters/2023/04/12/#libsecp256k1-0-3-1
[apr signrpc]: /en/newsletters/2023/02/15/#lnd-7171
[apr splicing]: /en/newsletters/2023/04/12/#splicing-specification-discussions
[apr taproot channels]: /en/newsletters/2023/08/30/#lnd-7904
[apr watchtower]: /en/newsletters/2023/04/05/#watchtower-accountability-proofs
[aug antidos]: /en/newsletters/2023/08/09/#denial-of-service-dos-protection-design-philosophy
[aug bdk]: /en/newsletters/2023/08/09/#bdk-0-28-1
[aug btcpay]: /en/newsletters/2023/08/02/#btcpay-server-1-11-1
[aug cln]: /en/newsletters/2023/08/30/#core-lightning-23-08
[aug combo]: /en/newsletters/2023/08/30/#covenant-mashup-using-txhash-and-csfs
[aug fraud]: /en/newsletters/2023/08/23/#fraud-proofs-for-outdated-backup-state
[aug fundingdos]: /en/newsletters/2023/08/30/#disclosure-of-past-ln-vulnerability-related-to-fake-funding
[aug htlcendo]: /en/newsletters/2023/08/09/#htlc-endorsement-testing-and-data-collection
[aug lnd taproot]: /en/newsletters/2023/08/30/#lnd-7904
[aug milksad]: /en/newsletters/2023/08/09/#libbitcoin-bitcoin-explorer-security-disclosure
[aug onion]: /en/newsletters/2023/08/09/#bolts-759
[aug opreturn]: /en/newsletters/2023/08/09/#proposed-changes-to-bitcoin-core-default-relay-policy
[aug payjoin]: /en/newsletters/2023/08/16/#serverless-payjoin
[aug sp]: /en/newsletters/2023/08/09/#bitcoin-core-pr-review-club
[chatbtc]: https://chat.bitcoinsearch.xyz/
[dec bcc]: /en/newsletters/2023/12/06/#bitcoin-core-26-0
[dec cluster]: /en/newsletters/2023/12/06/#cluster-mempool-discussion
[dec liqad]: /en/newsletters/2023/12/13/#discussion-about-griefing-liquidity-ads
[dec payjoin]: /en/newsletters/2023/12/13/#payjoin-client-for-bitcoin-core-released
[dec warnet announce]: /en/newsletters/2023/12/13/#bitcoin-network-simulation-tool-warnet-announced
[dec zipkin warnet]: /en/newsletters/2023/12/06/#testing-with-warnet
[feb bitcoinsearch]: /en/newsletters/2023/02/15/#bitcoinsearch-xyz
[feb cln offers]: /en/newsletters/2023/02/08/#core-lightning-5892
[feb codex32]: /en/newsletters/2023/02/22/#proposed-bip-for-codex32-seed-encoding-scheme
[feb eclair offers]: /en/newsletters/2023/02/22/#eclair-2479
[feb htlcendo]: /en/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring
[feb lnflag]: /en/newsletters/2023/02/22/#ln-quality-of-service-flag
[feb miniscript]: /en/newsletters/2023/02/22/#bitcoin-core-24149
[feb op_vault2]: /en/newsletters/2023/03/08/#alternative-design-for-op-vault
[feb op_vault]: /en/newsletters/2023/02/22/#draft-bip-for-op-vault
[feb ord1]: /en/newsletters/2023/02/08/#discussion-about-storing-data-in-the-block-chain
[feb ord2]: /en/newsletters/2023/02/15/#continued-discussion-about-block-chain-data-storage
[feb payjoin]: /en/newsletters/2023/02/01/#serverless-payjoin-proposal
[feb storage]: /en/newsletters/2023/02/15/#core-lightning-5361
[jamming paper]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[jan bip329]: /en/newsletters/2023/01/25/#bips-1383
[jan eclair]: /en/newsletters/2023/01/04/#eclair-0-8-0
[jan hwi]: /en/newsletters/2023/01/18/#hwi-2-2-0
[jan inquisition]: /en/newsletters/2023/01/04/#bitcoin-inquisition
[jan op_vault]: /en/newsletters/2023/01/18/#proposal-for-new-vault-specific-opcodes
[jan potentiam]: /en/newsletters/2023/01/11/#non-interactive-ln-channel-open-commitments
[jul cleanup]: /en/newsletters/2023/07/12/#ln-specification-clean-up-proposed
[jul htlcendo]: /en/newsletters/2023/07/26/#channel-jamming-mitigation-proposals
[jul hwi]: /en/newsletters/2023/07/26/#hwi-2-3-0
[jul ldk]: /en/newsletters/2023/07/26/#ldk-0-0-116
[jul lnclose]: /en/newsletters/2023/07/26/#simplified-ln-closing-protocol
[jul pdk]: /en/newsletters/2023/07/19/#payjoin-sdk-announced
[jul summit]: /en/newsletters/2023/07/26/#ln-summit-notes
[jul vls]: /en/newsletters/2023/07/19/#validating-lightning-signer-vls-beta-announced
[jun eclair]: /en/newsletters/2023/06/21/#eclair-v0-9-0
[jun matt]: /en/newsletters/2023/06/07/#using-matt-to-replicate-ctv-and-manage-joinpools
[jun sp]: /en/newsletters/2023/06/14/#draft-bip-for-silent-payments
[jun specsf]: /en/newsletters/2023/06/28/#speculatively-using-hoped-for-consensus-changes
[mar cln]: /en/newsletters/2023/03/08/#core-lightning-23-02
[mar mpchan]: /en/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[mar rb]: /en/newsletters/2023/03/29/#rust-bitcoin-0-30-0
[may ark]: /en/newsletters/2023/05/31/#proposal-for-a-managed-joinpool-protocol
[may bcc]: /en/newsletters/2023/05/31/#bitcoin-core-25-0
[may cln]: /en/newsletters/2023/05/24/#core-lightning-23-05
[may cluster]: /en/newsletters/2023/05/17/#mempool-clustering
[may lsp]: /en/newsletters/2023/05/17/#request-for-feedback-on-proposed-specifications-for-lsps
[may matt]: /en/newsletters/2023/05/03/#matt-based-vaults
[may payjoin]: /en/newsletters/2023/05/17/#advanced-payjoin-applications
[may state]: /en/newsletters/2023/05/24/#state-compression-with-zero-knowledge-validity-proofs
[newsletters]: /en/newsletters/
[nov cln]: /en/newsletters/2023/11/29/#core-lightning-23-11
[nov cov]: /en/newsletters/2023/11/01/#continued-discussion-about-scripting-changes
[nov htlcagg]: /en/newsletters/2023/11/08/#htlc-aggregation-with-covenants
[nov ldk]: /en/newsletters/2023/11/01/#ldk-0-0-118
[nov liqad]: /en/newsletters/2023/11/29/#update-to-the-liquidity-ads-specification
[nov offers]: /en/newsletters/2023/11/22/#offers-compatible-ln-addresses
[oct assumeutxo]: /en/newsletters/2023/10/11/#bitcoin-core-27596
[oct bitvm]: /en/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[oct cycling]: /en/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs
[oct generic]: /en/newsletters/2023/10/25/#research-into-generic-covenants-with-minimal-script-language-changes
[oct ldk]: /en/newsletters/2023/10/11/#ldk-0-0-117
[oct lnd]: /en/newsletters/2023/10/04/#lnd-v0-17-0-beta
[oct miniscript]: /en/newsletters/2023/10/18/#bitcoin-core-27255
[oct op_cat]: /en/newsletters/2023/10/25/#proposed-bip-for-op-cat
[oct p2pv2]: /en/newsletters/2023/10/11/#bitcoin-core-28331
[oct pss]: /en/newsletters/2023/10/04/#payment-splitting-and-switching
[oct sidepool]: /en/newsletters/2023/10/04/#pooled-liquidity-for-ln
[oct txhash]: /en/newsletters/2023/10/11/#specification-for-op-txhash-proposed
[policy series]: /en/blog/waiting-for-confirmation/
[sep lnscale]: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability
[sep secp]: /en/newsletters/2023/09/06/#libsecp256k1-0-4-0
[sept compress]: /en/newsletters/2023/09/06/#bitcoin-transaction-compression
[sept ldk offers]: /en/newsletters/2023/09/20/#ldk-2371
[sept tapassets]: /en/newsletters/2023/09/13/#specifications-for-taproot-assets
[tapsim]: /en/newsletters/2023/06/21/#tapscript-debugger-tapsim
[tldr]: https://tldr.bitcoinsearch.xyz/
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /en/newsletters/2021/12/22/
[yirs 2022]: /en/newsletters/2022/12/21/
