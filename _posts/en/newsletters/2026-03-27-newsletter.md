---
title: 'Bitcoin Optech Newsletter #398'
permalink: /en/newsletters/2026/03/27/
name: 2026-03-27-newsletter
slug: 2026-03-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with selected questions
and answers from the Bitcoin Stack Exchange, announcements of new releases and
release candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

*No significant news this week was found in any of our [sources][].*

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What is meant by "Bitcoin doesn't use encryption"?]({{bse}}130576)
  Pieter Wuille distinguishes encryption for purposes concealing data from
  unauthorized parties (which Bitcoin's ECDSA cannot be used for) from the
  digital signatures Bitcoin uses for verification and authentication.

- [When and why did Bitcoin Script shift to a commit–reveal structure?]({{bse}}130580)
  User bca-0353f40e explains the evolution from Bitcoin's original approach of
  users paying directly to public keys toward P2PKH and then to P2SH, [segwit][topic
  segwit] and [taproot][topic taproot] approaches, where spending conditions are
  committed to in the output and only revealed when spent.

- [Does P2TR-MS (Taproot M-of-N multisig) leak public keys?]({{bse}}130574)
  Murch confirms that a single-leaf taproot scriptpath multisig exposes all
  eligible public keys on spend since OP_CHECKSIG and OP_CHECKSIGADD both
  require that the public key corresponding to the signature is present.

- [Does OP_CHECKSIGFROMSTACK intentionally allow cross-UTXO signature reuse?]({{bse}}130598)
  User bca-0353f40e explains that [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] ([BIP348][]) deliberately does not bind signatures to
  specific inputs which allows CSFS to be combined with other [convenant][topic
  covenants] opcodes to enable re-bindable signatures, the mechanism
  underlying [LN-Symmetry][topic eltoo].

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

{% include snippets/recap-ad.md when="2026-03-31 16:30" %}
{% include references.md %}
[sources]: /en/internal/sources/
