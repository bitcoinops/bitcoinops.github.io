---
title: 'Bitcoin Optech Newsletter #413'
permalink: /en/newsletters/2026/07/10/
name: 2026-07-10-newsletter
slug: 2026-07-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes research into using fountain codes to allow
pruned nodes to contribute to initial block download. Also included are our
regular sections announcing new releases and release candidates, and describing
notable changes to popular Bitcoin infrastructure software.

## News

- **Using fountain codes for IBD**: Lucas Lima [posted][fount del] to Delving Bitcoin
  about his latest research on using [fountain codes][fount wiki] to allow pruned nodes
  to contribute to Initial Block Download (IBD), without significantly increasing their
  storage requirements.

  Lima provided a dedicated [blog post][fount blog] where he explains how this could be
  achieved by dividing the entire chain into epochs, fixed-length chunks made of `k` blocks,
  encoding these epochs using fountain codes, and sending these encodings, called droplets,
  together with block headers to those nodes that need to reconstruct the chain.
  The receiving node, referred to as a bucket node, needs to gather and decode enough droplets
  belonging to a certain epoch in order to reconstruct the `k` blocks. Block headers are then used
  to verify that the received data is valid, preventing malicious nodes from corrupting the
  reconstructed chain.

  Some critical points were raised during the discussion. In particular,
  developers highlighted the need for a high number of connected peers to manage to reconstruct
  the chain, slower IBD, risk of node fingerprinting, and possible increased DoS attack surface.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 31.1][] is a maintenance release of the predominant
  full-node implementation. It fixes an IP address leak in
  `-privatebroadcast` that could undermine [transaction origin
  privacy][topic transaction origin privacy] (see [Newsletter #409][news409
  privatebroadcast]), and includes fixes for chainstate database compaction,
  wallet migration, input-size estimation, [MuSig2][topic musig] key
  aggregation, and proxy handling during [v2 P2P transport][topic v2 p2p
  transport] reconnections. See the [release notes][bcc31.1 rn] for
  details.

- [LND v0.20.2-beta][] is a maintenance release of this popular LN node
  implementation. It fixes a DNS fallback panic and an onchain
  forward-interceptor settlement bug, and adds the final-hop [HTLC][topic
  htlc] CLTV expiry validation covered last week (see [Newsletter
  #412][news412 cltv]).

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32489][] adds an `exportwatchonlywallet` RPC that exports a
  watch-only version of the currently loaded wallet to a new wallet file,
  which can be loaded on another node using the `restorewallet` RPC (see
  Newsletter [#366][news366 watchonly]). The exported wallet contains the
  original wallet's public [descriptors][topic descriptors], transactions,
  labels, and other metadata, but not private keys. Previously, users had to
  manually construct such a wallet by importing public descriptors.

- [Bitcoin Core #32606][] updates [compact block relay][topic compact block
  relay] to ignore compact block messages from peers that have not
  negotiated support with `sendcmpct`, from peers not selected by the node
  for high-bandwidth announcements with `sendcmpct(1)`, and whenever the
  local node is running in `-blocksonly` mode. Since compact blocks are
  reconstructed using transactions from the receiver’s mempool, processing
  them can reveal which transactions the receiver is missing or already has.
  This is particularly undesirable for blocks-only nodes because the
  transactions in their mempools are more likely to have originated locally.

- [Bitcoin Core #34020][] adds the `getTransactionsByTxID()` and
  `getTransactionsByWitnessID()` methods to the Mining IPC interface (see
  Newsletters [#310][news310 mining] and [#323][news323 mining]). Each
  method takes a list of txids or wtxids and returns the corresponding
  serialized transactions from the node's mempool, or empty elements for
  transactions it doesn't know about. This is useful for [Stratum v2][topic
  pooled mining] custom job declaration, where a pool may want to request
  only those transactions from a miner-proposed block template that it
  doesn't already have.

- [Core Lightning #9104][] and [#9292][core lightning #9292] add
  experimental support for the `option_simple_close` cooperative close
  protocol (see [Newsletter #342][news342 simpleclose]). Legacy cooperative
  closes require peers to agree on a single closing transaction and fee, and
  if they disagree, the close can get stuck. Simple close avoids this issue
  by enabling each peer to propose a valid closing transaction that
  subtracts their chosen fee from their own output. Both versions can be
  signed and broadcast, and whichever conflicting transaction confirms first
  closes the channel. CLN implements this flow in a new `simpleclosed`
  subdaemon, that delays broadcasting its own version when the peer’s
  version pays a higher fee. [#9292][core lightning #9292] fixes an edge
  case where CLN rejected a signed simple-close transaction that replaced
  the closer’s uneconomical output with a permitted zero-value `OP_RETURN`,
  causing a force close.

- [Eclair #3323][] fails incoming [HTLCs][topic htlc] whose CLTV expiry is
  more than 2016 blocks (approximately two weeks) in the future. This
  extends Eclair’s existing maximum expiry policy for outgoing HTLCs, which
  reduces the risk of funds being locked for an extended period and makes
  [channel jamming][topic channel jamming attacks] harder. Eclair
  temporarily accepts an offending HTLC into the channel commitment and then
  fails it, since rejecting it outright would force close the channel.

- [LND #10832][] continues LND’s implementation of [BOLT12 offers][topic
  offers] by adding support for `InvoiceRequest` messages (see [Newsletter
  #410][news410 bolt12]). The new code adds TLV encoding, decoding, and
  structural validation, while deferring signature verification and
  cross-checking against the corresponding offer to subsequent PRs.

{% include snippets/recap-ad.md when="2026-07-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32489,32606,34020,9104,9292,3323,10832" %}
[fount del]: https://delvingbitcoin.org/t/fountain-codes-a-way-to-reduce-blockchain-storage-costs/2624
[fount wiki]: https://en.wikipedia.org/wiki/Fountain_code
[fount blog]: https://lucasdbr05.com/posts/fountain-codes/
[Bitcoin Core 31.1]: https://bitcoincore.org/bin/bitcoin-core-31.1/
[bcc31.1 rn]: https://bitcoincore.org/en/releases/31.1/
[LND v0.20.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.2-beta
[news366 watchonly]: /en/newsletters/2025/08/08/#bitcoin-core-pr-review-club
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /en/newsletters/2024/10/04/#bitcoin-core-30510
[news342 simpleclose]: /en/newsletters/2025/02/21/#bolts-1205
[news410 bolt12]: /en/newsletters/2026/06/19/#lnd-10789
[news409 privatebroadcast]: /en/newsletters/2026/06/12/#bitcoin-core-35410
[news412 cltv]: /en/newsletters/2026/07/03/#lnd-10927