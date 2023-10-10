---
title: 'Bitcoin Optech Newsletter #272'
permalink: /en/newsletters/2023/10/11/
name: 2023-10-11-newsletter
slug: 2023-10-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a specification for a proposed
`OP_TXHASH` opcode and includes our regular sections summarizing a
Bitcoin Core PR Review Club meeting, linking to new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Specification for `OP_TXHASH` proposed:** Steven Roose [posted][roose
  txhash] to the Bitcoin-Dev mailing list a [draft BIP][bips #1500] for
  a new `OP_TXHASH` opcode.  The idea behind this opcode has been
  discussed before (see [Newsletter #185][news185 txhash]) but this is
  the first specification of the idea.  In addition to describing
  exactly how the opcode would work, it also looks at mitigating some
  potential downsides, such as full nodes potentially needing to hash up
  to several megabytes of data every time the opcode is invoked.
  Roose's draft includes a sample implementation of the opcode.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[util: Type-safe transaction identifiers][review club 28107] is a PR
by Niklas Gögge (dergoegge) that improves type safety by introducing
separate types for `txid` (the transaction identifier or hash that
doesn't include the segwit witness data) and `wtxid` (same but includes
the witness data), rather than both being represented by a `uint256`
(a 256-bit integer, which can contain a SHA256 hash). This PR
should have no operational effect; it aims to prevent future
programming errors in which one kind of transaction ID is used where
the other was intended. Such errors will be detected at compile time.

To minimize disruption and ease review, these new types will initially
be used in only one area of the code (the transaction "orphanage");
future PRs will use the new types in other areas of the codebase.

{% include functions/details-list.md
  q0="What does it mean for a transaction identifier to be type-safe?
      Why is that important or helpful? Are there any downsides?"
  a0="Since a transaction identifier has one of two meanings (`txid`
      or `wtxid`), type-safety is the property that an identifier can't
      be used with the wrong meaning. That is, a `txid` can't be used
      where a `wtxid` is expected, and vice versa, and that this is
      enforced by the compiler's standard type checking."
  a0link="https://bitcoincore.reviews/28107#l-38"

  q1="Rather than the new class types `Txid` and a `Wtxid` _inheriting_
      from `uint256`, should they  _include_ (wrap) a `uint256`?
      What are the tradeoffs?"
  a1="Those classes could do that, but it would cause much more code
      churn (many more source lines would need to be touched)."
  a1link="https://bitcoincore.reviews/28107#l-39"

  q2="Why is it better to enforce types at compile-time instead of at
      run-time?"
  a2="Developers discover errors quickly as they're coding, rather
      than relying on writing extensive test suites to catch bugs in runtime
      (and these tests may still miss some errors). However, testing would
      still be useful since type safety won't prevent consistent use of the
      wrong type of transaction ID in the first place."
  a2link="https://bitcoincore.reviews/28107#l-67"

  q3="Conceptually, when writing new code that requires referring to
      transactions, when should you use `txid` and when should you use
      `wtxid`? Can you point to any examples in the code where using one
      instead of the other could be very bad?"
  a3="In general, use of `wtxid` is preferred since it commits to the
      entire transaction. An important exception is the `prevout`
      reference from each input to the output (UTXO) it's spending,
      which must specify the transaction by `txid`.
      An example of where it's important to use one and not the other is
      given [here][wtxid example] (for more info, see [Newsletter
      #104][news104 wtxid])."
  a3link="https://bitcoincore.reviews/28107#l-85"

  q4="In which concrete way(s) could using `transaction_identifier` instead
      of `uint256` help find existing bugs or prevent the introduction of
      new ones? On the other hand, could this change introduce new bugs?"
  a4="Without this PR, a function that takes a `uint256` argument (such as
      a block ID hash) could be passed a `txid`.
      With this PR, this causes a compile-time error."
  a4link="https://bitcoincore.reviews/28107#l-128"

  q5="The [`GenTxid`][GenTxid] class already exists. How does it
      already enforce type correctness, and how is it different from the
      approach in this PR?"
  a5="This class includes a hash and a flag indicating if the hash is a
      `wtxid` or a `txid`, so it's still a single type rather than two
      distinct types. This allows type checking, but it must be explicitly
      programmed, and, more importantly, can only be done at run-time,
      not compile-time. It satisfies the frequent use case of wanting
      to take input that can be either kind of identifier. For this reason,
      this PR doesn't remove `GenTxid`. A better alternative for the
      future might be `std::variant<Txid, Wtxid>`."
  a5link="https://bitcoincore.reviews/28107#l-161"

  q6="How is `transaction_identifier` able to subclass `uint256`, given
      that, in C++, integers are types and not classes?"
  a6="Because `uint256` is itself a class, rather than a built-in type.
      (The largest built-in C++ integer type is 64 bits.)"
  a6link="https://bitcoincore.reviews/28107#l-194"

  q7="Does a `uint256` behave otherwise the same as, for example, a
      `uint64_t`?"
  a7="No, arithmetic operations aren't permitted on `uint256` because
      they don't make sense for hashes (which is the main use of `uint256`).
      The name is misleading; it's really just a blob of 256 bits.
      A separate `arith_uint256` allows arithmetic (used, for example,
      in PoW calculations)."
  a7link="https://bitcoincore.reviews/28107#l-203"

  q8="Why does `transaction_identifier` subclass `uint256` instead of
      being a completely new type?"
  a8="It allows us to use explicit and implicit conversions to leave
      code that is expecting a transaction ID in the form of a `uint256`
      unchanged until it's an appropriate time to refactor to use the new,
      stricter `Txid` or `Wtxid` types."
  a8link="https://bitcoincore.reviews/28107#l-219"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.117][] is a release of this library for building LN-enabled
  applications.  It includes security bug fixes related to the [anchor
  outputs][topic anchor outputs] features included in the immediately
  prior release.  The release also improves pathfinding, improves
  [watchtower][topic watchtowers] support, enables [batch][topic payment
  batching] funding of new channels, among several other features and
  bug fixes.

- [BDK 0.29.0][] is a release of this library for building wallet
  applications.  It updates dependencies and fixes a (likely rare) bug
  affecting cases where a wallet received more than one output from
  miner coinbase transactions.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27596][bitcoin core #27596] finishes the first phase
  of the [assumeutxo][topic assumeutxo] project, containing all the
  remaining changes necessary to both use an assumedvalid snapshot
  chainstate and do a full validation sync in the background. It
  makes UTXO snapshots loadable via RPC (`loadtxoutset`) and adds
  `assumeutxo` parameters to chainparams.

    Although the feature set will not be available on mainnet until
    [activated][bitcoin core #28553], this merge marks the culmination of
    a multi-year effort. The project, [proposed in 2018][assumeutxo core dev] and
    [formalized in 2019][assumeutxo 2019 mailing list],
    will significantly improve the user experience of new full
    nodes first coming onto the network. Follow-ups of the merge include
    [Bitcoin Core #28590][bitcoin core #28590],
    [#28562][bitcoin core #28562], and [#28589][bitcoin core #28589].

- [Bitcoin Core #28331][], [#28588][bitcoin core #28588],
  [#28577][bitcoin core #28577], and [GUI #754][bitcoin core gui #754]
  add support for [version 2 encrypted P2P transport][topic v2 p2p
  transport] as specified in [BIP324][].  The feature is currently
  disabled by default but can be enabled using the `-v2transport`
  option.

    Encrypted transport helps improve the privacy of Bitcoin users by
    preventing passive observers (such as ISPs) from directly
    determining which transactions nodes relay to their peers.  It's also
    possible to use encrypted transport to thwart active
    man-in-the-middle observers by comparing session identifiers.  In
    the future, the addition of other [features][topic countersign] may
    make it convenient for a lightweight client to securely connect to a
    trusted node over a P2P encrypted connection.

- [Bitcoin Core #27609][] makes the `submitpackage` RPC available on
  non-regtest networks.  Users can use this RPC to submit packages of
  a single transaction with its unconfirmed parents, where none of the
  parents spend the output of another parent. The child transaction can
  be used to CPFP parents that are below the node's dynamic mempool
  minimum feerate. However, while [package relay][topic package relay]
  is not yet supported, these transactions may not necessarily propagate
  to other nodes on the network.

- [Bitcoin Core GUI #764][] removes the ability to create a legacy
  wallet in the GUI.  The ability to create legacy wallets is being
  removed; all newly created wallets in future versions of Bitcoin Core
  will be [descriptor][topic descriptors]-based.

- [Core Lightning #6676][] adds a new `addpsbtoutput` RPC that will add
  an output to a [PSBT][topic psbt] for receiving funds onchain to the
  node's wallet.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27596,28590,28562,28589,28331,28588,28577,28553,754,27609,764,6676,1500" %}
[roose txhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021975.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[ldk 0.0.117]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.117
[bdk 0.29.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.29.0
[review club 28107]: https://bitcoincore.reviews/28107
[wtxid example]: https://github.com/bitcoin/bitcoin/blob/3cd02806ecd2edd08236ede554f1685866625757/src/net_processing.cpp#L4334
[GenTxid]: https://github.com/bitcoin/bitcoin/blob/dcfbf3c2107c3cb9d343ebfa0eee78278dea8d66/src/primitives/transaction.h#L425
[news104 wtxid]: /en/newsletters/2020/07/01/#bips-933
[assumeutxo core dev]: https://btctranscripts.com/bitcoin-core-dev-tech/2018-03/2018-03-07-priorities/#:~:text=“Assume%20UTXO”
[assumeutxo 2019 mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
