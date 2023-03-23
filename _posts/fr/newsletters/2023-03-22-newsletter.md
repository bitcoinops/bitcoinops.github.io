---
title: 'Bulletin Bitcoin Optech #243'
permalink: /fr/newsletters/2023/03/22/
name: 2023-03-22-newsletter-fr
slug: 2023-03-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
This week's newsletter includes our regular sections with descriptions
of changes to services and client software, plus summaries of notable
changes to popular Bitcoin infrastructure software.

## News

*No significant news this week was found on the Bitcoin-Dev or
Lightning-Dev mailing lists.*

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Xapo Bank supports Lightning:**
  Xapo Bank [announced][xapo lightning blog] its customers can now send outgoing
  Lightning payments from the Xapo Bank mobile apps, using underlying infrastructure from Lightspark.

- **TypeScript library for miniscript descriptors released:**
  The TypeScript-based [Bitcoin Descriptors Library][github descriptors library]
  has support for [PSBTs][topic psbt], [descriptors][topic descriptors],
  and [miniscript][topic miniscript].  This includes support for signing
  directly or when using certain hardware signing devices.

- **Breez Lightning SDK announced:**
  In a recent [blog post][breez blog], Breez announced the open source [Breez
  SDK][github breez sdk] for mobile developers who want to integrate Bitcoin and
  Lightning payments. The SDK includes support for [Greenlight][blockstream
  greenlight], Lightning Service Provider (LSP) features, and other services.

- **PSBT-based exchange OpenOrdex launches:**
  The [open source][github openordex] exchange software allows sellers to create
  an order book of Ordinal satoshis using [PSBTs][topic psbt] and buyers to sign
  and broadcast to complete the trade.

- **BTCPay Server coinjoin plugin released:**
  The Wasabi Wallet [announcement][wasabi blog] notes that any BTCPay Server
  merchant can activate the optional plugin which supports the
  [WabiSabi][news102 wabisabi] protocol for [coinjoins][topic coinjoin].

- **mempool.space explorer enhances CPFP support:**
  The mempool.space [explorer][topic block explorers] announced [additional
  support][mempool tweet] for [CPFP][topic cpfp]-related transactions.

- **Sparrow v1.7.3 released:**
  Sparrow's [v1.7.3 release][sparrow v1.7.3] includes [BIP129][] support for multisig wallets (see
  [Newsletter #136][news136 bsms]) and custom block explorer support among other features.

- **Stack Wallet adds coin control, BIP47:**
  Recent releases of the [Stack Wallet][github stack wallet] add [coin
  control][topic coin selection] features and [BIP47][] support.

- **Wasabi Wallet v2.0.3 released:**
  Wasabi's [v2.0.3 release][Wasabi v2.0.3] includes taproot coinjoin signing and taproot change outputs,opt-in manual coin control for sending, improved wallet loading speed and more.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.16.0-beta.rc3][] is a release candidate for a new major
  version of this popular LN implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #7448][] adds a new rebroadcaster interface to resubmit
  unconfirmed transactions especially to address transactions that were
  evicted from mempools. When enabled, the rebroadcaster will submit
  unconfirmed transactions to the attached full node once per block
  until it is confirmed. LND was already rebroadcasting transactions in
  a similar fashion when operating in Neutrino-mode. As noted in a
  previously covered Stack Exchange Q&A, [Bitcoin Core currently
  does not rebroadcast transactions][no rebroadcast], although it would
  be desirable for privacy and reliability if full node behavior were
  amended to rebroadcast any transactions that the node had expected to
  have been included in the prior block. Until then, it is the responsibility
  of every wallet to ensure the presence of transactions of interest in
  mempools.

- [BDK #793][] is a major restructuring of the library based on the work
  of the [bdk_core sub-project][].  According to the PR description, it
  "maintains the existing wallet API as much as possible and adds very
  little."  Three API endpoints with seemingly minor changes are listed in the PR
  description.

{% include references.md %}
{% include linkers/issues.md v=2 issues="7448,793" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[bdk_core sub-project]: https://bitcoindevkit.org/blog/bdk-core-pt1/
[no rebroadcast]: /en/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools
[xapo lightning blog]: https://www.xapobank.com/blog/another-first-xapo-bank-now-supports-lightning-network-payments
[github descriptors library]: https://github.com/bitcoinerlab/descriptors
[breez blog]: https://medium.com/breez-technology/lightning-for-everyone-in-any-app-lightning-as-a-service-via-the-breez-sdk-41d899057a1d
[github breez sdk]: https://github.com/breez/breez-sdk
[blockstream greenlight]: https://blockstream.com/lightning/greenlight/
[github openordex]: https://github.com/orenyomtov/openordex
[wasabi blog]: https://blog.wasabiwallet.io/wasabiwalletxbtcpayserver/
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[mempool tweet]: https://twitter.com/mempool/status/1630196989370712066
[news136 bsms]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[sparrow v1.7.3]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.3
[github stack wallet]: https://github.com/cypherstack/stack_wallet
[Wasabi v2.0.3]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.3
