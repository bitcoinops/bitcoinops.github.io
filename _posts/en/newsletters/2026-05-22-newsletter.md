---
title: 'Bitcoin Optech Newsletter #406'
permalink: /en/newsletters/2026/05/22/
name: 2026-05-22-newsletter
slug: 2026-05-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a discussion of updates to BIP322's generic
signed message format and describes an idea to use TCP hole punching to help
Bitcoin nodes behind NATs accept inbound connections. Also included are our
regular sections describing recent changes to services and client software and
summarizing notable changes to popular Bitcoin infrastructure software.

## News

FIXME:bitschmidty

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Ibis Wallet announced:**
  [Ibis Wallet][ibis wallet] is an Android wallet built on BDK supporting coin
  control, [RBF][topic rbf] and [CPFP][topic cpfp] fee management, multisig,
  hardware signing device integration using QR codes, [silent payments][topic
  silent payments], and [Tor][topic anonymity networks] integration. It also
  supports optional second layers, including Spark, Liquid, and, in the future,
  [Ark][topic ark].

- **LDK Server announced:**
  Spiral announced [LDK Server][ldk server], an API-first Lightning node daemon
  built on LDK Node for payment processors and wallet providers. It provides a gRPC
  interface, an embedded BDK-based wallet, and a Model Context Protocol (MCP)
  server for AI-agent interactions with the node.

- **Mempool.space v3.3.0 released:**
  Mempool [v3.3.0][mempool v3.3.0] adds [taproot][topic taproot] script tree
  visualizations, updated [PSBT][topic psbt] previews, improvements to [fee
  estimation][topic fee estimation], [ephemeral dust][topic ephemeral anchors]
  support, stale block comparisons, sighash icons, and a merkle-proof API, among
  other features.

- **peer-observer P2P monitoring tooling:**
  0xB10C [outlined][peer-observer delving] some open-source components used by his
  [peer-observer][peer-observer site] platform, including infrastructure for
  extracting events from Bitcoin Core nodes using IPC, logs, P2P, and
  RPC sources. He also describes ongoing development around archiving, anomaly
  detection, and alerting tools.

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

{% include snippets/recap-ad.md when="2026-05-26 16:30" %}
{% include references.md %}
[ibis wallet]: https://github.com/aeonBTC/IbisWallet
[ldk server]: https://github.com/lightningdevkit/ldk-server
[mempool v3.3.0]: https://github.com/mempool/mempool/releases/tag/v3.3.0
[peer-observer delving]: https://delvingbitcoin.org/t/peer-observer-a-tool-and-infrastructure-for-monitoring-the-bitcoin-p2p-network-for-attacks-and-anomalies/1988/4
[peer-observer site]: https://public.peer.observer/
