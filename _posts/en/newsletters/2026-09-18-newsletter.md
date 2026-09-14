---
title: 'Bitcoin Optech Newsletter #423'
permalink: /en/newsletters/2026/09/18/
name: 2026-09-18-newsletter
slug: 2026-09-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **Vardiff controllers that strand slowing miners:** Eric Price [posted][price
  vardiff] to Delving Bitcoin an analysis of how [mining pools][topic pooled
  mining] adjust difficulty for a miner that slows down. A pool assigns each
  miner a share difficulty, a target easier than the network's that a block
  header candidate must meet to be submitted as a share. Software called a
  variable difficulty (vardiff) controller, running in the pool or in a proxy
  between the miner and the pool, raises or lowers that difficulty based on
  how quickly the miner's shares arrive, aiming for a steady rate. A miner
  that slows keeps the difficulty set for its former speed, so it produces few
  shares, and shares are the only signal that would let the controller notice.

  Price argues that adjusting the controller's parameters cannot fix this, since
  the controller cannot estimate a rate from shares that do not arrive. A
  controller that recomputes only when a share lands can hold difficulty too
  high indefinitely. His fix is a timer that lowers the difficulty whenever a
  fixed interval passes without a share from the miner. The Stratum v2 reference
  implementation already does this, although it recovers slowly for miners with
  long-lived connections. Ckpool recomputes only on shares. He released a
  [shaping proxy][shape proxy] that drops a fraction of a miner's shares so
  operators can test whether their pool lowers the difficulty.

  Anthony Towns [suggested][towns vardiff] handling this in the local proxy or
  gateway used in Stratum v2 and [DATUM][news325 datum] deployments, for example
  by halving a connection's difficulty after 30 seconds without a share. Price
  agreed and argued in a [separate thread][price frontier] that per-miner
  control must sit at the last hop that still sees each miner's shares.

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

{% include snippets/recap-ad.md when="2026-09-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[price vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718
[shape proxy]: https://github.com/marafoundation/sv2-apps/tree/shape-proxy-v0.1.0/test-tools/shape-proxy
[towns vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718/4
[news325 datum]: /en/newsletters/2024/10/18/#datum-protocol-announced
[price frontier]: https://delvingbitcoin.org/t/vardiff-belongs-at-the-frontier/2734
