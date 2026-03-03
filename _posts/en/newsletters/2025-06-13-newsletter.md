---
title: 'Bitcoin Optech Newsletter #358'
permalink: /en/newsletters/2025/06/13/
name: 2025-06-13-newsletter
slug: 2025-06-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes how the selfish mining danger threshold
can be calculated, summarizes an idea about preventing filtering of high
feerate transactions, seeks feedback about a proposed change to BIP390
`musig()` descriptors, and announces a new library for encrypting
descriptors.  Also included are our regular sections with the summary of
a Bitcoin Core PR Review Club, announcements of new releases and release
candidates, and descriptions of recent changes to popular Bitcoin
infrastructure projects.

## News

- **Calculating the selfish mining danger threshold:** Antoine Poinsot
  [posted][poinsot selfish] to Delving Bitcoin an expansion of the math
  from the 2013 [paper][es selfish] that gave the [selfish mining
  attack][topic selfish mining] its name (although the attack was
  [previously described][bytecoin selfish] in 2010).  He also provided a
  simplified mining and block relay
  [simulator][darosior/miningsimulation] that allows experimenting with
  the attack.  He focuses on reproducing one of the conclusions of the
  2013 paper: that a dishonest miner (or a cartel of well-connected
  miners) controlling 33% of the total network hashrate, with no additional
  advantages, can become marginally more profitable on a long term basis
  than the miners controlling 67% of the hashrate.  This is
  achieved by the 33% miner selectively delaying the announcement of some of
  the new blocks it finds.  As the dishonest miner's hashrate increases
  above 33%, it becomes even more profitable until it exceeds 50%
  hashrate and can prevent its competitors from keeping any new
  blocks on the best blockchain.

  We did not carefully review Poinsot's post, but his approach appeared
  sound to us and we would recommend it to anyone interested in
  validating the math or gaining a better understanding of it. {% assign timestamp="0:52" %}

- **Relay censorship resistance through top mempool set reconciliation:**
  Peter Todd [posted][todd feerec] to the Bitcoin-Dev mailing list about
  a mechanism that would allow nodes to drop peers that are filtering
  high-feerate transactions.  The mechanism depends on [cluster
  mempool][topic cluster mempool] and a set reconciliation mechanism
  such as that used by [erlay][topic erlay].  A node would use cluster
  mempool to calculate its most profitable set of unconfirmed
  transactions that could fit within (for example) 8,000,000 weight units (a
  maximum of 8 MB).  Each of the node's peers would also calculate their top
  8 MWU of unconfirmed transactions.  Using a highly efficient
  algorithm, such as [minisketch][topic minisketch], the node would
  reconcile its set of transactions with each of its peers.  In doing
  so, it would learn exactly what transactions each peer has in the top
  of its mempool.  Then the node would periodically drop the connection
  to whichever peer had the least profitable mempool on average.

  By dropping the least profitable connections, the node would
  eventually find peers that were least likely to filter out
  high-feerate transactions.  Todd mentioned that he hopes to work on an
  implementation after cluster mempool support is merged into Bitcoin
  Core.  He credited the idea to Gregory Maxwell and others; Optech
  first mentioned the underlying idea in [Newsletter #9][news9
  reconcile]. {% assign timestamp="59:26" %}

