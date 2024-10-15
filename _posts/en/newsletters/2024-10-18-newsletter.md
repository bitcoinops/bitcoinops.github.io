---
title: 'Bitcoin Optech Newsletter #325'
permalink: /en/newsletters/2024/10/18/
name: 2024-10-18-newsletter
slug: 2024-10-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME:harding

## News

_No significant news this week was found in any of our [sources][optech sources]._

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.5][] is a release candidate (RC) of this library for
  building wallets and other Bitcoin-enabled applications.  This latest
  RC "enables RBF by default, updates the bdk_esplora client to retry
  server requests that fail due to rate limiting. The `bdk_electrum`
  crate now also offers a use-openssl feature."

<!-- FIXME:harding to update Thursday -->

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30955][] Mining interface: getCoinbaseMerklePath() and submitSolution()

- [Eclair #2927][] Enforce recommended feerate for on-the-fly funding (#2927)

- [Eclair #2922][] Remove support for splicing without quiescence (#2922)

- [LDK #3235][] Add `last_local_balance_msats` field

- [LND #8183][] chanbackup, server, rpcserver: put close unsigned tx, remote signature and commit height to SCB

- [Rust Bitcoin #3450][] Add version three variant to transaction version

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30955,2927,2922,3235,8183,3450" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
