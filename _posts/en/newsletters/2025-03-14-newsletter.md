---
title: 'Bitcoin Optech Newsletter #345'
permalink: /en/newsletters/2025/03/14/
name: 2025-03-14-newsletter
slug: 2025-03-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter looks at an analysis of P2P traffic experienced
by a typical full node, summarizes research into LN pathfinding, and
describes a new approach for creating probabilistic payments.  Also
included are our regular sections summarizing a Bitcoin Core PR Review
Club meeting, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

- **P2P traffic analysis:** developer Virtu [posted][virtu traffic] to
  Delving Bitcoin an analysis of the network traffic generated and
  received by his node in four different modes: initial block download
  (IBD), non-listening (outbound connections only), non-archival (pruned) listening, and archival
  listening.  Although the results for his single node may not have been
  representative in all cases, we found several of his discoveries to be
  interesting:

  - *High block traffic as an archival listening node:* Virtu's node served
    several gigabytes of blocks each hour to other nodes when operating
    as a non-pruned listening node.  Many of the blocks were older blocks
    being requested by incoming connections so that they could perform
    IBD.

  - *High inv traffic as a non-archival listener:* about 20% of total node
    traffic was `inv` messages before he enabled serving of older
    blocks.  [Erlay][topic erlay] may significantly reduce
    that 20% overhead, which represented about 100 megabytes a day.

  - *Bulk of inbound peers appear to be spy nodes:* "Interestingly, the
    bulk of inbound peers exchange only around 1MB of traffic with my
    node, which is too low (using traffic via my outbound connections as
    baseline) for them to be regular connections. All those nodes do is
    complete the P2P handshake, and politely reply to ping messages.
    Other than that, they just suck up our `inv` messages."

  Virtu's post contains additional insights and multiple charts
  illustrating the traffic experienced by his node.

- **Research into single-path LN pathfinding:** Sindura Saraswathi
  [posted][saraswathi path] to Delving Bitcoin about [research][sk path]
  she conducted with Christian Kümmerle about finding optimal paths
  between LN nodes for sending payments in a single part.  Her post
  describes the strategies currently used by Core Lightning, Eclair,
  LDK, and LND.  The authors then use eight modified and unmodified LN
  nodes in a simulated LN network (based on a snapshot of the actual
  network) to test pathfinding, evaluating criteria such as
  highest success rate, lowest fee ratios (lowest cost), shortest total
  time lock (least bad worst-case waiting period), and shortest path
  (least likely to result in a stuck payment).  No algorithm performed
  better than the others in all cases, and Saraswathi suggests that
  implementations provide better weighting functions that allow users to
  choose the tradeoffs they prefer for different payments (e.g., you may
  prioritize a high success rate for a small in-person purchase but
  prefer a low fee ratio for paying a large monthly bill that isn't due
  for a few more weeks).  She also notes that "[although]  beyond the
  scope of this study, we note that the insights gained in this study
  are also relevant for future improvements in [multi-part
  payment][topic multipath payments] pathfinding algorithms."

- **Probabilistic payments using different hash functions as an xor function:**
  Robin Linus [replied][linus pp] to the Delving Bitcoin thread about
  [probabilistic payments][topic probabilistic payments] with a
  conceptually simple script that allows two parties to each commit to
  an arbitrary amount of entropy that can later be revealed and xored
  together, to produce a value that can be used to determine which one
  of them receives a payment.  Using (and slightly extending) Linus's
  example from the post:

  - Alice privately chooses the value `1 0 0` plus a separate nonce.
    Bob privately chooses the value `1 1 0` plus another
    separate nonce.

  - Each party successively hashes their nonce, with the numbers in
    their value determining which hash function is used.  When the value
    on the top of the stack is `0`, they use the `HASH160` opcode;
    when the value is `1`, they use the `SHA256` opcode.  In Alice's
    case, she performs `sha256(hash160(hash160(alice_nonce)))`; in Bob's
    case, he performs `sha256(sha256(hash160(bob_nonce)))`.  This
    produces a commitment for each of them, which they send to each
    other without revealing either their value or their nonce.

  - With the commitments shared, they create an onchain funding
    transaction with a script that will validate the inputs using
    `OP_IF` to choose between the different hash functions and allows
    one of them to claim the payment.  For example, if the sum of their
    two xored values is 0 or 1, Alice receives the money; if it's 2 or
    3, Bob receives it.  The contract may also have a timeout clause and
    a space-saving mutual-agreement clause.

  - After the funding transaction confirms to a suitable depth, Alice
    and Bob disclose to each other their values and their nonces.  The
    xor of `1 0 0` and `1 1 0` is `0 1 0`, which sums to `1`, allowing
    Alice to claim the payment.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Stricter internal handling of invalid blocks][review club 31405] is a
