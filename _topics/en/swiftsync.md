---
title: SwiftSync

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: swiftsync

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Consensus Enforcement
  - P2P Network Protocol

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "SwiftSync - smarter synchronization with hints"
      link: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd

    - title: "SwiftSync -- Speeding up IBD with pre-generated hints (PoC)"
      link: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Proposal and proof-of-concept implementation of SwiftSync showing a 5x IBD speedup"
    url: /en/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download

  - title: "PR Review Club: decoupling Bitcoin Core validation from the UTXO set for SwiftSync-style nodes"
    url: /en/newsletters/2025/06/13/#bitcoin-core-pr-review-club

  - title: "2025 year-in-review: SwiftSync speedup for initial block download"
    url: /en/newsletters/2025/12/19/#swiftsync

  - title: "Utreexod 0.5 introduces SwiftSync-based IBD"
    url: /en/newsletters/2026/04/17/#utreexod-0-5-released

  - title: "Bitcoin Core developer meeting transcript about SwiftSync"
    url: /en/newsletters/2026/05/29/#bitcoin-core-developer-meeting-transcripts

  - title: "Proposal to use the SwiftSync hints file to speed up Utreexo IBD"
    url: /en/newsletters/2026/09/18/#improvements-in-utreexo-initial-block-download

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
  **SwiftSync** is a proposed method for speeding up initial block
  download (IBD) using an untrusted _hints file_ that indicates, for each
  output created during the sync, whether it is still unspent at the
  target block. Spent outputs are not stored in the UTXO set but are
  added to a hash aggregate from which each spent outpoint is later
  subtracted. An aggregate of zero at the end of the sync proves the
  hints were correct, allowing blocks to be validated in parallel with
  near-zero memory usage.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
