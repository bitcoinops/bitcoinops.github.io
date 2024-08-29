---
title: 'Bitcoin Optech Newsletter #318'
permalink: /en/newsletters/2024/08/30/
name: 2024-08-30-newsletter
slug: 2024-08-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a new mailing list to discuss Bitcoin
mining.  Also included are our regular sections summarizing popular
questions and answers from the Bitcoin Stack Exchange, announcements of
new releases and release candidates, and descriptions of recent changes
to popular Bitcoin infrastructure software.

## News

- **New Bitcoin Mining Development mailing list:** Jay Beddict
  [announced][beddict mining-dev] a new mailing list to "discuss
  emerging Bitcoin mining technology updates as well as the impacts of
  Bitcoin-related software or protocol changes on mining."

  Mark "Murch" Erhardt [posted][erhardt warp] to the list to ask whether
  the [time warp][topic time warp] fix deployed on [testnet4][topic
  testnet] could lead to miners creating invalid blocks if the same fix
  was deployed to mainnet (such as part of a [cleanup soft fork][topic
  consensus cleanup]).  Mike Schmidt [referred][schmidt oblivious] list
  readers to a [thread][towns oblivious] on the Bitcoin-Dev mailing list
  about [oblivious shares][topic block withholding] (see [Newsletter
  #315][news315 oblivious]).

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Can a BIP152 compact block be sent before validation by a node that doesn't know all transactions?]({{bse}}123858)
  Antoine Poinsot points out that forwarding [compact blocks][topic compact
  block relay] before validating all of the included transactions are committed
  to by the block header would be a denial-of-service vector.

- [Did Segwit (BIP141) eliminate all txid malleability issues listed in BIP62?]({{bse}}124074)
  Vojtěch Strnad explains a variety of ways txids can be malleated, how segwit
  addressed malleability, what non-intentional malleability is, and a
  policy-related pull request.

- [Why are the checkpoints still in the codebase in 2024?]({{bse}}123768)
  Lightlike notes that with the addition of ["Headers Presync"][news216 headers
  presync], the Bitcoin Core codebase has no _known_ requirements for
  checkpoints, but emphasizes there may be _unknown_ attack vectors that the
  checkpoints are protecting against.

- [Bulletproof++ as generic ZKP ala SNARKs?]({{bse}}119556)
  Liam Eagen details the type of succinct non-interactive argument of knowledge
  (SNARKs) currently in use and how bulletproofs, [BitVM][topic acc], and
  [OP_CAT][topic op_cat] might be used to verify such proofs in Bitcoin Script.

- [How can OP_CAT be used to implement additional covenants?]({{bse}}123829)
  Brandon - Rearden describes how the proposed OP_CAT opcode could provide
  [covenant][topic covenants] functionality to Bitcoin scripts.

- [Why do some bech32 bitcoin addresses contain a large number of 'q's?]({{bse}}123902)
  Vojtěch Strnad reveals that the OLGA protocol encodes arbitrary data into
  P2WSH outputs with part of the scheme requiring 0-padding (0 is encoded as 'q'
  in [bech32][topic bech32]).

- [How does a 0-conf signature bond work?]({{bse}}124022)
  Matt Black outlines how funds locked in an OP_CAT-based covenant could provide
  incentives for spenders to not [RBF][topic rbf] fee bump their transactions,
  potentially increasing acceptance of zero-confirmation transactions.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 24.08rc2][] is a release candidate for the next major
  version of this popular LN node implementation.

- [LND v0.18.3-beta.rc1][] is a release candidate for a minor bug fix
  release of this popular LN node implementation.

- [BDK 1.0.0-beta.2][] is a release candidate for this library for
  building wallets and other Bitcoin-enabled applications.  The original
  `bdk` Rust crate has been renamed to `bdk_wallet` and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.
  The `bdk_wallet` crate "is the first version to offer a stable 1.0.0 API."

- [Bitcoin Core 28.0rc1][] is a release candidate for the next major
  version of the predominant full node implementation.  A [testing
  guide][bcc testing] is being prepared.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [LDK #3263][] simplifies how it handles [onion messages][topic onion messages]
  responses by removing the message type parameter from the `ResponseInstruction`
  struct, and introducing a  new `MessageSendInstructions` enum based on the
  updated `ResponseInstruction`, that can handle both [blinded][topic rv
  routing] and non-blinded reply paths. The `send_onion_message` method now uses
  `MessageSendInstructions`, allowing users to specify reply paths without
  needing to figure out the pathfinding themselves. A new option,
  `MessageSendInstructions::ForReply`, lets message handlers send responses
  later without creating circular dependencies in the code. See Newsletter
  [#303][news303 onion].

- [LDK #3247][] deprecates the `AvailableBalances::balance_msat` method in favor
  of the `ChannelMonitor::get_claimable_balances` method, which provides a more
  straightforward and accurate approach to obtaining a channel's balance. The
  deprecated method’s logic is now outdated as it was originally designed to
  handle potential underflow issues when balances included pending HTLCs (those
  that could later be reversed).

- [BDK #1569][] adds the `bdk_core` crate and moves to it some types from
  `bdk_chain`: `BlockId`, `ConfirmationBlockTime`, `CheckPoint`,
  `CheckPointIter`, `tx_graph::Update` and `spk_client`. The `bdk_esplora`,
  `bdk_electrum` and `bdk_bitcoind_rpc` chain sources have been changed to
  depend only on `bdk_core`. These changes were made to allow faster refactoring
  on `bdk_chain`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3247,1569" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[news315 oblivious]: /en/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[beddict mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/97fkfVmHWYU
[erhardt warp]: https://groups.google.com/g/bitcoinminingdev/c/jjkbeODskIk
[schmidt oblivious]: https://groups.google.com/g/bitcoinminingdev/c/npitVsP9KNo
[towns oblivious]: https://groups.google.com/g/bitcoindev/c/1tDke1a2e_Q
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 headers presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[news303 onion]: /en/newsletters/2024/05/17/#ldk-2907