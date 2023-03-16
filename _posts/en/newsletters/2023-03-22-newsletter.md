---
title: 'Bitcoin Optech Newsletter #243'
permalink: /en/newsletters/2023/03/22/
name: 2023-03-22-newsletter
slug: 2023-03-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with descriptions
of changes to services and client software, plus summaries of notable
changes to popular Bitcoin infrastructure software.

## News

*No significant news this week was found on the Bitcoin-Dev or
Lightning-Dev mailing lists.*

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.16.0-beta.rc3][] is a release candidate for a new major
  version of this popular LN implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #7448][] new tx rebroadcast FIXME:Xekyo, may want to mention https://bitcoinops.org/en/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools or other stuff we've covered about rebroadcasting in Bitcoin Core

- [BDK #793][] is a major restructuring of the library based on the work
  of the [bdk_core sub-project][].  According to the PR description, it
  "maintains the existing wallet API as much as possible and adds very
  little."  Three API endpoints with seemingly minor changes are listed in the PR
  description.

{% include references.md %}
{% include linkers/issues.md v=2 issues="7448,793" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[bdk_core sub-project]: https://bitcoindevkit.org/blog/bdk-core-pt1/
