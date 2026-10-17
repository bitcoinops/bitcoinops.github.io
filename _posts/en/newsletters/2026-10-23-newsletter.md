---
title: 'Bitcoin Optech Newsletter #428'
permalink: /en/newsletters/2026/10/23/
name: 2026-10-23-newsletter
slug: 2026-10-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

FIXME:bitschmidty

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Ibis Wallet v5.0-beta released:** [Ibis Wallet v5.0-beta][ibis v5.0] (see
  [Newsletter #406][news406 ibis]) adds [Ark][topic ark] support built on Bark,
  unilateral exits from the Spark [statechain][topic statechains], and receiving
  to [silent payment][topic silent payments] addresses.

- **Landfall wallet for Lightning mining payouts:** [Landfall][landfall gh] is a
  proof-of-concept wallet that derives from a single seed the payout address,
  [BOLT12 offer][topic offers], and [BIP322][topic generic signmessage]
  signature that the OCEAN mining pool requires to pay rewards over LN, using a
  Lexe-hosted node (see [Newsletter #419][news419 lexe]). It is not intended for
  production use.

- **rbitcoin 0.8.0 released:** [rbitcoin 0.8.0][rbitcoin 0.8.0] is a Bitcoin
  full node in Rust, described as entirely AI-written, for wallet and Lightning
  backends that replaces the UTXO set with a relational archive, serves Electrum
  and Esplora-style APIs, and uses [BIP324][topic v2 p2p transport] exclusively.

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

{% include snippets/recap-ad.md when="2026-10-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[ibis v5.0]: https://github.com/aeonBTC/IbisWallet/releases/tag/v5.0.1-beta
[news406 ibis]: /en/newsletters/2026/05/22/#ibis-wallet-announced
[landfall gh]: https://github.com/vincenzopalazzo/landfall
[news419 lexe]: /en/newsletters/2026/08/21/#lexe-adds-human-readable-addresses-and-lnurl-withdraw
[rbitcoin 0.8.0]: https://github.com/reardencode/rbitcoin/releases/tag/v0.8.0
