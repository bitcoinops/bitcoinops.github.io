---
title: 'Bitcoin Optech Newsletter #381'
permalink: /en/newsletters/2025/11/21/
name: 2025-11-21-newsletter
slug: 2025-11-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter looks at an analysis of how block propagation times may
affect miner revenue and describes a new approach for resolving protocols where
multiple parties share funds. Also included are our regular sections describing
recent changes to services and client software and summarizing recent merges to
popular Bitcoin infrastructure software.

## News

- **Modeling stale rates by propagation delay and mining centralization:**
  Antoine Poinsot [posted to Delving Bitcoin][antoine delving] about modeling
  stale block rates and how block propagation time affects a miner's revenue as
  a function of its hashrate. He set up a
  base-case scenario in which all miners act realistically (with a default
  Bitcoin Core node): if they receive a new block, they would immediately start
  mining on top of it and publish it. This would lead to revenue proportional to
  their share of the hashrate given propagation time is zero.

  In his model with uniform block propagation, he outlined two situations in which a
  block goes stale.

  1. Another miner found a block **before** this miner did. All other miners received
     the competing miner's block first and started mining on top of it. Any of
     these miners can then find a second block based on the received block.

  2. Another miner finds a block **after** this miner did. It immediately starts mining
     on top of it. The following block is also found by the same miner.

  Poinsot points out that, between these situations, it is more likely for a
  block to become stale in the first situation. This suggests that miners may
  care more about hearing others' blocks faster than they care about publishing
  their own. He also suggests that the probability of situation 2 increases
  significantly with miner centralization. While in both situations the
  probability increases as miner hashrate increases, Poinsot wanted to compute
  by how much.

  To do this, he created the following two models.

  Where **h** is the share of network hashrate, **s** is the number of seconds
  the rest of the network found a competing block before it did, **H** is the
  set of hashrates on the network representing its distribution.

  Model for situation 1:
  ![Illustration of P(another miner found a block before)](/img/posts/2025-11-stale-rates1.png)

  Model for situation 2:
  ![Illustration of P(another miner found a block after)](/img/posts/2025-11-stale-rates2.png)

  He went on to show graphs of probabilities that a miner's block goes stale as
  a function of propagation times, given the set distribution of hashrate. The
  graphs show how larger miners gain significantly more the longer the
  propagation time is.

  For example a mining operation with 5EH/s can expect a revenue of $91M and if
  blocks took 10 seconds to propogate the revenue would be increased by $100k.
  Keep in mind that the $91M is revenue and not profit so the increased revenue
  of $100k would contribute to a larger factor in terms of miner's net profit.

  Below the charts, he provides the methodology for generating the charts and a
  link to his [simulation][block prop simulation] which corroborates the
  results of the model used to generate the graphs. {% assign timestamp="1:03" %}

