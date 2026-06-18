---
title: 'Bitcoin Optech Newsletter #410'
permalink: /en/newsletters/2026/06/19/
name: 2026-06-19-newsletter
slug: 2026-06-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about wallets removing opt-in
replace-by-fee signaling from the transactions they create. Also included are
our regular sections describing recent changes to services and client software
and notable changes to popular Bitcoin infrastructure software.

## News

- **Discussion of removing RBF signaling from wallet transactions**: rkrux
  [posted][bip125 ml] to the Bitcoin-Dev mailing list proposing that wallets
  stop signaling [opt-in RBF][topic rbf] in the transactions they create. A
  transaction signals replaceability under [BIP125][] when at least one of its
  inputs sets `nSequence` below `MAX-1` (where `MAX` is `0xffffffff`). That
  signal no longer affects whether a transaction can be replaced since full RBF
  became the default (see [Newsletter #315][news315 fullrbf]) and the
  `mempoolfullrbf` opt-out was removed (see [Newsletter #329][news329 fullrbf]).
  Nodes using Bitcoin Core's default policy will replace any transaction
  regardless of its `nSequence` values. Signaling now serves mainly to
  fingerprint the wallet that created the transaction, so the post argued that
  wallets should converge on a single value.

  rkrux opened [Bitcoin Core #35405][] to stop the Bitcoin Core wallet from
  signaling by default, using `nSequence = MAX-1`, and asked other wallet
  authors which value they could standardize on. Murch and Electrum Wallet
  contributor SomberNight pointed out that `MAX-2` is already the dominant
  value, used by about 75% of transactions according to
  [mainnet-observer][bip125 graph] and by nearly all Electrum Wallet
  transactions. Because most transactions still signal, moving Bitcoin Core to a
  non-signaling `MAX-1` would make its transactions stand out rather than blend
  in, so both favored converging on `MAX-2` instead. rkrux closed the PR in
  light of that feedback.

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

{% include snippets/recap-ad.md when="2026-06-23 16:30" %}
{% include references.md %}
[bip125 ml]: https://groups.google.com/g/bitcoindev/c/C7zNIk8llew/m/YAdpwe33AgAJ
[bip125 graph]: https://mainnet.observer/charts/transactions-signaling-explicit-rbf/
[news315 fullrbf]: /en/newsletters/2024/08/09/#bitcoin-core-30493
[news329 fullrbf]: /en/newsletters/2024/11/15/#bitcoin-core-30592
