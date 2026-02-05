---
title: 'Bitcoin Optech Newsletter #391'
permalink: /en/newsletters/2026/02/06/
name: 2026-02-06-newsletter
slug: 2026-02-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to work on a constant-time parallelized UTXO
database, summarizes a new high-level language for writing Bitcoin Script, and
describes an idea to mitigate dust attacks. Also included are our regular
sections summarizing discussion about changing Bitcoin's consensus rules,
announcing new releases and release candidates, and describing notable changes
to popular Bitcoin infrastructure software.

## News

- **A constant-time parallelized UTXO database**: Toby Sharp
  [posted][hornet del] to Delving Bitcoin about his latest project, a custom, highly
  parallel UTXO database, with constant-time queries, called Hornet UTXO(1).
  This is a new additional component of [Hornet Node][hornet website], an
  experimental Bitcoin client focused on providing a minimal executable
  specification of Bitcoin's consensus rules.
  This new database aims to improve Initial Block Download (IBD) through a lock-free,
  highly concurrent architecture.

  The code is written in modern C++23, without external dependencies. To optimize for
  speed, sorted arrays and [LSM trees][lsmt wiki] were preferred over
  [hash maps][hash map wiki].
  Operations, such as append, query, and fetch, are executed concurrently, and
  blocks are processed out of order as they arrive, with data dependencies resolved
  automatically. The code is not yet publicly available.

  Sharp provided a benchmark to assess the capabilities of his software.
  For re-validating the whole mainnet chain, Bitcoin Core v30 took 167 minutes
  (with no script or signature validation), while Hornet UTXO(1) took 15 minutes
  to complete validation. Tests were performed on a 32-core computer,
  with 128GB RAM and 1TB storage.

  In the discussion that followed, other developers suggested Sharp to compare
  performance against [libbitcoin][libbitcoin gh], which is known for providing a
  very efficient IBD.

- **Bithoven: A formally verified, imperative language for Bitcoin Script:**
  Hyunhum Cho [wrote][delving hc bithoven] on Delving Bitcoin about his
  [work][arxiv hc bithoven] on Bithoven which is an alternative to
  [miniscript][topic miniscript]. In contrast to miniscript's predicate
  language for expressing the possible satisfactions for a locking script,
  Bithoven uses a more familiar C-family syntax with `if`, `else`, `verify`,
  and `return` as its primary operations. The compiler handles all stack
  management and makes similar guarantees to the miniscript compiler regarding
  all paths requiring at least one signature and similar. Similar to
  miniscript, it can target various Script versions.

- **Discussion of dust attack mitigations**: Bubb1es [posted][dust attacks del]
  to Delving Bitcoin about a way to dispose of [dust
  attacks][topic output linking] in onchain wallets. A dust attack happens when
  an adversary sends dust UTXO's to all the anonymous addresses they want to
  know about. Hoping that some will be spent unintentionally with an unrelated
  UTXO.

  The way _most_ wallets choose to handle this today is by preventing spending of the dust
  UTXOs by marking them as dust UTXOs in the wallets client. This can become an
  issue in the future if the user restores from keys and the new wallet client
  doesn't know these UTXOs are marked and "unlocks" the dust UTXOs to be spent.
  Bubb1es suggests another way to prevent this dust UTXO attack by
  creating a transaction with the dust UTXO that uses the entire amount and has
  an `OP_RETURN` output making it provably unspendable. This is possible because
  Bitcoin Core v30.0 has a lower minimum relay fee rate (0.1 sats/vbyte).

  He then lists out a few risks with implementing a wallet that handles dust
  UTXOs like this.

  1. Fingerprinting issues if only a few wallets implement this.

  2. If multiple dust UTXOs are broadcast at the same time, then there can be
     correlation.

  3. Rebroadcasting might need to be done if fee rates go up.

  4. It can be confusing to sign for dust UTXOs in multi-sig and hardware
     signing setups.

  AJ Towns mentioned that the minimum relay size is 65 bytes and explains that
  using ANYONECANPAY|ALL with a 3-byte OP_RETURN would make it more efficient.

  Bubb1es then provides an experimental tool [ddust][ddust tool] to demonstrate
  how this would be done.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **SHRINCS: 324-byte stateful post-quantum signatures with static backups:**
  Following-up on the [Hash-based Signature Schemes for Bitcoin][news386 jn
  hash], Jonas Nick [detailed][delving jn shrings] on Delving Bitcoin a
  specific hash-based [quantum-resistant][topic quantum resistance] signature algorithm with potentially useful properties for use in
  Bitcoin.

  In the paper, there was discussion of the trade-offs between
  stateful and stateless hash-based signatures, where stateful signatures can
  have significantly reduced cost at the expense of complex backup schemes.
  SHRINCS offers a compromise where a stateful signature is used when the
  fidelity of the key+state can be known with certainty, but falls back to
  stateless signing at higher cost if there is doubt that the state is valid.

  The two schemes chosen for SHRINCS are SPHINCS+ for stateless signing and
  Unbalanced XMSS for stateful signing. The public key posted in the output
  script is a hash of the stateful and stateless keys. Because these
  hash-based signature schemes return the signing public key as part of
  verification, the signer provides the unused public key along with their
  signature and the verifier checks that the returned public key hashes with
  the provided public key to the key specified in the locking script. The
  Unbalanced XMSS scheme is chosen to optimize for cases where relatively few
  signatures are needed from a key.

