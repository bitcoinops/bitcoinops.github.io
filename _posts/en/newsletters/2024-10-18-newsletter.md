---
title: 'Bitcoin Optech Newsletter #325'
permalink: /en/newsletters/2024/10/18/
name: 2024-10-18-newsletter
slug: 2024-10-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter looks at summaries of some of the topics
discussed at a recent LN developer meeting.  Also include are our
regular sections with descriptions of changes to popular clients and
services, announcements of new releases and release candidates, and
summaries of notable changes to popular Bitcoin infrastructure software.

## News

- **LN Summit 2024 notes:** Olaoluwa Osuntokun [posted][osuntokun
  summary] to Delving Bitcoin a summary of his [notes][osuntokun
  notes] (with additional commentary) from a recent LN developer
  conference.  Some of the topics discussed included:

  - **Version 3 commitment transactions:** developers discussed how to use
    [new P2P features][bcc28 guide], including [TRUC][topic v3 transaction relay]
    transactions and [P2A][topic ephemeral anchors] outputs, to improve
    the security of LN commitment transactions that can be used to
    unilaterally close a channel.  Discussion focused on various design
    tradeoffs.

  - **PTLCs:** although long proposed as a privacy upgrade to LN, as well
    as possibly useful for other purposes such as [stuckless
    transactions][topic redundant overpayments], recent research
    into the tradeoffs of various possible [PTLC][topic ptlc]
    implementations was discussed (see [Newsletter #268][news268 ptlc]).
    A particular focus was the construction of the [signature
    adaptor][topic adaptor signatures] (e.g. using scripted multisig
    versus scriptless [MuSig2][topic musig]) and its effect on the
    commitment protocol (see next item).

  - **State update protocol:** a proposal was discussed to convert LN's
    current state update protocol from allowing either side to propose an
    update at any time to only allowing one party at a time to propose
    updates (see Newsletters [#120][news120 simcom] and
    [#261][news261 simcom]).  Allowing either side to propose updates can
    result in both sides proposing updates simultaneously, which is
    difficult to reason about and can lead to accidental channel force
    closures.  The alternative is for only one party to be in
    charge at a time, e.g.  Alice is initially the only one allowed to
    propose state updates; if she has none to propose, she can tell Bob
    that he's in charge.  When Bob's finished proposing updates, he can
    transfer control back to Alice.  This simplifies reasoning about the
    protocol, eliminates problems with simultaneous proposals, and
    further makes it easy for the non-controlling party to reject any
    unwanted proposals.  The new round-based protocol would also work
    well with MuSig2-based signature adaptors.

  - **SuperScalar:** the developer of a proposed [channel factory][topic
    channel factories] construction for end-users gave a presentation on
    the proposal and solicited feedback.  Optech will publish a more
    detailed description of [SuperScalar][zmnscpxj superscalar] in a
    future newsletter.

  - **Gossip upgrade:** developers discussed upgrades to the [LN gossip
    protocol][topic channel announcements].  These are most urgently
    needed for supporting new types of
    funding transactions, such as for [simple taproot channels][topic
    simple taproot channels], but may also add support for other
    features.  One new feature discussed was having channel announcement
    messages include an SPV proof (or a commitment to an SPV proof) to
    allow lightweight clients to verify that a funding transaction (or
    sponsoring transaction) was included in a block at some point.

  - **Research on fundamental delivery limits:** research was presented on
    payment flows that cannot result in success given limitations of the
    network (e.g., channels with insufficient capacity); see [Newsletter
    #309][news309 feasible].  If an LN payment is infeasible, the
    spender and receiver can always use an onchain payment.  However,
    the rate of onchain payments is limited by the maximum block weight,
    so it's possible to calculate the maximum throughput (payments per
    second) of the combined Bitcoin and LN system by dividing the
    maximum onchain rate by the rate of infeasible LN payments.  Using
    this rough metric, to achieve a maximum of about 47,000 payments per
    second, the infeasible rate must be below 0.29%.  Two techniques
    were discussed for reducing the infeasible rate: (1) virtual or real
    channels that involve more than two parties, as more parties implies
    more funds for forwarding and more forwarding funds increases the
    rate of feasibility; and (2) credit channels where parties who
    trust each other can forward payments between themselves without the
    ability to enforce those payments onchain---with all other users
    still receiving trustless payments.

  Osuntokun encouraged other participants to post corrections or
  expansions to the thread.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.5][] is a release candidate (RC) of this library for
  building wallets and other Bitcoin-enabled applications.  This latest
  RC "enables RBF by default and updates the bdk_esplora client to retry
  server requests that fail due to rate limiting. The `bdk_electrum`
  crate now also offers a use-openssl feature."

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30955][] Mining interface: getCoinbaseMerklePath() and submitSolution()

- [Eclair #2927][] Enforce recommended feerate for on-the-fly funding (#2927)

- [Eclair #2922][] Remove support for splicing without quiescence (#2922)

- [LDK #3235][] Add `last_local_balance_msats` field

- [LND #8183][] chanbackup, server, rpcserver: put close unsigned tx, remote signature and commit height to SCB

- [Rust Bitcoin #3450][] Add version three variant to transaction version

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30955,2927,2922,3235,8183,3450" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[osuntokun summary]: https://delvingbitcoin.org/t/ln-summit-2024-notes-summary-commentary/1198
[osuntokun notes]: https://docs.google.com/document/d/1erQfnZjjfRBSSwo_QWiKiCZP5UQ-MR53ZWs4zIAVcqs/edit?tab=t.0#heading=h.chk08ds793ll
[news268 ptlc]: /en/newsletters/2023/09/13/#ln-messaging-changes-for-ptlcs
[news120 simcom]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news261 simcom]: /en/newsletters/2023/07/26/#simplified-commitments
[zmnscpxj superscalar]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[news309 feasible]: /en/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible
[bcc28 guide]: /en/bitcoin-core-28-wallet-integration-guide/
