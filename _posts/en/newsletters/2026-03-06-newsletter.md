---
title: 'Bitcoin Optech Newsletter #395'
permalink: /en/newsletters/2026/03/06/
name: 2026-03-06-newsletter
slug: 2026-03-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a standard for verifying VTXOs across different
Ark implementations and links to a draft BIP for expanding the miner-usable
nonce space in the block header's `nVersion` field. Also included are our
regular sections with descriptions of discussions about changing consensus,
announcements of new releases and release candidates, and summaries of notable
changes to popular Bitcoin infrastructure software.

## News

- **A standard for stateless VTXO verification**: Jgmcalpine [posted][vpack del]
  to Delving Bitcoin about his proposal for V-PACK, a stateless [VTXO][topic ark] verification
  standard, which aims to provide a mechanism to independently verify and visualize
  VTXOs in the Ark ecosystem. The goal is to develop a lean verifier able to run on
  embedded environments, such as hardware wallets, to allow auditing off-chain state and
  maintaining an independent backup of the data required for unilateral exit.

  In particular, V-PACK verifies that a unilateral exit path exists, by checking that
  the merkle path leads to a valid on-chain anchor and that the transaction preimages
  match the signatures. However, Second CEO, Steven Roose, pointed out that path
  exclusivity (i.e. verifying that the Ark Service Provider (ASP) did not introduce a
  backdoor) is not checked for, to which Jgmcalpine answered that the topic would be
  given the highest priority in the roadmap.

  Due to significant differences among Ark implementations
  (specifically, Arkade and Bark), V-PACK proposes a Minimal Viable VTXO (MVV) schema
  to allow translating from an implementation's "dialect" to a common neutral format,
  without the need for an embedded environment to import all the specific
  implementation's codebase.

  The V-PACK implementation, [libvpack-rs][vpack gh], is open-source, and a
  [live tool][vpack tool] to visualize VTXOs is available for testing.

- **Draft BIP for expanded `nVersion` nonce space for miners**: Matt Corallo
  [posted][mailing list nversion] to the Bitcoin-Dev mailing list a draft
  BIP to increase the number of bits available in `nVersion`'s nonce space for
  miners from 16 to 24. This will enable more possible block candidates for
  header-only mining without relying on rolling `nTime` more often than once per
  second and would supersede [BIP320][BIP 320].

  The motivation for this change is that BIP320 previously defined 16 bits
  of `nVersion` as additional nonce space, but it turns out
  that mining devices have started using 7 bits from `nTime` for extra nonce space.
  Given the limited utility of the additional `nVersion` bits for use in soft fork signaling,
  this BIP draft suggests to instead use some of those signaling bits to expand the `nVersion` extra nonce space.

  The rationale behind this is that providing additional nonce space for the
  ASICs to roll without needing fresh work from the controller may simplify ASIC
  design and it is preferable to do so in `nVersion` instead of `nTime`, which
  can distort block timestamps.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Extensions to standard tooling for TEMPLATEHASH-CSFS-IK support:**
  Antoine Poinsot [wrote][ap ml thikcs] on the Bitcoin-Dev mailing list about his
  preliminary work to integrate the [taproot-native `OP_TEMPLATEHASH`
  soft fork proposal][news365 thikcs] into [miniscript][topic miniscript] and
  [PSBTs][topic psbt].

  The new opcodes require some reconsideration of the miniscript properties
  because they break the assumption that signatures and transaction
  commitments are always done together. This work also emphasizes the
  limitations of Script's stack structure by requiring an `OP_SWAP` before
  each `OP_CHECKSIGFROMSTACK` when used with miniscript without further
  changes to the type system. Because `OP_CHECKSIGFROMSTACK` takes 3 arguments
  with either the message or the key or both being computed by other script
  fragments, there is no obviously superior argument order that avoids
  `OP_SWAP` in most cases.

  The modifications required for PSBTs are simpler, primarily a per-output
  field to map `OP_TEMPLATEHASH` commitments to their full transactions for
  verification by signers.

