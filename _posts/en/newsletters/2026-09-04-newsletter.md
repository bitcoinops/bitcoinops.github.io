---
title: 'Bitcoin Optech Newsletter #421'
permalink: /en/newsletters/2026/09/04/
name: 2026-09-04-newsletter
slug: 2026-09-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an idea for pools to pay miners using silent
payments in the coinbase transaction and summarizes the responsible disclosure
of a denial-of-service vulnerability affecting older versions of Core
Lightning. Also included are our regular sections summarizing proposals and
discussion about changing Bitcoin's consensus rules, announcing new releases
and release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Using silent payments for miner payouts in coinbase transaction**:
  average_gary [posted][spc del] to Delving Bitcoin about his idea for
  how [pools][topic pooled mining] could pay miners to different addresses
  directly in the coinbase transaction. Instead of providing an `xpub` to
  the pool to derive a fresh address for each payout, which could result in
  privacy issues if the pool's database gets compromised, a miner could
  share a [silent payment][topic silent payments] address, which is static and
  can be used several times without privacy leaks, through the encrypted
  communication channel provided by Stratum v2.

  For [BIP352][] silent payments, the receiver derives the shared secret from
  the transaction's input public keys, which a coinbase transaction does not
  have. The pool can create an ephemeral private key to be used to derive the
  sending public key `A_send`. To prevent the pool from grinding a malicious
  `a_send` private key, `A_send` is hashed with the height of the block being
  mined, which replaces the outpoint-derived uniqueness.
  The 34-byte `A_send` is finally included in the coinbase scriptSig replacing
  the so-called pool tag, so that the miner can scan the chain for the funds.

  The author is looking for feedback and critiques on the proposed idea,
  so that it can be formalized into a real specification.

