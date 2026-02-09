---
title: 'Bitcoin Optech Newsletter #392'
permalink: /en/newsletters/2026/02/13/
name: 2026-02-13-newsletter
slug: 2026-02-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion of improving worst-case silent
payment scanning performance and describes an idea for enabling many spending
conditions in a single key.  Also included are our regular sections announcements
of new releases and release candidates and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Proposal to limit the number of per-group silent payment recipients**: Sebastian
  Falbesoner [posted][kmax mailing list] to the Bitcoin-Dev mailing list the discovery and
  mitigation of a theoretical attack on [silent
  payment][topic silent payments] recipients. The attack occurs when an adversary
  constructs a transaction with a large number of taproot outputs (23255 max outputs per
  block according to current consensus rules) that all target the same entity.
  If there were no limit on group size, it would take several minutes
  to process, rather than tens of seconds.

  This motivated a mitigation to add a new parameter, `K_max`, that limits the
  number of per-group recipients within a single transaction. In theory, this
  change would not be backward-compatible, but in practice, none of the
  existing silent payment wallets should be affected
  for a sufficiently high `K_max`. Falbesoner is proposing `K_max=1000`.

  Falbesoner is seeking feedback or concerns about the proposed restriction. He
  also notes that most silent payment wallet developers have been notified and
  are aware of the issue.

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

{% include snippets/recap-ad.md when="2026-02-17 17:30" %}
{% include references.md %}
[kmax mailing list]: https://groups.google.com/g/bitcoindev/c/tgcAQVqvzVg
