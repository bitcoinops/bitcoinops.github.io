---
title: 'Bitcoin Optech Newsletter #143'
permalink: /en/newsletters/2021/04/07/
name: 2021-04-07-newsletter
slug: 2021-04-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter contains our regular sections with announcements
of new releases and release candidates, plus notable changes to popular
Bitcoin infrastructure projects.

## News

*No noteworthy news to report this week.*

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*


- [C-Lightning 0.10.0][C-Lightning 0.10.0] is the newest major release
  of this LN node software. It contains a number of enhancements to its
  API and includes experimental support for [dual funding][topic dual
  funding].

- [BTCPay 1.0.7.2][] fixes minor issues discovered after last
  week's security release.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #20286][] rpc: deprecate `addresses` and `reqSigs` from rpc outputs FIXME:Xekyo

- [Bitcoin Core #20197][] p2p: protect onions in AttemptToEvictConnection(), add eviction protection test coverage FIXME:jonatack

- [Eclair #1750][] Remove Electrum support FIXME:bitschmidty

- [Eclair #1751][] Add blocking option to payinvoice API FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="20286,20197,1750,1751" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0
[btcpay 1.0.7.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.2
