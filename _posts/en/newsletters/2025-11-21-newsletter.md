---
title: 'Bitcoin Optech Newsletter #381'
permalink: /en/newsletters/2025/11/21/
name: 2025-11-21-newsletter
slug: 2025-11-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **Modeling stale rates by propagation delay and mining centralization:**
  Antoine Poinsot [posted to Delving Bitcoin][antoine delving] about modeling
  stale block rates and how block propagation time affects a miner's revenue as
  a function of its hashrate given propagation time is zero. He set up a
  base-case scenario in which all miners act realistically (with a default
  Bitcoin Core node): if they receive a new block, they would immediately start
  mining on top of it and publish it. This would lead to revenue proportional to
  their share of the hashrate.

  In his model with uniform block propagation, he outlined two situations in which a
  block goes stale.

  1. Another miner found a block **before** this miner did. All other miners received
     the competing miner's block first and started mining on top of it. Any of
     these miners can then find a second block based on the received block.

  2. Another miner finds a block **after** this miner did. It immediately starts mining
     on top of it. The following block is also found by the same miner.

  Poinsot points out that, between these situations, it is more likely for a
  block to become stale in the first situation. This suggests that miners may
  care more about hearing others' blocks faster than they care about publishing
  their own. He also suggests that the probability of situation 2 increases
  significantly with miner centralization. While in both situations the
  probability increases as miner hashrate increases, Poinsot wanted to compute
  by how much.

  To do this, he created the following two models.

  Where **h** is the share of network hashrate, **s** is the number of seconds
  the rest of the network found a competing block before it did, **H** is the
  set of hashrates on the network representing its distribution.

  Model for situation 1:
  ![Illustration of P(another miner found a block before)](/img/posts/2025-11-stale-rates1.png)

  Model for situation 2:
  ![Illustration of P(another miner found a block after)](/img/posts/2025-11-stale-rates2.png)

  He went on to show graphs of probabilities that a miner's block goes stale as
  a function of propagation times, given the set distribution of hashrate. The
  graphs show how larger miners gain significantly more the longer the
  propagation time is.

  For example a mining operation with 5EH/s can expect a revenue of $91M and if
  blocks took 10 seconds to propogate the revenue would be increased by $100k.
  Keep in mind that the $91M is revenue and not profit so the increased revenue
  of $100k would contribute to a larger factor in terms of miner's net profit.

  Below the charts, he provides the methodology for generating the charts and a
  link to his [simulation][block prop simulation] which corroborates the
  results of the model used to generate the graphs.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2025-11-25 16:30" %}
{% include references.md %}
[antoine delving]: https://delvingbitcoin.org/t/propagation-delay-and-mining-centralization-modeling-stale-rates/2110
[block prop simulation]: https://github.com/darosior/miningsimulation
