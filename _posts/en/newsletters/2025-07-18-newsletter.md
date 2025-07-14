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

FIXME:bitschmidty

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
