---
title: V3 commitments

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Zero-fee commitments

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: Zero-fee commitments using v3 transactions
    link: https://github.com/lightning/bolts/pull/1228

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposed new transaction relay policies designed for LN-penalty
    url: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty

  - title: Proposed changes to LN for v3 relay and ephemeral anchors
    url: /en/newsletters/2024/01/24/#proposed-changes-to-ln-for-v3-relay-and-ephemeral-anchors

  - title: LN developer discussion of using TRUC for version-3 LN commitments
    url: /en/newsletters/2024/10/18/#version-3-commitment-transactions

  - title: Using v3 commitments to allow mobile wallets to settle channels without extra UTXOs
    url: /en/newsletters/2025/02/21/#allowing-mobile-wallets-to-settle-channels-without-extra-utxos

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Channel commitment upgrades
    link: topic channel commitment upgrades

  - title: Anchor outputs (v2 commitments)
    link: topic anchor outputs

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **V3 commitments** are LN commitment transactions made using version 3
  transactions adhering to the policies for TRUC, a P2A outputs,
  ephemeral dust, and sibling replacement.  This allows it to be a
  **zero-fee commitment**, as the onchain fee will be paid by a CPFP spend
  of the ephemeral P2A output.  The commitment transaction and its
  fee-paying child will be transmitted by package relay.

---
LN _commitment transactions_ commit to the current state of the channel,
including each party's settled balance plus any pending [HTLCs][topic
htlc] that conditionally transfer funds between them.  Commitment
transactions usually aren't published, allowing for offchain balance
updates, but each transaction must be confirmable onchain in case one
party needs to close the channel without the cooperation of the other
party.  For a transaction to be confirmable, it must be both valid and
incentivize miners to include it in a block---which is usually done by
having it pay a transaction fee.

The original [LN-Penalty][topic ln-penalty] commitment transaction
format used entirely [endogenous fees][topic fee sourcing], with the
full fee amount being implicitly allocated in the transaction itself
using normal Bitcoin transaction semantics.  This had the advantage of
being simple and compact, but it was fragile if market pricing for
feerates suddenly spiked---a previously signed valid commitment
transaction might no longer be confirmable in a reasonable amount of
time, which can lead to loss of money.

An updated commitment format called [anchor outputs][topic anchor
outputs] or _anchor commitments_ added two additional outputs to the
commitment transaction to allow either party to [CPFP][topic cpfp] fee
bump it if necessary.  This allowed reducing the commitment transaction
fee to the [minimum necessary][topic default minimum transaction relay
feerates] to get it to relay.  Although this was a
major improvement, it was still fragile if the minimum relay feerate
increased.  Additionally, it depended on [CPFP carve-out][topic cpfp
carve out] policy, which is vulnerable to [transaction pinning
attacks][topic transaction pinning] and may be removed to allow
deployment of [cluster mempool][topic cluster mempool].

Since the initial proposals in 2018 for anchor commitments, Bitcoin Core
transaction relay policy and tools have seen significant advances.  V3
commitments build on those improvements:

- [TRUC][topic v3 transaction relay] (v3) transactions significantly
  reduce the worst-case pinning vulnerabilities.  Additionally, CPFP
  carve-out required that only the two outputs designed for fee bumping
  be immediately spendable, forcing all other outputs (such as HTLCs) to
  include a 1-block relative locktime (commonly called "`1 OP_CSV`").
  This prevented using any of the value in those outputs to pay
  transaction fees.

- [Package relay][topic package relay] allows the commitment transaction
  to pay zero fee.  This eliminates the fragility of increases in
  feerates (or minimum relay feerates) making a previously signed
  commitment transaction non-confirmable.  It also allows removing the
  `update_fee` mechanism from the LN protocol, which was a source of
  multiple problems, from [stuck channels][cln stuckchan] to [security
  vulnerabilities][irrevfees].

- [P2A][topic ephemeral anchors] allows the output intended for fee
  bumping to be spendable by either party.  Additionally, P2A uses only
  a small amount of onchain space.  [Sibling RBF][topic kindred rbf]
  allows either party to increase the fee bump even if the other party
  created the initial fee bump.

- [Ephemeral dust][topic ephemeral anchors] allows the P2A output to have a
  zero value even though it would otherwise be [uneconomic][topic
  uneconomical outputs].  This is allowed under the assumption that
  spending a small P2A output is the most efficient way to add fees to
  the zero-fee commitment transaction using public transaction relay.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[cln stuckchan]: /en/newsletters/2020/02/19/#c-lightning-3500
[irrevfees]: /en/newsletters/2024/12/13/#vulnerability-allowing-theft-from-ln-channels-with-miner-assistance
