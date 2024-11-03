---
title: 'Bitcoin Optech Newsletter #317'
permalink: /en/newsletters/2024/08/23/
name: 2024-08-23-newsletter
slug: 2024-08-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion about an anti-exfiltration
protocol that only requires one round trip of communication between
a wallet and a signing device.  Also included are our regular sections
describing updates to clients and services, announcing new releases and
release candidates, and summarizing recent changes to popular Bitcoin
infrastructure software.

## News

- **Simple (but imperfect) anti-exfiltration protocol:** developer
  Moonsettler [posted][moonsettler exfil1] to Delving Bitcoin to describe an
  [anti-exfiltration][topic exfiltration-resistant signing] protocol.
  The same protocol has been described before (see Newsletters
  [#87][news87 exfil] and [#88][news88 exfil]), with Pieter Wuille
  [citing][wuille exfil1] the earliest known description of the
  technique for anti-exfil being a [2014 post][maxwell exfil] by Gregory
  Maxwell.

  The protocol uses the sign-to-contract protocol to allow a software
  wallet to contribute entropy to the nonce selected by a hardware
  signing device in a way that allows the software wallet to later
  verify the entropy was used.  Sign-to-contract is a variation on
  [pay-to-contract][topic p2c]: in pay-to-contract, the receiver's
  public key is tweaked; in sign-to-contract, the spender's signature
  nonce is tweaked.

  The advantage of this protocol, compared to the protocol implemented
  for BitBox02 and Jade hardware signing devices (see [Newsletter
  #136][news136 exfil]), is that it only requires one round trip of
  communication between the software wallet and the hardware signing
  device.  That one round trip can be combined with the other steps
  necessary to sign for a single-sig or scripted multisig transaction,
  meaning the technique doesn't affect user workflows.  The currently
  deployed technique, which is also based on sign-to-contract, requires
  two round trips; that's more than required for most users today,
  although multiple round trips may be required for users who upgrade to
  using [scriptless multisignatures][topic multisignature] and
  [scriptless threshold signatures][topic threshold signature].  For
  users who connect their signing devices directly to their computers or
  who use an interactive wireless communication protocol like Bluetooth,
  the number of round trips doesn't matter.  But, for users who prefer
  to keep their devices airgapped, each roundtrip requires two manual
  interventions---which can quickly add up to an annoying amount of work
  when signing frequently or using multiple devices for scripted
  multisignatures.

  The disadvantage of this protocol was mentioned by Maxwell in his
  original description, it "leaves open a [side-channel][topic side
  channels] that has exponential cost per additional bit, via grinding
  [...] but it eliminates the obvious and very powerful attacks where
  everything is leaked in a single signature.  This is clearly less
  good, but it's only a two-move protocol, so many places that wouldn't
  consider using a countermeasure could pick this up for free just as an
  element of a protocol spec."

  This protocol is a clear upgrade over not using anti-exfiltration at
  all and Pieter Wuille [notes][wuille exfil2] that it is probably the
  best possible anti-exfiltration with single-round signing.
  However, Wuille advocates for the deployed two-round anti-exfiltration
  protocol to prevent even grinding-based exfiltration.

  Discussion was ongoing at the time of writing. {% assign timestamp="0:53" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Proton Wallet announced:**
  Proton [announced][proton blog] their [open-source][proton github] Proton
  Wallet with support for multiple wallets, [bech32][topic bech32],
  [batch][topic payment batching] sending, [BIP39][] mnemonics, and integration with their email service. {% assign timestamp="23:33" %}

- **CPUNet testnet announced:**
  A contributor from the [braidpool][braidpool github] mining [pool][topic
  pooled mining] project [announced][cpunet post] test network [CPUNet][cpunet
  github]. CPUNet uses a modified proof-of-work algorithm to exclude ASIC miners with
  the intent of achieving more consistent block rates than is typical of
  [testnet][topic testnet]. {% assign timestamp="25:38" %}

- **Lightning.Pub launches:**
  [Lightning.Pub][lightningpub github] provides node management
  features for LND that allow for shared access and coordinating channel
  liquidity, using nostr for encrypted communications and key-based account
  identities. {% assign timestamp="38:52" %}

- **Taproot Assets v0.4.0-alpha released:**
  The [v0.4.0-alpha][taproot assets v0.4.0] release supports the [Taproot Assets][topic client-side validation]
  protocol on mainnet for onchain asset issuance and atomic swaps using
  [PSBTs][topic psbt] and routing assets through the Lightning Network. {% assign timestamp="39:45" %}

- **Stratum v2 benchmarking tool released:**
  The initial [0.1.0 release][sbm 0.1.0] supports testing, reporting, and comparing
  the performance of Stratum v1 and Stratum v2 [protocols][topic pooled mining] in different mining scenarios. {% assign timestamp="41:31" %}

- **STARK verification PoC on signet:**
  StarkWare [announced][starkware tweet] a [STARK verifier][bcs github]
  verifying a zero-knowledge proof on the [signet][topic signet] test network
  using the [OP_CAT][topic op_cat] opcode (see [Newsletter #304][news304 inquisition]). {% assign timestamp="42:52" %}

- **SeedSigner 0.8.0 released:**
  Bitcoin hardware signing device project [SeedSigner][seedsigner website] added
  signing features for P2PKH and P2SH multisig, additional [PSBT][topic psbt]
  support, and enabled [taproot][topic taproot] support by default in the
  [0.8.0][seedsigner 0.8.0] release. {% assign timestamp="48:48" %}

- **Floresta 0.6.0 released:**
  In [0.6.0][floresta 0.6.0], Floresta adds support for [compact block
  filters][topic compact block filters], fraud proofs on signet, and
  [`florestad`][floresta blog], a daemon for integration by existing wallets or client applications. {% assign timestamp="50:25" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 24.08rc2][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="51:52" %}

- [LND v0.18.3-beta.rc1][] is a release candidate for a minor bug fix
  release of this popular LN node implementation. {% assign timestamp="52:33" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #28553][] adds [assumeUTXO][topic assumeutxo] snapshot
  parameters for mainnet block 840,000: its block hash, the number of
  transactions up to that block, and the SHA256 hash of the serialized UTXO set
  up to that block. This follows tests by multiple contributors that they can
  reproduce the same [snapshot file][] with the expected SHA256 checksum, and that
  the snapshot works well when loaded. {% assign timestamp="53:18" %}

- [Bitcoin Core #30246][] introduces a `diff_addrs` subcommand to the
  `asmap-tool` utility to allow users to compare two maps of [Autonomous
  Systems][auto sys] (ASMaps) and compute statistics on how many node network
  addresses have been reassigned to a different Autonomous System Number (ASN).
  This functionality quantifies the degradation of an ASMap over time, which is
  an important step towards eventually shipping precomputed ASMaps in Bitcoin
  Core releases, and further increase Bitcoin Core’s resistance to [eclipse
  attacks][topic eclipse attacks]. See Newsletter [#290][news290 asmap]. {% assign timestamp="56:39" %}

- [Bitcoin Core GUI #824][] changes the `Migrate Wallet` menu item from a single
  action to a menu list, allowing users to migrate any legacy wallet in the
  wallet directory, including unloadable wallets. This change prepares for a
  possible future where legacy wallets may no longer be loadable in Bitcoin
  Core, with [descriptor][topic descriptors] wallets becoming the default. When
  selecting a wallet to migrate, the GUI will prompt the user to enter the
  wallet’s passphrase, if it has one. {% assign timestamp="1:02:10" %}

- [Core Lightning #7540][] improves the formula that calculates the probability
  of a successful routing through a channel in the `renepay` plugin (see
  Newsletter [#263][news263 renepay]) by adding a constant multiplier that
  represents the probability that a randomly chosen channel in the network is
  able to forward at least 1 msat. The default value is set to 0.98, but this
  may be changed in the future after further testing. {% assign timestamp="1:04:20" %}

- [Core Lightning #7403][] adds a channel filtering payment modifier to the
  `renepay` plugin which disables channels with a very low `max_htlc`. This can
  be extended in the future to filter out channels that are undesirable for
  other reasons: high base fee, low capacity, and high latency. In addition, a new
  `exclude` command line option has been added to manually disable nodes or channels. {% assign timestamp="1:05:20" %}

- [LND #8943][] introduces [Alloy][alloy model] models to the codebase, starting
  with an initial Alloy model for the [Linear Fee Function][lnd linear] fee
  bumping mechanism, inspired by a bugfix [LND #8751][]. Alloy provides a
  lightweight formal method for verifying the correctness of system components
  to make it easier to find bugs during the initial implementation. Rather than
  trying to prove that a model is always correct, as full-blown formal methods
  do, Alloy instead operates on an input of a set of bounded parameters and
  iterations and tries to find counterexamples to a given assertion, accompanied
  by a nice visualizer. Models can also be used to specify protocols in P2P
  systems, so it's particularly well suited to the Lightning Network. {% assign timestamp="1:06:13" %}

- [BDK #1478][] makes several changes to the `FullScanRequest` and `SyncRequest`
  request structures of the `bdk_chain` crate: use a builder pattern that
  separates request construction and consumption, make the `chain_tip` parameter
  optional to allow users to opt out of `LocalChain` updates (useful for those
  using `bdk_esplora` without a `LocalChain`), and improve the ergonomics of
  checking synchronization progress. In addition, the `bdk_esplora` crate is
  optimized by always adding previous transaction outputs  to the `TxGraph`
  update and reducing the number of API calls by using the `/tx/:txid` endpoint. {% assign timestamp="1:07:26" %}

- [BDK #1533][] enables support for single [descriptor][topic descriptors]
  wallets by adding the `Wallet::create_single` method, reverting a previous
  update that had made the `Wallet` structure require an internal (change)
  descriptor. The reason for the previous change was to protect the privacy of
  users' change addresses when relying on public Electrum or Esplora servers,
  but this is being reverted to be inclusive of all use cases. {% assign timestamp="1:08:12" %}

- [BOLTs #1182][] improves the clarity and completeness of the [route
  blinding][topic rv routing] and [onion messages][topic onion messages]
  sections of the [BOLT4][] specification with the following changes: moves the
  route blinding section up one level to emphasize its applicability to payments
  (and not just onion messages), provides more concrete details on the
  `blinded_path` type and its requirements, expands the description of the
  writer's responsibilities, splits the reader section into separate parts for
  the `blinded_path` and `encrypted_recipient_data`, improves the explanation of
  the `blinded_path` concept, adds a recommendation to use a dummy hop, renames
  `onionmsg_hop` to `blinded_path_hop`, and makes other clarifying changes. {% assign timestamp="1:11:49" %}

- [BLIPs #39][] adds [BLIP39][] for an optional field `b` in [BOLT11][] invoices to
  communicate a [blinded path][topic rv routing] for paying the receiver’s node.
  This is implemented in LND (see Newsletter [#315][news315 blinded]) and is
  intended to be used until the [offers][topic offers] protocol is widely
  deployed in the network. {% assign timestamp="1:12:55" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28553,30246,824,7540,7403,8943,1478,1533,1182,39,8751" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[moonsettler exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081
[wuille exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/3
[wuille exfil2]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/7
[news87 exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 exfil]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[maxwell exfil]: https://bitcointalk.org/index.php?topic=893898.msg9861102#msg9861102
[news136 exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
[proton blog]: https://proton.me/blog/proton-wallet-launch
[proton github]: https://github.com/protonwallet/
[braidpool github]: https://github.com/braidpool/braidpool
[cpunet post]: https://x.com/BobMcElrath/status/1823370268728873411
[cpunet github]: https://github.com/braidpool/bitcoin/blob/cpunet/contrib/cpunet/README.md
[lightningpub github]: https://github.com/shocknet/Lightning.Pub
[taproot assets v0.4.0]: https://github.com/lightninglabs/taproot-assets/releases/tag/v0.4.0
[sbm 0.1.0]: https://github.com/stratum-mining/benchmarking-tool/releases/tag/0.1.0
[starkware tweet]: https://x.com/StarkWareLtd/status/1813929304209723700
[bcs github]: https://github.com/Bitcoin-Wildlife-Sanctuary/bitcoin-circle-stark
[news304 inquisition]: /en/newsletters/2024/05/24/#bitcoin-inquisition-27-0
[seedsigner website]: https://seedsigner.com/
[seedsigner 0.8.0]: https://github.com/SeedSigner/seedsigner/releases/tag/0.8.0
[floresta 0.6.0]: https://github.com/vinteumorg/Floresta/releases/tag/0.6.0
[floresta blog]: https://medium.com/vinteum-org/floresta-update-simplifying-bitcoin-node-integration-for-wallets-6886ea7c975c
[auto sys]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[news290 asmap]: /en/newsletters/2024/02/21/#improved-reproducible-asmap-creation-process
[news263 renepay]: /en/newsletters/2023/08/09/#core-lightning-6376
[alloy model]: https://alloytools.org/about.html
[lnd linear]: https://github.com/lightningnetwork/lnd/blob/b7c59b36a74975c4e710a02ea42959053735402e/sweep/fee_function.go#L66-L109
[news315 blinded]: /en/newsletters/2024/08/09/#lnd-8735
[snapshot file]: magnet:?xt=urn:btih:596c26cc709e213fdfec997183ff67067241440c&dn=utxo-840000.dat&tr=udp%3A%2F%2Ftracker.bitcoin.sprovoost.nl%3A6969
