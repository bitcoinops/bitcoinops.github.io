---
title: 'Bitcoin Optech Newsletter #382'
permalink: /en/newsletters/2025/11/28/
name: 2025-11-28-newsletter
slug: 2025-11-28-newsletter
type: newsletter
layout: newsletter
lang: en
---

This week's newsletter provides an update on compact block reconstruction
discussions and relays a call to activate BIP3.  Also included are our regular
sections summarizing top questions and answers from the Bitcoin
Stack Exchange, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

- **Stats on compact block reconstructions updates:** 0xB10C posted an
  update to [Delving Bitcoin][0xb10c delving] about his statistics around
  compact block reconstruction (see Newsletters [#315][news315
  cb] and [#339][news339 cb]). 0xB10C provided three
  updates around his compact block reconstruction analysis:

  - He began tracking the average size of requested transactions in kB in
    response to [previous feedback][news365 cb] by David Gumberg.

  - He updated one of his nodes to include the lower `minrelayfee` settings from
    [Bitcoin Core #33106][news368 minrelay]. After updating, he found block
    reconstruction rates improved significantly for that node. He also saw an
    improvement in the average size of requested transactions in kB.

  - He then switched his other nodes to run with the lowered `minrelayfee` which
    caused most of the nodes to have a higher reconstruction rate and to request
    less data from peers. He also [mentions][0xb10c third update]
    that, in hindsight, it would have been better not to have updated all the
    nodes and to have kept some on v29 which would have made it easier to
    compare between node versions and
    settings.

  Overall, lowering the `minrelayfee` has improved his nodes' block reconstruction rates
  and lowered the amount of data requested from his peers. {% assign timestamp="0:34" %}

- **Motion to activate BIP3**: Murch [posted][murch ml] to the Bitcoin-Dev
  mailing list a formal motion to activate [BIP3][] (see [Newsletter
  #341][news341 bip3]). The goal of this improvement proposal is to provide new
  guidelines for preparing new BIPs, thereby replacing the current [BIP2][]
  process.

  According to the author, the proposal, which has been in "Proposed" status for
  more than 7 months, has no unaddressed objections and a growing list of
  contributors left an ACK on [BIPs #1820][]. Thus, following the procedure
  expressed by BIP2 for activating Process BIPs, he granted 4 weeks, until
  2025-12-02, to evaluate the proposal, ACK the PR, or state concerns and
  raise objections. After that date, BIP3 will replace BIP2 as the BIP process.

  Some minor objections have been raised in the thread, mainly regarding the use
  of AI/LLM tools in the BIPs submission process (see [Newsletter #378][news378
  bips2006]), which the author is currently addressing. We invite Optech readers
  to familiarize themselves with the proposal and provide feedback. {% assign timestamp="7:26" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Do pruned nodes store witness inscriptions?]({{bse}}129197)
  Murch explains that pruned nodes retain all block data, including witness
  data, until older blocks are eventually discarded. He goes on to outline
  tradeoffs of using OP_RETURN over the inscription scheme. {% assign timestamp="24:27" %}

- [Increasing probability of block hash collisions when difficulty is too high]({{bse}}129265)
  Vojtěch Strnad notes the extreme unlikelihood of a blockhash collision (unless SHA256 is
  broken) and goes on to explain why the hash of a block header serves as block
  identifiers. {% assign timestamp="29:33" %}

- [What is the purpose of the initial 0x04 byte in all extended public and private keys?]({{bse}}129178)
  Pieter Wuille points out that these 0x04 prefixes are simply a coincidence
  based on their respective target Base58 encodings. {% assign timestamp="33:25" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.20.0-beta][] is a major release of this popular LN node implementation
  that introduces multiple bug fixes, a new noopAdd [HTLC][topic htlc] type,
  support for [P2TR][topic taproot] fallback addresses on [BOLT11][] invoices,
  and many RPC and `lncli` additions and improvements. See the [release
  notes][lnd notes] for more details. {% assign timestamp="34:57" %}

- [Core Lightning v25.12rc1][] is a release candidate of a new version of this
  major LN node implementation that adds [BIP39][] mnemonic seed phrases as the
  new backup method, improvements to `xpay`, the `askrene-bias-node` RPC command
  to favor or disfavor all channels of a peer, the `networkevents` subsystem to
  access information about peers, and `experimental-lsps-client` and
  `experimental-lsps2-service` options for experimental [JIT channels][topic jit
  channels] support. {% assign timestamp="35:57" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33872][] removes the previously deprecated `-maxorphantx`
  startup option (see [Newsletter #364][news364 orphan]). Using it results in a
  startup failure. {% assign timestamp="37:55" %}

- [Bitcoin Core #33629][] completes the [cluster mempool][topic cluster mempool]
  implementation by partitioning the mempool into clusters that are limited to
  101 kvB and 64 transactions each by default. Each cluster is linearized into
  fee-ordered chunks (sub-cluster feerate-sorted groupings), so that
  higher-feerate chunks are selected first for inclusion in a block template,
  and the lowest-feerate chunks are evicted first when the mempool is full. This
  PR removes the [CPFP carve out][topic cpfp carve out] rule and the
  ancestor/descendant limits, and updates transaction relay to prioritize
  higher-feerate chunks. Finally, it updates the [RBF][topic rbf] rules by
  removing the restriction that replacements can’t introduce new unconfirmed
  inputs, changes the feerate rule to require that the overall cluster
  feerate diagram improves, and replaces the direct conflicts limit with a
  directly conflicting clusters limit. {% assign timestamp="42:05" %}

- [Core Lightning #8677][] improves the performance of large nodes considerably
  by limiting the number of RPC and plugin commands processed at once, reducing
  unnecessary database transactions for read-only commands, and restructuring
  database queries to handle millions of `chainmoves`/`channelmoves` events more
  efficiently. The PR also introduces a `filters` option to `rpc_command` or
  `custommsg` hooks, enabling plugins like `xpay`, `commando`, and `chanbackup`
  to register for specific invocations only. {% assign timestamp="49:49" %}

- [Core Lightning #8546][] adds a `withhold` option (default false) to
  `fundchannel_complete` that delays the broadcast of a channel funding
  transaction until `sendpsbt` is called or the channel is closed. This allows
  LSPs to postpone opening a channel until a user provides sufficient funds to
  cover the network fees. This is necessary to enable the `client-trusts-lsp`
  mode in [JIT channels][topic jit channels]. {% assign timestamp="51:28" %}

- [Core Lightning #8682][] updates the way [blinded paths][topic rv routing] are
  built by requiring peers to have the [`option_onion_messages`][topic onion
  messages] feature enabled, in addition to the `option_route_blinding`, even if
  the specification doesn’t require the former. This resolves an issue in which
  an LND node without the feature enabled would fail to forward a [BOLT12][topic
  offers] payment. {% assign timestamp="53:19" %}

- [LDK #4197][] caches the two most recently revoked commitment points in
  `ChannelManager` to respond to a peer’s `channel_reestablish` message after a
  reconnection. This avoids fetching the points from a potentially-remote signer
  and pausing the state machine when the counterparty is at most one commitment
  height prior. If a peer presents a different state, the signer validates the
  commitment point, and LDK either crashes if the state is valid or force-closes
  the channel if it's invalid. For previous LDK updates to
  `channel_reestablish`, see Newsletters [#335][news335 ldk], [#371][news371
  ldk], and [#374][news374 ldk]. {% assign timestamp="55:39" %}

- [LDK #4234][] adds the funding redeem script to `ChannelDetails` and the
  `ChannelPending` event, enabling LDK's on-chain wallet to reconstruct the
  `TxOut` of a channel and accurately estimate the feerate when building a
  [splice-in][topic splicing] transaction. {% assign timestamp="1:00:56" %}

- [LDK #4148][] adds support for [testnet4][topic testnet] by updating the
  `rust-bitcoin` dependency to version 0.32.4 (See [Newsletter #324][news324
  testnet]) and requiring that as the minimum supported version for the
  `lightning` and `lightning-invoice` crates. {% assign timestamp="1:02:17" %}

- [BDK #2027][] adds a `list_ordered_canonical_txs` method to `TxGraph`, which
  returns canonical transactions in topological order, where parent transactions
  always appear before their children. The existing `list_canonical_txs` and
  `try_list_canonical_txs` methods are deprecated in favor of the new ordered
  variant. See Newsletters [#335][news335 txgraph], [#346][news346 txgraph] and
  [#374][news374 txgraph] for previous canonicalization work on BDK. {% assign timestamp="1:03:04" %}

{% include snippets/recap-ad.md when="2025-12-02 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1820,33872,33629,8677,8546,8682,4197,4234,4148,2027" %}
[0xb10c delving]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/35
[news365 cb]: /en/newsletters/2025/08/01/#testing-compact-block-prefilling
[news339 cb]: /en/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news315 cb]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[david delving post]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[news368 minrelay]: /en/newsletters/2025/08/22/#bitcoin-core-33106
[0xb10c third update]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/44
[murch ml]: https://groups.google.com/g/bitcoindev/c/j4_toD-ofEc
[news341 bip3]: /en/newsletters/2025/02/14/#updated-proposal-for-updated-bip-process
[news378 bips2006]: /en/newsletters/2025/10/31/#bips-2006
[LND v0.20.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[lnd notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[Core Lightning v25.12rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12rc1
[news364 orphan]: /en/newsletters/2025/07/25/#bitcoin-core-31829
[news335 ldk]: /en/newsletters/2025/01/03/#ldk-3365
[news374 ldk]: /en/newsletters/2025/10/03/#ldk-4098
[news371 ldk]: /en/newsletters/2025/09/12/#ldk-3886
[news324 testnet]: /en/newsletters/2024/10/11/#rust-bitcoin-2945
[news335 txgraph]: /en/newsletters/2025/01/03/#bdk-1670
[news346 txgraph]: /en/newsletters/2025/03/21/#bdk-1839
[news374 txgraph]: /en/newsletters/2025/10/03/#bdk-2029