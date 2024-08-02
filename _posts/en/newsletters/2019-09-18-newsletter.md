---
title: 'Bitcoin Optech Newsletter #64'
permalink: /en/newsletters/2019/09/18/
name: 2019-09-18-newsletter
slug: 2019-09-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes several talks
from the Bitcoin Edge Dev++ training sessions and Scaling Bitcoin
conference held last week in Tel Aviv.  Also included is our regular
section on notable changes to popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*None this week.*

## News

- **Conference talk summaries:** last week's Scaling Bitcoin conference
  and Edge Dev++ training sessions yielded several interesting talks
  which we've summarized in two special sections later in this
  newsletter.

## Bitcoin Edge Dev++

The Scaling Bitcoin conference was preceded by the community-organized
Bitcoin Edge Dev++ training sessions.  Recordings of the sessions are
expected to be made public in the near future, but [transcripts][edge
dev ts] typed by Bryan Bishop are available now.  We suggest at least
skimming all of the topics, but we found the following transcripts
both novel and interesting:

- [Bitcoin Core rebroadcasting logic][uttarwar rebroadcast] by Amiti
  Uttarwar describes her work to eliminate a privacy leak in Bitcoin
  Core's wallet.  If the first send of a wallet transaction doesn't
  result in reasonably fast confirmation, the wallet will rebroadcast
  the transaction in order to ensure it is relayed to miners.  However,
  there's no other case where a full node will rebroadcast a
  transaction it sent previously, so spy nodes can assume any node
  rebroadcasting a transaction is operated by the user who created that
  transaction.  Worse, this behavior can be actively exploited by
  sending a tiny payment with a low fee to an address whose owner you
  want to identify and waiting for their wallet to rebroadcast the
  transaction.

  Uttarwar's proposed solution is having the node treat all
  transactions the same, rebroadcasting any of them when a heuristic
  indicates they should've been mined recently but weren't.  This
  prevents spy nodes from being able to assume that the node which
  rebroadcast a transaction is operated by the creator of that
  transaction.  The presentation concluded with an overview of some
  edge cases, an insight from Uttarwar's experience developing for
  Bitcoin Core, and a short list of open questions for future
  research.  See [Bitcoin Core #16698][] for the first of Uttarwar's
  PRs implementing these mitigations.

- [Blockchain design patterns: Layers and scaling approaches][pv patterns]
  by Andrew Poelstra and David Vorick briefly describes a long
  list of existing and proposed technologies for making effective use of
  a space-limited block chain.  Starting with existing features, they
  begin by comparing Bitcoin's UTXO model to Ethereum's balance model,
  finding that the spend-once nature of UTXOs greatly simplifies both
  security analysis and cache-based performance improvements.  This
  effective caching is the basis of technologies such as
  bandwidth-reducing [BIP152][] compact blocks, latency-reducing
  [FIBRE][], and many CPU- and memory-reducing improvements within node
  software.  Yet, Poelstra and Vorick note that the overall best way to
  reduce bandwidth, latency, CPU, and memory is to minimize the use of
  global state in the first place by looking for opportunities to use
  offchain protocols based on unbroadcast transactions, replacements of
  those unbroadcast transactions to allow state transitions, and hash
  locks to create dependencies between different transactions.

  Looking at proposed technology, the presenters explain how the
  bandwidth overhead for relaying transactions grows linearly in the
  current protocol as you increase the number of your peers; this can
  be made almost constant with the proposed [erlay][] protocol,
  allowing you to have many more peers, which reduces the risk of network
  partitioning attacks.  Moving on to describing various parts of the
  taproot proposal, they show how schnorr signatures make it possible
  to validate multiple signatures at once (batch validation) and
  combine several public keys and signatures into a single pubkey and
  signature (signature aggregation), reducing the costs of general
  block validation and the specific costs for multisig users.  Schnorr
  also makes it possible to create adaptor signatures that can provide
  the benefits of both a signature and a hash lock at the same time
  and for only the cost of one.  Finally, taproot can commit to a set
  of conditions without requiring any party to reveal those conditions
  unless they need them, which they might not if their protocol allows
  them to use schnorr multiparty signatures instead.  Each of these
  techniques, individually or in combination, can help users keep more
  data offchain.

  The final part of their talk examines more speculative technology,
  such as improvements to LN using [eltoo][], the minimization of
  storage requirements using [utreexo][], [client side
  validation][todd client side] which keeps almost all data offchain,
  Directed Acyclic Graph (DAG) based block chains that allow more
  frequent block production, confidential transactions that hide
  payment amounts, and sharding in both the form of federated block
  chains (available now) and other models that are more speculative.

- [Lightning network topology][kc topology] by Carla Kirk-Cohen
  describes the public topology of channels between LN nodes at present,
  what factors influenced that shape, and what we might be able to do to
  reshape it.  She starts by noting the existence of private channels
  between some nodes that aren't reflected in public data, and then
  outlines the current public network: "5600 nodes, about 35,218 public
  channels, and 959 public BTC sitting in those channels."  Many
  channels, including high-value channels, connect at one end to just a few popular
  nodes, such as the LNbig node which has about "20-24% of the liquidity
  of the LN in their channels."

  Looking at how we arrived at this hub-and-spoke type of topology,
  Kirk-Cohen notes the attractiveness of well-known nodes in the early
  network when all connections were made manually, then the
  attractiveness of well-connected nodes to the early LND autopilot,
  and finally the ongoing attractiveness of popular liquidity
  providers for people who want to receive or route payments.

  Possible improvements discussed involve leveraging various graph
  metrics to help autopilots choose channels that are well-connected
  but not necessarily hubs (such as nodes that are one hop away from a
  hub).  Additionally, she has been working on a scoring system for
  when to *close* a channel and so make your funds available for
  opening a channel to a more effective peer.  Finally, she notes that
  changing channel connections costs onchain fees, so it's not
  practical to make sudden changes to the topology; any changes are
  likely to be applied slowly over time as channels are opened and
  closed organically, so we may have to wait a long time to see
  what effect changes have.

## Scaling Bitcoin

The sixth Scaling Bitcoin conference was held in Tel Aviv, Israel,
September 11th and 12th.  Many of the topics and discussions focused on
subjects we've already covered at length in the newsletter (such as
[Erlay][], [COSHV][], [signet][signet progress], [miniscript][], and
[bitcoin vaults][]).  Of the remaining topics [transcribed][sb ts] by Bryan
Bishop, we found the following topic particularly interesting:

