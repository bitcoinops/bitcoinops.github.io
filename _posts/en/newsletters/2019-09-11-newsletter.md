---
title: 'Bitcoin Optech Newsletter #63'
permalink: /en/newsletters/2019/09/11/
name: 2019-09-11-newsletter
slug: 2019-09-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a demo implementation of eltoo and
several discussions related to it, requests comments on limiting the
normal number of LN gossip updates to one per day, and provides our
longest-to-date list of notable changes to popular Bitcoin
infrastructure projects.

{% comment %}<!-- evidence for being "longest-ever":
    find _posts/en/newsletters/ -type f | while read file ; do echo -n "$file "; sed -n '/^## Notable code/,${/^## [^\(Notable\)]/Q; /linkers\/issues.md/Q; p}' $file | wc -l ; done | sort -n -k2 | tail
-->{% endcomment %}

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*None this week.*

## News

- **Eltoo sample implementation and discussion:** on the
 Lightning-Dev mailing list, Richard Myers [posted][eltoo sample] a link
 to a sample implementation of an eltoo payment flow between nodes on a
 custom [signet][].  [Eltoo][] is a proposal to replace LN's current
 LN-penalty enforcement layer with a new layer named LN-eltoo.
 LN-penalty prevents counterparty theft by giving nodes the ability to
 financially penalize a counterparty that attempts to publish an old
 channel state onchain.  LN-eltoo accomplish the same goal by giving the
 later states the ability to spend funds from earlier states within a
 certain period of time---eliminating the need for a penalty, simplifying
 many aspects of the protocol, and reducing
 the complexity of many proposed protocol enhancements.  Myers's sample
 implementation works by using the Bitcoin Core functional test
 framework to simulate payments in an eltoo payment channel.

    This led to a discussion ([1][eltoo ms 1], [2][eltoo ms 2]) of
    whether using [miniscript][] would help make LN "more future-proof
    and extensible than directly using Bitcoin Script."

    It also led to eltoo co-author Christian Decker writing a
    [summary][eltoo summary] of why he thinks eltoo is especially
    valuable in providing a clean separation of protocol layers.  For
    example, by making state changes in eltoo similar to state changes
    in Bitcoin, this would allow tools and contract protocols built for
    regular Bitcoin transactions (state changes) to be easily reused
    within payment channels.

- **Request for comments on limiting LN gossip updates to once per day:**
  Rusty Russell [posted][less gossip] to the Lightning-Dev
  mailing list his plan to limit the number of gossip updates
  C-Lightning will accept to one per day normally.  By his calculations
  based on the current network characteristics, this should limit the
  amount of bandwidth used for gossip updates to about 12 MB per day,
  making it easier to use LN on slow devices (like single-board
  computers) and low-bandwidth network connections.  He requests
  feedback from anyone who thinks that will cause a problem for users of
  any current implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16185][] updates the `gettransaction` RPC with a new parameter
  `decode`.  If set to True, a `decoded` field will be added to the RPC
  output containing a version of the transaction decoded into JSON fields
  (the same format used when requesting verbose output with the
  `getrawtransaction` RPC).

