---
title: Watchtowers

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network
  - Security Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Watchtowers** send LN breach remedy transactions (justice
  transactions) when they detect that one of their client's
  counterparty has broadcast an outdated channel close transaction.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  The service provided by watchtowers allows their clients to go offline
  for significant amounts of time without having to worry about their
  funds being stolen by a counterparty.  Watchtowers are not
  entrusted with any funds, just the responsibility of monitoring the
  block chain and broadcasting transactions, although breach remedy
  transactions can be designed so that the watchtower receives a portion
  of the safeguarded funds if their services are needed.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LND PR #1543 adding watchtower version 0 encoding and encryption"
    url: /en/newsletters/2018/08/07/#lnd-1543
    date: 2018-08-07

  - title: "LND PRs #1535 and #1512 adding server-side communication for watchtowers"
    url: /en/newsletters/2018/10/30/#lnd-1535-1512
    date: 2018-10-30

  - title: "LND PR #2124 adding support for detecting and using onchain spends"
    url: /en/newsletters/2018/11/20/#lnd-2124
    date: 2018-11-20

  - title: "LND PR #2448 adding a standalone watchtower"
    url: /en/newsletters/2019/01/22/#lnd-2448
    date: 2019-01-22

  - title: "LND PR #2439 adding a default policy for the watchtower"
    url: /en/newsletters/2019/01/22/#lnd-2439
    date: 2019-01-22

  - title: "LND PR #2618 implementing private watchtower support"
    url: /en/newsletters/2019/03/19/#lnd-2618
    date: 2019-03-19

  - title: "LND PR #3133 adding support for altruist watchtowers"
    url: /en/newsletters/2019/06/19/#lnd-3133
    date: 2019-06-19

  - title: LND 0.7.0-beta release with initial watchtower support
    url: /en/newsletters/2019/07/03/#lnd-0-7-0-beta-released
    date: 2019-07-03

  - title: Watchtower storage costs
    url: /en/newsletters/2019/09/25/#watchtower-storage-costs
    date: 2019-09-25

  - title: Watchtower BOLT specification proposed
    url: /en/newsletters/2019/12/04/#proposed-watchtower-bolt
    date: 2019-12-04

  - title: Discussion about watchtowers for eltoo payment channels
    url: /en/newsletters/2019/12/11/#watchtowers-for-eltoo-payment-channels
    date: 2019-12-11

  - title: "2019 year-in-review: watchtowers"
    url: /en/newsletters/2019/12/28/#watchtowers
    date: 2019-12-28

  - title: Updated watchtower BOLT specification proposal
    url: /en/newsletters/2020/03/18/#proposed-watchtower-bolt-has-been-updated
    date: 2020-03-18

## Optional.  Same format as "primary_sources" above
see_also:
  - title: LND watchtower tutorial
    link: https://github.com/wbobeirne/watchtower-example
---
