---
title: 'Bitcoin Optech Newsletter #114'
permalink: /en/newsletters/2020/09/09/
name: 2020-09-09-newsletter
slug: 2020-09-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes continued discussion about a protocol
for making routable coinswaps and includes our regular sections summarizing
a Bitcoin Core PR Review Club meeting
and notable changes to popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Continued coinswap discussion:** in discussion [continued][belcher
  coinswap] from two weeks ago on the Bitcoin-Dev mailing list (see
  [Newsletter #112][news112 coinswap]), several contributors developed
  and analyzed potential attacks against a proposed routed coinswap
  protocol.  The proposed attacks were:

    - *Costless old state theft:* after a coinswap, when the initiating
      party has the ability to spend a different UTXO than they started
      with, they could try to spend their old UTXO (which is now owned
      by their counterparty).  If the counterparty, or a
      [watchtower][topic watchtowers] agent of theirs, is monitoring the
      block chain, this will fail---but the attempt will cost
      the attacker nothing.

    - *Costless scorched earth:* if fee bumping is made possible by the
      participants pre-signing a set of conflicting replacement
      transactions that signal support for opt-in [Replace By Fee
      (RBF)][topic rbf], then a counterparty may be able to broadcast
      the highest-fee replacement after they've finished receiving their
      new UTXO.  This won't earn them any money, but the high fees will
      be deducted from the value of the honest party's UTXO and so there's no cost to
      the attacker.

    - *Costless pinning theft:* like above, if there are multiple
      versions of the transaction with different feerates, an attacking
      counterparty can broadcast a low-feerate version and then use a
      [transaction pinning][topic transaction pinning] method to make it
      impractical to fee bump.  If the attack is successful, it would
      allow the attacker to spend the victim's money; if it was
      unsuccessful, it might cost the attacker nothing extra if they
      were already planning to send the transactions they used for
      pinning (e.g. they were planning to consolidate UTXOs anyway).

  Several potential solutions to these attacks were discussed.  The
  [most promising solution][belcher collateral] was to require anyone
  spending a coinswap UTXO to spend part of the value of one of their
  other UTXOs to transaction fees.  This *collateral payment* would
  eliminate the costless aspect of the previously described attacks.
  Fully addressing the attacks might also require some other changes
  related to timelocks, such as using a 1-block relative timelock ("`1
  OP_CSV`") to prevent pinning.

  In addition to the discussion helping to improve a privacy-enhancing
  coinswap protocol, at least one participant [noted][zmnscpxj ln] that
  some of the insights from the conversation might be applicable to
  other protocols, such as LN.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/FIXME"
%}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19405][] adds inbound and outbound connection counts to
  `bitcoin-cli -getinfo` and the `getnetworkinfo` RPC.

- [Bitcoin Core #19670][] reserves inbound connection slots for block-relay-only
  and localhost peers. This change was motivated by a user who saw a
  decrease in the number of active inbound Tor connections over time. This
  behavior was due to unintentional bias that increased the chance
  localhost peers would get evicted when Bitcoin Core's connection slots
  filled up.  Since inbound Tor connections are seen as
  localhost peers, the connectivity of Tor peers can be improved by reserving slots
  for localhost peers. A similar reservation is made for block-relay-only peers
  which are disadvantaged but serve as a protection against [eclipse attacks][topic eclipse attacks].

- [Bitcoin Core #14687][] updates the ZMQ event notification service to
  allow creating connections (sockets) that enable [TCP keepalive][] to
  help keep connections alive, especially when they pass through a
  device such as a router or a firewall.  This is especially useful when
  using ZMQ to monitor for sometimes-rare events, e.g. for when there's
  more than 30 minutes between notifications of new blocks.

- [Bitcoin Core #19671][] removes the `-zapwallettxes` configuration
  option that would delete unconfirmed transactions from the wallet so
  that users could create and broadcast alternative transactions using
  the same inputs.  This feature was long ago superseded by the
  `abandontransaction` RPC (or its equivalent context menu option in the
  GUI), each of which allows the user to remove specific unconfirmed
  transactions from the wallet.

- [Bitcoin Core #18244][] updates the `fundrawtransaction` and
  `walletcreatefundedpsbt` RPCs' `lockunspents` parameter so that it
  locks user-specified UTXOs (inputs) in addition to those
  automatically selected by the wallet itself.  Locked UTXOs won't
  automatically be chosen by the wallet for spending in other
  transactions until the wallet is restarted or they are manually
  unlocked; this prevents the user from accidentally creating
  multiple conflicting transactions that spend the same UTXOs.

- [LND #4463][] adds the ability to create authentication tokens
  ("macaroons") that only have permission to access a set of APIs
  specified by the administrator who created the macaroon.  This
  provides more granular access control than LND's existing
  category-based permissions system (see [Newsletter #82][news82 lnd
  acl]).  Additionally, a new `listpermissions` API is added that will
  list the available APIs and the permissions required to access them.

- [BIPs #983][] updates the [BIP325][] definition of the [signet
  protocol][topic signet] to document an existing feature of the proposed Bitcoin
  Core [implementation][bitcoin core #18267] where a challenge that's just
  `OP_TRUE` (or something else guaranteed to succeed on an empty
  witness) doesn't need to include a signet commitment in a block's
  coinbase transaction.

{% comment %}<!-- I'm tempted to link "BitBox 02" to the manufacturer's
product page, but per a quick `git grep` of the repository, we've never
linked to the product pages for Trezor, Ledger, or ColdCard, so adding a
link to for BitBox seems unfair. -harding -->{% endcomment %}

- [HWI #363][] adds support for the BitBox02 hardware wallet.  The
  initial support only allows signing for single-sig scripts, but
  multisig support is planned.  According to the PR comments, this is
  the first merge where HWI support for a new device was contributed on
  behalf of the manufacturer themselves.

{% include references.md %}
{% include linkers/issues.md issues="19405,19670,14687,19671,18244,4463,983,363,18267" %}
[tcp keepalive]: https://tldp.org/HOWTO/TCP-Keepalive-HOWTO/overview.html
[news112 coinswap]: /en/newsletters/2020/08/26/#discussion-about-routed-coinswaps
[belcher collateral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018151.html
[zmnscpxj ln]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018160.html
[belcher coinswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018080.html
[news82 lnd acl]: /en/newsletters/2020/01/29/#upgrade-to-lnd-0-9-0-beta
