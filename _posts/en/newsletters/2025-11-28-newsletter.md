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
  and lowered the amount of data requested from his peers.

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
  to familiarize themselves with the proposal and provide feedback.

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
