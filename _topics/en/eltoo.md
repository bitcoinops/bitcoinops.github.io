---
title: Eltoo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network
  - Contract Protocols

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Eltoo** is a proposed enforcement layer for LN that allows any later
  channel state to replace any earlier channel state.  Although eltoo
  can be used with a penalty mechanism similar to the one used with
  existing LN channels, eltoo doesn't need the penalty mechanism in
  order to be secure.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  If eltoo is used without a penalty mechanism, there's no harm in
  publishing an old state, except that it costs transaction fees to
  publish.  This makes it less dangerous to try to restore an LN node
  from a backup after a sudden failure or some other problem.  It also
  makes it much simpler for three or more parties to open a single LN
  channel together, enabling features such as [channel factories][topic
  channel factories].

  Another consequence of LN channels without penalties is that LN nodes
  using eltoo only need to store the latest state.  For certain devices
  that lack large amounts of persistent storage (for example, hardware
  wallets), they may not be able to store enough data to effectively use
  penalty-based LN---but as long as they can store a few kB, they should
  be able to use eltoo-based LN.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Eltoo

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "2018 year-in-review: Eltoo"
    url: /en/newsletters/2018/12/28#april

  - title: Optimization for Eltoo-based payment channels
    url: /en/newsletters/2019/01/08/#continued-sighash-discussion

  - title: SIGHASH_ANYPREVOUT proposal compatible with Eltoo
    url: /en/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes

  - title: Eltoo demo implementation
    url: /en/newsletters/2019/09/11/#eltoo-sample-implementation-and-discussion

  - title: "Modification to `SIGHASH_ANYPREVOUTANYSCRIPT` to improve eltoo flexibility"
    url: /en/newsletters/2020/01/29/#layered-commitments-with-eltoo

  - title: Implementing statechains without eltoo
    url: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo

  - title: "Impact of SIGHASH_NOINPUT and eltoo on LN backups"
    url: /en/newsletters/2020/06/03/#ln-backups

  - title: Upgrading LN commitment formats, including for eltoo
    url: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats

  - title: Using attacks like transaction pinning and selective relay against eltoo
    url: /en/newsletters/2020/08/12/#discussion-about-eltoo-and-sighash-anyprevout

## Optional.  Same format as "primary_sources" above
see_also:
  - title: SIGHASH_NOINPUT
    link: topic sighash_noinput
---
