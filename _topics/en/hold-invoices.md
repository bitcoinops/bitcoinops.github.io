---
title: Hold invoices

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Hold invoices** are LN invoices where the receiver doesn't
  immediately release the preimage upon receiving a payment.  Instead,
  the receiver performs some action and then either accepts the payment,
  explicitly rejects it, or lets it time out.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  For example, Alice could automatically generate hold invoices on her
  website but wait until a customer actually paid before searching her
  inventory for the requested item.  This would give her a chance to
  cancel the payment if she couldn't deliver.

  Hold invoices are sometimes spelled "hodl invoices".

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Hold invoices
      link: https://github.com/lightningnetwork/lnd/pull/2022

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LND #2022 merged adding support for hold invoices"
    url: /en/newsletters/2019/03/19/#lnd-2022
    date: 2019-03-19

  - title: "C-Lightning #2540 adds hook allowing plugins to implement hold invoices"
    url: /en/newsletters/2019/04/16/#c-lightning-2540
    date: 2019-04-16

  - title: "LND #3390 simplifies hold invoice logic by separate HTLC tracking"
    url: /en/newsletters/2019/09/11/#lnd-3390
    date: 2019-09-11

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
