---
title: 'Bitcoin Optech Newsletter #214'
permalink: /en/newsletters/2022/08/24/
name: 2022-08-24-newsletter
slug: 2022-08-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to the overview of a guide about channel
jamming attacks and summarizes several updates to a PR for silent
payments.  Also included are our regular sections with descriptions of
changes to popular services and clients, announcements of new releases
and release candidates, and summaries of notable changes to popular
Bitcoin infrastructure software.

## News

- **Overview of channel jamming attacks and mitigations:** Antoine Riard
  and Gleb Naumenko [announced][riard jam] to the Lightning-Dev mailing
  list that they've [published][rn jam] a guide to [channel jamming
  attacks][topic channel jamming attacks] and several proposed
  solutions.  The guide also examines how some solutions can benefit
  protocols building on top of LN, such as swap protocols and
  short-duration [DLCs][topic dlc].

- **Updated silent payments PR:** woltx [posted][woltx sp] to the
  Bitcoin-Dev mailing list that the PR to Bitcoin Core for [silent
  payments][topic silent payments] has been updated.  Silent payments
  provide an address that can be reused by different spenders without
  creating a link between those spends that's observable onchain (though
  the receiver needs to be careful not to weaken that privacy through
  their subsequent actions).  The most significant change to the PR is
  the addition of a new type of [output script descriptor][topic
  descriptors] for silent payments.

    The design of the new descriptor received quite a bit of discussion
    on the PR.  It was noted that only allowing a single silent payment
    descriptor per wallet would be most efficient for monitoring for new
    transactions but that it would also create a bad experience for
    users in many case.  A slight tweak to the silent payment design was
    proposed to address the issue, although it also came with trade
    offs.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.21.0][] is the latest release of this library for building
  wallets.

- [Core Lightning 0.12.0][] is a release of the next major
  version of this popular LN node implementation.  It includes a new
  `bookkeeper` plugin (see [Newsletter #212][news212 bookkeeper]), a
  `commando` plugin (see [Newsletter #210][news210 commando]), adds
  support for [static channel backups][topic static channel backups],
  and gives explicitly allowed peers the ability to open [zero-conf
  channels][topic zero-conf channels] to your node.  Those new features
  are in addition to many other added features and bug fixes.

- [LND 0.15.1-beta.rc1][] is a release candidate that "includes support
  for [zero conf channels][topic zero-conf channels], scid [aliases][],
  [and] switches to using [taproot][topic taproot] addresses everywhere".

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25504][] RPC: allow to track coins by parent descriptors FIXME:Xekyo

- [Eclair #2234][] adds support for associating a DNS name with a node
  in its announcements as now allowed by [BOLTs #911][] (see [Newsletter
  #212][news212 bolts911]).

- [LDK #1503][] adds support for [onion messages][topic onion messages]
  as defined by [BOLTs #759][].  The PR indicates that this change is in
  preparation for subsequently adding support for [offers][topic offers].

- [LND #6596][] adds a new `wallet addresses list` RPC that lists all of the
  wallet's addresses and their current balance.

- [BOLTs #1004][] begins recommending that nodes which maintain
  information about channels for routing should wait at least 12 blocks
  after a channel is closed before deleting their information it.  This
  delay will support detection of [splices][topic splicing] where a
  channel isn't actually closed but instead has funds added to or removed
  from it in an onchain transaction.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25504,2234,1503,911,759,6596,1004" %}
[core lightning 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[bdk 0.21.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.21.0
[lnd 0.15.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta.rc1
[news212 bolts911]: /en/newsletters/2022/08/10/#bolts-911
[aliases]: /en/newsletters/2022/07/13/#lnd-5955
[woltx sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020883.html
[riard jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-August/003673.html
[rn jam]: https://jamming-dev.github.io/book/
[news210 commando]: /en/newsletters/2022/07/27/#core-lightning-5370
[news212 bookkeeper]: /en/newsletters/2022/08/10/#core-lightning-5071
