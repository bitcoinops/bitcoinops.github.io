---
title: Channel factories

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network
  - Contract Protocols

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Channel factories** are a multi-user contract capable of opening
  payment channels without putting the channel-open transaction onchain.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  For example, three users create a channel factory by each of them
  depositing some funds to an onchain 3-of-3 multisig address.  Using
  non-broadcast (offchain) spends from that address, they open payment
  channels with each other (e.g. Alice↔Bob, Alice↔Charlie, and
  Bob↔Charlie).  They can then use those channels with the same security
  as if they had opened them onchain because, if necessary, they can
  broadcast the channel-open transactions.  However, they don't need to
  broadcast those transactions if both parties act cooperatively,
  allowing them to reduce the amount of block chain data used.

  For large numbers of users under ideal situations, channel factories
  can reduce the onchain size and fee cost of LN by 90% or more.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Scalable Funding of Bitcoin Micropayment Networks
      link: "https://tik-old.ee.ethz.ch/file//a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks%20(1).pdf"

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "2018 year-in-review: eltoo lays groundwork for channel factories"
    url: /en/newsletters/2018/12/28/#april
    date: 2018-12-28

  - title: Discussion of output tagging and its effect on eltoo and channel factories
    url: /en/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
    date: 2019-02-19

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
