---
title: 'Bitcoin Optech Newsletter #423'
permalink: /en/newsletters/2026/09/18/
name: 2026-09-18-newsletter
slug: 2026-09-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an analysis of mining pool difficulty
controllers stranding slowed miners, describes a proposed improvement to
Utreexo's initial block download, and links to a draft BIP for specifying
unspendable taproot internal keys. Also included are our regular sections
describing recent changes to services and client software, announcing new
releases and release candidates, and describing notable changes to popular
Bitcoin infrastructure software.

## News

- **Vardiff controllers that strand slowing miners:** Eric Price [posted][price
  vardiff] to Delving Bitcoin an analysis of how [mining pools][topic pooled
  mining] adjust difficulty for a miner that slows down. A pool assigns each
  miner a share difficulty, a target easier than the network's that a block
  header candidate must meet to be submitted as a share. Software called a
  variable difficulty (vardiff) controller, running in the pool or in a proxy
  between the miner and the pool, raises or lowers that difficulty based on
  how quickly the miner's shares arrive, aiming for a steady rate. A miner
  that slows keeps the difficulty set for its former speed, so it produces few
  shares. A controller that updates only when shares arrive may fail to notice
  the slowdown.

  Price argues that adjusting the controller's parameters cannot fix this, since
  the controller cannot estimate a rate from shares that do not arrive. A
  controller that recomputes only when a share lands can hold difficulty too
  high indefinitely. His fix is a timer that lowers the difficulty whenever a
  fixed interval passes without a share from the miner. The Stratum v2 reference
  implementation already does this, although it recovers slowly for miners with
  long-lived connections. Ckpool recomputes only on shares. He released a
  [shaping proxy][shape proxy] that drops a fraction of a miner's shares so
  operators can test whether their pool lowers the difficulty.

  Anthony Towns [suggested][towns vardiff] handling this in the local proxy or
  gateway used in Stratum v2 and [DATUM][news325 datum] deployments, for example
  by halving a connection's difficulty after 30 seconds without a share. Price
  agreed and argued in a [separate thread][price frontier] that per-miner
  control must sit at the last hop that still sees each miner's shares. {% assign timestamp="23:06" %}

