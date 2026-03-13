---
title: 'Bitcoin Optech Newsletter #396'
permalink: /en/newsletters/2026/03/13/
name: 2026-03-13-newsletter
slug: 2026-03-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a collision-resistant hash function using
Bitcoin Script and summarizes continued discussion of Lightning Network traffic
analysis. Also included are our regular sections with announcements of new releases
and release candidates and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Collision-resistant hash function for Bitcoin Script**: Robin Linus
  [posted][bino del] to Delving Bitcoin about Binohash, a new collision-resistant hash
  function using Bitcoin Script. In the [paper][bino paper] he shared, Linus states that
  Binohash allows for limited transaction introspection without requiring new consensus
  changes. In turn, this enables protocols like [BitVM][topic acc] bridges with
  [covenant][topic covenants]-like functionalities for trustless introspection, without the need to
  rely on trusted oracles.

  The proposed hash function indirectly derives a transaction digest following a
  two-step process:

  - Pin transaction fields: Transaction fields are bound by requiring a spender
    to solve multiple signature puzzles, each demanding `W1` bits of work, making
    unauthorized modification computationally expensive.

  - Derive the hash: The hash is computed by leveraging the behavior of
    `FindAndDelete` in legacy `OP_CHECKMULTISIG`. A nonce pool is initialized
    with `n` signatures. A spender produces a subset with `t` signatures, which are
    removed from the pool using `FindAndDelete`, and then computes a sighash of the
    remaining signatures. The process is iterated until a sighash produces a puzzle
    signature matching requirements. The resulting digest, the Binohash, will be composed of the `t` indices of the winning subset.

  The output digest has three properties relevant to Bitcoin applications: it
  can be extracted and verified entirely within Bitcoin Script; it provides
  approximately 84 bits of collision resistance; and it is [Lamport-signable][lamport wiki],
  allowing it to be committed to inside a BitVM program. Together these
  properties mean developers can construct protocols that reason about
  transaction data on-chain today, using only existing script primitives.

