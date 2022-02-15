---
title: 'Bitcoin Optech Newsletter #187'
permalink: /en/newsletters/2022/02/16/
name: 2022-02-16-newsletter
slug: 2022-02-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

## News

- **Simplified alternative to `OP_TXHASH`:** in continuing discussion
  about covenant-enabling opcodes (see [Newsletter #185][news185
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

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

FIXME:harding to update/remove on Tuesday

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #2164][] Typed features FIXME:dongcarl

- [BTCPay Server #3395][] adds support for [CPFP][topic cpfp]
  fee-bumping payments recevied to invoices and transactions sent by the
  wallet.

- [BIPs #1279][] updates the [BIP322][] specification of the [generic
  signmessage protocol][topic generic signmessage] with a few
  clarifications and test vectors.

<!-- FIXME:harding to add topic links Tuesday -->
{% include references.md %}
{% include linkers/issues.md v=1 issues="2164,3395,1279" %}
[russell op_tx]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019871.html
[news185 composable]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
