---
title: 'Bitcoin Optech Newsletter #276'
permalink: /en/newsletters/2023/11/08/
name: 2023-11-08-newsletter
slug: 2023-11-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces an upcoming change to the Bitcoin-Dev
mailing list and briefly summarizes a proposal to allow aggregating
multiple HTLCs together.  Also included are our regular sections with
the summary of a Bitcoin Core PR Review Club, announcements of new
releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Mailing list hosting:** administrators for the Bitcoin-Dev mailing
  list [announced][bishop lists] that the organization hosting the list
  plans to cease hosting any mailing lists after the end
  of the year.  The archives of previous emails are expected to
  continue being hosted at their current URLs for the foreseeable
  future.  We assume that the end of email relay also affects the
  Lightning-Dev mailing list, which is hosted by the same organization.

    The administrators sought feedback from the community about options,
    including migrating the mailing list to Google Groups.  If such a
    migration happens, Optech will begin using that as one of our [news
    sources][sources].

    We're also aware that,
    in the months prior to the announcement, some well-established
    developers had begun experimenting with discussions on the
    [DelvingBitcoin][] web forum.  Optech will begin monitoring that
    forum for interesting or important discussions effective
    immediately. {% assign timestamp="1:05" %}

- **HTLC aggregation with covenants:** Johan Torås Halseth
  [posted][halseth agg] to the Lightning-Dev mailing list a suggestion
  for using a [covenant][topic covenants] to aggregate multiple
  [HTLCs][topic htlc] into a single output that could be spent all at
  once if a party knew all the preimages.  If a party only knew some of
  the preimages, they could claim just those and then the remaining
  balance could be refunded to the other party.  Halseth notes that this
  would be more efficient onchain and could make it more difficult to
  perform certain types of [channel jamming attacks][topic channel
  jamming attacks]. {% assign timestamp="5:36" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Fee Estimator updates from Validation Interface/CScheduler thread][review club 28368]
