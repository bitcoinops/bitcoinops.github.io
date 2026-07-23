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

- [Core Lightning v26.06.6][] is a maintenance release of this LN node
  implementation. It updates the bundled `pyln-proto` library's `coincurve`
  dependency to fix Python build environments and adds a check that rejects
  any channel reusing the funding outpoint of an existing channel.

- [Bitcoin Inquisition 29.4][] is a release of this [signet][topic signet]
  full node designed for experimenting with proposed soft forks and other
  major protocol changes. Based on Bitcoin Core 29.4, it adds activation of
  [BIP446][] (`OP_TEMPLATEHASH`), a proposed [tapscript][topic tapscript]
  opcode that pushes a hash of the spending transaction onto the stack (see
  [Newsletter #365][news365 templatehash]), to its existing set of
  experimentally-activated soft-fork proposals.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35215][] speeds up lookups in the in-memory UTXO cache
  (`CCoinsMap`) by replacing `SipHash-2-4`, the function used to hash its
  `COutPoint` keys, with a faster, purpose-built [SipHash][] variant,
  `SipHasher13UJ`. Each coin is looked up by a key that combines its txid and
  output number, and every lookup runs that key through a hash function.
  `SipHash-2-4` digests a coin's 32-byte txid in four separate 64-bit pieces,
  so hashing one outpoint runs 14 internal rounds. `SipHasher13UJ` instead
  takes in the whole txid in one 256-bit step and does fewer rounds, cutting
  that to five. The author reports roughly double the hashing throughput in
  isolated benchmarks and about a 5% reduction in one chainstate-reindex run.

- [Bitcoin Core #35766][] enables [BIP324][] [v2 p2p transport][topic v2 p2p
  transport] by default when first connecting to addresses from DNS seeds and
  the compiled-in fixed seeds. Experimental support for BIP324 shipped in
  Bitcoin Core 26.0 and was enabled by default in 27.0. Since these seed
  mechanisms provide addresses without service flags, Bitcoin Core previously
  treated the peers as v1 only and a node's earliest automatic connections
  never attempted encrypted transport. The new `SeedsAssumedServiceFlags()`
  function now assumes `NODE_P2P_V2` for those addresses. If this assumption
  is incorrect for a given peer, the node simply reconnects using v1.
  Connections made through the `-seednode` option and address fetching
  already attempt v2 by default.

- [BIPs #2075][] clarifies [BIP174][]'s description of how [PSBTs][topic psbt]
  are combined. The specification had asserted that combining independently
  updated PSBTs is unconditionally order-independent, but this only holds when
  the participants add distinct fields. When two PSBTs contain the same key
  with different values, a combiner may pick either value or refuse to combine,
  so the specification now notes that in this case the result is not
  commutative.

- [BIPs #2204][] updates the draft [BIP440][] and [BIP441][] Great Script
  Restoration specifications (see [Newsletter #400][news400 gsr]). It
  introduces `wordspan` notation, which rounds up the byte length of a stack
  element to the next eight-byte boundary, and reworks numerous operation cost
  formulas so that operations that process data in 64-bit words are charged by
  `wordspan` while those that work on the exact bytes stay costed by `length`.
  The update also corrects the definition of `OP_RIGHT` and clarifies costs
  and range checks for several other opcodes.

- [Core Lightning #8935][] fixes a bug that could cause a node to repeatedly
  [RBF][topic rbf] a transaction, even after a replacement had already
  confirmed. CLN stores pending transactions in an `outgoing_tx_map` keyed by
  the original txid, but it replaces the transaction object with each
  higher-fee version without changing the key. The per-block
  `rebroadcast_txs()` loop checked for confirmation using the stale original
  txid, which was never mined, so it kept invoking the rebroadcast and
  replacement logic even though the latest transaction had confirmed. Since
  the txid serves as the hash-table key and cannot be updated in place, the
  loop now computes the current transaction's txid with each iteration and
  uses it for confirmation checks.

- [Core Lightning #9324][] fixes a `Renepay` regression (see [Newsletter
  #263][news263 renepay]) present since v26.04 that built [HTLCs][topic htlc]
  with CLTV expiries roughly one block height too far in the future. Renepay's
  route data already incorporated the current block height into each hop's
  CLTV value, but `route_sendpay_request()` added the block height a second
  time when passing the route to `sendpay`, roughly doubling the expiry.
  Forwarding nodes could then reject the onion with `expiry_too_far`.

- [libsecp256k1 #1765][] adds an optional `silentpayments` module that
  implements the elliptic-curve operations defined by [BIP352][] [silent
  payments][topic silent payments]. For
  senders, one function combines the sender's input private keys, the
  transaction's lowest outpoint, and the recipient's published scan and spend
  public keys to derive the output keys that the transaction should pay. For
  receivers, full-node scanning detects which of a transaction's outputs
  belong to the recipient and returns the tweaks needed to spend them, working
  from only the recipient's scan secret key and spend public key so the spend
  private key can stay offline. Separate functions manage labels, an optional
  [BIP352][] feature that lets recipients derive distinguishable variants of
  their address to tell incoming payments apart and flag their own change.
  Light client scanning support was deferred to a later PR.

- [Rust Bitcoin #6317][] updates its [compact block relay][topic compact block
  relay] decoding to reject `sendcmpct` messages whose boolean announcement
  field is not exactly `0` or `1`, as required by [BIP152][]. Previously, Rust
  Bitcoin decoded the field with a non-zero test, accepting any non-zero value
  as true (high-bandwidth mode). This PR mirrors the hardening equivalent in
  Bitcoin Core (see [Newsletter #412][news412 sendcmpct]).

- [BTCPay Server #7457][] adds the ability to import [wallet labels][topic
  wallet labels] in [BIP329][] JSON Lines format, complementing the existing
  export functionality. Previously labels were effectively lost when moving to
  another server, and label files produced by BIP329-aware wallets such as
  Sparrow or Envoy could not be loaded at all. The importer reads the format's
  `tx`, `addr`, and `output` records and maps them to BTCPay's transaction,
  address, and UTXO objects, skipping any records it can't apply.

- [BLIPs #71][] adds a `dnssec_error` response to [BLIP32][], the protocol
  that resolves [BIP353][] human-readable payment names by carrying DNSSEC
  queries and proofs over Lightning onion messages (see [Newsletter
  #306][news306 blip32]). Previously the protocol only defined `dnssec_query`
  and `dnssec_proof`, so resolvers that could not respond had no standardized
  way to indicate this to the requester, who would continue to wait. The new
  final-hop TLV (type `65550`) echoes the queried `domain_name` and includes a
  `definitely_unresolvable` boolean that a resolver should set for terminal
  failures, such as NXDOMAIN or an unsigned name, and not set for other,
  possibly transient failures.

{% include snippets/recap-ad.md when="2026-07-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2210,35215,35766,8935,9324,1765,6317,7457,2075,2204,71" %}

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
[news263 renepay]: /en/newsletters/2023/08/09/#core-lightning-6376
[news412 sendcmpct]: /en/newsletters/2026/07/03/#bitcoin-core-35550
[news400 gsr]: /en/newsletters/2026/04/10/#bips-2118
[news306 blip32]: /en/newsletters/2024/06/07/#blips-32
[news365 templatehash]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[SipHash]: https://en.wikipedia.org/wiki/SipHash
[Core Lightning v26.06.6]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.6
[Bitcoin Inquisition 29.4]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.4-inq
