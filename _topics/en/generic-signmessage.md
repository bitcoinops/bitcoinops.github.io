---
title: Generic signmessage

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Signmessage
  - BIP322

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Wallet Collaboration Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Generic signmessage** is a method that allows wallets to sign or
  partially sign a message for any script from which they could
  conceivably spend.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  The [BIP322][] *generic signed message format* proposal is backwards
  compatible with the `signmessage` format implemented in early versions
  of the Bitcoin software, which is specific to the P2PKH address
  format.   For other addresses types, it implements a generic system
  based on producing a signature in much the same way a wallet would
  need to produce a signature in order to create a valid transaction.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP322
    - title: Bitcoin Core PR#16440
      link: https://github.com/bitcoin/bitcoin/pull/16440

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: BIP322 proposed
    url: /en/newsletters/2018/09/18/#bip322-generic-signed-message-format
    date: 2018-09-18

  - title: "2018 year-in-review: initial discussion that became BIP322"
    url: /en/newsletters/2018/12/28/#march
    date: 2018-12-28

  - title: Bitcoin Core PR opened for BIP322 signmessage support
    url: /en/newsletters/2019/07/31/#pr-opened-for-bip322-generic-signed-message-format
    date: 2019-07-31

  - title: Searching for a bech32 signmessage format
    url: /en/bech32-sending-support/#bip322
    date: 2019-07-10

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
