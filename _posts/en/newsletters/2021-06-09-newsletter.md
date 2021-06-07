---
title: 'Bitcoin Optech Newsletter #152'
permalink: /en/newsletters/2021/06/09/
name: 2021-06-09-newsletter
slug: 2021-06-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow LN nodes to receive
payments without keeping their private keys online all the time.  Also
included are our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, announcements of new software releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Receiving LN payments with a mostly offline private key:** in 2019,
  developer ZmnSCPxj [proposed][zmn ff] an alternative way to
  encapsulate pending LN payments ([HTLCs][topic htlc]) that would
  reduce the amount of network bandwidth and latency required to accept
  a payment.  More recently, Lloyd Fournier suggested the idea could
  also be used to allow a node to accept multiple incoming LN payments
  without keeping its private keys online.  The idea does have some
  downsides:

  - The node would still need its private keys to send a penalty
    transaction if necessary.

  - The more payments the node received without using its private key,
    the more onchain fees would need to be paid if the channel was
    unilaterally closed.

  - The receiving node would lose privacy---its immediate peer would be
    able to determine that it was the ultimate receiver of a payment and
    not just a routing hop.  However, for some end-user nodes that don't
    route payments, this may already be obvious.

  Within those limitations, the idea seems workable and variations of it
  received [discussion][zmn revive] on the mailing list this week, with
  ZmnSCPxj preparing a clear [presentation][zmn preso].  Fournier later
  [suggested][fournier asym] improvements to the idea.

  Implementing the idea would require several significant LN protocol
  changes, so it seems unlikely to be something users will have access
  to in either the short or medium term.  However, anyone looking to
  minimize the need for LN receiving nodes to keep their keys online is
  encouraged to investigate the idea.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:jonatack

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/21061#FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta] is a release candidate that
  adds support for using a pruned Bitcoin full node, allows receiving
  and sending payments using Atomic MultiPath ([AMP][topic multipath payments]),
  and increases its [PSBT][topic psbt] capabilities, among other improvements
  and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22051][] Basic Taproot derivation support for descriptors FIXME:jnewbery

- [Bitcoin Core #22050][] drops support for version 2 Tor onion services
  (hidden services).  Version 2 services are already deprecated and the
  Tor project has announced that they'll become inaccessible in
  September.  Bitcoin Core already supports version 3 onion services
  (see [Newsletter #132][news132 v3onion]).

- [Bitcoin Core #22095][] adds a test to check how Bitcoin Core derives
  [BIP32][] private keys.  Although Bitcoin Core has always derived
  these keys correctly, it was recently [discovered][btcd issue] that some other
  wallets were incorrectly deriving slightly more than 1 out of 128 keys
  by failing to pad extended private keys (xprivs) that were
  less than 32 bytes long.  This doesn't directly result in a loss of
  funds or a reduction in security, but it does create problems for
  users who create an HD wallet seed in one wallet and import it into
  another wallet or who create multisignature wallets.  The test vector
  implemented in this PR is also being [added][bips #1030] to BIP32 to
  help future wallet authors avoid this issue.

- [C-Lightning #4532][] adds experimental support for [upgrading a
  channel][bolts #868]---rebuilding the latest commitment transaction so
  that it can incorporate new features or structural changes, e.g.
  converting to using [taproot][topic taproot].  The protocol starts
  with a request for [quiescence][bolts #869], an agreement that neither
  party will send any new state updates until the quiescence period is
  completed.  During this period, the nodes negotiate the changes they
  want to make and implement them.  Finally, the channel is restored to
  full operation.  C-Lightning currently implements this during
  connection reestablishment when the channel has already been in a
  period of forced inactivity.  Various proposals for channel upgrades
  were discussed in [Newsletter #108][news108 channel upgrades] and the
  author of this PR wants the feature in part to work on the "simplified
  HTLC negotiation" described in [Newsletter #109][news109 simplified
  htlc].  This particular PR allows upgrading old channels to support
  `option_static_remotekey`, which C-Lightning first added support for
  in 2019, see [Newsletter #64][news64 static remotekey].

- [LND #5336][] lnrpc: allow AMP pay-addr override + bump invoice timeouts FIXME:dongcarl

- [BTCPay Server #2474][] adds the ability to test webhooks by sending
  fake events that contain all their normal fields but dummy data.  This
  mirrors testing features available on centrally hosted Bitcoin payment
  processors such as Stripe and Coinbase Commerce.

{% include references.md %}
{% include linkers/issues.md issues="22051,22050,22095,4532,869,5336,2474,1030,868" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[news64 static remotekey]: /en/newsletters/2019/09/18/#c-lightning-3010
[news108 channel upgrades]: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news109 simplified htlc]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[zmn ff]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[zmn revive]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003038.html
[zmn preso]: https://zmnscpxj.github.io/offchain/2021-06-fast-forwards.odp
[fournier asym]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003045.html
[btcd issue]: https://github.com/btcsuite/btcutil/issues/172
[news132 v3onion]: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0
