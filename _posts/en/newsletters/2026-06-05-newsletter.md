---
title: 'Bitcoin Optech Newsletter #408'
permalink: /en/newsletters/2026/06/05/
name: 2026-06-05-newsletter
slug: 2026-06-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes ideas to make BIP324 transport encryption
quantum secure and describes a proposal to standardize QR-based signing payloads
for miniscript wallets. Also included are our regular sections summarizing
proposals and discussion about changing Bitcoin's consensus rules, announcing
new releases and release candidates, and describing notable changes to popular
Bitcoin infrastructure software.

## News

- **A post-quantum path for BIP324**: Olaoluwa Osuntokun [posted][pq bip324 ml]
  to the Bitcoin-Dev mailing list his thoughts on possible upgrades
  needed to make [BIP324][] quantum secure. BIP324 introduced [transport encryption][topic v2 p2p transport]
  for the P2P protocol, enabling peers to exchange messages on the network with
  improved privacy and security, and it is designed in such a way that the initial
  handshake and the whole traffic look completely random for an external viewer.
  According to Osuntokun, modifying the P2P protocol does not require widespread
  agreement as a consensus change does, and could be an easier first step to
  make Bitcoin quantum secure.

  Before proposing a formal BIP, Osuntokun invited discussion on two main design points.
  The first one covers which [Key-Encapsulation Mechanism][wiki kem] (KEM) should be used,
  either a hybrid approach or a pure post-quantum one, both leveraging a new
  primitive called Module-Lattice-based KEM (ML-KEM). The second design point addresses
  the question of whether the initial handshake should still be indistinguishable
  from a random byte string or not.

  On the first point, the author specified that a hybrid approach, combining the
  current ECDH algorithm and ML-KEM, could provide better guarantees,
  since it would provide protection in case either of the two algorithms is
  broken. In fact, while ECDH could be broken by a future Cryptographically
  Relevant Quantum Computer (CRQC), quantum-safe algorithms have not been
  battle-tested yet and could still fail due to mathematical flaws.

  On the second point, Osuntokun provided possible alternatives, in case
  the requirement for a handshake to be indistinguishable from a random
  byte string needs to be maintained. The first approach would use the
  current BIP324 handshake first to open a classical channel to be used
  to negotiate the post-quantum one. Another approach, based on Outer
  Encrypts Inner Nested Combiner (OEINC), would use an outer KEM to
  encrypt another inner KEM, achieving a post-quantum channel in a single step.

