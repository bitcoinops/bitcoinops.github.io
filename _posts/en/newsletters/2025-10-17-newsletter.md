---
title: 'Bitcoin Optech Newsletter #376'
permalink: /en/newsletters/2025/10/17/
name: 2025-10-17-newsletter
slug: 2025-10-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares an update on the proposal for nodes to share their
current block template and summarizes a paper outlining a covenant-less vault
construction. Also included are our regular sections announcing new releases and
release candidates and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Continued discussion of block template sharing:** Discussion
  [continued][towns tempshare] around the proposal for full node peers to
  occasionally send each other their current template for the next block using
  [compact block relay][topic compact block relay] encoding (see Newsletters
  [#366][news366 block template sharing] and [#368][news368 bts]). Feedback was
  raised around privacy and node fingerprinting concerns and the author decided
  to move the current draft to the [Bitcoin Inquisition Numbers and Names
  Authority][binana repo] (BINANA) repository, to address these considerations
  and to refine the document. The draft was given the code [BIN-2025-0002][bin]. {% assign timestamp="17:30" %}

- **B-SSL a Secure Bitcoin Signing Layer:** Francesco Madonna [posted][francesco
  post] to Delving Bitcoin about a concept which is a covenant-less
  [vault][topic vaults] model using [taproot][topic taproot],
  [`OP_CHECKSEQUENCEVERIFY`][op_csv], and [`OP_CHECKLOCKTIMEVERIFY`][op_cltv].
  In the post, he mentions that it uses existing Bitcoin primitives, which is
  important because most vault proposals require a soft fork.

  In the design, there are three different spend paths:

  1. A fast path for normal operation where an optional Convenience Service (CS)
  can enforce the chosen delay.

  2. A one-year fallback with custodian B.

  3. A three-year custodian path in case of disappearance or inheritance events.

  There are 6 different keys A, A₁, B, B₁, C and CS where B₁, and C are
  custodially held and are only used at the same time in the recovery path.

  This setup creates an environment where the user can lock up their funds and
  be fairly sure that the custodians they have entrusted their funds to won’t
  steal. While this does not restrict where the funds can move to like a
  [covenant][topic covenants] would, this setup does provide a more resilient
  scheme for self-custody with custodians. In the post, Francesco calls for
  readers to review and discuss the [white paper][bssl whitepaper] before anyone
  tries to implement this idea. {% assign timestamp="2:54" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 30.0][] is the latest version release of the network’s
  predominant full node. Its [release notes][notes30] describe several
  significant improvements, including a new 2500 cap on legacy sigops in
  standard transactions, multiple data carrier (OP_RETURN) outputs now being
  standard, an increased default  `datacarriersize` to 100,000, a default
  [minimum relay feerate][topic default minimum transaction relay feerates] and
  incremental relay feerate of 0.1sat/vb, a default minimum block feerate of
  0.001sat/vb, improved transaction orphanage DoS protections, a new `bitcoin`
  CLI tool, an experimental inter-process communication (IPC) mining interface
  for [Stratum v2][topic pooled mining] integrations, a new implementation of
  `coinstatsindex`, the `natpmp` option now being enabled by default, support
  for legacy wallets being removed in favor of [descriptor][topic descriptors] wallets, and support for
  spending and creating [TRUC][topic v3 transaction relay] transactions, among
  many other updates. {% assign timestamp="22:32" %}

- [Bitcoin Core 29.2][] is a minor release containing several bug fixes for P2P,
  mempool, RPC, CI, docs and other issues. Please see the [release
  notes][notes29.2] for more details. {% assign timestamp="28:44" %}

- [LDK 0.1.6][] is a release of this popular library for building LN-enabled
  applications that includes security vulnerability patches related to DoS and
  funds theft, performance improvements, and several bug fixes. {% assign timestamp="29:37" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #3184][] improves the cooperative closing flow by resending a
  `shutdown` message upon reconnection when one had already been sent before
  disconnection, as specified in [BOLT2][]. For [simple taproot channels][topic
  simple taproot channels], Eclair generates a new closing nonce for the resend
  and stores it, allowing the node to produce a valid `closing_sig` later. {% assign timestamp="30:59" %}

- [Core Lightning #8597][] prevents a crash that occurred when a direct peer
  returned a `failmsg` response after CLN sent a malformed [onion message][topic
  onion messages] via `sendonion` or `injectpaymentonion`. Now, CLN treats this
  as a plain first-hop failure and returns a clean error instead of crashing.
  Previously, it treated this as an encrypted `failonion` that came from further
  downstream. {% assign timestamp="32:25" %}

- [LDK #4117][] introduces an opt-in, deterministic derivation of the
  `remote_key` that uses the `static_remote_key`. This allows users to recover
  funds in the event of a force close using only the backup seed phrase.
  Previously, the `remote_key` depended on per-channel randomness, requiring
  channel state to recover funds. This new scheme is opt-in for new channels,
  but applies automatically when [splicing][topic splicing] existing ones. {% assign timestamp="34:05" %}

- [LDK #4077][] adds `SplicePending` and `SpliceFailed` events, with the former
  being emitted once a [splice][topic splicing] funding transaction is
  negotiated, broadcast, and locked by both sides (except in the case of an
  [RBF][topic rbf]). The latter event is emitted when a splice aborts before
  locking due to an `interactive-tx` failure, a `tx_abort` message, a channel
  shutdown, or a disconnection/reload while in a [quiescent][topic channel
  commitment upgrades] state. {% assign timestamp="35:03" %}

- [LDK #4154][] updates the handling of preimage on-chain monitoring to ensure
  that claim transactions are only created for [HTLCs][topic htlc] whose payment
  hash matches the retrieved preimage. Previously, LDK attempted to claim any
  claimable HTLC (expired ones and those with a known preimage), which risked
  creating invalid claim transactions and potential fund loss if the
  counterparty timed out another HTLC first. {% assign timestamp="36:47" %}

{% include snippets/recap-ad.md when="2025-10-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3184,8597,4117,4077,4154" %}
[francesco post]: https://delvingbitcoin.org/t/concept-review-b-ssl-bitcoin-secure-signing-layer-covenant-free-vault-model-using-taproot-csv-and-cltv/2047
[op_cltv]: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
[op_csv]: https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki
[bssl whitepaper]: https://github.com/ilghan/bssl-whitepaper/blob/main/B-SSL_WP_Oct_11_2025.pdf
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[news366 block template sharing]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bin]: https://github.com/bitcoin-inquisition/binana/blob/master/2025/BIN-2025-0002.md
[news368 bts]: /en/newsletters/2025/08/22/#draft-bip-for-block-template-sharing
[Bitcoin Core 30.0]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[notes30]: https://bitcoincore.org/en/releases/30.0/
[Bitcoin Core 29.2]: https://bitcoincore.org/bin/bitcoin-core-29.2/
[notes29.2]: https://bitcoincore.org/en/releases/29.2/
[LDK 0.1.6]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.6