- **Addressing remaining points on BIP54:** Antoine Poinsot [wrote][ml ap
  gcc] about the remaining points of discussion for the [consensus
  cleanup soft fork][topic consensus cleanup].

  First up for discussion is the proposal to enforce that the coinbase
  transaction's `nLockTime` be set to one less than the block height. Here the
  discussion centers around whether this change unnecessarily restricts mining
  chips' ability to use this field as an extra nonce as future miners run out
  of nonce space in the existing version, timestamp, and nonce fields. Several
  posters mentioned that the `nLockTime` field already has consensus enforced
  semantics and is therefore not a prime candidate for additional nonce
  rolling. Various proposals for alternate nonce space were made, including
  additional version bits and a separate `OP_RETURN` output.

  The other change discussed is the proposal to make 64-non-witness-byte
  transactions invalid in consensus. Such transactions are also restricted
  by default relay policy, but a consensus change would protect SPV (or other
  similar) light clients from certain attacks. Several posters questioned
  whether this change is even worthwhile, given that other mitigations exist,
  and it introduces a potentially surprising validity gap for certain types of
  transactions (e.g. [CPFPs][topic cpfp] for certain protocols).

- **Falcon post-quantum signature scheme proposal:** Giulio Golinelli
  [posted][ml gg falcon] on the mailing list proposing a fork to enable Falcon
  signature verification to Bitcoin. The Falcon algorithm is based on lattice
  cryptography and is seeking FIPS standardization as a post-quantum signature
  algorithm. It requires about 20x more space on chain than ECDSA signatures while being
  about twice as fast to verify. This makes it one of the smallest
  post-quantum signature schemes so far proposed for Bitcoin.

  Conduition posted some limitations of the Falcon algorithm, especially
  around the difficulty of implementing signing in constant time. Others
  discussed the question of whether a post-quantum signature algorithm for
  Bitcoin should be designed with future STARK/SNARK-friendliness in mind.

  Note: While the mailing list post describes it as a soft fork, it appears to
  be implemented as a flag-day disjunction in the P2WPKH verification path
  which would be a hard fork. Further work would be necessary to develop a
  soft fork client for this algorithm.

- **SLH-DSA verification can compete with ECC:** Conduition [wrote][ml cond
  slh-dsa] about his ongoing work benchmarking his post-quantum SLH-DSA
  verification implementation against libsecp256k1. His results show that
  SLH-DSA verification can compete with [schnorr][topic schnorr signatures] verification in common cases.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LDK 0.1.9][] and [0.2.1][ldk 0.2.1] are maintenance releases of this
  popular library for building LN-enabled applications. Both fix a bug
  where `ElectrumSyncClient` would fail to sync when unconfirmed
  transactions were present. Version 0.2.1 additionally fixes an issue
  where `splice_channel` didn't fail immediately when the peer doesn't
  support [splicing][topic splicing], makes the `AttributionData` struct
  public, and includes several other bug fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33604][] corrects the behavior of [assumeUTXO][topic
  assumeutxo] nodes. During background validation, the node avoids
  downloading blocks from peers that don't have the snapshot block in
  their best chain because the node lacks the necessary undo data to
  handle a potential reorg. However, this restriction persisted
  unnecessarily even after background validation had finished, despite
  the fact that the node could handle reorgs. Nodes now only apply this
  restriction while background validation is ongoing.

