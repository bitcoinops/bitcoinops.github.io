---
title: 'Bitcoin Optech Newsletter #402'
permalink: /en/newsletters/2026/04/24/
name: 2026-04-24-newsletter
slug: 2026-04-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes Hornet Node's work on a declarative executable
specification of consensus rules and summarizes a discussion about onion message
jamming in the Lightning Network. Also included are our regular sections with
selected questions and answers from the Bitcoin Stack Exchange, announcements of
new releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

FIXME:bitschmidty

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why did BIP342 replace CHECKMULTISIG with a new opcode, instead of just removing FindAndDelete from it?]({{bse}}130665)
  Pieter Wuille explains that the replacement of `OP_CHECKMULTISIG` with
  `OP_CHECKSIGADD` in [tapscript][topic tapscript] was necessary to enable batch
  verification of [schnorr][topic schnorr signatures] signatures (see
  [Newsletter #46][news46 batch]) in a potential future protocol change.

- [Does SIGHASH_ANYPREVOUT commit to the tapleaf hash or the full taproot merkle path?]({{bse}}130637)
  Antoine Poinsot confirms that [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
  signatures currently commit only to the tapleaf hash, not the full merkle path
  in the [taproot][topic taproot] tree. However, this design is under discussion
  as one BIP co-author has suggested committing to the full merkle path instead.

- [What does the BIP86 tweak guarantee in a MuSig2 Lightning channel, beyond address format?]({{bse}}130652)
  Ava Chow points out that the tweak prevents the use of hidden script paths
  because [MuSig2's][topic musig] signing protocol requires all participants to
  apply the same [BIP86][] tweak for signature aggregation to succeed. If one
  party attempts to use a different tweak, such as one derived from a hidden
  script tree, their partial signature won't aggregate into a valid final
  signature.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-04-28 16:30" %}
{% include references.md %}
[news46 batch]: /en/newsletters/2019/05/14/#new-script-based-multisig-semantics
