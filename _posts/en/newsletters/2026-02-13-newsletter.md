---
title: 'Bitcoin Optech Newsletter #392'
permalink: /en/newsletters/2026/02/13/
name: 2026-02-13-newsletter
slug: 2026-02-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion of improving worst-case silent
payment scanning performance and describes an idea for enabling many spending
conditions in a single key.  Also included are our regular sections announcements
of new releases and release candidates and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Proposal to limit the number of per-group silent payment recipients**: Sebastian
  Falbesoner [posted][kmax mailing list] to the Bitcoin-Dev mailing list the discovery and
  mitigation of a theoretical attack on [silent
  payment][topic silent payments] recipients. The attack occurs when an adversary
  constructs a transaction with a large number of taproot outputs (23255 max outputs per
  block according to current consensus rules) that all target the same entity.
  If there were no limit on group size, it would take several minutes
  to process, rather than tens of seconds.

  This motivated a mitigation to add a new parameter, `K_max`, that limits the
  number of per-group recipients within a single transaction. In theory, this
  change would not be backward-compatible, but in practice, none of the
  existing silent payment wallets should be affected
  for a sufficiently high `K_max`. Falbesoner is proposing `K_max=1000`.

  Falbesoner is seeking feedback or concerns about the proposed restriction. He
  also notes that most silent payment wallet developers have been notified and
  are aware of the issue.

- **BLISK, Boolean circuit Logic Integrated into the Single Key**: Oleksandr
  Kurbatov [posted][blisk del] to Delving Bitcoin about BLISK, a protocol
  designed to express complex authorization policies using boolean logic.
  BLISK tries to address the limitations of current spending policies. For example,
  protocols like [MuSig2][topic musig], though efficient and privacy-preserving,
  can only express cardinality (k-of-n) but cannot identify "who" can spend.

  BLISK creates a simple AND/OR boolean circuit, mapping logical gates to
  well-known cryptographic techniques. In particular, AND gates are obtained by
  applying an n-of-n multisignature setup, in which each participant must contribute a
  valid signature. On the other end, OR gates are obtained by leveraging key agreement
  protocols, such as [ECDH][ecdh wiki], in which any participant can derive a shared
  secret using their private key and the other participant's public key. It also applies
  a [Non-interactive Zero Knowledge proof][nizk wiki] to make circuit resolution
  verifiable and to prevent cheating.
  BLISK resolves the circuit to a single signature verification key. This means
  that only a single [Schnorr][topic schnorr signatures] signature must be verified
  against one public key.

  Another important advantage of BLISK with respect to other approaches is
  eliminating the need to generate a fresh key pair. In fact, it allows connecting an
  existing key to the specific signature instance.

  Kurbatov provided a [proof-of-concept][blisk gh] for the protocol, although he stated
  that the framework has not reached production maturity yet.

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

{% include snippets/recap-ad.md when="2026-02-17 17:30" %}
{% include references.md %}
[kmax mailing list]: https://groups.google.com/g/bitcoindev/c/tgcAQVqvzVg
[blisk del]: https://delvingbitcoin.org/t/blisk-boolean-circuit-logic-integrated-into-the-single-key/2217
[ecdh wiki]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[nizk wiki]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[blisk gh]: https://github.com/zero-art-rs/blisk
