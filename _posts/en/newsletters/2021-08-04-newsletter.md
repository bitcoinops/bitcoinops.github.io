---
title: 'Bitcoin Optech Newsletter #160'
permalink: /en/newsletters/2021/08/04/
name: 2021-08-04-newsletter
slug: 2021-08-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections describing how you
can prepare for taproot, summarizing the latest releases and release
candidates, and listing notable changes to popular Bitcoin
infrastructure projects.

## News

*No significant news this week.*

## Preparing for taproot #7: multisignatures

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/06-multisignatures.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.10.1rc2][C-Lightning 0.10.1] is a release candidate for
  an upgrade that contains a number of new features, several bug fixes,
  and a few updates to developing protocols (including [dual
  funding][topic dual funding] and [offers][topic offers]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22006][] first tracepoints and documentation on User-Space, Statically Defined Tracing (USDT) FIXME:glozow

- [Eclair #1893][] Different default relay fees for announced and unannounced channels FIXME:bitschmidty

- [Rust-Lightning #967][] valentinewallace/2021-06-keysend FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="22006,1893,967" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1rc2
