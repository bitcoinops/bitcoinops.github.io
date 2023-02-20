---
title: Multipath payments

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
#shortname:

## Optional.  An entry will be added to the topics index for each alias
#
## LND source code calls these multi-path payments, Eclair source code
## calls them multi-part payments, no C-Lightning sources yet but Rusty and
## Zmn call them multipath payments
aliases:
  - Multipart payments
  - Simplified multipath payments
  - Base AMP

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Simplified Multipath Payments (SMPs)**, also called **Base AMP**,
  are LN payments that are split into two or more parts all sharing the
  same hash and preimage, and which are sent using a different path for
  each part.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Simplified Multipath Payments
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001577.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LN protocol 1.1 goals: multipath payments"
    url: /en/newsletters/2018/11/20/#multi-path-payments

  - title: "LND #3390 separates tracking of HTLCs from invoices as necessary for SMP"
    url: /en/newsletters/2019/09/11/#lnd-3390

  - title: "LND #3499 extends several RPCs to support tracking multipath payments"
    url: /en/newsletters/2019/11/27/#lnd-3499

  - title: "Eclair #1153 adds experimental support for multipath payments"
    url: /en/newsletters/2019/11/20/#eclair-1153

  - title: "LND #3442 preparatory PR adding features necessary for multipath payments"
    url: /en/newsletters/2019/11/13/#lnd-3442

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

  - title: "Boomerang: improving latency and throughput with multipath payments"
    url: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks

  - title: "LND #3970 adds support for multipath payments to its payment lifecycle"
    url: /en/newsletters/2020/04/08/#lnd-3970

  - title: "LND #3967 adds support for sending multipath payments"
    url: /en/newsletters/2020/04/15/#lnd-3967

  - title: "Rust-Lightning #441 adds support for simplified multipath payments"
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

  - title: "Eclair #1599 improves multipath spending to direct channel counterparties"
    url: /en/newsletters/2020/11/18/#eclair-1599

  - title: New paper analyzes benefit of multipath payments on routing success
    url: /en/newsletters/2021/03/31/#paper-on-probabilistic-path-selection

  - title: Electrum 4.1.0 adds support for multipath payments
    url: /en/newsletters/2021/05/19/#electrum-4-1-0-enhances-lightning-features

  - title: "Discussion about the effect of base fees on multipath payment costs"
    url: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion

  - title: "BOLTs #1031 allows paying slightly more than the requested amount when using multipath"
    url: /en/newsletters/2022/11/16/#bolts-1031

  - title: Discussion about using multipath overpayment with recovery to decrease payment latency
    url: /en/newsletters/2023/02/22/#ln-quality-of-service-flag

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Atomic Multipath Payments (AMPs)
    link: topic amp

  - title: Payment secrets
    link: topic payment secrets
---
Although proposed after atomic multipath payments ([AMP][topic amp]),
simplified multipath payments required fewer changes to the LN protocol
to implement and preserved the ability for spenders to receive a
cryptographic proof of payment, so they were the first to be deployed on
the production network.

The main downside of simplified multipath payments when using
[HTLCs][topic htlc] is that third-parties who see multiple payments all
using the same hash can infer that they're part of a larger true payment.

Both AMP and SMP allow splitting higher value HTLCs into multiple lower
value HTLCs that are more likely to
individually succeed, so a spender with sufficient liquidity can use
almost all of their funds at once no matter how many channels those
funds are split across.

{% include references.md %}
