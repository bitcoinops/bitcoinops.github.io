---
title: 'Bitcoin Optech Newsletter #390'
permalink: /en/newsletters/2026/01/30/
name: 2026-01-30-newsletter
slug: 2026-01-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a more efficient approach to garbled
circuits and links to an LN-Symmetry update. Also included are our
regular sections with selected questions and answers from the Bitcoin
Stack Exchange, announcements of new software releases and release
candidates, and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Argo: a garbled-circuits scheme with more efficient off-chain computation**:
  Robin Linus [posted][delving rl garbled] to Delving Bitcoin about a new
  [paper][iacr le ytl garbled] by Liam Eagen and Ying Tong Lai describing a
  technique that will enable 1000 times more efficient [garbled locks][news359 rl
  garbled]. The new technique uses a MAC (message authentication code) that
  encodes the wires of a garbled circuit as EC (elliptic curve) points. The
  MAC is designed to be homomorphic, enabling many operations within the garbled
  circuit to be represented directly as operations on EC points. The key
  improvement is that Argo works over _arithmetic_ circuits, in contrast to
  binary circuits. With an binary circuit, millions of binary gates are needed to
  represent a curve point multiplication, whereas with this arithmetic
  circuit, you only need a single arithmetic gate. The current
  paper is the first of several pieces needed to apply this technique to
  [BitVM][topic acc]-like constructs on Bitcoin. {% assign timestamp="0:48" %}

