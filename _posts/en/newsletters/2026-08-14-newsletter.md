---
title: 'Bitcoin Optech Newsletter #418'
permalink: /en/newsletters/2026/08/14/
name: 2026-08-14-newsletter
slug: 2026-08-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed contract protocol for mitigating
Lightning Network channel jamming, reports on the availability of static Bitcoin
Core binaries for testing, and summarizes a change replacing Bitcoin Core's
per-peer transaction rate-limiting with a global approach. Also included are
our regular sections announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Conditional message transfer contract to solve jamming**: Antoine Riard
  [posted][chan jam del] to Delving Bitcoin a new approach to mitigate
  [channel jamming][topic channel jamming attacks] on the Lightning Network.
  Jamming is a denial-of-service attack in which the attacker sends
  [HTLCs][topic htlc] or [PTLCs][topic PTLC] and then holds them unresolved,
  tying up the channel liquidity along a route at no cost to itself. Riard's
  proposal makes holding expensive by charging a withhold fee proportional to
  how long a payment is held, converting a currently free attack into a costly
  one.

  The mechanism is a conditional message transfer contract (CMTC) which is a
  Bitcoin Script construction that lets two channel counterparties later prove
  whether a specific message (such as a payment preimage) was exchanged between
  them by a given block height, which Riard treats as a universal clock. The
  parties agree on a temporal window and assign an adaptor point to each point
  in time within it, so the withhold fee can be settled according to when the
  message was delivered. The contract offers three settlement paths:

  - Message transfer success: the preimage is delivered from Bob to Alice
    and cryptographically acknowledged, and the two split the withhold fee based
    on delivery time.

  - Liveness challenge: if Alice is offline and cannot counter-sign, Bob can
    exit the contract and recover the locked funds minus an equilibrium penalty
    fee.

  - Message transfer failure: if Bob is offline or otherwise fails to
    transfer the message, Alice can exit and recover the withhold fee.

  Riard notes that the proposed solution needs further analysis, both of its
  cryptographic correctness and of its incentives, and that it remains open
  whether this approach, or an expansion of it, could solve other types of
  problems in Bitcoin. {% assign timestamp="33:07" %}

