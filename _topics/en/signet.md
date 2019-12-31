---
title: Signet

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Developer Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Signet** is both a tool that allows developers to create networks
  for testing interactions between different Bitcoin software and the
  name of the most popular of these testing networks.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Blocks on signets are only valid if they're signed by a key used to
  create that signet.  This gives the creator complete control over
  block production, allowing them to choose the rate of block production
  or when forks occur.  This can provide a much better controlled
  network environment than proof-of-work testnets where adversarial
  miners can use various tricks to make the network practically unusable
  for long periods of time.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Signet
      link: https://en.bitcoin.it/wiki/Signet

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Feedback requested on signet
    url: /en/newsletters/2019/03/12/#feedback-requested-on-signet
    date: 2019-03-12

  - title: "CoreDev.tech discussion: signet"
    url: /en/newsletters/2019/06/12#signet
    date: 2019-06-12

  - title: Progress on signet
    url: /en/newsletters/2019/07/24/#progress-on-signet
    date: 2019-07-24

  - title: C-Lightning adds support for signet
    url: /en/newsletters/2019/07/24/#c-lightning-2816
    date: 2019-07-24

  - title: C-Lightning 0.7.2.1 released with support for signet
    url: /en/newsletters/2019/08/21/#upgrade-to-c-lightning-0-7-2-1
    date: 2019-08-21

  - title: Eltoo demo implementation using custom signet
    url: /en/newsletters/2019/09/11/#eltoo-sample-implementation-and-discussion
    date: 2019-09-11

  - title: Signet protocol published as BIP325
    url: /en/newsletters/2019/11/13/#bips-803
    date: 2019-11-13

  - title: "2019 year-in-review: signet"
    url: /en/newsletters/2019/12/28/#signet
    date: 2019-12-28

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Bitcoin Core #16411: signet support"
    link: https://github.com/bitcoin/bitcoin/pull/16411
---
