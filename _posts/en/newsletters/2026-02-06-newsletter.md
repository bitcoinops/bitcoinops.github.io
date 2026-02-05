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

{% include snippets/recap-ad.md when="2026-02-10 17:30" %}
{% include references.md %}
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
