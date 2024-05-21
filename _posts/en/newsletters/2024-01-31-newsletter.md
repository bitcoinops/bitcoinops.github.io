---
title: 'Bitcoin Optech Newsletter #287'
permalink: /en/newsletters/2024/01/31/
name: 2024-01-31-newsletter
slug: 2024-01-31-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow replacement of v3
transactions using RBF rules to ease the transition to cluster mempool
and summarizes an argument against `OP_CHECKTEMPLATEVERIFY` based on it
commonly requiring exogenous fees.  Also included are our regular
sections summarizing top questions and answers from the Bitcoin
Stack Exchange, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

- **Kindred replace by fee:** Gloria Zhao [posted][zhao v3kindred] to
  Delving Bitcoin about allowing a transaction to replace a related
  transaction in the mempool even if there's no conflict between the two
  transactions.  Two transactions are considered to be _conflicting_
  when they cannot both exist in the same valid block chain, usually
  because they both try to spend the same UTXO---violating the rule
  against double spending.
  The rules for [RBF][topic rbf] compare a transaction in the
  mempool against a newly received transaction that conflicts with it.
  Zhao suggests an idealized way to think about a conflicts policy: if
  a relay node has two transactions but can only accept one, it should not
  choose the one that arrives first---it should choose the one that
  best suits the node operator's goals (such as maximizing miner revenue without
  allowing effectively free relay).  The RBF rules attempt to do that
  for conflicts; Zhao, in her post, extends the idea to related
  transactions rather than just conflicts.

  Bitcoin Core places _policy_ limits on the number and size of related
  transactions that are concurrently allowed in the mempool.  This
  mitigates several DoS attacks, but means that it might reject
  transaction B because it previously received related transaction A,
  which maxed out the limits.  This violates Zhao's principle: instead,
  Bitcoin Core should accept whichever of A or B is actually best for
  its goals.

  The proposed rules for [v3 transaction relay][topic v3 transaction
  relay] only allow an unconfirmed v3 parent to have a single child
  transaction in the mempool.  Because neither transaction can have any
  other ancestors or dependents in the mempool, applying the
  existing RBF rules to replacements of a v3 child is easy and Zhao
  has [implemented it][zhao
  kindredimpl].  If, as described in [last week's newsletter][news286
  imbued], existing LN commitment transactions using [anchor
  outputs][topic anchor outputs] are automatically enrolled in the v3
  policy, this would ensure that either party can always fee bump the commitment
  transaction:

  - Alice can send the commitment transaction with a child transaction
    to pay fees.

  - Alice can later RBF her existing child transaction to increase the
    fees.

  - Bob can use kindred replacement to evict Alice's child by sending a
    child of his own that pays higher fees.

  - Alice can later use kindred replacement on Bob's child by sending a
    child of hers with an even higher fee (removing Bob's child).

  Adding this policy and automatically applying it to current LN anchors
  will allow the [CPFP carve-out rule][topic cpfp carve out] to be
  removed, which is necessary for [cluster mempool][topic cluster
  mempool] to be implemented, which should allow making replacements
  of all kinds more incentive-compatible in the future.

  As of this writing, there were no objections to the idea on the forum.
  One notable question was about whether this eliminated the need for
  [ephemeral anchors][topic ephemeral anchors], but the author of that
  proposal (Gregory Sanders) replied, "I have no plans on dropping
  ephemeral anchor work.  Zero-satoshi outputs have a number of
  important use cases outside of LN." {% assign timestamp="1:10" %}

- **Opposition to CTV based on commonly requiring exogenous fees:**
  Peter Todd [posted][pt ctv] to the Bitcoin-Dev mailing list an
  adaptation of his argument against [exogenous fees][topic fee
  sourcing] (see [Newsletter #284][news284 ptexogenous]) applied to the
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] proposal.  He
  notes that, "in many (if not most) CTV use-cases intended to allow
  multiple parties to share a single UTXO, it is difficult to impossible
  to allow for sufficient CTV variants to cover all possible fee-rates.
  It is expected that CTV would be usually used with [anchor
  outputs][topic ephemeral anchors] to pay fees [...] or possibly, via a
  [transaction sponsor][topic fee sponsorship] soft-fork. [...]
  This requirement for all users to have a UTXO to pay fees negates the
  efficiency of CTV-using UTXO sharing schemes [...] the only realistic
  alternative is to use a third party to pay for the UTXO, eg via a LN
  payment, but at that point it would be more efficient to pay an
  [out-of-band mining fee][topic out-of-band fees]. That of course is
  highly undesirable from a mining centralization perspective." (Links
  added by Optech.) He recommends abandoning CTV and working instead on
  [convenant schemes][topic covenants] that are compatible with
  [RBF][topic rbf].

  John Law replied that fee-dependent timelocks (see [Newsletter
  #283][news283 fdt]) could make CTV safe to use with endogenous fees
  in cases where particular versions of a transaction needed to be
  confirmed by a deadline, although fee-dependent timelocks might
  delay some contract settlements by an indefinite amount of time. {% assign timestamp="19:11" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [How does block synchronization work in Bitcoin Core today?]({{bse}}121292)
  Pieter Wuille describes the block header tree, block data, and active chaintip
  block chain data structures and goes on to explain the header synchronization, block
  synchronization, and block activation processes that act upon them. {% assign timestamp="28:14" %}

- [How does headers-first prevent disk-fill attack?]({{bse}}76018)
  Pieter Wuille follows up on an old question to explain the more recent IBD
  "Headers Presync" (see [Newsletter #216][news216 headers presync]) header spam
  mitigations added to Bitcoin Core in 24.0. {% assign timestamp="30:31" %}

- [Is BIP324 v2transport redundant on Tor and I2P connections?]({{bse}}121360)
  Pieter Wuille concedes a lack of [v2 transport][topic v2 p2p transport]
  encryption benefits when using [anonymity networks][topic anonymity networks]
  but notes potential computational improvements over v1 unencrypted transport. {% assign timestamp="33:57" %}

- [What's a rule of thumb for setting the maximum number of connections?]({{bse}}121088)
  Pieter Wuille distinguishes between [outbound and inbound
  connections]({{bse}}121015) and lists considerations around setting higher
  `-maxconnections` values. {% assign timestamp="34:57" %}

- [Why isn't the upper bound (+2h) on the block timestamp set as a consensus rule?]({{bse}}121248)
  In this and [other]({{bse}}121247) related [questions]({{bse}}121253), Pieter
  Wuille explains the requirement that a new block's timestamp must be no later
  than two hours in the future, the importance of the requirement, and why "consensus
  rules can only depend on information that is committed to by block hashes". {% assign timestamp="37:01" %}

- [Sigop count and its influence on transaction selection?]({{bse}}121355)
  User Cosmik Debris asks how the limit on signature check operations, "sigops", impact miners'
  block template construction and mempool-based [fee estimation][topic fee
  estimation]. User mononaut outlines the infrequency of sigops being the
  limiting factor in block template construction and discusses the `-bytespersigop` option. {% assign timestamp="43:22" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 2.4.0][] is a release of the next version of this
  package providing a common interface to multiple different hardware
  signing devices.  The new release adds support for Trezor Safe 3 and
  contains several minor improvements. {% assign timestamp="48:03" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #29291][] adds a test that will fail if a transaction
  executing an `OP_CHECKSEQUENCEVERIFY` opcode appears to have a
  negative version number.  This test, if it had been run by alternative
  consensus implementations, would have caught the consensus failure bug
  mentioned in [last week's newsletter][news286 bip68ver]. {% assign timestamp="48:41" %}

- [Eclair #2811][], [#2813][eclair #2813], and [#2814][eclair #2814]
  add the ability for a [trampoline payment][topic trampoline payments]
  to use a [blinded path][topic rv routing] for the ultimate receiver.
  Trampoline routing itself continues to use regular onion-encrypted
  node IDs, i.e. each trampoline node learns the ID for the next
  trampoline node.  However, if a blinded path is used, the final
  trampoline node will now only learn the node ID for the introduction
  node in the blinded path; it will not learn the ID for
  the ultimate receiver.

  Previously, strong trampoline privacy depended on using multiple
  trampoline forwarders so that none of the forwarders could be sure
  they were the final forwarder.  A downside of this approach is that
  it used longer paths that increased the probability of forwarding
  failure and required paying more forwarding fees for success.  Now
  forwarding payments through even a single trampoline node can
  prevent that node from learning the ultimate receiver. {% assign timestamp="49:23" %}

- [LND #8167][] allows an LND node to mutually close a channel that
  still has one or more pending payments ([HTLCs][topic htlc]).  The
  [BOLT2][] specification indicates the proper procedure for this is for
  one side to send a `shutdown` message, after which no new HTLCs will
  be accepted.  After all pending HTLCs are resolved offchain, the two
  parties negotiate and sign a mutual close transaction.  Previously,
  when LND received a `shutdown` message, it would force close the
  channel, requiring extra onchain transactions and fees to settle. {% assign timestamp="52:10" %}

- [LND #7733][] updates [watchtower][topic watchtowers] support to enable
  backing up and enforcing correct shutdown of the [simple taproot
  channels][topic simple taproot channels] that are now supported
  experimentally by LND. {% assign timestamp="53:01" %}

- [LND #8275][] begins requiring peers support certain
  universally-deployed features as specified in [BOLTs #1092][] (see
  [Newsletter #259][news259 lncleanup]). {% assign timestamp="54:01" %}

- [Rust Bitcoin #2366][] deprecates the `.txid()` method on
  `Transaction` objects and begins providing a replacement method
  named `.compute_txid()`.  Each time the `.txid()` method is called, the
  txid for the transaction is calculated, which consumes enough
  CPU for it to be a concern to anyone running the function on large
  transactions or many smaller transactions.  It is hoped that the new
  name for the method will help downstream programmers realize its
  potential costs.  The `.wtxid()` and `.ntxid()` method (respectively
  based on [BIP141][] and [BIP140][]) are similarly renamed to
  `.compute_wtxid()` and `.compute_ntxid()`. {% assign timestamp="56:34" %}

- [HWI #716][] adds support for the Trezor Safe 3 hardware signing
  device. {% assign timestamp="58:35" %}

- [BDK #1172][] adds a block-by-block API for the wallet.  A user with
  access to a sequence of blocks
  can iterate over those blocks to
  update the wallet based on any transactions in those blocks.  This can
  be simply used to iterate over every block in a chain.  Alternatively,
  software can use some sort of filtering method (e.g. [compact block
  filtering][topic compact block filters]) to find only blocks that are
  likely to have wallet-affecting transactions and iterate over that
  subset of blocks. {% assign timestamp="58:49" %}

- [BINANAs #3][] adds [BIN24-5][] with a list of specification
  repositories related to Bitcoin, such as BIPs, BOLTs, BLIPs, SLIPs,
  LNPBPs, and DLC specifications.  Some specification repositories for
  other related projects are also listed. {% assign timestamp="59:29" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29291,2811,2813,2814,8167,7733,8275,1092,2366,716,1172,3" %}
[hwi 2.4.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0
[news286 bip68ver]: /en/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd
[trezor safe 3]: https://trezor.io/trezor-safe-3
[news283 fdt]: /en/newsletters/2024/01/03/#fee-dependent-timelocks
[zhao v3kindred]: https://delvingbitcoin.org/t/sibling-eviction-for-v3-transactions/472
[news259 lncleanup]: /en/newsletters/2023/07/12/#ln-specification-clean-up-proposed
[news284 ptexogenous]: /en/newsletters/2024/01/10/#frequent-use-of-exogenous-fees-may-risk-mining-decentralization
[zhao kindredimpl]: https://github.com/bitcoin/bitcoin/pull/29306
[pt ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022309.html
[news286 imbued]: /en/newsletters/2024/01/24/#imbued-v3-logic
[news216 headers presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
