---
title: 'Bitcoin Optech Newsletter #245'
permalink: /en/newsletters/2023/04/05/
name: 2023-04-05-newsletter
slug: 2023-04-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an idea for watchtower accountability
proofs and includes our regular sections with announcements of new
releases and release candidates and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Watchtower accountability proofs:** Sergi Delgado Segura
  [posted][segura watchtowers post] to the Lightning-Dev mailing list
  last week about holding [watchtowers][topic watchtowers] accountable
  for failing to respond to protocol breaches they were capable of
  detecting.  For example, Alice provides a watchtower with data for
  detecting and responding to the confirmation of an old LN channel
  state; later, that state is confirmed but the watchtower fails to
  respond.  Alice would like to be able to hold the watchtower operator
  accountable by publicly proving it failed to respond appropriately.

    The basic principle would be for a watchtower to have a well-known
    public key and to use the corresponding private key to generate a
    signature for any breach-detection data it accepted.  Alice could
    then publish the data and the signature after an unresolved breach
    to prove the watchtower failed its responsibility.  However, Delgado
    noted that practical accountability isn't that simple:

    - *Data storage requirements:* the above mechanism would require
      Alice to store an additional signature every time she sent the
      watchtower new breach-detection data, which could be quite
      often for an active LN channel.

    - *No deletion capability:* the above mechanism potentially requires
      the watchtower to store the breach-detection data in perpetuity.
      Watchtowers may only want to store data for a limited time, e.g.
      they may accept payment for a particular term.

    Delgado suggests cryptographic accumulators provide a practical
    solution to both problems.  Accumulators allow compactly proving a
    particular element is a member of a large set of elements and also
    allow adding new elements to the set without rebuilding the entire
    data structure.  Some accumulators allow deleting elements from the
    set without rebuilding.  In a
    [gist][segura watchtowers gist], Delgado outlines several different
    accumulator constructions worth considering. {% assign timestamp="0:36" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.16.0-beta][] is beta release of a new major version of this popular LN
  implementation.  Its [release notes][lnd rn] mention numerous new
  features, bug fixes, and performance improvements. {% assign timestamp="21:37" %}

- [BDK 1.0.0-alpha.0][] is a test release of the major changes to BDK
  described in [Newsletter #243][news243 bdk].  Developers of
  downstream projects are encouraged to begin integration testing. {% assign timestamp="22:06" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #5967][] adds a `listclosedchannels` RPC that provides data
  about the node's closed channels, including the cause of channel being closed.
  Information about old peers is also retained now. {% assign timestamp="22:59" %}

- [Eclair #2566][] adds support for accepting offers.  Offers must be
  registered by a plugin that provides a handler for responding to
  invoice requests related to the offer and either accepting or
  rejecting payments to that invoice.  Eclair ensures requests and
  payments satisfy the protocol requirements---the handler only needs to
  decide whether the item or service being purchased can be provided.
  This allows code for marshaling offers to become arbitrarily complex
  without affecting Eclair's internal logic. {% assign timestamp="23:43" %}

- [LDK #2062][] implements [BOLTs #1031][] (see [Newsletter
  #226][news226 bolts1031]), [#1032][bolts #1032] (see [Newsletter
  #225][news225 bolts1032]), and [#1040][bolts #1040], allowing the
  ultimate receiver of a payment ([HTLC][topic htlc]) to accept a
  greater amount than they requested and with a longer time before it
  expires than they requested.  This makes it more difficult for a
  forwarding node to use a slight tweak in the payment's parameters to
  determine that the next hop is the receiver.  The merged PR also allows a
  spender to pay a receiver slightly more than the requested amount when
  using [simplified multipath payments][topic multipath payments]. This
  provides the above benefit and may also be required in the case where
  the chosen payment paths use channels with a minimum routable amount.
  For example, Alice wants to split a 900 sat total into two parts, but
  both of the paths she chooses require 500 sat minimum amounts. With
  this specification change, she can now send two 500 sat payments,
  choosing to overpay by a total of 100 sats in order to use her
  preferred route. {% assign timestamp="24:57" %}

- [LDK #2125][] adds helper functions to determine the amount of
  time until an invoice expires. {% assign timestamp="27:18" %}

- [BTCPay Server #4826][] allows service hooks to create and retrieve [LNURL][]
  invoices.  This was done to add support for NIP-57 zaps to BTCPay Server’s
  lightning address features. {% assign timestamp="27:56" %}

- [BTCPay Server #4782][] adds [proof of payment][topic proof of
  payment] on the receipt page for each payment.  For onchain payments,
  the proof is the transaction ID.  For LN payments, the proof is the
  preimage to the [HTLC][topic htlc]. {% assign timestamp="29:51" %}

- [BTCPay Server #4799][] adds the ability to export [wallet
  labels][topic wallet labels] for transactions in the format specified
  by [BIP329][].  Future PRs may add support for exporting other wallet
  data, such as labels for addresses. {% assign timestamp="30:15" %}

- [BOLTs #765][] adds [route blinding][topic rv routing] to the LN
  specification.  Route blinding, which we first described in
  [Newsletter #85][news85 blinding], allows a node to receive a payment
  or [onion message][topic onion messages] without revealing its node
  identifier to the spender or sender.  No other directly identifiable
  information needs to be revealed.  Route blinding works by having the
  receiver choose the last several hops over which the payment or
  message will be forwarded.  These steps are onion encrypted like
  regular forwarding information and are provided to the spender or
  sender who uses them to send a payment to the first of the hops.  That
  hop begins the process of decrypting the next hop, forwarding the
  payment to it, having that hop decrypt the subsequent hop, etc,
  until the receiver accepts the payment without their node being
  disclosed to the spender or sender. {% assign timestamp="31:37" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="5967,2566,2062,1031,1032,1040,2125,4826,4782,4799,765" %}
[lnd v0.16.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[segura watchtowers post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003892.html
[segura watchtowers gist]: https://gist.github.com/sr-gi/f91f007fc8d871ea96ead9b27feec3d5
[news85 blinding]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news226 bolts1031]: /en/newsletters/2022/11/16/#bolts-1031
[news225 bolts1032]: /en/newsletters/2022/11/09/#bolts-1032
[news243 bdk]: /en/newsletters/2023/03/22/#bdk-793
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.16.0.md
[lnurl]: https://github.com/lnurl/luds
