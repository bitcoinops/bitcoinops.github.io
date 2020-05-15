---
title: Unannounced channels

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Private channels

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Unannounced channels** are LN channels that are not advertised to
  the network for use in routing.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Most unannounced channels are believed to belong to users that simply
  don't intend to route payments, such as users of mobile clients that
  aren't always online to route payments.

  An alternative name is **private channels,** but there's contention
  between experts about whether the channels [improve privacy][privacy
  in pcns] or [not][unpublished channels delenda est], so it may be
  preferable to use the universally accepted name "unannounced
  channels."

  [privacy in pcns]: https://arxiv.org/pdf/1909.02717.pdf "Section 4.1: endpoint uncertainty"
  [unpublished channels delenda est]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002408.html

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LND #1944 tweaks `sendtoroute` RPC to allow routing via private channels"
    url: /en/newsletters/2018/11/13/#lnd-1944
    date: 2018-11-13

  - title: "C-Lightning #2230 adds a `private` flag to the `listpeers` RPC"
    url: /en/newsletters/2019/01/15/#c-lightning-2230
    date: 2019-01-15

  - title: "C-Lightning #2234 adds route hints for private channels to `invoice` RPC"
    url: /en/newsletters/2019/01/22/#c-lightning-2234
    date: 2019-01-22

  - title: "Talk about LN topology and lack of public info about unannounced channels"
    url: /en/newsletters/2019/09/18/#lightning-network-topology
    date: 2019-09-18

  - title: "C-Lightning #3351 enhances `invoice` RPC for private channels"
    url: /en/newsletters/2020/01/08/#c-lightning-3351
    date: 2020-01-08

  - title: "Eclair #1283 allows multipath payments to traverse unannounced channels"
    url: /en/newsletters/2020/01/22/#eclair-1283
    date: 2020-01-22

  - title: "Breaking the link between UTXOs and unannounced channels"
    url: /en/newsletters/2020/01/29/#breaking-the-link-between-utxos-and-unannounced-channels
    date: 2020-01-29

  - title: "C-Lightning #3600 adds blinded paths to improve unannounced channel privacy"
    url: /en/newsletters/2020/04/08/#c-lightning-3600
    date: 2020-04-08

  - title: "C-Lighting #3623 improves unannounced channel privacy when routing payments"
    url: /en/newsletters/2020/04/22/#c-lightning-3623
    date: 2020-04-22

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
