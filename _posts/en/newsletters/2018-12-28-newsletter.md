---
title: 'Bitcoin Optech Newsletter #27: 2018 Year-in-Review Special'
permalink: /en/newsletters/2018/12/28/
name: 2018-12-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter is a special year-end edition summarizing
notable developments in Bitcoin during all of 2018.  Despite the
extended length of this newsletter, we regret that it only covers a tiny
fraction of the work put into dozens of open source projects by hundreds
of contributors.  Without those low-level
contributions, the high-concept ideas described in this newsletter would
be just empty words, and so we extend our most sincere thanks to all of
you who contributed to Bitcoin development this year.

## January

Hundreds of Lightning Network (LN) channels were open on testnet before
the start of the year, but January 2018 saw a few businesses and users
start using LN payments with real bitcoins on mainnet.  The pioneers
tagged their own actions as *#reckless,* but this did little to stop
other experimenters from putting real money at risk on the nascent
payment network.

This month also saw the publication of the Schnorr-based [muSig][]
interactive multiparty signature protocol by Gregory Maxwell, Andrew
Poelstra, Yannick Seurin, and Pieter Wuille.  This provides the same
security as Bitcoin's current multisig but can often reduce the amount
of transaction data required down to a single normal-looking public key
and signature.  This not only reduces overhead and costs, it also
increases privacy by making basic multisig transactions look identical
to single-sig transactions.

| | Receive script | Spend data |
|-|-|-|
| **Single-sig, current Script (P2PK)** | `<pubkey> OP_CHECKSIG` | `<signature>` |
| **Bare multisig, current Script** | `2 <pubkey> <pubkey> <pubkey> 3 OP_CHECKMULTISIG` | `OP_0 <signature> <signature>` |
| **Multisig, muSig[^fn-opcodes]** | `<pubkey> OP_CHECKSIG` | `<signature>` |

Building on the idea that muSig, or something like it, could become
possible in Bitcoin, Maxwell further described [Taproot][]---a powerful
optimization for Merklized Alternative Script Trees[^fn-mast] ([MAST][]).  Just as
muSig allows basic multisig to look like single-sig, Taproot allows even
the most complex possible Bitcoin script to look like single-sig if its
participants cooperate with each other (but if they don't, they still
receive the full security of their chosen script).  This provides an
even larger set of users with reduced overhead, reduced costs, and
increased privacy.

| | Receive script | Spend data |
|-|-|-|
| **Single user, current Script (P2PK)** | `<pubkey> OP_CHECKSIG` | `<signature>` |
| **Cooperating users, earlier MAST proposals[^fn-harding-mast]** | `<hash> OP_MAST` | `<signature> <<pubkey> OP_CHECKSIG> <hash> <flags>` |
| **Cooperating users, Taproot[^fn-opcodes]** | `<pubkey> OP_CHECKSIG` | `<signature>` |

## February

As if Taproot's potential benefits weren't enough, February saw Gregory Maxwell
describe a construction of it called [Graftroot][] that
would allow the people currently authorized to spend a coin to create
additional sets of conditions that allow spending the coin---without
creating a new transaction.  At any point, any of the authorized sets of
conditions could be used to spend the coins.  For example, if a coin can
currently be spent by agreement between both Alice and Bob (2-of-2
multisig), they could both agree to allow it to be spent by any two of
Alice, Bob, or their lawyer Charlie (2-of-3 multisig)---and they could
make this choice years after first receiving the coin without creating a
new transaction.  This could further increase efficiency and privacy,
especially for certain offchain contract protocols.

Meanwhile, LN protocol developers Olaoluwa Osuntokun and Conner
Fromknecht described a [new way to make multipath payments over LN][ln
multipath].  Multipath payments are payments with parts split across
multiple channels---for example, Alice can send part of a payment to Zed
through her channel with Bob and part through her channel with Charlie.

| Single path | Multipath |
|-|-|
| Alice → Bob → Zed | Alice → {Bob, Charlie} → Zed |

