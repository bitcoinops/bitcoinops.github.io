---
title: 'Bitcoin Optech Newsletter #335'
permalink: /en/newsletters/2025/01/03/
name: 2025-01-03-newsletter
slug: 2025-01-03-newsletter
type: newsletter
layout: newsletter
lang: en
---

This week's newsletter links to information about longstanding deanonymization
vulnerabilities in software using centralized coinjoin protocols and
summarizes an update to a draft BIP about the ChillDKG distributed key
generation protocol compatible with scriptless threshold signing.  Also
included are our regular sections summarizing discussion about changing
Bitcoin's consensus rules, announcing new releases and release
candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Deanonymization attacks against centralized coinjoin:** Yuval Kogman
  [posted][kogman cc] to the Bitcoin-Dev mailing list details about several
  privacy-reducing vulnerabilities in the centralized [coinjoin][topic
  coinjoin] protocols used by current versions of the Wasabi and Ginger
  wallets, plus past versions of the Samourai, Sparrow, and Trezor Suite
  software wallets.  Kogman helped design the WabiSabi protocol used in
  Wasabi and Ginger (see [Newsletter #102][news102 wabisabi]) but "left
  in protest before its release." If exploited, the vulnerabilities
  allow the centralized coordinator to determine which user received
  which outputs, eliminating any benefit of using a sophisticated
  protocol over a simple webserver.  Kogman provides evidence that
  the vulnerabilities were known to several wallet developers for years.
  A similar vulnerability affecting some of the same software was
  previously mentioned in [Newsletter #333][news333 vuln].

- **Updated ChillDKG draft:** Tim Ruffing and Jonas Nick [posted][rn
  chilldkg] to the Bitcoin-Dev mailing list a link to the [current draft
  BIP for ChillDKG][bip-chilldkg], which describes a distributed key
  generation protocol compatible with FROST [scriptless threshold
  signatures][topic threshold signature] for Bitcoin.  Since their
  initial announcement (see [Newsletter #312][news312 chilldkg]), they've
  fixed a security vulnerability, added an investigation phase that
  makes it possible to identify faulty participants, and made backup and
  recovery easier.  They've also worked with Sivaram Dhakshinamoorthy to
  keep their proposal in sync with his proposal for Bitcoin-compatible
  FROST signing (see [Newsletter #315][news315 frost]).

## Changing consensus

_A new monthly section summarizing proposals and discussion about
changing Bitcoin's consensus rules._

- **CTV enhancement opcodes:** developer moonsettler posted to both
  [Bitcoin-Dev][moonsettler ctvppml] and [Delving Bitcoin][moonsettler
  ctvppdelv] to propose two additional opcodes to be used in conjunction
  with the already-proposed [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify]:

  - _OP_TEMPLATEHASH_ takes a list of transaction elements and converts
    it into a CTV-compatible hash.  This allows stack operations to
    specify details about the inputs to be used, the number of inputs,
    the locktime, the value of each output, the script of each output,
    the number of outputs, and the transaction version to use.

  - _OP_INPUTAMOUNTS_ puts the satoshi value of some or all of the
    inputs on the stack, which can be used as a parameter for
    `OP_TEMPLATEHASH` (e.g. to require an equal output value).

  Together these opcodes can create [vaults][topic vaults] with similar
  properties to those possible with [BIP345][]'s `OP_VAULT`.  The
  opcodes may also be convenient for implementing more onchain-efficient
  types of [accountable computing][topic acc], in addition to other
  contract protocols.  Discussion on the Delving Bitcoin thread was
  ongoing at the time of writing.

- **Adjusting difficulty beyond 256 bits:** Anders [posted][anders diff]
  to the Bitcoin-Dev mailing list with a concern about adjusting
  proof-of-work (PoW) difficulty beyond the 256 bits available in a
  block header.  That would require an unfathomable increase in hashrate
  (an increase of about 2<sup>176</sup> times the current rate), but if
  it were to happen, Michael Cassano [notes][cassano diff] that a fork
  could add a secondary hash target and both the primary target and the
  second target would need to be met in order for a block to be valid.
  This is similar to a proposal to mitigate block withholding attacks
  (see [Newsletter #315][news315 withholding]).  These types of forks,
  which include proposals like _forward blocks_ (see [Newsletter
  #16][news16 forward]), may technically be soft forks because they only
  tighten existing rules, but some developers prefer not to use that
  label because they make it easy for non-upgraded full nodes and
  potentially all lightweight (SPV) clients to be tricked into thinking
  that a transaction has hundreds or thousands of confirmations when it
  actually has zero confirmations or conflicts with an actually
  confirmed transaction.

- **Transitory soft forks for cleanup soft forks:** Jeremy Rubin
  [posted][rubin transitory] to Delving Bitcoin about only temporarily
  applying consensus rules designed to mitigate or fix vulnerabilities.
  The idea had previously been proposed for soft forks that add new
  features (see [Newsletter #197][news197 transitory]) but didn't
  receive any support from either advocates for new features or
  community members ambivalent about the proposed changes.  Rubin
  suggest the idea might apply better to soft forks that attempt to fix
  vulnerabilities but carry a risk of accidentally preventing users from
  spending their bitcoins (called _confiscation risk_) or limiting the
  ability to easily fix future vulnerabilities.  David Harding
  [argued][harding transitory] that the previous lack of support for the
  idea of transitory soft forks arose from neither advocates nor
  ambivalent community members wanting to have to re-argue for or
  against a consensus change every few years, and that this concern
  applies the same whether a change adds a feature or addresses a
  vulnerability.

- **Quantum computer upgrade path:** Matt Corallo [posted][corallo qc]
  to the Bitcoin-Dev mailing list about adding a quantum-resistant
  signature-checking opcode in [tapscript][topic tapscript] to allow
  funds to be spent even if ECDSA and [schnorr signature][topic schnorr
  signatures] operations were disabled due to forgery risk from fast
  quantum computers.  Luke Dashjr [noted][dashjr qc] that a soft fork is
  unnecessary at present as long as there's widespread agreement now
  about how quantum-resistant signature-checking opcode would work in
  the future, as users only need to commit to it as an option which may
  become available later.  Tadge Dryja [suggested][dryja qc] a
  transitory soft fork that would temporarily restrict the use of
  quantum-insecure ECDSA and schnorr signatures if it looked like
  quantum computers were on the verge of being able to steal bitcoins.
  Then, if anyone fulfilled an onchain puzzle contract that is only
  solvable with a quantum computer (or the discovery of a fundamental
  cryptographic vulnerability), the transitory soft fork would
  automatically become permanent; otherwise the transitory soft fork
  could be renewed or allowed to lapse (making bitcoins protected by
  ECDSA and schnorr spendable again).

- **Consensus cleanup timewarp grace period:** Sjors Provoost
  [posted][provoost timewarp] to Delving Bitcoin about the proposal for
  the [consensus cleanup][topic consensus cleanup] soft fork to mitigate
  the [time warp attack][topic time warp] by forbidding the first block
  in a new difficulty period from having a time more than 600 seconds
  earlier than the last block in the previous period.  Provoost is
  concerned that a honest miner using software that expands its nonce
  space by using a range of timestamps (called _time rolling_) will
  accidentally produce a block that nodes with slow clocks might not
  immediately accept, slowing the block's propagation compared to
  competing blocks with less variable timestamps that may be produced
  around the same time.  If a competing block remains on the best
  blockchain, the miner of the time-rolling block will lose income.
  Provoost instead suggests a less constrictive limit, such as
  forbidding time from running backwards more than 7,200 seconds (two
  hours).  Antoine Poinsot [defends][poinsot timewarp] the choice of 600
  seconds as avoiding any known problem and providing the strongest
  defense against future time warping.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BDK wallet-1.0.0][] is the first major release of this
  library for building Bitcoin wallets and other Bitcoin-enabled
  applications.  The original `bdk` Rust crate has been renamed to
  `bdk_wallet` (with an API intended to remain stable) and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.

- [LND 0.18.4-beta][] is a minor release of this popular LN
  implementation that "ships the features required for building custom
  channels, alongside the usual bug fixes and stability improvements."

- [Core Lightning v24.11.1][] is a minor release that improves
  compatibility between the experimental `xpay` plugin and the older
  `pay` RPC and makes several other improvements for xpay users.

- [Bitcoin Core 28.1rc2][] is a release candidate for a maintenance
  version of the predominant full-node implementation.

- [LDK v0.1.0-beta1][] is a release candidate of this library for
  building LN-enabled wallets and applications.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31223][] changes how a node derives its “[Tor][topic anonymity
  networks] service target” P2P port (see Newsletter [#118][news118 tor]), using
  the user-specified `-port` value plus one instead of the default of 8334, if a
  `-port` value is given. This fixes a problem where multiple local nodes would
  all bind to 8334 and crash due to port collision. However, in the rare case
  where two local nodes are assigned consecutive `-port` values, they may still
  collide on the derived onion port, but this should be avoided altogether.

- [Eclair #2888][] implements support for the [peer storage][topic peer storage]
  protocol as specified in [BOLTs #1110][], which allows nodes to store
  encrypted backups for peers that request them, up to 65kB by default. This
  feature is intended for Lightning Service Providers (LSPs) serving mobile
  wallets, and has configurable settings that allow a node operator to specify
  how long it will store the data. This makes Eclair the second implementation
  to support peer storage, after CLN (see Newsletter [#238][news238 storage]).

- [LDK #3495][] refines the historical success probability scoring model in LN
  pathfinding by improving the [probability density function (PDF)][probability
  density] and related parameters based on real-world data collected from
  randomized probes. This PR aligns historical and a priori models with
  real-world behavior, enhances default penalties, and improves pathfinding
  reliability.

- [LDK #3436][] moves the `lightning-liquidity` crate
  to the `rust-lightning` repository.  This crate provides types and
  primitives to integrate an LSP (as specified [here][lsp spec]) with an
  LDK-based node.

- [LDK #3435][] adds an authentication field to the [blinded path][topic rv
  routing] payment context message for a payer to include a Hash-based Message
  Authentication Code (HMAC) and a nonce and allow a recipient to authenticate
  the payer. This fixes an issue where an attacker could take a `payment_secret`
  from a [BOLT11][] invoice issued by the victim node and forge a payment, even
  if it didn't match the amount expected for that [offer][topic offers]. This
  also helps prevent deanonymization attacks using the same technique.

- [LDK #3365][] ensures that the `holder_commitment_point` (next commitment
  point) is immediately marked as available on upgrades by retrieving it in
  `get_channel_reestablish`, instead of leaving it in the previously used
  `PendingNext` state. This change prevents forced closures when a channel is in
  a steady state during an upgrade and then receives a `commitment_signed`
  message that requires the next commitment point to be available.

- [LDK #3340][] introduces [batching][topic payment batching] of on-chain claim
  transactions with [pinnable][topic transaction pinning] outputs, reducing
  block space usage and fees in force-closure scenarios. Previously, outputs
  were only batched if they were exclusively claimable by the node, and
  therefore non-pinnable. Now, any output within 12 blocks of the height at
  which a counterparty can spend it is treated as pinnable and batched
  accordingly, provided their [HTLC][topic htlc]-timeout [locktimes][topic
  timelocks] can be combined.

- [BDK #1670][] introduces a new O(n) canonicalization algorithm that identifies
  canonical transactions and removes unconfirmed conflicts that are unlikely to
  get confirmed (non-canonical) from the wallet's best local chain view. This
  significantly more efficient approach replaces and removes the old
  `get_chain_position` method, which provided an O(n²) solution that [may
  have been a DoS risk][canalgo] for certain use cases.

- [BIPs #1689][] merges [BIP374][] to specify a standard way to generate and
  verify [Discrete Log Equality Proofs (DLEQs)][topic dleq] for the elliptic
  curve used by Bitcoin (secp256k1). This BIP is motivated by support for
  [silent payments][topic silent payments] created using multiple independent
  signers; a DLEQ would allow all signers to prove to co-signers that their
  signature is valid and doesn't risk losing funds, without revealing their
  private key.

- [BIPs #1697][] updates [BIP388][] to add support for [MuSig][topic musig] in
  the templated set of [output script descriptors][topic descriptors] by making
  fine-grained grammar changes.

- [BLIPs #52][] adds [BLIP50][] to specify a protocol that is used for
  communication between LSP nodes and their clients, with a JSON-RPC format over
  [BOLT8][] peer-to-peer messages. This is part of a set of BLIPs that are
  upstreamed from the [LSP specification repository][lsp spec], and which are
  considered stable because they are live in production on multiple LSP and
  client implementations.

- [BLIPs #54][] adds [BLIP52][] to specify a protocol for [JIT channels][topic
  jit channels] that allows clients without any LN channels to start receiving
  payments. When an incoming payment is received by the LSP, a channel is opened
  to the client in response, and the cost of opening the channel is deducted
  from the first payment received. This is also part of a set of BLIPs that are
  upstreamed from the [LSP specification repository][lsp spec].

{% include snippets/recap-ad.md when="2025-01-07 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31223,2888,3495,3436,3435,3365,3340,1670,1689,1697,54,52,1110" %}
[news315 withholding]: /en/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[news16 forward]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[moonsettler ctvppml]: https://groups.google.com/g/bitcoindev/c/1P1aqkfwE7E
[moonsettler ctvppdelv]: https://delvingbitcoin.org/t/ctv-op-templatehash-and-op-inputamounts/1344/
[anders diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/qR4ucBeMCAAJ
[cassano diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/gPNAMn3ICAAJ
[corallo qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/4cM-7pf4AgAJ
[dashjr qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/YT0fR2j_AgAJ
[dryja qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/8nr6I5NIAwAJ
[rubin transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333
[news197 transitory]: /en/newsletters/2022/04/27/#relayed
[harding transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333/2
[provoost timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326
[poinsot timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/11
[news333 vuln]: /en/newsletters/2024/12/13/#deanonymization-vulnerability-affecting-wasabi-and-related-software
[news315 frost]: /en/newsletters/2024/08/09/#proposed-bip-for-scriptless-threshold-signatures
[news312 chilldkg]: /en/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[kogman cc]: https://groups.google.com/g/bitcoindev/c/CbfbEGozG7c/m/w2B-RRdUCQAJ
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[rn chilldkg]: https://groups.google.com/g/bitcoindev/c/HE3HSnGTpoQ/m/Y2VhaMCrCAAJ
[bip-chilldkg]: https://github.com/BlockstreamResearch/bip-frost-dkg
[lnd 0.18.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta
[bitcoin core 28.1rc2]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[bdk wallet-1.0.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.0.0
[core lightning v24.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.1
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[news118 tor]: /en/newsletters/2020/10/07/#bitcoin-core-19991
[news238 storage]: /en/newsletters/2023/02/15/#core-lightning-5361
[lsp spec]: https://github.com/BitcoinAndLightningLayerSpecs/lsp
[probability density]: https://en.wikipedia.org/wiki/Probability_density_function
[canalgo]: https://github.com/evanlinjin/bdk/blob/e9854455ca77875a6ff79047726064ba42f94f29/docs/adr/0003_canonicalization_algorithm.md
