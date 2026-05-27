---
title: 'Bitcoin Optech Newsletter #407'
permalink: /en/newsletters/2026/05/29/
name: 2026-05-29-newsletter
slug: 2026-05-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the responsible disclosure of a vulnerability
that allowed a remote peer to crash Core Lightning nodes and links to
transcripts from a recent Bitcoin Core developer meeting. Also included are our
regular sections announcing new releases and release candidates and describing
notable changes to popular Bitcoin infrastructure software.

## News

- **Core Lightning assertion DoS disclosure:** Chandra Pratap [posted][cln dos
  delving] to Delving Bitcoin disclosing a denial-of-service vulnerability
  discovered during a Summer of Bitcoin 2025 internship. The vulnerability
  affected Core Lightning nodes that accept incoming channels.

  During the channel-opening handshake, a remote peer sends a message
  containing the txid of the proposed funding transaction. Core Lightning
  performed an assertion check requiring a non-zero txid. When a peer sent an
  all-zero txid instead, the assertion failed and crashed the node. Since any
  peer can initiate a channel-opening handshake and send the malicious
  message, this allowed a remote attacker to reliably crash any vulnerable node
  that accepted inbound channels.

  The vulnerability was [responsibly disclosed][topic responsible disclosures]
  and discovered through fuzzing. At the time of the report, Rusty Russell had
  independently been working on a separate crash bug and his fix incidentally
  resolved this vulnerability as well. The vulnerability was fixed in [Core
  Lightning 26.04][news402 cln2604].

- **Bitcoin Core developer meeting transcripts:** many Bitcoin Core
  developers met in person in May, and transcripts from the meeting have
  been [published][coredev 2026-05]. Topics included
  [SwiftSync][coredev swiftsync], [post-cluster mempool][coredev post-cluster],
  an [Erlay redesign][coredev erlay], [package relay][coredev pkg relay],
  [silent payments][coredev silent payments], [TCP hole punching][coredev tcp holepunch]
  (see [Newsletter #406][news406 tcp holepunch]),
  [private broadcast][coredev private broadcast], a [modern crypto
  library][coredev modern crypto], and [mutation testing][coredev mutation
  testing], among others.

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

{% include snippets/recap-ad.md when="2026-06-02 16:30" %}
{% include references.md %}
[cln dos delving]: https://delvingbitcoin.org/t/vulnerability-disclosure-assertion-dos-in-core-lightning/2507
[news402 cln2604]: /en/newsletters/2026/04/24/#core-lightning-26-04
[coredev 2026-05]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05
[coredev swiftsync]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/swiftsync
[coredev post-cluster]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/post-cluster-mempool
[coredev erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/erlay-redesign
[coredev pkg relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/package-relay
[coredev silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/silent-payments
[coredev tcp holepunch]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/tcp-holepunch
[news406 tcp holepunch]: /en/newsletters/2026/05/22/#tcp-hole-punching-for-bitcoin-nodes-behind-nats
[coredev private broadcast]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/private-broadcast
[coredev modern crypto]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/modern-crypto-library
[coredev mutation testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/mutation-testing
