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

- [Bitcoin Core #29136][] adds an `addhdkey` RPC that imports a specified
  [BIP32][] extended private key, or generates one if none is specified,
  without using it to produce any output scripts. This allows a wallet to
  store a signing key for future use (e.g. for a multisig script), without
  immediately generating addresses from it. The PR also adds a new
  `unused(KEY)` [descriptor][topic descriptors] type, which is returned by
  `listdescriptors`, so the stored key can be included in wallet backups.

- [Bitcoin Core #34893][] updates the `combinepsbt` RPC to preserve [BIP174][]
  proprietary fields (see Newsletters [#72][news72 psbt] and
  [#181][news181 psbt]) when combining [PSBTs][topic psbt]. Previously,
  `combinepsbt` would silently drop the proprietary fields, resulting in the
  loss of application-specific PSBT metadata. The `decodepsbt` RPC already
  parses, serializes, and displays those fields properly.

- [Bitcoin Core #34860][] removes the `include_dummy_extranonce` option from
  the `CreateNewBlock()` method (see Newsletter [#392][news392 mining]).
  Bitcoin Core now always appends dummy padding to the internal coinbase
  scriptSig when creating blocks at heights 0 through 16, where the [BIP34][]
  height encoding alone is too short to satisfy the consensus minimum
  scriptSig length. However, the padding is not included in the
  `scriptSigPrefix` field of the `CoinbaseTx` struct exposed to [Stratum
  V2][topic pooled mining] clients connected through the Mining IPC interface
  (see Newsletter [#310][news310 ipc] and [#388][news388 ipc]).

- [Bitcoin Core #31298][] updates the `combinerawtransaction` RPC to reject
  unrelated transactions, instead of silently returning the first one and not
  reporting that they could not be merged. Bitcoin Core now strips input
  scriptSigs and witnesses from each transaction, compares the resulting
  unsigned transaction hashes, and returns an error if they do not match.

- [Bitcoin Core #28802][] adds support for command-specific options to
  `ArgsManager`, Bitcoin Core's CLI argument parser. Commands can now declare
  which options apply to them, allowing `ArgsManager` to list those options
  under the relevant command's help output and automatically reject invalid
  command-option combinations. The PR applies this to `bitcoin-wallet`'s (see
  [Newsletter #32][news32 dump]) `-dumpfile` option, which is now registered
  only for the `dump` and `createfromdump` commands.

- [Eclair #3298][] updates its internal [RBF][topic rbf] logic to follow the
  new [BOLT2][] feerate bump rule, which is designed to ensure compliance with
  [BIP125][]'s replacement rules at low feerates. Instead of only applying the
  previous 25/24 feerate multiplier, Eclair now uses whichever is larger: that
  multiplier or an additional 25 sat/kw. This matches the LDK behavior covered
  in Newsletter [#400][news400 rbf] and the BOLT specification update covered
  in Newsletter [#404][news404 rbf].

- [LDK #4575][] adds a `splice_in_inputs` API that allows users to manually
  select UTXOs when [splicing][topic splicing] funds into a channel. The
  selected UTXOs are fully consumed, with their value minus fees added to the
  channel, and no change output is created. This complements the existing
  amount-based splice-in flow, in which the caller specifies the amount to be
  added and the wallet selects the inputs. However, the two input selection
  flows cannot be mixed in the same funding contribution.

- [LND #10814][] removes the deprecated `SendPayment`, `SendPaymentSync`,
  `SendToRoute`, `SendToRouteSync`, and `TrackPayment` endpoints, which were
  scheduled for removal in version 0.21 (see Newsletter [#340][news340 lnd]).
  Callers should use the V2 replacements: `SendPaymentV2`, `SendToRouteV2`,
  and `TrackPaymentV2`. The PR also removes the deprecated single-channel
  `outgoing_chan_id` field, requiring callers to use the multi-channel
  `outgoing_chan_ids` field (see [Newsletter #33][news33 lnd]).

- [Rust Bitcoin #6191][] adds support for encoding and decoding the
  `sendtxrcncl` P2P message used for [Erlay][topic erlay] transaction
  reconciliation. Bitcoin Core added support for this message as an early part
  of Erlay support (see Newsletter [#223][news223 erlay]). However, full Erlay
  transaction reconciliation is not yet implemented.

- [BLIPs #42][] adds [BLIP42][], a specification for [BOLT12][] contacts.
  Since [BOLT12 offers][topic offers] can be reused as static Lightning payment
  instructions, wallets can store offers as contacts. The BLIP defines optional
  `invoice_request` fields that payers can include when making outgoing
  payments to a contact, such as a contact secret, their own offer, or a
  [BIP353][] name. This allows recipients to recognize payments from known
  contacts, add new contacts, and send funds back to the payer without
  additional interaction.

{% include snippets/recap-ad.md when="2026-05-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29136,34893,34860,31298,28802,3298,4575,10814,6191,42" %}
[ibis wallet]: https://github.com/aeonBTC/IbisWallet
[ldk server]: https://github.com/lightningdevkit/ldk-server
[mempool v3.3.0]: https://github.com/mempool/mempool/releases/tag/v3.3.0
[peer-observer delving]: https://delvingbitcoin.org/t/peer-observer-a-tool-and-infrastructure-for-monitoring-the-bitcoin-p2p-network-for-attacks-and-anomalies/1988/4
[peer-observer site]: https://public.peer.observer/
[news72 psbt]: /en/newsletters/2019/11/13/#bips-849
[news181 psbt]: /en/newsletters/2022/01/05/#bitcoin-core-17034
[news392 mining]: /en/newsletters/2026/02/13/#bitcoin-core-32420
[news310 ipc]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news388 ipc]: /en/newsletters/2026/01/16/#bitcoin-core-33819
[news32 dump]: /en/newsletters/2019/02/05/#bitcoin-core-13926
[news400 rbf]: /en/newsletters/2026/04/10/#ldk-4494
[news404 rbf]: /en/newsletters/2026/05/08/#bolts-1327
[news340 lnd]: /en/newsletters/2025/02/07/#lnd-9456
[news33 lnd]: /en/newsletters/2019/02/12/#lnd-2572
[news223 erlay]: /en/newsletters/2022/10/26/#bitcoin-core-23443
