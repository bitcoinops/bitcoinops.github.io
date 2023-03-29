---
title: Proof of payment

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Discussion about LN's proof of payment not proving who paid"
    url: /en/newsletters/2018/11/06/#discussion-about-improving-lightning-payments

  - title: "CVE-2020-26896 improper preimage revelation gives proof of payment for stolen payments"
    url: /en/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation

  - title: "Using LN offers and proof of payment to partly address stuck payments"
    url: /en/newsletters/2021/04/21/#using-ln-offers-to-partly-address-stuck-payments

  - title: "LND adds support for AMP-based spontaneous payments, combining systems without proof of payment"
    url: /en/newsletters/2021/12/22/#amp

  - title: Request for proof that an async payment was accepted
    url: /en/newsletters/2023/01/25/#request-for-proof-that-an-async-payment-was-accepted

  - title: LN async proof of payment
    url: /en/newsletters/2023/02/01/#ln-async-proof-of-payment

  - title: "Safety notes about CLN `signinvoice` RPC providing false proof of payment when misused"
    url: /en/newsletters/2023/02/15/#core-lightning-5697

  - title: "BTCPay Server #4782 adds proof of payment on the receipt page for each payment"
    url: /en/newsletters/2023/04/05/#btcpay-server-4782

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Pay to contract
    link: topic p2c

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Proof of payment** is a cryptographic proof that a payment was made.
  The proof may indicate the identity (such as public key) of the payer
  and the recipient, and it may commit to additional payment details
  (such as a detailed invoice), but not all types of proofs provide
  those features.
---

{% include references.md %}
{% include linkers/issues.md issues="" %}
