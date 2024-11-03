---
title: 'Bitcoin Optech Newsletter #30'
permalink: /en/newsletters/2019/01/22/
name: 2019-01-22-newsletter
slug: 2019-01-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed LN feature to allow making
spontaneous payments and provides our longest-ever list of notable code
changes to popular Bitcoin infrastructure projects.

## News

- **PR opened for spontaneous LN payments:** LN protocol developer
  Olaoluwa Osuntokun opened a [pull request][spontaneous payments] to
  allow an LN node to send a payment to another node without first
  receiving an invoice.  This takes advantage of LN's Tor-like onion
  routing by allowing a spender to choose a preimage, encrypt it so
  that only the receiver's node can decrypt it, and then route a payment
  along LN like normal using the hash of the preimage.  When the
  payment reaches the receiver, they decrypt the preimage and disclose
  it to the routing nodes in order to claim the payment.

  Spontaneous payments
  help in cases where users just want to do ad hoc payment
  tracking, for example you initiate a 10 mBTC withdrawal from an
  exchange and either 10 mBTC shows up in your balance within a few
  moments or you contact support.  Or you just publish your node's
  information and users can send you donations without having to get
  an invoice first.  For tracking specific payments, users
  should still continue to generate invoices which can be uniquely
  associated with particular orders or other expected payments.

  Osuntokun's pull request for LND is still marked as a work in
  progress as of this writing, so we don't know yet when the feature
  will become generally available to LND users or whether other LN
  implementations will also provide the same feature in a compatible
  way.

## Optech recommends

If you prefer listening to audio rather than reading the weekly Optech
newsletter, Max Hillebrand of World Crypto Network has recorded readings
of every newsletter to date---providing a total of more than 6 hours of
technical news about Bitcoin so far.  Audio and video is available on
[YouTube][wcn optech playlist], and audio only is also available as a
podcast via [iTunes][wcn itunes] and [acast][wcn acast].  Optech thanks
Max for volunteering to perform the readings and for doing them so well.
We encourage everyone who would prefer to receive the newsletter in
video or audio form to follow Max for future readings.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
and [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14941][] makes the `unloadwallet` RPC synchronous.
  It won't return now until the specified wallet has finished being
  unloaded.

- [Bitcoin Core #14982][] adds a new `getrpcinfo` RPC that provides
  information about the RPC interface.  Right now it returns an
  `active_commands` array listing all RPCs that haven't returned yet.

- [LND #2448][] adds a standalone watchtower, allowing it to "negotiate
  sessions with clients, accept state updates for active sessions,
  monitor the chain for breaches matching known breach hints, [and] publish
  reconstructed justice transactions on behalf of tower clients."
  This is one of the last pieces of an initial watchtower implementation
  than can help protect LN nodes that are offline from having their
  funds stolen---a feature that's an important part of making LN mature
  enough for general use.

- [LND #2439][] adds the default policy for the watchtower, such as
  allowing the tower to handle a maximum of 1,024 updates from a client
  in a single session, allowing the watchtower to receive a reward of 1%
  of the channel capacity if the tower ends up defending the channel,
  and setting the default onchain feerate for justice transactions
  (breach remedy transactions).

- [LND #2198][] gives the `sendcoins` RPC a new `sweepall` parameter
  that will spend all of the wallet's bitcoins to the specified address
  without the user having to manually specify the amount.

- [C-Lightning #2232][] extends the `listpeers` command with a new
  `funding_allocation_msat` field that returns the amounts initially
  placed into a channel by each peer.

- [C-Lightning #2234][] extends the `listchannels` RPC to take a
  `source` parameter for filtering by node id.  The same pull request also
  causes the `invoice` RPC to include route hints for private channels
  if you have no public channels unless you also set the new
  `exposeprivatechannels` parameter to false.  Route hints suggest part
  of a routing path to the spender so they can send payments through
  nodes they previously didn't know about.

- [C-Lightning #2249][] enables plugins by default on C-Lightning again,
  but a note is added to their documentation indicating that the API is
  still "under active development".

- [C-Lightning #2215][] adds a libplugin library that provides a
  C-language API for plugins.

- [C-Lightning #2237][] gives plugins the ability to register hooks for
  certain events that can change how the main process handles those
  events.  An example given in the code is a plugin that prevents the LN
  node from committing to a payment until a backup of important
  information about the payment has been completed.

- [Eclair #762][] adds limited probing.  Probing in LN is sending an
  invalid payment to a node and waiting for it to return an error.  If
  the node doesn't return an error, it likely means that it or some
  other node along a payment path to it is offline and unable to process
  payments.  Because the probe was an invalid payment that can never be
  redeemed, the sending node can immediately treat it as a timed out
  payment with no risk of loss.  This update to Eclair only allows
  probing a node's direct peers---the nodes with which Eclair has an
  open channel.

{% include references.md %}
{% include linkers/issues.md issues="14941,14982,2448,2439,2198,2232,2234,2249,2215,2237,762" %}
[spontaneous payments]: https://github.com/lightningnetwork/lnd/pull/2455
[wcn optech playlist]: https://www.youtube.com/playlist?list=PLPj3KCksGbSY9pV6EI5zkHcut5UTCs1cp
[wcn itunes]: https://itunes.apple.com/us/podcast/the-world-crypto-network-podcast/id825708806
[wcn acast]: https://play.acast.com/s/world-crypto-network
