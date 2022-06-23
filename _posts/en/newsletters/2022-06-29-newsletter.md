---
title: 'Bitcoin Optech Newsletter #206'
permalink: /en/newsletters/2022/06/29/
name: 2022-06-29-newsletter
slug: 2022-06-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections summarizing
popular questions and answers from Bitcoin Stack Exchange, announcing
new software releases and release candidates, and describing recent
changes to Bitcoin infrastructure software.

## News

*No significant news this week was found on the Bitcoin-Dev or
Lightning-Dev mailing lists.*

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

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.0-beta][] is a release for the next major version of this
  popular LN node.  It adds for invoice metadata which can be used by
  other programs (and potentially future versions of LND) for [stateless
  invoices][topic stateless invoices] and adds support to the internal
  wallet for receiving and spending bitcoins to [P2TR][topic taproot]
  keyspend outputs, along with experimental [MuSig2][topic musig]
  support.

- [Core Lightning 0.11.2][] is a bug fix release of the LN node.
  Upgrading is "highly recommended" by the Core Lightning developers.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5306][] updates multiple APIs to consistently use the
  name "msat" for millisatoshis and also returns JSON values in those
  fields as numbers.  Some fields are renamed to provide consistencies
  with other fields.  The old behavior is deprecated and so will remain
  available temporarily.

- [LDK #1531][] begins using [anti fee sniping][topic fee sniping]
  for LN funding transactions.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5306,1531" %}
[lnd 0.15.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta
[core lightning 0.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.2
