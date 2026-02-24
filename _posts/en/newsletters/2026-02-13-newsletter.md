---
title: 'Bitcoin Optech Newsletter #392'
permalink: /en/newsletters/2026/02/13/
name: 2026-02-13-newsletter
slug: 2026-02-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion of improving worst-case silent
payment scanning performance and describes an idea for enabling many spending
conditions in a single key.  Also included are our regular sections announcements
of new releases and release candidates and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Proposal to limit the number of per-group silent payment recipients**: Sebastian
  Falbesoner [posted][kmax mailing list] to the Bitcoin-Dev mailing list the discovery and
  mitigation of a theoretical attack on [silent
  payment][topic silent payments] recipients. The attack occurs when an adversary
  constructs a transaction with a large number of taproot outputs (23255 max outputs per
  block according to current consensus rules) that all target the same entity.
  If there were no limit on group size, it would take several minutes
  to process, rather than tens of seconds.

  This motivated a mitigation to add a new parameter, `K_max`, that limits the
  number of per-group recipients within a single transaction. In theory, this
  change would not be backward-compatible, but in practice, none of the
  existing silent payment wallets should be affected
  for a sufficiently high `K_max`. Falbesoner is proposing `K_max=1000`.

  Falbesoner is seeking feedback or concerns about the proposed restriction. He
  also notes that most silent payment wallet developers have been notified and
  are aware of the issue. {% assign timestamp="1:13" %}

