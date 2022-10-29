---
title: Low-r grinding

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Signature grinding

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Bandwidth Reduction
  - Fee Management

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Bitcoin Core wallet to begin only creating low-r signatures"
    url: /en/newsletters/2018/08/14/#bitcoin-core-wallet-to-begin-only-creating-low-r-signatures

  - title: "C-Lightning #3220 begins always creating signatures with a low r value"
    url: /en/newsletters/2019/11/06/#c-lightning-3220

  - title: "LDK #1388 adds default support for creating low-r signatures"
    url: /en/newsletters/2022/04/06/#ldk-1388

  - title: "BDK #779 adds support for creating low-r signatures"
    url: /en/newsletters/2022/11/02/#bdk-779

## Optional.  Same format as "primary_sources" above
see_also:
  - title: What is signature grinding?
    link: https://bitcoin.stackexchange.com/questions/111660/what-is-signature-grinding

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Low-r grinding** is an optimization for wallets where they keep
  generating new ECDSA signatures for the same transaction until the
  find a signature whose *r* value is on the lower half of the range,
  allowing it to be encoded with one fewer byte than a signature on the
  top half of the range.

---
This optimization only applies to legacy and segwit v0 transactions
where ECDSA is used.  Signatures in [taproot][topic taproot]
transactions can't be made any shorter.

Roughly half of all ECDSA transactions are expected to have high-r
values and roughly half are expect to have low-r values, so grinding
saves an average of 0.5 vbytes per signature in legacy transactions and
0.125 vbytes in segwit v0 transactions.

{% include references.md %}
{% include linkers/issues.md issues="" %}
