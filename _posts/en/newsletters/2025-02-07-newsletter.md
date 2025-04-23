---
title: 'Bitcoin Optech Newsletter #340'
permalink: /en/newsletters/2025/02/07/
name: 2025-02-07-newsletter
slug: 2025-02-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a fixed vulnerability affecting LDK,
summarizes discussion about zero-knowledge gossip for LN channel
announcements, describes the discovery of previous research that can be
applied to finding optimal cluster linearizations, provides an update on
the development of the Erlay protocol for reducing transaction relay
bandwidth, looks at tradeoffs between different scripts for implementing
LN ephemeral anchors, relays a proposal for emulating an `OP_RAND`
opcode in a privacy-preserving manner with no consensus changes
required, and points to renewed discussion about lowering the minimum
transaction feerate.

## News

- **Channel force closure vulnerability in LDK:** Matt Morehouse
  [posted][morehouse forceclose] to Delving Bitcoin to announce a
  vulnerability affecting LDK that he [responsibly disclosed][topic
  responsible disclosures] and which was fixed in LDK version 0.1.1.
  Similar to Morehouse's other recently disclosed vulnerability in LDK
  (see [Newsletter #339][news339 ldkvuln]), a loop in LDK's code
  terminated the first time it handled an unusual occurrence, preventing
  it from handling additional occurrences of the same problem.  In this
  case, it could result in LDK failing to settle pending [HTLCs][topic
  htlc] in open channels, ultimately leading honest counterparties to
  force close the channels so that they could settle the HTLCs onchain.

  This likely couldn't lead to direct theft, but it could result in the
  victim paying fees for the closed channels, paying fees to open new
  channels, and reduce the victim's ability to earn forwarding fees.

  Morehouse's excellent post goes into additional detail and suggests
  how future bugs from the same underlying cause might be avoided. {% assign timestamp="2:14" %}

- **Zero-knowledge gossip for LN channel announcements:** Johan Halseth
  [posted][halseth zkgoss] to Delving Bitcoin with an extension to the
  proposed 1.75 [channel announcement][topic channel announcements]
  protocol that would allow other nodes to verify that a channel was
  backed by a funding transaction, preventing multiple cheap DoS
  attacks, but without revealing which UTXO is the funding
  transaction---enhancing privacy.  Halseth's extension builds on his
  previous research (see [Newsletter #321][news321 zkgoss]) that uses
  [utreexo][topic utreexo] and a zero-knowledge (ZK) proof system.  It
  would be applied to [MuSig2][topic musig]-based [simple taproot
  channels][topic simple taproot channels].

  The discussion focused on the tradeoffs between Halseth's idea,
  continuing to use non-private gossip, and alternative methods for
  generating the ZK proof.  Concerns included ensuring that
  all LN nodes can quickly verify proofs and the complexity of the proof
  and verification system since all LN nodes will need to implement it.

  Discussion was ongoing at the time this summary was written. {% assign timestamp="16:01" %}

- **Discovery of previous research for finding optimal cluster linearization:**
  Stefan Richter [posted][richter cluster] to Delving Bitcoin about a
  research paper from 1989 he found that has a proven algorithm that
  can be used to efficiently find the highest-feerate subset of a group
  of transactions that will be topologically valid if the subset is included in a
  block.  He also found a [C++ implementation][mincut impl] of several
  algorithms for similar problems that "are supposed to be even faster
  in practice".

  Previous work on [cluster mempool][topic cluster mempool] focused on
  making it easy and fast to compare different linearizations so that
  the best one could be used.  This would allow using a fast algorithm
  to immediately linearize a cluster, with a slower but more optimal
  algorithm able to run on spare CPU cycles.  However, if the 1989
  algorithm for the _maximum-ratio closure problem_, or another
  algorithm for that problem, can run fast enough, it could be
  used all of the time instead.  But, even if it was moderately slow, it
  could still be used as the algorithm that runs on spare CPU cycles.

  Pieter Wuille [replied][wuille cluster] with excitement and multiple
  follow-up questions.  He also [described][wuille sp cl] a new cluster
  linearization algorithm that the cluster mempool working group has
  been developing based on a discussion from Bitcoin Research Week with
  Dongning Guo and Aviv Zohar.  It converts the problem to one that can
  be addressed using [linear programming][] and appears to be fast, easy
  to implement, and produces an optimal linearization---if it
  terminates.  However, proof is needed that it will terminate (and in a
  reasonable amount of time).

  Although not directly related to Bitcoin, we found interesting
  Richter's [description][richter deepseek] of how he found the 1989
  paper using the DeepSeek reasoning LLM.

  At the time of writing, discussion was ongoing and additional papers
  about the problem domain were being explored.  Richter wrote, "It
  appears that our problem, or rather, its generalized solution which is
  called _source-sink-monotone parametric min-cut_ has applications in
  something called polygon aggregation for map simplification and other
  topics in computer vision." {% assign timestamp="26:29" %}

- **Erlay update:** Sergi Delgado made several posts to Delving Bitcoin
  about his work over the past year implementing [Erlay][topic erlay]
  for Bitcoin Core.  He starts with an [overview][delgado erlay] of how
  existing transaction relay (called _fanout_) works and how Erlay
  proposes changing that.  He notes that some fanout is
  expected to remain even in a network where every node supports Erlay,
  as "fanout is more efficient and considerably faster than set
  reconciliation, provided the receiving node does not know about the
  transaction being announced."

  Using a mix of fanout and reconciliation requires choosing when
  to use each method and which peers to use them with, so his research
  has focused on making the optimal choices: {% assign timestamp="46:38" %}

  - [Filtering based on transaction knowledge][sd1] examines whether a
    node should include a peer in its plans to fanout a transaction even
    if it knows that peer already has the transaction.  For example, our
    node has ten peers; three of those peers have already announced a
    transaction to us.  If we want to randomly choose three peers to
    further fanout that transaction, should we select from all ten peers
    or just the seven peers that haven't announced the transaction to
    us?  Surprisingly, simulation results show that "there is no
    significant difference between [the options]".  Delgado explores
    this surprising result and concludes that all peers should be
    considered (i.e., no filtering should be done).

  - [When to select fanout candidate peers][sd2] examines when a node
    should choose which peers will receive a fanout transaction (with the
    remainder using Erlay reconciliation).  Two options are considered:
    shortly after a node validates a new transaction and queues it for relay, and
    when it's time for that transaction to be relayed (nodes don't relay
    transactions immediately: they wait a small random amount of
    time to make it harder to probe the network
    topology and guess which node originated a transaction, which would
    be bad for privacy).  Again, simulation results show that "there are
    no meaningful differences", although the "results may vary [...] in
    networks with partial [Erlay] support".

  - [How many peers should receive a fanout][sd3] examines the fanout
    rate.  A higher rate accelerates transaction propagation but reduces
    bandwidth savings.  Besides testing the fanout rate, Delgado also
    tested increasing the number of outbound peers, as that's one of the
    goals of adopting Erlay.  The simulation shows the current Erlay
    approach reduced bandwidth by approximately 35% using current outbound
    peer limits (8 peers), and 45% using 12 outbound peers.  However,
    the transaction latency is increased by about 240%.  Many other
    tradeoffs are graphed in the post.  In addition to the results
    being helpful for choosing current parameters, Delgado notes that
    they'll be useful for evaluating alternative fanout algorithms that
    might be able to make better tradeoffs.

  - [Defining the fanout rate based on how a transaction was received][sd4]
    examines whether the fanout rate should be adjusted depending on
    whether a transaction was first received via fanout or
    reconciliation.  Further, if it should be adjusted, what adjusted
    rate should be used?  The idea is that fanout is faster and more
    efficient as a new transaction begins being relayed through the
    network, but it leads to wasted bandwidth after a transaction has
    already reached most nodes.  There's no way for a node to directly
    determine how many other nodes have already seen a transaction, but
    if the peer that first sent it a transaction used fanout rather than
    waiting for the next scheduled reconciliation, then it's more likely
    that the transaction is in the early stage of propagation.  This data
    can be used to moderately increase the node's own fanout rate for that
    transaction to help it propagate faster.  Delgado simulated the idea
    and found a modified fanout ratio that decreases propagation time by
    18% with only a 6.5% increase in bandwidth over the control result
    that uses the same fanout rate for all transactions.

- **Tradeoffs in LN ephemeral anchor scripts:** Bastien Teinturier
  [posted][teinturier ephanc] to Delving Bitcoin to ask for opinions
  about what [ephemeral anchor][topic ephemeral anchors] script should
  be used as one of the outputs to [TRUC][topic v3 transaction
  relay]-based LN commitment transactions as a replacement for existing
  [anchor outputs][topic anchor outputs].  The script used determines
  who can [CPFP fee bump][topic cpfp] the commitment transaction (and
  under what conditions they can bump).  He presented four options:

  - *Use a pay-to-anchor (P2A) script:* this has a minimal onchain size
    but means that all [trimmed HTLC][topic trimmed htlc] value will
    probably go to miners (like it presently does).

  - *Use a single-participant keyed anchor:* this may allow some excess
    trimmed HTLC value to be claimed by a participant who voluntarily
    accepts waiting a few dozen blocks before being able to spend the
    money they close out of a channel.  Anyone who wants to force close
    a channel must wait that time anyway.  However, neither
    party to the channel can delegate paying the fee to a third-party
    without allowing that party to steal all of their channel funds.
    If both you and your counterparty compete to claim the excess value,
    it will likely all go to miners anyway.

  - *Use a shared key anchor:* this also allows recovery of excess
    trimmed HTLC value and allows delegation, but anyone who receives
    the delegation can compete with you and your counterparty to claim
    the excess value.  Again, in the case of competition, all excess
    value is likely to go to miners.

  - *Use a dual-keyed anchor:* this allows each participant to claim excess
    trimmed HTLC value without having to wait for additional blocks before
    being able to spend.  However, it does not allow delegation.  The
    two parties to a channel can still compete with each other.

  In replies to the post, Gregory Sanders [noted][sanders ephanc] that
  the different schemes could be used at different times.  For example,
  P2A could be used when there were no trimmed HTLCs, and one of the
  keyed anchors could be used other times.  If the
  trimmed value was above the [dust threshold][topic uneconomical
  outputs], that value could be added to the LN commitment
  transaction instead of an anchor output.
  Additionally, he warned that it could create "new weirdness [a]
  counterparty may be tempted to ramp up the trimmed amount and take it
  themselves."  David Harding extended on this theme in a [later
  post][harding ephanc].

  Antoine Riard [warned][riard ephanc] against using P2A due to the risk
  of encouraging miner [transaction pinning][topic transaction pinning]
  (see [Newsletter #339][news339 pincycle]).

  Discussion was ongoing at the time of writing. {% assign timestamp="1:09:50" %}

- **Emulating OP_RAND:** Oleksandr Kurbatov [posted][kurbatov rand] to
  Delving Bitcoin about an interactive protocol that allows two parties
  to make a contract that will pay out in a way that neither can
  predict, which is functionally equivalent to randomly.  [Previous work][dryja pp] on
  _probabilistic payments_ in Bitcoin has used advanced scripts, but
  Kurbatov's approach uses specially constructed public keys
  that allows the winner to spend the contracted funds.  This is more
  private and may allow greater flexibility.

  Optech wasn't able to fully analyze the protocol, but we didn't spot any
  obvious problems.   We hope to see additional discussion of the
  idea---probabilistic payments have multiple applications, including
  allowing users to send amounts onchain that would otherwise be
  [uneconomical][topic uneconomical outputs], such as for [trimmed
  HTLCs][topic trimmed htlc]. {% assign timestamp="1:30:30" %}

- **Discussion about lowering the minimum transaction relay feerate:**
  Greg Tonoski [posted][tonoski minrelay] to the Bitcoin-Dev mailing
  list about lowering the [default minimum transaction relay
  feerate][topic default minimum transaction relay feerates], a topic
  that has been discussed repeatedly (and summarized by Optech) since
  2018---most recently in 2022 (see [Newsletter #212][news212 relay]).
  Of note, a recently disclosed vulnerability (see [Newsletter
  #324][news324 largeinv]) did reveal a potential problem that could
  have affected users and miners who lowered the setting in the past.
  Optech will provide updates if there is significant further discussion. {% assign timestamp="1:36:33" %}

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Updates to cleanup soft fork proposal:** Antoine Poinsot made
  several posts to the Delving Bitcoin thread about the [consensus
  cleanup soft fork][topic consensus cleanup] suggesting parameter
  changes: {% assign timestamp="1:43:46" %}

  - [Introduce legacy input sigops limit][ap1]: in a private thread,
    Poinsot and several other contributors have attempted to produce a
    block for regtest that will take the longest possible time to
    validate using known problems in the validation of legacy
    (pre-segwit) transactions.  After research, he found that he could
    "adapt [the worst block] to be valid under the [mitigations
    originally proposed][ccbip] in 2019" (see [Newsletter #36][news36
    cc]).  This leads him to propose a different mitigation: limiting
    the maximum number of signature operations (sigops) in legacy
    transactions to 2,500.  Each execution of `OP_CHECKSIG` counts as
    one sigop and each execution of `OP_CHECKMULTISIG` can count as up
    to 20 sigops (depending on the number of public keys used with it).
    His analysis shows that this will decrease the worst-case validation
    time by 97.5%.

    As with any change of this type, there is a risk of [accidental
    confiscation][topic accidental confiscation] due to the new rule
    making previously signed transactions invalid.  If you know of
    someone who requires legacy transactions with more than 2,500
    single-sig operations or more than 2,125 keys for multisig
    operations[^2kmultisig], please alert Poinsot or other protocol
    developers.

  - [Increase timewarp grace period to 2 hours][ap2]: previously, the
    cleanup proposal disallowed the first block in a new difficulty
    period from having a block header time more than 600 seconds before
    the time of the previous block.  This meant that a constant amount
    of hashrate could not use the [timewarp][topic time warp]
    vulnerability to produce blocks faster than once every 10 minutes.

    Poinsot now accepts using a 7,200 second (2 hour) grace period, as
    originally proposed by Sjors Provoost as being much less likely to
    lead to a miner accidentally producing an invalid block, although it
    does allow a very patient attacker controlling more than 50% of
    network hashrate to use the timewarp attack to lower difficulty
    over a period of months even if actual hashrate remains constant or
    increases.  This would be a publicly visible attack and the network
    would have months to react.  In his post, Poinsot summarizes
    previous arguments (see [Newsletter #335][news335 cc] for our much
    less detailed summary) and concludes that, "despite the fairly weak
    arguments in favor of increasing the grace period, the cost of doing
    so [does] not prohibit erring on the safe side."

    On a thread dedicated to discussing extending the grace period,
    developers Zawy and Pieter Wuille [discussed][wuille erlang] how the
    600 second grace period, which would seem to allow slowly decreasing
    difficulty to its minimum value, was actually sufficient to prevent more
    than one small difficulty decrease.  Specifically, they looked at the impact of
    Bitcoin's off-by-one difficulty adjustment bug and the asymmetry of
    the [erlang][] distribution on accurately retargetting difficulty.
    Zawy succinctly concluded, "It’s not that an adjustment for both
    Erlang and '2015 hole' aren’t needed, it’s that 600 seconds before
    the previous block isn’t a 600 second lie, it’s a 1200 second lie
    because we expected a timestamp 600 seconds after it."

  - [Duplicate transaction fix][ap3]: following a request for feedback
    from miners (see [Newsletter #332][news332 cleanup]) about potential
    negative impacts of consensus solutions to the [duplicate
    transactions][topic duplicate transactions] problem, Poinsot
    selected a specific solution to include in the cleanup proposal:
    requiring the height of the previous block be included in each
    coinbase transaction's time lock field.  This proposal has two
    advantages: it allows [extracting][corallo duplocktime] the
    committed block height from a block without having to parse Script
    and it allows [creating][harding duplocktime] a compact SHA256-based
    proof of block height (about 700 bytes in the worst case, much less
    than the worst-case 1 MB proof that would be required now without an
    advanced proof system).

    This change will not affect regular users but it will eventually
    require miners to update the software they use to generate coinbase
    transactions.  If any miners have concerns about this proposal,
    please contact Poinsot or another protocol developer.

  Poinsot also [posted][ap4] a high-level update on his work and the
  proposal's current state to the Bitcoin-Dev mailing list.

- **Request for a covenant design supporting Braidpool:** Bob McElrath
  [posted][mcelrath braidcov] to Delving Bitcoin requesting developers
  working on [covenant][topic covenants] designs to consider how their
  favorite proposal, or a new proposal, could assist in the creation of
  an efficient decentralized [mining pool][topic pooled mining].  The
  current prototype design for Braidpool uses a federation of signers,
  where signers receive [threshold signing][topic threshold signature]
  shares based on their contribution of hashrate to the pool.  This
  allows a majority miner (or a collusion of multiple miners
  constituting a majority) to steal payouts from smaller miners.
  McElrath would prefer to use a covenant that ensures each miner is
  able to withdraw funds from the pool in proportion to their
  contributions.  He provides a specific list of requirements in the
  post; he also welcomes a proof of impossibility.

  As of this writing, there have been no replies. {% assign timestamp="2:28:59" %}

- **Deterministic transaction selection from a committed mempool:** a
  thread from April 2024 received renewed attention this past month.
  Previously, Bob McElrath [posted][mcelrath dtx] about having
  miners commit to the transactions in their mempool and then only
  allowing them to include transactions in their blocks that were
  deterministically selected from previous commitments.  He sees two
  applications:

  - _Globally for all miners:_ this would eliminate the "risk and
    liability of transaction selection" in a world where miners are
    often large corporate entities that need to comply with laws,
    regulations, and the advice of risk managers.

  - _Locally for a single pool:_ this has most of the advantage of a
    global deterministic algorithm but doesn't require any consensus
    changes to implement.  Additionally, it can save a large amount of
    bandwidth between peers in a decentralized [mining pool][topic
    pooled mining] such as Braidpool, as the algorithm determines which
    transactions a _candidate block_ must include, so any _share_
    produced from that block doesn't need to explicitly provide any
    transaction data to pool peers.

  Anthony Towns [described][towns dtx] several potential problems with a
  global consensus change option: any change to transaction selection
  would require a consensus change (possibly a hard fork) and anyone who
  created a non-standard transaction would be unable to get it mined
  even with the cooperation of a miner.  Recent policy changes in the
  past few years that would've required a consensus change include:
  [TRUC][topic v3 transaction relay], updated [RBF][topic rbf] policies,
  and [ephemeral anchors][topic ephemeral anchors].  Towns linked to a
  [well-known case][bitcoin core #26348] where millions of dollars in value were
  accidentally stuck into a non-standard script, which a cooperative
  miner was able to unstick.

  The rest of the discussion focused on the local approach as conceived
  for Braidpool.  There were no objections and additional discussion on
  a topic about a difficulty adjustment algorithm (see next item in this
  section) showed how it could be especially useful for a pool that
  creates blocks at a much higher rate than Bitcoin, where transaction
  selection determinism significantly reduces bandwidth, latency, and
  validation costs. {% assign timestamp="2:04:52" %}

- **Fast difficulty adjustment algorithm for a DAG blockchain:**
  developer Zawy [posted][zawy daadag] to Delving Bitcoin about a mining
  [difficulty adjustment algorithm][topic daa] (DAA) for a directed
  acyclic graph (DAG) type blockchain.  The algorithm was [designed][bp
  pow] for use in Braidpool's peer consensus (not global Bitcoin
  consensus), however discussion did repeatedly touch on aspects of
  global consensus.

  In Bitcoin's blockchain, each block commits to exactly one parent;
  multiple child blocks may commit to the same parent, but only one of
  them will be considered valid on the _best blockchain_ by a node.  In
  a DAG blockchain, each block may commit to one or more parents and may
  have zero or more children that commit to it; the DAG best blockchain
  may consider multiple blocks in the same generation to be valid.

  ![Illustration of a DAG blockchain](/img/posts/2025-02-dag-blockchain.dot.png)

  The proposed DAA targets the average number of parents in the
  last-seen 100 valid blocks.  If the average number of parents
  increases, the algorithm increases difficulty; if there are fewer
  parents, the difficulty decreases.  Targeting an average of two
  parents gives the fastest consensus, according to Zawy.  Unlike
  Bitcoin's DAA, the proposed DAA doesn't need any awareness of time;
  however, it does require peers to ignore blocks that arrive much later
  than other blocks in the same generation.  It's not possible to
  achieve consensus on lateness, so ultimately DAGs with more
  proof-of-work (PoW) are preferred over those with less PoW; the
  developer of the DAA, Bob McElrath, [analyzed][mcelrath daa-latency]
  the problem and a possible mitigation.

  Pieter Wuille [commented][wuille prior] that the proposal appears
  similar to a [2012 idea][miller stale] by Andrew Miller; Zawy
  [agreed][zawy prior] and McElrath [will][mcelrath prior] update his
  paper with a citation.  Sjors Provoost [discussed][provoost dag] the
  complexity of handling DAG chains in Bitcoin Core's current
  architecture, but noted that it might be easier using libbitcoin and
  efficient using [utreexo][topic utreexo].  Zawy extensively
  [simulated][zawy sim] the protocol and indicated that he was working
  on additional simulations for variants of the protocol to find the
  best mix of tradeoffs.

  The last post to the discussion thread was made about a month before this
  summary was written, but we expect Zawy and Braidpool developers are
  continuing to analyze and implement the protocol. {% assign timestamp="2:19:24" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BDK Wallet 1.1.0][] is a release of this library for building
  Bitcoin-enabled applications.  It uses transaction version 2 by
  default (improving privacy by allowing BDK transactions to blend in
  with other wallets that must use v2 transactions due to their support
  for relative locktimes, see [Newsletter #337][news337 bdk]).  It also
  adds support for [compact block filters][topic compact block filters]
  (see [Newsletter #339][news339 bdk-cpf]), in addition to "various bug
  fixes and improvements". {% assign timestamp="2:39:15" %}

- [LND v0.18.5-beta.rc1][] is a release candidate for a minor version of
  this popular LN node implementation. {% assign timestamp="2:39:43" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #21590][] implements a safegcd-based [modular
  inversion][modularinversion] algorithm for MuHash3072 (see Newsletters
  [#131][news131 muhash] and [#136][news136 gcd]), based on libsecp256k1’s implementation while adding
  support for both 32-bit and 64-bit architectures and specializing for the
  specific modulus. Benchmark results show an approximate 100× performance
  improvement on x86_64, reducing MuHash’s computation from 5.8 ms to 57 μs,
  paving the way for more efficient state validation. {% assign timestamp="38:58" %}

- [Eclair #2983][] modifies routing table synchronization on reconnection to
  only synchronize [channel announcements][topic channel announcements] with the node's
  top peers (determined by shared channel capacity) to
  reduce network overhead. In addition, the default behavior of the
  synchronization whitelist (see Newsletter [#62][news62 whitelist]) has been
  updated: to disable synchronization with non-whitelisted peers, users must now
  set `router.sync.peer-limit` to 0 (the default value is 5). {% assign timestamp="1:23:30" %}

- [Eclair #2968][] adds support for [splicing][topic splicing] on public
  channels. Once the splice transaction is confirmed and locked on both sides,
  nodes exchange announcement signatures and then broadcast a
  `channel_announcement` message to the network. Recently, Eclair added tracking
  of third-party splices as a prerequisite for this (see Newsletter
  [#337][news337 splicing]). This PR also disallows the use of
  `short_channel_id` for routing on private channels, instead prioritizing
  `scid_alias` to ensure that the channel UTXO isn't revealed. {% assign timestamp="1:27:53" %}

- [LDK #3556][] improves [HTLC][topic htlc] handling by proactively failing
  HTLCs backwards if they are too close to expiration before waiting for an
  upstream on-chain claim to confirm. Previously, a node would delay failing the
  HTLC backwards by an additional three blocks to give the claim time to
  confirm. However, this delay ran the risk of forcibly closing its channel. In
  addition, the `historical_inbound_htlc_fulfills` field is removed to clean up
  the channel state, and a new `SentHTLCId` is introduced to eliminate confusion
  from duplicate HTLC IDs on inbound channels. {% assign timestamp="2:40:31" %}

- [LND #9456][] adds deprecation warnings to the `SendToRoute`,
  `SendToRouteSync`, `SendPayment`, and `SendPaymentSync` endpoints in
  preparation for their removal in the release after next (0.21). Users are
  encouraged to migrate to the new v2 methods `SendToRouteV2`, `SendPaymentV2`,
  `TrackPaymentV2`. {% assign timestamp="2:41:10" %}

{% include snippets/recap-ad.md when="2025-02-11 15:30" %}

## Footnotes

[^2kmultisig]:
    In P2SH and the proposed input sigop counting, an `OP_CHECKMULTISIG`
    with more than 16 public keys is counted as 20 sigops, so someone
    using `OP_CHECKMULTISIG` 125 times with 17 keys each time will be
    counted as 2,500 sigops.

{% include references.md %}
{% include linkers/issues.md v=2 issues="21590,2983,2968,3556,9456,26348" %}
[dryja pp]: https://docs.google.com/presentation/d/1G4xchDGcO37DJ2lPC_XYyZIUkJc2khnLrCaZXgvDN0U/mobilepresent?pli=1#slide=id.g85f425098_0_219
[morehouse forceclose]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news339 ldkvuln]: /en/newsletters/2025/01/31/#vulnerability-in-ldk-claim-processing
[halseth zkgoss]: https://delvingbitcoin.org/t/zk-gossip-for-lightning-channel-announcements/1407
[news321 zkgoss]: /en/newsletters/2024/09/20/#proving-utxo-set-inclusion-in-zero-knowledge
[richter cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/9
[mincut impl]: https://github.com/jonas-sauer/MonotoneParametricMinCut
[wuille cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/10
[linear programming]: https://en.wikipedia.org/wiki/Linear_programming
[wuille sp cl]: https://delvingbitcoin.org/t/spanning-forest-cluster-linearization/1419
[richter deepseek]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/15
[delgado erlay]: https://delvingbitcoin.org/t/erlay-overview-and-current-approach/1415
[sd1]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[sd2]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[sd3]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[teinturier ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412
[sanders ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/2
[harding ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/4
[riard ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/3
[news339 pincycle]: /en/newsletters/2025/01/31/#replacement-cycling-attacks-with-miner-exploitation
[kurbatov rand]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[tonoski minrelay]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMHHROxVo_7ZRFy+nq_2YzyeYNO1ijR_r7d89bmBWv4f4wb9=g@mail.gmail.com/
[news324 largeinv]: /en/newsletters/2024/10/11/#dos-from-large-inventory-sets
[news212 relay]: /en/newsletters/2022/08/10/#lowering-the-default-minimum-transaction-relay-feerate
[ap1]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/64
[ap2]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/66
[mcelrath braidcov]: https://delvingbitcoin.org/t/challenge-covenants-for-braidpool/1370/1
[news332 cleanup]: /en/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
[harding duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/26
[corallo duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/25
[ap3]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/65
[mcelrath dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/
[towns dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/7
[bp pow]: https://github.com/braidpool/braidpool/blob/6bc7785c7ee61ea1379ae971ecf8ebca1f976332/docs/braid_consensus.md#difficulty-adjustment
[miller stale]: https://bitcointalk.org/index.php?topic=98314.msg1075701#msg1075701
[mcelrath daa-latency]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/12
[zawy prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/9
[mcelrath prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/8
[zawy sim]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/10
[zawy daadag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331
[wuille prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/6
[provoost dag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/13
[ccbip]: https://github.com/TheBlueMatt/bips/blob/7f9670b643b7c943a0cc6d2197d3eabe661050c2/bip-XXXX.mediawiki#specification
[news36 cc]: /en/newsletters/2019/03/05/#prevent-use-of-op-codeseparator-and-findanddelete-in-legacy-transactions
[news335 cc]: /en/newsletters/2025/01/03/#consensus-cleanup-timewarp-grace-period
[wuille erlang]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/28?u=harding
[erlang]: https://en.wikipedia.org/wiki/Erlang_distribution
[sd4]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[news136 gcd]: /en/newsletters/2021/02/17/#faster-signature-operations
[news337 bdk]: /en/newsletters/2025/01/17/#bdk-1789
[news339 bdk-cpf]: /en/newsletters/2025/01/31/#bdk-1614
[bdk wallet 1.1.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.1.0
[lnd v0.18.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta.rc1
[ap4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/jiyMlvTX8BnG71f75SqChQZxyhZDQ65kldcugeIDJVJsvK4hadCO3GT46xFc7_cUlWdmOCG0B_WIz0HAO5ZugqYTuX5qxnNLRBn3MopuATI=@protonmail.com/
[modularinversion]: https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
[news131 muhash]: /en/newsletters/2021/01/13/#bitcoin-core-19055
[news62 whitelist]: /en/newsletters/2019/09/04/#eclair-954
[news337 splicing]: /en/newsletters/2025/01/17/#eclair-2936
