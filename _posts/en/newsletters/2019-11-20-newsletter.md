---
title: 'Bitcoin Optech Newsletter #73'
permalink: /en/newsletters/2019/11/20/
name: 2019-11-20-newsletter
slug: 2019-11-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a new minor version release of LND, notes downtime on the development mailing lists,
describes some recent updates to Bitcoin services and clients, and
summarizes recent changes to popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Upgrade to LND 0.8.1-beta:** this [release][lnd 0.8.1-beta] fixes
  several minor bugs and adds compatibility for the upcoming Bitcoin Core 0.19 release.

## News

- **Mailing list downtime:** the Bitcoin-Dev and Lightning-Dev mailing
  lists both experienced [downtime][bishop migration] last week due to an unannounced
  server migration.  Both lists are functional again as of this writing.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17437][] updates the `gettransaction`,
  `listtransactions`, and `listsinceblock` RPCs to include the height
  of the block containing each returned transaction.

- [C-Lightning #3223][] updates the `listpeers` RPC to display the
  address that will be paid if the channel is closed.

- [C-Lightning #3186][] adds a new utility named `hsmtool` that will be
  built alongside C-Lightning's other binaries.  The tool can encrypt or
  decrypt your C-Lightning wallet as well as print private information
  about your commitment transactions.

- [Eclair #1209][] adds support for creating and decrypting the draft
  [trampoline payment][topic trampoline payments] onion format.
  This is in preparation for later PRs that will add support for
  actually routing trampoline payments.

- [Eclair #1153][] adds experimental support for [multipath
  payments][topic multipath payments] that allow a payment to be split
  into two or more parts that can be sent over different routes,
  allowing a user with multiple open channels to spend funds from each
  of those channels.  It's expected that this code may need to be
  tweaked as other LN software also finish their own multipath payment
  implementations and as real-world data is acquired on the performance
  of the splitting and routing algorithms.

{% include linkers/issues.md issues="16442,3649,17437,3223,3186,1209,1153,17449" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[lnd 0.8.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.1-beta
[bishop migration]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002335.html
