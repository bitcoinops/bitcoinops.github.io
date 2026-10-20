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
  with freely licensed [source][workbook source]. {% assign timestamp="0:48" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.1][] is the release of a maintenance
  version of the predominant full node software. {% assign timestamp="10:48" %}

- [Eclair v0.13.0][] is the release of this LN node implementation.  It
  "s release contains a lot of refactoring, an initial implementation of
  taproot channels, [...] improvements to splicing based on recent
  specification updates, and better Bolt 12 support."  The taproot
  channels and splicing features are still being fully specified, so
  they should not be used by regular users.  The release notes also
  warn: "This is the last release of eclair where channels that don't
  use anchor outputs will be supported.  If you have channels that don't
  use anchor outputs, you should close them." {% assign timestamp="11:17" %}

- [Bitcoin Core 30.0rc1][] is a release candidate for the next major
  version of this full verification node software. {% assign timestamp="25:27" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30469][] updates the types of the
  `m_total_prevout_spent_amount`, `m_total_new_outputs_ex_coinbase_amount` and
  `m_total_coinbase_amount` values from `CAmount` (64 bit) to `arith_uint256`
  (256 bit) to prevent a value overflow bug that has already been observed on
  the default [signet][topic signet]. The new version of the coinstats index is
  stored in `/indexes/coinstatsindex/` and an upgraded node will need to sync
  from scratch to rebuild the index. The old version is kept for downgrade
  protection, but may be removed in a future update. {% assign timestamp="31:45" %}

- [Eclair #3163][] adds a test vector to ensure that a payee’s public key can be
  recovered from a [BOLT11][] invoice with a high-S signature, in addition to
  already allowing low-S signatures. This aligns with the behaviour of
  libsecp256k1 and the proposed [BOLTs #1284][]. {% assign timestamp="33:18" %}

- [Eclair #2308][] introduces a new `use-past-relay-data` option that when set
  to true (default false), uses a probabilistic approach based on past
  payment attempt history to improve pathfinding. This replaces a prior method
  that assumed uniformity in channel balances. {% assign timestamp="40:27" %}

- [Eclair #3021][] allows the non-initiator of a [dual-funded channel][topic
  dual funding] to [RBF][topic rbf] the funding transaction, which is already
  allowed in [splicing][topic splicing] transactions. However, an exception
  applies to [liquidity advertisement][topic liquidity advertisements] purchase
  transactions. This has been proposed in [BOLTs #1236][]. {% assign timestamp="45:18" %}

- [Eclair #3142][] adds a new `maxClosingFeerateSatByte` parameter to the
  `forceclose` API endpoint that overrides the global feerate configuration
  for non-urgent force close transactions on a per-channel basis. The global
  setting `max-closing-feerate` was introduced in [Eclair #3097][]. {% assign timestamp="48:08" %}

- [LDK #4053][] introduces zero-fee commitment channels by replacing the two
  anchor outputs with one shared [Pay-to-Anchor (P2A)][topic ephemeral anchors]
  output, capped at a value of 240 sats. Additionally, it switches [HTLC][topic
  htlc] signatures in zero-fee commitment channels to
  `SIGHASH_SINGLE|ANYONECANPAY` and bumps HTLC transactions to [version 3][topic
  v3 transaction relay]. {% assign timestamp="50:30" %}

- [LDK #3886][] extends `channel_reestablish` for [splicing][topic splicing] with
  two `funding_locked_txid` TLVs (what a node last sent and received) so that
  peers can reconcile the active funding transaction upon reconnecting.
  Additionally, it streamlines the reconnection process by resending
  `commitment_signed` before `tx_signatures`, handling implicit `splice_locked`,
  adopting `next_funding`, and requesting announcement signatures as needed. {% assign timestamp="58:12" %}

{% include snippets/recap-ad.md when="2025-09-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30469,3163,2308,3021,3142,4053,3886,1284,1236,3097" %}
[bitcoin core 29.1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[nick workbook]: https://delvingbitcoin.org/t/provable-cryptography-for-bitcoin-an-introduction-workbook/1974
[workbook pdf]: https://github.com/cryptography-camp/workbook/releases
[workbook source]: https://github.com/cryptography-camp/workbook
[Eclair v0.13.0]: https://github.com/ACINQ/eclair/releases/tag/v0.13.0
