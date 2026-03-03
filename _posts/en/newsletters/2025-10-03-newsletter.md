---
title: 'Bitcoin Optech Newsletter #374'
permalink: /en/newsletters/2025/10/03/
name: 2025-10-03-newsletter
slug: 2025-10-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections summarizing
discussion about changing Bitcoin's consensus rules, announcing new
release and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

_No significant news this week was found in any of our [sources][optech sources]._

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Draft BIPs for Script Restoration:** Rusty Russell posted to the Bitcoin-Dev mailing list a [summary][rr0]
  and four BIPs ([1][rr1], [2][rr2], [3][rr3], [4][rr4]) in various stages of
  draft relating to a proposal to restore Script's capabilities in a new
  [tapscript][topic tapscript] version. Russell has previously [spoken][rr atx] and [written][rr
  blog] about these ideas. Briefly, this proposal aims to restore enhanced programmability
  (including [covenant][topic covenants] functionality) to Bitcoin while avoiding some
  of the trade-offs required in more narrowly scoped proposals.

  - _Varops budget for script runtime constraint:_ The [first BIP][rr1] is
    fairly complete and proposes assigning a cost metric to nearly all Script
    operations, similar to the SegWit sigops budget. For most operations in
    Script the cost is based on the number of bytes written to the node's RAM
    during execution of the opcode by a naive implementation. Unlike the sigops
    budget, the cost for each opcode depends on the size of its inputs - hence
    the name "varops". With this unified cost model, many limits currently used
    to protect nodes from excessive Script validation cost can be raised to the
    point that they are impossible or nearly impossible to hit in practical
    scripts.

  - _Restoration of disabled script functionality (tapscript v2):_ The [second BIP][rr2]
    is also fairly complete (aside from a reference implementation) and
    details the restoration of opcodes [removed][misc changes] from Script back
    in 2010, as required to protect the Bitcoin network from excessive Script
    validation cost. With the varops budget in place, all of these opcodes (or
    updated versions of them) can be restored, limits can be raised, and numbers
    can be made arbitrary length.

  - _OP_TX:_ The [third BIP][rr3] is a proposal for a new general
    introspection opcode. `OP_TX` allows the caller to get nearly any item or
    items from the transaction into the script stack. By providing direct access to the
    spending transaction, this opcode enables any covenant
    functionality possible with opcodes such as `OP_TEMPLATEHASH` or
    [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify].

  - _New opcodes for tapscript v2:_ The [final BIP][rr4] proposes new
    opcodes which round out the functionality that was either missing or not
    needed when Bitcoin was first launched. For example, adding the ability to
    manipulate taptrees and taproot outputs was not necessary at Bitcoin's
    introduction, but in a world with restored Script it makes sense to have
    these capabilities as well. Brandon Black [noted][bb1] an omission in the
    specified opcodes needed to fully construct taproot outputs. Two of the
    proposed opcodes seem likely to require their own full BIPs: `OP_MULTI` and
    `OP_SEGMENT`.

  `OP_MULTI` modifies the subsequent opcode to operate on more than its standard
  number of stack items, enabling (for example) a script to add up a variable
  number of items. This avoids the need for a looping construct in Script or for
  an `OP_VAULT` style deferred check while enabling value flow control and
  similar logic.

  `OP_SEGMENT` (if present) modifies the behavior of `OP_SUCCESS` such that
  instead of the whole script succeeding if an `OP_SUCCESS` is present, only the
  segment succeeds (bounded by script start, `OP_SEGMENT`, ..., and script end).
  This enables the possibility of scripts with a required prefix, including
  `OP_SEGMENT`, and an untrusted suffix. {% assign timestamp="0:40" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 30.0rc2][] is a release candidate for the next major version of
  this full verification node software. Please see the [version 30 release
  candidate testing guide][bcc30 testing]. {% assign timestamp="19:19" %}

- [bdk-wallet 2.2.0][] is a minor release of this library used for building
  wallet applications that introduces a new feature that returns events upon
  applying an update, new test facilities for test persistence, and
  documentation improvements. {% assign timestamp="23:39" %}