- **TxProbe: discovering Bitcoin's network topology using orphan transactions**
  presented by Sergi Delgado-Segura ([video][vid txprobe],
  [transcript][ts txprobe], [paper][paper txprobe]) describes the
  advantages and disadvantages of being able to determine Bitcoin's
  network topology---which nodes connect to which other
  nodes---something Bitcoin Core tries to prevent.  Delgado-Segura then
  discloses a novel technique he and his co-authors developed for
  probing the network to determine its topology, a combination of using
  orphan transactions (child transactions received before at least one
  of their parents) and a method for temporarily delaying the relay of
  transactions between peers.  The talk illustrates some of the
  challenges of keeping Bitcoin secure and private at the P2P network
  level.

  Although not described in detail during the talk, but perhaps worth
  mentioning here, are the mitigations Bitcoin Core developers have
  deployed as a result of the paper.  The first of these was Bitcoin
  Core [PR#14626][Bitcoin Core #14626], released as part of 0.18.0,
  which made orphan transactions less effective for probing (i.e., it
  fixes the problem described in section 4.3 of the TxProbe paper).
  [PR#14897][Bitcoin Core #14897], described in [Newsletter
  #33][pr14897] with follow-up in Newsletters [#43][pr15839] and
  [#51][pr15834], provided a second and much more significant
  mitigation by eliminating the ability of a third-party to delay
  transaction propagation across the entire network (the *invblock*
  technique described in section 4.2 of the paper as well as a
  [previously published paper][coinscope] by some of the same
  co-authors).  A third mitigation was [PR#15759][Bitcoin Core #15759],
  described in [last week's newsletter][pr15759], which adds two outbound
  connections to each node that only relay blocks---making those two
  connections fundamentally resistant against transaction probing.
  These second and third mitigations are expected to be included in
  the upcoming Bitcoin Core 0.19 release.

  Although several of the specific probing methods described in the
  presentation are being addressed, anyone interested in learning more
  about how nodes form a network and relay information should consider
  perusing the presentation or its paper.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16680][] adds a `-chain` configuration parameter that
  allows the user to select which block chain to use.  This currently
  supports "main" (mainnet), "test" (testnet), and "regtest".  The later
  two chain names can currently be selected using the `-testnet` or
  `-regtest` parameters, but adding a generic function simplifies the
  introduction of additional chains later (e.g. using the signet
  code described in [Newsletter #56][signet progress]).

- [Bitcoin Core #16787][] extends the `getpeerinfo` and `getnetworkinfo`
  RPCs with a new field that decodes the services bitfield which
  indicates what services the peer or local node offer.  This is in
  addition to a previous field that provided the bitfield itself.  For example,
  the bitfield `000000000000040d` decodes to
  `["NETWORK", "BLOOM", "WITNESS", "NETWORK_LIMITED"]`.

- [Bitcoin Core #16725][] now omits the inferred `addresses` field from
  decoded transactions for P2PK outputs.  P2PK outputs---payments
  directly to a pubkey---have never had an address format but the
  RPC interface previously returned the P2PKH address for that pubkey,
  confusing some users and developers.

- [Bitcoin Core #16714][] updates the GUI first-time wizard with an
  option to enable block data pruning.  The default value in the wizard depends on the
  available disk space, with pruning enabled by default if the user
  doesn't have enough space to store the estimated block chain size plus
  10 GB.

- [Bitcoin Core #16285][] extends the `scantxoutset` results with
  `height` and `bestblock` fields so that it's possible to determine
  what chainstate was scanned.

- [Bitcoin Core #15584][] disables support for the [BIP70][] payment
  protocol by default.  It can be re-enabled by compiling with the
  `--enabled-bip70` configure parameter.  See our previous description
  in [Newsletter #19][pr14451] for several reasons why developers
  favor disabling BIP70 support.

- [LND #3282][] allows building LND as a mobile library for Android and
  iOS.  Other programs can include the library and access LND over its
  regular gRPC interface.  For details, see the [mobile readme][].

- [LND #3485][] removes the ability to upgrade from more than one major
  release in the past, simplifying the database migration code and
  allowing testing to focus on fewer upgrade paths.  You can still
  upgrade older versions of LND by upgrading in steps (e.g., 0.5.2-beta
  → 0.6-beta → 0.7-beta → 0.7.1-beta).

- [C-Lightning #2945][] makes new `sendpay_success` and `sendpay_failure`
  notifications available to plugins.

- [C-Lightning #3010][] implements experimental support for [BOLT3][]
  `option_static_remotekey`, allowing C-Lightning to honor the request
  from a channel peer to always pay the same public key for it rather
  than deriving a new key for it.  This makes it easy for the remote
  peer to spend that money even if it loses some channel state.  This
  option is only enabled if C-Lightning is compiled with experimental
  features enabled.

{% include linkers/issues.md issues="16680,16787,16725,16714,16285,15584,3282,3485,2945,3010,16698,14897,14626,15759" %}
[mobile readme]: https://github.com/lightningnetwork/lnd/blob/master/mobile/README.md
[uttarwar rebroadcast]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/edgedevplusplus/rebroadcasting/
[todd client side]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/milan/client-side-validation/
[pv patterns]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/edgedevplusplus/blockchain-design-patterns/
[kc topology]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/edgedevplusplus/lightning-network-topology/
[pr14897]: /en/newsletters/2019/02/12/#bitcoin-core-14897
[pr15839]: /en/newsletters/2019/04/23/#bitcoin-core-15839
[pr15834]: /en/newsletters/2019/06/19/#bitcoin-core-15834
[pr15759]: /en/newsletters/2019/09/11/#bitcoin-core-15759
[signet progress]: /en/newsletters/2019/07/24/#progress-on-signet
[pr14451]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[edge dev ts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/edgedevplusplus/
[utreexo]: https://eprint.iacr.org/2019/611.pdf
[coshv]: /en/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments
[bitcoin vaults]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[fibre]: http://bitcoinfibre.org/
[vid txprobe]: https://youtu.be/-gdfxNalDIc?t=11757
[ts txprobe]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/txprobe/
[paper txprobe]: https://arxiv.org/pdf/1812.00942.pdf
[coinscope]: https://www.cs.umd.edu/projects/coinscope/coinscope.pdf
[sb ts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/
[eltoo]: https://blockstream.com/eltoo.pdf
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
[miniscript]: /en/topics/miniscript/
