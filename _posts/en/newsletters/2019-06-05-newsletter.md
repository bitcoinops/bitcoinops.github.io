---
title: 'Bitcoin Optech Newsletter #49'
permalink: /en/newsletters/2019/06/05/
name: 2019-06-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the proposed Erlay protocol that could
significantly reduce the overhead of relaying unconfirmed transactions between
nodes, summarizes an executive briefing by Bitrefill CEO Sergej Kotliar about
LN, and lists some recent changes to the COSHV proposal described last week.
Also included are our regular sections on bech32 sending support and notable
code changes in popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*None this week.*

## News

- **Erlay proposed:** a new paper by Gleb Naumenko, Pieter Wuille, Gregory
  Maxwell, Sasha Fedorova, and Ivan Beschastnikh describes an alternative
transaction relay protocol, [Erlay][].  Currently, when a node learns about a
new transaction that passes its relay policy, it announces the txid of that
transaction to all of its peers (except any peers that announced it
previously).  This is a very simple and effective policy, but it's not
efficient---most of the announcements a node receives are announcements for
transactions it has already learned about from a different peer a few moments
before, a redundancy that wastes about 44% of all node bandwidth according to
the paper.

    The paper attempts to reduce that redundancy using the authors' Erlay
protocol which separates relaying into two phases, a fanout phase and a
reconciliation phase.  In the fanout phase, a node will only directly announce
new transactions it has learned about to a maximum of eight peers selected from
the node's outbound peers.

    In the reconciliation phase, a node will periodically request from each of
