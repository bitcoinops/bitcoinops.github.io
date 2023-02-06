---
title: 'Bitcoin Optech Newsletter #235'
permalink: /en/newsletters/2023/01/25/
name: 2023-01-25-newsletter
slug: 2023-01-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an analysis comparing proposals for
ephemeral anchors to `SIGHASH_GROUP` and relays a request for
researchers to investigate how to create proof that an LN async payment
was accepted.  Also included are our regular sections with summaries of
popular questions and answers on the Bitcoin Stack Exchange
and descriptions
of notable changes to popular Bitcoin infrastructure software.

## News

- **Ephemeral anchors compared to `SIGHASH_GROUP`:** Anthony Towns
  [posted][towns e-vs-shg] to the Bitcoin-Dev mailing list an analysis
  comparing the recent [ephemeral anchors][topic ephemeral anchors]
  proposal to an older [`SIGHASH_GROUP` proposal][].  `SIGHASH_GROUP`
  allows an input to specify which outputs it authorizes, with
  different inputs in a transaction being able to specify different
  outputs as long as they don't overlap.  This can be especially useful
  for adding fees to transactions in contract protocols where two or
  more inputs are used with presigned transactions.  The presigned
  nature of these transactions implies that fees may need to be added
  later when an appropriate feerate is known, and the existing
  `SIGHASH_ANYONECANPAY` and `SIGHASH_SINGLE` sighash flags aren't
  flexible enough for multi-input transactions because they only commit
  to a single input or output.

    Ephemeral anchors, similar to [fee sponsorship][topic fee
    sponsorship], lets anyone [CPFP][topic cpfp] fee bump a transaction.
    The transaction being fee-bumped is allowed to contain zero fees.
    Because anyone can fee bump a transaction using ephemeral anchors,
    this mechanism can also be used to pay fees for the multi-input
    presigned transactions which are a target for `SIGHASH_GROUP`.

    `SIGHASH_GROUP` would still have two advantages: first, it
    could allow [batching][topic payment batching] multiple unrelated
    presigned transactions, which could reduce transaction size
    overhead, reducing user costs and increasing network
    capacity.  Second, it doesn't require a child transaction,
    which would further reduce costs and increase capacity.

    Towns concludes by noting that ephemeral anchors, with its
    dependency on [v3 transaction relay][topic v3 transaction relay],
    captures most of the benefits of `SIGHASH_GROUP` and provides the
    significant advantage of being much easier to get into
    production than the `SIGHASH_GROUP` soft fork consensus change.

- **Request for proof that an async payment was accepted:** Valentine
  Wallace [posted][wallace pop] to the Lightning-Dev mailing list a
  request for researchers to investigate how someone making an [async
  payment][topic async payments] could receive proof that they paid.
  For traditional LN payments, the receiver generates a secret which
  gets digested by a hash function; that digest is given to the spender
  in a signed invoice; the spender uses an [HTLC][topic htlc] to pay
  anyone who discloses the original secret.  That disclosed secret
  proves the spender paid the digest contained in the signed invoice.

    By contrast, async payments are accepted when the receiver is
    offline, so they can't reveal a secret, preventing the creation of a
    proof of payment in the current LN model.  Wallace asks researchers
    to consider investigating how proof of payment for async payments
    could be obtained, either in LN's current HTLC-based system or a
    future upgrade to [PTLCs][topic ptlc].

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Bitcoin Core signing keys were removed from repo. What is the new process?]({{bse}}116649)
  Andrew Chow explains that while the signing keys were [removed][remove builder
  keys] from the Bitcoin Core repository, there is now a list of keys on the
  [guix.sigs repository][guix.sigs repo] which houses [guix][topic reproducible
  builds] build attestations.

