---
title: Simple taproot channels

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLTs PR #995: simple taproot channels"
      link: https://github.com/lightning/bolts/pull/995

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "LND #7904 adds experimental support for simple taproot channels"
    url: /en/newsletters/2023/08/30/#lnd-7904

  - title: "Specifications for taproot assets released based on LND's experimental simple taproot channels"
    url: /en/newsletters/2023/09/13/#specifications-for-taproot-assets

  - title: "Zeus v0.8.0 released with support for simple taproot channels"
    url: /en/newsletters/2023/12/13/#zeus-v0-8-0-released

  - title: "LND #7733 updates its watchtower support for simple taproot channels"
    url: /en/newsletters/2024/01/31/#lnd-7733

  - title: "LND #8499 makes significant changes to the TLV types used for simple taproot channels"
    url: /en/newsletters/2024/03/13/#lnd-8499

  - title: "Discussion of channel upgrade methods, such as switching to simple taproot channels"
    url: /en/newsletters/2024/05/24/#upgrading-existing-ln-channels

  - title: "Updated channel announcements that include support for simple taproot channels"
    url: /en/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal

  - title: "Eclair #2896 enables the storage of MuSig2 partial signatures for simple taproot channels"
    url: /en/newsletters/2025/01/24/#eclair-2896

  - title: "Zero-knowledge gossip for LN channel announcements compatible with MuSig2 simple taproot channels"
    url: /en/newsletters/2025/02/07/#zero-knowledge-gossip-for-ln-channel-announcements

  - title: "Eclair #3016 introduces low-level methods for creating LN transactions in simple taproot channels"
    url: /en/newsletters/2025/03/07/#eclair-3016

  - title: "Eclair #3026 adds support for wallets containing P2TR addresses in preparation for taproot channels"
    url: /en/newsletters/2025/03/28/#eclair-3026

  - title: "LND #9669 downgrades simple taproot channels to always use the legacy cooperative close flow"
    url: /en/newsletters/2025/04/11/#lnd-9669

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Taproot
    link: topic taproot

  - title: MuSig2
    link: topic musig

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Simple taproot channels** are LND funding and commitment
  transactions that use taproot (P2TR) with support for MuSig2
  scriptless multisignature signing when both parties are cooperating.
  This reduces transaction weight space and improves privacy when
  channels are closed cooperatively.

---
The initial experimental deployment of simple taproot channels in LND
continues to exclusively use [HTLCs][topic htlc], allowing payments
starting in a taproot channel to continue to be forwarded through other
LN nodes that don’t support taproot channels.  Later upgrades of simple
taproot channels, or alternative approaches, may begin supporting
[PTLCs][topic ptlc].

{% include references.md %}
{% include linkers/issues.md issues="" %}
