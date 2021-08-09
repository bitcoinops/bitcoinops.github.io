---
title: 'Bitcoin Optech Newsletter #161'
permalink: /en/newsletters/2021/08/11/
name: 2021-08-11-newsletter
slug: 2021-08-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter follows up on a previous description about
fidelity bonds in JoinMarket and includes our regular sections with the
summary of a Bitcoin Core PR Review Club meeting, suggestions for
preparing for taproot, announcements of releases and release candidates,
and descriptions of notable changes to popular infrastructure projects.

## News

- **Implementation of fidelity bonds:** the [JoinMarket 0.9.0][]
  implementation of [coinjoin][topic coinjoin] includes [support][jm notes]
  for [fidelity bonds][fidelity bonds doc].  As previously described in
  [Newsletter #57][news57 fidelity bonds], the bonds improve the sybil resistance of the
  JoinMarket system, increasing the ability for coinjoin initiators
  ("takers") to choose unique liquidity providers ("makers").  Within
  days of release, [over 50 BTC][waxwing toot] (currently valued at over
  $2 million USD) had been placed in timelocked fidelity bonds.

    Although the specific implementation is unique to JoinMarket, the
    overall design may be useful in other decentralized protocols built
    on top of Bitcoin.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[FIXME]<!-- -->[review club #12345] is a PR by FIXME which FIXME.

{% include functions/details-list.md

  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/22363#l-17FIXME"
%}

## Preparing for taproot #8: multisignature nonces

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/07-nonces.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.10.1][] is a release
  that contains a number of new features, several bug fixes,
  and a few updates to developing protocols (including [dual
  funding][topic dual funding] and [offers][topic offers]).

FIXME:bitcoincore

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #21528][] aims to improve the p2p propagation of full
  node listening addresses.  Exposure to a diverse set of addresses is important
  for nodes to be protected against network partitions such as [eclipse attacks][topic eclipse attacks].
  When Bitcoin Core nodes receive an address message containing 10 or fewer
  addresses, they forward it to 1 or 2 peers. This is the primary technique
  used to self-advertise addresses, so sending to peers that would not relay
  these addresses would effectively stop or "black hole" the propagation through
  the network. Although propagation failures cannot be prevented in the malicious case, this
  patch improves address propagation for the honest cases, such as for block-relay-only
  connections or light clients.

  This update identifies whether or not an inbound connection is a
  candidate for forwarding addresses based on whether it has sent an address
  related message over the connection, such as `addr`, `addrv2`, or `getaddr`. This behavior
  change could be problematic if there is software on the network that
  relies on receiving address messages but never initiates an address-related
  message. Therefore, the author took care to circulate this proposed change
  before it was merged, including posting it to the
  [mailing list][addrRelay improvements] and researching
  [other open source clients][addr client research] to confirm compatibility.

- [LND #5484][] etcd: enable full remote database support FIXME:dongcarl

- [Rust-Lightning #1004][] adds a new event for `PaymentForwarded` that
  allows tracking when a payment has been successfully forwarded.  Since
  successful forwarding may earn fees for the node, this allows tracking
  that income for the user's accounting records.

- [BTCPay Server #2730][] Implement topup invoices FIXME:Xekyo

{% include references.md %}
{% include linkers/issues.md issues="21528,5484,1004,2730" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1
[joinmarket 0.9.0]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.0
[jm notes]: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/release-notes/release-notes-0.9.0.md#fidelity-bond-for-improving-sybil-attack-resistance
[fidelity bonds doc]: https://gist.github.com/chris-belcher/18ea0e6acdb885a2bfbdee43dcd6b5af/
[waxwing toot]: https://x0f.org/@waxwing/106696673020308743
[news57 fidelity bonds]: /en/newsletters/2019/07/31/#fidelity-bonds-for-improved-sybil-resistance
[addrRelay improvements]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018784.html
[addr client research]: https://github.com/bitcoin/bitcoin/pull/21528#issuecomment-809906430
