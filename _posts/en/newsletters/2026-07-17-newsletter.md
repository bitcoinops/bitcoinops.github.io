---
title: 'Bitcoin Optech Newsletter #414'
permalink: /en/newsletters/2026/07/17/
name: 2026-07-17-newsletter
slug: 2026-07-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new project to apply formal verification to the
Bitcoin protocol. Also included are our regular sections announcing new releases
and release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Formal verification of the Bitcoin protocol**: Keagan McClelland [posted][verif ml]
  to the Bitcoin-Dev mailing list and [Delving Bitcoin][verif del] about his effort to
  formally verify the Bitcoin protocol. Formal verification is a software development
  practice that aims to prove the correctness of a system with respect to a
  specification using the formal methods of mathematics. This could help resolve
  factual disputes about proposed changes to Bitcoin's consensus rules. Optech
  previously covered a related project developing a declarative executable
  specification of Bitcoin's consensus rules (see [Newsletter #402][news402 hornet]).

  McClelland is developing [btc-verified][verif gh], a [Lean4][lean lang]
  implementation of the verification process. The author provided initial results
  demonstrating the approach. In particular, he focused on the algorithm Bitcoin uses
  to compute the merkle root, which contains a known flaw ([CVE-2012-2459][topic cves])
  that can cause two different transaction lists to produce the same
  [merkle root][topic merkle tree vulnerabilities]. Bitcoin Core's merkle-root
  construction includes a check meant to detect this mutation. McClelland used
  btc-verified to formally prove that the check is correct and that no two distinct
  transaction lists can pass it and produce the same merkle root under the assumption
  that SHA256 is collision resistant.

  Finally, the author asked for feedback from others both on the repository and
  on the general approach. He also provided some disclaimers, such as the heavy use
  of AI in the repository, and the current immaturity of the project.

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

{% include snippets/recap-ad.md when="2026-07-21 16:30" %}
{% include references.md %}

[verif ml]: https://groups.google.com/g/bitcoindev/c/OIml9stwbGQ
[verif del]: https://delvingbitcoin.org/t/btc-verified-formalizing-the-bitcoin-protocol/2684
[verif gh]: https://github.com/ProofOfKeags/btc-verified
[lean lang]: https://lean-lang.org/
[news402 hornet]: /en/newsletters/2026/04/24/#hornet-node-s-declarative-executable-specification-of-bitcoin-consensus-rules
