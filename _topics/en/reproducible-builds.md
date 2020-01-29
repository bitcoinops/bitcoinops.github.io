---
title: Reproducible builds

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Gitian
  - Guix

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Security Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Reproducible builds** are software that was compiled
  deterministically, making it possible for multiple people to compile
  the same source code into identical binaries.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  This means no one person or computer needs to be trusted to produce
  the executable binaries that most people use.  Additionally, people
  who compile the software themselves can ensure that they received an
  executable that's identical to what other people received, helping to
  ensure their software will remain compatible with other software, e.g.
  a full node staying in consensus with the rest of the network.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Bitcoin Core PR #15277: Enable building in Guix containers"
      link: https://github.com/bitcoin/bitcoin/pull/15277

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Notable Bitcoin Core PRs: reproducible builds using GNU Guix"
    url: /en/newsletters/2019/02/19/#bitcoin-core-freeze-week
    date: 2019-02-19

  - title: "Breaking Bitcoin summaries: Bitcoin build system security"
    url: /en/newsletters/2019/06/19/#bitcoin-build-system-security
    date: 2019-06-19

  - title: Merged PR for reproducible build of Bitcoin Core using GNU Guix
    url: /en/newsletters/2019/07/17/#bitcoin-core-15277
    date: 2019-07-17

  - title: New reproducibly-build architecture and Snap packages for Bitcoin Core
    url: /en/newsletters/2019/05/07/#new-architecture-and-new-ubuntu-snap-package
    date: 2019-05-07

  - title: "2019 year-in-review: reproducible builds"
    url: /en/newsletters/2019/12/28/#reproducibility
    date: 2019-12-28

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Presentation: Bitcoin Build System Security"
    link: https://youtu.be/I2iShmUTEl8
---
