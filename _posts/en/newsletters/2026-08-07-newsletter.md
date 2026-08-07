---
title: 'Bitcoin Optech Newsletter #417'
permalink: /en/newsletters/2026/08/07/
name: 2026-08-07-newsletter
slug: 2026-08-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a draft BIP for relaying stale block tips
between peers. Also included are our regular sections summarizing proposals and
discussion about changing Bitcoin's consensus rules, announcing new releases and
release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Draft BIP for stale tip relay**: Ram and w0xlt [posted][stale tip ml]
  to the Bitcoin-Dev mailing list about the proposal for an opt-in P2P
  message for relaying stale tips between peers. Currently, the stale block rate
  is a difficult metric to monitor, since stale blocks stop propagating
  as soon as the winning chain is relayed. However, it is a useful signal
  to check the network health. Changes in the stale block rate may expose validation
  or relay bottlenecks, network partitions, or [selfish mining][topic selfish
  mining] behavior.

  The proposed [BIP][stale tip bip] defines a new message, called
  `staletip`, for announcing recent stale chain tips to peers. The message
  itself contains the block height at which a stale branch diverges (the
  fork point), a vector containing the block headers belonging to the stale
  branch, and a flag signaling willingness to serve that block data. A node
  should only send the message after [BIP434][] negotiation with its peers
  (see [Newsletter #386][news386 bip434]).

  The authors are waiting for feedback from other developers.
  In the meantime, a [proof of concept][stale tip poc] for the proposal
  is already available.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **CISA for taproot keypath spends (BIP460)**: Fabian Jahr
  [posted][fj ml cisa] to the Bitcoin-Dev mailing list a draft of BIP460
  ([BIPs #2212][]) for transaction-wide [cross-input signature aggregation
  (CISA)][topic cisa] of [taproot][topic taproot]-style keypath spends. The
  proposal introduces a new witness version (v2) whose keypath spends mirror
  [BIP341][] except that each input's witness begins with a marker byte
  selecting half-aggregation (BIP458/[BIPs #2205][]), full-aggregation
  (BIP459/[BIPs #2210][]), or an explicit opt-out that carries a standard
  [BIP340][] [schnorr][topic schnorr signatures] signature. Half-aggregation
  non-interactively compresses many 64-byte signatures to 32 bytes each plus a
  single 32-byte aggregate part (see [Newsletter #208][news208 halfagg]);
  full-aggregation reduces them to a single 64-byte aggregate signature with
  interactive signing (see [Newsletter #415][news415 dahlias]). Scriptpath
  spends follow BIP341/BIP342 unchanged and are not aggregated, preserving
  the `OP_SUCCESS` upgrade path. Signatures
  in the proposed scheme commit to the aggregation mode so aggregation is
  opt-in: third parties cannot fold an opted-out signature into a
  half-aggregation group. Jahr notes the witness version collides with
  [BIP360][] (P2MR); reviewers (including Mark Erhardt) expect whichever
  proposal activates first to take the next free version.

  Conduition [asked][c ml cisa] how CISA dovetails with [post-quantum][topic
  quantum resistance] migration: aggregation needs bare EC public keys for
  verification, so pairing CISA with [P2TRv2][news403 pqout] maximizes fee
  savings (as little as 1 witness byte per full-aggregated input) but inherits
  P2TRv2's EC-disabling timing problem, whereas hashing the key (P2MR or
  P2TRH) costs roughly 32-65 weight units per input and weakens the savings.
  Jahr [replied][fj ml cisa conduition] that the transaction-level marker/group
  framework should generalize to future aggregatable schemes and that a
  hash-hidden CISA variant could be specified as a separate output type
  sharing most of the logic. Adam Gibson (waxwing) [questioned][ag ml cisa]
  the single-group-per-scheme limit when several users each want
  full-aggregation of only their own inputs inside a shared transaction. Jahr
  [replied][fj ml cisa waxwing] that multiple groups remain open if reviewers
  see concrete use cases.

- **Segwit commitment to post-quantum witness data**: Pieter Wuille
  [posted][pw delving pqwit] to Delving Bitcoin a design for attaching
  [post-quantum][topic quantum resistance] witness data without repeating all
  of [segwit][topic segwit]'s deployment costs. A naive second witness area
  would need a new transaction identifier (pqwtxid), a coinbase commitment to
  those IDs, mining stack changes, and P2P logic tracking three identifiers.
  Wuille's alternative commits to each input's extended witness data from
  the input's current witness, so wtxid covers the additional data. A
  worked-out version introduces per-input witness "styles" (0 = segwit, 1 =
  pqdata, 2+ for future extensions), each with its own P2P extension and
  weight function. Unsupported styles can be represented by a valid style-0
  commitment for compatibility with unupgraded nodes. Anthony Towns compared
  styles to distinct authorization weight formulas, suggested annex-based
  commitments so locktime-like assertions remain available without the
  additional data, and argued that capacity reserved for post-quantum
  signatures should stay unusable for ordinary data so pre-Q-day blocks do not
  bloat toward a larger target. Wuille agreed that introducing a style is
  still a combined soft fork, storage, and P2P upgrade, but without a
  new transaction ID.

- **PQC output type discussion**: Pieter Wuille [opened][pw delving pqout] a
  Delving Bitcoin thread to centralize discussion of [post-quantum][topic
  quantum resistance] output types. He tabulated candidates including
  [BIP360][] (P2MR), [P2TRv2][news403 pqout], P2TRH (taproot-like with a hashed
  output key and public-key recovery, see [Newsletter #412][news412 pkr]), and
  P2QR (P2MR with EC opcodes disabled from the start), and variations of
  those. His current preference is to deploy both P2TRv2 (with [tripwire/miner
  lockdown][news412 p2xx] and a [hash-based PQC opcode][news386 jn hash]) for
  easy pre-Q-day migration that keeps today's fee profile, and a longer-term
  P2MR-based type with a new witness style so EC and PQC costs can be priced
  independently after migration. Regtest measurements by jeanpablojp
  [showed][jp delving pqout] BIP360 spends requiring ~96 lines of consensus
  delta over existing taproot machinery, with a depth-1 schnorr leaf about
  32 bytes lighter than the equivalent P2TR scriptpath. Conduition noted that Jahr's CISA
  proposal (above) makes P2TRv2+CISA extremely attractive for voluntary
  migration, but raises the stakes of a later EC-disabling soft fork, and
  pointed to block-wide PQ-SNARK aggregation of hash-based signatures as a
  research path that could make post-quantum spends competitive on fees.

- **Input-triggered transaction expiry**: Josh Doman [posted][jd delving
  expire htlc] to Delving Bitcoin a construction for expiring [HTLCs][topic
  htlc] without [free relay][topic free relay], then generalized it in a
  follow-up on [input-triggered transaction expiry][jd delving input expiry].
  Absolute expiry proposals such as Peter Todd's [`OP_EXPIRE`][news274 expire]
  make a valid transaction later invalid, enabling cheap relay spam unless
  policy demands near-next-block fees. Doman's approach instead expires a
  spend when the transaction creating the UTXO it's spending was
  confirmed too late: if [BIP68][] `nSequence` enforces a height-based relative
  locktime R and bit 21 is set, the input fails validation unless `nLockTime`
  is height-based and at least the BIP68 minimum inclusion height. Because a
  mined parent cannot become invalid without a deep reorg, a once-valid child
  cannot expire under ordinary progress, eliminating free relay. Use cases
  include mempool-free HTLC forwarding (preimage monitoring via the chainstate
  rather than the local mempool, useful for low-bandwidth or
  [Utreexo-style][topic utreexo] nodes) and pseudo contract-level relative
  [timelocks][topic timelocks] for [LN-Symmetry][topic eltoo]. Optional companion changes enforce
  bit 21 in `OP_CSV` and add a tapscript `OP_LOCKTIME` introspection opcode so
  scripts can require a maximum locktime. Anthony Towns compared the idea to
  coin-height introspection via `OP_TX` and questioned whether the 100-block
  minimum delay (chosen to match coinbase maturity and Todd's proposal) is
  necessary; Doman later agreed that a much smaller delay may suffice and reframed
  the primitive as users asserting "now" (input confirmations by `nLockTime`)
  in a way that can also raise the cost of deep reorgs post-subsidy.

- **Layered quantum recovery of hashed addresses**: Shinobi [posted][shinobi
  ml qr] to the Bitcoin-Dev mailing list and [cross-posted][shinobi delving
  qr] to Delving Bitcoin a layered recovery plan for coins secured by hashed
  address types (P2PKH, P2SH, P2WPKH, P2WSH, and analogous constructions) if
  secp256k1 spending is later restricted due to the existence of a
  [cryptographically relevant quantum computer][topic quantum resistance]. No
  single recovery mechanism covers every key-generation method: [BIP32][]
  hierarchical proofs (recently [demonstrated][news403 pqrecovery] by
  Osuntokun) miss non-hierarchical keys; stateful pre-deadline timestamped
  attestations miss inactive users; and commit-reveal migration fails when
  public keys are already exposed. Allowing any recovery method to authorize a
  spend after secp256k1 is disabled would, under the assumption that public
  keys and internal scriptpaths stay secret, cover essentially all
  hashed-address holders who still control their keys. To facilitate this in
  the future, Shinobi suggests wallets use new derivation paths and
  Electrum-style per-address balance queries to avoid leaking xpubs to service
  providers. Conduition reframed recovery as authenticating existing knowledge
  asymmetries that a quantum attacker lacks: hashed scripts and BIP32
  seeds are such asymmetries. He stressed that some UTXOs (notably many
  early P2PK coins) have no such asymmetry, so only pre-deadline action to
  create one can distinguish their owners from an attacker. He also noted
  that taproot internal keys can serve as a knowledge asymmetry for P2TR
  keypath recovery, separate from the hashed-address layering.

- **Segregated Data (SegData) BIP draft**: MrHash [posted][mh delving segdata]
  to Delving Bitcoin companion BIP drafts for Segregated Data, a soft fork
  that would add a prunable, script-isolated block region for arbitrary data
  carriage. Entries would be committed via a coinbase merkle root ([BIP141][]-
  style), counted at the witness discount, and bound to transactions by
  unspendable value-zero witness v2 reference outputs excluded from the UTXO
  set. No opcode may read entry contents, keeping entries prunable and unable
  to gate spends, and beyond a retention window nodes could validate from the
  base serialization alone. The goal is to give data that scripts need not
  evaluate (application blobs, attestations) a structural home so it can leave
  `OP_RETURN` and witness stuffing, without changing those existing vectors.
  Antoine Poinsot and Pieter Wuille argued that if full nodes need not retain
  the payload to accept a block, the data is not part of Bitcoin consensus in
  any meaningful sense and is equivalent to paying fees to inflate weight.
  Mark Erhardt questioned why embedders would prefer reduced availability at
  the same cost as witness data. After Anthony Towns described reorg risks
  from depth-dependent presence rules, MrHash pivoted toward consensus
  checking only committed weight/length with payload validation as policy. The
  draft remains open; witness version allocation also collides with BIP360 and
  BIP460 discussions above.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Libsecp256k1 0.8.0][] is a release of this library for Bitcoin-related
  cryptographic operations. It adds the [BIP352][] [silent payments][topic
  silent payments] module described in [Newsletter #415][news415 silent],
  allows applications to provide hardware-optimized SHA256 compression
  implementations as described in [Newsletter #396][news396 sha256], and
  improves 64-bit field arithmetic, producing signature verification speedups
  of up to approximately 11% in some GCC and MSVC builds. It also removes the
  deprecated `secp256k1_schnorrsig_sign` and
  `secp256k1_context_no_precomp` symbols.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35501][] updates the wallet to store multiple witness variants
  of the same transaction. Previously, once the wallet knew a transaction with
  a given txid, it would generally ignore another transaction with the same
  txid but a different wtxid. Now, the wallet stores each variant in a separate
  `wtxvariant` database record and selects one as canonical. Preference is
  given to a confirmed variant, otherwise to a variant containing witness data
  and then to a variant with the lowest weight. The canonical variant remains
  in the existing `tx` record. The `gettransaction`, `listtransactions`, and
  `listsinceblock` RPCs now report noncanonical variants in a new
  `alternate_wtxids` field. See Newsletters [#193][news193 wtxid] and
  [#304][news304 wtxid] for previous references to transactions having the
  same txid but different wtxids.

- [Core Lightning #9298][] advances the migration to `bwatch`, an experimental
  blockchain-watching plugin intended to move block polling and transaction
  filtering out of `lightningd`. This PR moves wallet transaction and UTXO
  tracking to that system by adding `our_outputs` and `our_txs` tables,
  backfilling them from the existing wallet tables, and switching wallet reads
  to the new tables. With `--experimental-bwatch` enabled, the scriptPubKey
  watches detect when funds are received and the outpoint watches detect when
  wallet outputs are spent, including handling reorgs. Writes are temporarily
  mirrored to the legacy `outputs` and `transactions` tables to enable users to
  downgrade without needing to rescan.

- [Core Lightning #9353][] makes `sendpay` return an RPC error when the combined
  per-hop payload for a supplied route cannot fit in the 1,300-byte
  `hop_payloads` field of an onion packet defined by [BOLT4][]. Previously,
  onion construction returned a null result that `sendpay` passed unchecked to
  the sending code, causing `lightningd` to crash. This issue was observed with
  a 25-hop route generated by a rebalancing plugin. However, the actual route
  limit depends on the size of the encoded payloads for each hop rather than
  solely on the number of hops.

- [Eclair #3336][] prevents duplicate [HTLC][topic htlc] settlement messages
  received from a peer from being added multiple times to the proposed remote
  commitment changes. Previously, a peer or local message queue could deliver
  the same `update_fulfill_htlc`, `update_fail_htlc`, or
  `update_fail_malformed_htlc` message more than once, causing Eclair to store
  duplicate commitment changes and potentially force close the channel when
  the peers later exchanged `commit_sig` messages.

- [LND #10942][] adds support for forwarding an [HTLC][topic htlc] on a
  [blinded payment path][topic rv routing] when the encrypted recipient data
  identifies the next hop using `next_node_id` rather than `short_channel_id`
  (SCID). This issue was observed in a Core Lightning [BOLT12][topic offers]
  payment, where LND was the introduction node in the receiver's blinded path.
  CLN used the [BOLT4][]-permitted `next_node_id` form, but LND's HTLC
  forwarding code required an SCID, resulting in the payment failing. LND now
  resolves the node id to one of its usable channels with that peer using its
  existing non-strict forwarding logic, which also supports private and alias
  channels.

- [LND #10992][] bounds the memory used when synchronizing [channel
  announcements][topic channel announcements] by limiting the number of short
  channel IDs (SCIDs) accepted in the [BOLT7][] `reply_channel_range` response
  to a `query_channel_range` request. Previously, compressed responses could
  cause LND to decode and buffer an unpredictable number of SCIDs across one
  or more `reply_channel_range` messages. Now, LND accepts a maximum of 100,000
  SCIDs per message and 100,000 SCIDs in aggregate for a single query.

- [Rust Bitcoin #6364][] adds P2P encoding and decoding support for [BIP434][]
  `feature` messages (see Newsletters [#386][news386 bip434] and
  [#390][news390 bip434]), following Bitcoin Core's earlier implementation
  (see [Newsletter #410][news410 bip434]). It adds protocol version `70017`,
  the `feature` `NetworkMessage` variant, while enforcing BIP434's size limits
  on feature identifiers and data. This update provides the message
  infrastructure, but does not implement the peer feature negotiation logic.

- [Rust Bitcoin #6642][] applies a 4 MB size limit to each transaction witness
  element. This limit is derived from [BIP141][]'s four-million-weight-unit
  block limit, as a witness element larger than this size would not fit in a
  valid block. Previously, when decoding a transaction, Rust Bitcoin only
  applied the limit to the first witness element, resetting to a larger default
  limit of 32 MiB for subsequent elements. This could allow an oversized element
  to be accepted during decoding, leaving the witness in an inconsistent state
  that could cause a panic when later interpreted as a [taproot][topic taproot]
  spend. This follows earlier witness-decoding memory-allocation hardening
  described in [Newsletter #410][news410 witness].

- [BTCPay Server #7491][] fixes a two-factor authentication (2FA) bypass in the
  Greenfield API authentication handler. While the authentication handler
  checked for FIDO2 2FA (see [Newsletter #146][news146 btcpay mfa]), it did not
  check for time-based one-time password (TOTP) 2FA. This allowed TOTP-protected
  accounts to access the API without providing their 2FA. The handler now
  rejects this form of authentication whenever any second factor is enabled.

- [BTCPay Server #7488][] improves [PSBT][topic psbt] signing compatibility by
  adding `witness_utxo` to [segwit][topic segwit] inputs when the PSBT already
  contains the corresponding previous transaction in `non_witness_utxo`. This
  resolves an issue with signing devices such as the Blockstream Jade when used
  with newer [HWI][topic hwi] versions, while retaining the existing
  `non_witness_utxo`. The PR also fixes an issue with pending multisig
  transactions whose stored signing status became stale. BTCPay Server now
  recalculates their signing progress when they are loaded and marks them as
  `Signed` when enough signatures are present and the PSBT can be finalized
  successfully.

{% include snippets/recap-ad.md when="2026-08-11 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2212,2205,2210,35501,9298,9353,3336,10942,10992,6364,6642,7491,7488" %}

[stale tip ml]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU
[stale tip bip]: https://github.com/pseudoramdom/bips/blob/staletip-bip-draft/bip-staletip.md
[stale tip poc]: https://github.com/w0xlt/bitcoin/tree/staletip-v4

[fj ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA
[c ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/V6PZL7bGAwAJ
[fj ml cisa conduition]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/kF-RpqEgBAAJ
[ag ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/-zRSmrFZGQAJ
[fj ml cisa waxwing]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/oOQ7TIEVAgAJ
[news208 halfagg]: /en/newsletters/2022/07/13/#half-aggregation-of-bip340-signatures
[news415 dahlias]: /en/newsletters/2026/07/24/#draft-bip-for-full-aggregation-of-bip340-signatures
[news403 pqout]: /en/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[pw delving pqwit]: https://delvingbitcoin.org/t/segwit-commitment-to-post-quantum-witness-data/2702
[pw delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749
[jp delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/3
[news412 pkr]: /en/newsletters/2026/07/03/#public-key-recovery-for-p2mr-ec-leaves
[news412 p2xx]: /en/newsletters/2026/07/03/#triggering-ec-disabling-with-a-nums-point-spend-or-hashrate-majority
[news386 jn hash]: /en/newsletters/2026/01/02/#hash-based-signatures-for-bitcoin-s-post-quantum-future
[jd delving expire htlc]: https://delvingbitcoin.org/t/expiring-htlcs-without-free-relay/2663
[jd delving input expiry]: https://delvingbitcoin.org/t/input-triggered-transaction-expiry/2667
[news274 expire]: /en/newsletters/2023/10/25/#op-expire
[shinobi ml qr]: https://groups.google.com/g/bitcoindev/c/gtxpSxgG7E4
[shinobi delving qr]: https://delvingbitcoin.org/t/post-quantum-recovery-of-hashed-addresses-with-no-confiscatory-risk/2714
[news403 pqrecovery]: /en/newsletters/2026/05/01/#post-quantum-bip86-recovery-using-zk-stark-proofs-of-bip32-seeds
[mh delving segdata]: https://delvingbitcoin.org/t/bip-draft-segregated-data-a-prunable-script-isolated-block-region-for-data-carriage/2641
[news193 wtxid]: /en/newsletters/2022/03/30/#transaction-witness-replacement
[news304 wtxid]: /en/newsletters/2024/05/24/#bitcoin-core-30000
[news386 bip434]: /en/newsletters/2026/01/02/#peer-feature-negotiation
[news390 bip434]: /en/newsletters/2026/01/30/#bips-2076
[news410 bip434]: /en/newsletters/2026/06/19/#bitcoin-core-35221
[news410 witness]: /en/newsletters/2026/06/19/#rust-bitcoin-6321
[news146 btcpay mfa]: /en/newsletters/2021/04/28/#btcpay-server-2356
[Libsecp256k1 0.8.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.8.0
[news415 silent]: /en/newsletters/2026/07/24/#libsecp256k1-1765
[news396 sha256]: /en/newsletters/2026/03/13/#libsecp256k1-1777