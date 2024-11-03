---
title: 'Bitcoin Optech Newsletter #280'
permalink: /en/newsletters/2023/12/06/
name: 2023-12-06-newsletter
slug: 2023-12-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes several discussions about the proposed
cluster mempool and summarizes the results of a test performed using
warnet.  Also included are our regular sections summarizing a meeting of
the Bitcoin Core PR Review Club, announcing new releases and release
candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Cluster mempool discussion:** Bitcoin Core developers working on
  [cluster mempool][topic cluster mempool] started a [working
  group][wg-cluster-mempool] (WG) on the Delving Bitcoin forum. Cluster
  mempool is a proposal to make it much easier to operate on the mempool
  while respecting the required ordering of transactions.  A valid
  ordering of Bitcoin transactions requires parent transactions be
  confirmed before their children, either by putting the parent in an
  earlier block than any of its children, or earlier in the same block.
  In the cluster mempool design, _clusters_ of one or more related
  transactions are designed to be split into feerate-sorted _chunks_.
  Any chunk can be included in a block, up to the block's maximum
  weight, as long as all previous (higher feerate) unconfirmed chunks
  are included earlier in the same block.

  Once all transactions have been associated into clusters, and the
  clusters split into chunks, it's easy to choose which transactions
  to include in a block: select the highest-feerate chunk, followed by
  the next highest, over and over, until the block is full.  When this
  algorithm is used, it's obvious that the lowest-feerate chunk in the
  mempool is the chunk that's furthest from being included in a block,
  so we can apply the opposite algorithm when the mempool becomes full
  and some transactions need to be evicted: evict the lowest-feerate
  chunk, followed the next-lowest, over and over, until the local
  mempool is again below its intended maximum size.

  The WG archives can now be read by anyone, but only invited members
  can post.  Some noteworthy topics they've discussed include:

  {% assign timestamp="0:57" %}

  - [Cluster mempool definitions and theory][clusterdef] defines the terms being
    used in the design of cluster mempool.  It also describes a small
    number of theorems that showcase some of the useful properties of
    this design.  The single post in this thread (as of this writing) is
    very useful in understanding other discussions by the WG, although
    its author (Pieter Wuille) [warns][wuille incomplete] that it's
    still "very incomplete".

  - [Merging incomparable linearizations][cluster merge] looks at how
    to merge two different sets of chunks ("chunkings") for the same
    set of transactions, specifically _incomparable_ chunkings.  By
    comparing different lists of chunks ("chunkings"), we can
    determine which would be better for miners.  Chunkings can be
    compared if one of them always accumulates the same or greater
    amount of fees within any number of vbytes (discrete to the size
    of the chunks).  For example:

    ![Comparable chunkings](/img/posts/2023-12-comparable-chunkings.png)

    Chunkings are incomparable if one of them accumulates a greater
    amount of fees within some number of vbytes but the other chunking
    accumulates a greater amount of fees within a larger number of
    vbytes.  For example:

    ![Incomparable chunkings](/img/posts/2023-12-incomparable-chunkings.png)

    As one of the theorems in the previously linked thread notes, "if
    one has two incomparable chunkings for a graph, then another
    chunking must exist which is strictly better than both".  That
    means an effective method for merging two different incomparable
    chunkings can be a powerful tool for improving miner
    profitability.  For example, a new transaction has been received that
    is related to other transactions already in the mempool, so its
    cluster needs to be updated, which implies its chunking also
    needs to be updated.  Two different methods of making that update
    can both be performed:

    1. A new chunking for the updated cluster is computed from
       scratch.  For large clusters, it may be computationally
       impractical to find an optimal chunking, so the new chunking
       might be less optimal than the old chunking.

    2. The previous chunking for the previous cluster is updated by
       inserting the new transaction in a location that is valid
       (parents before children).  This has the advantage that it
       preserves any existing optimizations in the unmodified chunks
       but the downside that it could place the transaction in a
       suboptimal location.

    After the two different types of updates have been made, a
    comparison may reveal one of them is strictly better, in which
    case it can be used.  But, if the updates are incomparable, a
    merging method that's guaranteed to produce an equivalent or
    better result can be used instead to produce a third chunking that
    will capture the best aspects of both approaches---using new
    chunkings when they're better but keeping old chunkings when they
    were closer to optimal.

  - [Post-cluster package RBF][cluster rbf] discusses an alternative
    to the rules currently used for [replace by fee][topic rbf].
    When a valid replacement of
    one or more transactions is received, a temporary version of all
    the clusters it affects can be made and their updated chunking
    derived.  This can be compared to the chunking of the original
    clusters that are currently in the mempool (that don't include the
    replacement).  If the chunking with the replacement always earns equal or
    more fees than the original for any number of vbytes, and if it
    increases the total amount of fees in the mempool by enough to pay
    for its relay fees, then it should be included in the mempool.

    This evidence-based evaluation can replace several
    [heuristics][mempool replacements] currently used in Bitcoin
    Core to determine whether a transaction should be replaced,
    potentially improving the RBF rules in several areas, including
    proposed [package relay][topic package relay] for replacements.
    Several [other][cluster rbf-old1] threads [also][cluster
    rbf-old2] discussed [this][cluster rbf-old3] topic.

