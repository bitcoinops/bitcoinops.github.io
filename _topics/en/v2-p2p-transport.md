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

  - title: "Request for feedback on message identifiers for v2 P2P encrypted transport"
    url: /en/newsletters/2022/11/02/#bip324-message-identifiers

  - title: "2022 year-in-review: encrypted v2 transport protocol"
    url: /en/newsletters/2022/12/21/#v2-transport

  - title: "Libsecp256k1 #1129 implements the ElligatorSwift technique for establishing v2 P2P connections"
    url: /en/newsletters/2023/06/28/#libsecp256k1-1129

  - title: "Bitcoin Core #28008 adds encryption and decryption routines for v2 transport protocol encryption"
    url: /en/newsletters/2023/08/16/#bitcoin-core-28008

  - title: "Bitcoin Core PR Review Club summary about internal serialization changes for BIP324"
    url: /en/newsletters/2023/09/13/#bitcoin-core-pr-review-club

  - title: "Bitcoin Core #28196 adds a substantial portion of the code to provide BIP324 support"
    url: /en/newsletters/2023/09/20/#bitcoin-core-28196

  - title: "Bitcoin Core #28331 adds optional support for v2 encrypted P2P transport"
    url: /en/newsletters/2023/10/11/#bitcoin-core-28331

## Optional.  Same format as "primary_sources" above
see_also:
  - title: BIP151
  - title: Countersign
    link: topic countersign
---
Some other changes to the communication protocol are also suggested,
such as allowing frequently-used protocol commands to be aliased to
shorted byte sequences to reduce bandwidth.

This proposal replaces the earlier [BIP151][] proposal.

{% include references.md %}
