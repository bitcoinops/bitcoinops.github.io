---
title: 'Bitcoin Optech Newsletter #393'
permalink: /en/newsletters/2026/02/20/
name: 2026-02-20-newsletter
slug: 2026-02-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about recent OP_RETURN usage and
describes a protocol to enforce covenant-like spending conditions without
consensus changes.  Also included are our regular sections describing recent
changes to services and client software, announcing new releases and release
candidates, and summarizing recent merges to popular Bitcoin infrastructure
software.

## News

- **Recent OP_RETURN output statistics**: Anthony Towns posted to
  [Delving][post op_return stats] about the recent OP_RETURN statistics since
  the release of Bitcoin Core v30.0 on October 10, which included changes to
  the mempool policy limits for OP_RETURN outputs (allowing multiple OP_RETURN
  outputs and allowing up to 100kB of data in OP_RETURN outputs). The range of
  blocks he looked at was heights 915800 to 936000, with the following
  results:

  - 24,362,310 txs with OP_RETURN outputs

  - 61 txs with multiple OP_RETURN outputs

  - 396 txs with total OP_RETURN output script sizes greater than 83 bytes

  - Total OP_RETURN output script data over the period was 473,815,552 bytes (of
    which large OP_RETURNS accounted for 0.44%)

  - There are 34,283 txs burning sats to OP_RETURN outputs, for a total of
    1,463,488 sats burnt

  - There are 949,003 txs with between 43 and 83 bytes of OP_RETURN data, and
    23,412,911 txs with OP_RETURN data of 42 bytes or less

  Towns also included a chart showing the frequency of sizes for the 396
  transactions with large OP_RETURN outputs. 50% of these transactions had less
  than 210 bytes of OP_RETURN data. Also, 10% had more than 10KB of OP_RETURN
  data.

  He later added that Murch subsequently published a [similar analysis][murch twitter] on
  X and a [dashboard][murch dashboard] of OP_RETURN
  statistics, and that orangesurf published a [report][orangesurf report] on
  OP_RETURN for mempool research.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

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

{% include snippets/recap-ad.md when="2026-02-24 17:30" %}
{% include references.md %}
[post op_return stats]: https://delvingbitcoin.org/t/recent-op-return-output-statistics/2248
[murch dashboard]: https://dune.com/murchandamus/opreturn-counts
[murch twitter]: https://x.com/murchandamus/status/2022930707820269670
[orangesurf report]: https://research.mempool.space/opreturn-report/
