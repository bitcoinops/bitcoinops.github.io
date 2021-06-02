---
title: 'Bitcoin Optech Newsletter #151'
permalink: /en/newsletters/2021/06/02/
name: 2021-06-02-newsletter
slug: 2021-06-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to change Bitcoin Core's
transaction selection algorithm for miner block templates to slightly
increase miner profitability and give fee bumping users more
collective leverage.  Also included are our regular sections describing
software releases and release candidates, plus notable changes to popular
Bitcoin infrastructure software.

## News

- **Candidate Set Based (CSB) block template construction:** Mark
  Erhardt [posted][erhardt post] to the Bitcoin-Dev mailing list about
  an [analysis][es analysis] he and Clara Shikhelman performed on an
  alternative transaction selection algorithm for miners.  Bitcoin's
  consensus rules enforce that no transaction can be included in a block
  unless all of its unconfirmed ancestors are also included earlier in
  that same block.  Bitcoin Core addresses this constraint by treating
  each transaction with unconfirmed ancestors as if it contained both
  the fees and the size of those ancestors.  For example, if transaction B
  depends on unconfirmed transaction A, then Bitcoin Core adds together
  the fees paid by both transactions and divides them by the combined
  size of both transactions.  This allows Bitcoin Core to fairly compare
  all transactions in the mempool based on their effective feerate
  whether or not those transactions have any ancestors.

    However, Erhardt and Shikhelman note that a more sophisticated
    algorithm that may require a bit more CPU can find sets of related
    transactions that are even more profitable to mine than Bitcoin
    Core's existing simple algorithm.  The authors tested their
    algorithm on historic mempool data and found that it would've
    collected slightly more fees than Bitcoin Core's existing algorithm
    in almost all recent blocks.

    If implemented and used by miners, the improved algorithm could
    allow multiple users who each received an output from a large
    [coinjoin][topic coinjoin] or [batched payment][topic payment
    batching] to each pay a small part of the total fee necessary to [CPFP
    fee bump][topic cpfp] that coinjoin or payment.  That would be an
    improvement over the current case where each user's CPFP fee bump is
    considered independently and multiple related fee bumps may not have
    an aggregate effect on whether an ancestor transaction is mined.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 2.0.2][] is a minor release that adds support for message signing
  with the BitBox02, always uses `h` instead of `'` to indicated
  [BIP32][] paths with hardened derivation, and includes several bug
  fixes.

- [LND 0.13.0-beta.rc3][LND 0.13.0-beta] is a release candidate that
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

- [Bitcoin Core #20833][] is the first PR in an effort to implement
  [mempool package acceptance][package mempool accept blog] in Bitcoin
  Core. This change allows the `testmempoolaccept` RPC
  to accept multiple transactions where later transactions may be
  descended from earlier transactions. Future PRs may enable testing L2 transaction
  chains, submitting transaction packages directly to the mempool through RPCs
  and communicating packages over the P2P network.

- [Bitcoin Core #22017][] updates the code signing certificate used for
  Windows releases after the previous certificate was revoked by its
  issuer without them providing an explicit reason.  Several recent
  releases of Bitcoin Core might be re-released with slightly different
  version numbers so that their Windows binaries can use this
  certificate.

- [Bitcoin Core #18418][] increases the maximum number of UTXOs received
  to the same address that will be spent simultaneously if the
  `avoid_reuse` wallet flag is set.  The more outputs that are spent
  together, the higher the fee might be for that particular transaction relative to a wallet with
  default flags but, also, the less likely it becomes that third parties
  will be able to identify the user's later transactions.

- [C-Lightning #4501][] adds [JSON schemas][] for the output of
  roughly half of C-Lightning's current commands (with schemas for the
  other half planned to be added in the future).  Output produced during
  a run of C-Lightning's test suite is validated against the schemas to
  ensure consistency.  The schemas are also used to automatically
  generate C-Lightning's documentation about what output each command
  produces.

- [LND #5025][] adds basic support for using [signet][topic signet].  Of
  the other LN implementations tracked by Optech, C-Lightning also has
  support for signet (see [Newsletter #117][news117 cl4068]).

- [LND #5155][] adds a configuration option to randomly select which
  wallet UTXOs to spend in a transaction; this reduces UTXO
  fragmentation in the wallet over time.  By contrast, the default coin
  selection algorithm in LND spends higher value UTXOs before lower
  value UTXOs; this minimizes fees in the short term but may result in
  needing to pay higher fees in the future when all inputs near the size
  of a transaction, or larger, have already been spent.

- [BOLTs #672][] updates [BOLT2][] to allow nodes to negotiate a
  `option_shutdown_anysegwit` option which, if set, allows LN closing
  transactions to be able to pay any segwit script version, including
  script types that don't yet have consensus meaning on the network,
  such as addresses for [taproot][topic taproot].

- [BOLTs #872][] updates [BOLT3][]'s use of [BIP69][] to specify in more
  detail the sort order to use for commitment transaction inputs and
  outputs.  One commentator points out that the use of BIP69 has so far
  caused three separate problems that may have led to
  accidental channel closures and small amounts of funds lost to
  unnecessary onchain fees.  The commentator suggests that this is
  another reason to migrate away from explicit use of BIP69 (for other
  reasons, see [Newsletter #19][news19 bip69]).

{% include references.md %}
{% include linkers/issues.md issues="20833,22017,18418,4501,5025,5155,672,872" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc3
[HWI 2.0.2]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.2
[erhardt post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/019020.html
[es analysis]: https://gist.github.com/Xekyo/5cb413fe9f26dbce57abfd344ebbfaf2#file-candidate-set-based-block-building-md
[news117 cl4068]: /en/newsletters/2020/09/30/#c-lightning-4068
[news19 bip69]: /en/newsletters/2018/10/30/#bip69-discussion
[json schemas]: http://json-schema.org/
[package mempool accept blog]: https://brink.dev/blog/2021/01/21/fellowship-project-package-accept/
