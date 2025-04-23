---
title: 'Bitcoin Optech Newsletter #349'
permalink: /en/newsletters/2025/04/11/
name: 2025-04-11-newsletter
slug: 2025-04-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for speeding up Bitcoin
Core initial block download, with a proof-of-concept implementation that
shows a roughly 5x speed up compared to Bitcoin Core's defaults.  Also
included are our regular sections summarizing a Bitcoin Core PR Review
Club meeting, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

- **SwiftSync speedup for initial block download:** Sebastian
  Falbesoner [posted][falbesoner ss1] to Delving Bitcoin a sample
  implementation and performance results for _SwiftSync_, an idea
  [proposed][somsen ssgist] by Ruben Somsen during a recent Bitcoin Core
  developers meeting and later [posted][somsen ssml] to the mailing
  list.  As of writing, the [most recent results][falbesoner
  ss2] posted in the thread show a 5.28x speedup of _initial block
  download_ (IBD) over Bitcoin Core's default IBD settings (which uses
  [assumevalid][] but not [assumeUTXO][topic assumeutxo]), reducing the
  initial sync time from about 41 hours
  to about 8 hours.

  Before using SwiftSync, someone who has already synced their node to
  a recent block creates a _hints file_ that indicates which transaction
  outputs will be in the UTXO set at that block (i.e., which
  outputs will be unspent).  This can be efficiently encoded to a few
  hundred megabytes for the current UTXO set size.  The hints file also
  indicates what block it was generated at, which we'll call the
  _terminal SwiftSync block_.

  The user performing SwiftSync downloads the hints file and uses it
  when processing each block prior to the terminal SwiftSync block to
  only store outputs in the UTXO database if the hints file indicates
  that the output will remain in the UTXO set when the terminal
  SwiftSync block is reached.  This massively reduces the number of
  entries that are added, and then later removed, from the UTXO database
  during IBD.

  To ensure that the hints file is correct, every created output not
  stored in the UTXO database is added to a [cryptographic
  accumulator][].  Every spent output is removed from the accumulator.
  When the node reaches the terminal SwiftSync block, it ensures the
  accumulator is empty, meaning every output seen was later spent.  If
  that fails, it means that the hints file was incorrect and that IBD
  needs to be performed again from scratch without using SwiftSync.  In
  this way, users do not need to trust the creator of the hints file---a
  malicious file cannot result in an incorrect UTXO state; it can only
  waste a few hours of the user's computing resources.

  An additional property of SwiftSync that has not yet been implemented
  is allowing parallel validation of blocks during IBD.  This is
  possible because assumevalid does not check the scripts of older
  blocks, entries are never removed from UTXO database prior to the
  terminal SwiftSync block, and the accumulator used only tracks the net
  effect of outputs being added (created) and removed (spent).  That
  eliminates any dependencies between blocks before the terminal
  SwiftSync block.  Parallel validation during IBD is also a feature of
  [Utreexo][topic utreexo] for some of the same reasons.

  The discussion examined several aspects of the proposal.  Falbesoner's
  original implementation used the [MuHash][] accumulator (see
  [Newsletter #123][news123 muhash]), which [has been shown][wuille
  muhash] to be resistant to the [generalized birthday attack][].
  Somsen [described][somsen ss1] an alternative approach that may be
  faster.  Falbesoner questioned whether the alternative approach was
  cryptographically secure but, since it was simple, implemented it
  anyway and found it further sped up SwiftSync.

  James O'Beirne [asked][obeirne ss] whether SwiftSync is useful given
  that assumeUTXO provides an even larger speedup.
  Somsen [replied][somsen ss2] that SwiftSync speeds up assumeUTXO's
  background validation, making it a nice addition for users of
  assumeUTXO.  He further notes that anyone who downloads assumeUTXO's
  required data (the UTXO database at a particular block) doesn't need a
  separate hints file if they use that same block as the terminal
  SwiftSync block.

  Vojtěch Strnad, 0xB10C, and Somsen [discussed][b10c ss] compressing
  the hint file data, with an expected savings of about 75%, bringing the
  test hints file (for block 850,900) down to about 88 MB.

  Discussion was ongoing at the time of writing. {% assign timestamp="0:34" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Add Fee rate Forecaster Manager][review club 31664] is a PR by
[ismaelsadeeq][gh ismaelsadeeq] that upgrades the transaction fee
forecasting (also called [estimation][topic fee estimation]) logic. It introduces a new
`ForecasterManager` class to which multiple `Forecaster`s can be
registered. The existing `CBlockPolicyEstimator` (which only considers
confirmed transactions) is refactored to become one such forecaster, but
notably a new `MemPoolForecaster` is introduced. `MemPoolForecaster`
considers unconfirmed transactions that are in the mempool, and as such
can react to feerate changes more quickly.

{% include functions/details-list.md
  q0="Why is the new system called a “Forecaster” and
  “ForecasterManager” rather than an “Estimator” and “Fee Estimation
  Manager”?"
  a0="The system predicts future outcomes based on current and past
  data. Unlike an estimator, which approximates present conditions with
  some randomization, a forecaster projects future events, which aligns
  with this system’s predictive nature and its output of
  uncertainty/risk levels."
  a0link="https://bitcoincore.reviews/31664#l-19"

  q1="Why is `CBlockPolicyEstimator` not modified to hold the mempool
  reference, similar to the approach in PR #12966? What is the current
  approach and why is it better than holding a reference to mempool?
  (Hint: see PR #28368)"
  a1="`CBlockPolicyEstimator` inherits from `CValidationInterface` and
  implements its virtual methods `TransactionAddedToMempool`,
  `TransactionRemovedFromMempool`, and
  `MempoolTransactionsRemovedForBlock`. This gives
  `CBlockPolicyEstimator` all the mempool information it needs without
  being unnecessarily tightly coupled to the mempool via a reference."
  a1link="https://bitcoincore.reviews/31664#l-26"

  q2="What are the trade-offs between the new architecture and a direct
  modification of `CBlockPolicyEstimator`?"
  a2="The new architecture with a `FeeRateForecasterManager` class to
  which multiple `Forecaster`s can be registered is a more modular
  approach which allows for better testing, and enforces a better
  separation of concerns. It allows easily plugging in new forecasting
  strategies later on. This comes at the cost of a bit more code to
  maintain, and potentially confusing users about which estimation
  method to use."
  a2link="https://bitcoincore.reviews/31664#l-43"
%}

{% assign timestamp="29:33" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.02.1][] is a maintenance release for the current
  major version of this popular LN node that includes several bug fixes. {% assign timestamp="46:54" %}

- [Core Lightning 24.11.2][] is a maintenance release for a prior major
  version of this popular LN node.  It includes several bug fixes, some
  of them the same bug fixes that were released in version 25.02.1. {% assign timestamp="47:03" %}

- [BTCPay Server 2.1.0][] is a major release of this self-hosted payment
  processing software.  It includes breaking changes for users of some
  altcoins, improvements for [RBF][topic rbf] and [CPFP][topic cpfp] fee
  bumping, and a better flow for multisig when all signers are using
  BTCPay Server. {% assign timestamp="48:14" %}

- [Bitcoin Core 29.0rc3][] is a release candidate for the next major
  version of the network's predominate full node.  Please see the
  [version 29 testing guide][bcc29 testing guide]. {% assign timestamp="49:25" %}

- [LND 0.19.0-beta.rc2][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes. {% assign timestamp="51:21" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [LDK #2256][] and [LDK #3709][] improve attributable failures (see
  Newsletter [#224][news224 failures]) as specified in [BOLTs #1044][] by adding
  an optional `attribution_data` field to the `UpdateFailHTLC` struct and
  introducing the `AttributionData` struct. In this protocol, each forwarding
  node appends to the failure message a `hop_payload` flag, a duration field
  that records how long the node held the HTLC, and HMACs corresponding to
  different assumed positions in the route. If a node corrupts the failure
  message, the mismatch in the HMAC chain helps identify the pair of nodes
  between which this happened. {% assign timestamp="53:52" %}

- [LND #9669][] downgrades [simple taproot channels][topic simple taproot
  channels] to always use the legacy cooperative close flow, even if the
  [RBF][topic rbf] cooperative close flow (see Newsletter [#347][news347 coop])
  is configured. Previously, a node that had both features configured would fail
  to start up. {% assign timestamp="56:16" %}

- [Rust Bitcoin #4302][] adds a new `push_relative_lock_time()` method to the
  script builder API, which takes a relative [timelock][topic timelocks]
  parameter, and deprecates `push_sequence()` which takes a raw sequence number
  as a parameter. This change resolves a potential confusion where developers
  would mistakenly push a raw sequence number in scripts instead of a relative
  timelock value, which is then checked against an input's sequence number
  using `CHECKSEQUENCEVERIFY`. {% assign timestamp="57:24" %}

{% include snippets/recap-ad.md when="2025-04-15 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2256,3709,9669,4302,1044" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[wuille muhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[falbesoner ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/
[somsen ssgist]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[falbesoner ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/7
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[cryptographic accumulator]: https://en.wikipedia.org/wiki/Accumulator_(cryptography)
[news123 muhash]: /en/newsletters/2020/11/11/#bitcoin-core-pr-review-club
[muhash]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
[generalized birthday attack]: https://www.iacr.org/archive/crypto2002/24420288/24420288.pdf
[somsen ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/2
[obeirne ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/5
[somsen ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/6
[b10c ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/4
[somsen ssml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjaM0tfbcBTRa0_713Bk6Y9jr+ShOC1KZi2V3V2zooTXyg@mail.gmail.com/T/#u
[core lightning 25.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.02.1
[core lightning 24.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.2
[btcpay server 2.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.1.0
[news224 failures]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[news347 coop]: /en/newsletters/2025/03/28/#lnd-8453
[review club 31664]: https://bitcoincore.reviews/31664
[gh ismaelsadeeq]: https://github.com/ismaelsadeeq
[forecastresult compare]: https://github.com/bitcoin-core-review-club/bitcoin/commit/1e6ce06bf34eb3179f807efbddb0e9bca2d27f28#diff-5baaa59bccb2c7365d516b648dea557eb50e63837de71531dc460dbcc62eb9adR74-R77
