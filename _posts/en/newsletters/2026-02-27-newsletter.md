---
title: 'Bitcoin Optech Newsletter #394'
permalink: /en/newsletters/2026/02/27/
name: 2026-02-27-newsletter
slug: 2026-02-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter looks at a proposed BIP for including supplemental
information with output script descriptors.  Also included are our regular
sections summarizing popular questions on the Bitcoin Stack Exchange, announcing
new releases and release candidates, and describing recent changes to popular
Bitcoin infrastructure software.

## News

- **Draft BIP for output script descriptor annotations**: Craig Raw
  [posted][annot ml] to the Bitcoin-Dev mailing list about a new BIP idea to
  address feedback that emerged during the discussion around BIP392
  (see [Newsletter #387][news387 sp]).
  According to Raw, metadata, such as the wallet birthday expressed as a
  block height, could make [silent payment][topic silent payments] scanning more efficient.
  However, metadata is not technically needed to determine output scripts,
  thus it is deemed unsuitable for inclusion in a [descriptor][topic descriptors].

  Raw's BIP proposes to provide useful metadata in the form of annotations, expressed
  as key/value pairs, appended directly to the descriptor string using URL-like query
  delimiters. An annotated descriptor would look like this:
  `SCRIPT?key=value&key=value#CHECKSUM`.
  Notably, characters `?`, `&`, and `=` are already defined in [BIP380][], thus the
  checksum algorithm would not need to be updated.

  In the [draft BIP][annot draft], Raw also defines three initial annotation keys specifically to make funds silent payment scanning more efficient:

  - Block Height `bh`: The block height at which a wallet received the first funds;

  - Gap Limit `gl`: The number of unused addresses to derive before stopping;

  - Max Label `ml`: The maximum label index to scan for, for silent payments wallets.

  Finally, Raw noted that annotations should not be used in the general wallet backup process,
  but only for making funds recovery more efficient without altering the scripts
  produced by the descriptor.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Is Bitcoin BIP324 v2 P2P transport distinguishable from random traffic?]({{bse}}130500)
  Pieter Wuille points out that [BIP324][]'s [v2 encrypted transport][topic v2 p2p
  transport] protocol supports shaping traffic patterns, although no known
  software implements that feature, concluding "today's implementations only
  defeat protocol signatures that involve patterns in the sent bytes, not in
  traffic".

- [What if a miner just broadcasts the header and never gives the block?]({{bse}}130456)
  User bigjosh outlines how a miner might behave after receiving a block header
  on the P2P network but before receiving the block's contents: by mining an
  empty block on top of it. Pieter Wuille clarifies that, in practice, many
  miners actually see new block headers by monitoring the work other mining
  pools give out to their miners, a technique known as spy mining.

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

{% include snippets/recap-ad.md when="2026-03-03 17:30" %}
{% include references.md %}
[annot ml]: https://groups.google.com/g/bitcoindev/c/ozjr1lF3Rkc
[news387 sp]: /en/newsletters/2026/01/09/#draft-bip-for-silent-payment-descriptors
[annot draft]: https://github.com/craigraw/bips/blob/descriptorannotations/bip-descriptorannotations.mediawiki
