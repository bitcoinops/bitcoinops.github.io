---
title: 'Bitcoin Optech Newsletter #175'
permalink: /en/newsletters/2021/11/17/
name: 2021-11-17-newsletter
slug: 2021-11-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter provides information about the activation of
taproot and includes our regular sections with summaries of changes to
services and client software, new releases and release candidates, and
notable changes to popular Bitcoin infrastructure software.

## News

- **Taproot activated:** as expected, the [taproot][topic taproot] soft
  fork activated at block height {{site.trb}}.  As of this writing,
  several large mining pools are not mining blocks containing taproot
  spends.  This may indicate that they were falsely signaling readiness
  to enforce taproot's rules, a risk we [previously warned about][p4tr
  what happens].  Alternatively, they may be risklessly using a
  taproot-enforcing node to choose which block chain to use while also
  using an older node or custom software to choose which transactions to
  include in their blocks.

    The safest course of action for users and businesses is to run their
    own taproot-enforcing node (such as Bitcoin Core 22.0) and only
    accept transactions confirmed by it.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **bitcoinj adds bech32m, P2TR support:**
  Andreas Schildbach added [a commit][bitcoinj bech32m] for [bech32m][topic
  bech32] and another for [P2TR support][bitcoinj p2tr] to the bitcoinj repository.

- **libwally-core adds bech32m support:**
  The [0.8.4 release][libwally 0.8.4] of this wallet primative library includes [bech32m
  support][libwally 297].

- **Spark Lightning Wallet adds BOLT12 offers:**
  Spark [v0.3.0][spark v0.3.0] adds [offer][topic offers] features including
  offer creation, sending offer payments, and pull payments. Recurring offer
  features are planned for a future release.

- **BitGo wallets support taproot:**
  BitGo [announced][bitgo taproot blog] support for both sending from and
  receiving to [taproot][topic taproot] outputs using their API. Taproot support
  in the UI is planned for a future update.

- **NthKey adds bech32m send capabilities:**
  iOS signing service [NthKey][nthkey website] added support for taproot sends
  in the [v1.0.4 release][nthkey v1.0.4].

- **Ledger Live supports taproot:**
  Ledger's client software, Ledger Live, announced taproot support in their
  [v2.35.0 release][ledger v2.35.0] as an experimental feature.

- **Muun wallet supports taproot:**
  Muun wallet enabled taproot address support after activation occurred,
  including the ability for users to default to taproot receive addresses.

- **Kollider launches alpha LN-based trading platform:**
  Kollider's latest [announcement][kollider blog] details the derivative
  platform's features including LN deposits and withdrawals plus LNAUTH and LNURL
  support.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.14.0-beta.rc4][] is a release candidate that includes
  additional [eclipse attack][topic eclipse attacks] protection (see
  [Newsletter #164][news164 ping]), remote database support ([Newsletter
  #157][news157 db]), faster pathfinding ([Newsletter #170][news170
  path]), improvements for users of Lightning Pool ([Newsletter
  #172][news172 pool]), and reusable [AMP][topic amp] invoices
  ([Newsletter #173][news173 amp]) in addition to many other features
  and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #22934][] adds a verification step after both ECDSA signatures and
  [schnorr signatures][topic schnorr signatures] are created.  This may
  prevent the software from disclosing an incorrectly-generated
  signature that may leak information about the private key or nonce
  used to generate it.  This follows advice given in a previous update
  to [BIP340][] (see [Newsletter #87][news87 bips886]) previously discussed in
  [Newsletter #83][news83 safety].

- [Bitcoin Core #23077][] enables address relay via [CJDNS][], making CJDNS
  a fully supported network like IPv4, IPv6, Tor, and I2P. Once CJDNS is
  set up outside of Bitcoin Core, node operators can toggle the new
  configuration option `-cjdnsreachable` to have Bitcoin Core interpret
  `fc00::/8` addresses as belonging to CJDNS rather than being
  interpreted as private IPv6 addresses.

<!-- FIXME: harding to add topic for onion messages -->
- [Eclair #1957][] Add basic support for onion messages (lightning/bolts#759) FIXME:dongcarl

- [Rust Bitcoin #691][] adds an API to create [bech32m][topic bech32]
  addresses for a [P2TR][topic taproot] scriptPubKey from a pubkey and
  optional [tapscript][topic tapscript] merkle root.

- [BDK #460][] adds a new function for adding an `OP_RETURN` output to a
  transaction.

- [BIPs #1225][] updates BIP341 with the taproot test vectors described
  in [Newsletter #173][news173 taproot tests].

{% include references.md %}
{% include linkers/issues.md issues="22934,23077,1957,691,460,1225" %}
[lnd 0.14.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta.rc4
[news164 ping]: /en/newsletters/2021/09/01/#lnd-5621
[news157 db]: /en/newsletters/2021/07/14/#lnd-5447
[news170 path]: /en/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /en/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /en/newsletters/2021/11/03/#lnd-5803
[news87 bips886]: /en/newsletters/2020/03/04/#bips-886
[news83 safety]: /en/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news173 taproot tests]: /en/newsletters/2021/11/03/#taproot-test-vectors
[p4tr what happens]: /en/preparing-for-taproot/#what-happens-at-activation
[cjdns]: https://github.com/cjdelisle/cjdns
[bitcoinj bech32m]: https://github.com/bitcoinj/bitcoinj/pull/2099
[bitcoinj p2tr]: https://github.com/bitcoinj/bitcoinj/pull/2225
[libwally 0.8.4]: https://github.com/ElementsProject/libwally-core/releases/tag/release_0.8.4
[libwally 297]: https://github.com/ElementsProject/libwally-core/pull/297
[spark v0.3.0]: https://github.com/shesek/spark-wallet/releases/tag/v0.3.0
[bitgo taproot blog]: https://blog.bitgo.com/taproot-support-for-bitgo-wallets-9ed97f412460
[nthkey website]: https://nthkey.com/
[nthkey v1.0.4]: https://github.com/Sjors/nthkey-ios/releases/tag/v1.0.4
[ledger v2.35.0]: https://github.com/LedgerHQ/ledger-live-desktop/releases/tag/v2.35.0
[kollider blog]: https://kollider.medium.com/kollider-alpha-version-h1-3bec739df1d4
