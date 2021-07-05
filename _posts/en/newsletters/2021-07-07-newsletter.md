---
title: 'Bitcoin Optech Newsletter #156'
permalink: /en/newsletters/2021/07/07/
name: 2021-07-07-newsletter
slug: 2021-07-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a set of BIPs for output script
descriptors, summarizes a proposal to create a set of standards
documents for LN protocol extensions and application interoperability,
and discusses standardizing support for pre-trusted zero-conf channel
opens.  Also included are our regular sections describing how to prepare
for taproot, releases and release
candidates, and notable changes to popular Bitcoin infrastructure
projects.

## News

- **BIPs for output script descriptors:** Andrew Chow [posted][chow
  descriptors post] to the Bitcoin-Dev mailing list a proposed set of
  BIPs to standardize [output script descriptors][topic descriptors].  A
  core BIP provides the general semantics and primary elements used by
  descriptors.  Six additional BIPs describe expansion functions such as
  `pkh()`, `wpkh()`, and `tr()` that use their arguments to fill in a
  script template.  The multiple BIPs allow developers to choose which
  descriptor features they want to implement, e.g. newer wallets may
  never implement the legacy `pkh()` descriptor.

    Descriptors were originally implemented for Bitcoin Core and have
    seen increased adoption over the past year by other projects.
    They're poised to see a significant increase in use as wallets begin
    to explore the flexibility enabled by [taproot][topic taproot] and
    the ability to simplify access to the flexible scripts through tools
    like [miniscript][topic miniscript].

{% comment %}<!-- Gentry uses a lowercase leading character (bLIPs).  I
asked in IRC why, but unless there's a *really* compelling reason, I'd
prefer to capitalize.  I won't die on this hill, but I'm willing to lose
a little blood to prevent terms like iPhone that are super annoying to use
at the beginning of a sentence. -harding -->{% endcomment %}

- **BLIPs:** Ryan Gentry [posted][gentry blips] to the Lightning-Dev
  mailing list a proposal for a collection of Bitcoin Lightning
  Improvement Proposals (BLIPs), documents that describe extensions and
  applications of LN that will benefit from interoperability standards.
  René Pickhardt linked to an almost [identical proposal][pickhardt
  lips] he made in 2018.

    In discussion, the idea seemed to have broad support, although
    [concerns][teinturier blips] were raised that it doesn't actually
    solve the barrier to getting those standards incorporated in the
    base BOLTs documents---that barrier being experienced developers
    lacking enough time to review the many community proposals.  If
    BLIPs are merged without significant review, that increases the
    chance that they'll contain bugs or that they'll fail to achieve
    broad support from multiple stakeholders, leading to fragmentation
    as different projects adopt competing standards.  Still,
    non-mainline protocols are already being created and most discussion
    participants seemed to believe providing a well-known archive where
    documentation about those protocols could be published would be
    primarily beneficial.

- **Zero-conf channel opens:** Rusty Russell started a
  [discussion][russell zeroconf] on the Lightning-Dev mailing list about
  standardizing the handling of zero-conf channels, also known under the
  name *turbo channels*.  These are new single-funded channels where the
  funder gives some or all of their initial funds to the acceptor.
  Those funds are not secure until the channel open transaction receives
  a sufficient number of confirmations, so there's no risk to the
  acceptor spending some of those funds back through the funder using
  the standard LN protocol.

    For example, Alice has several BTC in an account at Bob's custodial
    exchange.  Alice asks Bob to open a new channel paying her 1.0 BTC.
    Because Bob trusts himself not to double-spend the channel he just
    opened, he can allow Alice to send 0.1 BTC through his node to
    third-party Carol even before the channel open transaction has
    received a single confirmation.

    {:.center}
    ![Zero-conf channel illustration](/img/posts/2021-07-zeroconf-channels.png)

    Some LN implementations already support the idea in a
    non-standardized way and all discussion participants seemed to favor
    standardizing it.  The exact details to use were still being
    discussed at the time of writing.

## Preparing for taproot #3: taproot descriptors

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/02-descriptors.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.13.1-beta.rc1][LND 0.13.1-beta] is a maintenance release with
  minor improvements and bug fixes for features introduced in
  0.13.0-beta.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #19651][] allows the wallet key manager to update existing
  [descriptors][topic descriptors]. This allows wallet users to edit labels,
  extend descriptor ranges, reactivate inactive descriptors, and make other
  updates using the `importdescriptors` wallet RPC.

- [C-Lightning #4610][] adds an `--experimental-accept-extra-tlv-types`
  command-line option which allows users to specify a list of even-numbered TLV types
  that `lightningd` should pass through for plugins to handle. Previously,
  `lightningd` considered all unknown evenly-typed TLV messages to be invalid. This
  change allows for plugins to define and handle their own custom TLV types
  unknown to `lightningd`.

- [Eclair #1854][] adds support for decoding and logging of [warning
  messages][bolts #834] sent from peers like C-Lightning that have [recently
  implemented][news136 c-lightning 4364] warning message types.

- [BIPs #1137][] adds [BIP86][], which suggests a key derivation scheme for
  single key P2TR outputs. The BIP was [summarized in last week's
  newsletter][bip-taproot-bip44 desc].

- [BIPs #1134][] updates BIP155 to indicate that the `sendaddr2` P2P
  feature negotiation message should be sent any time a software program
  understands [version 2 addr messages][topic addr v2], including in
  cases where the program doesn't necessarily want to receive `addr`
  messages.

{% include references.md %}
{% include linkers/issues.md issues="19651,4610,1854,1137,1134,834" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta.rc1
[chow descriptors post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019151.html
[news34 descriptor checksums]: /en/newsletters/2019/02/19/#bitcoin-core-15368
[gentry blips]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003086.html
[pickhardt lips]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003088.html
[teinturier blips]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-July/003093.html
[russell zeroconf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003074.html
[news136 c-lightning 4364]: /en/newsletters/2021/02/17/#c-lightning-4364
[bip86]: https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki
[bip-taproot-bip44 desc]: /en/newsletters/2021/06/30/#key-derivation-path-for-single-sig-p2tr
