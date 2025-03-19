---
title: 'Bitcoin Optech Newsletter #346'
permalink: /en/newsletters/2025/03/21/
name: 2025-03-21-newsletter
slug: 2025-03-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about LND's updated
dynamic feerate adjustment system.  Also included are our regular
sections describing recent changes to services and client software,
announcing new releases and release candidates, and summarizing recent
merges to popular Bitcoin infrastructure software.

## News

- **Discussion of LND's dynamic feerate adjustment system:** Matt
  Morehouse [posted][morehouse sweep] to Delving Bitcoin a description
  of LND's recently-rewritten _sweeper_ system, which
  determines the feerates to use for onchain transactions (including
  [RBF][topic rbf] fee bumps).  He begins with a brief description
  of the safety critical aspects of fee management for an LN node, as
  well as the natural desire to avoid overpaying.  He then describes the
  two general strategies used by LND:

  - Querying external feerate estimators, such as a local Bitcoin Core
    node or a third party.  This is mainly used for choosing initial
    feerates and fee bumping non-urgent transactions.

  - Exponential fee bumping, used when a deadline is approaching to
    ensure that problems with a node's mempool or its [fee estimation][topic fee estimation]
    don't prevent timely confirmation.  For example, Eclair uses exponential fee
    bumping when deadlines are within six blocks.

  Morehouse then describes how these two strategies are combined in
  LND's new sweeper system: "[HTLC][topic htlc] claims with matching
  deadlines [are aggregated] into a single [batched transaction][topic
  payment batching]. The budget for the batched transaction is
  calculated as the sum of the budgets for the individual HTLCs in the
  transaction. Based on the transaction budget and deadline, a fee
  function is computed that determines how much of the budget is spent
  as the deadline approaches.  By default, a linear fee function is used,
  which starts at a low fee (determined by the minimum relay fee rate or
  an external estimator) and ends with the total budget being allocated
  to fees when the deadline is one block away."

  He additionally describes how the new logic helps protect against
  [replacement cycling][topic replacement cycling] attacks, concluding:
  "with LND’s default parameters an attacker must generally spend at
  least 20x the value of the HTLC to successfully carry out a
  replacement cycling attack."  He adds that the new system also
  improves LND's defense against [pinning attacks][topic transaction
  pinning].

  He concludes with a link-filled summary of several "LND-specific bug
  and vulnerability fixes" made through the improved logic.  Abubakar
  Sadiq Ismail [replied][ismail sweep] with some suggestions for how all
  LN implementations (in addition to other software) can more
  effectively use Bitcoin Core's fee estimation.  Several other
  developers also commented, adding both nuance to the description and
  praise for the new approach.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.0rc2][] is a release candidate for the next major
  version of the network's predominate full node.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31649][] consensus: Remove checkpoints (take 2)

- [Bitcoin Core #31283][] Add waitNext() to BlockTemplate interface

- [Eclair #3037][] Improve Bolt12 offer APIs

- [LND #9546][] macaroons: ip range constraint

- [LND #9458][] multi+server.go: add initial permissions for some peers

- [BTCPay Server #6581][] Feature: RBF and UX improvement to fee bumping

- [BDK #1839][] Introduce `evicted-at`/`last-evicted` timestamps

- [BOLTs #1233][] Check for preimage before failing back missing HTLCs, c.f. https://bitcoinops.org/en/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft

{% include snippets/recap-ad.md when="2025-03-25 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31649,31283,3037,9546,9458,6581,1839,1233" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[morehouse sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512
[ismail sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512/3
