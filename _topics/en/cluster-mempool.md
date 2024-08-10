---
title: Cluster mempool

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Transaction Relay Policy
  - Mining

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Bitcoin Core #27677: new mempool design"
      link: https://github.com/bitcoin/bitcoin/issues/27677

    - title: Introduction to cluster linearization
      link: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Bitcoin Core meeting transcript about mempool redesign"
    url: /en/newsletters/2023/05/17/#mempool-clustering

  - title: "Mempool proposals, including cluster mempool"
    url: /en/blog/waiting-for-confirmation/#policy-proposals
    date: 2023-07-12

  - title: "LN developer discussion about multiple relay policy topics, including cluster mempool"
    url: /en/newsletters/2023/07/26/#reliable-transaction-confirmation

  - title: "Multiple discussions about cluster mempool"
    url: /en/newsletters/2023/12/06/#cluster-mempool-discussion

  - title: "Discussion about cluster fee estimation"
    url: /en/newsletters/2024/01/03/#cluster-fee-estimation

  - title: "Overview of cluster mempoool, including discussion about its effect on CPFP carve-out"
    url: /en/newsletters/2024/01/17/#overview-of-cluster-mempool-proposal

  - title: "Interplay between cluster mempool, CPFP carve-out removal, and LN use of v3 relay"
    url: /en/newsletters/2024/01/24/#imbued-v3-logic

  - title: "Idea to apply RBF rules to v3 transactions to allow removing CPFP carve-out for cluster mempool"
    url: /en/newsletters/2024/01/31/#kindred-replace-by-fee

  - title: "Cluster mempool could help solve challenges opening zero-conf channels with v3 transaction relay"
    url: /en/newsletters/2024/02/07/#securely-opening-zero-conf-channels-with-v3-transactions

  - title: "Ideas for post-v3 relay enhancements after cluster mempool is deployed"
    url: /en/newsletters/2024/02/14/#ideas-for-relay-enhancements-after-cluster-mempool-is-deployed

  - title: "Bitcoin Core #29242 introduces utility functions to compare two feerate diagrams"
    url: /en/newsletters/2024/04/03/#bitcoin-core-29242

  - title: "Analysis: what would have happened if cluster mempool had been deployed a year ago?"
    url: /en/newsletters/2024/04/17/#what-would-have-happened-if-cluster-mempool-had-been-deployed-a-year-ago

  - title: "Introduction to cluster linearization"
    url: /en/newsletters/2024/07/19/#introduction-to-cluster-linearization

  - title: "Discussion about replacing CPFP carve-out with either TRUC or RBFR to unblock cluster mempool"
    url: /en/newsletters/2024/07/26/#path-to-cluster-mempool

  - title: "Question: why is restructure of mempool required with cluster mempool?"
    url: /en/newsletters/2024/07/26/#why-is-restructure-of-mempool-required-with-cluster-mempool

  - title: "Optimizing block building with cluster mempool"
    url: /en/newsletters/2024/08/02/#optimizing-block-building-with-cluster-mempool

  - title: "Bitcoin Core #30126 introduces a cluster linearization function for eventual use by cluster mempool"
    url: /en/newsletters/2024/08/02/#bitcoin-core-30126

  - title: "Bitcoin Core #30285 adds two key cluster linearization algorithms"
    url: /en/newsletters/2024/08/09/#bitcoin-core-30285

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Package relay
    link: topic package relay

  - title: Replace-by-Fee
    link: topic rbf

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Cluster mempool** is a proposal to associate each unconfirmed
  transaction in a mempool with related transactions, creating a
  _cluster_.  Each cluster contains feerate-sorted _chunks_ consisting
  of one or more transactions.  If we limit a cluster's size,
  we also limit how much needs to be recomputed in response to new
  transactions being added to the mempool, allowing algorithmic
  decisions affecting the entire mempool to complete fast enough to
  use them in P2P network code.

---
The overall goal of cluster mempool is being able to reason about the
effect of transactions on the blocks a miner would create if it has an
identical mempool to the local node's mempool.

