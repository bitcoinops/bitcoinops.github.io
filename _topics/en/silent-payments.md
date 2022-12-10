---
title: Silent payments

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Silent Payments
      link: https://gist.github.com/RubenSomsen/c43b79517e7cb701ebf77eec6dbb46b8

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Silent payments proposed
    url: /en/newsletters/2022/04/06/#delinked-reusable-addresses

  - title: Updated alternative to BIP47 reusable payment codes compared to silent payments
    url: /en/newsletters/2022/07/06/#updated-alternative-to-bip47-reusable-payment-codes

  - title: Updated silent payments PR
    url: /en/newsletters/2022/08/24/#updated-silent-payments-pr

  - title: "BIPs #1349 adds BIP351 for a payment protocol inspired by silent payments"
    url: /en/newsletters/2022/10/05/#bips-1349

  - title: "2022 year-in-review: silent payments"
    url: /en/newsletters/2022/12/21/#silent-payments

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Output linking
    link: topic output linking

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Silent payments** are a type of payment that can be made to a
  unique onchain address for every payment even though the receiver
  provided the spender with a reusable (offchain) address.  This helps
  improve privacy.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
