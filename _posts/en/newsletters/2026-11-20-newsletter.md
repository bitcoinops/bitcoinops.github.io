---
title: 'Bitcoin Optech Newsletter #432'
permalink: /en/newsletters/2026/11/20/
name: 2026-11-20-newsletter
slug: 2026-11-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an analysis of decentralized mining pool
payouts, describes the disclosure of a fixed denial-of-service vulnerability
in Eclair, and links to continued discussion about whether stale tip relay
should include block data. Also included are our regular sections describing
recent changes to services and client software, announcing new releases and
release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Framework for decentralized mining pool payouts:** Developer 7d5x9
  [posted][7d5x9 dcpp] to Delving Bitcoin an analysis of how decentralized
  [mining pools][topic pooled mining] can pay miners directly from coinbase
  transactions, which the post calls decentralized coinbase payout protocols
  (DCPPs). Giving every miner its own output does not scale because mining
  firmware limits coinbase transaction size and each output displaces
  fee-paying transactions. The post argues that when a pool has more miners
  than outputs, any rule ranking miners by work allows a _rich list attack_,
  where a large miner splits its hashrate across identities that each still
  outrank the smallest miners, pushing them out of the coinbase transaction.

  According to 7d5x9, earlier designs only move this problem. Braidpool shifts
  it from who receives an output to who controls the pool's threshold key (see
  [Newsletter #340][news340 braidpool]). For a single coinbase output paying a
  [joinpool][topic joinpools] with unilateral exits, the obstacle is that
  miners vary the coinbase transaction for extra nonce space, so its txid is
  unknown and exit transactions cannot be signed until a block is found. 7d5x9
  believes this leaves the output controlled by a single key or threshold of
  keys until a soft fork enables rebindable signatures, such as those proposed
  in [BIP448][] (see [Newsletter #397][news397 bip448]). In sketches based on
  Spark-style [statechains][topic statechains] and on [Ark][topic ark], an
  attacker keeping one small claim per subtree can block cheap cooperative
  settlement, raising miners' costs, though the post considers this less
  severe for Ark.

  The post concludes that a joinpool does not decide which outputs enter the
  coinbase transaction. It sees two options for that: a value-weighted random
  draw (an idea credited to Matt Corallo) or outputs reserved for designated
  operators.

  LearnBitcoin.com, who ran a public P2Pool node, [examined][lb p2pool] 2,545
  P2Pool coinbase transactions and argued that growth alone, without any
  attacker, squeezed out small miners because P2Pool raised the share
  difficulty of miners expected to earn under 0.001 BTC per block. For its
  successor P2Poolv2, jungly [suggested][jungly dcpp] a limit of 16 outputs
  given current firmware. Steven Roose [replied][roose dcpp] that he could not
  think of a scheme worth exploring without [covenants][topic covenants],
  which would let a coinbase output deterministically commit to an Ark
  transaction tree that pays every miner who uses the same Ark server.

FIXME:bitschmidty

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

{% include snippets/recap-ad.md when="2026-11-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[7d5x9 dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060
[news340 braidpool]: /en/newsletters/2025/02/07/#request-for-a-covenant-design-supporting-braidpool
[news397 bip448]: /en/newsletters/2026/03/20/#bips-1974
[lb p2pool]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/2
[jungly dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/5
[roose dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/4
