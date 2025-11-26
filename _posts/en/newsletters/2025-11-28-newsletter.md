---
title: 'Bitcoin Optech Newsletter #382'
permalink: /en/newsletters/2025/11/28/
name: 2025-11-28-newsletter
slug: 2025-11-28-newsletter
type: newsletter
layout: newsletter
lang: en
---

FIXME:bitschmidty

## News

- **Stats on compact block reconstructions updates:** 0xB10C posted to
  [Delving Bitcoin][0xb10c delving] about his stats on compact block
  reconstruction. This is an update to a previous [optech
  post][compact block optech], since then 0xB10C has provided three updates
  on compact block reconstruction. He has also tracking the average size of
  requested transactions in kB, because of the [previous
  post][david delving post] by Gumberg. The new chart is similar looking as
  the share of compact block reconstructions without request transactions
  chart and can be found directly under them in each post.

  0xB10C updated one of his nodes named bob to the master branch and found
  that because there were no existing sub-1 sat/vbyte transactions there was
  no improvment for the first few days, afterwards block reconstruction rates
  improved significantly. We could also see an improvement in the average
  size of reqeuested transactions in kB.

  In the [third update][0xb10c thrid update] he had posted, 0xB10C mentions
  that he swiched the nodes to run with a lowered minrelayfee. This caused
  most the nodes to have better reconstruction rate and less data requested
  from peers. He also mentions in hindsight it would have been better to not
  have updated all the nodes and to have kept some on v29. This would have
  made it easier to compare between node versions and settings.

  Overall updating to the latest version of Bitcoin Core and dropping the
  minrelayfee has improved block reconstruction rates and lowered the amount
  of data requested from peers.

- **Motion to activate BIP3**: Murch [posted][murch ml] to the Bitcoin-Dev
  Mailing List a formal motion to activate [BIP3][]. The goal of this
  improvement proposal is to provide new guidelines for the preparation of new
  BIPS, thus replacing [BIP2][].

  According to the author, the proposal, which has been in "Proposed" status for
  more than 7 months, has no unaddressed objections and a growing list of
  contributors left an ACK on [BIPs #1820][]. Thus, following the procedure
  expressed by BIP2 for activating Process BIPs, he conceded 4 weeks, untill
  2025-12-02, to evaluate the proposal, ACK the PR or to state concerns and
  raise objections. After that date BIP3 will replace BIP2 as BIPs Process.

  Some small objections have been raised in the thread, mainly related to the
  use of AI/LLM tools in the BIPs submission process, which are currently being
  addressed by the author. We invite our readers to familiarize with the
  proposal and provide feedback.

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
  tradeoffs of using OP_RETURN over the inscription scheme.

- [Increasing probability of block hash collisions when difficulty is too high]({{bse}}129265)
  Vojtěch Strnad notes the extreme unlikelihood of a blockhash collision (unless SHA256 is
  broken) and goes on to explain why the hash of a block header serves as block
  identifiers.

- [What is the purpose of the initial 0x04 byte in all extended public and private keys?]({{bse}}129178)
  Pieter Wuille points out that these 0x04 prefixes are simply a coincidence
  based on their respective target Base58 encodings.

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

{% include snippets/recap-ad.md when="2025-12-02 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1820" %}
[0xb10c delving]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/35
[compact block optech]: /en/newsletters/2025/08/01/#testing-compact-block-prefilling
[david delving post]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[0xb10c thrid update]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/44
[murch ml]: https://groups.google.com/g/bitcoindev/c/j4_toD-ofEc