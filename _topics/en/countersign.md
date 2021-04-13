---
title: Countersign

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - P2P Network Protocol
  - Security Enhancements
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Countersign** is the idea for a protocol that will allow a client and
  server who have each other's public keys to negotiate authentication
  without either participant revealing any identifying information to third parties.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Countersign
      link: https://gist.github.com/sipa/d7dcaae0419f10e5be0270fada84c20b

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "2018 year-in-review: untrackable authentication"
    url: /en/newsletters/2018/12/28/#countersign

  - title: "CoreDev.tech meetings: v2 P2P transport and countersign"
    url: /en/newsletters/2019/06/12/#v2-p2p

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Version 2 P2P Transport
    link: topic v2 p2p transport
---
This would make it easier to securely set up whitelisted nodes across
the Internet for miners or exchanges, or to allow lightweight wallets
to ensure they connect to trusted nodes.  By enabling authentication
without revealing identity to third parties, nodes on anonymity
networks (such as Tor) or nodes that simply changed IP addresses
couldn't have their network identity tracked.

The protocol should be compatible with the [version 2 P2P transport
protocol][topic v2 p2p transport].

{% include references.md %}
