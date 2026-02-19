---
title: 'Bitcoin Optech Newsletter #393'
permalink: /en/newsletters/2026/02/20/
name: 2026-02-20-newsletter
slug: 2026-02-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about recent OP_RETURN usage and
describes a protocol to enforce covenant-like spending conditions without
consensus changes.  Also included are our regular sections describing recent
changes to services and client software, announcing new releases and release
candidates, and summarizing recent merges to popular Bitcoin infrastructure
software.

## News

- **Recent OP_RETURN output statistics**: Anthony Towns posted to
  [Delving][post op_return stats] about the recent OP_RETURN statistics since
  the release of Bitcoin Core v30.0 on October 10, which included changes to
  the mempool policy limits for OP_RETURN outputs (allowing multiple OP_RETURN
  outputs and allowing up to 100kB of data in OP_RETURN outputs). The range of
  blocks he looked at was heights 915800 to 936000, with the following
  results:

  - 24,362,310 txs with OP_RETURN outputs

  - 61 txs with multiple OP_RETURN outputs

  - 396 txs with total OP_RETURN output script sizes greater than 83 bytes

  - Total OP_RETURN output script data over the period was 473,815,552 bytes (of
    which large OP_RETURNS accounted for 0.44%)

  - There are 34,283 txs burning sats to OP_RETURN outputs, for a total of
    1,463,488 sats burnt

  - There are 949,003 txs with between 43 and 83 bytes of OP_RETURN data, and
    23,412,911 txs with OP_RETURN data of 42 bytes or less

  Towns also included a chart showing the frequency of sizes for the 396
  transactions with large OP_RETURN outputs. 50% of these transactions had less
  than 210 bytes of OP_RETURN data. Also, 10% had more than 10KB of OP_RETURN
  data.

  He later added that Murch subsequently published a [similar analysis][murch twitter] on
  X and a [dashboard][murch dashboard] of OP_RETURN
  statistics, and that orangesurf published a [report][orangesurf report] on
  OP_RETURN for mempool research.

- **Bitcoin PIPEs v2**: Misha Komarov [posted][pipes del] to Delving Bitcoin
  about Bitcoin PIPEs, a protocol that allows enforcement of spending conditions
  without the need for consensus changes or optimistic challenge mechanisms.

  The Bitcoin protocol is based on a minimal transaction validation model, which
  consists of verifying that a UTXO being spent is authorized by a valid digital
  signature. Thus, instead of relying on spending conditions expressed by Bitcoin
  Script, Bitcoin PIPEs adds prerequisites on whether a valid signature can be
  produced or not. In other words, a private key is cryptographically locked behind a
  predetermined condition. If and only if the condition is fulfilled, the private key
  is revealed, allowing for a valid signature. While the Bitcoin protocol
  only has to validate a single [schnorr signature][topic schnorr signatures],
  all the conditional logic is processed off-chain.

  On a formal level, Bitcoin PIPEs consists of two main phases:

  - *Setup*: A standard Bitcoin keypair `(sk, pk)` is generated. `sk` is then
    encrypted behind a spending condition statement using witness encryption.

  - *Signing*: A witness `w` is provided for the statement. If `w` is valid, `sk` is
    revealed and a schnorr signature can be produced. Otherwise, recovering `sk`
    becomes computationally infeasible.

  According to Komarov, Bitcoin PIPEs can be used to reproduce [covenant][topic covenants] semantics. In
  particular, [Bitcoin PIPEs v2][pipes v2 paper] focuses on a limited set of spending
  conditions, enforcing binary covenants. This model naturally captures a wide range of
  useful conditions whose outcomes are binary, such as providing a valid zk-proof,
  satisfying an exit condition, or existence of a fraud proof. Basically, it all comes
  down to a single question: "Is the condition satisfied or not?".

  Finally, Komarov provided real-world examples of how PIPEs could be leveraged instead
  of new opcodes, and how it could be used to improve the optimistic verification flow
  of the [BitVM][topic acc] protocol.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Second releases hArk-based Ark software:**
  Second's [Ark][topic ark] libraries were updated to use hArk, hash-lock Ark,
  in version [0.1.0-beta.6][second 0.1.0 beta6]. The new protocol eliminates the
  synchronous interactivity requirement for users during rounds, with its own
  set of tradeoffs. The release includes various other updates,
  including breaking changes.

