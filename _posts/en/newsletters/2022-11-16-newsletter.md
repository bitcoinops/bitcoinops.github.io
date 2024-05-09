---
title: 'Bitcoin Optech Newsletter #226'
permalink: /en/newsletters/2022/11/16/
name: 2022-11-16-newsletter
slug: 2022-11-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to enable generalized smart
contracts on Bitcoin and summarizes a paper about addressing LN channel
jamming attacks.  Also included are our regular sections with
descriptions of changes to services and client software, announcements
of new releases and release candidates, and summaries of notable changes
to popular Bitcoin infrastructure software.

## News

- **General smart contracts in Bitcoin via covenants:** Salvatore Ingala
  [posted][ingala matt] to the Bitcoin-Dev mailing list a proposal for a
  new type of [covenant][topic covenants] (requiring a soft fork) that
  would allow using [merkle trees][] to create smart contracts that can
  carry state from one onchain transaction to another.  To use an
  example from Ingala's post, two users could wager on a game of chess
  where the contract could hold the rules of the game and the state
  could hold the positions of all the pieces on the board, with it being
  possible to update that state by each onchain transaction.  Of course,
  a well-designed contract would allow the game to be played offchain
  with only the settlement transaction at the end of the game being put
  onchain (or possibly even then staying offchain if the game was played
  within another offchain construct, such as a payment channel).

  Ingala explains how the work could help design [joinpools][topic
  joinpools], optimistic rollups (see [Newsletter #222][news222
  rollup]), and other stateful constructions. {% assign timestamp="1:21" %}

