---
title: 'Bitcoin Optech Newsletter #389'
permalink: /en/newsletters/2026/01/23/
name: 2026-01-23-newsletter
slug: 2026-01-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a paper on the study of payment channel networks.
Also included are our regular sections describing recent updates to services and
client software, announcing new releases and release candidates, and summarizing
notable changes to popular Bitcoin infrastructure software.

## News

- **A mathematical theory of payment channel networks**: René Pickhardt [posted][channels post] to Delving Bitcoin
  about the publication of his new [paper][channels paper] called "A Mathematical Theory of
  Payment Channel Networks". In the paper, Pickhardt groups several observations, gathered
  during years of research, under a single geometric framework. In particular, the paper aims to
  analyze common phenomena, such as channel depletion (see [Newsletter #333][news333 depletion]) and capital inefficiencies of two-party
  channels, assessing how they are interconnected and why they are true.

  The main paper contributions are the following:

  - A model for feasible wealth distributions of users on the Lightning Network
    given a channel graph

  - A formula for estimating the upper bound of payment bandwidth for payments

  - A method to estimate the likelihood that a payment is feasible (see
    [Newsletter #309][news309 feasibility])

  - An analysis on different
    [mitigation strategies][mitigation post] for channel depletion

  - The conclusion that two-party channels put strong constraints to the ability of liquidity to
    flow between peers of the network

  According to Pickhardt, the insights coming from his research were the motivation behind his
  recent post about using Ark as a channel factory (see [Newsletter #387][new387 ark]).
  Pickhardt also provided his [collection][pickhardt gh] of code, notebooks, and papers that
  were used as groundwork for his research.

  Finally, Pickhardt opened the discussion on his work to questions and feedback from the LN
  developer community on how the protocol design could be influenced by his research and on
  the best use for multi-party channels. {% assign timestamp="0:31" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Electrum server for testing silent payments:**
  [Frigate Electrum Server][frigate gh] implements the [remote scanner][bip352
  remote scanner] service from [BIP352][] to provide [silent payment][topic
  silent payments] scanning for client applications. Frigate also
  uses modern GPU computation to decrease scanning time which is useful for
  providing multi-user instances that handle many simultaneous scanning requests. {% assign timestamp="30:04" %}

- **BDK WASM library:**
  The [bdk-wasm][bdk-wasm gh] library, originally developed and [used][metamask
  blog] by the MetaMask organization, provides access to BDK features in
  environments that support WebAssembly (WASM). {% assign timestamp="33:28" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.12.1][] is a maintenance release that fixes a critical bug
  where nodes created with v25.12 could not spend funds sent to non-[P2TR][topic
  taproot] addresses (see below). It also fixes recovery and `hsmtool`
  compatibility issues with the new mnemonic-based `hsm_secret` format
  introduced in v25.12 (see [Newsletter #388][news388 cln]). {% assign timestamp="35:14" %}

- [LND 0.20.1-beta.rc1][] is a release candidate for a minor version that adds a
  panic recovery for gossip message processing, improves reorg protection,
  implements LSP detection heuristics, and fixes multiple bugs and race
  conditions. See the [release notes][] for more details. {% assign timestamp="39:14" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32471][] fixes a bug where calling the `listdescriptors` RPC
  with the `private=true` parameter (see Newsletters [#134][news134 descriptor]
  and [#162][news162 descriptor]) would fail if the wallet contained any [descriptor][topic
  descriptors] for which it had some but not
  all the private keys. This PR updates the RPC
  to return the descriptor with the available subset of private keys, enabling users to back them up.
  Calling `listdescriptors private=true` on a watch-only
  wallet still fails. {% assign timestamp="40:57" %}

- [Bitcoin Core #34146][] improves address propagation by sending a node's
  first self-announcement in its own P2P message. Previously, the self-announcement
  was bundled with multiple other addresses in response to a peer’s `getaddr`
  request, which could cause it to be dropped or to displace other addresses. {% assign timestamp="42:02" %}

- [Core Lightning #8831][] fixes a critical bug where nodes created with v25.12
  could not spend funds sent to non-[P2TR][topic taproot] addresses. Although
  all address types were derived based on [BIP86][] for those nodes, the signing
  code only used [BIP86][] for P2TR addresses. This PR ensures signing uses
  [BIP86][] derivation for all address types. {% assign timestamp="45:00" %}

- [LDK #4261][] adds support for mixed-mode [splicing][topic splicing], allowing
  for simultaneous splice-in and splice-out in the same transaction. The funding
  input pays the appropriate fees, as in the splice-in case. The net contributed
  value may be negative if more value is spliced out than spliced in. {% assign timestamp="45:35" %}

- [LDK #4152][] adds support for dummy hops on [blinded][topic rv routing]
  payments paths, paralleling the feature for blinded message paths added in
  [Newsletter #370][news370 dummy]. Adding additional hops makes it
  significantly harder to determine the distance to or the identity of the
  receiver node. See [Newsletter #381][news381 dummy]  for previous work
  enabling this. {% assign timestamp="46:24" %}

- [LND #10488][] fixes a bug where channels opened with the `fundMax` option
  (see [Newsletter #246][news246 fundmax]) were limited in size by the
  user-configured `maxChanSize` setting (see [Newsletter #116][news116
  maxchan]), which is intended to only limit incoming channel requests. This PR
  ensures that the `fundMax` option uses the protocol-level maximum channel size
  instead, depending on whether the user and peer support [large channels][topic
  large channels]. {% assign timestamp="47:42" %}

- [LND #10331][] improves how channel closes handle blockchain reorgs by using
  scaled confirmation requirements based on channel size, where the minimum is 1
  and the maximum is 6 confirmations. The chain watcher is revamped with the
  introduction of a state machine to better detect blockchain reorgs and track
  competing channel close transactions in such scenarios. The PR also adds
  monitoring for negative confirmations (when a confirmed transaction is later
  reorged out), though how to handle them remains unsolved. This PR addresses
  LND's [oldest open issue][lnd issue] from 2016. {% assign timestamp="48:43" %}

- [Rust Bitcoin #5402][] adds validation during decoding to reject transactions
  with duplicate inputs, related to [CVE-2018-17144][topic cve-2018-17144].
  Transactions containing multiple inputs spending the same outpoint are invalid
  by consensus. {% assign timestamp="49:06" %}

- [BIPs #1820][] updates [BIP3][] to status `Deployed`, replacing [BIP2][] as the
  guideline for the Bitcoin Improvement Proposal (BIP) process. See [Newsletter
  #388][news388 bip3] for more details. {% assign timestamp="50:39" %}

- [BOLTs #1306][] clarifies in the [BOLT12][] specification that [offers][topic
  offers] with an empty `offer_chains` field must be rejected. An offer with
  this field present but containing zero chain hashes makes invoice requests
  impossible since the payer cannot satisfy the requirement to set
  `invreq_chain` to one of the `offer_chains`. {% assign timestamp="51:41" %}

- [BLIPs #59][] updates [BLIP51][], also known as LSPS1, to add support for
  [BOLT12 offers][topic offers] as an option for paying Lightning Service
  Providers (LSPs), alongside the existing [BOLT11][] and on-chain options. This
  was previously implemented in LDK (see [Newsletter #347][news347 lsp]). {% assign timestamp="53:05" %}

{% include snippets/recap-ad.md when="2026-01-27 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32471,34146,8831,4261,4152,10488,10331,5402,1820,1306,59" %}

[channels post]: https://delvingbitcoin.org/t/a-mathematical-theory-of-payment-channel-networks/2204
[channels paper]: https://arxiv.org/pdf/2601.04835
[news309 feasibility]: /en/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible
[mitigation post]: https://delvingbitcoin.org/t/mitigating-channel-depletion-in-the-lightning-network-a-survey-of-potential-solutions/1640/1
[news333 depletion]: /en/newsletters/2024/12/13/#insights-into-channel-depletion
[new387 ark]: /en/newsletters/2026/01/09/#using-ark-as-a-channel-factory
[pickhardt gh]: https://github.com/renepickhardt/Lightning-Network-Limitations
[frigate gh]: https://github.com/sparrowwallet/frigate
[bip352 remote scanner]: https://github.com/silent-payments/BIP0352-index-server-specification/blob/main/README.md#remote-scanner-ephemeral
[bdk-wasm gh]: https://github.com/bitcoindevkit/bdk-wasm
[metamask blog]: https://metamask.io/news/bitcoin-on-metamask-btc-wallet
[Core Lightning 25.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12.1
[LND 0.20.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta.rc1
[news388 cln]: /en/newsletters/2026/01/16/#core-lightning-8830
[release notes]: https://github.com/lightningnetwork/lnd/blob/v0.20.x-branch/docs/release-notes/release-notes-0.20.1.md
[news134 descriptor]: /en/newsletters/2021/02/03/#bitcoin-core-20226
[news162 descriptor]: /en/newsletters/2021/08/18/#bitcoin-core-21500
[news370 dummy]: /en/newsletters/2025/09/05/#ldk-3726
[news381 dummy]: /en/newsletters/2025/11/21/#ldk-4126
[news246 fundmax]: /en/newsletters/2023/04/26/#lnd-6903
[news116 maxchan]: /en/newsletters/2020/09/23/#lnd-4567
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/53
[news388 bip3]: /en/newsletters/2026/01/16/#bip-process-updated
[news347 lsp]: /en/newsletters/2025/03/28/#ldk-3649
