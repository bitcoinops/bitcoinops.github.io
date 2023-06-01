---
title: 'Bitcoin Optech Newsletter #122'
permalink: /en/newsletters/2020/11/04/
name: 2020-11-04-newsletter
slug: 2020-11-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about bi-directional
upfront fees for LN and relays the results of a small survey among
experts about their preferences for taproot activation.  Also included
are our regular sections with updates about various projects.

## Action items

*None this week.*

## News

- **Bi-directional upfront fees for LN:** continuing a previous
  Lightning-Dev mailing list thread about upfront fees (see [Newsletter
  #120][news120 upfront]), [[Bastien Teinturier]] [posted][teinturier bidir]
  a proposal to have both the party offering an [HTLC][topic htlc] and
  the party receiving it each pay fees to the other---although the
  receiving party receives a refund on their fees if the payment is
  settled within a specified amount of time.  For example:

    {:.center}
    ![Alice routes a payment through Bob to Carol with bi-directional upfront fees](/img/posts/2020-11-bi-directional-upfront.png)

    The forward fee (e.g., Alice→Bob) discourages spam; it must be paid
    even if the receiver refuses to relay the payment.  The backward fee
    (e.g., Bob→Alice) encourages prompt settlement by having a refund
    deadline.  Any ultimate receiver who wants to use [hold
    invoices][topic hold invoices] for longer than the remaining time
    will now need to pay the backwards fee.  Any intermediate hop who
    doubts the payment will succeed before the deadline will now reject
    the payment, allowing previous hops to also settle the failed
    payment before the deadline and receive their refund.

    In discussion of the idea, it did not appear that any fatal issue
    was discovered, although it was unclear how much enthusiasm it
    generated.

- **Taproot activation survey results:** Anthony Towns received survey
  responses from an unnamed set of 13 "smart dev-type people" about
  their preferences for a soft fork activation mechanism to use with
  taproot.  The [post][towns survey] includes his own personal summary
  of the results, which we quote in abbreviated form below:

    > - Activation threshold should stay at 95% [...]
    >
    > - [...] hope for a quick response [from miners] within a few
    >   months, but plan for it taking up to a year, even if everything
    >   goes well
    >
    > - Setting the [earliest possible activation time] to be about a
    >   month or two [after the Bitcoin Core release containing the
    >   activation code] is probably about right [...]
    >
    > - Almost everyone is open to the idea of a flag day in some
    >   circumstances
    >
    > - If there’s a flag day, we should expect it to be a year or two
    >   away [...]
    >
    > - There probably isn’t support for setting a flag day initially
    >   [...]
    >
    > - Almost everyone wants to see as many nodes as possible enforce
    >   the rules after activation
    >
    > - Most people seem to be willing to accept bringing a flag day
    >   forward by mandatory signalling
    >
    > - There’s not a lot of support for opting-in to flag day
    >   activation by setting a configuration option

    After Bitcoin Core developers finish working on the upcoming 0.21
    release, it's likely that the results of this survey will help them
    choose the activation parameters that will be used for taproot in a
    subsequent release.  Of course, actual enforcement of the soft fork
    will depend on it gaining broad support among users---and users may
    decide to use an alternative activation mechanism.  Further
    discussion of activation parameters is encouraged in the
    [##taproot-activation][] IRC chatroom ([logs][##taproot-activation
    logs]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #4162][] updates logging to include whether a payment used
  a [payment secret][]. Payment secrets were added to BOLT 11 in [BOLTs #643][]
  as part of the [multipath payments][topic multipath payments] feature to prevent probing attacks by nodes
  along the payment path. Payment secrets are supported by all LN
  implementations and will eventually be made compulsory by C-Lightning; logging
  which payments are using payment secrets makes it easier for the developers to
  know when it's reasonable to make that change.

{% include references.md %}
{% include linkers/issues.md issues="643,4162" %}
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[##taproot-activation logs]: http://gnusha.org/taproot-activation/
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[teinturier bidir]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002862.html
[towns survey]: http://www.erisian.com.au/wordpress/2020/10/26/activating-soft-forks-in-bitcoin
[payment secret]: https://github.com/lightningnetwork/lightning-rfc/commit/5776d2a7
