---
title: 'Bitcoin Optech Newsletter #419'
permalink: /en/newsletters/2026/08/21/
name: 2026-08-21-newsletter
slug: 2026-08-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the disclosure of a fixed reorg vulnerability
in LND's channel closes and describes a draft BIP for the `rawtr()` output
script descriptor. Also included are our regular sections describing recent
changes to services and client software and notable changes to popular Bitcoin
infrastructure software.

## News

- **Reorg vulnerability in LND channel closes**: Bastien Teinturier [posted][lnd vuln del]
  to Delving Bitcoin the [responsible disclosure][topic responsible disclosures]
  of a vulnerability that affected LND versions before [0.20.0][lnd v20.0],
  which fixed it in February 2026. Operators running an older version should
  upgrade. To Teinturier's knowledge, no one was affected by the vulnerability.

  Before that version, an LND node would forget about a collaboratively closed
  channel immediately after the first onchain confirmation, losing the protection
  against chain reorgs. In case of a reorg, an attacker could publish an old, revoked
  commitment transaction for the channel and because the node had already
  forgotten the channel, it would not publish a penalty transaction,
  letting the attacker drain all of the channel's funds.

  The vulnerability was discovered in February 2025 and fixed in
  [LND #10331][] (see [Newsletter #389][news389 lnd10331]). The patch makes a node
  wait for more confirmations before considering a channel close final (at
  least six, following [BOLT5][]'s reorg-safety handling). Teinturier's post
  includes a regtest reproduction and a timeline of the disclosure.

- **Draft BIP for `rawtr()` output script descriptor**: Jean Pablo [posted][rawtr ml]
  to the Bitcoin-Dev mailing list about a BIP proposal for the `rawtr()`
  [output script descriptor][topic descriptors].

  A `rawtr()` descriptor can be used to express a P2TR output directly by its output key,
  without needing an internal key or a script tree. The key is used as the
  [taproot][topic taproot] output key without applying the [BIP341][] tweak.
  This is useful, for example, when the internal structure isn't known, or the
  script tree hasn't been revealed by the owner.

  This descriptor has been available in Bitcoin Core since version 24.0,
  but had not yet been specified in a BIP. Several implementations route around
  the problem by either not supporting it, or quoting other BIPs.
  The proposal aims to close this gap. The BIP draft and test vectors are available
  and being discussed under [BIPs #2251][].

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Payjoin Dev Kit (rust-payjoin) 1.0.0 released:**
  The Payjoin Dev Kit project [released][payjoin 1.0.0] the first stable version
  of rust-payjoin, supporting both synchronous BIP78 [payjoins][topic payjoin]
  and asynchronous BIP77 payjoins with resumable, persisted sessions.

- **Silent Payments sender plugin for Electrum:**
  Ali Sherief [released][sp electrum delving] a plugin that adds [silent
  payments][topic silent payments] (BIP352) sending (no receiving) to the
  Electrum desktop wallet for single-signature software wallets.

- **Superscalar implementation announced:**
  8144225309 [announced][superscalar delving] an implementation of Superscalar,
  ZmnSCPxj's [channel factory][topic channel factories] design that puts many
  self-custodial Lightning clients behind a single onchain UTXO without a soft
  fork (see our [Superscalar deep dive podcast][superscalar deepdive]).

- **Cofund multisig wallet announced:**
  Cofund [announced][cofund x] a self-custody [multisig][topic multisignature]
  wallet built on a policy-based [taproot][topic taproot] (P2TR) architecture
  with multi-vendor key registration and hierarchical multisig.

- **Lexe adds human-readable addresses and LNURL-withdraw:**
  Lexe, a self-custodial Lightning wallet that runs each user's node in a
  trusted execution environment (TEE) so it stays online without the operator
  taking custody, [announced][lexe x] support for [BIP353][] human-readable
  bitcoin addresses (which also function as Lightning Addresses) and
  [LNURL-withdraw][topic lnurl].

- **Ledger Bitcoin app 2.5.0 adds human-readable policy descriptions:**
  Salvatore Ingala [announced][salvatoshi x] version 2.5.0 of the Ledger Bitcoin
  app, which displays a human-readable description for many [taproot][topic
  taproot] [miniscript][topic miniscript] and [multisig][topic multisignature]
  wallet policies during registration, instead of only the opaque
  [descriptor][topic descriptors] template. This makes it easier for a user to
  verify a policy and catch a malicious substitution (such as a 3-of-5 replaced
  with a 1-of-5) before registering it.

- **Bark 0.5.0 released:**
  Second [released][second x] version 0.5.0 of Bark, its [Ark][topic ark]
  implementation, adding restoration of a wallet's full off-chain balance
  (VTXOs) from its mnemonic and support for Lightning receives to external Ark
  addresses, which enables non-custodial Lightning-address servers.

- **Bitcoin-PIR for private UTXO queries:**
  Weikeng Chen [announced][bitcoinpir] Bitcoin-PIR, a private information
  retrieval (PIR) system that lets a light client check the UTXO set for its own
  addresses or scriptPubKeys without revealing to the server which ones it is
  interested in. It offers a choice of four PIR backends: DPF-PIR, HarmonyPIR,
  OnionPIRv2, and an ORAM scheme backed by a trusted execution environment
  (TEE).

- **OP_TEMPLATEHASH Ark demonstration:**
  Steven Roose [launched][templatehash] a signet demonstration of Bark, Second's
  [Ark][topic ark] implementation, running against `OP_TEMPLATEHASH`, a
  taproot-native [CTV][topic op_checktemplateverify]-style [covenant][topic
  covenants] opcode. The demo is built from the `templatehash` branch of the
  Bark [repository][bark gitlab].

- **libshrincs formally verified hash-based signatures:**
  Jonas Nick [announced][libshrincs delving] libshrincs, a C implementation of
  [post-quantum][topic quantum resistance] hash-based signatures with a
  machine-checked security proof, written by remix7531.

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

{% include snippets/recap-ad.md when="2026-08-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="10331,2251" %}

[payjoin 1.0.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-1.0.0
[sp electrum delving]: https://delvingbitcoin.org/t/silent-payments-sender-bip352-plugin-for-electrum/2743
[superscalar delving]: https://delvingbitcoin.org/t/superscalar-an-implementation-report/2705
[superscalar deepdive]: /en/podcast/2024/10/31/
[cofund x]: https://x.com/getcofund/status/2085389177193972164
[lexe x]: https://x.com/lexeapp/status/2079245197817548964
[salvatoshi x]: https://x.com/salvatoshi/status/2086727660353261863
[second x]: https://x.com/secondhq/status/2084716752789991614
[bitcoinpir]: https://bitcoinpir.org
[templatehash]: https://templatehash.com
[bark gitlab]: https://gitlab.com/ark-bitcoin/bark
[libshrincs delving]: https://delvingbitcoin.org/t/libshrincs-a-c-implementation-with-a-machine-checked-security-proof/2795
[lnd vuln del]: https://delvingbitcoin.org/t/disclosure-lnd-doesnt-wait-for-enough-confirmations-when-closing-channels/2800
[lnd v20.0]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[rawtr ml]: https://groups.google.com/g/bitcoindev/c/CCZN_qQ5C1s
[news389 lnd10331]: /en/newsletters/2026/01/23/#lnd-10331
