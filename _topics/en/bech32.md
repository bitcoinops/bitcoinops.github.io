---
title: Bech32
aliases:
  - BIP173
  - Native segwit address

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Bech32** is an address format used to pay native segwit outputs.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Using only 32 letters and numbers, the bech32 address format is case
  insensitive and includes an error-correction code that can catch
  almost all address typos (and even identify where the typos occur in
  some cases).  Addresses encode a segwit version, making them forward
  compatible with a large range of conceivable upgrades.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP173
    - title: Bech32 reference code
      link: https://github.com/sipa/bech32

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Bech32 sending support (24-part series)"
    url: /en/bech32-sending-support/
    date: 2019-03-19
    feature: true

  - title: Bech32 security update for C implementations
    url: /en/newsletters/2018/11/06#bech32-security-update-for-c-implementation
    date: 2018-11-06

  - title: How does the bech32 length-extension mutation weakness work?
    url: /en/newsletters/2019/11/27/#how-does-the-bech32-length-extension-mutation-weakness-work
    date: 2019-11-27

  - title: Impact of bech32 length-change mutability on v1 segwit script length
    url: /en/newsletters/2019/11/13/#taproot-review-discussion-and-related-information
    date: 2019-11-13

  - title: "LND #3767 rejects malformed BOLT11 invoices with a valid bech32 checksum"
    url: /en/newsletters/2019/12/11/#lnd-3767
    date: 2019-12-11

  - title: Proposed plan to deal with bech32 malleability in variable-length addresses
    url: /en/newsletters/2019/12/18/#review-bech32-action-plan
    date: 2019-12-18

  - title: Analysis of bech32 error detection capability
    url: /en/newsletters/2019/12/18/#analysis-of-bech32-error-detection
    date: 2019-12-18

  - title: "2019 year-in-review: bech32 mutability"
    url: /en/newsletters/2019/12/28/#bech32-mutability
    date: 2019-12-28

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Javascript bech32 demo decoder
    link: http://bitcoin.sipa.be/bech32/demo/demo.html
---
