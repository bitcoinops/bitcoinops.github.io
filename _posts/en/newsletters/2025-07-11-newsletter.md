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

- [Core Lightning #8377][]
  - BOLT11: Make payment secret field ('s') mandatory
  - bolt11: don't accept wrong-length p, h, s or n fields.

- [BDK #1957][] feat(electrum): optimize merkle proof validation with batching

- [BIPs #1888][] 380: Disallow H as a hardened indicator

{% include snippets/recap-ad.md when="2025-07-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8377,1957,1888" %}
[LND v0.19.2-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta.rc2
[news358 descencrypt]: /en/newsletters/2025/06/13/#descriptor-encryption-library
[dorman descom]: https://delvingbitcoin.org/t/a-rust-library-to-encode-descriptors-with-a-30-40-size-reduction/1804
[descriptor-codec]: https://github.com/joshdoman/descriptor-codec
