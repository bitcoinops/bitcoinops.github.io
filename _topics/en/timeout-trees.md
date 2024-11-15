---
title: Timeout trees

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Proposal for a managed joinpool protocol (Ark)"
    url: /en/newsletters/2023/05/31/#proposal-for-a-managed-joinpool-protocol

  - title: Using covenants to improve LN scalability via timeout trees
    url: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability

  - title: "Superscalar: timeout tree channel factories"
    url: /en/newsletters/2024/11/01/#timeout-tree-channel-factories

  - title: "OPR protocol proposed to improve timeout tree efficiency"
    url: /en/newsletters/2024/11/15/#mad-based-offchain-payment-resolution-opr-protocol

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Timeout trees** are a type of trustless contract protocol that
  produces a tree of offchain transactions that only remain safe against
  counterparty theft for a limited period of time (i.e., they time out).

---
Typically, the single transaction at the root of the tree (the funding
transaction) is the only transaction that must be put onchain.  The
leaves of the tree (and any intermediate branches between the root and
the leaves) can be kept offchain as long as all of the involved parties
remain cooperative with each other.  However, in the case of a dispute,
trustlessness is preserved by allowing the relevant parts of the tree to
be placed onchain for settlement.

Ideally, as the timeout approaches, all parties agree to an offchain transfer
of their funds from the leaves of the tree to the counterparty who will
be able to claim those funds at the timeout.  If every party does this,
they can claim all funds at the timeout in a single transaction that
spends from the funding transaction, allowing all leaves and branches of
the tree to be forgotten (never published onchain).  Similar to [channel
factories][topic channel factories] and [joinpools][topic joinpools],
this can allow large numbers of users to share a UTXO and split the
costs of creating and spending it.

The main advantage of timeout trees over previous UTXO sharing schemes
is its small onchain footprint even in the case of nonresponsiveness.
For example, in a channel factory with ten users, even one of those
users being offline or having lost critical data prevents the root state
from being updated any further, requiring all parts of the tree of
transactions that created the current state to be put onchain.  In a
timeout tree, the offline user (or user with data loss) risks having
their funds taken by a counterparty but does not force any additional
data to be published onchain.

Note that, even when a counterparty can take the funds of a
nonresponsive user, the counterparty may choose to return those funds to
that user.  Although no user can depend on this charity, it may be the
common state of affairs for timeout trees run by established business
that profit from repeat customers.

Timeout trees can be created on Bitcoin today with no consensus changes
required, although there are advantages in block space efficiency and
reduced cooperative steps if a [covenant][topic covenants] mechanism is
added to consensus.

Optech first became aware of the concept now called _timeout trees_ with
the publication of the original [Ark][topic ark] protocol.  The idea has
seen notable development since then in the context of other protocols.

{% include references.md %}
{% include linkers/issues.md issues="" %}
