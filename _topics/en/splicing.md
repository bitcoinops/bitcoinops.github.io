---
title: Splicing

## Optional.  An entry will be added to the topics index for each alias
#aliases:

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Splicing** is the act of transferring funds from onchain outputs
  into a payment channel, or from a payment channel to independent
  onchain outputs, without the channel participants having to wait for a
  confirmation delay to spend the channel's other funds.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Splicing comes in two varieties:

  - **Splice in** means adding funds to a channel.  In this case, a
    cooperative close of the channel is arranged between the involved
    parties that spends the old channel funds to a new channel along
    with the new deposit.  Because the new channel open is based on the
    security of the old channel close, the channel participants can
    safely spend the old funds within the channel while waiting for the
    close and open transactions to confirm.

  - **Splice out** means removing funds from a channel to an
    independent onchain output.  Similar to splice-in, the channel is
    closed and a new channel is opened, with the remaining funds being
    secured by the old channel's security until the new channel has
    fully confirmed.

   Splicing is different from *submarine swaps* (such as those
   implemented by [Lightning Loop][]) where funds are transferred
   between users in exchange for onchain transactions---in submarine
   swaps, the overall balance of the channel stays the same; in
   splicing, the overall balance of the channel changes.

   [Lightning loop]: https://blog.lightning.engineering/posts/2019/03/20/loop.html

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Splice proposal (Rusty Russell)
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html

    - title: Splice proposal (Rene Prickhardt)
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001437.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Proposals for LN splicing
    url: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
    date: 2018-10-16

  - title: LN 1.1 protocol goals
    url: /en/newsletters/2018/11/20/#splicing
    date: 2018-11-20

  - title: "2018 year-in-review: splicing"
    url: /en/newsletters/2018/12/28/#splicing
    date: 2018-12-28

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
