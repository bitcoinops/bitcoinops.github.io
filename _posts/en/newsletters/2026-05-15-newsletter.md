---
title: 'Bitcoin Optech Newsletter #405'
permalink: /en/newsletters/2026/05/15/
name: 2026-05-15-newsletter
slug: 2026-05-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the responsible disclosure of a vulnerability
that could allow an attacker with sufficient proof-of-work to crash Bitcoin Core
nodes and describes a draft BIP proposal for sharing the UTXO set over the P2P
network. Also included are our regular sections announcing a new release
candidate and describing notable changes to popular Bitcoin infrastructure
software.

## News

- **Bitcoin Core script interpreter remote crash disclosure:**
  Niklas Gögge [posted][topic cve mailing list] to the Bitcoin-Dev mailing list
  disclosing [CVE-2024-52911][topic cve disclosure], a vulnerability affecting versions of Bitcoin Core
  after version 0.14.0 and before 29.0. After version 0.14.0 (released
  March 2017), validating a specially-crafted block could cause the node to access
  previously freed memory. During validation, data required for
  checking transaction inputs is cached. The bug occurred due to object lifetime
  ordering during parallel script validation, where cached precomputed
  transaction data could be freed before background script-check threads
  completed. For specially-crafted invalid blocks, it was possible for this data
  to be destroyed while it was still being accessed by background threads.

  An attacker with sufficient proof of work could, using the specially-crafted invalid block, crash a
  victim's node. Because of the nature of use-after-free bugs, it is possible
  to perform remote code execution on the victims' nodes, but actually executing
  that attack is unlikely due to the difficulty of crafting a block that achieves it.

  The vulnerability was discovered and [responsibly disclosed][topic responsible disclosures] by Cory Fields, who
  also provided a proof of concept and proposed mitigation. The issue was fixed
  in Bitcoin Core 29.0.

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

{% include snippets/recap-ad.md when="2026-05-19 16:30" %}
{% include references.md %}
[topic cve mailing list]: https://groups.google.com/g/bitcoindev/c/e1UEdViSYkU
[topic cve disclosure]: https://bitcoincore.org/en/2026/05/05/disclose-cve-2024-52911/
