---
title: Splicing

## Optional.  An entry will be added to the topics index for each alias
#aliases:

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network
  - Liquidity Management

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Splicing** is the act of transferring funds from onchain outputs
  into a payment channel, or from a payment channel to independent
  onchain outputs, without the channel participants having to wait for a
  confirmation delay to spend the channel's other funds.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Splicing specification (draft)"
      link: https://github.com/lightning/bolts/pull/863

    - title: Splice proposal (Rusty Russell)
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html

    - title: Splice proposal (Rene Pickhardt)
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001437.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Proposals for LN splicing
    url: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing

  - title: LN 1.1 protocol goals
    url: /en/newsletters/2018/11/20/#splicing

  - title: "2018 year-in-review: splicing"
    url: /en/newsletters/2018/12/28/#splicing

  - title: Draft specification for LN splicing based on interactive funding protocol
    url: /en/newsletters/2021/04/28/#draft-specification-for-ln-splicing

  - title: "Discussion about the best way to gossip channel splices"
    url: /en/newsletters/2022/07/06/#announcing-splices

  - title: "BOLTs #1004 makes recommendations to support future detection of splices"
    url: /en/newsletters/2022/08/24/#bolts-1004

  - title: "Eclair #2540 makes backend preparations for splicing"
    url: /en/newsletters/2023/02/01/#eclair-2540

  - title: "Eclair #2595 continues the project's work on adding support for splicing"
    url: /en/newsletters/2023/02/22/#eclair-2595

  - title: "Splicing specification discussion about relative amounts and minimizing redundant data"
    url: /en/newsletters/2023/04/12/#splicing-specification-discussions

  - title: "Eclair #2584 adds support for both splice-in and splice-out"
    url: /en/newsletters/2023/04/19/#eclair-2584

  - title: "Phoenix wallet adds splicing support"
    url: /en/newsletters/2023/07/19/#phoenix-wallet-adds-splicing-support

  - title: "Eclair #2680 adds quiescence negotiation for splicing"
    url: /en/newsletters/2023/08/02/#eclair-2680

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Interactive transaction construction protocol
    link: topic dual funding

  - title: Submarine swaps
    link: topic submarine swaps
---
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

Splicing is different from [submarine swaps][topic submarine swaps] (such as those
implemented by [Lightning Loop][]) where funds are transferred
between users in exchange for onchain transactions---in submarine
swaps, the overall balance of the channel stays the same; in
splicing, the overall balance of the channel changes.

{% include references.md %}
[Lightning loop]: https://blog.lightning.engineering/posts/2019/03/20/loop.html