- **Hourglass V2 update:** Mike Casey [posted][mk ml hourglass] an update to
  the Bitcoin-Dev mailing list for the [Hourglass protocol][bip draft hourglass2] to
  mitigate the market impact of [quantum][topic quantum resistance] attacks against certain lost coins.
  The earlier proposal was discussed [here][hb ml hourglass]. This soft fork
  would restrict the total value of P2PK-locked Bitcoin that can be spent in a
  single block to 1 spent output and 1 Bitcoin. These specific values are
  somewhat arbitrary, but seemed to those responding to represent a reasonable
  Schelling point for such a restriction. Those responding in favor of the
  change focused on the potential economic consequences of a large number of
  Bitcoin being sold by a quantum adversary. Those responding against it
  argued that possession of secret keys to unlock some Bitcoin is the only way
  the protocol can identify ownership and that even in the face of a break in
  the underlying cryptographic security, the protocol should not apply
  additional restrictions on coin ownership or movement.

- **Algorithm agility for Bitcoin:** Ethan Heilman [wrote][eh ml agility] on
  the Bitcoin-Dev mailing list regarding the potential need for [RFC7696 Cryptographic
  Algorithm Agility][rfc7696] in Bitcoin. Heilman proposes that a
  cryptographic algorithm be made available in [BIP360][] P2MR scripts which
  is not intended for current spending, but instead serves as a fallback to
  bridge between primary signing algorithms in the event that the current
  secp256k1-based signing algorithm (or some later primary algorithm) becomes
  insecure. The central idea is that if Bitcoin supports two simultaneous
  signing algorithms, future breaks of either one need not be as high stakes
  as the current discussions around a potential quantum break of secp256k1.

  Other developers responded with discussions of various potential backup
  signing algorithms that would be unlikely to break in Heilman's 75-year time
  horizon.

  Also discussed was the question of whether BIP360 P2MR, or something that
  looks more like [P2TR][topic taproot] but opts into the keyspend being later
  disabled by soft fork is preferable. In P2MR, all spends are script spends
  with either a lower cost primary signature mechanism or a higher cost
  fallback being chosen among merkle leaves. In a P2TR variant, the primary
  signature type is a lower cost key spend until it is disabled due to a
  cryptographic break and only the fallback must be a merkle leaf. Heilman
  suggested that cold storage users would prefer P2MR and hot wallets could
  readily switch to a new output type as needed, making the keyspend with
  script backup signature algorithm irrelevant for both major types of users.

- **The limitations of cryptographic agility in Bitcoin:**
  Pieter Wuille [wrote][pw ml agility] to the Bitcoin-Dev mailing list about the
  limitations of the cryptographic agility mentioned in the previous item. Specifically, because Bitcoin,
  like all money, is based on belief, if the ownership of Bitcoin is secured by
  a multiple cryptographic systems, proponents of each scheme want their scheme to be
  used universally and, importantly, do not want other schemes to be used
  because they would weaken the fundamental invariant of ownership security.
  Wuille posits that in the fullness of time, old signature schemes will need
  to be disabled as part of the migration from one scheme to another.

  Heilman [proposes][eh ml agility2] that because the secondary signing scheme
  proposed for algorithm agility is much more costly than the current scheme
  (and hopefully a future primary scheme), it would remain a backup and only
  used for migrations when the primary scheme has been shown to be
  sufficiently weakened, thus avoiding the need to disable the secondary
  scheme after each migration to a new primary scheme.

  John Light [takes][jl ml agility] the opposite view from Wuille, claiming
  that disabling old, even insecure, signing schemes is a greater threat to
  the shared belief in Bitcoin's ownership model than the coins still secured
  by such insecure schemes being claimed by whomever breaks them. Essentially
  claiming that the most important aspect of Bitcoin's ownership model is the
  indelibility of each locking script's validity from the time it is created
  until it is spent.

  Conduition [counters][c ml agility] Wuille's preconditions by demonstrating
  that (thanks to Script's flexibility) users can require signatures from
  multiple signing schemes to unlock their coins. This allows users to express
  a wider set of security assumptions than those which gave rise to Wuille's
  conclusion that insecure schemes would need to be disabled and that users of
  each scheme would want nearly nobody to use others.

  The discussion continues with some clarifications but no firm conclusions as
  to how Bitcoin can practically migrate from one cryptosystem to another
  whether in response to a quantum adversary or any other reason.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 28.4rc1][] is a release candidate for a maintenance release of a
  previous major release series. It primarily contains wallet migration fixes
  and removal of an unreliable DNS seed.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33616][] skips the [ephemeral dust][topic ephemeral
  anchors] spend check (`CheckEphemeralSpends`) during block reorgs when
  confirmed transactions re-enter the mempool. Previously, these
  transactions would be rejected by relay policy because they're brought
  back individually rather than as a package. This follows the same
  pattern as [Bitcoin Core #33504][] (see [Newsletter #375][news375
  truc]), which skipped [TRUC][topic v3 transaction relay] topology
  checks during reorgs for the same reason.

