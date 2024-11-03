---
title: Peer storage

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Backup and Recovery
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLTs #881: Peer backup storage"
      link: https://github.com/lightning/bolts/pull/881

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Restoring LN channels from only a BIP32 seed
    url: /en/newsletters/2021/05/05/#closing-lost-channels-with-only-a-bip32-seed

  - title: "Core Lightning #5361 adds experimental support for peer storage backups"
    url: /en/newsletters/2023/02/15/#core-lightning-5361

  - title: "Fraud proofs for outdated state compared to peer storage backups"
    url: /en/newsletters/2023/08/23/#fraud-proofs-for-outdated-backup-state

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
  **Peer storage** is an optional service where a node accepts a small
  amount of frequently-updated encrypted data from its peers (especially
  channel counterparties).  It provides the latest version of that data
  back to the peer upon request, such as connection reestablishment.  The
  data can be a backup of the peer's latest channel state, allowing them
  to resume using a channel even if they lost their local state.
---

{% include references.md %}
{% include linkers/issues.md issues="" %}