- **Testing with warnet:** Matthew Zipkin [posted][zipkin warnet] to
  Delving Bitcoin with the results of some simulations he's run using
  [warnet][], a program that launches a large number of Bitcoin nodes
  with a defined set of connections between them (usually on a test
  network).  Zipkin's results show the extra memory that would be used if
  several proposed changes to peer management code are merged (either
  independently or together).  He also notes that he's excited to use
  simulations for testing other proposed changes and to quantify the
  effect of proposed attacks. {% assign timestamp="32:42" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Testing Bitcoin Core 26.0 Release Candidates][review club v26-rc-testing]
was a review club meeting that did not review a particular PR, but rather was
a group testing effort.

Before each [major Bitcoin Core release][], extensive testing by the
community is considered essential.
For this reason, a volunteer writes a testing guide for a [release candidate][]
so that as many people as possible can productively test without having to
independently ascertain what's new or changed in the release, and reinvent
the various setup steps to test these features or changes.

Testing can be difficult because when one encounters unexpected behavior,
it's often unclear if it's due to an actual bug or if the tester is making a mistake.
It wastes developers' time to report bugs to them that aren't real bugs.
To mitigate these problems and promote testing efforts, a Review
Club meeting is held for a particular release candidate, in this instance, 26.0rc2.

The [26.0 release candidate testing guide][26.0 testing] was written by Max
Edwards, who also hosted the review club meeting with help from
Stéphan (stickies-v).

Attendees were also encouraged to get testing ideas by reading the [26.0 release notes][].

This review club session covered two RPCs, [`getprioritisedtransactions`][PR getprioritisedtransactions]
(also covered in an [earlier review club meeting][news250 pr review],
although the name of that RPC was changed after that review club meeting
was held), and [`importmempool`][PR importmempool].
The [New RPCs][] section of the release notes describes these and other
added RPCs.
The meeting also covered [V2 transport (BIP324)][topic v2 p2p transport],
and intended to cover [TapMiniscript][PR TapMiniscript] but this topic
wasn't discussed due to time limitations.

{% assign timestamp="43:18" %}

{% include functions/details-list.md
  q0="Which operating systems are people running?"
  a0="Ubuntu 22.04 on WSL (Windows Subsystem for Linux); macOS 13.4 (M1 chip)."
  a0link="https://bitcoincore.reviews/v26-rc-testing#l-18"

  q1="What are your results testing `getprioritisedtransactions`?"
  a1="Attendees reported that it worked as expected, but one noticed
      that the effects of [`prioritisetransaction`][prioritisetransaction]
      compounded; that is, running it twice on the same transaction doubled
      its fee.
      This is expected behavior, as the fee argument is _added_
      to the transaction's existing priority."
  a1link="https://bitcoincore.reviews/v26-rc-testing#l-32"

  q2="What are your results testing `importmempool`?"
  a2="One attendee received the error
      \"Can only import the mempool after the block download and sync is done\"
      but after waiting 2 minutes, the RPC was successful.
      Another participant noted that it takes a long time to complete."
  a2link="https://bitcoincore.reviews/v26-rc-testing#l-45"

  q3="What happens if we interrupt the CLI process during the import,
      then restart it (without stopping `bitcoind`)?"
  a3="This did not seem to cause any problem; the second import request
      completed as expected. It appears that the import process
      continued even after the CLI command was interrupted and
      that the second request didn't (for example) cause two import
      threads to run simultaneously and conflict with each other."
  a3link="https://bitcoincore.reviews/v26-rc-testing#l-91"

  q4="What are your results running V2 transport?"
  a4="The attendees weren't able to connect to a known mainnet
      V2-enabled node; it didn't seem to accept the connection request.
      It was suggested that all of its inbound slots may have been in use.
      Therefore, no P2P testing could be done during the meeting."
  a4link="https://bitcoincore.reviews/v26-rc-testing#l-115"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.0][] is the next major version of the predominant
  full-node implementation.  The release includes experimental support
  for the [version 2 transport protocol][topic v2 p2p transport],
  support for [taproot][topic taproot] in [miniscript][topic
  miniscript], new RPCs for working with states for [assumeUTXO][topic
  assumeutxo], and an experimental RPC for processing [packages][topic
  package relay] of transactions (which is not yet supported for relay),
  among numerous other improvements and bug fixes. {% assign timestamp="45:30" %}

