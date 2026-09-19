---
title: 'Bitcoin Optech Newsletter #424'
permalink: /en/newsletters/2026/09/25/
name: 2026-09-25-newsletter
slug: 2026-09-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for upgrading the offchain
protocols of the Lightning Network to post-quantum security. Also included are
our regular sections with selected questions and answers from the Bitcoin
Stack Exchange, announcements of new releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure software.

## News

FIXME:bitschmidty

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What would be a drawback if sum instead of SHA256 of amounts was used in the taproot signature message?]({{bse}}130977)
  User 1uba explains that committing to only the sum of input amounts in a
  [taproot][topic taproot] signature hash (sighash) would still prevent the
  fee-overpayment attack [BIP341][] cites, but the software preparing a
  transaction for a signing device could then swap the amounts between inputs
  as long as the total stayed the same. This impacts offline signers and
  for collaborative transactions, where a signer needs to verify its own
  input's amount.

- [Post-BIP110 fork is it necessary to resync from block 0?]({{bse}}131037)
  Murch expects that a pruned Bitcoin Knots node that enforced BIP110
  rules (see [Newsletter #418][news418 bip110]) still holds the last block
  common to both chains, because few blocks were added to the BIP110 chain
  before the node was last run. Installing Bitcoin Core in its place
  should work, but if the node does not reorganize on its own, he suggests
  trying `reconsiderblock` on the first block the BIP110 node rejected.

- [Can a Bitcoin node build a partial UTXO set from only the most recent blocks and use it to validate new transactions?]({{bse}}131051)
  Pieter Wuille explains that such a node cannot tell whether a missing input
  was already spent or was created in a block it skipped. Because it cannot
  reject any transaction as invalid, the scheme performs no useful validation
  and is equivalent in security to SPV, which relies entirely on proof of
  work.

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

{% include snippets/recap-ad.md when="2026-09-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[news418 bip110]: /en/newsletters/2026/08/14/#bips-2225
