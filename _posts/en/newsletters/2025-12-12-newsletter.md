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
  avoid denial of service and loss of funds. {% assign timestamp="0:59" %}

- **A virtualized secure enclave for hardware signing devices:** Salvatoshi
  [posted][vanadium post] to Delving Bitcoin about [Vanadium][vanadium github],
  a virtualized secure enclave for hardware signing devices. Vanadium is a
  RISC-V virtual machine, designed to run arbitrary applications, called "V-Apps",
  in an embedded secure element, outsourcing memory and storage needs to an
  untrusted host. According to Salvatoshi, Vanadium's aim is to abstract
  the complexities of embedded development, such as limited RAM and storage,
  vendor-specific SDKs, slow development cycles, and debugging, to make
  innovation in self-custody faster, more open, and standardized.

  Salvatoshi notes that from a performance perspective, the virtual machine only
  runs the application business logic, while the heavy operations (i.e.
  cryptography) run natively via ECALLs.

  While the threat model is the same as existing hardware wallets, Salvatoshi
  points out that this approach allows memory access-pattern leakage, where the host
  can observe which code and data pages are accessed and when. This is
  particularly important for cryptography developers.

  The project is still not deemed production-ready, and there are some known
  limitations, such as performance and UX. However, Salvatoshi asked developers
  to try it out and provide feedback to lay out the roadmap for
  the project. {% assign timestamp="21:11" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Interactive transaction visualization tool:**
  [RawBit][rawbit delving] is a [web-based][rawbit website], [open-source][rawbit github]
  transaction visualization tool. It features interactive lessons on a variety
  of transaction types with plans for additional lessons on taproot,
  [PSBTs][topic psbt],
  [HTLCs][topic htlc], [coinjoins][topic coinjoin], and covenant proposals. {% assign timestamp="37:16" %}

- **BlueWallet v7.2.2 released:**
  BlueWallet's [v7.2.2 release][bluewallet v7.2.2] adds support for
  [taproot][topic taproot] wallets, including sending, receiving, watch-only,
  coin control, and hardware signing device features. {% assign timestamp="38:20" %}

- **Stratum v2 updates:**
  Stratum v2 [v1.6.0][sv2 v1.6.0] rearchitects the Stratum v2 repositories,
  adding an [sv2-apps repository and v.01 release][sv2-apps] supporting direct
  communication with unmodified Bitcoin Core 30.0 nodes using IPC (see
  [Newsletter #369][news369 ipc]). The releases also include web tools
  for [miners][sv2 wizard miners] and [developers][sv2 wizard devs] for testing,
  among other features. {% assign timestamp="38:42" %}

- **Auradine announces Stratum v2 support:**
  Auradine [announced][auradine tweet] support for Stratum v2 features in their miners. {% assign timestamp="40:18" %}

- **LDK Node 0.7.0 released:**
  [LDK Node 0.7.0][ldk node blog] adds experimental support for [splicing][topic
  splicing] and support for serving and paying static invoices for [async payments][topic
  async payments], among other features and bugfixes. {% assign timestamp="41:58" %}

- **BIP-329 Python Library 1.0.0 release:**
  [BIP-329 Python Library][news273 329 lib] version [1.0.0][bip329 python 1.0.0]
  supports [BIP329][]'s additional fields, including type validation and test coverage. {% assign timestamp="43:30" %}

- **Bitcoin Safe 1.6.0 released:**
  The [1.6.0 release][bitcoin safe 1.6.0] adds support for [compact block
  filters][topic compact block filters] and [reproducible builds][topic reproducible builds]. {% assign timestamp="44:34" %}

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
  to configure the public key correctly". {% assign timestamp="45:12" %}

- [Why do different implementations produce different DER signatures for the same private key and hash?]({{bse}}129270)
  User dave_thompson_085 explains that different implementations can produce
  different valid ECDSA signatures because the algorithm is inherently
  randomized unless RFC 6979 deterministic nonce generation is used. {% assign timestamp="45:58" %}

- [Why is the miniscript `after` value limited at 0x80000000?]({{bse}}129253)
  Murch answers that [miniscript][topic miniscript] limits `after(n)` time-based
  CLTV [timelocks][topic timelocks] to a maximum of 2<sup>31</sup> - 1
  (representing a time in the year 2038) because Bitcoin Script integers are
  4-byte *signed* values, while block-height based locktimes can exceed the 2038
  threshold. {% assign timestamp="49:27" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33528][] prevents the wallet from spending outputs of
  unconfirmed [TRUC][topic v3 transaction relay] transactions with an
  unconfirmed ancestor, to comply with TRUC policy limits. Previously, the
  wallet could create such transactions, but they were rejected when
  broadcast. {% assign timestamp="53:12" %}

- [Bitcoin Core #33723][] removes `dnsseed.bitcoin.dashjr-list-of-p2p-nodes.us`
  from the list of DNS seeds. Maintainers found that it was the only seed
  omitting newer Bitcoin Core versions (29 and 30), violating the policy stating
  "seed results must consist exclusively of fairly selected and functioning
  Bitcoin nodes from the public network”. {% assign timestamp="54:17" %}

- [Bitcoin Core #33993][] updates the help text for the `stopatheight` option,
  clarifying that the target height specified to stop syncing is only an
  estimate and that blocks after that height may still be processed during
  shutdown. {% assign timestamp="56:35" %}

- [Bitcoin Core #33553][] adds a warning message indicating potential database
  corruption when headers are received for blocks that were previously marked as
  invalid. This helps users realize they might be stuck in a header sync loop.
  This PR also enables a fork detection warning message that was previously
  disabled for IBD. {% assign timestamp="59:54" %}

- [Eclair #3220][] extends the existing `spendFromChannelAddress` helper to
  [taproot channels][topic simple taproot channels], adding a
  `spendfromtaprootchanneladdress` endpoint that allows users to cooperatively
  spend UTXOs accidentally sent to [taproot][topic taproot] channel funding
  addresses, with [MuSig2][topic musig] signatures. {% assign timestamp="1:01:52" %}

- [LDK #4231][] stops force-closing [zero-conf channels][topic zero-conf
  channels] when a block reorganization unconfirms the channel funding
  transaction. LDK has a mechanism to force-close locked channels that become
  unconfirmed due to the risk of double-spending. However, the trust model is
  different for zero-conf channels. The SCID change is also now properly handled
  in this edge case. {% assign timestamp="1:02:48" %}

- [LND #10396][] tightens the router’s heuristic for detecting LSP-assisted
  nodes: invoices with a public destination node or whose route hint destination
  hops are all private are now treated as normal nodes, while those with a
  private destination and at least one public destination hop are classified as
  LSP-backed. Previously, the looser heuristic could misclassify nodes as
  LSP-assisted, resulting in more probing failures. Now, when an LSP-assisted
  node is detected, LND probes up to three candidate LSPs and uses the
  worst-case route (highest fees and CLTV) to provide conservative fee
  estimates. {% assign timestamp="1:05:40" %}

- [BTCPay Server #7022][] introduces an API for the `Subscriptions` feature (see
  [Newsletter #379][news379 btcpay]), enabling merchants to create and manage
  offerings, plans, subscribers, and checkouts. About a dozen endpoints have been
  added for each specific operation. {% assign timestamp="1:08:26" %}

- [Rust Bitcoin #5379][] adds a method for constructing [Pay-to-Anchor
  (P2A)][topic ephemeral anchors] addresses, to complement the existing method
  for verifying P2A addresses. {% assign timestamp="1:09:32" %}

- [BIPs #2050][] updates [BIP390][], which specifies [MuSig2][topic musig]
  descriptors, to allow `musig()` key expressions inside of a `rawtr()` in
  addition to the already allowed `tr()`, aligning the description with existing
  test vectors and Bitcoin Core’s descriptor implementation. {% assign timestamp="1:10:06" %}

## Happy holidays!

This is Bitcoin Optech's final regular newsletter of the year.  On
Friday, December 19th, we'll publish our eighth annual year-in-review
newsletter.  Regular publication will resume on Friday, January 2nd.

{% include snippets/recap-ad.md when="2025-12-16 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33528,33723,33993,33553,3220,4231,10396,7022,5379,2050" %}
[morehouse delving]: https://delvingbitcoin.org/t/disclosure-critical-vulnerabilities-fixed-in-lnd-0-19-0/2145
[lnd vln1]: https://morehouse.github.io/lightning/lnd-infinite-inbox-dos/
[lnd vln2]: https://morehouse.github.io/lightning/lnd-excessive-failback-exploit-2/
[lnd vln3]: https://morehouse.github.io/lightning/lnd-replacement-stalling-attack/
[lnd version]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[morehouse failback bug]: /en/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[vanadium post]: https://delvingbitcoin.org/t/vanadium-a-virtualized-secure-enclave-for-hardware-signing-devices/2142
[vanadium github]: https://github.com/LedgerHQ/vanadium
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
[news379 btcpay]: /en/newsletters/2025/11/07/#btcpay-server-6922