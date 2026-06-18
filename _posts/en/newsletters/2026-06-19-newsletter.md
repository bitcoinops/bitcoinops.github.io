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

- **Sparrow Wallet 2.5.0 adds silent payments receiving:**
  Sparrow [2.5.0][sparrow 2.5.0] adds [silent payments][topic silent payments]
  receiving wallets, including airgapped hardware wallet signers, building on
  the send support added in 2.3.0 (see [Newsletter #377][news377 sparrow]).

- **Bark live on Bitcoin mainnet:**
  Second [announced][bark mainnet] that Bark, its [Ark][topic ark] protocol
  implementation, is now running on Bitcoin mainnet, with a public Ark server
  plus the Bark SDK and `barkd` daemon for developers. Bark previously launched
  on signet (see [Newsletter #346][news346 bark]).

- **Arké Ark wallet announced:**
  [Arké][arke] is a native iOS wallet integrating the [Ark][topic ark] protocol
  with onchain ([BDK][bdk repo]) and Lightning payments, displaying transactions
  from all three layers in a single combined history. It currently runs on
  signet with mainnet pending.

- **Noah Ark wallet announced:**
  [Noah][noah] is a cross-platform mobile wallet built on the [Ark][topic ark]
  protocol with Lightning support and a trust-minimized design. It is currently
  in beta.

- **Alby Hub v1.23.0 released:**
  Alby Hub [v1.23.0][alby hub v1.23.0] adds [just-in-time channels][topic jit
  channels] that open automatically to accept incoming payments and an
  experimental [Ark][topic ark] payment backend, among other improvements.

- **JoinMarket NG 0.32.0 released:**
  JoinMarket-NG, a community-maintained fork of the [coinjoin][topic coinjoin]
  implementation, [released][joinmarket 0.32.0] mempool support for the
  [Neutrino][topic compact block filters] backend so takers can verify maker
  broadcasts, among other fidelity bond and reliability improvements.

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
[sparrow 2.5.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.5.0
[news377 sparrow]: /en/newsletters/2025/10/24/#sparrow-2-3-0-released
[bark mainnet]: https://blog.second.tech/bark-now-on-bitcoin-mainnet/
[arke]: https://github.com/GBKS/arke
[noah]: https://github.com/smolcars/noah
[news346 bark]: /en/newsletters/2025/03/21/#bark-launches-on-signet
[alby hub v1.23.0]: https://github.com/getAlby/hub/releases/tag/v1.23.0
[joinmarket 0.32.0]: https://github.com/joinmarket-ng/joinmarket-ng/releases/tag/0.32.0
