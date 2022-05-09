---
title: 'Bitcoin Optech Newsletter #199'
permalink: /en/newsletters/2022/05/11/
name: 2022-05-11-newsletter
slug: 2022-05-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's short newsletter summarizes a Bitcoin Core PR Review Club meeting
and describes an update to Rust Bitcoin.

## News

No significant news this week.  Topics we've previously covered,
including [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] and
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout], did receive many
additional comments---but much of the conversation was either
non-technical or about minor details that we don't consider broadly
relevant.  Several interesting posts to the developer mailing lists were
received while this issue of the newsletter was being edited; we will
cover them in detail next week.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Improve Indices on pruned nodes via prune blockers][review club pr] is a PR by Fabian Jahr to
introduce a new method for deciding when it is safe to prune a block from block storage. This new
method enables pruning nodes to maintain a Coinstats index and removes the validation module's
dependency on index-related code.

{% include functions/details-list.md

  q0="What indexes currently exist in Bitcoin Core, and what do they do?"
  a0="A node may maintain up to three optional indexes to help efficiently retrieve data from disk.
The transaction index (`-txindex`) maps transaction hashes to the block in which transaction can be
found. The block filter index (`-blockfilterindex`) indexes BIP157 block filters for each block.
The coin stats index (`-coinstatsindex`) stores statistics on the UTXO set."
  a0link="https://bitcoincore.reviews/21726#l-28"

  q1="What is a circular dependency? Why do we want to avoid them when possible?"
  a1="A circular dependency between two code modules exists when both cannot be used without the
other. While circular dependencies are not a security issue, they signify poor code organization
and encumber development by making it more difficult to build, use, and test specific modules or
functionality in isolation."
  a1link="https://bitcoincore.reviews/21726#l-44"

  q2="How do the prune blockers introduced in [this commit][review club commit] work?"
  a2="The PR introduces a list of 'prune locks', the height of the earliest block that must be kept
for each index. In `CChainState::FlushStateToDisk`, when the node decides which blocks to prune, it
avoids pruning blocks higher than those heights. Each time an index updates its view of the best
block index, the prune locks are also updated."
  a2link="https://bitcoincore.reviews/21726#l-68"

  q3="What are the benefits and costs of this approach to pruning compared to the old one?"
  a3="Previously, the logic in `CChainState::FlushStateToDisk` would query the indexes for their
best height in order to learn which block to stop pruning at; the indexes and validation logic
depended on one another. Now, the prune locks are calculated proactively, and thus may be
calculated more often, but no longer require validation to query the indexes."
%}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Rust Bitcoin #716][] Added `amount::Display`, a configurable Display
  type for denominations or other user-facing amounts. This patch reduces
  all representations of numbers to the minimum width by default, thereby
  reducing the use of superfluous zeros that caused [BIP21][] URIs to be
  needlessly longer, which often made QR codes larger or harder to scan
  than necessary.

{% include references.md %}
{% include linkers/issues.md v=2 issues="716" %}
[review club commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/527ef4463b23ab8c80b8502cd833d64245c5cfc4
[review club pr]: https://bitcoincore.reviews/21726
