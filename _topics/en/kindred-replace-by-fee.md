---
title: Kindred replace by fee

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: kindred rbf

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Sibling eviction

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Fee Management
  - Transaction Relay Policy

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Sibling Eviction for v3 transactions
      link: https://delvingbitcoin.org/t/sibling-eviction-for-v3-transactions/472

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Kindred replace by fee
    url: /en/newsletters/2024/01/31/#kindred-replace-by-fee

  - title: "What if v3 semantics and sibling replacement had been applied to anchor outputs a year ago?"
    url: /en/newsletters/2024/02/14/#what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago

  - title: "Bitcoin Core #29306 adds sibling eviction for unconfirmed v3 transaction children"
    url: /en/newsletters/2024/03/20/#bitcoin-core-29306

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
  **Kindred replace by fee** is the ability for a transaction to replace
  a related transaction in the mempool even if there’s no conflict
  between the two transactions.  The main form of it is **sibling
  eviction**, where one child of an unconfirmed transaction can replace
  a different child.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
