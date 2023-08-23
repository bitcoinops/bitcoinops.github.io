---
title: 'Bitcoin Optech Newsletter #227'
permalink: /en/newsletters/2022/11/23/
name: 2022-11-23-newsletter
slug: 2022-11-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter contains our regular sections with selected
questions and answers from the Bitcoin Stack Exchange, announcements of
new releases and release candidates, and descriptions of notable changes
to popular Bitcoin infrastructure projects.

## News

*No significant news this week was found on the Bitcoin-Dev or
Lightning-Dev mailing lists.*

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Did the P2SH BIP-0016 make some Bitcoin unspendable?]({{bse}}115803)
  User bca-0353f40e lists 6 outputs that existed with the P2SH script format,
  `OP_HASH160 OP_DATA_20 [hash_value] OP_EQUAL`, before [BIP16][]'s activation.
  One of those outputs had been spent under the old rules before activation and
  an [exception made][p2sh activation exception] for that single block in the
  P2SH activation code. Other than this exception, activation applied back to
  the genesis block so the remaining UTXOs would need to satisfy BIP16 rules in
  order to be spent. {% assign timestamp="0:39" %}

- [What software was used to make P2PK transactions?]({{bse}}115962)
  Pieter Wuille notes that P2PK outputs were created using the original Bitcoin
  software in coinbase transactions as well as when sending using [pay-to-IP
  address][wiki p2ip]. {% assign timestamp="8:33" %}

- [Why are both txid and wtxid sent to peers?]({{bse}}115907)
  Pieter Wuille references [BIP339][] and explains that while using wtxid is
  better for relay (due to malleability among other reasons), some peers do not
  support the newer wtxid identifiers and txids are supported for older
  pre-BIP339 peers for backward compatibility. {% assign timestamp="12:59" %}

- [How do I create a taproot multisig address?]({{bse}}115700)
  Pieter Wuille points out that Bitcoin Core's existing [multisig][topic multisignature] RPCs (like
  `createmultisig` and `addmultisigaddress`) will only support legacy wallets
  and outlines that with Bitcoin Core 24.0, users will be able to use
  [descriptors][topic descriptors] and RPCs (like `deriveaddresses` and
  `importdescriptors`) along with the new `multi_a` descriptor to create
  [taproot][topic taproot]-compatible multisig scripts. {% assign timestamp="15:38" %}

- [Is it possible to skip Initial Block Download (IBD) on pruned node?]({{bse}}116030)
  While not currently supported in Bitcoin Core, Pieter Wuille points to the
  [assumeutxo][topic assumeutxo] project which would allow for a new node to
  bootstrap by fetching a UTXO set that can be verified by a hard-coded hash. {% assign timestamp="18:58" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.5-beta.rc2][] is a release candidate for a maintenance
  release of LND.  It contains only minor bug fixes according to its
  planned release notes. {% assign timestamp="27:05" %}

- [Core Lightning 22.11rc2][] is a release candidate for the next major
  version of CLN.  It'll also be the first release to use a new version
  numbering scheme, although CLN releases continue to use [semantic
  versioning][]. {% assign timestamp="27:52" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25730][] updates the `listunspent` RPC with a new
  argument that will include in the results any immature coinbase
  outputs---outputs which can't yet be spent because fewer than 100
  blocks have passed since they were included in the miner coinbase
  transaction of a block. {% assign timestamp="28:50" %}

- [LND #7082][] updates the way invoices without requested amounts are
  created to allow the inclusion of route hints, which can help the spender find
  a path to the receiver. {% assign timestamp="30:50" %}

- [LDK #1413][] removes support for the original fixed-length onion data
  format.  The upgraded variable-length format was added to the
  specification over three years ago and support for the old version has
  already been removed from the specification (see [Newsletter
  #220][news220 bolts962]), Core Lightning ([Newsletter #193][news193
  cln5058]), LND ([Newsletter #196][news196 lnd6385]), and Eclair
  ([Newsletter #217][news217 eclair2190]). {% assign timestamp="33:04" %}

- [HWI #637][] adds support for a major planned upgrade of the
  Bitcoin-related firmware for Ledger devices.  Not included in this PR
  but mentioned in its description as future planned work is the policy
  management work mentioned in [Newsletter #200][news200 policy]. {% assign timestamp="34:23" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="25730,7082,1413,637" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc2
[news220 bolts962]: /en/newsletters/2022/10/05/#bolts-962
[news217 eclair2190]: /en/newsletters/2022/09/14/#eclair-2190
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news196 lnd6385]: /en/newsletters/2022/04/20/#lnd-6385
[news200 policy]: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[wiki p2ip]: https://en.bitcoin.it/wiki/IP_transaction
[p2sh activation exception]: https://github.com/bitcoin/bitcoin/commit/ce650182f4d9847423202789856e6e5f499151f8
