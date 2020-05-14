---
title: 'Bitcoin Optech Newsletter #78: 2019 Year-in-Review Special'
permalink: /en/newsletters/2019/12/28/
name: 2019-12-28-newsletter
slug: 2019-12-28-newsletter
type: newsletter
layout: newsletter
lang: en

excerpt: >
  This special edition of the Optech Newsletter summarizes notable
  developments in Bitcoin during all of 2019.
---
{{page.excerpt}} It's the sequel to our [2018 summary][].

{% comment %}
  ## Commits
  $ for d in bitcoin/ c-lightning/ eclair/ lnd/ secp256k1/ bips/ lightning-rfc/ ; do
    cd $d ; git log --oneline --since=2019-01-01 upstream/master | wc -l ; cd -
  done | numsum
  8863

  ## Merges
  $ for d in bitcoin/ c-lightning/ eclair/ lnd/ secp256k1/ bips/ lightning-rfc/ ; do
    cd $d ; git log --oneline --merges --since=2019-01-01 upstream/master | wc -l ; cd -
  done | numsum
  1988

  ## Mailing list posts
  $ for d in .lists.bitcoin-devel/ .lists.lightning/ ; do
    find $d -type f | xargs -i sed -n '1,/^$/p' '{}' | grep '^Date: .* 2019 ' | wc -l
  done | numsum
  1529

  ## Newsletter words; divide by 350 to get pages
  #
  ## Note, doesn't include this summary
  $ cd _posts/en/newsletters   # end italics_
  $ find 2019-* | xargs wc -w | tail -n1   # end italics*
  72450 total
{% endcomment %}

This summary is based heavily on our [weekly newsletters][] from the past
year for which we reviewed almost 9,000 commits (nearly 2,000 merges),
over 1,500 mailing list posts, many thousands of lines of IRC logs, and
numerous other public sources.  It took us 50 newsletter issues and over 200 printed pages worth
of content to summarize all that amazing work originally.
Even then, we missed many important contributions, especially from
people fixing bugs, writing tests, performing reviews, and providing
support---work that's critical but not necessarily "newsworthy."  In
summarizing even further and trying to compress the entire year into
this article's handful of pages, we've now also omitted a great many
other important contributions.

So, before we continue, we want to extend our heartfelt thanks to
everyone who contributed to Bitcoin in 2019.  Even if the following
summary doesn't mention you or one of your projects, please know that we
at Optech---and probably all Bitcoin users---are more grateful than
words can express for all that you've done to help Bitcoin.

## Contents

