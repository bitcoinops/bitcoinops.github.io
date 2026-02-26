---
title: 'Bitcoin Optech Newsletter #394'
permalink: /en/newsletters/2026/02/27/
name: 2026-02-27-newsletter
slug: 2026-02-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter looks at a proposed BIP for including supplemental
information with output script descriptors.  Also included are our regular
sections summarizing popular questions on the Bitcoin Stack Exchange, announcing
new releases and release candidates, and describing recent changes to popular
Bitcoin infrastructure software.

## News

- **Draft BIP for output script descriptor annotations**: Craig Raw
  [posted][annot ml] to the Bitcoin-Dev mailing list about a new BIP idea to
  address feedback that emerged during the discussion around BIP392
  (see [Newsletter #387][news387 sp]).
  According to Raw, metadata, such as the wallet birthday expressed as a
  block height, could make [silent payment][topic silent payments] scanning more efficient.
  However, metadata is not technically needed to determine output scripts,
  thus it is deemed unsuitable for inclusion in a [descriptor][topic descriptors].

  Raw's BIP proposes to provide useful metadata in the form of annotations, expressed
  as key/value pairs, appended directly to the descriptor string using URL-like query
  delimiters. An annotated descriptor would look like this:
  `SCRIPT?key=value&key=value#CHECKSUM`.
  Notably, characters `?`, `&`, and `=` are already defined in [BIP380][], thus the
  checksum algorithm would not need to be updated.

  In the [draft BIP][annot draft], Raw also defines three initial annotation keys specifically to make funds silent payment scanning more efficient:

  - Block Height `bh`: The block height at which a wallet received the first funds;

  - Gap Limit `gl`: The number of unused addresses to derive before stopping;

  - Max Label `ml`: The maximum label index to scan for, for silent payments wallets.

  Finally, Raw noted that annotations should not be used in the general wallet backup process,
  but only for making funds recovery more efficient without altering the scripts
  produced by the descriptor.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Is Bitcoin BIP324 v2 P2P transport distinguishable from random traffic?]({{bse}}130500)
  Pieter Wuille points out that [BIP324][]'s [v2 encrypted transport][topic v2 p2p
  transport] protocol supports shaping traffic patterns, although no known
  software implements that feature, concluding "today's implementations only
  defeat protocol signatures that involve patterns in the sent bytes, not in
  traffic".

- [What if a miner just broadcasts the header and never gives the block?]({{bse}}130456)
  User bigjosh outlines how a miner might behave after receiving a block header
  on the P2P network but before receiving the block's contents: by mining an
  empty block on top of it. Pieter Wuille clarifies that, in practice, many
  miners actually see new block headers by monitoring the work other mining
  pools give out to their miners, a technique known as spy mining.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 28.4rc1][] is a release candidate for a maintenance
  release of a previous major release series. It primarily contains
  wallet migration fixes and removal of an unreliable DNS seed.

