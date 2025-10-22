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

- **Detecting block template feerate increases using cluster mempool:** Abubakar
  Sadiq Ismail recently [posted][ismail post] to Delving Bitcoin about the
  possibility of tracking the potential fee increase from each mempool update to
  provide a new block template to miners only when the fee rate improvement
  justifies it. This approach would reduce the number of redundant block
  template builds, which can delay transaction processing and relay to peers.
  The proposal leverages [cluster mempool][topic cluster mempool] to assess
  whether a potential fee rate improvement is available without a rebuild of the
  block template.

  When a new transaction enters the mempool, it connects to zero or more
  existing clusters triggering re-linearization (see Newsletter [#312][news312
  lin] for more information about linearization) of affected clusters to produce
  old (pre-update) and new (post-update) feerate diagrams. The old diagram
  identifies potential chunks for eviction from the block template, while the
  new diagram identifies high-feerate chunks for potential addition. The system
  then follows a 4-step process to simulate the impact:

  1. Eviction: Remove matching chunks from a template copy, updating modified
     fees and sizes.

  2. Naive Merge: Greedily add candidate chunks while respecting block weight
     limits to estimate potential fee gains (ΔF).

  3. Iterative Merge: If the naive estimate is inconclusive, use a more detailed
     simulation to refine ΔF.

  4. Decision: Compare ΔF to a threshold; if it exceeds the threshold, rebuild
     the block template and send it to miners. Otherwise, skip to avoid
     unnecessary computation.

  The current proposal is still in the discussion phase, with no prototype
  available.

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

- **BULL wallet launches:**
  The open source [BULL mobile wallet][bull blog] is built on BDK and supports [descriptors][topic
  descriptors], [labeling][topic wallet labels], and coin selection, Lightning,
  [payjoin][topic payjoin], Liquid, hardware wallets, and watch-only wallets, among
  other features.

- **Sparrow 2.3.0 released:**
  [Sparrow 2.3.0][sparrow github] adds support for sending to [silent
  payment][topic silent payments] addresses and [BIP353][] human-readable
  Bitcoin payment instructions, among other features and bug fixes.

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
[bull blog]: https://www.bullbitcoin.com/blog/bull-by-bull-bitcoin
[sparrow github]: https://github.com/sparrowwallet/sparrow/releases/tag/2.3.0
[ismail post]: https://delvingbitcoin.org/t/determining-blocktemplate-fee-increase-using-fee-rate-diagram/2052
[carla earlier delving post]: /en/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[news312 lin]: /en/newsletters/2024/07/19/#introduction-to-cluster-linearization
