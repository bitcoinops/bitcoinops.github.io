---
title: 'Bitcoin Optech Newsletter #426'
permalink: /en/newsletters/2026/10/09/
name: 2026-10-09-newsletter
slug: 2026-10-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a draft BIP for letting peers choose their own
one-byte message type IDs over the version 2 P2P transport, summarizes a
discussion about whether BIPs should include their number in tagged hash
tags, and describes a proposed metaprotocol for private onchain transfers
that requires no consensus changes. Also included are our regular sections
announcing new releases and release candidates and describing notable changes
to popular Bitcoin infrastructure software.

## News

- **Dynamic one-byte message type IDs for BIP324:** Anthony Towns [posted][towns
  set324alias] to the Bitcoin-Dev mailing list a draft BIP that lets each peer
  choose its own one-byte message type IDs for the messages it sends over the
  [v2 P2P transport][topic v2 p2p transport]. [BIP324][] assigns one-byte IDs
  from a fixed table, so any new message needs a globally coordinated entry (see
  [Newsletter #392][news392 bip324 ids]) or must use its full 12-byte name. With
  a new `set324alias` message, a node announces its own aliases at connection
  time, so new messages can be deployed and experimented with at the P2P layer
  without that coordination. Towns also [noted][towns set324alias savings] that
  the space saving ranges from up to 66% on a connection carrying only pings to
  about 5% on a typical connection, and is zero until new messages without an
  existing one-byte ID are deployed.

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

{% include snippets/recap-ad.md when="2026-10-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[towns set324alias]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes
[news392 bip324 ids]: /en/newsletters/2026/02/13/#bips-2092
[towns set324alias savings]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes/m/JHCPpVWaBAAJ
