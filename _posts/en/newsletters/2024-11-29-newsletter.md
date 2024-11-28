---
title: 'Bitcoin Optech Newsletter #331'
permalink: /en/newsletters/2024/11/29/
name: 2024-11-29-newsletter
slug: 2024-11-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes several recent discussions about a
Lisp dialect for Bitcoin scripting and includes our regular sections
with descriptions of popular questions and answers on the Bitcoin Stack
Exchange, announcements of new releases and release candidates, and
summaries of notable changes to popular Bitcoin infrastructure projects.

## News

- **Lisp dialect for Bitcoin scripting:** Anthony Towns made several
  posts about a continuation of his [work][topic bll] on creating a
  Lisp dialect for Bitcoin that could be added to Bitcoin in a soft
  fork.

  - *bll, symbll, bllsh:* Towns [notes][towns bllsh1] that he spent a
    long time thinking about advice from Chia Lisp developer Art Yerkes
    about ensuring a good mapping between high-level code (what
    programmers typically write) and low-level code (what actually gets
    run, typically created from high-level code by compilers).  He
    decided to take a [miniscript][topic miniscript]-like approach where
    "you treat the high-level language as a friendly variation of the
    low-level language (as miniscript does with script)".  The result is
    two languages and a tool:

    - *Basic Bitcoin Lisp language (bll)* is the low-level language
      that could be added to Bitcoin in a soft fork.  Towns says bll is
      similar to BTC Lisp as of his last update (see [Newsletter
      #294][news294 btclisp]).

    - *Symbolic bll (symbll)* is the high-level language that is
      converted into bll.  It should be relatively easy for anyone
      already familiar with functional programming.

    - *Bll shell (bllsh)* is a [REPL][] that allows a user to test
      scripts in bll and symbll, compile from symbll to bll, and execute
      code with debugging capabilities.

  - *Implementing quantum-safe signatures in symbll versus GSR:* Towns
    [links][towns wots] to a [Twitter post][nick wots] by Jonas Nick
    about implementing Winternitz One Time Signatures (WOTS+) using
    existing opcodes and the opcodes specified in Rusty Russell's
    _great script restoration_ (GSR) [proposal][russell gsr].  Towns
    then compares implementing WOTS using symbll in bllsh.  This reduces
    the amount of data that would need to be placed onchain by at least
    83% and potentially by more than 95%.  That could allow the use of
    [quantum-safe signatures][topic quantum resistance] at a cost only
    30x greater than P2WPKH outputs.

  - *Flexible coin earmarks:* Towns [describes][towns earmarks] a
    generic construction compatible with symbll (and probably
    [Simplicity][topic simplicity]) that allows partitioning a UTXO into
    specific amounts and spending conditions.  If a spending condition
    is fulfilled, the associated amount can be spent and the remaining
    value from the UTXO is returned to a new UTXO with the remaining
    conditions.  An alternative condition may also be satisfied to allow
    spending the entire UTXO; for example, this could allow all parties
    to agree to update some of the conditions.  This is a flexible type of
    [covenant][topic covenants] mechanism, similar to Towns's previous
    proposal for `OP_TAP_LEAF_UPDATE_VERIFY` (TLUV, see [Newsletter
    #166][news166 tluv]), but Towns has [written previously][towns
    badcov] that he thinks _covenants_ is "not an accurate or useful
    term".

    Several examples for how these _flexible coin earmarks_ can be used
    are provided, including improvements in the security and usability
    of LN channels (including [LN-Symmetry][topic eltoo]-based
    channels), an alternative to the [BIP345][] version of [vaults][topic
    vaults], and a [payment pool][topic joinpools] design similar to
    that contemplated for use with TLUV but that avoids the problems
    that proposal had with [x-only public keys][topic x-only public
    keys].

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [How does ColliderScript improve Bitcoin and what features does it enable?]({{bse}}124690)
  Victor Kolobov lists potential uses for ColliderScript (see [Newsletter
  #330][news330 cs] and [Podcast #330][pod330 cs]) including [covenants][topic
  covenants], [vaults][topic vaults], emulation of [CSFS][topic
  op_checksigfromstack], and validity rollups (see [Newsletter #222][news222
  validity rollups]) while noting the high computational costs of such transactions.

- [Why do standardness rules limit transaction weight?]({{bse}}124636)
  Murch provides arguments for and against Bitcoin Core's standardness weight
  limits and outlines how economic demand for larger transactions could erode
  the effectiveness of the [policy][policy series].

- [Is the scriptSig spending an PayToAnchor output expected to always be empty?]({{bse}}124615)
  Pieter Wuille points out that because of how [pay-to-anchor (P2A)][topic ephemeral
  anchors] outputs are [constructed][news326 p2a], they must adhere to segwit spending
  conditions, including an empty scriptSig.

- [What happens to the unused P2A outputs?]({{bse}}124617)
  Instagibbs notes that unused P2A outputs will eventually be swept when the block
  inclusion feerate drops low enough to make a sweep worth it, removing them from
  the UTXO set. He goes on to reference
  the recently-merged [ephemeral dust][news330 ed] PR that allows a single
  below-dust-threshold output in a zero-fee transaction provided a [child
  transaction][topic cpfp] immediately spends it.

- [Why doesn't Bitcoin's PoW algorithm use a chain of lower-difficulty hashes?]({{bse}}124777)
  Pieter Wuille and Vojtěch Strnad describe the mining centralization pressure
  that would happen if the progress-free property of Bitcoin's mining was
  violated with such an approach.

- [Clarification on false value in Script]({{bse}}124673)
  Pieter Wuille specifies the three values that evaluate to false in Bitcoin
  Script: an empty array, an array of 0x00 bytes, and an array of 0x00 bytes with a
  0x80 at the end. He notes that all other values are evaluated as true.

- [What is this strange microtransaction in my wallet?]({{bse}}124744)
  Vojtěch Strnad explains the mechanics of an address poisoning attack and ways
  to mitigate such attacks.

- [Are there any UTXOs that can not be spent?]({{bse}}124865)
  Pieter Wuille provides two examples of outputs that are unspendable regardless
  of the breaking of cryptographic assumptions: `OP_RETURN` outputs and outputs
  with a scriptPubKey longer than 10,000 bytes.

- [Why was BIP34 not implemented via the coinbase tx's locktime or nSequence?]({{bse}}75987)
  Antoine Poinsot follows up to this older question to point out that the
  coinbase transaction's `nLockTime` value cannot be set to the current block
  height because the [locktime][topic timelocks] represents the last block at
  which a transaction is *invalid*.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 24.11rc2][] is a releases candidate for the next major
  version of this popular LN implementation.

- [BDK 0.30.0][] is a release of this library for building wallets and
  other Bitcoin-enabled applications.  It includes several minor bug
  fixes and prepares for the anticipated upgrade to the version 1.0 of
  the library.

- [LDK 0.18.4-beta.rc1][] is a release candidate for a minor version of
  this popular LN implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31122][] implements a `changeset` interface for the mempool,
  allowing a node to compute the impact of a proposed set of changes on the state
  of the mempool.  For example, checking whether ancestor/descendant/[TRUC][topic v3
  transaction relay] (and future cluster) limits are violated when a transaction
  or a package is accepted, or determining whether an [RBF][topic RBF] fee bump
  improves the state of the mempool. This PR is part of the [cluster
  mempool][topic cluster mempool] project.

- [Core Lightning #7852][] restores backwards compatibility with versions prior
  to 24.08 for the `pyln-client` plugin (a Python client library) by
  reintroducing a description field.

- [Core Lightning #7740][] improves the minimum cost flow (MCF) solver of the
  `askrene` (see [Newsletter #316][news316 askrene]) plugin by providing an API
  that abstracts the complexity of MCF solving to allow easier integration of
  newly added graph-based flow computation algorithms. The solver adopts the
  same channel cost function linearization as `renepay`(see [Newsletter
  #263][news263 renepay]), which improves pathfinding reliability, and
  introduces support for customizable units beyond msats, allowing greater
  scalability for large payments. This PR adds the `simple_feasibleflow`,
  `get_augmenting_flow`, `augment_flow`, and `node_balance` methods to improve
  the efficiency of flow calculations.

- [Core Lightning #7719][] achieves interoperability with Eclair for
  [splicing][topic splicing], allowing splices to be executed between the two
  implementations. This PR introduces several changes to align with Eclair’s
  implementation including support for rotating remote funding keys, adding
  `batch_size` for commitment-signed messages, preventing transmission of
  previous funding transactions due to packet size limits, removing blockhashes
  from messages, and adjusting pre-set funding output balances.

- [Eclair #2935][] adds a notification to the node operator in the event of a
  channel force close initiated by a channel peer.

- [LDK #3137][] adds support for accepting peer-initiated [dual-funded
  channels][topic dual funding], although funding or creating such channels is
  not yet supported. If `manually_accept_inbound_channels` is set to false,
  channels are automatically accepted, while the
  `ChannelManager::accept_inbound_channel()` function allows manual acceptance.
  A new `channel_negotiation_type` field is introduced to distinguish between
  inbound requests for dual-funded and non-dual-funded channels.
  [Zero-conf][topic zero-conf channels] dual-funded channels and
  [RBF][topic rbf] fee
  bumping of funding transactions are not supported.

- [LND #8337][] introduces the `protofsm` package, a reusable framework for
  creating event-driven protocol finite state machines (FSMs) in LND. Instead of
  writing boilerplate code to handle states, transitions, and events, developers
  can define the states, what triggers events, and the rules for moving between
  them, and the `State` interface will encapsulate behavior, handle events, and
  determine terminal states, while daemon adapters handle side effects like
  broadcasting transactions and sending peer messages.

{% include references.md %}
{% include linkers/issues.md v=2 issues="31122,7852,7740,7719,2935,3137,8337" %}
[news294 btclisp]: /en/newsletters/2024/03/20/#overview-of-btc-lisp
[russell gsr]: https://github.com/rustyrussell/bips/pull/1
[towns bllsh1]: https://delvingbitcoin.org/t/debuggable-lisp-scripts/1224
[repl]: https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
[towns wots]: https://delvingbitcoin.org/t/winternitz-one-time-signatures-contrasting-between-lisp-and-script/1255
[nick wots]: https://x.com/n1ckler/status/1854552545084977320
[towns earmarks]: https://delvingbitcoin.org/t/flexible-coin-earmarks/1275
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[towns badcov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[core lightning 24.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc2
[bdk 0.30.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.0
[ldk 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 askrene]: /en/newsletters/2024/08/16/#core-lightning-7517
[news263 renepay]: /en/newsletters/2023/08/09/#core-lightning-6376
[news330 cs]: /en/newsletters/2024/11/22/#covenants-based-on-grinding-rather-than-consensus-changes
[pod330 cs]: /en/podcast/2024/11/26/#covenants-based-on-grinding-rather-than-consensus-changes
[news222 validity rollups]: /en/newsletters/2022/10/19/#validity-rollups-research
[policy series]: /en/blog/waiting-for-confirmation/
[news326 p2a]: /en/newsletters/2024/10/25/#how-was-the-structure-of-pay-to-anchor-decided
[news330 ed]: /en/newsletters/2024/11/22/#bitcoin-core-30239
