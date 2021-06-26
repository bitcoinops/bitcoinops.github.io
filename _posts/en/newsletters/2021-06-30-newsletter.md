---
title: 'Bitcoin Optech Newsletter #155'
permalink: /en/newsletters/2021/06/30/
name: 2021-06-30-newsletter
slug: 2021-06-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes two proposed BIPs related to wallet
support for taproot and includes our regular sections describing selected
questions and answers on the Bitcoin Stack Exchange, how to prepare for
taproot, and notable changes to popular Bitcoin
infrastructure projects.

## News

- **PSBT extensions for taproot:** Andrew Chow [posted][chow taproot
  psbt] a [proposed BIP][bip-taproot-psbt] to the Bitcoin-Dev mailing
  list that defines new fields for [PSBTs][topic psbt] to use when
  either spending or creating taproot outputs.  The fields extend both
  the original version 0 PSBTs and the proposed version 2 PSBTs (see
  [Newsletter #128][news128 psbt2]).  Both keypath and scriptpath spends
  are supported.

    The proposed BIP also recommends that P2TR inputs in a
    PSBT can omit copies of previous transactions because taproot fixes
    the fee overpayment attack against v0 segwit inputs (see
    [Newsletter #101][news101 fee overpayment attack]).

- **Key derivation path for single-sig P2TR:** Andrew Chow also
  [posted][chow taproot path] a second [proposed BIP][bip-taproot-bip44]
  to the Bitcoin-Dev mailing list suggesting a [BIP32][] derivation path
  to use for wallets creating single-sig taproot addresses.  Chow notes
  that the BIP is very similar to [BIP49][] for P2SH-wrapped P2WPKH
  addresses and [BIP84][] for native P2WPKH addresses.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Preparing for taproot #2: is taproot even worth it for single-sig?

*A weekly series about how developers and service providers can prepare
for the upcoming activation of taproot at block height {{site.trb}}.*

{% include specials/taproot/en/01-single-sig.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22154][] adds code that will allow the user to generate
  [bech32m][topic bech32] addresses for P2TR scripts after taproot
  activates in block {{site.trb}}, e.g. by calling `getnewaddress "" bech32m`.
  If a transaction includes any bech32m addresses after taproot
  activation, the descriptor wallet will also use a P2TR change output.
  The feature only applies to wallets with taproot descriptors (see
  [Newsletter #152][news152 p2tr descriptors]).

- [Bitcoin Core #22166][] Add support for inferring tr() descriptors FIXME:Xekyo

- [Bitcoin Core #20966][] changes the name and format of the saved
  banlist file from `banlist.dat` (based on serialized P2P protocol
  `addr` messages) to `banlist.json`.  The file format update allows the
  new list to store ban entries for peers on Tor v3 and peers on
  other networks with addresses more than 128 bits wide---the maximum
  width that original `addr` messages can contain.

- [Bitcoin Core #21056][] adds a new `-rpcwaittimeout` parameter to
  `bitcoin-cli`.  The existing `-rpcwait` parameter will delay sending a
  command (RPC call) until the `bitcoind` server has started.  The new
  parameter stops the waiting after the indicated number of seconds,
  returning an error.

- [C-Lightning #4606][] allows creating invoices over about 0.043 BTC,
  following a similar change in LND (see [Newsletter #93][news93
  lnd4075]) and the change to the specification described in the next item.

- [BOLTs #877][] Remove HTLC amount restriction FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="22154,22166,20966,21056,4606,877" %}
[news128 psbt2]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[news101 fee overpayment attack]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[chow taproot psbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019095.html
[bip-taproot-psbt]: https://github.com/achow101/bips/blob/taproot-psbt/bip-taproot-psbt.mediawiki
[chow taproot path]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019096.html
[bip-taproot-bip44]: https://github.com/achow101/bips/blob/taproot-bip44/bip-taproot-bip44.mediawiki
[news93 lnd4075]: /en/newsletters/2020/04/15/#lnd-4075
[news152 p2tr descriptors]: /en/newsletters/2021/06/09/#bitcoin-core-22051
