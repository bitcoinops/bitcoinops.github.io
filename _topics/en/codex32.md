---
title: Codex32

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - BIP93

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Backup and Recovery

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Codex32
      link: https://secretcodex32.com/

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposed BIP for new codex32 seed backup, splitting, verification, and recovery scheme
    url: /en/newsletters/2023/02/22/#proposed-bip-for-codex32-seed-encoding-scheme

  - title: Partial checksum verification of codex32-encoded seeds
    url: /en/newsletters/2023/03/01/#faster-seed-backup-checksums

  - title: "BIPs #1425 assigns BIP93 to the codex32 seed backup, splitting, verification, and recovery scheme"
    url: /en/newsletters/2023/03/29/#bips-1425

  - title: "Question about hand-derivation of public keys from private keys"
    url: /en/newsletters/2023/07/26/#how-can-i-manually-on-paper-calculate-a-bitcoin-public-key-from-a-private-key

  - title: "Core Lightning #6466 and #6473 add support for backing up and restoring codex32-encoded seeds"
    url: /en/newsletters/2023/08/09/#core-lightning-6466

## Optional.  Same format as "primary_sources" above
see_also:
  - title: BIP32 hierarchical derivation from seeds
    link: topic BIP32

  - title: "SLIP39 seed backup, splitting, and recovery"
    link: https://github.com/satoshilabs/slips/blob/master/slip-0039.md

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Codex32** is an encoding designed for BIP32 seeds that is convenient
  to store on paper.  It supports relatively simple processes for
  creating a seed, encoding that seed, splitting the seed into parts
  (requiring a configurable quorum of parts to gain any knowledge of the
  seed), and verifying the integrity of partial or full seed backups.
  The processes, though simple, can be laborious, but optional paper
  assistive devices (volvelles) can reduce some of the effort.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