- **Updating BIP390 to allow duplicate participant keys in `musig()` expressions:**
  Ava Chow [posted][chow dupsig] to the Bitcoin-Dev mailing list to ask
  if anyone objected to updating [BIP390][] to allow `musig()`
  expressions in [output script descriptors][topic descriptors] to
  contain the same participant public key more than once.  This would
  simplify implementation and is explicitly allowed by the [BIP327][]
  specification of [MuSig2][topic musig].  As of this writing, no one has
  objected, and Chow has opened a [pull request][bips #1867] to change
  the BIP390 specification. {% assign timestamp="55:50" %}

- **Descriptor encryption library:** Josh Doman [posted][doman descrypt]
  to Delving Bitcoin to announce a library he's built that encrypts the
  sensitive parts of an [output script descriptor][topic descriptors] or
  [miniscript][topic miniscript] to the public keys contained within it.
  He describes what information is needed to decrypt:

  > - If your wallet requires 2-of-3 keys to spend, it will require
  >   exactly 2-of-3 keys to decrypt.
  >
  > - If your wallet uses a complex miniscript policy like "Either 2
  >   keys OR (a timelock AND another key)", encryption follows the same
  >   structure, as if all timelocks and hash-locks are satisfied.

  This differs from the encrypted descriptor backup scheme discussed in
  [Newsletter #351][news351 salvacrypt], in which knowledge of any
  public key contained within the descriptor allows decryption of the
  descriptor.  Doman argues that his scheme provides better privacy for
  cases where the encrypted descriptor is being backed up to a public or
  semi-public source, such as a blockchain. {% assign timestamp="31:35" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Separate UTXO set access from validation functions][review club 32317]
is a PR by [TheCharlatan][gh thecharlatan] that allows calling
validation functions by passing just the required UTXOs, instead of
requiring the complete UTXO set. It is part of the [`bitcoinkernel`
project][Bitcoin Core #27587], and is an important step to make the
library more usable for full-node implementations that do not implement
a UTXO set, such as [Utreexo][topic utreexo] or [SwiftSync][somsen
swiftsync] nodes (see [Newsletter #349][news349 swiftsync]).

In the first 4 commits, this PR reduces coupling between transaction
validation functions and the UTXO set by requiring the caller to first
fetch the `Coin`s or `CTxOut`s they require and passing those to the
validation function, instead of letting the validation function access
the UTXO set directly.

In subsequent commits, the dependency of `ConnectBlock()` on the UTXO set
is removed entirely by carving out the remaining logic that requires UTXO
set interaction into a separate `SpendBlock()` method. {% assign timestamp="43:05" %}

{% include functions/details-list.md
  q0="Why is carving out the new `SpendBlock()` function from
  `ConnectBlock()` helpful for this PR? How would you compare the
  purpose of the two functions?"
  a0="The `ConnectBlock()` function originally performed both block
  validation and UTXO set modifications. This refactor splits these
  responsibilities: `ConnectBlock()` is now only responsible for
  validation logic that doesn't require the UTXO set, while the new
  `SpendBlock()` function handles all UTXO set interactions. This allows
  a caller to use `ConnectBlock()` to do block validation without a UTXO
  set."
  a0link="https://bitcoincore.reviews/32317#l-37"

  q1="Do you see another benefit of this decoupling, besides allowing
  kernel usage without a UTXO set?"
  a1="Besides enabling kernel usage for projects without a UTXO set,
  this decoupling makes the code easier to test in isolation and simpler
  to maintain. One reviewer also notes that removing the need for UTXO
  set access opens the door for validating blocks in parallel, which is
  an important feature of SwiftSync."
  a1link="https://bitcoincore.reviews/32317#l-64"

  q2="`SpendBlock()` takes a `CBlock block`, `CBlockIndex pindex` and
  `uint256 block_hash` parameter, all referencing the block being spent.
  Why do we need 3 parameters to do that?"
  a2="Validation code is performance-critical, it affects important
  parameters such as block propagation speed. Calculating the block hash
  from a `CBlock` or `CBlockIndex` is not free, because the value is not
  cached. For that reason, the author decided to prioritize performance
  by passing an already calculated `block_hash` as a separate parameter.
  Similarly, the `pindex` could be fetched from the block index, but this
  would involve an additional map lookup that is not strictly necessary.
  <br>_Note: the author later [changed][32317 updated approach] the
  approach, removing the `block_hash` performance optimization._"
  a2link="https://bitcoincore.reviews/32317#l-97"

  q3="The first commits in this PR refactor `CCoinsViewCache` out of the
  function signature of a couple of validation functions. Does
  `CCoinsViewCache` hold the entire UTXO set? Why is that (not) a
  problem? Does this PR change that behaviour?"
  a3="`CCoinsViewCache` does not hold the entire UTXO set; it is an
  in-memory cache that sits in front of `CCoinsViewDB`, which stores the
  full UTXO set on disk. If a requested coin is not in the cache, it
  must be fetched from disk. This PR does not change this caching
  behavior itself. By removing `CCoinsViewCache` from function
  signatures, it makes the UTXO dependency explicit, requiring the
  caller to fetch coins before calling the validation function."
  a3link="https://bitcoincore.reviews/32317#l-116"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.05rc1][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="58:25" %}

- [LND 0.19.1-beta][] is a release of a maintenance version of this
  popular LN node implementation.  It [contains][lnd rn] multiple bug
  fixes. {% assign timestamp="58:38" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32406][] uncaps the `OP_RETURN` output size limit
  (standardness rule) by raising the default `-datacarriersize` setting
  from 83 to 100,000 bytes (the maximum transaction size limit). The
  `-datacarrier` and `-datacarriersize` options remain, but are marked
  as deprecated and are expected to be removed in an undetermined future release.
  Additionally, this PR also lifts the one-per-transaction policy
  restriction for OP_RETURN outputs, and the size limit is now allocated
  across all such outputs in a transaction. See [Newsletter
  #352][news352 opreturn] for additional context on this change. {% assign timestamp="19:54" %}

- [LDK #3793][] adds a new `start_batch` message that signals peers to
  treat the next `n` (`batch_size`) messages as a single logical unit.
  It also updates `PeerManager` to rely on this for `commitment_signed`
  messages during [splicing][topic splicing], rather than adding a TLV
  and a `batch_size` field to each message in the batch.  This is an
  attempt to allow additional LN protocol messages to be batched rather
  than only `commitment_signed` messages, which is the only batching
  defined in the LN specification. {% assign timestamp="1:14:21" %}

- [LDK #3792][] introduces initial support for [v3 commitment
  transactions][topic v3 commitments] (see [Newsletter #325][news325
  v3]) that rely on [TRUC transactions][topic v3 transaction relay] and
  [ephemeral anchors][topic ephemeral anchors], behind a test flag. A
  node now rejects any `open_channel` proposal that sets a non-zero
  feerate, ensures that it never initiates such channels itself, and
  stops automatically accepting v3 channels to first reserve a UTXO for
  later fee-bumping.  The PR also lowers the per-channel [HTLC][topic
  htlc] limit from 483 to 114 because TRUC transactions must remain
  under 10 kvB. {% assign timestamp="1:14:59" %}

- [LND #9127][] adds a `--blinded_path_incoming_channel_list` option to
  the `lncli addinvoice` command, allowing a recipient to embed one or
  more (for multiple hops) preferred channel IDs for the payer to
  attempt to forward through on a [blinded path][topic rv routing]. {% assign timestamp="1:18:38" %}

- [LND #9858][] begins signaling the production feature bit 61 for the
  [RBF][topic rbf] cooperative close flow (see [Newsletter #347][news347
  rbf]) to properly enable interoperability with Eclair. It retains the
  staging bit 161 to maintain interoperability with nodes testing the
  feature. {% assign timestamp="1:20:04" %}

- [BOLTs #1243][] updates the [BOLT11][] specification to indicate that
  a reader (sender) must not pay an invoice if a mandatory field, such
  as p (payment hash), h (description hash), or s (secret), has an
  incorrect length. Previously, nodes could ignore this issue. This PR
  also adds a note to the Examples section explaining that [Low R
  signatures][topic low-r grinding], even if they save one byte of
  space, are not enforced in the specification. {% assign timestamp="1:21:49" %}

{% include snippets/recap-ad.md when="2025-06-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32406,3793,3792,9127,1867,9858,1243,27587" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[lnd 0.19.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta
[poinsot selfish]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757
[bytecoin selfish]: https://bitcointalk.org/index.php?topic=2227.msg30083#msg30083
[darosior/miningsimulation]: https://github.com/darosior/miningsimulation
[todd feerec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aDWfDI03I-Rakopb@petertodd.org/
[news9 reconcile]: /en/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
[chow dupsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08dbeffd-64ec-4ade-b297-6d2cbeb5401c@achow101.com/
[doman descrypt]: https://delvingbitcoin.org/t/rust-descriptor-encrypt-encrypt-any-descriptor-such-that-only-authorized-spenders-can-decrypt/1750/
[news351 salvacrypt]: /en/newsletters/2025/04/25/#standardized-backup-for-wallet-descriptors
[es selfish]: https://arxiv.org/pdf/1311.0243
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/v0.19.1-beta/docs/release-notes/release-notes-0.19.1.md
[news352 opreturn]: /en/newsletters/2025/05/02/#increasing-or-removing-bitcoin-core-s-op-return-size-limit
[news325 v3]: /en/newsletters/2024/10/18/#version-3-commitment-transactions
[news347 rbf]: /en/newsletters/2025/03/28/#lnd-8453
[review club 32317]: https://bitcoincore.reviews/32317
[gh thecharlatan]: https://github.com/TheCharlatan
[somsen swiftsync]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[32317 updated approach]: https://github.com/bitcoin/bitcoin/pull/32317#issuecomment-2883841466
[news349 swiftsync]: /en/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download
