---
title: 'Bitcoin Optech Newsletter #390'
permalink: /en/newsletters/2026/01/30/
name: 2026-01-30-newsletter
slug: 2026-01-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a more efficient approach to garbled
circuits and links to an LN-Symmetry update. Also included are our
regular sections with selected questions and answers from the Bitcoin
Stack Exchange, announcements of new software releases and release
candidates, and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Argo: a garbled-circuits scheme with more efficient off-chain computation**:
  Robin Linus [posted][delving rl garbled] to Delving Bitcoin about a new
  [paper][iacr le ytl garbled] by Liam Eagen and Ying Tong Lai describing a
  technique that will enable 1000 times more efficient [garbled locks][news359 rl
  garbled]. The new technique uses a MAC (message authentication code) that
  encodes the wires of a garbled circuit as EC (elliptic curve) points. The
  MAC is designed to be homomorphic, enabling many operations within the garbled
  circuit to be represented directly as operations on EC points. The key
  improvement is that Argo works over _arithmetic_ circuits, in contrast to
  binary circuits. With an binary circuit, millions of binary gates are needed to
  represent a curve point multiplication, whereas with this arithmetic
  circuit, you only need a single arithmetic gate. The current
  paper is the first of several pieces needed to apply this technique to
  [BitVM][topic acc]-like constructs on Bitcoin.

- **LN-Symmetry update**: Gregory Sanders [posted][symmetry update]
  an update to Delving Bitcoin about his previous work on [LN-Symmetry][topic eltoo]
  (see [Newsletter #284][news284 ln sym]).

  Sanders rebased his previous proof-of-concept work on the
  [BOLTs specifications][bolts fork] and [CLN implementation][cln fork] to the latest updates.
  The updated implementation now works on [Bitcoin Inquisition][bitcoin inquisition repo]
  29.x on [signet][topic signet] with [TRUC][topic v3 transaction relay],
  [ephemeral dust, P2A][topic ephemeral anchors], and 1p1c [package relay][topic package relay].
  It supports cooperative channel closure, fixes a crash that prevented the node from restarting
  correctly, and expands test coverage. Sanders asked other developers to test his new
  proof-of-concept on signet with Bitcoin Inquisition.

  Sanders also leveraged LLM capabilities to migrate his work from APO to
  OP_TEMPLATEHASH+OP_CSFS+IK (see [Newsletter #365][news365 op proposal]), modified a
  [BOLT draft][bolt th] and created a [CLN-based implementation][cln th].
  However, Sanders added that since OP_TEMPLATEHASH is not yet live on Bitcoin Inquisition,
  this update can only be tested in regtest.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What is stored in dbcache and with what priority?]({{bse}}130376)
  Murch describes the purpose of the `dbcache` data structure as an in-memory
  cache for the a subset of entire UTXO set and goes on to detail its behavior.

- [Can one do a coinjoin in Shielded CSV?]({{bse}}130364)
  Jonas Nick points out that the Shielded CSV protocol doesn't support
  [coinjoins][topic coinjoin] currently, but that [client-side validation][topic
  client-side validation] protocols do not inherently preclude such functionality.

- [In Bitcoin Core, how to use Tor for broadcasting new transactions only?]({{bse}}99442)
  Vasil Dimov follows up to this older question pointing out that with the new
  `privatebroadcast` option (see [Newsletter #388][news388 private broadcast]),
  Bitcoin Core can broadcast transactions through short-lived [privacy
  network][topic anonymity networks] connections.

- [Brassard-Høyer-Tapp (BHT) algorithm and Bitcoin (BIP360)]({{bse}}130431) User
  bca-0353f40e explains that the capability for a collision attack on
  [multisignature][topic multisignature] addresses using the Brassard-Høyer-Tapp
  (BHT) [quantum][topic quantum resistance] algorithm to diminish SHA256
  security would not affect addresses created before the capability.

- [Why does BitHash alternate sha256 and ripmed160?]({{bse}}130373)
  Sjors Provoost outlines the rationale around [BitVM3][topic acc]'s BitHash
  function, a hash function tailored for Bitcoin's Script language.

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

{% include snippets/recap-ad.md when="2026-02-03 17:30" %}
{% include references.md %}
[news359 rl garbled]: /en/newsletters/2025/06/20/#improvements-to-bitvm-style-contracts
[news369 le garbled]: /en/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[delving rl garbled]: https://delvingbitcoin.org/t/argo-a-garbled-circuits-scheme-for-1000x-more-efficient-off-chain-computation/2210
[iacr le ytl garbled]: https://eprint.iacr.org/2026/049.pdf
[symmetry update]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359/17
[news284 ln sym]: /en/newsletters/2024/01/10/#ln-symmetry-research-implementation
[bolts fork]: https://github.com/instagibbs/bolts/tree/eltoo_trucd
[cln fork]: https://github.com/instagibbs/lightning/tree/2026-01-eltoo_rebased
[news365 op proposal]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[news388 private broadcast]: /en/newsletters/2026/01/16/#bitcoin-core-29415
