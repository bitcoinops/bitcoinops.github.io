---
title: 'Bitcoin Optech Newsletter #309'
permalink: /en/newsletters/2024/06/28/
name: 2024-06-28-newsletter
slug: 2024-06-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes research into estimating the
likelihood that an LN payment is feasible.  Also included are our regular
sections with descriptions of popular questions and answers from the
Bitcoin Stack Exchange, announcements of new releases and release
candidates, and summaries of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Estimating the likelihood that an LN payment is feasible:** René
  Pickhardt [posted][pickhardt feasible1] to Delving Bitcoin about
  estimating the likelihood that an LN payment is feasible given the
  public knowledge of a channel's maximum capacity but no knowledge
  about its current balance distribution.  For example, Alice has a
  channel with Bob and Bob has a channel with Carol.  Alice knows the
  capacity of the Bob-Carol channel but not how much of
  that balance is controlled by Bob and how much is controlled by Carol.

  Pickhardt notes that some wealth distributions are impossible in a
  payment network.  For example, Carol can't receive more money in her
  channel with Bob than the capacity of that channel.  When all the
  impossible distributions are excluded, it can be useful to consider
  all the remaining wealth distributions as equally likely to occur.
  That can be used to produce a metric for the likelihood that a payment
  is feasible.

  For example, if Alice wants to send a 1 BTC payment to Carol, and the
  only channels it can pass through are Alice-Bob and Bob-Carol, then
  we can look at what percentages of wealth distributions in the
  Alice-Bob channel and the Bob-Carol channel would allow that payment
  to succeed.  If the Alice-Bob channel has a capacity of several BTC,
  most possible wealth distributions would allow the payment to succeed.
  If the Bob-Carol channel has a capacity of just barely over 1 BTC, then
  most possible wealth distributions would prevent the payment from
  succeeding.  This can be used to calculate the overall likelihood
  of the feasibility of a payment of 1 BTC from Alice to Carol.

  The likelihood of feasibility makes it clear that many LN payments
  that naively seem possible will not succeed in practice.  It also
  provides a useful basis for making comparisons.
  In a [reply][pickhardt feasible2], Pickhardt describes how the
  likelihood metric could be used by wallets and business software to
  automatically make some intelligent decisions on behalf of its users.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.18.1-beta][] is a minor release with a fix for "an [issue][lnd
  #8862] that arises when handling an error after attempting to
  broadcast transactions if a btcd backend with an older version
  (pre-v0.24.2) is used."

- [Bitcoin Core 26.2rc1][] is a release candidate for a maintenance
  version of Bitcoin Core's older release series.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29575][] net_processing: make any misbehavior trigger immediate discouragement

- [Bitcoin Core #28984][] Cluster size 2 package rbf

- [Core Lightning #7388][] no longer allow creation of old
  (experimental-only!) non-zero-fee anchor channels. [...] We still
  support existing ones, though we were the only implementation which
  ever did, and only in experimental mode, so we should be able to
  upgrade them and avoid a forced close, with a bit of engineering...

  Harding notes: there's a lot of updates in this PR.  I think we've
  discussed most of them in the past, so a quick mention for them is
  fine but what I think is really worth announcing in this item are the
  changes in commit
  https://github.com/ElementsProject/lightning/pull/7388/commits/27a846a133832b6629231440b72f085c096e28d5

- [LND #8734][] routing: cancelable payment loop

- [LDK #3127][] Implement non-strict forwarding

- [Rust Bitcoin #2794][]

- [BDK #1395][] Remove `rand` dependency from `bdk`

- [BIPs #1620][] and [#1622][bips #1622] BIP-352: handle invalid privkey / pubkey sums for sending / scanning, add changelog / BIP-352: generate `input_hash` after summing up keys (simplification)

- [BOLTs #869][] BOLT 2: quiescence protocol (feature 34/35) option_quiesce

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29575,28984,7388,8734,3127,2794,1395,1620,1622,869,8862" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[pickhardt feasible1]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973
[pickhardt feasible2]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973/4
[lnd v0.18.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.1-beta
