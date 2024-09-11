---
title: 'Bitcoin Optech Newsletter #320'
permalink: /en/newsletters/2024/09/13/
name: 2024-09-13-newsletter
slug: 2024-09-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a new testing tool for Bitcoin Core and
briefly describes a DLC-based loan contract.  Also included are our
regular sections summarizing a Bitcoin Core PR Review Club, announcing
new releases and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **Mutation testing for Bitcoin Core:** Bruno Garcia [posted][garcia announce] to
  Delving Bitcoin to announce a [tool][mutation-core] that would
  automatically modify (mutate) code changed in a PR or commit to
  determine whether the mutations cause existing tests to fail.  Anytime
  random changes to code don't produce a failure, it indicates that test
  coverage may be incomplete.  Garcia's automatic mutation tool ignores
  code comments and other lines of code that wouldn't be expected to
  produce changes.

- **DLC-based loan contract execution:** Shehzan Maredia
  [posted][maredia post] to Delving Bitcoin to announce [Lava Loans][], a
  loan contract that uses [DLC][topic dlc] oracles for price discovery
  of bitcoin-collateralized loans.  For example, Alice offers Bob
  $100,000 USD if Bob keeps at least 2x $100,000 in BTC in a deposit
  address.  Oracles trusted by both Alice and Bob periodically publish
  signatures committing to the current BTC/USD price.  If Bob's BTC
  collateral drops below the agreed-upon amount, Alice can seize
  $100,000 USD worth of his BTC at the highest oracle-signed amount.
  Alternatively, Bob can provide proof onchain that he repaid the loan
  (in the form of a hash preimage revealed by Alice) to receive back his
  collateral.  Other resolutions of the contract are available if the
  parties fail to cooperate or one party becomes unresponsive.  As with
  any DLC, the price oracles are prevented from learning the contract
  details or even that their price information is being used in a
  contract.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/30352#l-18FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.18.3-beta][] is a minor bug fix
  release of this popular LN node implementation.

- [BDK 1.0.0-beta.2][] is a release candidate for this library for
  building wallets and other Bitcoin-enabled applications.  The original
  `bdk` Rust crate has been renamed to `bdk_wallet` and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.
  The `bdk_wallet` crate "is the first version to offer a stable 1.0.0 API."

- [Bitcoin Core 28.0rc1][] is a release candidate for the next major
  version of the predominant full node implementation.  A [testing
  guide][bcc testing] is available.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

_Note: the commits to Bitcoin Core mentioned below apply to its master
development branch, so those changes will likely not be released until
about six months after the release of the upcoming version 28._

- [Bitcoin Core #30509][] multiprocess: Add -ipcbind option to bitcoin-node

- [Bitcoin Core #29605][] net: Favor peers from addrman over fetching seednodes
{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30509,29605" %}
[LND v0.18.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[garcia announce]: https://delvingbitcoin.org/t/mutation-core-a-mutation-testing-tool-for-bitcoin-core/1119
[mutation-core]: https://github.com/brunoerg/mutation-core
[maredia post]: https://delvingbitcoin.org/t/lava-loans-trust-minimized-bitcoin-secured-loans/1112
[lava loans]: https://github.com/lava-xyz/loans-paper/blob/960b91af83513f6a17d87904457e7a9e786b21e0/loans_v2.pdf
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
