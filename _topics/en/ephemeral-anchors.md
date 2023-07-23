---
title: Ephemeral anchors

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Fee Management
  - P2P Network Protocol

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Ephemeral Anchors
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021036.html

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposed additional rules for v3 transaction relay to assist CPFP fee bumping
    url: /en/newsletters/2022/10/05/#ephemeral-dust

  - title: Ephemeral anchors
    url: /en/newsletters/2022/10/26/#ephemeral-anchors
    feature: true

  - title: Ephemeral anchors implementation
    url: /en/newsletters/2022/12/07/#ephemeral-anchors-implementation

  - title: "Ephemeral anchors compared to `SIGHASH_GROUP`"
    url: /en/newsletters/2023/01/25/#ephemeral-anchors-compared-to-sighash-group

  - title: "Bitcoin Inquisition #23 adds part of the support for ephemeral anchors"
    url: /en/newsletters/2023/04/26/#bitcoin-inquisition-23

  - title: "LN developer discussion about multiple relay policy topics, including ephemeral anchors"
    url: /en/newsletters/2023/07/26/#reliable-transaction-confirmation

## Optional.  Same format as "primary_sources" above
see_also:
  - title: V3 Transaction Relay
    link: topic v3 transaction relay

  - title: Anchor outputs
    link: topic anchor outputs

  - title: Package relay
    link: topic package relay

  - title: Fee sponsorship
    link: topic fee sponsorship

  - title: CPFP carve out
    link: topic cpfp carve out

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Ephemeral anchors** are a proposal to allow some transactions to be
  relayed even if they don't pay any transaction fee, provided they're
  relayed as part of a package containing a child transaction which pays
  a fee sufficient for the entire package.

---
The proposal is built on top of the [v3 transaction relay][topic v3
transaction relay] proposal.  A v3 transaction containing as little as
zero fee that has a zero-value output paying `OP_TRUE` as the entire script
would be accepted when included in a [relay package][topic package
relay] with a fee-paying child.

This allows anyone on the network to use
that output as the input to a child transaction.  This allows anyone to
create the fee-paying child, even if they don't receive any of the other
outputs from the parent transaction.  This allows ephemeral anchors to
function as [fee sponsorship][topic fee sponsorship] but without
requiring any consensus changes.

Ephemeral anchors is envisioned to be used with contract protocols such
as LN where transactions are signed by the contract participants a long
time before they are broadcast, preventing the participants from
determining an appropriate feerate to use.  Instead, any participant (or
several acting together) can use the ephemeral anchor output as the
input to a child transaction which adds fees at the time the transaction
is broadcast.  This is similar to the [anchor outputs][topic anchor
outputs] added to LN in 2021-22, based on the [CPFP carve out][topic
cpfp carve out] relay rule.

{% include references.md %}
{% include linkers/issues.md issues="" %}
