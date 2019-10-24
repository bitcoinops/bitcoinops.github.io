---
title: Minisketch

aliases:
  - Libminisketch

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Developer Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Minisketch** is a library implementing an algorithm that allows
  efficient set reconcilliation of announcements in gossip protocols,
  such as those used in Bitcoin and LN.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  The type of set reconcilliation provided by minisketch underlies the
  proposed [Erlay][topic erlay] enhancement to the Bitcoin gossip
  protocol.

  Minisketch should not be confused with [miniscript][topic miniscript],
  a system for helping wallets create and implement bitcoin security
  policies.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: libminisketch

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "2018 year-in-review: research into reducing transaction relay data"
    url: /en/newsletters/2018/12/28/#libminisketch
    date: 2018-12-28

  - title: Minisketch library released with implications for Bitcoin and LN
    url: /en/newsletters/2018/12/18/#minisketch-library-released
    date: 2018-12-18

  - title: Researching bandwidth-efficient set reconciliation protocol
    url: /en/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
    date: 2018-08-21

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Erlay
    link: topic erlay
---
