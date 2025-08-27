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
  supported target for bitcoinfuzz.

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
  any public replies.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.1rc2][] is a release candidate for a maintenance
  version of the predominant full node software.

- [Core Lightning v25.09rc4][] is a release candidate for a new major
  version of this popular LN node implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31802][] Add bitcoin-{node,gui} to release binaries for IPC

- [LDK #3979][] Add splice-out support

- [LND #10102][] Catch bad gossip peer and fix `UpdatesInHorizon`

- [Rust Bitcoin #4907][] Introduce script tagging

{% include snippets/recap-ad.md when="2025-09-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31802,3979,10102,4907" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09rc4]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc4
[garcia fuzz]: https://delvingbitcoin.org/t/the-state-of-bitcoinfuzz/1946
[bitcoinfuzz]: https://github.com/bitcoinfuzz
[fuzz testing]: https://en.wikipedia.org/wiki/Fuzzing
[eagen glock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Aq_-LHZtVdSN5nODCryicX2u_X1yAQYurf9UDZXDILq6s4grUOYienc4HH2xFnAohA69I_BzgRCSKdW9OSVlSU9d1HYZLrK7MS_7wdNsLmo=@protonmail.com/
[eagen paper]: https://eprint.iacr.org/2025/1485
[garbled circuits]: https://en.wikipedia.org/wiki/Garbled_circuit
[news359 delbrag]: /en/newsletters/2025/06/20/#improvements-to-bitvm-style-contracts
