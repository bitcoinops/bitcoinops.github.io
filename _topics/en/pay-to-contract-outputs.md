---
title: Pay-to-Contract (P2C) protocols

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: p2c

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Privacy Enhancements
  - Scripts and Addresses

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Pay to Contract Protocol
      link: https://arxiv.org/abs/1212.3257

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Taproot history: pay to contract protocol"
    url: /en/newsletters/2021/10/20/#pay-to-contract

  - title: Proposal to add extension fields to PSBTs for pay-to-contract
    url: /en/newsletters/2019/03/12/#extension-fields-to-partially-signed-bitcoin-transactions-psbts

  - title: "Eclair #965 allows specifying custom preimages, which can be used with pay-to-contract"
    url: /en/newsletters/2019/05/29/#eclair-965

  - title: "Question: Can Taproot commit arbitrary data to chain without any additional footprint?"
    url: /en/newsletters/2021/04/28/#can-taproot-be-used-to-commit-arbitrary-data-to-chain-without-any-additional-footprint

  - title: "PSBT extension for pay-to-contract fields"
    url: /en/newsletters/2022/01/26/#psbt-extension-for-p2c-fields

  - title: "BIPs #1293 adds BIP372 Pay-to-contract tweak fields for PSBT"
    url: /en/newsletters/2022/10/05/#bips-1293

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Proof of payment
    link: topic proof of payment

  - title: Taproot
    link: topic taproot

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Pay-to-contract protocols** allow a spender and a receiver to agree
  on the text of a contract (or anything else) and then create a
  public key that commits to that text.  The spender can then later
  demonstrate that the payment committed to that text and that it
  would've been computationally infeasible for that commitment to have
  been made without the cooperation of the receiver.  In short, P2C
  allows the spender to prove to a court or the public what they paid for.

---
{% include references.md %}
{% include linkers/issues.md issues="" %}
