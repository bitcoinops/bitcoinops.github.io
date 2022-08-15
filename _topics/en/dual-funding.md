---
title: Dual funding

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Interactive funding protocol

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Dual funding** is creating a payment channel for LN where both
  parties can contribute funds.  The underlying protocol, called
  the *version 2 channel establishment protocol*, may also be used for
  negotiated opening of single-funded channels, but its motivating
  purpose is providing support for dual funding.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Dual funding
      link: https://github.com/lightningnetwork/lightning-rfc/pull/851

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LN protocol specification 1.1 goals: dual funding"
    url: /en/newsletters/2018/11/20/#dual-funded-channels

  - title: "Interactive construction of funding transactions"
    url: /en/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions

  - title: Using PoDLE in LN for dual funding privacy protection
    url: /en/newsletters/2020/02/19/#using-podle-in-ln

  - title: "C-Lightning #3738 adds initial support for PSBTs, part of dual funding"
    url: /en/newsletters/2020/05/27/#c-lightning-3738

  - title: Sydney meetup discussion about LN, including dual funding
    url: /en/newsletters/2020/06/03/#sydney-meetup-discussion

  - title: "C-Lightning #3954 adds locktime support to PSBT RPCs for dual funding"
    url: /en/newsletters/2020/08/26/#c-lightning-3954

  - title: "C-Lightning #3973 adds the accepter side of dual-funded channels"
    url: /en/newsletters/2020/09/16/#c-lightning-3973

  - title: "2020 year-in-review: LN dual funding and interactive funding"
    url: /en/newsletters/2020/12/23/#dual-interactive-funding

  - title: "Preventing UTXO probing in dual funded channels; PoDLE tradeoffs"
    url: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing

  - title: "C-Lightning #4410 updates experimental implementation dual funding"
    url: /en/newsletters/2021/03/17/#c-lightning-4410

  - title: "C-Lightning 0.10.0 includes experimental support for dual funding"
    url: /en/newsletters/2021/04/07/#c-lightning-0-10-0

  - title: Dual funding's interactive construction used in splicing proposal
    url: /en/newsletters/2021/04/28/#draft-specification-for-ln-splicing

  - title: "C-Lightning #4489 adds plugin for configuring dual-funding behavior"
    url: /en/newsletters/2021/05/12/#c-lightning-4489

  - title: "C-Lightning #4639 adds experimental support for liquidity advertisments based on dual funding"
    url: /en/newsletters/2021/07/28/#c-lightning-4639

  - title: C-Lightning 0.10.1 updates the experimental implementation of dual funding
    url: /en/newsletters/2021/08/11/#c-lightning-0-10-1

  - title: "2021 year-in-review: dual-funded channels"
    url: /en/newsletters/2021/12/22/#dual-funding

  - title: "2021 year-in-review: liquidity advertisements"
    url: /en/newsletters/2021/12/22/#liq-ads

  - title: "Eclair #2273 implements the proposed interactive funding protocol"
    url: /en/newsletters/2022/08/17/#eclair-2273

## Optional.  Same format as "primary_sources" above
see_also:
  - title: PSBT (dependency of dual funding)
    link: topic psbt
---
[Early analysis][dryja single-funded] of LN determined that it would be
significantly easier to build software where the user requesting to
open the payment channel contributed all funds to that channel and
paid all of its onchain fees, called *single funded channels*.  This
prevented attackers from freely or cheaply opening new channels,
locking up their counterparty's funds, and then making those victims
pay onchain fees to get their money back.

For spenders, single funded channels work great.  As soon as a channel
finishes opening, the user can start spending their funds with all of
the speed, efficiency, and privacy benefits of LN.  But receivers who
open a new single funded channel can't use it to receive funds until
they've spent funds.  This creates problems for merchants who want to
accept payments over LN but who aren't yet in a position to pay an
equal amount of their costs over LN.

One solution to this problem is to allow channels to be dual funded,
immediately allowing spending in either direction once the channel
opens.  Dual funded channels don't need to start with the same amount
of funding on both sides, so a merchant who wants to be able to
receive a significant amount of bitcoins may only need to contribute a
small part of the total channel capacity.

The dual funded protocol may also be used to open new single-funded
channels.  This may have advantages when the participating parties
want to use the protocol's ability to communicate node preferences and
find mutually acceptable values for various channel parameters.

After dual funding is available, it may be used in combination with
new [proposed node announcements][advertising channel liquidity] that
could help buyers and sellers of inbound capacity find each other in a
decentralized fashion.

Dual funding does require each party reveal ownership of one of their
UTXOs to the other party.  Like other protocols where this is
required (such as [coinjoin][topic coinjoin] and [payjoin][topic
payjoin]), this can be abused by an attacker to learn information
about who owns which UTXO.  Several [approaches][podle1] to
[limiting][podle2] this [problem][podle-alt] have been discussed.

{% include references.md %}
[dryja single-funded]: https://docs.google.com/presentation/d/1G4xchDGcO37DJ2lPC_XYyZIUkJc2khnLrCaZXgvDN0U/edit?pref=2&pli=1#slide=id.g85f425098_0_2
[advertising channel liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[podle1]: /en/newsletters/2020/02/05/#podle
[podle2]: /en/newsletters/2020/02/19/#using-podle-in-ln
[podle-alt]: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing
