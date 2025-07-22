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
  The RGB v0.12 [blog post][rgb blog] announces the release of RGB's consensus
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

- [Bitcoin Core #32604][] rate-limits unconditional logging to disk such as for
  `LogPrintf`, `LogInfo`, `LogWarning` and `LogError` to mitigate disk-filling
  attacks by giving each source location a 1 MB per hour quota. All log lines
  are prefixed with an asterisk (*) when any source location is suppressed.
  Console output, logs with an explicit category argument, and `UpdateTip`
  Initial Block Download (IBD) messages are exempt from rate limits. When the
  quota resets, Core prints the number of bytes that were dropped.

- [Bitcoin Core #32618][] removes the `include_watchonly` option and its
  variants, as well as the `iswatchonly` field from all wallet RPCs because
  [descriptor][topic descriptors] wallets don’t support mixing watch-only and
  spendable descriptors. Previously, users could import a watch-only address or
  script into a legacy spending wallet. However, legacy wallets have now been
  removed.

- [Bitcoin Core #31553][] adds block reorg handling to the [cluster
  mempool][topic cluster mempool] project by introducing the `TxGraph::Trim()`
  function. When a reorg reintroduces previously confirmed transactions to the
  mempool and the resulting combined cluster exceeds cluster count or weight
  policy limits, `Trim()` builds a feerate-ordered, dependency‑respecting,
  rudimentary linearization. If adding a transaction would breach a limit, that
  transaction and all its descendants are dropped.

- [Core Lightning #7725][] adds a lightweight JavaScript log viewer that loads
  CLN log files in a browser and allows users to filter messages by daemon,
  type, channel, or regex. This tool adds minimal repository maintenance
  overhead while improving the debugging experience for developers and node
  runners.

- [Eclair #2716][] implements a local peer-reputation system for [HTLC
  endorsement][topic htlc endorsement] that tracks the routing fees earned by
  each incoming peer versus the fees that should have been earned based on the
  liquidity and [HTLC][topic htlc] slots used. Successful payments result in a
  perfect score, failed payments lower it, and HTLCs that remain pending past
  the configured threshold are heavily penalized. When forwarding, the node
  includes its current peer score in the `update_add_htlc` endorsement TLV (see
  Newsletter [#315][news315 htlc]). Operators can adjust the reputation decay
  (`half-life`), the stuck payment threshold (`max-relay-duration`), the penalty
  weight for stuck HTLCs (`pending-multiplier`), or simply disable the
  reputation system entirely in the configuration. This PR primarily collects
  data to improve [channel jamming attack][topic channel jamming attacks]
  research and does not yet implement penalties.

- [LDK #3628][] implements the server-side logic for [async payments][topic
  async payments], allowing an LSP node to provide [BOLT12][topic offers] static
  invoices on behalf of an often-offline recipient. The LSP node can accept
  `ServeStaticInvoice` messages from the recipient, store the provided static
  invoices, and respond to payer invoice requests by searching for and returning
  the cached invoice via [blinded paths][topic rv routing].

- [LDK #3890][] changes the way it scores routes in its pathfinding algorithm by
  considering total cost divided by channel amount limit (cost per sat of usable
  capacity) instead of considering only the raw total cost. This biases the
  selection toward higher-capacity routes and reduces excessive [MPP][topic
  multipath payments]  sharding, resulting in a higher payment success rate.
  Although the change overly penalizes small channels, this tradeoff is
  preferable to previous excessive sharding.

- [LND #10001][] enables the quiescence protocol in production (see Newsletter
  [#332][news332 quiescence]) and adds a new configuration value
  `--htlcswitch.quiescencetimeout`, which specifies the maximum duration for
  which a channel can be quiescent. The value ensures that dependent protocols,
  such as [dynamic commitments][topic channel commitment upgrades], finish
  within the timeout period. The default value is 60 seconds, and the minimum
  value is 30 seconds.

{% include snippets/recap-ad.md when="2025-07-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32604,32618,31553,7725,2716,3628,3890,10001" %}
[LND v0.19.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta
[sources]: /en/internal/sources/
[floresta v0.8.0]: https://github.com/vinteumorg/Floresta/releases/tag/v0.8.0
[rgb blog]: https://rgb.tech/blog/release-v0-12-consensus/
[frostsnap website]: https://frostsnap.com/
[electrum 4.6.0]: https://github.com/spesmilo/electrum/releases/tag/4.6.0
[news315 htlc]: /en/newsletters/2024/08/09/#eclair-2884
[news332 quiescence]: /en/newsletters/2024/12/06/#lnd-8270
