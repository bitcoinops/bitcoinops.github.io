---
title: 'Bitcoin Optech Newsletter #340'
permalink: /en/newsletters/2025/02/07/
name: 2025-02-07-newsletter
slug: 2025-02-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

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
  how future bugs from the same underlying cause could be avoided.

- **Zero-knowledge gossip for LN channel announcements:** Johan Halseth
  [posted][halseth zkgoss] to Delving Bitcoin with an extension to the
  proposed 1.75 [channel announcement][topic channel announcements]
  protocol that would allow other nodes to verify that a channel was
  backed by a funding transaction, preventing multiple cheap DoS
  attacks, but without revealing exactly which UTXO is the funding
  transaction to enhance privacy.  Halseth's extension builds on his
  previous research (see [Newsletter #321][news321 zkgoss]) that uses
  [utreexo][topic utreexo] and a zero-knowledge (ZK) proof system.  It
  would be applied to [MuSig2][topic musig]-based [simple taproot
  channels][topic simple taproot channels].

  The discussion focused on the tradeoffs between Halseth's idea,
  continuing to use non-private gossip, and alternative methods for
  generating the ZK proof.  Concerns included ensuring that
  all LN nodes can quickly verify proofs and the complexity of the proof
  and verification system since all LN nodes will need to include an
  implementation of it.

  Discussion was ongoing at the time this summary was written.  <!-- FIXME:harding to review discussion again on Thursday -->

- **Discovery of previous research for finding optimal cluster linearization:**
  Stefan Richter [posted][richter cluster] to Delving Bitcoin about a
  research paper from 1989 he found that has an proven algorithm which
  can be used to efficiently find the highest-feerate subset of a group
  of transactions which remains topologically valid for inclusion in a
  block.  He also found an [C++ implementation][mincut impl] of several
  algorithms for similar problems that "are supposed to be even faster
  in practice".

  Previous work on [cluster mempool][topic cluster mempool] focused on
  making it easy and fast to compare different linearizations, so that
  the best one could be used.  This would allow using a fast algorithm
  to immediately linearize a cluster, with a slower but more optimal
  algorithm able to run on spare CPU cycles.  However, if the 1989
  algorithm for the _maximum-ratio closure problem_, or another
  algorithm for that problem, is able to run fast enough, it could be
  used instead all of the time.  But, even if it was moderately slow, it
  could still be used as the algorithm that runs an spare CPU cycles.

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
  for the problem domain were being explored.  Richter wrote, "It
  appears that our problem, or rather, its generalized solution which is
  called _source-sink-monotone parametric min-cut_ has applications in
  something called polygon aggregation for map simplification and other
  topics in computer vision."

- **Erlay update:** Sergi Delgado made several posts to Delving Bitcoin
  about his work over the past year implementing [Erlay][topic erlay]
  for Bitcoin Core.  He starts with an [overview][delgado erlay] of how
  existing transaction relay (called _fanout_) works and how erlay
  proposes to change that.  He notes that some amount of fanout is
  expected to remain even in a network where every node supports Erlay,
  as "fanout is more efficient and considerably faster than set
  reconciliation, provide the receiving node does not know about the
  transaction being announced."

  Using a mix of fanout and Erlay reconciliation requires choosing when
  to use each method and which peers to use them with, so his research
  has focused on making the optimal choices:

  - [Filtering based on transaction knowledge][sd1] examines whether a
    node should include a peer in its plans to fanout a transaction even
    if it knows that peer already has the transaction.  For example, our
    node has ten peers; three of those peers have already announced a
    transaction to us.  If we want randomly select three peers to
    further fanout that transaction, should we select from all ten peers
    or just the seven peers that haven't announced the transaction to
    us?  Surprisingly, simulation results show that "there is no
    significant difference between [the options]".  Delgado explores
    this surprising result and concludes that all peers should be
    considered (i.e., no filtering should be done).

  - [When to select fanout candidate peers][sd2] examines when a node
    should choose which peers will receive a fanout transaction (with the
    remainder using Erlay reconciliation).  Two options are considered:
    when the node processes the transaction and queues it for relay, and
    when it's time to be relayed (nodes wait a small random amount of
    time to relay transactions to make it harder to probe the network
    topology and guess which node originated a transaction, which would
    be bad for privacy).  Again, simulation results show that "there are
    no meaningful differences", although the "results may vary [...] in
    networks with partial [Erlay] support".

  - [How many peers should receive a fanout?][sd3] examines the fanout
    rate.  A higher rate accelerates transaction propagation but reduces
    bandwidth savings.  Besides testing the fanout rate, Delgado also
    tested increasing the number of outbound peers, as that's one of the
    goals of adopting Erlay.  The simulation shows the current Erlay
    approach reduced bandwidth by approximately 35% using current outbound
    peer limits (8 peers), and 45% using 12 outbound peers.  However,
    the transaction latency is increased by about 240%.  Many other
    tradeoffs are graphed in the posted.  In addition to the results
    being useful for choosing current parameters, Delgado notes that
    they'll be useful for evaluating alternative fanout algorithms that
    might be able to make better tradeoffs.

- **Tradeoffs in LN ephemeral anchor scripts:** Bastien Teinturier
  [posted][teinturier ephanc] to Delving Bitcoin to ask for opinions
  about what [ephemeral anchor][topic ephemeral anchors] script should
  be used as one of the outputs to [TRUC][topic v3 transaction
  relay]-based LN commitment transactions as a replacement for existing
  [anchor outputs][topic anchor outputs].  The script used determines
  who can [CPFP fee bump][topic cpfp] the commitment transaction (and
  under what conditions they can bump).  He presented four options:

  - _Use a pay-to-anchor (P2A) script:_ this has a minimal onchain size
    but means that all [trimmed HTLC][topic trimmed htlc] value will
    probably go to miners (like it presently does).

  - _Use a single-participant keyed anchor:_ this may allow some excess
    trimmed HTLC value to be claimed by a participant who voluntarily
    accepts waiting a few dozens blocks before being able to spend the
    money they close out of a channel.  Anyone who wants to force close
    a channel would need to wait that time anyway.  However, neither
    party to the channel can delegate paying the fee to a third-party
    without allowing that party to steal all of the channel funds.
    If both you and your counterparty compete to claim the excess value,
    it's likely that it will all go to miners anyway.

  - _Use a shared key anchor:_ this also allows recovery of excess
    trimmed HTLC value and allows delegation, but anyone who receives
    the delegation can compete with you and your counterparty to claim
    the excess value.  Again, in the case of competition, all excess
    value is likely to go to miners.

  - _Use a dual-keyed anchor:_ allows each participant to claim excess
    trimmed HTLC value without having to wait additional blocks before
    being able to spend.  However, it does not allow delegation.  The
    two parties to a channel can still compete with each other.

  In replies to the post, Gregory Sanders [noted][sanders ephanc] that
  the different schemes could be used at different times.  For example,
  P2A could be used when there were no trimmed HTLCs and one of the
  keyed anchors could be used other times.  He also suggested that
  trimmed value above the [dust threshold][topic uneconomical outputs]
  could instead be added to the LN commitment transaction.
  Additionally, we warned that it could create "new weirdness [a]
  counterparty may be tempted to ramp up the trimmed amount and take it
  themselves."  David Harding extended on this theme in a [later
  post][harding ephanc].

  Antoine Riard [warned][riard ephanc] against using P2A due to the risk
  of encouraging miner [transaction pinning][topic transaction pinning]
  (see [Newsletter #339][news339 pincycle]).

  Discussion was ongoing at the time of writing.

- **Emulating OP_RAND:** Oleksandr Kurbatov [posted][kurbatov rand] to
  Delving Bitcoin about an interactive protocol that allows two parties
  to make a contract that will pay out in a way neither of them can
  predict, in other words: "randomly".  [Previous work][dryja pp] on
  _probabilistic payments_ in Bitcoin has used advanced scripts, but
  Kurbatov's approach entirely uses specially constructed public keys
  that allow the winner to spend the contracted funds.  This is more
  private and may allow greater flexibility.

  Optech wasn't able to analyze the protocol, but we didn't spot any
  obvious problems.   We hope to see additional discussion of the
  idea---probabilistic payments have multiple applications, including
  allowing users to send amounts onchain that would otherwise be
  [uneconomical][topic uneconomical outputs], such as for [trimmed
  HTLCs][topic trimmed htlc].

- **Discussion about lowering the minimum transaction relay feerate:**
  Greg Tonoski [posted][tonoski minrelay] to the Bitcoin-Dev mailing
  list about lowering the [default minimum transaction relay
  feerate][topic default minimum transaction relay feerates], a topic
  that has been discussed repeatedly (and summarized by Optech) since
  2018---most recently in 2022 (see [Newsletter #212][news212 relay]).
  Of note, a recently disclosed vulnerability (see [Newsletter
  #324][news324 largeinv]) did reveal a potential problem that could
  have affected users and miners who lowered the setting in the past.
  Optech will provide updates if new significant discussion occurs.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

FIXME:harding to add Wednesday

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:harding to update or remove on Thursday

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #21590][] Safegcd-based modular inverses in MuHash3072

- [Eclair #2983][] Only sync with top peers

- [Eclair #2968][] Send `channel_announcement` for splice transactions on public channels

- [LDK #3556][] Fail HTLC backwards before upstream claims on-chain

- [LND #9456][] lnrpc+docs: deprecate warning `SendToRoute`, `SendToRouteSync`, `SendPayment`, and `SendPaymentSync` in Release 0.19

{% include snippets/recap-ad.md when="2025-02-11 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="21590,2983,2968,3556,9456" %}
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
