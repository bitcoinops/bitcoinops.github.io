---
title: 'Bitcoin Optech Newsletter #384'
permalink: /en/newsletters/2025/12/12/
name: 2025-12-12-newsletter
slug: 2025-12-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter discloses vulnerabilities in LND and describes a project
for running a virtual machine in an embedded secure element. Also included are
our regular sections describing changes to services and client software,
summarizing popular questions and answers of the Bitcoin Stack Exchange, and
examining recent changes to popular Bitcoin infrastructure software.

## News

- **Critical vulnerabilities fixed in LND 0.19.0:** Matt Morehouse
  [posted][morehouse delving] to Delving Bitcoin about critical vulnerabilities
  fixed in LND 0.19.0. In this disclosure, there are three vulnerabilities
  mentioned including one denial-of-service (DoS) and two theft-of-funds.

  - *Message processing out-of-memory DoS vulnerability:* This [DoS vulnerability][lnd vln1] took
    advantage of LND allowing as many peers as there were available file
    descriptors. The attacker could open multiple connections to the victum
    and spam 64 KB `query_short_channel_ids` messages while keeping the
    connection open until LND ran out of memory. The mitigation for this
    vulnerability was implemented in LND 0.19.0 on March 12th, 2025.

  - *Loss of funds due to new excessive failback vulnerability:* [This attack][lnd vln2] is a variant of the [excessive
    failback bug][morehouse failback bug], and while the original fix for the
    failback bug was made in LND 0.18.0, a minor variant remained when the
    channel was force closed using LND’s commitment instead of the attacker’s.
    The mitigation for this vulnerability was implemented in LND 0.19.0 on March
    20th, 2025.

  - *Loss of funds vulnerability in HTLC sweeping:* This [theft-of-funds vulnerability][lnd vln3] took
    advantage of weaknesses in LND's sweeper system, which enabled an attacker
    to stall LND's attempts at claiming expired HTLC's on chain. After stalling
    for 80 blocks then the attacker could steal essentially the whole channel
    balance.

  Morehouse urges users to upgrade to [LND 0.19.0][lnd version] or higher to
  avoid denial of service and loss of funds.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

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

## Happy holidays!

This is Bitcoin Optech's final regular newsletter of the year.  On
Friday, December 19th, we'll publish our eighth annual year-in-review
newsletter.  Regular publication will resume on Friday, January 2nd.

{% include snippets/recap-ad.md when="2025-12-09 17:30" %}
{% include references.md %}
[morehouse delving]: https://delvingbitcoin.org/t/disclosure-critical-vulnerabilities-fixed-in-lnd-0-19-0/2145
[lnd vln1]: https://morehouse.github.io/lightning/lnd-infinite-inbox-dos/
[lnd vln2]: https://morehouse.github.io/lightning/lnd-excessive-failback-exploit-2/
[lnd vln3]: https://morehouse.github.io/lightning/lnd-replacement-stalling-attack/
[lnd version]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[morehouse failback bug]: /en/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
