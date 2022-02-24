---
title: Joinpools

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Payment pools
  - Coinpools

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Fee Management
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: CoinPool generalized privacy for identifiable onchain protocols
    url: /en/newsletters/2020/06/17/#coinpool-generalized-privacy-for-identifiable-onchain-protocols

  - title: "OP_TAPLEAF_UPDATE_VERIFY proposal to simplify covenant and joinpool implementation"
    url: /en/newsletters/2021/09/15/#covenant-opcode-proposal

  - title: "Post-taproot soft fork ideas: OP_TAPLEAF_UPDATE_VERIFY"
    url: /en/newsletters/2021/10/27/#op-tapleaf-update-verify

  - title: "Proposed `OP_EVICT` opcode to make joinpools more efficient"
    url: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Coinjoin
    link: topic coinjoin

  - title: Channel factories
    link: topic channel factories

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Joinpools** are a construction that allows multiple users to
  trustlessly share ownership of a single UTXO.  When funds are spent,
  it's not possible to tell from the block chain which pool member (or
  members) spent the funds.  Joinpools can use presigned transactions or
  proposed protocol features to ensure each member can unilaterally
  withdraw their funds from the pool at any time.
---

{% include references.md %}
{% include linkers/issues.md issues="" %}
