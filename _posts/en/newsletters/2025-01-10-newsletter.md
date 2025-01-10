---
title: 'Bitcoin Optech Newsletter #336'
permalink: /en/newsletters/2025/01/10/
name: 2025-01-10-newsletter
slug: 2025-01-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a potential change to Bitcoin Core
affecting miners, summarizes discussion about creating contract-level
relative timelocks, and discusses a proposal for an LN-Symmetry variant
with optional penalties.  Also included are our regular sections
announcing new releases and release candidates and summarizing notable
changes to popular Bitcoin infrastructure software.

## News

- **Investigating mining pool behavior before fixing a Bitcoin Core bug:**
  Abubakar Sadiq Ismail [posted][ismail double] to Delving Bitcoin about
  a [bug][bitcoin core #21950] discovered in 2021 by Antoine Riard that
  results in nodes reserving 2,000 vbytes in block templates for coinbase
  transactions rather than the intended 1,000 vbytes.  Each template
  could include approximately five additional small transactions if the
  double reservation was eliminated.  However, that could lead to miners
  who depended on the double reservation producing invalid blocks,
  resulting in a large loss of income.  Ismail analyzed past blocks to
  determine which mining pools might be at risk.  He noted
  Ocean.xyz, F2Pool, and an unknown miner are apparently using
  non-default settings, although none of these appear to be at risk of
  losing money if the bug is fixed.

  However, to minimize the risk, it's currently proposed to introduce a
  new startup option that defaults to reserving 2,000 vbytes for the
  coinbase.  Miners who don't need backwards compatibility can easily
  reduce the reservation to 1,000 vbytes (or less, if they need less).

  Jay Beddict [relayed][beddict double] the message to the Mining-Dev
  mailing list.

- **Contract-level relative timelocks:** Gregory Sanders
  [posted][sanders clrt] to Delving Bitcoin about finding a solution for
  a complication he discovered about a year ago (see [Newsletter
  #284][news284 deltas]) when creating a proof-of-concept implementation
  of [LN-Symmetry][topic eltoo].  In that protocol, each channel state
  can be confirmed onchain, but only the last state confirmed before a
  deadline can distribute the channel funds.  Usually, the parties to
  a channel would attempt to confirm only the latest state; however, if
  Alice initiates a new state update by partially signing a transaction
  and sending it to Bob, only Bob can complete that transaction.  If Bob
  stalls at that point, Alice can only close a channel in its
  penultimate state.  If Bob waits until Alice's penultimate state has
  almost reached its deadline and then confirms the last state, it
  will take approximately twice as long as the deadline for the channel
  to resolve, called the _2x delay problem_.  That means
  [timelocks][topic timelocks] for [HTLCs][topic htlc] in LN-Symmetry
  must be up to twice as long, which makes it easier for attackers to
  prevent forwarding nodes from earning income on their capital (through
  [channel jamming attacks][topic channel jamming attacks] and other
  problems).

  Sanders suggests solving the problem with a relative timelock that
  would apply to all transactions required to settle a contract.  If
  LN-Symmetry had such a feature and Alice confirmed the penultimate
  state, Bob would need to confirm the last state before the
  deadline of the penultimate state.  In a [later post][sanders tpp],
  Sanders links to a channel protocol by John Law (see [Newsletter
  #244][news244 tpp]) that uses two transaction-level relative timelocks
  to provide a contract-level relative timelock without consensus
  changes.  However, that doesn't work for LN-Symmetry which allows each
  state to spend from any previous state.

  Sanders sketches a solution, but notes that it has downsides.  He also
  notes how the problem could be solved using Chia's `coinid` feature,
  which appears to be similar to John Law's 2021 idea for Inherited
  Identifiers (IIDs).  Jeremy Rubin [replied][rubin muon] with a link to
  his proposal last year for _muon_ outputs that must be spent in the
  same block as the transaction that created them, showing how they
  could contribute to a solution.  Sanders mentions, and Anthony Towns
  [expands][towns coinid] on, the `coinid` feature from the Chia
  blockchain, showing how it could reduce the data required
  to a constant amount.  Salvatore Ingala [posted][ingala cat]
  about a similar mechanism using [OP_CAT][topic op_cat] that he learned
  about from developer Rijndael, who later [provided details][rijndael
  cat].  Brandon Black [described][black penalty] an
  alternative type of solution---a penalty-based variant of
  LN-Symmetry---and cited work by Daniel Roberts about it (see next news
  item).

- **Multiparty LN-Symmetry variant with penalties for limiting published updates:**
  Daniel Roberts [posted][roberts sympen] to Delving Bitcoin about
  preventing a malicious channel counterparty (Mallory) from being able
  to delay channel settlement by deliberately broadcasting old states at
  a higher feerate than an honest counterparty (Bob) is paying for
  confirmation of the final state.  In theory, Bob can rebind his final
  state to Mallory's old state and both transactions might confirm in
  the same block, causing her to lose money on fees and Bob to confirm
  the final state for the same fee cost he was already willing to
  pay.  However, if Mallory can repeatedly prevent Bob from learning
  about her broadcasts of old states before they are confirmed, she can
  prevent him from responding until [HTLCs][topic htlc] in the
  channel expire and Mallory is able to steal funds.

  Roberts proposed a scheme that allows a channel participant to
  confirm only a single state.  If a later state is confirmed, the
  participant who submitted the final state and any participant who
  didn't submit any states can take the money of any participants who
  submitted outdated states.

  Unfortunately, after publishing the scheme, Roberts discovered and
  self-disclosed a critical flaw in it: similar to the _2x delay
  problem_ described in the previous news item, the last party to sign
  can complete a state that no other party can complete, giving
  the final signer exclusive access to the current final state.  If any
  other party tries to close in the previous state, they will lose
  money if the final signer uses the final state.

  Roberts is investigating alternative approaches, but the topic spurred
  interesting discussion about whether or not adding a penalty mechanism
  to LN-Symmetry is useful.  Gregory Sanders, whose previous
  proof-of-concept implementation of LN-Symmetry led him to believe
  that a penalty mechanism is unnecessary (see [Newsletter
  #284][news284 sympen]), noted that the repeated-old-state attack is
  similar to a [replacement cycling attack][topic replacement cycling].
  He finds "this attack pretty weak, since the attack[er] can be driven
  to negative EV [expected value] pretty easily" even if the defender
  has modest resources and no insight into what transactions miners are
  attempting to confirm.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 28.1][] is a release of a maintenance
  version of the predominant full-node implementation.

- [BDK 0.30.1][] is a maintenance release for the previous release
  series containing bug fixes.  Projects are encouraged to upgrade to
  BDK wallet 1.0.0, as announced in last week's newsletter, for which
  the a [migration guide][bdk migration] has been provided.

- [LDK v0.1.0-beta1][] is a release candidate of this library for
  building LN-enabled wallets and applications.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #28121][] adds a new `reject-details` field to the response of
  the `testmempoolaccept` RPC command, which is only included if the transaction
  would be rejected from the mempool due to consensus or policy violations. The
  error message is identical to the one returned by `sendrawtransaction` if the
  transaction is rejected there as well.

- [BDK #1592][] introduces Architectural Decision Records (ADRs) to document
  significant changes, outlining the problem addressed, decision drivers,
  alternatives considered, pros and cons, and the final decision. This allows
  newcomers to familiarize themselves with the repository’s history. This PR
  adds an ADR template and the first two ADRs: one to remove the `persist`
  module from `bdk_chain` and another to introduce a new `PersistedWallet` type
  that wraps a `BDKWallet`.

{% include snippets/recap-ad.md when="2025-01-14 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28121,1592,21950" %}
[bitcoin core 28.1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[bdk migration]: https://bitcoindevkit.github.io/book-of-bdk/getting-started/migrating/
[ismail double]: https://delvingbitcoin.org/t/analyzing-mining-pool-behavior-to-address-bitcoin-cores-double-coinbase-reservation-issue/1351
[beddict double]: https://groups.google.com/g/bitcoinminingdev/c/aM9SDXSMZDs
[sanders clrt]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/
[news284 deltas]: /en/newsletters/2024/01/10/#expiry-deltas
[sanders tpp]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/2
[news244 tpp]: /en/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[rubin muon]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/3
[towns coinid]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/7
[ingala cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/8
[rijndael cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/11
[black penalty]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/12
[roberts sympen]: https://delvingbitcoin.org/t/broken-multi-party-eltoo-with-bounded-settlement/1364/
[news284 sympen]: /en/newsletters/2024/01/10/#penalties
[bdk 0.30.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.1
