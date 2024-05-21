---
title: Channel jamming attacks

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Channel jamming attacks** are Denial of Service (DoS) attacks where
  an attacker can prevent a series of channels up to 20 hops away from
  being able to use part or all of their funds for a prolonged period of
  time.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: "Loop attack (original description)"
    link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html

  - title: LN spam prevention
    link: https://github.com/t-bast/lightning-docs/blob/master/spam-prevention.md

  - title: "Unjamming Lightning: A Systematic Approach"
    link: https://raw.githubusercontent.com/s-tikhomirov/ln-jamming-simulator/master/unjamming-lightning.pdf

  - title: "Circuit Breaker: software to protect nodes from being flooded with htlcs"
    link: https://github.com/lightningequipment/circuitbreaker

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Hashcash and refund-based upfront fees to mitigate jamming
    url: /en/newsletters/2019/11/13/#ln-up-front-payments

  - title: Reverse upfront fees to mitigate jamming
    url: /en/newsletters/2020/02/26/#reverse-up-front-payments

  - title: "Eclair #1539 implements a simple measure to reduce channel jamming attacks"
    url: /en/newsletters/2020/10/07/#eclair-1539

  - title: Incremental routing as an alternative to upfront fees
    url: /en/newsletters/2020/10/14/#incremental-routing

  - title: Trusted upfront fees to mitigate jamming attacks
    url: /en/newsletters/2020/10/14/#trusted-upfront-payment

  - title: More upfront fees discussion
    url: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion

  - title: Fidelity bonds to prevent channel jamming attacks
    url: /en/newsletters/2020/12/02/#fidelity-bonds-for-ln-routing

  - title: "2020 year-in-review: LN channel jamming attacks"
    url: /en/newsletters/2020/12/23/#jamming

  - title: Bi-directional upfront fees to mitigate jamming attacks
    url: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln

  - title: Renewed discussion about bidirectional upfront LN fees
    url: /en/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees

  - title: Making jamming attacks more expensive by lowering the cost of probing
    url: /en/newsletters/2021/10/20/#lowering-the-cost-of-probing-to-make-attacks-more-expensive

  - title: "Summary of LN developer conference, including discussion of channel jamming attacks"
    url: /en/newsletters/2021/11/10/#ln-summit-2021-notes

  - title: "2021 year-in-review: channel jamming"
    url: /en/newsletters/2021/12/22/#jamming

  - title: "Guide to channel jamming attacks and proposed solutions"
    url: /en/newsletters/2022/08/24/#overview-of-channel-jamming-attacks-and-mitigations

  - title: "Paper suggesting solutions to jamming attacks based on local reputation and upfront fees"
    url: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks

  - title: "Reputation credentials proposal to mitigate LN jamming attacks"
    url: /en/newsletters/2022/11/30/#reputation-credentials-proposal-to-mitigate-ln-jamming-attacks

  - title: "CircuitBreaker add-on software to partly mitigate jamming attacks without protocol changes"
    url: /en/newsletters/2022/12/14/#local-jamming-to-prevent-remote-jamming

  - title: "2022 year-in-review: channel jamming"
    url: /en/newsletters/2022/12/21/#jamming

  - title: "Summary of call about mitigating LN jamming"
    url: /en/newsletters/2023/02/08/#summary-of-call-about-mitigating-ln-jamming

  - title: "Feedback requested on LN good neighbor scoring for local reputation to mitigate jamming"
    url: /en/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring

  - title: "Testing HTLC endorsement for preventing channel jamming attacks"
    url: /en/newsletters/2023/05/17/#testing-htlc-endorsement

  - title: "Eclair #2701 now records HTLC receive and settlement times to help with channel jamming mitigation"
    url: /en/newsletters/2023/06/28/#eclair-2701

  - title: "LND #7710 allows retrieving extra data about an HTLC in support of jamming countermeasures"
    url: /en/newsletters/2023/06/28/#lnd-7710

  - title: "LN developer discussion about channel jamming attacks"
    url: /en/newsletters/2023/07/26/#channel-jamming-mitigation-proposals

  - title: "DoS protection design philosophy and example of forward commitment fees and reverse hold fees"
    url: /en/newsletters/2023/08/09/#denial-of-service-dos-protection-design-philosophy

## Optional.  Same format as "primary_sources" above
see_also:
  - title: HTLCs
    link: topic htlc

  - title: HTLC endorsement
    link: topic htlc endorsement

---
An LN node can route a payment to itself across a path of 20 or more
hops. This creates two possible avenues for channel jamming attacks:

- *Liquidity jamming attack* (originally called the [loop attack][russell
  loop] in 2015) is where an attacker with `x` amount of money (e.g. 1 BTC) sends
  it to themselves across 20 other channels but delays either settling
  or rejecting the payment, temporarily locking up a total of `20x`
  funds belonging to other users (e.g. 20 BTC). After several hours of locking other
  users' money, the attacker can cancel the payment and receive a
  complete refund on their fees, making the attack essentially free.

- *HTLC jamming attack* is where an attacker sends 483 small payments
  ([HTLCs][topic HTLC]) through the series of 20 channels, where 483
  is the maximum number of pending payments a channel may contain. In
  this case, an attacker with two channels, each with 483 slots, can
  jam over 10,000 honest HTLC slots—again without paying any fees.

![Illustration of LN liquidity and HTLC jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

A variety of possible solutions have been
discussed, including *forward upfront fees* paid from the spender to
each node along the path, [backwards upfront fees][news86 backwards
upfront] paid from each payment hop to the previous hop, a
[combination][news122 bidir fees] of both forward and backwards fees,
[nested incremental routing][news119 nested routing], and [fidelity
bonds][news126 routing fibonds].  As of April 2021, no solution has
gained widespread support and developers continue to discuss the issue.

{% include references.md %}
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[russell loop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html
[news86 backwards upfront]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[news122 bidir fees]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news119 nested routing]: /en/newsletters/2020/10/14/#incremental-routing
[news126 routing fibonds]: /en/newsletters/2020/12/02/#fidelity-bonds-for-ln-routing