- [Bitcoin Core #34616][] introduces a more accurate cost model for the
  spanning-forest [cluster linearization][topic cluster mempool] (SFL)
  algorithm (see [Newsletter #386][news386 sfl]), by using cost limits to
  bound the amount of CPU time spent searching for an optimal
  linearization of each cluster. The previous model only tracked one type
  of internal operation, resulting in a poor correlation between the
  reported cost and the actual CPU time spent. The new model tracks many
  internal operations with weights calibrated from benchmarks across
  diverse hardware, providing a much closer approximation of real time.

- [Eclair #3256][] adds a new `ChannelFundingCreated` event emitted when
  a funding or [splice][topic splicing] transaction has been signed and
  is ready to be published. This is particularly useful for single-funded
  channels where the non-funding side has no opportunity to validate
  inputs beforehand and may want to force-close before the channel
  confirms.

- [Eclair #3258][] adds a `ValidateInteractiveTxPlugin` trait that
  enables plugins to inspect and reject the remote peer's inputs and
  outputs in interactive transactions before signing. This applies to
  [dual-funded][topic dual funding] channel opens and [splices][topic
  splicing], where both sides participate in transaction construction.

- [Eclair #3255][] fixes the automatic channel type selection introduced
  in [Eclair #3250][] (see [Newsletter #394][news394 eclair3250]) so
  that it no longer includes `scid_alias` for public channels. Per the
  BOLTs, `scid_alias` is only allowed for [private channels][topic
  unannounced channels].

- [LDK #4402][] fixes the HTLC claim timer to use the actual HTLC CLTV
  expiry rather than the value from the onion payload. For
  [trampoline][topic trampoline payments] payments where a node is both a
  trampoline hop and the final recipient, the actual HTLC expiry is
  higher than what the onion specifies, because the outer trampoline
  route added its own [CLTV delta][topic cltv expiry delta]. Using the
  onion value caused the node to set a tighter claim deadline than
  necessary.

- [LND #10604][] adds a SQL backend (SQLite or Postgres) for LND's
  outgoing payments database, as an alternative to the existing bbolt
  key-value (KV) store. This consolidation PR brings together several
  sub-PRs, notably [#10153][LND #10153] which introduced an abstract
  payment store interface, [#9147][LND #9147] which implemented the SQL
  schema and core backend, and [#10485][LND #10485] which added an
  experimental KV-to-SQL data migration. LND added support for
  PostgreSQL in [Newsletter #169][news169 lnd-sql] and SQLite in
  [Newsletter #237][news237 lnd-sql].

- [BIPs #1699][] publishes [BIP442][] specifying `OP_PAIRCOMMIT`, a new
  [tapscript][topic tapscript] opcode that pops two elements off the
  stack and pushes their tagged SHA256 hash. This provides
  multi-commitment functionality similar to what [OP_CAT][topic op_cat]
  enables but avoids enabling recursive [covenants][topic covenants].
  `OP_PAIRCOMMIT` is part of the [LNHANCE][news383 lnhance] soft fork
  proposal alongside [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] ([BIP119][]),
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] ([BIP348][]), and
  OP_INTERNALKEY ([BIP349][]). See [Newsletter #330][news330 paircommit]
  for the initial proposal.

- [BIPs #2106][] updates [BIP352][] ([silent payments][topic silent
  payments]) to introduce a per-group recipient limit of `K_max` = 2323,
  mitigating worst-case scanning time from adversarial transactions (see
  [Newsletter #392][news392 kmax]). This limit caps the number of
  outputs that a scanner must check per recipient group within a single
  transaction. The value was originally proposed at 1000 but increased to
  2323 to match the maximum number of [P2TR][topic taproot] outputs that
  can fit in a standard-sized (100 kvB) transaction and to avoid
  fingerprinting silent payment transactions.

- [BIPs #2068][] publishes [BIP128][], which specifies a standard JSON
  format for storing timelock-recovery plans. A recovery plan consists of
  two pre-signed transactions for recovering funds if the owner loses
  access to their wallet: an alert transaction that consolidates the
  wallet's UTXOs to a single address, and a recovery transaction that
  moves those funds to backup wallets after a relative [timelock][topic
  timelocks] of 2–388 days. If the alert transaction is broadcast
  prematurely, the owner can simply spend from the alert address to
  invalidate the recovery.

- [BOLTs #1301][] updates the specification to recommend a higher
  `dust_limit_satoshis` for [anchor][topic anchor outputs] channels.
  With `option_anchors`, pre-signed HTLC transactions have zero fees,
  so their cost is no longer factored into the dust calculation. This
  means HTLC outputs that pass the dust check may still be
  [uneconomical][topic uneconomical outputs] to claim on-chain, since
  spending them requires a second-stage transaction whose fee can exceed
  the output's value. The spec now recommends that nodes set a dust
  limit that accounts for the cost of these second-stage transactions,
  and that nodes accept values above Bitcoin Core's standard dust
  thresholds from their peers.

{% include snippets/recap-ad.md when="2026-03-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33616,33504,34616,3256,3258,3255,3250,4402,10604,10153,9147,10485,1699,2106,2068,1301" %}

[vpack del]: https://delvingbitcoin.org/t/stateless-vtxo-verification-decoupling-custody-from-implementation-specific-stacks/2267
[vpack gh]: https://github.com/jgmcalpine/libvpack-rs
[vpack tool]: https://www.vtxopack.org/
[ap ml thikcs]: https://groups.google.com/g/bitcoindev/c/xur01RZM_Zs
[news365 thikcs]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[mk ml hourglass]: https://groups.google.com/g/bitcoindev/c/0E1UyyQIUA0
[bip draft hourglass2]: https://github.com/cryptoquick/bips/blob/hourglass-v2/bip-hourglass-v2.mediawiki
[hb ml hourglass]: https://groups.google.com/g/bitcoindev/c/zmg3U117aNc
[eh ml agility]: https://groups.google.com/g/bitcoindev/c/7jkVS1K9WLo
[rfc7696]: https://datatracker.ietf.org/doc/html/rfc7696
[pw ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A
[eh ml agility2]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/OXmZ-PnVAwAJ
[jl ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5GnsttP2AwAJ
[c ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5y9GkeXVBAAJ
[news375 truc]: /en/newsletters/2025/10/10/#bitcoin-core-33504
[news386 sfl]: /en/newsletters/2026/01/02/#bitcoin-core-32545
[news394 eclair3250]: /en/newsletters/2026/02/27/#eclair-3250
[news169 lnd-sql]: /en/newsletters/2021/10/06/#lnd-5366
[news237 lnd-sql]: /en/newsletters/2023/02/08/#lnd-7252
[news330 paircommit]: /en/newsletters/2024/11/22/#update-to-lnhance-proposal
[news383 lnhance]: /en/newsletters/2025/12/05/#lnhance-soft-fork
[news392 kmax]: /en/newsletters/2026/02/13/#proposal-to-limit-the-number-of-per-group-silent-payment-recipients
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[mailing list nversion]: https://groups.google.com/g/bitcoindev/c/fCfbi8hy-AE
[BIP 320]: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
