---
title: 'Bitcoin Optech Newsletter #324'
permalink: /en/newsletters/2024/10/11/
name: 2024-10-11-newsletter
slug: 2024-10-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

## News

- FIXME:harding btcd disclosure details set to be announced Thursday

## FIXME instagibbs article

FIXME:harding, see PR 1937

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/30352#l-18FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.5][] is a release candidate (RC) of this library for
  building wallets and other Bitcoin-enabled applications.  This latest
  RC "enables RBF by default, updates the bdk_esplora client to retry
  server requests that fail due to rate limiting. The `bdk_electrum`
  crate now also offers a use-openssl feature."

<!-- FIXME:harding to update Thursday -->

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #7494][] pay: Remember and update channel_hints across payments #7494

- [Core Lightning #7539][] Add getemergencyrecoverdata RPC Command to Fetch Data from emergency.recover File

- [LDK #3179][] Add the core functionality required to resolve Human Readable Names

- [LND #8960][] merge custom channel staging branch into master

- [Libsecp256k1 #1479][] Add module "musig" that implements MuSig2 multi-signatures (BIP 327)

- [Rust Bitcoin #2945][] Support Testnet4 Network

- [BIPs #1674][] reverts the changes to the [BIP85][] specification
  described in [Newsletter #323][news323 bip85].  The changes broke
  compatibility with deployed versions of the protocol.  Discussion on
  the PR supported creating a new BIP for the major changes.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7494,7539,3179,8960,1479,2945,1674" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[news323 bip85]: /en/newsletters/2024/10/04/#bips-1600
