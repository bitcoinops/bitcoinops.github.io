---
title: 'Bitcoin Optech Newsletter #367'
permalink: /en/newsletters/2025/08/15/
name: 2025-08-15-newsletter
slug: 2025-08-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections announcing new
release candidates and summarizing notable changes to popular Bitcoin
infrastructure software.

## News

_No significant news this week was found in any of our [sources][optech sources]._

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.19.3-beta.rc1][] is a release candidate for a maintenance
  version for this popular LN node implementation containing "important
  bug fixes".  Most notably, "an optional migration [...] lowers disk
  and memory requirements for nodes significantly."

- [Bitcoin Core 29.1rc1][] is a release candidate for a maintenance
  version of the predominant full node software.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33050][] net, validation: don't punish peers for consensus-invalid txs

- [Bitcoin Core #32473][] Introduce per-txin sighash midstate cache for legacy/p2sh/segwitv0 scripts

- [Bitcoin Core #33077][] kernel: create monolithic kernel static library

- [Core Lightning #8389][] lightningd: make option_channel_type compulsory.

{% include snippets/recap-ad.md when="2025-08-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33050,32473,33077,8389" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
