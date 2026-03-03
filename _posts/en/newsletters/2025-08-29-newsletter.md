---
title: 'Bitcoin Optech Newsletter #369'
permalink: /en/newsletters/2025/08/29/
name: 2025-08-29-newsletter
slug: 2025-08-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares an update on differential fuzzing of
Bitcoin and LN implementations and links to a new paper about garbled
locks for accountable computing contracts.  Also included are our
regular sections summarizing popular questions and answers from the
Bitcoin Stack Exchange, announcing new releases and release candidates,
and describing notable changes to popular Bitcoin infrastructure
software.

## News

- **Update on differential fuzzing of Bitcoin and LN implementations:**
  Bruno Garcia [posted][garcia fuzz] to Delving Bitcoin to describe
  recent progress and accomplishments of [bitcoinfuzz][], a library and
  related data for [fuzz testing][] Bitcoin-based software and
  libraries.  Accomplishments include the discovery of "over 35 bugs in
  projects such as btcd, rust-bitcoin, rust-miniscript, Embit, Bitcoin
  Core, Core Lightning, [and] LND."  Discovered discrepancies between LN
  implementations has not only revealed bugs but has also driven
  clarifications to the LN specification.  Developers of Bitcoin
  projects are encouraged to investigate making their software a
  supported target for bitcoinfuzz. {% assign timestamp="24:56" %}

- **Garbled locks for accountable computing contracts:** Liam Eagen
  [posted][eagen glock] to the Bitcoin-Dev mailing list about a
  [paper][eagen paper] he's written about a new mechanism for creating
  [accountable computing contracts][topic acc] but based on [garbled
  circuits][].  This is similar (but distinct) from other recent
  independent work on using garbled circuits for BitVM (see [Newsletter
  #359][news359 delbrag]).  Eagen's post claims "the first (in his
  opinion) practical garbled lock whose fraud proof is a single
  signature, which represent over a 550x reduction of onchain data
  compared to BitVM2."  As of this writing, his post has not received
  any public replies. {% assign timestamp="0:58" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Is it possible to recover a private key from an aggregate public key under strong assumptions?]({{bse}}127723)
  Pieter Wuille explains current and hypothetical security assumptions around
  [MuSig2][topic musig] scriptless [multisignatures][topic multisignature]. {% assign timestamp="39:45" %}

- [Are all taproot addresses vulnerable to quantum computing?]({{bse}}127660)
  Hugo Nguyen and Murch point out that even [taproot][topic taproot] outputs
  constructed to be spent only using script paths are [quantum][topic quantum
  resistance] vulnerable. Murch goes on to note "Interestingly, the party that
  generated the output script would be able to show that the internal key was a
  NUMS point and thus prove that a Quantum Decryption has occurred." {% assign timestamp="41:24" %}

- [Why cant we set the chainstate obfuscation key?]({{bse}}127814)
  Ava Chow highlights that the key that obfuscates on-disk contents of the
  `blocksdir` (see [Newsletter #339][news339 blocksxor]) is not the
  same key that obfuscates the `chainstate` contents (see [Bitcoin Core
  #6650][]). {% assign timestamp="45:20" %}

- [Is it possible to revoke a spending branch after a block height?]({{bse}}127683)
  Antoine Poinsot points to a [previous answer]({{bse}}122224) confirming that
  expiring spending conditions, or "inverse timelocks", are not possible and
  perhaps not even desirable. {% assign timestamp="52:09" %}

- [Configure Bitcoin Core to use onion nodes in addition to IPv4 and IPv6 nodes?]({{bse}}127727)
  Pieter Wuille clarifies that setting the `onion` configuration option only
  applies to outbound peer connections. He goes on to outline how to configure
  [Tor][topic anonymity networks] and `bitcoind` for inbound connections. {% assign timestamp="53:45" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.1rc2][] is a release candidate for a maintenance
  version of the predominant full node software. {% assign timestamp="54:22" %}

- [Core Lightning v25.09rc4][] is a release candidate for a new major
  version of this popular LN node implementation. {% assign timestamp="56:45" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31802][] enables inter-process communication (IPC) by default
  (`ENABLE_IPC`), adding the `bitcoin-node` and `bitcoin-gui` multiprocess
  binaries to the release builds on all systems except Windows. This allows an
  external [Stratum v2][topic pooled mining] mining service that creates,
  manages and submits block templates to experiment with the multiprocess layout
  without custom builds. For additional context on the multiprocess project and
  the `bitcoin-node` binary, see Newsletters [#99][news99 ipc], [#147][news147
  ipc], [#320][news320 ipc], [#323][news323 ipc]. {% assign timestamp="57:37" %}

- [LDK #3979][] adds splice-out support, enabling an LDK node to both initiate a
  splice-out transaction, and accept requests from a counterparty. This
  completes LDK’s [splicing][topic splicing] implementation, as [LDK #3736][]
  already added splice-in support. This PR adds a `SpliceContribution` enum that
  covers both in and out scenarios and ensures that the output values of a
  splice-out transaction don’t exceed the user’s channel balance after
  accounting for fees and reserve requirements. {% assign timestamp="1:04:46" %}

- [LND #10102][] adds a `gossip.ban-threshold` option (100 is the default, 0
  disables it) that allows users to configure the score threshold at which a
  peer is banned for sending invalid [gossip][topic channel announcements]
  messages. The peer banning system was previously introduced and covered in
  [Newsletter #319][news319 ban]. This PR also resolves an issue where
  unnecessary node and [channel announcement][topic channel announcements]
  messages were sent in response to a backlog gossip query request. {% assign timestamp="1:06:19" %}

- [Rust Bitcoin #4907][] introduces script tagging by adding a new generic tag
  parameter `T` to `Script` and `ScriptBuf`, and defines the type aliases
  `ScriptPubKey`, `ScriptSig`, `RedeemScript`, `WitnessScript`, and `TapScript`
  which are backed by a sealed `Tag` trait for compile-time role safety. {% assign timestamp="1:07:04" %}

{% include snippets/recap-ad.md when="2025-09-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31802,3979,10102,4907,6650,3736" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09rc4]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc4
[garcia fuzz]: https://delvingbitcoin.org/t/the-state-of-bitcoinfuzz/1946
[bitcoinfuzz]: https://github.com/bitcoinfuzz
[fuzz testing]: https://en.wikipedia.org/wiki/Fuzzing
[eagen glock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Aq_-LHZtVdSN5nODCryicX2u_X1yAQYurf9UDZXDILq6s4grUOYienc4HH2xFnAohA69I_BzgRCSKdW9OSVlSU9d1HYZLrK7MS_7wdNsLmo=@protonmail.com/
[eagen paper]: https://eprint.iacr.org/2025/1485
[garbled circuits]: https://en.wikipedia.org/wiki/Garbled_circuit
[news359 delbrag]: /en/newsletters/2025/06/20/#improvements-to-bitvm-style-contracts
[news339 blocksxor]: /en/newsletters/2025/01/31/#how-does-the-blocksxor-switch-that-obfuscates-the-blocks-dat-files-work
[news99 ipc]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 ipc]: /en/newsletters/2021/05/05/#bitcoin-core-19160
[news320 ipc]: /en/newsletters/2024/09/13/#bitcoin-core-30509
[news323 ipc]: /en/newsletters/2024/10/04/#bitcoin-core-30510
[news319 ban]: /en/newsletters/2024/09/06/#lnd-9009
