---
title: 'Bitcoin Optech Newsletter #377'
permalink: /en/newsletters/2025/10/24/
name: 2025-10-24-newsletter
slug: 2025-10-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an idea to use cluster mempool to detect
block template feerate increases and shares an update on channel jamming
mitigation simulation results. Also included are our regular sections
describing recent changes to services and client software, announcing
new releases and release candidates, and summarizing notable changes to
popular Bitcoin infrastructure software.

## News


- **Channel jamming mitigation simulation results and updates:** Carla
  Kirk-Cohen, in collaboration with Clara Shikhelman and elnosh, [posted][carla
  post] to Delving Bitcoin about their simulation results and updates with the
  reputation algorithm for their [channel jamming mitigation proposal][channel
  jamming bolt]. Some notable changes are that reputation is tracked for
  outgoing channels, and resources are limited on incoming channels. Bitcoin
  Optech has previously covered [lightning channel jamming attacks][topic
  channel jamming attacks] and an earlier [Delving Bitcoin post][carla earlier
  delving post] from Carla. Read those posts to gain a baseline understanding of
  lightning channel jamming.

  In this latest update, they used their simulator to run both the
  [resource][resource attacks] and [sink][sink attacks] attacks. They found that
  with the new updates, protection against resource attacks remains intact, and
  with sink attacks, attacking nodes will be quickly cut off when they
  misbehave. It is noted that if an attacker builds a reputation and then
  targets a chain of nodes, only the last node is compensated. But there is a
  significant cost to an attacker to target multiple nodes.

  The write-up concludes that [channel jamming attack][topic channel jamming
  attacks] mitigation has reached a point where it is good enough and encourages
  readers to try their simulator to test out attacks.

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
[carla post]: https://delvingbitcoin.org/t/outgoing-reputation-simulation-results-and-updates/2069
[channel jamming bolt]: https://github.com/lightning/bolts/pull/1280
[resource attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[sink attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
