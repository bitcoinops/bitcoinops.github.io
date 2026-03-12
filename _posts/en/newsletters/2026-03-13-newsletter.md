---
title: 'Bitcoin Optech Newsletter #396'
permalink: /en/newsletters/2026/03/13/
name: 2026-03-13-newsletter
slug: 2026-03-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a collision-resistant hash function using
Bitcoin Script and summarizes continued discussion of Lightning Network traffic
analysis. Also included are our regular sections announcements of new releases
and release candidates and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Collision-resistant hash function for Bitcoin Script**: Robin Linus
  [posted][bino del] to Delving Bitcoin about Binohash, a new collision-resistant hash
  function using Bitcoin Script. In the [paper][bino paper] he shared, Linus states that
  Binohash allows for limited transaction introspection without requiring new consensus
  changes. In turn, this enables protocols like [BitVM][topic acc] bridges with
  [covenant][topic covenants]-like functionalities for trustless introspection, without the need to
  rely on trusted oracles.

  The proposed hash function indirectly derives a transaction digest following a
  two-step process:

  - Pin transaction fields: Transaction fields are bound by requiring a spender
    to solve multiple signature puzzles, each demanding `W1` bits of work, making
    unauthorized modification computationally expensive.

  - Derive the hash: The hash is computed by leveraging the behavior of
    `FindAndDelete` in legacy `OP_CHECKMULTISIG`. A nonce pool is initialized
    with `n` signatures. A spender produces a subset with `t` signatures, which are
    removed from the pool using `FindAndDelete`, and then computes a sighash of the
    remaining signatures. The process is iterated until a sighash produces a puzzle
    signature matching requirements. The resulting digest, the Binohash, will be composed of the `t` indices of the winning subset.

  The output digest has three properties relevant to Bitcoin applications: it
  can be extracted and verified entirely within Bitcoin Script; it provides
  approximately 84 bits of collision resistance; and it is [Lamport-signable][lamport wiki],
  allowing it to be committed to inside a BitVM program. Together these
  properties mean developers can construct protocols that reason about
  transaction data on-chain today, using only existing script primitives.

- **Continued discussion of Gossip Observer traffic analysis tool**: In November, Jonathan
  Harvey-Buschel [announced][news 381 gossip observer] Gossip Observer, a tool
  for collecting LN gossip traffic and computing metrics to evaluate replacing
  message flooding with a set-reconciliation-based protocol.

  Since then, Rusty Russell and others [joined the discussion][gossip observer
  delving] on how best to transmit sketches. Russell suggested encoding
  improvements for efficiency, including skipping the `GETDATA` round-trip by
  using the block number suffix as the set key for a message, avoiding an
  unnecessary request/response exchange when the receiver can already infer the
  relevant block context.

  In response, Harvey-Buschel [updated][gossip observer github] his version of
  Gossip Observer that is running and continuing to collect data. He
  [posted][gossip observer update] analysis of average daily messages, a model of
  detected communities, and propagation delays.

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

{% include snippets/recap-ad.md when="2026-03-17 16:30" %}
{% include references.md %}
[bino del]: https://delvingbitcoin.org/t/binohash-transaction-introspection-without-softforks/2288
[bino paper]: https://robinlinus.com/binohash.pdf
[lamport wiki]: https://en.wikipedia.org/wiki/Lamport_signature
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
[gossip observer update]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105/23
[gossip observer github]: https://github.com/jharveyb/gossip_observer
[news 381 gossip observer]: /en/newsletters/2025/11/21/#ln-gossip-traffic-analysis-tool-announced
