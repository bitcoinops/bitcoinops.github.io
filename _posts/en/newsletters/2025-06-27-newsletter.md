---
title: 'Bitcoin Optech Newsletter #360'
permalink: /en/newsletters/2025/06/27/
name: 2025-06-27-newsletter
slug: 2025-06-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes research about fingerprinting full
nodes using P2P protocol messages and seeks feedback about possibly
removing support for `H` in BIP32 paths in the BIP380 specification of
descriptors.  Also included are our regular sections summarizing top
questions and answers on the Bitcoin Stack Exchange, announcing new
releases and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **Fingerprinting nodes using `addr` messages:** Daniela Brozzoni
  [posted][brozzoni addr] to Delving Bitcoin about research she conducted with
  developer Naiyoma into identifying the same node on multiple networks
  using the `addr` messages it sends.  Nodes send P2P protocol `addr`
  (address) messages to their peers to advertise other potential nodes,
  allowing peers to find each other using a decentralized gossip system.
  However, Brozzoni and Naiyoma were able to fingerprint individual
  nodes using details from their specific address messages, allowing
  them to identify the same node running on multiple networks (such as
  IPv4 and [Tor][topic anonymity networks]).

  The researchers suggest two possible mitigations: removing timestamps
  from address messages or, if the timestamps are kept, randomizing them
  slightly to make them less specific to particular nodes.

- **Does any software use `H` in descriptors?** Ava Chow [posted][chow hard] to
  the Bitcoin-Dev mailing list to ask whether any software generates
  descriptors using uppercase-H to indicate a hardened [BIP32][topic
  bip32] key derivation step.  If not, the [BIP380][] specification of
  [output script descriptors][topic descriptors] may be modified to only
  allow lowercase-h and `'` to be used to indicate hardening.  Chow
  notes that, although BIP32 allows uppercase-H, the BIP380
  specification previously included a test that forbids using uppercase-H
  and that Bitcoin Core currently does not accept uppercase-H.

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

- [Bitcoin Core 28.2][] is a maintenance release for the previous
  release series of the predominant full node implementation.  It
  contains multiple bug fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31981][] Add checkBlock() to Mining interface

- [Eclair #3109][]  Prepare attribution data for trampoline payments

- [LND #9950][] starius/describegraph-authproofs2

- [LDK #3868][] joostjager/coarse-hold-times

- [LDK #3873][] jkczyz/2025-06-splice-locked-fixes

- [Libsecp256k1 #1678][] cmake: add a helper for linking into static libs

- [BIPs #1803][], [#1871][bips #1871], [#1867][bips #1867], and
  [#1866][bips #1866] quapka/hardened-indicator achow101/desc-clarifications achow101/390-clarifications rkrux/musig-multipath

{% include snippets/recap-ad.md when="2025-07-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31981,3109,9950,3868,3873,1678,1803,1871,1867,1866" %}
[bitcoin core 28.2]: https://bitcoincore.org/bin/bitcoin-core-28.2/
[brozzoni addr]: https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/
[chow hard]: https://mailing-list.bitcoindevs.xyz/bitcoindev/848d3d4b-94a5-4e7c-b178-62cf5015b65f@achow101.com/T/#u
