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
  addresses. {% assign timestamp="1:06:09" %}

- **Sparrow 2.4.0 and 2.4.2 released:**
  Sparrow [2.4.0][sparrow 2.4.0] adds [BIP375][] [PSBT][topic psbt] fields for
  [silent payment][topic silent payments] hardware wallet support and adds a
  [Codex32][topic codex32] importer. Sparrow [2.4.2][sparrow 2.4.2] adds [v3
  transaction][topic v3 transaction relay] support. {% assign timestamp="1:13:15" %}

- **Blockstream Jade adds Lightning via Liquid:**
  Blockstream [announced][jade ln blog] that Jade hardware wallet (via Green app
  5.2.0) can now interact with Lightning using [submarine swaps][topic submarine
  swaps] that convert Lightning payments to [Liquid][topic sidechains] Bitcoin
  (L-BTC), keeping keys offline. {% assign timestamp="1:15:33" %}

- **Lightning Labs releases agent tools:**
  Lightning Labs [released][ll agent tools] an open-source toolkit enabling AI
  agents to operate on Lightning without human intervention or API keys using
  the [L402 protocol][blip 26]. {% assign timestamp="14:49" %}

- **Tether launches MiningOS:**
  Tether [launched][tether mos] MiningOS, an open-source operating system for
  managing Bitcoin mining operations. The Apache 2.0 licensed software is
  hardware-agnostic with a modular, P2P architecture. {% assign timestamp="1:17:38" %}

- **FIBRE network relaunched:**
  Localhost Research [announced][fibre blog] the relaunch of FIBRE (Fast
  Internet Bitcoin Relay Engine), previously shut down in 2017.
  The reboot includes a Bitcoin Core v30 rebase and monitoring suite,
  with six public nodes deployed globally. FIBRE complements [compact block
  relay][topic compact block relay] for low-latency block propagation. {% assign timestamp="1:35" %}

- **TUI for Bitcoin Core released:**
  [Bitcoin-tui][btctui tweet], a terminal interface for Bitcoin Core, connects
  via JSON-RPC to display blockchain and network data, featuring mempool
  monitoring, transaction search and broadcasting, and peer management. {% assign timestamp="1:19:34" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 31.0rc1][] is a release candidate for the next major
  version of the predominant full node implementation. A [testing
  guide][bcc31 testing] is available. {% assign timestamp="28:24" %}

- [BTCPay Server 2.3.6][] is a minor release of this self-hosted
  payment solution that adds label filtering in the wallet search bar,
  includes payment method data in the invoices API endpoint, and allows
  plugins to define custom permission policies. It also includes several
  bug fixes. {% assign timestamp="1:20:55" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31560][] extends the `dumptxoutset` RPC (see
  [Newsletter #72][news72 dump]), enabling the UTXO set snapshot to be
  written to a named pipe. This allows the output to be streamed
  directly to another process, bypassing the need to write the full dump
  to disk. This combines well with the `utxo_to_sqlite.py` tool (see
  [Newsletter #342][news342 sqlite]), allowing a SQLite database of the
  UTXO set to be created on the fly. {% assign timestamp="1:21:55" %}

- [Bitcoin Core #31774][] starts protecting the AES-256 encryption key
  material used for wallet encryption with `secure_allocator` to prevent
  it from being swapped to disk by the operating system when running low
  on memory, and zeroes it from memory when no longer used. When a user
  encrypts or unlocks their wallet, the passphrase is used to derive an
  AES key that encrypts or decrypts the wallet's private keys.
  Previously, this key material was allocated using the standard
  allocator, meaning it could be swapped to disk or linger in memory. {% assign timestamp="1:23:35" %}

- [Core Lightning #8817][] fixes several [splice][topic splicing]
  interoperability issues with Eclair that were discovered during
  cross-implementation testing (see Newsletters
  [#331][news331 interop] and [#355][news355 interop] for previous
  interop work). CLN now handles `channel_ready` messages that Eclair
  may send during splice reestablishment before resuming negotiation,
  fixes RPC error handling that could cause a crash, and implements
  announcement signature retransmission via new `channel_reestablish`
  TLVs. {% assign timestamp="1:25:12" %}

- [Eclair #3265][] and [LDK #4324][] start rejecting [BOLT12
  offers][topic offers] where `offer_amount` is set to zero, to align
  with the latest changes in the BOLT specification (see [Newsletter
  #396][news396 amount]). {% assign timestamp="1:27:41" %}

- [LDK #4427][] adds support for [RBF][topic rbf] fee bumping of
  [splice][topic splicing] funding transactions that have been
  negotiated but not yet locked, by re-entering the [quiescence][topic
  channel commitment upgrades] state. When both peers attempt to RBF
  simultaneously, the quiescence tie-breaker loser can contribute as the
  acceptor. Prior contributions are automatically reused when the
  counterparty initiates an RBF, preventing the fee bump from silently
  removing a peer's splice funds. See [Newsletter #396][news396 splice]
  for the base splice acceptor contribution support that this builds on.  {% assign timestamp="22:36" %}

- [LDK #4484][] raises the maximum accepted channel [dust][topic
  uneconomical outputs] limit to 10,000 satoshis for [anchor][topic
  anchor outputs] channels with zero-fee [HTLCs][topic htlc], including
  [zero-conf channels][topic zero-conf channels]. This implements the
  recommendation from [BOLTs #1301][] (see [Newsletter #395][news395
  dust]). {% assign timestamp="23:45" %}

- [BIPs #1974][] publishes [BIP446][] and [BIP448][] as Draft BIPs.
  [BIP446][] specifies `OP_TEMPLATEHASH`, a new [tapscript][topic
  tapscript] opcode that pushes a hash of the spending transaction
  onto the stack (see [Newsletter #365][news365 op] for the initial
  proposal). [BIP448][] groups `OP_TEMPLATEHASH` with
  [OP_INTERNALKEY][BIP349] and [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] to propose "Taproot-native (Re)bindable
  Transactions". This [covenant][topic covenants] bundle would enable
  [LN-Symmetry][topic eltoo] as well as reduce interactivity in and
  simplify other second layer protocols. {% assign timestamp="49:52" %}

{% include snippets/recap-ad.md when="2026-03-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31560,31774,8817,3265,4324,4427,4484,1974,1301" %}
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
[bitcoin core 31.0rc1]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[BTCPay Server 2.3.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.6
[news72 dump]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news342 sqlite]: /en/newsletters/2025/02/21/#bitcoin-core-27432
[news331 interop]: /en/newsletters/2024/11/29/#core-lightning-7719
[news355 interop]: /en/newsletters/2025/05/23/#core-lightning-8021
[news396 amount]: /en/newsletters/2026/03/13/#bolts-1316
[news396 splice]: /en/newsletters/2026/03/13/#ldk-4416
[news395 dust]: /en/newsletters/2026/03/06/#bolts-1301
[news365 op]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal