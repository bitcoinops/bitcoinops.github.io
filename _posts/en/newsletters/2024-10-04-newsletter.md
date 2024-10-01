---
title: 'Bitcoin Optech Newsletter #323'
permalink: /en/newsletters/2024/10/04/
name: 2024-10-04-newsletter
slug: 2024-10-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a planned security disclosure and
includes our regular sections describing new releases, release
candidates, and notable changes to popular Bitcoin infrastructure
software.

## News

- **Impending btcd security disclosure:** Antoine Poinsot
  [posted][poinsot btcd] to Delving Bitcoin to announce the planned
  disclosure on October 10th of a consensus bug affecting the btcd full
  node.  Using data from a rough survey of active full nodes, Poinsot
  surmises that there about 36 btcd nodes that are vulnerable (although
  20 of those nodes are also vulnerable to an already disclosed
  consensus vulnerability, see [Newsletter #286][news286 btcd vuln]).
  In a [reply][osuntokun btcd], btcd maintainer Olaoluwa Osuntokun
  confirmed the existence of the vulnerability and that it was fixed in
  btcd version 0.24.2.  Anyone running an older version of btcd is
  encouraged to upgrade to the [latest release][btcd v0.24.2], which was
  already announced as security critical.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 28.0][] is the latest major release of the predominant
  full node implementation.  It's the first release to include support
  for [testnet4][topic testnet], opportunistic one-parent-one-child
  (1p1c) [package relay][topic package relay], default relay of opt-in
  topologically restricted until confirmation ([TRUC][topic v3
  transaction relay]) transactions, default relay of
  [pay-to-anchor][topic ephemeral anchors] transactions, limited package
  [RBF][topic rbf] relay, and default [full-RBF][topic rbf].  Default
  parameters for [assumeUTXO][topic assumeutxo] have been added,
  allowing the `loadtxoutset` RPC to be used with a UTXO set downloaded
  outside of the Bitcoin network (e.g. via a torrent).  The release also
  includes many other improvements and bug fixes, as described in its
  [release notes][bcc 28.0 rn].

- [BDK 1.0.0-beta.5][] is a release candidate (RC) of this library for
  building wallets and other Bitcoin-enabled applications.  This latest
  RC "enables RBF by default, updates the bdk_esplora client to retry
  server requests that fail due to rate limiting. The `bdk_electrum`
  crate now also offers a use-openssl feature."

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30043][] net: Replace libnatpmp with built-in PCP+NATPMP implementation

- [Bitcoin Core #30510][] and [#30409][bitcoin core #30409] multiprocess: Add IPC wrapper for Mining interface; Introduce waitTipChanged() mining interface, replace RPCNotifyBlockChange, drop CRPCSignals & g_best_block

- [Core Lightning #7644][] hsmtool: provide nodeid from hsm secret.

- [Eclair #2875][] Add support for `funding_fee_credit` (#2875)

- [Eclair #2861][] Implement on-the-fly funding based on splicing and liquidity ads (#2861)

- [Eclair #2860][] Add `recommended_feerates` optional message (#2860)

- [Eclair #2848][] Extensible Liquidity Ads (#2848)

- [LDK #3303][] Merge pull request #3303 from TheBlueMatt/2024-09-inbound-payment-id

- [BDK #1616][] Merge bitcoindevkit/bdk#1616: feat(wallet)!: enable RBF by default on TxBuilder

- [BIPs #1600][] BIP85: Update/clarify spec, add change log, Portuguese language code, dice application (#1600)

- [BOLTs #798][] BOLT 12: offers, sixth draft

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30043,30510,7644,2875,2861,2860,2848,3303,1616,1600,798,30409" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[bitcoin core 28.0]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[poinsot btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177
[osuntokun btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177/3
[news286 btcd vuln]: /en/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd
[btcd v0.24.2]: https://github.com/btcsuite/btcd/releases/tag/v0.24.2
[bcc 28.0 rn]: https://github.com/bitcoin/bitcoin/blob/5de225f5c145368f70cb5f870933bcf9df6b92c8/doc/release-notes.md
