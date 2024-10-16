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

- **Coinbase adds taproot send support:**
  Coinbase exchange [now supports][coinbase post] user withdrawals (send) to taproot
  [bech32m][topic bech32] addresses.

- **Dana wallet released:**
  [Dana wallet][dana wallet github] is a [silent payment][topic silent payments] wallet focused the
  donation use case. The developers recommend using [signet][topic signet] and
  also run a signet [faucet][dana wallet faucet].

- **Bitcoin script editor and visualizer:**
  The Saving Satoshi [script editor][saving satoshi editor] allows for visually
  building and executing Bitcoin scripts.

- **Kyoto BIP157/158 light client released:**
  [Kyoto][kyoto github] is a Rust light client using [compact block
  filters][topic compact block filters] for use by wallet developers.

- **DLC Markets launches on mainnet:**
  The [DLC][topic dlc]-based platform [announced][dlc markets blog] mainnet
  availability for its non-custodial trading service.

- **Ashigaru wallet announced:**
  Ashigaru is a fork of the Samourai Wallet project and the
  [announcement][ashigaru blog] listed improvements to [batching][scaling
  payment batching], [RBF][topic rbf] support, and [fee estimation][topic fee estimation].

- **DATUM protocol announced:**
  The [DATUM mining protocol][datum docs] the allows miners to build candidate blocks as part
  of a [pooled mining][topic pooled mining] setup, similar to the Stratum v2 protocol.

- **Bark Ark implementation announced:**
  The Second team [announced][bark blog] the [Bark][bark codeberg]
  implementation of the [Ark][topic ark] protocol and [demonstrated][bark demo]
  live Ark transactions on mainnet.

- **Phoenix v2.4.0 and phoenixd v0.4.0 released:**
  The [Phoenix v2.4.0][phoenix v2.4.0] and [phoenixd v0.4.0][] releases add
  support for the [BLIP36][blip36] on-the-fly funding proposal and other
  liquidity features (see [Podcast #323][pod323 eclair]).

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
[coinbase post]: https://x.com/CoinbaseAssets/status/1843712761391399318
[dana wallet github]: https://github.com/cygnet3/danawallet
[dana wallet faucet]: https://silentpayments.dev/
[saving satoshi editor]: https://script.savingsatoshi.com/
[kyoto github]: https://github.com/rustaceanrob/kyoto
[dlc markets blog]: https://blog.dlcmarkets.com/dlc-markets-reshaping-bitcoin-trading/
[ashigaru blog]: https://ashigaru.rs/news/release-wallet-v1-0-0/
[datum docs]: https://ocean.xyz/docs/datum
[bark blog]: https://blog.second.tech/ark-on-bitcoin-is-here/
[bark codeberg]: https://codeberg.org/ark-bitcoin/bark
[bark demo]: https://blog.second.tech/demoing-the-first-ark-transactions-on-bitcoin-mainnet/
[phoenix v2.4.0]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.4.0
[phoenixd v0.4.0]: https://github.com/ACINQ/phoenixd/releases/tag/v0.4.0
[blip36]: https://github.com/lightning/blips/pull/36
[pod323 eclair]: /en/podcast/2024/10/08/#eclair-2848-transcript
