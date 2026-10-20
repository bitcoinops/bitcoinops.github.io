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
  the node than it spends itself. The fix is [Eclair #3263][]. {% assign timestamp="1:01" %}

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
  output descriptors. {% assign timestamp="15:25" %}

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
  output types and letting users choose. {% assign timestamp="21:36" %}

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
  suggested shipping the prover in Bitcoin Core so it gets review. {% assign timestamp="27:17" %}

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
  work required to produce a chain of a given length in a given time. {% assign timestamp="35:19" %}

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
  requirement rather than a recommendation. {% assign timestamp="39:23" %}

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
  depot parameters and channel state in addition to a seed. {% assign timestamp="43:18" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.21.4-beta.rc1][] is a release candidate for a maintenance release of
  this popular LN node implementation. It includes the [channel
  announcement][topic channel announcements] synchronization fix and
  restriction on new legacy channels described in the notable code section
  below. Other fixes address pending [HTLCs][topic htlc], unintended
  cancellation of [AMP][topic amp] invoices, and SQL graph migration failures.
  `WalletKit` can now reserve outputs until their spending transaction reaches
  a specified confirmation depth. The release also requires explicit channel
  types when opening channels. {% assign timestamp="48:40" %}

- [LND v0.20.5-beta.rc1][] is a release candidate for a maintenance release of
  LND's 0.20 release branch. It backports several fixes also included in
  0.21.4-beta.rc1, including those for pending HTLCs, AMP invoice cancellation,
  and channel synchronization, and adds bounds on onion payload parsing. {% assign timestamp="50:29" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29278][] adds a `-maxfeerate` config option that caps the
  feerate of wallet transactions at 0.10 BTC/kvB (10,000 sat/vB) by default.
  Previously, the `-maxtxfee` option was documented as an absolute fee cap.
  However, certain checks also interpreted the same amount as a fee per 1,000
  vB (see [Newsletter #54][news54 maxtxfee]). The new option separates the feerate limit from the total fee limit and
  applies to transaction creation, [fee bumping][topic rbf], [CPFP][topic cpfp]
  and regular wallet broadcast. {% assign timestamp="51:55" %}

- [Bitcoin Core #35984][] fixes a bug where [PSBT][topic psbt] signing could
  produce a `SIGHASH_SINGLE` signature without a corresponding output. This
  sighash type commits to the output at the same index as the input being
  signed. If the corresponding output is missing, legacy signing produces a
  signature over a constant hash (see [Newsletter #207][news207 single]). This
  signature can be reused to spend other UTXOs controlled by the same key,
  provided the corresponding output remains missing. Bitcoin Core now leaves
  such inputs unsigned for legacy and segwit v0, while still signing the PSBT's
  other inputs, extending a check already present in raw transaction signing. {% assign timestamp="53:43" %}

- [Bitcoin Core #35301][] begins the [BIP352][] [silent payments][topic silent
  payments] implementation by adding support for encoding and decoding
  addresses, deriving [taproot][topic taproot] payment outputs from eligible
  transaction inputs, and scanning transactions for payments to a recipient. It
  also adds support for labels to distinguish payments to different derived
  addresses and identify change. The implementation builds on libsecp256k1's
  silent-payments module (see [Newsletter #415][news415 silent]). However, this
  PR does not yet enable sending or receiving silent payments through the
  wallet's RPCs or GUI. {% assign timestamp="56:45" %}

- [Bitcoin Core #36312][] fixes a privacy leak in the experimental, opt-in
  private transaction broadcasting feature (see [Newsletter #388][news388
  private broadcast]). Previously, [discouraging a misbehaving peer][news106
  discouragement] could disconnect both regular and private broadcast
  connections to the same address. A malicious peer could deliberately trigger
  these disconnections to link a private broadcast connection to the node's
  regular connections, weakening [transaction origin privacy][topic transaction
  origin privacy]. Now, misbehaving private broadcast peers are disconnected
  without discouraging their addresses, and discouraging regular peers leaves
  private broadcast connections to the same addresses intact. {% assign timestamp="58:51" %}

- [Bitcoin Core #36284][] fixes a bug where the wallet could reject a payment
  despite having enough eligible funds when partial-spend avoidance is enabled
  via the `-avoidpartialspends` option (see [Newsletter #6][news6 avoidpartial])
  or the wallet's `avoid_reuse` flag (see [Newsletter #52][news52 avoid reuse]). Partial-spend avoidance groups
  together outputs paid to the same address during [coin selection][topic coin
  selection] to reduce [output linking][topic output linking]. Previously, if a
  group failed eligibility checks (e.g. the limit on unconfirmed ancestors),
  its value was subtracted twice from the amount available for selection. Now,
  each rejected group's value is subtracted only once. {% assign timestamp="1:01:59" %}

- [Bitcoin Core #35752][] fixes error handling when encrypting a wallet,
  changing its encryption passphrase, or adding private keys. Previously, a
  failed database write could cause a passphrase change to appear successful,
  but only the old passphrase would work after reloading the wallet. The
  encryption process could also report success despite missing required key
  records or leaving plaintext private keys in the database, while a failed
  database commit could terminate Bitcoin Core. Failed private-key insertions
  could leave keys only in memory, causing them to disappear from the wallet
  upon reloading. Now, the wallet checks database operations, rolls back failed
  encryption updates, and only updates its in-memory keys after the
  corresponding writes succeed, allowing failed operations to be retried. The
  PR also prevents a failed passphrase change from leaving a previously locked
  wallet unlocked and reports database or encryption failures separately from
  incorrect passphrase errors. {% assign timestamp="1:07:47" %}

- [Bitcoin Core #35813][] adds a `listrawtransactions` wallet RPC that can list
  every transaction known to the wallet, returning one entry per transaction
  with its raw transaction hex. The existing `listtransactions` RPC returns
  accounting entries: a self-transfer to a receiving address can appear as both
  a send and a receive, while a transfer entirely to change addresses can be
  omitted. The `count` and `skip` parameters provide pagination, and `verbose`
  adds decoded transaction details. {% assign timestamp="1:11:46" %}

- [BIPs #2276][] and [#2277][bips #2277] correct [PSBT][topic psbt]
  finalization rules that could discard information needed for later signing or
  transaction extraction. The first removes [BIP376][]'s requirement to delete
  `PSBT_IN_WITNESS_UTXO` when finalizing a [silent-payment][topic silent
  payments] input (see [Newsletter #401][news401 bip376]). Other
  [taproot][topic taproot] inputs in the same transaction may still require
  that spent output's amount and script to compute their signatures. The second
  updates [BIP370][] to retain previous output identifiers, sequence numbers,
  and required [locktimes][topic timelocks] after a PSBTv2 input is finalized.
  Deleting these fields could invalidate the PSBT or alter the extracted
  transaction. It also removes an erroneous [BIP371][] instruction to delete
  output taproot derivation data during input finalization. {% assign timestamp="1:13:07" %}

- [LDK #4993][] fixes a bug that could cause a wallet to spend reserved inputs
  in a transaction conflicting with an unconfirmed [splice][topic splicing].
  Previously, if LDK rejected an [RBF][topic rbf] fee-bump contribution because
  the channel had already been force-closed, it could instruct the wallet to
  release inputs still needed by the original splice. Across successive
  fee-bump attempts, the wallet could also receive duplicate release
  instructions or keep reservations after they were no longer needed. Now, each
  funding contribution records which inputs and outputs it inherited from
  earlier attempts, so failure tells the wallet to release only that
  contribution's own reservations. The PR also adds error information and
  reservation queries to help applications retry failed contributions safely. {% assign timestamp="1:16:39" %}

- [LND #11173][] fixes a bug where an invalid or oversized channel range
  response could stall the initial sync of [channel announcements][topic
  channel announcements] until the next scheduled attempt. LND limits responses
  to a total of 100,000 short channel IDs (SCIDs) per query (see [Newsletter
  #417][news417 scids]). Now, when another eligible peer is available, LND
  immediately retries synchronization with it and temporarily excludes the
  failed peer from selection. The existing connection to the failed peer remains
  open. {% assign timestamp="1:19:40" %}

- [LND #11190][] updates LND to reject [BOLT11][] invoices containing multiple
  payment hash (`p`) fields, even when the hashes are identical. Previously,
  LND used the first supported payment hash and ignored the rest, as
  recommended by the BOLT11 spec. However, other invoice parsers may choose a
  different hash. If a service's invoice parser and Lightning node use
  different hashes, the service could misinterpret a completed withdrawal as
  unpaid, which could result in two payments being made. Rejecting duplicates
  removes that ambiguity. BOLT11 already requires invoice creators to include
  exactly one `p` field; [BOLTs #1357][] proposes requiring readers to reject
  duplicates. {% assign timestamp="1:22:12" %}

- [LND #11212][] removes support for opening or accepting new channels using
  the legacy commitment format, aligning with [BOLT2][] (see [Newsletter
  #305][news305 commitments]). Legacy commitments derive the key for the output
  paying the counterparty (`to_remote`) using a per-commitment point. If a node
  loses its channel state, recovering funds from its peer's commitment
  transaction therefore requires that peer to supply the missing point. Static
  remote key channels keep this output key unchanged across channel updates,
  avoiding that dependency (see [Newsletter #67][news67 static remote key]).
  Existing legacy channels remain usable. Eclair made the same change last year (see [Newsletter #378][news378 eclair legacy]). {% assign timestamp="1:27:37" %}

- [LND #11258][] fixes a bug where forwarded [HTLCs][topic htlc] could remain
  unresolved if LND restarted after the outgoing channel was closed and its
  records cleaned up. Previously, channel cleanup could delete a received
  settlement or failure response before it was locked into the incoming
  channel. This could leave the incoming HTLC stuck, resulting in an
  unnecessary force close of the incoming channel and additional onchain fees.
  Now, LND saves pending responses separately from the closed channel, retains
  the information needed to match them to incoming HTLCs, and replays them on
  startup. {% assign timestamp="1:29:58" %}

{% include snippets/recap-ad.md when="2026-10-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3264,29278,35984,35301,36312,36284,35752,35813,11173,11190,1357,11212,11258,2276,2277,4993" %}

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
[LND v0.21.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.4-beta.rc1
[LND v0.20.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.5-beta.rc1
[news54 maxtxfee]: /en/newsletters/2019/07/10/#bitcoin-core-16257
[news207 single]: /en/newsletters/2022/07/06/#rust-bitcoin-1024
[news388 private broadcast]: /en/newsletters/2026/01/16/#bitcoin-core-29415
[news106 discouragement]: /en/newsletters/2020/07/15/#bitcoin-core-19219
[news6 avoidpartial]: /en/newsletters/2018/07/31/#bitcoin-core-12257
[news52 avoid reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
[news305 commitments]: /en/newsletters/2024/05/31/#bolts-1092
[news378 eclair legacy]: /en/newsletters/2025/10/31/#eclair-3173
[news67 static remote key]: /en/newsletters/2019/10/09/#lnd-3365
[news415 silent]: /en/newsletters/2026/07/24/#libsecp256k1-1765
[news417 scids]: /en/newsletters/2026/08/07/#lnd-10992
[LDK #4993]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/4993
[news401 bip376]: /en/newsletters/2026/04/17/#bips-2089
