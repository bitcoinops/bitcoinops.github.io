---
title: 'Bitcoin Optech Newsletter #372'
permalink: /en/newsletters/2025/09/19/
name: 2025-09-19-newsletter
slug: 2025-09-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:harding

## News

FIXME:harding

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Zero-knowledge proof of reserve tool:**
  [Zkpoor][zkpoor github] generates [proof of reserves][topic proof of reserves]
  using STARK proofs without revealing the owner's addresses or UTXOs.

- **Alternative submarine swap protocol proof of concept:**
  The [Papa Swap][papa swap github] protocol proof of concept achieves
  [submarine swap][topic submarine swaps] functionality by requiring one
  transaction instead of two.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 30.0rc1][] is a release candidate for the next major
  version of this full verification node software.

- [BDK Chain 0.23.2][] is a release of this library for building wallet
  applications that introduces improvements to transaction conflict handling,
  redesigns the `FilterIter` API to enhance [BIP158][] filtering capabilities,
  and improves anchor and block reorg management.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33268][] changes how transactions are recognized as part of a
  user’s wallet by removing the requirement that the total amount of a
  transaction's inputs exceeds zero sats. As long as a transaction spends at least
  one output from a wallet, it will be recognized as part of that wallet. This
  allows transactions with zero-value inputs, such as spending a [P2A ephemeral
  anchor][topic ephemeral anchors], to appear in a user’s transaction list.

- [Eclair #3157][] updates the way it signs and broadcasts remote commitment
  transactions upon reconnection. Instead of resending the previously signed
  commitment, it resigns with the latest nonces from `channel_reestablish`.
  Peers that do not use deterministic nonces in [simple taproot channels][topic
  simple taproot channels] will have a new nonce upon reconnection, rendering
  the previous commitment signature invalid.

- [LND #9975][] adds [P2TR][topic taproot] fallback on-chain address support to
  [BOLT11][] invoices, following the test vector added in [BOLTs #1276][].
  BOLT11 invoices have an optional `f` field that allows users to include a
  fallback on-chain address in case a payment cannot be completed over the LN.

- [LND #9677][] adds the `ConfirmationsUntilActive` and `ConfirmationHeight`
  fields to the `PendingChannel` response message returned by the
  `PendingChannels` RPC command. These fields inform users of the number of
  confirmations required for channel activation and the block height
  at which the funding transaction was confirmed.

- [LDK #4045][] implements the reception of an [async payment][topic async
  payments] by an LSP node by accepting an incoming [HTLC][topic htlc] on behalf
  of an often-offline recipient, holding it, and releasing it to the recipient
  later when signaled. This PR introduces an experimental `HtlcHold` feature
  bit, adds a new `hold_htlc` flag on `UpdateAddHtlc`, and defines the release
  path.

- [LDK #4049][] implements the forwarding of [BOLT12][topic offers] invoice
  requests from an LSP node to an online recipient, who then replies with a
  fresh invoice. If the recipient is offline, the LSP node can reply with a
  fallback invoice, as enabled by the server-side logic implementation for
  [async payments][topic async payments] (see Newsletter [#363][news363 async]).

- [BDK #1582][] refactors the `CheckPoint`, `LocalChain`, `ChangeSet`, and
  `spk_client` types to be generic and take a `T` payload instead of being fixed
  to block hashes. This prepares `bdk_electrum` to store full block headers in
  checkpoints, which avoids header redownloads and enables cached merkle proofs
  and Median Time Past (MTP).

- [BDK #2000][] adds block reorg handling to a refactored `FilterIter` struct
  (see Newsletter [#339][news339 filters]). Rather than splitting its flow
  across multiple methods, this PR ties everything to the `next()` function,
  thus avoiding timing risks. A checkpoint is emitted at every block height to
  ensure that the block isn't stale and that BDK is on the valid chain.
  `FilterIter` scans all blocks and fetches those containing transactions
  relevant to a list of script pubkeys, using [compact block filters][topic
  compact block filters] as specified in [BIP158][].

- [BDK #2028][] adds a `last_evicted` timestamp field to the `TxNode` struct to
  indicate when a transaction was excluded from the mempool after being replaced
  through [RBF][topic rbf]. This PR also removes the `TxGraph::get_last_evicted`
  method (See Newsletter [#346][news346 evicted]) because the new field replaces
  it.

{% include snippets/recap-ad.md when="2025-09-23 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33268,3157,9975,1276,9677,4045,4049,1582,2000,2028" %}
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[zkpoor github]: https://github.com/AbdelStark/zkpoor
[papa swap github]: https://github.com/supertestnet/papa-swap
[news363 async]: /en/newsletters/2025/07/18/#ldk-3628
[news339 filters]: /en/newsletters/2025/01/31/#bdk-1614
[news346 evicted]: /en/newsletters/2025/03/21/#bdk-1839
[BDK Chain 0.23.2]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.2