its outbound peers a *sketch* of short transaction identifiers (short txids)
for all the new transactions that peer would normally announce to the node.
Sketches are created using the [libminisketch][] library described in
[Newsletter #26][] which implements a highly bandwidth efficient set
reconciliation technique based on error correction codes.  Upon receipt of a
requested sketch, the node itself also generates a sketch of all the new
transactions that it would normally announced to its peer.  The node
combines its sketch with the peer's sketch to produce a list of any differences
between the sketches.  That diff contains the short txids of any transactions
that are in one set of new transactions but not the other.  The node can then
request any transactions it doesn't have from that peer and proceed to querying
its next peer for that peer's sketch.  This is repeated for a new peer once
each second, allowing the node to quickly receive any transactions it didn't
receive via a fanout announcement.  This simple two-step protocol of fanout and
reconciliation describes the primary operation of Erlay; the remaining parts of
the protocol described and analyzed in the paper cover the optimal parameters
to use for the sketches and a series of fallback steps to take if a particular
attempt at set reconciliation fails.

    After describing the Erlay protocol, the paper analyzes its performance
using both a simulated network of 60,000 nodes (similar in number and use to
the current Bitcoin network) and a live set of 100 nodes spread internationally
across several datacenters.  The most notable result is that Erlay reduces the
amount of bandwidth used to announce the existence of new transactions by 84%.
<!-- figure 11, 1 - 0.7 / 4.33 -->  However, it does take about 80% (2.6
seconds) longer for transactions to propagate to all of the nodes in the
network. <!-- page 9 --> It's still the case that Bitcoin transactions can only
be confirmed once every ten minutes on average, so a three second slowdown
seems like a reasonable price to pay for a major reduction in bandwidth.

    Having established that the protocol is a worthwhile efficiency
improvement, the paper considers the most important of its secondary aspects:
its effect on privacy.  Currently, each Bitcoin Core node slightly delays
the relaying of transactions to
its peers; this makes it more difficult for spy nodes to use timing
correlations to guess that the first peer they receive a transaction from is
the peer that created the transaction.  Multiple simulations were run testing
the effectiveness of the current relay protocol against the effectiveness of
Erlay for various amounts of spy nodes among network peers, from 5% spy nodes
to 60% spy nodes.  In cases where the spy nodes were public nodes accepting
incoming connections, Erlay always performed as well or better than the current
protocol.  In cases where the spy nodes were private nodes making connections
to honest nodes, Erlay sometimes performed better and sometimes performed
worse---but never more than 10% worse (and this worst case is an unlikely situation). <!--
tables 2 and 3 -->  The paper also notes that Erlay is compatible with the
proposed [BIP156][] Dandelion protocol for further improving the network's
resistance to spy nodes.

    Considering future possible changes to Bitcoin relay policy, the paper
notes that an increase in the number of outbound peers from 8 to 32 would only
increase the bandwidth used by a node to announce the existence of new
transactions by 32% with Erlay compared to 300% using the current protocol.
<!-- figure 10 --> As described in the paragraph above about Erlay's two
phases, new transactions would still only be fanned out via direct announcements
to 8 peers, but nodes would perform set reconciliation with all 32 peers.
A four-fold improvement in relay connectivity improves the chance that
time-sensitive transactions for contract protocols like LN will make it
to miners quickly.

    In addition to libminisketch, the code changes necessary to implement Erlay
in Bitcoin Core amount to only 584 lines of code, and the CPU intensive part of
set reconciliation has been benchmarked to take less than a millisecond under
conditions that are worse than expected in practice. <!-- page 8: 1
millisecond, figure 13: expected set difference size -->  If no objections are
raised over the paper, Naumenko has announced his intention to write a BIP and
work to get Erlay included in a subsequent version of Bitcoin Core.  The method
used for transaction relay is part of the P2P network protocol (not a consensus
rule), so the change could begin operation as soon as multiple users upgrade to
it, although we expect nodes will also include a backwards-compatible mode to
support peers who haven't upgraded.

- **Presentation: Operating on Lightning:** Bitrefill CEO Sergej Kotliar gave a
  presentation about LN for the Optech executive briefing last month.  The
[video][kotliar ln] is now available.  Kotliar begins by explaining that high
transaction fees during previous years had a significant effect on Bitrefill's
business, so they made a special effort to get really good at minimizing
fee-related expenses.  The ability to receive LN payments supported that goal,
and he believes they were the first service on mainnet to sell real items for
LN payments.  Today, LN payments represent about 5% of their sales, similar to
the amount of business they do using Ethereum.

    He believes it's important for businesses to start working on LN now.  "In
Bitcoin we've gotten used to waiting for things [...] but making customers wait
an unknown amount of time creates a risk that the customer will go away."  For
example, by the time a deposit clears at an exchange, the customer may no
longer be interested in making the trade that would've earned the exchange a
commission.  Additionally, Bitrefill's experience with LN is that LN's improved
invoicing eliminates a number of different payment errors seen with onchain
bitcoin payments, including overpayments, underpayments, stuck transactions,
copy/paste errors, and other problems.  Receiving payments over LN also
eliminates the need to consolidate UTXOs and reduces the need to rotate money
between hot and cold wallets.  Eliminating all of these problems has the potential to significantly reduce customer support and backend expenses.

    In a particularly interesting section of his talk, Kotliar shows how perhaps as
much as 70% of current onchain payments are users moving money
from one exchange to another exchange (or even between different users of the
same exchange).  If all that activity could be moved offchain using LN
payments, exchanges and their users could save a considerable amount of money and everyone in Bitcoin would benefit from the increase in available block space.

    Kotliar concluded his talk with a few short segments.  He described what
software and services Bitrefill sees LN users using today and what he
expects them to be using in the near future.  He then explained two of
Bitrefill's services for LN users (including businesses), [Thor][] and [Thor
Turbo][].  Finally, he briefly described several planned improvements to LN:
reusable addresses (see [Newsletter #30][]), splicing in and out (see
[#22][Newsletter #22]), and larger channels (also [#22][Newsletter
#22]).

    Overall, Kotliar made a compelling case that LN's faster speed, lower fees,
and improved invoicing means businesses that expect to remain competitive
serving Bitcoin customers in the near future should start working on
implementing LN support today.

- **COSHV proposal replaced:** the author of the COSHV proposal we described
  [last week][news48 coshv] has replaced it with a [similar
  proposal][alt-coshv] under a different name.  The new proposal checks more
  than just the hash of a transaction's outputs---now the hash also includes the transaction's
  version number, number of inputs, sequence numbers, and locktime.  This
  change eliminates concerns related to transaction malleability that would've
  affected using the opcode with some types of contract protocols (such as
  LN).  Additionally, by hashing the
  number of inputs allowed in the transaction, the original proposal's
  restriction on just one input is lifted---however, the proposal warns that only
  allowing a single input is still recommended to avoid unwanted interactions.
  (Note: except for the new name, the changes don't affect the summary
  of COSHV we wrote last week.)

## Optech recommends

As of this writing, the Bitcoin Core project currently has [over 300 open Pull
Requests (PRs).][core prs]  Some of these are works in progress, but most of
the rest are waiting for developers to review them and either identify any
problems that need to be fixed or acknowledge that they're ready to be
merged.

If you want to help Bitcoin Core improve by reviewing PRs but aren't
sure how to get started, we recommend you check out the [Bitcoin Core PR
Review Club][].  In a weekly IRC meeting, an experienced Bitcoin Core
contributor provides background information
about a selected PR and then answers live questions from new
contributors.  Often they are assisted by other established Bitcoin Core
contributors, including sometimes the authors of the PRs being
discussed.

Optech recommends attendance to any engineer who wants to get more
involved in the Bitcoin Core process.  IRC meetings are held at 17:00
UTC on Wednesdays.

## Bech32 sending support

*Week 12 of 24 in a [series][bech32 easy] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/12-midway.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #15741][] speeds up importing keys, addresses, and other
  information into the wallet using the `importmulti` RPC by batching the
  database updates rather than making them sequentially.  In a test performed by
  the PR author, this reduced the time to import 10,000 addresses from 465
  seconds to 4 seconds.

- [LND #2985][] waits to relay gossip announcements until there are there are
  at least ten of them to send and five seconds have elapsed since the previous
  batch, reducing bandwidth overhead.  This continues the work done by
  LND and other implementations towards reducing the overhead of the
  gossip protocol given the significant growth in the size of the LN
  network over the past year.

- [LND #2761][] switches to using a persistent state machine for routed
  payments and to storing some additional state data for the machine, improving
  the program's ability to correctly handle HTLCs that were unresolved when the
  daemon was restarted.

{% include linkers/issues.md issues="15741,2985,2761" %}
[bech32 easy]: {{news38}}#bech32-sending-support
[news48 coshv]: {{news48}}#proposed-transaction-output-commitments
[alt-coshv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/016997.html
[kotliar ln]: https://www.youtube.com/watch?v=1UDD9PMFTds
[thor]: https://www.bitrefill.com/thor-lightning-network-channels/?hl=en
[thor turbo]: https://www.bitrefill.com/thor-turbo-channels/?hl=en
[Bitcoin Core PR Review Club]:https://bitcoin-core-review-club.github.io/
[core prs]: https://github.com/bitcoin/bitcoin/pulls
