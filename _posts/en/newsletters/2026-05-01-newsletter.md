---
title: 'Bitcoin Optech Newsletter #403'
permalink: /en/newsletters/2026/05/01/
name: 2026-05-01-newsletter
slug: 2026-05-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes research around using binary fuse filters as an
alternative to the GCS used in compact block filters. Also included are our
regular sections summarizing proposals and discussion about changing Bitcoin's
consensus rules, announcing new releases and release candidates, and describing
notable changes to popular Bitcoin infrastructure software.

## News

- **Binary fuse filters as an alternative to BIP158's GCS**: Csaba Purszki
  [posted][bin fuse del] to Delving Bitcoin his research on finding a better alternative
  to Golomb-Rice Coded Sets (GCS) used for [compact block filters][topic compact block filters]
  as defined in [BIP158][].

  According to Purszki, a suitable alternative can be found in binary fuse
  filters, a family of probabilistic data structures for approximate set
  membership, and specifically the 16-bit variant, called Fuse16. The main
  characteristic of this type of algorithm is the ability to give O(1) query
  time (for reference, GCS gives O(N)), which reduces the CPU power required to
  query the filters. Moreover, these filters guarantee zero false negatives,
  with a rate of false positives equal to `1/2^k`, with `k` being the number of
  bits.

  Purszki provided the preliminary results of his research, which compare the current GCS
  performance against binary fuse filters. Tests were performed on 10 different wallet
  use cases (from 24 scripts up to 480), running filters on 50,000 mainnet blocks,
  on two different CPUs, a desktop x86_64, and an ARM. Binary fuse filters were able to
  obtain a 6x-45x speedup on ARM, according to the different wallet use cases, and 9x-80x
  on desktop at the cost of a slight increase in bandwidth, 0%-3%. For a full write up on
  the methodology and full results, the reader can refer to [Purszki's website][bin fuse web].

  Kyoto developer Robert Netzke commented on the differences in false positive
  rates with respect to GCS and possible failures that could occur in the
  algorithm.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Post-quantum HD wallets with fallback SPHINCS keys:** In a
  [post][c ml pq bip32] on the Bitcoin-Dev mailing list, Conduition described
  a design for [post-quantum][topic quantum resistance] [BIP32][] congruent [hierarchical deterministic
  wallets][topic bip32] with fallback [SPHINCS][news383 sphincs] keys. The design replaces
  the child key derivation functions of BIP32 to generate SPHINCS keys
  alongside [secp256k1][secp256k1] keys. Due to the lack of an algebraic
  relationship within SPHINCS keys, non-hardened child keys share the same
  SPHINCS keys as their parents and siblings. This requires wallets to insert
  a nonce (or the secp256k1 key) into scripts spent using the SPHINCS key to
  retain privacy equivalent to BIP32 wallets. A benefit of this design choice
  is that the expensive full SPHINCS key derivation can be deferred to the
  first non-hardened derivation step and then cached for all non-hardened keys
  below that step. This wallet design is intended to be combined with
  [BIP360][] P2MR outputs and a future `OP_CHECKSPHINCS` (or similar) to
  enable migration to quantum-resistant wallets. Conduition suggests that such
  a wallet structure might also be combined with future lower-cost
  post-quantum signature algorithms with SPHINCS providing a dependable
  fallback in case they are proven insecure.

- **Discussion of a post-quantum output type**: Antoine Poinsot [wrote][ap ml pqout] to
  the Bitcoin-Dev mailing list defending a plain post-quantum output type (as
  opposed to a [P2TR][topic taproot]-like output type which allows
  quantum-vulnerable key spending to be disabled by a later soft fork). The
  crux of the argument is that the decision of whether or when it makes sense
  to disable quantum-vulnerable spends should be separated from enabling users
  to migrate to post-quantum cryptography at their discretion. In the
  subsequent conversation, the participants agreed on both adding
  post-quantum signing to [tapscript][topic tapscript] and adding a plain post-quantum output
  type. Several open questions remain, including whether and to what degree to
  incentivize migration and when / whether to disable quantum-vulnerable
  signatures.

- **Proposal to embed post-quantum keys in tapscript without consensus changes**: Daniel
  Buchner [sent][db ml minpqc] a proposal to the Bitcoin-Dev mailing list
  which describes a potential path to enabling flexible post-quantum wallet
  designs without fully describing the signature validation parameters.
  Because [BIP342][] signature checking opcodes treat all non-32-byte keys as
  unknown key types which are valid with any non-empty signature, other key
  lengths (in this case with an initial tag byte) can be used in scripts today
  as long as either the scripts are kept secret or they also require a secure
  [BIP340][] signature in addition to the unknown key or keys. If Buchner's
  proposal were to be standardized, wallets could start building scripts with
  various post-quantum key types now while continuing to spend using
  quantum-vulnerable keys until such time as a soft fork enables secure
  spending with the post-quantum keys. Like many quantum migration proposals,
  this proposal only retains security in the face of a quantum adversary if
  key reuse is strictly prevented. Buchner is seeking feedback on the
  proposal.

- **BIP54 demonstration of slow blocks on signet**: On Delving Bitcoin,
  Antoine Poinsot [wrote][ap delving slowblocks] about a demonstration of the
  types of slow-to-validate blocks that [BIP54][]
  ([consensus cleanup][topic consensus cleanup]) prevents. Repeated three times over the course of a
  day, batches of slow-to-validate blocks were signed on the most popular
  Bitcoin [signet][topic signet] and then reorged away to enable testing of
  propagation and validation behavior of these blocks without forever slowing
  signet initial block download. Many around the world watched the slow blocks
  hit their nodes and logged the validation and propagation behavior. As
  expected, the slow-to-validate blocks propagated much more slowly through
  the network and required significantly more time to be fully validated on
  individual nodes compared to typical blocks. It should be noted that these
  demonstration blocks were far from the worst case that is prevented by
  BIP54.

- **Post-quantum BIP86 recovery using zk-STARK proofs of BIP32 seeds**:
  Olaoluwa Osuntokun (roasbeef) [posted][oo ml pqrecovery] on the Bitcoin-Dev
  mailing list his project to demonstrate zk-STARK recovery of
  quantum-vulnerable coins secured by keys derived using [BIP32][]. This
  possible mechanism for coin recovery in the event that
  [secp256k1][secp256k1] is disabled in the face of a cryptographically
  relevant quantum computer has long been discussed, but never fully
  demonstrated. Osuntokun produced a fully working implementation of the
  required prover and verifier and provided benchmarks showing that recovery
  using this method is, at least, possible. The original implementation was
  intentionally not optimized and several developers offered optimizations
  that make the recovery less costly both to prove and to verify.

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

{% include snippets/recap-ad.md when="2026-05-05 16:30" %}
{% include references.md %}
[c ml pq bip32]: https://groups.google.com/g/bitcoindev/c/5tLKm8RsrZ0
[news383 sphincs]: /en/newsletters/2025/12/05/#slh-dsa-sphincs-post-quantum-signature-optimizations
[secp256k1]: https://en.bitcoin.it/wiki/Secp256k1
[ap ml pqout]: https://groups.google.com/g/bitcoindev/c/JA3kDl8AmQg
[db ml minpqc]: https://groups.google.com/g/bitcoindev/c/jn7COyeHtW0
[ap delving slowblocks]: https://delvingbitcoin.org/t/consensus-cleanup-demo-of-slow-blocks-on-signet/2367
[oo ml pqrecovery]: https://groups.google.com/g/bitcoindev/c/Q06piCEJhkI
[bin fuse del]: https://delvingbitcoin.org/t/binary-fuse-filters-as-an-alternative-to-bip-158-gcs/2428
[bin fuse web]: https://purszki.github.io/bitcoin_research_01/
