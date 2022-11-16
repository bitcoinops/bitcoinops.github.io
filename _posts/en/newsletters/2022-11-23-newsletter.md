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

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.5-beta.rc2][] is a release candidate for a maintenance
  release of LND.  It contains only minor bug fixes according to its
  planned release notes.

- [Core Lightning 22.11rc2][] is a release candidate for the next major
  version of CLN.  It'll also be the first release to use a new version
  numbering scheme, although CLN releases continue to use [semantic
  versioning][].

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
  transaction of a block.

- [LND #7082][] updates the way invoices without requested amounts are
  created to allow the inclusion of route hints, which can help the spender find
  a path to the receiver.

- [LDK #1413][] removes support for the original fixed-length onion data
  format.  The upgraded variable-length format was added to the
  specification over three years ago and support for the old version has
  already been removed from the specification (see [Newsletter
  #220][news220 bolts962]), Core Lightning ([Newsletter #193][news193
  cln5058]), LND ([Newsletter #196][news196 lnd6385]), and Eclair
  ([Newsletter #217][news217 eclair2190]).

- [HWI #637][] adds support for a major planned upgrade of the
  Bitcoin-related firmware for Ledger devices.  Not included in this PR
  but mentioned in its description as future planned work is the policy
  management work mentioned in [Newsletter #200][news200 policy].

{% include references.md %}
{% include linkers/issues.md v=2 issues="25730,7082,1413,637" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc1
[core lightning 22.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc1
[news220 bolts962]: /en/newsletters/2022/10/05/#bolts-962
[news217 eclair2190]: /en/newsletters/2022/09/14/#eclair-2190
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news196 lnd6385]: /en/newsletters/2022/04/20/#lnd-6385
[news200 policy]: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices
[semantic versioning]: https://semver.org/spec/v2.0.0.html
