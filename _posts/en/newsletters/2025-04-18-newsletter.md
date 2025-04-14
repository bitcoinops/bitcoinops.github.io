---
title: 'Bitcoin Optech Newsletter #350'
permalink: /en/newsletters/2025/04/18/
name: 2025-04-18-newsletter
slug: 2025-04-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections describing recent
changes to services and client software, announcements of new releases
and release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.  Also included is a correction to some
details from our story last week about SwiftSync.

## News

*No significant news this week was found in any of our [sources][].*

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.0][] is the latest major version of the network's
  predominate full node.  Its [release notes][bcc rn] describe several
  significant improvements: replacement of the default-off UPnP feature (responsible
  in part for several past security vulnerabilities) with a NAT-PMP
  option (also defaulting to off), improved fetching of parents of
  orphan transactions that may increase the reliability of Bitcoin
  Core's current [package relay][topic package relay] support, slightly
  more space in default block templates (potentially improving miner
  revenue), improvements in avoiding accidental [timewarps][topic
  time warp] for miners that might accidentally result in revenue loss
  if timewarps are forbidden in a [future soft fork][topic consensus
  cleanup], and a migration of the build system from autotools to cmake.

- [LND 0.19.0-beta.rc2][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [LDK #3593][] Implement a way to do BOLT 12 Proof of Payment

- [BOLTs #1242][] Make payment_secret mandatory and ASSUMED

## Correction

Last week's newsletter [story][news349 ss] about SwiftSync contained
several errors and confusing statements.

- *No cryptographic accumulator used:* we described SwiftSync as using a cryptographic
  accumulator, which is incorrect.  A cryptographic accumulator would allow testing
  whether or not an individual transaction output (TXO) was a part of a set.
  SwiftSync doesn't need to do that.  Instead, it adds a value
  representing a TXO to an aggregate when the TXO is created and
  subtracts the same value when the TXO is destroyed (spent).  After
  performing this for all TXOs that were supposed to be spent before the
  SwiftSync terminal block, the node checks that the aggregate is
  zero---indicating that all created TXOs were later spent.

- *Parallel block validation does not require assumevalid:* we described
  one way that parallel validation could work with SwiftSync, in which
  scripts up to the terminal SwiftSync block were not
  validated---similar to how Bitcoin Core works today during initial
  sync with _assumevalid_.  However, previous scripts could be validated
  with SwiftSync, although this would likely require changes to the
  Bitcoin P2P protocol to optionally include extra data with blocks.
  Bitcoin Core nodes already store this data for any block they also
  store, so we don't think adding a P2P message extension would be
  difficult if it was expected that a significant number of people
  wanted to use SwiftSync with assumevalid disabled.

- *Parallel block validation is for different reasons than Utreexo:*
  we wrote that SwiftSync is able to validate blocks in parallel for
  reasons similar to those of [Utreexo][topic utreexo], but they take different approaches.
  Utreexo validates a block (or series of blocks for efficiency) by
  starting with a commitment to the UTXO set, performing all of the
  changes to the UTXO set, and producing a commitment to the new UTXO
  set.  This allows the work of validation to be split based on the
  number of CPU threads; for example: one thread validates the first
  thousand blocks and another thread validates the second thousand
  blocks.  At the end of validation, the node checks that the commitment
  at the end of the first thousand blocks is the same as the commitment
  it started with for the second thousand blocks.

  SwiftSync uses an aggregate state that allows subtracting before
  adding.  Imagine a TXO is created in block 1 and spent in block 2.  If
  we process block 2 first, we subtract the representation of the TXO
  from the aggregate.  When we later process block 1, we add the
  representation of the TXO to the aggregate.  The net effect is zero,
  which is what gets checked at the end of SwiftSync validation.

We apologize to our readers for our mistakes and thank Ruben Somsen for
reporting them.

{% include snippets/recap-ad.md when="2025-04-22 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3593,1242" %}
[bitcoin core 29.0]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[sources]: /en/internal/sources/
[news349 ss]: /en/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download
[bcc rn]: https://bitcoincore.org/en/releases/29.0/
