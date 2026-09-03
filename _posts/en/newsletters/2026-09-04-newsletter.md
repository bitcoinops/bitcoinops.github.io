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

- [Core Lightning 26.06.7][] is a security release for the current major
  version of this popular LN node implementation. It fixes several responsibly
  disclosed vulnerabilities, none of which are known to be actively exploited,
  reported by researchers including Erick Cestari, whose earlier disclosure is
  described in the news section above. The project strongly encourages all
  users to upgrade. As described in [Newsletter #420][news420 cln embargo], the
  source code is being withheld for 14 days after the August 28 binary release
  to slow attackers from reverse engineering the fixes. After that, CLN's
  [reproducible builds][topic reproducible builds] will allow users to verify
  the binaries. Between August 28 and September 1, Docker users who pulled the
  `v26.06.7` or `latest` tags received images that reported the new version but
  did not contain the fixes. These users should check their image digest and
  re-pull.

- [LND v0.21.3-beta][] is a maintenance release of this popular LN node
  implementation. It includes the peer resource limits, `channel_update`
  encoding fix, and dust [HTLC][topic htlc] resolution fix described in the
  notable code section below, as well as the [PSBT][topic psbt] funding
  deadlock fix from [Newsletter #420][news420 lnd deadlock]. It also fixes a
  cooperative close fee bug for channels with auxiliary outputs such as
  [Taproot Assets][topic client-side validation] channels, a native SQL invoice
  migration failure for legacy [AMP][topic amp] invoices, a REST WebSocket
  proxy panic, and several gossip query and cooperative close bugs, and adds
  the experimental `XCreateAccount` RPC (see [Newsletter #419][news419 lnd
  account]).

- [LND v0.20.4-beta][] is a maintenance release of LND's 0.20 release branch.
  It backports most of the fixes in 0.21.3-beta, including the peer resource
  limits, `channel_update` encoding fix, and dust HTLC resolution fix, and
  additionally rejects fixed-size TLV records such as inbound fees and
  [MuSig2][topic musig] nonces whose declared length is incorrect, instead of
  silently accepting and re-encoding them.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #36111][] limits the memory used by the `validateaddress` RPC
  when reporting errors for overly long [bech32][topic bech32] strings.
  Previously, for strings exceeding the 90-character limit set by [BIP173][],
  every position past the limit was returned as an error location (see
  [Newsletter #177][news177 bech32]) and converted into a separate JSON value.
  Now, the RPC returns only position 90, where the length violation begins. In
  the author's tests, an authenticated request near the maximum HTTP request
  size used approximately 5.7 GiB of memory before the change and 240 MiB
  after.

- [Bitcoin Core #36032][] improves the performance of `createrawtransaction`,
  `createpsbt`, `sendmany`, and other RPCs that build a transaction by making
  output parsing linear instead of quadratic. Previously, the parser iterated
  through the output keys and separately looked up each corresponding value
  individually, rescanning the same internal list each time. In addition,
  `sendmany` held the wallet lock while parsing. Now, the parser walks through
  the keys and values together by index, similar to the `gettxspendingprevout`
  fix in [Newsletter #419][news419 gettxspendingprevout]. The author reports
  that parsing 10,000 outputs in a debug build now takes 0.5 seconds instead of
  1.8 seconds.

- [Core Lightning #9435][] updates CLN to force close a channel when a peer
  sends a `channel_reestablish` message with a `next_commitment_number` of
  zero, as required by [BOLT2][]. A value of zero indicates that the peer has
  lost its channel state, and broadcasting the latest commitment transaction
  lets it recover its balance using a [static channel backup][topic static
  channel backups]. Previously, CLN only enforced this on a freshly opened
  channel. For any other channel, CLN first detected the peer's stale
  `next_revocation_number`, sent a warning, and left the channel open.

- [Eclair #3368][] fixes a bug where a `commitment_signed` message received
  from a peer on a non-[taproot][topic taproot] channel could carry the
  `partial_signature_with_nonce` TLV used by [simple taproot channels][topic
  simple taproot channels] for their [MuSig2][topic musig] partial signatures
  (see [Newsletter #404][news404 eclair taproot]). Although Eclair correctly
  verified the message's regular ECDSA signature, it incorrectly stored the
  unsolicited partial signature as the peer's signature. This prevented Eclair
  from force closing the channel later on. Now, Eclair selects the signature
  type that matches the channel's commitment format before verification and
  only stores the verified signature.

- [Eclair #3366][] hardens [splicing][topic splicing] against peers that don't
  follow the specification. Eclair now disconnects a peer that sends channel
  updates after its own `stfu` [quiescence][topic channel commitment upgrades]
  message, or that sends a `commitment_signed` message while the splice is
  still being negotiated. Eclair force closes instead of accepting if a peer
  attempts to advance the channel's existing commitment while the splice is
  being signed. It also refuses to complete a splice or [dual funding][topic
  dual funding] [RBF][topic rbf] attempt whose commitment numbers no longer
  match the channel's. Finally, when a splice in which Eclair sells liquidity
  through [liquidity advertisements][topic liquidity advertisements] is aborted
  after signing begins, Eclair now immediately fails the incoming [HTLCs][topic
  htlc] paying for it (see [Newsletter #379][news379 eclair liquidity] for a
  related fix).

- [LND #11090][] rate limits inbound `ping` messages and caps each peer's
  outgoing message queue, preventing the kind of resource exhaustion described
  for CLN in the news section above. For each peer connection, LND now
  maintains two token buckets. The inbound `ping` request bucket starts with
  200 tokens and replenishes at a rate of 10 per second. Exhausting this bucket
  results in the peer getting disconnected. The outbound `pong` reply bucket
  starts with 20 tokens and replenishes at a rate of one per second. Exhausting
  this bucket causes LND to stop replying, which is a deliberate deviation from
  [BOLT1][]. Each peer's outgoing queue is also capped at 10,000 messages or
  approximately 16 MiB. Additionally, the PR fixes the encoding of
  `channel_update` [gossip messages][topic channel announcements] so that LND's
  own updates advertising [inbound fees][topic inbound forwarding fees] are
  signed over exactly the bytes it broadcasts. Previously, these bytes could
  differ, causing peers to reject the update. Updates that LND forwards from
  other nodes now also keep any TLV records it doesn't recognize, rather than
  dropping them and invalidating the originator's signature (see [Newsletter
  #418][news418 eclair flags] for a similar Eclair fix).

- [LND #11140][] fixes how LND handles a forwarded [HTLC][topic htlc] when the
  outgoing channel force closes and the HTLC is [trimmed][topic trimmed htlc]
  as [dust][topic uneconomical outputs] on one party's commitment transaction
  but not the other's. Previously, if the HTLC had an output on LND's
  commitment but the peer's commitment confirmed without one, LND never failed
  the incoming HTLC back, because it had judged the HTLC based on its own
  commitment. The incoming HTLC would then stay pending until the upstream
  channel force closed near its expiry. Now, LND decides based on the
  commitment that actually confirmed. LND also no longer fails an incoming HTLC
  early when the outgoing HTLC is dust on its commitment but has an output on
  the peer's commitment, since the peer could still claim the output with the
  preimage.

- [HWI #792][] adds a `--registration` option to the `signtx` command for
  signing [PSBTs][topic psbt] using [BIP388][] wallet policies that were
  previously registered on a hardware signing device with the
  `registerdescriptor` command (see Newsletters [#419][news419 hwi] and
  [#420][news420 hwi]). The option accepts the serialized registration returned
  by `registerdescriptor`, including the policy name, [descriptor][topic
  descriptors], device type, and any device-specific registration data such as
  Ledger's HMAC. Support is implemented for BitBox02, Coldcard Edge, Jade, and
  non-legacy Ledger devices.

- [BDK #2262][] fixes a bug where reindexing a wallet's transaction graph could
  miss some of the wallet's own outputs. BDK's `KeychainTxOutIndex` watches a
  look-ahead [window of addresses][topic gap limits] beyond the highest
  [BIP32][] derivation index it has seen, extending the window each time an
  output at a higher index is found. Previously, reindexing examined each
  output only once, so an output beyond the current window was deemed not to
  belong to the wallet and was never reexamined, even after a later output
  extended the window. Since outputs were examined in a random order, the same
  wallet could show different balances on different runs. Reindexing now
  repeats the process until the window stops extending.

{% include snippets/recap-ad.md when="2026-09-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8525,36111,36032,9435,3368,3366,11090,11140,792,2262" %}
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
[news177 bech32]: /en/newsletters/2021/12/01/#bitcoin-core-16807
[news419 gettxspendingprevout]: /en/newsletters/2026/08/21/#bitcoin-core-35889
[news379 eclair liquidity]: /en/newsletters/2025/11/07/#eclair-3206
[news418 eclair flags]: /en/newsletters/2026/08/14/#eclair-3341
[news419 hwi]: /en/newsletters/2026/08/21/#hwi-842
[news404 eclair taproot]: /en/newsletters/2026/05/08/#eclair-3144
[news420 hwi]: /en/newsletters/2026/08/28/#hwi-841
[Core Lightning 26.06.7]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.7
[LND v0.21.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.3-beta
[LND v0.20.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.4-beta
[news420 cln embargo]: /en/newsletters/2026/08/28/#prepare-for-an-upcoming-core-lightning-security-release
[news420 lnd deadlock]: /en/newsletters/2026/08/28/#lnd-11008
[news419 lnd account]: /en/newsletters/2026/08/21/#lnd-11065
