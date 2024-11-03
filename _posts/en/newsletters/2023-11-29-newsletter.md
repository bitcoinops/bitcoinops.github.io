---
title: 'Bitcoin Optech Newsletter #279'
permalink: /en/newsletters/2023/11/29/
name: 2023-11-29-newsletter
slug: 2023-11-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an update to the liquidity
advertisements specification.  Also included are our regular sections
with selected questions and answers from the Bitcoin Stack Exchange,
announcements of new releases and release candidates, and descriptions of
notable changes to popular Bitcoin infrastructure software.

## News

- **Update to the liquidity ads specification:** Lisa Neigut
  [posted][neigut liqad] to the Lightning-Dev mailing list to announce
  an update to the specification for [liquidity advertisements][topic
  liquidity advertisements].  That feature, implemented in Core
  Lightning and currently being worked on for Eclair, allows a node to
  announce that it is willing to contribute funds to a [dual-funded
  channel][topic dual funding].  If another node accepts the offer by
  requesting to open a channel, the requesting node must pay the
  offering node an upfront fee.  This allows a node needing incoming
  liquidity (e.g., a merchant) to find well-connected peers that can
  provide that liquidity at a market rate, entirely using open source
  software and the decentralized LN gossip protocol.

  The updates include a few structural changes plus increased
  flexibility to the contract duration and forwarding fee ceiling.
  The post received several replies on the mailing list and additional
  changes to the [specification][bolts #878] are expected.  Neigut's
  post also notes that the current construction of liquidity
  advertisements and channel announcements makes it theoretically
  possible to cryptographically prove one case where a party is
  violating its contract.  It's an open problem to design an actual
  compact fraud proof that could be used in a bond contract to
  incentivize contract compliance. {% assign timestamp="1:00" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Is the Schnorr digital signature scheme a multisignature interactive scheme, and also not an aggregated non-interactive scheme?]({{bse}}120402)
  Pieter Wuille describes the differences between multisignatures, signature
  aggregation, key aggregation, and Bitcoin multisig and notes several related
  schemes including [BIP340][] [schnorr signatures][topic schnorr signatures],
  [MuSig2][topic musig], FROST, and Bellare--Neven 2006.  {% assign timestamp="38:49" %}

- [Is it advisable to operate a release candidate full node on mainnet?]({{bse}}120375)
  Vojtěch Strnad and Murch point out that running Bitcoin Core release
  candidates on mainnet pose little threat to the Bitcoin _network_ but users of Bitcoin
  Core's APIs, wallet, or other features should exercise appropriate caution and
  testing for their configuration. {% assign timestamp="41:40" %}

- [What is the relation between nLockTime and nSequence?]({{bse}}120256)
  Antoine Poinsot and Pieter Wuille answer a series of Stack Exchange questions about
  `nLockTime` and `nSequence` including the [relationship between the
  two]({{bse}}120273), the [original purpose of `nLockTime`]({{bse}}120276), the [potential values of `nSequence`]({{bse}}120254) and
  relationship to [BIP68]({{bse}}120320) and [`OP_CHECKLOCKTIMEVERIFY`]({{bse}}120259). {% assign timestamp="44:40" %}

- [What would happen if we provide to OP_CHECKMULTISIG more than threshold number (m) of signatures?]({{bse}}120604)
  Pieter Wuille explains that while this was possible previously, the [BIP147][]
  dummy stack element malleability soft fork no longer allows the additional
  stack element in OP_CHECKMULTISIG and OP_CHECKMULTISIGVERIFY to be an arbitrary value. {% assign timestamp="52:18" %}

- [What is "(mempool) policy"?]({{bse}}120269)
  Antoine Poinsot defines the terms _policy_ and _standardness_ in the context of
  Bitcoin Core and provides a few examples. He also links to Bitcoin Optech's
  [Waiting for confirmation][policy series] series on policy. {% assign timestamp="54:30" %}

- [What does Pay to Contract (P2C) mean?]({{bse}}120362)
  Vojtěch Strnad describes [Pay-to-Contract (P2C)][topic p2c] and links to the
  [original proposal][p2c paper]. {% assign timestamp="57:31" %}

- [Can a non-segwit transaction be serialized in the segwit format?]({{bse}}120317)
  Pieter Wuille points out that while several older versions of Bitcoin Core
  unintentionally allowed the extended serialization format for non-segwit
  transactions, [BIP144][] specifies non-segwit transactions must use the old
  serialization format. {% assign timestamp="58:18" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.11][] is a release of the next major version of
  this LN node implementation.  It provides additional flexibility to the
  _rune_ authentication mechanism, improved backup verification, new
  and features for plugins. {% assign timestamp="1:00:05" %}

- [Bitcoin Core 26.0rc3][] is a release candidate for the next major
  version of the predominant full-node implementation. There's a [testing
  guide][26.0 testing] available. {% assign timestamp="1:03:31" %}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Rust Bitcoin #2213][] amends the weight prediction for P2WPKH inputs
  processes during fee estimation. Since transactions with high-s signatures
  are considered non-standard since Bitcoin Core versions [0.10.3][bcc
  0.10.3] and [0.11.1][bcc 0.11.1], transaction building processes
  can safely assume that any serialized ECDSA signatures will at most take
  72 bytes instead of the previously used upper bound of 73 bytes. {% assign timestamp="1:04:55" %}

- [BDK #1190][] adds a new `Wallet::list_output` method that retrieves
  all outputs in the wallet, both spent outputs and unspent outputs.
  Previously, it was easy to get a list of unspent outputs but difficult
  to get a list of spent outputs. {% assign timestamp="1:09:04" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2213,1190,878" %}
[bitcoin core 26.0rc3]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11]: https://github.com/ElementsProject/lightning/releases/tag/v23.11
[neigut liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004217.html
[policy series]: /en/blog/waiting-for-confirmation/
[p2c paper]: https://arxiv.org/abs/1212.3257
[bcc 0.11.1]: https://bitcoin.org/en/release/v0.11.1#test-for-lows-signatures-before-relaying
[bcc 0.10.3]: https://bitcoin.org/en/release/v0.10.3#test-for-lows-signatures-before-relaying
