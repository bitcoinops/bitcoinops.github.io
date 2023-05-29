---
title: Compact block relay

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - BIP152

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Bandwidth Reduction
  - Mining
  - P2P Network Protocol

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP152

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Bitcoin Core PR Review Club about dropping support for v1 compact blocks
    url: /en/newsletters/2021/02/10/#bitcoin-core-pr-review-club

  - title: "Bitcoin Core #20764 adds BIP152 high bandwidth indicator to bitcoin-cli"
    url: /en/newsletters/2021/02/10/#bitcoin-core-20764

  - title: "Bitcoin Core #19776 updates `getpeerinfo` RPC with BIP152 peer status"
    url: /en/newsletters/2020/12/16/#bitcoin-core-19776

  - title: Consequences of not backporting taproot relay on compact block efficiency
    url: /en/newsletters/2020/07/29/#dont-relay-taproot

  - title: "Disabling compact block relay for `-blocksonly` nodes"
    url: /en/newsletters/2021/09/08/#bitcoin-core-pr-review-club

  - title: "Bitcoin Core #20799 disables v1 compact block relay; v2 still enabled"
    url: /en/newsletters/2022/05/25/#bitcoin-core-20799

  - title: "Rust Bitcoin #1088 adds structures and methods for compact blocks"
    url: /en/newsletters/2022/08/03/#rust-bitcoin-1088

  - title: Discussion about inconsistent mempools and how that could affect compact block relay
    url: /en/newsletters/2022/11/02/#better-peering-involves-tradeoffs

  - title: "Bitcoin Core #27626 allows parallel download of compact blocks from multiple peers"
    url: /en/newsletters/2023/05/31/#bitcoin-core-27626

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Compact block relay** is a protocol that allows two nodes with
  roughly similar sets of unconfirmed transactions to minimize both the
  bandwidth and the latency required to transfer a block that confirms
  many of those same transactions.

---

By default, most full nodes are configured to receive relayed
unconfirmed transactions, which the nodes store in their mempools and
further relay to their other peers.  Ultimately those transactions
reach miners, who attempt to include them in a block.  When that new
block is itself relayed back to nodes, it typically consists almost
entirely of transactions that the nodes already have in their mempools.

Relaying those transactions a second time is redundant, and it's that
redundancy that [BIP152][] compact blocks aims to eliminate.  A sending
node constructs a compact block by replacing each transaction it
believes its peer has with a fast per-peer 6-byte non-cryptographic hash
of that transaction's identifier (txid for pre-segwit nodes, witness
txid (wtxid) for segwit nodes).
This can take a multimegabyte block with thousands of
transactions and compact it down to just a few kilobytes.  This directly
reduces bandwidth.  Indirectly, it also significantly reduces latency
because TCP propagates smaller amounts of data faster than larger
amounts.

For any transactions the generating node doesn't think its peer knows
about, it sends the full transaction.

The receiving peer hashes the wtxids of all the transactions in its
mempool.  It then substitutes each wtxid hash in the compact block with
the full transaction from its mempool.  If any of the wtxid hashes in the
compact block don't match a transaction in the receiving peer's mempool,
it requests that transaction from the sending node.

To maximize both bandwidth and latency improvements, compact blocks can
be used in two different modes:

- **Low bandwidth mode** is designed to be used with most peers.  When a
  node learns about a new block, it announces the header hash of that
  block to its BIP152 low-bandwidth peers.  Only if a peer requests the
  compact block is any additional data sent.  This avoids sending data
  to peers who may have already received the block from one of their
  other peers.

- **High bandwidth mode** is designed to only be used with a few peers
  who specifically request the mode.  When a node receives a block, it
  verifies its header contains an appropriate amount of Proof of Work
  (PoW) and then, without performing any other significant verification,
  immediately sends it as a compact block to its high bandwidth mode
  peers.  This allows blocks to propagate across the network quickly at
  the cost of nodes sometimes sending a compact block to a peer who
  already received the block from another node.  Since compact blocks
  are so much smaller than raw blocks, this "high bandwidth" mode still
  typically uses less bandwidth than pre-BIP152 block relay.

BIP152 also specifies two versions of compact blocks:

- Version 1 uses hashes of txids.

- Version 2 uses hashes of wtxids.

Preserving the advantages of compact block relay is often cited as one
reason for trying to keep mempool and relay policy consistent between
nodes---the more the mempools of nodes differ, the less effective
compact blocks will be at minimizing bandwidth and latency.

{% include references.md %}
{% include linkers/issues.md issues="" %}
