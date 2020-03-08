---
title: 'Bitcoin Optech Newsletter #88'
permalink: /en/newsletters/2020/03/11/
name: 2020-03-11-newsletter
slug: 2020-03-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a description of methods for preventing
hardware wallets from leaking private information through transaction
signatures and provides an update on the BIP322 generic signmessage
protocol.  Also included are our regular sections about new releases and
notable merges of popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Exfiltration resistant nonce protocols:** Pieter Wuille sent an
  [email][wuille overview] to the Bitcoin-Dev mailing list providing an
  overview of techniques that can prevent a hardware wallet or other
  offline signing device from communicating secret information to a
  third party by biasing the nonces in the ECDSA or schnorr signatures it creates.
  The email is clearly written and packed with information.  Anyone with
  an interest in secure use of external signers should consider reading
  it.

- **BIP322 generic `signmessage`---progress or perish:** [BIP322][] author
  Karl-Johan Alm noted that his PR to add support for the [generic
  `signmessage` protocol][topic generic signmessage] has not seen any
  progress towards getting merged for the past several months.  He's
  [seeking feedback][alm feedback]---including "unfiltered
  criticism"---about whether to take a different approach or to simply
  abandon the proposal.  As we've mentioned [previously][segwit
  signmessage], there is currently no widely adopted way for wallets to
  create and verify signed messages for anything besides legacy P2PKH
  addresses.  If wallet developers want to enable this capability for
  P2SH, P2WPKH, P2WSH, and (if taproot is activated) P2TR addresses,
  they are recommended to review Alm's email and provide feedback on
  their preferred path forward.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.19.1][] was released with several bug fixes; see the
  [release notes][bitcoin core 0.19.1 notes] for details.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #1323][] Wumbo support FIXME:jnewbery

{% include references.md %}
{% include linkers/issues.md issues="1323" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[bitcoin core 0.19.1 notes]: https://bitcoincore.org/en/releases/0.19.1/
[wuille overview]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017667.html
[alm feedback]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017668.html
[segwit signmessage]: /en/bech32-sending-support/#message-signing-support
