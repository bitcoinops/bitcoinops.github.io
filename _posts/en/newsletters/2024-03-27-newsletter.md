---
title: 'Bitcoin Optech Newsletter #295'
permalink: /en/newsletters/2024/03/27/
name: 2024-03-27-newsletter
slug: 2024-03-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the disclosure of a bandwidth-wasting
attack affecting Bitcoin Core and related nodes, describes several
improvements to the idea for transaction fee sponsorship, and summarizes
a discussion about using live mempool data to improve Bitcoin Core's
feerate estimation.  Also included are our regular sections with
selected questions and answers from the Bitcoin Stack Exchange,
announcements of new releases and release candidates, and notable
changes to popular Bitcoin infrastructure projects.

## News

- **Disclosure of free relay attack:** a bandwidth-wasting attack was
  [described][todd free relay] to the Bitcoin-Dev mailing
  list.  In short, Mallory broadcasts one
  version of a transaction to Alice and a different version of the
  transaction to Bob.  The transactions are designed so that Bob won't
  accept Alice's version as an [RBF replacement][topic rbf] and Alice
  won't accept Bob's version.  Mallory then sends Alice a replacement
  that she will accept but Bob won't.  Alice relays the replacement to
  Bob, consuming their mutual bandwidth, but Bob rejects it, resulting
  in the relay bandwidth being wasted (called [free relay][topic free
  relay]).  Mallory can repeat this multiple times until a transaction
  eventually gets confirmed, with each cycle seeing Alice accept the
  replacement, use bandwidth sending it to Bob, and Bob rejecting it.
  The effect of the attack can be multiplied by Alice having multiple
  Bob-like peers who all reject the replacements and Mallory sending
  multiple specially constructed transactions of this type in parallel.

  The attack is limited by the fee costs Mallory will pay when some
  version of her transactions eventually confirms, although the attack description
  notes that this can be essentially zero if Mallory was planning to
  send a transaction anyway.  The maximum amount of bandwidth that can
  be wasted is limited by Bitcoin Core's existing transaction relay
  limits, although it is possible that performing this attack many
  times in parallel could delay the propagation of legitimate
  unconfirmed transactions.

  The description also mentions another well-known type of node bandwidth
  wasting, where a user broadcasts a set of large transactions and
  then works with a miner to create a block that contains a relatively
  small transaction that conflicts with all the relayed transactions.
  For example, a 29,000-vbyte transaction <!-- 500 inputs --> could
  remove about 200 megabytes of transactions <!-- 500 txes each
  100,000 vbytes (~400,000 bytes) --> from every relaying full node's
  mempool.  The description argues that the existence of attacks that allow wasting
  bandwidth means that it should be reasonable to deliberately allow
  some amount of free relay, such as by enabling proposals like
  replace by feerate (see [Newsletter #288][news288 rbfr]). {% assign timestamp="1:22" %}

- **Transaction fee sponsorship improvements:** Martin Habovštiak
  [posted][habovstiak boost] to the Bitcoin-Dev mailing list an idea for
  allowing one transaction to boost the priority of an unrelated
  transaction.  Fabian Jahr [noted][jahr boost] that the fundamental
  idea appears to be very similar to [transaction fee sponsorship][topic
  fee sponsorship], which was proposed in 2020 by Jeremy Rubin (see
  [Newsletter #116][news116 sponsor]).  In Rubin's original proposal,
  the _sponsor transaction_ committed to the _boosted transactions_
  using a zero-value output script, which uses about <!-- 8 + 1 + 1 + 32
  (nAmount + sPK size + OP_VER + txid); I say "about" because also
  discussed was using an outpoint commitment --> 42 vbytes for a single
  sponsorship and about 32 bytes for each additional sponsorship.  In
  Habovštiak's version, the sponsor transaction commits to the boosted
  transaction using the taproot [annex][topic annex], which uses about <!--
  32 / 4; might have encoding overhead and might also end up using
  an outpoint instead --> 8 vbytes for a single sponsorship and 8 vbytes
  for each additional sponsorship.

  After hearing about Habovštiak's idea, David Harding
  [posted][harding sponsor] to Delving Bitcoin an efficiency
  improvement he and Rubin had previously developed in January.  The
  sponsor transaction commits to the boosted transaction using the
  signature commitment message, which is never published onchain, so
  zero block space is used for a single commitment.  To allow this,
  the sponsor transaction must appear in blocks and [package
  relay][topic package relay] messages immediately after the boosted
  transaction, allowing full node verifiers to infer the txid of the
  boosted transaction when they verify the sponsor transaction.

  For cases where a block may contain multiple sponsor transactions
  that each commit to some of the same boosted transactions, it's not
  possible to simply have a series of boosted transactions appear
  immediately before their sponsors, so entirely inferable commitments
  is not an option.  Harding describes a simple alternative that only
  uses 0.5 vbytes per boosted transaction; Anthony Towns
  [improves][towns sponsor] upon that with a version that would never
  use more than 0.5 vbytes per boost and would use less space
  in most cases.

  Both Habovštiak and Harding note the potential for outsourcing:
  anyone who is planning to broadcast a transaction anyway (or who
  has an unconfirmed transaction they're willing to update with
  [RBF][topic rbf]) can increase its feerate and boost another
  transaction at an insignificant cost of 0.5 vbytes or less per
  boost; for comparison, 0.5 vbytes is about 0.3% of a 1-input,
  2-output P2TR transaction.  Unfortunately, they both warn that
  there's no convenient way to trustlessly pay a third party for a
  boost; however, Habovštiak points out that anyone paying over LN
  would receive [proof of payment][topic proof of payment] and so
  could potentially prove deceit.

  Towns further notes that sponsors seems compatible with the proposed
  design for [cluster mempool][topic cluster mempool], that the most
  efficient versions of sponsorship present some mild challenges for
  transaction validity caching, and concludes with a table showing the
  relative block space consumed by various current and proposed fee
  bumping techniques.  At 0.5 vbytes or less per boost, the most
  efficient form of fee sponsorship is only bested by the 0.0 vbytes
  used in the best case with RBF and paying miners [out-of-band][topic
  out-of-band fees].  Because fee sponsorship allows dynamic fee
  bumping and is almost as efficient as paying miners out-of-band, it
  may resolve a major concern with protocols that depend on [exogenous
  fees][topic fee sourcing].

  In [continued discussion][daftuar sponsor] shortly before this
  newsletter was about to be published, Suhas Daftuar raised concerns
  that sponsors could introduce problems that are not easily addressed
  by cluster mempool and which could create problems for users who
  didn't need sponsors, indicating that sponsorship (if it is ever
  added to Bitcoin) should only be available to transactions that
  opt-in to allowing it. {% assign timestamp="9:55" %}

- **Mempool-based feerate estimation:** Abubakar Sadiq Ismail
  [posted][ismail fees] to Delving Bitcoin about improving Bitcoin
  Core's [feerate estimation][topic fee estimation] using data from a
  node's local mempool.  Currently, Bitcoin Core generates estimates by
  recording the block height when each unconfirmed transaction is
  received, the block height when it is confirmed, and its feerate.
  When all of that information is known, the delta between received
  height and confirmed height is used to update an exponentially
  weighted moving average for a bucket that represents a range of
  feerates.  For example, a transaction that takes 100 blocks to confirm
  with a feerate of 1.1 sat/vbyte will be incorporated into the average
  for the 1 sat/vbyte bucket.

  An advantage of this approach is its resistance to manipulation: all
  transactions must be both relayed (meaning they're available to all
  miners) and confirmed (meaning they can't violate any consensus
  rules).  A disadvantage is that it only updates once per block and
  can lag far behind other estimates that use real-time mempool
  information.

  Ismail has taken [previous discussion][bitcoin core #27995] about
  incorporating mempool data into feerate estimates, written some
  preliminary code, and performed an analysis showing how the current
  algorithm and a new algorithm compare (not including some safety
  checks).  A [reply][harding fees] to the thread also linked to
  [previous research][alm fees] on this topic by Kalle Alm and led to a
  discussion about whether mempool information should be used to both
  raise and lower feerate estimates, or if it should only be used to
  lower estimates.  The advantage of doing both is that it overall makes
  the estimates more useful; the advantage of only lowering estimates
  using mempool data (while only raising estimates using the existing
  confirmation-based estimation) is that it could be more resistant to
  manipulation and positive feedback loops.

  Discussion was ongoing as of this writing. {% assign timestamp="34:49" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What are the risks of running a pre-SegWit node (0.12.1)?]({{bse}}122211)
  Michael Folkson, Vojtěch Strnad, and Murch list downsides to running Bitcoin
  Core 0.12.1 for an individual user including a higher risk of accepting an
  invalid transaction or block, increased vulnerability to double spend attacks,
  higher reliance on others to do updated consensus validation, much slower
  block validation, missing many performance improvements, inability to use
  [compact block relay][topic compact block relay], not relaying ~95% of current
  unconfirmed transactions, less accurate [fee estimation][topic fee
  estimation], and vulnerability to security issues fixed in previous versions.
  Wallet users of 0.12.1 would also miss out on developments around
  [miniscript][topic miniscript], [descriptor][topic descriptors] wallets, and
  the fee savings and additional script capabilities enabled by [segwit][topic
  segwit], [taproot][topic taproot], and [schnorr signatures][topic schnorr
  signatures]. Effects on the Bitcoin network if Bitcoin Core
  0.12.1 was more broadly adopted could include: higher chance of invalid
  blocks being accepted by the network and associated reorg risk, miner
  centralization pressure from increased stale block risk, and decreased mining
  rewards for miners running that version. {% assign timestamp="50:30" %}

- [When is OP_RETURN cheaper than OP_FALSE OP_IF?]({{bse}}122321)
  Vojtěch Strnad details the overheads associated with `OP_RETURN`-based data
  embedding and `OP_FALSE` `OP_IF`-based embedding, concluding that "`OP_RETURN`
  is cheaper for data smaller than 143 bytes". {% assign timestamp="55:51" %}

- [Why does BIP-340 use secp256k1?]({{bse}}122268)
  Pieter Wuille explains the rationale of choosing secp256k1 over Ed25519 for
  [BIP340][] schnorr signatures and notes "reusability of existing key derivation
  infrastructure" and "not changing security assumptions" as reasons for the choice. {% assign timestamp="56:33" %}

- [What criteria does Bitcoin Core use to create block templates?]({{bse}}122216)
  Murch explains Bitcoin Core's current ancestor set feerate-based algorithm for
  transaction selection for a block candidate and mentions ongoing work on [cluster
  mempool][topic cluster mempool] which offers various improvements. {% assign timestamp="58:08" %}

- [How does the initialblockdownload field in the getblockchaininfo RPC work?]({{bse}}122169)
  Pieter Wuille notes the two conditions that need to occur after node startup
  for `initialblockdownload` to become false:

  1. "The currently active chain has at least as much cumulative PoW as the hardcoded constant in the software"
  2. "The timestamp of the currently active tip is no more than 24 hours in the past"

{% assign timestamp="1:04:45" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.1rc2][] is a release candidate for a maintenance release
  of the network's predominant full node implementation. {% assign timestamp="1:07:34" %}

- [Bitcoin Core 27.0rc1][] is a release candidate for the next major
  version of the network's predominant full node implementation.
  There's a brief overview to [suggested testing topics][bcc testing]
  and a scheduled meeting of the [Bitcoin Core PR Review Club][]
  dedicated to testing today (March 27th) at 15:00 UTC. {% assign timestamp="1:07:55" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until about six months after the release of the upcoming version 27.*

- [Bitcoin Core #28950][] updates the `submitpackage` RPC with arguments
  for `maxfeerate` and `maxburnamount` which will terminate the call in
  failure if the provided package has an aggregate feerate above the
  indicated maximum or sends more than the indicated amount to a
  well-known template for an unspendable output. {% assign timestamp="1:17:13" %}

- [LND #8418][] begins polling its connected Bitcoin protocol client
  for its full node peers' [BIP133][] `feefilter` values.  The
  `feefilter` message allows a node to tell its connected peers the
  lowest feerate it'll accept for a transaction to relay.  LND will now
  use this information to avoid sending transactions with too low of a
  feerate.  Only `feefilter` values from outbound peers are used, as
  those are the peers the user's node chose to connect to and so they
  are less likely to be controlled by attackers than inbound peers that
  requested a connection. {% assign timestamp="1:19:07" %}

- [LDK #2756][] adds support for including a [trampoline routing][topic
  trampoline payments] packet in its messages.  This doesn't provide full
  support for using trampoline routing or providing trampoline routing
  services, but it does make it easier for other code to accomplish that
  using LDK. {% assign timestamp="1:23:44" %}

- [LDK #2935][] begins supporting sending [keysend payments][topic
  spontaneous payments] to [blinded paths][topic rv routing].  Keysend
  payments are unconditional payments sent without an invoice.  Blinded
  paths hide the final hops of the payment path from the spender.
  Blinded paths are usually encoded in an invoice, so they're usually
  not combined with keysend payments, but they can make sense when a
  Lightning service provider (LSP) or some other node wants to provide a
  generic invoice for a particular receiver without revealing the
  receiver's node ID. {% assign timestamp="1:25:55" %}

- [LDK #2419][] adds a state machine for handling [interactive
  transaction construction][topic dual funding], a dependency for
  dual-funded channels and [splicing][topic splicing]. {% assign timestamp="1:27:39" %}

- [Rust Bitcoin #2549][] makes various changes to the APIs for working
  with relative [locktimes][topic timelocks]. {% assign timestamp="1:32:54" %}

- [BTCPay Server #5852][] adds support for scanning BBQr animated QR
  codes (see [Newsletter #281][news281 bbqr]) for [PSBTs][topic psbt]. {% assign timestamp="1:33:36" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28950,8418,2756,2935,2419,2549,5852,27995" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[news281 bbqr]: /en/newsletters/2023/12/13/#bbqr-encoding-scheme-announced
[todd free relay]: https://gnusha.org/pi/bitcoindev/Zfg%2F6IZyA%2FiInyMx@petertodd.org/
[news288 rbfr]: /en/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[habovstiak boost]: https://gnusha.org/pi/bitcoindev/CALkkCJZWBTmWX_K0+ERTs2_r0w8nVK1uN44u-sz5Hbb-SbjVYw@mail.gmail.com/
[jahr boost]: https://gnusha.org/pi/bitcoindev/45ghFIBR0JCc4INUWdZcZV6ibkcoofy4MoQP_rQnjcA4YYaznwtzSIP98QvIOjtcnIdRQRt3jCTB419zFa7ZNnorT8Xz--CH4ccFCDv9tv4=@protonmail.com/
[harding sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696
[news116 sponsor]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[towns sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/5
[ismail fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703
[harding fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703/2
[alm fees]: https://scalingbitcoin.org/stanford2017/Day2/Scaling-2017-Optimizing-fee-estimation-via-the-mempool-state.pdf
[daftuar sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/6
