---
title: 'Bitcoin Optech Newsletter #220'
permalink: /en/newsletters/2022/10/05/
name: 2022-10-05-newsletter
slug: 2022-10-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for new opt-in transaction relay
rules and summarizes research into helping LN channels stay balanced.
Also included are our regular sections listing new software releases and
release candidates plus notable changes to popular Bitcoin infrastructure
projects.

## News

- **Proposed new transaction relay policies designed for LN-penalty:**
  Gloria Zhao [posted][zhao tx3] to the Bitcoin-Dev mailing list a proposal to
  allow transactions to opt-in to a modified set of transaction relay
  policies.  Any transaction which sets its version parameter to `3`
  will:

    - Be replaceable while it is unconfirmed by a transaction paying a
      higher feerate and a higher total fee (the current main
      [RBF][topic rbf] rules)

    - Require all of its descendents also be v3 transactions for as long
      as it remains unconfirmed.  Descendents violating this rule will
      not be relayed or mined by default

    - Be rejected if any of its v3 unconfirmed ancestors already have
      any other descendants in the mempool (or in a [package][topic
      package relay] containing this transaction)

    - Be required to be 1,000 vbytes or smaller if any of its v3
      ancestors are unconfirmed

    Accompanying the proposed relay rules was a simplification of the
    previously-proposed package relay rules (see [Newsletter
    #167][news167 packages]).

    Together, the v3 relay and updated package relay rules are designed
    to allow LN commitment transactions to include only minimal fees (or
    potentially even zero fees) and have their actual fees paid by a
    child transaction, all while preventing [pinning][topic transaction pinning].  Almost all LN
    nodes already use a mechanism like this, [anchor outputs][topic anchor outputs], but the
    proposed upgrade should make confirming commitment
    transactions simpler and more robust.

    Greg Sanders [replied][sanders tx3] with two suggestions:

    - *Ephemeral dust:* any transactions paying a zero-value (or
      otherwise *uneconomical*) output should be exempt from the
      [dust policy][topic uneconomical outputs] if that transaction is part of a package which
      spends the dust output.

    - *Standard OP_TRUE:* that outputs paying an output consisting
      entirely of `OP_TRUE` should be relayed by default.  Such an
      output can be spent by anyone---it has no security.  That makes it
      easy for either party to an LN channel (or even third parties) to
      fee-bump a transaction spending that `OP_TRUE` output.  No data
      needs to be put on the stack to spend an `OP_TRUE` output, making
      it cost-efficient to spend.

    Neither of these needs to be done at the same time as implementing
    relay of v3 transactions, but several respondents to the thread
    seemed to be in favor of all the proposed changes. {% assign timestamp="1:30" %}

- **LN flow control:** Rene Pickhardt [posted][pickhardt ml valve] to the Lightning-Dev
  mailing list a summary of [recent research][pickhardt bitmex valve] he performed on using
  the `htlc_maximum_msat` parameter as a flow control valve.  As
  [previously defined][bolt7 htlc_max] in BOLT7, `htlc_maximum_msat` is
  the maximum value that a node will forward to the next hop in a
  particular channel for an individual payment part ([HTLC][topic htlc]).
  Pickhardt addresses the problem of a channel with more value
  flowing through it in one direction than the other direction---eventually
  leaving the channel without enough funds to transfer in the overused
  direction.  He suggests that channel can be kept in balance by
  limiting the maximum value in the overused direction.  For example, if
  a channel starts by allowing 1,000 sat forwards in either direction
  but becomes unbalanced, then try lowering the overused direction's
  maximum amount per forwarded payment to 800.  Pickhardt's
  research provides several code snippets that can be used to calculate
  actual appropriate `htlc_maximum_msat` values.

    In a [separate email][pickhardt ratecards], Pickhardt also suggests that the previous
    idea of *fee ratecards* (see [last week's newsletter][news219 ratecards]) could
    instead become *maximum amount per-forward ratecards*, where a
    spender would be charged a lower feerate to send small payments and
    a higher feerate to send larger payments.  Unlike the original
    ratecards proposal, they would be absolute amounts and not relative
    to the channel's current balance.  Anthony Towns [described][towns ratecards]
    several challenges with the original ratecards idea that wouldn't be
    problems for flow control based on adjusting `htlc_maximum_msat`.

    ZmnSCPxj [criticized][zmnscpxj valve] several aspects of the idea, including
    noting that spenders could still send the same amount of value
    through a lower-max rate channel, resulting in it again becoming
    unbalanced, just by splitting an overall payment into additional
    small parts.  Towns suggested this could potentially be addressed by
    rate limiting.

    The discussion appeared to be ongoing at the time this summary was
    being written, but we expect that several new insights will come in
    the following weeks and months as node operators begin experimenting
    with their channels `htlc_maximum_msat` parameters. {% assign timestamp="22:06" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 24.0 RC1][] is the first release candidate for the
  next version of the network's most widely used full node
  implementation.  A [guide to testing][bcc testing] is available. {% assign timestamp="44:38" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #2435][] adds optional support for a basic form of *async
  payments* when [trampoline relay][topic trampoline payments] is used.  As described in
  [Newsletter #171][news171 async], async payments would allow paying an
  offline node (such as a mobile wallet) without trusting a third-party
  with the funds.  The ideal mechanism for async payments depends on
  [PTLCs][topic ptlc], but a partial implementation just requires a third party to
  delay forwarding the funds until the offline node comes back online.
  Trampoline nodes can provide that delay and so this PR makes use of
  them to allow experimentation with async payments. {% assign timestamp="51:28" %}

- [BOLTs #962][] removes support for the original fixed-length onion
  data format from the specification.  The upgraded variable-length
  format was added to the specification over three years ago and test
  results mentioned in the commit message indicate almost no one is
  using the older format any more. {% assign timestamp="54:38" %}

- [BIPs #1370][] revises [BIP330][] ([Erlay][topic erlay] for reconciliation-based
  transaction announcements) to reflect the current proposed
  implementation. Changes include:

  - Removing truncated transaction IDs in favor of just using
    transaction wtxids.  This also means nodes can use the existing
    `inv` and `getdata` messages, so the `invtx` and `gettx` messages
    have been removed.

  - Renaming `sendrecon` to `sendtxrcncl`,
  `reqreconcil` to `reqrecon`, and `reqbisec` to `reqsketchtext`.

  - Adding details for negotiating support using `sendtxrcncl`. {% assign timestamp="55:29" %}

- [BIPs #1367][] simplifies [BIP118][]'s description of
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] by referring to BIPs [340][bip340] and
  [341][bip341] as much as possible. {% assign timestamp="1:03:04" %}

- [BIPs #1349][] adds [BIP351][] titled “Private Payments”,
  describing a cryptographic protocol inspired by
  [BIP47][bip47] and [Silent Payments][topic silent payments]. The BIP
  introduces a new Payment Code format per which participants specify
  supported output types next to their public key.  Similar to BIP47, a
  sender uses a notification transaction to establish a shared secret
  with the receiver based on the receiver's Payment Code. The sender can
  then send multiple payments to unique addresses derived from the
  shared secret which the receiver may spend using information from the
  notification transaction. Where BIP47 had multiple senders reuse the
  same notification address per receiver, this proposal uses OP_RETURN
  outputs labeled with the search key `PP` and a
  notification code specific to the sender-receiver pair to get the receiver's attention and establish the
  shared secret for improved privacy. {% assign timestamp="1:08:54" %}

- [BIPs #1293][] adds [BIP372][] titled "Pay-to-contract tweak fields for PSBT". This BIP
  proposes a standard for including additional [PSBT][topic psbt] fields
  that provide signing devices with contract commitment data required to participate in
  [Pay-to-Contract][topic p2c] protocols (see [Newsletter #184][news184 psbt]). {% assign timestamp="1:12:26" %}

- [BIPs #1364][] adds additional detail to the text for the
  [BIP300][] specification of [drivechains][topic sidechains].  The
  related specification of [BIP301][] for enforcing drivechain's blind
  merge mining rules is also updated. {% assign timestamp="1:14:47" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="2435,962,1370,1367,1349,1293,1364" %}
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bolt7 htlc_max]: https://github.com/lightning/bolts/blob/48fed66e26b80031d898c6492434fa9926237d64/07-routing-gossip.md#requirements-3
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[zhao tx3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020937.html
[news167 packages]: /en/newsletters/2021/09/22/#package-mempool-acceptance-and-package-rbf
[sanders tx3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020938.html
[pickhardt ml valve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003686.html
[pickhardt bitmex valve]: https://blog.bitmex.com/the-power-of-htlc_maximum_msat-as-a-control-valve-for-better-flow-control-improved-reliability-and-lower-expected-payment-failure-rates-on-the-lightning-network/
[pickhardt ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003696.html
[news219 ratecards]: /en/newsletters/2022/09/28/#ln-fee-ratecards
[towns ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003695.html
[zmnscpxj valve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003703.html
[news171 async]: /en/newsletters/2021/10/20/#paying-offline-ln-nodes
[news184 psbt]: /en/newsletters/2022/01/26/#psbt-extension-for-p2c-fields
