---
title: Large channels

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Wumbo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Large channels** are LN payment channels where both peers send the
  parameter `option_support_large_channel` and which can be funded with
  a balance over 0.16777216 BTC.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
#
## BOLT2 "- if both nodes advertised `option_support_large_channel`:
## - MAY set `funding_satoshis` greater than or equal to 2^24 satoshi.
## otherwise:
## - MUST set `funding_satoshis` to less than 2^24 satoshi."
#
##  BOLT7 "for channels with `chain_hash` identifying the Bitcoin blockchain:
##  - MUST set this [`htlc_maximum_msat`] to less than 2^32."
extended_summary: |
  During the early development of LN, developers [agreed][russell why
  limit] to temporarily limit the maximum size of channels to less than
  2<sup>24</sup> base units (0.16777216 BTC; about $40 at the time) and
  individual payments to 2<sup>32</sup> msat (0.04294967296 BTC; about
  $10 at the time).  The goal was to limit the amount any individual
  early adopter would lose due to bugs in the software:

  > I **guarantee** that early releases of lightning clients will have
  > bugs and **people will lose money** because of them. [...] I sleep
  > better at night knowing that, if you lose money because of my bug, I
  > can buy you a beer/coffee in exchange for your story and we’re about
  > even. ---LN developer Rusty Russell (emphasis in original)

  After several years of LN development, the [2018 LN specification
  meeting][] decided to allow implementations to opt-in to [wumbo][]
  (jumbo) channel sizes with no protocol-level amount limit, although
  implementations and users can still refuse to accept channels over
  a customizable size.  Support for this new feature, later named
  `option_support_large_channel` saw widespread implementation among LN
  software in 2020.

  The limit of approximately 0.04 BTC per payment still remains part of
  the LN protocol specification, but [multipath payments][topic
  multipath payments] allow splitting a payment amount above the limit
  into several smaller parts that are each below the limit, making it
  possible for any compatible software to optionally send or receive
  payments above the limit.

  [2018 ln specification meeting]: /en/newsletters/2018/11/20/#feature-news-lightning-network-protocol-11-goals
  [wumbo]: /en/newsletters/2018/11/20/#wumbo
  [russell why limit]: https://medium.com/@rusty_lightning/bitcoin-lightning-faq-why-the-0-042-bitcoin-limit-2eb48b703f3

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Update to BOLT specifaction adding optional large channel support
      link: https://github.com/lightningnetwork/lightning-rfc//pull/596

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LN 1.1 specification meeting: wumbo channels and payments proposal"
    url: /en/newsletters/2018/11/20/#wumbo
    date: 2018-11-20

  - title: "BOLTs #596 updates BOLT2 to allow channel opens over ~0.17 BTC"
    url: /en/newsletters/2020/02/26/#bolts-596
    date: 2020-02-26

  - title:  "Eclair #1323 advertise support for channel opens over ~0.17 BTC"
    url: /en/newsletters/2020/03/11/#eclair-1323
    date: 2020-03-11

  - title: "C-Lightning #3612 adds support for `option_support_large_channel`"
    url: /en/newsletters/2020/04/08/#c-lightning-3612
    date: 2020-04-08

  - title: "LND #4075 allows creating invoices over 0.043 BTC"
    url: /en/newsletters/2020/04/15/#lnd-4075
    date: 2020-04-15

  - title: "C-Lightning 0.8.2 released with support for large channels"
    url: /en/newsletters/2020/05/06/#c-lightning-0-8-2
    date: 2020-05-06

  - title: LND 0.10.0-beta released with the ability to create invoices over 0.043 BTC
    url: /en/newsletters/2020/05/06/#lnd-0-10-0-beta
    date: 2020-05-06

  - title: "C-Lightning fixes incompatibility when opening large channels with Eclair"
    url: /en/newsletters/2020/05/13/#c-lightning-0-8-2-1
    date: 2020-05-13

  - title: "LND #4429 enables support for large channels by default"
    url: /en/newsletters/2020/07/22/#lnd-4429
    date: 2020-07-22

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Origin of "wumbo" term (video)
    link: https://www.youtube.com/watch?v=--hsVknT1c0
---
