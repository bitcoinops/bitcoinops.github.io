---
title: Payment secrets

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BOLT4
    - title: BOLT11

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "C-Lightning #3259 adds payment secrets to prevent multipath probing"
    url: /en/newsletters/2019/12/04/#c-lightning-3259

  - title: 'LND #3788 adds support for "payment addresses" (payment secrets)'
    url: /en/newsletters/2019/12/11/#lnd-3788

  - title: "BOLTs #643 adds payment secrets to LN specification"
    url: /en/newsletters/2019/12/18/#bolts-643

  - title: "CVE-2020-26896 could have been prevented by payment secrets"
    url: /en/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation

  - title: "LND #4752 prevents the node from releasing a local payment preimage without a payment secret"
    url: /en/newsletters/2020/12/02/#lnd-4752

  - title: "Rust-Lightning #893 requires payment secrets to prevent multipath probing"
    url: /en/newsletters/2021/05/05/#rust-lightning-893

  - title: "Eclair #1810 makes it mandatory for peers to signal and comply with the payment_secret feature"
    url: /en/newsletters/2021/05/26/#eclair-1810

  - title: "LND #5336 allows non-interactive reuse of AMP invoices by changing the payment secret"
    url: /en/newsletters/2021/06/09/#lnd-5336

  - title: "C-Lightning #4646 makes payment secrets required"
    url: /en/newsletters/2021/07/21/#c-lightning-4646

  - title: "BOLTs #887 updates BOLT11 to require that spenders specify the payment secret"
    url: /en/newsletters/2021/08/25/#bolts-887

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Simplified multipath payments
    link: topic multipath payments

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Payment secrets** are extra data added to BOLT11 invoices that
  spenders include in their BOLT4 onion-encrypted payments.  This
  allows the receiver to only accept a payment from the intended
  spender, preventing a probing attack against the receiver when
  simplified multipath payments are being used.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
