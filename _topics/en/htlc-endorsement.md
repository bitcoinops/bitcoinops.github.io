---
title: HTLC endorsement

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

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Unjamming Lightning: A Systematic Approach"
      link: https://raw.githubusercontent.com/s-tikhomirov/ln-jamming-simulator/master/unjamming-lightning.pdf

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Paper suggesting HTLC endorsement as part of a mitigation for jamming attacks"
    url: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks

  - title: "2022 year-in-review: HTLC endorsement for channel jamming"
    url: /en/newsletters/2022/12/21/#jamming

  - title: "Summary of call about mitigating LN jamming"
    url: /en/newsletters/2023/02/08/#summary-of-call-about-mitigating-ln-jamming

  - title: "Feedback requested on HTLC endorsement to mitigate jamming"
    url: /en/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring

  - title: "Testing HTLC endorsement for preventing channel jamming attacks"
    url: /en/newsletters/2023/05/17/#testing-htlc-endorsement

  - title: "Eclair #2701 now records HTLC receive and settlement times to help later testing of HTLC endorsement"
    url: /en/newsletters/2023/06/28/#eclair-2701

  - title: "LND #7710 allows retrieving extra data about an HTLC in support of trying HTLC endorsement"
    url: /en/newsletters/2023/06/28/#lnd-7710

  - title: "LN developer discussion about channel jamming attacks and HTLC endorsement"
    url: /en/newsletters/2023/07/26/#ptlcs-and-redundant-overpayment

  - title: "HTLC endorsement testing and data collection"
    url: /en/newsletters/2023/08/09/#htlc-endorsement-testing-and-data-collection

  - title: "Eclair #2884 implements BLIP4 for HTLC endorsement"
    url: /en/newsletters/2024/08/09/#eclair-2884

  - title: "BLIPs #27 adds BLIP04 for an experimental HTLC endorsement signaling protocol"
    url: /en/newsletters/2024/08/16/#blips-27

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Channel jamming attacks
    link: topic channel jamming attacks

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **HTLC endorsement** is a reputation system proposed for LN.  When a
  node receives a payment (HTLC) from a channel counterparty for
  forwarding, that payment may be flagged as endorsed.  If forwarded
  HTLCs from that counterparty have been profitable in the past, the
  node may choose to pass on that endorsement when it forwards the HTLC
  to the next hop.
---
Nodes opting into this endorsement protocol may give endorsed HTLCs
access to more resources than unendorsed HTLCs.  The two main resources
would be access to a channel's limited number of _HTLC slots_ (the number
of pending payments the channel can support) and the node's _liquidity_ (the
amount of capital it has available in the channel).  Both of those
resources are vulnerable to being used without payment (or with
insufficient payment) in a [channel jamming attack][topic channel
jamming attacks].

With endorsement, someone executing a channel jamming attack that makes
their counterparties less profitable will not have their HTLCs endorsed.
Honest parties will continue to have their HTLCs endorsed and will be
able to access any HTLC slots and liquidity that is only accessible to
endorsed HTLCs.

{% include references.md %}
{% include linkers/issues.md issues="" %}
