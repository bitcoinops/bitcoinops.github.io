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

- **Private key handover for collaborative closure**: ZmnSCPxj [posted][privkeyhand post] to Delving
  Bitcoin about private key handover, an optimization that protocols can
  implement when funds, previously owned by two parties, need to be refunded to
  a single entity. This enhancement requires [taproot][topic taproot] and
  [MuSig2][topic musig] support to work in the most efficient way.

  An example of such a protocol would be an [HTLC][topic htlc], where one party
  pays the other if the preimage is revealed, creating a refunding transaction
  that needs to be signed by both parties. Private key handover would allow an
  entity to simply handover an ephemeral private key to the other after the
  preimage has been revealed, thus giving the receiver complete and unilateral
  access to the funds.

  The steps to achieve a private key handover are:

  - When setting up an HTLC, Alice and Bob each exchange an ephemeral and a
    permanent public key.

  - The keypath spend branch of the HTLC taproot output is computed as the
    MuSig2 of Alice and Bob's ephemeral public keys.

  - At the end of the protocol operations, Bob provides the preimage to Alice,
    who in turn hands him over the ephemeral private key.

  - Bob can now derive the combined private key for the MuSig2 sum, gaining full
    control over the funds.

  This optimization brings some particular benefits. First of all, in case of a
  sudden spike in onchain fees, Bob would be able to [RBF][topic rbf] the
  transaction without the other party's collaboration. This feature is
  particularly useful for protocol developers, since they would not need to
  implement RBF in a simple proof of concept. Second, the receiver would be
  able to batch the transaction claiming the funds with any other operation.

  Private key handover is limited to protocols that require the remaining funds
  to be transferred entirely to a single beneficiary. Thus, [splicing][topic
  splicing] or cooperative closure of Lightning channels would not benefit from
  this.

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
[privkeyhand post]: https://delvingbitcoin.org/t/private-key-handover/2098
