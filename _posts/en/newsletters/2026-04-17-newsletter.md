---
title: 'Bitcoin Optech Newsletter #401'
permalink: /en/newsletters/2026/04/17/
name: 2026-04-17-newsletter
slug: 2026-04-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an idea for nested MuSig2 Lightning nodes and
summarizes a project formally verifying secp256k1's modular scalar
multiplication. Also included are our regular sections describing recent changes
to services and client software, announcing new releases and release candidates,
and summarizing notable changes to popular Bitcoin infrastructure software.

## News

- **Discussion of using nested MuSig2 in the Lightning Network**: ZmnSCPxj [posted][kofn post del]
  to Delving Bitcoin about the idea to create k-of-n multisignature Lightning
  nodes by leveraging nested MuSig2 as discussed in a recent
  [paper][nmusig2 paper].

  According to ZmnSCPxj, the need for a k-of-n signature scheme in Lightning
  derives from large holders wanting to provide their liquidity to the network
  in exchange for fees. Those large holders may need strong guarantees on the
  safety of their funds, which a single key may not grant. Instead, a k-of-n
  scheme would provide the required security as long as less than k keys are
  compromised.

  As of today, the BOLTs specifications do not allow for a secure way
  to implement a k-of-n multisig scheme, with the main obstacle being the revocation
  key. According to the BOLTs, the revocation key is created using a
  shachain, which, due to its characteristics, is not suitable for use with k-of-n
  multisig schemes.

  ZmnSCPxj proposes a modification to the BOLTs specifications to make it
  optional for nodes to perform shachain validation of revocation keys from channel
  parties by signaling a new pair of feature bits, named `no_more_shachains`, in
  both `globalfeatures` and `localfeatures`. An odd bit would signal that the node
  will not perform shachain validation on the counterparty, while still providing
  shachain-valid revocation keys to keep compatibility with legacy nodes. An
  even bit would signal that the node will neither validate nor provide
  shachain-valid revocation keys. The former bit would be used by gateway nodes,
  as ZmnSCPxj defines them, which would connect the rest of the network to the
  k-of-n nodes, those featuring the even bit.

  Finally, ZmnSCPxj emphasizes how this proposal would present a major trade-off,
  namely the storage requirements for revocation keys. In fact, nodes would be
  required to store individual revocation keys instead of the compact shachain
  representation, effectively tripling the on-disk space needed.


## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Coldcard 6.5.0 adds MuSig2 and miniscript:**
  Coldcard [6.5.0][coldcard 6.5.0] adds [MuSig2][topic musig] signing support,
  [BIP322][] proof of reserve capabilities, and additional [miniscript][topic
  miniscript] and [taproot][topic taproot] features including [tapscript][topic
  tapscript] support for up to eight leaves.

- **Frigate 1.4.0 released:**
  Frigate [v1.4.0][frigate blog], an experimental Electrum server for [silent
  payments][topic silent payments] scanning (see [Newsletter #389][news389
  frigate]), now uses the UltrafastSecp256k1 library in conjunction with modern
  GPU computation to reduce scanning time for a few months of blocks from an
  hour to half a second.

