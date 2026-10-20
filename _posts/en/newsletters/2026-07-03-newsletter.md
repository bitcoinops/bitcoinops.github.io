---
title: 'Bitcoin Optech Newsletter #412'
permalink: /en/newsletters/2026/07/03/
name: 2026-07-03-newsletter
slug: 2026-07-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections summarizing discussion about
changing Bitcoin's consensus rules, announcing new releases and
release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

*No significant news this week was found in any of our [sources][].*

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Benchmarking SLH-DSA STARK aggregation**: Remix7531 [posted][rs ml starkbench]
  to the Bitcoin-Dev mailing list his benchmark results for aggregating many
  [SPHINCS][news383 sphincs] signature verifications into a single
  STARK proof. This follows Ethan Heilman's earlier
  [proposal][eh ml starkagg] to use STARKs to scale [post-quantum][topic
  quantum resistance] blocks. In this benchmark suite (built in RISC Zero's
  zkVM), proving time scales roughly linearly with the number of signatures
  (~3.1 seconds per signature on an RTX 5090), proof size grows sublinearly
  (218 KiB for one signature up to 454 KiB for 512 signatures, versus 3.8 MiB
  of raw signatures), and verification stays near 12-15 milliseconds
  regardless of batch size. Proving an entire block on one GPU would still
  take hours, but Remix suggests that dedicated AIR circuits (polynomial
  constraints tailored to signature verification rather than the
  general-purpose zkVM used here), mempool preprocessing, and multi-GPU
  proving could improve this. The benchmarks also
  use standard SPHINCS rather than the more compact Bitcoin-optimized
  [SPHINCS+][news386 jn hash] variant. {% assign timestamp="1:05" %}

- **Bird of Prey 2 (BoP-2) non-malleable schnorr and PQ signatures**: Pieter
  Wuille [posted][pw delving bop2] to Delving Bitcoin about a EuroCrypt 2026
  paper on constructing hybrid strongly-unforgeable signature schemes from a
  [schnorr][topic schnorr signatures]-like scheme and an arbitrary
  [post-quantum][topic quantum resistance] signature scheme. While simply
  concatenating signatures from both schemes is unforgeable if at least one
  remains secure, it is not strongly unforgeable. If either scheme breaks, an
  attacker can replace that scheme's partial signature while the signature as
  a whole remains valid. The paper's BoP-2 construction avoids this by having
  the schnorr signature commit to the post-quantum signature in its challenge
  hash.

  Adam Gibson and Conduition discussed whether strong unforgeability still
  matters post-[segwit][topic segwit], since witnesses no longer affect
  txids. Wuille explained that the concern is a quantum or classical break
  allowing anyone to malleate the broken scheme's signature component.
  Conduition compared the construction to Boris Nagaev's space-saving hybrid
  hash-based design (see the lattice signatures item below) and concluded
  BoP-2 looks like the stronger unified-hybrid contender, though Wuille and
  Conduition both questioned whether unified hybrid schemes are worth the
  complexity when separate [BIP360][] ([P2MR][news393 p2mr]) leaves, or simple
  script combinations can achieve similar results. {% assign timestamp="10:21" %}

- **Lattice-based signatures**: Nikita Karetnikov
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
  discussed whether unified hybrid schnorr+lattice schemes are necessary
  versus achieving similar security with separate [BIP360][] (P2MR) leaves. On
  the other hand, Boris Nagaev described space savings from treating hybrid
  signing as a single construction rather than a simple concatenation of
  multiple signature schemes, since they could likely share certain required
  randomizing parameters, for example. {% assign timestamp="19:41" %}

- **Public key recovery for P2MR EC leaves**: starius
  [posted][st delving recover] to Delving Bitcoin a proposal to add a
  recoverable elliptic curve (EC) key leaf type to [BIP360][] (P2MR). The idea
  is to recover the EC public key from the [schnorr][topic schnorr signatures]
  signature. The public key is committed to in P2MR merkle tree instead of a
  script, and the schnorr signature challenge is modified to include the
  merkle root and control block instead of the public key itself. Because both
  the merkle root and control block are known both at signing and verification
  time, the signature can be verified without knowledge of the public key,
  and then the public key's inclusion in the merkle root can be verified via
  the control block. Using this technique, a depth-1 schnorr leaf witness
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
  witness parsing rules. {% assign timestamp="25:50" %}

