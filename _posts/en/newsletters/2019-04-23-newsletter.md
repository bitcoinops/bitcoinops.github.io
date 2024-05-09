---
title: 'Bitcoin Optech Newsletter #43'
permalink: /en/newsletters/2019/04/23/
name: 2019-04-23-newsletter
slug: 2019-04-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the release of LND 0.6-beta and the
merge of BIP158 support into Bitcoin Core's development branch.  Also
included are the regular sections about bech32 sending support and
notable changes to popular Bitcoin infrastructure projects.

{% include references.md %}

## Action items

- **Help test Bitcoin Core 0.18.0 release candidates:** Bitcoin Core's
  fourth RC for its next major version is [available][0.18.0].   This
  resolves several issues found in previous versions and reverts the
  previous merge of a new feature that seemed to be causing problems for
  a minority of testers (see the *notable code changes* section for
  details).  RC testers have already helped improve the quality of the
  final release and those trying this newest RC will further help
  contribute towards making 0.18 the best version of Bitcoin Core yet.
  Please use [this issue][Bitcoin Core #15555] for reporting feedback.

## News

- **LND 0.6-beta released:** seven months after the release of 0.5-beta,
  this [new major version][lnd 0.6-beta] brings a large number of
  notable changes.  Headlining the changes are Static Channel Backups
  (SCBs).  These allow users to create a single backup file any time
  after a new channel has been opened so that they can recover funds
  from that channel and any previously-opened channels in the case of
  data loss (e.g. a hard drive crash).  The system isn't perfect---for
  example, money stored in unsettled HTLCs at the time data was lost
  can't currently be recovered---but it represents a major improvement
  in LN backup safety and a baseline that can be improved upon via
  proposed protocol changes and watchtower support.

  Other changes include several major reductions in the use of memory
  and bandwidth, plus an improved autopilot feature that helps users
  automatically open new channels for payment routing.  Release
  binaries were also built with everything necessary to use with
  [Lightning Loop][] for trustlessly moving LN funds to an onchain
  address without closing a channel.

  For more information, we encourage you to read the comprehensive
  [release notes][lnd 0.6-beta].

- **Basic BIP158 support merged in Bitcoin Core:** with the
  [merge][Bitcoin Core #14121] of a PR by Jim Posen into Bitcoin Core's
  master development branch, users can now enable a new
  `blockfilterindex` configuration option (defaults to off) that will
  generate a [BIP158][] compact block filter for each block on the
  chain plus its corresponding filter header needed for [BIP157][]
  support.[^fn-bip157-bip158]  This will operate in the background while the program
  otherwise continues functioning normally, taking about one to three
  hours on most computers.  The user can then retrieve the filter for a
  specific block using the new `getblockfilter` RPC.  Filters for the
  entire block chain currently use about 4 gigabytes.  Growth over time
  can be seen in the following chart:

  ![Plot of filter size over block height](/img/posts/2019-04-bip158-filter-size-cumulative.png)

  These filters are not currently used anywhere else in the program or
  exposed publicly via Bitcoin Core's implementation of the P2P
  protocol.  A proposed next step for the filters that seems to enjoy
  wide support among Bitcoin Core developers is to allow the local
  program to use the filters to quickly scan the block chain for
  historic transactions.  For example, if you unload a wallet in
  Bitcoin Core's multiwallet mode and then reload it later, it needs
  to look through every block that's arrived since it was unloaded to
  see if any of them contained a transaction affecting the wallet.
  With filters, the wallet can just check the smaller and faster
  filters first and only take a full look at any blocks that the
  filter indicates are a match for containing wallet transactions.

## Bech32 sending support

*Week 6 of 24.  Until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 series] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/06-stackexchange.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].  Note: unless otherwise noted, all merges described
for Bitcoin Core are to its master development branch; some may also be
backported to its pending release.*