- **Continued discussion of Gossip Observer traffic analysis tool**: In November, Jonathan
  Harvey-Buschel [announced][news 381 gossip observer] Gossip Observer, a tool
  for collecting LN gossip traffic and computing metrics to evaluate replacing
  message flooding with a set-reconciliation-based protocol.

  Since then, Rusty Russell and others [joined the discussion][gossip observer
  delving] on how best to transmit sketches. Russell suggested encoding
  improvements for efficiency, including skipping the `GETDATA` round-trip by
  using the block number suffix as the set key for a message, avoiding an
  unnecessary request/response exchange when the receiver can already infer the
  relevant block context.

  In response, Harvey-Buschel [updated][gossip observer github] his version of
  Gossip Observer that is running and continuing to collect data. He
  [posted][gossip observer update] analysis of average daily messages, a model of
  detected communities, and propagation delays.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BDK wallet 3.0.0-rc.1][] is a release candidate for a new major
  version of this library for building wallet applications. Major
  changes include UTXO locking that persists across restarts, structured
  wallet events returned on chain updates, and adoption of `NetworkKind`
  throughout the API to distinguish mainnet from testnet. The release
  also adds Caravan (see [Newsletter #77][news77 caravan]) wallet format
  import/export and a migration utility for SQLite databases from before
  version 1.0.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #26988][] updates the `-addrinfo` CLI command (see
  [Newsletter #146][news146 addrinfo]) to now return the full set of
  known addresses, instead of a subset filtered for quality and recency.
  Internally, the `getaddrmaninfo` RPC (see [Newsletter #275][news275
  addrmaninfo]) is used instead of the `getnodeaddresses` RPC (see
  [Newsletter #14][news14 rpc]). The returned count now matches the
  unfiltered set used to select outbound peers.

- [Bitcoin Core #34692][] increases the default `dbcache` from 450 MiB
  to 1 GiB on 64-bit systems with at least 4 GiB of RAM, falling back
  to 450 MiB otherwise. This change only affects `bitcoind`; the kernel
  library retains 450 MiB as its default.

- [LDK #4304][] refactors [HTLC][topic htlc] forwarding to support
  multiple incoming and outgoing HTLCs per forward, laying the
  groundwork for [trampoline][topic trampoline payments] routing. Unlike
  regular forwarding, a trampoline node can act as an [MPP][topic
  multipath payments] endpoint on both sides: it accumulates incoming
  HTLC parts, finds routes to the next hop, and splits the forward
  across multiple outgoing HTLCs. A new `HTLCSource::TrampolineForward`
  variant tracks all HTLCs for a trampoline forward. Claims and failures
  are handled properly, and channel monitor recovery is extended to
  reconstruct the trampoline forward state upon restart.

- [LDK #4416][] enables an acceptor to contribute funds when both peers
  attempt to initiate a [splice][topic splicing] simultaneously,
  effectively adding support for [dual funding][topic dual funding] on
  splices. When both sides initiate, [quiescence][topic channel
  commitment upgrades] tie-breaking selects one as the initiator.
  Previously, only the initiator could add funds, and the acceptor had
  to wait for a subsequent splice to add their own. Since the acceptor
  had prepared to be the initiator, their fee is adjusted from the
  initiator rate (which covers common transaction fields) to the
  acceptor rate. The `splice_channel` API now also accepts a
  `max_feerate` parameter to target a maximum feerate.

- [LND #10089][] adds [onion message][topic onion messages] forwarding
  support, building on the message types and RPCs from [Newsletter
  #377][news377 onion]. It introduces an `OnionMessagePayload` wire type
  to decode the onion's inner payload, and a per-peer actor that handles
  decryption and forwarding decisions. The feature can be disabled using
  the `--protocol.no-onion-messages` flag. This is part of LND's
  roadmap toward [BOLT12 offers][topic offers] support.

- [Libsecp256k1 #1777][] adds a new
  `secp256k1_context_set_sha256_compression()` API, which allows
  applications to supply a custom SHA256 compression function at
  runtime. This API allows environments such as Bitcoin Core, which
  already detect CPU features at startup, to route libsecp256k1's
  hashing through hardware-accelerated SHA256 without recompiling the
  library.

- [BIPs #2047][] publishes [BIP392][], which defines a
  [descriptor][topic descriptors] format for [silent payment][topic
  silent payments] wallets. The new `sp()` descriptor instructs wallet
  software on how to scan for and spend silent payment outputs, which
  are [P2TR][topic taproot] outputs as specified in [BIP352][]. A one
  key expression argument form takes a single [bech32m][topic bech32]
  key: `spscan` which encodes the scan private key and the spend public
  key for watch-only, or `spspend` which encodes both scan and spend
  private keys. A two-argument form `sp(KEY,KEY)` takes a private scan
  key as first expression and a separate spend key expression, either
  public or private with support for [MuSig2][topic musig] aggregate
  keys via [BIP390][]. See [Newsletter #387][news387 sp] for the
  initial mailing list discussion.

- [BOLTs #1316][] clarifies that `offer_amount` in [BOLT12 offers][topic
  offers] must be greater than zero when present. Writers must set the
  `offer_amount` to a value greater than zero, and readers must not
  respond to offers where the amount is zero. Test vectors for invalid
  zero-amount offers are added.

- [BOLTs #1312][] adds a test vector for [BOLT12][topic offers] offers
  with invalid [bech32][topic bech32] padding, clarifying that such
  offers must be rejected according to [BIP173][] rules. This issue was
  discovered through differential fuzzing across Lightning
  implementations, which revealed that CLN and LDK accepted offers with
  invalid padding while Eclair and Lightning-KMP correctly rejected
  them. See [Newsletter #390][news390 bech32] for LDK's fix.

{% include snippets/recap-ad.md when="2026-03-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26988,34692,4304,4416,10089,1777,2047,1316,1312" %}

[bino del]: https://delvingbitcoin.org/t/binohash-transaction-introspection-without-softforks/2288
[bino paper]: https://robinlinus.com/binohash.pdf
[lamport wiki]: https://en.wikipedia.org/wiki/Lamport_signature
[news146 addrinfo]: /en/newsletters/2021/04/28/#bitcoin-core-21595
[news275 addrmaninfo]: /en/newsletters/2023/11/01/#bitcoin-core-28565
[news14 rpc]: /en/newsletters/2018/09/25/#bitcoin-core-13152
[news377 onion]: /en/newsletters/2025/10/24/#lnd-9868
[news387 sp]: /en/newsletters/2026/01/09/#draft-bip-for-silent-payment-descriptors
[news390 bech32]: /en/newsletters/2026/01/30/#ldk-4349
[news77 caravan]: /en/newsletters/2019/12/18/#unchained-capital-open-sources-caravan-a-multisig-coordinator
[BDK wallet 3.0.0-rc.1]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/v3.0.0-rc.1
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
[gossip observer update]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105/23
[gossip observer github]: https://github.com/jharveyb/gossip_observer
[news 381 gossip observer]: /en/newsletters/2025/11/21/#ln-gossip-traffic-analysis-tool-announced
