---
title: 'Bitcoin Optech Newsletter #372'
permalink: /en/newsletters/2025/09/19/
name: 2025-09-19-newsletter
slug: 2025-09-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal to enhance LN redundant
overpayments and links to a discussion about potential partitioning
attacks against full nodes.  Also included are our regular sections
describing recent changes to services and client software, announcing
new releases and release candidates, and summarizing notable changes to
popular Bitcoin infrastructure software.

## News

- **LSP-funded redundant overpayments:** developer ZmnSCPxj
  [posted][zmnscpxj lspstuck] to Delving Bitcoin a proposal to allow
  LSPs to provide the additional funding (liquidity) required for
  [redundant overpayments][topic redundant overpayments].  In the
  original proposals for redundant overpayments, Alice pays Zed by
  sending multiple payments through multiple routes in a way that only
  allows Zed to claim one of the payments; the rest of the payments are
  refunded to Alice.  The upside of this approach is that the first
  payment attempts to reach Zed can succeed while other attempts are
  still traveling through the network, increasing the speed of payments
  on LN.

  Downsides of this approach are that Alice must have extra capital
  (liquidity) to make the redundant payments, Alice must remain online
  until the redundant overpayment completes, and any payment that becomes
  stuck prevents Alice from being able to spend that money until the
  payment attempt times out (up to two weeks with commonly used
  settings).

  ZmnSCPxj's proposal allows Alice to pay only the actual payment amount
  (plus fees) and her Lightning service providers (LSPs) supply the
  liquidity for sending the redundant payments, providing the speed
  advantage of redundant overpayments without requiring her to have
  extra liquidity either briefly or until timeout.  The LSPs are also
  able to finalize the payment while Alice is offline, so the payment
  can be completed even if Alice has poor connectivity.

  Downsides of the new proposal are that Alice loses some privacy to her
  LSPs and that the proposal requires several changes to the LN protocol
  in addition to support for redundant overpayments. {% assign timestamp="16:24" %}

- **Partitioning and eclipse attacks using BGP interception:** developer
  cedarctic [posted][cedarctic bgp] to Delving Bitcoin about using flaws
  in the Border Gateway Protocol (BGP) to prevent full nodes from being
  able to connect to peers, which can be used to partition the network
  or execute [eclipse attacks][topic eclipse attacks].  Several
  mitigations were described by cedarctic, with other developers in the
  discussion describing other mitigations and ways to monitor for use of
  the attack. {% assign timestamp="1:02" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Zero-knowledge proof of reserve tool:**
  [Zkpoor][zkpoor github] generates [proof of reserves][topic proof of reserves]
  using STARK proofs without revealing the owner's addresses or UTXOs. {% assign timestamp="13:49" %}

- **Alternative submarine swap protocol proof of concept:**
  The [Papa Swap][papa swap github] protocol proof of concept achieves
  [submarine swap][topic submarine swaps] functionality by requiring one
  transaction instead of two. {% assign timestamp="15:12" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 30.0rc1][] is a release candidate for the next major
  version of this full verification node software. {% assign timestamp="39:14" %}

- [BDK Chain 0.23.2][] is a release of this library for building wallet
  applications that introduces improvements to transaction conflict handling,
  redesigns the `FilterIter` API to enhance [BIP158][] filtering capabilities,
  and improves anchor and block reorg management. {% assign timestamp="1:16:28" %}

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
  anchor][topic ephemeral anchors], to appear in a user’s transaction list. {% assign timestamp="1:17:19" %}

- [Eclair #3157][] updates the way it signs and broadcasts remote commitment
  transactions upon reconnection. Instead of resending the previously signed
  commitment, it resigns with the latest nonces from `channel_reestablish`.
  Peers that do not use deterministic nonces in [simple taproot channels][topic
  simple taproot channels] will have a new nonce upon reconnection, rendering
  the previous commitment signature invalid. {% assign timestamp="1:18:56" %}

- [LND #9975][] adds [P2TR][topic taproot] fallback on-chain address support to
  [BOLT11][] invoices, following the test vector added in [BOLTs #1276][].
  BOLT11 invoices have an optional `f` field that allows users to include a
  fallback on-chain address in case a payment cannot be completed over the LN. {% assign timestamp="1:19:52" %}

- [LND #9677][] adds the `ConfirmationsUntilActive` and `ConfirmationHeight`
  fields to the `PendingChannel` response message returned by the
  `PendingChannels` RPC command. These fields inform users of the number of
  confirmations required for channel activation and the block height
  at which the funding transaction was confirmed. {% assign timestamp="1:20:21" %}

- [LDK #4045][] implements the reception of an [async payment][topic async
  payments] by an LSP node by accepting an incoming [HTLC][topic htlc] on behalf
  of an often-offline recipient, holding it, and releasing it to the recipient
  later when signaled. This PR introduces an experimental `HtlcHold` feature
  bit, adds a new `hold_htlc` flag on `UpdateAddHtlc`, and defines the release
  path. {% assign timestamp="1:20:41" %}

- [LDK #4049][] implements the forwarding of [BOLT12][topic offers] invoice
  requests from an LSP node to an online recipient, who then replies with a
  fresh invoice. If the recipient is offline, the LSP node can reply with a
  fallback invoice, as enabled by the server-side logic implementation for
  [async payments][topic async payments] (see Newsletter [#363][news363 async]). {% assign timestamp="1:21:32" %}

- [BDK #1582][] refactors the `CheckPoint`, `LocalChain`, `ChangeSet`, and
  `spk_client` types to be generic and take a `T` payload instead of being fixed
  to block hashes. This prepares `bdk_electrum` to store full block headers in
  checkpoints, which avoids header redownloads and enables cached merkle proofs
  and Median Time Past (MTP). {% assign timestamp="1:22:18" %}

- [BDK #2000][] adds block reorg handling to a refactored `FilterIter` struct
  (see Newsletter [#339][news339 filters]). Rather than splitting its flow
  across multiple methods, this PR ties everything to the `next()` function,
  thus avoiding timing risks. A checkpoint is emitted at every block height to
  ensure that the block isn't stale and that BDK is on the valid chain.
  `FilterIter` scans all blocks and fetches those containing transactions
  relevant to a list of script pubkeys, using [compact block filters][topic
  compact block filters] as specified in [BIP158][]. {% assign timestamp="1:23:13" %}

- [BDK #2028][] adds a `last_evicted` timestamp field to the `TxNode` struct to
  indicate when a transaction was excluded from the mempool after being replaced
  through [RBF][topic rbf]. This PR also removes the `TxGraph::get_last_evicted`
  method (See Newsletter [#346][news346 evicted]) because the new field replaces
  it. {% assign timestamp="1:24:17" %}

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
[zmnscpxj lspstuck]: https://delvingbitcoin.org/t/multichannel-and-multiptlc-towards-a-global-high-availability-cp-database-for-bitcoin-payments/1983/
[cedarctic bgp]: https://delvingbitcoin.org/t/eclipsing-bitcoin-nodes-with-bgp-interception-attacks/1965/
