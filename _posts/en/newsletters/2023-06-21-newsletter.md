---
title: 'Bitcoin Optech Newsletter #256'
permalink: /en/newsletters/2023/06/21/
name: 2023-06-21-newsletter
slug: 2023-06-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about extending BOLT11
invoices to request two payments.  Also included is another entry in our
limited weekly series about mempool policy, plus our regular sections
describing updates to clients and services, new releases and release
candidates, and changes to popular Bitcoin infrastructure software.

## News

- **Proposal to extend BOLT11 invoices to request two payments:** Thomas
  Voegtlin [posted][v 2p] to the Lightning-Dev mailing list to suggest
  [BOLT11][] invoices be extended to optionally allow a receiver to
  request two separate payments from a spender, with each payment having
  a separate secret and amount.  Voegtlin explains how that could be
  useful in for both [submarine swaps][topic submarine swaps] and [JIT
  channels][topic jit channels]:

    - *Submarine swaps*, where paying an offchain LN invoice results in
      receiving funds onchain (submarine swaps can also work the other
      way, from onchain to offchain, but that is not being discussed
      here).  The onchain receiver chooses a secret and the offchain
      spender pays an [HTLC][topic htlc] to the hash of that secret,
      which is routed over LN to a submarine swap service provider.
      The service provider receives an offchain HTLC for that secret
      and creates an onchain transaction paying to that HTLC.  When the
      user is satisfied that the onchain transaction is secure, they
      disclose the secret to settle the onchain HTLC, allowing the
      service provider to settle the offchain HTLC (and any forwarded
      payments on LN that also depend on the same secret).

        However, if the receiver doesn't disclose their secret, then the
        service provider won't receive any compensation and will need to
        spend the onchain output they just created, incurring costs for
        no gain.  To prevent this abuse, existing submarine swap
        services require the spender to pay a fee using LN before
        the service will create an onchain transaction (the service may
        optionally refund part or all of this fee if the onchain HTLC is
        settled).  The upfront fee and the submarine swap are for
        different amounts and need to be settled at different times, so
        they need to use different secrets.  A current BOLT11 invoice
        can only contain one commitment to a secret and one amount, so
        any wallet making submarine swaps at present needs to either be
        programmed to handle the interaction with the server or needs
        both the spender and the receiver to complete a multi-step workflow.

    - *Just-in-Time (JIT) channels*, where a user with no channels (or
      none with liquidity) creates a virtual channel with a service
      provider; when the first payment to that virtual channel arrives,
      the service provider creates an onchain transaction that both
      funds the channel and contains that payment.  Like any LN HTLC,
      the offchain payment is made to a secret only the receiver (the
      user) knows.  If the user is convinced the JIT channel funding
      transaction is secure, they disclose the secret to claim the
      payment.

        However, again, if the user doesn't disclose their secret, then
        the service provider won't receive any compensation and will
        incur onchain costs for no gain.  Voegtlin believes existing JIT
        channel service providers avoid this problem by requiring the
        user to disclose their secret before the funding transaction is
        secure, which he says may create legal problems and prevents
        non-custodial wallets from offering a similar service.

    Voegtlin suggests that allowing a BOLT11 invoice to contain two
    separate commitments to secrets, each for a different amount, will
    allow using one secret and amount for an upfront fee to pay the
    onchain transaction costs and the other secret and amount for the
    actual submarine swap or JIT channel funding.  The proposal received
    several comments, a few of which we'll summarize:

    - *Dedicated logic required for submarine swaps:* Olaoluwa Osuntokun
      [notes][o 2p] that the receiver of a submarine swap needs to create a
      secret, distribute it, and then settle a payment to it onchain.  The cheapest
      way to settle it is by interacting with the swap service provider.
      If the spender and receiver are going to interact with the service
      provider anyway, as is often the case with some existing
      implementations where the spender and receiver are the same entity,
      they don't need to communicate extra information using an invoice.
      Voegtlin [replied][v 2p2] that a dedicated piece of software can handle
      the interaction, eliminating the need for additional logic in the
      offchain wallet that pays out the funds and the onchain wallet
      that receives the funds---but this is only possible if the LN
      wallet can pay two separate secrets and amounts in the same
      invoice.

    - *BOLT11 ossified:* Matt Corallo [replied][c 2p] that it hasn't yet
      been possible to get all LN implementations to update their BOLT11
      support to support invoices that don't contain an amount (for
      allowing [spontaneous payments][topic spontaneous payments]), so
      he doesn't think adding an additional field is a practical
      approach at this time.  Bastien Teinturier makes a [similar
      comment][t 2p], suggesting adding support to [offers][topic offers]
      instead.  Voegtlin [disagrees][v 2p3] and thinks adding support
      is practical.

    - *Splice-out alternative:* Corallo also inquires about why the
      protocol should be modified to support submarine swaps if [splice
      outs][topic splicing] become available.  It wasn't mentioned in
      the thread, but both submarine swaps and splice outs allow moving
      offchain funds into an onchain output---however splice outs can be
      more efficient onchain and aren't vulnerable to uncompensated fee
      problems.  Voegtlin answers that submarine swaps allow an LN user
      to increase their capacity for receiving new LN payments, which
      splicing does not.

    The discussion appeared to be ongoing at the time of writing.

## Waiting for confirmation #6: Policy as individual choice

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/06-choice.md %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair v0.9.0][] is a new release of this LN implementation that
  "contains a lot of preparatory work for important (and complex)
  lightning features: [dual-funding][topic dual funding],
  [splicing][topic splicing] and [BOLT12 offers][topic offers]."  The
  features are experimental for now.  The release also "makes plugins
  more powerful, introduces mitigations against various types of DoS, and
  improves performance in many areas of the codebase."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LDK #2294][] adds support for replying to [onion messages][topic
  onion messages] and brings LDK closer to full support for
  [offers][topic offers].

- [LDK #2156][] adds support for [keysend payments][topic spontaneous
  payments] that use [simplified multipath payments][topic multipath
  payments].  LDK previously supported both of those technologies, but
  only when they were used separately.  Multipath payments must use
  [payment secrets][topic payment secrets] but LDK previously rejected
  keysend payments with payment secrets, so descriptive errors, a
  configuration option, and a warning about downgrading are added to
  mitigate any potential problems.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2294,2156" %}
[policy series]: /en/blog/waiting-for-confirmation/
[v 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003977.html
[o 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003978.html
[v 2p2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003979.html
[c 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003980.html
[t 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003982.html
[v 2p3]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003981.html
[eclair v0.9.0]: https://github.com/ACINQ/eclair/releases/tag/v0.9.0
