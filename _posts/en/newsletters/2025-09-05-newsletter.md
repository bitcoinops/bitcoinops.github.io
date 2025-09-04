---
title: 'Bitcoin Optech Newsletter #370'
permalink: /en/newsletters/2025/09/05/
name: 2025-09-05-newsletter
slug: 2025-09-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections summarizing
discussion about changing Bitcoin's consensus rules, announcing new
release and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

_No significant news this week was found in any of our [sources][optech sources]._

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Details about the design of Simplicity:** Russell O'Connor made
  three posts ([1][sim1], [2][sim2], [3][sim3]) so far to Delving
  Bitcoin about "the philosophy and design of the [Simplicity
  language][topic simplicity]."  The posts examine "the three major
  forms of composition for transforming basic operations into complex
  operations," "Simplicity’s type system, combinators, and basic
  expressions," and "how to build logical operations starting from bits
  [...up to...] cryptographic operations, such as SHA-256 and Schnorr
  signature validation, using just our computational Simplicity
  combinators."

  The most recent post indicates further entries in the series are
  expected.

- **Draft BIP for adding elliptic curve operations to tapscript:**
  Olaoluwa Osuntokun [posted][osuntokun ec] to the Bitcoin-Dev mailing
  list a link to a [draft BIP][osuntokun bip] for adding several opcodes
  to [tapscript][topic tapscript] that will allow elliptic curve
  operations to be performed on the script evaluation stack.  The
  opcodes are intended to be used in combination with introspection
  opcodes to create or enhance [covenant][topic covenants] protocols in
  addition to other advances.

  Jeremy Rubin [replied][rubin ec1] to suggest additional opcodes to
  enable additional features, as well as [other opcodes][rubin ec2] that
  would make it more convenient to use some features provided by the
  base proposal.

- **Draft BIP for OP_TWEAKADD:** Jeremy Rubin [posted][rubin ta1] to the
  Bitcoin-Dev mailing list a link a [draft BIP][rubin bip] to add
  `OP_TWEAKADD` to [tapscript][topic tapscript].  He separately
  [posted][rubin ta2] notable examples of scripts enabled by the
  addition of the opcode, which include a script to reveal a
  [taproot][topic taproot] tweak, proof of order of signing a
  transaction (e.g., Alice must have signed before Bob), and [signing
  delegation][topic signer delegation].

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning v25.09][] is a release of a new major
  version of this popular LN node implementation.  It adds support to
  the `xpay` command for paying [BIP353][] addresses and simple
  [offers][topic offers], offers improved bookkeeper support, provides
  better plugin dependency management, and includes other new features
  and bug fixes.

- [Bitcoin Core 29.1rc2][] is a release candidate for a maintenance
  version of the predominant full node software.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [LDK #3726][] Improve privacy for Blinded Message Paths using Dummy Hops

- [LDK #4019][] Integrate Splicing with Quiescence

- [LND #9455][] discovery+lnwire: add support for DNS host name in NodeAnnouncement msg

- [LND #10103][] Rate limit outgoing gossip bandwidth by peer

- [HWI #795][] Fix CI <!-- don't need to mention the CI changes, but please do mention the new hardware supported by this merge -harding -->

{% include snippets/recap-ad.md when="2025-09-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3726,4019,9455,10103,795" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[sim1]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[sim2]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[sim3]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[osuntokun ec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-Cwj=5vJgBfDqZGtvmoYPMrpKYFAYHRb_EqJ5i0PG0cA@mail.gmail.com/
[osuntokun bip]: https://github.com/bitcoin/bips/pull/1945
[rubin ec1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f118d974-8fd5-42b8-9105-57e215d8a14an@googlegroups.com/
[rubin ec2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1c2539ba-d937-4a0f-b50a-5b16809322a8n@googlegroups.com/
[rubin ta1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bc9ff794-b11e-47bc-8840-55b2bae22cf0n@googlegroups.com/
[rubin ta2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/c51c489c-9417-4a60-b642-f819ccb07b15n@googlegroups.com/
[rubin bip]: https://github.com/bitcoin/bips/pull/1944