- **Improvements in Utreexo initial block download**: Davidson Souza
  [posted][utreexo ibd del] to Delving Bitcoin about a way to improve the
  performance of [Utreexo][topic utreexo] during initial block download (IBD).
  Utreexo is a dynamic accumulator that represents the UTXO set as a forest of
  perfect merkle trees, allowing nodes to store only the roots. The goal is to
  reduce the storage requirements for a validating node at the cost of increased
  bandwidth, since each transaction verification requires an inclusion proof
  appended to it. Each inclusion proof has a size similar to that of its related
  block, for a total data requirement of around 1.3TB. Even with extensive caching
  of recently spent UTXOs, proof data for explicit deletion weighs around 200GB.
  The proposal would eliminate the need for deletion proofs during IBD,
  resulting in a near-zero proof overhead.

  According to BIP181, currently being discussed in [BIPs #1923], Utreexo has a
  `modify` operation that performs both addition and deletion of an output from
  the tree. The former follows a multi-step process which leverages a destroy-and-move
  cycle, while the latter works by deleting a node of the tree and pushing the sibling
  to the position where their parent was. Souza and other developers proposed to
  modify the addition operation to include an implicit deletion. If you know beforehand
  that a UTXO has been spent, you can avoid adding it to the tree and just push
  the root directly up in the tree, as expected by the deletion operation.

  One of the critical points is how to know which UTXOs have already been spent.
  Souza's proposal leverages the [SwiftSync][topic swiftsync]
  hintsfile, a file whose goal is exactly that of
  keeping track of spent outputs, while also keeping a hash aggregate to check
  whether the provided file is correct. This means that the implicit deletion
  operation can only be leveraged during IBD. After that, a Utreexo client
  will go back to normal addition and deletion operations.
  An `assumevalid` SwiftSync implementation is under development in
  [Floresta #1115][flor PR115], while a non-`assumevalid` version is actively
  being developed. {% assign timestamp="1:18" %}

- **New BIP draft for unspendable internal keys**: NTL [posted][unspendable ml] to
  the Bitcoin-Dev mailing list about his proposal for a new BIP draft to specify how
  to make the [taproot][topic taproot] key path unspendable. The new specification
  builds on a prior discussion on Delving Bitcoin between Salvatore Ingala, Pieter Wuille,
  Josie Baker and other developers (see [Newsletter #283][news283 unspendable])
  and on a previous attempt by Andrew Toth to define a dedicated BIP in [BIPs #1746][]
  (see [Newsletter #338][news338 unspendable]).

  The proposal, already available as a [draft][unspendable gh], specifies `_` as
  a placeholder for the internal key with no known signing key. It also states that
  the internal key must be derived from a synthetic [BIP32][] extended public key
  using the [BIP341][] Nothing Up My Sleeve (NUMS) point, which is a point with unknown
  discrete logarithm, and a chaincode, which is a tagged hash of the normalized policy,
  which allows different implementations to independently reproduce the same address.

  According to the author, the new proposal follows three guiding principles: It does
  not police adherence to other BIPs except when they directly affect this specific issue,
  it does not propose new cryptography or structures but uses only what is already
  available, and it does not claim semantic canonicalization of the script. {% assign timestamp="1:17:51" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **BitBoxApp adds Spark-based Lightning payments:**
  BitBox [announced][bitbox ln blog] a public beta hot wallet in the mobile
  BitBoxApp [4.52.0][bitboxapp 4.52.0] built on the Breez SDK and the Spark
  [statechain][topic statechains]. {% assign timestamp="1:24:09" %}

- **Covenants.diy script editor:**
  [covenants.diy][covenants diy] is an editor for constructing [covenant][topic
  covenants] scripts and stepping through their execution in the browser. It supports
  capabilities including [`OP_CTV`][topic op_checktemplateverify],
  [`OP_CSFS`][topic op_checksigfromstack], [`OP_CAT`][topic op_cat],
  [ANYPREVOUT][topic sighash_anyprevout], `OP_TEMPLATEHASH`, `OP_INTERNALKEY`,
  `OP_PAIRCOMMIT`, and `OP_TXHASH` and is meant to be used on test networks. {% assign timestamp="1:28:40" %}

- **EntropyLab offline key calculator:**
  [EntropyLab][entropylab gh] is a self-contained HTML file for air-gapped use
  that converts user-supplied entropy or existing key material into [BIP39][]
  seeds, extended keys, [descriptors][topic descriptors], addresses, [BIP85][]
  child entropy, and [BIP352][] [silent payment][topic silent payments]
  addresses, among other features. {% assign timestamp="59:46" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Eclair 0.14.3][] is a security release for this LN node implementation that
  fixes vulnerabilities exploitable by malicious peers and upgrading is strongly
  recommended. It fixes issues with channel closing, [splicing][topic splicing],
  and [on-the-fly funding][topic jit channels]. It also adds configurable limits on
  funding feerates and allows [trampoline nodes][topic trampoline payments] to
  retain lower fees to improve payment success, as described in the notable
  changes below. {% assign timestamp="1:31:10" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35445][] fixes a compatibility bug that prevented existing
  [descriptor][topic descriptors] wallets with [miniscript][topic miniscript]
  expressions using `h`-style hardened derivation markers from loading after
  upgrading to version 31.0. An earlier change, [#31734][bitcoin core #31734],
  altered how Bitcoin Core represented hardened derivation paths when
  calculating internal descriptor identifiers, causing the newer software to
  incorrectly report that the existing wallet was corrupted. Stored identifiers
  are now treated as links between related wallet records rather than as values
  to recompute and validate. The `importdescriptors` and
  `createwalletdescriptor` RPCs now compare canonical descriptor strings when
  checking whether a descriptor is already present. {% assign timestamp="1:33:34" %}

- [Bitcoin Core #36076][] fixes a bug where `combinepsbt` could discard an
  input's requested signature hash (sighash) type when combining [PSBTs][topic
  psbt]. If the first PSBT omitted `PSBT_IN_SIGHASH_TYPE`, signatures from
  another PSBT were copied without that field, potentially causing finalization
  to reject valid signatures using a non-default sighash type, such as
  `ALL|ANYONECANPAY`. The field is now copied when absent from the first PSBT,
  allowing finalization regardless of argument order. {% assign timestamp="1:38:51" %}

- [Bitcoin Core #36150][] fixes a bug where enabling pruning together with a
  new [compact block filter index][topic compact block filters]
  (`-blockfilterindex`) or UTXO set statistics index (`-coinstatsindex`) (see
  [Newsletter #198][news198 coinstats]) could prevent the index from
  synchronizing. When an unpruned node was restarted with both settings
  enabled, the block files could be pruned before the new index determined
  which blocks were needed. Now, the index installs a pruning lock at height
  zero, even before processing its first block. {% assign timestamp="1:42:18" %}

- [Bitcoin Core #36174][] adds send-side backpressure to the replacement HTTP
  server (see [Newsletter #411][news411 http]), complementing the receive-side
  protection described in [Newsletter #422][news422 http]. Previously, clients
  could send many requests without reading the responses, causing queued
  response data to grow indefinitely. Now, the server pauses processing of
  further requests for a connection when its send buffer exceeds 32 MiB,
  resuming when the client drains the responses. The earlier fix prevented
  incoming requests from accumulating faster than they could be processed. {% assign timestamp="1:44:37" %}

- [Bitcoin Core #34743][] changes how manually selected peers are handled when
  they stall block downloading during IBD (see [Newsletter #237][news237
  stall]). Previously, if a peer failed to deliver a block and the download
  could not advance without it, the node would disconnect the peer. Now, for
  peers selected using `-addnode`, `-connect`, or the `addnode` RPC, the node
  makes their outstanding blocks available to be requested from other peers and
  pauses new block requests to the stalling peer for two minutes. Manual peers
  remain subject to separate block download and header sync timeouts. {% assign timestamp="1:46:13" %}

- [Bitcoin Core #36081][] adds a `bestblockhash` field to the `getmininginfo`
  RPC response. Together with the existing `next` object (see [Newsletter
  #339][news339 mininginfo]), this lets mining software obtain the current tip
  hash and the next block's difficulty target from a single RPC call.
  Previously, obtaining the hash and mining information through separate RPC
  calls could race with a tip change, producing values referring to different
  tips. {% assign timestamp="1:48:07" %}

- [Bitcoin Core #35975][] fixes a wallet crash that occurred when calling
  `bumpfee` on two malleated versions of the same transaction. Previously,
  bumping one version did not immediately mark the other as replaced.
  Attempting to bump the other version could then trigger an assertion failure
  and crash the node. Now, bumping either version marks all its malleated
  variants as replaced. Attempting to bump a variant that has already been
  replaced results in an error. The PR also ensures that comments and
  [replacement][topic rbf] metadata are copied to malleated transactions,
  including malleated fee-bump replacements, and persist after reloading the
  wallet. {% assign timestamp="1:48:59" %}

- [BIPs #2241][] adds [BIP332][], which specifies opt-in relay of recent stale
  chain tips, previously discussed in [Newsletter #417][news417 staletip]. The
  `staletip` message includes a known fork-point block hash, the stale branch's
  headers, and a flag indicating whether the sender is willing to serve the
  stale tip's block data. Peers negotiate support using [BIP434][], implemented
  in Bitcoin Core as described in [Newsletter #410][news410 bip434].
  Recommended resource limits include 20 headers per announcement and a
  1,000-block recency window. {% assign timestamp="1:50:04" %}

- [BIPs #2258][] updates [BIP93][] [codex32][topic codex32] to include the
  prefix's contribution when checking checksum length limits. Previously, these
  checks only counted the data portion, which allowed some strings to exceed
  the lengths covered by the stated error-detection guarantees of the checksum.
  The specification and reference implementation now use the complete, expanded
  length to select and validate the checksum. Additionally, the PR restricts
  master-seed encodings to 16-, 20-, 24-, 28-, 32-, or 64-byte seeds, reducing
  ambiguity when correcting accidentally inserted or deleted characters.
  Existing encodings at these sizes remain unchanged, but encodings of other
  sizes that were previously permitted no longer conform. {% assign timestamp="1:53:09" %}

- [Eclair #3380][] rejects API requests containing an `Origin` header,
  including WebSocket connections, to prevent cross-site request forgery using
  cached HTTP Basic authentication credentials. Browser-based frontends must
  now use their own backend instead of calling Eclair directly. Command-line
  clients such as `curl` and `eclair-cli` remain unaffected when they do not
  set this header. {% assign timestamp="1:56:33" %}

- [Eclair #3376][] fixes several issues with channel closing, [splicing][topic
  splicing], and [on-the-fly funding][topic jit channels]. When Eclair pays the
  fees, the closing fee negotiation rejects peer proposals that exceed the
  configured maximum closing feerate and are outside the local fee range.
  Previously, the negotiation fallback could accept excessive fees that could
  deplete the local channel balance. When force-closing during an incomplete
  splice, Eclair now uses the latest commitment whose funding transaction is
  fully signed if the peer's signatures needed to publish the splice are
  missing. If the peer broadcasts the splice and it confirms first, Eclair
  instead closes using the commitment that spends the new funding output.
  Additionally, the PR checks relay fees and [CLTV expiry deltas][topic cltv
  expiry delta] before executing on-the-fly funding for payments via [blinded
  paths][topic rv routing], preventing unsafe forwarding that could result in a
  loss of funds. The PR adds a new `on-chain-fees.max-funding-feerate` setting,
  defaulting to 50 sat/vB, that caps [automatically estimated feerates][topic
  fee estimation] for channel opens and splices. {% assign timestamp="1:57:37" %}

- [Eclair #3372][] allows Eclair nodes acting as [trampoline nodes][topic
  trampoline payments] to retain lower fees, making more of the sender's fee
  budget available for downstream routing. For payments with routing hints or
  [blinded paths][topic rv routing], the new `relay.fees.min-local-trampoline`
  setting defines the minimum fee that Eclair retains. Operators can set this
  minimum below their standard outgoing channel fees to help payments succeed
  when the total downstream fees, including those charged by the recipient's
  Lightning Service Provider (LSP), would otherwise exceed the budget. Payments
  without those hints continue to include the usual local channel cost.
  Additionally, the PR increases the default minimum total fee budget required
  by `relay.fees.min-trampoline` from 1 sat plus 0.01% of the forwarded amount
  to 2 sats plus 0.04%. {% assign timestamp="2:04:34" %}

- [LND #11163][] fixes the handling of replayed [HTLCs][topic htlc] when using
  the forward interceptor (see [Newsletter #104][news104 intercept]), which
  allows external software to approve or reject forwarding. After a peer
  reconnects or a node restarts, LND may reprocess an incoming HTLC that it has
  already forwarded. Previously, LND could treat this as a new interception and
  reject it if the expiry was too close, for example, even though the outgoing
  HTLC remained active. Now, LND checks existing forwarding records, allowing
  the replay to continue through the original payment's resolution. For
  payments still awaiting the interceptor's decision, LND instead keeps the
  HTLC on hold with its original automatic failure deadline (see [Newsletter
  #224][news224 intercept]), avoiding a second expiry check on the replay. {% assign timestamp="2:05:57" %}

- [BDK #2246][] and [#2263][bdk #2263] improve wallet balance classification
  (see [Newsletter #213][news213 balance]) by checking an output's unsettled
  transaction ancestry. Previously, change from spending an unconfirmed
  incoming payment could be considered trusted, even though it depended on an
  incoming transaction confirming. BDK now carries that untrusted status
  through descendant transactions. The new `classify_outpoints` API exposes
  per-output classifications, while the updated `balance` API lets applications
  separately define which transactions are untrusted and when transactions are
  considered settled. The second PR adds
  `ChainPosition::confirmations_lower_bound`, to help applications define
  settlement rules such as requiring six confirmations. It returns a
  conservative confirmation count, including the confirming block, and returns
  zero for unconfirmed transactions or confirmation heights above the supplied
  tip. {% assign timestamp="2:07:44" %}

{% include snippets/recap-ad.md when="2026-09-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1923,1746,35445,31734,36076,36150,36174,34743,36081,2241,3380,2258,3376,3372,11163,2246,2263,35975" %}

[price vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718
[shape proxy]: https://github.com/marafoundation/sv2-apps/tree/shape-proxy-v0.1.0/test-tools/shape-proxy
[towns vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718/4
[news325 datum]: /en/newsletters/2024/10/18/#datum-protocol-announced
[price frontier]: https://delvingbitcoin.org/t/vardiff-belongs-at-the-frontier/2734
[utreexo ibd del]: https://delvingbitcoin.org/t/implicit-deletions-and-improvements-in-utreexo-ibd/2881
[flor PR115]: https://github.com/getfloresta/Floresta/pull/1115
[bitbox ln blog]: https://blog.bitbox.swiss/en/introducing-lightning-in-the-bitboxapp/
[bitboxapp 4.52.0]: https://github.com/BitBoxSwiss/bitbox-wallet-app/releases/tag/v4.52.0
[covenants diy]: https://covenants.diy/
[entropylab gh]: https://github.com/OogaBoogaX/entropylab
[unspendable ml]: https://groups.google.com/g/bitcoindev/c/se3TkNnbno4
[news283 unspendable]: /en/newsletters/2024/01/03/#how-to-specify-unspendable-keys-in-descriptors
[news338 unspendable]: /en/newsletters/2025/01/24/#draft-bip-for-unspendable-keys-in-descriptors
[unspendable gh]: https://github.com/bitryonix/bips/blob/bip-xxxx-unspendable-internal-keys/bip-xxxx-unspendable-internal-keys.mediawiki
[news198 coinstats]: /en/newsletters/2022/05/04/#bitcoin-core-21726
[news237 stall]: /en/newsletters/2023/02/08/#bitcoin-core-25880
[news339 mininginfo]: /en/newsletters/2025/01/31/#bitcoin-core-31583
[news417 staletip]: /en/newsletters/2026/08/07/#draft-bip-for-stale-tip-relay
[news410 bip434]: /en/newsletters/2026/06/19/#bitcoin-core-35221
[news411 http]: /en/newsletters/2026/06/26/#bitcoin-core-35182
[news422 http]: /en/newsletters/2026/09/11/#bitcoin-core-36123
[Eclair 0.14.3]: https://github.com/ACINQ/eclair/releases/tag/v0.14.3
[news104 intercept]: /en/newsletters/2020/07/01/#lnd-4018
[news224 intercept]: /en/newsletters/2022/11/02/#lnd-6831
[news213 balance]: /en/newsletters/2022/08/17/#bdk-640
