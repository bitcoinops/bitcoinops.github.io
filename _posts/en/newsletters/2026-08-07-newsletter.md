---
title: 'Bitcoin Optech Newsletter #417'
permalink: /en/newsletters/2026/08/07/
name: 2026-08-07-newsletter
slug: 2026-08-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a draft BIP for relaying stale block tips
between peers. Also included are our regular sections summarizing proposals and
discussion about changing Bitcoin's consensus rules, announcing new releases and
release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Draft BIP for stale tip relay**: Ram and w0xlt [posted][stale tip ml]
  to the Bitcoin-Dev mailing list about the proposal for an opt-in P2P
  message for relaying stale tips between peers. Currently, the stale block rate
  is a difficult metric to monitor, since stale blocks stop propagating
  as soon as the winning chain is relayed. However, it is a useful signal
  to check the network health. Changes in the stale block rate may expose validation
  or relay bottlenecks, network partitions, or [selfish mining][topic selfish
  mining] behavior.

  The proposed [BIP][stale tip bip] defines a new message, called
  `staletip`, for announcing recent stale chain tips to peers. The message
  itself contains the block height at which a stale branch diverges (the
  fork point), a vector containing the block headers belonging to the stale
  branch, and a flag signaling willingness to serve that block data. A node
  should only send the message after [BIP434][] negotiation with its peers
  (see [Newsletter #386][news386 bip434]).

  The authors are waiting for feedback from other developers.
  In the meantime, a [proof of concept][stale tip poc] for the proposal
  is already available.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

FIXME:rearden

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:gustavo

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:gustavo

{% include snippets/recap-ad.md when="2026-08-11 16:30" %}
{% include references.md %}
[stale tip ml]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU
[stale tip bip]: https://github.com/pseudoramdom/bips/blob/staletip-bip-draft/bip-staletip.md
[stale tip poc]: https://github.com/w0xlt/bitcoin/tree/staletip-v4
