---
title: Submarine swaps

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
  - Liquidity Management

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Lightning Labs announces a new tool and service to facilitate submarine swaps
    url: /en/newsletters/2019/03/26/#loop-announced

  - title: Lightning Loop adds support for user swap-ins
    url: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins

  - title: "Electrum 4.0.1 adds support for submarine swaps"
    url: /en/newsletters/2020/07/22/#electrum-adds-lightning-network-and-psbt-support

  - title: Proposal to extend BOLT11 invoices to allow requesting prepayment for submarine swaps
    url: /en/newsletters/2023/06/21/#submarine-swaps

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Splicing
    link: topic splicing

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Submarine swaps** are trust-minimized atomic swaps of offchain
  bitcoins for onchain bitcoins.  A payment secured by an HTLC is routed
  over LN to a service provider who creates an onchain output paying the
  same HTLC.  The onchain receiver can settle the HTLC to claim its
  funds, allowing the LN HTLCs to be settled like normal.
---

{% include references.md %}
{% include linkers/issues.md issues="" %}
