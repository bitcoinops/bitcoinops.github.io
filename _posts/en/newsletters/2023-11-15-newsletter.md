---
title: 'Bitcoin Optech Newsletter #277'
permalink: /en/newsletters/2023/11/15/
name: 2023-11-15-newsletter
slug: 2023-11-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an update to the proposal for ephemeral
anchors and provides a contributed field report about miniscript from a
developer working at Wizardsardine.  Also included are our regular sections
announcing new software releases and release candidates and summarizing
notable changes to popular Bitcoin infrastructure projects.

## News

- **Eliminating malleability from ephemeral anchor spends:** Gregory
  Sanders [posted][sanders mal] to the Delving Bitcoin forum about a
  tweak to the [ephemeral anchors][topic ephemeral anchors] proposal.
  That proposal would allow transactions to include a zero-value output
  with an anyone-can-spend output script.  Because anyone can spend the
  output, anyone can [CPFP][topic cpfp] fee bump the transaction that
  created the output.  This is convenient for multiparty contract
  protocols such as LN where transactions often get signed before it's
  possible to accurately predict what feerate they should pay.
  Ephemeral anchors allows any
  party to the contract to add as much fee as they think is necessary.
  If any other party---or any other user for any reason---wants to add a
  higher fee, they can [replace][topic rbf] the CPFP fee bump with their
  own higher-feerate CPFP fee bump.

    The type of anyone-can-spend script proposed for use is an output
    script consisting of the equivalent of `OP_TRUE`, which can be spent by an input
    with an empty input script.  As Sanders posted this week, using a
    legacy output script means that the child transaction spending it
    has a malleable txid, e.g. any miner can add data to the input
    script to change the child transaction's txid.  That can make it
    unwise to use the child transaction for anything besides fee bumping
    as, even if it gets confirmed, it might get confirmed with a
    different txid that invalidates any grandchild transactions.

    Sanders suggests instead using one of the output scripts that had
    been reserved for future segwit upgrades.  This uses slightly more
    block space---four bytes for segwit versus one byte for bare
    `OP_TRUE`---but eliminates any concerns about transaction
    malleability.  After some discussion on the thread, Sanders later
    proposed offering both: an `OP_TRUE` version for anyone who doesn't
    care about malleability and wants to minimize transaction size, plus a
    segwit version that is slightly larger but does not allow the child
    transaction to be mutated.  Additional discussion in the thread
    focused on choosing the extra bytes for the segwit approach to
    create a memorable [bech32m address][topic bech32]. {% assign timestamp="1:54" %}

## Field Report: A Miniscript Journey

{% include articles/wizardsardine-miniscript.md extrah="#" %} {% assign timestamp="20:17" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.17.1-beta][] is a maintenance release for this LN node
  implementation that includes several bug fixes and minor improvements. {% assign timestamp="37:27" %}

- [Bitcoin Core 26.0rc2][] is a release candidate for the next major
  version of the predominant full node implementation. There's a [testing
  guide][26.0 testing] and a scheduled
  meeting of the [Bitcoin Core PR Review Club][] dedicated to testing on
  15 November 2023. {% assign timestamp="40:05" %}

- [Core Lightning 23.11rc1][] is a release candidate for the next
  major version of this LN node implementation. {% assign timestamp="53:24" %}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28207][] updates the way the mempool is stored on disk
  (which normally happens during node shutdown, but can also be
  triggered by the `savemempool` RPC).  Previously, it was stored in a
  simple serialization of the underlying data.  Now, that serialized
  structure is XOR'd by a random value generated independently by each
  node, obfuscating the data.  It's XOR'd by the same value during
  loading to remove the obfuscation.  The obfuscation prevents someone
  from being able to put certain data in a transaction to get a
  particular sequence of bytes to appear in the saved mempool data, which
  might cause programs like virus scanners to flag the saved mempool
  data as dangerous.  The same method was previously applied to storing
  the UTXO set in [PR #6650][bitcoin core #6650].  Any software that
  needs to read mempool data from disk should be able to trivially apply
  the XOR operation itself, or use the configuration setting
  `-persistmempoolv1` to request saving in the unobfuscated format.
  Note, the backward-compatibility configuration setting is planned to
  be removed in a future release. {% assign timestamp="55:33" %}

- [LDK #2715][] allows a node to optionally accept a smaller value
  [HTLC][topic htlc] than is supposed to be delivered.  This is useful
  when the upstream peer is paying the node through a new [JIT
  channel][topic jit channels], which costs the upstream peer an onchain
  transaction fee that they want to deduct from the amount of the HTLC
  being paid to the node.  See [Newsletter #257][news257 jitfee] for
  LDK's previous implementation of the upstream portion of this feature. {% assign timestamp="1:02:34" %}

{% include snippets/recap-ad.md when="2023-11-16 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28207,6650,2715" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta
[sanders mal]: https://delvingbitcoin.org/t/segwit-ephemeral-anchors/160
[news257 jitfee]: /en/newsletters/2023/06/28/#ldk-2319
