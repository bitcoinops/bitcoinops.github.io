---
title: 'Bitcoin Optech Newsletter #409'
permalink: /en/newsletters/2026/06/12/
name: 2026-06-12-newsletter
slug: 2026-06-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a draft BIP to replace the testnet4 test
network with a successor. Also included are our regular sections announcing
new releases and release candidates and describing notable changes to popular
Bitcoin infrastructure software.

## News

- **Draft BIP for testnet5**: Pol Espinasa [posted][testnet5 ml] to the
  Bitcoin-Dev mailing list a [draft BIP][testnet5 BIP], co-authored with Fabian
  Jahr, to replace [testnet4][topic testnet] with testnet5.
  The proposal is motivated by testnet4's low reliability, which stems from
  sustained exploitation of the difficulty exception (also known as the
  20-minute rule). This rule allows CPU miners to mine blocks at difficulty `1` once 20
  minutes have passed since the previous block, enabling "block storms" in which
  large numbers of low-difficulty blocks can be mined in a short time (see
  [Newsletter #311][news311 block storm]).

  The draft BIP proposes removing the difficulty exception rule so that testnet
  matches mainnet behavior as closely as possible. Testnet5 would follow the
  same consensus rules as mainnet except for two changes: activating [BIP54][]
  (the [consensus cleanup soft fork][topic consensus cleanup]) from block `1`,
  and setting the maximum proof-of-work target to `0x1a0fffff`
  (a lower maximum target than testnet4, i.e. a higher minimum difficulty).

  Espinasa invited other developers to provide feedback on the proposal.
  Discussion on the mailing list thread centered on applying patches to testnet4
  instead of spinning up a new one, the possibility of pre-mining testnet coins,
  and the best minimum difficulty for the new network.

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

{% include snippets/recap-ad.md when="2026-06-16 16:30" %}
{% include references.md %}

[testnet5 ml]: https://groups.google.com/g/bitcoindev/c/kGUMTxOvdJA/m/Eyx5FxQeAAAJ
[testnet5 BIP]: https://github.com/bitcoin/bips/pull/2196
[news311 block storm]: /en/newsletters/2024/07/12/#bitcoin-core-pr-review-club
