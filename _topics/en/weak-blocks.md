---
title: Weak blocks

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: weak-blocks

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Mining
  - P2P Network Protocol

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Second look at weak blocks"
      link: https://delvingbitcoin.org/t/second-look-at-weak-blocks/805

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Using weak blocks for more recent feerate information
    url: /en/newsletters/2021/11/03/#submitting-transactions-directly-to-miners
    date: 2021-11-03

  - title: Proof-of-concept implementation of weak blocks for compact block relay
    url: /en/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation
    date: 2024-04-24
    feature: true

  - title: Weak blocks discussed at CoreDev.tech Berlin
    url: /en/newsletters/2024/05/01/#coredev-tech-berlin-event
    date: 2024-05-01

  - title: Weak blocks in the 2024 year in review
    url: /en/newsletters/2024/12/20/#weak-blocks
    date: 2024-12-20

  - title: Peer block template sharing proposed as an alternative to weak blocks
    url: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
    date: 2025-08-08

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Weak blocks** are blocks that are valid in every respect except that
  they do not meet the network's proof-of-work target, so they never become
  part of the chain.  Miners produce them far more often than full blocks,
  and a weak block reflects exactly which transactions the miner was trying
  to mine, so they have been proposed for feerate estimation, compact block
  relay between peers with divergent mempool policies, and related uses.
---
A weak block is produced by the same hashing work that produces real blocks:
a miner that finds a candidate with 10% of the required proof of work will,
on average, find nine such candidates for every block that reaches the full
target.  The candidate is a valid block in every other respect -- correct
structure, valid transactions, appropriate header -- and only the proof of
work is insufficient, which is why it is never added to the chain.

Because the work is identical, a weak block is an accurate statement of what
the miner was trying to mine at that moment.  To include an invalid
transaction in a weak block, a miner would have to risk producing an invalid
full-proof-of-work block that nodes would reject, losing the block reward.
That property is what makes weak blocks interesting: Pieter Wuille
[suggested][wuille relay] using them to improve [feerate estimation][topic
fee estimation], since unconfirmed transactions are otherwise the only
signal of what is paying to get mined and weak blocks appear much more often
than real blocks.  Greg Sanders later proposed relaying weak blocks to
improve [compact block relay][topic compact block relay] between peers whose
mempool policies diverge, because a weak block shows exactly which
transactions a miner had selected.

Weak blocks have not been deployed.  Later discussion has explored
alternatives with a similar goal, such as peers sharing block templates with
each other so that transaction differences between mempools can be resolved
without asking miners to relay weak blocks.

{% include references.md %}
{% include linkers/issues.md issues="" %}

[wuille relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019578.html
