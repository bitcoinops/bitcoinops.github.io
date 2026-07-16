---
title: 'Bitcoin Optech Newsletter #414'
permalink: /en/newsletters/2026/07/17/
name: 2026-07-17-newsletter
slug: 2026-07-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new project to apply formal verification to the
Bitcoin protocol. Also included are our regular sections announcing new releases
and release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Formal verification of the Bitcoin protocol**: Keagan McClelland [posted][verif ml]
  to the Bitcoin-Dev mailing list and [Delving Bitcoin][verif del] about his effort to
  formally verify the Bitcoin protocol. Formal verification is a software development
  practice that aims to prove the correctness of a system with respect to a
  specification using the formal methods of mathematics. This could help resolve
  factual disputes about proposed changes to Bitcoin's consensus rules. Optech
  previously covered a related project developing a declarative executable
  specification of Bitcoin's consensus rules (see [Newsletter #402][news402 hornet]).

  McClelland is developing [btc-verified][verif gh], a [Lean4][lean lang]
  implementation of the verification process. The author provided initial results
  demonstrating the approach. In particular, he focused on the algorithm Bitcoin uses
  to compute the merkle root, which contains a known flaw ([CVE-2012-2459][topic cves])
  that can cause two different transaction lists to produce the same
  [merkle root][topic merkle tree vulnerabilities]. Bitcoin Core's merkle-root
  construction includes a check meant to detect this mutation. McClelland used
  btc-verified to formally prove that the check is correct and that no two distinct
  transaction lists can pass it and produce the same merkle root under the assumption
  that SHA256 is collision resistant.

  Finally, the author asked for feedback from others both on the repository and
  on the general approach. He also provided some disclaimers, such as the heavy use
  of AI in the repository, and the current immaturity of the project.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 30.3][] is a maintenance release of the predominant
  full-node implementation. It fixes a chainstate database issue that could
  cause excessive disk reads and writes during normal operation, along with
  wallet, [PSBT][topic psbt], [miniscript][topic miniscript], networking,
  build, test, and documentation fixes. See the [release notes][bcc30.3 rn]
  for details.

- [Bitcoin Core 29.4][] is a maintenance release of the predominant
  full-node implementation. It fixes the same chainstate database rewrite
  issue as 30.3 and includes selected validation, wallet, build, test,
  documentation, CI, and compatibility fixes. See the [release
  notes][bcc29.4 rn] for details.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35295][] speeds up block validation by fetching the coins
  spent by a block's transaction inputs in parallel. Before validation begins,
  Bitcoin Core starts several worker threads that retrieve different previous
  outputs concurrently, while the main thread processes the block in the
  normal order. The new `-prevoutfetchthreads` option uses eight workers by
  default, allows up to 16, and can be set to zero to disable the optimization.
  This change prevents the latency of many disk reads from accumulating
  sequentially. Depending on the hardware and configuration, the author's
  benchmarks show initial block download (IBD) speedups ranging from 1.18 times
  to over three times faster.

