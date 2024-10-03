---
title: 'Bitcoin Optech Newsletter #323'
permalink: /en/newsletters/2024/10/04/
name: 2024-10-04-newsletter
slug: 2024-10-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a planned security disclosure and
includes our regular sections describing new releases, release
candidates, and notable changes to popular Bitcoin infrastructure
software.

## News

- **Impending btcd security disclosure:** Antoine Poinsot
  [posted][poinsot btcd] to Delving Bitcoin to announce the planned
  disclosure on October 10th of a consensus bug affecting the btcd full
  node.  Using data from a rough survey of active full nodes, Poinsot
  surmises that there about 36 btcd nodes that are vulnerable (although
  20 of those nodes are also vulnerable to an already disclosed
  consensus vulnerability, see [Newsletter #286][news286 btcd vuln]).
  In a [reply][osuntokun btcd], btcd maintainer Olaoluwa Osuntokun
  confirmed the existence of the vulnerability and that it was fixed in
  btcd version 0.24.2.  Anyone running an older version of btcd is
  encouraged to upgrade to the [latest release][btcd v0.24.2], which was
  already announced as security critical.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 28.0][] is the latest major release of the predominant
  full node implementation.  It's the first release to include support
  for [testnet4][topic testnet], opportunistic one-parent-one-child
  (1p1c) [package relay][topic package relay], default relay of opt-in
  topologically restricted until confirmation ([TRUC][topic v3
  transaction relay]) transactions, default relay of
  [pay-to-anchor][topic ephemeral anchors] transactions, limited package
  [RBF][topic rbf] relay, and default [full-RBF][topic rbf].  Default
  parameters for [assumeUTXO][topic assumeutxo] have been added,
  allowing the `loadtxoutset` RPC to be used with a UTXO set downloaded
  outside of the Bitcoin network (e.g. via a torrent).  The release also
  includes many other improvements and bug fixes, as described in its
  [release notes][bcc 28.0 rn].

- [BDK 1.0.0-beta.5][] is a release candidate (RC) of this library for
  building wallets and other Bitcoin-enabled applications.  This latest
  RC "enables RBF by default, updates the bdk_esplora client to retry
  server requests that fail due to rate limiting. The `bdk_electrum`
  crate now also offers a use-openssl feature."

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30043][] introduces a built-in implementation of the [Port
  Control Protocol (PCP)][rfcpcp] to support IPv6 pinholing, allowing nodes to
  become reachable without manual configuration on the router. This update
  replaces the existing `libnatpmp` dependency for IPv4 port mapping with PCP,
  while also implementing a fallback mechanism to the [NAT Port Mapping Protocol
  (NAT-PMP)][rfcnatpmp]. Although the PCP / NAT-PMP functionality is disabled by
  default, this may change in future releases. See Newsletter [#131][news131
  natpmp].

- [Bitcoin Core #30510][] adds an inter-process communication (IPC) wrapper to
  the `Mining` interface (See Newsletter [#310][news310 stratumv2]) to allow a
  separate [Stratum v2][topic pooled mining] mining process to create, manage,
  and submit block templates by connecting to and controlling the `bitcoin-node`
  process (see Newsletter [#320][news320 stratumv2]). [Bitcoin Core #30409][]
  extends the `Mining` interface with a new `waitTipChanged()` method that
  detects when a new block arrives and then pushes new block templates to
  connected clients. The `waitfornewblock`, `waitforblock` and
  `waitforblockheight` RPC methods have been refactored to use it.

- [Core Lightning #7644][] adds a `nodeid` command to the `hsmtool` utility
  which returns the node identifier for a given `hsm_secret` backup file, to
  match the backup to its specific node and to avoid confusion with other nodes.

- [Eclair #2848][] implements extensible [liquidity advertisements][topic
  liquidity advertisements] as specified in the proposed [BOLTs #1153][], which
  allows sellers to advertise rates at which they are willing to sell liquidity
  to buyers in their `node_announcement` message, and then buyers can connect
  and request liquidity. This can be used when creating a [dual-funded
  channel][topic dual funding], or when adding additional liquidity to an
  existing channel via [splicing][topic splicing].

- [Eclair #2860][] adds an optional `recommended_feerates` message for nodes to
  inform their peers of acceptable fee rates they wish to use for funding
  channel transactions. If a node rejects a peer's funding requests, the peer
  will understand that this was due to the fee rates.

- [Eclair #2861][] implements on-the-fly funding as specified in [BLIPs
  #36][], allowing clients without sufficient inbound liquidity to request
  additional liquidity from a peer via the [liquidity advertisements][topic
  liquidity advertisements] protocol (see PR above) in order to receive a
  payment. The liquidity seller covers the on-chain transaction fee for the
  [dual-funded channel][topic dual funding] or [splicing][topic
  splicing] transaction, but is later paid by the buyer when the
  payment is routed. If the amount isn't sufficient enough to cover the on-chain
  fee required for the transaction to confirm, the seller can double-spend it to
  use their liquidity elsewhere.

- [Eclair #2875][] implements funding fee credits as specified in [BLIPs #41][],
  allowing on-the-fly funding (see PR above) clients to accept payments that are
  too small to cover the on-chain fees for a channel. Once sufficient fee
  credits have been accumulated, an on-chain transaction such as a channel
  funding or [splice][topic splicing] is created using the fee credits. Clients
  rely on liquidity providers to honour the fee credits in future transactions.

- [LDK #3303][] adds a new `PaymentId` for inbound payments to improve
  idempotent event handling. This allows users to easily check if an event has
  already been handled when replaying events during node restarts. The risk of
  duplicate processing that was possible when relying on the `PaymentHash` is
  eliminated. The `PaymentId` is a hash-based message authentication code (HMAC)
  of the [HTLC][topic htlc] channel identifier and HTLC identifier pairs
  included in the payment.

- [BDK #1616][] signals opt-in [RBF][topic rbf] by default in the
  `TxBuilder` class.  The caller can disable the signal by changing the
  sequence number.

- [BIPs #1600][] makes several changes to the [BIP85][] specification, including
  specifying that `drng_reader.read` (responsible for reading random numbers) is
  a first-class function rather than an evaluation. This update also clarifies
  endianness handling, adds support for [testnet][topic testnet], includes a new
  reference implementation in Python, clarifies that an [HD wallet][topic bip32]
  seed wallet import format (WIF) uses the most significant bits, adds the
  Portuguese language code, and corrects test vectors. Finally, a new champion
  for the BIP specification has been designated.

- [BOLTs #798][] merges the [offers][topic offers] protocol specification which
  introduces [BOLT12][], and also brings several updates to [BOLT1][] and
  [BOLT4][].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30043,30510,7644,2875,2861,2860,2848,3303,1616,1600,798,30409,1153,36,41" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[bitcoin core 28.0]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[poinsot btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177
[osuntokun btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177/3
[news286 btcd vuln]: /en/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd
[btcd v0.24.2]: https://github.com/btcsuite/btcd/releases/tag/v0.24.2
[bcc 28.0 rn]: https://github.com/bitcoin/bitcoin/blob/5de225f5c145368f70cb5f870933bcf9df6b92c8/doc/release-notes.md
[rfcpcp]: https://datatracker.ietf.org/doc/html/rfc6887
[rfcnatpmp]: https://datatracker.ietf.org/doc/html/rfc6886
[news131 natpmp]: /en/newsletters/2021/01/13/#bitcoin-core-18077
[news310 stratumv2]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news320 stratumv2]: /en/newsletters/2024/09/13/#bitcoin-core-30509
