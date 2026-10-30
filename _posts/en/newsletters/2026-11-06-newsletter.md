---
title: 'Bitcoin Optech Newsletter #430'
permalink: /en/newsletters/2026/11/06/
name: 2026-11-06-newsletter
slug: 2026-11-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **Continued discussion of TCP hole punching for home nodes:** Following
  our May [summary][news406 holepunch] of 0xB10C's Delving Bitcoin thread on
  using hole punching to let nodes behind home routers accept connections
  from each other, 0xB10C [posted][b10c holepunch recap] that work has
  resumed on a specification and an experimental Bitcoin Core implementation.
  Home nodes can usually only make outbound connections, and turning on
  NAT-PMP port mapping by default in Bitcoin Core 30.0 did not make many more
  of them reachable as hoped. Hole punching, in which two home nodes open
  connections to each other at the same moment so that each router lets the
  other's traffic through, would be a best-effort supplement to port
  forwarding. More reachable honest nodes would make it harder for attackers,
  whose nodes are easier to reach, to fill a node's outbound connection
  slots.

  0xB10C recapped the four designs discussed so far and
  [proposed][b10c holepunch option6] a fifth that needs no coordinator: a
  node announces its punchable address and a temporary public key in a new
  [addr v2][topic addr v2] type, and each pair of nodes derives the same
  candidate list and punch timing from their shared secret and each new
  block. After finding that unreachable nodes receive such announcements far
  less reliably than listening nodes, he sketched a "message board"
  alternative in which listening nodes hold the verified addresses of home
  nodes looking for a peer.

  Anthony Towns questioned whether random inbound connections help home
  nodes at all and [argued][aj holepunch goals] that hole punching makes it
  easier for an attacker to reach honest nodes directly while doing little to
  guarantee a connection to an honest one. He estimated that an attacker
  advertising about 10,000 addresses would be an early match for most honest
  nodes and suggested short-lived connections to random peers as a lower-risk
  alternative. Jonathan Harvey-Buschel cited data showing honest nodes are
  less reachable than attacker-controlled ones and favored coordinating
  through a node's own [Tor][topic anonymity networks] service. Discussion is
  ongoing.

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

{% include snippets/recap-ad.md when="2026-11-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[news406 holepunch]: /en/newsletters/2026/05/22/#tcp-hole-punching-for-bitcoin-nodes-behind-nats
[b10c holepunch recap]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/18
[b10c holepunch option6]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/22
[aj holepunch goals]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/25
