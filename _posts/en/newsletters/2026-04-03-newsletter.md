---
title: 'Bitcoin Optech Newsletter #399'
permalink: /en/newsletters/2026/04/03/
name: 2026-04-03-newsletter
slug: 2026-04-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes how wallet fingerprinting can damage
payjoin privacy and summarizes a proposal for a wallet backup metadata
format. Also included are our regular sections summarizing proposals
and discussion about changing Bitcoin's consensus rules, announcing new
releases and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **Wallet fingerprinting risks for payjoin privacy**: Armin Sabouri
  [posted][topic payjoin fingerprinting] to Delving Bitcoin about how differences in
  payjoin implementations make it possible to fingerprint [payjoin][topic payjoin] transactions
  and can damage payjoin's privacy.

  Sabouri states that payjoin transactions should appear indistinguishable from
  standard single-party transactions. However, there can be artifacts of collaborative transactions:

  - Intra-transaction

    - Partition inputs and outputs by owner within a single transaction.

    - Differences in input encoding.

    - Inputs length in bytes.

  - Inter-transaction

    - Backward: Each input was created by a prior transaction that carries its own fingerprint.

    - Forward: Each output may be spent in a future transaction, revealing fingerprints.

  He then reviewed three payjoin implementations: Samourai, the PDK demo,
  and Cake Wallet (sending to Bull Bitcoin Mobile). In each of these examples, he finds
  a few discrepancies which make it possible to fingerprint these
  implementations. This includes but is not limited to:

  - Differences in encoded input signatures.

  - SIGHASH_ALL byte being included in one input but not the other.

  - Output value assignment.

  Sabouri concludes that while some of these
  wallet fingerprints are trivial to eliminate, others are intrinsic to a
  particular wallet's design choice. Wallet developers should be aware of these
  potential privacy leaks when implementing payjoin into their wallets.

