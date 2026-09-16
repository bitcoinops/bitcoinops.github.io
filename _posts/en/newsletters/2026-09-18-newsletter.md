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
  control must sit at the last hop that still sees each miner's shares.

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
  being developed.

FIXME:bitschmidty

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **BitBoxApp adds Spark-based Lightning payments:**
  BitBox [announced][bitbox ln blog] a public beta hot wallet in the mobile
  BitBoxApp [4.52.0][bitboxapp 4.52.0] built on the Breez SDK and the Spark
  [statechain][topic statechains].

- **Covenants.diy script editor:**
  [covenants.diy][covenants diy] is an editor for constructing [covenant][topic
  covenants] scripts and stepping through their execution in the browser. It supports
  capabilities including [`OP_CTV`][topic op_checktemplateverify],
  [`OP_CSFS`][topic op_checksigfromstack], [`OP_CAT`][topic op_cat],
  [ANYPREVOUT][topic sighash_anyprevout], `OP_TEMPLATEHASH`, `OP_INTERNALKEY`,
  `OP_PAIRCOMMIT`, and `OP_TXHASH` and is meant to be used on test networks.

- **EntropyLab offline key calculator:**
  [EntropyLab][entropylab gh] is a self-contained HTML file for air-gapped use
  that converts user-supplied entropy or existing key material into [BIP39][]
  seeds, extended keys, [descriptors][topic descriptors], addresses, [BIP85][]
  child entropy, and [BIP352][] [silent payment][topic silent payments]
  addresses, among other features.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-09-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1923" %}

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
