---
title: 'Bitcoin Optech Newsletter #316'
permalink: /en/newsletters/2024/08/16/
name: 2024-08-16-newsletter
slug: 2024-08-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new time warp that's particularly
consequential for the new testnet4, summarizes discussion about proposed
mitigations for onion message denial-of-service concerns, seeks feedback
on a proposal to allow LN payers to optionally identify themselves, and
announces a major change to Bitcoin Core's build system that could
affect downstream developers and integrators.  Also included are our
regular sections announcing new releases and release candidates and
describing notable changes to popular Bitcoin infrastructure software.

## News

<!-- Note: confirmed via email that "Zawy" is how this person would like be attributed.  -harding -->

- **New time warp vulnerability in testnet4:** Mark "Murch"
  Erhardt [posted][erhardt warp] to Delving Bitcoin to describe an
  attack [discovered][zawy comment] by developer Zawy for exploiting
  [testnet4][topic testnet]'s new difficulty adjustment algorithm.
  Testnet4 applied a solution from the [consensus cleanup][topic
  consensus cleanup] soft fork for mainnet that is intended to block the
  [time warp attack][topic time warp].  However, Zawy described an
  attack similar to time warp that could be used even with the new rule
  to reduce mining difficulty to 1/16th its normal value.  Erhardt
  extended Zawy's attack to allow reducing difficulty to its minimum
  value.  We describe several related attacks in simplified form below:

  Bitcoin blocks are produced stochastically, with the difficulty
  intended to _retarget_ every 2,016 blocks to keep the average time
  between blocks at about 10 minutes.  The following simplified
  illustration shows what is supposed to happen with a constant rate of
  block production, given a retarget every 5 blocks (reduced from every
  2,016 blocks to make the illustration legible):

  ![Illustration of honest mining with a constant hashrate (simplified)](/img/posts/2024-time-warp/reg-blocks.png)

  A dishonest miner (or cabal of miners) possessing slightly more than 50%
  of hashrate can censor blocks produced by the other slightly-less-than
  50% of honest miners.  That would naturally lead initially to only one
  block being produced every 20 minutes on average.  After 2,016 blocks
  are produced using this pattern, difficulty will adjust to 1/2 its
  original value to return the rate of blocks being added to the
  mainchain to one block every 10 minutes on average:

  ![Illustration of block censorship by an attacker with slightly more than 50% of total network hashrate (simplified)](/img/posts/2024-time-warp/50p-attack.png)

  A time warp attack occurs when the dishonest miners use their hashrate
  majority to force the timestamps in most blocks to use the minimum
  allowed value.  At the end of each 2,016-block retarget period, they
  increase block header time to the current [wall time][] to make it
  seem like it took longer to produce the blocks than it actually did,
  leading to a lower difficulty in the subsequent period.

  <!-- TODO:harding can probably integrate the illustration below into
  the time warp topic page -->

  ![Illustration of a classic time warp attack (simplified)](/img/posts/2024-time-warp/classic-time-warp.png)

  The [new rule][testnet4 rule] applied to testnet4 fixes this by
  preventing the first block in a new retarget period from having a
  timestamp much earlier than its previous block (the last block in the
  previous period).

  Like the original time warp attack, Erhardt's version of Zawy's attack
  increments most block's header time by the bare minimum.  However, for
  two of every three retarget periods, it jumps forward the time for
  the final block in a period and the first block in the subsequent
  period.  This decreases difficulty by the maximum allowed each period
  (1/4th the current value).  For the third period, it uses the lowest
  time allowed for all blocks, plus the first block of the subsequent
  period, which increases difficulty by the maximum value (4x).  In
  other words, difficulty decreases 1/4, decreases again to 1/16, and
  then increases to 1/4 of its original value:

  ![Illustration of Erhardt's version of Zawy's new time warp attack (simplified)](/img/posts/2024-time-warp/new-time-warp.png)

  The three-period cycle can be repeated indefinitely to reduce
  difficulty by 1/4 each cycle, eventually reducing it to a level that
  allows miners to produce up to [6 blocks per second][erhardt se].

  To reduce difficulty by 1/4 in a retarget period, the attacking miners
  need to set the time of the retarget blocks to 8 weeks further in the
  future than the block at the start of the current period.  To do this
  twice in a row at the start of the attack requires eventually setting
  some block's time 16 weeks into the future.  Full nodes will not
  accept blocks more than two hours into the future, preventing the
  malicious blocks from being accepted for 8 weeks for the first set of
  blocks and 16 weeks for the second set of blocks.  While the attacking
  miners wait for their blocks to be accepted, they can create
  additional blocks at ever lower difficulties.  Any blocks created by
  honest miners during the 16 weeks that attackers are preparing their
  attack will be reorganized out of the chain when full nodes begin
  accepting the attacker blocks; this could mark every transaction
  confirmed during that time as either unconfirmed or invalid
  (_conflicted_) on the current chain.

  Erhardt suggests solving the attack with a soft fork that requires
  the timestamp of the last block in a retarget period be greater than
  the timestamp of the first block in that period.  Zawy proposed
  several solutions, including forbidding block timestamps from
  decreasing (which could create problems if some miners create blocks near
  the two-hour future limit enforced by nodes), or at least forbidding
  them from decreasing by more than about two hours.

  Overall, on mainnet, the new time warp attack is similar to the
  original attack in its requirements for mining equipment, its ability
  to be detected in advance, its consequences for users, and the
  relative simplicity of a soft fork to fix it.  It depends on an
  attacker maintaining control over at least 50% of hashrate for
  at least a month, while likely signaling to users that an
  attack was impending and hoping they don't respond, which could be
  quite challenging on mainnet.  As Zawy [notes][zawy testnet risk], the
  attack is much easier on testnet: a small amount of modern mining
  equipment is enough to achieve 50% of hashrate on testnet and set up
  the attack in stealth.  An attacker could then, in theory, produce
  over 500,000 blocks per day.  Only someone willing to dedicate a
  greater amount of hashrate to testnet could stop an attacker unless
  the attack is prevented using a soft fork.

  At the time of writing, the tradeoffs between proposed solutions were
  being discussed. {% assign timestamp="1:05" %}

