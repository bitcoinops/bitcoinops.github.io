---
title: 'Bitcoin Optech Newsletter #259'
permalink: /en/newsletters/2023/07/12/
name: 2023-07-12-newsletter
slug: 2023-07-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to remove details from the
LN specification that are no longer relevant to modern nodes and
includes the penultimate entry in our limited weekly series about
mempool policy, plus our regular sections summarizing a Bitcoin Core PR
Review Club meeting, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **LN specification clean up proposed:** Rusty Russell [posted][russell
  clean up] to the Lightning-Dev mailing list a link to a [PR][bolts
  #1092] where he proposes to remove some features that are no longer
  supported by modern LN implementations and to assume other features
  will always be supported.  Related to the proposed changes, Russell also
  provides the results of a survey he ran of public node features
  according to their gossip messages.  His results imply that nearly all
  nodes support the following features:

  - *Variable-sized onion messages:* made part of the specification in
    2019 (see [Newsletter #58][news58 bolts619]) around the same time as
    the specification was updated to use Type-Length-Value (TLV) fields.
    This replaced the original format for encrypted onion routing that
    required each hop to use a fixed-length message and limited the number
    of hops to 20.  The variable-sized format makes it much easier to
    relay arbitrary data to specific hops, with the only downside being
    that the overall message size remains constant, so any increase in
    the amount of data sent decreases the maximum number of hops.

  - *Gossip queries:* made part of the specification in 2018 (see [BOLTs #392][]).
    This allows a node to request from its peers only a subset of gossip
    messages sent by other nodes on the network.  For example, a node
    may request only recent gossip updates, ignoring older updates to
    save bandwidth and reduce processing time.

  - *Data loss protection:* made part of the specification in 2017 (see
    [BOLTs #240][]).  Nodes using this feature send information about
    their latest channel state when they reconnect.  This may allow a
    node to detect that it has lost data, and it encourages a node that
    has not lost data to close the channel in its latest state.  See
    [Newsletter #31][news31 data loss] for additional details.

  - *Static remote-party keys:* made part of the specification in 2019
    (see [Newsletter #67][news67 bolts642]), this allows a node to
    request that every channel update commit to sending the node's
    non-[HTLC][topic htlc] funds to the same address.  Previously, a
    different address was used in every channel update.  After this
    change, a node that opted into this protocol and lost data would
    almost always eventually receive at least some of their funds to their
    chosen address, such as an address in their [HD wallet][topic bip32].

  Initial replies to the clean-up proposal PR were positive.

## Waiting for confirmation #8: Policy Proposals

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/09-proposals.md %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:LarryRuane

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/27600#l-33FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.16.4-beta][] is a maintenance release of this LN node software
  that fixes a memory leak that may affect some users.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27869][] wallet: Give deprecation warning when loading a legacy wallet FIXME:adamjonas

{% include references.md %}
{% include linkers/issues.md v=2 issues="1092,392,240,27869" %}
[news58 bolts619]: /en/newsletters/2019/08/07/#bolts-619
[policy series]: /en/blog/waiting-for-confirmation/
[news31 data loss]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news67 bolts642]: /en/newsletters/2019/10/09/#bolts-642
[lnd v0.16.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.4-beta
[russell clean up]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/004001.html
