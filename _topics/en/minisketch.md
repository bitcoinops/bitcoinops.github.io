---
title: Minisketch

title-aliases:
  - Libminisketch

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Developer Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Minisketch** is a library implementing an algorithm that allows
  efficient set reconcilliation of announcements in gossip protocols,
  such as those used in Bitcoin and LN.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: libminisketch

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "2018 year-in-review: research into reducing transaction relay data"
    url: /en/newsletters/2018/12/28/#libminisketch

  - title: Minisketch library released with implications for Bitcoin and LN
    url: /en/newsletters/2018/12/18/#minisketch-library-released

  - title: Researching bandwidth-efficient set reconciliation protocol
    url: /en/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions

  - title: New LN gossip wire protocol proposal designed for use with minisketch
    url: /en/newsletters/2022/02/23/#updated-ln-gossip-proposal

  - title: Research into interaction between LN rate limiting and minisketch gossiping
    url: /en/newsletters/2022/05/04/#ln-gossip-rate-limiting

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Erlay
    link: topic erlay
---
The type of set reconcilliation provided by minisketch underlies the
proposed [Erlay][topic erlay] improvement to Bitcoin transaction relay
efficiency.

Minisketch should not be confused with [miniscript][topic miniscript],
a system for helping wallets create and implement bitcoin security
policies.

{% include references.md %}
