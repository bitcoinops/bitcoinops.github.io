---
title: 'Bitcoin Optech Newsletter #76'
permalink: /en/newsletters/2019/12/11/
name: 2019-12-11-newsletter
slug: 2019-12-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a new maintenance release of LND,
summarizes a discussion about watchtowers for eltoo payment channels,
and describes several notable changes to popular Bitcoin infrastructure
projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Help test LND 0.8.2-beta RC2:** this [release candidate][lnd 0.8.2-beta] contains
  several bug fixes and minor UX improvements, most notably for the
  recovery of static channel backups.  (One of these improvements is
  [described][lnd-3698] later in this newsletter.)

## News

- **Watchtowers for eltoo payment channels:** [eltoo][topic eltoo] is a
  proposed alternative payment channel layer for LN that doesn't require
  participants be able to generate penalty transactions.
  [Watchtowers][topic watchtowers] are services that broadcast a
  pre-programmed transaction if they detect that one of their client's
  channels is being closed using an older state; this allows their
  clients to go offline without risking a loss of funds.

  Conner Fromknecht started a [thread][fromknecht eltoo tower] asking
  what data watchtowers would need to store for eltoo and how that
  would affect the scalability of watchtowers or the privacy of their
  clients.  One option would be for a watchtower to store only the
  latest update transaction.  This is highly scalabale because it only
  requires a constant amount of storage per channel, and it's secure
  because only the final settlement transaction can spend from the
  final update transaction.  The offline node can broadcast the
  settlement transaction whenever it next comes online, even if that
  is months or years later.

  An alternative mechanism discussed would be for the watchtower to also store the
  settlement transaction.  This could provide
  additional safety in case the node lost all data while it was
  offline by sending funds to the node's desired withdrawal address
  (such as an address in its cold wallet).  However, it would
  increase the storage requirements for watchtowers and, worse, the
  obvious way to implement it would significantly reduce user privacy
  by giving watchtowers enough data to learn details about previous
  payments made in the user's payment channels.  Some participants in
  the thread discussed ways to obtain the safety benefits while
  mitigating the privacy loss, although no clear conclusion was
  reached in the thread as of this writing.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #3260][] adds new `createonion` and `sendonion` RPC
  methods that allow external tools or C-Lightning plugins to create and
  send encrypted LN messages that the node itself doesn't necessarily
  understand.  Some use cases for this mechanism described in the PR
  include: cross-chain atomic swaps, rendez-vous routing (see [Newsletter
  #22][rendez-vous routing]), [trampoline payments][topic trampoline
  payments], and chat-over-LN similar to [WhatSat][].

- [C-Lightning #3295][] extends the `listinvoices` RPC with a new field
  containing the payment preimage for any invoices that have already
  been paid.  (The preimage isn't shown for unpaid invoices in order to
  prevent the user from accidentally sharing the preimage before a
  payment has been finalized, which could result in a loss of funds.)

- [C-Lightning #3155][] adds a `--statictor` (static tor) command line
  parameter that allows the user to always operate as the same Tor v3
  hidden service instead of as an ephemeral hidden service that changes
  its address on every restart.  The static address is derived from the
  node's public identifier (pubkey) so the user doesn't need to store
  any extra information, although the user can use the `--torblob`
  parameter to specify entropy from which the static address will be
  generated.

- [LND #3788][] adds support for "payment addresses" which are the same
  thing as the "payment secrets" described in [last week's
  newsletter][payment secrets].  This addition prevents privacy-reducing probing
  of receiver nodes that are expecting to receive additional parts of a
  [multipath payment][topic multipath payments].

- [LND #3767][] prevents LND from accepting malformed [BOLT11][] invoices
  that have a valid bech32 checksum.  As [previously reported][news72
  bech32 mutability], bech32 addresses ending with `p` don't allow
  decoders to detect the addition or removal of preceding `q` characters
  with the high reliability expected from bech32's choice of BCH code
  parameters.  This problem is compounded by BOLT11 invoices expecting
  the paying node to recover the pubkey of the receiver node from the
  signature appended to the end of the invoice---the location where this
  type of undetected bech32 mutation would occur.  According to code
  comments in this merged PR, "In rare cases (about 3%) [the mutated
  signature] is still seen as a valid signature, [so] public key
  recovery causes a different node than the originally intended one to
  be derived." The PR eliminates the problem by rejecting any invoices
  where the last field in the invoice doesn't match its expected length.

- [LND #3698][] prints a warning when the user attempts to restore a
  Static Channel Backup (SCB), ensuring they know all of their channels
  will be closed (incurring onchain fees).  Users of `lncli` need to
  acknowledge the prompt before continuing.

- [LND #3655][] adds support for [BOLT2][] upfront shutdown scripts
  where the withdrawal address for a node is specified before opening a
  channel and that address is locked in for the life of the channel.  If
  the node later requests its payments be sent to a different address,
  its counterparty should refuse that request.  This makes it more
  difficult for an attacker who compromises a node to withdraw funds to
  the attacker's onchain wallet (although the attacker may still
  attempt to steal funds in other ways).

{% include linkers/issues.md issues="3260,3295,3155,3788,3767,3698,3655" %}
[lnd 0.8.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.2-beta-rc2
[lnd-3698]: #lnd-3698
[fromknecht eltoo tower]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002349.html
[whatsat]: https://github.com/joostjager/whatsat
[rendez-vous routing]: /en/newsletters/2018/11/20/#hidden-destinations
[payment secrets]: /en/newsletters/2019/12/04/#c-lightning-3259
[news72 bech32 mutability]: /en/newsletters/2019/11/13/#taproot-review-discussion-and-related-information
