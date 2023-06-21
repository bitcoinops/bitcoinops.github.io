---
title: Just-In-Time (JIT) channels

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: jit channels

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
   - title: "LSPS2: JIT channel negotiation"
     link: https://github.com/BitcoinAndLightningLayerSpecs/lsp/blob/d812a6481f9ff08cc16ab94807483205040de53b/LSPS2/README.md

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "LDK #1835 adds a SCID namespace for intercepted HTLCs allowing LSPs to open a JIT channel"
    url: /en/newsletters/2022/12/14/#ldk-1835

  - title: "Request for feedback on proposed specifications for LSPs, including LSPS2: JIT channels"
    url: /en/newsletters/2023/05/17/#request-for-feedback-on-proposed-specifications-for-lsps

  - title: Proposal to extend BOLT11 invoices to allow requesting prepayment for submarine swaps
    url: /en/newsletters/2023/06/21/#just-in-time-jit-channels

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
  **JIT channels** are virtual LN channels hosted by a service provider.
  When the first payment to the channel is received, the service
  provider creates a funding transaction and adds the payment to it,
  creating a normal channel.  This allows new user to begin receiving
  funds over LN immediately.

---
JIT channels should not be confused with [JIT routing][topic jit
routing], which is a technique for rebalancing existing channels to
allow accepting payments that might naively need to be rejected.

{% include references.md %}
{% include linkers/issues.md issues="" %}
