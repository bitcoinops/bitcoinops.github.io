---
title: 'Bitcoin Optech Newsletter #391'
permalink: /en/newsletters/2026/02/06/
name: 2026-02-06-newsletter
slug: 2026-02-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to work on a constant-time parallelized UTXO
database, summarizes a new high-level language for writing Bitcoin Script, and
describes an idea to mitigate dust attacks. Also included are our regular
sections summarizing discussion about changing Bitcoin's consensus rules,
announcing new releases and release candidates, and describing notable changes
to popular Bitcoin infrastructure software.

## News

- **A constant-time parallelized UTXO database**: Toby Sharp
  [posted][hornet del] to Delving Bitcoin about his latest project, a custom, highly
  parallel UTXO database, with constant-time queries, called Hornet UTXO(1).
  This is a new additional component of [Hornet Node][hornet website], an
  experimental Bitcoin client focused on providing a minimal executable
  specification of Bitcoin's consensus rules.
  This new database aims to improve Initial Block Download (IBD) through a lock-free,
  highly concurrent architecture.

  The code is written in modern C++23, without external dependencies. To optimize for
  speed, sorted arrays and [LSM trees][lsmt wiki] were preferred over
  [hash maps][hash map wiki].
  Operations, such as append, query, and fetch, are executed concurrently, and
  blocks are processed out of order as they arrive, with data dependencies resolved
  automatically. The code is not yet publicly available.

  Sharp provided a benchmark to assess the capabilities of his software.
  For re-validating the whole mainnet chain, Bitcoin Core v30 took 167 minutes
  (with no script or signature validation), while Hornet UTXO(1) took 15 minutes
  to complete validation. Tests were performed on a 32-core computer,
  with 128GB RAM and 1TB storage.

  In the discussion that followed, other developers suggested Sharp to compare
  performance against [libbitcoin][libbitcoin gh], which is known for providing a
  very efficient IBD.


## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

FIXME:reardencode

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-02-10 17:30" %}
{% include references.md %}
[hornet del]: https://delvingbitcoin.org/t/hornet-utxo-1-a-custom-constant-time-highly-parallel-utxo-database/2201
[hornet website]: https://hornetnode.org/overview.html
[lsmt wiki]: https://en.wikipedia.org/wiki/Log-structured_merge-tree
[hash map wiki]: https://en.wikipedia.org/wiki/Hash_table
[libbitcoin gh]: https://github.com/libbitcoin
