---
title: Cluster mempool

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Transaction Relay Policy
  - Mining

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Bitcoin Core #27677: new mempool design"
      link: https://github.com/bitcoin/bitcoin/issues/27677

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
  cluster.  Each cluster of transactions, whether it be a single
  transaction or several transactions, can be ordered from most
  desirable to mine to least desirable, allowing operations for adding
  or removing new clusters to complete fast enough to use them in P2P
  network code.

---
If P2P network code can determine whether a new unconfirmed transaction
(or cluster of transactions) will improve the profitability of the
mempool for miners in the near term, that criteria can be used instead
of other heuristics for determining when a transaction [package][topic
package relay] or [replacement][topic rbf] should be accepted.  It is
hoped that this will allow transaction relay to provide more flexible
policy without exposing relay nodes to new resource-wasting attacks.

{% include references.md %}
{% include linkers/issues.md issues="" %}
