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

- [Core Lightning 25.09.1][] is a maintenance release for the current major
  version of this popular LN node that includes several bug fixes.

- [Bitcoin Core 28.3][] is a maintenance release for the previous release series
  of the predominant full node implementation. It contains multiple bug fixes,
  and also includes the new defaults for `blockmintxfee`, `incrementalrelayfee`,
  and `minrelaytxfee`.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33157][] optimizes the memory usage in [cluster
  mempool][topic cluster mempool] by introducing a `SingletonClusterImpl` type
  for single-transaction clusters and by compacting several `TxGraph` internals.
  This PR also adds a `GetMainMemoryUsage()` function to estimate `TxGraph`’s
  memory usage.

- [Bitcoin Core #29675][] introduces support for receiving and spending
  [taproot][topic taproot] outputs controlled by [MuSig2][topic musig] aggregate
  keys on wallets with imported `musig(0)` [descriptors][topic descriptors]. See
  [Newsletter #366][news366 musig2] for the earlier enabling work.

- [Bitcoin Core #33517][] and [Bitcoin Core #33518][] reduce the CPU consumption
  of multiprocess logging by adding log levels and categories, which avoids
  serializing discarded inter-process communication (IPC) log messages. The
  author found that before this PR, logging accounted for 50% of his [Stratum
  v2][topic pooled mining] client application's CPU time and 10% of the Bitcoin
  node's processes. It has now dropped to near zero percent. See Newsletters
  [#323][news323 ipc] and [#369][news369 ipc] for additional context.

- [Eclair #2792][] adds a new [MPP][topic multipath payments] splitting
  strategy, `max-expected-amount`, which allocates parts across routes by
  factoring in each route’s capacity and success probability. A new
  `mpp.splitting-strategy` configuration option is added with three options:
  `max-expected-amount`, `full-capacity`, which considers only a route’s
  capacity, and `randomize` (default), which randomizes the splitting. The
  latter two are already accessible through the boolean config
  `randomize-route-selection`. This PR adds enforcement of [HTLC][topic htlc]
  maximum limits on remote channels.

- [LDK #4122][] enables queuing a [splice][topic splicing] request while the
  peer is offline, starting negotiation upon reconnection. For [zero-conf][topic
  zero-conf channels] splices, LDK now sends a `splice_locked` message to the
  peer immediately after `tx_signatures` are exchanged. LDK will also now queue
  a splice during a concurrent splice and attempt it as soon as the other one
  locks.

- [LND #9868][] defines an `OnionMessage` type and adds two new RPC endpoints:
  `SendOnionMessage`, which sends an onion message to a specific peer, and
  `SubscribeOnionMessages`, which subscribes to a stream of incoming onion
  messages. These are the first steps required to support [BOLT12 offers][topic
  offers].

- [LND #10273][] fixes an issue where LND would crash when the legacy sweeper,
  `utxonursery`, attempted to sweep an [HTLC][topic htlc] with a
  [locktime][topic timelocks] (height hint) of 0. Now, LND successfully sweeps
  those HTLCs by deriving the height hint from the channel’s close height.

{% include snippets/recap-ad.md when="2025-10-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33157,29675,33517,33518,2792,4122,9868,10273" %}
[carla post]: https://delvingbitcoin.org/t/outgoing-reputation-simulation-results-and-updates/2069
[channel jamming bolt]: https://github.com/lightning/bolts/pull/1280
[resource attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[sink attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[bull blog]: https://www.bullbitcoin.com/blog/bull-by-bull-bitcoin
[sparrow github]: https://github.com/sparrowwallet/sparrow/releases/tag/2.3.0
[ismail post]: https://delvingbitcoin.org/t/determining-blocktemplate-fee-increase-using-fee-rate-diagram/2052
[carla earlier delving post]: /en/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[Core Lightning 25.09.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.09.1
[Bitcoin Core 28.3]: https://bitcoincore.org/en/2025/10/17/release-28.3/
[news366 musig2]: /en/newsletters/2025/08/08/#bitcoin-core-31244
[news323 ipc]: /en/newsletters/2024/10/04/#bitcoin-core-30510
[news369 ipc]: /en/newsletters/2025/08/29/#bitcoin-core-31802
[news312 lin]: /en/newsletters/2024/07/19/#introduction-to-cluster-linearization
