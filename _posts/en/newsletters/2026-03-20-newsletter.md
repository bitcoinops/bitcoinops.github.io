---
title: 'Bitcoin Optech Newsletter #397'
permalink: /en/newsletters/2026/03/20/
name: 2026-03-20-newsletter
slug: 2026-03-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections describing changes
to services and client software, announcing new releases and release
candidates, and summarizing recent changes to popular Bitcoin
infrastructure software.

## News

*No significant news this week was found in any of our [sources][].*

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Cake Wallet adds Lightning support:**
  Cake Wallet [announced][cake ln post] Lightning Network support using the
  Breez SDK and a [Spark][topic statechains] integration, including Lightning
  addresses.

- **Sparrow 2.4.0 and 2.4.2 released:**
  Sparrow [2.4.0][sparrow 2.4.0] adds [BIP375][] [PSBT][topic psbt] fields for
  [silent payment][topic silent payments] hardware wallet support and adds a
  [Codex32][topic codex32] importer. Sparrow [2.4.2][sparrow 2.4.2] adds [v3
  transaction][topic v3 transaction relay] support.

- **Blockstream Jade adds Lightning via Liquid:**
  Blockstream [announced][jade ln blog] that Jade hardware wallet (via Green app
  5.2.0) can now interact with Lightning using [submarine swaps][topic submarine
  swaps] that convert Lightning payments to [Liquid][topic sidechains] Bitcoin
  (L-BTC), keeping keys offline.

- **Lightning Labs releases agent tools:**
  Lightning Labs [released][ll agent tools] an open-source toolkit enabling AI
  agents to operate on Lightning without human intervention or API keys using
  the [L402 protocol][blip 26].

- **Tether launches MiningOS:**
  Tether [launched][tether mos] MiningOS, an open-source operating system for
  managing Bitcoin mining operations. The Apache 2.0 licensed software is
  hardware-agnostic with a modular, P2P architecture.

- **FIBRE network relaunched:**
  Localhost Research [announced][fibre blog] the relaunch of FIBRE (Fast
  Internet Bitcoin Relay Engine), previously shut down in 2017.
  The reboot includes a Bitcoin Core v30 rebase and monitoring suite,
  with six public nodes deployed globally. FIBRE complements [compact block
  relay][topic compact block relay] for low-latency block propagation.

- **TUI for Bitcoin Core released:**
  [Bitcoin-tui][btctui tweet], a terminal interface for Bitcoin Core, connects
  via JSON-RPC to display blockchain and network data, featuring mempool
  monitoring, transaction search and broadcasting, and peer management.

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

{% include snippets/recap-ad.md when="2026-03-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[sources]: /en/internal/sources/
[cake ln post]: https://blog.cakewallet.com/our-lightning-journey/
[sparrow 2.4.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.0
[sparrow 2.4.2]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.2
[jade ln blog]: https://blog.blockstream.com/jade-lightning-payments-are-here/
[ll agent tools]: https://github.com/lightninglabs/lightning-agent-tools
[blip 26]: https://github.com/lightning/blips/pull/26
[x402 blog]: https://blog.cloudflare.com/x402/
[tether mos]: https://mos.tether.io/
[fibre blog]: https://lclhost.org/blog/fibre-resurrected/
[btctui tweet]: https://x.com/_jan__b/status/2031741548098896272
