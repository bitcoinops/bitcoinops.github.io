---
title: 'Bitcoin Optech Newsletter #373'
permalink: /en/newsletters/2025/09/26/
name: 2025-09-26-newsletter
slug: 2025-09-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a vulnerability affecting old versions of
Eclair and summarizes research into full node feerate settings.  Also included
are our regular sections summarizing popular questions and answers on the
Bitcoin Stack Exchange, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Eclair vulnerability:** Matt Morehouse [posted][morehouse eclair] to
  Delving Bitcoin to announce the [responsible disclosure][topic
  responsible disclosures] of a vulnerability affecting older versions
  of Eclair.  All Eclair users are recommended to upgrade to version
  0.12 or greater.  The vulnerability allowed an attacker to broadcast
  an old commitment transaction to steal all current funds from a
  channel.  In addition to fixing the vulnerability, Eclair developers
  added a comprehensive testing suite designed to catch similar problems.

- **Research into feerate settings:** Daniela Brozzoni [posted][brozzoni
  feefilter] to Delving Bitcoin the results of a scan of almost 30,000
  full nodes that were accepting incoming connections.  Each node was
  queried for its [BIP133][] fee filter, which indicates the lowest
  feerate at which it will currently accept relayed unconfirmed
  transactions.  When node mempools aren't full, this is
  the node's [default minimum transaction relay feerate][topic default
  minimum transaction relay feerates].  Her results indicate most nodes
  used the default of 1 sat/vbyte (s/v), which has long been the default
  in Bitcoin Core.  About 4% of nodes used 0.1 s/v, the default for the
  upcoming 30.0 version of Bitcoin Core, and about 8% of nodes didn't
  respond to the query---indicating that they might be spy nodes.

  A small percentage of the nodes used a feefilter value of 9,170,997
  (10,000 s/v), which developer 0xB10C [noted][0xb10c feefilter] is the
  value Bitcoin Core sets, through rounding, when the node is more than
  100 blocks behind the tip of the chain and is focused on receiving
  block data rather than transactions that might be confirmed in later
  blocks.

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

{% include snippets/recap-ad.md when="2025-09-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[morehouse eclair]: https://delvingbitcoin.org/t/disclosure-eclair-preimage-extraction-exploit/2010
[brozzoni feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989
[0xb10c feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989/3
