---
title: Inbound forwarding fees

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

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BLIPs #18: Inbound routing fees"
      link: https://github.com/lightning/blips/pull/18

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "LND #6703 and #6934 add support for inbound routing fees"
    url: /en/newsletters/2024/04/10/#lnd-6703

  - title: "LND #8627 defaults to rejecting channel settings that require above-zero inbound forwarding fees"
    url: /en/newsletters/2024/05/01/#lnd-8627

  - title: "LND #8886 updates the BuildRoute function to support inbound forwarding fees"
    url: /en/newsletters/2024/08/16/#lnd-8886

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Inbound forwarding fees** are fees charged by an LN node for
  accepting a payment for forwarding.  The original LN protocol only
  specifies charging forwarding fees when a node relays the payment to
  its next hop (i.e., outbound forwarding fees).  Inbound forwarding
  fees, which can be negative, give a node more options for encouraging
  payments to route through channels they consider to be more liquid.

---

In the original specification of the LN protocol, a node can advertise
the cost it will charge to forward a payment through a particular
outbound channel.  For example, Carol might advertise that she will only
forward payments to her channel peer Dan if the payments offer 0.1% of
their value to her.  If that lowers the average number of satoshis
(sats) per minute that Carol forwards to Dan below the average amount he
forwards to her, eventually all of the channel balance will end up on
Carol's side, preventing Dan from being able to forward more payments to
her, reducing both of their revenue potentials.  To prevent that, Carol
might lower her outbound forwarding fee to Dan to 0.05%.  Similarly, if
Carol's lower outbound forwarding fee to Dan results in her forwarding
more sats per minute to him than he forwards to her, all of the balance
might end up on his side of the channel, also preventing additional
forwarding and revenue earning; in that case, Carol can raise her
outbound fees.

However, outbound fees only apply to outbound channels.  Carol is
offering to charge the same fee regardless of what channel she
receives the payment over; for example, she charges the same rate
whether she receives the payment from either of her channel peers
Alice or Bob:

```
Alice -> Carol -> Dan
Bob -> Carol -> Dan
```

This makes sense since the base LN protocol doesn't pay Carol for
receiving a forwarding request from Alice or Bob.  Alice and Bob can
set outbound fees for their channels to Carol, and it's up to them to
set fees that help keep the channels liquid.  Similarly, Carol can
adjust her fees for outbound payments to Alice and Bob (e.g. `Dan ->
Carol -> Bob`) to help manage liquidity.

However, Carol may want more control over policies that affect her.
For example, if Alice's node is poorly managed, she might frequently
forward payments to Carol without many people later wanting to forward
payments from Carol to Alice.  That would eventually end with all the
funds in their channel ending up on Carol's side, preventing further
payments in that direction.  Before this PR, there was nothing Carol
could do about that, except close her channel with Alice before it
wasted too much of the time value of Carol's capital.

Inbound forwarding fees allow incentivizing or disincentivizing incoming
forwarded payments specific to each channel.  For example, Carol might
charge a high fee for payments arriving inbound from Alice's problematic
node but a lower fee for payments arriving inbound from Bob's highly
liquid node.  The initial uses of inbound fees are expected to always be
negative to make them backward compatible with older nodes that don't
understand inbound fees; for example, Carol might give a 10% fee
discount on payments forwarded by Bob and a 0% discount on payments
forwarded by Alice.

The fees are assessed simultaneously with the outbound fees.  For
example, when Alice offers a payment to Carol for forwarding to Dan,
Carol calculates the original `dan_outbound` fee, calculates the new
`alice_inbound` fee, and ensures the forwarded payment offers her at
least the sum of both.  Otherwise, she rejects the forwarded payment
([HTLC][topic htlc]).  Since the initial inbound fees are always
expected to be negative, Carol won't reject any payments that pay
sufficient outbound fees, but any node that's now aware of inbound fees
may be able to receive a discount.

Inbound routing fees were first [proposed][bolts #835] in 2021,
[discussed][jager inbound] on the Lightning-Dev mailing list in 2022,
and documented in draft [BLIPs #18][] also in 2022.  Since its initial
proposal, maintainers of the LND implementation have expressed interest in
it, with several maintainers of other LN implementations opposing it.
Some have opposed it on [principle][teinturier bolts835]; others have
opposed its design as being [overly specific to LND][corallo overly
specific] rather than a local and generic upgrade that can immediately
use positive inbound forwarding fees and doesn't require global
advertisement of additional fee details for each channel.  An
alternative approach is proposed in draft [BLIPs #22][].  We're only
aware of one maintainer of a non-LND implementation [indicating][corallo
free money] that they'll adopt LND's method---and only in cases where
negative inbound forwarding fees are offered, as that's "free money for
our users."

{% include references.md %}
{% include linkers/issues.md issues="835,18,22" %}
[teinturier bolts835]: https://github.com/lightning/bolts/issues/835#issuecomment-764779287
[corallo free money]: https://github.com/lightning/blips/pull/18#issuecomment-1304319234
[corallo overly specific]: https://github.com/lightningnetwork/lnd/pull/6703#issuecomment-1374694283
[jager inbound]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-July/003643.html

