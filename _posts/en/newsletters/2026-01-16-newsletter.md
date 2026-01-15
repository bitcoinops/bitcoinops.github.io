---
title: 'Bitcoin Optech Newsletter #388'
permalink: /en/newsletters/2026/01/16/
name: 2026-01-16-newsletter
slug: 2026-01-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a discussion of incremental mutation testing in
Bitcoin Core and announces deployment of a new BIP process.  Also included are
our regular sections announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

- **An overview of incremental mutation testing in Bitcoin Core**: Bruno Garcia
  [posted][mutant post] to Delving Bitcoin about his current work on improving
  [mutation testing][news320 mutant] in Bitcoin Core. Mutation testing is a technique that allows
  developers to assess the effectiveness of their tests by intentionally adding
  systemic bugs, called mutants, to the codebase. If a test fails, the mutant is
  considered "killed", signaling that the test is able to catch the fault; otherwise,
  it survives, revealing a potential issue in the test.

  Mutation testing has provided significant results, leading to PRs being opened
  to address some reported mutants. However, the process is resource-intensive,
  taking more than 30 hours to complete on a subset of the codebase.
  This is the reason why Garcia is currently focusing on incremental mutation
  testing, a technique that applies mutation testing progressively, focusing only on
  parts of the codebase that have changed since the last analysis.
  While the approach is faster, it still takes too much time.

  Thus, Garcia is working on improving the efficiency of Bitcoin Core's incremental
  mutation testing, following a [paper][mutant google] by Google. The approach is based on the
  following principles:

  - Avoiding bad mutants, such as those syntactically different from
    the original program but semantically identical. This means those that will always behave in
    the same way regardless of the input.

  - Collecting feedback from developers to refine mutant generation, to understand where
    mutations tend to provide unhelpful results.

  - Report only a limited number of unkilled mutants (7, according to Google's
    research), to not overwhelm developers with possibly low-informative mutants.

  Garcia tested his approach on eight different PRs, gathering feedback and suggesting
  changes to address mutants.

  To conclude, Garcia asked Bitcoin Core contributors to notify him on their PRs in case they
  wanted a mutation test run and to report feedback on the provided mutants.


## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 30.2][] is a maintenance release that fixes a bug where the
  entire `wallets` directory could be accidentally deleted when migrating an
  unnamed legacy wallet (see Newsletter [#387][news387 wallet]). It includes a
  few other improvements and fixes; see the [release notes][] for all details.

- [BTCPay Server 2.3.3][] is a minor release of this self-hosted payment
  solution that introduces cold wallet transaction support via the `Greenfield`
  API (see below), removes CoinGecko-based exchange rate sources, and includes several bug
  fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33819][] introduces a new `getCoinbaseTx()` method on the
  `Mining` interface (see [Newsletter #310][news310 mining]) to return a struct
  containing all the fields clients need to construct a coinbase transaction.
  The existing  `getCoinbaseTx()` method, which instead returned a serialized
  dummy transaction that clients had to parse and manipulate, is renamed to
  `getCoinbaseRawTx()` and is deprecated alongside `getCoinbaseCommitment()`, and
  `getWitnessCommitmentIndex()`.

- [Bitcoin Core #29415][] adds a new `privatebroadcast` boolean option to
  broadcast transactions through short-lived [Tor][topic anonymity networks] or
  I2P connections, or through the Tor proxy to IPv4/IPv6 peers, when using the
  `sendrawtransaction` RPC. This approach protects the privacy of the
  transaction originator by concealing their IP address and by using separate
  connections for each transaction to prevent linkability.

- [Core Lightning #8830][] adds a `getsecret` command to the `hsmtool` utility
  (see [Newsletter #73][news73 hsmtool]) that replaces the existing
  `getsecretcodex` command with additional support for recovering nodes created
  after the changes introduced in v25.12 (see [Newsletter #383][news383 bip39]).
  The new command outputs the [BIP39][] mnemonic seed phrase for a given
  `hsm_secret` file for new nodes, and retains the functionality of outputting
  `Codex32` strings for legacy nodes. The `recover` plugin is updated to accept
  mnemonics.

- [Eclair #3233][] starts using the configured default feerates when Bitcoin
  Core fails to estimate fees on [testnet3][topic testnet] or testnet4 due to
  insufficient block data. The default feerates are updated to better match
  current values.

- [Eclair #3237][] reworks the channel lifecycle events to be compatible with
  [splicing][topic splicing] and consistent with [zero-conf][topic zero-conf
  channels] by adding the following: `channel-confirmed`, which signals that the
  funding transaction or splice has been confirmed, and `channel-ready`, which
  signals that the channel is ready for payments. The `channel-opened` event is
  removed.

- [LDK #4232][] adds support for the experimental `accountable` signal, which
  replaces [HTLC endorsement][topic htlc endorsement], as proposed in [BLIPs
  #67][] and [BOLTs #1280][]. LDK now sets zero-value accountable signals on its
  own payments and on forwards with no signal, and copies the incoming
  accountable value to outgoing forwards when present. This follows similar
  changes in Eclair and LND (see [Newsletter #387][news387 accountable]).

- [LND #10296][] adds an `inputs` field to the `EstimateFee` RPC command
  request, allowing users to get a [fee estimate][topic fee estimation] for a
  transaction using specific inputs instead of letting the wallet select them
  automatically.

- [BTCPay Server #7068][] adds support for cold wallet transactions via the
  `Greenfield` API, allowing users to generate unsigned [PSBTs][topic psbt] and
  broadcast externally signed transactions through a new endpoint. This feature
  provides greater security in automated environments and enables setups that
  meet higher regulatory compliance requirements.

- [BIPs #1982][] adds [BIP433][] to specify the [Pay-to-Anchor (P2A)][topic
  ephemeral anchors] standard output type and makes spending of this
  output type standard.

{% include snippets/recap-ad.md when="2026-01-20 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33819,29415,8830,3233,3237,4232,67,1280,10296,7068,1982,2051" %}
[mutant post]: https://delvingbitcoin.org/t/incremental-mutation-testing-in-the-bitcoin-core/2197
[news320 mutant]:/en/newsletters/2024/09/13/#mutation-testing-for-bitcoin-core
[mutant google]: https://research.google/pubs/state-of-mutation-testing-at-google/
[Bitcoin Core 30.2]: https://bitcoincore.org/bin/bitcoin-core-30.2/
[release notes]: https://bitcoincore.org/en/releases/30.2/
[BTCPay Server 2.3.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.3
[news387 wallet]: /en/newsletters/2026/01/09/#bitcoin-core-34156
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news73 hsmtool]: /en/newsletters/2019/11/20/#c-lightning-3186
[news383 bip39]: /en/newsletters/2025/12/05/#core-lightning-v25-12
[news387 accountable]: /en/newsletters/2026/01/09/#eclair-3217
