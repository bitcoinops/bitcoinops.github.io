---
title: 'Bitcoin Optech Newsletter #187'
permalink: /en/newsletters/2022/02/16/
name: 2022-02-16-newsletter
slug: 2022-02-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes continued discussion about covenants in
Bitcoin and includes our regular sections with summaries of changes to
services and client software and notable changes to popular Bitcoin
infrastructure software.

## News

- **Simplified alternative to `OP_TXHASH`:** in continuing discussion
  about [covenant][topic covenants]-enabling opcodes (see [Newsletter #185][news185
  composable]), Rusty Russell [proposed][russell op_tx] that the
  function provided by `OP_TXHASH` could be provided by the existing
  `OP_SHA256` opcode plus a new `OP_TX` opcode which accepted the same
  input as `OP_TXHASH`.  The new opcode would make serialized fields
  from a spending transaction available to a [tapscript][topic
  tapscript].  Scripts could then test the fields directly (e.g. is the
  transaction version's number greater than `1`?) or hash the data and
  compare it to a signature with the previously-proposed
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] opcode.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Blockchain.com Wallet adds taproot sends:**
  [v202201.2.0(18481)][blockchain.com v202201.2.0(18481)] of the Blockchain.com
  Wallet for Android added support for sending to [bech32m][topic bech32]
  addresses. At the time of writing, the iOS version of the wallet does not
  yet support sending to bech32m addresses.

- **Sensei Lightning node implementation launches:**
  [Sensei][sensei website], currently in beta, is built using the [Bitcoin Dev
  Kit (BDK)][bdk website] and [Lightning Dev Kit (LDK)][ldk website]. The node
  currently requires bitcoind and Electrum server with additional backend
  options planned.

- **BitMEX adds taproot sends:**
  In a recent [blog post][bitmex blog], BitMEX announced support for bech32m
  withdrawals. The post also notes that 73% of [BitMEX user deposits][news141
  bitmex bech32 receive] are received to P2WSH outputs and result in around 65% fee savings.

- **BitBox02 adds taproot sends:**
  Both the [v9.9.0 - Multi][bitbox02 v9.9.0 multi] and [v9.9.0 -
  Bitcoin-only][bitbox02 v9.9.0 bitcoin] releases add support for sending to bech32m addresses.

- **Fulcrum 1.6.0 adds performance improvements:**
  Address indexing software Fulcrum adds [performance improvements][sparrow docs
  performance] in the [1.6.0 release][fulcrum 1.6.0].

- **Kraken announces proof of reserves scheme:**
  [Kraken details][kraken por] their proof of reserves scheme involving a
  trusted auditor, also noting shortcomings and future improvements. Kraken
  proves onchain address ownership by digitally signing,
  a merkle tree of Kraken user account balances is created, the auditor verifies
  onchain balances are greater than account balances, and tooling is provided
  for users to verify their balance inclusion in the tree.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #2164][] improves its handling of feature bits in various contexts.
  Notably, invoices that requires a mandatory but non-invoice feature would no
  longer be rejected, since the lack of support for a non-invoice feature does
  not affect an invoice’s ability to be fulfilled.

- [BTCPay Server #3395][] adds support for [CPFP][topic cpfp]
  fee-bumping payments recevied to invoices and transactions sent by the
  wallet.

- [BIPs #1279][] updates the [BIP322][] specification of the [generic
  signmessage protocol][topic generic signmessage] with a few
  clarifications and test vectors.

{% include references.md %}
{% include linkers/issues.md v=1 issues="2164,3395,1279" %}
[russell op_tx]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019871.html
[news185 composable]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[blockchain.com v202201.2.0(18481)]: https://github.com/blockchain/My-Wallet-V3-Android/releases/tag/v202201.2.0(18481)
[sensei website]: https://l2.technology/sensei
[bdk website]: https://bitcoindevkit.org/
[ldk website]: https://lightningdevkit.org/
[bitmex blog]: https://blog.bitmex.com/bitmex-supports-sending-to-taproot-addresses/
[news141 bitmex bech32 receive]: /en/newsletters/2021/03/24/#bitmex-announces-bech32-support
[bitbox02 v9.9.0 multi]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware%2Fv9.9.0
[bitbox02 v9.9.0 bitcoin]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware-btc-only%2Fv9.9.0
[fulcrum 1.6.0]: https://github.com/cculianu/Fulcrum/releases/tag/v1.6.0
[sparrow docs performance]: https://www.sparrowwallet.com/docs/server-performance.html
[kraken por]: https://www.kraken.com/proof-of-reserves
