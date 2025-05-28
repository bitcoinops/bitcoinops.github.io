---
title: 'Bitcoin Optech Newsletter #356'
permalink: /en/newsletters/2025/05/30/
name: 2025-05-30-newsletter
slug: 2025-05-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about the possible
effects of attributable failures on LN privacy.  Also included are our
regular sections with selected questions and answers from the Bitcoin
Stack Exchange, announcements of new releases and release candidates,
and descriptions of recent changes to popular Bitcoin infrastructure
software.

## News

- **Do attributable failures reduce LN privacy?** Carla Kirk-Cohen
  [posted][kirkcohen af] to Delving Bitcoin an analysis of the possible
  consequences for the privacy of LN spenders and receivers if the
  network adopts [attributable failures][topic attributable failures],
  particularly telling the spender the amount of time it took to forward
  a payment at each hop.  Citing several papers, she describes two types
  of deanonymization attacks:

  - An attacker operating one or more forwarding nodes uses timing
    data to determine the number of hops used by a payment ([HTLC][topic
    htlc]), which can be combined with knowledge of the topography of
    the public network to narrow the set of nodes that might have been
    the receiver.

  - An attacker uses an IP network traffic forwarder
    ([autonomous system][]) to passively monitor traffic and combines
    that with knowledge of the IP network latency between nodes (i.e.,
    their ping times) plus knowledge of the topography (and other
    characteristics) of the public Lightning Network.

  She then describes possible solutions, including:

  - Encouraging receivers to delay acceptance of an HTLC by a small
    random amount to prevent timing attacks that attempt to identify the
    receiver's node.

  - Encouraging spenders to delay resending failed payments (or
    [MPP][topic multipath payments] parts) by a small random amount and
    by using alternative paths to prevent timing and failure attacks
    attempting to identify the spender's node.

  - Increased payment splitting with MPP to make it harder to guess the
    amount being spent.

  - Allowing spenders to opt-in to having their payments forwarded less
    quickly, as previously proposed (see [Newsletter #208][news208
    slowln]).  This could be combined with HTLC batching, which is
    already implemented in LND (although the addition of a randomized
    delay could enhance privacy).

  - Reducing the precision of attributable failure timestamps to avoid
    penalizing forwarding nodes that add small random delays.

  Discussion from multiple participants evaluated the concerns and
  proposed solutions in more detail, as well as considering other
  possible attacks and mitigations.

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

- [Core Lightning 25.05rc1][] is a release candidate for the next major
  version of this popular LN node implementation.

- [LDK 0.1.3][] and [0.1.4][ldk 0.1.4] are releases of this popular
  library for building LN-enabled applications.  Version 0.1.3, tagged
  as a release on GitHub this week but dated last month, includes the
  fix for a denial-of-service attack.  Version 0.1.4, the latest
  release, "fixes a funds-theft vulnerability in exceeding rare cases".
  Both releases also include other bug fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31622][] psbt: add non-default sighash types to PSBTs and unify sighash type match checking

- [Eclair #3065][] Attributable failures Implements lightning/bolts#1044

- [LDK #3796][] tankyleo/2025-05-dont-dip-into-reserve

- [BIPs #1760][] BIP 53: Disallow 64-byte transactions

- [BIPs #1850][] murchandamus/Revert-bip48-update

- [BIPs #1793][] BIP 443: OP_CHECKCONTRACTVERIFY

{% include snippets/recap-ad.md when="2025-06-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31622,3065,3796,1760,1850,1793" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ldk 0.1.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.3
[ldk 0.1.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.4
[news208 slowln]: /en/newsletters/2022/07/13/#allowing-deliberately-slow-ln-payment-forwarding
[autonomous system]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[kirkcohen af]: https://delvingbitcoin.org/t/latency-and-privacy-in-lightning/1723