- **BLISK, Boolean circuit Logic Integrated into the Single Key**: Oleksandr
  Kurbatov [posted][blisk del] to Delving Bitcoin about BLISK, a protocol
  designed to express complex authorization policies using boolean logic.
  BLISK tries to address the limitations of current spending policies. For example,
  protocols like [MuSig2][topic musig], though efficient and privacy-preserving,
  can only express cardinality (k-of-n) but cannot identify "who" can spend.

  BLISK creates a simple AND/OR boolean circuit, mapping logical gates to
  well-known cryptographic techniques. In particular, AND gates are obtained by
  applying an n-of-n multisignature setup, in which each participant must contribute a
  valid signature. On the other end, OR gates are obtained by leveraging key agreement
  protocols, such as [ECDH][ecdh wiki], in which any participant can derive a shared
  secret using their private key and the other participant's public key. It also applies
  a [Non-interactive Zero Knowledge proof][nizk wiki] to make circuit resolution
  verifiable and to prevent cheating.
  BLISK resolves the circuit to a single signature verification key. This means
  that only a single [Schnorr][topic schnorr signatures] signature must be verified
  against one public key.

  Another important advantage of BLISK with respect to other approaches is
  eliminating the need to generate a fresh key pair. In fact, it allows connecting an
  existing key to the specific signature instance.

  Kurbatov provided a [proof-of-concept][blisk gh] for the protocol, although he stated
  that the framework has not reached production maturity yet. {% assign timestamp="26:43" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.3][] is a maintenance release for the previous major
  release series that includes several wallet migration fixes (see
  Newsletter [#387][news387 wallet]), a per-input sighash midstate cache
  that reduces the impact of quadratic sighashing in legacy scripts (see
  Newsletter [#367][news367 sighash]), and removal of peer discouragement
  for consensus-invalid transactions (see Newsletter [#367][news367
  discourage]). See the [release notes][bcc29.3 rn] for all details. {% assign timestamp="49:18" %}

- [LDK 0.2.2][] is a maintenance release of this library for building
  LN-enabled applications. It updates the `SplicePrototype` feature flag
  to the production feature bit (63), fixes an issue where async
  `ChannelMonitorUpdate` persistence operations could hang after restarts
  and lead to force-closures, and fixes a debug assertion failure that
  occurred when receiving invalid splicing messages from a peer. {% assign timestamp="51:16" %}

- [HWI 3.2.0][] is a release of this package providing a common interface
  to multiple hardware signing devices. The new release adds
  support for the Jade Plus and BitBox02 Nova devices, [testnet4][topic
  testnet], native [PSBT][topic psbt] signing for Jade, and [MuSig2][topic
  musig] PSBT fields as specified in [BIP373][]. {% assign timestamp="52:20" %}

- [Bitcoin Inquisition 29.2][] is a release of this [signet][topic signet]
  full node designed for experimenting with proposed soft forks and other
  major protocol changes. Based on Bitcoin Core 29.3r2, this release
  implements the [BIP54][] ([consensus cleanup][topic consensus cleanup])
  proposal and disables [testnet4][topic testnet]. {% assign timestamp="53:54" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32420][] updates the Mining IPC interface (see
  [Newsletter #310][news310 mining]) to stop including a dummy
  `extraNonce` in the coinbase `scriptSig`. A new
  `include_dummy_extranonce` option is added to `CreateNewBlock()`, and
  the IPC codepath sets it to `false`. [Stratum v2][topic pooled mining]
  clients receive only the consensus-required [BIP34][] height in the
  `scriptSig` and no longer need to strip or ignore the extra data. {% assign timestamp="56:05" %}

- [Core Lightning #8772][] removes support for the legacy onion payment
  format. While CLN had stopped creating legacy onions in 2022 (see
  [Newsletter #193][news193 legacy]), it added a translation layer in
  v24.05 to handle the few remaining legacy onions produced by older LND
  versions. These have not been created since LND v0.18.3, so support is
  no longer needed. The legacy format was removed from the BOLTs
  specification in 2022 (see [Newsletter #220][news220 bolts]). {% assign timestamp="1:02:29" %}

- [LND #10507][] adds a new `wallet_synced` boolean field to the
  `GetInfo` RPC response, which indicates whether the wallet has finished
  catching up to the current chain tip. Unlike the existing
  `synced_to_chain` boolean field, this new field does not require the
  channel graph router (which validates [channel announcements][topic
  channel announcements]) or the blockbeat dispatcher (a subsystem that
  coordinates block-driven events) to be synced before returning true. {% assign timestamp="1:03:56" %}

- [LDK #4387][] switches the [splicing][topic splicing] feature flag from
  the provisional bit 155 to the production bit 63. LDK v0.2 used bit
  155, which Eclair also uses for a custom, Phoenix-specific splice
  implementation that predates and is incompatible with the current draft
  specification. This caused Eclair nodes to attempt splices using their
  protocol when connecting to LDK nodes, resulting in deserialization
  failures and reconnections. {% assign timestamp="1:05:48" %}

- [LDK #4355][] adds support for async signing of commitment signatures
  exchanged during [splicing][topic splicing] and [dual-funded][topic dual
  funding] channel negotiations. When receiving
  `EcdsaChannelSigner::sign_counterparty_commitment`, the async signer
  immediately returns and calls back via
  `ChannelManager::signer_unblocked` once the signature is ready.
  Dual-funded channels still require additional work to fully support
  async signing. {% assign timestamp="1:08:14" %}

- [LDK #4354][] makes channels with [anchor outputs][topic anchor outputs]
  the default by setting the config option of
  `negotiate_anchors_zero_fee_htlc_tx` to true by default. Automatic
  channel acceptance has been removed, so all inbound channel requests
  must be manually accepted. This ensures that the wallet has enough
  on-chain funds to cover fees in the event of a force close. {% assign timestamp="1:09:21" %}

- [LDK #4303][] fixes two bugs where [HTLCs][topic htlc] could be
  double-forwarded after a `ChannelManager` restart: one where the
  outbound HTLC was still in a holding cell (internal queue) but it was
  missed, and another where it had already been forwarded, settled, and
  removed from the outbound channel, but the inbound side's holding cell
  still had a resolution for it. This PR also prunes inbound HTLC onions
  once they are irrevocably forwarded. {% assign timestamp="1:10:52" %}

- [HWI #784][] adds [PSBT][topic psbt] serialization and deserialization
  support for [MuSig2][topic musig] fields, including participant public
  keys, public nonces, and partial signatures for both inputs and
  outputs, as specified in [BIP327][]. {% assign timestamp="1:13:10" %}

- [BIPs #2092][] assigns a one-byte [v2 P2P transport][topic v2 p2p
  transport] message type ID to the `feature` message from [BIP434][],
  and adds an auxiliary file to [BIP324][] tracking one-byte ID
  assignments across BIPs to help developers avoid conflicts. The file
  also records [Utreexo][topic utreexo]'s proposed assignments from
  BIP183. {% assign timestamp="1:15:02" %}

- [BIPs #2004][] adds [BIP89][] for Chain Code Delegation (see
  [Newsletter #364][news364 delegation]), a collaborative custody
  technique where a delegatee withholds [BIP32][] chain codes from a
  delegator, sharing only enough information with the delegator to
  produce signatures without learning which addresses received funds. {% assign timestamp="1:16:33" %}

- [BIPs #2017][] adds [BIP110][], which specifies the Reduced Data
  Temporary Softfork (RDTS), a proposal to temporarily restrict
  data-carrying transaction fields at the consensus level for
  approximately one year. The rules would invalidate scriptPubKeys
  exceeding 34 bytes (except OP_RETURN up to 83 bytes), pushdata and
  witness stack elements exceeding 256 bytes, spending of undefined
  witness versions, [taproot][topic taproot] annexes, control blocks
  exceeding 257 bytes, `OP_SUCCESS` opcodes, and `OP_IF`/`OP_NOTIF` in
  [tapscripts][topic tapscript]. Inputs spending UTXOs created before
  activation are exempt. Activation uses a modified [BIP9][] deployment
  with a reduced 55% miner signaling threshold and mandatory lock-in by
  approximately September 2026. See [Newsletter #379][news379 rdts] for
  earlier coverage of this proposal. {% assign timestamp="1:19:44" %}

- [Bitcoin Inquisition #99][] adds an implementation of the [BIP54][]
  [consensus cleanup][topic consensus cleanup] soft fork rules on
  [signet][topic signet]. The four implemented mitigations are: limits on
  the number of potentially executed legacy sigops per transaction,
  prevention of timewarp attacks with a two-hour grace period (plus
  prevention of negative difficulty adjustment intervals), mandatory
  timelocking of coinbase transactions to the block height, and
  invalidation of 64-byte transactions. {% assign timestamp="1:26:53" %}

{% include snippets/recap-ad.md when="2026-02-17 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32420,8772,10507,4387,4355,4354,4303,784,2092,2004,2017,99" %}
[kmax mailing list]: https://groups.google.com/g/bitcoindev/c/tgcAQVqvzVg
[blisk del]: https://delvingbitcoin.org/t/blisk-boolean-circuit-logic-integrated-into-the-single-key/2217
[ecdh wiki]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[nizk wiki]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[blisk gh]: https://github.com/zero-art-rs/blisk
[Bitcoin Core 29.3]: https://bitcoincore.org/bin/bitcoin-core-29.3/
[bcc29.3 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.3.md
[Bitcoin Inquisition 29.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.2-inq
[HWI 3.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.2.0
[LDK 0.2.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.2
[news387 wallet]: /en/newsletters/2026/01/09/#bitcoin-core-wallet-migration-bug
[news367 sighash]: /en/newsletters/2025/08/15/#bitcoin-core-32473
[news367 discourage]: /en/newsletters/2025/08/15/#bitcoin-core-33050
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news193 legacy]: /en/newsletters/2022/03/30/#c-lightning-5058
[news220 bolts]: /en/newsletters/2022/10/05/#bolts-962
[news364 delegation]: /en/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[news379 rdts]: /en/newsletters/2025/11/07/#temporary-soft-fork-to-reduce-data
[BIP89]: https://github.com/bitcoin/bips/blob/master/bip-0089.mediawiki