- **Private key handover for collaborative closure**: ZmnSCPxj [posted][privkeyhand post] to Delving
  Bitcoin about private key handover, an optimization that protocols can
  implement when funds, previously owned by two parties, need to be refunded to
  a single entity. This enhancement requires [taproot][topic taproot] and
  [MuSig2][topic musig] support to work in the most efficient way.

  An example of such a protocol would be an [HTLC][topic htlc], where one party
  pays the other if the preimage is revealed, creating a refunding transaction
  that needs to be signed by both parties. Private key handover would allow an
  entity to simply handover an ephemeral private key to the other after the
  preimage has been revealed, thus giving the receiver complete and unilateral
  access to the funds.

  The steps to achieve a private key handover are:

  - When setting up an HTLC, Alice and Bob each exchange an ephemeral and a
    permanent public key.

  - The keypath spend branch of the HTLC taproot output is computed as the
    MuSig2 of Alice and Bob's ephemeral public keys.

  - At the end of the protocol operations, Bob provides the preimage to Alice,
    who in turn hands him over the ephemeral private key.

  - Bob can now derive the combined private key for the MuSig2 sum, gaining full
    control over the funds.

  This optimization brings some particular benefits. First of all, in case of a
  sudden spike in onchain fees, Bob would be able to [RBF][topic rbf] the
  transaction without the other party's collaboration. This feature is
  particularly useful for protocol developers, since they would not need to
  implement RBF in a simple proof of concept. Second, the receiver would be
  able to batch the transaction claiming the funds with any other operation.

  Private key handover is limited to protocols that require the remaining funds
  to be transferred entirely to a single beneficiary. Thus, [splicing][topic
  splicing] or cooperative closure of Lightning channels would not benefit from
  this. {% assign timestamp="30:55" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Arkade launches:**
  [Arkade][ark labs blog] is an [Ark protocol][topic ark] implementation which
  also includes multiple programming language SDKs, a wallet, a BTCPayServer
  plugin, and other features. {% assign timestamp="52:32" %}

- **Mempool monitoring mobile application:**
  The [Mempal][mempal gh] Android application provides various metrics and
  alerts about the Bitcoin network, sourcing data from a self-hosted mempool server. {% assign timestamp="55:25" %}

- **Web-based policy and miniscript IDE:**
  [Miniscript Studio][miniscript studio site] provides an interface for
  interacting with [miniscript][topic miniscript] and the policy language. A
  [blog post][miniscript studio blog] describes the features and the
  [source][miniscript studio gh] is available. {% assign timestamp="56:25" %}

- **Phoenix Wallet adds taproot channels:**
  Phoenix Wallet [added][phoenix post] support for [taproot][topic taproot]
  channels, a migration workflow for existing channels, and multi-wallet
  features. {% assign timestamp="57:45" %}

- **Nunchuk 2.0 launches:**
  [Nunchuk 2.0][nunchuk blog] supports wallet configurations using multisig,
  [timelocks][topic timelocks], and miniscript. It also includes degrading
  multisig features. {% assign timestamp="59:19" %}

- **LN gossip traffic analysis tool announced:**
  [Gossip Observer][gossip observer gh] collects Lightning Network gossip
  messages from multiple nodes and provides summary metrics. The results may
  inform a [minisketch][topic minisketch]-like set reconciliation protocol for
  Lightning. A [Delving Bitcoin topic][gossip observer delving] includes
  discussion about the approach. {% assign timestamp="1:01:49" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33745][] ensures that blocks submitted by an external
  [StratumV2][topic pooled mining] client via the new mining inter-process
  communication (IPC) `submitSolution()` interface (see [Newsletter
  #325][news325 ipc]) have their witness commitment revalidated. Previously,
  Bitcoin Core only checked for this during  the original template construction,
  which allowed a block with an invalid or missing witness commitment to be
  accepted as the best chain tip. {% assign timestamp="1:04:23" %}

- [Core Lightning #8537][] sets the `maxparts` limit (see [Newsletter
  #379][news379 parts]) on `xpay` to six when first trying to pay a non-publicly
  reachable node using [MPP][topic multipath payments]. This conforms to the
  reception limit of six [HTLCs][topic htlc] on Phoenix-based nodes for
  on-the-fly funding (see [Newsletter #323][news323 fly]), a type of [JIT
  channel][topic jit channels]. If routing fails under that cap, `xpay` removes
  the limit and retries. {% assign timestamp="1:09:28" %}

- [Core Lightning #8608][] introduces node-level biases to `askrene` (see
  [Newsletter #316][news316 askrene]), alongside existing channel biases. A new
  `askrene-bias-node` RPC command is added to favor or disfavor all outgoing or
  incoming channels of a specified node. A `timestamp` field is added to biases
  so that they expire after a certain period. {% assign timestamp="1:11:26" %}

- [Core Lightning #8646][] updates the reconnection logic for [spliced][topic
  splicing] channels, aligning it with the proposed specification changes in
  [BOLTs #1160][] and [BOLTs #1289][]. Specifically, it enhances the
  `channel_reestablish` TLVs so that peers can reliably synchronize splice state
  and communicate what needs to be retransmitted. This update is a breaking
  change for spliced channels, so both sides must upgrade simultaneously to
  avoid disruptions. See [Newsletter #374][news374 ldk] for a similar change in
  LDK. {% assign timestamp="1:13:34" %}

- [Core Lightning #8569][] adds experimental support for [JIT channels][topic
  jit channels], as specified by [BLIP52][] (LSPS2), in the `lsp-trusts-client` mode and
  without [MPP][topic multipath payments] support. This feature is gated behind
  the `experimental-lsps-client` and `experimental-lsps2-service` options and it
  represents the first step toward providing full support for JIT channels. {% assign timestamp="1:17:44" %}

- [Core Lightning #8558][] adds a `listnetworkevents` RPC command, which
  displays the history of peer connections, disconnections, failures, and ping
  latencies. It also introduces an `autoclean-networkevents-age` config option
  (default 30 days) to control how long network event logs are kept. {% assign timestamp="1:22:46" %}

- [LDK #4126][] introduces `ReceiveAuthKey`-based authentication verification on
  [blinded payment paths][topic rv routing], replacing the older per-hop
  HMAC/nonce scheme (see [Newsletter #335][news335 hmac]). This builds on [LDK
  #3917][], which added `ReceiveAuthKey` for blinded message paths. Reducing the
  per-hop data shrinks the payload and paves the way for dummy payment hops in a
  future PR, similar to the dummy message hops (see [Newsletter #370][news370
  dummy]). {% assign timestamp="1:24:11" %}

- [LDK #4208][] updates its weight estimation to consistently assume 72-byte
  DER-encoded signatures, instead of using 72 in some places and 73 in others.
  73-byte signatures are non-standard and LDK never produces them. See
  [Newsletter #379][news379 sign] for a related change in Eclair. {% assign timestamp="1:26:37" %}

- [LND #9432][] adds a new global `upfront-shutdown-address` configuration
  option, which specifies a default Bitcoin address for cooperative channel
  closures, unless overridden when opening or accepting a specific channel. This
  builds on the upfront shutdown feature specified in [BOLT2][]. See [Newsletter
  #76][news76 upfront] for previous coverage on LND’s implementation. {% assign timestamp="1:27:58" %}

- [BOLTs #1284][] updates BOLT11 to clarify that when an `n` field is present in
  an invoice, the signature must be in normalized lower-S form, and when it is
  absent, public key recovery may accept either high-S and low-S signatures. See
  Newsletters [#371][news371 eclair] and [#373][news373 ldk] for recent LDK and
  Eclair changes that implement this behavior. {% assign timestamp="1:31:38" %}

- [BOLTs #1044][] specifies the optional [attributable failures][topic
  attributable failures] feature, which adds attribution data to failure
  messages so that hops commit to the messages they send. If a node corrupts a
  failure message, the sender can identify and penalize the node later. For more
  details on the mechanism and the LDK and Eclair implementations, see
  Newsletters [#224][news224 fail], [#349][news349 fail] and [#356][news356
  fail]. {% assign timestamp="1:33:33" %}

{% include snippets/recap-ad.md when="2025-11-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33745,8537,8608,8646,1160,1289,8569,8558,4126,3917,4208,9432,1284,1044" %}
[antoine delving]: https://delvingbitcoin.org/t/propagation-delay-and-mining-centralization-modeling-stale-rates/2110
[block prop simulation]: https://github.com/darosior/miningsimulation
[privkeyhand post]: https://delvingbitcoin.org/t/private-key-handover/2098
[news325 ipc]: /en/newsletters/2024/10/18/#bitcoin-core-30955
[news379 parts]: /en/newsletters/2025/11/07/#core-lightning-8636
[news323 fly]: /en/newsletters/2024/10/04/#eclair-2861
[news316 askrene]: /en/newsletters/2024/08/16/#core-lightning-7517
[news374 ldk]: /en/newsletters/2025/10/03/#ldk-4098
[news335 hmac]: /en/newsletters/2025/01/03/#ldk-3435
[news370 dummy]: /en/newsletters/2025/09/05/#ldk-3726
[news379 sign]: /en/newsletters/2025/11/07/#eclair-3210
[news76 upfront]: /en/newsletters/2019/12/11/#lnd-3655
[news371 eclair]: /en/newsletters/2025/09/12/#eclair-3163
[news373 ldk]: /en/newsletters/2025/09/26/#ldk-4064
[news224 fail]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[news349 fail]: /en/newsletters/2025/04/11/#ldk-2256
[news356 fail]: /en/newsletters/2025/05/30/#eclair-3065
[ark labs blog]: https://blog.arklabs.xyz/press-start-arkade-goes-live/
[mempal gh]: https://github.com/aeonBTC/Mempal
[miniscript studio gh]: https://github.com/adyshimony/miniscript-studio
[miniscript studio blog]: https://adys.dev/blog/miniscript-studio-intro
[miniscript studio site]: https://adys.dev/miniscript
[phoenix post]: https://x.com/PhoenixWallet/status/1983524047712391445
[nunchuk blog]: https://nunchuk.io/blog/autonomous-inheritance
[gossip observer gh]: https://github.com/jharveyb/gossip_observer
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
