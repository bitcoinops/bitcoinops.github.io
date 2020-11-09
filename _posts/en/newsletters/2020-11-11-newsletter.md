---
title: 'Bitcoin Optech Newsletter #123'
permalink: /en/newsletters/2020/11/11/
name: 2020-11-11-newsletter
slug: 2020-11-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares the announcement of a marketplace for
incoming LN channels. Also included are our regular sections with summaries of
a Bitcoin Core PR Review Club meeting and notable changes to popular Bitcoin
infrastructure software.

## Action items

*None this week.*

## News

- **Incoming channel marketplace:** Olaoluwa Osuntokun [announced][pool
  announce] a new *Lightning Pool* marketplace for buying incoming LN channels.  Users and
  merchants need channels with incoming capacity in order to allow
  quickly receiving funds over LN.  Some existing node operators already
  provide incoming channels, either for free or as a paid service, but
  Lightning Pool hopes to make this service more
  standardized and competitive.  The initial focus is a contract for
  highly ranked [nodes][node rankings] to provide an incoming
  channel for a period of 2,016 blocks (about two weeks).  Additional
  contract lengths and other features are planned for the future.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Add MuHash3072 implementation][review club #19055-2] is a PR ([#19055][Bitcoin
Core #19055]) by Fabian Jahr (incorporating code originally written by Pieter
Wuille) that implements the [MuHash algorithm][muhash mailing list] in C++.
MuHash is a rolling hash algorithm that can be used to calculate the hash
digest of a set of objects and efficiently update that digest when items are
added to or removed from the set. The algorithm could be used to calculate a
digest of the complete UTXO set, which would be useful for database consistency
checks or for a fast sync method such as [assumeutxo][topic assumeutxo].

The high-level concepts for MuHash had been discussed in [a previous review
club meeting][review club #19055], so this meeting focused specifically on the
specification and implementation of the algorithm.

{% include functions/details-list.md
  q0="How much state is stored inside the MuHash3072 rolling hash object? How
      much data is returned to a user requesting the set hash?"
  a0="The MuHash3072 object stores 3072 bits (384 bytes) of internal state.
      This state is hashed using a 256-bit hash function to return 256 bits (32
      bytes) to the end user. An optimization is to store both a numerator (for the
      added items) and a denominator (for the removed items), which would require
      6144 bits (768 bytes) of internal state, but would reduce the number of costly
      modulo operations required."
  a0link="https://bitcoincore.reviews/19055-2#l-47"

  q1="How can we test for membership in the MuHash set?"
  a1="MuHash is not an accumulator, so there is no efficient way to test for set
      membership. The only way would be to recalculate the MuHash digest from the
      entire set of objects and then compare the digests."
  a1link="https://bitcoincore.reviews/19055-2#l-131"

  q2="What does the `#ifdef HAVE___INT128` code in the MuHash implementation do?"
  a2="`#ifdef HAVE___INT128` is a C++ preprocessor directive. It ensures that code
      contained within the `#ifdef` and `#endif` directives is only compiled on
      platforms that support 128-bit integers. Since the MuHash code is
      operating on numbers that are many times larger than built-in integer types
      can handle, those numbers are broken down into multiple 'limbs', which are
      combined to make the full number. Larger limbs means fewer operations and
      therefore [better performance][muhash performance]. Support for 128-bit
      integers allows us to use 64-bit limbs and safely multiply the numbers in
      those limbs together (the product of two 64-bit numbers is a 128-bit number).
      If we can't use 64-bit limbs, then 32-bit limbs are used instead."
  a2link="https://bitcoincore.reviews/19055-2#l-190"

  q3="What is 1437 mod 99?"
  a3="1437 mod 99 = 51. This question was given as an example of an efficient way to
      calculate the remainder of a number when divided by a modulus that is slightly
      smaller than a power of the number base. In this example, 99 is slightly
      smaller than 10^2, so to calculate the remainder we can add the bottom half
      --- 37 in this case --- to the top half times the difference of the modulus from the
      base number power --- 14 * (10^2 - 99) in this case. The same technique is used
      in the MuHash implementation and explains why the modulus was chosen as a
      number slightly smaller than 2^3072."
  a3link="https://bitcoincore.reviews/19055-2#l-246"
%}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [BOLTs #807][] Fail channel in case of high-S remote signature reception FIXME:dongcarl

- [Eclair #1545][] Add blockchain watchdog FIXME:Xeyko

- [LND #4735][] adds a `max_local_csv` configuration parameter that
  will reject channels from peers who require the local node to wait for more
  than the indicated number of blocks before spending its
  funds if it unilaterally closes the channel.  The default maximum is
  10,000 blocks, and there's also a minimum of 144 blocks to ensure users
  don't set the value lower than is reasonable.

- [LND #4701][] adds the `assumechanvalid` (assume channels are
  valid) configuration option to default builds.  For nodes using the Neutrino
  client to retrieve [compact block filters][topic compact block
  filters], this allows the node to assume the channels it learns about via LN
  gossip are available rather than by expending additional bandwidth
  checking for related transactions in recent blocks.  If the assumption
  is wrong and the channels are actually not available (e.g. they've
  been closed recently), any payments LND attempts to route through
  those channels will fail.  This may cause delays or unnecessary
  payment failures but not the loss of funds.

{% include references.md %}
{% include linkers/issues.md issues="807,1545,4735,4701,19055,19055-2" %}
[node rankings]: https://nodes.lightning.computer/availability/v1/btc.json
[pool announce]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-November/002874.html
[muhash mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[muhash performance]: https://github.com/bitcoin/bitcoin/pull/19055#discussion_r508093977
