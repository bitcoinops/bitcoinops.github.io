---
title: 'Bitcoin Optech Newsletter #279'
permalink: /en/newsletters/2023/11/29/
name: 2023-11-29-newsletter
slug: 2023-11-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an update to the liquidity
advertisements specification.  Also included are our regular sections
with selected questions and answers from the Bitcoin Stack Exchange,
announcements of new releases and release candidates, and descriptions of
notable changes to popular Bitcoin infrastructure software.

## News

- **Update to the liquidity ads specification:** Lisa Neigut
  [posted][neigut liqad] to the Lightning-Dev mailing list to announce
  an update to the specification for [liquidity advertisements][topic
  liquidity advertisements].  That feature, implemented in Core
  Lightning and currently being worked on for Eclair, allows a node to
  announce that it is willing to contribute funds to a [dual-funded
  channel][topic dual funding].  If another node accepts the offer by
  requesting to open a channel, the requesting node must pay the
  offering node an upfront fee.  This allows a node needing incoming
  liquidity (e.g., a merchant) to find well-connected peers that can
  provide that liquidity at a market rate, entirely using open source
  software and the decentralized LN gossip protocol.

    The updates include a few structural changes plus increased
    flexibility to the contract duration and forwarding fee ceiling.
    The post received several replies on the mailing list and additional
    changes to the [specification][bolts #878] are expected.  Neigut's
    post also notes that the current construction of liquidity
    advertisements and channel announcements makes it theoretically
    possible to cryptographically prove one case where a party is
    violating its contract.  It's an open problem to design an actual
    compact fraud proof that could be used in a bond contract to
    incentivize contract compliance.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.11][] is a release of the next major version of
  this LN node implementation.  It provides additional flexibility to the
  _rune_ authentication mechanism, improved backup verification, new
  and features for plugins.

- [Bitcoin Core 26.0rc3][] is a release candidate for the next major
  version of the predominant full-node implementation. There's a [testing
  guide][26.0 testing] available.

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Rust Bitcoin #2213][] Fix InputWeightPrediction::P2WPKH_MAX constant DER sig length FIXME:Murchandamus

- [BDK #1190][] adds a new `Wallet::list_output` method that retrieves
  all outputs in the wallet, both spent outputs and unspent outputs.
  Previously, it was easy to get a list of unspent outputs but difficult
  to get a list of spent outputs.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2213,1190,878" %}
[bitcoin core 26.0rc3]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11]: https://github.com/ElementsProject/lightning/releases/tag/v23.11
[neigut liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004217.html