- **Responsible disclosure of a denial-of-service vulnerability in CLN**:
  Erick Cestari [posted][cln dos del] to Delving Bitcoin the responsible
  disclosure of a critical denial-of-service (DoS) vulnerability affecting
  CLN nodes running versions prior to [25.09][cln v25.09]. An attacker
  would have been able to flood a node with `ping` messages asking for the
  largest possible `pong` reply and never read the TCP socket, causing an
  out-of-memory (OOM) crash, needing only to complete the [BOLT8][] handshake,
  without a channel.

  The issue was linked to the way CLN manages its connections. Each peer opens a
  BOLT8 encrypted Noise channel with the node and the connection is managed by
  a specific daemon, `connectd`. The daemon handles the TCP connection, decrypts
  the incoming messages, and routes them to the specific subdaemon managing a
  payment channel with the sending peer. However, there are some messages that
  are taken care of locally by the daemon. One of them is the `ping` message and
  the sender gets to pick the size of the `pong` reply.

  While CLN applies a backpressure mechanism to the messages routed to the subdaemons,
  with `connectd` waiting for them to be ready before reading a new message, that did
  not apply to the daemon itself, which would continue to read the locally handled
  messages. An attacker would have been able to repeatedly send `ping` messages
  requesting a reply of the maximum allowed size of 65531 bytes and never read the
  answer, thus filling its TCP socket buffer first, then the peer's. This would
  have prevented the `peer_outq` queue from draining, leading to the OOM crash.

  The issue was fixed by providing the `connectd` daemon with its own backpressure
  mechanism, activated by the `peer_outq` queue actually draining before reading
  the next incoming message. The fix was introduced in [Core Lightning #8525][]
  and published in release 25.09.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Continued discussion of PQC output types**: Following last month's
  [summary][news417 pqout] of Pieter Wuille's Delving Bitcoin thread on
  [post-quantum][topic quantum resistance] output types, Wuille [replied][pw
  delving pqout cisa] to Conduition's argument that pairing [CISA][topic cisa]
  with [P2TRv2][news403 pqout] would strongly incentivize migration. Wuille was
  not convinced that feerate savings, which he put at a maximum weight
  reduction of about 28% and only for transactions with many inputs, would move
  the long tail: wallet and custodian support is the bottleneck, CISA adds
  specification and implementation complexity that may delay a P2TRv2 soft
  fork, and entities might postpone any PQC work until they can ship P2TRv2 and
  CISA together. He still prefers P2TRv2 as a default for casual users and
  [P2MR][news393 p2mr] for more sophisticated users who want to hide EC points,
  and noted that post-Q-day hash-based signatures likely need a new witness
  costing rule that weighs CPU more and serialized size less (see [Newsletter
  #417][news417 pqwit]). He also cautioned that having third-party relay nodes
  incrementally aggregate signatures would hide the real bandwidth cost within
  the consensus layer and could entrench existing mining pools by incentivizing
  direct submission to miners. Conduition [countered][c delving pqout cisa]
  that a CISA supporting output type can be adopted first with ordinary BIP340
  signatures and aggregation added later, and that an 8x (or larger) serialized
  block-size increase to make hash-based signatures fee-competitive with EC
  would push archival storage into terabytes per year unless block-wide SNARK
  aggregation can prune witnesses. Adam Gibson [agreed][ag delving pqout] with
  Wuille that bundling CISA into P2TRv2 is a poor fit for P2TRv2's
  adoption-first goal.

- **DropKick commit/reveal PQC rescue**: Conduition [posted][c ml dropkick] to
  the Bitcoin-Dev mailing list a sketch of DropKick, a commit/reveal
  [post-quantum][topic quantum resistance] rescue protocol (see also
  [Newsletter #361][news361 pqcr] and [Newsletter #348][news348 utxo proving])
  for users who have not moved coins to PQC-enabled outputs by Q-day. A user
  hides a commitment to their post-quantum public key and ownership witness
  (proof of knowledge asymmetry) somewhere in a block (for example in an
  `OP_RETURN` or a taproot tweak). Users without a PQ-safe UTXO of their own
  can hand their commitments to untrusted aggregators, who merkle-commit many
  users' commitments under a single onchain root, optionally for a fee paid
  from the rescued coins. After a delay, they reveal the proof, a signature
  from their post-quantum public key, and an SPV-style opening proof that the
  commitment appeared in an earlier block. DropKick can be deployed as a
  non-confiscatory soft fork if it encumbers only UTXOs with decidable
  knowledge asymmetries, where validators can tell from the output alone that
  hidden data such as a hashed pubkey exists. Covering undecidable cases such
  as BIP32 key derivation would rescue more coins but could confiscate some.
  P2PK coins cannot be covered. Compared with Tadge Dryja's Lifeboat, which
  requires each user to have a PQ-secure UTXO to post a commitment, DropKick
  drops the requirement to index and order every onchain commitment, at the
  cost of miner-censorship risk on the reveal: Conduition argues a long delay
  (about 100 blocks if users will pay 1% of the UTXO to honest miners) plus a
  value-proportional fee can make censorship unprofitable, assuming that the
  censors are not capable or unwilling to reorganize out blocks that undermine
  the censorship attempt.

- **SHRINCS draft BIP**: Conduition [posted][c ml shrincs] to the Bitcoin-Dev
  mailing list, on behalf of the SHRINCS working group, a first [draft][shrincs
  bip] specifying SHRINCS as a semi-stateful [hash-based][news386 jn hash]
  signature scheme for Bitcoin (see [Newsletter #391][news391 shrincs]). Public
  keys are 48 bytes. Stateful signatures are 548 bytes at the smallest; a
  built-in stateless fallback produces 5,777-byte signatures (the draft raises
  the stateless budget to 2^40 signatures so high-frequency protocols such as
  LN can use the fallback). Verification is 4x-16x faster per byte than
  [BIP340][] [schnorr][topic schnorr signatures] with SHA256 hardware
  acceleration, or at worst 2,792 SHA256 compressions for a stateless
  signature. Notable changes since the original proposal include black-box
  SLH-DSA (FIPS-205) compatibility, flexible XMSS trees of any structure, and
  faster (larger) stateful parameters. The draft specifies only a signature
  scheme; deployment of the new signatures per new opcodes or a new output type
  would be subject of a separate proposal. Reusing a stateful counter lets an
  observer forge signatures. Antoine Riard [noted][ar ml shrincs] that
  5,777-byte stateless signatures would be roughly 90x the onchain cost of
  today's transactions unless those fields are discounted. Jonas Nick and
  remix7531's [libshrincs][news419 libshrincs] C library with machine-checked
  WOTS+C proofs was also separately released to provide implementation support
  for those wishing to integrate SHRINCS.

- **BIP448 and CSFS/CTV demos and applications**: Work around [BIP448][] (the
  [tapscript][topic tapscript] bundle of `OP_TEMPLATEHASH`,
  [`OP_CHECKSIGFROMSTACK`][topic op_checksigfromstack] (CSFS), and
  `OP_INTERNALKEY`; see [Newsletter #397][news397 bip448]) continues with new
  sites aggregating demos, implementations, and proofs of concept. A
  [BIP448][bip448 org] GitHub organization collects implementations (Bitcoin
  Inquisition, a Bitcoin Core patch without activation, [miniscript and PSBT
  integration][news395 thikcs], draft [LN-Symmetry][topic eltoo] BOLTs and Core
  Lightning implementation, and an [Ark][topic ark] `OP_TEMPLATEHASH` signet
  [demo][news419 thark]). The organization notes that the full bundle will be
  usable on the default [signet][topic signet] with the next Bitcoin
  Inquisition release. askii21m [announced][askii delving cvd] covenants.diy, a
  browser editor that builds [taproot][topic taproot] outputs and steps through
  tapscript under selectable opcode sets, with permalinked examples including
  BIP448 rebindable state, [BIP119][] vaults and congestion control, and BIP348
  delegation. Jesus Najera (setzeus) of Cofund [published][cofund atlas] an
  interactive Covenants Use-Case Atlas of more than two dozen constructions,
  including vaults, congestion control, Ark issuance, and LN-Symmetry.

  Ademan [posted][ademan delving lark] a related construction for Ark
  out-of-round (OOR) virtual transaction output (VTXO) assignments used to open
  small just-in-time ([JIT][topic jit channels]) Lightning channels. Because
  the Ark server is both operator and initial VTXO holder, it can currently
  reassign the same VTXO many times. Ademan's equivocation bond is slashable by
  publishing two CSFS-validated signatures from the assignment key over
  distinct [BIP341][] sighashes. The bond and the preallocated transaction tree
  need a next-transaction [covenant][topic covenants], which can be either
  [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify] (CTV) or
  `OP_TEMPLATEHASH`.

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

{% include snippets/recap-ad.md when="2026-09-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8525" %}
[spc del]: https://delvingbitcoin.org/t/silent-payments-coinbase/2833
[cln dos del]: https://delvingbitcoin.org/t/disclosure-crashing-cln-with-a-flood-of-pings/2846
[cln v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[news417 pqout]: /en/newsletters/2026/08/07/#pqc-output-type-discussion
[news417 pqwit]: /en/newsletters/2026/08/07/#segwit-commitment-to-post-quantum-witness-data
[news403 pqout]: /en/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news393 p2mr]: /en/newsletters/2026/02/20/#bips-1670
[pw delving pqout cisa]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/6
[c delving pqout cisa]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/7
[ag delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/15
[c ml dropkick]: https://groups.google.com/g/bitcoindev/c/6SqWPfBf-p0
[news361 pqcr]: /en/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[news348 utxo proving]: /en/newsletters/2025/04/04/#securely-proving-utxo-ownership-by-revealing-a-sha256-preimage
[c ml shrincs]: https://groups.google.com/g/bitcoindev/c/HbVboXIFiG8
[shrincs bip]: https://github.com/SHRINCS/shrincs-bip/blob/main/SHRINCS.md
[ar ml shrincs]: https://gnusha.org/pi/bitcoindev/b4bb949d-bd35-424d-a1d1-459e6cca263an@googlegroups.com/
[news386 jn hash]: /en/newsletters/2026/01/02/#hash-based-signatures-for-bitcoin-s-post-quantum-future
[news391 shrincs]: /en/newsletters/2026/02/06/#shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups
[news419 libshrincs]: /en/newsletters/2026/08/21/#libshrincs-formally-verified-hash-based-signatures
[news397 bip448]: /en/newsletters/2026/03/20/#bips-1974
[news395 thikcs]: /en/newsletters/2026/03/06/#extensions-to-standard-tooling-for-templatehash-csfs-ik-support
[bip448 org]: https://github.com/bip448
[news419 thark]: /en/newsletters/2026/08/21/#op-templatehash-ark-demonstration
[askii delving cvd]: https://delvingbitcoin.org/t/covenants-diy-a-node-editor-for-covenant-scripts/2826
[cofund atlas]: https://getcofund.com/research/covenants-use-case-atlas
[ademan delving lark]: https://delvingbitcoin.org/t/improving-the-security-of-lark-oor-channels-with-equivocation-bonds/2816
