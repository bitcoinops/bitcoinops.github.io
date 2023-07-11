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

## Waiting for confirmation #9: Policy Proposals

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/09-proposals.md %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Stop relaying non-mempool txs][review club 27625]
is a PR by Marco Falke (MarcoFalke) that simplifies the Bitcoin Core
client by removing an in-memory data structure, `mapRelay`, that may
cause high memory consumption and is no longer needed, or at least
is of very marginal benefit.
This map contains transactions that may or may not also be in the mempool,
and is sometimes used to reply to [`getdata`][wiki getdata] requests from peers.

{% include functions/details-list.md
  q0="What are the reasons to remove `mapRelay`?"
  a0="The memory consumption of this data structure is unbounded.
      Though typically it doesn't use much memory, it's concerning when
      the size of any data structure is determined by the behavior of
      outside entities (peers) and has no maximum, as this can create
      a DoS vulnerability."
  a0link="https://bitcoincore.reviews/27625#l-19"

  q1="Why is the memory usage of `mapRelay` hard to determine?"
  a1="Each entry in `mapRelay` is a shared pointer to a transaction
      (`CTransaction`), with the mempool possibly holding another pointer.
      A second pointer to the same object uses very little additional
      space relative to a single pointer.
      If a shared transaction is removed from the mempool,
      all of its space becomes attributable to the `mapRelay` entry.
      So `mapRelay`'s memory usage doesn't depend only on the number
      of transactions and their individual sizes, but also on how many
      of its transactions are no longer in the mempool, which is hard
      to predict."
  a1link="https://bitcoincore.reviews/27625#l-33"

  q2="What problem is solved by introducing `m_most_recent_block_txs`?
      (This is a list of only the transactions in the most recently-received
      block.)"
  a2="Without it, since `mapRelay` is no longer available, we wouldn't
      be able to serve just-mined transactions (in the most recent block)
      to peers requesting them, since we will have dropped them from
      our mempool."
  a2link="https://bitcoincore.reviews/27625#l-45"

  q3="Do you think it is necessary to introduce `m_most_recent_block_txs`,
      as opposed to just removing `mapRelay` without any replacement?"
  a3="There was some uncertainty among review club attendees on this question.
      It was suggested that `m_most_recent_block_txs` might improve block
      propagation speed, because if our peer doesn't yet have the block
      that we just received, our node's ability to provide its transactions
      may help complete our peer's [compact block][topic compact block relay].
      Another suggestion was that it may help in the event of a chain split;
      if our peer is on a different tip than us, it may not have that
      transaction via a block."
  a3link="https://bitcoincore.reviews/27625#l-54"

  q4="What are the memory requirements for `m_most_recent_block_txs`
      compared to `mapRelay`?"
  a4="The number of entries in `m_most_recent_block_txs` is bounded by
      the number of transactions in a block. But the memory requirement
      is even less than that many transactions, because `m_most_recent_block_txs`
      entries are shared pointers (to transactions), and they are
      also (already) pointed to by `m_most_recent_block`."
  a4link="https://bitcoincore.reviews/27625#l-65"

  q5="Are there scenarios in which transactions would be made available
      for a shorter or longer time than before as a result of this change?"
  a5="Longer when the time since the last block is greater than 15 minutes
      (which is the time that entries remained in `mapRelay`), shorter otherwise.
      This seems acceptable since the 15-minute time choice was rather arbitrary.
      But the change may decrease the availability of transactions in case of
      chain splits greater than one block deep (which are extremely rare)
      because we're not retaining transactions that are unique to non-best
      chains."
  a5link="https://bitcoincore.reviews/27625#l-70"
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

- [Bitcoin Core #27869][] gives a deprecation warning when loading a
  legacy wallet in the continued efforts outlined in [Bitcoin Core #20160][]
  to help users migrate from legacy wallets to [descriptor][topic descriptors]
  wallets as mentioned in Newsletters [#125][news125 descriptor wallets],
  [#172][news172 descriptor wallets], and
  [#230][news230 descriptor wallets].

{% include references.md %}
{% include linkers/issues.md v=2 issues="1092,392,240,20160,27869" %}
[news58 bolts619]: /en/newsletters/2019/08/07/#bolts-619
[policy series]: /en/blog/waiting-for-confirmation/
[news31 data loss]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news67 bolts642]: /en/newsletters/2019/10/09/#bolts-642
[lnd v0.16.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.4-beta
[russell clean up]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/004001.html
[review club 27625]: https://bitcoincore.reviews/27625
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[news125 descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news172 descriptor wallets]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[news230 descriptor wallets]: /en/newsletters/2022/12/14/#with-legacy-wallets-deprecated-will-bitcoin-core-be-able-to-sign-messages-for-an-address
