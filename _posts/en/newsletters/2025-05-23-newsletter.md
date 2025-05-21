---
title: 'Bitcoin Optech Newsletter #355'
permalink: /en/newsletters/2025/05/23/
name: 2025-05-23-newsletter
slug: 2025-05-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections describing changes
to services and client software, announcing new releases and release
candidates, and summarizing recent changes to popular Bitcoin
infrastructure software.

## News

*No significant news this week was found in any of our [sources][].*

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.19.0-beta][] is the latest major release of this popular LN
  node.  Its contains many [improvements][lnd rn] and bug fixes,
  including new RBF-based fee bumping for cooperative closes.

- [Core Lightning 25.05rc1][] is a release candidate for the next major
  version of this popular LN node implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32423][] rpc: Undeprecate rpcuser/rpcpassword, store all credentials hashed in memory

- [Bitcoin Core #31444][] cluster mempool: add txgraph diagrams/mining/eviction

- [Core Lightning #8140][] peer storage enable

- [Core Lightning #8136][] channel gossip rework

- [Core Lightning #8266][] reckless: add update command

- [Core Lightning #8021][] interop with eclair

- [Core Lightning #8226][] signmessage (please mention bip137 -harding)

- [LND #9801][] peer+lnd: add new CLI option to control if we D/C on slow pongs

{% include snippets/recap-ad.md when="2025-05-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32423,31444,8140,8136,8266,8021,8226,9801" %}
[lnd 0.19.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[sources]: /en/internal/sources/
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.19.0.md
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
