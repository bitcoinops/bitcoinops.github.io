---
title: Probabilistic payments

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols
  - Scripts and Addresses

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Electronic Lottery Tickets as Micropayments (1997)
      link: https://people.csail.mit.edu/rivest/pubs/Riv97b.pdf

    - title: "Sustainable nanopayment idea: Probabilistic Payments"
      link: https://bitcointalk.org/index.php?topic=62558.0

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Emulating `OP_RAND`"
    url: /en/newsletters/2025/02/07/#emulating-op-rand

  - title: "Probabilistic payments using different hash functions as an xor function"
    url: /en/newsletters/2025/03/14/#probabilistic-payments-using-different-hash-functions-as-an-xor-function

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Probabilistic payments** are outputs that allow a pseudorandom
  function to decide which of _n_ parties will be able to spend the funds.

---
For example, Alice and Bob each deposit 1 BTC into a contract that pays
one of them the full amount based on the result of a cryptographically fair
coin flip.

A particular focus of attention for probabilistic payments in Bitcoin is
for trustless micropayments.  For example, Alice wants to pay Bob 1 sat,
but that would be [uneconomical][topic uneconomical outputs] because it
will cost several hundred sats for Alice to create the payment and for
Bob to later spend it.  Instead, Alice offers Bob 10,000 sats with a
0.01% probability.  On average, that's equivalent to him receiving 1
sat.

Probabilistic micropayments have been proposed as an alternative for
[trimmed HTLCs][topic trimmed htlc].

{% include references.md %}
{% include linkers/issues.md issues="" %}
