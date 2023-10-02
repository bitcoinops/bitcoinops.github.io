---
title: 'Bitcoin Optech Newsletter #211'
permalink: /en/newsletters/2022/08/03/
name: 2022-08-03-newsletter
slug: 2022-08-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow multiple derivation
paths in a single output script descriptor and includes our regular
section with summaries of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Multiple derivation path descriptors:** Andrew Chow [posted][chow
  desc] a [proposed BIP][bip-multipath-descs] to the Bitcoin-Dev mailing
  list for allowing a single descriptor to specify two related [BIP32][]
  paths for [HD key generation][topic bip32].  The first path would be
  for generating addresses to which incoming payments could be received.
  The second address would be for internal payments within the wallet,
  namely returning change back to the wallet after spending a UTXO.

    As [specified][bip32 wallet layout] in BIP32, most wallets use
    separate paths for generating external versus internal addresses in
    order to enhance privacy.  An external path used for receiving
    payments might be shared with less-trusted devices, e.g. uploading
    it to a webserver to receive payments.  The internal path used only
    for change might only be needed at times when the private key is
    also needed, so it could receive the same security.  If the example
    webserver were compromised and the external addresses were leaked,
    the attacker would learn about each time the user received money,
    how much they received, and when they initially spent the money---but
    they wouldn't necessarily learn how much money was sent in the
    initial spend, and they also might not learn about any spends that
    entirely consisted of spending change.

    Replies from [Pavol Rusnak][rusnak desc] and [Craig Raw][raw desc]
    indicated that Trezor Wallet and Sparrow Wallet already supported
    the scheme Chow proposed.  Rusnak also asked whether a single
    descriptor should be able to describe more than two related paths.
    Dmitry Petukhov [noted][petukhov desc] that only internal and
    external paths are widely used today and that any additional paths
    wouldn't have a clear meaning to existing wallets.  That could
    create interoperability issues.  He suggested limiting the BIP to
    just two paths and waiting for anyone needing additional paths to
    write their own BIP. {% assign timestamp="0:52" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5441][] updates `hsmtool` to make it easier to check
  a [BIP39][] passphrase against the [HD seed][topic bip32] used by
  CLN's internal wallet. {% assign timestamp="23:26" %}

- [Eclair #2253][] adds support for relaying [blinded payments][topic rv
  routing] as specified in [BOLTs #765][] (see [Newsletter #187][news178
  eclair 2061]). {% assign timestamp="24:33" %}

- [LDK #1519][] always includes the `htlc_maximum_msat` field in
  `channel_update` messages as will be required if [BOLTs #996][] is
  merged into the LN specification.  The reason given in the pull
  request for the change is to simplify message parsing. {% assign timestamp="26:40" %}

- [Rust Bitcoin #994][] adds a `LockTime` type that can be used with
  nLockTime and [BIP65][] `OP_CHECKLOCKTIME` fields.  Locktime fields in
  Bitcoin can contain either a block height or a [Unix epoch time][]
  value. {% assign timestamp="29:37" %}

- [Rust Bitcoin #1088][] adds the structures needed for [compact
  blocks][topic compact block relay] as specified in [BIP152][], as well
  as a method for creating a compact block from a regular block.
  Compact blocks allow a node to tell its peers which transactions a
  block contains without sending complete copies of those transactions.
  If a peer has previously received and stored those transactions from
  when they were unconfirmed, it doesn't need to download them again,
  saving bandwidth and speeding up the relay of new blocks. {% assign timestamp="32:50" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="5441,2253,1519,994,1088,996,765" %}
[bip32 wallet layout]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#specification-wallet-structure
[chow desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020791.html
[bip-multipath-descs]: https://github.com/achow101/bips/blob/bip-multipath-descs/bip-multipath-descs.mediawiki
[rusnak desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020792.html
[raw desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020799.html
[petukhov desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020804.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[news178 eclair 2061]: /en/newsletters/2021/12/08/#eclair-2061