- [Bitcoin Core #34897][] ensures that optional indexes never persist state
  ahead of the chainstate's last durable UTXO flush by skipping an index commit
  unless the index tip is an ancestor of the last flushed chainstate block.
  Previously, an unclean shutdown could cause Bitcoin Core to restart with the
  chainstate at an earlier block than the index, creating an inconsistency
  between the two databases. This was particularly problematic for
  `coinstatsindex`, whose rolling [MuHash][news131 muhash] state is difficult to
  reverse without reprocessing the corresponding blocks, which would then be
  unavailable in the chainstate. While the index can process newer blocks in
  memory, it now waits for the chainstate to catch up before saving that
  progress to disk.

- [Bitcoin Core #35406][] limits the [private broadcast][topic transaction origin
  privacy] tracking queue to 10,000 transactions (see [Newsletter
  #409][news409 privatebroadcast]). Transactions
  broadcast using this method are tracked until they are observed returning
  from the network. Previously, the size of the tracking queue was unlimited,
  so transactions that never returned due to policy differences could
  accumulate indefinitely and consume unlimited memory and CPU. Once the limit
  is reached, Bitcoin Core rejects new submissions without removing existing
  entries. Users can inspect the queue with `getprivatebroadcastinfo` and
  remove stuck transactions with `abortprivatebroadcast`.

- [Bitcoin Core #35380][] extends the `libbitcoinkernel` API (see [Newsletter
  #380][news380 kernel]) to expose each transaction input's witness stack and
  `scriptSig` by adding a `btck_WitnessStack` view and functions for counting,
  retrieving, and copying its elements. This allows external applications,
  including [silent payment][topic silent payments] scanners, to retrieve
  public keys stored in segwit witness data or P2PKH `scriptSig`s without
  deserializing the raw transactions separately. These input public keys are
  necessary for silent-payment scanners to determine whether any of the
  transaction's outputs belong to the wallet.

- [Bitcoin Core #35568][] reduces the synchronization time and disk usage of
  the optional `txospenderindex` (see [Newsletter #394][news394 txospender]) by
  disabling its internal LevelDB Bloom filters. These are database-lookup
  optimizations, unrelated to the [BIP37][] [bloom filters][topic transaction
  bloom filtering] historically used by SPV wallets. LevelDB bloom filters
  were never consulted and only added processing and storage overhead. In the
  author's benchmark, a full index synchronization decreased from 4 hours 37
  minutes to 3 hours 57 minutes, while disk usage fell from 85.0 GiB to 80.9
  GiB. Existing indexes remain compatible, but reclaiming the space used by
  previously generated filters requires rebuilding the index.

- [Bitcoin Core #34538][] allows an address explicitly configured with the
  `externalip` option to be eligible for advertisement, even if the `onlynet`
  option excludes its network. This change benefits nodes that open automatic
  outbound connections over one network but accept inbound connections over
  another. For example, consider a node that establishes outbound connections
  via IPv4 only while operating a [Tor][topic anonymity networks] onion service
  that is configured separately. Previously, Bitcoin Core would reject
  manually supplied onion addresses because the `onlynet` option marked Tor as
  unreachable.

- [BIPs #2208][] updates the rationale for [BIP54][]'s [consensus
  cleanup][topic consensus cleanup], which proposes invalidating
  64-byte witness-stripped transactions to prevent their hashes from being
  confused with Merkle internal-node hashes. The PR documents an alternative
  proposal that keeps 64-byte transactions valid while rejecting Merkle
  internal nodes whose two 32-byte child hashes, when concatenated, form a
  valid 64-byte transaction (see [Newsletter #412][news412 merkle64]).
  Additionally, it corrects BIP54's previous claim that Merkle-proof verifiers
  would never need updating. Proofs of ordinary, non-64-byte transactions are
  automatically protected, but a verifier that accepts proofs of 64-byte
  transactions would need to reject them after activation.

- [LND #10962][] prevents the [RBF][topic rbf] cooperative-close flow (see
  [Newsletter #347][news347 rbf]) from being used for auxiliary channels, such
  as [Taproot Assets][topic client-side validation] channels, whose funding
  outputs commit to additional protocol state. LND previously selected the RBF
  closer using peer-level feature bits, but that closer does not invoke the
  auxiliary hooks needed to carry the assets into the closing transaction.
  Therefore, it could broadcast a valid Bitcoin transaction that would destroy
  the asset commitments and leave the channel stuck in a waiting-close state.

- [LND #10897][] fixes a sweeper bug that could have permanently stranded
  inputs from auxiliary channels, such as [Taproot Assets][topic client-side
  validation] channels. These inputs may have only a small bitcoin fee budget
  because most of their value is represented by the overlay asset, while an
  auxiliary sweeper contributes additional budget to the final sweep
  transaction. Initially, LND's filter only considered each input's
  own budget, so after a failed sweep increased the required starting feerate,
  the input could be excluded from every future attempt. Now, the filter
  includes the auxiliary contribution when determining whether an input can
  afford the minimum relay fee and the starting feerate.

- [BINANAs #21][] assigns BIN-2025-0003 to [BIP442][], the draft
  `OP_PAIRCOMMIT` proposal (see [Newsletter #395][news395 paircommit]).

{% include snippets/recap-ad.md when="2026-07-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35295,34897,35406,35380,35568,34538,2208,10962,10897,21" %}

[verif ml]: https://groups.google.com/g/bitcoindev/c/OIml9stwbGQ
[verif del]: https://delvingbitcoin.org/t/btc-verified-formalizing-the-bitcoin-protocol/2684
[verif gh]: https://github.com/ProofOfKeags/btc-verified
[lean lang]: https://lean-lang.org/
[news402 hornet]: /en/newsletters/2026/04/24/#hornet-node-s-declarative-executable-specification-of-bitcoin-consensus-rules
[Bitcoin Core 30.3]: https://bitcoincore.org/bin/bitcoin-core-30.3/
[bcc30.3 rn]: https://bitcoincore.org/en/releases/30.3/
[Bitcoin Core 29.4]: https://bitcoincore.org/bin/bitcoin-core-29.4/
[bcc29.4 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.4.md
[news131 muhash]: /en/newsletters/2021/01/13/#bitcoin-core-19055
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news394 txospender]: /en/newsletters/2026/02/27/#bitcoin-core-24539
[news409 privatebroadcast]: /en/newsletters/2026/06/12/#bitcoin-core-35410
[news412 merkle64]: /en/newsletters/2026/07/03/#prohibit-merkle-internal-node-preimages-that-encode-minimal-64-byte-transactions
[news347 rbf]: /en/newsletters/2025/03/28/#lnd-8453
[news395 paircommit]: /en/newsletters/2026/03/06/#bips-1699
