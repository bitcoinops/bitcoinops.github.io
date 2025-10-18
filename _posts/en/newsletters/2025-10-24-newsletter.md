---
title: 'Bitcoin Optech Newsletter #377'
permalink: /en/newsletters/2025/10/24/
name: 2025-10-24-newsletter
slug: 2025-10-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **Delving thread Determining BlockTemplate Fee Increase Using Fee Rate Diagram:** A suggested title for this
  news item could be "Detecting block template feerate increases using cluster
  mempool" https://delvingbitcoin.org/t/determining-blocktemplate-fee-increase-using-fee-rate-diagram/2052

- **Delving thread on optimized worst block:** https://delvingbitcoin.org/t/worst-block-validation-time-inquiry/711/83

- **Channel Jamming Mitigation Simulation Results and Updates:** Carla Kirk-Cohen [posted][carla post]
  to Delving Bitcoin about their simulation results and updates with the reputation algorithm
  for their [channel jamming mitigation proposal][channel jamming bolt]. Some of the notable changes are
  that reputation is tracked for outgoing channels, and resources are limited on incoming channels.

  Using their simulator they have run both the [resource][resource attacks] and [sink][sink attacks] attacks.
  They found that with the new updates protection against resource attacks remain intact and with sink attacks
  attacking nodes will be quickly cut off when they misbehave. It is noted that if an attacker builds a
  reputation and then targets a chain of nodes, only the last node is compensated. But there is a
  significant cost to an attacker to target multiple nodes.

  They think that the [channel jamming][topic channel jamming attacks] mitigation has reached a point
  where it is good enough and encourages readers to try their simulator to test out attacks.
  

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

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

{% include snippets/recap-ad.md when="2025-10-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[carla post]: https://delvingbitcoin.org/t/outgoing-reputation-simulation-results-and-updates/2069
[channel jamming bolt]: https://github.com/lightning/bolts/pull/1280
[resource attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[sink attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
