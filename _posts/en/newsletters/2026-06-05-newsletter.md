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

FIXME:bitschmidty

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

{% include snippets/recap-ad.md when="2026-06-09 16:30" %}
{% include references.md %}
[ademan delving mccv]: https://delvingbitcoin.org/t/ctv-only-vault-concept-v0-1-0-release/2539
[jamesob ctv vault]: https://github.com/jamesob/simple-ctv-vault
[news191 simple vault]: /en/newsletters/2022/03/16/#continued-ctv-discussion
[mccv]: https://github.com/LNHANCE-Expedition/mccv
[oo delving ln lbl]: https://delvingbitcoin.org/t/post-quantum-lightning-layer-by-layer/2479
[jl delving qag]: https://delvingbitcoin.org/t/quantum-attack-game-theory/2524
[jl qag]: https://blog.lopp.net/quantum-attack-game-theory/
[jr ml 64]: https://groups.google.com/g/bitcoindev/c/iCuq6bFKt5Y/m/MCATyQ4zAAAJ
