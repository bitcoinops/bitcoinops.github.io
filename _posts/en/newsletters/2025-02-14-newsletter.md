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

[Cluster mempool: introduce TxGraph][review club 31363] is a PR by
[sipa][gh sipa] that introduces the `TxGraph` class, which encapsulates
knowledge about the (effective) fees, sizes, and dependencies between
all mempool transactions, but nothing else. It is part of the [cluster
mempool][topic cluster mempool] project and brings a comprehensive
interface that allows interaction with the mempool graph through
mutation, inspector, and staging functions.

Notably, `TxGraph` does not have any knowledge about `CTransaction`,
inputs, outputs, txids, wtxids, prioritization, validity, policy
rules, and a lot more. This makes it easier to (almost) fully specify
the class's behavior, allowing for simulation-based tests - which are
included in the PR.


{% include functions/details-list.md
  q0="What is the mempool \"graph\" and to what extent does it exist in
  the mempool code on master?"
  a0="On master, the mempool graph exists implicitly as the set of
  `CTxMemPoolEntry` objects as nodes, and their ancestor/dependant
  relationships which can be recursively traversed with
  `GetMemPoolParents()` and `GetMemPoolChildren()`."
  a0link="https://bitcoincore.reviews/31363#l-26"

  q1="What are the benefits of having a `TxGraph`, in your own words?
  Can you think of drawbacks?"
  a1="Benefits include: 1) `TxGraph` enables the implementation of
  [cluster mempool][topic cluster mempool], with all of its benefits. 2)
  Better encapsulation of mempool code, using more efficient data
  structures. 3) Makes it easier to interface with and reason about the
  mempool, abstracting away topological details such as not
  double-counting replacements.
  <br><br>Drawbacks include: 1) The significant review and testing efforts
  associated with the large changes introduced. 2) It restricts how
  validation can dictate per-transaction topology limits, as is for
  example relevant to TRUC and other policies. 3) A very slight run-time
  performance overhead caused by translation to-and-from the
  `TxGraph::Ref*` pointers."
  a1link="https://bitcoincore.reviews/31363#l-54"

  q2="How many `Clusters` can an individual transaction be part of,
  within a `TxGraph`?"
  a2="Even though a transaction can conceptually only belong to a single
  cluster, the answer is 2. This is because a `TxGraph` can encapsulate
  2 parallel graphs: \"main\", and optionally \"staging\"."
  a2link="https://bitcoincore.reviews/31363#l-116"

  q3="What does it mean for a `TxGraph` to be oversized? Is that the
  same as the mempool being full?"
  a3="A `TxGraph` is oversized when at least one of its `Cluster`s
  exceeds the `MAX_CLUSTER_COUNT_LIMIT`. This is not the same as the
  mempool being full, because a `TxGraph` can have more than one
  `Cluster`."
  a3link="https://bitcoincore.reviews/31363#l-147"

  q4="If a `TxGraph` is oversized, which functions can still be called,
  and which ones can’t?"
  a4="Operations that could require actually materializing an oversized
  cluster, as well as functions that require O(n<sup>2</sup>) work or more, are
  not allowed for an oversized `Cluster`. This includes operations such
  as computing the ancestors/descendants of a transaction. Mutation
  operations (`AddTransaction()`, `RemoveTransaction()`,
  `AddDependency()`, and `SetTransactionFee()`), and operations such as
  `Trim()` (roughly `O(n log n)`) are still allowed."
  a4link="https://bitcoincore.reviews/31363#l-162"
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
[review club 31363]: https://bitcoincore.reviews/31363
[gh sipa]: https://github.com/sipa
[news244 ebpf]: https://bitcoinops.org/en/newsletters/2023/03/29/#bitcoin-core-26531
[news160 ebpf]: https://bitcoinops.org/en/newsletters/2021/08/04/#bitcoin-core-22006
[ludpr]: https://github.com/lnurl/luds/pull/234
[news232 deschash]: /en/newsletters/2023/01/04/#btcpay-server-4411
[news194 deschash]: /en/newsletters/2022/04/06/#c-lightning-5121
