---
title: 'Bitcoin Optech Newsletter #233'
permalink: /en/newsletters/2023/01/11/
name: 2023-01-11-newsletter
slug: 2023-01-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a idea for allowing offline LN nodes to
receive funds onchain that they'll later be able to use offchain without
extra delay.  Also included are our regular sections with summaries of
new software releases and release candidates, plus descriptions of
notable changes to popular Bitcoin infrastructure software.

## News

- **Non-interactive LN channel open commitments:** developers ZmnSCPxj
  and Jesse Posner [posted][zp potentiam] to the Lightning-Dev mailing
  list a proposal for a new technique for opening LN channels, which
  they call *swap-in-potentiam*.  The existing methods for opening an LN
  channel require that each participant sign a refund transaction before
  any funds are deposited in the channel.  To create a refund, details
  about the funding need to be known, so existing LN channel opening
  techniques require interaction: the funder needs to tell their
  counterparty about the funding they plan to provide; the counterparty
  needs to create and sign a refund transaction; then the funder needs
  to sign and broadcast a funding transaction.

    The authors note that this is problematic for some wallets,
    particularly wallets on mobile devices that may not be online or
    able to act all the time.  For those wallets, it would be reasonable
    to generate a fallback onchain address to which they can receive
    funds if their LN node can't be reached.  When the wallet next comes
    online, they can use the onchain funds to open an LN channel.
    However, new LN channels need to be confirmed to a reasonable depth
    (e.g. 6 confirmations) before the non-funder can securely and
    trustlessly forward payments for the funder.  That means a mobile
    wallet user who receives a payment while their node is offline might
    need to wait six blocks after they come online before they can use
    that money to send a new payment over LN.

    The authors suggest an alternative: user Alice chooses a
    counterparty (Bob) in advance whose node she expects will always be
    available (e.g. a Lightning Service Provider, LSP).  Alice and Bob
    cooperate to create an onchain address for a script which allows
    spending with a signature from Alice plus either a signature from
    Bob or the expiration of a multi-week timelock (e.g. 6,000 blocks),
    for [example][potentiam minsc]:

    ```hack
    pk(A) && (pk(B) || older(6000))
    ```

    This address can receive a payment that begins to accrue
    confirmations while Alice is offline.  Until the payment has the
    expiry number of confirmations, Bob must co-sign any attempt to
    spend the money.  If Bob chooses to only sign a single spend attempt
    that Alice also signs, then Bob can be sure that Alice can't double
    spend that money before the expiry.  The only way Alice's spend
    could become invalid is by the earlier payment to her also becoming
    double spent.  If that payment has accrued many confirmations before
    Alice came online and initiated her spend, a double spend should be
    improbable.

    This allows Alice to receive a payment while her wallet is offline,
    come online after the payment has at least 6 confirmations (but
    considerably less than 6,000 confirmations), and immediately co-sign
    a transaction to open an LN channel that Bob knows can't be double
    spent.  Even before that channel creation transaction is confirmed,
    Bob can begin securely and trustlessly forwarding payments for
    Alice.  Or, if Alice and Bob both already have LN channels (either
    with each other or with separate peers), Bob can send an LN payment
    to Alice which she can claim by spending her onchain funds to Bob.
    Alternatively, if Alice's wallet comes online and she decides she
    just wants to make a regular onchain payment, all she needs is for
    Bob's wallet to co-sign the spend.  In the worst case, if Bob becomes
    uncooperative, Alice can simply wait a few weeks to spend her money
    without his participation.

    In addition to allowing offline wallets to receive funds for LN, the
    authors describe how the idea might combine well with [async
    payments][topic async payments] to allow LSPs to prepare channel
    rebalance operations in advance for when an offline client comes
    back online, allowing those rebalance operations to occur without
    any delay from the user's perspective.  For example, if Carol sends
    an async LN payment to Alice for an amount larger than the current
    capacity in Alice's channel, Bob can send a payment to the script
    `pk(B) && (pk(A) || older(6000))`.  This alternative script flips the
    roles for Alice and Bob.  If Bob's payment receives a sufficient
    number of confirmations by the time Alice next comes online,
    Alice can immediately upgrade that payment to a new LN channel and
    then have Bob forward the async payment over that new channel,
    maintaining LN's usual secure and trustless properties.

    The idea received a moderate amount of discussion on the mailing
    list as of this writing, with several comments seeking clarification
    about aspects of the idea and at least one [comment][fournier
    potentiam] strongly supportive of the general concept.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.26.0][] is a new release of this library for building wallets.

- [HWI 2.2.0-rc1][] is a release candidate of this application for
  allowing software wallets to interface with hardware signing devices.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #2455][] implements support for the optional Type-Length-Value (TLV) stream in
  onion failure messages [recently introduced][bolts #1021] to BOLT 04.
  The TLV stream allows nodes to report additional details about routing
  failures and may be used for the proposed [fat errors][news224 fat]
  scheme to further close the gap in error attribution.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2455,1021" %}
[bdk 0.26.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0
[hwi 2.2.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0-rc.1
[zp potentiam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003810.html
[potentiam minsc]: https://min.sc/#c=pk%28A%29%20%26%26%20%28pk%28B%29%20%7C%7C%20older%286000%29%29
[fournier potentiam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003813.html
[news224 fat]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