- [Bitcoin Core #15759][] increases the number of outbound connections
  the node will make from 8 to 10.  The two new connections will only be
  used to announce and relay new blocks; they won't announce or relay
  unconfirmed transactions or `addr` peer-discovery messages.  Only
  announcing blocks minimizes the bandwidth and memory overhead of the
  new connections and makes it much more difficult for an adversary to map
  the connections between nodes. An adversary that can map all of a node's
  connections can attack that node, either by identifying which transactions
  originate from that node (a privacy leak) or by isolating the node from
  the rest of the network (potentially making theft of funds from the node
  possible). For details on how an adversary could map the network topology
  using transaction relay, see the [TxProbe paper][].

- [Bitcoin Core #15450][] allows users to create new wallets for
  multiwallet mode from the GUI, completing a set of GUI actions that
  also allows users to load and unload wallets.  The action opens a
  dialog that lets the user name the wallet and set various wallet
  options.

- [Bitcoin Core #16421][] follows up [PR#15681][Bitcoin Core #15681]
  (described in [Newsletter #56][carve-out]) by allowing a carve-out
  transaction to be replaced using RBF.  Carve-out transactions are
  allowed to slightly exceed Bitcoin Core's limits on transaction size
  and number of ancestors.  When carve-out was added, the exception to
  those rules was not applied to transaction replacements, so nodes
  would accept carve-outs but not RBF fee bumps of them.  With this PR,
  RBF fee bumping of the carve-out is now possible, making it an even
  more useful tool for fee management of settlement transactions in
  two-party LN payment channels.

- [LND #3401][] caps the amount of onchain fee that a node will propose
  paying in a channel update transaction (commitment transaction),
  limiting it to 50% of the node's current in-channel balance (the 50%
  default is adjustable).  In theory, the channel can still be used
  after this---which is why it isn't closed---although the node may not
  have enough funds to initiate a spend, possibly making receiving its
  only option unless onchain feerates drop.
  The LN protocol only allows the node that opens a channel to propose new
  commitment transactions with feerate changes, so this change only
  applies to channel initiators.

- [LND #3390][] separates tracking of HTLCs from invoices.  Previously,
  each invoice was only meant to be associated with one HTLC, so the
  details were the same.  More recent innovations such as Atomic
  Multipath Payments (AMP) will allow the same invoice to be paid
  incrementally by multiple HTLCs, so this change makes it possible to
  independently track either individual HTLCs or the overall invoice.
  The change also improves tracking of existing HTLCs that were paid
  more than once and simplifies the logic for the hold invoices
  described in [Newsletter #38][lnd hold invoices].

- [C-Lightning #3025][] updates the `listfunds` RPC with a `blockheight`
  field for confirmed transactions indicating the height of the block
  containing them.

- [C-Lightning #2938][] delays reprocessing of incoming HTLCs at
  startup until after all plugins have been loaded.  This prevents
  plugin hooks from being called before their plugin has loaded.

- [C-Lightning #3004][] removes all the features deprecated in
  C-Lightning 0.7.0, including:

    - The deprecated `listpayments` RPC as well as the deprecated
      `description` parameter or output field in `pay`, `sendpay`, and
      `waitsendpay`.  (See [Newsletter #36][listpayments deprecated])

    - The deprecated older style of colon-delimited short channel
      identifier (`Block:Transaction_index:Output_index`).  Instead, use
      the standardized [BOLT7 format][] delimited using an x
      (`BxTxO`).

- [C-Lightning #2924][] abstracts C-Lightning's database handling code
  and SQL queries so that it can be adapted to handle other backends
  besides the default sqlite3.  Future PRs are expected to "add concrete
  implementations of [other database] drivers."

- [C-Lightning #2964][] updates the `txprepare` RPC to allow it to pay
  multiple outputs in the same transaction.

- [Libsecp256k1 #337][] makes it easy to configure the size of a
  pre-computed table used by the library to speed up signature
  generation.  This can save about 32 KB of memory, which is a
  significant amount on some embedded devices that use libsecp256k1.

- [BOLTs #656][] adds a feature bits specification to [BOLT11][],
  allowing payments to indicate which features they support or require.
  This is planned to be used for several new features still under
  development.

{% include linkers/issues.md issues="16185,627,1106,3449,3401,3390,15759,15450,16421,656,337,3004,3025,2938,2924,2964,15681" %}

[bolt7 format]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md#definition-of-short_channel_id
[lnd hold invoices]: {{news38}}#lnd-2022
[listpayments deprecated]: {{news36}}#c-lightning-2382
[carve-out]: {{news56}}#bitcoin-core-15681
[eltoo sample]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002131.html
[eltoo ms 1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002132.html
[eltoo ms 2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002135.html
[eltoo summary]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002136.html
[signet]: https://en.bitcoin.it/wiki/Signet
[less gossip]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002134.html
[txprobe paper]: https://arxiv.org/pdf/1812.00942.pdf
