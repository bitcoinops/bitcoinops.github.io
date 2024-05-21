---
title: 'Bitcoin Optech Newsletter #169'
permalink: /en/newsletters/2021/10/06/
name: 2021-10-06-newsletter
slug: 2021-10-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal to add transaction heritage
identifiers to Bitcoin and includes our regular sections with
information about preparing for taproot,
a list of new releases and release candidates,
and summaries of notable changes to popular Bitcoin infrastructure
software.

## News

- **Proposal for transaction heritage identifiers:** a [post][rubin-law
  iids] by pseudonymous developer John Law was submitted to the
  Bitcoin-Dev and Lightning-Dev mailing lists.  Law proposed a soft fork
  to add *Inherited Identifiers* (IIDs) which would allow referencing
  the txid of a transaction's ancestor and the position of the outputs
  leading to the current input.  For example, `0123...cdef:0:1`
  indicates the current transaction input is spending the second child
  of the first output of txid `0123...cdef`.  This allows participants
  in a multiparty protocol to create signatures spending a particular
  output even in cases when they can't know in advance the txid of the
  transaction that will create that output.

  This compares to the *floating transactions* approach enabled by the
  proposed [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] soft fork
  and described as part of the [eltoo][topic eltoo] protocol.
  Floating transactions allow participants to create signatures for a
  particular output without knowing its txid as long as they otherwise
  satisfy the conditions in that output's script.

  Law describes four different protocols enabled by IIDs in an
  extended [paper][law iids], <!-- it's 66 pages, yikes --> including
  alternatives to eltoo and [channel factories][topic channel
  factories], plus ideas that could simplify [watchtower][topic
  watchtowers] design.  Anthony Towns [suggested][towns iids] that the
  features of IIDs could be simulated using anyprevout, which would
  still represent a novel development, although Law [disagreed][law
  nosim] about the possibility of simulation.

  Discussion of the ideas was complicated due to not all participants
  being willing to use the mailing lists.  If discussion on the lists
  resumes, we'll summarize any notable updates in a future newsletter.

## Preparing for taproot #16: output linking

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/15-output-linking.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.13.3-beta][] is a security release fixing [CVE-2021-41593][], a
  vulnerability which can lead to loss of funds.  The release notes also
  contain suggested mitigations for nodes that can't be immediately
  upgraded.

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

- [Bitcoin Core #20591][] changes the wallet time calculation logic to
  only use the block timestamp when rescanning historical blocks for
transactions relevant to the wallet. Users and applications using the
`rescanblockchain` RPC to manually invoke rescans should no longer see
transactions inaccurately labeled with the time scanned instead of
time confirmed, eliminating an occasional source of confusion and
frustration.

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
  mempool (which remains the default, so it shouldn't need to be passed).

- [Bitcoin Core #23065][] makes it possible for wallet UTXO locks to be
  persisted to disk.  The Bitcoin Core wallet allows users to lock one or more of their
  UTXOs to prevent it from being used in automatically-created
  transactions.  The `lockunspent` RPC now includes a `persistent`
  parameter that saves the preference to disk, and the GUI automatically
  persists user-selected locks to disk.  One use for persistent locks is
  preventing spending of [low-value spam][topic output linking] outputs, or
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

- [LND #5366][] adds initial support for using PostgreSQL as a database backend.
  Compared to the existing bbolt backend, PostgreSQL can replicate across
  multiple servers, perform database compaction on-the-fly, handle larger
  datasets, and provide a more granular locking model which may improve I/O lock
  contention.

- [Rust Bitcoin #563][] adds support for [bech32m][topic bech32]
  addresses for [P2TR][topic taproot] outputs.

- [Rust Bitcoin #644][] adds support for [tapscript's][topic tapscript] new
  `OP_CHECKMULTISIGADD` and `OP_SUCCESSx` opcodes.

- [BDK #376][] adds support for using sqlite as the database backend.

{% include references.md %}
{% include linkers/issues.md issues="416,20591,22722,17526,23061,23065,4806,1900,1065,894,5699,5366,563,644,376" %}
[news165 waste]: /en/newsletters/2021/09/08/#bitcoin-core-22009
[srd review club]: https://bitcoincore.reviews/17526
[rubin-law iids]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019470.html
[law iids]: https://github.com/JohnLaw2/btc-iids/raw/main/iids14.pdf
[towns iids]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019471.html
[law nosim]: https://github.com/JohnLaw2/btc-iids/blob/main/response_to_towns_20210918_113740.txt
[CVE-2021-41593]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html
[lnd 0.13.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.3-beta
