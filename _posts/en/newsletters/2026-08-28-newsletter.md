---
title: 'Bitcoin Optech Newsletter #420'
permalink: /en/newsletters/2026/08/28/
name: 2026-08-28-newsletter
slug: 2026-08-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter relays advance notice of a planned Core Lightning
security release, summarizes a discussion about opt-in replay protection for
potential future forks, notes that the Hardware Wallet Interface (HWI) project
will enter maintenance mode, and describes a request for comments on using
block-range filters. Also included are our regular sections announcing new
releases and release candidates and describing notable changes to popular
Bitcoin infrastructure software.

## Action items

## News

- **Discussion on universal opt-in replay protection**: Moonsettler
  [posted][replay del] to Delving Bitcoin to discuss the possibility
  of introducing an opt-in replay protection mechanism in case of future
  forks. The idea followed recent events in which a minority chain was subject
  to replay attacks, a type of attack in which a valid signed transaction on one
  chain of a fork is rebroadcast on the other, unintentionally spending the
  equivalent coins on both networks. The author proposes to use the [taproot
  annex][topic annex]
  by committing a 34-byte payload that includes the previous block
  hash (i.e. `<0xFAF0><32-byte-prior-block-hash>`).

  Discussion followed with Anthony Towns proposing to use the block height
  and a hash suffix of the block instead, so as to reduce the amount of
  data to 6 bytes. Moonsettler agreed on the approach and added that it
  would be valuable for nodes to annotate UTXOs with the block commitment
  to provide that information to users. The author also proposed a limit on new
  commitment depth, ideally the `assumevalid` height, and for nodes to keep
  track of the commitment for up to `100` blocks. Moreover, Towns proposed
  to add a mechanism similar to a maturity constraint by setting an explicit
  `nLocktime` to prevent a transaction from being mined before a certain number
  of blocks to account for block reorgs.

- **HWI repository to enter maintenance mode**: Ava Chow (achow101)
  [announced][hwi future] that the [Hardware Wallet Interface (HWI)][topic hwi]
  project will scale back to maintenance-only work and eventually be archived.
  HWI, which lets [Bitcoin Core][bitcoin core repo] and other software
  communicate with hardware signing devices, has been developed almost entirely
  by one person and has received little new development for several years. Chow
  said it achieved most of its original aim of bringing hardware wallet support
  to Bitcoin Core, but that its Python codebase has held it back from the goal,
  since it cannot be [reproducibly built][topic reproducible builds] and bundled
  with Bitcoin Core.

  Before entering maintenance mode, the project will finish its in-progress
  [MuSig2][topic musig] support and issue what is expected to be its last
  release. It will stop taking new features and support for additional devices,
  aside from MuSig2. Chow named [BHWI][bhwi], a work-in-progress Rust
  implementation from Wizardsardine, as a potential replacement.

- **Request for comments on using block-range filters**: Output [posted][rfc del]
  to Delving Bitcoin a request for comments (RFC) on a proposal to use
  block-range filters to reduce the total download size
  when using [compact block filters][topic compact block filters]. Instead of
  downloading all the individual block filters, filters for ranges of blocks could
  be created. If a script is found inside one of those ranges, the individual block
  filters are downloaded and the process works as described in [BIP157][]. Although
  both range and block filters are downloaded for matching ranges, savings in size
  are obtained by avoiding downloading all the block filters in the other ranges.

  Preliminary results seem promising. The author ran simulations using different
  range sizes on simulated data of around 30k blocks. Two different sets of scripts
  were used, one with a very low transaction count (4-6 transactions) and one with
  a higher one (20-30 transactions). The total block-range filter size decreases as
  the range increases. However, most of the savings are canceled when increasing the
  range too much. According to the author, the best trade-off seems to be found at
  256-block range which reduced the total download size by about 70–80% for the tested sets of scripts.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BTCPay Server 2.4.3][] is a security release of this self-hosted payment
  processor. Users are encouraged to upgrade, especially if their servers are
  shared by multiple users.

