---
title: 'Bitcoin Optech Newsletter #53'
permalink: /en/newsletters/2019/07/03/
name: 2019-07-03-newsletter
type: newsletter
layout: newsletter
lang: en
slug: 2019-07-03-newsletter
---
This week's newsletter announces the newest release of C-Lightning,
briefly describes several proposals related to LN, and provides our
usual sections about bech32 sending support and notable changes to
popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*None this week.*

## Dashboard items

- **Mempool variability:** over the past week, the mempool
  [tracked][johoe stats] by various nodes has varied in size from almost
  100,000 transactions to fewer than 1,000 transactions.  Because most
  fee estimation algorithms lag behind changes in mempool state, high
  variability in mempool size may create more stuck transactions or
  overpaying transactions than normal.  High-frequency spenders such as
  exchanges may want to monitor mempool state themselves (e.g. using
  Bitcoin Core's `getmempoolinfo` RPC) in order to tweak their feerates
  for the current mempool conditions.

## News

- **LND 0.7.0-beta released:** this [new major version][lnd 0.7]
  is the first to contain a [watchtower implementation][watchtower docs] that allows third
  parties to help defend the in-channel funds of offline users.  Also
  included are bug fixes, improvements to the API for payment tracking,
  and faster initial syncs.  Upgrading is recommended.

- **C-Lightning 0.7.1 released:** this [new version][cl 0.7.1] contains new plugins and
  RPCs as well as numerous improvements to its handling of the channel
  gossip protocol that reduce the use of memory and bandwidth.
  Upgrading is recommended.

- **Stuckless payments:** Hiroki Gondo [proposed][stuckless] an
  alternative way to route payments across LN channels with a two-step
  protocol for releasing payment.  In the first phase, money is
  transferred using HTLCs locked to a preimage not known to the receiver.
  When the receiver acknowledges that the money is available, the
  spender releases the information necessary for the receiver to claim
  the money.  The advantage of this method is that it allows the spender
  to prevent a payment from succeeding up until the last moment,
  allowing them to unilaterally cancel stuck payments or even try
  sending the same payment over multiple routes simultaneously to see
  which succeeds the fastest (before canceling the slower payments).
  The proposal would require substantial revision of the current LN
  protocol, so it's something developers will need to consider for
  future upgrades.

- **Standardized atomic data delivery following LN payments:** Nadav
  Kohen [posted][atomic data payments] a proposal to the Lightning-Dev
  mailing list for a standardized way to deliver data paid for via LN,
  the same method already used on Alex Bosworth's [Y'alls][] site.
  Data would be encrypted by a payment request's pre-image so that the
  encrypted data could be given to the buyer before any payment was
  made.  The buyer would then send a payment, the merchant would accept that
  payment by releasing the pre-image, and the buyer would then use the
  pre-image to decrypt the data.  The system still requires the buyer
  trust the merchant, as the merchant could deliver encrypted junk
  instead of the actual data (i.e., this proposal isn't trustless like a
  [zero-knowledge contingent payment][zkcp]), but the proposed protocol
  can allow the buyer to begin downloading data while the payment is
  still being processed.

- **Lightning Loop supports user loop-ins:** as described in [Newsletter
  #39][], [Lightning Loop][] uses *submarine swaps* to allow a user to
  exchange bitcoins in an offchain LN payment channel for bitcoins in
  a normal onchain transaction, called a *loop out.*  This is done without
  opening or closing any channels.  An [update][loop-in] to the
  system now allows users to do the opposite: exchange bitcoins in a
  regular onchain UTXO for bitcoins in one of their LN channels, called
  a *loop in.*  Both loop in and loop out are trustless except for the
  need for one party to pay a transaction fee if the other party backs
  out of the swap.  With the new loop in feature, LN users can
  conveniently refill their exhausted channels without using a custodial
  service.  The Loop software is compatible with recent versions of LND.

## Bech32 sending support

*Week 16 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/16-checklist.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [C-Lightning #2767][] disables the `listtransactions` RPC described in
  *code changes* section of [Newsletter #51][].  That RPC currently has
  several issues open, so it was disabled for the 0.7.1 release.
  Developers plan to re-enable it shortly after the release.

- [Eclair #962][] adds a `balances` method that prints the balances of
  each channel.

{% include linkers/issues.md issues="962,2767" %}
[bech32 series]: /en/bech32-sending-support/
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[johoe stats]: https://jochen-hoenicke.de/queue/#0,24h
[stuckless]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002029.html
[zkcp]: https://bitcoincore.org/en/2016/02/26/zero-knowledge-contingent-payments-announcement/
[lightning loop]: https://github.com/lightninglabs/loop
[loop-in]: https://blog.lightning.engineering/announcement/2019/06/25/loop-in.html
[atomic data payments]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002035.html
[Y'alls]: https://www.yalls.org
[lnd 0.7]: https://github.com/lightningnetwork/lnd/releases/tag/v0.7.0-beta
[cl 0.7.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.1
[watchtower docs]: https://github.com/lightningnetwork/lnd/blob/master/docs/watchtower.md
