---
title: SIGHASH_NOINPUT

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Soft Forks
  - Scripts and Addresses

aliases:
  - SIGHASH_ANYPREVOUT

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **SIGHASH\_NOINPUT** and **SIGHASH\_ANYPREVOUT** are proposals for a
  signature hash (sighash) where the identifier for the UTXO being
  spent is not signed, allowing the signature to be used with any
  UTXO that's protected by a similar script (i.e. uses the same public
  keys).

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  A noinput-style sighash is necessary for the proposed [eltoo][topic eltoo]
  layer for LN.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP118
    - title: bip-anyprevout

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Renaming of `SIGHASH_NOINPUT` to `SIGHASH_NOINPUT_UNSAFE`
    url: /en/newsletters/2018/07/17/#naming-of-sighash-noinput
    date: 2018-07-17

  - title: "Discussion of the evolution of script: `SIGHASH_NOINPUT_UNSAFE`"
    url: /en/newsletters/2018/10/09/#discussion-the-evolution-of-bitcoin-script
    date: 2018-10-09

  - title: Proposal included additional data in sighashes
    url: /en/newsletters/2018/11/27/#sighash-updates
    date: 2018-11-27

  - title: "`SIGHASH_NOINPUT_UNSAFE` edge cases"
    url: /en/newsletters/2019/01/08/#continued-sighash-discussion
    date: 2019-01-08

  - title: Tagging outputs to increase safety of `SIGHASH_NOINPUT_UNSAFE`
    url: /en/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
    date: 2019-02-19

  - title: Discussion about increasing `SIGHASH_NOINPUT_UNSAFE` safety
    url: /en/newsletters/2019/03/19/#more-discussion-about-sighash-noinput-unsafe
    date: 2019-03-19

  - title: New proposed `SIGHASH_ANYPREVOUT` mode
    url: /en/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes
    date: 2019-05-21

  - title: Criticism of `SIGHASH_ANYPREVOUT` and a generic alternative
    url: /en/newsletters/2019/05/29/#not-generic-enough
    date: 2019-05-29

  - title: Continued discussion of noinput/anyprevout
    url: /en/newsletters/2019/10/09/#continued-discussion-about-noinput-anyprevout
    date: 2019-10-09

  - title: "2018 year-in-review: `SIGHASH_NOINPUT`"
    url: /en/newsletters/2018/12/28#sighash_noinput
    date: 2018-12-28

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Eltoo
    link: topic eltoo
---
