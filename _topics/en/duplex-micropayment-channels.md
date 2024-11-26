---
title: Duplex micropayment channels

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network
  - Contract Protocols

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: Bitcoin Duplex Micropayment Channels
    link: https://tik-old.ee.ethz.ch/file//716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Implementing statechains with duplex micropayment channels instead of LN-Symmetry
    url: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo

  - title: Pooled liquidity for LN using duplex micropayment channels
    url: /en/newsletters/2023/10/04/#pooled-liquidity-for-ln

  - title: SuperScalar timeout tree channel factories using duplex micropayment channels
    url: /en/newsletters/2024/11/01/#timeout-tree-channel-factories

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
  **Duplex micropayment channels** are bi-directional micropayment channels
  that use deincrementing relative time locks to ensure the latest state
  is the first that can be confirmed.  Compared to bi-directional
  LN-Penalty channels, they allow a much more limited number of state
  updates but safely support more than two participants.
---

{% include references.md %}
{% include linkers/issues.md issues="" %}