is a PR by Abubakar Sadiq Ismail (ismaelsadeeq)
that modifies the way the transaction fee estimator data is updated.
(Fee estimation is used when the node's owner initiates a transaction.)
It moves fee estimator updates from occurring synchronously during mempool
updates (transactions being added or removed) to instead occur asynchronously.
While this adds more processing complexity overall, it improves critical-path
performance (which the following discussion will make evident).

When a new block is found, its transactions that are in the mempool are removed
along with any transactions that conflict with the block's transactions.
Since block processing and relay are performance-critical, it's beneficial
to reduce the required amount of work during the processing of a new block,
such as updating the fee estimator. {% assign timestamp="16:47" %}

{% include functions/details-list.md
  q0="Why is it beneficial to remove `CTxMempool`'s dependency on `CBlockPolicyEstimator`?"
  a0="Currently, upon receiving a new block, its processing is blocked while the
      fee estimator is updated. This delays
      the completion of new block processing, and also delays relaying the block to peers.
      Removing `CTxMempool`'s dependency on `CBlockPolicyEstimator`
      allows fee estimates to be updated asynchronously (in a different thread)
      so that validation and relay can complete more quickly.
      It may also make testing `CTxMempool` easier.
      Finally, it allows the future use of more complex fee estimation
      algorithms without affecting block validation and relay performance."
  a0link="https://bitcoincore.reviews/28368#l-30"

  q1="Isn't fee estimation currently updated synchronously when transactions
      are added to or removed from the mempool even without a new block arriving?"
  a1="Yes, but performance isn't as critical at those times as during
      block validation and relay."
  a1link="https://bitcoincore.reviews/28368#l-41"

  q2="Are there any benefits of the `CBlockPolicyEstimator` being a member
      of `CTxMempool` and updating it synchronously (the current arrangement)?
      Are there downsides to removing it?"
  a2="Synchronous code is simpler and easier to reason about. Also, the fee
      estimator has more visibility into the entire mempool; a downside is
      the need to encapsulate all the information needed for fee estimation
      into a new `NewMempoolTransactionInfo` structure.
      However, not much information is needed by the fee estimator."
  a2link="https://bitcoincore.reviews/28368#l-43"

  q3="What do you think are the advantages and disadvantages of the approach
      taken in this PR, compared with the one taken in [PR 11775][] that
      splits `CValidationInterface`?"
  a3="While it seems nice to split them, they still had a shared backend
      (to keep the events well-ordered), so weren't really very independent
      of each other.
      There doesn't seem to be much practical benefit to splitting.
      The current PR is more narrow, and minimally scoped to making fee
      estimates update asynchronously."
  a3link="https://bitcoincore.reviews/28368#l-71"

  q4="In a subclass, why is implementing a `CValidationInterface` method
      equivalent to subscribing to the event?"
  a4="All subclasses of  `CValidationInterface` are clients.
      The subclass can implement some or all `CValidationInterface` methods (callbacks),
      for example, connecting or disconnecting a block, or a transaction
      [added][tx add] to or [removed][tx remove] from the mempool.
      After being registered (by calling `RegisterSharedValidationInterface()`),
      any implemented `CValidationInterface` method will be executed each time
      the method callback is fired using `CMainSignals`.
      Callbacks are fired whenever the corresponding event occurs."
  a4link="https://bitcoincore.reviews/28368#l-90"

  q5="[`BlockConnected`][BlockConnected] and [`NewPoWValidBlock`][NewPoWValidBlock]
      are different callbacks.
      Which one is asynchronous and which one is synchronous? How can you tell?"
  a5="`BlockConnected` is asynchronous; `NewPoWValidBlock` is synchronous.
      Asynchronous callbacks queue an \"event\" to be run later within the
      `CScheduler` thread."
  a5link="https://bitcoincore.reviews/28368#l-105"

  q6="In [commit 4986edb][], why are we adding a new callback,
      `MempoolTransactionsRemovedForConnectedBlock`, instead of using
      `BlockConnected` (which also indicates a transaction being removed
      from the mempool)?"
  a6="The fee estimator needs to know when transactions are removed from the
      mempool for any reason, not just when a block is connected.
      Also, the fee estimator needs a transaction's base fee, and this isn't
      provided via `BlockConnected` (which provides a `CBlock`).
      We could add the base fee to the `block.vtx` (transaction list) entries,
      but it's undesirable to change such an important and ubiquitous data
      structure just to support fee estimation."
  a6link="https://bitcoincore.reviews/28368#l-130"

  q7="Why don’t we use a `std::vector<CTxMempoolEntry>` as a parameter of
      `MempoolTransactionsRemovedForBlock` callback?
      This would eliminate the requirement for a new struct type to hold the
      per-transaction information needed for fee estimation."
  a7="The fee estimator doesn't need all of the fields from `CTxMempoolEntry`."
  a7link="https://bitcoincore.reviews/28368#l-159"

  q8="How is the base fee of a `CTransactionRef` computed?"
  a8="It's the sum of the input values minus the sum of the output values.
      However, the callback can't access the input values because they're stored
      in the previous transaction outputs (which the callback doesn't have access to).
      That's why the base fee is included in the `TransactionInfo` structure."
  a8link="https://bitcoincore.reviews/28368#l-166"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.0rc2][] is a release candidate for the next major
  version of the predominant full node implementation. There's a brief overview to [suggested
  testing topics][26.0 testing] and a scheduled meeting of the [Bitcoin
  Core PR Review Club][] dedicated to testing on 15 November 2023. {% assign timestamp="26:14" %}

- [Core Lightning 23.11rc1][] is a release candidate for the next
  major version of this LN node implementation. {% assign timestamp="29:26" %}

- [LND 0.17.1-beta.rc1][] is a releases candidate for a maintenance
  release for this LN node implementation. {% assign timestamp="31:28" %}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6824][] updates the implementation of the
  [interactive funding protocol][topic dual funding] to "store state
  when sending `commitment_signed`, and [add] a `next_funding_txid`
  field to `channel_reestablish` to ask our peer to retransmit
  signatures that we haven't received."  It is based on an
  [update][36c04c8ac] to the proposed [dual funding PR][bolts #851]. {% assign timestamp="32:38" %}

- [Core Lightning #6783][] deprecates the `large-channels` configuration
  option, making [large channels][topic large channels] and large
  payment amounts always enabled. {% assign timestamp="34:59" %}

- [Core Lightning #6780][] improves support for fee bumping onchain transactions
  associated with [anchor outputs][topic anchor outputs]. {% assign timestamp="36:29" %}

- [Core Lightning #6773][] allows the `decode` RPC to verify that the
  contents of a backup file are valid and contain the latest information
  necessary to perform a full recovery. {% assign timestamp="39:06" %}

- [Core Lightning #6734][] updates the `listfunds` RPC to provide
  information users need if they want to [CPFP][topic cpfp] fee bump a
  channel mutual close transaction. {% assign timestamp="39:58" %}

- [Eclair #2761][] allows forwarding a limited number of [HTLCs][topic
  htlc] to a party even if they're below their channel reserve
  requirement.  This can help resolve a _stuck funds problem_ that might
  occur after [splicing][topic splicing] or [dual funding][topic dual
  funding].  See [Newsletter #253][news253 stuck] for another mitigation
  by Eclair for a stuck funds problem. {% assign timestamp="41:02" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="6824,6783,6780,6773,6734,2761,851" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta.rc1
[sources]: /internal/sources/
[bishop lists]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022134.html
[delvingbitcoin]: https://delvingbitcoin.org/
[halseth agg]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-October/004181.html
[36c04c8ac]: https://github.com/lightning/bolts/pull/851/commits/36c04c8aca48e04d1fba64d968054eba221e63a1
[news253 stuck]: /en/newsletters/2023/05/31/#eclair-2666
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Testing-Guide-Topics
[review club 28368]: https://bitcoincore.reviews/28368
[pr 11775]: https://github.com/bitcoin/bitcoin/pull/11775
[tx add]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/validation.cpp#L1217
[tx remove]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/txmempool.cpp#L504
[BlockConnected]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L227
[NewPoWValidBlock]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L260
[commit 4986edb]: https://github.com/bitcoin-core-review-club/bitcoin/commit/4986edb99f8aa73f72e87f3bdc09387c3e516197