- [LND 0.17.3-beta.rc1][] is a release candidate that contains several
  bug fixes. {% assign timestamp="57:41" %}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28848][] updates the `submitpackage` RPC to be more helpful when
  any transaction fails. Instead of throwing a `JSONRPCError` with the first
  failure, it returns results for each transaction whenever possible. {% assign timestamp="58:49" %}

- [LDK #2540][] builds on LDK's recent [blinded path][topic rv routing]
  work (see Newsletters [#257][news257 ldk2120] and [#266][news266 ldk2411])
  by supporting forwarding as the intro node in a blinded path and is part of
  LDK's BOLT12 [offers][topic offers] tracking [issue][LDK #1970]. {% assign timestamp="59:49" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28848,2540,1970" %}
[bitcoin core 26.0]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[wg-cluster-mempool]:  https://delvingbitcoin.org/c/implementation/wg-cluster-mempool/9
[clusterdef]: https://delvingbitcoin.org/t/clustermempool-definitions-theory/202
[cluster merge]: https://delvingbitcoin.org/t/merging-incomparable-linearizations/209/38
[cluster rbf]: https://delvingbitcoin.org/t/post-clustermempool-package-rbf-per-chunk-processing/190
[cluster rbf-old1]: https://delvingbitcoin.org/t/defunct-post-clustermempool-package-rbf/173
[cluster rbf-old2]: https://delvingbitcoin.org/t/defunct-cluster-mempool-package-rbf-sketch/171
[cluster rbf-old3]: https://delvingbitcoin.org/t/cluster-mempool-rbf-thoughts/156
[zipkin warnet]: https://delvingbitcoin.org/t/warnet-simulations/232
[warnet]: https://github.com/bitcoin-dev-project/warnet
[wuille incomplete]: https://github.com/bitcoinops/bitcoinops.github.io/pull/1421#discussion_r1414487021
[mempool replacements]: https://github.com/bitcoin/bitcoin/blob/fa9cba7afb73c01bd2c8fefd662dfc80dd98c5e8/doc/policy/mempool-replacements.md
[LND 0.17.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta.rc1
[review club v26-rc-testing]: https://bitcoincore.reviews/v26-rc-testing
[major bitcoin core release]: https://bitcoincore.org/en/lifecycle/#major-releases
[26.0 release notes]: https://github.com/bitcoin/bitcoin/blob/44d8b13c81e5276eb610c99f227a4d090cc532f6/doc/release-notes.md
[new rpcs]: https://github.com/bitcoin/bitcoin/blob/44d8b13c81e5276eb610c99f227a4d090cc532f6/doc/release-notes.md#new-rpcs
[news250 pr review]: /en/newsletters/2023/05/10/#bitcoin-core-pr-review-club
[release candidate]: https://bitcoincore.org/en/lifecycle/#versioning
[pr getprioritisedtransactions]: https://github.com/bitcoin/bitcoin/pull/27501
[pr importmempool]: https://github.com/bitcoin/bitcoin/pull/27460
[pr tapminiscript]: https://github.com/bitcoin/bitcoin/pull/27255
[prioritisetransaction]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[news257 ldk2120]: /en/newsletters/2023/06/28/#ldk-2120
[news266 ldk2411]: /en/newsletters/2023/08/30/#ldk-2411
