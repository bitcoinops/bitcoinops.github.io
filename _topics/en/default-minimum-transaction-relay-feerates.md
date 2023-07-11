---
title: Default minimum transaction relay feerates

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Transaction Relay Policy
  - Fee Management
  - Mining

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Discussion about lowering the default minimum relay feerate
    url: /en/newsletters/2018/07/10/#discussion-min-fee-discussion-about-minimum-relay-fee

  - title: Accidentially creating transaction below the default min relay feerate
    url: /en/newsletters/2018/07/10/#unrelayable-transactions

  - title: "Bitcoin Core #16507 fixes a rounding issue related to the minimum relay feerate"
    url: /en/newsletters/2019/10/09/#bitcoin-core-16507

  - title: "Bitcoin Core #13987 adds info about peers' minimum feerates to `getpeerinfo`"
    url: /en/newsletters/2018/09/04/#bitcoin-core-13987

  - title: Discussion about lowering the default minimum transaction relay feerate
    url: /en/newsletters/2022/08/10/#lowering-the-default-minimum-transaction-relay-feerate

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Package relay
    link: topic package relay

  - title: Ephemeral anchors
    link: topic ephemeral anchors

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Default minimum transaction relay feerates** are the policy
  implemented by nodes for ignoring individual unconfirmed transactions
  whose feerate is below a certain amount.  For Bitcoin Core, this
  threshold has for several years been 1 sat/vbyte.
---
{% include references.md %}
{% include linkers/issues.md issues="" %}