- **Paper about channel jamming attacks:** Clara Shikhelman and Sergei
  Tikhomirov [posted][st unjam post] to the Lightning-Dev mailing list
  the summary of a [paper][st unjam paper] they've written about
  solutions to [channel jamming attacks][topic channel jamming attacks].
  These attacks, first described in 2015, can make large numbers of
  channels unusable for long periods of time at negligible cost to an
  attacker.

  The authors split jamming attacks into two types. The first is *slow
  jamming* where a channel's limited slots or funds for payment
  forwarding are made unavailable for long periods of time---which
  rarely happens with legitimate payments.  The second type is *fast
  jamming* where the slots and funds are blocked only briefly---which
  happens often with normal payments, potentially making fast jamming
  harder to mitigate.

  They suggest two solutions:

  - *Unconditional fees* (the same as *upfront fees* described in
    previous newsletters), where some amount of fee is paid to
    forwarding nodes even if a payment fails to reach the receiver.
    The authors suggest both a *base* upfront fee that's independent
    of the amount of the payment and a *proportional* fee that
    increases with the payment amount.  The two separate fees
    respectively address HTLC slot jamming and liquidity jamming.  The
    fees can be very small because they're only meant to prevent fast
    jamming, which requires frequent resends of fake payments that
    would each need to pay additional upfront fees, raising the cost
    for the attacker.

  - *Local reputation with forwarding,* where each node would keep
    statistics about each of its peers related to how long its
    forwarded payments remain pending and the forwarding fees
    collected.  If a peer's time per fee is high, it considers that
    peer high-risk and only allows that peer to use a limited number
    of the local node's slots and funds.  Otherwise, it considers the
    peer low-risk.

    When a node receives a forwarded payment from a peer it considers
    low-risk, it checks to see whether that peer tagged the
    payment as also being low-risk.  If both the upstream forwarding
    node and the payment are low-risk, it allows the payment to use
    any available slot and funds.

  The paper received some discussion on the mailing list, with the
  proposed local reputation method specifically being praised. {% assign timestamp="29:46" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Sparrow 1.7.0 released:**
  [Sparrow 1.7.0][sparrow 1.7.0] adds support for a [Replace-By-Fee (RBF)][topic rbf]-enabled
  transaction cancellation feature among other updates. {% assign timestamp="55:59" %}

- **Blixt Wallet adds taproot support:**
  [Blixt Wallet v0.6.0][blixt v0.6.0] adds send and receive support for [taproot][topic taproot] addresses. {% assign timestamp="56:42" %}

- **Specter-DIY v1.8.0 released:**
  [Specter-DIY v1.8.0][] now supports [reproducible builds][topic reproducible
  builds] and [taproot][topic taproot] keypath spending support. {% assign timestamp="57:07" %}

- **Trezor Suite adds coin control features:**
  In a [recent blog post][trezor coin control], Trezor announced that Trezor
  Suite now supports [coin control][topic coin selection] features. {% assign timestamp="57:50" %}

- **Strike adds taproot send support:**
  Strike's wallet now allows sending to [bech32m][topic bech32] addresses. {% assign timestamp="58:32" %}

- **Kollider exchange launches with Lightning support:**
  Kollider [announced][kollider launch] an exchange with LN deposit and
  withdrawal capabilities as well as a browser-based Lightning wallet. {% assign timestamp="58:53" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 24.0 RC4][] is a release candidate for the
  next version of the network's most widely used full node
  implementation.  A [guide to testing][bcc testing] is available.

  **Warning:** this release candidate includes the `mempoolfullrbf`
  configuration option which several protocol and application developers
  believe could lead to problems for merchant services as described in
  previous newsletters [#222][news222 rbf] and [#223][news223 rbf].  It
  could also cause problems for transaction relay as described in
  [Newsletter #224][news224 rbf]. {% assign timestamp="1:00:06" %}

- [LND 0.15.5-beta.rc1][] is a release candidate for a maintenance
  release of LND.  It's contains only minor bug fixes according to its
  planned release notes. {% assign timestamp="1:00:36" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5681][] adds the ability to filter the JSON output of
  an RPC on the server side.  Filtering on the server side avoids
  sending unwanted data when using a bandwidth-constrained remote
  connection.  In the future, some RPCs may be able to avoid computing
  filtered data, allowing them to return sooner.  Filtering is not
  guaranteed for all RPCs, especially those provided by plugins.  When
  filtering is not available, the unfiltered full output will be
  returned.  For more information, see the added [documentation][cln
  filter doc]. {% assign timestamp="1:00:54" %}

- [Core Lightning #5698][] updates the experimental developer mode to
  allow receiving onion-wrapped error messages of any size. BOLT2
  currently recommends 256-byte errors, but it doesn’t forbid longer error
  messages and [BOLTs #1021][] is open to encourage use of 1024-byte
  error messages encoded using LN’s modern Type-Length-Value (TLV)
  semantics. {% assign timestamp="1:02:09" %}

- [Core Lightning #5647][] adds the reckless plugin manager. The plugin manager
  may be used to install CLN plugins by name from the `lightningd/plugins`
  repository. The plugin manager automatically installs dependencies and verifies the
  installation. It can also be used to enable and disable plugins as well as
  persist the plugin state in a configuration file. {% assign timestamp="1:03:21" %}

- [LDK #1796][] updates `Confirm::get_relevant_txids()` to return not
  just txids but also the hashes of the blocks containing those
  referenced transactions.  This makes it easier for a higher-level
  application to determine when a block chain reorganization may have
  changed the confirmation depth of a transaction.  If the block hash
  for a given txid changes, then a reorganization has occurred. {% assign timestamp="1:04:52" %}

- [BOLTs #1031][] allows a spender to pay a receiver slightly more than
  the requested amount when using [simplified multipath payments][topic
  multipath payments].  This may be required in the case where the
  chosen payment paths use channels with a minimum routable amount.  For
  example, Alice wants to split a 900 sat total into two parts, but both
  of the paths she chooses require 500 sat minimum amounts.  With this
  specification change, she can now send two 500 sat payments, choosing
  to overpay by a total of 100 sats in order to use her preferred route. {% assign timestamp="1:06:14" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="5681,5698,5647,1796,1031,1021" %}
[bitcoin core 24.0 rc4]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[lnd 0.15.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc1
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[cln filter doc]: https://github.com/rustyrussell/lightning/blob/a6f38a2c1a47c5497178c199691047320f2c55bc/doc/lightningd-rpc.7.md#field-filtering
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021182.html
[merkle trees]: https://en.wikipedia.org/wiki/Merkle_tree
[news222 rollup]: /en/newsletters/2022/10/19/#validity-rollups-research
[st unjam post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003740.html
[st unjam paper]: https://raw.githubusercontent.com/s-tikhomirov/ln-jamming-simulator/master/unjamming-lightning.pdf
[sparrow 1.7.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.0
[blixt v0.6.0]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.0
[Specter-DIY v1.8.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.8.0
[trezor coin control]: https://blog.trezor.io/coin-control-in-trezor-suite-92f3455fd706
[kollider launch]: https://blog.kollider.xyz/announcing-kolliders-launch/