- **LN-Symmetry update**: Gregory Sanders [posted][symmetry update]
  an update to Delving Bitcoin about his previous work on [LN-Symmetry][topic eltoo]
  (see [Newsletter #284][news284 ln sym]).

  Sanders rebased his previous proof-of-concept work on the
  [BOLTs specifications][bolts fork] and [CLN implementation][cln fork] to the latest updates.
  The updated implementation now works on [Bitcoin Inquisition][bitcoin inquisition repo]
  29.x on [signet][topic signet] with [TRUC][topic v3 transaction relay],
  [ephemeral dust, P2A][topic ephemeral anchors], and 1p1c [package relay][topic package relay].
  It supports cooperative channel closure, fixes a crash that prevented the node from restarting
  correctly, and expands test coverage. Sanders asked other developers to test his new
  proof-of-concept on signet with Bitcoin Inquisition.

  Sanders also leveraged LLM capabilities to migrate his work from APO to
  OP_TEMPLATEHASH+OP_CSFS+IK (see [Newsletter #365][news365 op proposal]), modified a
  [BOLT draft][bolt th] and created a [CLN-based implementation][cln th].
  However, Sanders added that since OP_TEMPLATEHASH is not yet live on Bitcoin Inquisition,
  this update can only be tested in regtest. {% assign timestamp="26:05" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What is stored in dbcache and with what priority?]({{bse}}130376)
  Murch describes the purpose of the `dbcache` data structure as an in-memory
  cache for the a subset of entire UTXO set and goes on to detail its behavior. {% assign timestamp="34:21" %}

- [Can one do a coinjoin in Shielded CSV?]({{bse}}130364)
  Jonas Nick points out that the Shielded CSV protocol doesn't support
  [coinjoins][topic coinjoin] currently, but that [client-side validation][topic
  client-side validation] protocols do not inherently preclude such functionality. {% assign timestamp="24:02" %}

- [In Bitcoin Core, how to use Tor for broadcasting new transactions only?]({{bse}}99442)
  Vasil Dimov follows up to this older question pointing out that with the new
  `privatebroadcast` option (see [Newsletter #388][news388 private broadcast]),
  Bitcoin Core can broadcast transactions through short-lived [privacy
  network][topic anonymity networks] connections. {% assign timestamp="36:47" %}

- [Brassard-Høyer-Tapp (BHT) algorithm and Bitcoin (BIP360)]({{bse}}130431) User
  bca-0353f40e explains that the capability for a collision attack on
  [multisignature][topic multisignature] addresses using the Brassard-Høyer-Tapp
  (BHT) [quantum][topic quantum resistance] algorithm to diminish SHA256
  security would not affect addresses created before the capability. {% assign timestamp="38:31" %}

- [Why does BitHash alternate sha256 and ripemd160?]({{bse}}130373)
  Sjors Provoost outlines the rationale around [BitVM3][topic acc]'s BitHash
  function, a hash function tailored for Bitcoin's Script language. {% assign timestamp="39:24" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Libsecp256k1 0.7.1][] is a maintenance release of this library for
  Bitcoin-related cryptographic operations which includes a security improvement
  that increases the number of cases where the library attempts to clear secrets
  from the stack. It also introduces a new unit test framework and some build
  system changes. {% assign timestamp="41:09" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33822][] adds block header support to the `libbitcoinkernel`
  API interface (see [Newsletter #380][news380 kernel]). A new
  `btck_BlockHeader` type and its associated methods enable creating, copying,
  and destroying headers, as well as fetching header fields such as hash,
  previous hash, timestamp, difficulty target, version and nonce. A new
  `btck_chainstate_manager_process_block_header()`  method validates and
  processes block headers without requiring the full block, and
  `btck_chainstate_manager_get_best_entry()` returns the block tree entry with
  the most cumulative proof-of-work. {% assign timestamp="42:59" %}

- [Bitcoin Core #34269][] disallows creating or restoring unnamed wallets
  when using the `createwallet` and `restorewallet` RPCs, as well as the wallet
  tool's `create` and `createfromdump` commands (see Newsletters [#45][news45
  wallettool] and [#130][news130 wallettool]). While the GUI already enforced
  this restriction, the RPCs and underlying functions did not. Wallet migration
  can still restore unnamed wallets. See [Newsletter #387][news387 unnamed] for
  a bug related to unnamed wallets. {% assign timestamp="44:50" %}

- [Core Lightning #8850][] removes several deprecated features:
  `option_anchors_zero_fee_htlc_tx`, renamed to `option_anchors` to reflect
  changes on [anchor outputs][topic anchor outputs], the `decodepay` RPC
  (replaced by `decode`), the `tx` and `txid` fields in the `close` command
  response (replaced by `txs` and `txids`), and `estimatefeesv1`, the original
  response format used by the `bcli` plugin to return [fee estimates][topic fee
  estimation]. {% assign timestamp="47:38" %}

- [LDK #4349][] adds validation for [bech32][topic bech32] padding when parsing
  [BOLT12 offers][topic offers], as specified in [BIP173][]. Previously, LDK
  would accept offers with invalid padding, whereas other implementations, such
  as Lightning-KMP and Eclair, would correctly reject them. A new
  `InvalidPadding` error variant is added to the `Bolt12ParseError` enum. {% assign timestamp="49:16" %}

- [Rust Bitcoin #5470][] adds validation to the decoder to reject transactions
  with zero outputs, as valid Bitcoin transactions must have at least one
  output. {% assign timestamp="50:54" %}

- [Rust Bitcoin #5443][] adds validation on the decoder to reject transactions
  where the sum of the output values exceeds `MAX_MONEY` (21 million bitcoin).
  This check is related to [CVE-2010-5139][topic cves], a historical
  vulnerability where an attacker could create transactions with extremely large
  output values. {% assign timestamp="51:26" %}

- [BDK #2037][] adds the `median_time_past()` method to calculate
  median-time-past (MTP) for `CheckPoint` structures. MTP, defined in
  [BIP113][], is the median timestamp of the previous 11 blocks and is used to
  validate [timelocks][topic timelocks]. See [Newsletter #372][news372 mtp] for
  previous work enabling this. {% assign timestamp="52:51" %}

- [BIPs #2076][] adds [BIP434][] which defines a P2P feature message that would
  allow peers to announce and negotiate support for new features. The idea
  generalizes [BIP339][]'s mechanism (see [Newsletter #87][news87 negotiation])
  but instead of requiring a new message type for each feature, [BIP434][]
  provides a single, reusable message for announcing and negotiating multiple
  P2P upgrades. This benefits various proposed P2P use cases, including
  [template sharing][news366 template]. See [Newsletter #386][news386 feature]
  for the mailing list discussion. {% assign timestamp="55:49" %}

- [BIPs #1500][] adds [BIP346][] which defines the `OP_TXHASH` opcode for
  [tapscript][topic tapscript] that pushes onto the stack a hash digest of
  specified parts of the spending transaction. This can be used to create
  [covenants][topic covenants] and reduce interactivity in multi-party
  protocols. The opcode generalizes [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] and, when combined with [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack], can emulate [SIGHASH_ANYPREVOUT][topic
  sighash_anyprevout]. See Newsletters [#185][news185 txhash] and [#272][news272
  txhash] for previous discussion. {% assign timestamp="59:39" %}

{% include snippets/recap-ad.md when="2026-02-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33822,34269,8850,4349,5470,5443,2037,2076,1500" %}
[news359 rl garbled]: /en/newsletters/2025/06/20/#improvements-to-bitvm-style-contracts
[news369 le garbled]: /en/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[delving rl garbled]: https://delvingbitcoin.org/t/argo-a-garbled-circuits-scheme-for-1000x-more-efficient-off-chain-computation/2210
[iacr le ytl garbled]: https://eprint.iacr.org/2026/049.pdf
[symmetry update]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359/17
[news284 ln sym]: /en/newsletters/2024/01/10/#ln-symmetry-research-implementation
[bolts fork]: https://github.com/instagibbs/bolts/tree/eltoo_trucd
[cln fork]: https://github.com/instagibbs/lightning/tree/2026-01-eltoo_rebased
[news365 op proposal]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[news388 private broadcast]: /en/newsletters/2026/01/16/#bitcoin-core-29415
[bolt th]: https://github.com/instagibbs/bolts/tree/2026-01-eltoo_th
[cln th]: https://github.com/instagibbs/lightning/commits/2026-01-eltoo_templatehash
[Libsecp256k1 0.7.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.1
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news45 wallettool]: /en/newsletters/2019/05/07/#new-wallet-tool
[news130 wallettool]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news387 unnamed]: /en/newsletters/2026/01/09/#bitcoin-core-wallet-migration-bug
[news372 mtp]: /en/newsletters/2025/09/19/#bdk-1582
[news87 negotiation]: /en/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[news386 feature]: /en/newsletters/2026/01/02/#peer-feature-negotiation
[news366 template]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news272 txhash]: /en/newsletters/2023/10/11/#specification-for-op-txhash-proposed