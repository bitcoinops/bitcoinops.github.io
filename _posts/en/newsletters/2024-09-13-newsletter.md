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
  produce changes. {% assign timestamp="1:39" %}

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
  contract. {% assign timestamp="9:15" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting.*

[Testing Bitcoin Core 28.0 Release Candidates][review club
v28-rc-testing] was a review club meeting that did not review a
particular PR, but rather was a group testing effort.

Before each [major Bitcoin Core release][], extensive testing by the
community is considered essential. For this reason, a volunteer writes a
testing guide for a [release candidate][] so that as many people as
possible can productively test without having to independently ascertain
what's new or changed in the release, and reinvent the various setup
steps to test these features or changes.

Testing can be difficult because when one encounters unexpected
behavior, it's often unclear if it's due to an actual bug or if the
tester is making a mistake. It wastes developers' time to report bugs to
them that aren't real bugs. To mitigate these problems and promote
testing efforts, a Review Club meeting is held for a particular release
candidate, in this instance, 28.0rc1.

The [28.0 release candidate testing guide][28.0 testing] was written by
rkrux, who also hosted the review club meeting.

Attendees were also encouraged to get testing ideas by reading the [28.0
release notes][].

This review club covered the introduction of [testnet4][topic testnet]
([Bitcoin Core #29775][]), [TRUC (v3) transactions][topic v3
transaction relay] ([Bitcoin Core #28948][]), [package RBF][topic
rbf] ([Bitcoin Core #28984][]) and conflicting mempool
transactions ([Bitcoin Core #27307][]). Other topics in the guide, but
not covered in the meeting include `mempoolfullrbf` by default ([Bitcoin
Core #30493][]), [`PayToAnchor`][topic ephemeral anchors] spending
([Bitcoin Core #30352][]), and a new `dumptxoutset` format ([Bitcoin
Core #29612][]). {% assign timestamp="21:08" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.18.3-beta][] is a minor bug fix
  release of this popular LN node implementation. {% assign timestamp="51:33" %}

- [BDK 1.0.0-beta.2][] is a release candidate for this library for
  building wallets and other Bitcoin-enabled applications.  The original
  `bdk` Rust crate has been renamed to `bdk_wallet` and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.
  The `bdk_wallet` crate "is the first version to offer a stable 1.0.0 API." {% assign timestamp="53:05" %}

- [Bitcoin Core 28.0rc1][] is a release candidate for the next major
  version of the predominant full node implementation.  A [testing
  guide][bcc testing] is available. {% assign timestamp="53:14" %}

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

- [Bitcoin Core #30509][] adds an `-ipcbind` option to `bitcoin-node` to allow
  other processes to connect to and control the node via a unix socket. In
  combination with the upcoming PR [Bitcoin Core #30510][], this will allow an
  external [Stratum v2][topic pooled mining] mining service to create, manage,
  and submit block templates. This is part of the Bitcoin Core [multiprocess
  project][multiprocess project]. See Newsletters [#99][news99 multi] and
  [#147][news147 multi]. {% assign timestamp="53:38" %}

- [Bitcoin Core #29605][] changes peer discovery to prioritize peers from the
  local address manager over fetching from seed nodes, to reduce the influence
  of the latter on peer selection and reduce unnecessary information sharing.
  By default, seed nodes are a backup in case all DNS seeds are
  unreachable (which is very uncommon on mainnet); however users of test
  networks or customized nodes may manually add seed nodes to find
  similarly configured nodes.  Before this PR, adding a seed node would
  result in it being queried for new addresses almost every time the
  node was started, potentially allowing it to influence peer selection
  and to only recommend peers that shared data with it.  With this PR,
  only when the address manager is empty, or after a period of unsuccessful
  address attempts, will seed nodes be added to the address fetch queue in
  random order. See Newsletter [#301][news301 seednode] for more on seed nodes. {% assign timestamp="1:00:52" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30509,29605,30510,29775,28948,28984,27307,30493,30352,29612" %}
[LND v0.18.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[garcia announce]: https://delvingbitcoin.org/t/mutation-core-a-mutation-testing-tool-for-bitcoin-core/1119
[mutation-core]: https://github.com/brunoerg/mutation-core
[maredia post]: https://delvingbitcoin.org/t/lava-loans-trust-minimized-bitcoin-secured-loans/1112
[lava loans]: https://github.com/lava-xyz/loans-paper/blob/960b91af83513f6a17d87904457e7a9e786b21e0/loans_v2.pdf
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news99 multi]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 multi]: /en/newsletters/2021/05/05/#bitcoin-core-19160
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news301 seednode]: /en/newsletters/2024/05/08/#bitcoin-core-28016
[review club v28-rc-testing]: https://bitcoincore.reviews/v28-rc-testing
[major bitcoin core release]: https://bitcoincore.org/en/lifecycle/#major-releases
[28.0 release notes]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Notes-Draft
[release candidate]: https://bitcoincore.org/en/lifecycle/#versioning
[28.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