- [Rust Bitcoin 0.33.0-beta][] is a beta release of this library for
  working with Bitcoin data structures. This is a large update with over
  300 commits that introduces a new `bitcoin-consensus-encoding` crate,
  adds P2P network message encoding traits, rejects transactions with
  duplicate inputs or output sums exceeding `MAX_MONEY` during
  decoding, and bumps major versions across all sub-crates.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #34568][] makes several breaking changes to the Mining
  IPC interface (see [Newsletter #310][news310 mining]). Deprecated
  methods `getCoinbaseRawTx()`, `getCoinbaseCommitment()` and
  `getWitnessCommitmentIndex()` (see [Newsletter #388][news388 mining])
  are removed, `context` parameters are added to `createNewBlock` and
  `checkBlock` so they can run on separate threads without blocking the
  [Cap'n Proto][capn proto] event loop, and default option values are
  declared in the schema. The `Init.makeMining` version number is bumped
  so that older clients receive a clear error instead of silently
  misinterpreting the new schema. The threading change is a prerequisite
  for the cooldown feature covered next.

- [Bitcoin Core #34184][] adds an optional cooldown to the
  `createNewBlock()` method on the Mining IPC interface. When enabled,
  the method always waits for Initial Block Download (IBD) to complete
  and for the tip to catch up before returning a block template. This
  prevents [Stratum v2][topic pooled mining] clients from being flooded
  with rapidly outdated templates during startup. A new `interrupt()`
  method is also added so IPC clients can cleanly abort a blocking
  `createNewBlock()` or `waitTipChanged()` call.

- [Bitcoin Core #24539][] adds a new `-txospenderindex` option that
  maintains an index of which transaction spent each confirmed output.
  When enabled, the `gettxspendingprevout` RPC is extended to return
  the `spendingtxid` and `blockhash` for confirmed transactions, in
  addition to its existing mempool lookups. Two new optional arguments
  are also added to the RPC: `mempool_only` restricts lookups to the
  mempool even when the index is available, and `return_spending_tx`
  returns the full spending transaction. The index does not require
  `-txindex` and is incompatible with pruning. This is particularly
  useful for Lightning and other second-layer protocols that need to
  track chains of spending transactions.

- [Bitcoin Core #34329][] adds two new RPCs for managing private
  transaction broadcasts (see [Newsletter #388][news388 private]):
  `getprivatebroadcastinfo` returns information about transactions
  currently in the private broadcast queue, including the chosen peer
  addresses and when each broadcast was sent, and
  `abortprivatebroadcast` cancels the broadcast of a specific
  transaction and its pending connections.

- [Bitcoin Core #28792][] completes the embedded ASMap series of PRs by bundling
  ASMap data directly in the Bitcoin Core binary, so users who enable
  `-asmap` no longer need to separately obtain a data file. Removing the
  build option `WITH_EMBEDDED_ASMAP` allows excluding the data. ASMap
  improves [eclipse attack][topic eclipse attacks] resistance by
  diversifying peer connections across Autonomous Systems (see
  Newsletters [#52][news52 asmap] and [#290][news290 asmap]). The
  feature remains off by default; the user must still specify `-asmap`
  to enable it. A new [documentation file][github asmap-data] outlines the
  process for sourcing the data and including it in a Bitcoin Core release.

- [Bitcoin Core #32138][] removes the `settxfee` RPC and `-paytxfee`
  startup option, which allowed users to set a static fee rate for all
  transactions. Both were deprecated in Bitcoin Core 30.0 (see
  [Newsletter #349][news349 settxfee]). Users should instead rely on
  [fee estimation][topic fee estimation] or set a per-transaction fee
  rate.

- [Bitcoin Core #34512][] adds a `coinbase_tx` field to the `getblock`
  RPC response at verbosity level 1 and above, containing the coinbase
  transaction's `version`, `locktime`, `sequence`, `coinbase` script,
  and `witness` data. Outputs are intentionally excluded to keep the
  response compact. Previously, accessing coinbase properties required
  verbosity 2, which decodes every transaction in the block. This is
  useful for monitoring [BIP54][] ([consensus cleanup][topic consensus
  cleanup]) coinbase locktime requirements or identifying mining pools
  from the coinbase script.

- [Core Lightning #8490][] adds a new `payment-fronting-node`
  configuration option that specifies one or more nodes to always use
  as entry points for incoming payments. When set, route hints in
  [BOLT11][] invoices and [blinded path][topic rv routing] introduction
  points in [BOLT12][topic offers] offers, invoices, and invoice
  requests are constructed to use only the specified fronting nodes.
  Previously, CLN would automatically select from the node's channel
  peers, potentially exposing different peers across invoices. The
  option can be set globally or overridden per offer.

- [Eclair #3250][] allows the `OpenChannelInterceptor` to automatically
  select a `channel_type` when the local node opens a channel without
  one explicitly set. Previously, automatic channel creation (e.g., by
  an LSP opening channels to clients) would fail unless a type was
  provided. The current default prefers [anchor channels][topic anchor
  outputs], with [simple taproot channels][topic simple taproot
  channels] expected to take priority in follow-up PRs.

- [LDK #4373][] adds support for sending [multipath payments][topic
  multipath payments] where the local node pays only a portion of the
  total invoice amount. A new `total_mpp_amount_msat` field in
  `RecipientOnionFields` allows declaring an MPP total larger than what
  this node sends, enabling multiple wallets or nodes to collaboratively
  pay a single invoice by each contributing part of the payment. The
  receiver collects HTLCs from all contributing nodes and claims the
  payment once the full amount arrives. [BOLT12][topic offers] support
  is left for a follow-up.

- [BDK #2081][] adds `spent_txouts()` and `created_txouts()` methods to
  `SpkTxOutIndex` and `KeychainTxOutIndex` that, given a transaction,
  return which tracked outputs it spent and which new tracked outputs it
  created. This enables wallets to easily determine the addresses and
  amounts involved in transactions they care about.

{% include snippets/recap-ad.md when="2026-03-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34568,34184,24539,34329,28792,32138,34512,8490,3250,4373,2081" %}

[annot ml]: https://groups.google.com/g/bitcoindev/c/ozjr1lF3Rkc
[news387 sp]: /en/newsletters/2026/01/09/#draft-bip-for-silent-payment-descriptors
[annot draft]: https://github.com/craigraw/bips/blob/descriptorannotations/bip-descriptorannotations.mediawiki
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news388 mining]: /en/newsletters/2026/01/16/#bitcoin-core-33819
[news388 private]: /en/newsletters/2026/01/16/#bitcoin-core-29415
[capn proto]: https://capnproto.org/
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news290 asmap]: /en/newsletters/2024/02/21/#improved-reproducible-asmap-creation-process
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news349 settxfee]: /en/newsletters/2025/04/04/#bitcoin-core-31278
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[Rust Bitcoin 0.33.0-beta]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.33.0-beta