PR by [mzumsande][gh mzumsande] that improves the correctness of two
non-consensus-critical and expensive-to-calculate validation fields by
immediately updating them when a block is marked as invalid. Prior to
this PR, these updates were delayed until a later event to minimize
resource usage. However, since [Bitcoin Core #25717][], an attacker
would need to invest much more work to exploit this.

Specifically, this PR ensures that `ChainstateManager`'s `m_best_header`
always points to the most-work header not known to be valid, and that
a block's `BLOCK_FAILED_CHILD` `nStatus` is always correct.


{% include functions/details-list.md
  q0="Which purpose(s) does `ChainstateManager::m_best_header` serve?"
  a0="`m_best_header` represents the most-PoW header the node has seen
  so far which it hasn't yet invalidated but also can't guarantee to be
  valid. It has many uses, but the main one is to serve as a target to
  which the node can progress its best chain. Other use cases include
  providing an estimate of the current time, and an estimate of the best
  chain's height when requesting missing headers from a peer. A more
  complete overview can be found in the ~6-year old pull request
  [Bitcoin Core #16974][]."
  a0link="https://bitcoincore.reviews/31405#l-36"

  q1="Prior to this PR, which of these statements are true, if any?
  1) a `CBlockIndex` with an INVALID predecessor will ALWAYS have a
     `BLOCK_FAILED_CHILD` `nStatus`.
  2) a `CBlockIndex` with a VALID predecessor will NEVER have a
     `BLOCK_FAILED_CHILD` `nStatus`"
  a1="Statement 1) is false, and directly addressed in this PR. Prior to
  this PR, `AcceptBlock()` would mark an invalid block as such, but for
  performance reasons not immediately update its descendants as such.
  The Review Club attendees could not think of a scenario where
  statement 2) was false."
  a1link="https://bitcoincore.reviews/31405#l-68"

  q2="One of the goals of this PR is to ensure `m_best_header`, and the
  `nStatus` of successors of an invalid block are always correctly set.
  Which functions are directly responsible for updating these values?"
  a2="`SetBlockFailureFlags()` is responsible for updating `nStatus`. In
  normal operation, `m_best_header` is most commonly set via the
  out-parameter in `AddToBlockIndex()`, but it can also be calculated
  and set via `RecalculateBestHeader()`."
  a2link="https://bitcoincore.reviews/31405#l-110"

  q3="Most of the logic in commit `4100495` `validation: in
  invalidateblock, calculate m_best_header right away` implements
  finding the new best header. What prevents us from just using
  `RecalculateBestHeader()` here?"
  a3="`RecalculateBestHeader()` traverses the entire `m_block_index`,
  which is an expensive operation. Commit `4100495` optimizes this by
  instead caching and iterating over a set of candidates with high-PoW
  headers."
  a3link="https://bitcoincore.reviews/31405#l-114"

  q4="Would we still need the `cand_invalid_descendants` cache if we
  were able to iterate forwards (i.e. away from the genesis block) over
  the block tree? What would be the pros and cons of such an approach,
  compared to the one taken in this PR?"
  a4="If `CBlockIndex` objects held references to all their descendants,
  we wouldn't need to iterate over the entire `m_block_index` to
  invalidate descendants, and consequently wouldn't need the
  `cand_invalid_descendants` cache. However, this approach would have
  significant downsides. First, it would increase the memory footprint
  of each `CBlockIndex` object, which needs to be kept in-memory for the
  entire `m_block_index`. Second, the iteration logic would still be
  non-trivial since while each `CBlockIndex` has exactly one ancestor,
  it may have no or multiple descendants."
  a4link="https://bitcoincore.reviews/31405#l-136"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Eclair v0.12.0][] is a major release of this LN node.  It "adds
  support for creating and managing [BOLT12][] offers and a new channel
  closing protocol that supports [RBF][topic rbf].  [It] also adds
  support for storing small amounts of data for our peers" ([peer
  storage][topic peer storage]), among other improvements and bug fixes.
  The release notes mention that several major dependencies have been
  updated, requiring users to make those updates before deploying the
  new version of Eclair.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31407][] adds support for notarizing macOS application bundles
  and binaries by updating the `detached-sig-create.sh` script. The script now
  also signs standalone macOS and Windows binaries. The recently updated
  [signapple][] tool is used to perform these tasks.

- [Eclair #3027][] adds pathfinding functionality for [blinded paths][topic rv
  routing] when generating [BOLT12][topic offers] invoices by introducing the
  `routeBlindingPaths` function, which computes a path from a selected
  initiating node to the receiver node using only nodes that support blinded
  paths. The blinded path is then included in the invoice.

- [Eclair #3007][] adds a `last_funding_locked` TLV parameter in
  `channel_reestablish` messages to improve synchronization between peers during
  channel [splicing][topic splicing] after a disconnect. It fixes a race
  condition where a node sends a `channel_update` after receiving a
  `channel_reestablish` but before `splice_locked`, which is harmless for
  regular channels but could disrupt [simple taproot channels][topic simple
  taproot channels] that require nonce exchanges between peers.

- [Eclair #2976][] adds support for creating [offers][topic offers] without
  additional plugins by introducing the `createoffer` command, which takes
  optional parameters for description, amount, expiration in seconds, issuer,
  and `blindedPathsFirstNodeId` to define an initiating node for a [blinded
  path][topic rv routing]. In addition, this PR introduces the `disableoffer`
  and `listoffers` commands to manage existing offers.

- [LDK #3608][] redefines the `CLTV_CLAIM_BUFFER` to represent twice the
  expected maximum number of blocks required to confirm a transaction, adapting
  to [anchor][topic anchor outputs] channels where [HTLCs][topic htlc] claim
  transactions are delayed by an `OP_CHECKSEQUENCEVERIFY` (CSV) [timelock][topic
  timelocks] of 1 block. Previously, it was set to a single maximum confirmation
  period, which was sufficient for pre-anchor channels where HTLC claim
  transactions were broadcast alongside commitment transactions. A new
  `MAX_BLOCKS_FOR_CONF` constant is added as the base value.

- [LDK #3624][] enables funding key rotation after successful channel
  [splices][topic splicing] by applying a scalar tweak to the base funding key
  to obtain the channel's 2-of-2 [multisig][topic multisignature] key. This
  allows a node to derive additional keys from the same secret. The tweak
  computation follows the [BOLT3][] specification, but replaces
  `per_commitment_point` with the splice funding txid to ensure uniqueness, and
  uses the `revocation_basepoint` to restrict derivation to channel
  participants.

- [LDK #3016][] adds support for external projects to run functional tests and
  replace components like the signer by introducing an `xtest` macro. It
  includes a `MutGlobal` utility and a `DynSigner` struct to support dynamic
  test components like the signer, exposes these tests under the
  `_externalize_tests` feature flag, and provides a `TestSignerFactory` for
  creating dynamic signers.

- [LDK #3629][] improves logging of remote
  failures that can't be attributed or interpreted to provide more visibility
  into these edge cases. This PR modifies `onion_utils.rs` to log
  non-attributable failures that could disrupt sender operation, and introduces
  a `decrypt_failure_onion_error_packet` function for decryption handling. It
  also fixes a bug where an unreadable failure with a valid hash-based message
  authentication code (HMAC) was not properly attributed to a node.
  This may be related to allowing spenders to avoid using nodes that
  advertise [high availability][news342 qos] but fail to deliver.

- [BDK #1838][] improves the clarity of the full-scan and sync flow by adding a
  mandatory `sync_time` to `SyncRequest` and `FullScanRequest`, applying this
  `sync_time` as the `seen_at` property for unconfirmed transactions while
  allowing non-canonical (see Newsletter [#335][news335 noncanonical])
  transactions to exclude a `seen_at` timestamp. It updates `TxUpdate::seen_ats`
  to a `HashSet` of (Txid, u64) to support multiple `seen_at` timestamps per
  transaction, and changes `TxGraph` to be non-exhaustive, among other changes.

{% include snippets/recap-ad.md when="2025-03-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31407,3027,3007,2976,3608,3624,3016,3629,1838,16974,25717" %}
[virtu traffic]: https://delvingbitcoin.org/t/bitcoin-node-p2p-traffic-analysis/1490/
[saraswathi path]: https://delvingbitcoin.org/t/an-exposition-of-pathfinding-strategies-within-lightning-network-clients/1500
[sk path]: https://arxiv.org/pdf/2410.13784
[linus pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/10
[eclair v0.12.0]: https://github.com/ACINQ/eclair/releases/tag/v0.12.0
[review club 31405]: https://bitcoincore.reviews/31405
[gh mzumsande]: https://github.com/mzumsande
[signapple]: https://github.com/achow101/signapple
[news335 noncanonical]: /en/newsletters/2025/01/03/#bdk-1670
[news342 qos]: /en/newsletters/2025/02/21/#continued-discussion-about-an-ln-quality-of-service-flag
