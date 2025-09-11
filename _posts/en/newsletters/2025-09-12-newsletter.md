---
title: 'Bitcoin Optech Newsletter #371'
permalink: /en/newsletters/2025/09/12/
name: 2025-09-12-newsletter
slug: 2025-09-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the availability of a workbook
dedicated to provable cryptography.  Also included are our regular
sections with links to new releases and release candidates, plus
descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **Provable Cryptography Workbook:** Jonas Nick [posted][nick workbook]
  to Delving Bitcoin to announce a short workbook he created for a four
  day event to "teach developers the basics of provable cryptography,
  [...] consisting of cryptographic definitions, propositions, proofs
  and exercises."  The workbook is available as a [PDF][workbook pdf]
  with freely licensesd [source][workbook source].

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.1][] is the release of a maintenance
  version of the predominant full node software.

- [Eclair v0.13.0][] is the release of this LN node implementation.  It
  "s release contains a lot of refactoring, an initial implementation of
  taproot channels, [...] improvements to splicing based on recent
  specification updates, and better Bolt 12 support."  The taproot
  channels and splicing features are still being fully specified, so
  they should not be used by regular users.  The release notes also
  warn: "This is the last release of eclair where channels that don't
  use anchor outputs will be supported.  If you have channels that don't
  use anchor outputs, you should close them."

- [Bitcoin Core 30.0rc1][] is a release candidate for the next major
  version of this full verification node software.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30469][] index: Fix coinstats overflow

- [Eclair #3163][] Add high-S signature Bolt 11 test vector

- [Eclair #2308][] Use balance estimates from past payments in path-finding

- [Eclair #3021][] Allow non-initiator RBF for dual funding

- [Eclair #3142][] Allow overriding `max-closing-feerate` with `forceclose` API

- [LDK #4053][] tankyleo/2025-09-p2a-anchor

- [LDK #3886][] Update `channel_reestablish` for splicing

{% include snippets/recap-ad.md when="2025-09-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30469,3163,2308,3021,3142,4053,3886" %}
[bitcoin core 29.1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[nick workbook]: https://delvingbitcoin.org/t/provable-cryptography-for-bitcoin-an-introduction-workbook/1974
[workbook pdf]: https://github.com/cryptography-camp/workbook/releases
[workbook source]: https://github.com/cryptography-camp/workbook
[Eclair v0.13.0]: https://github.com/ACINQ/eclair/releases/tag/v0.13.0
