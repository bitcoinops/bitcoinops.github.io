---
title: Coin selection

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Fee Management
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Coin selection** is the method a wallet uses to choose which of its
  UTXOs to spend in a particular transaction.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Most early Bitcoin wallets implemented relatively simple coin
  selection strategies, such as spending UTXOs in the order they were
  received (first-in, first-out), but as fees have become more of a
  concern, some wallets have switched to more advanced algorithms that
  try to minimize transaction size.

  Coin selection strategies can also be used to improve onchain privacy
  by trying to avoid the use of UTXOs associated with previous
  transactions in later unrelated transactions.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Coin selection simulations
    url: /en/newsletters/2018/06/26/#coin-selection-simulations
    date: 2018-06-26

  - title: Coin selection groups for privacy and consolidation
    url: /en/newsletters/2018/07/17/#coin-selection-groups-discussion
    date: 2018-07-17

  - title: Bitcoin Core unlikely to add coin selection RPC
    url: /en/newsletters/2018/07/24/#coin-selection-rpc-unlikely
    date: 2018-07-24

  - title: Bitcoin Core PR#17290 coin selection for customized transactions
    url: /en/newsletters/2019/11/27/#bitcoin-core-17290
    date: 2019-11-27

  - title: Bitcoin Core PR#13756 adds flag to avoid address reuse privacy loss
    url: /en/newsletters/2019/06/26/#bitcoin-core-13756
    date: 2019-06-26

  - title: Bitcoin Core 0.19 adds wallet flag to avoid address reuse privacy loss
    url: /en/newsletters/2019/11/27/#optional-privacy-preserving-address-management
    date: 2019-11-27

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Simulation-based Evaluation of Coin Selection Strategies
    link: http://murch.one/wp-content/uploads/2016/09/CoinSelection.pdf
---