- **Onion message DoS risk discussion:** Gijs van Dam [posted][vandam
  onion] to Delving Bitcoin to discuss a recent [paper][bk onion] by
  researchers Amin Bashiri and Majid Khabbazian about [onion
  messages][topic onion messages].  The researchers note each onion
  message can be forwarded across many nodes (481 hops by
  Van Dam's calculations), potentially wasting bandwidth for all of
  those nodes.  They describe several methods for reducing the risk
  of bandwidth abuse, including a clever method of requiring an
  exponentially increasing amount of PoW for each additional hop, making
  short routes computationally cheap but long routes expensive.

  Matt Corallo suggested first trying a previously proposed idea (see
  [Newsletter #207][news207 onion]) to provide back pressure on nodes
  sending too many onion messages before working on anything more
  complicated. {% assign timestamp="14:20" %}

- **Optional identification and authentication of LN payers:** Bastien
  Teinturier [posted][teinturier auth] to Delving Bitcoin to propose
  methods for allowing spenders to optionally include extra data with
  their payments that would allow receivers to identify those payments
  as having come from a known contact.  For example, if Alice generates
  an [offer][topic offers] that Bob pays, she may want
  cryptographic proof that the payment came from Bob and not from some
  third party pretending to be Bob.  Offers are designed by default to
  hide the identities of the spender and receiver, so additional
  mechanisms are required to enable opt-in identification and
  authentication.

  Teinturier starts by describing an opt-in _contact key_ distribution
  mechanism that Bob can use to disclose a public key of his to Alice.
  He then describes three potential candidates for an additional opt-in
  mechanism that Bob can use to sign his payments to Alice.  If Bob uses
  that mechanism, Alice's LN wallet can authenticate that
  signature as belonging to Bob and display that information to her.
  In unauthenticated payments, fields set by the spender (such as the
  free-form `payer_note` field) can be marked as untrusted to discourage
  users from relying on information provided in them.

  Feedback on which cryptographic methods to use is requested, with
  Teinturier planning to release [BLIP42][blips #42] with a
  specification for the methods selected. {% assign timestamp="28:04" %}

- **Bitcoin Core switch to CMake build system:** Cory Fields
  [posted][fields cmake] to the Bitcoin-Dev mailing list to announce
  Bitcoin Core's impending switch from the GNU autotools build system to
  the CMake build system, which has been led by Hennadii Stepanov with
  contributions from Michael Ford for bug fixes and modernization, with
  reviews and contributions from several other developers (including
  Fields).  This should not affect anyone who uses the pre-built
  binaries available from BitcoinCore.org---which is what we expect most
  people are using.  However, developers and integrators who build their own
  binaries for testing or customization may be affected---especially
  those working on uncommon platforms or build configurations.

  Fields's email provides answers to anticipated questions and asks
  anyone who builds Bitcoin Core themselves to test [PR #30454][bitcoin
  core #30454] and report any issues.  That PR is expected to be merged
  in the next several weeks with anticipated release in version 29
  (anticipated about 7 months from now).  The earlier you test, the more
  time Bitcoin Core developers will have to fix problems before the
  release of version 29---increasing the chance that they can prevent
  problems in the released code from affecting your configuration. {% assign timestamp="36:15" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.1][] is a release candidate for this library for
  building wallets and other Bitcoin-enabled applications.  The original
  `bdk` Rust crate has been renamed to `bdk_wallet` and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.
  The `bdk_wallet` crate "is the first version to offer a stable 1.0.0 API." {% assign timestamp="53:55" %}

- [Core Lightning 24.08rc2][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="54:10" %}

- [LND v0.18.3-beta.rc1][] is a release candidate for a minor bug fix
  release of this popular LN node implementation. {% assign timestamp="54:29" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29519][] resets the `pindexLastCommonBlock` value after an
  [assumeUTXO][topic assumeutxo] snapshot is loaded, so that a node prioritizes
  downloading blocks after the most recent block in the snapshot. This fixes a
  bug where a node would set `pindexLastCommonBlock` from existing peers before
  loading the snapshot and start downloading blocks from that much-older block.
  Although older blocks still need to be downloaded for assumeUTXO's
  background validation, newer blocks should receive priority so that
  users can see whether their recent transactions have been confirmed. {% assign timestamp="55:01" %}

- [Bitcoin Core #30598][] removes block height from the [assumeUTXO][topic
  assumeutxo] snapshot file metadata as it is not a unique identifier in a
  pre-sanitized untrusted file compared to the block hash that is kept. A node
  can still obtain block height from many other internal sources. {% assign timestamp="59:29" %}

- [Bitcoin Core #28280][] optimizes Initial Block Download (IBD) performance for
  pruned nodes by not emptying the UTXO cache during pruning flushes. It does
  this by separately tracking "dirty" cache entries---entries that have changed since they
  were last written to the database. This allows a node to avoid
  unnecessarily scanning the entire cache during prune flushes and instead focus
  on the dirty entries.  The optimization results in up to 32% faster IBD for
  pruned nodes with high `dbcache` settings, and about 9% improvement with
  default settings. See Newsletter [#304][news304 cache]. {% assign timestamp="1:02:18" %}

- [Bitcoin Core #28052][] adds [XOR][] encoding to `blocksdir *.dat` files on
  creation as a preventative mechanism against unintentional and accidental data
  corruption by anti-virus or similar software. This can be
  optionally disabled and doesn't protect against intentional data corruption
  attacks. This was implemented for the `chainstate` files in [Bitcoin Core
  #6650][] in September 2015 and the mempool in [#28207][bitcoin core
  #28207] in November 2023 (see [Newsletter #277][news277 bcc28207]). {% assign timestamp="1:04:47" %}

- [Core Lightning #7528][] adjusts the [fee rate estimation][topic fee
  estimation] for sweeps of non-time-sensitive unilateral channel closures to an
  absolute deadline of 2016 blocks (approximately 2 weeks). Previously, the fee
  rate was set to target confirmation within 300 blocks, which sometimes caused
  transactions to be stuck at the [minimum relay fee limit][topic default
  minimum transaction relay feerates], resulting in indefinite delays. {% assign timestamp="1:08:01" %}

- [Core Lightning #7533][] updates the internal coin movement notifications and
  the transaction bookkeeper to properly account for the spending of funding
  outputs for [splicing][topic splicing] transactions. Previously, there was no
  logging or tracking of this. {% assign timestamp="1:10:11" %}

- [Core Lightning #7517][] introduces `askrene`, a new experimental plugin and
  API infrastructure for minimum-cost pathfinding based on the `renepay` plugin
  (See Newsletter [#263][news263 renepay]) for an improved implementation of
  Pickhart Payments. The `getroutes` RPC command allows the specification of
  persistent channel capacity data and transient information such as [blinded
  paths][topic rv routing] or route hints, and returns a set of possible routes
  along with their estimated probability of success. Several other RPC commands
  are added to manage routing data in layers by adding channels, manipulating
  channel data, excluding nodes from routing, inspecting layer data, and
  managing ongoing payment attempts. {% assign timestamp="1:11:19" %}

- [LND #8955][] adds an optional `utxo` field on the `sendcoins` command (and
  `Outpoints` for the corresponding `SendCoinsRequest` RPC command) to simplify
  the [coin selection][topic coin selection] user experience to a single step.
  Previously, a user had to go through a multi-step command process that
  included coin selection, fee estimation, [PSBT][topic psbt] funding, PSBT
  completion, and transaction broadcasting. {% assign timestamp="1:13:08" %}

- [LND #8886][] updates the `BuildRoute` function to support [inbound forwarding
  fees][topic inbound forwarding fees] by reversing the pathfinding process, now
  working from receiver to sender, allowing for more accurate fee calculations
  over multiple hops. See Newsletter [#297][news297 inboundfees] for more on
  inbound fees. {% assign timestamp="1:14:39" %}

- [LND #8967][] adds a new wire message type `Stfu` (SomeThing Fundamental is
  Underway) designed to lock the channel state before initiating [protocol
  upgrades][topic channel commitment upgrades]. The `Stfu` message type includes
  fields for the channel id, an initiator flag, and additional data for
  potential future extensions. This is part of the Quiescence protocol
  implementation (see Newsletter [#309][news309 quiescence]). {% assign timestamp="1:19:45" %}

- [LDK #3215][] checks that a transaction is at least 65 bytes long to protect
  against an [unlikely and costly attack][spv attack] against a light client SPV
  wallet where a valid SPV proof can be created for a fake 64-byte transaction
  by matching the hash of an inner merkle node. See [merkle tree
  vulnerabilities][topic merkle tree vulnerabilities]. {% assign timestamp="1:22:13" %}

- [BLIPs #27][] adds BLIP04 for an experimental [HTLC endorsement][topic htlc
  endorsement] signaling protocol proposal to partially mitigate [channel
  jamming attacks][topic channel jamming attacks] on the network. It outlines
  the experimental endorsement TLV values, the deployment approach, and the
  eventual deprecation of the experimental phase when HTLC endorsements are
  merged into the BOLTs. {% assign timestamp="1:26:27" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29519,30598,28280,28052,7528,7533,7517,8955,8886,8967,3215,1658,27,30454,42,6650,28207" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[erhardt se]: https://bitcoin.stackexchange.com/a/123700
[erhardt warp]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062
[zawy comment]: https://github.com/bitcoin/bitcoin/pull/29775#issuecomment-2276135560
[wall time]: https://en.wikipedia.org/wiki/Elapsed_real_time
[testnet4 rule]: https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki#time-warp-fix
[news36 warp rule]: /en/newsletters/2019/03/05/#the-time-warp-attack
[zawy testnet risk]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062/5
[vandam onion]: https://delvingbitcoin.org/t/onion-messaging-dos-threat-mitigations/1058
[bk onion]: https://fc24.ifca.ai/preproceedings/104.pdf
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[teinturier auth]: https://delvingbitcoin.org/t/bolt-12-trusted-contacts/1046
[fields cmake]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6cfd5a56-84b4-4cbc-a211-dd34b8942f77n@googlegroups.com/
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[news304 cache]: /en/newsletters/2024/05/24/#bitcoin-core-28233
[news263 renepay]: /en/newsletters/2023/08/09/#core-lightning-6376
[news309 quiescence]: /en/newsletters/2024/06/28/#bolts-869
[spv attack]: https://web.archive.org/web/20240329003521/https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[news297 inboundfees]: /en/newsletters/2024/04/10/#lnd-6703
[news277 bcc28207]: /en/newsletters/2023/11/15/#bitcoin-core-28207
[xor]: https://en.wikipedia.org/wiki/One-time_pad