- **Discussion of QR signing payloads for miniscript wallets**: Pyth [posted][pyth delving qr]
  to Delving Bitcoin a proposal to standardize the data payloads exchanged
  between wallet coordinators and air-gapped signing devices over QR codes when
  using [miniscript][topic miniscript]-based spending policies. While existing
  QR-based protocols handle standard m-of-n multisig, miniscript's
  variable policies require additional capabilities that current
  schemes do not cover. His proposal defines payload types for retrieving xpubs, registering a
  [descriptor][topic descriptors], verifying addresses, and signing. Pyth is
  seeking feedback from signing device and wallet developers on the proposed payloads.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **CTV-only vault proof of concept**: Ademan [announced][ademan delving
  mccv] on Delving Bitcoin the 0.1.0 release of his [CTV][topic op_checktemplateverify] ([BIP119][])
  [vault][topic vaults] project called [MCCV][mccv] (More Complicated CTV
  Vault). MCCV implements several ideas about how full featured vaults (less
  simple than James O'Beirne's [simple-ctv-vault][jamesob ctv vault], see
  [Newsletter #191][news191 simple vault]) can be
  built without more complex opcodes such as `OP_VAULT` ([BIP345][]) or
  [`OP_CHECKCONTRACTVERIFY`][topic matt] ([BIP443][]). Specifically, MCCV uses a directed
  acyclic graph (DAG) of CTV transactions to implement a single-UTXO vault
  which can exist for many interactions before eventually becoming spendable
  by the vault's recovery keys. Using a [taproot][topic taproot] script tree
  of possible withdrawal scripts, each with different amounts and
  [timelocks][topic timelocks], MCCV implements rate limiting. Also in the
  script tree are deposit CTV hashes which allow additional funds of various
  amounts to be added to the vault. MCCV avoids one of the fundamental
  problems solved by BIPs 345 and 443 of combining vaulted inputs by using a
  single vault UTXO which is expanded and contracted, rather than a collection
  of vault UTXOs. Like all CTV-based vault designs, the amounts which can be
  deposited or withdrawn must be precise and enumerated at creation, which
  BIPs 345 and 443 do not require. However, MCCV's rate limiting is not fully
  possible in multi-UTXO vaults. MCCV can also be implemented with
  `OP_TEMPLATEHASH` ([BIP446][]).

- **Post-quantum Lightning discussion**: Olaoluwa Osuntokun (roasbeef)
  [posted][oo delving ln lbl] to Delving Bitcoin a breakdown of how a [post-quantum][topic quantum resistance] Lightning
  Network might look, layer by layer. Osuntokun outlined
  the landscape of available post-quantum cryptosystems and the layers of
  the Lightning Network to match cryptosystems to each required cryptographic
  primitive. Post-quantum Lightning can retain its overall structure, but will
  likely have to give up the single node key that it currently relies on. No
  single post-quantum cryptosystem or key can provide all of the primitives
  required. Osuntokun found that lattice-based
  cryptography is best suited for certain Lightning Network functions,
  including key exchange. He also notes that due to the large size of
  post-quantum cryptographic elements, it would likely make sense to continue
  using elliptic curve cryptography in parallel to provide security in case of
  a weakness in the several post-quantum schemes.

- **Quantum attack game theory**: Jameson Lopp [posted][jl delving qag] to Delving Bitcoin his
  [blog post][jl qag] about the game theory of a quantum attack. Lopp describes the potential incentives and actions of various
  market participants if a quantum computer is built which can reveal Bitcoin
  secret keys from public keys. The potential scenarios he describes are unpredictable, as quantum
  attackers might rapidly gain access to large amounts of Bitcoin without the
  proof of work and capital investment associated with other large holders.

- **BIP54 64-byte transactions and potential legitimate uses**: Jeremy
  Rubin [wrote][jr ml 64] to the Bitcoin-Dev mailing list about potential
  legitimate uses for 64-byte witness-stripped transactions. The
  [consensus cleanup][topic consensus cleanup] ([BIP54][]) proposal includes a
  change to make 64-byte witness-stripped transactions consensus invalid. This
  change is intended to make a class of [merkle tree vulnerabilities][topic
  merkle tree vulnerabilities] impossible and therefore make implementing
  simplified payment verification wallets and similar header-based payment
  verification schemes safer. Because a 64-byte transaction can have at most 1
  input and 1 anyone-can-spend output, the authors of [BIP54][] had considered
  them not worth protecting. Rubin proposes several potential scenarios where
  present or future protocols might make use of such transactions.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 26.06][] is a major release of this popular LN node
  implementation. It adds new `graceful`, `sendamount`, and `xkeysend` RPCs,
  begins the `pay` deprecation cycle in favor of `xpay`, and adds experimental
  [BOLT12][topic offers] payment proof support. See the [changelog][cln 26.06
  changelog] for additional details.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35269][] fixes [MuSig2][topic musig] [PSBT][topic psbt]
  signing by including each participant's public nonce in Bitcoin Core's
  internal MuSig2 signing session identifier. Previously, calling
  `walletprocesspsbt` more than once on the same nonce-less PSBT could generate
  a new public nonce but the same internal session ID, triggering an assertion
  meant to prevent nonce reuse. The new session identifier distinguishes
  signing sessions with different public nonces, but still crashes if the same
  nonce appears to be reused to prevent a private key leak.