The authors noted that LN provides native support for multipath payments
by using the same commitment preimage (hashlock) for each part of the
payment, but that using this mechanism allows third parties to detect
that they are handling different parts of the same payment.  They then
described a more complex protocol that could prevent this correlation
and potentially provide other benefits.  Whether the simpler method or
the more complex method is used, either could significantly enhance the
usability of LN by removing the constraint that a user must have a
single channel with enough funds to make a payment.  For example, in the
current protocol, if Alice has two channels each with a bit over $100
available, she can only securely send Zed a maximum of $100 in a single payment.
With a multipath payment, Alice can send $200 by splitting the payment
across the two channels.

February closed with a bit of historical parallelism.  Early Bitcoin
contributor and the first known person to buy pizza with Bitcoin, Laszlo
Hanyecz, [bought][offchain pizza] two pizzas using LN for 6.49 mBTC---a
much lower price in BTC terms than the 10 million mBTC he [paid][onchain
pizza] for two pizzas in May 2010.

## March

Many Bitcoin users are familiar with being able to create signed
messages corresponding to their Bitcoin addresses.  There's currently no
standard way to do this with P2SH or segwit addresses.  A discussion in
March would eventually turn into [BIP322][], a proposal to create a
generic format capable of creating a signature proof for any spendable
Bitcoin script.

<div markdown="1" class="callout">
### 2018 summary<br>Major releases of popular infrastructure projects

- [Bitcoin Core 0.16][] released in February included default support in the
  wallet for receiving to segwit addresses, [BIP159][] support to allow
  pruned nodes to signal their willingness to serve recent blocks, and a
  number of performance improvements.

- [LND 0.4-beta][] released in March was the first LND release
  targeting mainnet support.  It also supported using Bitcoin Core as a
  backend, using Tor for connections, and many other features.

- [C-Lightning 0.6][] released in June reduced resource requirements,
  provided a built-in wallet, and added Tor support.

- [LND 0.5-beta][] released in September included many changes focused on
  making the system much more reliable.  It also dropped the requirement
  for full node backends to keep a transaction index, improving
  performance and reducing disk space requirements.

- [Bitcoin Core 0.17][] released in October included optional partial
  spend avoidance, the ability to dynamically create and load wallets,
  and [BIP174][] partially-signed Bitcoin transaction support for
  communication between Bitcoin programs.

</div>
## April

LN protocol developers Christian Decker, Rusty Russell, and Olaoluwa
Osuntokun announced [Eltoo][], a proposed alternative enforcement
mechanism for LN.  The current mechanism ([LN-penalty][]) requires
making previous offchain balance updates unsafe so that users don't try
to put them onchain.  The Eltoo mechanism allows onchain spending of
previous balance updates to later balance updates within a limited time
window.  In normal operation, parties would normally simply publish the
final channel balance onchain, but even if a party were to publish an
old balance, their channel counterparty could simply publish a second
transaction correcting it to the final balance.  Neither party would
lose anything but the transaction fees they paid.

The advantage of Eltoo is that user software doesn't need to manage the
data that makes earlier balance updates unsafe.  This simplifies
backups and reduces the risks associated with data loss---but perhaps
most importantly, it makes it much easier and computationally efficient
for payment channels to be opened between many users in a single onchain
transaction.  This lays the groundwork for other proposals such as
[Channel Factories][] that could make LN channels 10x or more efficient
in their onchain operations.

Eltoo requires a soft fork to add a new optional signature hash,
[BIP118][] SIGHASH_NOINPUT_UNSAFE.[^fn-unsafe]  This would allow a signature
authorizing the spend of a UTXO to indicate that the signature doesn't
apply to just that UTXO but to any UTXO that could be spent by a
signature from the same private key.  Additionally, Eltoo's publication
mechanism [may not be reliably safe][eltoo pinning] because current node
relay policies allow [transaction pinning][].  Still, protocol
developers appear optimistic about the proposal and many are hoping that
the noinput feature can be part of a possible future Schnorr and Taproot
soft fork proposal.

