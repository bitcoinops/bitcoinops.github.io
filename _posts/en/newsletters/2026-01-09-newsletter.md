---
title: 'Bitcoin Optech Newsletter #387'
permalink: /en/newsletters/2026/01/09/
name: 2026-01-09-newsletter
slug: 2026-01-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter warns of a wallet migration bug in Bitcoin Core,
summarizes a post about using the Ark protocol as an LN channel factory, and
links to a draft BIP for silent payment descriptors.  Also included are our
regular sections describing release candidates and notable
changes to popular Bitcoin infrastructure software.

## News

- **Bitcoin Core wallet migration bug**: Bitcoin Core posted a [notice][bitcoin
  core notice] of a bug in the legacy wallet migration feature in versions 30.0
  and 30.1. Users of a Bitcoin Core legacy wallet who use an unnamed wallet,
  had not previously migrated their wallet to a descriptor wallet, and who
  attempt a migration in these versions, could, if the migration fails, have
  their wallet directory deleted, potentially resulting in a loss of funds.
  Wallet users should not attempt wallet migrations using the GUI or RPC until
  v30.2 is released (see [Bitcoin Core 30.2rc1](#bitcoin-core-30-2rc1) below). Users of features other
  than legacy wallet migration can continue to use these Bitcoin Core versions
  as normal.

- **Using Ark as a channel factory**:
  René Pickhardt [wrote][rp delving ark cf] on Delving Bitcoin about his
  discussions and ideas around whether [Ark][topic ark]'s best use case might
  be as a flexible [channel factory][topic channel factories] rather than as an end-user payment solution.
  Pickhardt's earlier research has focused on techniques to optimize payment
  success on the Lightning Network through [routing][news333 rp routing] and
  [channel balancing][news359 rp balance]. Ark-like structures containing
  Lightning channels have been discussed earlier ([1][optech superscalar],
  [2][news169 jl tt], [3][news270 jl cov]).

  Pickhardt's ideas focus on the possibility of many channel owners batching
  their channel liquidity changes (i.e. opens, closes, splices) using the vTXO
  structure of Ark as a way to significantly reduce the on-chain cost of
  operating the Lightning Network at the expense of additional liquidity
  overhead during the time between when one channel is forfeited and when its
  Ark batch fully expires. By using Ark batches as efficient channel
  factories, LSPs could provide liquidity to more end users efficiently,
  and the built-in expiration of the batches guarantees
  they can reclaim liquidity from idle channels without a costly
  dedicated on-chain force-close sequence. Routing nodes would also benefit
  from more efficient channel management operations by using regular batches
  to shift liquidity between their channels rather than individual splice
  operations.

  Greg Sanders [replied][delving ark hark] that he's been investigating similar possibilities,
  specifically using [hArk][sr delving hark] to facilitate the (mostly) online
  transfer of a Lightning channel state from one batch to another. hArk would
  require [CTV][topic op_checktemplateverify], `OP_TEMPLATEHASH`, or a similar
  opcode.

  Vincenzo Palazzo [replied][delving ark poc] with his proof-of-concept code implementing an Ark
  channel factory.

- **Draft BIP for silent payment descriptors**: Craig Raw [posted][sp ml]
  to the Bitcoin-Dev mailing list a proposal for a draft [BIP][BIPs #2047],
  which defines a new top-level descriptor script expression `sp()` for
  [silent payments][topic silent payments].
  According to Raw, the descriptor provides a standardized way to represent silent
  payment outputs within the output descriptor framework, enabling wallet
  interoperability and recovery using existing descriptor-based infrastructure.

  The `sp()` expression takes as an argument one of the two new key expressions, both defined
  in the same proposal:

  - `spscan1q..`: A
    [bech32m][topic bech32] encoding of the scan private key and the
    spend public key, with the `q` character representing silent payment version
    `0`.

  - `spspend1q..`: A bech32m encoding of the scan private key and
    the spend private key, with the `q` character representing silent payment version
    `0`.

  Optionally, the `sp()` expression can take as input arguments a `BIRTHDAY`,
  defined as a positive integer representing the block height at which scanning
  should begin (must be > 842579, the block height at which [BIP352][] was merged),
  and zero or more `LABEL`s as integers used with the wallet.

  The output scripts produced by `sp()` are [BIP341][] taproot outputs as specified in BIP352.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 30.2rc1][] is a release candidate of a minor version that fixes
  (see [Bitcoin Core #34156](#bitcoin-core-34156)) a bug where the entire
  `wallets` directory could be deleted accidentally when migrating an unnamed
  legacy wallet (see [above](#bitcoin-core-wallet-migration-bug)).

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #34156][] and [Bitcoin Core #34215][] fix a bug in versions 30.0
  and 30.1 where the entire `wallets` directory could be deleted accidentally.
  When migrating a legacy unnamed wallet fails, the cleanup logic is intended to
  remove only the newly created [descriptor][topic descriptors] wallet
  directory. However, since an unnamed wallet resides directly in the top-level
  wallets directory, the entire directory was deleted. The second PR addresses a
  similar issue with the `createfromdump` command of `wallettool` (see
  Newsletters [#45][news45 wallettool] and [#130][news130 createfrom]) when a
  wallet name is an empty string and the dump file contains a checksum error.
  Both fixes ensure that only the newly created wallet files are removed.

- [Bitcoin Core #34085][] eliminates the separate `FixLinearization()` function
  by integrating its functionality into `Linearize()`; `TxGraph` now postpones
  fixing clusters until their first re-linearization. The number of calls to
  `PostLinearize` is reduced because the spanning-forest linearization (SFL)
  algorithm (see [Newsletter #386][news386 sfl]) effectively performs similar
  work when loading an existing linearization. This is part of the [cluster
  mempool][topic cluster mempool] project.

- [Bitcoin Core #34197][] removes the `startingheight` field from the
  `getpeerinfo` RPC response, effectively deprecating it. Using the
  configuration option `deprecatedrpc=startingheight` retains the field in the
  response. The `startingheight` states a peer’s self-reported chaintip height when the connection was initiated. This deprecation is based on the idea that the starting height
  reported in a peer's `VERSION` message is unreliable. It will be fully removed
  in the next major version.

- [Bitcoin Core #33135][] adds a warning when `importdescriptors` is called with
  a [miniscript][topic miniscript] [descriptor][topic descriptors] containing an
  `older()` value (which specifies a [timelock][topic timelocks]) that has no
  consensus meaning in [BIP68][] (relative timelocks) and [BIP112][] (OP_CSV).
  While some protocols, such as Lightning, intentionally use non-standard values
  to encode extra data, this practice is risky because the value may appear
  strongly timelocked when it is actually not delayed.

- [LDK #4213][] sets [blinded path][topic rv routing] defaults: when building a
  blinded path that is not for an [offers][topic offers] context, it aims to
  maximize privacy by using a non-compact blinded path and pads it to four hops
  (including the recipient). When the blinded path is for an offer, the byte
  size is minimized by reducing the padding and attempting to build a compact
  blinded path.

- [Eclair #3217][] adds an accountability signal for [HTLCs][topic htlc],
  replacing the experimental [HTLC endorsement][topic htlc endorsement] signal.
  This aligns with the latest specification updates in [BOLTs #1280][] for
  [channel jamming][topic channel jamming attacks] mitigations.  The new
  proposal treats the signal as an accountability flag for scarce resources,
  indicating that protected HTLC capacity was used, and that downstream peers
  can be held responsible for a timely resolution.

- [LND #10367][] renames the experimental `endorsement` signal from [BLIP4][] to
  `accountable` to align with the latest proposal in [BLIPs #67][], which is
  based on the proposed [BOLTs #1280][].

- [Rust Bitcoin #5450][] adds validation to the transaction decoder to reject
  non-coinbase transactions that contain a `null` prevout, as dictated by a
  consensus rule.

- [Rust Bitcoin #5434][] adds validation to the transaction decoder, rejecting
  coinbase transactions with a `scriptSig` length outside the  2–100 byte range.

{% include snippets/recap-ad.md when="2026-01-13 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2047,34156,34215,34085,34197,33135,4213,3217,1280,10367,67,5450,5434" %}
[rp delving ark cf]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179
[news333 rp routing]: /en/newsletters/2024/12/13/#insights-into-channel-depletion
[news359 rp balance]: /en/newsletters/2025/06/20/#channel-rebalancing-research
[optech superscalar]: /en/podcast/2024/10/31/
[news169 jl tt]: /en/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[news270 jl cov]: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability
[delving ark hark]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/2
[delving ark poc]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/4
[sr delving hark]: https://delvingbitcoin.org/t/evolving-the-ark-protocol-using-ctv-and-csfs/1602
[bitcoin core notice]: https://bitcoincore.org/en/2026/01/05/wallet-migration-bug/
[Bitcoin Core 30.2rc1]: https://bitcoincore.org/bin/bitcoin-core-30.2/test.rc1/
[news45 wallettool]: /en/newsletters/2019/05/07/#new-wallet-tool
[news130 createfrom]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news386 sfl]: /en/newsletters/2026/01/02/#bitcoin-core-32545
[sp ml]:https://groups.google.com/g/bitcoindev/c/bP6ktUyCOJI