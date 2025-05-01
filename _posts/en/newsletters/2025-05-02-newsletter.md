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

- [Bitcoin Core #31250][] disables the creation and loading of legacy wallets,
  completing the migration to [descriptor][topic descriptors] wallets that have
  been the default since October 2021 (see Newsletter [#172][news172
  descriptors]). Berkeley DB files used by legacy wallets can no longer be
  loaded, and all unit and functional tests for legacy wallets are deleted. Some
  legacy wallet code remains, but will be removed in follow up PRs.
  Bitcoin Core is still able to migrate legacy wallets to the new
  descriptor wallet format (see [Newsletter #305][news305 bdbro]).

- [Eclair #3064][] refactors channel key management by introducing a
  `ChannelKeys` class. Each channel now has its own `ChannelKeys` object which,
  together with the commitment points, derives a `CommitmentKeys` set for
  signing remote/local commitment and [HTLC][topic htlc] transactions. The force
  close logic and script/witness creation are also updated to rely on
  `CommitmentKeys`. Previously, key generation was scattered across several
  parts of the codebase to support external signers, which was prone to errors
  because it relied on naming rather than types to ensure the correct pubkey was
  provided.

- [BTCPay Server #6684][] adds support for a subset of [BIP388][] wallet policy
  [descriptors][topic descriptors], allowing users to import and export both
  single-sig and k-of-n policies. It includes the formats supported by Sparrow
  such as P2PKH, P2WPKH, P2SH-P2WPKH, and P2TR, with corresponding multisig
  variants, except for P2TR. Improving the use of multisig wallets is the
  intended goal of this PR.

- [BIPs #1555][] merges [BIP321][], which proposes a URI scheme for describing
  bitcoin payment instructions that modernizes and extends [BIP21][]. It keeps
  the legacy path‐based address but standardizes the use of query parameters by
  making new payment methods identifiable by their own parameters, and allows
  the address field to be left empty if at least one instruction appears in a
  query parameter. It adds an optional extension to provide a proof of payment
  to the spender, and provides guidance on how to incorporate new payment
  instructions.

{% include snippets/recap-ad.md when="2025-05-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31250,3064,6684,1555,32359" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[wuille clusbench]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/73
[hughes opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f4f6831a-d6b8-4f32-8a4e-c0669cc0a7b8n@googlegroups.com/
[wuille opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/QMywWcEgJgWmiQzASR17Dt42oLGgG-t3bkf0vzGemDVNVnvVaD64eM34nOQHlBLv8nDmeBEyTXvBUkM2hZEfjwMTrzzoLl1_62MYPz8ZThs=@wuille.net/
[news316 blockxor]: /en/newsletters/2024/08/16/#bitcoin-core-28052
[news172 descriptors]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[news305 bdbro]: /en/newsletters/2024/05/31/#bitcoin-core-26606
