---
title: 'Bitcoin Optech Newsletter #363'
permalink: /en/newsletters/2025/07/18/
name: 2025-07-18-newsletter
slug: 2025-07-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections summarizing updates
to services and client software, announcing new releases and release
candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

_No significant news this week was found in any of our [sources][]._

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Floresta v0.8.0 released:**
  The [Floresta v0.8.0][floresta v0.8.0] release of this [Utreexo][topic utreexo] node adds support for [version 2 P2P
  transport (BIP324)][topic v2 p2p transport], [testnet4][topic testnet],
  enhanced metrics and monitoring, among other features and bugfixes.

- **RGB v0.12 announced:**
  The RGB v0.12 [blog post][rgb blog] announces the release of RBG's consensus
  layer for RGB's [client-side validated][topic client-side validation] smart
  contracts on Bitcoin testnet and mainnet.

- **FROST signing device available:**
  [Frostsnap][frostsnap website] signing devices support k-of-n [threshold signing][topic
  threshold signature] using the FROST protocol, with only a single signature on chain.

- **Gemini adds taproot support:**
  Gemini Exchange and Gemini Custody add support for sending (withdrawing) to
  [taproot][topic taproot] addresses.

- **Electrum 4.6.0 released:**
  [Electrum 4.6.0][electrum 4.6.0] adds support for [submarine swaps][topic
  submarine swaps] using nostr for discoverability.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.19.2-beta][] is the release of a maintenance
  version of this popular LN node.  It "contains important bug fixes and
  performance improvements."

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32604][] log: Mitigate disk filling attacks by rate limiting LogPrintf, LogInfo, LogWarning, LogError

- [Bitcoin Core #32618][] wallet: Remove ISMINE_WATCHONLY and watchonly from RPCs

- [Bitcoin Core #31553][] cluster mempool: add TxGraph reorg functionality

- [Core Lightning #7725][] logs: A basic javascript log viewer

- [Eclair #2716][] Endorse htlc and local reputation

- [LDK #3628][] Static invoice server

- [LDK #3890][] Use `cost / path amt limit` as the pathfinding score, not `cost`

- [LND #10001][] Enable quiescence in production and add timeout config

{% include snippets/recap-ad.md when="2025-07-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32604,32618,31553,7725,2716,3628,3890,10001" %}
[LND v0.19.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta
[sources]: /en/internal/sources/
[floresta v0.8.0]: https://github.com/vinteumorg/Floresta/releases/tag/v0.8.0
[rgb blog]: https://rgb.tech/blog/release-v0-12-consensus/
[frostsnap website]: https://frostsnap.com/
[electrum 4.6.0]: https://github.com/spesmilo/electrum/releases/tag/4.6.0
