---
title: 'Bitcoin Optech Newsletter #112'
permalink: /en/newsletters/2020/08/26/
name: 2020-08-26-newsletter
slug: 2020-08-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a discussion about routed coinswaps and
includes our regular sections with summaries of questions and answers
from the Bitcoin StackExchange, releases and release candidates, and
notable changes to popular Bitcoin infrastructure software

## Action items

*None this week.*

## News

- **Discussion about routed coinswaps:** Chris Belcher [posted][belcher
  coinswap] a design document for a routed multi-transaction coinswap
  implementation to the Bitcoin-Dev mailing list as a follow-up to his
  previous post in May (see [Newsletter #100][news100 coinswap]).
  Discussion from ZmnSCPxj and Nadav Kohen focused on ensuring the
  protocol was safe both in its use of cryptography and in ensuring that
  the expected transactions would get confirmed (rather than alternative
  transactions attempting theft).  In general, it appeared that all
  major concerns were addressed and that the protocol would provide
  several advantageous privacy benefits

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
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

- [LND 0.11.0-beta][lnd 0.11.0-beta] is now released.   This new major
  version allows accepting [large channels][topic large channels] (by
  default, this is off) and contains numerous improvements to its
  backend features that may be of interest to advanced users (see the
  [release notes][lnd 0.11.0-beta]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #14582][] and [#19743][Bitcoin Core #19743] wallet: always do partial spends FIXME:jonatack

- [Bitcoin Core #19550][] adds a new `getindexinfo` RPC that indicates
  which optional indexes have been enabled and how many blocks they've
  indexed so far.

- [C-Lightning #3954][] updates both the `fundpsbt` and `utxopsbt` RPCs
  so that they can each take a `locktime` parameter that specifies the
  nLockTime of the transaction to create.  The PR notes that this is
  "required for [dual funding][bolts #524], where the opener sets [the
  locktime]".

- [BIPs #955][] BIP174: add hash preimage fields to inputs FIXME:dongcarl

- [BOLTs #688][] adds support for [anchor outputs][topic anchor outputs]
  to the LN specification.  This extends commitment transactions with
  two extra outputs---one for each counterparty---which can be used for
  Child Pays For Parent ([CPFP][topic cpfp]) fee bumping.   With this
  change, it becomes possible to fee bump commitment transactions that
  may have been signed days or weeks earlier, when the current feerates
  would've been hard to predict.  In practice, LN nodes using anchor
  outputs should pay lower fees normally (because there's no longer any
  incentive to overestimate fees) and also have greater security
  (because, if feerates do increase beyond what was predicted, the node
  can fee bump its commitment transaction).  Various degrees of support
  for anchor outputs have already been merged into several LN
  implementations monitored by Optech.

- [BOLTS #785][] updates the minimum CLTV expiry delta to 18 blocks.  To
  ensure that the latest state gets recorded onchain, a channel should
  be unilaterally closed when there are only this many blocks until an
  LN payment has to be settled.  However, the higher the expiry is, the
  more time a payment could become temporarily stuck in an open channel
  (either by accident or deliberately).  This has led some LN
  implementations to use route-finding algorithms that optimize for
  routes with low CLTV expiry deltas, which has in turn led some users
  to set their deltas to values that are especially unsafe.  This new
  minimum should help prevent inexperienced users from naively setting
  an unsafe value.

{% include references.md %}
{% include linkers/issues.md issues="14582,19743,19550,3954,524,955,688,785" %}
[lnd 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta
[belcher coinswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018080.html
[news100 coinswap]: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation
