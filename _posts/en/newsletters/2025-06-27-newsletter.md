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

- [Is there any way to block Bitcoin Knots nodes as my peers?]({{bse}}127456)
  Vojtěch Strnad provides an approach to blocking peers based on user-agent strings
  using two Bitcoin Core RPCs but discourages such an approach and points to a
  related [Bitcoin Core GitHub issue][Bitcoin Core #30036] with similar discouragement.

- [What does OP_CAT do with integers?]({{bse}}127436)
  Pieter Wuille explains that Bitcoin Script stack elements do not contain data
  type information and different opcodes interpret the stack element's bytes in
  different ways.

- [Async Block Relaying With Compact Block Relay (BIP152)]({{bse}}127420)
  User bca-0353f40e outlines Bitcoin Core's handling of [compact blocks][topic
  compact block relay] and estimates the impact of missing transactions on block
  propagation.

- [Why is attacker revenue in selfish mining disproportional to its hash-power?]({{bse}}53030)
  Antoine Poinsot follows up on this and [another]({{bse}}125682) older [selfish
  mining][topic selfish mining] question, pointing out, "The difficulty
  adjustment does not take stale blocks into account, which means that
  decreasing competing miners' effective hashrate increases a miner's profits
  (on a long enough time scale) as much as increasing his own" (see [Newsletter
  #358][news358 selfish mining]).

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

- [Bitcoin Core #31981][] adds a `checkBlock` method to the inter-process
  communication (IPC) `Mining` interface (see Newsletter [#310][news310 ipc])
  that performs the same validity checks as the `getblocktemplate` RPC in
  `proposal` mode. This enables mining pools using [Stratum v2][topic pooled
  mining] to validate block templates provided by miners via the faster IPC
  interface, rather than serialising up to 4 MB of JSON through RPC. The
  proof-of-work and merkle root checks can be disabled in the options.

- [Eclair #3109][] extends its [attributable failures][topic attributable failures] support (see Newsletter
  [#356][news356 failures]) to [trampoline payments][topic trampoline payments].
  A trampoline node now decrypts and stores the part of the attribution payload
  intended for it and prepares the remaining blob for the next trampoline hop.
  This PR does not implement the relay of the attribution data for trampoline
  nodes, which is expected in a follow-up PR.

- [LND #9950][] adds a new `include_auth_proof` flag to the `DescribeGraph`,
  `GetNodeInfo` and `GetChanInfo` RPCs and to their corresponding `lncli`
  commands. Including this flag returns the [channel announcement][topic channel
  announcements] signatures, allowing validation of channel details
  by third-party software.

- [LDK #3868][] reduces the precision of the [HTLC][topic htlc] hold time for
  [attributable failure][topic attributable failures] (see Newsletter [#349][news349 attributable]) payloads
  from 1-millisecond to 100-millisecond units, to mitigate timing-fingerprint
  leaks. This aligns LDK with the latest updates to the [BOLTs #1044][] draft.

- [LDK #3873][] raises the delay for forgetting a Short Channel Identifier
  (SCID) after its funding output is spent from 12 to 144 blocks to allow for
  the propagation of a [splice][topic splicing] update. This is double the
  72-block delay introduced in [BOLTs #1270][] that was implemented by Eclair
  (see Newsletter [#359][news359 eclair]). This PR also implements additional
  changes to the `splice_locked` message exchange process.

- [Libsecp256k1 #1678][] adds a `secp256k1_objs` CMake interface library that
  exposes all the library’s object files to allow parent projects, such as
  Bitcoin Core’s planned [libbitcoinkernel][libbitcoinkernel project], to link
  those objects directly into their own static libraries. This solves the
  problem of CMake lacking a native mechanism to link static libraries into
  another and spares downstream users from providing their own `libsecp256k1`
  binary.

- [BIPs #1803][] clarifies [BIP380][]’s [descriptor][topic descriptors] grammar
  by allowing all common hardened-path markers, while [#1871][bips #1871],
  [#1867][bips #1867], and [#1866][bips #1866] refine [BIP390][]’s
  [MuSig2][topic musig] descriptors by tightening key path rules, permitting
  repeated participant keys, and explicitly restricting multipath child
  derivations.

{% include snippets/recap-ad.md when="2025-07-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31981,3109,9950,3868,3873,1678,1803,1871,1867,1866,30036,1044,1270" %}
[bitcoin core 28.2]: https://bitcoincore.org/bin/bitcoin-core-28.2/
[brozzoni addr]: https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/
[chow hard]: https://mailing-list.bitcoindevs.xyz/bitcoindev/848d3d4b-94a5-4e7c-b178-62cf5015b65f@achow101.com/T/#u
[news358 selfish mining]: /en/newsletters/2025/06/13/#calculating-the-selfish-mining-danger-threshold
[news310 ipc]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news356 failures]: /en/newsletters/2025/05/30/#eclair-3065
[news349 attributable]: /en/newsletters/2025/04/11/#ldk-2256
[news359 eclair]: /en/newsletters/2025/06/20/#eclair-3110
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
