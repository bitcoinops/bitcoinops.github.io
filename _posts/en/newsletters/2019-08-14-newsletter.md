---
title: 'Bitcoin Optech Newsletter #59'
permalink: /en/newsletters/2019/08/14/
name: 2019-08-14-newsletter
slug: 2019-08-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter briefly describes two discussions on the
Bitcoin-Dev mailing list, one about Bitcoin vaults and one about
reducing the size of public keys used in taproot.  Also included are our
regular sections about bech32 sending support and notable changes in
popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **[Optech schnorr/taproot workshops][taproot-workshop]:**  Optech is hosting
  workshops in San Francisco (September 24) and New York (September 27) on
  schnorr signatures and taproot. Engineers will learn about these technologies
  and how they apply to their own products and services, build schnorr and
  taproot wallet implementations, and have an opportunity to take part in the
  feedback process for these proposed changes to the Bitcoin protocol.

  Member companies should [send us an email][optech email] to reserve spots for
  your engineers.

## News

- **Bitcoin vaults without covenants:** In a [post][vault1] to the
  Bitcoin-Dev mailing list, Bryan Bishop describes how pre-signed
  transactions paid to scripts using `OP_CHECKSEQUENCEVERIFY` (CSV)
  could allow users to detect and block attempts to steal their money by
  a thief who had gained access to the user's private keys, a capability
  previously referred to as providing *Bitcoin vaults.*  After
  describing at length both the basic protocol and several possible
  variations, Bishop made a second [post][vault2] describing one case
  where it would still be possible to steal from the vaults, although he
  also suggests a partial mitigation that would limit losses to a
  percentage of the protected funds and he requests proposals for the
  smallest necessary change to Bitcoin's consensus rules to fully
  mitigate the risk.

- **Proposed change to schnorr pubkeys:** Pieter Wuille started a
  [thread][pubkey32] on the Bitcoin-Dev mailing list requesting feedback
  on a proposal to switch [bip-schnorr][] and [bip-taproot][] to using
  32-byte public keys instead of the 33-byte compressed pubkeys
  previously proposed.  Compressed pubkeys include a bit to indicate to
  verifiers whether their Y coordinate is an even or odd number.
  This can be combined with an algorithm that allows verifiers to
  determine two possible Y coordinates for the full pubkey from the
  32-byte X coordinate contained in the compressed pubkey.  One of these
  coordinates is odd and one is even, so the oddness bit allows
  verifiers to pick the correct coordinate, preventing them from having
  to try both combinations during verification (which would slow down
  verification in general and eliminate any benefits from
  batch signature verification).  Several
  <span title="voodoo">mathematical</span> schemes have been proposed
  that would produce signatures for keys whose Y coordinates could be
  inferred without the additional bit (which is currently the only data
  contained within a prefix byte).  This would save one vbyte for each
  payment to a taproot output (potentially thousands of vbytes per block
  if most users migrate to taproot) and 0.25 vbytes for each public key
  included in a script-path spend.  For previous discussion about
  32-byte pubkeys, please see [Newsletter #48][oddness byte].

## Bech32 sending support

*Week 22 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% include specials/bech32/22-priority.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #2858][] limits the maximum number of pending HTLCs in
  each direction to 30 (down from the maximum 483 allowed by the LN
  specification) and makes the value configurable with a
  `--max-concurrent-htlcs` option.  The fewer the number of pending
  HTLCs, the smaller the byte size and fee cost of a unilateral close transaction
  because settling each HTLC produces a separate output that can only be
  spent by a fairly large input.

{% include linkers/issues.md issues="2858" %}
[bech32 series]: /en/bech32-sending-support/
[oddness byte]: /en/newsletters/2019/05/29/#move-the-oddness-byte
[vault1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017229.html
[vault2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017231.html
[pubkey32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017247.html
[pr pubkey32]: https://github.com/sipa/bips/pull/52
[taproot-workshop]: /en/workshops#taproot-workshop
