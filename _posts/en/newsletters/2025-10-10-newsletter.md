---
title: 'Bitcoin Optech Newsletter #375'
permalink: /en/newsletters/2025/10/10/
name: 2025-10-10-newsletter
slug: 2025-10-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes research into tradeoffs between usability and
security in threshold signatures, summarizes an approach to convert nested
threshold signatures into a single-layer signing group, and examines the
extent to which data could be embedded in the UTXO set under a restrictive set
of rules. Also included are our regular sections summarizing a Bitcoin Core PR
Review Club meeting, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

FIXME:harding

- **Optimal Threshold Signatures**: Sindura Saraswathi [posted][sindura post]
  research, co-authored by her and Korok Ray, to Delving Bitcoin about determining the optimal threshold for a
  [multisignature][topic multisignature] scheme. In this research, the parameters of usability and
  security are explored, along with their relationship and how it affects the
  threshold that the user should select. By defining p(τ) and q(τ) and then
  combining them into a closed-form solution, they chart the gap between
  security and usability.

  Saraswathi also explores the use of degrading [threshold signatures][topic
  threshold signature] where early stages use higher thresholds, which gradually
  decline in later stages. This means that over time, the attacker gains more
  access to take the funds. She also says that using [taproot][topic taproot],
  there may be new possibilities to be unlocked with these through taptrees and
  more complex contracts, including [timelocks][topic timelocks] and multiple signatures.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/31829#l-12FIXME"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Inquisition 29.1][] is a release of this [signet][topic signet] full
  node designed for experimenting with proposed soft forks and other major
  protocol changes. It includes the new [minimum relay fee default][topic
  default minimum transaction relay feerates] (0.1 sat/vb) introduced in Bitcoin
  Core 29.1, the larger `datacarrier` limits expected in Bitcoin Core 30.0,
  support for `OP_INTERNALKEY` (see Newsletter [#285][news285 internal] and
  [#332][news332 internal]), and new internal infrastructure for supporting new
  soft forks.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33453][] undeprecates the `datacarrier` and `datacarriersize`
  configuration options because many users want to continue using these options,
  the depreciation plan was unclear, and there are minimal downsides to removing
  the deprecation. See Newsletters [#352][news352 data] and [#358][news358 data]
  for additional context on this topic.

- [Bitcoin Core #33504][] skips the enforcement of [TRUC][topic v3 transaction
  relay] checks during a block reorganization when confirmed transactions
  re-enter the mempool, even if they violate TRUC topological constraints.
  Previously, enforcing these checks would erroneously evict many transactions.

- [Core Lightning #8563][] defers the deletion of old [HTLCs][topic htlc] until
  a node is restarted, rather than deleting them when a channel is closed and
  forgotten. This improves performance by avoiding an unnecessary pause that
  halts all other CLN processes. This PR also updates the `listhtlcs` RPC to
  exclude HTLCs from closed channels.

- [Core Lightning #8523][] removes the previously deprecated and disabled
  `blinding` field from the `decode` RPC and on the `onion_message_recv` hook,
  as it has been replaced by `first_path_key`. The `experimental-quiesce` and
  `experimental-offers` options are also removed, because these features are the
  default.

- [Core Lightning #8398][] adds a `cancelrecurringinvoice` RPC command to the
  experimental recurring [BOLT12][] [offers][topic offers], allowing a payer to
  signal a receiver to stop expecting further invoice requests from that series.
  Several other updates are made to align with the latest specification changes
  in [BOLTs #1240][].

- [LDK #4120][] clears the interactive-funding state when a [splice][topic
  splicing] negotiation fails before the signing phase, if a peer disconnects or
  sends `tx_abort`, allowing the splice to be retried cleanly. If a `tx_abort`
  is received after the peers have begun exchanging `tx_signatures`, LDK treats
  it as a protocol error and closes the channel.

- [LND #10254][] deprecates support for [Tor][topic anonymity networks] v2 onion
  services, which will be removed in the next 0.21.0 release. The configuration
  option `tor.v2` is now hidden; users should use Tor v3 instead.

{% include snippets/recap-ad.md when="2025-10-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33453,33504,8563,8523,8398,4120,10254,1240" %}
[sindura post]: https://delvingbitcoin.org/t/optimal-threshold-signatures-in-bitcoin/2023
[Bitcoin Inquisition 29.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.1-inq
[news285 internal]: /en/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed
[news332 internal]: /en/newsletters/2024/12/06/#bips-1534
[news352 data]: /en/newsletters/2025/05/02/#increasing-or-removing-bitcoin-core-s-op-return-size-limit
[news358 data]: /en/newsletters/2025/06/13/#bitcoin-core-32406