* January
    * [BIP127 proof of reserves](#bip127)
* February
    * [Bitcoin Core compatible with HWI](#core-hwi)
    * <a href="#miniscript">Miniscript</a>
* March
    * [Consensus cleanup soft fork proposal](#cleanup)
    * <a href="#signet">Signet</a>
    * [Lightning Loop](#loop)
* April
    * <a href="#assumeutxo">AssumeUTXO</a>
    * [Trampoline payments](#trampoline)
* May
    * <a href="#taproot">Taproot</a>
    * [SIGHASH_ANYPREVOUT](#anyprevout)
    * [OP_CHECKTEMPLATEVERIFY](#ctv)
* June
    * [Erlay and other P2P relay improvements](#erlay-and-other-p2p-improvements)
    * <a href="#watchtowers">Watchtowers</a>
* July
    * [Reproducible builds](#reproducibility)
* August
    * [Vaults without covenants](#vaults)
* September
    * <a href="#snicker">SNICKER</a>
    * [LN vulnerability](#ln-cve)
* October
    * [LN anchor outputs](#anchor-outputs)
* November
    * <a href="#bech32-mutability">Bech32 mutability</a>
    * [Bitcoin Core OpenSSL removal](#openssl)
    * [Bitcoin Core BIP70 removal](#bip70)
* December
    * [Multipath payments](#multipath)
* Featured summaries
    * [Major releases of popular infrastructure projects](#releases)
    * [Notable technical conferences and other events](#conferences)
    * [Bitcoin Optech](#optech)
    * [New open source infrastructure solutions](#new-infrastructure)

## January

{:#bip127}
In January, Steven Roose [proposed][roose reserves] a standardized format
for *proof of reserves* pseudo-transactions that bitcoin custodians can
use to generate evidence that they control a certain number of bitcoins.
No tool of this type can
guarantee that depositors will be able to withdraw their coins from a
custodian, but it can make it more difficult for a custodian to conceal the
loss or theft of coins.  Roose would go on to produce a [tool][news33
reserves] based on Partially Signed Bitcoin Transactions ([PSBTs][topic
psbt]) for creating reserve proofs and would follow through to see the
specification published as [BIP127][].

## February

{:#core-hwi}
In February, Bitcoin Core's master development branch saw the merge of
the final set of PRs necessary for using it with the [Hardware Wallet
Interface (HWI)][topic hwi] Python library and command-line tool.  HWI
would later see its first stable release in March, see Wasabi Wallet add
support for it in [April][wasabi hwi], and see BTCPay add support for it via
a [side package][btcpayserver.vault] in November<!--
https://github.com/btcpayserver/btcpayserver/pull/1152 -->.  HWI makes
it easy for hardware wallets and software wallets to interact using a
combination of [output script descriptors][topic descriptors] and
Partially Signed Bitcoin Transactions ([PSBTs][topic psbt]).  The
increasing support in 2019 for standardized formats and APIs makes it
easier for users to choose the right combination of hardware and
software solutions for their needs rather than having to choose one
solution or another.

<div markdown="1" id="miniscript">
Also in February, Pieter Wuille gave a [presentation][wuille sbc
miniscript] during the [Stanford Blockchain Conference][] on
[miniscript][topic miniscript], a spin-off from his work on output
script descriptors.  Miniscript provides a structured representation of
Bitcoin scripts that simplifies automated analysis by software.  The
analysis can determine what data a wallet needs to supply in order to
satisfy the script (e.g. a signature or a hash preimage), how much
transaction data will be used by the script and the data that satisfies
it, and whether or not the script passes known consensus rules and
popular transaction relay policies.

In addition to miniscript, Wuille, Andrew Poelstra, and Sanket Kanjalkar also provided a
composable policy language that compiles down to miniscript (which
itself converts to Bitcoin Script).  With the policy language,
users can easily describe the conditions they want to be fulfilled
in order to spend their coins.  When multiple users want to share
control of a coin, the composability of the policy language makes it easy
to combine each user's own signing policies into a single script.

If widely adopted, miniscript could make it easier for different Bitcoin
systems to work together to sign a transaction, significantly reducing
the amount of custom code that needs to be written in order to integrate
wallet front-ends, LN nodes, coinjoin systems, multisig wallets,
consumer hardware wallets, industrial Hardware Signing Modules (HSMs), and
other software and hardware.

Wuille and his collaborators continued working on miniscript through the
year, subsequently [requesting community feedback][news61 miniscript
feedback] and [opening a PR][Bitcoin Core #16800] to add support to
Bitcoin Core.  Miniscript would also be used by LN developers in
December to [analyze and optimize][anchor miniscript] several new
scripts for upgraded versions of some of their onchain transactions.
</div>

## March

<div markdown="1" id="cleanup">
In March, Matt Corallo proposed the [consensus cleanup soft fork][topic
consensus cleanup] to eliminate potential problems in Bitcoin's
consensus code.  If adopted, the fixes would eliminate the [time warp
attack][], lower legacy Script's [worst case CPU usage][], make caching
transaction validation status more reliable, and eliminate a known (but
expensive) [attack against lightweight clients][news37 merkle tree
attacks].

Although parts of the proposal (such as the time-warp fix) seemed to
interest a variety of people, other parts of the proposal (such as fixes
for the worst case CPU usage and validity caching) received some
[criticism][news37 cleanup discussion].  Perhaps it was for that reason
that the proposal didn't make any obvious progress towards
implementation in the second half of the year.
</div>

<div markdown="1" id="signet">
March also saw Kalle Alm request initial feedback on [signet][topic
signet], which would eventually become [BIP325][].  The signet protocol
allows creating testnets where all valid new blocks must be signed by a
centralized party.  Although this centralization would be antithetical to
Bitcoin, it's ideal for a testnet where testers sometimes want to create
a disruptive scenario (such as a chain reorganization) and other times
just want a stable platform to use for testing software interoperation.
On Bitcoin's existing testnet, reorgs and other disruptions can occur
frequently and for prolonged lengths of time, making regular testing
impractical.

Signet would mature throughout the year and eventually be
[integrated][cl signet] into software such as C-Lightning as well as
used for a demonstration of [eltoo][].  A [pull request][Bitcoin Core
#16411] adding support to Bitcoin Core remains open.
</div>

{:#loop}
Additionally in March, Lightning Labs announced [Lightning Loop][],
providing a non-custodial solution for users who want to withdraw
some of their funds from a LN channel to an onchain UTXO without closing
the channel.  In June, they would [upgrade][loop-in] Loop to also allow
users to spend a UTXO into an existing channel.  Loop uses Hash Time
Locked Contracts (HTLCs) similar to those used by regular offchain LN
transactions, ensuring that a user's funds are either transferred as
expected or that the user receives a refund of all costs except for any
onchain transaction fees.  This makes Loop almost completely trustless.

<div markdown="1" class="callout" id="releases">
### 2019 summary<br>Major releases of popular infrastructure projects

- [C-Lightning 0.7][] released in March added a plugin system that
  would see heavy use by the end of the year.  It was also the
  first C-Lightning release supporting [reproducible builds][topic
  reproducible builds] for increased safety through improved
  auditability.

- [LND 0.6-beta][] released in April included support for [Static Channel
  Backups (SCBs)][lnd scb] that help users recover any funds settled in their LN
  channels even if they've lost their recent channel state.  The release also
  featured an improved autopilot to help users open new channels, plus
  built-in compatibility with [Lightning Loop][] for moving funds
  onchain without closing a channel or using a custodian.

- [Bitcoin Core 0.18][] released in May improved Partially Signed
  Bitcoin Transaction ([PSBT][topic psbt]) support and added support for
  [output script descriptors][topic descriptors].  The
  combination of those two features allowed it to be used with the first
  released version of the Hardware Wallet Interface ([HWI][]).

- [Eclair 0.3][] released in May improved backup safety, added support
  for plugins, and made it possible to run as a Tor hidden service.

- [LND 0.7-beta][] released in July added support for using a
  [watchtower][topic watchtowers] to guard your channels when you're
  offline.

- [LND 0.8-beta][] released in October added support for a more
  extensible onion format, improved backup safety, and improved the
  watchtower support.

- [Bitcoin Core 0.19][] released in November implemented the new [CPFP
  carve-out][topic cpfp carve out] mempool policy, added initial support
  for [BIP158][]-style [compact block filters][topic compact block
  filters] (currently RPC only), improved security by
  disabling protocols such as [BIP37][] bloom filters and
  [BIP70][] payment requests by default.  It also switches GUI users to bech32
  addresses by default.

- [C-Lightning 0.8][] released in December added support for [multipath
  payments][topic multipath payments] and switched its default network to
  mainnet from testnet.  It was also the first major C-Lightning release
  to support alternative databases, with postgresql support available in
  addition to the default sqlite support.

</div>

## April

{:#assumeutxo}
In April, James O’Beirne proposed [AssumeUTXO][topic assumeutxo], a
method for allowing full nodes to defer verification of old block chain
history by downloading and temporarily using a trusted copy of the
recent UTXO set.  This would allow wallets and other software using the
full node to start receiving and sending transactions within minutes of
the node being started instead of having to wait hours or days, as is
the case now for a newly started node.  AssumeUTXO proposes that the
node download and verify the old block chain history in the
background until it eventually verified its initial UTXO state, allowing
it to ultimately obtain the same trustless security as a node that
doesn't use AssumeUTXO.  O'Beirne would continue working on the project
throughout the year, incrementally adding [new features][dumptxoutset]
and refactoring existing code on the path towards a goal of ultimately
adding AssumeUTXO to Bitcoin Core.

<div markdown="1" id="trampoline">
Also in April, Pierre-Marie Padiou [proposed][trampoline proposed] the idea of [trampoline payments][topic
trampoline payments], a method for allowing lightweight LN nodes to
outsource pathfinding to heavyweight routing nodes.  A lightweight
node, such as a mobile app, might not keep track of the full LN routing
graph, making it unable to find routes to other nodes.  Padiou's
proposal would allow the lightweight node to route the payment to a
nearby node and then have that node calculate the rest of the path.  In
essence, the payment would bounce off the trampoline node on the way
to its destination.  To add privacy, the original spender might require
the payment bounce off several trampoline nodes in sequence so that
none of them know whether or not it was routing the payment to the final
recipient or just another trampoline node.

A [PR][trampolines pr] adding features for trampoline payments to the LN
specification is currently open and the Eclair implementation of LN has
added [experimental support][exp tramp] for relaying trampoline payments.
</div>

## May

<div markdown="1" id="taproot">
In May, Pieter Wuille proposed a [taproot soft fork][topic taproot]
consisting of [bip-taproot][] and [bip-tapscript][] (which both depend
on last year's [bip-schnorr][] proposal).  If implemented, this change
will allow single-sig, multisig, and many contracts to all use the same
style of scriptPubKeys.  Many spends from multisigs and complex
contracts will also look identical to each other and single-sig spends.
This can significantly improve user privacy and coin fungibility while
also reducing the amount of block chain space used by multisig and
contract use cases.

Even in cases where multisig and contract spends can't take full
advantage of taproot's privacy and space savings, they still may only
need to put a subset of their code onchain, giving them more privacy and
space savings than they have today.  In addition to taproot,
[tapscript][topic tapscript] brings small refinements to Bitcoin's
scripting capabilities, mainly by making it easier and cleaner to add
new opcodes in the future.

The proposals received significant discussion and review throughout the
rest of the year, including through a series of [group review sessions][taproot
review] organized by Anthony Towns that had more than 150 people sign up
to help review.
</div>

<div markdown="1" id="anyprevout">
Towns also proposed in May two new signature hashes to be used in
combination with tapscript, `SIGHASH_ANYPREVOUT` and
`SIGHASH_ANYPREVOUTANYSCRIPT`.  A signature hash (sighash) is the hash
of a transaction's fields and related data to which a signature commits.  Different
sighashes in Bitcoin commit to different parts of a transaction, allowing
signers to optionally let other people make certain modifications to
their transactions.  The two new proposed sighashes function similar to
[BIP118][]'s [SIGHASH_NOINPUT][topic sighash_noinput] by deliberately not
identifying which UTXO they spend, allowing the signature
to spend any UTXO whose script it can fulfill (e.g. that uses the same
pubkey).

The primary suggested use for noinput-style sighashes is to enable the
previously proposed [eltoo][topic eltoo] update layer for LN.
Eltoo can simplify several aspects of channel construction and
management; it's especially desirable for simplifying [channels
involving more than two participants][topic channel factories] that can
significantly reduce onchain channel costs.
</div>

<div markdown="1" id="ctv">
A third soft fork proposed this month came from Jeremy Rubin, who
[described][coshv] a new opcode now called `OP_CHECKTEMPLATEVERIFY`
(CTV).  This would allow a limited form of [covenant][topic covenants]
where an output of one transaction would require a subsequent transaction
spending it to contain certain other outputs.  A suggested use for this
would be committed future payments where a spender pays a single small
output that can only be spent using a transaction (or a tree of
transactions) that later pays dozens, hundreds, or even thousands of
different receivers.  This could enable new techniques to enhance
coinjoin-style privacy, support security-enhancing vaults, or
manage spender costs when transaction feerates spike.

Rubin would continue working on CTV for the remainder of the year,
including opening PRs ([1][Bitcoin Core #17268], [2][Bitcoin Core #17292]) for improvements to parts
of Bitcoin Core where optimizations could make a deployed version of CTV
more effective.
</div>

<div markdown="1" class="callout" id="conferences">
### 2019 summary<br>Notable technical conferences and other events

- [Stanford Blockchain Conference][], January, Stanford University
- [MIT Bitcoin Expo][], March, MIT
- [Optech Executive Briefing][], May, New York City
- [Magical Crypto Friends (technical track)][mcf], May, New York City
- [Breaking Bitcoin][], June, Amsterdam
- [Bitcoin Core developers meetup][coredevtech amsterdam], June, Amsterdam
- [Edge Dev++][], September, Tel Aviv
- [Scaling Bitcoin][], September, Tel Aviv
- [Cryptoeconomic Systems Summit][], October, MIT
</div>

## June

<div markdown="1" id="erlay-and-other-p2p-improvements">
Gleb Naumenko, Pieter Wuille, Gregory Maxwell, Sasha Fedorova, and Ivan
Beschastnikh published a [paper][erlay] about [erlay][topic erlay],
a protocol for relaying unconfirmed transaction announcements between nodes
that makes use of [libminisketch-based][topic minisketch] set
reconciliation to produce an estimated 84% reduction in announcement
bandwidth.  The paper also demonstrates that erlay would make it much
more practical to significantly increase the default number of outbound
connections that nodes make.  This could improve each node's resistance to [eclipse
attacks][] that can trick it into accepting blocks not
on the most proof-of-work block chain.  More outbound connections also
improves node resistance against other attacks that
could be used to track or delay payments originating from the node.
Work on erlay would continue through the year with additional research
and the proposal of [BIP330][] for the set reconciliation protocol.

Other improvements made in P2P relay this year included Bitcoin Core's
[privacy improvements for transaction relay][#14897] (eliminating a
problem described in the [TxProbe][] paper by Sergi Delgado-Segura and
others) and the addition of [two extra outbound connections][] used only
for the relay of new blocks, improving resistance against eclipse
attacks.
</div>

<div markdown="1" id="watchtowers">
After a significant amount of prior work, June also saw the
[merge][altruist watchtowers] of altruist [LN watchtowers][topic
watchtowers] into LND.  Altruist watchtowers don't receive any reward
via the protocol for helping to secure their client's channels, so a
user needs to run their own watchtower or depend on the charity of a watchtower
operator, but this is enough to demonstrate that watchtowers can reliably send
penalty transactions on behalf of other users---ensuring that users who
go offline for significant amounts of time don't lose any money.

Altruist watchtowers would eventually be released in [LND
0.7.0-beta][lnd 0.7-beta] and would see additional development through
the remainder of the year, including a [proposed
specification][watchtower spec] and [discussion][eltoo watchtowers]
about how they could be combined with next-generation payment channels
such as [eltoo][topic eltoo].
</div>

## July

<div markdown="1" id="reproducibility">
In July, the Bitcoin Core project [merged][guix merge] Carl Dong's PR adding
support for reproducible builds of Bitcoin Core's Linux binaries using
GNU Guix (pronounced "geeks").  Although Bitcoin Core has long provided
support for reproducible builds using the [Gitian][] system, it can be
difficult to set up and it depends on the security of several hundred
Ubuntu packages.  By comparison, Guix can be much easier to install and
run, and builds of Bitcoin Core using it currently depend on a much
smaller number of packages.  In the long term, contributors to Guix are
also working on eliminating the [trusting trust][] problem to make it
easy for users to verify that binaries such as `bitcoind` are derived
solely from auditable source code.

Work continued on Guix build support throughout the year, with some
contributors hopeful that Guix will be used for the first major version
of Bitcoin Core released in 2020 (perhaps in parallel with the older
Gitian-based mechanism).

Independently, documentation was added this year to both the
[C-Lightning][cl repro] and [LND][lnd repro] repositories describing how
to create reproducible builds of their software using trusted compilers.
</div>

## August

<div markdown="1" id="vaults">
In August, Bryan Bishop described a method for implementing [vaults on
Bitcoin without using covenants][].  *Vaults* is a term used to describe a
script that limits an attacker's ability to steal funds even if they
obtain a user's normal private key.  A *[covenant][topic covenants]* is
a script that can only be spent to certain other scripts.  There's no
known way to create covenants using the current Bitcoin Script language,
but it turns out that they're not necessary if users are willing to run
code that performs a few extra steps when depositing their money into
the vault contract.

Perhaps more notably, Bishop described a new weakness in previous vault
proposals as well as a mitigation for the weakness that would limit the
maximum amount of funds that could be stolen from a vault by an
attacker.  The development of practical vaults could be useful for both
individual users and large custodial organizations such as exchanges.
</div>

<div markdown="1" class="callout" id="optech">
### 2019 summary<br>Bitcoin Optech

In Optech's second year, we signed up six new member companies, held an
[executive briefing][optech executive briefing] during NYC block chain
week, published a [24-week series][bech32 sending support] promoting
bech32 sending support, added a wallet and services [compatibility
matrix][] to our website, published 51 weekly [newsletters][]<!-- #28 to
#78, inclusive -->, saw several of our newsletters and blog posts translated into
languages such as [Japanese][xlation ja] and [Spanish][xlation es],
created a [topics index][], added a chapter to our [Scalability
Workbook][], hosted two [schnorr/taproot workshops][] with
publicly released [jupyter notebooks][], and published field reports
from [BTSE][] and [BRD][].

We have big plans for 2020, so we hope you'll continue to follow us on
[Twitter][], subscribe to our [weekly newsletter][], or track our [RSS
feed][].

</div>

## September

<div markdown="1" id="snicker">
Adam Gibson [proposed][snicker] a novel form of non-interactive
[coinjoin][topic coinjoin] for the existing Bitcoin system.  The
protocol, called SNICKER, involves a user selecting one of their UTXOs
and a randomly-selected UTXO from the global UTXO set to both be spent
in the same transaction.  The proposing user signs their part of this
transaction and uploads it in the Partially Signed Bitcoin Transaction
([PSBT][topic psbt]) format to a public server.  If the other user
checks the server and sees the PSBT, they can download it, sign it, and
broadcast it---completing the coinjoin without both users needing to be
online at the same time.  The proposing user can create and upload as
many PSBTs as they want using their same UTXO until some other user
accepts the coinjoin.

SNICKER's major advantages over other coinjoin approaches are that it
doesn't require the users be online at the same time and that it should
be easy to add support for it to any wallet that already has [BIP174][]
PSBT support, which is an increasing number of wallets.
</div>

{:#ln-cve}
Also in September, the maintainers of C-Lightning, Eclair, and LND
[disclosed][ln missed validation] a vulnerability that affected previous
versions of their software.  It appeared that, in some cases, each of
the implementations failed to confirm that channel funding transactions
paid the correct script or the correct amount (or both).  If exploited,
this could result in channel payments being impossible to confirm
onchain, making it possible for nodes to lose money by relaying payments
from an invalid channel to a valid channel.  Optech is unaware of any
users who lost money before the first public announcements of the
vulnerability.  The LN specification was [updated][news67 bolts676] to
help future implementers avoid this problem and there's an expectation
that [other proposed changes][dual-funding serialization] to LN's
communication protocol will help avoid other failures of this type.

## October

<div markdown="1" id="anchor-outputs">
LN developers made significant progress in October and November towards
addressing a long-standing concern about ensuring that users can always
close their channels without excessive delays.  If a user decides that
they want to close one of their channels and they're unable to contact
their remote peer, they broadcast the latest *commitment transaction*
for that channel---a pre-signed transaction that spends the channel's
funds onchain to each party according to the latest version of their
offchain contract.  A potential problem with this arrangement is that
the commitment transaction was potentially created days or weeks earlier
when transaction fees were lower, so it may not pay a high enough fee to
confirm quickly before any security-essential time locks expire.

It's always been known that the solution to this problem is to make it
possible to fee bump commitment transactions.  Unfortunately, nodes such
as Bitcoin Core have to limit the use of fee bumping in order to prevent
Denial of Service (DoS) attacks that waste their bandwidth and CPU.  In
trustless multi-user protocols like LN, your counterparty might be an
attacker who could deliberately trigger the anti-DoS policy in order to
delay the confirmation of your LN commitment transaction, an attack
sometimes called [transaction pinning][topic transaction pinning].  A
pinned transaction may not confirm before its time locks expire,
allowing an attacking counterparty to steal funds from you.

Last year, Matt Corallo [suggested][carve-out proposed] carving out a
special exemption from the part of Bitcoin Core's transaction relay
policy related to Child-Pays-For-Parent (CPFP) fee bumping.  This
limited exemption ensures that two-party contract protocols (such as
current-generation LN) can guarantee each party the ability to create
their own fee bump.  Corallo's idea was named [CPFP carve-out][topic
cpfp carve out] and his implementation of it was released as part of
Bitcoin Core 0.19.  Even before that release, other LN developers worked
on the [revisions][anchor outputs] to the LN scripts and protocol
messages necessary to start using the change.  As of this writing, those
specification changes are awaiting final implementation and acceptance
before seeing deployment on the network.
</div>

<div markdown="1" class="callout" id="new-infrastructure">
### 2019 summary<br>New open source infrastructure solutions

- [Proof of reserves tool][] released in February allows exchanges and
  other bitcoin custodians to prove they have control over a certain
  set of UTXOs using [BIP127][] reserve proofs.

- [Hardware Wallet Interface][topic hwi] released in March makes it easy
  for a wallet already compatible with Partially Signed Bitcoin
  Transactions ([PSBTs][topic psbt]) and [output script descriptors][topic
  descriptors]
  to use several different models of hardware wallets for secure key
  storage and signing.

- <a href="/en/newsletters/2019/03/26/#loop-announced">Lightning Loop</a> released in March (with loop-in support added in
  June) provides a non-custodial service that allows users to add or
  remove funds from their LN channels without closing existing channels
  or opening new channels.
</div>

## November

<div markdown="1" id="bech32-mutability">
Discussion in November about using bech32 addresses for [taproot][topic
taproot] payments brought additional attention to an [issue][bech32
malleability issue] discovered in May.  According to [BIP173][],
mis-copied bech32 strings are supposed to have a worst-case failure rate
of about 1-in-a-billion.  However, it was discovered that bech32 strings
ending with a `p` could have any number of preceding `q` characters
added or removed.  This doesn't practically affect bech32 addresses for
segwit P2WPKH or P2WSH addresses, as at least 19 consecutive `q`
characters would need to be added or removed in order to transform one
address type into another---and any other length change for v0 segwit
addresses would be invalid.  <!-- "19 characters" math in
_posts/en/newsletters/2019-11-13-newsletter.md -->

But that's not the case for v1+ segwit addresses, such as those proposed for taproot, where a
single added or removed `q` character in a vulnerable address could lead
to a loss of funds.  BIP173 co-author Pieter Wuille performed
[additional analysis][bech32 analysis] and found that this was the only
deviation from bech32's expected error correction ability, so he
proposed limiting the use of BIP173 addresses in Bitcoin to only 20
byte or 32 byte witness programs.  This will ensure that v1 and subsequent segwit
address versions provide the same reliable error correction as v0 segwit
addresses.  He also described a small tweak to the bech32 algorithm that
will allow other applications using bech32, as well as next-generation
Bitcoin address formats, to use BCH error detection without this
problem.
</div>

{:#openssl}
Also in November, Bitcoin Core [removed its dependency on OpenSSL][rm
openssl], which had been part of its codebase since the original 2009
release of Bitcoin 0.1.  OpenSSL was the cause of [consensus
vulnerabilities][non-strict der], [remote memory leaks][heartbleed]
(potential private key leaks), [other bugs][cve-2014-3570], and [poor
performance][libsecp256k1 sig speedup].  It's hoped that its removal
will reduce the frequency of future vulnerabilities.

{:#bip70}
As part of the OpenSSL removal, Bitcoin Core deprecated its support for
the [BIP70][] payment protocol in version 0.18, and later disabled
support by default in version 0.19.  This decision was [supported][ceo
bitpay] by the CEO of one of the few companies that continued to use
BIP70 in 2019.

## December

{:#multipath}
In December, LN developers achieved one of their major goals from last
year's [planning meeting][ln1.1]: the [implementation][mpp
implementation] of basic [multipath payments][topic multipath payments].
These are payments that can be split into several parts, with each part
being routed separately through different channels.  This allows users
to spend or receive money using more than one of their channels at a
time, making it possible to spend their full offchain balance or receive
up to their full capacity in a single payment (within the limitations of
certain safety restrictions).  <!-- safety restrictions: non-wumbo and
channel reserve funding --> It's expected that this will make LN
significantly more user-friendly by eliminating the need for spenders to
worry about the balances of specific channels.

## Conclusion

In the summary above, we see no revolutionary proposals or improvements.
Instead, we see a flurry of incremental improvements---solutions that
take cases where Bitcoin and LN are already successful and build on them
to make the system even better.  We see developers working to make
hardware wallets more accessible (HWI), generalize communication between
wallets for multisig and contract use cases (descriptors, PSBTs,
miniscript), strengthen consensus security (cleanup soft fork), simplify
testing (signet), eliminate unnecessary custody (loop), make it easier
to start running a node (assumeutxo), improve privacy and save block
space (taproot), simplify LN enforcement (anyprevout), better manage
feerate spikes (CTV), reduce node bandwidth (erlay), keep LN users safe
when offline (watchtowers), reduce the need for trust (reproducible
builds), prevent thefts (vaults), make privacy more accessible (SNICKER), better
manage onchain fees for LN users (anchor outputs), and make LN payments
automatically work more often (multipath payments).

(And those are just the highlights for the year!)

We can only guess what Bitcoin contributors will accomplish next year,
but we suspect it will be more of the same---dozens of modest changes
that each make the system better without breaking it for anyone who's
already satisfied.

*The Optech newsletter will return to its regular Wednesday publication
schedule on January 8th.*

{% include references.md %}
{% include linkers/issues.md issues="16800,16411,17268,17292" %}
[#14897]: /en/newsletters/2019/02/12/#bitcoin-core-14897
[2018 summary]: /en/newsletters/2018/12/28/
[altruist watchtowers]: /en/newsletters/2019/06/19/#lnd-3133
[anchor miniscript]: https://github.com/lightningnetwork/lightning-rfc/pull/688#pullrequestreview-326862133
[anchor outputs]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[bech32 analysis]: /en/newsletters/2019/12/18/#analysis-of-bech32-error-detection
[bech32 malleability issue]: https://github.com/sipa/bech32/issues/51
[bech32 sending support]: /en/bech32-sending-support/
[bitcoin core 0.18]: /en/newsletters/2019/05/07/#bitcoin-core-0-18-0-released
[bitcoin core 0.19]: /en/newsletters/2019/11/27/#bitcoin-core-0-19-released
[brd]: /en/newsletters/2019/08/07/#bech32-sending-support
[breaking bitcoin]: /en/newsletters/2019/06/19/#breaking-bitcoin
[btcpayserver.vault]: https://github.com/btcpayserver/BTCPayServer.Vault
[btse]: /en/btse-exchange-operation/
[carve-out proposed]: /en/newsletters/2018/12/04/#cpfp-carve-out
[ceo bitpay]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[c-lightning 0.7]: /en/newsletters/2019/03/05/#upgrade-to-c-lightning-0-7
[c-lightning 0.8]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.0
[cl repro]: https://github.com/ElementsProject/lightning/blob/master/doc/REPRODUCIBLE.md
[cl signet]: /en/newsletters/2019/07/24/#c-lightning-2816
[coredevtech amsterdam]: /en/newsletters/2019/06/12/#bitcoin-core-contributor-meetings
[coshv]: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments
[cryptoeconomic systems summit]: /en/newsletters/2019/10/16/#conference-summary-cryptoeconomic-systems-summit
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[dual-funding serialization]: https://twitter.com/rusty_twit/status/1179976386619928576
[dumptxoutset]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[eclair 0.3]: https://github.com/ACINQ/eclair/releases/tag/v0.3
[eclipse attacks]: https://eprint.iacr.org/2015/263.pdf
[edge dev++]: /en/newsletters/2019/09/18/#bitcoin-edge-dev
[eltoo watchtowers]: /en/newsletters/2019/12/11/#watchtowers-for-eltoo-payment-channels
[exp tramp]: /en/newsletters/2019/11/20/#eclair-1209
[gitian]: https://github.com/devrandom/gitian-builder
[guix merge]: /en/newsletters/2019/07/17/#bitcoin-core-15277
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[jupyter notebooks]: https://github.com/bitcoinops/taproot-workshop#readme
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation
[lightning loop]: /en/newsletters/2019/03/26/#loop-announced
[ln1.1]: /en/newsletters/2018/11/20/#feature-news-lightning-network-protocol-11-goals
[lnd 0.6-beta]: /en/newsletters/2019/04/23/#lnd-0-6-beta-released
[lnd 0.7-beta]: /en/newsletters/2019/07/03/#lnd-0-7-0-beta-released
[lnd 0.8-beta]: /en/newsletters/2019/10/16/#upgrade-lnd-to-version-0-8-0-beta
[lnd repro]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[lnd scb]: /en/newsletters/2019/04/09/#lnd-2313
[ln missed validation]: /en/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[loop-in]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[mcf]: /en/newsletters/2019/05/21/#talks-of-technical-interest-at-magical-crypto-friends-conference
[mit bitcoin expo]: /en/newsletters/2019/03/19/#mit-bitcoin-club-2019-expo-videos-available
[mpp implementation]: /en/newsletters/2019/12/18/#ln-implementations-add-multipath-payment-support
[news33 reserves]: /en/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[news37 cleanup discussion]: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[news37 merkle tree attacks]: /en/newsletters/2019/03/05/#merkle-tree-attacks
[news61 miniscript feedback]: /en/newsletters/2019/08/28/#miniscript-request-for-comments
[news67 bolts676]: /en/newsletters/2019/10/09/#bolts-676
[newsletters]: /en/newsletters/
[non-strict der]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[optech executive briefing]: /en/2019-exec-briefing/
[proof of reserves tool]: /en/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[rm openssl]: /en/newsletters/2019/11/27/#bitcoin-core-17265
[roose reserves]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016633.html
[scalability workbook]: https://github.com/bitcoinops/scaling-book
[scaling bitcoin]: /en/newsletters/2019/09/18/#scaling-bitcoin
[schnorr/taproot workshops]: /en/schorr-taproot-workshop/
[snicker]: /en/newsletters/2019/09/04/#snicker-proposed
[stanford blockchain conference]: /en/newsletters/2019/02/05/#notable-talks-from-the-stanford-blockchain-conference
[sybil attacks]: https://en.wikipedia.org/wiki/Sybil_attack
[taproot review]: /en/newsletters/2019/10/23/#taproot-review
[time warp attack]: /en/newsletters/2019/03/05/#the-time-warp-attack
[topics index]: /en/topics/
[trampoline proposed]: /en/newsletters/2019/04/02/#trampoline-payments-for-ln
[trampolines pr]: /en/newsletters/2019/08/07/#trampoline-payments
[trusting trust]: https://www.archive.ece.cmu.edu/~ganger/712.fall02/papers/p761-thompson.pdf
[twitter]: https://twitter.com/bitcoinoptech/
[two extra outbound connections]: /en/newsletters/2019/09/11/#bitcoin-core-15759
[txprobe]: /en/newsletters/2019/09/18/#txprobe-discovering-bitcoin-s-network-topology-using-orphan-transactions
[vaults on bitcoin without using covenants]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[wasabi hwi]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v1.1.4
[watchtower spec]: /en/newsletters/2019/12/04/#proposed-watchtower-bolt
[weekly newsletter]: /en/newsletters/
[weekly newsletters]: /en/newsletters/
[worst case cpu usage]: /en/newsletters/2019/03/05/#legacy-transaction-verification
[wuille sbc miniscript]: /en/newsletters/2019/02/05/#miniscript
[xlation es]: https://bitcoinops.org/es/publications/
[xlation ja]: https://bitcoinops.org/ja/publications/
