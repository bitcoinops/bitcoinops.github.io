---
title: Annex

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Scripts and Addresses

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BIP341: Taproot"
      link: bip341

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Bitcoin Inquisition #22 adds an `-annexcarrier` runtime option"
    url: /en/newsletters/2023/03/29/#bitcoin-inquisition-22

  - title: Discussion about the taproot annex
    url: /en/newsletters/2023/06/14/#discussion-about-the-taproot-annex

  - title: Suggestion to store fee-dependent timelock parameters in the taproot annex
    url: /en/newsletters/2024/01/03/#fee-dependent-timelocks

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Taproot
    link: topic taproot

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  The taproot **annex** is an optional field in the witness structure of
  segwit v1 (taproot) inputs that currently has no defined purpose.
  If an annex is present, any taproot and tapscript signatures must
  commit to its value.

---
As of the implementation and activation of taproot, the annex was
reserved for future upgrades.  Transactions containing an annex were not
relayed or mined by default by Bitcoin Core.  There have been several
ideas for using the annex, as well as at least one attempt to define an
extensible data structure for the field.

{% include references.md %}
{% include linkers/issues.md issues="" %}