- [Bitcoin Core #34644][] adds a `submitBlock` method to the Mining IPC
  interface (see Newsletters [#310][news310 mining] and [#323][news323
  mining]), allowing [Stratum v2][topic pooled mining] clients to submit a
  fully assembled block for validation and processing. This is useful when a
  Stratum v2 job declarator receives a solved block for which Bitcoin Core
  lacks a corresponding `BlockTemplate` object, making the existing
  `submitSolution` method insufficient (see [Newsletter #325][news325 ipc]).
  The new method is similar to the `submitblock` RPC, but it returns a boolean
  result and rejection details for duplicate, inconclusive, or invalid blocks.
  Unlike the RPC, IPC callers must submit a complete block, including the
  coinbase witness when a witness commitment is present.

- [Bitcoin Core #34198][] fixes a migration failure affecting very old legacy
  wallets created before wallet best block records were added in 2011. It is
  now possible to migrate a wallet with an empty best block locator to a
  [descriptor][topic descriptors] wallet, but a full chain rescan is required
  before the migration is complete.

- [LND #10813][] removes support for producing [Tor][topic anonymity networks]
  v2 onion services, which were deprecated in LND 0.20 (see Newsletter
  [#375][news375 tor]). The deprecated `tor.v2` option is removed, however v2
  addresses are still preserved in peer announcements so existing gossip
  messages can still be verified and rebroadcast. Tor v2 onion services have
  been obsolete since October 2021; users should use Tor v3 instead.

- [Rust Bitcoin #6250][] starts validating that the coinbase input contains a
  32-byte witness reserved value whenever the coinbase transaction includes a
  witness commitment, aligning rust-bitcoin's block validation with [BIP141][].
  Previously, rust-bitcoin only performed this check when the block contained
  other [segwit][topic segwit] transactions, so it could accept a block with a
  coinbase witness commitment but no coinbase witness reserved value.

- [BOLTs #1338][] updates [BOLT2][] to require nodes to wait at least 100
  blocks before sending `channel_ready` if the channel funding transaction is a
  coinbase transaction, preventing a miner from immediately using an immature
  coinbase output to open a channel.

- [BOLTs #1326][] updates [BOLT4][] to allow final nodes, not just forwarding
  nodes, to return `invalid_onion_version`, `invalid_onion_hmac`, or
  `invalid_onion_key` errors. Previously, these errors were incorrectly placed
  under a rule that final nodes must not use. The PR also clarifies that
  forwarding nodes must not handle already-paid payment hashes as final
  recipients do.

{% include snippets/recap-ad.md when="2026-06-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35269,34644,34198,10813,6250,1338,1326" %}

[ademan delving mccv]: https://delvingbitcoin.org/t/ctv-only-vault-concept-v0-1-0-release/2539
[jamesob ctv vault]: https://github.com/jamesob/simple-ctv-vault
[news191 simple vault]: /en/newsletters/2022/03/16/#continued-ctv-discussion
[mccv]: https://github.com/LNHANCE-Expedition/mccv
[oo delving ln lbl]: https://delvingbitcoin.org/t/post-quantum-lightning-layer-by-layer/2479
[jl delving qag]: https://delvingbitcoin.org/t/quantum-attack-game-theory/2524
[jl qag]: https://blog.lopp.net/quantum-attack-game-theory/
[jr ml 64]: https://groups.google.com/g/bitcoindev/c/iCuq6bFKt5Y/m/MCATyQ4zAAAJ
[pq bip324 ml]: https://groups.google.com/g/bitcoindev/c/n_5WuKVYqwI/m/lBooLis3AQAJ
[wiki kem]: https://en.wikipedia.org/wiki/Key_encapsulation_mechanism
[pyth delving qr]: https://delvingbitcoin.org/t/qr-based-signing-flow-payloads-in-miniscript-context/2464
[Core Lightning 26.06]: https://github.com/ElementsProject/lightning/releases/tag/v26.06
[cln 26.06 changelog]: https://github.com/ElementsProject/lightning/blob/v26.06/CHANGELOG.md
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /en/newsletters/2024/10/04/#bitcoin-core-30510
[news325 ipc]: /en/newsletters/2024/10/18/#bitcoin-core-30955
[news375 tor]: /en/newsletters/2025/10/10/#lnd-10254