- [Eclair 0.14.2][] is a security release for this LN node implementation. It
  fixes payment failure and channel handling bugs (see [Newsletter
  #418][news418 eclair fixes]), missing channel reserve checks (see [Newsletter
  #419][news419 eclair reserves]), and [on-the-fly][topic jit channels] funding
  issues (see [Newsletter #419][news419 eclair funding]). It also limits
  resources consumed by [gossip queries][topic channel announcements] (see
  [Newsletter #419][news419 eclair gossip]) and pending incoming connections,
  and includes [onion message][topic onion messages] and Tor configuration
  changes. Upgrading is strongly recommended because malicious nodes could
  exploit some of the fixed bugs. Operators should run `bitcoind` on the same
  machine as Eclair or connect through an encrypted, authenticated tunnel, and
  review the [release notes][eclair 0.14.2 notes] for configuration changes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #34075][] incorporates a mempool-based [fee rate
  estimator][topic fee estimation] next to the existing confirmation-based
  block-policy estimator. The new estimator uses the [chunk fee rates][topic
  cluster mempool] in the middle and at the last quartile of the next block for
  conservative and economical estimates, respectively. If there are too few
  transactions waiting for confirmation, it falls back to higher of the minimum
  relay feerate and the mempool minimum feerate. By default, `estimatesmartfee`
  now returns the lower of the mempool and block-policy estimates, so mempool
  conditions can lower fee rate estimates but not raise them. The new
  `fee_rate_estimator` option can be used to get estimates based on just one of
  the approaches.

- [Bitcoin Core #35730][] adds a `-rpcmaxconnections` configuration option
  (default 16), which limits the number of clients that can simultaneously
  connect to its HTTP server (see [Newsletter #411][news411 http]). Once the
  limit is reached, additional connections remain in the operating system's
  socket queue without consuming application memory until a slot becomes
  available. Bitcoin Core can now limit and track the file descriptor usage of
  these connections, addressing a longstanding issue in which heavy RPC usage
  could exhaust the available file descriptors, causing unrelated operations to
  fail. This change also improves connection handling by accepting all queued
  connections up to the limit during each I/O loop iteration, instead of
  accepting only one connection per iteration.

- [Bitcoin Core #35580][] fixes a block template construction bug that
  compared a transaction chunk's sigops-adjusted weight (see [Newsletter
  #416][news416 sigops]), rather than its actual [BIP141][] weight, against the
  maximum block weight. The sigops-adjusted weight ranks chunks by effective
  feerate, while block validity separately constrains actual weight and sigop
  cost. Therefore, the previous behavior could have incorrectly excluded a
  sigop-dense, high-fee-rate chunk even when it satisfied both limits, thereby
  reducing mining revenue.

- [Bitcoin Core #35665][], [#36025][bitcoin core #36025], and [#35516][bitcoin
  core #35516] fix several issues when combining or joining [PSBTs][topic
  psbt]. The first fix addresses an issue when merging two global xpub records.
  Previously, Bitcoin Core grouped records by key origin (fingerprint and
  derivation path), even though PSBT serialization identifies them by xpub.
  This resulted in the same xpub with conflicting origins being serialized as
  duplicate keys, creating an invalid PSBT that the `decodepsbt` RPC rejects.
  The second PR fixes the analogous mismatch for [tapscript][topic tapscript]
  records, which are grouped by leaf script internally but serialized by
  control block. Previously, the merge could create duplicate keys when one
  control block was associated with different scripts, or it could discard
  valid control blocks for the same script. The third PR resolves the issue of
  the `joinpsbts` RPC dropping the global xpub and metadata records by
  shuffling the merged PSBT in place rather than constructing a separate
  shuffled PSBT that omits some global metadata.

- [Bitcoin Core #35933][] and [#34697][bitcoin core #34697] fix several
  [MuSig2][topic musig] [PSBT][topic psbt] processing and [descriptor][topic
  descriptors] issues. The first PR prevents invalid or inconsistent MuSig2
  derivation metadata from causing the `analyzepsbt`, `finalizepsbt`, and
  `descriptorprocesspsbt` RPCs to abort. Hardened public derivation now fails
  normally while a mismatched aggregate key is skipped so that another matching
  key can be tried. The second PR improves the detection of duplicate keys in
  descriptors by using the available private-key information to compare key
  expressions with hardened derivation during descriptor parsing. Previously,
  different expressions could both fail to resolve and be falsely treated as
  duplicates, which would reject valid `musig()` descriptors that reuse the
  same participants with different derivation paths. It also prevents a reused
  MuSig2 participant's key origin from being prepended twice to [taproot][topic
  taproot] derivation metadata stored in a PSBT.

- [Core Lightning #9374][] fixes a channel state error that could occur when
  an earlier [RBF][topic rbf] attempt for a [dual-funded][topic dual funding]
  channel confirmed instead of the latest attempt (see [Newsletter
  #418][news418 eclair] for a similar bug on Eclair). Previously, if the peer
  reconnected while Core Lightning was still catching up with the blockchain,
  it could assume that the latest RBF attempt was the one that confirmed and
  lock the channel to an unconfirmed funding transaction. Now, Core Lightning
  records the funding attempt that actually confirmed as soon as its block is
  processed and uses that attempt when reestablishing the channel.

- [Eclair #3342][] implements the `option_onion_messages_only_channels`
  feature bit specified in [BOLTs #1343][] (see [Newsletter #416][news416
  onion]). When configured to relay [onion messages][topic onion messages] only
  for peers with channels, Eclair now advertises this feature bit. When
  relaying for all peers, Eclair advertises the `option_onion_messages` feature
  bit.

- [Eclair #3321][] implements support for the optional `fulfillment_payload`
  field added to the `update_fulfill_htlc` message as specified by [BOLTs
  #1344][], extending [attributable failures][topic attributable failures] to
  successful payments (see [Newsletter #416][news416 fulfillment]). Eclair can
  relay fulfillment payloads and authenticate them as part of the attribution
  data, and can decrypt them when it is the payer, but does not yet originate
  them when it is the payment recipient. The PR reports interoperability with
  LDK, which previously added attribution data to the successful-payment path
  (see [Newsletter #364][news364 ldk attribution]).

- [LND #11008][] fixes a deadlock issue in LND's [PSBT][topic psbt]
  channel-opening flow. Previously, if PSBT funding verification and cleanup
  for a canceled channel reservation ran at the same time, each operation could
  wait on resources held by the other. This could cause LND's single
  reservation handler to get stuck, preventing the node from opening or
  accepting channels and leaving newly funded channels stuck until a restart.
  The fix changes the order in which the shared state is accessed, preventing
  the two operations from blocking each other indefinitely.

- [HWI #841][] extends the `displayaddress` command to display on a hardware
  device an address for a registered [BIP388][] wallet [descriptor][topic
  descriptors] policy, selected by address index and receive or change branch.
  The command accepts the registration information returned by the
  `registerdescriptor` command and adds support for BitBox02, Coldcard, Jade,
  and Ledger devices, building on the descriptor registration support described
  in [Newsletter #419][news419 hwi].

- [HWI #849][] updates Coldcard support to display single-signature
  [taproot][topic taproot] addresses on Coldcard Edge devices. It also
  preserves PSBTv2 format when signing with Coldcard firmware that supports it,
  instead of always converting the PSBT to version 0. The PR adds Coldcard Edge
  simulator coverage, restores single-signature transaction signing tests, and
  updates the tested Coldcard firmware to version 5.6.0.

- [Rust Bitcoin #6755][] fixes segwit v0 signature verification for
  transactions using nonstandard but consensus-valid ECDSA signature hash
  (sighash) values. Previously, `EcdsaSighashType` mapped those values to
  standard sighash types with equivalent `ALL`, `NONE`, `SINGLE`, and
  `ANYONECANPAY` behavior, losing the original value. Because the exact value
  is also included in the segwit v0 signature hash, this could cause Rust
  Bitcoin to compute the wrong sighash and fail to verify signatures from
  transactions that are consensus-valid and already confirmed. The new
  representation preserves the original value, while callers that require
  standard sighash types can continue using `from_standard` (see [Newsletter
  #138][news138 sighash]).

{% include snippets/recap-ad.md when="2026-09-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34075,35730,35580,35665,36025,35516,35933,34697,9374,3342,1343,3321,1344,11008,841,849,6755" %}

[replay del]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792
[hwi future]: https://github.com/bitcoin-core/HWI/issues/850
[bhwi]: https://github.com/wizardsardine/bhwi
[BTCPay Server 2.4.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.3
[Eclair 0.14.2]: https://github.com/ACINQ/eclair/releases/tag/v0.14.2
[eclair 0.14.2 notes]: https://github.com/ACINQ/eclair/blob/v0.14.2/docs/release-notes/eclair-v0.14.2.md
[news295 fee]: /en/newsletters/2024/03/27/#mempool-based-feerate-estimation
[news349 fee]: /en/newsletters/2025/04/11/#bitcoin-core-pr-review-club
[news411 http]: /en/newsletters/2026/06/26/#bitcoin-core-35182
[news416 sigops]: /en/newsletters/2026/07/31/#bitcoin-core-32800
[news418 eclair]: /en/newsletters/2026/08/14/#eclair-3346
[news416 onion]: /en/newsletters/2026/07/31/#bolts-1343
[news416 fulfillment]: /en/newsletters/2026/07/31/#bolts-1344
[news419 hwi]: /en/newsletters/2026/08/21/#hwi-842
[news364 ldk attribution]: /en/newsletters/2025/07/25/#ldk-3801
[news138 sighash]: /en/newsletters/2021/03/03/#rust-bitcoin-573
[news418 eclair fixes]: /en/newsletters/2026/08/14/#eclair-3346
[news419 eclair reserves]: /en/newsletters/2026/08/21/#eclair-3352
[news419 eclair funding]: /en/newsletters/2026/08/21/#eclair-3351
[news419 eclair gossip]: /en/newsletters/2026/08/21/#eclair-3345
[rfc del]: https://delvingbitcoin.org/t/rfc-block-range-filters-a-k-a-hierarchical-filters/2735