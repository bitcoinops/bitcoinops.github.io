---
title: 'Bitcoin Optech Newsletter #186'
permalink: /en/newsletters/2022/02/09/
name: 2022-02-09-newsletter
slug: 2022-02-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a discussion about changing relay
policy for replace-by-fee transactions and includes our regular sections
with the summary of a Bitcoin Core PR Review Club meeting, announcements
of new releases and release candidates, and descriptions of notable
changes to popular Bitcoin infrastructure projects.

## News

- **Discussion about RBF policy:** Gloria Zhao started a
  [discussion][zhao rbf] on the Bitcoin-Dev mailing list about
  Replace-by-Fee ([RBF][topic rbf]) policy.  Her email provides
  background on the current policy, enumerates several problems
  discovered with it over the years (such as [pinning attacks][topic
  transaction pinning]), examines how the policy affects wallet user
  interfaces, and then describes several possible improvements.
  Significant attention is given to improvement ideas based on
  considering transactions within the context of the next block
  template---the proposed block a miner would create and then commit to
  when attempting to produce a proof of work.  By evaluating the impact
  of a replacement on the next block template, it's possible to
  determine for certain, without the use of heuristics, whether or not
  it will earn the miner of that next block more fee income.  Several
  developers replied with comments on Zhao's summary and her proposals,
  including additional or alternative proposals for changes that
  could be made.

    Discussion appeared to be ongoing as this summary was being written.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:glozow

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/23443#l-29"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.14.2-beta][] is the release for a
  maintenance version that includes several bug fixes and a few minor
  improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23508][] Add getdeploymentinfo RPC FIXME:Xekyo

- [Bitcoin Core #21851][] release: support cross-compiling for arm64-apple-darwin FIXME:adamjonas

- [Bitcoin Core #16795][] updates the `getrawtransaction`, `gettxout`,
  `decoderawtransaction`, and `decodescript` RPCs to return the inferred
  [output script descriptor][topic descriptors] for any scriptPubKeys
  that are decoded.

- [LND #6226][] sets 5% as the default fee for payments routed through
  LN when created using the legacy `SendPayment`, `SendPaymentSync`, and
  `QueryRoutes` RPCs.  Payments sent using the newer `SendPaymentV2` RPC
  default to zero fees, essentially requiring users to specify a value.
  An additional merged PR, [LND #6234][], defaults to 100% fees for
  payments of less than 1,000 satoshis made with the legacy RPCs.

- [LND #6177][] allows the users of the [HTLC][topic HTLC] interceptor
  to specify the reason an HTLC was failed, making the interceptor more
  useful for testing how failures affect software using LND.

- [Rust-Lightning #1227][] Merge pull request #1227 from jkczyz/2021-12-probabilistic-scorer FIXME:dongcarl

- [HWI #549][] adds support for [PSBT][topic psbt] version two as
  specified in [BIP370][].  When using a device that natively supports
  version zero PSBT, such as existing Coldcard hardware signing devices,
  v2 PSBTs are translated to v0 PSBTs.

- [HWI #544][] adds support for receiving and spending [taproot][topic
  taproot] payments with Trezor hardware signing devices.

{% include references.md %}
{% include linkers/issues.md v=1 issues="23508,21851,16795,6226,6234,6177,1227,549,544" %}
[lnd 0.14.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.2-beta
[zhao rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019817.html
