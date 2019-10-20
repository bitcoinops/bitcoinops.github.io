---
title: 'Bitcoin Optech Newsletter #69'
permalink: /en/newsletters/2019/10/23/
name: 2019-10-23-newsletter
slug: 2019-10-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests testing of the C-Lightning
and Bitcoin Core release candidates, invites
participation in structured review of the taproot proposal, highlights updates to two
Bitcoin wallets, and describes a few notable changes to popular
Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Help test release candidates:** experienced users are encouraged to
  help test the latest release candidates for the upcoming versions of
  [Bitcoin Core][Bitcoin Core 0.19.0] and [C-Lightning][c-lightning
  0.7.3].

## News

- **Taproot review:** starting the first week of November, several Bitcoin
  contributors will be hosting a series of weekly meetings to help guide
  people through review of the proposed [bip-schnorr][],
  [bip-taproot][], and [bip-tapscript][] changes.  All developers,
  academics, and anyone else with technical experience are welcome.  The
  expected commitment is four hours a week for seven weeks, with
  one hour each week being a group meeting and the other three hours
  being your own independent review of the proposals.  In addition to
  review, developers will be encouraged to optionally implement a
  proof-of-concept that either shows how schnorr or taproot can be integrated
  into existing software or that demonstrates the new or improved
  features the proposals make possible.
  This will help implementers to identify flaws or sub-optimal requirements in
  the current proposals that might be missed by people who only read the
  documentation.

    The ultimate goal of the review is to allow participants to
    gain enough technical familiarity with the proposals to be able to
    either vocally support the proposals, advocate for changes to the
    proposals, or clearly explain why the proposals shouldn't be adopted
    into the Bitcoin consensus rules.  Adding new consensus rules to
    Bitcoin is something that should be done carefully---because it can't
    be undone safely for as long as anyone's bitcoins depend on those rules---so
    it's in every user's interest
    that a large number of technical reviewers examine the proposals for
    possible flaws before they are implemented and before users are
    asked to consider upgrading their full nodes to enforce the new
    rules.  Whether through this organized review or
    in some other way, Optech strongly encourages all technically
    skilled Bitcoin users to dedicate time to reviewing the taproot set
    of proposals.

    Anyone wanting to participate should [RSVP][tr rsvp] soon so that the
    organizers can estimate the total number of participants and start
    forming study groups.  To register or learn more, please see
    the [Taproot Review][tr] repository.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin wallets
and services.*

- **Electrum Lightning support:** In a [series of commits this
  month][electrum commits], Electrum has merged support for Lightning
  Network into master. A presentation deck titled [Lightning Implementation in
  Electrum][electrum lightning presentation] by Thomas Voegtlin provides some
  background information and screenshots.

- **Blockstream Green Tor support:** Version 3.2.4 of the Blockstream Green
  Wallet [adds built-in Tor support][blockstream green tor article] for both iOS and Android.
  While Tor was supported in previous Android versions, it required a separate
  application whereas both Android and iOS versions are now bundled with Tor
  support.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #3150][] adds new `signmessage` and `checkmessage` RPCs.
  The first RPC will sign a message that can be verified by someone with
  your LN node's public key.  The second RPC will verify a signed message
  from another node either using a pubkey provided by the user or by
  confirming the message is signed by a pubkey belonging to any known LN
  node (e.g. a node in the set returned by the `listnodes` RPC).

- [LND #3595][] raises the default maximum CLTV expiry from 1,008 blocks
  (about 1 week) to 2,016 blocks (about two weeks).  This is the maximum
  amount of time a new payment can be stuck as pending before it can be reclaimed
  by its spender.  LND
  recently tried to keep this at 1,008 blocks by decreasing the CLTV
  delta---the minimum number of blocks each routing node along the payment path
  will have to claim its particular payment---from 144 blocks to 40 blocks
  (see [Newsletter #40][lnd cltv delta]) but older LND nodes and some
  other implementations have continued to use 144 as their default.  If
  each hop requires a delta of 144, the new maximum expiry of 2,016 makes the maximum-length
  routing path about 14 hops.

- [LND #3597][] reverts the migration policy described in [Newsletter
  #64][lnd3485] where LND could only be upgraded from a maximum of one major
  release back.  The PR for the reversion notes, "the prior stricter
  policy created a large burden on applications that package lnd as
  they're forced to deploy special code to handle certain upgrade paths.
  In addition, it was realized that the policy was most damaging to
  mobile deployments as it's customary for users to skip versions,
  making the stricter upgrade policy difficult to manage without
  dramatically affecting the end user."

{% include linkers/issues.md issues="3595,3597,3150" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[blockstream green tor article]: https://bitcoinmagazine.com/articles/blockstream-green-wallet-adds-early-access-tor-integration
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3rc3
[electrum commits]: https://github.com/spesmilo/electrum/commits/master
[electrum lightning presentation]: https://www.electrum.org/talks/lightning/presentation.html#slide1
[lnd cltv delta]: /en/newsletters/2019/04/02/#lnd-2759
[lnd3485]: /en/newsletters/2019/09/18/#lnd-3485
[tr]: https://github.com/ajtowns/taproot-review
[tr rsvp]: https://forms.gle/iiPaphTcYC5AZZKC8
