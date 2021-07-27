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

  - title: "Breaking Bitcoin summaries: Bitcoin build system security"
    url: /en/newsletters/2019/06/19/#bitcoin-build-system-security

  - title: Merged PR for reproducible build of Bitcoin Core using GNU Guix
    url: /en/newsletters/2019/07/17/#bitcoin-core-15277

  - title: New reproducibly-build architecture and Snap packages for Bitcoin Core
    url: /en/newsletters/2019/05/07/#new-architecture-and-new-ubuntu-snap-package

  - title: "2019 year-in-review: reproducible builds"
    url: /en/newsletters/2019/12/28/#reproducibility

  - title: "Eclair #1295 allows the eclair-core module to be reproducibly built"
    url: /en/newsletters/2020/02/05/#eclair-1295

  - title: "Eclair #1307 updates packaging to also reproducibly build Eclair GUI"
    url: /en/newsletters/2020/03/04/#eclair-1307

  - title: "Bitcoin Core #17595 adds Guix support for Windows builds"
    url: /en/newsletters/2020/04/22/#bitcoin-core-17595

  - title: "Bitcoin Core #17920 adds Guix support for macOS builds"
    url: /en/newsletters/2021/01/27/#bitcoin-core-17920

  - title: "Bitcoin Core #21462 adds tooling for attesting to Guix-based builds"
    url: /en/newsletters/2021/05/19/#bitcoin-core-21462

  - title: "Question: what's the purpose of Guix within Gitian?"
    url: /en/newsletters/2021/07/28/#what-s-the-purpose-of-using-guix-within-gitian-doesn-t-that-reintroduce-dependencies-and-security-concerns

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Presentation: Bitcoin Build System Security"
    link: https://youtu.be/I2iShmUTEl8
---
This means no one person or computer needs to be trusted to produce
the executable binaries that most people use.  Additionally, people
who compile the software themselves can ensure that they received an
executable that's identical to what other people received, helping to
ensure their software will remain compatible with other software, e.g.
a full node staying in consensus with the rest of the network.

{% include references.md %}
