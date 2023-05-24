---
title: 'Bitcoin Optech Newsletter #170'
permalink: /en/newsletters/2021/10/13/
name: 2021-10-13-newsletter
slug: 2021-10-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a vulnerability recently fixed in
several LN implementations and summarizes a proposal providing multiple
benefits for upgrading the LN protocol to take advantage of features in
taproot.  Also included are our regular sections with the summary of a
recent Bitcoin Core PR Review Club meeting, information about preparing for
taproot, listings of new software releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **LN spend to fees CVE:** last week, Antoine Riard [posted][riard cve]
  the announcement of CVEs for multiple programs to the Lightning-Dev
  mailing list.  Bitcoin users have always been discouraged from
  creating [uneconomical outputs][topic uneconomical outputs] that would
  cost a significant portion of their value to spend.  However, LN
  allows users to send small amounts that would be uneconomical onchain.
  In those cases, the paying or routing node overpays the miner fee for
  the commitment transaction by the small amount, effectively donating
  the money to miners if the commitment transaction gets published
  (which, in most cases, shouldn't happen).

    As reported by Riard, LN implementations allowed setting their
    uneconomical limit to 20% or more of a channel's value, so five
    or fewer payments could spend all of a channel's value to miner
    donations.  Losing value to miners is a fundamental risk of the
    small-payments mechanism used in LN, but risking losing all of a
    channel's value in just five payments was apparently considered
    excessive.

    Several mitigations are described in Riard's email, including having
    LN nodes simply refuse to route payments that would risk donating
    more than a certain amount of their funds to miner fees.
    Implementing this may decrease the ability of nodes to
    simultaneously route more than a few small payments that are
    uneconomical onchain, although it's unclear whether it will cause any
    problems in practice.  All affected LN implementations tracked by
    Optech have released, or soon will release, a version implementing
    at least one of the proposed mitigations.

- **Multiple proposed LN improvements:** Anthony Towns [posted][towns
  proposal] to the Lightning-Dev mailing list a detailed proposal, with
  some example code, describing how to reduce payment latency, improve
  backup resiliency, and allow receiving LN payments while signing keys
  are offline.  The proposal provides some of the same benefits of
  [eltoo][topic eltoo] but without requiring the
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] soft fork or any other
  consensus changes beyond the taproot soft fork that will activate at
  block height {{site.trb}}.  As such, it could be deployed as soon as
  it was implemented and tested by LN developers.  Looking at the major
  features:

    - **Reduced payment latency:** some details necessary to process a
      payment but not specific to the details of the payment can be
      exchanged by channel partners in advance, allowing a node to
      initiate or route a payment by simply sending the payment and
      a signature for the payment to the channel partner.  No round-trip
      communication is required on the critical path, allowing payments
      to propagate across the network at close to the speed of the
      underlying links between LN nodes.  Refunding a payment in case of
      failure would be slower, but not slower than before this change.
      This feature is an extension of ideas previously proposed by
      developer [[ZmnSCPxj]] (see [Newsletter #152][news152 ff]), who also
      [wrote][zmnscpxj name drop] a related post this week based on some
      of his out of band discussions with Towns.

    - **Improved backup resiliency:** currently LN requires both channel
      parties and any [watchtowers][topic watchtowers] they use to store
      information about every prior state of the channel in case of attempted
      theft.  Towns's proposal uses deterministic derivation for most
      information about channel state and encodes a state number in
      each transaction to allow recovering the necessary information
      (with some small amount of brute force grinding required in some
      cases).  This allows a node to backup all of the key-related
      information it needs at the time a channel is created.  Any other
      required information should be obtainable from either the block
      chain (in case of a theft attempt) or from the channel
      partner (in the case a node loses its own data).

    - **Receiving payments with an offline key:** an online (hot) key is
      fundamentally required to send or route a payment in LN, but the
      current protocol also requires an online key in order to receive a
      payment.  Based on an adaptation of [[ZmnSCPxj]]'s previously
      mentioned idea by Lloyd Fournier (also covered in [Newsletter
      #152][news152 ff]), it would be possible for a receiving node to
      only need to bring its keys online in order to open a channel,
      close a channel, or rebalance its channels.  This could
      improve the security of merchant nodes.

    The proposal would also provide the [better known][zmnscpxj taproot ln]
    privacy and efficiency advantages of upgrading LN to use taproot and
    [PTLCs][topic ptlc].  The idea was well discussed on the mailing
    list, with discussion ongoing at the time of writing.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Extract RBF logic into policy/rbf][review club #22675] is a PR by Gloria Zhao
to extract Bitcoin Core's [Replace By Fee][topic rbf] logic into separate
utility functions.

{% include functions/details-list.md

  q0="What is the high-level design goal for the mempool?"
  a0="The mempool aims to keep the most incentive-compatible transaction
candidates for mining, even for non-mining nodes. However, there's a
fundamental conflict between DoS protection (e.g. not allowing people to use
the P2P network to broadcast transactions that will never confirm), and miner
incentives (maximizing joint fee of the top 1 block worth of the mempool).  The
design goal is to specify where that conflict occurs and attempt to minimize it"
  a0link="https://bitcoincore.reviews/22675#l-86"

  q1="What are the benefits of extracting the RBF logic into separate helper functions?"
  a1="Separating the logic into smaller functions allows better unit testing
and for the logic to be re-used in the implementation of package mempool
accept and [package relay][topic
package relay]."
  a1link="https://bitcoincore.reviews/22675#l-24"

  q2="In [BIP125][] Rule #2, why is it important for the replacement
transaction to not introduce any new unconfirmed inputs?"
  a2="If the replacement is allowed to add new _unconfirmed_ inputs, then even
if the feerate increases, the ancestor feerate of the transaction can be
decreased. Miners select transactions for inclusion in a block based on the
ancestor feerate, so if we allowed new inputs to be added, a replacement
transaction could be less attractive to mine than the transaction it is
replacing."
  a2link="https://bitcoincore.reviews/22675#l-52"

  q3="In BIP125 Rule #4, what does it mean for a transaction to \"pay for its
own bandwidth?\" Why don’t we just allow any replacement as long as it has a
higher feerate?"
  a3="\"Paying for its own bandwidth\" means paying a fee which includes an
additional amount that would cover the minimum relay fee for the replacement
transactions. Without this rule, malicious actors could repeatedly bump their
transaction fee by 1 satoshi, and use a disproportionate amount of mempool
compute resources and network bandwidth."
  a3link="https://bitcoincore.reviews/22675#l-117"

  q4="Replace-by-fee logic is concerned with mempool policy. Why does [this
logic][transaction spends its outputs] return that the replacement transaction
failed due to consensus rules, not policy rules?"
  a4="This logic catches the case where the replacement transaction is spending
a transaction that it is replacing. Since it's impossible for both the original
transaction and the replacement transaction to be confirmed, this replacement
transaction can never appear in the block chain, and so is consensus invalid."
  a4link="https://bitcoincore.reviews/22675#l-40"

%}

## Preparing for taproot #17: is cooperation always an option?

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/17-keypath-universality.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.6.2][] in a new release that includes a fix for
  the vulnerability described in the *news* section above as well new
  features and other bug fixes described in its [release notes][eclair
  rn].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #20487][] adds a `-sandbox` configuration option that
  can be used to enable an experimental system call (syscall) sandbox.
  When the sandbox is active, the kernel will terminate Bitcoin Core if
  it makes any syscalls other than those on a per-process allowlist.  The
  mode is currently only available on x86_64 and is mainly meant for
  testing what syscalls are being used by particular threads.

- [Bitcoin Core #17211][] updates the wallet's `fundrawtransaction`,
  `walletcreatefundedpsbt` and `send` RPC methods to allow transactions
  where not all of the outputs being spent by the transaction are owned by the
  wallet.

    Previously, the wallet was not able to estimate the fee required
    for spending outputs that it didn't own, since it didn't know
    the size of the input required to spend that output. This PR
    updates those RPC methods to accept a `solving_data` argument. By providing
    the public keys, serialized scriptPubKeys, or [descriptors][topic
    descriptors] for the outputs being spent in the transaction, the wallet can
    estimate the size of the inputs required to spend those outputs (and therefore
    the fee required to spend the outputs).

- [Bitcoin Core #22340][] After a block is mined, it is broadcast to the p2p network,
  where it will eventually be relayed to all nodes on the network. Traditionally,
  there have been two methods to relay blocks: legacy relay and [BIP152][]-style
  [compact block relay][topic compact block relay].

  A node started with the `-blocksonly` setting does not accept relayed transactions from public nodes to reduce its
  bandwidth usage, and so usually has an empty mempool. Therefore, compact blocks are
  not beneficial to such a node since it will always have to download full blocks.
  However, in both high- and low-bandwidth mode, the `cmpctblock` message is
  relayed, representing a bandwidth overhead for blocks-only nodes because the
  `cmpctblock` message is several times larger than in average case than the
  equivalent headers or `inv` announcement.

  As described in [newsletter #165][PR review club 22340], this PR makes blocks-only
  nodes use legacy relaying to download new blocks by preventing blocks-only nodes
  from initiating a high-bandwidth block relay connection and disabling the sending
  of `sendcmpct(1)`. Additionally, a blocks-only node no longer requests a compact
  block using `getdata(CMPCT)`.

- [Bitcoin Core #23123][] removes the `-rescan` startup option.  Users
  can instead use the `rescan` RPC.

- [Eclair #1980][] will accept commitment transactions created with any
  feerate above the local full node's dynamic minimum relay fee when
  [anchor outputs][topic anchor outputs] are being used.

- [LND #5363][] allows skipping the [PSBT][topic psbt] finalization step within LND,
  allowing PSBTs to be finalized and broadcast using other software.
  This can lead to funds loss if the transaction's txid is accidentally
  changed, but it does allow alternative workflows.

- [LND #5642][] will now keep an in-memory cache of the channel graph to speed
  up pathfinding operations. Previously, pathfinding required expensive database
  queries which were over 10x slower according to the PR author's measurements.

  Users running LND on low-memory systems can reduce the memory footprint of
  this new cache by using the `routing.strictgraphpruning=true` flag to more
  aggressively remove zombie channels.

- [LND #5770][] provides more information to LND's subsystems about
  uneconomical outputs in order to allow implementing mitigations for
  the LN CVE described in the *news* section above.

{% include references.md %}
{% include linkers/issues.md issues="20487,17211,22340,23123,1980,5363,5642,5770,22675" %}
[riard cve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html
[zmnscpxj name drop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003265.html
[news152 ff]: /en/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key
[towns proposal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003278.html
[zmnscpxj taproot ln]: /en/preparing-for-taproot/#ln-with-taproot
[eclair 0.6.2]: https://github.com/ACINQ/eclair/releases/tag/v0.6.2
[eclair rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.6.2.md
[transaction spends its outputs]: https://github.com/bitcoin/bitcoin/blob/0ed5ad102/src/validation.cpp#L774
[PR review club 22340]: /en/newsletters/2021/09/08/#bitcoin-core-pr-review-club
