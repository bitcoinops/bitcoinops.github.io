---
title: Channel announcements

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLT7: P2P node and channel discovery"
      link: bolt7

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Gossip update proposed
    url: /en/newsletters/2019/07/17/#gossip-update-proposal

  - title: Updated gossip proposal
    url: /en/newsletters/2022/02/23/#updated-ln-gossip-proposal

  - title: Continued discussion about updated gossip proposal
    url: /en/newsletters/2022/03/30/#continued-discussion-about-updated-ln-gossip-protocol

  - title: LN developer meeting discussion about gossip updates
    url: /en/newsletters/2022/06/15/#gossip-network-updates

  - title: LN developer discussion about updated channel announcements
    url: /en/newsletters/2023/07/26/#updated-channel-announcements

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
  **Channel announcements** are advertisements that a channel is
  available to forward payments.  The advertisements are relayed through
  the LN gossip network.
---
Version 1 announcements require the nodes that want to advertise a
channel prove that they control a UTXO for
a P2WSH output for a 2-of-2 multisig script.  Proposed upgrades to the
announcements may allow UTXOs for other scripts to be used, making it
possible to advertise channels that use [P2TR][topic taproot],
[MuSig2][topic musig], and other technologies.  Other improvements have
been discussed that may break the link between UTXOs and specific
channels.

{% include references.md %}
{% include linkers/issues.md issues="" %}