## May

A [draft BIP][BIP156] for the Dandelion protocol was published to
the Bitcoin-Dev mailing list in May.  Dandelion can privately relay
transactions so that the IP address of the spender can't be reliably
determined.  This works even without using a method like Tor, and
Dandelion can be combined with Tor to further decrease the risk of a
privacy compromise.  Dandelion by itself only fully benefits users of
relaying full nodes (not P2P lightweight clients[^fn-dandelion-lite])
and it needs to be combined with some form of encryption to prevent ISPs
from being able to identify spenders.

However, Dandelion depends in part on relay nodes pretending that
they've never seen a transaction they previously helped relay.  This
makes the nodes vulnerable to denial of service attacks that can waste
the node's bandwidth and memory---problems which developers are still
[working on addressing][daftuar dandelion] before adopting this protocol.

<div markdown="1" class="callout">
### 2018 summary<br>Notable technical conferences and other events

- [BPASE][bpase], January, Stanford University
- [Bitcoin Core developers meetup][coredevtech nyc], March, New York
  City ([transcripts][coredevtech ts])
- [L2 Summit][], May, Boston
- [Building on Bitcoin][], July, Lisbon ([transcripts][bob ts])
- [Edge Dev++][], October, Tokyo ([videos][edge dev vids],
  [transcripts][edge dev ts])
- [Scaling Bitcoin Conference][], October, Tokyo. ([videos][scaling
  bitcoin vids], [transcripts][scaling bitcoin ts])
- [Bitcoin Core developers meetup][coredevtech tokyo], October, Tokyo
  ([transcripts][coredevtech ts])
- [Chaincode Lightning Residency][], October, New York City ([videos][ln
  residency vids])
- [Lightning protocol development summit][], November, Adelaide

</div>

## June

In June, Matt Corallo publicly announced a project he'd been working on
for some time: a new protocol for communication from a mining pool
server to individual miners and on to the actual ASICs doing the work.
Named [BetterHash][], the protocol separates pool payouts from transaction
selection.  An illustration of why this is important came later in the year when several
traditional mining pools [threatened][bitcoin.com forced bch mining] to redirect their Bitcoin hashrate to
work on an altcoin---something which miners using BetterHash could've
automatically resisted.  Corallo provided BetterHash with both a [draft
BIP][betterhash] and a [working implementation][betterhash
implementation] that includes backwards compatibility with the
predominant Stratum mining communication protocol.

