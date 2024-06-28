---
title: 'Bitcoin Optech Newsletter #180: 2021 Year-in-Review Special'
permalink: /en/newsletters/2021/12/22/
name: 2021-12-22-newsletter
slug: 2021-12-22-newsletter
type: newsletter
layout: newsletter
lang: en

excerpt: >
  This special edition of the Optech Newsletter summarizes notable
  developments in Bitcoin during all of 2021.
---

{{page.excerpt}} It's the sequel to our summaries from [2018][2018
summary], [2019][2019 summary], and [2020][2020 summary].

## Contents

* January
  * [Signet in Bitcoin Core](#signet)
  * [Bech32m addresses](#bech32m)
  * [Onion messages and offers protocol](#offers)
* February
  * [Faster signature creation and verification](#safegcd)
  * [Channel jamming attacks](#jamming)
* March
  * [Quantum computing risks](#quantum)
* April
  * [LN atomic multipath payments](#amp)
* May
  * [BIP125 opt-in replace-by-fee discrepancy](#bip125)
  * [Dual funded channels](#dual-funding)
* June
  * [Candidate set based block construction](#csb)
  * [Default transaction replacement by fee](#default-rbf)
  * [Mempool package acceptance and package relay](#mpa)
  * [LN fast forwards for speed and offline receiving](#ff)
* July
  * [LN liquidity advertisements](#liq-ads)
  * [Output script descriptors](#descriptors)
  * [Zero-conf channel opens](#zeroconfchan)
  * [SIGHASH_ANYPREVOUT](#anyprevout)
* August
  * [Fidelity bonds](#fibonds)
  * [LN pathfinding](#pathfinding)
* September
  * [OP_TAPLEAF_UPDATE_VERIFY](#tluv)
* October
  * [Transaction heritage identifiers](#txhids)
  * [PTLCs and LN fast forwards](#ptlcsx)
* November
  * [LN developer summit](#lnsummit)
* December
  * [Advanced fee bumping](#bumping)
* Featured summaries
  * [Taproot](#taproot)
  * [Major releases of popular infrastructure projects](#releases)
  * [Bitcoin Optech](#optech)

## January

{:#signet}
After years of discussion, January saw the first [release][bcc21] of a
Bitcoin Core version supporting [signets][topic signet], following prior
[support][cl#2816] by C-Lightning and followed by [support][lnd#5025] in
LND.  Signets are test networks anyone can use to simulate Bitcoin's
main network (mainnet), either as it exists today or how it might exist
with certain changes (such as the activation of a soft fork consensus
change).  Most software implementing signets also supports a default
signet that provides a particularly convenient means for software
developed by different teams to be tested in a safe environment that
comes as close as possible to the environment they'll experience when
real money is at stake.  Also [discussed][signet reorgs] this year was
adding deliberate block chain reorganizations to Bitcoin Core's default signet network to help
developers test their software against that class of problems.

{:#bech32m}
A draft BIP for [bech32m][topic bech32] was also [announced][bech32 bip]
in January.  Bech32m addresses are a slight modification of bech32
addresses that make them safe for use with [taproot][topic taproot] and
future protocol extensions.  Later in the year, a [Bitcoin Wiki
page][bech32m page] was updated to track adoption of bech32m addresses
by wallets and services.

{:#offers}
Another [first release][cl 0.9.3] of a new protocol was [onion
messages][topic onion messages] and the [offers protocol][topic offers].
Onion messages allow an LN node to send a message to another node in a
way that minimizes overhead compared to [HTLC][topic htlc]-based message
sending.  Offers use onion messages to allow one node to *offer* to pay
another node, allowing the receiving node to return a detailed invoice
and other necessary information.  Onion messages and offers would
continue as draft specifications for the remainder of the year, but they
would receive additional development, including a proposal to use them
to [reduce the impact of stuck payments][offers stuck].

## February

{:#safegcd}
Contributors to Bitcoin [advanced][safegcd blog] the state of research
into an improved signature creation and verification algorithm, and then
used their research to produce a variation with additional improvements.
When implemented in libsecp256k1 ([1][secp831], [2][secp906]) and
[later][bcc21573] in Bitcoin Core, this reduced the amount of time it
takes to verify signatures by about 10%---a significant improvement when
verifying the roughly billion signatures in Bitcoin's block chain.
Several cryptographers worked on ensuring the change was mathematically
sound and safe to use.  The change also provides a significant boost to
the speed of securely creating signatures on low-powered hardware
signing devices.

{:#jamming}
[Channel jamming attacks][topic channel jamming attacks], a known
problem for LN since 2015, received continued discussion throughout the
year, with a [variety][jam1] of [possible][jam2] solutions
[discussed][jam3].  Unfortunately no widely accepted solution was found
and the problem remained unmitigated by year's end.

{:.center}
![Illustration of jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

## March

{:#quantum}
Significant [discussion][quant] in March was devoted to analyzing the
risk of quantum computer attacks on Bitcoin, particularly for the case
where taproot activated and became widely used.  One of Bitcoin's
original features, public key hashing---likely added to make Bitcoin addresses shorter---has
also likely made it harder to steal funds from a limited number of users
if there's a sudden major advance in quantum computing.  [Taproot][topic
taproot] doesn't provide this feature and at least one developer was
concerned that it created an unreasonable risk.  A large number of
counterarguments were presented and community support for taproot seemed
to be unchanged.

<div markdown="1" class="callout" id="taproot">

### 2021 summary<br>Taproot activation

By the end of 2020, an implementation of the [taproot][topic taproot]
soft fork containing support for [schnorr signatures][topic schnorr
signatures] and [tapscript][topic tapscript] had been
[merged][bcc#19953] into Bitcoin Core.  This largely completed the work
of protocol developers; it was now up to the community to activate
taproot if they wished, and for wallet developers to begin adding
support for it and related technology like [bech32m][topic bech32]
addresses.

{% comment %}<!-- comments in bold text below tweak auto-anchors to prevent ID conflicts -->{% endcomment %}

- **January<!--taproot-->** began with the [release][bcc21] of Bitcoin Core 0.21.0,
  which was the first release to contain support for [signets][topic
  signet], including the default signet where taproot had been
  activated---giving users and developers an easy place to start
  testing.

- **February<!--taproot-->** saw the [first][tapa1] of [many][tapa2] scheduled
  [meetings][tapa3] in the `##taproot-activation` IRC channel, which
  would become the primary hub for discussion among developers, users,
  and miners for how to activate taproot.

- **March<!--taproot-->** began with many discussion participants tentatively agreeing
  to [try][speedy trial] a particular activation approach named *speedy
  trial*, which was designed to gather rapid feedback from miners but also
  still give users sufficient time to upgrade their software for taproot
  enforcement.  Speedy trial would go on to become the actual
  [mechanism][topic soft fork activation] used to activate taproot.

  While activation discussions were underway, there was a final
  [discussion][quant] about one of its design decisions, using bare
  public keys, which was argued might put user funds at increased
  risk of being stolen by future quantum computers.  Many developers
  argued that the concerns were unwarranted or, at least, overblown.

  Also in March, Bitcoin Core merged support for [BIP350][], allowing
  it to pay to [bech32m][topic bech32] addresses.  This slight variation
  on the bech32 addresses that are used for payments to original
  segwit version addresses fixes a bug which could've caused taproot
  users to lose money in some very rare cases.  (Original segwit
  outputs created from bech32 addresses are safe and unaffected by the
  bug.)

  {% comment %}
  /en/newsletters/2021/03/03/#rust-lightning-794
  /en/newsletters/2021/03/10/#documenting-the-intention-to-use-and-build-upon-taproot
  /en/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
  /en/newsletters/2021/03/24/#bitcoin-core-20861
  /en/newsletters/2021/03/31/#should-block-height-or-mtp-or-a-mixture-of-both-be-used-in-a-soft-fork-activation-mechanism
  {% endcomment %}

- **April<!--taproot-->** almost saw activation progress derail as protocol developers
  and some users [debated][tapa4] the merits of two slightly different versions
  of the speedy trial activation mechanism.  However, the authors of
  different implementations of the two different versions came to a
  [compromise][bcc#21377] that allowed a Bitcoin Core [version][bcctap]
  to be released with an activation mechanism and parameters.

- **May<!--taproot-->** was when miners were [able][signal
  able] to [begin][signal began] signalling their readiness to enforce taproot and a website for
  tracking signaling progress became [popular][taproot.watch].

- **June<!--taproot-->** saw miners [lock-in taproot][lockin], committing to enforcing
  its activation an estimated six months later at block {{site.trb}}.
  This meant it was [time][rb#589] for [wallet developers][bcc#22051]
  and [other infrastructure developers][bolts#672] to [put][cl#4591]
  more [attention][bcc#21365] to [adapting][rb#601] their
  [software][p2trhd] for taproot, [which][bcc#22154] many of them
  [did][bcc#22166].  Additionally, a [proposal][nsequence default] was
  made that would allow onchain taproot wallets to easily contribute
  towards the privacy of wallets using various contract protocols like
  LN and [coinswaps][topic coinswap].  Optech also [began][p4tr begins]
  its [Preparing for Taproot][p4tr] series.

- **July<!--taproot-->** met with a Bitcoin Wiki [page][bech32m page] devoted to
  tracking support for the bech32m address format needed for wallets to
  be able to use taproot after its activation.  Many wallet and service
  developers rose to the occasion and ensured they would be ready to
  allow anyone to use taproot upon activation.  Other [soft fork
  proposals][bip118 update] were updated to use taproot or [lessons
  learned][bip119 update] from its activation.

- **August<!--taproot-->** was quiet for taproot development, although some
  [documentation][reuse risks] related to taproot was written.

- **September<!--taproot-->** saw Bitcoin's most popular open source merchant software
  add [support][btcpay taproot] for taproot in advance of its planned
  activation.  It also saw the [proposal][op_tluv] for a new opcode that
  would make special use of taproot features to enable script-based
  [covenants][topic covenants].

- **October<!--taproot-->** began with [renewed][rb#563] development
  [activity][rb#644] as taproot activation [approached][testing
  taproot].  Taproot's BIP was updated with [expanded test vectors][] to
  help wallet and infrastructure developers verify their
  implementations.

- **November<!--taproot-->** celebrated [taproot activation][].  There was some
  initial confusion as the miners of block {{site.trb}} and several
  subsequent blocks didn't include any taproot-spending transactions.
  However, thanks to the work of several developers and mining pool
  administrators, most blocks mined in subsequent days were ready to
  contain taproot-spending transactions.  [Development][nov cs] and [testing][cbf
  verification] of [taproot-ready][dec cs] software [continued][rb#691].

- **December<!--taproot-->** saw Bitcoin Core merge a PR that would
  allow [descriptor wallets][topic descriptors] to create
  [bech32m][topic bech32] addresses for receiving taproot payments.  LN
  developers also further discussed [making use][ln ptlcs] of taproot's
  features.

Despite complications choosing an activation mechanism for taproot and
some minor confusion immediately after its activation, the final steps
of adding support for the taproot soft fork to Bitcoin overall seemed to
go well.  This is hardly the end of the story for taproot.  Optech
expects to continue to spend a significant amount of time writing about
it in the coming years as wallet and infrastructure developers begin
making use of its many features.

</div>

## April

{:#amp}
LND added [support][lnd#5709] in April for making Atomic Multipath
Payments ([AMP][topic amp]), also called original AMPs due to being described earlier
than the [Simplified Multipath Payments][topic multipath payments]
(SMPs) all major LN implementations currently support.  AMPs have a
privacy advantage over SMPs and also ensure that the receiver has
received all parts before they claim the payment.  Their downside is
that they don't produce cryptographic proof of payment.  LND implemented
them for use with [spontaneous payments][topic spontaneous payments]
which fundamentally can't provide a proof of payment, eliminating from
consideration the one significant downside of AMPs.

## May

{:#bip125}
A discrepancy between the specification of [BIP125][] transaction
[replacement][topic rbf] and the implementation in Bitcoin Core was
[disclosed][bip125 discrep] in May.  This didn't put any bitcoins at
risk, as far as we know, but it did spawn several discussions about the
risks to users of contract protocols (such as LN) from unexpected transaction relay
behavior.

{:#dual-funding}
Also in May, the C-Lightning project [merged][cl#4489] a plugin for
managing [dual-funded channels][topic dual funding]---channels where
both parties can provide some amount of the initial funding.  In
addition to prior dual-funding work [merged][cl#4410] this year, this
allows the party initiating the channel open to not only spend funds
through the channel but also receive them in the channel's initial
state.  That initial ability to receive funds makes dual-funding particularly useful for merchants whose primary
use of LN is receiving payments instead of sending them.

<div markdown="1" class="callout" id="releases">

### 2021 summary<br>Major releases of popular infrastructure projects

- [Eclair 0.5.0][] added support for a scalable cluster mode (see
  [Newsletter #128][news128 akka]), block chain watchdogs ([Newsletter
  #123][news123 watchdog]), and additional plugin hooks.

- [Bitcoin Core 0.21.0][] included support for new Tor onion services
  using [version 2 address announcement messages][topic addr v2], the
  optional ability to serve [compact block filters][topic compact block
  filters], and support for [signets][topic signet] (including the
  default signet which had [taproot][topic taproot] activated).  It also
  offered experimental support for wallets that natively use [output
  script descriptors][topic descriptors].

- [Rust Bitcoin 0.26.0][] included support for signet, version 2 address
  announcement messages, and improvements to [PSBT][topic psbt]
  handling.

- [LND 0.12.0-beta][] included support for using [watchtowers][topic
  watchtowers] with [anchor outputs][topic anchor outputs] and added a
  new `psbt` wallet subcommand for working with [PSBTs][topic psbt].

- [HWI 2.0.0][] contained support for multisig on the BitBox02, improved
  documentation, and support for paying `OP_RETURN` outputs with a
  Trezor.

- [C-Lightning 0.10.0][] contained a number of enhancements to its API
  and experimental support for [dual funding][topic dual funding].

- [BTCPay Server 1.1.0][] included [Lightning Loop][news53 lightning
  loop] support, added [WebAuthN/FIDO2][fido2 website] as a two-factor
  authentication option, made various UI improvements, and marked a
  switch to using [semantic versioning][semantic versioning website] for
  version numbers moving forward.

- [Eclair 0.6.0][] contained several improvements that enhanced user
  security and privacy.  It also provided compatibility with future
  software that may use [bech32m][topic bech32] addresses.

- [LND 0.13.0-beta][] improved feerate management by making [anchor
  outputs][topic anchor outputs] the default commitment transaction
  format, added support for using a pruned Bitcoin full node, allowed
  receiving and sending payments using Atomic MultiPath ([AMP][topic
  amp]), and increased LND's [PSBT][topic psbt]
  capabilities

- [Bitcoin Core 22.0][] included support for [I2P][topic anonymity
  networks] connections, removed support for [version 2 Tor][topic
  anonymity networks] connections, and enhanced support for [hardware
  wallets][topic hwi].

- [BDK 0.12.0][] added the ability to store data using Sqlite.

- [LND 0.14.0][] included additional [eclipse attack][topic eclipse
  attacks] protection (see [Newsletter #164][news164 ping]), remote
  database support ([Newsletter #157][news157 db]), faster pathfinding
  ([Newsletter #170][news170 path]), improvements for users of Lightning
  Pool ([Newsletter #172][news172 pool]), and reusable [AMP][topic amp]
  invoices ([Newsletter #173][news173 amp]).

- [BDK 0.14.0][] simplified adding an `OP_RETURN` output to a
  transaction and contained improvements for sending payments to
  [bech32m][topic bech32] addresses for taproot.

</div>

## June

{:#csb}
A new [analysis][csb] discussed in June described an alternative way for
miners to select which transactions they want to include in the blocks
they create.  The new method is predicted to slightly increase miner
revenue in the short term.  In the long-term, if the technique is
adopted by miners, wallets aware of it will be able to collaborate when [CPFP fee bumping][topic cpfp]
transactions, increasing the effectiveness of that technique.

{:#default-rbf}
Another attempt to make fee bumping more effective was a [proposal][rbf
default] to allow any unconfirmed transaction to be [replaced by
fee][topic rbf] (RBF) in Bitcoin Core---not just those that opt-in to
allowing replacement using [BIP125][].  This could help resolve some issues
with fee bumping in multiparty protocols and also improve privacy by
allowing more transactions to use uniform settings.  Related to privacy,
a separate [proposal][nseq default] suggested that wallets creating
taproot spends should set a default nSequence value even when they
don't need the features offered by [BIP68][]'s consensus enforced
sequence values; this would allow transactions created by software that
does need to use BIP68 to blend in with more common transactions.
Neither proposal seemed to make much progress despite few significant
objections.

{:#mpa}
June also saw the merge of the [first PR][bcc#20833] in a
series implemeting [mempool package acceptance][mpa ml]
in Bitcoin Core, the first step towards package relay.  [Package
relay][topic package relay] will allow relay nodes and miners to treat
packages of related transactions as if they were a single transaction
for feerate purposes.  A package might contain a parent transaction with a
low feerate and a child transaction with a high feerate; the
profitability of mining the child transaction would incentivize miners
to also mine the parent transaction.  Although package mining has been
[implemented][bitcoin core #7600] in Bitcoin Core since 2016, there has
so far been no way for nodes to relay transactions as packages, meaning
low-feerate parent transactions might not reach miners during
high-feerate periods even if they have high-feerate children.  This
makes [CPFP fee bumping][topic cpfp] unreliable for contract protocols
using presigned transactions, such as LN.  Package relay hopes to solve
this key safety issue.

{:#ff}
An idea originally proposed in 2019 for LN saw renewed life in June.  The
original [fast forwards][ff orig] idea described how an LN wallet could receive
or relay a payment with fewer network round-trips, reducing network
bandwidth and payment latency.  The idea was [expanded][ff expanded]
this year to describe how an LN wallet could receive multiple payments
without bringing its signing key online for every payment, making it
easier to keep that signing key secured.

## July

{:#liq-ads}
After years of discussion and development, the first implementation of a
decentralized liquidity advertisements system was [merged][cl#4639] into
an LN implementation.  The still-draft [liquidity ads][bolts #878]
proposal allows a node to use the LN gossip protocol to advertise its
willingness to lease out its funds for a period of time, giving other
nodes the ability to buy inbound capacity that allows them to receive
instant payments. A node that sees the advertisement can simultaneously
pay for and receive the inbound capacity using a [dual funded][topic
dual funding] channel open. Although there’s no way to enforce that the
advertising node actually routes payments, the proposal does incorporate
an earlier proposal (also [later used][lnd#5709] in Lightning Pool) that
prevents the advertiser from using their money for other purposes until
the agreed upon lease period has concluded.  That means refusing to
route payments would provide no advantages but would deny the
advertising node the opportunity to earn routing fees.

{:#descriptors}
Three years after [first being proposed][descriptor gist] for Bitcoin
Core, [draft BIPs][descriptor bips1] were [created][descriptor bips2] for
[output script descriptors][topic descriptors].  Descriptors are strings
that contain all the information necessary to allow a wallet or other
program to track payments made to or spent from a particular script or
set of related scripts (i.e. an address or a set of related addresses
such as in an [HD wallet][topic bip32]).  Descriptors combine well with [miniscript][topic miniscript] in
allowing a wallet to handle tracking and signing for a larger variety of
scripts.  They also combine well with [PSBTs][topic psbt] in allowing
the wallet to determine which keys it controls in a multisig script.  By
the end of the year, Bitcoin Core had made descriptor-based wallets its
[default][descriptor default] for newly-created wallets.

{:#zeroconfchan}
A common way of opening LN channels that had never before been
part of the LN protocol began to be [specified][0conf channels] in July.  Zero-conf
channel opens, also called *turbo channels*, are new single-funded
channels where the funder gives some or all of their initial funds to
the acceptor. Those funds are not secure until the channel open
transaction receives a sufficient number of confirmations, so there’s no
risk to the acceptor spending some of those funds back through the
funder using the standard LN protocol.  For example, Alice has several
BTC in an account at Bob’s custodial exchange. Alice asks Bob to open a
new channel paying her 1.0 BTC. Because Bob trusts himself not to
double-spend the channel he just opened, he can allow Alice to send 0.1
BTC through his node to third-party Carol even before the channel open
transaction has received a single confirmation.  Specifying the behavior
should help improve interoperability between LN nodes and the merchants
who offer this service.

{:.center}
![Zero-conf channel illustration](/img/posts/2021-07-zeroconf-channels.png)

{:#anyprevout}
Two related proposals for new signature hash (sighash) types were
[combined][sighash combo] into [BIP118][].  `SIGHASH_NOINPUT`, proposed
in 2017 and partly based on previous proposals going back a decade, was
superseded by [`SIGHASH_ANYPREVOUT` and `SIGHASH_ANYPREVOUTANYSCRIPT`][topic sighash_anyprevout] first
[proposed][anyprevout proposed] in 2019.  The new sighash types will
allow offchain protocols such as LN and [vaults][topic vaults] to reduce
the number of intermediate states they need to retain, greatly reducing
storage requirements and complexity.  For multiparty protocols, the
benefits may be even more significant by eliminating the number of
different states that need to be generated in the first place.

## August

{:#fibonds}
Fidelity bonds is an idea [described][wiki contract] at least as early as
2010 for locking up bitcoins for a period of time in order to create a
cost for misbehavior in third-party systems.  Because the bitcoins can't be used again until
their time lock expires, users in the other system who are banned or otherwise penalized during the
locking period are prevented from using the same bitcoins to create a new
virtual identity.  In August, JoinMarket put into [production][fi bonds]
the first large scale and decentralized use of fidelity bonds.  Within
days of release, over 50 BTC had been timelocked (worth over $2 million
USD at the time).

{:#pathfinding}
A new variation of pathfinding for LN was [discussed][0base] in August.
Proponents of the technique thought that it would be most effective if
routing nodes only charged a percentage of the amount routed without
charging a minimum *base fee* on every payment.  Others felt
differently.  By the end of the year, a [variation][cl#4771] on the
technique would be implemented in C-Lightning.

<div markdown="1" class="callout" id="optech">

### 2021 summary<br>Bitcoin Optech

In Optech's fourth year, we published 51 weekly [newsletters][], added 30
new pages to our [topics index][], published a [contributed blog
post][additive batching], and wrote (with the help of [two][zmn guest]
guest [posters][darosior guest]) a 21-part series about [preparing for
taproot][p4tr].  Altogether, Optech published over 80,000 words about
Bitcoin software research and development this year, the rough
equivalent of a 250-page book. <!-- wc -w _posts/en/newsletters/2021-*
_includes/specials/taproot/en/* -->

</div>

## September

{:#tluv}
One feature Bitcoin developers have long discussed is the ability to
send bitcoins to a script which could limit which other scripts could
later receive those bitcoins, a mechanism called [covenants][topic
covenants].  For example, Alice receives bitcoins to a script that can
be spent by her hot wallet---but only by sending it to a second script
that time delays any further spend by her hot wallet.  During the time
delay, her cold wallet can claim the funds.  If it doesn't, and the time
delay passes, Alice's hot wallet can spend the funds freely.  In
September, a new `OP_TAPLEAF_UPDATE_VERIFY` opcode was
[proposed][op_tluv] for creating these sort of covenants in a way that
takes particular advantage of taproot's ability to spend funds either
using just a signature (keypath spending) or a [MAST-like][topic mast] tree of scripts
(scriptpath spending).  The new opcode would be especially useful for
creating [joinpools][topic joinpools] that could significantly increase
privacy by allowing multiple users to easily and trustlessly share
ownership of a UTXO.

## October

{:#txhids}
In October, Bitcoin developers discussed a new way for a transaction to
[identify][heritage identifiers] which set of bitcoins it wanted to
spend.  Currently, bitcoins are identified by their location in the
transaction that last spent them; for example "transaction foo, output
zero".  A new proposal would allow identifying bitcoins using a previous
transaction that spent them plus their placement in the descent
hierarchy and their location; for example, "transaction bar's second
child, output zero".  It was suggested that this would provide
advantages for designs such as [eltoo][topic eltoo], [channel
factories][topic channel factories], and [watchtowers][topic
watchtowers], all of which benefit contract protocols such as LN.

{:#ptlcsx}
Also in October, a combination of existing ideas for improving LN were
bundled into a [single proposal][ptlcs extreme] that would bring some of
the same benefits of eltoo but without requiring the
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] soft fork or any other
consensus changes.  The proposal would reduce payment latency to nearly
as fast as data could travel one way between all the routing nodes on a
particular path. It would also increase resiliency by allowing a node to
back up all of the information it needs at the time a channel is created
and obtain any other information in most cases during a data restore.
It would also allow receiving payments with an offline key, allowing
merchant nodes in particular to limit the amount of time their keys
needed to be used by online computers.

## November

{:#lnsummit}
LN developers held the first general LN summit [since 2018][2018 ln
summit] and [discussed][2021 ln summit] topics including using
[taproot][topic taproot] in LN, including [PTLCs][topic ptlc],
[MuSig2][topic musig] for [multisignatures][topic multisignature], and
[eltoo][topic eltoo]; moving specification discussion from IRC to video
chats; changes to the current BOLTs specification model; [onion
messages][topic onion messages] and [offers][topic offers]; [stuckless
payments][]; [channel jamming attacks][topic channel jamming attacks]
and various mitigations; and [trampoline routing][topic trampoline
payments].

## December

{:#bumping}
For single-sig onchain transactions, fee bumping a transaction's feerate
to encourage miners to confirm it sooner is a relatively straightforward
operation.  But for contract protocols such as LN and [vaults][topic
vaults], not all the signers who authorized a spend may be available
when fee bumping is needed.  Worse, contract protocols often require
certain transactions to be confirmed by a deadline---or an honest user
could lose money.  December saw the [publication][fee bump research] of
research related to choosing effective fee bumping mechanisms for
contract protocols, helping spur discussion of solutions to this
important long-term problem.

## Conclusion

We tried something new in this year's summary---describing two dozen
noteworthy developments in 2021 without mentioning even a single
contributor's name.  We're indebted to all of those contributors and
very much want to see them credited for their incredible work, but we
also want to recognize all of the contributors who we wouldn't normally
mention.

They're the people spending hours on code reviews, or who are writing
tests for established behavior to ensure it doesn't unexpectedly change,
or who put effort into debugging mysterious issues to fix problems
before money is put at risk, or who are working on a hundred other tasks
that would only make the news if they weren't being done.

This final newsletter of 2021 is dedicated to them.  We don't have an
easy way to make a list of the names of these underacknowledged
contributors.  Instead we've omitted all names from this newsletter to
make the point that developing Bitcoin is a team effort where some of
the most important work is being done by people whose names have never
appeared in any issue of this newsletter.

We thank them and all contributors to Bitcoin in 2021.  We can't wait to
see what exciting new developments they will deliver in 2022.

*The Optech newsletter will return to its regular Wednesday publication
schedule on January 5th.*

{% include references.md %}
{% include linkers/issues.md issues="878,7600" %}
[2018 summary]: /en/newsletters/2018/12/28/
[2019 summary]: /en/newsletters/2019/12/28/
[2020 summary]: /en/newsletters/2020/12/23/
[cl 0.9.3]: /en/newsletters/2021/01/27/#c-lightning-0-9-3
[safegcd blog]: /en/newsletters/2021/02/17/#faster-signature-operations
[secp831]: /en/newsletters/2021/03/24/#libsecp256k1-831
[secp906]: /en/newsletters/2021/04/28/#libsecp256k1-906
[bcc21573]: /en/newsletters/2021/06/16/#bitcoin-core-21573
[bcc21]: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0
[cl#2816]: /en/newsletters/2019/07/24/#c-lightning-2816
[jam1]: /en/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees
[jam2]: /en/newsletters/2021/10/20/#lowering-the-cost-of-probing-to-make-attacks-more-expensive
[jam3]: /en/newsletters/2021/11/10/#ln-summit-2021-notes
[quant]: /en/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
[tapa1]: /en/newsletters/2021/01/27/#scheduled-meeting-to-discuss-taproot-activation
[tapa2]: /en/newsletters/2021/02/10/#taproot-activation-meeting-summary-and-follow-up
[tapa3]: /en/newsletters/2021/02/24/#taproot-activation-discussion
[tapa4]: /en/newsletters/2021/04/14/#taproot-activation-discussion
[bcctap]: /en/newsletters/2021/04/21/#taproot-activation-release-candidate
[speedy trial]: /en/newsletters/2021/03/10/#taproot-activation-discussion
[bcc#21377]: /en/newsletters/2021/04/21/#bitcoin-core-21377
[signal began]: /en/newsletters/2021/05/05/#miners-encouraged-to-start-signaling-for-taproot
[signal able]: /en/newsletters/2021/05/05/#bips-1104
[taproot.watch]: /en/newsletters/2021/05/26/#how-can-i-follow-the-progress-of-miner-signaling-for-taproot-activation
[rb#589]: /en/newsletters/2021/05/12/#rust-bitcoin-589
[bolts#672]: /en/newsletters/2021/06/02/#bolts-672
[bcc#22051]: /en/newsletters/2021/06/09/#bitcoin-core-22051
[lockin]: /en/newsletters/2021/06/16/#taproot-locked-in
[nsequence default]: /en/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions
[cl#4591]: /en/newsletters/2021/06/16/#c-lightning-4591
[p4tr]: /en/preparing-for-taproot/
[bcc#21365]: /en/newsletters/2021/06/23/#bitcoin-core-21365
[rb#601]: /en/newsletters/2021/06/23/#rust-bitcoin-601
[p2trhd]: /en/newsletters/2021/06/30/#key-derivation-path-for-single-sig-p2tr
[bcc#22154]: /en/newsletters/2021/06/30/#bitcoin-core-22154
[bcc#22166]: /en/newsletters/2021/06/30/#bitcoin-core-22166
[p4tr begins]: /en/newsletters/2021/06/23/#preparing-for-taproot-1-bech32m-sending-support
[bech32m page]: /en/newsletters/2021/07/14/#tracking-bech32m-support
[bip118 update]: /en/newsletters/2021/07/14/#bips-943
[bip119 update]: /en/newsletters/2021/11/10/#bips-1215
[reuse risks]: /en/newsletters/2021/08/25/#are-there-risks-to-using-the-same-private-key-for-both-ecdsa-and-schnorr-signatures
[btcpay taproot]: /en/newsletters/2021/09/15/#btcpay-server-2830
[op_tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[rb#563]: /en/newsletters/2021/10/06/#rust-bitcoin-563
[rb#644]: /en/newsletters/2021/10/06/#rust-bitcoin-644
[testing taproot]: /en/newsletters/2021/10/20/#testing-taproot
[expanded test vectors]: /en/newsletters/2021/11/03/#taproot-test-vectors
[taproot activation]: /en/newsletters/2021/11/17/#taproot-activated
[rb#691]: /en/newsletters/2021/11/17/#rust-bitcoin-691
[cbf verification]: /en/newsletters/2021/11/10/#additional-compact-block-filter-verification
[lnd#5709]: /en/newsletters/2021/10/27/#lnd-5709
[bitcoin core 0.21.0]: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0
[eclair 0.5.0]: /en/newsletters/2021/01/06/#eclair-0-5-0
[rust bitcoin 0.26.0]: /en/newsletters/2021/01/20/#rust-bitcoin-0-26-0
[lnd 0.12.0-beta]: /en/newsletters/2021/01/27/#lnd-0-12-0-beta
[hwi 2.0.0]: /en/newsletters/2021/03/17/#hwi-2-0-0
[c-lightning 0.10.0]: /en/newsletters/2021/04/07/#c-lightning-0-10-0
[btcpay server 1.1.0]: /en/newsletters/2021/05/05/#btcpay-1-1-0
[eclair 0.6.0]: /en/newsletters/2021/05/26/#eclair-0-6-0
[lnd 0.13.0-beta]: /en/newsletters/2021/06/23/#lnd-0-13-0-beta
[bitcoin core 22.0]: /en/newsletters/2021/09/15/#bitcoin-core-22-0
[bdk 0.12.0]: /en/newsletters/2021/10/20/#bdk-0-12-0
[lnd 0.14.0]: /en/newsletters/2021/11/24/#lnd-0-14-0-beta
[bdk 0.14.0]: /en/newsletters/2021/12/08/#bdk-0-14-0
[csb]: /en/newsletters/2021/06/02/#candidate-set-based-csb-block-template-construction
[rbf default]: /en/newsletters/2021/06/23/#allowing-transaction-replacement-by-default
[nseq default]: /en/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions
[bcc#20833]: /en/newsletters/2021/06/02/#bitcoin-core-20833
[ff expanded]: /en/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key
[cl#4639]: /en/newsletters/2021/07/28/#c-lightning-4639
[descriptor bips1]: /en/newsletters/2021/07/07/#bips-for-output-script-descriptors
[descriptor bips2]: /en/newsletters/2021/09/08/#bips-1143
[descriptor default]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[descriptor gist]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82/
[0conf channels]: /en/newsletters/2021/07/07/#zero-conf-channel-opens
[sighash combo]: /en/newsletters/2021/07/14/#bips-943
[fi bonds]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[0base]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[newsletters]: /en/newsletters/
[topics index]: /en/topics/
[additive batching]: /en/cardcoins-rbf-batching/
[zmn guest]: /en/newsletters/2021/09/01/#preparing-for-taproot-11-ln-with-taproot
[darosior guest]: /en/newsletters/2021/09/08/#preparing-for-taproot-12-vaults-with-taproot
[heritage identifiers]: /en/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[ptlcs extreme]: /en/newsletters/2021/10/13/#multiple-proposed-ln-improvements
[lnd#5709]: /en/newsletters/2021/10/27/#lnd-5709
[2018 ln summit]: /en/newsletters/2018/11/20/#feature-news-lightning-network-protocol-11-goals
[2021 ln summit]: /en/newsletters/2021/11/10/#ln-summit-2021-notes
[stuckless payments]: /en/newsletters/2019/07/03/#stuckless-payments
[bcc#19953]: /en/newsletters/2020/10/21/#bitcoin-core-19953
[lnd#5025]: /en/newsletters/2021/06/02/#lnd-5025
[signet reorgs]: /en/newsletters/2021/09/15/#signet-reorg-discussion
[bech32 bip]: /en/newsletters/2021/01/13/#bech32m
[offers stuck]: /en/newsletters/2021/04/21/#using-ln-offers-to-partly-address-stuck-payments
[news128 akka]: /en/newsletters/2020/12/16/#eclair-1566
[news123 watchdog]: /en/newsletters/2020/11/11/#eclair-1545
[news53 lightning loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[semantic versioning website]: https://semver.org/
[fido2 website]: https://fidoalliance.org/fido2/fido2-web-authentication-webauthn/
[news164 ping]: /en/newsletters/2021/09/01/#lnd-5621
[news157 db]: /en/newsletters/2021/07/14/#lnd-5447
[news170 path]: /en/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /en/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /en/newsletters/2021/11/03/#lnd-5803
[bcc#22364]: /en/newsletters/2021/12/01/#bitcoin-core-22364
[ln ptlcs]: /en/newsletters/2021/12/15/#preparing-ln-for-ptlcs
[anyprevout proposed]: /en/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes
[cl#4489]: /en/newsletters/2021/05/12/#c-lightning-4489
[cl#4410]: /en/newsletters/2021/03/17/#c-lightning-4404
[bip125 discrep]: /en/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation
[wiki contract]: https://en.bitcoin.it/wiki/Contract#Example_1:_Providing_a_deposit
[cl#4771]: /en/newsletters/2021/10/27/#c-lightning-4771
[fee bump research]: /en/newsletters/2021/12/08/#fee-bumping-research
[nov cs]: /en/newsletters/2021/11/17/#changes-to-services-and-client-software
[dec cs]: /en/newsletters/2021/12/15/#changes-to-services-and-client-software
[mpa ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019464.html
[ff orig]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[2020 conclusion]: /en/newsletters/2020/12/23/#conclusion
