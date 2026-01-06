---
title: 'Bitcoin Optech Newsletter #387'
permalink: /en/newsletters/2026/01/09/
name: 2026-01-09-newsletter
slug: 2026-01-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter warns of a wallet migration bug in Bitcoin Core,
summarizes a post about using the Ark protocol as an LN channel factory, and
links to a draft BIP for silent payment descriptors.  Also included are our
regular sections describing release candidates and notable
changes to popular Bitcoin infrastructure software.

## News


- **Using Ark as a channel factory**:
  René Pickhardt [wrote][rp delving ark cf] on Delving Bitcoin about his
  discussions and ideas around whether [Ark][topic ark]'s best use case might
  be as a flexible [channel factory][topic channel factories] rather than as an end-user payment solution.
  Pickhardt's earlier research has focused on techniques to optimize payment
  success on the Lightning Network through [routing][news333 rp routing] and
  [channel balancing][news359 rp balance]. Ark-like structures containing
  Lightning channels have been discussed earlier ([1][optech superscalar],
  [2][news169 jl tt], [3][news270 jl cov]).

  Pickhardt's ideas focus on the possibility of many channel owners batching
  their channel liquidity changes (i.e. opens, closes, splices) using the vTXO
  structure of Ark as a way to significantly reduce the on-chain cost of
  operating the Lightning Network at the expense of additional liquidity
  overhead during the time between when one channel is forfeited and when its
  Ark batch fully expires. By using Ark batches as efficient channel
  factories, LSPs could provide liquidity to more end users efficiently,
  and the built-in expiration of the batches guarantees
  they can reclaim liquidity from idle channels without a costly
  dedicated on-chain force-close sequence. Routing nodes would also benefit
  from more efficient channel management operations by using regular batches
  to shift liquidity between their channels rather than individual splice
  operations.

  Greg Sanders [replied][delving ark hark] that he's been investigating similar possibilities,
  specifically using [hArk][sr delving hark] to facilitate the (mostly) online
  transfer of a Lightning channel state from one batch to another. hArk would
  require [CTV][topic op_checktemplateverify], `OP_TEMPLATEHASH`, or a similar
  opcode.

  Vincenzo Palazzo [replied][delving ark poc] with his proof-of-concept code implementing an Ark
  channel factory.

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

{% include snippets/recap-ad.md when="2026-01-13 17:30" %}
{% include references.md %}
[rp delving ark cf]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179
[news333 rp routing]: /en/newsletters/2024/12/13/#insights-into-channel-depletion
[news359 rp balance]: /en/newsletters/2025/06/20/#channel-rebalancing-research
[optech superscalar]: /en/podcast/2024/10/31/
[news169 jl tt]: /en/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[news270 jl cov]: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability
[delving ark hark]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/2
[delving ark poc]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/4
[sr delving hark]: https://delvingbitcoin.org/t/evolving-the-ark-protocol-using-ctv-and-csfs/1602
