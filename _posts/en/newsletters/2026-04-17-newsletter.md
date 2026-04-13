---
title: 'Bitcoin Optech Newsletter #401'
permalink: /en/newsletters/2026/04/17/
name: 2026-04-17-newsletter
slug: 2026-04-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an idea for nested MuSig2 Lightning nodes and
summarizes a project formally verifying secp256k1's modular scalar
multiplication. Also included are our regular sections describing recent changes
to services and client software, announcing new releases and release candidates,
and summarizing notable changes to popular Bitcoin infrastructure software.

## News

FIXME:bitschmidty

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Coldcard 6.5.0 adds MuSig2 and miniscript:**
  Coldcard [6.5.0][coldcard 6.5.0] adds [MuSig2][topic musig] signing support,
  [BIP322][] proof of reserve capabilities, and additional [miniscript][topic
  miniscript] and [taproot][topic taproot] features including [tapscript][topic
  tapscript] support for up to eight leaves.

- **Frigate 1.4.0 released:**
  Frigate [v1.4.0][frigate blog], an experimental Electrum server for [silent
  payments][topic silent payments] scanning (see [Newsletter #389][news389
  frigate]), now uses the UltrafastSecp256k1 library in conjunction with modern
  GPU computation to reduce scanning time for a few months of blocks from an
  hour to half a second.

- **Bitcoin Backbone updates:**
  Bitcoin Backbone [released][backbone ml 1] multiple [updates][backbone ml 2]
  adding [BIP152][] [compact block][topic compact block relay] support,
  transaction and address management improvements, and multiprocess interface
  groundwork (see [Newsletter #368][news368 backbone]). The announcement also
  proposes Bitcoin Kernel API extensions for standalone header verification and
  transaction validation.

- **Utreexod 0.5 released:**
  Utreexod [v0.5][utreexod blog] introduces IBD using [SwiftSync][news349
  swiftsync], reducing extra data downloaded from 1.4TB to 200GB. The release
  uses Floresta 0.9, a minimal [utreexo][topic utreexo] node implementation with
  an integrated Electrum server that uses assumeutreexo for fast setup.

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

{% include snippets/recap-ad.md when="2026-04-21 16:30" %}
{% include references.md %}

[coldcard 6.5.0]: https://coldcard.com/docs/upgrade/#edge-version-650xqx-musig2-miniscript-and-taproot-support
[frigate blog]: https://damus.io/nevent1qqsrg3xsjwpt4d9g05rqy4vkzx5ysdffm40qtxntfr47y3annnfwpzgpp4mhxue69uhkummn9ekx7mqpz3mhxue69uhkummnw3ezummcw3ezuer9wcq3samnwvaz7tmjv4kxz7fwwdhx7un59eek7cmfv9kqz9rhwden5te0wfjkccte9ejxzmt4wvhxjmczyzl85553k5ew3wgc7twfs9yffz3n60sd5pmc346pdaemf363fuywvqcyqqqqqqgmgu9ev
[news389 frigate]: /en/newsletters/2026/01/23/#electrum-server-for-testing-silent-payments
[news368 backbone]: /en/newsletters/2025/08/22/#bitcoin-core-kernel-based-node-announced
[backbone ml 1]: https://groups.google.com/g/bitcoindev/c/D6nhUXx7Gnw/m/q1Bx4vAeAgAJ
[backbone ml 2]: https://groups.google.com/g/bitcoindev/c/ViIOYc76CjU/m/cFOAYKHJAgAJ
[news349 swiftsync]: /en/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download
[utreexod blog]: https://delvingbitcoin.org/t/new-utreexo-releases/2371
