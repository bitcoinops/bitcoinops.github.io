---
title: 'Bitcoin Optech Newsletter #352'
permalink: /en/newsletters/2025/05/02/
name: 2025-05-02-newsletter
slug: 2025-05-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to comparisons between different cluster
linearization techniques and briefly summarizes discussion about
increasing or removing Bitcoin Core's `OP_RETURN` size limit.  Also
included are our regular sections announcing new releases and release
candidates and summarizing notable changes to popular Bitcoin
infrastructure software.

## News

- **Comparison of cluster linearization techniques:**
  Pieter Wuille [posted][wuille clustrade] to Delving Bitcoin about some of the fundamental
  tradeoffs between three different cluster linearization techniques,
  following up with [benchmarks][wuille clusbench] of implementations of
  each.  Several other developers discussed the results and asked
  clarifying questions, to which Wuille responded.

- **Increasing or removing Bitcoin Core's `OP_RETURN` size limit:**
  in a thread on Bitcoin-Dev, several developers discussed changing or
  removing Bitcoin Core's default limit for `OP_RETURN` data carrier
  outputs.  A subsequent Bitcoin Core [pull request][bitcoin core
  #32359] saw additional discussion.  Rather than attempt to summarize
  the entire voluminous discussion, we'll summarize what we
  thought was the most compelling argument for and against the change.

  - *For increasing (or eliminating) the limit:* Pieter Wuille
    [argued][wuille opr] that transaction standardness policy is
    unlikely to significantly prevent confirmation of data
    carrying transactions created by well-funded organizations
    that will put the effort into sending the transactions directly to
    miners.  Additionally, he argues that blocks are generally full
    whether or not they contain data-carrying transactions, so the
    overall amount of data a node needs to store is roughly the same
    either way.

  - *Against increasing the limit:* Jason Hughes [argued][hughes opr]
    that increasing the limit would make it easier to store arbitrary
    data on computers running full nodes, and that some of that data
    could be highly objectionable (including illegal in most
    jurisdictions).  Even if the node encrypts the data on disk (see
    [Newsletter #316][news316 blockxor]), storage of the data and the
    ability to retrieve it using Bitcoin Core RPCs could be problematic
    for many users.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.19.0-beta.rc3][] is a release candidate for this popular LN
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

- [Bitcoin Core #31250][] wallet: Disable creating and loading legacy wallets

- [Eclair #3064][] Simplify channel keys management

- [BTCPay Server #6684][] btcpayserver/wallet-policy

- [BIPs #1555][] TheBlueMatt/2024-03-uris-without-bodies

{% include snippets/recap-ad.md when="2025-05-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31250,3064,6684,1555,32359" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[wuille clusbench]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/73
[hughes opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f4f6831a-d6b8-4f32-8a4e-c0669cc0a7b8n@googlegroups.com/
[wuille opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/QMywWcEgJgWmiQzASR17Dt42oLGgG-t3bkf0vzGemDVNVnvVaD64eM34nOQHlBLv8nDmeBEyTXvBUkM2hZEfjwMTrzzoLl1_62MYPz8ZThs=@wuille.net/
[news316 blockxor]: /en/newsletters/2024/08/16/#bitcoin-core-28052
