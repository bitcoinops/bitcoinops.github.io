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

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Transaction pinning
    link: topic transaction pinning

  - title: Anchor outputs
    link: topic anchor outputs

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Version 3 transaction relay** is a proposal to allow transactions to
  opt-in to a modified set of transaction relay policies designed to prevent
  pinning attacks. Combined with package relay, these policies help enable
  the use of dynamic feerates with LN onchain transactions.

---
{% include references.md %}
{% include linkers/issues.md issues="" %}
