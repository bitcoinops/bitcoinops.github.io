---
title: Multipath payments

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - AMP

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Multipath payments** are LN payments split into two or more parts
  and sent using a different path for each part.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Smaller payments are more likely to succeed in general, and allowing a
  payment to be split allows the spender to use almost all of their funds at
  once no matter how many channels those funds are split across.  There
  are two basic multipath proposals:

  - *Atomic Multipath Payments (AMP)*, sometimes called *Original AMP*
    or *OG AMP*, which allows a spender to pay multiple hashes all
    derived from the same preimage---a preimage the receiver can only
    reconstruct if they receive a sufficient number of shares.  This
    only allows the receiver to accept a payment if they receive all of the
    individual parts.  Each share using a different hash adds privacy by
    preventing the separate payments from being automatically correlated
    with each other by a third party.  The proposal's downside is that
    the spender selects all the preimages, so knowledge of the preimage
    doesn't provide cryptographic proof that they actually paid the
    receiver.

  - *Base-AMP* which simply sends multiple payments all using to the
    same hash and assumes the receiver will wait until the full amount
    is received before claiming the payment (releasing the hash preimage
    and allowing generation of a provable receipt).  It's also possible
    for third-parties who see multiple payments using the same hash to
    assume they're part of the same true payment.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Atomic Multipath Payments
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html

    - title: Base AMP
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001577.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LN protocol 1.1 goals: multipath payments"
    url: /en/newsletters/2018/11/20/#multi-path-payments
    date: 2018-11-20

  - title: "LND #3390 separates tracking of HTLCs from invoices as necessary for AMP"
    url: /en/newsletters/2019/09/11/#lnd-3390
    date: 2019-09-15

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
