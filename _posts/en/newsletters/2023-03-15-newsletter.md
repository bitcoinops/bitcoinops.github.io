---
title: 'Bitcoin Optech Newsletter #242'
permalink: /en/newsletters/2023/03/15/
name: 2023-03-15-newsletter
slug: 2023-03-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter relays the announcement of a service bit being
used for testing Utreexo, links to several new software releases and
release candidates, and describes a merged Bitcoin Core pull request.

## News

- **Service bit for Utreexo:** Calvin Kim [posted][kim utreexo] to the
  Bitcoin-Dev mailing list that software currently designed for
  experimentation on signet and testnet will be using P2P protocol
  service bit 24.  The experimental software provides support for
  [Utreexo][topic utreexo], a protocol for allowing full verification of
  transactions by nodes that don't store a copy of the UTXO set,
  saving up to 5 GB of disk space compared to a modern Bitcoin Core full
  node (without any reduction in security).  A Utreexo node needs to
  receive extra data when it receives an unconfirmed transaction (or a block full of
  confirmed transactions), so the service bit will help a node find peers capable
  of providing the extra data. {% include functions/podcast-callout.md url="pod242 utreexo" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning v23.02.2][] is a maintenance release of this LN node
  software.  It reverts a change to the `pay` RPC that cause problems
  for other software and includes several other changes. {% include functions/podcast-callout.md url="pod242 cln" %}

- [Libsecp256k1 0.3.0][] of this cryptographic library.  It includes an
  API change which breaks ABI compatibility. {% include functions/podcast-callout.md url="pod242 lsp" %}

- [LND v0.16.0-beta.rc3][] is a release candidate for a new major
  version of this popular LN implementation. {% include functions/podcast-callout.md url="pod242 lnd" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25740][] allows a node using [assumeUTXO][topic
  assumeutxo] to verify all blocks and transactions on the best block
  chain until reaching the block where the assumeUTXO state claimed it
  was generated, building a
  UTXO set (chainstate) as of that block.  If that chainstate is equal
  to the assumeUTXO state downloaded when the node was first started, then the
  state is fully validated.  The node has validated every block on the
  best block chain, the same as any other full node, it has just
  validated them in a different order than a standard node.  The special
  chainstate used to perform the verification of older blocks is deleted
  the next time the node starts, freeing disk space.  Other parts of the
  [assumeUTXO project][] still need to be merged before it will be usable. {% include functions/podcast-callout.md url="pod242 bc25740" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="25740" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[libsecp256k1 0.3.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.0
[core lightning v23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[kim utreexo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021515.html
[assumeutxo project]: https://github.com/bitcoin/bitcoin/projects/11
[pod242 utreexo]: /en/podcast/2023/03/16/#service-bit-for-utreexo
[pod242 cln]: /en/podcast/2023/03/16/#core-lightning-v23-02-2
[pod242 lsp]: /en/podcast/2023/03/16/#libsecp256k1-0-3-0
[pod242 lnd]: /en/podcast/2023/03/16/#lnd-v0-16-0-beta-rc3
[pod242 bc25740]: /en/podcast/2023/03/16/#bitcoin-core-25740
