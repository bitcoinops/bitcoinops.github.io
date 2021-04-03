---
title: Coinswap

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements
  - Contract Protocols

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Coinswap** is a protocol that allows two or more users to create a
  set of transactions that look like independent payments but which
  actually swap their coins with each other, optionally making a payment
  in the process. This improves the privacy of not just the coinswap
  users but all Bitcoin users, as anything that looks like a payment
  could have instead been a coinswap.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Coinswaps are often compared to [coinjoins][topic coinjoin].  The most
  obvious difference is that a coinjoin uses a single transaction but a
  coinswap uses two or more transactions.  Although it's possible for a
  coinjoin to look like [payment batching][topic payment batching],
  they can be fairly easy to identify onchain---and some Bitcoin exchanges
  have refused to accept coins with a recent history of coinjoining.
  Coinswaps look like payments, so they may be harder to discriminate
  against.  Coinswaps may also be performed across different block
  chains---often under the name *atomic swap*---but that's not possible
  with a coinjoin.

  To ensure that coinswaps either successfully swap funds or any
  unswapped funds are refunded, they need to use a locking mechanism
  such as an [HTLC][topic htlc] or a [PTLC][topic ptlc].

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Original idea for coinswap
      link: https://bitcointalk.org/index.php?topic=321228.0

    - title: Design for a coinswap implementation
      link: https://gist.github.com/chris-belcher/9144bd57a91c194e332fb5ca371d0964

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Talk about using schnorr signatures for blind coinswaps
    url: /en/newsletters/2018/07/10/#blind-signatures-in-sciptless-scripts

  - title: Two-transaction cross chain atomic swap or same-chain coinswap
    url: /en/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap

  - title: Design for a coinswap implementation
    url: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation

  - title: Presentation about coinswaps
    url: /en/newsletters/2020/07/01/#coinswap

  - title: Presentation about succinct atomic swaps
    url: /en/newsletters/2020/07/01/#sydney-meetup-discussion

  - title: Discussion about routed coinswaps
    url: /en/newsletters/2020/08/26/#discussion-about-routed-coinswaps

  - title: Continued coinswap discussion focused on potential weaknesses
    url: /en/newsletters/2020/09/09/#continued-coinswap-discussion

  - title: "2020 year-in-review: succinct atomic swaps"
    url: /en/newsletters/2020/12/23/#succinct-atomic-swaps-sas

  - title: "2020 year-in-review: routed coinswap discussion and implementation"
    url: /en/newsletters/2020/12/23/#coinswap-implementation

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Coinjoin
    link: topic coinjoin

  - title: HTLCs
    link: topic htlc

  - title: PTLCs
    link: topic ptlc
---
