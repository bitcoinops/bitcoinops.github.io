---
title: Version 3 transaction relay

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: v3 transaction relay

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - "Topologically Restricted Until Confirmation (TRUC)"

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
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
    - title: "BIP431: Topology Restrictions for Pinning"
      link: https://github.com/bitcoin/bips/blob/master/bip-0431.mediawiki

    - title: "New transaction policies (nVersion=3) for contracting protocols"
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020937.html

    - title: Original implementation
      link: https://github.com/bitcoin/bitcoin/issues/28948

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

  - title: Discussion about the costs of pinning when v3 policies are used
    url: /en/newsletters/2024/01/03/#v3-transaction-pinning-costs

  - title: Discussion about LN anchors and v3 transaction relay proposal
    url: /en/newsletters/2024/01/10/#discussion-about-ln-anchors-and-v3-transaction-relay-proposal

  - title: Discussion about cluster mempool and a need for a CPFP carve out replacement like v3 relay
    url: /en/newsletters/2024/01/17/#cpfp-carve-out-needs-to-be-removed

  - title: Proposed changes to LN for v3 relay and ephemeral anchors
    url: /en/newsletters/2024/01/24/#proposed-changes-to-ln-for-v3-relay-and-ephemeral-anchors

  - title: "Idea to apply RBF rules to v3 transactions to allow removing CPFP carve-out for cluster mempool"
    url: /en/newsletters/2024/01/31/#kindred-replace-by-fee

  - title: "Challenges opening zero-conf channels when using the initially allowed v3 transaction topology"
    url: /en/newsletters/2024/02/07/#securely-opening-zero-conf-channels-with-v3-transactions

  - title: "Ideas for post-v3 relay enhancements after cluster mempool is deployed"
    url: /en/newsletters/2024/02/14/#ideas-for-relay-enhancements-after-cluster-mempool-is-deployed

  - title: "Research about historic use of anchor outputs for possibly imbuing them with v3 properties"
    url: /en/newsletters/2024/02/14/#what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago

  - title: "Bitcoin Core #28948 adds support for (but does not enable) version 3 transaction relay"
    url: /en/newsletters/2024/02/14/#bitcoin-core-28948

  - title: "Bitcoin Core #29242 lays the groundwork for package replace by fee with v3-compatible packages"
    url: /en/newsletters/2024/04/03/#bitcoin-core-29242

  - title: "BIPs #1541 adds BIP431 with a specification of TRUC transactions"
    url: /en/newsletters/2024/06/07/#bips-1541

  - title: "Bitcoin Core #29496 makes TRUC transactions standard"
    url: /en/newsletters/2024/06/14/#bitcoin-core-29496

  - title: "Criticism of motivations for preferring TRUC over replace-by-feerate as a pinning solution"
    url: /en/newsletters/2024/07/26/#truc-utility

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