- [LND v0.20.0-beta.rc1][] is a release candidate for a new version of this
  popular LN node implementation that introduces multiple bug fixes, persistence
  of node announcement settings across restarts, a new `noopAdd` [HTLC][topic
  htlc] type, support for [P2TR][topic taproot] fallback addresses on [BOLT11][]
  invoices, and an experimental `XFindBaseLocalChanAlias` endpoint, among many
  other changes. {% assign timestamp="24:15" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33229][] implements automatic multiprocess selection for
  inter-process communication (IPC) (see [Newsletter #369][news369 ipc]),
  allowing users to skip specifying the `-m` startup option when IPC arguments
  are passed or IPC configurations are set. This change simplifies the
  integration of Bitcoin Core with an external [Stratum v2][topic pooled mining]
  mining service that creates, manages and submits block templates. {% assign timestamp="25:03" %}

- [Bitcoin Core #33446][] fixes a bug introduced when the `target` field was
  added to the responses of the `getblock` and `getblockheader` commands (see
  [Newsletter #339][news339 target]). Instead of always incorrectly returning
  the chain tip’s target, it now returns the requested block’s target. {% assign timestamp="26:55" %}

- [LDK #3838][] adds support for the `client_trusts_lsp` model for [JIT
  channels][topic jit channels], as specified in [BLIP52][] (LSPS2) (see
  [Newsletter #335][news335 blip]), on top of already supporting the
  `lsp_trusts_client` model. With the new model, the LSP will not broadcast the
  on-chain funding transaction until the receiver reveals the preimage required
  to claim the [HTLC][topic htlc]. {% assign timestamp="28:11" %}

- [LDK #4098][] updates the implementation of the `next_funding` TLV in the
  `channel_reestablish` flow for [splicing][topic splicing] transactions, to
  align with the proposed specification change in [BOLTs #1289][]. This PR
  follows the recent work on `channel_reestablish` covered in [Newsletter
  #371][news371 splicing]. {% assign timestamp="30:40" %}

- [LDK #4106][] fixes a race condition in which an [HTLC][topic htlc] held by an
  LSP on behalf of an [async payment][topic async payments] recipient would fail
  to be released because the LSP could not locate it. This occurred when the LSP
  received the `release_held_htlc` [onion message][topic onion messages] (see
  Newsletters [#372][news372 async] and [#373][news373 async]) before the HTLC
  was moved from the pre-decode map to the `pending_intercepted_htlcs` map. LDK
  now checks both maps, rather than just the latter one, to ensure the HTLC is
  found and released properly. {% assign timestamp="33:40" %}

- [LDK #4096][] changes the per-peer outbound [gossip][topic channel
  announcements] queue from a 24-message limit to a 128 KB size limit. If the
  total number of bytes currently queued for a given peer exceeds this limit,
  new gossip forwards to that peer are skipped until the queue drains. This new
  limit significantly reduces missed forwards, and is particularly relevant
  because when messages vary in size. {% assign timestamp="35:43" %}

- [LND #10133][] adds the experimental `XFindBaseLocalChanAlias` RPC endpoint,
  which returns a base SCID for a specified SCID alias (see [Newsletter
  #203][news203 alias]). This PR also extends the alias manager to persist the
  reverse mapping when aliases are created, enabling the new endpoint. {% assign timestamp="37:24" %}

- [BDK #2029][] introduces the `CanonicalView` struct, which performs a one-time
  canonicalization of a wallet’s `TxGraph` at a given chaintip. This snapshot
  powers all subsequent queries, eliminating the need for re-canonicalization
  with every call. Methods that required canonicalization now have
  `CanonicalView` equivalents, and `TxGraph` methods that took a fallible
  `ChainOracle` are removed. See Newsletters [#335][news335 txgraph] and
  [#346][news346 txgraph] for previous canonicalization work on BDK. {% assign timestamp="39:08" %}

- [BIPs #1911][] marks [BIP21][] as replaced by [BIP321][] and updates
  [BIP321][]’s status from `Draft` to `Proposed`. [BIP321][] proposes a modern
  URI scheme for describing bitcoin payment instructions, see [Newsletter
  #352][news352 bip321] for more details. {% assign timestamp="42:15" %}

{% include snippets/recap-ad.md when="2025-10-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33229,33446,3838,4098,4106,4096,10133,2029,1911,1289" %}
[rr0]: https://gnusha.org/pi/bitcoindev/877bxknwk6.fsf@rustcorp.com.au/
[rr1]: https://gnusha.org/pi/bitcoindev/874isonniq.fsf@rustcorp.com.au/
[rr2]: https://gnusha.org/pi/bitcoindev/871pnsnnhh.fsf@rustcorp.com.au/
[rr3]: https://gnusha.org/pi/bitcoindev/87y0q0m8vz.fsf@rustcorp.com.au/
[rr4]: https://gnusha.org/pi/bitcoindev/87tt0om8uz.fsf@rustcorp.com.au/
[rr atx]: https://www.youtube.com/watch?v=rSp8918HLnA
[rr blog]: https://rusty.ozlabs.org/2024/01/19/the-great-opcode-restoration.html
[bb1]: https://gnusha.org/pi/bitcoindev/aNsORZGVc-1_-z1W@console/
[misc changes]: https://github.com/bitcoin/bitcoin/commit/6ac7f9f144757f5f1a049c059351b978f83d1476
[bitcoin core 30.0rc2]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[bdk-wallet 2.2.0]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/wallet-2.2.0
[LND v0.20.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc1
[news369 ipc]: /en/newsletters/2025/08/29/#bitcoin-core-31802
[news339 target]: /en/newsletters/2025/01/31/#bitcoin-core-31583
[news335 blip]: /en/newsletters/2025/01/03/#blips-54
[news371 splicing]: /en/newsletters/2025/09/12/#ldk-3886
[news372 async]: /en/newsletters/2025/09/19/#ldk-4045
[news373 async]: /en/newsletters/2025/09/26/#ldk-4046
[news203 alias]: /en/newsletters/2022/06/08/#bolts-910
[news335 txgraph]: /en/newsletters/2025/01/03/#bdk-1670
[news346 txgraph]: /en/newsletters/2025/03/21/#bdk-1839
[news352 bip321]: /en/newsletters/2025/05/02/#bips-1555