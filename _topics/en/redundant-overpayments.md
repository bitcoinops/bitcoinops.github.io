---
title: Redundant overpayments

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Stuckless payments
  - Boomerang payments

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Stuckless payments
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002029.html

    - title: Boomerang
      link: https://arxiv.org/pdf/1910.01834.pdf

    # Spear (not available publicly AFAICT): https://dl.acm.org/doi/10.1145/3479722.3480997

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Stuckless payments proposed
    url: /en/newsletters/2019/07/03/#stuckless-payments

  - title: "LN summit 2021: stuckless payments"
    url: /en/newsletters/2021/11/10/#ln-summit-2021-notes

  - title: "Speeding up payment delivery with algorithms and stuckless payments"
    url: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update

  - title: "Presentation summary: Boomerang"
    url: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks

  - title: "Using redundant overpayments instead of a quality-of-service flag"
    url: /en/newsletters/2023/02/22/#ln-quality-of-service-flag

  - title: "LN developer discussion about protocol changes to support redundant overpayments"
    url: /en/newsletters/2023/07/26/#ptlcs-and-redundant-overpayment

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Simplified multipath payments
    link: topic multipath payments

  - title: Atomic multipath payments
    link: topic amp

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Redundant overpayments** are LN payments split into parts where the
  spender sends a greater amount and more parts than necessary to pay
  the receiver's invoice.

---
Even if some of the parts fail to arrive at the receiver's node on the
first try due to forwarding failures, enough of the other parts may
arrive to allow the receiver to claim their invoiced amount.  Protocol
features prevent the receiver from claiming more than the invoiced
amount.  Compared to sending an exact amount, over paying initially can
eliminate the latency of resending failed payments in most cases.

An overpayment requires a mechanism that prevents the receiver from
claiming more than the invoiced amount.  The simplest mechanism for
implementing that is for the spender to not provide the receiver with
all the information necessary to claim each payment part until the
receiver indicates which payment parts have been received.  The spender
can then send the claim information for only the number of parts needed
to claim the invoiced amount.  A downside of this approach is that it
requires an extra roundtrip of communication between the receiver and
spender, which may be roughly equivalent to the time needed to handle
one round of payment failures.  By comparison, in the best case, an
exact payment will complete on the first try.  That means this type of
redundant overpayments can, in most cases, put a low ceiling on
the worst-case payment time at the cost of roughly doubling the
best-case time it would take to send a non-overpayment.

Other mechanisms may be able to use cryptography to eliminate the
roundtrip communication overhead, allowing overpayments to complete in
the same best-case amount of time as non-overpayments.  However, that
approach may come with additional complexity and may require a
significant number of forwarding nodes upgrade to support the new
protocol before it can become widely used.

{% include references.md %}
{% include linkers/issues.md issues="" %}
