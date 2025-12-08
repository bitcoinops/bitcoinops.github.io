---
title: 'Bitcoin Optech Newsletter #384'
permalink: /en/newsletters/2025/12/12/
name: 2025-12-12-newsletter
slug: 2025-12-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter discloses vulnerabilities in LND and describes a project
for running a virtual machine in an embedded secure element. Also included are
our regular sections describing changes to services and client software,
summarizing popular questions and answers of the Bitcoin Stack Exchange, and
examining recent changes to popular Bitcoin infrastructure software.

## News

- **Critical vulnerabilities fixed in LND 0.19.0:** Matt Morehouse
  [posted][morehouse delving] to Delving Bitcoin about critical vulnerabilities
  fixed in LND 0.19.0. In this disclosure, there are three vulnerabilities
  mentioned including one denial-of-service (DoS) and two theft-of-funds.

  - *Message processing out-of-memory DoS vulnerability:* This [DoS vulnerability][lnd vln1] took
    advantage of LND allowing as many peers as there were available file
    descriptors. The attacker could open multiple connections to the victum
    and spam 64 KB `query_short_channel_ids` messages while keeping the
    connection open until LND ran out of memory. The mitigation for this
    vulnerability was implemented in LND 0.19.0 on March 12th, 2025.

  - *Loss of funds due to new excessive failback vulnerability:* [This attack][lnd vln2] is a variant of the [excessive
    failback bug][morehouse failback bug], and while the original fix for the
    failback bug was made in LND 0.18.0, a minor variant remained when the
    channel was force closed using LND’s commitment instead of the attacker’s.
    The mitigation for this vulnerability was implemented in LND 0.19.0 on March
    20th, 2025.

  - *Loss of funds vulnerability in HTLC sweeping:* This [theft-of-funds vulnerability][lnd vln3] took
    advantage of weaknesses in LND's sweeper system, which enabled an attacker
    to stall LND's attempts at claiming expired HTLC's on chain. After stalling
    for 80 blocks then the attacker could steal essentially the whole channel
    balance.

  Morehouse urges users to upgrade to [LND 0.19.0][lnd version] or higher to
  avoid denial of service and loss of funds.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Interactive transaction visualization tool:**
  [RawBit][rawbit delving] is a [web-based][rawbit website], [open-source][rawbit github]
  transaction visualization tool. It features interactive lessons on a variety
  of transaction types with plans for additional lessons on taproot,
  [PSBTs][topic psbt],
  [HTLCs][topic htlc], [coinjoins][topic coinjoin], and covenant proposals.

- **BlueWallet v7.2.2 released:**
  BlueWallet's [v7.2.2 release][bluewallet v7.2.2] adds support for
  [taproot][topic taproot] wallets, including sending, receiving, watch-only,
  coin control, and hardware signing device features.

- **Stratum v2 updates:**
  Stratum v2 [v1.6.0][sv2 v1.6.0] rearchitects the Stratum v2 repositories,
  adding an [sv2-apps repository and v.01 release][sv2-apps] supporting direct
  communication with unmodified Bitcoin Core 30.0 nodes using IPC (see
  [Newsletter #369][news369 ipc]). The releases also include web tools
  for [miners][sv2 wizard miners] and [developers][sv2 wizard devs] for testing,
  among other features.

- **Auradine announces Stratum v2 support:**
  Auradine [announced][auradine tweet] support for Stratum v2 features in their miners.

- **LDK Node 0.7.0 released:**
  [LDK Node 0.7.0][ldk node blog] adds experimental support for [splicing][topic
  splicing] and support for serving and paying static invoices for [async payments][topic
  async payments], among other features and bugfixes.

- **BIP-329 Python Library 1.0.0 release:**
  [BIP-329 Python Library][news273 329 lib] version [1.0.0][bip329 python 1.0.0]
  supports [BIP329][]'s additional fields, including type validation and test coverage.

- **Bitcoin Safe 1.6.0 released:**
  The [1.6.0 release][bitcoin safe 1.6.0] adds support for [compact block
  filters][topic compact block filters] and [reproducible builds][topic reproducible builds].

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Does a clearnet connection to my Lightning node require a TLS certificate?]({{bse}}129303)
  Pieter Wuille points out that in LN, users specify a public key as part of
  connecting to a peer so "There is no need for a trusted third party to attest
  to the correctness of that public key, because it is the user's responsibility
  to configure the public key correctly".

- [Why do different implementations produce different DER signatures for the same private key and hash?]({{bse}}129270)
  User dave_thompson_085 explains that different implementations can produce
  different valid ECDSA signatures because the algorithm is inherently
  randomized unless RFC 6979 deterministic nonce generation is used.

- [Why is the miniscript `after` value limited at 0x80000000?]({{bse}}129253)
  Murch answers that [miniscript][topic miniscript] limits `after(n)` time-based
  CLTV [timelocks][topic timelocks] to a maximum of 2<sup>31</sup> - 1
  (representing a time in the year 2038) because Bitcoin Script integers are
  4-byte *signed* values, while block-height based locktimes can exceed the 2038
  threshold.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

## Happy holidays!

This is Bitcoin Optech's final regular newsletter of the year.  On
Friday, December 19th, we'll publish our eighth annual year-in-review
newsletter.  Regular publication will resume on Friday, January 2nd.

{% include snippets/recap-ad.md when="2025-12-09 17:30" %}
{% include references.md %}
[morehouse delving]: https://delvingbitcoin.org/t/disclosure-critical-vulnerabilities-fixed-in-lnd-0-19-0/2145
[lnd vln1]: https://morehouse.github.io/lightning/lnd-infinite-inbox-dos/
[lnd vln2]: https://morehouse.github.io/lightning/lnd-excessive-failback-exploit-2/
[lnd vln3]: https://morehouse.github.io/lightning/lnd-replacement-stalling-attack/
[lnd version]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[morehouse failback bug]: /en/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[rawbit delving]: https://delvingbitcoin.org/t/raw-it-the-visual-raw-transaction-builder-script-debugger/2119
[rawbit github]: https://github.com/rawBit-io/rawbit
[rawbit website]: https://rawbit.io/
[bluewallet v7.2.2]: https://github.com/BlueWallet/BlueWallet/releases/tag/v7.2.2
[sv2 v1.6.0]: https://github.com/stratum-mining/stratum/releases/tag/v1.6.0
[sv2-apps]: https://github.com/stratum-mining/sv2-apps/releases/tag/v0.1.0
[news369 ipc]: /en/newsletters/2025/08/29/#bitcoin-core-31802
[sv2 wizard miners]: https://stratumprotocol.org/get-started
[sv2 wizard devs]: https://stratumprotocol.org/developers
[auradine tweet]: https://x.com/Auradine_Inc/status/1991159535864803665?s=20
[ldk node blog]: https://newreleases.io/project/github/lightningdevkit/ldk-node/release/v0.7.0
[news273 329 lib]: /en/newsletters/2023/10/18/#bip-329-python-library-released
[bip329 python 1.0.0]: https://github.com/Labelbase/python-bip329/releases/tag/1.0.0
[bitcoin safe 1.6.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.6.0
