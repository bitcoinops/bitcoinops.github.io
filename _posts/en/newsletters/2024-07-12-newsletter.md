---
title: 'Bitcoin Optech Newsletter #311'
permalink: /en/newsletters/2024/07/12/
name: 2024-07-12-newsletter
slug: 2024-07-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with the summary of
a Bitcoin Core PR Review Club meeting, announcements of new releases and
release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

*No significant news this week was found in any of our [sources][].  For
fun, you may want to check out a recent [interesting transaction][].*

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/30132#l-19FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.2][] is a maintenance version of Bitcoin Core's older
  release series.  Anyone on 26.1 or earlier who is unable or unwilling to
  upgrade to the latest release (27.1) is encouraged to upgrade to this
  maintenance release.

- [LND v0.18.2-beta][] is a minor release to fix a bug affecting users
  of older versions of the btcd backend.

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

- [Rust Bitcoin #2949][] OP_RETURN standardness check

- [BDK #1487][] Add support for custom sorting and deprecate BIP69 <!--
  maybe mention
  https://bitcoinops.org/en/newsletters/2018/10/30/#bip69-discussion and
  https://bitcoinops.org/en/newsletters/2021/06/02/#bolts-872 -->

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2949,1487" %}
[bitcoin core 26.2]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[sources]: /internal/sources/
[interesting transaction]: https://stacker.news/items/600187
[LND v0.18.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.2-beta
