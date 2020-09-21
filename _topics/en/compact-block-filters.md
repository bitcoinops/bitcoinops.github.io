---
title: Compact block filters

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - BIP157
  - BIP158
  - Neutrino protocol

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements
  - Lightweight Client Support
  - P2P Network Protocol

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Compact block filters** are a condensed representation of the
  contents of a block that allow wallets to determine whether the block
  contains any transactions involving the user's keys.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  A full node uses [BIP158][] to create a Golomb-Rice Coded Set (GCS) of the
  data from each block in the block chain. The GCSs (called filters) are then
  distributed to wallets (such as via the P2P protocol as described in
  [BIP157][]), allowing them to search for any matches to their scripts.  If a
  match is found, the wallet can then download the corresponding block to access
  any relevant transactions.

    The GCS mechanism guarantees that a wallet following the protocol will find
    any transactions matching its scripts, but it may also find some
    false-positive matches for which it will need to download and scan
    the block despite the block not containing any transactions relevant
    to the wallet.

    The BIP157/158 protocol is sometimes incorrectly called "Neutrino" after the
    wallet library developed to use the protocol.  It's one of several
    methods that lightweight clients can use to acquire data about their
    wallet transactions.  Compared to [BIP37][] bloom filters, it offers
    more privacy against spy nodes and less risk of attack against
    honest nodes.  Compared to address-indexed servers (such as
    Electrum-style servers), it also provides more privacy and requires
    less server storage and CPU.  However, the BIP157/158 does consume
    significantly more bandwidth in the normal case than either of those
    other protocols.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP157
    - title: BIP158

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Discussion of what data should be included in BIP158 filters
    url: /en/newsletters/2018/06/08#bip157-bip157-bip158-bip158-lightweight-client-filters

  - title: Functions for generating BIP158 filters added to Bitcoin Core
    url: /en/newsletters/2018/08/28/#bitcoin-core-12254

  - title: Basic BIP158 support merged into Bitcoin Core
    url: /en/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core

  - title: BIP157 bandwidth higher than BIP37 bloom filters
    url: /en/newsletters/2019/07/31/#bip157-would-use-more-bandwidth-than-bip37

  - title: Bitcoin Core 0.19 released with RPC support for BIP158 block filters
    url: /en/newsletters/2019/11/27/#bip158-block-filters-rpc-only

  - title: Maximum number of block filters per request increased from 100 to 1,000
    url: /en/newsletters/2019/11/13/#bips-857

  - title: "Bitcoin Core #18877 adds `getcfcheckpt` and `cfcheckpt` messages"
    url: /en/newsletters/2020/05/20/#bitcoin-core-18877

  - title: "Bitcoin Core #19010 & #19044 add additional messages from BIP157"
    url: /en/newsletters/2020/06/03/#bitcoin-core-19010

  - title: "Bitcoin Core #19070 allows advertising support for serving BIP157 filters"
    url: /en/newsletters/2020/08/19/#bitcoin-core-19070

## Optional.  Same format as "primary_sources" above
see_also:
  - title: BIP37 transaction bloom filtering
    link: topic transaction bloom filtering
---