- **Bitcoin Backbone updates:**
  Bitcoin Backbone [released][backbone ml 1] multiple [updates][backbone ml 2]
  adding [BIP152][] [compact block][topic compact block relay] support,
  transaction and address management improvements, and multiprocess interface
  groundwork (see [Newsletter #368][news368 backbone]). The announcement also
  proposes Bitcoin Kernel API extensions for standalone header verification and
  transaction validation.

- **Utreexod 0.5 released:**
  Utreexod [v0.5][utreexod blog] introduces IBD using [SwiftSync][news349
  swiftsync], reducing extra data downloaded from 1.4TB to 200GB. The release
  uses Floresta 0.9, a minimal [utreexo][topic utreexo] node implementation with
  an integrated Electrum server that uses assumeutreexo for fast setup.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects. Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 31.0rc4][] is a release candidate for the next major version
  of the predominant full node implementation. A [testing guide][bcc31 testing]
  is available.

- [Core Lightning 26.04rc3][] is the latest release candidate for the next
  major version of this popular LN node, continuing the splicing updates and
  bug fixes from earlier candidates.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #34401][] extends the `btck_BlockHeader` support added to the
  `libbitcoinkernel` C API (see Newsletters [#380][news380 kernel] and
  [#390][news390 header]) by adding a method to serialize a block
  header into its standard byte encoding. This allows external programs using
  the C API to store, transmit, or compare serialized headers without needing separate serialization code.

- [Bitcoin Core #35032][] stops storing network addresses learned when using the
  `privatebroadcast` option (see [Newsletter #388][news388 private]) with the
  `sendrawtransaction` RPC in `addrman`, Bitcoin Core’s peer address manager. The
  `privatebroadcast` option allows users to broadcast transactions through
  short-lived [Tor][topic anonymity networks] or I2P connections, or through
  the Tor proxy to IPv4/IPv6 peers.

- [Core Lightning #9021][] enables [splicing][topic splicing] by default by
  removing it from experimental status, following the merge of the splicing
  protocol into the BOLTs specification (see [Newsletter #398][news398 splicing]).

- [Core Lightning #9046][] increases the assumed `final_cltv_expiry` (the
  [CLTV expiry delta][topic cltv expiry delta] for the last hop) for [keysend
  payments][topic spontaneous payments] from 22 to 42 blocks to match LDK’s
  value, restoring interoperability.

- [LDK #4515][] switches [zero-fee commitment][topic v3 commitments] channels (see [Newsletter
  #371][news371 0fc]) from the experimental feature bit to the production feature
  bit. Zero-fee commitment channels replace the two [anchor outputs][topic anchor outputs] with
  one shared [Pay-to-Anchor (P2A)][topic ephemeral anchors] output, capped at a
  value of 240 sats.

- [LDK #4558][] applies the existing receiver-side timeout for incomplete
  [multipath payments][topic multipath payments] to [keysend payments][topic
  spontaneous payments]. Previously, incomplete keysend MPPs could remain pending
  until CLTV expiry, tying up [HTLC][topic htlc] slots instead of failing back
  after the normal timeout period.

- [LND #9985][] adds end-to-end support for production [simple taproot
  channels][topic simple taproot channels] with a distinct commitment type
  (`SIMPLE_TAPROOT_FINAL`) and production feature bits 80/81. Production uses
  optimized [tapscripts][topic tapscript] that prefer `OP_CHECKSIGVERIFY` over
  `OP_CHECKSIG`+`OP_DROP`, and adds map-based nonce handling on `revoke_and_ack`
  keyed by funding txid as groundwork for future [splicing][topic splicing].

- [BTCPay Server #7250][] adds [LUD-21][] support by introducing an optional
  unauthenticated endpoint named `verify` that allows external services to verify
  whether a [BOLT11][] invoice created via [LNURL-pay][topic lnurl] has been
  settled.

- [BIPs #2089][] publishes [BIP376][], which defines new [PSBTv2][topic psbt]
  per-input fields to carry the [BIP352][] tweak data needed to sign and spend
  [silent payment][topic silent payments] outputs, plus an optional spend-key
  [BIP32][topic bip32] derivation field compatible with BIP352’s 33-byte
  spend keys. This complements [BIP375][], which specifies how to create silent
  payment outputs using PSBTs (see [Newsletter #337][news337 bip375]).

{% include snippets/recap-ad.md when="2026-04-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34401,35032,9021,9046,4515,4558,9985,7250,2089" %}

[coldcard 6.5.0]: https://coldcard.com/docs/upgrade/#edge-version-650xqx-musig2-miniscript-and-taproot-support
[frigate blog]: https://damus.io/nevent1qqsrg3xsjwpt4d9g05rqy4vkzx5ysdffm40qtxntfr47y3annnfwpzgpp4mhxue69uhkummn9ekx7mqpz3mhxue69uhkummnw3ezummcw3ezuer9wcq3samnwvaz7tmjv4kxz7fwwdhx7un59eek7cmfv9kqz9rhwden5te0wfjkccte9ejxzmt4wvhxjmczyzl85553k5ew3wgc7twfs9yffz3n60sd5pmc346pdaemf363fuywvqcyqqqqqqgmgu9ev
[news389 frigate]: /en/newsletters/2026/01/23/#electrum-server-for-testing-silent-payments
[news368 backbone]: /en/newsletters/2025/08/22/#bitcoin-core-kernel-based-node-announced
[backbone ml 1]: https://groups.google.com/g/bitcoindev/c/D6nhUXx7Gnw/m/q1Bx4vAeAgAJ
[backbone ml 2]: https://groups.google.com/g/bitcoindev/c/ViIOYc76CjU/m/cFOAYKHJAgAJ
[news349 swiftsync]: /en/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download
[utreexod blog]: https://delvingbitcoin.org/t/new-utreexo-releases/2371
[kofn post del]: https://delvingbitcoin.org/t/towards-a-k-of-n-lightning-network-node/2395
[nmusig2 paper]: https://eprint.iacr.org/2026/223
[bitcoin core 31.0rc4]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc4/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[Core Lightning 26.04rc3]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc3
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news390 header]: /en/newsletters/2026/01/30/#bitcoin-core-33822
[news388 private]: /en/newsletters/2026/01/16/#bitcoin-core-29415
[news398 splicing]: /en/newsletters/2026/03/27/#bolts-1160
[news371 0fc]: /en/newsletters/2025/09/12/#ldk-4053
[news337 bip375]: /en/newsletters/2025/01/17/#bips-1687
[BIP376]: https://github.com/bitcoin/bips/blob/master/bip-0376.mediawiki
[LUD-21]: https://github.com/lnurl/luds/blob/luds/21.md
