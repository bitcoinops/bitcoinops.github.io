---
title: Version 2 P2P transport
shortname: v2 p2p transport

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - P2P Network Protocol
  - Privacy Enhancements

aliases:
  - BIP151
  - BIP324

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Version 2 (v2) P2P transport** is a proposal to allow Bitcoin nodes
  to communicate with each other over encrypted connections.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: v2 Encrypted Transport Protocol proposed BIP
      link: https://github.com/bitcoin/bips/issues/1378

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Continuing work on P2P protocol encryption
    url: /en/newsletters/2018/08/21/#p2p-protocol-encryption

  - title: PR opened for initial BIP151 support
    url: /en/newsletters/2018/08/28/#pr-opened-for-initial-bip151-support

  - title: Criticism and defense of BIP151 choices
    url: /en/newsletters/2018/09/11/#bip151-discussion

  - title: Announcement of v2 P2P transport proposal
    url: /en/newsletters/2019/03/26/#version-2-p2p-transport-proposal

  - title: "CoreDev.tech discussion of v2 P2P transport proposal"
    url: /en/newsletters/2019/06/12/#v2-p2p

  - title: "Update on BIP324 v2 encrypted transport protocol"
    url: /en/newsletters/2022/10/19/#bip324-update

  - title: "CoreDev.tech discussion of v2 P2P encrypted transport proposal"
    url: /en/newsletters/2022/10/26/#transport-encryption

## Optional.  Same format as "primary_sources" above
see_also:
  - title: BIP151
  - title: "Countersign: a secret authentication protocol"
    link: https://gist.github.com/sipa/d7dcaae0419f10e5be0270fada84c20b
---
Some other changes to the communication protocol are also suggested,
such as allowing frequently-used protocol commands to be aliased to
shorted byte sequences to reduce bandwidth.

This proposal replaces the earlier [BIP151][] proposal.

{% include references.md %}