At the same time, a [vulnerability][sdl fake spv proof] long known to
some Bitcoin protocol developers was unwittingly disclosed publicly.
[CVE-2017-12842][] makes it possible to create an SPV proof for a
transaction that doesn't exist by specially crafting a real 64-byte
transaction that gets confirmed in a block.  Many lightweight wallets
that depend on SPV proofs remain vulnerable even today, but the
estimated cost of the attack is more expensive than the original attack
against SPV-trusting wallets described by Nakamoto in section 8 of the
2009 [Bitcoin paper][bitcoin.pdf], so lightweight clients don't appear
to be significantly less secure than they were before.  For other cases
where SPV proofs are used in conjunction with a full node, such when used
with federated sidechains, Bitcoin Core modified its RPCs to perform
additional checks or provide additional information that fully mitigates
the vulnerability (see PRs [#13451][Bitcoin Core #13451] and
[#13452][Bitcoin Core #13452]).

On the fun side, the [satoshis.place][] website by Lightning K0ala rose
to sudden popularity as an amusing place to spend real bitcoins using LN.
Hundreds of users paid one satoshi per pixel to paint anything they
wanted to the shared canvas, providing an amazingly effective live
demonstration of the speed and convenience of LN payments.

## July

After over a year of [advanced notice][alert retirement alert], July
began with the [release][alert key release] of the private key
previously used to sign alert messages that spread through the Bitcoin
P2P network.  Alert messages didn't just warn users about problems but
also, in some older releases of the software, gave those with the alert key
the ability to effectively stop all commerce on the Bitcoin network---a
concerning centralization of power for a decentralized network.  Details
of multiple denial-of-service vulnerabilities against older nodes that
could be performed with the alert key were released at the same time as
the key.

In positive news, Pieter Wuille released a [draft BIP][schnorr bip]
defining a Schnorr-based signature scheme with the goal of allowing
everyone to discuss---and hopefully agree upon---how that aspect of
adding Schnorr to Bitcoin would work while other details of a possible
soft fork are still being worked out.  The proposed format would be
fully compatible with existing bitcoin private and public keys, so HD
wallets shouldn't need to generate new recovery seeds.  Signatures would
be roughly 10% smaller, slightly increasing onchain capacity.
Signatures could also be verified in batches about 2x faster than they
could be verified individually, even in parallel, mainly speeding up
verification of blocks for nodes catching up.

The signature scheme is compatible with the muSig protocol described
in January (or similar protocols) and so encompasses its benefits for
increased efficiency and privacy.  Use of Schnorr also simplifies the
implementation of techniques such as Taproot, Graftroot, more private
payment channels for LN, more private atomic swaps across chains, more
private atomic swaps on the same chain (providing for improved
coinjoin), and other advances that improve efficiency, privacy, or both.

Meanwhile, participants in a privacy roundtable described a method
called Pay-to-EndPoint ([P2EP][]) that can significantly improve wallet
resistance to block chain analysis by applying a limited form of
coinjoin to interactive payments.  A [simplified form][bustapay] of the
proposal has also been described.  The protocol works by having the
receiver of a transaction mix some of their existing bitcoins
into the transaction, preventing an outside observer from being able to
automatically assume that all the inputs to a transaction came from the
same person.  The more people who use this technique, the less reliable
the input association assumption becomes---improving privacy for all
Bitcoin users, not just the people who use P2EP.

{% capture today-private %}Inputs:<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Alice (2 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Alice's change (1 BTC)<br>&nbsp;&nbsp;Bob's revenue (3 BTC){% endcapture %}
{% capture today-public %}Inputs:<br>&nbsp;&nbsp;Spender (2 BTC)<br>&nbsp;&nbsp;Spender (2 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Spender or Receiver (1 BTC)<br>&nbsp;&nbsp;Spender or Receiver (3 BTC){% endcapture %}
{% capture p2ep-private %}Inputs:<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Bob (3 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Alice's change (1 BTC)<br>&nbsp;&nbsp;Bob's revenue & change (6 BTC){% endcapture %}
{% capture p2ep-public %}Inputs:<br>&nbsp;&nbsp;Spender or Receiver (2 BTC)<br>&nbsp;&nbsp;Spender or Receiver (2 BTC)<br>&nbsp;&nbsp;Spender or Receiver (3 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Spender or Receiver (1 BTC)<br>&nbsp;&nbsp;Spender or Receiver (6 BTC){% endcapture %}

| | What Alice and Bob know | What the network sees |
|-|-|-|
| **Current norm** | {{today-private}} | {{today-public}} |
| **With P2EP** | {{p2ep-private}} | {{p2ep-public}} |

## August

A long-term effort to bring encryption to Bitcoin's network protocol
received new developments in August with the opening of a [PR][bitcoin
core #14032] to Bitcoin Core and the publication of a [revised
BIP151][BIP151].  Communication encryption is already possible (and
recommended) using Tor---which can provide other benefits---but enabling
encryption by default could help protect a larger number of users from
eavesdropping by their ISPs.

Separately, Pieter Wuille has been working on a [draft document][untrackable auth]
since February based on a protocol he, Gregory Maxwell, and others have been developing
to allow optional authentication on top of encryption.  Similar to
[BIP150][], this would make it easier to securely set up whitelisted
nodes across the Internet or lightweight wallets bound to trusted nodes.
Notably, the current idea for this is to enable authentication without
revealing identity to third parties so that nodes on anonymity networks
(such as Tor) or nodes that simply changed IP addresses couldn't have
their network identity tracked.  Although Wuille discovered flaws in his
originally documented proposal, it's been updated as research into
developing the protocol has proceeded.

<div markdown="1" class="callout">
### 2018 summary<br>Bitcoin Optech

After starting [Optech][] in May, we've signed up 15 companies as
members, held two [workshops][optech workshops], produced 28 weekly
[newsletters][optech newsletters], built a [dashboard][optech
dashboard], and made a solid start on a book about
individually-deployable scaling techniques.  To learn more about what we
accomplished in 2018 and what we have planned for 2019, please see our
short [annual report][optech annual report].

</div>

## September

The major news of September was the discovery, [disclosure][core dup
post], repair, and analysis of the [CVE-2018-17144][] duplicate inputs
vulnerability in unpatched Bitcoin Core versions 0.14.0 to 0.16.2.  The vulnerability allowed
a miner to create a block that spent the same bitcoins more than once,
allowing unexpected inflation of the amount of bitcoin currency.  This would later
be exploited on testnet (temporarily), demonstrating the vulnerability
but without putting real bitcoins at risk.  There is no evidence anyone
tried the attack against Bitcoin mainnet.  Anyone using a release
version of Bitcoin Core 0.16.3 or later is no longer at risk.

Such problems can ultimately only be avoided by increasing the amount of
review and automated testing that code changes receive---and for that,
Bitcoin needs more reviewers, more test writers, and more organizations
committed to hiring or sponsoring such contributors.

## October

The fifth [Scaling Bitcoin conference][] in early October both
introduced new ideas for the future of Bitcoin and refined existing
ideas.  At related events, [immediately-practical talks][edge dev++]
focused on exchange security, wallet security, and safe handling of
block chain reorganizations and forks.  Bitcoin Core developers also
[held meetings][coredevtech tokyo] to give each developer a chance to
discuss their current initiatives with other developers.

Separately, LN protocol developer Rusty Russell proposed a method for
[splicing][], which allows users to add or subtract funds from a channel
without pausing payments in that channel.  This especially helps wallets
hide from their users the technical details of managing balances.  For
example, Alice's wallet can automatically pay Bob offchain or onchain
from the same payment channel---offchain using LN through that payment
channel or onchain using a splice out (withdrawal) from that payment
channel.

<div markdown="1" class="callout">
### 2018 summary<br>New open source infrastructure solutions

- [Electrs][] released in July provides an efficient reimplementation of
  an Electrum-style transaction lookup server written in the Rust
  programming language.  Resource requirements are significantly lower
  than they are for alternatives.  Electrum-style servers provide the
  backend for many wallets and some other services.

- [Subzero][] released in October by Square provides a suite of tools
  and documentation to use with a Hardware Security Module (HSM) for key
  management.  It's designed to help exchanges and other bitcoin
  custodians securely store their bitcoins.

- [Esplora][] released in December by Blockstream provides the frontend
  and backend code for a block explorer.  Based in part on Electrs, it
  supports mainnet, testnet, and the Liquid sidechain.

</div>

## November

LN protocol developers met in November to decide which changes to adopt
for the forthcoming Lightning Network Protocol Specification 1.1.
[Accepted changes][ln1.1 changes] focus heavily on usability
improvements.  Two changes, multipath payments (described above in
February) and Splicing (October), together can allow wallets to almost
completely hide the complexity of channel balance management from users.
For example, with one click (ideally) Alice can pay Bob up to almost her
full wallet balance from any combination of her channels whether she's
paying him offchain or onchain.

Other accepted changes include increasing the maximum channel capacity,
dual-funded channels that can help businesses improve their LN user
experience, and hidden destinations that can help nodes stay hidden even
when routing payments for arbitrary untrusted spenders.  These topics
and many others were [discussed][ln list november] in this busiest-ever
month on the Lightning-Dev mailing list.

One of the desired changes requires a variance to Bitcoin Core's relay
policy.  LN devs would like offchain payments to commit to a minimum
amount of onchain fee while the channel is in use.  When the channel is
closed, they want to use fee bumping to set the fee to an appropriate
amount for current network conditions.  This is made difficult by some
of Bitcoin Core's code for preventing denial-of-service attacks that
unfortunately make fee bumping unreliable in adversarial cases, but
protocol developer Matt Corallo has [proposed][cpfp carve out] a new
rule that may safely allow fee bumping in the case of two-party LN
payments.

## December

Pieter Wuille, Gregory Maxwell, and Gleb Naumenko researched how to
reduce the amount of data used to relay Bitcoin transactions.  Their
initial result is [libminisketch][], a library that allows one user with
a set of elements (e.g. {1, 2, 3}) to efficiently send missing elements
to another user who only has part of that set (e.g. {1, 3}).  No changes
to Bitcoin consensus are required for this---it's just a different way of
transmitting the same information.  If implemented for relay, it can
reduce overall node bandwidth (for a typical case) by [40% to 80%][wuille minisketch savings].  It
also keeps bandwidth low as the number of connections increases,
potentially allowing nodes to make many more connections to
peers in order to improve the robustness of the P2P relay network.

Finally, as 2018 drew to a close, developers continued to discuss how
Schnorr signatures, Taproot MAST, SIGHASH_NOINPUT_UNSAFE, and other
changes might be integrated together into a concrete soft fork proposal.
Protocol developer Anthony Towns concisely [summarized][schnorr and
more] what might be contained in a proposal if it were released today.

<div markdown="1" class="callout">
### 2018 summary<br>Use of fee-reduction techniques

![Plot of compressed pubkey, segwit, payment batching, and opt-in RBF use in 2018](/img/posts/2018-12-overall.png)

We surveyed a variety of [techniques for reducing transaction fees][]
whose use can easily be tracked by looking at confirmed transactions.

- **Compressed pubkeys** save 32 bytes per use and have been widely used
  [since 2012][Bitcoin Core 0.6].  The number of inputs using compressed
  pubkeys rose from about 96% in January to 98% in December.

- **Segwit spends** reduce the effect of witness size on fees by up to
  75%, depending on how segwit is used (see next graph).  The number of
  inputs using segwit rose from about 10% in Jan to 38% in Dec.

- **Batched payments** spread the size and fee overhead of spending an
  input or set of inputs across a greater number of outputs, making them
  a great way for high-frequency spenders like exchanges to [save up to
  80% on fees][payment batching].  The number of transactions spending to
  three or more outputs hovered around 11% all year.  Note: this
  heuristic also counts coinjoin transactions and other techniques that
  are not strictly payment batching.

- **Opt-in RBF** (Replace-by-Fee) allows efficient fee bumping so
  spenders can start by paying a low fee and then increase their bid
  later.  Transactions signaling RBF rose from about 4% in Jan to
  6% in Dec.

![Plot of wrapped and native segwit use in 2018](/img/posts/2018-12-segwit.png)

There are two classes of segwit spends:

- **Nested** segwit puts the extension mechanism inside a
  backwards-compatible P2SH script, making it compatible with almost all
  software but not allowing it to achieve its full efficiency.  The
  number of inputs using nested segwit rose from about 10% in Jan to 33%
  in Dec.

- **Native** segwit is more efficient but is only compatible
  with wallets that support sending to segwit addresses.  The number of
  native segwit inputs rose from almost 0% in Jan to about 5% in Dec.

![Plot of UTXO set changes per block in 2018](/img/posts/2018-12-utxo.png)

A final fee-reduction technique we surveyed was the per-block change to
the size of the set of Unconfirmed Transaction Outputs (UTXOs).  Decreases
indicate [consolidation][towns consolidation] of bitcoins into larger
coins that can be spent more efficiently later.  Altogether, the UTXO set
size decreased by about 12 million entries this year.

![Plot of the block size as a percentage of the maximum allowed block size](/img/posts/2018-12-weight.png)

Overall, the average amount of block space used this year rarely
approached the maximum allowed by the protocol, but it did seem to be
increasing towards the max up until the beginning of December.  If that
trend returns and blocks become consistently full again in 2019---as
they were in 2017---fees are likely to rise and wallets and businesses
that implement fee-reduction techniques may be able to offer their users
substantially lower costs than competitors that haven't optimized.

*Data for all the above plots consists of values collected from
within each block, smoothed using a simple moving average over 1,000
blocks.  Empty blocks (those with only a generation transaction) were
excluded from analysis.  Most of the above statistics may be obtained
from the [Optech Dashboard][], which is updated after every block.
Note: After 1 January 2019, we will update the plots in this article to
reflect all of 2018, at which point this sentence will be deleted.*
</div>

## Conclusion

We sometimes hear people requesting roadmaps for future Bitcoin
development, but looking back over the developments of 2018 makes it
clear how futile publishing such a document would be.  Many of the
developments described above are things we doubt even the most advanced
protocol developer could've predicted just a year ago.  Accordingly, we have no idea
exactly what 2019 has in store for Bitcoin development---but we're looking
forward to finding out.

*The Optech newsletter will return to its regular Tuesday publication
schedule on January 8th.  You can [subscribe by email][optech
newsletters] or follow our [RSS feed][].*

## Footnotes

[^fn-dandelion-lite]:
    Lightweight clients using the Bitcoin P2P network don't relay
    transactions for other users---they only send their own
    transactions.  This means that any transactions sent from a P2P lite
    client can be associated with the client's network identity (e.g. IP
    address).  Dandelion is just a routing protocol and so cannot
    eliminate this privacy leak.  Instead, P2P lite clients should
    always send transactions using an anonymity network such as Tor (and
    should use a different throw-away network identity for each spending
    transaction).

[^fn-opcodes]:
    A Schnorr signature proposal may not use the same opcodes as current
    Script, but single-sig, multisig using something like muSig, and
    cooperative MAST using something like Taproot could all use the same
    format.

[^fn-mast]:
    Also called *Merklized Abstract Syntax Trees* because the original
    idea by Russell O'Connor combined the cryptographic commitment
    structure of merkle trees with the programming language analysis
    technique of abstract syntax trees to provide a method for compactly
    committing to a complex script whose elements and results from
    different branches could be combined.  Later simplifications of the
    idea have removed this potential for combining and so recent
    proposals are unlike abstract syntax trees, leading O'Connor and
    others to discourage use of the original term for the new idea.  Yet
    the abbreviation "MAST" has been used to refer to the basic technique since
    [at least 2013][todd mast], and so we've chosen to adopt Anthony
    Towns's [proposed][mast backronym] backronym, *Merklized Alternative
    Script Trees*.

[^fn-unsafe]:
    [BIP118][] SIGHASH_NOINPUT_UNSAFE receives the unsafe appellation
    because naive use of it could allow loss of funds.  For example,
    Alice receives 1 BTC to one of her addresses.  She then uses noinput
    when signing a spend of those funds to Bob.  Later, Alice receives
    another 1 BTC to the same address.  This allows the signature from
    the previous transaction to be reused to send Alice's new 1 BTC to
    Bob.  BIP118 co-author Christian Decker has [agreed][decker unsafe]
    to label the opcode as *unsafe* to encourage developers to learn
    about this safety concern before they use the flag.  A well-designed
    program can use noinput safely by being careful about what it signs
    and what addresses it exposes to users for receiving payments.

[^fn-harding-mast]:
    This example doesn't correspond to any specific MAST proposal but
    instead provides a simple view of the minimal data necessary for
    MAST to work.  For actual proposals, please see BIPs [114][BIP114],
    [116][BIP116], and [117][BIP117].

{% include linkers/issues.md issues="13451,13452,14032" %}
{% include references.md %}

[alert key release]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016189.html
[alert retirement alert]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement
[betterhash]: https://github.com/TheBlueMatt/bips/blob/master/bip-XXXX.mediawiki
[betterhash implementation]: https://github.com/TheBlueMatt/mining-proxy
[bitcoin core 0.16]: https://bitcoincore.org/en/releases/0.16.0/
[bitcoin core 0.17]: https://bitcoincore.org/en/releases/0.17.0/
[bob ts]: https://diyhpl.us/wiki/transcripts/building-on-bitcoin/2018/
[bpase]: https://cyber.stanford.edu/bpase18
[building on bitcoin]: https://building-on-bitcoin.com/
[bustapay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016340.html
[chaincode lightning residency]: https://lightningresidency.com/
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks%20(1).pdf
[c-lightning 0.6]: https://github.com/ElementsProject/lightning/releases/tag/v0.6
[coredevtech nyc]: https://coredev.tech/2018_newyork.html
[coredevtech tokyo]: https://coredev.tech/2018_tokyo.html
[coredevtech ts]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[core dup post]: https://bitcoincore.org/en/2018/09/20/notice/
[cpfp carve out]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[edge dev++]: https://keio-devplusplus-2018.bitcoinedge.org/
[edge dev ts]: http://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/
[edge dev vids]: https://www.youtube.com/channel/UCywSzGiWWcUG1gTp45YdPUQ/videos
[electrs]: https://github.com/romanz/electrs
[eltoo]: https://blockstream.com/eltoo.pdf
[eltoo pinning]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-June/001316.html
[esplora]: https://blockstream.com/2018/12/06/esplora-source-announcement/
[graftroot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[l2 summit]: https://medium.com/mit-media-lab-digital-currency-initiative/the-importance-of-layer-2-105189f72102
[lightning protocol development summit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001569.html
[ln1.1 changes]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[lnd 0.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.4-beta
[lnd 0.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5-beta
[ln list november]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/thread.html
[ln multipath]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html
[ln-penalty]: https://lightning.network/lightning-network-paper.pdf
[ln residency vids]: https://lightningresidency.com/#videos
[mast]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[musig]: https://www.blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures/
[offchain pizza]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001044.html
[onchain pizza]: https://en.bitcoin.it/wiki/Laszlo_Hanyecz
[optech]: /
[optech annual report]: /en/2018-optech-annual-report/
[optech dashboard]: https://dashboard.bitcoinops.org/
[optech newsletters]: /en/newsletters/
[optech workshops]: /workshops/
[p2ep]: https://blockstream.com/2018/08/08/improving-privacy-using-pay-to-endpoint/
[satoshis.place]: https://satoshis.place/
[scaling bitcoin conference]: https://tokyo2018.scalingbitcoin.org/
[scaling bitcoin ts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/
[scaling bitcoin vids]: https://tokyo2018.scalingbitcoin.org/#remote-participation
[schnorr and more]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[schnorr bip]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[sdl fake spv proof]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[splicing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[subzero]: https://medium.com/square-corner-blog/open-sourcing-subzero-ee9e3e071827
[taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[transaction pinning]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning/80804#80804
[untrackable auth]: https://gist.github.com/sipa/d7dcaae0419f10e5be0270fada84c20b
[mast backronym]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016500.html
[todd mast]: https://bitcointalk.org/index.php?topic=255145.msg2757327#msg2757327
[daftuar dandelion]: https://bitcoin.stackexchange.com/a/81504/26940
[bitcoin.com forced bch mining]: https://www.reddit.com/r/Bitcoin/comments/9x2jub/warning_if_you_have_any_bitcoin_hashing_power/
[wuille minisketch savings]: https://twitter.com/pwuille/status/1075460072786935808
[decker unsafe]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016193.html
[bitcoin core 0.6]: https://bitcoin.org/en/release/v0.6.0
[techniques for reducing transaction fees]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees
[payment batching]: https://bitcointechtalk.com/saving-up-to-80-on-bitcoin-transaction-fees-by-batching-payments-4147ab7009fb
[towns consolidation]: /en/xapo-utxo-consolidation/
