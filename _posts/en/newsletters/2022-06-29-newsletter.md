---
title: 'Bitcoin Optech Newsletter #206'
permalink: /en/newsletters/2022/06/29/
name: 2022-06-29-newsletter
slug: 2022-06-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections summarizing
popular questions and answers from Bitcoin Stack Exchange, announcing
new software releases and release candidates, and describing recent
changes to Bitcoin infrastructure software.

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

- [What is the purpose of indexing the mempool by these five criteria?]({{bse}}114216)
  Murch and glozow explain the different mempool transaction indexes (txid,
  wtxid, time in mempool, ancestor feerate, and descendant feerate) in Bitcoin
  Core as well as their usages.

- [BIP-341: Should key-path-only P2TR be eschewed altogether?]({{bse}}113989)
  Pieter Wuille defines 4 [taproot][topic taproot] keypath spend options,
  outlines why [BIP341 recommends][bip41 constructing] the "noscript" option, and notes scenarios
  where other options might be preferred.

- [Was the addition of OP_NOP codes in Bitcoin 0.3.6 a hard or soft fork?]({{bse}}113994)
  Pieter Wuille explains that the addition of [`OP_NOP` codes][wiki reserved words] in Bitcoin Core
  0.3.6 was a backward incompatible consensus change since older software versions would
  see transactions with the newly valid `OP_NOP` codes as invalid. However, since no
  transactions using these `OP_NOP` codes were previously mined, there was no actual fork.

- [What is the largest multisig quorum currently possible?]({{bse}}114048)
  Andrew Chow lists the different possible multisig types (bare script, P2SH, P2WSH,
  P2TR, P2TR + [MuSig][topic musig]) and the multisig quorum restrictions for each.

- [What is the difference between blocksonly and block-relay-only in Bitcoin Core?]({{bse}}114081)
  Lightlike lists the differences between block-relay-only connections and a
  node running in `-blocksonly` mode.

- [Where are BIPs 40 and 41?]({{bse}}114168)
  User andrewz asks why [assigned BIP numbers][] BIP40 for Stratum wire protocol and
  BIP41 for Stratum mining protocol have no content. In a [separate answer][se 114179],
  Michael Folkson links to some work-in-progress Stratum documentation links.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.0-beta][] is a release for the next major version of this
  popular LN node.  It adds for invoice metadata which can be used by
  other programs (and potentially future versions of LND) for [stateless
  invoices][topic stateless invoices] and adds support to the internal
  wallet for receiving and spending bitcoins to [P2TR][topic taproot]
  keyspend outputs, along with experimental [MuSig2][topic musig]
  support.

- [Core Lightning 0.11.2][] is a bug fix release of the LN node.
  Upgrading is "highly recommended" by the Core Lightning developers.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5306][] updates multiple APIs to consistently use the
  name "msat" for millisatoshis and also returns JSON values in those
  fields as numbers.  Some fields are renamed to provide consistencies
  with other fields.  The old behavior is deprecated and so will remain
  available temporarily.

- [LDK #1531][] begins using [anti fee sniping][topic fee sniping]
  for LN funding transactions.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5306,1531" %}
[lnd 0.15.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta
[core lightning 0.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.2
[bip41 constructing]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#user-content-constructing_and_spending_taproot_outputs
[wiki reserved words]: https://en.bitcoin.it/wiki/Script#Reserved_words
[se 114179]: https://bitcoin.stackexchange.com/a/114179/87121
[assigned bip numbers]: https://github.com/bitcoin/bips#readme
