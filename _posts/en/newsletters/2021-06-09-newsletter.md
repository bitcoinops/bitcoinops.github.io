---
title: 'Bitcoin Optech Newsletter #152'
permalink: /en/newsletters/2021/06/09/
name: 2021-06-09-newsletter
slug: 2021-06-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow LN nodes to receive
payments without keeping their private keys online all the time.  Also
included are our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, announcements of new software releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Receiving LN payments with a mostly offline private key:** in 2019,
  developer [[ZmnSCPxj]] [proposed][zmn ff] an alternative way to
  encapsulate pending LN payments ([HTLCs][topic htlc]) that would
  reduce the amount of network bandwidth and latency required to accept
  a payment.  More recently, Lloyd Fournier suggested the idea could
  also be used to allow a node to accept multiple incoming LN payments
  without keeping its private keys online.  The idea does have some
  downsides:

  - The node would still need its private keys to send a penalty
    transaction if necessary.

  - The more payments the node received without using its private key,
    the more onchain fees would need to be paid if the channel was
    unilaterally closed.

  - The receiving node would lose privacy---its immediate peer would be
    able to determine that it was the ultimate receiver of a payment and
    not just a routing hop.  However, for some end-user nodes that don't
    route payments, this may already be obvious.

  Within those limitations, the idea seems workable and variations of it
  received [discussion][zmn revive] on the mailing list this week, with
  ZmnSCPxj preparing a clear [presentation][zmn preso].  Fournier later
  [suggested][fournier asym] improvements to the idea.

  Implementing the idea would require several significant LN protocol
  changes, so it seems unlikely to be something users will have access
  to in either the short or medium term.  However, anyone looking to
  minimize the need for LN receiving nodes to keep their keys online is
  encouraged to investigate the idea.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Prune g_chainman usage in auxiliary modules][review club #21767] is a
refactoring PR ([#21767][Bitcoin Core #21767]) by Carl Dong that is part of a
project to de-globalize `g_chainman` as a first step toward modularizing the
consensus engine. This would decouple
components and enable more focused testing.  A longer-term goal is to
completely separate the consensus engine from non-consensus code.

The review club discussion began with the following general questions before
diving deeper into the code changes:

{% include functions/details-list.md
  q0="This PR is a refactoring and should not change any functional
      behaviour.  What are some ways we can verify that?"
  a0="Reviewing the code carefully, running the tests, adding test coverage,
      inserting asserts or custom logging, building with `--enable-debug`,
      running bitcoind with the changes, and stepping through the code
      with debuggers like GDB or LLDB."
  a0link="https://bitcoincore.reviews/21767#l-53"

  q1="This PR is part of a larger project to modularize and separate the Bitcoin
      Core consensus engine.  What are some benefits of doing that?"
  a1="This could make it easier to reason about, maintain, configure and test
      the code.  It could expose a minimal API for security and maintainability,
      with configuration options to pass non-global data. We could construct
      components with variable parameters, providing more control over testing those
      objects with different configurations."
  a1link="https://bitcoincore.reviews/21767#l-63"

  q2="What is the `ChainstateManager` responsible for?"
  a2="The [`ChainstateManager`][ChainstateManager] class provides an interface
      for creating and interacting with one or two chainstates: initial block
      download (IBD) and an optional snapshot."
  a2link="https://bitcoincore.reviews/21767#l-117"

  q3="What does `CChainState` do?"
  a3="The [`CChainState`][CChainState] class stores the current best chain and
      provides an API to update our local knowledge of its state."
  a3link="https://bitcoincore.reviews/21767#l-174"

  q4="What is the `CChain` class?"
  a4="The [`CChain`][CChain] class is an in-memory indexed chain of blocks. It
      contains a [vector of block index pointers][cchain vectors]."
  a4link="https://bitcoincore.reviews/21767#l-120"

  q5="What is the `BlockManager` responsible for?"
  a5="The [`BlockManager`][BlockManager] class maintains a tree of blocks stored
      in `m_block_index` that is consulted to locate the most-work chain tip."
  a5link="https://bitcoincore.reviews/21767#l-121"

  q6="What is `cs_main`?"

  a6="`cs_main` is a mutex that protects validation-specific data (as well as,
      for now, many other things). The name means [*critical section
      main*][csmain1], as it protected data in `main.cpp`, and the code that is
      now in `validation.cpp` and `net_processing.cpp` [used to be in one file
      called `main.cpp`][csmain2])."

  a6link="https://bitcoincore.reviews/21767#l-202"

  q7="Conceptually, when we refer to the \"validation\" part of the codebase,
      what does that include?"
  a7="Validation stores and maintains our best view of the block chain and
      associated UTXO set. It also includes an interface to submit unconfirmed
      transactions to the mempool."
  a7link="https://bitcoincore.reviews/21767#l-228"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta] is a release candidate that
  adds support for using a pruned Bitcoin full node, allows receiving
  and sending payments using Atomic MultiPath ([AMP][topic multipath payments]),
  and increases its [PSBT][topic psbt] capabilities, among other improvements
  and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22051][] adds support for importing [descriptors][topic
  descriptors] for [taproot][topic taproot] outputs into the Bitcoin Core
  wallet. This PR allows wallet users to receive funds to taproot outputs and is
  the prerequisite for an [open PR][Bitcoin Core #21365] that implements full
  support for users to receive to and spend from taproot outputs.

- [Bitcoin Core #22050][] drops support for version 2 Tor onion services
  (hidden services).  Version 2 services are already deprecated and the
  Tor project has announced that they'll become inaccessible in
  September.  Bitcoin Core already supports version 3 onion services
  (see [Newsletter #132][news132 v3onion]).

- [Bitcoin Core #22095][] adds a test to check how Bitcoin Core derives
  [BIP32][] private keys.  Although Bitcoin Core has always derived
  these keys correctly, it was recently [discovered][btcd issue] that some other
  wallets were incorrectly deriving slightly more than 1 out of 128 keys
  by failing to pad extended private keys (xprivs) that were
  less than 32 bytes long.  This doesn't directly result in a loss of
  funds or a reduction in security, but it does create problems for
  users who create an HD wallet seed in one wallet and import it into
  another wallet or who create multisignature wallets.  The test vector
  implemented in this PR is also being [added][bips #1030] to BIP32 to
  help future wallet authors avoid this issue.

- [C-Lightning #4532][] adds experimental support for [upgrading a
  channel][bolts #868]---rebuilding the latest commitment transaction so
  that it can incorporate new features or structural changes, e.g.
  converting to using [taproot][topic taproot].  The protocol starts
  with a request for [quiescence][bolts #869], an agreement that neither
  party will send any new state updates until the quiescence period is
  completed.  During this period, the nodes negotiate the changes they
  want to make and implement them.  Finally, the channel is restored to
  full operation.  C-Lightning currently implements this during
  connection reestablishment when the channel has already been in a
  period of forced inactivity.  Various proposals for channel upgrades
  were discussed in [Newsletter #108][news108 channel upgrades] and the
  author of this PR wants the feature in part to work on the "simplified
  HTLC negotiation" described in [Newsletter #109][news109 simplified
  htlc].  This particular PR allows upgrading old channels to support
  `option_static_remotekey`, which C-Lightning first added support for
  in 2019, see [Newsletter #64][news64 static remotekey].

- [LND #5336][] adds the ability for users to reuse [AMP][topic multipath
  payments] invoices non-interactively by specifying a new payment secret. The
  default invoice expiry for AMP invoices created by LND is also bumped to 30
  days in order to facilitate the aforementioned reuse mechanism.

- [BTCPay Server #2474][] adds the ability to test webhooks by sending
  fake events that contain all their normal fields but dummy data.  This
  mirrors testing features available on centrally hosted Bitcoin payment
  processors such as Stripe and Coinbase Commerce.

{% include references.md %}
{% include linkers/issues.md issues="22051,22050,22095,4532,869,5336,2474,1030,868,21767,21365" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[news64 static remotekey]: /en/newsletters/2019/09/18/#c-lightning-3010
[news108 channel upgrades]: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news109 simplified htlc]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[zmn ff]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[zmn revive]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003038.html
[zmn preso]: https://zmnscpxj.github.io/offchain/2021-06-fast-forwards.odp
[fournier asym]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003045.html
[btcd issue]: https://github.com/btcsuite/btcutil/issues/172
[news132 v3onion]: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0
[cchain vectors]: https://bitcoincore.reviews/21767#l-196
[csmain1]: https://bitcoincore.reviews/21767#l-216
[csmain2]: https://bitcoincore.reviews/21767#l-213
[ChainstateManager]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L759
[CChainState]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L502
[CChain]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/chain.h#L391
[BlockManager]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L343
