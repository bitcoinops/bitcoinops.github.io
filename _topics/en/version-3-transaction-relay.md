---
title: Version 3 transaction relay

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: v3 transaction relay

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Transaction Relay Policy

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Version 3 transaction relay** is a proposal to allow transactions
  to opt-in to a modified set of transaction relay policies designed to
  prevent pinning attacks. Combined with package relay, these policies help enable
  the use of dynamic feerates with LN onchain transactions.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "New transaction policies (nVersion=3) for contracting protocols"
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020937.html

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposed new transaction relay policies designed for LN-penalty
    url: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty

  - title: Ephemeral anchors proposal built on v3 transaction relay proposal
    url: /en/newsletters/2022/10/26/#ephemeral-anchors

  - title: Comparing disabling non-replaceable transactions to disabling special v3 transaction relay rules
    url: /en/newsletters/2022/11/09/#determining-incentive-compatibility-isn-t-always-straightforward

  - title: Ephemeral anchors implementation as proposed extension to v3 transaction relay policy
    url: /en/newsletters/2022/12/07/#ephemeral-anchors-implementation

  - title: "2022 year-in-review: v3 transaction relay"
    url: /en/newsletters/2022/12/21/#v3-tx-relay

  - title: Preventing coinjoin pinning with v3 transaction relay
    url: /en/newsletters/2023/06/28/#preventing-coinjoin-pinning-with-v3-transaction-relay

  - title: "LN developer discussion about multiple relay policy topics, including v3 transaction relay"
    url: /en/newsletters/2023/07/26/#reliable-transaction-confirmation

  - title: "Replacement cycle attacks not solved by current v3 transaction relay policies"
    url: /en/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Transaction pinning
    link: topic transaction pinning

  - title: Ephemeral anchors
    link: topic ephemeral anchors
---
V3 transaction relay is a superset of standard transaction policy.
That is, v3 transactions follow all rules for standard transactions
(e.g. minimum and maximum transaction weights) while also adding some
additional rules designed to allow [transaction replacement][topic rbf]
while precluding transaction-pinning attacks. v3 transactions also
require minor changes to the [package RBF][topic package relay] policy in order to maintain
incentive compatibility with miners.

V3 transaction relay solves rule 3 [transaction pinning][topic transaction pinning]
and may allow the removal of the [CPFP carve-out][topic cpfp carve out].

Version 3 transactions are used by [ephemeral anchors][topic ephemeral anchors].

{% include references.md %}
{% include linkers/issues.md issues="" %}