- [Bitcoin Core #34358][] fixes a wallet bug that occurred when removing
  transactions via the `removeprunedfunds` RPC. Previously, removing a
  transaction marked all of its inputs as spendable again, even if the
  wallet contained a conflicting transaction that also spent the same
  UTXOs.

- [Core Lightning #8824][] adds an `auto.include_fees` layer to the
  pathfinding `askrene` plugin (see [Newsletter #316][news316 askrene])
  that deducts routing fees from the payment amount, effectively making
  the receiver pay for the fees.

- [Eclair #3244][] adds two events: `PaymentNotRelayed`, emitted when a
  payment couldn't be relayed to the next node likely due to
  insufficient liquidity, and `OutgoingHtlcNotAdded`, emitted when an
  [HTLC][topic htlc] couldn't be added to a specific channel. These
  events help node operators build heuristics for liquidity allocation,
  though the PR notes that a single event shouldn't trigger allocation.

- [LDK #4263][] adds a `custom_tlvs` optional parameter to the
  `pay_for_bolt11_invoice` API, enabling callers to embed arbitrary
  metadata in the payment onion. Although the low-level endpoint
  `send_payment` already allowed for custom Type-Length-Values
  ([TLVs][]) in [BOLT11][] payments, it wasn't properly surfaced on
  higher-level endpoints.

- [LDK #4300][] adds support for generic [HTLC][topic htlc]
  interception, building on the HTLC holding mechanism added for [async
  payments][topic async payments] and expanding the prior capability,
  which only intercepted HTLCs destined for fake SCIDs (see [Newsletter
  #230][news230 intercept]). The new implementation uses a configurable
  bitfield to intercept HTLCs destined for: intercept SCIDs (as before),
  offline private channels (useful for LSPs to wake sleeping clients),
  online private channels, public channels, and unknown SCIDs. This lays
  the groundwork for supporting LSPS5 (see [Newsletter #365][news365
  lsps5] for the client-side implementation) and other LSP use cases.

- [LND #10473][] makes the `SendOnion` RPC (see [Newsletter
  #386][news386 sendonion]) fully idempotent, enabling clients to safely
  retry requests after network failures without risking duplicate
  payments. If a request with the same `attempt_id` has already been
  processed, the RPC will return a `DUPLICATE_HTLC` error.

- [Rust Bitcoin #5493][] adds the ability to use hardware-optimized
  SHA256 operations on compatible ARM architectures. Benchmarks show
  that hashing is approximately five times faster for large blocks. This
  complements the existing SHA256 acceleration on x86 architectures (see
  [Newsletter #265][news265 x86sha]).

{% include snippets/recap-ad.md when="2026-02-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33604,34358,8824,3244,4263,4300,10473,5493" %}

[news386 jn hash]: /en/newsletters/2026/01/02/#hash-based-signatures-for-bitcoin-s-post-quantum-future
[delving jn shrings]: https://delvingbitcoin.org/t/shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups/2158
[ml ap gcc]: https://groups.google.com/g/bitcoindev/c/6TTlDwP2OQg
[delving hc bithoven]: https://delvingbitcoin.org/t/bithoven-a-formally-verified-imperative-smart-contract-language-for-bitcoin/2189
[arxiv hc bithoven]: https://arxiv.org/abs/2601.01436
[ml gg falcon]: https://groups.google.com/g/bitcoindev/c/PsClmK4Em1E
[ml cond slh-dsa]: https://groups.google.com/g/bitcoindev/c/8UFkEvfyLwE
[hornet del]: https://delvingbitcoin.org/t/hornet-utxo-1-a-custom-constant-time-highly-parallel-utxo-database/2201
[hornet website]: https://hornetnode.org/overview.html
[lsmt wiki]: https://en.wikipedia.org/wiki/Log-structured_merge-tree
[hash map wiki]: https://en.wikipedia.org/wiki/Hash_table
[libbitcoin gh]: https://github.com/libbitcoin
[dust attacks del]: https://delvingbitcoin.org/t/disposing-of-dust-attack-utxos/2215
[ddust tool]: https://github.com/bubb1es71/ddust
[LDK 0.1.9]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.9
[ldk 0.2.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.1
[news316 askrene]: /en/newsletters/2024/08/16/#core-lightning-7517
[TLVs]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[news230 intercept]: /en/newsletters/2022/12/14/#ldk-1835
[news365 lsps5]: /en/newsletters/2025/08/01/#ldk-3662
[news386 sendonion]: /en/newsletters/2026/01/02/#lnd-9489
[news265 x86sha]: /en/newsletters/2023/08/23/#rust-bitcoin-1962