- **Draft BIP for a wallet backup metadata format**: Pythcoiner
  [posted][wallet bip ml] to the Bitcoin-Dev mailing list about a new
  proposal for a common structure for wallet backup metadata.
  The draft BIP, available at [BIPs #2130][], specifies a standard
  way to store various type of metadata, such as account descriptors,
  keys, [labels][topic wallet labels], [PSBTs][topic psbt], and more, allowing compatibility between
  different wallet implementations and a simpler wallet migration and
  recovery processes. According to Pythcoiner, the ecosystem lacks a
  common specification and this proposal aims to fill this gap.

  From a technical perspective, the proposed format is a UTF-8 encoded
  text file containing a single valid JSON object representing the
  backup structure. The BIP lists all the different fields that could be
  included in the JSON object, specifies that each is
  optional, and notes that any wallet implementation should be free to ignore any
  metadata not deemed useful.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Compact Isogeny PQC can replace HD wallets, key-tweaking, silent payments**:
  Conduition [wrote][c delving ibc hd] on Delving Bitcoin about his research
  into the suitability of Isogeny-Based Cryptography (IBC) as a [post-quantum][topic quantum resistance]
  cryptosystem for Bitcoin. While the elliptic curve discrete logarithm
  problem (ECDLP) may be rendered insecure in a post-quantum world, there is
  nothing fundamentally broken about elliptic curve mathematics in general.
  Briefly, an Isogeny is a mapping from one elliptic curve to another. The
  cryptographic assumption of IBC is that it is difficult to compute the
  Isogeny between one elliptic curve of a specific type and another, while it
  is easy to produce an Isogeny and the curve it maps to from a base curve.
  Thus IBC secret keys are Isogenies and the public keys are the mapped
  curves.

  Like ECDLP secret and public keys, it is possible to compute new secret keys
  and public keys independently from the same salt (e.g. a [BIP32 derivation][topic bip32]
  step) and have the resulting secret keys correctly sign for the resulting
  public keys. Conduition refers to this as "rerandomization" and it
  fundamentally enables [BIP32][], [BIP341][], and [BIP352][] (with some
  additional cryptographic innovation, probably).

  To date, there are no signature aggregation protocols for IBC like there
  are in [MuSig][topic musig] and [FROST][topic threshold signature], and
  conduition issues a call to action for Bitcoin developers and cryptographers
  to research what may be possible.

  Keys and signatures in known IBC cryptosystems are about twice the
  size of keys in ECDLP-dependent cryptosystems. Much smaller than hash-based
  or lattice-based cryptosystems. Verification is costly even on desktop
  machines (on the order of 1 millisecond per verification), in the same
  ballpark as hash-based and lattice-based.

- **Varops budget and tapscript leaf 0xc2 (aka "Script Restoration") are BIPs 440 and 441**:
  Rusty Russell [wrote][rr ml gsr bips] on the Bitcoin-Dev mailing list
  that the first two BIPs of the Great Script Restoration (or Grand Script
  Renaissance) have been submitted for BIP numbering. They subsequently
  received BIP numbers 440 and 441 respectively. [BIP440][news374 varops]
  enables the restoration of previously-disabled Script opcodes by building an accounting system for the
  cost of each operation that ensures the worst case block-level script
  validation cost cannot exceed the cost of validating a block containing the
  worst case number of signature operations. [BIP441][news374 c2] describes
  the validation of a new [tapscript][topic tapscript] version which restores the opcodes
  disabled by Satoshi in 2010.

- **SHRIMPS: 2.5 KB post-quantum signatures across multiple stateful devices**:
  Jonas Nick [writes][jn delving shrimps] on Delving Bitcoin about a new
  semi-stateful hash-based signature construction for post-quantum Bitcoin.
  SHRIMPS takes advantage of the fact that [SPHINCS+][news383 sphincs]
  signature sizes scale with the maximum number of signatures for a given key
  which can be produced while retaining a given security level.

  Similar to the [SHRINCS][news391 shrincs] design, a SHRIMPS key consists of
  two keys hashed together. In this case, both keys are stateless SPHINCS+ keys,
  but with different parameter sets. The first key is only secure for a small
  number of signatures and intended to be used with first (or first few)
  signatures from each signing device the key is used with. The second key is
  secure for a much larger number of signatures (effectively unlimited in a
  Bitcoin context) and each device falls back to that key after some
  (potentially user chosen) number of signatures from that device. The result is
  that in the common Bitcoin use-case where any given key (of which many can be
  derived from a single seed) only signs a small handful of times, nearly all
  signatures can be < 2.5 KB while still having no effective limit on the total
  number of signatures if a key ends up being reused many times, at the cost of
  the later signatures being ~7.5 KB. SHRIMPS is semi-stateful in that no global
  state must be retained, but each signing device must record a few bits of
  state for each SHRIMPS key it signs with (as little as a single bit if only
  the first signature from each device-key tuple takes advantage of the small
  signature).

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

{% include snippets/recap-ad.md when="2026-04-07 16:30" %}
{% include references.md %}

[topic payjoin]: /en/topics/payjoin/
[topic payjoin fingerprinting]: https://delvingbitcoin.org/t/how-wallet-fingerprints-damage-payjoin-privacy/2354
[c delving ibc hd]: https://delvingbitcoin.org/t/compact-isogeny-pqc-can-replace-hd-wallets-key-tweaking-silent-payments/2324
[rr ml gsr bips]: https://groups.google.com/g/bitcoindev/c/T8k47suwuOM
[news374 varops]: /en/newsletters/2025/10/03/#first-bip
[news374 c2]: /en/newsletters/2025/10/03/#second-bip
[jn delving shrimps]: https://delvingbitcoin.org/t/shrimps-2-5-kb-post-quantum-signatures-across-multiple-stateful-devices/2355
[news383 sphincs]: /en/newsletters/2025/12/05/#slh-dsa-sphincs-post-quantum-signature-optimizations
[news391 shrincs]: /en/newsletters/2026/02/06/#shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups
[wallet bip ml]: https://groups.google.com/g/bitcoindev/c/ylPeOnEIhO8
