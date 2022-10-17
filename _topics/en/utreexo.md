---
title: Utreexo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - P2P Network Protocol
  - Consensus Enforcement

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Utreexo** is a proposed alternative to the UTXO set for allowing
  full nodes to obtain and verify information about the UTXOs being
  spent in a transaction.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Utreexo: A dynamic hash-based accumulator optimized for the Bitcoin UTXO set"
      link: https://eprint.iacr.org/2019/611.pdf

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "CoreDev.Tech summaries: Utreexo"
    url: /en/newsletters/2018/10/16/#using-utxo-accumulators-to-reduce-data-storage-requirements-utreexo

  - title: Exploring accumulators
    url: /en/newsletters/2019/02/05/#accumulators-for-blockchains

  - title: Utreexo Q&A session at CoreDev.Tech
    url: /en/newsletters/2019/06/12/#utreexo

  - title: "Launch of ZeroSync project using Utreexo"
    url: /en/newsletters/2022/10/19/#zerosync-project-launches

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
A merkle tree updated after every block accumulates references to
every unspent transaction output, allowing nodes to skip storing the
outputs themselves.  New transactions can be distributed with the
UTXOs they spend and a merkle branch proving they're part of the
utreexo merkle tree.  Overall, this can decrease the amount of storage
full nodes need to a minimal amount at the cost of modest increases in
bandwidth.  Utreexo would not change Bitcoin's security model.

{% include references.md %}