- [Why doesn't signet use a unique bech32 prefix?]({{bse}}116630)
  Casey Rodarmor wonders why both testnet and [signet][topic signet] use
  the `tb1` [address prefix][wiki address prefixes]. Kalle, one of the [BIP325][] authors, explains that
  while signet initially used a different address prefix, it was thought using the same
  prefix would simplify usage of that alternate test network.

- [Arbitrary data storage in witness?]({{bse}}116875)
  RedGrittyBrick points to [one of several][large witness tx] recent P2TR
  transactions containing a large amount of witness data. Other users point out
  that the Ordinals project provides a service for including arbitrary data,
  like [the image][ordinals example] in the transaction above, into a Bitcoin transaction using the witness.

- [Why is the locktime set at transaction level while the sequence is set at input level?]({{bse}}116706)
  RedGrittyBrick provides early historical context for `nSequence` and `nLockTime`
  while Pieter Wuille goes on to explain the evolution in the meanings of these [timelock][topic
  timelocks] fields over time.

- [BLS signatures vs Schnorr]({{bse}}116551)
  Pieter Wuille contrasts the cryptographic assumptions between BLS and
  [schnorr][topic schnorr signatures] signatures, comments on the verification
  times, and notes complications around BLS [multisignatures][topic
  multisignature] and the lack of support for [adaptor signatures][topic adaptor signatures].

- [Why exactly would adding further divisibility to bitcoin require a hard fork?]({{bse}}116584)
  Pieter Wuille explains 4 soft fork methods that could enable sub-satoshi divisibility in transactions:

  1. A [forced soft fork][] method with consensus rule changes
     requiring all new transactions to comply with the new rules
  2. A one-way extension block that separates transactions following the new
     rules, similar to 1. above, but also allowing for legacy transactions
  3. A two-way extension block, similar to 2. above, but allowing coins
     following the new side to move back to legacy side
  4. A method that uses current consensus rules but truncates sub-satoshi
     amounts for old nodes by storing these sub-satoshi amounts elsewhere in
     the transaction

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26325][] improves the results of the `scanblocks` rpc
  by removing false positives in a second pass. `scanblocks` may be used
  to find blocks containing transactions relevant to a provided set of descriptors.
  Since scanning against the filters may falsely indicate some blocks
  that do not actually contain relevant transactions, this PR validates
  each hit in another pass to see whether blocks actually correspond to
  the passed descriptors before providing the results to the caller.
  For performance reasons, the second pass needs to be enabled by
  calling the RPC with the `filter_false_positives` option.

- [Libsecp256k1 #1192][] updates the library's exhaustive tests.  By
  changing the `B` parameter of the secp256k1 curve from `7` to another
  number, it is possible to find different curve groups that are
  compatible with libsecp256k1 but which are much smaller than
  secp256k1's order of approximately 2<sup>256</sup>.  On these tiny
  groups that are useless for secure cryptography, it's possible to test
  the libsecp256k1 logic exhaustively on every possible signature.  This
  PR added a group of size 7 in addition to the existing sizes 13 and
  199, although cryptographers first had to figure out the peculiar
  algebraic properties that caused the naive search algorithm for such
  groups to not always succeed before.  Size 13 remains the default.

- [BIPs #1383][] assigns [BIP329][] to the proposal for a standard
  wallet label export format.  Since the original proposal (see
  [Newsletter #215][news215 labels]), the main difference is a switch
  in data format from CSV to JSON.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26325,1383,1192" %}
[news215 labels]: /en/newsletters/2022/08/31/#wallet-label-export-format
[towns e-vs-shg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021334.html
[`sighash_group` proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019243.html
[wallace pop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003820.html
[forced soft fork]: https://petertodd.org/2016/forced-soft-forks
[remove builder keys]: https://github.com/bitcoin/bitcoin/commit/296e88225096125b08665b97715c5b8ebb1d28ec
[guix.sigs repo]: https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys
[wiki address prefixes]: https://en.bitcoin.it/wiki/List_of_address_prefixes
[large witness tx]: https://blockstream.info/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c?expand
[ordinals example]: https://ordinals.com/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c
