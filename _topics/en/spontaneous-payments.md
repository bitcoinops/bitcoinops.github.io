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

  - title: Using ECDH for uncoordinated LN payments
    url: /en/newsletters/2019/06/19/#using-ecdh-for-uncoordinated-ln-payments

  - title: Eclair 0.3.3 adds experimental support for trampoline payments
    url: /en/newsletters/2020/02/05/#upgrade-to-eclair-0-3-3

  - title: "C-Lightning #3611 adds a keysend plugin to support spontaneous payments"
    url: /en/newsletters/2020/04/22/#c-lightning-3611

  - title: "C-Lightning 0.8.2 released with a plugin for sending spontaneous payments"
    url: /en/newsletters/2020/05/06/#c-lightning-0-8-2

  - title: Juggernaut uses spontaneous payments for messaging and instant payments"
    url: /en/newsletters/2020/05/20/#lightning-based-messenger-application-juggernaut-launches

  - title: Breez wallet adds support for spontaneous payments
    url: /en/newsletters/2020/05/20/#breez-wallet-enables-spontaneous-payments

  - title: "LND #4167 allows spontaneous payments made using keysend to be held"
    url: /en/newsletters/2020/07/08/#lnd-4167

  - title: Zap 0.7.0 Beta adds support for spontaneous payments
    url: /en/newsletters/2020/07/22/#zap-0-7-0-beta-released

  - title: "C-Lightning #3792 adds support for sending keysend spontaneous payments"
    url: /en/newsletters/2020/07/22/#c-lightning-3792

  - title: "Eclair #1485 adds support for keysend spontaneous payments"
    url: /en/newsletters/2020/07/29/#eclair-1485

  - title: Eclair 0.4.2 adds support for keysend-style spontaneous payments
    url: /en/newsletters/2020/10/14/#eclair-0-4-2

  - title: "C-Lightning #4404 allows keysending to nodes that don't advertise support"
    url: /en/newsletters/2021/03/17/#c-lightning-4404

  - title: "LND #5108 adds support for spontaneous multipath payments using AMP"
    url: /en/newsletters/2021/04/14/#lnd-5108

  - title: "Rust-Lightning #967 adds support for sending keysend-style spontaneous payments"
    url: /en/newsletters/2021/08/04/#rust-lightning-967

  - title: "LND #5803 allows multiple spontaneous payments to the same invoice"
    url: /en/newsletters/2021/11/03/#lnd-5803

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
The invoice used for regular LN payments contains a hash that the
payer and each routing node uses as part of the
Hash-Time-Locked-Contract.  Spontaneous payments need to replicate
this security mechanism but without the invoice mechanism for
communication.  At least two different mechanisms have been proposed
for accomplishing this:

- *Add data to the routing packet (keysend):* the person sending the payment
  chooses a hash pre-image, encrypts it to the receiver's key, and
  appends it as extra data in the routing packet.  When the payment
  arrives at the receiver, they can decrypt the data and use the
  pre-image to claim the payment.
{:#add-data-to-the-routing-packet}

- *Using a shared secret:* the person sending the payment combines
  their key and the receiver's key to create a shared secret.  Then
  the spender uses a hash of this secret as the pre-image.  The
  receiver can also generate a shared secret and can use it to accept
  the payment.

{% include references.md %}
