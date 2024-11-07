---
title: 'Bitcoin Optech Newsletter #328'
permalink: /en/newsletters/2024/11/08/
name: 2024-11-08-newsletter
slug: 2024-11-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a vulnerability affecting old versions
of Bitcoin Core and includes our regular sections summarizing a Bitcoin
Core PR Review Club meeting, announcing new releases and release
candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Disclosure of a vulnerability affecting Bitcoin Core versions before 25.1:**
  Antoine Poinsot [announced][poinsot stall] to the Bitcoin-Dev
  mailing list the final vulnerability disclosure predating Bitcoin
  Core's new disclosure policy (see [Newsletter #306][news306
  disclosure]).  The [detailed vulnerability report][stall vuln] notes
  that Bitcoin Core versions 25.0 and earlier were susceptible to an
  inappropriate P2P protocol response that would delay a node from
  re-requesting a block for up to 10 minutes.  The solution was to allow
  blocks to "be requested concurrently from up to 3 high-bandwidth
  compact block peers, one of which is required to be an outbound
  connection." Versions 25.1 and later include the fix.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/30793#l-16FIXME"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 27.2][] is a maintenance update for the previous release
  series containing bug fixes.  Any users who will not soon upgrade to
  the latest version, [28.0][], should consider updating at least to
  this new maintenance release.

- [Libsecp256k1 0.6.0][] is a release of this library of Bitcoin-related
  cryptographic operations.  "This release adds a [MuSig2][topic musig]
  module, adds a significantly more robust method to clear secrets from
  the stack, and removes the unused `secp256k1_scratch_space` functions."

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [LDK #3360][] adds rebroadcasting of `channel_announcement` messages every six
  blocks for one week after the public channel is confirmed. This removes the
  dependency on peers for rebroadcast and ensures that channels are always
  visible to the network.

- [LDK #3207][] introduces support for including invoice requests in the [async
  payments’][topic async payments] [onion message][topic onion messages] when
  paying static [BOLT12][topic offers] invoices as an always online sender. This
  was previously missing from the PR covered in Newsletter [#321][news321
  invreq]. The inclusion of invoice requests in payment onions also extends to
  retries, see Newsletter [#321][news321 retry].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3360,3207" %}
[news306 disclosure]: /en/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[stall vuln]: https://bitcoincore.org/en/2024/11/05/cb-stall-hindering-propagation/
[poinsot stall]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uJpfg8UeMOfVUATG4YRiGmyz5MALtZq68FCBXA6PT-BNstodivpqQfDxD1JAv5Qny_vuNr-A1m8jIDNHQLhAQt8hj8Ee9OT6ZFE5Z16O97A=@protonmail.com/
[bitcoin core 27.2]: https://bitcoincore.org/en/2024/11/04/release-27.2/
[28.0]: https://bitcoincore.org/en/2024/10/02/release-28.0/
[libsecp256k1 0.6.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.6.0
[news321 invreq]: /en/newsletters/2024/09/20/#ldk-3140
[news321 retry]: /en/newsletters/2024/09/20/#ldk-3010
