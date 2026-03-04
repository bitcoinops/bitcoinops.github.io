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

FIXME:bitschmidty

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
