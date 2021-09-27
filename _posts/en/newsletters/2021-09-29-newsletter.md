---
title: 'Bitcoin Optech Newsletter #168'
permalink: /en/newsletters/2021/09/29/
name: 2021-09-29-newsletter
slug: 2021-09-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal to implement breaking
changes in the DLC specification, examines options for allowing recovery
of closed LN channels using just a BIP32 seed, and describes an idea to
generate stateless LN invoices.  Also included are our regular sections
with popular questions and answers from the Bitcoin Stack Exchange,
ideas for preparing for taproot's activation, and descriptions of
notable changes to popular Bitcoin infrastructure software.

## News

- **Discussion about DLC specification breaking changes:** Nadav Kohen
  [posted][kohen post] to the DLC-dev mailing list about updating the
  [DLC][topic dlc] specification with several changes that could break
  compatibility with existing applications.  He presented two options:
  updating the specification as needed and letting applications
  advertise what version they implement, or batching together several
  breaking changes in order to minimize the number of disruptions.
  Feedback was requested from developers working on DLC software.

<!-- confirmed on IRC that "ghost43" (all lowercase) is how they'd like to be attributed -->

- **Challenges recovering LN close transactions using only a seed:**
  Electrum Wallet developer ghost43 [posted][ghost43 post] to the
  Lightning-Dev mailing list about some of the challenges of scanning
  the block chain for a wallet's channel close transactions.  A specific
  problem is dealing with the new [anchor outputs][topic anchor outputs]
  protocol when recovering a wallet using only [BIP32][]-style [HD key
  generation][topic bip32].  Several possible schemes were analyzed by
  ghost43 and a scheme currently used by Eclair is recommended as the
  best currently possible.  A further improvement is suggested if
  implementations are willing to slightly modify the channel opening
  protocol.

- **Stateless LN invoice generation:** Joost Jager [posted][jager post]
  to the Lightning-Dev mailing list about a possible denial of service
  attack against applications generating LN invoices for unauthenticated
  users.  Specifically, an attacker could request an unbounded number of
  invoices, which the generating service would need to store until they
  expired.  Jager suggested instead that, for small invoices not
  requiring much data, the service could generate the invoice and
  immediately forget about it, instead giving the requesting user the
  invoice parameters.  Those parameters would be submitted with the
  payment, allowing the service to reconstruct the invoice, accept the
  payment, and fulfill the order.

    Although some respondents [expressed concern][osuntokun reply] that
    the idea was unnecessary---it's possible to flood apps with requests
    in other ways, and any solution to those problems should also fix
    invoice request flooding---others thought the idea was useful.  The
    idea does not seem to require any protocol changes, just software
    changes (or plugins) to create and manage the invoice generation and
    reconstruction.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Preparing for taproot #15: signmessage protocol still needed

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/14-signmessage.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.2][bitcoin core 0.21.2] is a release
  for a maintenance version of Bitcoin Core.  It contains several bug
  fixes and small improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #12677][] adds `ancestorcount`, `ancestorsize` and
  `ancestorfees` fields to the transaction outputs returned by the wallet's
  `listunspent` RPC method. If the transaction creating the transaction output is
  unconfirmed, those fields will indicate the total count, size and fees
  of the transaction and all its unconfirmed ancestors in the mempool.
  Miners select transactions for inclusion in a block based on their ancestor
  feerate, so knowing the ancestor size and fees are useful for users estimating
  the confirmation time for the transaction or attempting to bump the transaction's
  fee using [CPFP][topic cpfp] or [RBF][topic rbf].

- [Eclair #1942][] Add success probabilities in path finding FIXME:dongcarl

- [LND #5101][] adds a *middleware interceptor* which receives each RPC
  request on its way to the server and can make modifications.  This
  allows implementing logic outside of LND that can track or affect a
  large variety of user and automated actions.  For security, only RPCs
  that explicitly use authentication tokens (macaroons) that opt-in to
  interception can be intercepted.

{% include references.md %}
{% include linkers/issues.md issues="12677,1942,5101,2842" %}
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[kohen post]: https://mailmanlists.org/pipermail/dlc-dev/2021-September/000075.html
[ghost43 post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003229.html
[jager post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003236.html
[osuntokun reply]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003252.html
