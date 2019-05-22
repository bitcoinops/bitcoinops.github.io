---
title: 'Bitcoin Optech Newsletter #41'
permalink: /en/newsletters/2019/04/09/
name: 2019-04-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests testing for release candidates of
Bitcoin Core and LND, describes a discussion about UTXO snapshots for
fast initial syncing of nodes, and provides regular coverage of bech32
sending support and notable merges in popular Bitcoin infrastructure
projects.

{% include references.md %}

## Action items

- **Help test Bitcoin Core 0.18.0 RC3:** The third Release Candidate
  (RC) for the next major version of Bitcoin Core has been [released][0.18.0].
  This may be the final test version, so we encourage organizations and
  expert users to test it promptly if they want to ensure any
  possible regressions are caught before release.  Please use [this
  issue][Bitcoin Core #15555] for reporting feedback.

- **Help test LND 0.6-beta RC3:** the first, second, and third RCs for
  the next major version of LND were [released][lnd releases] this week.
  Testing by organizations and experienced LN users is encouraged to
  catch any regressions or serious problems that could affect users of
  the final release.  [Open a new issue][lnd issue] if you discover any
  problems.

## News

- **Discussion about an assumed-valid mechanism for UTXO snapshots:**
  When Bitcoin Core developers are preparing a new major release,
  one developer selects the hash of a recent block on the best block
  chain.  Other well-known contributors check their personal nodes and
  ensure that hash is indeed part of the best block chain, and then add
  that hash to the software as the "assumed valid" block.  When new
  users start Bitcoin Core for the first time, the program then defaults[^full-chain-verification]
  to skipping script evaluation in all transactions included
  in blocks before the assumed valid block.  The program still keeps
  track of the bitcoin ownership changes produced by each transaction in
  a index called the Unspent Transaction Output (UTXO) set.  Although
  reviewing each historic ownership change still takes time, simply
  skipping script checking reduces initial sync time by about 80%
  according to [tests][0.14 tests].  Gregory Maxwell, who [implemented
  the assumed valid feature][Bitcoin Core #9484], has argued that,
  "Because the validity of a chain history is a simple objective fact,
  it is [easy] to review this setting."

    This week James O'Beirne started a [thread][assumeutxo thread] on
    the Bitcoin-Dev mailing list about taking a hash of the UTXO set at
    a particular block, having multiple well-known contributors verify
    they get the same hash, and then having freshly installed Bitcoin
    Core nodes default to using that hash to download the exact same
    UTXO set.  This would allow a newly-started node to skip not only
    scripts but all block chain data before the assumed valid block,
    perhaps reducing the time requirements to start a node
    today by 95% or more (and certainly more as the block chain
    continues to grow).  The verification of older blocks and
    transactions could then be done in the background after the user is
    already using their node, eventually giving them the same security
    as a user who disabled this feature.  This is an old idea and is part of
    the motivation for research into other techniques such as [fast
    updatable UTXO commitments][] and [automatic levelDB backups][].

    Discussion mainly revolved around whether or not this is a good
    idea.  Arguments in favor of it include it making starting a new
    node much easier and that it doesn't seem to change the trust model
    for anyone who already trusts the peer review of their development
    team.
    Arguments against
    it include a fear that fast initial syncs with an assumed valid UTXO
    set would disguise the fact that block size increases make complete
    initial syncing from scratch much more expensive; if block sizes
    increased too much, it could become impossible for anyone of modest
    means to ever trustlessly verify Bitcoin's UTXO state, forcing new
    users to trust existing users.

## Bech32 sending support

*Week 4 of 24.  Until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 easy] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

{% include specials/bech32/04-ecc.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].  Note: all merges described for Bitcoin Core and LND
are to their master development branches; some may also be backported to
their pending releases.*

- [Bitcoin Core #15596][] updates the `sendmany` RPC to remove the
  `minconf` parameter, which [didn't function the way people
  expected][sendmany wackiness].
  Now the wallet defaults are
  always used.  Those defaults are not to spend outputs received from
  other people until they are confirmed and to optionally allow spending
  unconfirmed change outputs from yourself depending on the
  `spendzeroconfchange` configuration setting.  This is the same way the
  more commonly used `sendtoaddress` RPC has always worked.

- [LND #2885][] changes how LND attempts to reconnect to all of its
  peers when coming back online.  Previously it attempted to open
  connections to all its persistent peers at once.  Now it spreads the
  connections over a 30 second window to reduce peak memory usage by
  about 20%.  This also means that messages that are sent on a regular
  interval, such as pings, do not happen at the same time for all peers.

- [LND #2740][] implements a new gossiper subsystem which puts its peers
  into two buckets, active gossiper or passive gossiper.  Active
  gossipers are peers communicating in the currently normal way of
  sharing all of their state with your node; passive gossipers are peers
  from which you will only request specific updates.  Because most
  active gossipers will be sending you the same updates as all other
  gossipers, having more than a few of them is a waste of your
  bandwidth, so this code will ensure that you get a default of 3
  active gossipers and then put any other gossipers into the passive
  category.  Furthermore, the new code will try to only request updates
  from one active gossiper at a time in [round-robin][] fashion to avoid
  syncing the same updates from different nodes.  In one test described
  on the PR, this change reduced the amount of gossip data requested by
  97.5%.

- [LND #2313][] implements code and RPCs that allow LND nodes to use
  static channel backups.  This is based on the Data Loss Protection
  (DLP) protocol implemented in [LND #2370][] to allow backing up a
  single file containing all of your current channel state at any point
  and then enabling restoring from that file at any later point to get
  your remote peer to help you to close any of those channels in their
  latest state (excluding unfinalized routed payments (HTLCs)).  Note:
  despite the "static" in this feature's name, this is not like an HD
  wallet one-time backup.  It's a backup that needs to be done at least
  as often as each time you open a new channel---but that's much better
  than the current state where you may not be able to recover any funds
  from any of your channels if you lose data.  Further improvements to
  backup robustness are mentioned in the PR's description.  See the
  description of LND #2370 in [Newsletter #31][] for more details on how
  DLP-based backup and recovery works.  Getting this major improvement
  to backups merged was one of the major goals for upcoming LND version
  0.6-beta.

- [BIPs #772][] withdraws [BIP151][] at the request of its author, who
  has proposed an alternative scheme for [P2P protocol
  encryption][].

- [BIPs #756][] assigns [BIP127][] to a specification for the proof of
  reserves tool described in [Newsletter #33][].  Draft text for the BIP
  is merged.

## Footnotes

[^full-chain-verification]:
    The assumed valid mechanism is enabled by default but can be
    disabled by starting Bitcoin Core with the configuration parameter
    `assumevalid=0` (or `noassumevalid`).  This is will allow your node
    to completely verify every transaction in the block chain to ensure
    it follows all consensus rules.  Note that this will have no effect
    on blocks your node has already processed, so if you want to verify
    scripts in old blocks, you will need to have this option enabled
    from the first time you ever use your node or you will need to need
    to restart Bitcoin Core one time with the `reindex-chainstate`
    configuration option.  For pruned nodes, reindexing requires
    redownloading all pruned blocks.

{% include linkers/issues.md issues="15555,9484,772,756,2313,15596,2885,2740,2370" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[0.14 tests]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#ibd
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[assumeutxo thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
[fast updatable UTXO commitments]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[automatic leveldb backups]: https://github.com/bitcoin/bitcoin/issues/8037
[round-robin]: https://en.wikipedia.org/wiki/Round-robin_scheduling
[bitcoin core 0.5.0]: https://bitcoin.org/en/release/v0.5.0
[sendmany wackiness]: https://github.com/bitcoin/bitcoin/pull/15595#issue-260932169
