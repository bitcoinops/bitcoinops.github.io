---
title: 'Bitcoin Optech Newsletter #169'
permalink: /en/newsletters/2021/10/06/
name: 2021-10-06-newsletter
slug: 2021-10-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME:harding

## News

FIXME:harding

## Preparing for taproot #16: output linking

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

FIXME:harding <!-- include specials/taproot/en/14-signmessage.md -->

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

FIXME:harding (nothing at this time)

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core GUI #416][] adds an "Enable RPC server" checkbox which allows
  the user to turn on and off Bitcoin Core's RPC server (requires restart).

    {:.center}
    ![Screenshot of the Enable RPC server configuration option](/img/posts/2021-10-gui-rpc-server.png)

- [Bitcoin Core #20591][] wallet, bugfix: fix ComputeTimeSmart function during rescanning process FIXME:glozow

- [Bitcoin Core #22722][] updates the `estimatesmartfee` RPC so that it
  only returns feerates higher than both the configured and dynamic
  minimum transaction relay fees.  For example, if the estimator
  calculates a fee of 1 sat/vbyte, the configured value is 2 sat/vbyte,
  and the dynamic minimum has risen to 3 sat/vbyte, then a value of 3
  sat/vbyte will be returned.

- [Bitcoin Core #17526][] adds the [Single Random Draw][srd review club] (SRD) algorithm as
  a third [coin selection][topic coin selection] strategy. The wallet will now acquire coin
  selection results from each of the Branch and Bound (BnB), the knapsack,
  and the SRD algorithms and use the [waste heuristic][news165 waste] we
  described previously to select the most cost effective coin selection
  result out of the three to fund the transaction.

  In simulations based on about 8,000 payments, the PR author
  found that the addition of the SRD algorithm reduced overall
  transaction fees by 6% and increased the occurrence of changeless
  transactions from 5.4% to 9.0%. Not creating a change output decreases
  the weight and fees of a transaction, reduces the wallet's UTXO pool
  size, saves the cost of later spending the change output, and is
  thought to improve the privacy of the wallet.

- [Bitcoin Core #23061][] fixes the `-persistmempool` configuration
  option, which previously did not persist the mempool to disk on
  shutdown when no parameter was passed (to actually persist, you had to
  pass `-persistmempool=1`).  Now using the bare option will persist the
  mempool.

- [Bitcoin Core #23065][] makes it possible for wallet UTXO locks to be
  persisted to disk.  Bitcoin Core allows users to lock one or more of their
  UTXOs to prevent it from being used in automatically-created
  transactions.  The `lockunspent` RPC now includes a `persistent`
  parameter that saves the preference to disk, and the GUI automatically
  persists user-selected locks to disk.  One use for persistent locks is
  preventing spending of [dust spam][topic output linking] outputs, or
  the spending of other outputs that may reduce a user's privacy.

- [C-Lightning #4806][] adds a default delay of 10 minutes between the
  time the user changes their node's fee settings and when the new
  settings are enforced.  This allows the node's announcement of the new
  fees to propagate across the network before any payments are rejected
  for failing to pay a recently-raised fee.

- [Eclair #1900][] and [Rust-Lightning #1065][] implement [BOLTs
  #894][], which makes the LN protocol more strict by only allowing the
  use of segwit outputs in commitment transactions.  By implementing
  this restriction, LN programs can use a lower [dust limit][topic
  uneconomical outputs] which (when feerates are low) reduces the amount
  of money that may be lost to miners during a channel force close.

- [LND #5699][] adds a `deletepayments` command that can be used to
  delete payment attempts.  By default, only failed payment attempts can
  be deleted; for safety, an additional flag must be passed to delete
  successful payment attempts.

- [LND #5366][] kvdb: add postgres FIXME:dongcarl

- [Rust Bitcoin #563][] adds support for [bech32m][topic bech32]
  addresses for [P2TR][topic taproot] outputs.

- [Rust Bitcoin #644][] adds support for [tapscript's][topic tapscript] new
  `OP_CHECKMULTISIGADD` and `OP_SUCCESSx` opcodes.

- [BDK #376][] adds support for using a sqlite as the database backend.

<!--
- FIXME:harding update topics/RCs
- FIXME:harding check #bitcoin-core-dev weekly meeting logs
- FIXME:harding check #lightning-dev weekly meeting log
-->
{% include references.md %}
{% include linkers/issues.md issues="416,20591,22722,17526,23061,23065,4806,1900,1065,894,5699,5366,563,644,376" %}
[news165 waste]: /en/newsletters/2021/09/08/#bitcoin-core-22009
[srd review club]: https://bitcoincore.reviews/17526
