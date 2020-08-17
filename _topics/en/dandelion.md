---
title: Dandelion
aliases:
  - BIP156

categories:
  - P2P Network Protocol
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Dandelion** is a privacy-enhancement proposal to allow transactions
  to first propagate serially from one node to one other node before
  being broadcast from one node to all of its peers.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  This propagation behavior would help hide which node originated the
  transaction, especially if some of the nodes involved in the initial
  serial relay ("stem phase") encrypted their Bitcoin protocol traffic
  using either Tor or something like [v2 P2P transport][topic v2 p2p
  transport].

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP156

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: What's the BIP156 hold-up in Bitcoin Core?
    url: /en/newsletters/2019/01/29/#what-s-the-hold-up-implementing-bip156-dandelion-in-bitcoin-core

  - title: PRs that need more review or development
    url: /en/newsletters/2019/02/19/#bitcoin-core-freeze-week

  - title: Erlay compatible with BIP156
    url: /en/newsletters/2019/06/05/#erlay-proposed

  - title: Discussion of Dandelion route selection
    url: /en/newsletters/2018/07/03/#dandelion-transaction-relay

  - title: Dandelion DoS-resistant stem routing being researched
    url: /en/newsletters/2018/08/21/#dandelion-protocol-dos-resistant-stem-routing

  - title: "2018 year-in-review notable developments: BIP156 Dandelion"
    url: /en/newsletters/2018/12/28/#dandelion

## Optional.  Same format as "primary_sources" above
# see_also:
#  - title:
#    link:
---
