---
title: 'Bitcoin Optech Newsletter #219'
permalink: /en/newsletters/2022/09/28/
name: 2022-09-28-newsletter
slug: 2022-09-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow LN nodes to
advertise capacity-dependent feerates and announces a software fork of
Bitcoin Core focused on testing major protocol changes on signet.  Also
included are our regular sections with summaries of popular questions
and answers from the Bitcoin Stack Exchange, announcements of new
releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **LN fee ratecards:** Lisa Neigut [posted][neigut ratecards] to the
  Lightning-Dev mailing list a proposal for *fee ratecards* that would
  allow a node to advertise four tiered rates for forwarding fees.  For
  example, a forwarded payment that leaves a channel with less than 25%
  of its outbound capacity available to forward subsequent payments
  would need to pay proportionally more than a payment which leaves 75%
  of its outbound capacity available.

    Developer ZmnSCPxj [described][zmnscpxj ratecards] a simple way to
    use ratecards, "you can model a rate card as four separate channels
    between the same two nodes, with different costs each.  If the path
    at the lowest cost fails, you just try another route that may
    have more hops but lower effective cost, or else try the same
    channel at a higher cost."

    The proposal also allows for negative fees.  For example, a channel
    could subsidize payments forwarded through it when it had more than
    75% outbound capacity by adding 1 satoshi to every 1,000 satoshis in
    payment value.  Negative fees could be used by merchants to
    incentivize others to restore inbound capacity to channels
    frequently used for receiving payments.

    Neigut notes that some nodes are already adjusting their fees based
    on channel capacity, and that fee ratecards would provide a more
    efficient way for node operators to communicate their intentions to the network than
    frequently advertising new feerates via the LN gossip network.

- **Bitcoin implementation designed for testing soft forks on signet:**
  Anthony Towns [posted][towns bi] to the Bitcoin-Dev mailing list a
  description of a fork of Bitcoin Core he's working on that will only
  operate on the default [signet][topic signet] and which will enforce
  rules for soft fork proposals with high-quality specifications and
  implementations.  This should make it simpler for users to experiment
  with the proposed change, including directly comparing one change to
  another similar change (e.g. comparing [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] to [SIGHASH_ANYPREVOUT][topic
  sighash_anyprevout]).  Towns also plans to include proposed major
  changes to transaction relay policy (such as [package relay][topic
  package relay]).

    Towns is seeking constructive criticism of the idea for this new
    testing implementation, called [Bitcoin Inquisition][], as well as
    reviews of the [pull requests][bi prs] adding the initial set of
    soft forks to it.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
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

- [Core Lightning 0.12.1][] is a maintenance release containing several
  bug fixes.

- [Bitcoin Core 0.24.0 RC1][] is the first release candidate for the
  next version of the network's most widely used full node
  implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26116][] allows the `importmulti` RPC to import a
  watch-only item even if the wallet's private keys are encrypted.  This
  matches the behavior of the old `importaddress` RPC.

- [Core Lightning #5594][] makes several changes, including adding and
  updating several APIs, to allow the `autoclean` plugin to delete old
  invoices, payments, and forwarded payments.

- [Core Lightning #5315][] allows the user to choose the *channel
  reserve* for a particular channel.  The reserve is the amount a node
  will normally not accept from a channel peer as part of a payment or
  forward.  If the peer later attempts to cheat, the honest node can
  spend the reserve.  Core Lightning defaults to a channel reserve of 1%
  of the channel balance, penalizing by that amount any peers that
  attempt to cheat.

    This merged PR allows the user to reduce the reserve for a specific
    channel, including reducing it to zero.  Although this can be
    dangerous---the lower the reserve, the less penalty there is for
    cheating---it can be useful for certain situations.  Most notably,
    setting the reserve to zero can allow the remote peer to spend all of their
    funds, emptying their channel.

- [Rust Bitcoin #1258][] adds a method for comparing two locktimes to
  determine whether one satisfies the other.  As described in the code
  comments, "A lock time can only be satisfied by n blocks being mined
  or n seconds passing. If you have two lock times (same unit) then the
  larger lock time being satisfied implies (in a mathematical sense) the
  smaller one being satisfied.  This function is useful if you wish to
  check a lock time against various other locks e.g., filtering out
  locks which cannot be satisfied. Can also be used to remove the
  smaller value of two `OP_CHECKLOCKTIMEVERIFY` operations within one
  branch of the script."

{% include references.md %}
{% include linkers/issues.md v=2 issues="26116,5594,5315,1258" %}
[bitcoin core 0.24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[Core Lightning 0.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.1
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin/
[bi prs]: https://github.com/bitcoin-inquisition/bitcoin/pulls
[neigut ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003685.html
[zmnscpxj ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003688.html
[towns bi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020921.html
