---
title: 'Bitcoin Optech Newsletter #362'
permalink: /en/newsletters/2025/07/11/
name: 2025-07-11-newsletter
slug: 2025-07-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter briefly describes a new library allowing output
script descriptors to be compressed for use in QR codes.  Also included
are our regular sections summarizing a Bitcoin Core PR Review Club
meeting, announcing new releases and release candidates, and describing
notable changes to popular Bitcoin infrastructure software.

## News

- **Compressed descriptors:** Josh Doman [posted][dorman descom] to
  Delving Bitcoin to announce a [library][descriptor-codec] he's written
  that encodes [output script descriptors][topic descriptors] into a
  binary format that reduces their size by about 40%.  This can be
  especially useful when descriptors are backed up using QR codes.  His
  post goes into the details of the encoding and mentions that he plans
  to incorporate the compression into his encrypted descriptors backup
  library (see [Newsletter #358][news358 descencrypt]).

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/32317#l-37FIXME"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.19.2-beta.rc2][] is a release candidate for a maintenance
  version of this popular LN node.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #8377][] tightens [BOLT11][] invoice parsing
  requirements by mandating that senders not pay an invoice if a
  [payment secret][topic payment secrets] is missing or if a mandatory
  field such as p (payment hash), h (description hash), or s (secret),
  has an incorrect length. These changes are made to align with the
  recent specification updates (see Newsletters [#350][news350 bolts]
  and [#358][news358 bolts]).

- [BDK #1957][] introduces RPC batching for transaction history, merkle
  proofs, and block header requests to optimize full scan and sync
  performance with an Electrum backend. This PR also adds anchor caching
  to skip Simple Payment Verification (SPV) (see Newsletter
  [#312][news312 spv]) revalidation during a sync. Using sample data,
  the author observed performance improvements of 8.14 seconds to 2.59
  seconds with RPC call batching on a full scan and of 1.37 seconds to
  0.85 seconds with caching during a sync.

- [BIPs #1888][] removes `H` as a hardened-path marker from [BIP380][],
  leaving just the canonical `h` and the alternative `'`. The recent
  Newsletter [#360][news360 bip380] had noted that grammar was clarified
  to allow all three markers, but since few (if any) descriptor
  implementations actually support it (neither Bitcoin Core nor
  rust-miniscript do), the specification is tightened to disallow it.

{% include snippets/recap-ad.md when="2025-07-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8377,1957,1888" %}
[LND v0.19.2-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta.rc2
[news358 descencrypt]: /en/newsletters/2025/06/13/#descriptor-encryption-library
[dorman descom]: https://delvingbitcoin.org/t/a-rust-library-to-encode-descriptors-with-a-30-40-size-reduction/1804
[descriptor-codec]: https://github.com/joshdoman/descriptor-codec
[news350 bolts]: /en/newsletters/2025/04/18/#bolts-1242
[news358 bolts]: /en/newsletters/2025/06/13/#bolts-1243
[news312 spv]: /en/newsletters/2024/07/19/#bdk-1489
[news360 bip380]: /en/newsletters/2025/06/27/#bips-1803
