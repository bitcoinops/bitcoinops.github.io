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

- [What are the downsides to enabling potentially suboptimal or unused opcodes in a future soft fork?]({{bse}}106851)
  G. Maxwell outlines many considerations for enabling any opcodes that affect
  consensus including:

    * upfront as well as ongoing maintenance costs

    * potential risks to the user of the opcode but also the entire network

    * additional complexity acting as a disincentive for customizing or reimplementing node software

    * partial or inefficient features crowding out better future alternative ones

    * accidentally creating perverse incentives

- [Why does blockwide signature aggregation prevent adaptor signatures?]({{bse}}107196)
  Pieter Wuille explains why cross-input signature aggregation interferes
  with techniques like [adaptor signatures][topic adaptor signatures] or
  scriptless scripts, noting: "In case of block-wide signature aggregation, there
  is just a single signature for the entire block. There is simply no space for
  that single signature to reveal multiple independent secrets to multiple
  independent parties."

- [Should the Bitcoin Core wallet (or any wallet) prevent users from sending funds to a Taproot address pre activation?]({{bse}}107186)
  Murch makes the case for why wallet software should allow users to send to any future BIP173
  segwit output types. By putting the onus on the receiver to provide a spendable
  address, the ecosystem can take advantage of the forward-compatibility of
  [bech32/bech32m][topic bech32] and instantly utilize new output types.

- [Why are the witnesses segregated with schnorr signatures?]({{bse}}106930)
  Dalit Sairio asks why, since [schnorr signatures][topic schnorr signatures] do
  not suffer from the same malleability that ECDSA signatures do, schnorr
  signatures will still be segregated? Darosior points out that malleability is
  only one of the many benefits of segwit.  Pieter Wuille adds that signature malleability is
  only part of broader script malleability.

- [Possible amount of signatures with MuSig?]({{bse}}106929)
  Nickler explains that for both [MuSig][topic musig] and MuSig2 the number of signers is
  practically infinite, noting that [his benchmark][nickler musig] with 1 million
  signers runs in about 130 seconds on his laptop.

- [Support for P2WSH-wrapped P2TR addresses?]({{bse}}106706)
  In addition to [BIP341][bip341 p2sh footnote]'s collision security concern,
  jnewbery also points out the privacy issue with having an additional output
  type, and the questionable need for wrapped taproot outputs given wide
  ecosystem adoption of bech32 already.

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

- [BOLTs #877][] removes the protocol-level per-payment amount limit originally
  introduced to avoid significant losses arising out of implementation bugs.
  This follows the widespread implementation of `option_support_large_channel`
  in 2020, which (when enabled) removed the *per-channel* amount limit. See the
  topic on [large channels][topic large channels] for more details on these two
  limits.

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
[nickler musig]: https://github.com/jonasnick/musig-benchmark
[bip341 p2sh footnote]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-3