The most apparent example of why we need that kind of
reasoning is the fact that today, the eviction mechanism (when the
mempool exceeds the node's size limit) can choose to evict the very best
transaction in the mempool overall ([example][wuille slide7]).

To describe the current limitation in short: miners prefer to select for inclusion the
transactions in order of highest ancestor-feerate first (feerate of a
set formed by a single transaction and all its unconfirmed ancestors).
Eviction removes transactions in order of lowest-descendant feerate
first (feerate of a set formed by a single unconfirmed transaction and
its descendants). This mechanism is certainly suboptimal (highest
ancestor-feerate first is just an approximation for highest-feerate
subset overall, and e.g. can't deal with
multiple-children-pay-for-the-same-parent), but more problematic is the
fact that eviction isn't the exact opposite of transaction selection: they're both
approximations, and the ways they are suboptimal don't cancel out, so
they don't result in the opposite order of each other.

## The obvious solution doesn't work

There is an obvious solution to the problem: instead of finding
lowest-feerate-descendant-sets, run the normal selection algorithm on the
entire mempool (don't stop after one block worth of transactions), and
see what it would include last. That's the thing you should evict!

Sadly, this is computationally infeasible. The block building algorithm
is fairly fast when running on one block worth of transactions, but
running it on the entire mempool would take a significant multiple of
the time. This is not possible to do every time
something needs to be evicted (which may be multiple times per second,
and ideally, with ~millisecond latency to not stall other processing).

An obvious question arises: can't we precompute things so that computing
the updated selection-order-of-full-mempool isn't too slow? And we kind of
can. What the block building algorithm ultimately does is find groups of
transactions to include at once (e.g. [child pays for parent][topic cpfp] means both
will be included at once), at the feerate that included set overall has
(sum of fees divided by sum of sizes). If we could somehow precompute
those groupings (which we'll call chunks) ahead of time, then the actual
block building algorithm (ignoring bin-packing issues once we get close
to the block being full) is just including chunks in decreasing feerate
order.

## Precomputing is feasible---but only if clusters are limited in size

So can we precompute the chunks, and update just the ones that get
affected when a new transaction or block comes in? Sadly, there is in
theory no bound on how many transactions' chunkings can be affected by
even a single new transaction---it could be the entire mempool, in which
case we'd be back to recomputing everything. See [this example][wuille
slide11] where a single newly added transaction completely reverses the
chunking of all transactions.

However, it is hopefully apparent that the limit of how much can be
affected by a transaction is just whatever transactions it is directly
or indirectly connected to, i.e. its cluster. Optimal chunks never cross
cluster boundaries---any chunk that did could be split into independent
chunks, and doing so would never worsen the result.  Thus, if clusters
are limited in size, we effectively also limit how much needs to be
recomputed in response to new transactions being added to the mempool.

So what is cluster mempool?

- A policy rule to limit how big clusters of transactions can get (a
  replacement for the current ancestor and descendant limits).

- As a result, it becomes feasible to precompute the chunkings (groups
  of transactions that will be included simultaneously at block building
  time) ahead of time by running the selection algorithm on those
  clusters individually and updating this precomputation on the fly
  whenever a cluster changes.

- Modify all places that effectively involve guessing "how will this
  impact future mined blocks" with looking up chunk feerates, which
  become kind of a "transaction selection score". This includes the aforementioned
  block building and eviction, but also transaction relay, [RBF][topic
  rbf] assessment, [package relay][topic package relay], possibly fee
  estimation, and maybe other things.

- As a result of the selection algorithm now working on very small sets,
  maybe even higher-quality algorithms than
  highest-ancestor-feerate-first become possible.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[wuille slide7]: https://docs.google.com/presentation/d/1Jl6VDNismGKEeVI7MxWsi0PW9pfNfKzOe1KdbH94QYw/edit#slide=id.g293b84fe537_0_63
[wuille slide11]: https://docs.google.com/presentation/d/1Jl6VDNismGKEeVI7MxWsi0PW9pfNfKzOe1KdbH94QYw/edit#slide=id.g293b84fe537_0_105
