---
title: 'Bitcoin Optech Newsletter #176'
permalink: /en/newsletters/2021/11/24/
name: 2021-11-24-newsletter
slug: 2021-11-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a discussion about how to allow LN users
to choose between higher fees and higher payment reliability.  Also
included are our regular sections with popular questions and answers from
the Bitcoin Stack Exchange, announcements of new releases and release
candidates, and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **LN reliability versus fee parameterization:** Joost Jager started a
  [thread][jager params] on the Lightning-Dev mailing list about how to
  best allow users to choose between paying more fees for faster
  payments or waiting longer to save money.  One of the challenges
  discussed in the thread is how to relate user preferences that exist
  on a single continuum to the discrete and multi-factor routes being
  returned by a pathfinding algorithm.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why is it important that nonces when signing not be related?]({{bse}}110811)
  Pieter Wuille provides mathematical breakdowns for how private key information
  can be leaked when signing twice with the same public key using: the same nonces,
  nonces with known offsets, and nonces with known factors. Wuille also lists
  three techniques for infeasible-to-exploit nonce generation, two techniques that
  are broken, and points out there is a huge gap of techniques in between that
  are neither known to be secure nor broken.

- [How could a 2 byte witness program make sense?]({{bse}}110660)
  Discussing [BIP141][]'s requirement that a witness program be 2-40 bytes,
  Kalle Rosenbaum brainstorms examples of potential use cases for a 2 byte
  witness program size.

- [What is the xpriv/xpub type for P2TR?]({{bse}}110733)
  Andrew Chow notes that as more diverse and complicated scripts become more
  widely used and for separation of concern reasons, there is no taproot
  equivalent for xpub/ypub/zpub. He recommends to "use xpriv/xpub along with
  some extra information indicating that the script to create is Taproot, (e.g.
  with a `tr()` descriptor)".

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.14.0-beta][] is a release that includes additional [eclipse
  attack][topic eclipse attacks] protection (see [Newsletter
  #164][news164 ping]), remote database support ([Newsletter
  #157][news157 db]), faster pathfinding ([Newsletter #170][news170
  path]), improvements for users of Lightning Pool ([Newsletter
  #172][news172 pool]), and reusable [AMP][topic amp] invoices
  ([Newsletter #173][news173 amp]) in addition to many other features
  and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [C-Lightning #4890][] wallet/db_sqlite3.c: Support direct replication of SQLITE3 backends. FIXME:jnewbery

- [Rust-Lightning #1173][] adds a new `accept_inbound_channels`
  configuration that can be used to prevent the node from accepting new
  incoming channels.  It defaults to true.

- [Rust-Lightning #1166][] improves the default route scoring logic by
  penalizing channels where the payment HTLC amount would constitute more than
  1/8th of the channel's capacity. The penalty increases linearly as the payment
  amount reaches the channel capacity.

{% include references.md %}
{% include linkers/issues.md issues="4890,1173,1166" %}
[lnd 0.14.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta
[news164 ping]: /en/newsletters/2021/09/01/#lnd-5621
[news157 db]: /en/newsletters/2021/07/14/#lnd-5447
[news170 path]: /en/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /en/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /en/newsletters/2021/11/03/#lnd-5803
[jager params]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003342.html
