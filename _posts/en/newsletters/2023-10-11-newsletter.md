---
title: 'Bitcoin Optech Newsletter #272'
permalink: /en/newsletters/2023/10/11/
name: 2023-10-11-newsletter
slug: 2023-10-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a specification for a proposed
`OP_TXHASH` opcode and includes our regular sections summarizing a
Bitcoin Core PR Review Club meeting, linking to new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Specification for `OP_TXHASH` proposed:** Steven Roose [posted][roose
  txhash] to the Bitcoin-Dev mailing list a [draft BIP][bips #1500] for
  a new `OP_TXHASH` opcode.  The idea behind this opcode has been
  discussed before (see [Newsletter #185][news185 txhash]) but this is
  the first specification of the idea.  In addition to describing
  exactly how the opcode would work, it also looks at mitigating some
  potential downsides, such as full nodes potentially needing to hash up
  to several megabytes of data every time the opcode is invoked.
  Roose's draft includes a sample implementation of the opcode.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:LarryRuane

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/28165#l-22FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.117][] is a release of this library for building LN-enabled
  applications.  It includes security bug fixes related to the [anchor
  outputs][topic anchor outputs] features included in the immediately
  prior release.  The release also improves pathfinding, improves
  [watchtower][topic watchtowers] support, enables [batch][topic payment
  batching] funding of new channels, among several other features and
  bug fixes.

- [BDK 0.29.0][] is a release of this library for building wallet
  applications.  It updates dependencies and fixes a (likely rare) bug
  affecting cases where a wallet received more than one output from
  miner coinbase transactions.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27596][bitcoin core #27596], [#28590][bitcoin core #28590], [#28562][bitcoin core #28562], [nd #28589][bitcoin core #28589] assumeutxo (2) FIXME:adamjonas

- [Bitcoin Core #28331][], [#28588][bitcoin core #28588],
  [#28577][bitcoin core #28577], and [GUI #754][bitcoin core gui #754]
  add support for [version 2 encrypted P2P transport][topic v2 p2p
  transport] as specified in [BIP324][].  The feature is currently
  disabled by default but can be enabled using the `-v2transport`
  option.

    Encrypted transport helps improve the privacy of Bitcoin users by
    preventing passive observers (such as ISPs) from directly
    determining which transactions nodes relay to their peers.  It's also
    possible to use encrypted transport to thwart active
    man-in-the-middle observers by comparing session identifiers.  In
    the future, the addition of other [features][topic countersign] may
    make it convenient for a lightweight client to securely connect to a
    trusted node over a P2P encrypted connection.

- [Bitcoin Core #27609][] rpc: allow submitpackage to be called outside of regtest FIXME:glozow

- [Bitcoin Core GUI #764][] removes the ability to create a legacy
  wallet in the GUI.  The ability to create legacy wallets is being
  removed; all newly created wallets in future versions of Bitcoin Core
  will be [descriptor][topic descriptors]-based.

- [Core Lightning #6676][] adds a new `addpsbtoutput` RPC that will add
  an output to a [PSBT][topic psbt] for receiving funds onchain to the
  node's wallet.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27596,28590,28562,28589,28331,28588,28577,754,27609,764,6676,1500" %}
[roose txhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021975.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[ldk 0.0.117]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.117
[bdk 0.29.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.29.0
