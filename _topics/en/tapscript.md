---
title: Tapscript

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Soft Forks
  - Scripts and Addresses

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Tapscript** is the scripting language used for taproot script-path
  spends.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  It shares most operations with legacy and segwit Bitcoin Script but
  has a few differences:

  - `OP_CHECKMULTISIG` and `OP_CHECKMULTISIGVERIFY` are replaced by a
    `OP_CHECKSIGADD` opcode.

  - Many opcodes are redefined to be `OP_SUCCESS` opcodes that
    unconditionally render the entire script valid to simplify soft fork
    upgrades.

  - Signature hashes are calculated differently than in legacy script or
    BIP143 v0 segwit.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: bip-tapscript

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Executive briefing: Taproot and Tapscript"
    url: /en/2019-exec-briefing/#the-next-softfork
    date: 2019-06-14

  - title: BIP322 signmessage forward compatibility
    url: /en/bech32-sending-support/#message-signing-support
    date: 2019-07-10

  - title: Extended summary of bip-taproot and bip-tapscript
    url: /en/newsletters/2019/05/14/#overview-of-the-taproot--tapscript-proposed-bips
    date: 2019-05-14
    feature: true

  - title: Overview of Taproot and Tapscript
    url: /en/newsletters/2019/05/14/#soft-fork-discussion
    date: 2019-05-14

  - title: Tapscript resource limits
    url: /en/newsletters/2019/09/25/#tapscript-resource-limits
    date: 2019-09-25

  - title: Update on changes to schnorr, taproot, and tapscript
    url: /en/newsletters/2019/10/16/#taproot-update
    date: 2019-10-16

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Taproot
    link: topic taproot
---
