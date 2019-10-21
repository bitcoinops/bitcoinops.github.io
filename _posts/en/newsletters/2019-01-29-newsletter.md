---
title: 'Bitcoin Optech Newsletter #31'
permalink: /en/newsletters/2019/01/29/
name: 2019-01-29-newsletter
slug: 2019-01-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a post about the privacy-improving
payjoin proposal, links to top-voted questions and answers from Bitcoin
StackExchange, and describes another busy week worth of notable commits
in popular Bitcoin infrastructure projects.

## Action items

None this week.

## News

- **Post about BIP79 (P2EP/payjoin):** Joinmarket developer Adam (waxwing)
  Gibson sent a [post][payjoin post] to the Bitcoin-Dev mailing list
  about the simplified version of the Pay-to-EndPoint (P2EP) proposal
  described in [BIP79][].  The proposal allows an onchain spender to
  include an input from the person receiving the transaction alongside
  the spender's own inputs, preventing block chain analysts from being
  able to reasonably assume that all inputs came from the same person.
  This could make block chain analysis significantly less reliable even
  if only a fairly small number of people actually use the feature.  See
  [Newsletter #27][payjoin summary] for details.

  Gibson's suggestions focused on modifying the proposal based on his
  experience implementing a P2EP-like protocol in the development
  version of Joinmarket, as well as feedback he's received from the
  developers of Samourai Wallet, who have also implemented a variant of
  the protocol still in developer testing.  The goal is to try to get
  both wallets (and many others) to use the same protocol, and also have
  it supported by payment processors such as BTCPay.
  The suggestions are pretty simple:

    - Version the protocol so spending clients and receiving servers can
      negotiate what protocol features they support
    - Rename the protocol to *payjoin,* as many people aren't quite sure
      what to call it right now
    - Use [BIP174][] Partially Signed Bitcoin Transactions (PSBTs) for
      communicating transaction and signature data between clients and
      servers
    - Specify that transactions should use a short list of best-practice
      transaction features and avoid odd-looking coin selection so that
      payjoin transactions blend in with normal transactions and create
      maximum confusion for block chain analysts

## Selected Q&A from Bitcoin StackExchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.  The section was omitted last month
to make room for our year-end special, so this update includes entries
from both December and January.*

- [How should an LN node decide which channels to open?]({{bse}}83362) LN
  protocol developer and educator Rene Pickhardt describes some criteria
  you can use to help open productive channels.  He also links to some
  interesting discussions about automating channel selection using the
  autopilot feature of LND and his own plugin for C-Lightning.

- [If I generate 20 million Bitcoin addresses an hour, how long until I find a collision?]({{bse}}83818)
  A user generating an incredible
  number of addresses using a computer with 32 cores and 128 GB of
  memory wonders how long until he creates two identical addresses with
  different private keys.  Pieter Wuille's answer and its follow-up comments describe the mathematical
  principles involved, calculate how long it would take---an answer
  given in multiples of the age of the universe---and finally dash any
  hopes the poster had of breaking bitcoin by pointing out that poster's
  method would almost certainly find a collision only between the
  poster's own addresses---leaving other users unaffected.

- [What's the hold-up implementing BIP156 Dandelion in Bitcoin Core?]({{bse}}81503)
  Dandelion is a [proposed method][BIP156] for
  initially relaying newly-created transactions that can make it harder
  to determine the network address of the wallet that created the
  transaction.  This answer from Bitcoin Core developer Suhas Daftuar
  describes some of the challenges faced by developers of
  mission-critical relay protocols and why even conceptually-simple
  ideas like Dandelion might require more work to implement safely than
  other ideas that could also improve the system (e.g. [BIP151][]
  encryption or [libminisketch][] efficient relay).

- [How to use BIP174 PSBTs with a cold wallet and watching-only wallet?]({{bse}}83070)
  It's easy to setup two copies of Bitcoin Core,
  one on an offline computer as a cold wallet for storing private keys
  and one on a networked computer for monitoring the wallet balance and
  broadcasting transactions.  But how would you actually use [BIP174][]
  Partially Signed Bitcoin Transactions (PSBTs) to spend money using
  these two wallets?  BIP174 author Andrew Chow explains.

- [Why relay transactions from node to node---why not send them to miners directly?]({{bse}}83054)
  It seems like the Bitcoin network could
  use a lot less bandwidth if everyone just sent their transactions to
  miners directly and then nodes only distributed blocks.  Pieter Wuille
  explains why that would be bad for privacy and the health of the
  network, plus why it wouldn't even save that much bandwidth.

- [Why should miners hashing arbitrary nonces inspire trust in transaction security?]({{bse}}83951)
  When described as a simple
  guessing game, Bitcoin's proof of work doesn't sound compelling, but
  this answer from one of Bitcoin StackExchange's top 30 experts,
  Chytrik, provides a simple analogy that captures the essence of proof
  of work and how it helps keep Bitcoin transactions secure.

Optech also congratulates and thanks Pieter Wuille, who this month
became the [all-time top-voted contributor][top bse] to Bitcoin
StackExchange.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
and [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14955][] switches the Random Number Generator (RNG)
  used from OpenSSL to Bitcoin Core's own implementation, although RNG
  output gathered by Bitcoin Core is fed out to OpenSSL and then read
  back in when the program needs strong randomness.  This moves Bitcoin
  Core a little closer to no longer needing to depend on OpenSSL, as
  that dependency has caused security issues in the past.  The PR
  description and the code changes are very well documented for anyone
  concerned about the safety of this change.

- [Bitcoin Core #14353][] adds a new REST call
  `/rest/blockhashbyheight/` for fetching the block in the current best
  block chain based on its height (how many blocks after the Genesis
  Block it is).

- [Bitcoin Core #15193][] sets the `whitelistforcerelay` configuration
  option to off by default.  When enabled, this option causes a node to
  relay transactions from its manually whitelisted peers and clients
  even if those transactions violate node policy or consensus rules.
  This could cause the relaying node, rather than the origin node or
  client, to be banned by its peers, so it's better to default to
  turning this option off.  Developers are also asking anyone using this
  feature to [contact][contact core] them so that they know it's not an
  unused option that should be deprecated in the future.

- [LND #2314][] adds a chain notifier subserver, allowing services to
  receive notification about changes to the best block chain---such as
  when new blocks are received, when transactions get confirmed, and
  whether or not an input has been spent.

- [LND #2405][] allows different autopilot heuristics to be combined into
  a single score for each node to which you could connect.  The higher a
  score, the more it's expected that opening a channel to that node will
  increase the connectivity of your node (according to various
  characteristics).

- [LND #2350][] adds a `query` option for the autopilot that accepts a
  list of LN nodes and returns the scores for those nodes indicating how
  good a candidate they are for opening a channel to them.

- [LND #2460][] adds support for the `max_htlc` field in channel
  updates.  This feature allows light clients and pruned nodes to learn
  the maximum routing capacity of a channel belonging to a distant node
  without having to look up that channel's opening transaction on the
  block chain---something which archival full nodes can do, but which
  light clients and pruned nodes can't (not easily, at least).  Now LND
  nodes advertise this information directly, which not only helps light
  clients and pruned nodes, but it also allows LN nodes to specify a
  value below their maximum if they only want to route smaller payments.
  In the future, it could also help support multipath
  payments---payments that are split into parts so that the total
  payment can be larger than the capacity of the smallest channel used.

- [LND #2370][] adds a new sub-system that updates a `channel.backup`
  file each time a new channel is opened or closed.  Users who backup
  this file can run a recovery command that will attempt to close each
  channel in its most recent settled state after connecting to that
  channel's remote peer and initiating the data loss protection protocol
  specified in [BOLT2][].[^fn-data-loss-protect] The backups are
  encrypted using a key from your main LND keychain, which itself should
  be encrypted by a strong passphrase of your choice.

- [C-Lightning #2283][] re-enables the [BOLT2][]
  `option_data_loss_protect` field[^fn-data-loss-protect] after it was
  disabled by default in December (see the code changes section of
  [Newsletter #26][]).

- [Eclair #784][] sends payments using the channel with the lowest
  available balance that can support sending the payment.  This reserves
  the value in higher-value channels for larger payments that may come
  later.  (Ultimately, if the network adopts multipath payments, the
  need to keep at least one channel with a balance larger than the largest payment you
  want to send should go away.)

## Footnotes

[^fn-data-loss-protect]:
    The final paragraph of [BOLT2][] describes the
    `option_data_loss_protect` option.  The basic idea is that a node
    that has potentially lost some of its state can encourage its peer
    to initiate a channel close.  Since the peer still has the most
    recent state, it should close the channel using that state and
    allow both nodes to receive their most recent balances.

    This method does carry a risk---the peer can guess that something
    is wrong and attempt to steal funds from the stale node by closing
    the channel using an old state.  But the risk is mitigated in
    large part by the LN penalty mechanism: if the stale node *does*
    have a revocation of that old state in its backups, it can create
    a breach remedy transaction (justice transaction) that will seize
    all of the lying peer's funds from that channel.  Because of this
    risk, peers using the `option_data_loss_protect` mechanism have an
    incentive to close the channel honestly with the latest state when
    they hear from a stale node.

{% include references.md %}
{% include linkers/issues.md issues="14955,14353,15193,2314,2405,2350,2460,2370,2283,784" %}
[top bse]: https://bitcoin.stackexchange.com/users?tab=Reputation&filter=all
[payjoin summary]: {{news27}}#july
[payjoin post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016625.html
[contact core]: https://bitcoincore.org/en/contact/
