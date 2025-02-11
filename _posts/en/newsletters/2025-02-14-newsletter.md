---
title: 'Bitcoin Optech Newsletter #341'
permalink: /en/newsletters/2025/02/14/
name: 2025-02-14-newsletter
slug: 2025-02-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes continued discussion about
probabilistic payments, describes additional opinions about ephemeral
anchor scripts for LN, relays statistics about evictions from the
Bitcoin Core orphan pool, and announces an updated draft for a revised
BIP process.  Also included are our regular sections summarizing a
Bitcoin Core PR Review Club meeting, announcing new releases and release
candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Continued discussion about probabilistic payments:** following
  Oleksandr Kurbatov's [post][kurbatov pp] to Delving Bitcoin last week
  about emulating an `OP_RAND` opcode (see [Newsletter #340][news340
  pp]), several discussions were started:

  - _Suitability as an alternative to trimmed HTLCs:_ Dave Harding
    [asked][harding pp] if Kurbatov's method was suitable for use inside
    an [LN-Penalty][topic ln-penalty] or [LN-Symmetry][topic eltoo]
    payment channel for routing [HTLCs][topic htlc] that are currently
    [uneconomical][topic uneconomical outputs], which is currently done
    using [trimmed HTLCs][topic trimmed htlc] whose value is lost if
    they're pending during a channel force closure.  Anthony Towns
    [didn't think that would work][towns pp1] with the existing
    protocol's roles due to them being the inverse of the corresponding
    roles used for resolving HTLCs.  However, he thought tweaks to the
    protocol might be able to align it with HTLCs.

  - _Setup step required:_ Towns [discovered][towns pp1] that the
    originally published protocol was missing a step.  Kurbatov
    concurred.

  - _Simpler zero-knowledge proofs:_ Adam Gibson [suggested][gibson pp1]
    that using [schnorr][topic schnorr signatures] and [taproot][topic
    taproot] rather than hashed public keys might significantly
    simplify and speed up the construction and verification of the required
    zero-knowledge proof.  Towns [offered][towns pp2] a tentative
    approach, which [Gibson][gibson pp2] analyzed.

  Discussion was ongoing at the time of writing.

- **Continued discussion about ephemeral anchor scripts for LN:** Matt
  Morehouse [replied][morehouse eanchor] to the thread about what
  [ephemeral anchor][topic ephemeral anchors] script LN should use for
  future channels (see [Newsletter #340][news340 eanchor]).  He
  expressed concerns about third-party fee griefing of transactions with
  [P2A][topic ephemeral anchors] outputs.

  Anthony Towns [noted][towns eanchor] that counterparty griefing is a
  greater concern, since the counterparty is more likely to be in a
  position to steal funds if the channel isn't closed on time or in the
  proper state.  Third parties who delay your transaction or attempt to
  moderately increase its feerate may lose some of their money,
  with no direct way to profit from you.

  Greg Sanders [suggested][sanders eanchor] thinking probabilistically:
  if the worst a third-party griefer can do is raise the cost of your
  transaction by 50%, but using a griefing-resistant method costs about
  10% extra, do you really expect to be griefed by a third party more
  often than one force close out of every five---especially if the
  third-party griefer may lose money and doesn't benefit financially?

- **Stats on orphan evictions:** developer 0xB10C [posted][b10c orphan]
  to Delving Bitcoin with statistics about the number of transactions
  evicted from the orphan pools for his nodes.  Orphan transactions are
  unconfirmed transactions for which a node doesn't yet have all of its
  parent transactions, without which it cannot be included in a block.
  Bitcoin Core by default keeps up to 100 orphan transactions.  If a new
  orphan transaction arrives after the pool is full, a previously
  received orphan transaction is evicted.

  0xB10C found that, on some days, more than 10 million orphans were
  evicted by his node, with a peak rate of over 100,000 evictions per
  minute.  Upon investigating, he found ">99% of these [...] are similar
  to this [transaction][runestone tx], which seems related to runestone
  mints [a colored coin (NFT) protocol]"  It appeared that many of the
  same orphan transactions were repeatedly requested, randomly evicted a
  short time later, and then requested again.

- **Updated proposal for updated BIP process:** Mark "Murch" Erhardt
  [posted][erhardt bip3] to the Bitcoin-Dev mailing list to announce that his draft
  BIP for a revised BIP process has been assigned the identifier BIP3
  and is ready for additional review---possibly its last round of review
  before being merged and activated.  Anyone with opinions is encouraged
  to leave feedback on the [pull request][bips #1712].

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/31397#l-23FIXME"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.18.5-beta][] is a bug fix release of this popular LN node
  implementation.  Its bug fixes are described as "important"
  and "critical" in its release notes.

- [Bitcoin Inquisition 28.1][] is a minor release of this [signet][topic
  signet] full node designed for experimenting with proposed soft forks
  and other major protocol changes.  It includes the bug fixes included
  in Bitcoin Core 28.1 plus support for [ephemeral dust][topic ephemeral
  anchors].

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #25832][] tracing: network connection tracepoints

- [Eclair #2989][] Add router support for batched splices

- [LDK #3440][] Support receiving async payments

- [LND #9470][] Make BumpFee RPC user inputs more stricter.

- [BTCPay Server #6580][] Remove LNURL description hash check, see
  https://bitcoinops.org/en/newsletters/2022/04/06/#c-lightning-5121 and
  https://bitcoinops.org/en/newsletters/2023/01/04/#btcpay-server-4411

## Corrections

In a [footnote][fn sigops] to last week's newsletter, we incorrectly
wrote: "In P2SH and the proposed input sigop counting, an
OP_CHECKMULTISIG with more than 16 public keys is counted as 20 sigops."
This is an oversimplification; for the actual rules, please see a
[post][towns sigops] this week by Anthony Towns.

{% include snippets/recap-ad.md when="2025-02-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="25832,2989,3440,9470,6580,1712" %}
[lnd v0.18.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta
[Bitcoin Inquisition 28.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.1-inq
[news340 pp]: /en/newsletters/2025/02/07/#emulating-op-rand
[towns sigops]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/69
[kurbatov pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[harding pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/2
[towns pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/3
[gibson pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/5
[towns pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/6
[gibson pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/7
[morehouse eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/8
[news340 eanchor]: /en/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts
[towns eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/9
[sanders eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/11
[b10c orphan]: https://delvingbitcoin.org/t/stats-on-orphanage-overflows/1421/
[runestone tx]: https://mempool.space/tx/ac8990b04469bad8630eaf2aa51561086d81a241deff6c95d96d27e41fa19f90
[erhardt bip3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/25449597-c5ed-42c5-8ac1-054feec8ad88@murch.one/
[fn sigops]: /en/newsletters/2025/02/07/#fn:2kmultisig
