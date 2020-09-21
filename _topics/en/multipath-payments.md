---
title: Multipath payments

## Optional.  An entry will be added to the topics index for each alias
#
## LND source code calls these multi-path payments, Eclair source code
## calls them multi-part payments, no C-Lightning sources yet but Rusty and
## Zmn call them multipath payments
aliases:
  - AMP
  - Multipart payments

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Multipath payments** are LN payments split into two or more parts
  and sent using a different path for each part.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Smaller payments are more likely to succeed in general, and allowing a
  payment to be split allows the spender to use almost all of their funds at
  once no matter how many channels those funds are split across.  There
  are two basic multipath proposals:

  - *Atomic Multipath Payments (AMP)*, sometimes called *Original AMP*
    or *OG AMP*, which allows a spender to pay multiple hashes all
    derived from the same preimage---a preimage the receiver can only
    reconstruct if they receive a sufficient number of shares.  This
    only allows the receiver to accept a payment if they receive all of the
    individual parts.  Each share using a different hash adds privacy by
    preventing the separate payments from being automatically correlated
    with each other by a third party.  The proposal's downside is that
    the spender selects all the preimages, so knowledge of the preimage
    doesn't provide cryptographic proof that they actually paid the
    receiver.

  - *Base-AMP* which simply sends multiple payments all using to the
    same hash and assumes the receiver will wait until the full amount
    is received before claiming the payment (releasing the hash preimage
    and allowing generation of a provable receipt).  It's also possible
    for third-parties who see multiple payments using the same hash to
    assume they're part of the same true payment.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Atomic Multipath Payments
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html

    - title: Base AMP
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001577.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LN protocol 1.1 goals: multipath payments"
    url: /en/newsletters/2018/11/20/#multi-path-payments

  - title: "LND #3390 separates tracking of HTLCs from invoices as necessary for AMP"
    url: /en/newsletters/2019/09/11/#lnd-3390

  - title: "LND #3499 extends several RPCs to support tracking multipath payments"
    url: /en/newsletters/2019/11/27/#lnd-3499

  - title: "Eclair #1153 adds experimental support for multipath payments"
    url: /en/newsletters/2019/11/20/#eclair-1153

  - title: "LND #3442 preparatory PR adding features necessary for multipath payments"
    url: /en/newsletters/2019/11/13/#lnd-3442

  - title: "C-Lightning #3259 adds payment secrets to prevent multipath probing"
    url: /en/newsletters/2019/12/04/#c-lightning-3259

  - title: 'LND #3788 adds support for "payment addresses" (payment secrets)'
    url: /en/newsletters/2019/12/11/#lnd-3788

  - title: Multiple LN implementations add multipath payment support
    url: /en/newsletters/2019/12/18/#ln-implementations-add-multipath-payment-support

  - title: Basic multipath payment support added to LN specification
    url: /en/newsletters/2019/12/18/#bolts-643

  - title: "2019 year-in-review: multipath payments"
    url: /en/newsletters/2019/12/28/#multipath

  - title: "Eclair #1283 allows multipath payments to traverse unannounced channels"
    url: /en/newsletters/2020/01/22/#eclair-1283

  - title: "LND 0.9.0-beta adds support for receiving multipath payments"
    url: /en/newsletters/2020/01/29/#upgrade-to-lnd-0-9-0-beta

  - title: "Eclair 0.3.3 adds support for multipath payments"
    url: /en/newsletters/2020/02/05/#upgrade-to-eclair-0-3-3

  - title: "LND #3957 adds code useful for Atomic Multipath Payments (AMP) support"
    url: /en/newsletters/2020/02/12/#lnd-3957

  - title: "Boomerang: improving latency and throughput with multipath payments"
    url: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks

  - title: "LND #3970 adds support for multipath payments to its payment lifecycle"
    url: /en/newsletters/2020/04/08/#lnd-3970

  - title: "LND #3967 adds support for sending multipath payments"
    url: /en/newsletters/2020/04/15/#lnd-3967

  - title: "Rust-Lightning #441 adds support for basic multipath payments"
    url: /en/newsletters/2020/04/22/#rust-lightning-441

  - title: "LND 0.10 presentation: multipath payments"
    url: /en/newsletters/2020/05/06/#lnd-v0-10

  - title: "LND 0.10.0-beta released with support for multipath payments"
    url: /en/newsletters/2020/05/06/#lnd-0-10-0-beta

  - title: Lightning Loop adds support for multipath payments
    url: /en/newsletters/2020/05/20/#lightning-loop-using-multipath-payments

  - title: "Eclair #1427 and #1439 add support to Eclair for sending multipath payments"
    url: /en/newsletters/2020/07/08/#eclair-1427

  - title: Eclair 0.4.1 adds support for sending multipath payments
    url: /en/newsletters/2020/07/08/#eclair-0-4-1

  - title: Zap 0.7.0 Beta adds support for multipath payments
    url: /en/newsletters/2020/07/22/#zap-0-7-0-beta-released

  - title: "C-Lightning #3809 adds support for sending of multipath payments"
    url: /en/newsletters/2020/07/22/#c-lightning-3809

  - title: "LND #4521 improves invoice routing hints for multipath payments"
    url: /en/newsletters/2020/08/19/#lnd-4521

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
