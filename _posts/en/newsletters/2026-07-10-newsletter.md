---
title: 'Bitcoin Optech Newsletter #413'
permalink: /en/newsletters/2026/07/10/
name: 2026-07-10-newsletter
slug: 2026-07-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes research into using fountain codes to allow
pruned nodes to contribute to initial block download. Also included are our
regular sections announcing new releases and release candidates, and describing
notable changes to popular Bitcoin infrastructure software.

## News

- **Using fountain codes for IBD**: Lucas Lima [posted][fount del] to Delving Bitcoin
  about his latest research on using [fountain codes][fount wiki] to allow pruned nodes
  to contribute to Initial Block Download (IBD), without significantly increasing their
  storage requirements.

  Lima provided a dedicated [blog post][fount blog] where he explains how this could be
  achieved by dividing the entire chain into epochs, fixed-length chunks made of `k` blocks,
  encoding these epochs using fountain codes, and sending these encodings, called droplets,
  together with block headers to those nodes that need to reconstruct the chain.
  The receiving node, referred to as a bucket node, needs to gather and decode enough droplets
  belonging to a certain epoch in order to reconstruct the `k` blocks. Block headers are then used
  to verify that the received data is valid, preventing malicious nodes from corrupting the
  reconstructed chain.

  Some critical points were raised during the discussion. In particular,
  developers highlighted the need for a high number of connected peers to manage to reconstruct
  the chain, slower IBD, risk of node fingerprinting, and possible increased DoS attack surface.

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

{% include snippets/recap-ad.md when="2026-07-14 16:30" %}
{% include references.md %}
[fount del]: https://delvingbitcoin.org/t/fountain-codes-a-way-to-reduce-blockchain-storage-costs/2624
[fount wiki]: https://en.wikipedia.org/wiki/Fountain_code
[fount blog]: https://lucasdbr05.com/posts/fountain-codes/
