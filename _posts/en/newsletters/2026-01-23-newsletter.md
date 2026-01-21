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
  Payment Channel Network". In the paper, Pickhardt groups several observations, gathered
  during years of research, under a single geometric framework. In particular, the paper aims to
  analyze common phenomena, such as channel depletion (see [Newsletter #333][news333 depletion]) and capital inefficiencies of two-party
  channels, assessing how they are interconnected and why they are true.

  The main paper contributions are the following:

  - A model for feasible wealth distributions of users on the lightning network
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
  the best use for multi-party channels.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Electrum server for testing silent payments:**
  [Frigate Electrum Server][frigate gh] implements the [remote scanner][bip352
  remote scanner] service from [BIP352][] to provide [silent payment][topic
  silent payments] scanning for client applications. Frigate also
  uses modern GPU computation to decrease scanning time which is useful for
  providing multi-user instances that handle many simultaneous scanning requests.

- **BDK WASM library:**
  The [bdk-wasm][bdk-wasm gh] library, originally developed and [used][metamask
  blog] by the MetaMask organization, provides access to BDK features in
  environments that support WebAssembly (WASM).

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

{% include snippets/recap-ad.md when="2026-01-27 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

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
