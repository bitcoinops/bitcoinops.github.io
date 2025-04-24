---
title: 'Bitcoin Optech Newsletter #351'
permalink: /en/newsletters/2025/04/25/
name: 2025-04-25-newsletter
slug: 2025-04-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a new aggregate signature protocol
compatible with secp256k1 and describes a standardized backup scheme for
wallet descriptors.  Also included are our regular sections summarizing
recent Bitcoin Stack Exchange questions and answers, announcing new
releases and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **Interactive aggregate signatures compatible with secp256k1:** Jonas
  Nick, Tim Ruffing, Yannick Seurin [posted][nrs dahlias] to the
  Bitcoin-Dev mailing list to announce a [paper][dahlias paper] they've
  written about creating 64-byte aggregate signatures compatible with
  the cryptographic primitives already used by Bitcoin.  Aggregate
  signatures are the cryptographic requirement for [cross-input
  signature aggregation][topic cisa] (CISA), a feature proposed for
  Bitcoin that could reduce the size of transactions with multiple
  inputs, which would reduce the cost of many different types of
  spending---including privacy-enhanced spending through
  [coinjoins][topic coinjoin] and [payjoins][topic payjoin].

  In addition to an aggregate signature scheme like the DahLIAS scheme proposed
  by the authors, adding support for CISA to Bitcoin would require a
  consensus change and possible interactions between signature
  aggregation and other proposed consensus changes that may warrant further
  study.

- **Standardized backup for wallet descriptors:** Salvatore Ingala
  [posted][ingala backdes] to Delving Bitcoin a summary of various
  tradeoffs related to backing up wallet [descriptors][topic
  descriptors] and a proposed scheme that should be useful for many
  different types of wallets, including those using complex scripts.
  His scheme encrypts descriptors using a deterministically generated
  32-byte secret.  For each public key (or extended public key) in the
  descriptor, a copy of the secret is xored with a variant of the public
  key, creating _n_ 32-byte secret encryptions for _n_ public keys.
  Anyone who knows one of the public keys used in the descriptor can xor
  it with the 32-byte secret encryption to get the 32-byte secret that
  can decrypt the descriptor.  This simple and efficient scheme allows
  anyone to store many encrypted copies of a descriptor across multiple
  media and network locations, and then use their [BIP32 wallet
  seed][topic bip32] to generate their xpub, which they can use to
  decrypt the descriptor if they ever lose their wallet data.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.19.0-beta.rc3][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31247][] adds support for serializing and parsing
  [MuSig2][topic musig] [PSBT][topic psbt] fields as specified in [BIP373][] to
  allow wallets to sign and spend [MuSig2][topic musig] inputs. On the input
  side, this consists of a field listing the participant pubkeys, plus a
  separate public nonce field and a separate partial signature field for each
  signer. On the output side, it is a single field listing the participant
  pubkeys for the new UTXO.

- [LDK #3601][] adds a new `LocalHTLCFailureReason` enum to represent each
  standard [BOLT4][] error code, along with some variants that surface
  additional information to the user that was previously removed for privacy
  reasons.

{% include snippets/recap-ad.md when="2025-04-29 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31247,3601" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[nrs dahlias]: https://mailing-list.bitcoindevs.xyz/bitcoindev/be3813bf-467d-4880-9383-2a0b0223e7e5@gmail.com/
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[ingala backdes]: https://delvingbitcoin.org/t/a-simple-backup-scheme-for-wallet-accounts/1607
