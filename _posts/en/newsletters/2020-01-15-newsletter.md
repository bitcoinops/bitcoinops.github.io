---
title: 'Bitcoin Optech Newsletter #80'
permalink: /en/newsletters/2020/01/15/
name: 2020-01-15-newsletter
slug: 2020-01-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests help testing the next version of LND,
summarizes a discussion about soft fork activation mechanisms, and
describes a few notable changes to popular Bitcoin infrastructure
software.

## Action items

- **Help test LND 0.9.0-beta-rc1:** this [pre-release][lnd 0.9.0-beta]
  of the next major version of LND brings several new features and bug
  fixes.  Experienced users are encouraged to help test the software so
  that any problems can be identified and fixed prior to release.

## News

- **Discussion of soft fork activation mechanisms:** Matt Corallo
  started a [discussion][corallo sf] on the Bitcoin-Dev mailing list about
  what attributes are desirable in a soft fork activation method and
  submitted a proposal for a mechanism that contains those attributes.
  In short, the attributes are:

    1. The ability to abort if a serious objection to the proposed
       consensus rules changes is encountered

    2. The allocation of enough time after the release of updated
       software to ensure that most economic nodes are upgraded to
       enforce those rules

    3. The expectation that the network hash rate will be roughly the
       same before and after the change, as well as during any transition

    4. The prevention, as much as possible, of the creation of blocks
       that are invalid under the new rules, which could lead to false
       confirmations in non-upgraded nodes and SPV clients

    5. The assurance that the abort mechanisms can't be misused by
       griefers or partisans to withhold a widely desired upgrade with
       no known problems

    Corallo believes that a well-crafted soft fork using the [BIP9][]
    versionbits activation mechanism and surrounded with good community
    engagement fulfills the first four criteria---but not the fifth.
    Alternatively, a [BIP8][] flag-day soft fork fulfills the fifth
    criteria but encounters challenges fulfilling the other four
    criteria.  Corallo also worries that using BIP8 from the start of a
    soft fork deployment gives the impression that the developers of
    node software get to decide the rules of the system.

    As an alternative to either BIP9 or BIP8 alone, Corallo proposes
    a three-step process:  use BIP9 to allow a proposal to be
    activated within a one-year window; pause for a six-month discussion
    period if the proposal is not activated; and---if it's clear that
    the community still wants the proposal activated---force activation
    using a BIP8 flag day set to two years in the future (with faster
    activation possible using versionbits signaling).  Node software can
    prepare for this maximum 42-month process by including, even in its
    initial versions, a configuration option that users can manually enable
    to enforce the BIP8 flag day if necessary.  If the first 18 months of
    the activation period passes without activation (but also without
    any blocking problems being discovered), new releases can enable
    this option by default for the remaining 24 months of the activation
    period.

    In the responses to the post, [Jorge Timón][timon sf] and [Luke
    Dashjr][dashjr sf] both proposed that any BIP8-like mechanism use
    mandatory versionbits signaling leading up to the flag day (similar
    to how [BIP148][] proposed to activate segwit); Corallo
    [notes][corallo reply timon] that this conflicts with the third and
    fourth goals.  Jeremy Rubin provides a [quick analysis][rubin sf] of
    his previous [spork proposal][spork vid] (see [Newsletter #32][spork
    summary]) in the context of the five goals.  Anthony Towns provides
    [lucid commentary][towns sf] on several aspects of Corallo's
    proposal and Timón's response.

    No clear conclusion was reached in the thread and we expect
    to see continued discussion.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17578][] updates the `getaddressinfo` RPC to return an
  array of strings corresponding to the label used by an address.
  Previously, it returned an array of objects where the label contained
  fields for its name and its purpose, where purpose corresponded to the
  part of the wallet that generated the address.  Users who need the old
  behavior can use the `-deprecatedrpc=labelspurpose` configuration
  parameter until Bitcoin Core 0.21.

- [Bitcoin Core #16373][] causes the `bumpfee` RPC used for
  [Replace-by-Fee][topic rbf] fee bumping to return a [Partially Signed
  Bitcoin Transaction][topic psbt] (PSBT) when the user attempts to fee
  bump a transaction using a wallet with disabled private keys.  The
  PSBT can then be copied to an external wallet (such as a hardware
  device or cold wallet) for signing.

- [Bitcoin Core #17621][] fixes a potential privacy leak for users of
  the `avoid_reuse` wallet flag.  The flag prevents the wallet from
  spending bitcoins received to an address the wallet has already used
  for spending (see [Newsletter #52][news52 avoid_reuse]).  This enhances privacy by
  preventing otherwise-unrelated transactions from being associated
  together because they all involve the same address.  However, Bitcoin
  Core currently monitors for payments to any of its public keys using
  any of several different address formats.  This meant that multiple
  payments to the same public key---but with different addresses (e.g.
  P2PKH, P2WPKH, P2SH-P2WPKH)---could be associated with each other on
  the block chain even though the `avoid_reuse` behavior is supposed to
  prevent this type of linkability.  This merged PR fixes the problem for the
  `avoid_reuse` flag, and the ongoing adoption of [output script
  descriptors][topic descriptors] is expected to
  eliminate the problem of Bitcoin Core monitoring for alternative
  addresses.  This change is expected to be backported into the next
  Bitcoin Core maintenance release (see [PR #17792][Bitcoin Core
  #17792]).

- [LND #3829][] makes a number of internal changes and documentation
  updates in order to simplify adding [anchor outputs][] in the future.

{% include references.md %}
{% include linkers/issues.md issues="17578,16373,17621,3829,17792" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta-rc1
[corallo sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017547.html
[timon sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017548.html
[dashjr sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017551.html
[corallo reply timon]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017549.html
[rubin sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017552.html
[towns sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017553.html
[spork vid]: https://www.youtube.com/watch?v=J1CP7qbnpqA&feature=youtu.be
[spork summary]: /en/newsletters/2019/02/05/#probabilistic-bitcoin-soft-forks-sporks
[anchor outputs]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[news52 avoid_reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
