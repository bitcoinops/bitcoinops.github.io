---
title: 'Bitcoin Optech Newsletter #390'
permalink: /en/newsletters/2026/01/30/
name: 2026-01-30-newsletter
slug: 2026-01-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **Argo: a garbled-circuits scheme for 1000x more efficient off-chain computation**:
  Robin Linus [wrote][delving rl garbled] on Delving Bitcoin about a new
  [paper][iacr le ytl garbled] by Liam Eagen and Ying Tong Lai describing a
  technique that will enable 1000x more efficient [garbled locks][news359 rl
  garbled]. The new technique uses a MAC (message authentication code) that
  encodes the wires of a garbled circuit as EC (elliptic curve) points. The
  MAC is designed to be homomorphic, enabling many operations within the
  garbled circuit to be represented directly as operations on EC points. The
  resulting points will can then be used in circuit verification with native
  bitcoin signatures. The current paper is the first of several pieces needed
  to apply this technique to [BitVM][topic acc]-like constructs on Bitcoin.

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

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-02-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[news359 rl garbled]: /en/newsletters/2025/06/20/#improvements-to-bitvm-style-contracts
[news369 le garbled]: /en/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[delving rl garbled]: https://delvingbitcoin.org/t/argo-a-garbled-circuits-scheme-for-1000x-more-efficient-off-chain-computation/2210
[iacr le ytl garbled]: https://eprint.iacr.org/2026/049.pdf
