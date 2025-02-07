---
title: Difficulty adjustment algorithms

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: daa

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Consensus Enforcement

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Discussion about reseting testnet and tweaking its DAA
    url: /en/newsletters/2024/04/10/#discussion-about-resetting-and-modifying-testnet

  - title: New time warp vulnerability in testnet4's new DAA
    url: /en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4

  - title: Fast difficulty adjustment algorithm for a DAG blockchain
    url: /en/newsletters/2025/02/07/#fast-difficulty-adjustment-algorithm-for-a-dag-blockchain

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Time warp
    link: topic time warp

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Difficulty adjustment algorithms (DAAs)** are the methods by which
  mining difficulty is regulated, which affects the average time between
  blocks, the total amount of block space, and the rate of distribution
  of new bitcoins (the block subsidy).

---
Bitcoin's DAA attempts to keep the average time between blocks at
approximately one block every ten minutes.  It uses timestamps contained
within block headers to retarget difficulty every 2,016 blocks.

Bitcoin's [testnets][topic testnet] use a slightly different DAA than
Bitcoin.  The alternative DAAs are designed to ensure block production
continues even if there's a sudden major reduction in hashrate.  This
mechanism can't be used on Bitcoin itself due to it incentivizing miners
to lie about when they created their blocks; however, for a testnet
where coins have no value, there's no incentive to lie.

Other cryptocurrencies use different DAAs, and these have sometimes
resulted in severe security vulnerabilities for those systems.
Alternative DAAs for systems that use the same SHA256d PoW function as
Bitcoin have occasionally resulted in that system temporarily overpaying
or underpaying for hashrate, attracting miners away from (or to)
Bitcoin, leading to inconsistent block production in Bitcoin until the
problem is solved.

Alternative DAAs may also be used in Bitcoin-related protocols, such as
decentralized [mining pools][topic pooled mining] like Braidpool.

{% include references.md %}
{% include linkers/issues.md issues="" %}
