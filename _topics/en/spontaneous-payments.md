---
title: Spontaneous payments

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Spontaneous payments** is the ability of one LN node to pay another
  node without receiving an invoice first.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  The invoice used for regular LN payments contains a hash that the
  payer and each routing node uses as part of the
  Hash-Time-Locked-Contract.  Spontaneous payments need to replicate
  this security mechanism but without the invoice mechanism for
  communication.  At least two different mechanisms have been proposed
  for accomplishing this:

  - *Add data to the routing packet:* the person sending the payment
    chooses a hash pre-image, encrypts it to the receiver's key, and
    appends it as extra data in the routing packet.  When the payment
    arrives at the receiver, they can decrypt the data and use the
    pre-image to claim the payment.

  - *Using a shared secret:* the person sending the payment combines
    their key and the receiver's key to create a shared secret.  Then
    the spender uses a hash of this secret as the pre-image.  The
    receiver can also generate a shared secret and can use it to accept
    the payment.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: LND PR for spontaneous LN payments
    url: /en/newsletters/2019/01/22/#pr-opened-for-spontaneous-ln-payments
    date: 2019-01-22

  - title: Using ECDH for uncoordinated LN payments
    url: /en/newsletters/2019/06/19/#using-ecdh-for-uncoordinated-ln-payments
    date: 2019-06-19

  - title: Eclair 0.3.3 adds experimental support for trampoline payments
    url: /en/newsletters/2020/02/05/#upgrade-to-eclair-0-3-3
    date: 2020-02-05

  - title: "C-Lightning #3611 adds a keysend plugin to support spontaneous payments"
    url: /en/newsletters/2020/04/22/#c-lightning-3611
    date: 2020-04-22

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
