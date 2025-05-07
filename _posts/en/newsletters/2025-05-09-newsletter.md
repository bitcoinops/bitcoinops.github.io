---
title: 'Bitcoin Optech Newsletter #353'
permalink: /en/newsletters/2025/05/09/
name: 2025-05-09-newsletter
slug: 2025-05-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a recently discovered theoretical
consensus failure vulnerability and links to a proposal to avoid reuse
of BIP32 wallet paths.  Also included are our regular sections summarizing
a Bitcoin Core PR Review Club meeting, announcing new releases and
release candidates, and describing notable code changes to popular
Bitcoin infrastructure software.

## News

- **BIP30 consensus failure vulnerability:** Ruben Somsen [posted][somsen
  bip30] to the Bitcoin-Dev mailing list about a theoretical consensus
  failure that could occur now that checkpoints have been removed from
  Bitcoin Core (see [Newsletter #346][news346 checkpoints]).  In short,
  the coinbase transactions of blocks 91722 and 91812 are [duplicated][topic duplicate transactions] in
  blocks 91880 and 91842.  [BIP30][] specifies that those second two
  blocks should be handled the way the historic version of Bitcoin Core
  handled them in 2010, which is by overwriting the earlier coinbase
  entries in the UTXO set with the later duplicates.  However, Somsen
  notes that a reorg of either or both later blocks would result in the
  duplicate entry (or entries) being removed from the UTXO set, leaving
  it devoid also of the earlier entries due to the overwriting.
  But, a newly started node that never saw the duplicate
  transactions would still have the earlier transactions, giving it a
  different UTXO set that could result in a consensus failure if either
  transaction is ever spent.

  This wasn't an issue when Bitcoin Core had checkpoints as they
  required all four blocks mentioned above to be part of the best
  blockchain.  It's not really an issue now, except in a theoretical
  case where Bitcoin's proof-of-work security mechanism breaks.  Several
  possible solutions were discussed, such as hardcoding additional
  special case logic for these two exceptions.

- **Avoiding BIP32 path reuse:** Kevin Loaec [posted][loaec bip32reuse]
  to Delving Bitcoin to discuss options for preventing the same
  [BIP32][topic bip32] wallet path from being used with different
  wallets, which could lead to a loss of privacy due to [output
  linking][topic output linking] and a theoretical loss of security
  (e.g., due to [quantum computing][topic quantum resistance]).  He
  suggested three possible approaches: use a randomized path, use a path
  based on the wallet birthday, and use a path based on an incrementing
  counter.  He recommended the birthday-based approach.

  He also recommended dropping most of the [BIP48][] path elements as
  unnecessary due to the increasingly widespread use of [descriptor][topic descriptors]
  wallets, especially for multisig and complex script wallets.  However,
  Salvatore Ingala [replied][ingala bip48] to suggest keeping the _coin
  type_ part of the BIP48 path as it helps ensure keys for use with
  different cryptocurrencies are kept segregated, which is enforced by
  some hardware signing devices.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/31664#l-19FIXME"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.19.0-beta.rc4][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #8227][] lsps: Add service implementation for LSPS0

- [Core Lightning #8162][] lightningd: allow up to 100 "slow open" channels before forgetting them.

- [Core Lightning #8166][] lightningd: improve wait API by making details fields per-subsystem.

- [Core Lightning #8237][] lightningd: add `short_channel_id` option to listpeerchannels.

- [LDK #3700][] (3/3) Add Failure Reason to HTLCHandlingFailed

- [Rust Bitcoin #4387][] bip32: overhaul error types and add a "maximum depth exceeded" error

- [BIPs #1835][] BIP48: Add p2tr script type derivation

- [BIPs #1800][] BIP 54: Consensus Cleanup

- [BOLTs #1245][] Require minimally-encoded fields in BOLT 11 invoices

{% include snippets/recap-ad.md when="2025-05-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8227,8162,8166,8237,3700,4387,1835,1800,1245" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[somsen bip30]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjZTWhgzzdps3vb0YoU3EYJwThDFhNLkf4XmmdfhbORTaw@mail.gmail.com/
[loaec bip32reuse]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644
[ingala bip48]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644/3
[news346 checkpoints]: /en/newsletters/2025/03/21/#bitcoin-core-31649
