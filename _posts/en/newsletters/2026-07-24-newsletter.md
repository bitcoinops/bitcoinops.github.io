---
title: 'Bitcoin Optech Newsletter #415'
permalink: /en/newsletters/2026/07/24/
name: 2026-07-24-newsletter
slug: 2026-07-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a draft BIP for full aggregation of BIP340
signatures. Also included are our regular sections describing recent changes to
services and client software, announcing new releases and release candidates,
and summarizing notable changes to popular Bitcoin infrastructure software.

## News

- **Draft BIP for full aggregation of BIP340 signatures**: Fabian Jahr [posted][aggr ml] to
  the Bitcoin-Dev mailing list about a new draft BIP for full aggregation of
  [BIP340][] [schnorr signatures][topic schnorr signatures], a standard for the DahLIAS aggregate signature scheme
  (see [Newsletter #351][news351 dahlias]), which describes a process to
  combine a collection of signatures into a single aggregate one, with a size
  of only 64 bytes, regardless of the number of signers. However, the described
  protocol is interactive and requires cooperation among all the signers and involves
  the presence of an untrusted coordinator to reduce communication complexity.
  The coordinator role can be taken by any of the signers participating in the process.

  The process is divided into two rounds:

  1. Each signer starts the signing session by computing a secret nonce
  (`secnonce`) and a public nonce (`pubnonce`). `pubnonce` is sent to the
  coordinator, which aggregates them (`aggnonce`) and sends the result back to
  signers, together with other pieces of information.

  2. Each signer computes a partial signature using the secret key, `secnonce`,
  the message to sign, and the information provided. Partial signatures are then
  sent to the coordinator, which aggregates them in a single 64-byte signature.

  According to Jahr, one of the possible applications of the proposal would
  be [cross-input signature aggregation (CISA)][topic cisa], a change to Bitcoin
  consensus that would reduce size and thus on-chain fees of multi-input transactions.
  However, the author specified that the consensus change is outside the scope of this BIP.

  The draft BIP, which is now referred to as BIP459, is currently being discussed in [BIPs #2210][]
  and the proposal is gathering feedback from the community.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Wasabi Wallet 2.8.0 released:**
  Wasabi Wallet [2.8.0][wasabi 2.8.0] downloads [compact block filters][topic compact
  block filters] directly from the P2P network, removing the previously
  required centralized backend server. The release also adds the ability to pay
  recipients directly within a [coinjoin][topic coinjoin], support for
  [feerates below 1 sat/vbyte][topic default minimum transaction relay
  feerates], and [payment batching][topic payment batching], among other
  features.

- **Coinswap v0.2.2 released:**
  Coinswap [v0.2.2][coinswap v0.2.2] adds multi-transaction swaps, deniability
  proofs, and marketplace improvements to its [coinswap][topic coinswap]
  protocol implementation (see Newsletter [#338][news338 coinswap]). The
  release also includes fixes for findings from a security audit performed
  using Loupe, Spiral's open source, AI-powered security scanner.

- **Go secp256k1 library announced:**
  Allocz [announced][secp256k1 go delving] a [Go library][secp256k1 go] that
  uses [libsecp256k1][libsecp256k1 repo] bindings when C interoperability is
  enabled and falls back to a pure-Go implementation otherwise, preserving Go's
  cross-compilation capability. The author reports ECDSA and [schnorr
  signature][topic schnorr signatures] verification times drop 70% compared to
  the pure-Go implementation.

- **ASMap dashboard announced:**
  Joris Strakeljahn [announced][asmap delving] an [ASMap
  dashboard][asmap dashboard] that tracks the history of [ASMap
  data][github asmap-data] releases (see Newsletter [#394][news394 asmap]),
  including how much address space shifts between operators from release to
  release and how well each release covers actually observed Bitcoin nodes as
  the data ages.

- **Wavelength alpha released:**
  Lightning Labs [announced][wavelength blog] an alpha version of Wavelength,
  a toolkit for adding self-custodial payments to applications. It pays and
  receives BOLT11 LN invoices, and batches off-chain transfers using an
  [Ark][topic ark]-like settlement layer, without requiring users to manage their own
  channels. The alpha is available on [signet][topic signet] and testnet.

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

{% include snippets/recap-ad.md when="2026-07-28 16:30" %}
{% include references.md %}
[aggr ml]: https://groups.google.com/g/bitcoindev/c/TF5mPfy58RQ/m/vAk1Mfg2AwAJ
[news351 dahlias]: /en/newsletters/2025/04/25/#interactive-aggregate-signatures-compatible-with-secp256k1
[wavelength blog]: https://lightning.engineering/posts/2026-07-21-wavelength-launch/
[wasabi 2.8.0]: https://github.com/WalletWasabi/WalletWasabi/releases/tag/v2.8.0
[coinswap v0.2.2]: https://github.com/citadel-tech/coinswap/releases/tag/v0.2.2
[news338 coinswap]: /en/newsletters/2025/01/24/#coinswap-v0-1-0-released
[secp256k1 go delving]: https://delvingbitcoin.org/t/a-faster-go-golang-secp256k1-library/2658
[secp256k1 go]: https://github.com/allocz/secp256k1
[asmap delving]: https://delvingbitcoin.org/t/asmap-dashboard-tracking-the-asmap-data-history-against-the-observed-network/2652
[asmap dashboard]: https://jorisstrakeljahn.github.io/asmap-dashboard/
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news394 asmap]: /en/newsletters/2026/02/27/#bitcoin-core-28792
