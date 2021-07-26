---
title: 'Bitcoin Optech Newsletter #159'
permalink: /en/newsletters/2021/07/28/
name: 2021-07-28-newsletter
slug: 2021-07-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with the best
questions and answers of the past month from the Bitcoin Stack Exchange,
our latest column about preparing for taproot, a list of new software
releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

*No significant news this week.*

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Preparing for taproot #6: learn taproot by using it

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/05-taproot-notebooks.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Rust Bitcoin 0.27.0] (bech32m support) is a new release.  Most
  notably, it adds support for handling [bech32m][topic bech32]
  addresses.

- [C-Lightning 0.10.1rc1][C-Lightning 0.10.1] is a release candidate for
  an upgrade that contains a number of new features, several bug fixes,
  and a few updates to developing protocols (including [dual
  funding][topic dual funding] and [offers][topic offers]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22387][] limits the average number of announced
  addresses it'll process from each peer to one per 10 seconds.  Any
  addresses in excess of the limit will be ignored.  It's possible to
  whitelist peers to allow them to exceed this limit, and any address
  announcements the node explicitly requests from its peers are also
  excluded from the limit.  The limit is estimated to be about 40 times
  higher than the current rate at which a Bitcoin Core node announces
  addresses.

- [C-Lightning #4669][] Updates to offers FIXME:dongcarl

- [C-Lightning #4639][] adds experimental support for the liquidity
  advertisements proposed in [BOLTs #878][].  This allows a node to
  use the LN gossip protocol to advertise its willingness to lease out
  its funds for a period of time, giving other nodes the ability to buy
  incoming capacity that allows them to receive instant payments.
  A node that sees the advertisement can simultaneously pay for and
  receive the incoming capacity using a [dual funded][topic dual
  funding] channel open.  Although there's no way to enforce that the
  advertising node actually routes payments, the proposal does
  incorporate an earlier [proposal][zmn liquidity providers] also
  planned<!-- [1] --> to be used in [Lightning Pool][] that prevents the
  advertiser from using their money for other purposes until the agreed
  upon lease period has concluded, so refusing to route would only deny
  them the opportunity to earn routing fees.  The following table
  compares liquidity advertisements to the similar Lightning Pool
  marketplace described in [Newsletter #123][news123 lightning pool].

  <!-- [1]: See "Service-Level Based Lifetime Enforcement" in
  https://lightning.engineering/posts/2020-11-02-pool-deep-dive/ -->

   <table>
    <tr>
     <th></th>
     <th>Lightning Pool</th>
     <th>Liquidity advertisements</th>
    </tr>

    <tr>
     <th>Control over listings</th>
     <td>Centralized: allows curation to ensure high-quality listings, but
         also allows censoring listings</td>
     <td>Decentralized: listings can’t be censored, but users need to do
         their own research before buying a lease</td>
    </tr>

    <tr>
     <th>Licensing</th>
     <td>Open source client, proprietary server, open protocol</td>
     <td>All open source</td>
    </tr>

    <tr>
     <th>Price information</th>
     <td>Actual prices paid are public information via public auction results</td>
     <td>Advertised prices are public information via public gossip network</td>
    </tr>

    <tr>
     <th markdown="span">Third-party purchased liquidity ("[sidecar channels][]")</th>
     <td>Yes, Alice can pay Bob to fund a channel to Carol</td>
     <td markdown="span">[Maybe.]({{bse}}107786)</td>
    </tr>

   </table>

- [BIPs #1072][] BIP48: HD Multisig derivation standard FIXME:Xekyo

- [BIPs #1139][] adds [BIP371][] with a specification of new fields for
  using [PBSTs][topic psbt] (both [version 0][BIP174] and [version
  2][BIP370]) with [taproot][topic taproot] transactions.  See
  [Newsletter #155][news155 tr psbts] for previous discussion.

{% include references.md %}
{% include linkers/issues.md issues="22387,4669,4639,878,1072,1139" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1rc1
[rust bitcoin 0.27.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.27.0
[sidecar channels]: https://lightning.engineering/posts/2021-05-26-sidecar-channels/
[news123 lightning pool]: /en/newsletters/2020/11/11/#incoming-channel-marketplace
[news155 tr psbts]: /en/newsletters/2021/06/30/#psbt-extensions-for-taproot
[zmn liquidity providers]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[lightning pool]: https://lightning.engineering/posts/2020-11-02-pool-deep-dive/
