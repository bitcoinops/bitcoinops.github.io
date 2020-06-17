---
title: Output script descriptors
shortname: descriptors

aliases:
  - Descriptors

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Wallet Collaboration Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Output script descriptors** are strings that contain all the
  information necessary to allow a wallet or other program to track
  payments made to or spent from a particular script or set of related
  scripts (i.e. an address or a set of related addresses such as in an
  HD wallet).

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Descriptors combine well with [miniscript][topic miniscript] in
  allowing a wallet to handle tracking and signing for a larger variety
  of scripts.  They also combine well with [PSBTs][topic psbt] in
  allowing the wallet to determine which keys it controls in a multisig
  script.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Output script descriptors

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: First use of descriptors in Bitcoin Core
    url: /en/newsletters/2018/07/24/#first-use-of-output-script-descriptors
    date: 2018-07-24

  - title: Key origin support
    url: /en/newsletters/2018/10/30/#bitcoin-core-14150
    date: 2018-10-30

  - title: Descriptor checksum support added
    url: /en/newsletters/2019/02/19/#bitcoin-core-15368
    date: 2019-02-19

  - title: Descriptors extended with sortedmulti
    url: /en/newsletters/2019/10/16/#bitcoin-core-17056
    date: 2019-10-16

  - title: "Encoded descriptors (e.g., with base64)"
    url: /en/newsletters/2020/01/08/#encoded-descriptors
    date: 2020-01-08

  - title: "Bitcoin Core #18032 add `descriptor` field to multisig address RPCs"
    url: /en/newsletters/2020/02/12/#bitcoin-core-18032
    date: 2020-02-12

  - title: "Bitcoin Core #16528 adds support for native output descriptor wallets"
    url: /en/newsletters/2020/05/06/#bitcoin-core-16528
    date: 2020-05-06

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Miniscript
    link: topic miniscript
  - title: Partially-Signed Bitcoin Transactions (PSBTs)
    link: topic psbt
---