- [Bitcoin Core #15839][] reverts [#14897][Bitcoin Core #14897] in the
  0.18 branch only (not the master development branch).  See the
  *notable code changes* section of [Newsletter #33][] for our detailed
  description of #14897, which was merged in early February.  Several
  careful testers of the 0.18.0 Release Candidates (RCs) noticed that
  their node would sometimes stop requesting new transactions shortly
  after being started.  This intermittent problem seemed to be related
  to the transaction-requesting improvement made in #14897 to reduce
  denial-of-service risk.  At least two PRs ([1][Bitcoin Core #15776],
  [2][Bitcoin Core #15834]) have already been opened to attempt to
  address the issue, but there was general agreement in the project to
  remove the new feature in 0.18.0 so that it and its patches can be
  receive additional testing in the development branch before they are
  released in a production version.  The goal of the RC cycle is to
  identify potential problems such as this before they affect regular
  users, so we think we speak for those users in thanking everyone
  involved in the testing so far.

- [Bitcoin Core #15557][] enhances the underlying functions behind the
  `bumpfee` RPC and the equivalent menu option in the GUI to include
  additional inputs if the fee increase can't be paid for by simply
  decreasing the value of an existing change output.  This eliminates
  the [failure mode][rbf core fail] for Bitcoin Core described in
  Optech's [RBF usability study][] and so allows fee bumps made by
  Bitcoin Core users to succeed more often.

- [C-Lightning #2541][], [#2545][c-lightning
  #2545], and [#2546][c-lightning #2546] implement multiple changes to
  the gossip subsystem used for tracking which channels are available
  and calculating routes across them.  This work was motivated by the
  [million channels project][] and performance results from that project
  are included in many of the commit messages.  If Optech is
  interpreting the results correctly, the difference between the [first
  commit][417e1ba] in the series and the [last commit][0fc4241] is an
  79% reduction in memory use, from 2.6 GiB to 0.6 GiB, and an 80%
  reduction in the time to build a route to a randomly-selected node
  (within 20 hops) from 60 seconds to 12 seconds.  (If even the improved
  values seem high, recall this is for a simulation network more than 25
  times the size of the current mainnet network and 1,000 times the size
  of the network a bit over a year ago.)  A notable part of this change
  is C-Lightning switching from its rather unique [Bellman--Ford--Gibson
  (BFG)][bfg post] routing algorithm to a [slightly-customized][e197956]
  version of [Dijkstra][].

- [Eclair #885][] adds a single UUID-style identifier for tracking
  payments no matter what HTLCs are used in relation to it, allowing
  simplified tracking of whether the payment itself ultimately succeeded
  or failed.  This addresses the case where the program automatically
  retries sending a temporarily-failed payment using a different route
  and so generates non-ultimate failures and other information that may
  not be useful to a high-level API consumer.  Although there are
  differences in implementation and motivation, this seems conceptually
  related to [C-Lightning #2382][] as described in the *notable code
  changes* section of [Newsletter #36][].

- [Eclair #951][] implements a channel backup mechanism and provides
  [documentation][eclair backup] for using it.  Unlike the LND static
  channel backups described earlier in this newsletter, this needs to be
  backed up after every payment.  A configuration option allows Eclair
  to call a script you specify to automatically handle backing up the
  data file whenever a backup is needed.

- [Eclair #927][] adds support for plugins written in Scala, Java, or a
  JVM-compatible language.  Plugins are implementations of the [plugin
  interface][eclair plugin interface].  See the newly-added
  [documentation][eclair plugin doc] for details.

## Footnotes

[^fn-bip157-bip158]:
    [BIP158][] introduces _Compact block filters_, which are based on an efficient method for encoding
    a list of equally-sized items. In the case of the "basic" block
    filters described in the BIP, this is a list of all the
    spendable output scriptPubKeys in the current block plus all
    the scriptPubKeys for the outputs spent by this block's inputs
    (what developers call previous outputs (prevouts)).   Each of the
    scriptPubKeys is hashed to give each item the same size and then
    these items are sorted into a list that has duplicated elements
    removed.  This list is then encoded using the [Golomb--Rice Coded
    Sets][gcs] (GCS) algorithm also described in BIP158, losslessly
    reducing the size of the list.  This specific basic filter provides
    enough information for anyone who knows a Bitcoin address to find
    any block containing a transaction either paying that address
    (output scriptPubKey) or spending funds previously received to that
    address (prevout scriptPubKey).  The search may produce false-postive
    matches (so blocks which don't contain transactions for that address
    will be included in the results), but will never result in false-negatives
    (so blocks that _do_ contain transactions for that address will never
    be omitted from the results).

    A separate BIP, [BIP157][], describes how these compact block
    filters can be served over the network using the Bitcoin P2P
    protocol.  BIP157 is designed to work with BIP158 "basic" filters
    but it can also be extended to support additional filters that
    encode lists of other items.  One particularly noteworthy part of
    BIP157 is that it introduces the concept of *filter headers* where
    the header for each filter commits to a hash of the previous block's
    filter header plus a hash of the current filter.  This creates a
    chain of filters similar to Bitcoin's chain of blocks and is
    designed to make it easy to compare filters from multiple peers:
    each peer can send just the filter header (32 bytes) and, if there
    are any headers that don't match, the client can request earlier and
    earlier headers in the chain until the divergence point is found.
    Generating a filter header on demand for a particular block
    would require hashing all previous filters, so even though Bitcoin
    Core's implementation doesn't currently support BIP157, it still
    stores these headers on disk for potential future use.  When
    retrieving a filter using the new `getblockfilter` RPC, both the
    BIP158 filter and the BIP157 header are returned:

    ```text
    $ bitcoin-cli getblockfilter $( bitcoin-cli getblockhash 170 )
    {
      "filter": "0357e49590040c79b0",
      "header": "349eaecc8bb7793c9f3c28e78df6675ef904515e9a310e4532785aeb45526090"
    }
    ```

    We selected block 170 because its filter is the first to contain
    more than one element (it holds 3 elements) and because the latest
    block as of this writing (block 572,879) has a filter that contains
    8,599 elements---far too much for us to print elegantly.

{% include linkers/issues.md issues="15555,14121,15839,14897,15776,15834,15557,885,2541,2545,2546,951,927,2382" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[bech32 series]: /en/bech32-sending-support/
[rbf core fail]: /en/rbf-in-the-wild/#bitcoin-core-increase-transaction-fee-almost
[million channels project]: https://github.com/rustyrussell/million-channels-project
[bfg post]: https://medium.com/@rusty_lightning/routing-dijkstra-bellman-ford-and-bfg-7715840f004
[dijkstra]: https://en.wikipedia.org/wiki/Dijkstra's_algorithm
[417e1ba]: https://github.com/ElementsProject/lightning/commit/417e1bab7d58f05aebb72825063e97b09fb8a6b9
[0fc4241]: https://github.com/ElementsProject/lightning/commit/0fc42415c24c12634b7e219ef80faf0223225c96
[e197956]: https://github.com/ElementsProject/lightning/commit/e197956032ec68470644766f52f9e50470b66a1c
[eclair backup]: https://github.com/ACINQ/eclair/#backup
[eclair plugin interface]: https://github.com/ACINQ/eclair/blob/master/eclair-node/src/main/scala/fr/acinq/eclair/Plugin.scala
[eclair plugin doc]: https://github.com/ACINQ/eclair#plugins
[lnd 0.6-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.6-beta
[lightning loop]: https://github.com/lightninglabs/loop
[rbf usability study]: /en/rbf-in-the-wild/
[gcs]:  https://en.wikipedia.org/wiki/Golomb_coding#Rice_coding
[newsletter #33]: /en/newsletters/2019/02/12/#bitcoin-core-14897
[newsletter #36]: /en/newsletters/2019/03/05/#c-lightning-2382
