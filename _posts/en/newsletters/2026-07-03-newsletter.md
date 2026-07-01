---
title: 'Bitcoin Optech Newsletter #412'
permalink: /en/newsletters/2026/07/03/
name: 2026-07-03-newsletter
slug: 2026-07-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

FIXME:bitschmidty

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

FIXME:bitschmidty

- **Benchmarking SLH-DSA STARK aggregation**: Remix7531 [posted][rs ml starkbench]
  to the Bitcoin-Dev mailing list his benchmark results for aggregating many
  [SPHINCS][news383 sphincs] signature verifications into a single
  [STARK][news403 stark] proof. This follows Ethan Heilman's earlier
  [proposal][eh ml starkagg] to use STARKs to scale [post-quantum][topic
  quantum resistance] blocks. In this benchmark suite (built in RISK Zero's
  zkVM), proving time scales roughly linearly with the number of signatures
  (~3.1 seconds per signature on an RTX 5090), proof size grows sublinearly
  (218 KiB for one signature up to 454 KiB for 512 signatures, versus 3.8 MiB
  of raw signatures), and verification stays near 12-15 milliseconds
  regardless of batch size. Proving an entire block on one GPU would still
  take hours, but Remix suggests that dedicated AIR circuits, mempool
  preprocessing, and multi-GPU proving could improve this. The benchmarks also
  use standard SPHINCS rather than the more compact Bitcoin-optimized
  [SPHINCS+][news386 jn hash] variant.

- **Bird of Prey 2 (BoP-2): non-malleable Schnorr + PQ signatures**: Pieter
  Wuille [posted][pw delving bop2] to Delving Bitcoin about a EuroCrypt 2026
  paper on constructing hybrid strongly-unforgeable signature schemes from a
  [Schnorr][topic schnorr signatures]-like scheme and an arbitrary
  [post-quantum][topic quantum resistance] signature scheme. While simply
  concatenating signatures from both schemes is unforgeable if at least one
  remains secure, it is not strongly unforgeable: if either scheme breaks, an
  attacker can replace that scheme's partial signature while the signature as
  a whole remains valid. The paper's BoP-2 construction avoids this by having
  the Schnorr signature commit to the post-quantum signature in its challenge
  hash.

  Adam Gibson and Conduition discussed whether strong unforgeability still
  matters post-[segwit][topic segwit], since witnesses no longer affect
  txids. Wuille explained that the concern is a quantum or classical break
  allowing anyone to malleate the broken scheme's signature component.
  Conduition compared the construction to Boris Nagaev's space-saving hybrid
  hash-based design (see the lattice signatures item below) and concluded
  BoP-2 looks like the stronger unified-hybrid contender, though Wuille and
  Conduition both questioned whether unified hybrid schemes are worth the
  complexity when separate [BIP360][] (P2MR[news393 p2mr]) leaves, or simple
  script combinations can achieve similar results.

- **Post-quantum: lattice-based signatures**: Nikita Karetnikov
  [posted][nk delving lattice] to Delving Bitcoin and
  [cross-posted][nk ml lattice] to the Bitcoin-Dev mailing list about a
  Blockstream [blog post][bs blog lattice] comparing post-quantum signature
  families, where lattice-based schemes appear favorable on size and
  functionality. He inquired as to why Bitcoin post-quantum work has focused
  on hash-based signatures instead.

  Conduition [replied][c ml lattice] that hash-based signatures remain
  attractive for Bitcoin because of weaker security assumptions,
  implementation simplicity, fast verification, and suitability as a long-term
  fallback. Mikhail Kudinov noted that while naïvely, lattice-based signatures
  often require floating point computations, Falcon's floating-point
  operations can be simulated with integers. Conduition and Jesse Posner
  discussed whether unified hybrid Schnorr+lattice schemes are necessary
  versus achieving similar security with separate [BIP360][] (P2MR) leaves. On
  the other hand, Boris Nagaev described space savings from treating hybrid
  signing as a single construction rather than a simple concatenation of
  multiple signature schemes - schemes could likely share certain required
  randomizing parameters, for example.

- **Public key recovery for EC leaves in P2MR (BIP360)**: starius
  [posted][st delving recover] to Delving Bitcoin a proposal to add a
  recoverable elliptic curve (EC) key leaf type to [BIP360][] (P2MR). The idea
  is to recover the EC public key from the [Schnorr][topic schnorr signatures]
  signature. The public key is committed to in P2MR Merkle tree instead of a
  script, and the Schnorr signature challenge is modified to include the
  Merkle root and control block instead of the public key itself. Because both
  the Merkle root and control block are known both at signing and verification
  time, the signature can be verified without foreknowledge of the public key,
  and then the public key's inclusion in the Merkle root can be verified via
  the control block. Using this technique, a depth-1 Schnorr leaf witness
  shrinks from 135 bytes to 100 bytes, between the size of a [P2TR][topic
  taproot] key spend and a [P2WPKH][topic segwit] spend, at the cost of giving
  up BIP340 batch verification. starius and Conduition explained that
  including the control block in the challenge prevents a related-key attack
  when multiple such leaves share a tree. Pieter Wuille reviewed the
  construction favorably. Anthony Towns, Pieter Wuille, and Conduition
  discussed implications for [BIP32][topic bip32] derivation,
  batch-verification discounts, and the interaction with Conduition's
  depth-zero tree ban (depth-zero recoverable leaves could match [P2TR][topic
  taproot] witness sizes without a post-quantum fallback). starius explained
  that this should be folded into BIP360 before activation because it changes
  witness parsing rules.

