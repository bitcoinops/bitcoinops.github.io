---
title: Transaction bloom filtering

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - BIP37
  - Bloom filters

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightweight Client Support
  - Privacy Problems
  - P2P Network Protocol
  - Security Problems

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Transaction bloom filtering** is a method that allows lightweight
  clients to limit the amount of transaction data they receive from full
  nodes to only those transactions that affect their wallet (plus a
  configurable amount of additional transactions to generate
  plausible deniability about which transactions belong to the client).

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  [Bloom filters][] provide the ability to create a compact filter that
  is guaranteed to match a specified string with a configurable rate of
  false positive matches for other strings.  A lightweight client can
  create a bloom filter for all of its wallet addresses, send that
  filter to a node using the P2P protocol messages defined in BIP37, and
  then request a special form of blocks (merkle blocks) from the node.

  A merkle block, also defined in BIP37, will contain only transactions
  matching the previously sent filter plus the block header and a
  partial merkle branch connecting each matching transaction to the
  merkle root in the block header.

  Clients will also receive announcements of new unconfirmed transactions being
  relayed by the node if they match the filter.

  When BIP37 was popular, most lightweight clients that used it ran on
  mobile devices with limited bandwidth and so chose low false positive
  rates to minimize their bandwidth use.  This meant that they
  essentially gave their list of addresses to any node they contacted.
  It was expected that privacy-focused users could mitigate this privacy
  loss by setting a higher false positive rate, but research suggests
  that the rate needs to be quite high in order to provide plausible
  deniability.

  As an additional problem, nodes serving BIP37 filters must perform
  filtering independently for each client and it's possible for filters to be created
  in a way that requires nodes perform an extensive amount of CPU processing to
  filter each block.  This resulted in a set of known DoS vectors
  against nodes.

  Although in practice BIP37 allowed clients to use a fairly small
  amount of bandwidth, it was slower and used more bandwidth than other
  remote transaction scanning methods based on large databases of
  transactions.  Many popular lightweight clients today query such
  databases instead of using transaction bloom filters.

  *Note: this topic only refers to BIP37 transaction bloom filters.  There
  are uses of generic bloom filters in Bitcoin (such as in Bitcoin Core's
  transaction relay tracking) that aren't indexed to this topic.*

  [bloom filters]: https://en.wikipedia.org/wiki/Bloom_filter

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP37

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Bitcoin Core PR#16152 disables bloom filter support by default
    url: /en/newsletters/2019/07/24/#bitcoin-core-16152
    date: 2019-07-24

  - title: Mailing list discussion about disabling bloom filters in Bitcoin Core
    url: /en/newsletters/2019/07/31/#bloom-filter-discussion
    date: 2019-07-31

  - title: Bitcoin Core 0.19 released with bloom filters disabled
    url: /en/newsletters/2019/11/27/#deprecated-or-removed-features
    date: 2019-11-27

  - title: "Bitcoin Core PR#16248 adds bloom filter whitelist option"
    url: /en/newsletters/2019/08/21/#bitcoin-core-16248
    date: 2019-08-21

  - title: "BRD field report: using native segwit addresses with bloom filters"
    url: /en/bech32-sending-support/#brd-field-report
    date: 2019-08-07

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Privacy in BitcoinJ [bloom filters]"
    link: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/

  - title: Compact block filters
    link: topic compact block filters
---
