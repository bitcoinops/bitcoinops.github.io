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

{% include snippets/recap-ad.md when="2026-03-10 17:30" %}
{% include references.md %}
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
