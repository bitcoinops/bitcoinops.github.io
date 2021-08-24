---
title: Liquidity advertisements

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

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLTs #878: `option_will_fund`: liquidity ads"
      link: https://github.com/lightningnetwork/lightning-rfc/pull/878

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Proposal for nodes to advertise liquidity
    url: /en/newsletters/2018/11/13/#advertising-node-liquidity

  - title: Allowing dual funding for liquidity management
    url: /en/newsletters/2018/11/20/#dual-funded-channels

  - title: "C-Lightning #4639 adds experimental support for liquidity advertisements"
    url: /en/newsletters/2021/07/28/#c-lightning-4639

  - title: "Question: Will liquidity ads allow for third-party purchased liquidity ('sidecar channels')?"
    url: /en/newsletters/2021/08/25/#will-ln-liquidity-advertisements-and-dual-funding-allow-for-third-party-purchased-liquidity-sidecar-channels

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Dual funding
    link: topic dual funding

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Liquidity advertisements** are an experimental feature of LN that
  allows a node to publicize its willingness to contribute funds
  (liquidity) to a new channel requested by a remote peer.  The offering
  node specifies the duration of time they'll lease the liquidity and
  the amount they'll charge for it; the purchasing peer pays the lease
  fee using a dual-funded channel open.

---
{% include references.md %}
{% include linkers/issues.md issues="" %}
