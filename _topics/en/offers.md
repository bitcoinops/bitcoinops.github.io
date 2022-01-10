---
title: Offers

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Offers** is a proposed protocol enhancement for Lightning that would
  allow nodes to request and receive invoices over LN.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BOLT12 (draft)
      link: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: New proposed BOLT for offers protocol
    url: /en/newsletters/2019/11/13/#proposed-bolt-for-ln-offers

  - title: New direct messages protocol to be used for offers
    url: /en/newsletters/2020/02/26/#ln-direct-messages

  - title: "C-Lightning #4255 is the first of a series of PRs for offers"
    url: /en/newsletters/2020/12/16/#c-lightning-4255

  - title: "2020 year in review: LN offers"
    url: /en/newsletters/2020/12/23/#ln-offers

  - title: "C-Lightning 0.9.3 released with experimental offers support"
    url: /en/newsletters/2021/01/27/#c-lightning-0-9-3

  - title: Offers specification updated to partly address stuck payments
    url: /en/newsletters/2021/04/21/#using-ln-offers-to-partly-address-stuck-payments

  - title: "Offers specification updated to no longer require a signature"
    url: /en/newsletters/2021/07/14/#c-lightning-4625

  - title: C-Lightning 0.10.1 updates the experimental implementation of offers
    url: /en/newsletters/2021/08/11/#c-lightning-0-10-1

  - title: Spark Lightning Wallet adds partial support for offers
    url: /en/newsletters/2021/08/18/#spark-lightning-wallet-adds-bolt12-support

  - title: "Summary of LN developer conference, including discussion of offers"
    url: /en/newsletters/2021/11/10/#ln-summit-2021-notes

  - title: "2021 year-in-review: offers"
    url: /en/newsletters/2021/12/22/#offers

  - title: "Eclair #2117 adds onion message replies in preparation for supporting offers"
    url: /en/newsletters/2022/01/12/#eclair-2117

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
An example of a common use of this protocol would be that a merchant
generates a QR code, the customer scans the QR code, the customer’s LN
node sends some of the details from the QR code (such as an order ID
number) to the merchant’s node over LN, the merchant’s node returns an
invoice (also over LN), the invoice is displayed to the user (who
agrees to pay), and the payment is sent.

Although the above use case is already addressed today using
[BOLT11][] invoices, the ability for the spending and receiving nodes
to communicate directly before attempting payment provides much more
flexibility. For example, the requested amount could be specified in
the terms of a non-Bitcoin currency (e.g. USD); if the BTC-to-USD
exchange rate changed too much since the invoice was received, the two
nodes could automatically negotiate an update to the payable BTC
amount to make it again consistent with the requested USD amount.

Interactive communication between the nodes also enables features that
aren’t possible with BOLT11’s one-time-use hashlocks, such as
recurring payments for subscriptions and donations.

{% include references.md %}