- **Aligning privacy incentives in P2MR**: Conduition [posted][c ml p2mrdepth]
  to the Bitcoin-Dev mailing list a proposed [BIP360][] (P2MR) change to
  require every P2MR control block to include at least one 32-byte Merkle
  authentication path (i.e. ban depth-zero script trees). Depth-zero trees
  make some protocols requiring only a single script path more efficient in
  P2MR than [P2TR][topic taproot], creating a perverse incentive to skip
  cooperative signing paths and making some contract protocols easier to
  fingerprint on chain.

  Antoine Poinsot agreed this would address that privacy concern but still
  prefers [P2TRv2][news403 pqout] for mass migration because typical
  single-key P2MR spends cost roughly 15% more than P2TRv2 (possibly less with
  key recovery discussed above). Pieter Wuille argued that pre-quantum
  adoption incentives matter more than long-term post-quantum efficiency and
  that P2TRv2 better minimizes migration costs, he also noted that P2MR only
  even makes sense if users can rely on a future soft fork disabling elliptic
  curve paths within P2MR. Conduition predicted similarly low voluntary
  migration rates for either design and noted an upcoming witness-size
  optimization for common elliptic curve spends (see the next item). Hayashi
  [suggested][h ml p2mrdepth] an additional witness discount on P2MR Schnorr
  leaves to further close the cost gap.

- **Prohibit Merkle internal node preimages that encode minimal 64-byte transactions**:
  Jeremy Rubin [posted][jr ml merkle64] to the Bitcoin-Dev mailing list a
  draft BIP proposing an alternative to the [consensus cleanup][topic
  consensus cleanup] ([BIP54][]) rule making 64-byte witness-stripped
  transactions consensus-invalid. Instead of banning the transactions
  themselves, Rubin's rule would invalidate any block whose transaction Merkle
  tree contains an internal node preimage with the byte layout of a minimal
  one-input, one-output, witness-stripped transaction. This targets the same
  [merkle tree vulnerability][topic merkle tree vulnerabilities] at the
  internal-node boundary while preserving potentially useful 64-byte
  transactions (see [Newsletter #408][news408 64byte]). SPV verifiers would
  need to reject proofs whose branch preimages match the forbidden pattern.
  The draft includes miner recovery guidance (reorder or drop offending
  transactions) and notes that accidental violations should be rare.

- **Giving teeth to expected EC disabling: P2XX(-T)(-ML)**: Pieter Wuille
  [wrote][pw ml p2xx] to the Bitcoin-Dev mailing list about codifying the
  expected future disabling of elliptic curve (EC) spending paths within new
  [post-quantum][topic quantum resistance] output types such as [BIP360][]
  (P2MR) and [P2TRv2][news403 pqout]. Without consensus-enforced triggers,
  users won't be confident that EC spending will actually be disabled,
  undermining the quantum-resistance story for output types that initially
  allow cheap EC spends.

  Wuille proposed two mechanisms bundled with the introducing soft fork:
  **tripwire** (P2XX-T), which disables EC paths in the new output type after
  any successful `<NUMS> OP_CHECKSIG` spend proves secp256k1 is broken,
  putting a non-confiscatory upper bound on EC availability; and **miner
  lockdown** (P2XX-ML), which lets a hashrate majority activate the same
  disabling through a separately signaled soft fork with a very long
  activation window. Boris Nagaev supported tripwire but raised false-positive
  concerns for miner lockdown after large classical thefts. Sjors Provoost
  suggested long delays and user migration back to [P2TR][topic taproot] as a
  remedy. Conduition supported tripwire, noted that the proof need not be
  mined on-chain, and warned that early miner lockdown could be
  fee-incentivized. Wuille clarified that disabling must cover all EC usage
  within the output type (not just key paths) and that hybrid signing should
  use dedicated opcodes rather than arbitrary script combinations to ensure
  spendability post-EC disabling.

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

{% include snippets/recap-ad.md when="2026-07-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[rs ml starkbench]: https://groups.google.com/g/bitcoindev/c/0IdqdnlC4Og
[eh ml starkagg]: https://groups.google.com/g/bitcoindev/c/wKizvPUfO7w
[pw delving bop2]: https://delvingbitcoin.org/t/bird-of-prey-2-non-malleable-schnorr-pq-signatures/2514
[c ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA
[h ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA/m/T7UWqgnvAAAJ
[st delving recover]: https://delvingbitcoin.org/t/public-key-recovery-for-ec-leaves-in-p2mr-bip-360/2603
[jr delving cr]: https://delvingbitcoin.org/t/commit-reveal-for-pq-migration/2419
[nk ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc
[nk delving lattice]: https://delvingbitcoin.org/t/pqc-lattice-based-signatures/2522
[c ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc/m/WE-R3z85AAAJ
[bs blog lattice]: https://blog.blockstream.com/schnorr-but-with-vectors-lattice-based-signatures-explained/
[jr ml merkle64]: https://groups.google.com/g/bitcoindev/c/ZVDEzxG6Sq8
[pw ml p2xx]: https://groups.google.com/g/bitcoindev/c/aWYtPLVPZ3U
[pacts]: https://www.paradigm.xyz/2026/05/pacts-protecting-your-bitcoin-from-a-quantum-sunset
[news383 sphincs]: /en/newsletters/2025/12/05/#slh-dsa-sphincs-post-quantum-signature-optimizations
[news386 jn hash]: /en/newsletters/2026/01/02/#hash-based-signatures-for-bitcoin-s-post-quantum-future
[news393 p2mr]: /en/newsletters/2026/02/20/#bips-1670
[news403 pqout]: /en/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news403 stark]: /en/newsletters/2026/05/01/#post-quantum-bip86-recovery-using-zk-stark-proofs-of-bip32-seeds
[news408 64byte]: /en/newsletters/2026/06/05/#bip54-64-byte-transactions-and-potential-legitimate-uses
[news361 pqcr]: /en/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
