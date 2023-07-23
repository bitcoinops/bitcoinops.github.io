---
title: 'Bitcoin Optech Newsletter #261'
permalink: /en/newsletters/2023/07/26/
name: 2023-07-26-newsletter
slug: 2023-07-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a protocol for simplifying the
communication related to mutual closing of LN channels and summarizes
notes from a recent meeting of LN developers.  Also included are our
regular sections with popular questions and answers from the Bitcoin
Stack Exchange, announcements of new releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure
projects.

## News

- **Simplified LN closing protocol:** Rusty Russell [posted][russell
  closing] to the Lightning-Dev mailing list a proposal that simplifies
  the process of two LN nodes mutually closing a channel they share.
  With the new closing protocol, one of the nodes tells its peer that it
  wants to close the channel and indicates the amount of transaction fee
  it will pay.  That closing initiator will be responsible for the entire fee,
  although both outputs of a typical mutual close transaction will be
  immediately spendable so either party will be able to use [CPFP fee
  bumping][topic cpfp] in the normal case.  The new protocol is also
  compatible with exchanging information for [MuSig2][topic musig]-based
  [scriptless multisignatures][topic multisignature], which are part of
  in-development upgrades to LN that will increase privacy and lower
  onchain fee costs.

    No comments on Russell's proposal had been posted to the mailing
    list as of this writing but some initial comments had been posted to
    his [pull request][bolts #1096] with the complete proposal.

- **LN Summit notes:** Carla Kirk-Cohen [posted][kc notes] to the
  Lightning-Dev mailing list a summary of several discussions from the
  recent meeting of LN developers in New York City.  Some of the topics
  discussed included:

    - *Reliable transaction confirmation:* [package relay][topic package
      relay], [v3 transaction relay][topic v3 transaction relay],
      [ephemeral anchors][topic ephemeral anchors], [cluster
      mempool][topic cluster mempool], and other topics related to
      transaction relay and mining were discussed in the context of how
      they will provide a clearer path to allowing LN onchain
      transactions confirm more reliably, without the threat of [transaction
      pinning][topic transaction pinning] or needing to overpay fees
      when using [CPFP][topic cpfp] or [RBF][topic rbf] fee bumping.  We
      strongly recommend readers with an interest in transaction relay
      policy, which affects almost all second-layer protocols, read the
      notes for the insightful feedback provided by LN developers on
      several ongoing initiatives.

    - *Taproot and MuSig2 channels:* a brief discussion about the progress of
      channels that use [P2TR][topic taproot] outputs and [MuSig2][topic
      musig] for signatures.  A significant portion of the notes for this
      discussion was about a simplified mutual close protocol; see the previous
      news item for one of the results of that discussion.

    - *Updated channel announcements:* the LN gossip protocol currently only
      relays announcements of new or updated channels if those channels were
      funded using a P2WSH output that committed to a 2-of-2
      `OP_CHECKMULTISIG` script.  For moving to [P2TR][topic taproot]
      outputs with [MuSig2][topic musig]-based [scriptless
      multisignature][topic multisignature] commitments, the gossip
      protocol will need to be updated.  A [topic][topic channel
      announcements] also discussed during the previous in-person
      meeting of LN developers (see [Newsletter #204][news204 gossip])
      has been whether to make a minimal update to the protocol (called
      v1.5 gossip) that just adds support for P2TR outputs or a more
      general update to the protocol (called v2.0) that more broadly
      allows a valid signature for any UTXO of any type to be used for
      announcements.  Allowing any output to be used means that the
      output used to announce the channel is less likely than it is
      today to be the output actually being used to operate the channel,
      breaking the public link between outputs and channel funding.

      An additional consideration discussed was whether a UTXO with a value of
      _n_ should be allowed to announce a channel with a capacity greater than
      _n_.  This could allow channel participants to keep some of their funding
      transactions private.  For example, Alice and Bob could open two separate
      channels with each other; they could use one channel to create an
      announcement for greater than the value of the channel, making it clear
      that they could forward LN payments greater than the capacity of that
      channel using their other channel which had not been associated with a
      UTXO and so were more private.  This would help increase the plausibility
      that any output on the network, even one that had never been gossiped
      about in LN, was being used for an LN channel.

      The notes indicate a compromise decision, "v1.75 gossip", which
      seemed to allow using any script but with no available value
      multiplier.

    - *PTLCs and redundant overpayment:* from the notes, adding support for
      [PTLCs][topic ptlc] to the protocol was briefly discussed, mostly in
      relation to [signature adaptors][topic adaptor signatures].  More text in
      the notes was devoted to an improvement that would affect similar
      parts of the protocol: the ability to [redundantly overpay][topic
      redundant overpayments] an invoice and receive a refund for most
      or all of the overpayment.  For example, Alice wants to ultimately
      pay Bob 1 BTC.  She initially sends Bob 20 [multipath
      payments][topic multipath payments] each worth 0.1 BTC.  Using
      either math (via a technique called _Boomerang_, see [Newsletter
      #86][news86 boomerang]) or layered commitments and an extra
      communication round (called _Spear_), Bob is only able to claim a
      maximum of 10 of the payments; any others that arrive at his node
      are rejected.  The advantage of this approach is that up to 10 of
      Alice's MPP shards can fail to reach Bob without delaying the
      payment.  The downsides appear to be extra complexity and possibly
      (in the case of Spear) slower speed than today in the best case
      where every shard reaches Bob.  The participants discussed whether
      any changes that would help support redundant overpayments could
      be made at the same time as the changes necessary for PTLCs.

    - *Channel jamming mitigation proposals:* a substantial portion of
      the notes summarized discussion about proposals to mitigate
      [channel jamming attacks][topic channel jamming attacks].  The
      discussion started with a claim that no known single solution
      (such as reputation or upfront fees) can satisfactorily address
      the problem by itself without producing unacceptable downside.
      Reputation by itself must make allowances for new nodes without
      reputation and for the natural rate of failed HTLCs---provisions
      which an attacker can use to cause some level of harm, even if
      less than they could today.  Upfront fees by themselves must
      be set high enough to discourage attackers, but that might be high
      enough to also discourage honest users and to create a perverse
      incentive for nodes to deliberately fail to forward a payment.
      Instead, it was proposed that using several methods together might
      obtain the benefits without producing the worst-case costs.

      After examining the current understanding, the discussion notes
      focused on details about testing the local reputation scheme
      described in [Newsletter #226][news226 jamming] and setting the
      stage for a later implementation of low upfront fees to go along
      with it.  From the notes, it seemed like the participants
      supported seeing the proposal tested.

    - *Simplified commitments:* participants discussed the simplified
      commitments protocol idea (see [Newsletter #120][news120 commitments]),
      that defines which peer is responsible for proposing
      the next change to the commitment transaction rather than allowing
      either peer to propose a new commitment transaction at any time.
      Putting one peer in charge eliminates the complexity of two
      proposals being sent at roughly the same time, such as both Alice
      and Bob wanting to add an [HTLC][topic htlc] simultaneously.  A
      particular complication discussed in the notes were cases where
      one of the peers didn't want to accept the other's peer's
      proposal---a situation that's complicated to address in
      the current protocol.  A downside of the simplified commitment
      approach is that it may increase latency in some cases, as the
      peer who is not currently responsible for proposing the next
      change will need to request that privilege from its counterparty
      before proceeding.  The notes did not indicate a clear resolution
      to this discussion.

    - *The specification process:* the participants discussed various
      ideas for improving the specification process and the documents it
      manages, including the current BOLTs and BLIPs plus other ideas
      for documentation.  The discussion appeared highly varied and no
      clear conclusions were apparent from the notes.

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
projects.  Please consider upgrading to new releases or helping to test release candidates.*

- [HWI 2.3.0][] is a release of this middleware that allows software
  wallets to communicate with hardware signing devices.  It adds support
  for DIY Jade devices and a binary for running the main `hwi` program
  on Apple Silicon hardware with MacOS 12.0+.

- [LDK 0.0.116][] is a release of this library for creating LN-enabled
  software.  It includes support for [anchor outputs][topic anchor
  outputs] and [multipath payments][topic multipath payments] with
  [keysend][topic spontaneous payments].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core GUI #740][] Show own outputs on PSBT signing window FIXME:Murchandamus

{% include references.md %}
{% include linkers/issues.md v=2 issues="740,1096" %}
[russell closing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004013.html
[kc notes]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004014.html
[news193 gossip]: /en/newsletters/2022/03/30/#continued-discussion-about-updated-ln-gossip-protocol
[news204 gossip]: /en/newsletters/2022/06/15/#gossip-network-updates
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[news226 jamming]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news120 commitments]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[hwi 2.3.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.0
[ldk 0.0.116]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.116
