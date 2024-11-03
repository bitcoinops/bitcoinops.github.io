---
title: Payment probes

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Probing

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network
  - Privacy Problems

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Making path probing more convenient
    url: /en/newsletters/2018/11/13/#making-path-probing-more-convenient

  - title: Eclair #762 adds limited probing
    url: /en/newsletters/2019/01/22/#eclair-762

  - title: "BOLTs #608 provides a privacy update to BOLT4 to probe channels for the ultimate recipient"
    url: /en/newsletters/2019/08/28/#bolts-608

  - title: Lowering the cost of probing to make attacks more expensive
    url: /en/newsletters/2021/10/20/#lowering-the-cost-of-probing-to-make-attacks-more-expensive

  - title: "LN developer meeting summary: probing and balance sharing"
    url: /en/newsletters/2022/06/15/#probing-and-balance-sharing

  - title: "LDK #1555 now slightly prefers paying through channels which make balance probing harder"
    url:  /en/newsletters/2022/07/06/#ldk-1555

  - title: "C-Lightning #3259 adds support for payment secrets designed to resist recipient probing"
    url: /en/newsletters/2019/12/04/#c-lightning-3259

  - title: Discussion about preventing UTXO probing in interactively constructed LN funding transactions
    url: /en/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions

  - title: Upfront fees discussion and its ability to make probing more expensive
    url: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion

  - title: Preventing UTXO probing in dual funded channels
    url: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing

  - title: "LDK #1567 adds support for a basic payment probing API"
    url: /en/newsletters/2022/07/13/#ldk-1567

  - title: "LDK #2534 adds additional support for pre-payment probing"
    url: /en/newsletters/2023/09/27/#ldk-2534

  - title: "Dynamic Payment Switching and Splitting (PSS) proposed to thwart Balance Discovery Attacks"
    url: /en/newsletters/2023/10/04/#payment-splitting-and-switching

  - title: "LND #8136 updates the `EstimateRouteFee` RPC to use payment probing"
    url: /en/newsletters/2024/03/13/#lnd-8136

  - title: "LDK #3103 begins using data collected from frequent probing in its testing benchmarks"
    url: /en/newsletters/2024/06/21/#ldk-3103

## Optional.  Same format as "primary_sources" above
see_also:
  - title: JIT routing
    link: topic jit routing

  - title: Channel jamming attacks
    link: topic channel jamming attacks

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Payment probes** are packets designed to discover information about
  the LN channels they travel through, such as whether the channel can
  currently handle a payment of a certain size or how many bitcoins are
  allocated to each participant in the channel.  Probes use the regular
  payment (HTLC) mechanism but are designed to always fail, preventing
  any funds from being transfered.  Probing can be useful, but it can
  also reduce user privacy.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
