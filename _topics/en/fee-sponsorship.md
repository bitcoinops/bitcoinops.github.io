---
title: Fee sponsorship

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Fee Management

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Fee sponsorship
      link: https://gist.github.com/JeremyRubin/92a9fc4c6531817f66c2934282e71fdf

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Transaction fee sponsorship proposal
    url: /en/newsletters/2020/09/23/#transaction-fee-sponsorship

  - title: "Call for topics in layer-crossing workshop, including fee sponsorship"
    url: /en/newsletters/2021/04/28/#call-for-topics-in-layer-crossing-workshop

  - title: "Fee accounts, an outgrowth from fee sponsorship"
    url: /en/newsletters/2022/01/12/#fee-accounts

  - title: Fee bumping discussion with advocacy for fee sponsorship
    url: /en/newsletters/2022/02/23/#fee-bumping-and-transaction-fee-sponsorship

  - title: Proposed ephemeral anchors relay policy to implement sponsorship-like behavior
    url: /en/newsletters/2022/10/26/#ephemeral-anchors

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Child Pays For Parent
    link: topic cpfp

  - title: Transaction pinning
    link: topic transaction pinning

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Fee sponsorship** is a proposed consensus change to allow the creation of
  transactions which effectively add fees to other unrelated
  transactions, possibly helping those other transactions confirm
  faster.  It's enables CPFP-like fee bumping without the transactions needing to
  be related.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
