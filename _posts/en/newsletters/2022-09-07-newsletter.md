---
title: 'Bitcoin Optech Newsletter #216'
permalink: /en/newsletters/2022/09/07/
name: 2022-09-07-newsletter
slug: 2022-09-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes several notable changes to popular
Bitcoin infrastructure software.

## News

*No significant news this week.*

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25717][] adds a "Headers Presync" step during Initial
  Block Download (IBD) to help prevent Denial of Service (DoS) attacks and
  step towards removing checkpoints. Nodes use the pre-sync phase to
  verify that a peer's headers chain has sufficient work before storing
  them permanently.

  During IBD, adversarial peers may attempt to stall the syncing process, serve
  blocks that don't lead to the most-work chain, or simply exhaust the
  node's resources. As such, while sync speed and bandwidth usage are
  important concerns during IBD, a primary design goal is avoiding
  Denial of Service attacks. Since v0.10.0, Bitcoin Core nodes sync block
  headers first before downloading block data and reject headers that
  don't connect to a set of checkpoints. Instead of using hard-coded
  values, this new design utilizes the inherent DoS-resistant property of
  Proof of Work (PoW) puzzles to minimize the amount of memory allocated
  before finding the main chain.

  With these changes, nodes download headers twice during initial
  headers sync: a first pass to verify the headers' PoW
  (without storing them) until the accumulated work meets a
  predetermined threshold, and then a second pass to store them. To
  prevent an attacker sending the main chain during presync and then a
  different, malicious chain during redownload, the node stores
  commitments to the headers chain during presync. {% assign timestamp="2:34" %}

- [Bitcoin Core #25355][] adds support for transient, one-time I2P
  addresses when only outbound [I2P connections][topic anonymity networks] are allowed. In I2P, the
  recipient learns the I2P address of the connection initiator.
  Non-listening I2P nodes will now by default make use of transient I2P
  addresses when making outbound connections. {% assign timestamp="22:41" %}

- [BDK #689][] adds an `allow_dust` method which allows a wallet to
  create a transaction that violates the [dust limit][topic uneconomical
  outputs].  Bitcoin Core and other nodes which use the same settings
  won't relay unconfirmed transactions unless every output (except
  `OP_RETURN`) receives more satoshis than the dust limit.  BDK usually
  prevents users from creating such unrelayable transactions by
  enforcing the dust limit on the transactions it creates, but this new
  option allows ignoring that policy.  The author of the PR mentions
  that they're using it for testing their wallet. {% assign timestamp="31:45" %}

- [BDK #682][] adds signing capabilities for hardware signing devices using
  [HWI][topic hwi] and the [rust-hwi][rust-hwi github] library. The PR also introduces a Ledger
  device emulator for testing. {% assign timestamp="39:07" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="25717,25355,689,682" %}
[rust-hwi github]: https://github.com/bitcoindevkit/rust-hwi