- **Amboss announces RailsX:**
  The [RailsX announcement][amboss blog] outlines a platform using LN and
  [Taproot Assets][topic client-side validation] to support swaps and various
  other financial services.

- **Nunchuk adds silent payment support:**
  Nunchuk [announced][nunchuk post] support for sending to [silent
  payment][topic silent payments] addresses.

- **Electrum adds submarine swap features:**
  [Electrum 4.7.0][electrum release notes] allows users to pay onchain using
  their Lightning balance (see [submarine swaps][topic submarine swaps]), among
  other features and fixes.

- **Sigbash v2 announced:**
  [Sigbash v2][sigbash post] now uses [MuSig2][topic musig], WebAssembly
  (WASM), and zero-knowledge proofs to achieve better cosigning-service privacy.
  See our [previous coverage][news298 sigbash] on Sigbash for more.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BTCPay Server 2.3.5][] is a minor release of this self-hosted payment
  solution that adds multi-crypto wallet balance widgets on the dashboard,
  a custom textbox for checkout, new exchange rate providers, and includes
  several bug fixes.

- [LND 0.20.1-beta][] is a maintenance release of this popular LN node
  implementation, which adds a panic recovery for gossip message
  processing, improves reorg protection, implements LSP detection
  heuristics, and fixes multiple bugs and race conditions.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33965][] fixes a bug where the `-blockreservedweight`
  startup config (see [Newsletter #342][news342 weight]) could silently
  override the `block_reserved_weight` value set by Mining IPC clients
  (see [Newsletter #310][news310 mining]). Now, when an IPC caller sets
  the latter, it takes precedence. For RPC callers who never set this
  value, the startup config `-blockreservedweight` always takes effect.
  This PR also enforces the `MINIMUM_BLOCK_RESERVED_WEIGHT` for IPC
  callers, preventing them from setting a value below it.

- [Eclair #3248][] starts prioritizing private channels over public ones
  when forwarding [HTLCs][topic htlc], if both options are available.
  This keeps more liquidity available in public channels, which are
  visible to the network. When two channels have the same visibility,
  Eclair now prioritizes the channel with the smaller balance.

- [Eclair #3246][] adds new fields to several internal events:
  `TransactionPublished` splits the single `miningFee` field into
  `localMiningFee` and `remoteMiningFee`, adds a computed `feerate` and
  an optional `LiquidityAds.PurchaseBasicInfo` linking the transaction
  to a [liquidity purchase][topic liquidity advertisements]. Channel
  lifecycle events now include the `commitmentFormat` to describe the
  channel type, and `PaymentRelayed` adds a `relayFee` field.

- [LDK #4335][] adds initial support for phantom node payments (see
  [Newsletter #188][news188 phantom]) using [BOLT12 offers][topic
  offers]. In the [BOLT11][] version, invoices included route hints
  pointing to a non-existent "phantom" node, with each path's last hop
  being a real node that could accept the payment using [stateless
  invoices][topic stateless invoices]. In [BOLT12][], the offer simply
  includes multiple [blinded paths][topic rv routing] terminating at each
  participating node. The current implementation allows multiple nodes to
  respond to the invoice request, though the resulting invoice can only
  be paid to the responding node.

- [LDK #4318][] removes the `max_funding_satoshis` field from the
  `ChannelHandshakeLimits` struct, effectively eliminating the
  pre-[wumbo][topic large channels] default channel size limit. LDK was
  already advertising support for [large channels][topic large channels]
  via the `option_support_large_channels` feature flag by default, which
  could have incorrectly signaled support to peers by conflicting with
  the former setting. Users who want to limit risk can use the manual
  channel acceptance flow.

- [LND #10542][] extends the graph database layer to support gossip v1.75
  (see Newsletters [#261][news261 gossip] and [#326][news326 gossip]).
  LND can now store and retrieve [channel announcements][topic channel
  announcements] for [simple taproot channels][topic simple taproot
  channels]. Gossip v1.75 remains disabled at the network level, pending
  the completion of the validation and gossiper subsystems.

- [BIPs #1670][] publishes [BIP360][], which specifies Pay-to-Merkle-Root
  (P2MR), a new output type that operates like [P2TR][topic taproot] but
  with the keypath spend removed. P2MR outputs are resistant to
  long-exposure attacks by cryptographically relevant quantum computers
  (CRQCs) because they commit directly to the Merkle root of the script tree, a SHA256 hash, rather
  than a public key. However, protection against
  short-exposure attacks, such as against private key recovery while a
  transaction is unconfirmed, requires a separate [post-quantum][topic quantum resistance] signature
  proposal. See [Newsletter #344][news344 p2qrh] for earlier coverage when the
  proposal was known as P2QRH and [Newsletter #385][news385 bip360] when the proposal was
  known as P2TSH.

- [BOLTs #1236][] updates the [dual funding][topic dual funding]
  specification to allow either node to send `tx_init_rbf` during
  channel establishment, effectively allowing both parties to [fee
  bump][topic rbf] the funding transaction. Previously, only the channel
  initiator could do so. This change aligns dual funding with [splicing][topic
  splicing], where either side could already initiate an RBF. The PR
  also adds a requirement that both the senders of `tx_init_rbf` and
  `tx_ack_rbf` must reuse at least one input from a previous attempt,
  ensuring that the new transaction double-spends all prior attempts.

- [BOLTs #1289][] changes how `commitment_signed` is retransmitted
  during reconnection in the interactive transaction protocol used by
  both [dual funding][topic dual funding] and [splicing][topic splicing].
  Previously, `commitment_signed` was always retransmitted on
  reconnection, even if the peer had already received it. Now,
  `channel_reestablish` includes an explicit bitfield that lets a node
  request `commitment_signed` only if it still needs it. This avoids
  unnecessary retransmission, which is especially important for future
  [simple taproot channels][topic simple taproot channels] where
  retransmitting would require a full [MuSig2][topic musig] signing
  round due to nonce changes.

{% include snippets/recap-ad.md when="2026-02-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33965,3248,3246,4335,4318,10542,1670,1236,1289" %}

[post op_return stats]: https://delvingbitcoin.org/t/recent-op-return-output-statistics/2248
[pipes del]: https://delvingbitcoin.org/t/bitcoin-pipes-v2/2249
[pipes v2 paper]: https://eprint.iacr.org/2026/186
[second 0.1.0 beta6]: https://docs.second.tech/changelog/changelog/#010-beta6
[amboss blog]: https://amboss.tech/blog/railsx-first-lightning-native-dex
[nunchuk post]: https://x.com/nunchuk_io/status/2021588854969414119
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[news298 sigbash]: /en/newsletters/2024/04/17/#key-agent-sigbash-launches
[sigbash post]: https://x.com/arbedout/status/2020885323778044259
[BTCPay Server 2.3.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.5
[LND 0.20.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta
[news342 weight]: /en/newsletters/2025/02/21/#bitcoin-core-31384
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[news261 gossip]: /en/newsletters/2023/07/26/#updated-channel-announcements
[news326 gossip]: /en/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal
[news344 p2qrh]: /en/newsletters/2025/03/07/#update-on-bip360-pay-to-quantum-resistant-hash-p2qrh
[news385 bip360]: /en/newsletters/2025/12/19/#quantum
[murch dashboard]: https://dune.com/murchandamus/opreturn-counts
[murch twitter]: https://x.com/murchandamus/status/2022930707820269670
[orangesurf report]: https://research.mempool.space/opreturn-report/
