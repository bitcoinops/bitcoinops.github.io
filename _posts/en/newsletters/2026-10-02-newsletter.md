---
title: 'Bitcoin Optech Newsletter #425'
permalink: /en/newsletters/2026/10/02/
name: 2026-10-02-newsletter
slug: 2026-10-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the responsible disclosure of two
denial-of-service vulnerabilities affecting older versions of Eclair and
describes a proposal for synchronizing wallet labels between devices
through an untrusted store. Also included are our regular sections summarizing
proposals and discussion about changing Bitcoin's consensus rules, announcing
new releases and release candidates, and describing notable changes to popular
Bitcoin infrastructure software.

## News

- **Disclosure of two DoS vulnerabilities in Eclair**: Matt Morehouse
  [posted][mm eclair dos] to Delving Bitcoin the [responsible
  disclosure][topic responsible disclosures] of two denial-of-service (DoS)
  vulnerabilities affecting Eclair v0.13.1 and earlier. Both were fixed in
  [Eclair v0.14.0][news407 eclair], released in May, and users still running
  an older version should upgrade. Each attack requires only a completed
  [BOLT8][] handshake, not a channel.

  The first vulnerability is in feature bit parsing. Eclair parsed the
  feature bits in an `init` message one at a time, allocating several
  objects per bit, so a single maximum-length `init` message allocated and
  discarded about 300 MB of memory and occupied a parsing thread for up to
  300 ms. In Morehouse's tests, an attacker with a few dozen connections
  repeating that message disconnected all of the node's peers within a minute
  and exhausted its memory within five. Morehouse found the bug with
  [smite][smite repo], his LN fuzzer, using its most basic test, which sends
  raw bytes as a single message and checks that the target still answers a
  `ping` promptly. The fix was merged in March as part of [Eclair #3264][], a
  refactoring of feature parsing that did not mention the vulnerability.

  The second vulnerability is in gossip queries. [BOLT7][] removed the zlib
  encoding for `query_short_channel_ids` messages in April 2022, and Eclair stopped
  sending it the same month but continued to accept it. The zlib decompression
  had no output limit, so a 64 kB message could inflate to 64 MB and about 17
  million objects, and a flood of such messages took a node offline within
  seconds. Morehouse found it after the first bug by using an LLM to search the
  Eclair codebase for other places where a peer could impose far more work on
  the node than it spends itself. The fix is [Eclair #3263][].

- **Proposal for wallet label synchronization**: Jakub [posted][label sync ml]
  to the Bitcoin-Dev mailing list to gauge interest in standardizing
  synchronization of [wallet labels][topic wallet labels] between wallets
  through a shared, untrusted store before writing a specification. Although
  [BIP329][] standardized a label export format (see [Newsletter #215][news215
  label]), moving labels between wallets that use the same
  [descriptor][topic descriptors], such as a coordinator and a watch-only
  wallet, remains a manual export and import cycle, so coin selection decisions
  are made without the associated labels.

  Under the proposal, wallets derive a storage location and encryption keys
  from a canonical form of the descriptor, without any private keys, so
  wallets sharing a descriptor find the same data with no configuration.
  Unmodified BIP329 records travel inside an authenticated encryption
  envelope. Each record is stored with the time it was written, so when two
  wallets change the same label, the most recent change takes precedence.
  Because BIP329 has no way to delete a label, a deletion is recorded as a
  marker that removes the label from other wallets. Jakub proposes Nostr as
  the reference transport, but the protocol only requires a service that can
  store and return data. The Bitcoin Safe wallet already synchronizes labels
  this way over Nostr. Jakub asked whether encryption keys should derive from
  the descriptor, which lets a wallet restore its labels from the descriptor
  alone but exposes them to anyone who has held the xpubs, or from a separate
  secret. He also asked whether to use one shared keypair across devices or
  per-device pairing, and how to define the canonical descriptor form.

  Craig Raw replied that label synchronization should be part of a broader
  inter-wallet communication specification, which should include other use cases
  such as [PSBTs][topic psbt], multisig setups, and payment confirmations.
  He also pushed back on the use of Nostr as the reference transport protocol,
  since exchange of financial data should optimize for privacy, rather than
  censorship resistance, and noted that he is working on a BIP for canonical
  output descriptors.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Continued discussion of PQC output types**: Following last month's
  [summary][news421 pqout] of Pieter Wuille's Delving Bitcoin thread on
  [post-quantum][topic quantum resistance] output types, Antoine Riard
  [replied][ar delving pqout] affirming that a [P2TRv2][news403 pqout] output
  whose quantum-vulnerable spend paths can later be disabled only within that
  output type is acceptable because users opt in by receiving to it, avoiding a
  generic freeze of existing outputs. He prefers not to bundle [CISA][topic
  cisa] with that change, and suggested a later [P2MR][news393 p2mr]-based type
  with a new witness style, plus optional leaf versions so some coins could
  keep a secp256k1-secured path after others had been disabled.

  Conduition
  [argued][c delving pqout deriv] that even P2TRv2 is not a trivial
  witness-version bump: wallets that actually use the post-quantum path still
  need new standards for deriving PQ keys, replacing [BIP32][]-style workflows.
  Wuille [replied][pw delving pqout cisa2] that CISA is unlikely to move the
  long tail of wallets whose users do not care about fees or PQ, and that
  neither P2TRv2 nor P2MR is a categorically quantum-secure output type,
  because both rely on someone deciding when to stop using secp256k1. P2MR lets
  the owner decide, but Wuille believes address reuse and public key sharing
  are too entrenched for most users to benefit.

  Antoine Poinsot
  [agreed][ap delving pqout] that P2TRv2 and CISA pull in opposite directions:
  users who want CISA without expecting an early secp256k1 disablement may refuse
  P2TRv2 or, worse, adopt it without a post-quantum spend path, undermining a
  later secp256k1 disablement. He also noted that shipping them as separate
  output types could leave
  distinguishable footprints if both become widely used. Conduition and Wuille
  continued to discuss whether P2MR's protection is achievable in
  practice, and Conduition [proposed][c delving pqout both] deploying both
  output types and letting users choose.

- **Block-wide signature aggregation via SNARKs**: Conduition
  [posted][c delving snark] to Delving Bitcoin a design sketch for
  compressing many [post-quantum][topic quantum resistance] signatures
  in a block into a single SNARK (see also
  Ethan Heilman's earlier [proposal][eh delving stark] and
  [Newsletter #412][news412 stark]). Hash-based signatures are cheap to verify
  but large; a witness discount large enough to make them fee-competitive
  would grow archival storage into terabytes per year (see [Newsletter
  #417][news417 pqwit]).

  Conduition expects large mining pools to produce
  the proofs themselves and argues that ordinary nodes should never run a
  prover. His design uses a bespoke aggregation
  circuit rather than a general-purpose virtual machine (VM), a single flat
  proof rather than recursive proofs, and a [SPHINCS][news383 sphincs]
  variant with WOTS+C rather than SLH-DSA. Verifying the variant takes the
  same number of hash operations for every signature, whereas the number for
  SLH-DSA depends on choices the signer makes, so a circuit for it would have
  to be sized for the most expensive case. The smallest hash-based SNARK proofs
  are typically 300-500 kB. To allay concerns about the soundness of the
  proposed proof, he sketched out several mechanisms to recover or opt out
  depending on future conditions. He argues against allowing both
  raw signatures and a SNARK as valid block formats, which would let miners mine
  while a proof is produced instead of mining empty blocks, because resource
  limits would have to assume the worst case. A naive extrapolation from the
  SHA256 benchmarks in Flock, a SNARK prover for hash circuits, suggested about
  20 seconds to prove a 10,000-signature block on a 10-thread CPU, with hope of
  reducing that below 10 seconds; Conduition noted that nobody has yet tested a
  SPHINCS verifier circuit in Flock.

  Jonas Nick [pointed][jn delving snark] to work showing that a SNARK's
  random-oracle proof does not automatically cover recursive use of
  the same SNARK. ZmnSCPxj [warned][zmn delving snark] that a DoS in
  prover code used by miners could stall block production, and
  suggested shipping the prover in Bitcoin Core so it gets review.

- **Bounds on chain length with BIP54 time warp fixes**: Pieter Wuille
  [posted][pw delving timewarp] to Delving Bitcoin a proof that the two
  timestamp rules in the [consensus cleanup][topic consensus cleanup]
  proposal ([BIP54][]) suffice to bound how many blocks can be mined in a chain
  of given work. The bound is machine-checked in Lean, so only the statement
  being proven needs review. The first rule (classic [time warp][topic time warp]) requires
  the first block of a retarget period to be no more than
  7,200 seconds before the preceding block; the second (Murch–Zawy; see
  [Newsletter #316][news316 timewarp]) requires the last block of a
  period not to predate the first. Together they bound the long-term
  block rate to about one block per 9 minutes 56 seconds, plus a
  bounded number of extra blocks paid for with difficulty increases.

  For a chain at height 966,270 the formula allows at most 1,012,794
  blocks, about 3,300 times tighter than with neither rule. Omitting
  either rule leaves a limit above 3.34 billion blocks. The longest
  constructed chain Wuille reported is 1,007,326 blocks.

  Wuille's
  motivation was Bitcoin Core's headers presync [DoS protection][news216 presync],
  which could rely on the bound once BIP54 is buried. Zawy discussed alternative
  formulations. Wuille later proved a complementary lower bound on the
  work required to produce a chain of a given length in a given time.

- **Comparing covenant proposals for vaults**: Lillian Wang
  [posted][lw delving vaults] to Delving Bitcoin and [cross-posted][lw
  ml vaults] to the Bitcoin-Dev mailing list a [report][vault report]
  comparing simplified [vault][topic vaults] constructions using
  presigned transactions, [`OP_CHECKTEMPLATEVERIFY`][topic
  op_checktemplateverify] (CTV), [`SIGHASH_ANYPREVOUT`][topic
  sighash_anyprevout] / `SIGHASH_ANYPREVOUTANYSCRIPT` (APO/APOAS),
  `OP_TXHASH`, [`OP_CHECKCONTRACTVERIFY`][topic matt] (CCV,
  [BIP443][]), and an [`OP_CAT`][topic op_cat]-based [Purrfect Vault][news291 cat vault].

  The report concludes that CTV fits simple vaults with precomputed
  outputs, CCV best supports partial withdrawals and choosing a
  withdrawal address at trigger time, and TXHASH offers more
  commitment flexibility at the cost of more designer responsibility.
  APOAS and CAT may be more appealing if their broader non-vault
  applications are also valued.

  askii21m [noted][askii delving vaults]
  that APOAS signatures can be combined across two deposits to the
  same vault address in a single transaction that creates the expected
  output only once, with the second deposit's value going to fees (a half-spend), because APOAS commits to neither the input
  count nor the input index, so never reusing a vault address is a
  requirement rather than a recommendation.

- **Depots for probabilistic Lightning channels**: John Law
  [posted][jl delving depots] to Delving Bitcoin a [protocol][depots paper]
  in which an operator funds a single time-limited taproot output (a depot)
  that can host Lightning channels for many thousands or millions of users.
  Users buy those channels from the operator with a Lightning payment rather
  than putting their own funds onchain. Those balances are typically too small
  to be worth claiming onchain, so a depot replaces each user's small guaranteed
  claim with a chance at a large one of the same expected value, which bounds
  how many claims can ever go onchain.

  Each purchased channel is assigned a
  secret guess, chosen by the user, between zero and a large prime (P), and has a 1/P chance of
  being a "hit" after the depot expires. Before expiry, users are expected to
  drain their channels in the depot by paying out over Lightning (potentially
  to a later depot) and revealing their guesses to revoke those channels so
  they cannot be hits. After expiry the operator reveals a target: a channel
  is a hit if its guess matches. If no channel hits, the operator reclaims the
  output. If exactly one channel hits, that user can force the depot onchain
  and receive P times their offchain balance (so a 1/P chance of a P-times
  payout has the same expected value as the user's actual balance). If two or
  more channels hit, the depot is burned, which prevents users from collecting more than the depot
  holds.

  According to Law, this keeps the onchain footprint to about 1 or 2
  vbytes per user per year, and avoids a thundering herd of forced onchain
  transactions because a depot resolves in a constant-size set of transactions
  regardless of how many users it hosts. Security relies on [griefer
  penalization][news329 opr]: a party that griefs (for example by refusing to cooperate in a
  drain) must expect to lose a configured fraction of the damage it inflicts.
  Depots require [`OP_CHECKSIGFROMSTACK`][topic op_checksigfromstack] and
  [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]. They are more efficient with `OP_PAIRCOMMIT`
  ([BIP442][]), `OP_MUL`, and `OP_MOD`, but do not require them.

  Anzus asked
  what happens if a user misses expiry or loses a device. Law [replied][jl
  delving depots recover] that unlike his [timeout trees][topic timeout
  trees], the operator cannot roll a depot over without a user-provided
  secret, that wallets can automate an early drain, and that recovery needs
  depot parameters and channel state in addition to a seed.

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

{% include snippets/recap-ad.md when="2026-10-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[mm eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-0/2914
[news407 eclair]: /en/newsletters/2026/05/29/#eclair-v0-14-0
[smite repo]: https://github.com/lnfuzz/smite
[label sync ml]: https://groups.google.com/g/bitcoindev/c/p6UUOdGi9YI
[news215 label]: /en/newsletters/2022/08/31/#wallet-label-export-format
[news421 pqout]: /en/newsletters/2026/09/04/#continued-discussion-of-pqc-output-types
[news403 pqout]: /en/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news393 p2mr]: /en/newsletters/2026/02/20/#bips-1670
[ar delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/18
[c delving pqout deriv]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/20
[pw delving pqout cisa2]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/22
[ap delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/32
[c delving pqout both]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/38
[c delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875
[eh delving stark]: https://delvingbitcoin.org/t/post-quantum-signatures-and-scaling-bitcoin-with-starks/1584
[news383 sphincs]: /en/newsletters/2025/12/05/#slh-dsa-sphincs-post-quantum-signature-optimizations
[news412 stark]: /en/newsletters/2026/07/03/#benchmarking-slh-dsa-stark-aggregation
[news417 pqwit]: /en/newsletters/2026/08/07/#segwit-commitment-to-post-quantum-witness-data
[jn delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875/8
[zmn delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875/4
[pw delving timewarp]: https://delvingbitcoin.org/t/bounds-on-chain-length-with-bip-54-timewarp-fixes/2899
[news316 timewarp]: /en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4
[news216 presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[lw delving vaults]: https://delvingbitcoin.org/t/comparing-bitcoin-covenant-proposals-for-vaults/2877
[lw ml vaults]: https://groups.google.com/g/bitcoindev/c/Tv4k9kK5KYA
[vault report]: https://raw.githubusercontent.com/Skyler-Cloud/Bitcoin-Vault-Comparison/main/bitcoin-vault-comparison.pdf
[askii delving vaults]: https://delvingbitcoin.org/t/comparing-bitcoin-covenant-proposals-for-vaults/2877/4
[news291 cat vault]: /en/newsletters/2024/02/28/#simple-vault-prototype-using-op-cat
[jl delving depots]: https://delvingbitcoin.org/t/depots-theft-proof-self-custodial-bitcoin-for-billions-of-users/2892
[depots paper]: https://github.com/JohnLaw2/ln-depots/blob/main/depots_v1.0.pdf
[jl delving depots recover]: https://delvingbitcoin.org/t/depots-theft-proof-self-custodial-bitcoin-for-billions-of-users/2892/10
[news329 opr]: /en/newsletters/2024/11/15/#mad-based-offchain-payment-resolution-opr-protocol
