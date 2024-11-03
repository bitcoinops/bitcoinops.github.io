---
title: Atomic multipath payments (AMPs)

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: amp

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - AMP
  # Although common, I prefer not to put "OG AMP" in the alias list -harding

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Atomic Multipath Payments
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LN protocol 1.1 goals: multipath payments"
    url: /en/newsletters/2018/11/20/#multi-path-payments

  - title: "LND #3957 adds code useful for Atomic Multipath Payments (AMP) support"
    url: /en/newsletters/2020/02/12/#lnd-3957

  - title: "LND #5108 adds support for spontaneous multipath payments using AMP"
    url: /en/newsletters/2021/04/14/#lnd-5108

  - title: "LND #5159 adds support for making spontaneous AMPs"
    url: /en/newsletters/2021/05/05/#lnd-5159

  - title: "LND #5253 adds support for Atomic Multipath Payment (AMP) invoices"
    url: /en/newsletters/2021/05/19/#lnd-5253

  - title: "LND #5336 adds the ability for users to reuse AMP invoices non-interactively"
    url: /en/newsletters/2021/06/09/#lnd-5336

  - title: "LND 0.13.0-beta allows receiving and sending payments using AMP"
    url: /en/newsletters/2021/06/23/#lnd-0-13-0-beta

  - title: "LND #5803 allows multiple spontaneous payments to the same AMP invoice"
    url: /en/newsletters/2021/11/03/#lnd-5803

  - title: "LND 0.14.0-beta allows multiple spontaneous payments to the same AMP invoice"
    url: /en/newsletters/2021/11/24/#lnd-0-14-0-beta

  - title: "2021 year-in-review: atomic multipath payments"
    url: /en/newsletters/2021/12/22/#amp

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Simplified Multipath Payments (SMP)
    link: topic multipath payments

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Atomic Multipath Payments (AMPs)**, sometimes called **Original AMP**
  or **OG AMP**, allow a spender to pay multiple hashes all derived from
  the same preimage---a preimage the receiver can only reconstruct if
  they receive a sufficient number of shares.
---
Unlike Simplified Multipath Payments ([SMP][topic multipath payments]), this only
allows the receiver to accept a payment if they receive all of the
individual parts.  Each share using a different hash adds privacy by
preventing the separate payments from being automatically correlated
with each other by a third party.  The proposal's downside is that the
spender selects all the preimages, so knowledge of the preimage doesn't
provide cryptographic proof that they actually paid the receiver.

Both AMP and SMP allow splitting higher value HTLCs into multiple lower
value HTLCs that are more likely to
individually succeed, so a spender with sufficient liquidity can use
almost all of their funds at once no matter how many channels those
funds are split across.

{% include references.md %}
{% include linkers/issues.md issues="" %}