- **Aligning privacy incentives in P2MR**: Conduition [posted][c ml p2mrdepth]
  to the Bitcoin-Dev mailing list a proposed [BIP360][] (P2MR) change to
  require every P2MR control block to include at least one 32-byte merkle
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
  that P2TRv2 better minimizes migration costs. He also noted that P2MR only
  makes sense if users can rely on a future soft fork disabling elliptic
  curve paths within P2MR. Conduition predicted similarly low voluntary
  migration rates for either design and noted an upcoming witness-size
  optimization for common elliptic curve spends (see the next item). Hayashi
  [suggested][h ml p2mrdepth] an additional witness discount on P2MR schnorr
  leaves to further close the cost gap. {% assign timestamp="30:48" %}

- **Prohibit merkle internal node preimages that encode minimal 64-byte transactions**:
  Jeremy Rubin [posted][jr ml merkle64] to the Bitcoin-Dev mailing list a
  draft BIP proposing an alternative to the [consensus cleanup][topic
  consensus cleanup] ([BIP54][]) rule making 64-byte witness-stripped
  transactions consensus-invalid. Instead of banning the transactions
  themselves, Rubin's rule would invalidate any block whose transaction merkle
  tree contains an internal node preimage with the byte layout of a minimal
  one-input, one-output, witness-stripped transaction. This targets the same
  [merkle tree vulnerability][topic merkle tree vulnerabilities] at the
  internal-node boundary while preserving potentially useful 64-byte
  transactions (see [Newsletter #408][news408 64byte]). SPV verifiers would
  need to reject proofs whose branch preimages match the forbidden pattern.
  The draft includes miner recovery guidance (reorder or drop offending
  transactions) and notes that accidental violations should be rare.

  Several responses preferred the simpler outright 64-byte transaction ban of
  BIP54. Antoine Poinsot argued that any system securing value already validates
  these transactions properly, so the distinction Rubin draws matters little in
  practice. Matt Corallo noted this would require miners to change their
  block-building software or risk producing invalid blocks. Murch pointed out
  that occasionally adding a one-byte padding is a smaller burden than making
  every node check thousands of hashes during block validation. Sjors Provoost
  suggested deferring a cleaner fix to a future block-header format change. {% assign timestamp="49:38" %}

- **Triggering EC disabling with a NUMS point spend or hashrate majority**: Pieter Wuille
  [wrote][pw ml p2xx] to the Bitcoin-Dev mailing list about codifying the
  expected future disabling of elliptic curve (EC) spending paths within new
  [post-quantum][topic quantum resistance] output types such as [BIP360][]
  (P2MR) and [P2TRv2][news403 pqout]. Without consensus-enforced triggers,
  users won't be confident that EC spending will actually be disabled,
  undermining the quantum-resistance story for output types that initially
  allow cheap EC spends.

  Wuille proposed two mechanisms bundled with the introducing soft fork:
  tripwire (P2XX-T), which disables EC paths in the new output type after
  any successful `<NUMS> OP_CHECKSIG` spend proves secp256k1 is broken,
  putting a non-confiscatory upper bound on EC availability; and miner
  lockdown (P2XX-ML), which lets a hashrate majority activate the same
  disabling through a separately signaled soft fork with a very long
  activation window. Boris Nagaev supported tripwire but raised false-positive
  concerns for miner lockdown after large classical thefts. Sjors Provoost
  suggested long delays and user migration back to [P2TR][topic taproot] as a
  remedy. Conduition supported tripwire, noted that the proof need not be
  mined on-chain, and warned that early miner lockdown could be
  fee-incentivized. Wuille clarified that disabling must cover all EC usage
  within the output type (not just key paths) and that hybrid signing should
  use dedicated opcodes rather than arbitrary script combinations to ensure
  spendability post-EC disabling. {% assign timestamp="37:36" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 31.1rc1][] is a release candidate for a maintenance version of
  the predominant full-node implementation. It fixes an IP address leak in
  `-privatebroadcast` that could undermine [transaction origin privacy][topic
  transaction origin privacy] (see [Newsletter #409][news409 privatebroadcast]),
  and includes fixes for chainstate compaction,
  wallet migration, input-size estimation, [MuSig2][topic musig] key
  aggregation, and proxy handling during [v2 P2P transport][topic v2 p2p
  transport] reconnections. {% assign timestamp="1:32:43" %}

- [Bitcoin Core 30.3rc1][] is a release candidate for a maintenance version of
  the predominant full-node implementation. It fixes a chainstate database issue
  that could cause excessive disk reads and writes during normal operation,
  along with wallet, [PSBT][topic psbt], [miniscript][topic miniscript],
  networking, build, test, and documentation fixes. {% assign timestamp="1:32:48" %}

- [Bitcoin Core 29.4rc1][] is a release candidate for a maintenance version of
  the predominant full-node implementation. It fixes the same chainstate
  database rewrite issue as 30.3rc1 and includes selected validation, wallet,
  build, test, documentation, CI, and compatibility fixes. {% assign timestamp="1:32:52" %}

- [Core Lightning v26.06.2][] is a maintenance release that fixes
  `cln-currencyrate` on minimal OS and Docker setups without installed TLS root
  certificates. {% assign timestamp="1:36:01" %}

- [LND v0.20.2-beta.rc1][] is a release candidate for a maintenance release of
  this popular LN node implementation. It fixes a DNS fallback panic and an
  onchain forward-interceptor settlement bug, and adds the final-hop
  [HTLC][topic htlc] CLTV expiry validation described in the notable code
  section below. {% assign timestamp="1:36:39" %}

- [LND v0.21.1-beta][] is a maintenance release of this popular LN node
  implementation. It fixes [Tor][topic anonymity networks] v3 onion service
  creation for fresh Tor-enabled nodes, a DNS fallback panic, and an onchain
  forward-interceptor settlement bug, and tightens final-hop HTLC CLTV expiry
  validation. {% assign timestamp="1:38:10" %}

- [LDK v0.2.4][] is a maintenance release of this library for building
  LN-enabled wallets and applications. It fixes a regression in v0.2.3 that
  raised the minimum supported Rust version for the `lightning` crate; the
  crate now again compiles with `rustc` 1.63. {% assign timestamp="1:38:57" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35266][] adds a `load_wallet` argument (default true) to the
  `migratewallet` RPC, allowing a legacy wallet to be migrated to
  [descriptor][topic descriptors] wallets without immediately loading the
  migrated wallet. This helps users migrate a legacy wallet on a pruned node
  whose chain state is pruned below the wallet's birthday, where loading the
  migrated wallet would require unavailable block data even though migration
  itself does not. {% assign timestamp="1:40:00" %}

- [Bitcoin Core #35550][] updates [compact block relay][topic compact block
  relay] negotiation to reject `sendcmpct` messages whose boolean announcement
  field is not exactly `0` or `1`, as required by [BIP152][]. Previously,
  Bitcoin Core decoded the field directly as a C++ `bool`, causing any non-zero
  value to be accepted as true. The PR now reads the field as an integer and
  treats values greater than 1 as peer misbehavior, disconnecting the peer. {% assign timestamp="1:41:10" %}

- [Bitcoin Core #35610][] adds a `netmagic` command to `bitcoin-util` that
  prints the four-byte network identifier used in Bitcoin P2P messages for the
  selected chain, including custom [signets][topic signet]. This command is
  useful for the proposed multi-signet datadir support, in which custom signets
  would be stored in datadirs that are suffixed by their network identifiers.
  This allows scripts to select the correct directory before starting
  `bitcoind`. {% assign timestamp="1:42:15" %}

- [BIPs #2196][] adds [BIP95][], a draft specification for [testnet5][topic
  testnet], a new test network intended to replace testnet4 (see [Newsletter
  #409][news409 testnet5]). Testnet4 has a difficulty exception that allows
  for minimum-difficulty blocks after long gaps. However, this exception has
  been persistently exploited, resulting in frequent, small reorgs and rendering
  the network difficult to use for testing. Testnet5 removes the exception,
  raises the minimum difficulty to about 1,048,561, and enforces [BIP54][]
  [consensus cleanup][topic consensus cleanup] rules from block 1. The draft
  also specifies message start bytes `0x46495645` (`FIVE`) and default P2P port
  `18335`, although its genesis block values remain placeholders for now. {% assign timestamp="1:43:52" %}

- [BIPs #2165][] updates [BIP52][], the Optical Proof-of-Work proposal
  described in [Newsletter #181][news181 bip52], changing its status from Draft
  to Closed. BIP52 proposed a hard fork that claimed to shift mining costs away
  from electricity and operations and toward specialized optical mining
  equipment. After several years without progress and recent unsuccessful
  attempts to contact the authors, the proposal was closed. {% assign timestamp="1:47:46" %}

- [BIPs #2201][] advances [BIP110][], the Reduced Data Temporary Softfork
  proposal, to Complete status (see [Newsletter #392][news392 bip110]). This
  update emphasizes that UTXOs created before activation are grandfathered and
  can be spent under the old rules during deployment. It also adds
  reference-implementation test coverage and
  transaction-level test vectors. Additionally, it clarifies the impact of the
  temporary ban on executing `OP_IF` and `OP_NOTIF` in [tapscript][topic
  tapscript] leaves: existing UTXOs are exempt, but new constructions using
  these opcodes would require alternatives, such as separate leaves. {% assign timestamp="1:50:13" %}

- [LND #10900][] adds a `WalletKit.SubmitPackage` RPC and `lncli wallet
  submitpackage` command for submitting a 1p1c [transaction package][topic package relay]
  to LND's chain backend. For bitcoind backends, LND forwards the
  package to Bitcoin Core's `submitpackage` RPC, allowing a zero-fee [v3
  transaction relay][topic v3 transaction relay] parent with an [ephemeral
  anchor][topic ephemeral anchors] to be accepted together with a fee-paying
  [CPFP][topic cpfp] child. Other backends do not provide the same
  package submission: btcd returns unimplemented, and neutrino broadcasts the
  transactions individually. {% assign timestamp="1:51:20" %}

- [LND #10927][] tightens validation of final-hop [HTLC][topic htlc] CLTV
  expiries. Previously, a final-hop HTLC could specify an expiry much farther
  in the future than the receiver's policy allowed, tying up liquidity for an
  excessive amount of time even though forwarding CLTV deltas were already
  bounded. LND now rejects final HTLCs outside the receiver's CLTV policy with
  `incorrect_or_unknown_payment_details`, validates related config bounds, and
  applies the same checks if the channel is force-closed before deciding
  whether to claim the HTLC on-chain with a preimage. {% assign timestamp="1:52:37" %}

- [LDK #4748][] and [#4751][ldk #4751] fix two [splicing][topic splicing]
  state-machine edge cases involving delayed messages. [LDK #4748][] fixes a
  case in which delayed splice `tx_signatures` could arrive while an unrelated
  [HTLC][topic htlc]-preimage channel monitor update was pending, causing LDK
  to incorrectly block completion of the splice flow. LDK now only waits when
  the pending monitor update is the splice-related update that must be durably
  persisted first. [#4751][ldk #4751] fixes a case in which a peer's in-flight
  splice `commitment_signed` could arrive after the local user canceled their
  funding contribution, causing LDK to validate a signature for a stale splice
  funding transaction and potentially force-close the still-live channel. LDK
  now checks the optional `funding_txid` in `commitment_signed` and ignores
  signatures for stale splice funding transactions. {% assign timestamp="1:54:13" %}

{% include snippets/recap-ad.md when="2026-07-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2165,2196,2201,35266,35550,35610,10900,10927,4748,4751" %}

[rs ml starkbench]: https://groups.google.com/g/bitcoindev/c/0IdqdnlC4Og
[eh ml starkagg]: https://groups.google.com/g/bitcoindev/c/wKizvPUfO7w
[pw delving bop2]: https://delvingbitcoin.org/t/bird-of-prey-2-non-malleable-schnorr-pq-signatures/2514
[c ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA
[h ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA/m/D3hERI8wCwAJ
[st delving recover]: https://delvingbitcoin.org/t/public-key-recovery-for-ec-leaves-in-p2mr-bip-360/2603
[nk ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc
[nk delving lattice]: https://delvingbitcoin.org/t/pqc-lattice-based-signatures/2522
[c ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc/m/XFpCuylPCQAJ
[bs blog lattice]: https://blog.blockstream.com/schnorr-but-with-vectors-lattice-based-signatures-explained/
[jr ml merkle64]: https://groups.google.com/g/bitcoindev/c/ZVDEzxG6Sq8
[pw ml p2xx]: https://groups.google.com/g/bitcoindev/c/aWYtPLVPZ3U
[news383 sphincs]: /en/newsletters/2025/12/05/#slh-dsa-sphincs-post-quantum-signature-optimizations
[news386 jn hash]: /en/newsletters/2026/01/02/#hash-based-signatures-for-bitcoin-s-post-quantum-future
[news393 p2mr]: /en/newsletters/2026/02/20/#bips-1670
[news403 pqout]: /en/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news408 64byte]: /en/newsletters/2026/06/05/#bip54-64-byte-transactions-and-potential-legitimate-uses
[Core Lightning v26.06.2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.2
[LND v0.20.2-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.2-beta.rc1
[LND v0.21.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.1-beta
[LDK v0.2.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.4
[Bitcoin Core 31.1rc1]: https://bitcoincore.org/bin/bitcoin-core-31.1/test.rc1/
[Bitcoin Core 30.3rc1]: https://bitcoincore.org/bin/bitcoin-core-30.3/test.rc1/
[Bitcoin Core 29.4rc1]: https://bitcoincore.org/bin/bitcoin-core-29.4/test.rc1/
[news181 bip52]: /en/newsletters/2022/01/05/#bips-1126
[news392 bip110]: /en/newsletters/2026/02/13/#bips-2017
[news409 testnet5]: /en/newsletters/2026/06/12/#draft-bip-for-testnet5
[news409 privatebroadcast]: /en/newsletters/2026/06/12/#bitcoin-core-35410
[sources]: /en/internal/sources/