- **Static Bitcoin Core binaries available for testing**: Michael Ford
  (fanquake) [posted][fanquake static ml] to the Bitcoin-Dev mailing list
  announcing test builds of static Bitcoin Core release binaries produced
  using the project's existing [Guix][topic reproducible builds]
  infrastructure. Test binaries are available for `bitcoind` and the other
  command-line utilities on x86_64 and aarch64 Linux, with more platforms
  planned. The `bitcoin-qt` GUI binary is unchanged.

  Bitcoin Core's current Linux release binaries are dynamically linked, meaning
  that they contain most of the code they need but depend on the C library
  (glibc) and a few related libraries provided by the user's operating system.
  Those libraries are located and loaded each time the program starts, a
  dependency that carries some risks. The binaries only run on systems that
  provide a compatible glibc (currently version 2.31 or newer), their behavior
  can vary with the host's libraries, and some of the code the node actually
  executes falls outside the binary that reproducible builds allow users to
  verify. A static binary instead includes all of the code it needs, so the same
  verified executable runs the same way on nearly any Linux system, including
  older releases, distributions built on a different C library such as Alpine
  Linux, and minimal container images that ship no system libraries at all. The
  new binaries remain position-independent executables, preserving the ASLR
  exploit mitigation of current releases, and are only about 1 MB larger.

  The mailing list post continues years of work in [Bitcoin Core #25573][],
  which Ford opened in 2022. Progress required changes to the GCC compiler and
  to glibc itself, including fixes to glibc's name resolution code, historically
  the main hazard of statically linking glibc. Some preparatory changes to the
  Guix build process (see [Bitcoin Core #35537][]) have been merged, but the
  main PR remains open and under review. Readers who run Bitcoin Core on Linux
  are encouraged to try the [test binaries][static test bins] and report any
  problems, or successes, to the mailing list or the PR.
  {% assign timestamp="1:19" %}

- **Replacing per-peer transaction rate-limiting with global rate limits**:
  Anthony Towns [posted][peer queue del] to Delving Bitcoin announcing the merge of
  [Bitcoin Core #34628][], which replaces the per-peer transaction rate-limiting
  with a global approach.

  For each of its peers, a node keeps a queue of the transaction announcements
  it intends to send to that peer, called `m_tx_inventory_to_send`, sorts those
  announcements by ancestor feerate, and sends the best of them first. To limit
  bandwidth and to make it harder to probe the relay topology, a node announces
  no more than about 7 transactions per second to each peer. In normal times
  this rate is enough to drain the queue, but a sudden burst of transactions can
  fill it faster than the limit lets it drain. Because the node re-sorts the
  growing queue on every announcement, this can consume an excessive amount of
  CPU, a denial-of-service (DoS) vector previously described in
  [Newsletter #324][news324 dos].

  Towns' PR replaces the per-peer rate-limiting with a global rate limit, using
  two token buckets that meter total announcements by count (number of
  transactions) and by size (serialized witness size). If there is enough
  capacity, an incoming transaction is relayed immediately, otherwise it is
  added to a single global backlog sorted by feerate and [cluster
  mempool][topic cluster mempool] rules. Transactions selected from that backlog
  are then placed in a small per-peer queue used for privacy batching. Sorting
  one shared backlog instead of a separate queue per peer avoids the repeated
  per-peer sorting that made the original design a DoS vector.
  {% assign timestamp="18:44" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BTCPay Server 2.4.2][] is a security release that fixes a critical
  vulnerability affecting all releases before 2.4.2. An unauthenticated remote
  attacker could obtain an LND node's `.macaroon` credential files and use them
  to take control of the node and move funds. The project [reports][btcpay 2.4.2
  advisory] that the vulnerability was exploited and funds were stolen. BTCPay
  Server operators using LND should update to 2.4.2 and LND 0.21.1 immediately,
  audit their node for unauthorized activity, and rotate their macaroon
  credentials, since an attacker may have already obtained them. BTCPay
  Server's onchain wallets and deployments using other Lightning
  implementations are not exposed to this specific risk.
  {% assign timestamp="43:16" %}

- [LND v0.21.2-beta][] is a maintenance release of this popular LN node
  implementation. It fixes two database migration failures, bounds memory
  usage during channel graph synchronization, and fixes bugs affecting onion
  messages, RBF cooperative closes, invoice updates, [blinded][topic rv
  routing]-payment forwarding, and [HTLC][topic htlc] resolution.
  {% assign timestamp="45:45" %}

- [LND v0.20.3-beta][] is a maintenance release of LND's 0.20 release branch.
  It backports several fixes also included in 0.21.2-beta, including bounds on
  memory use during channel graph synchronization and fixes for cooperative
  closes, invoice updates, blinded-payment forwarding, and HTLC resolution.
  {% assign timestamp="45:45" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35493][] fixes a false warning that indicated private keys
  were missing when importing [MuSig2][topic musig]
  [descriptors][topic descriptors] (see [Newsletter #366][news366 musig
  descriptors]) with all the required private keys. Previously, the
  `importdescriptors` RPC checked for a corresponding private key for every
  public key produced when expanding the descriptor, including the MuSig
  aggregate key, which doesn't have a standalone private key. This could cause
  a descriptor containing all of its participants' private keys to be reported
  as incomplete. The completeness check now accounts for MuSig participant
  keys, so complete descriptors import without a warning, while those missing
  participant private keys still trigger a warning. {% assign timestamp="48:10" %}

- [Core Lightning #9150][] introduces `impressions`, a new type of liquidity
  information that records successful payments through a channel and allows
  the `askrene` RPC command (see [Newsletter #316][news316 askrene]) to adjust
  its liquidity estimates for subsequent routing attempts. Additionally, the
  `getroutes` RPC command is updated to provide more specific error messages
  when routing fails, such as when the source has insufficient funds or the
  destination has insufficient incoming capacity. Also, the PR limits invoices
  generated from [BOLT12 offers][topic offers] denominated in another currency
  to a 10-minute expiry by default to account for exchange rate fluctuations.
  {% assign timestamp="50:57" %}

- [BIPs #2248][] updates [BIP3][] to remove Luke Dashjr from the list of BIP
  editors, following [discussion][luke removal ml] on the Bitcoin-Dev mailing
  list. See [Newsletter #299][news299 bip editors] for previous coverage of the
  editor set. {% assign timestamp="54:13" %}

- [BIPs #2225][] and [#2245][bips #2245] update [BIP110][] (see [Newsletter
  #412][news412 bip110]) following its unsuccessful activation attempt.
  [#2245][bips #2245] changes its status to Closed. [#2225][bips #2225]
  makes [BIP433][]'s policy rule requiring [pay-to-anchor (P2A)][topic ephemeral
  anchors] spends to carry an empty witness stack into a consensus requirement.
  {% assign timestamp="56:07" %}

- [Eclair #3346][] fixes a crash and makes several onchain and channel-handling
  improvements. It now verifies that decrypted payment failures correspond to a
  valid intermediate position in the payment route before using them as routing
  information, preventing malformed or maliciously crafted failures from the
  recipient from triggering an out-of-bounds access that could crash the payment
  lifecycle actor. It also starts retrying onchain transaction broadcasts when
  it receives error messages from Bitcoin Core it can't classify, instead of
  potentially abandoning a time-sensitive transaction. When using
  [CPFP][topic cpfp] to fee-bump a peer's [zero-fee commitment][topic v3
  commitments], it now accounts for the full parent-and-child [package][topic
  package relay] weight instead of only the parent's weight. Finally, Eclair now
  uses the [MuSig2][topic musig] nonce associated with the funding
  [RBF][topic rbf] attempt that actually confirmed when sending `channel_ready`,
  instead of assuming that its latest RBF attempt is the one that confirmed.
  {% assign timestamp="58:50" %}

- [Eclair #3341][] prepares to relay future `channel_update` [gossip
  messages][topic channel announcements] that use currently undefined
  `message_flags` or `channel_flags` in [BOLT7][]. Previously, if Eclair
  received an update with an unknown flag bit set to one, it would discard that
  value and encode the bit as zero when forwarding the update. This modified
  the signed message and invalidated its signature. Now, Eclair preserves
  unknown flag values when decoding and re-encoding `channel_update` messages,
  allowing Eclair nodes to relay updates containing flags they don't yet
  understand. {% assign timestamp="1:02:22" %}

- [LND #11019][] fixes a data race in the legacy cooperative-close state
  machine, which could occur when the link goroutine (which tracks the
  channel's HTLC and commitment state) and the peer goroutine (which processes
  close messages from the remote peer) advance concurrently. Now, instead of
  advancing the closer itself, the link reports to the peer's channel manager
  when a channel has been flushed (pending HTLCs have been drained), ensuring
  that all close state-machine transitions run on a single goroutine. The PR
  also ensures that the RBF cooperative-close path (see [Newsletter
  #347][news347 rbf coop]) checks that the peer's delivery script is present
  and uses an accepted output type, even when no upfront shutdown script was
  negotiated (see [Newsletter #76][news76 upfront]). {% assign timestamp="1:05:18" %}

- [LND #11023][] changes `update_fee` handling to match [BOLT2][]'s
  replaceable-state model and prevent redundant uncommitted fee updates from
  growing the update log. If a newer fee update arrives before the previous one
  has been included in either party's commitment transaction, LND now replaces
  the previous fee value in place. The PR also limits channel mailboxes to
  1,000 queued messages and 4 MiB of serialized data. If a message cannot be
  accepted, LND disconnects the peer instead of dropping the message and
  processing subsequent messages out of order. This allows the ordered channel
  state to be recovered upon reconnection. {% assign timestamp="1:09:03" %}

- [Libsecp256k1 #1904][] strengthens the startup self-test for applications
  that provide their own SHA256 compression function (see [Newsletter
  #396][news396 sha256]). Previously, the self-test hashed a single 63-byte
  message, which could detect general incorrect implementations but not ones
  that failed when processing multiple blocks, unaligned input, or a SHA256
  state other than the initial one. The new test uses different message lengths
  and input alignments. It rejects a supplied compression function if its
  results differ from the expected SHA256 results, allowing faulty
  implementations to be detected during initialization rather than producing
  incorrect results later. {% assign timestamp="1:11:49" %}

- [HWI #839][] fixes several [PSBT][topic psbt] parsing and transaction
  reconstruction issues that were revealed when adding the complete [BIP174][]
  and [BIP370][] test-vector suites. When reconstructing a transaction from
  PSBTv2, HWI now applies the computed [locktime][topic timelock] instead of
  leaving it at zero and uses the specified final sequence value (0xffffffff)
  when an input omits `PSBT_IN_SEQUENCE`. For PSBTv0, [HWI][topic hwi] rejects
  v2-only input and output fields and strictly parses the global unsigned
  transaction using non-witness serialization, while correctly recognizing an
  empty unsigned transaction as present. The PR also validates that required
  height and time-based locktimes fall within their specified ranges and adds
  tests for BIP370 locktime determination. {% assign timestamp="1:13:58" %}

{% include snippets/recap-ad.md when="2026-08-18 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="25573,35537,34628,35493,9150,2248,2225,2245,3346,3341,11019,11023,1904,839" %}

[chan jam del]: https://delvingbitcoin.org/t/conditional-message-transfer-contract-to-solve-jamming/2772
[fanquake static ml]: https://groups.google.com/g/bitcoindev/c/UgGHs-_YGvw
[static test bins]: https://github.com/fanquake/bitcoin/releases/tag/static_bitcoind_ff01e5af948d
[peer queue del]: https://delvingbitcoin.org/t/transaction-rate-limiting/2744
[news324 dos]: /en/newsletters/2024/10/11/#dos-from-large-inventory-sets
[luke removal ml]: https://groups.google.com/g/bitcoindev/c/knbv3MFwlvU
[topic timelock]: /en/topics/timelocks/
[BTCPay Server 2.4.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.2
[btcpay 2.4.2 advisory]: https://blog.btcpayserver.org/security-advisory-btcpay-server-2-4-2/
[LND v0.21.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.2-beta
[LND v0.20.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.3-beta
[news366 musig descriptors]: /en/newsletters/2025/08/08/#bitcoin-core-31244
[news316 askrene]: /en/newsletters/2024/08/16/#core-lightning-7517
[news299 bip editors]: /en/newsletters/2024/04/24/#bip-editors-update
[news412 bip110]: /en/newsletters/2026/07/03/#bips-2201
[news347 rbf coop]: /en/newsletters/2025/03/28/#lnd-8453
[news76 upfront]: /en/newsletters/2019/12/11/#lnd-3655
[news396 sha256]: /en/newsletters/2026/03/13/#libsecp256k1-1777
