---
title: 'Bitcoin Optech Newsletter #415'
permalink: /en/newsletters/2026/07/24/
name: 2026-07-24-newsletter
slug: 2026-07-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a draft BIP for full aggregation of BIP340
signatures. Also included are our regular sections describing recent changes to
services and client software, announcing new releases and release candidates,
and summarizing notable changes to popular Bitcoin infrastructure software.

## News

- **Draft BIP for full aggregation of BIP340 signatures**: Fabian Jahr [posted][aggr ml] to
  the Bitcoin-Dev mailing list about a new draft BIP for full aggregation of
  [BIP340][] [schnorr signatures][topic schnorr signatures], a standard for the DahLIAS aggregate signature scheme
  (see [Newsletter #351][news351 dahlias]), which describes a process to
  combine a collection of signatures into a single aggregate one, with a size
  of only 64 bytes, regardless of the number of signers. However, the described
  protocol is interactive and requires cooperation among all the signers and involves
  the presence of an untrusted coordinator to reduce communication complexity.
  The coordinator role can be taken by any of the signers participating in the process.

  The process is divided into two rounds:

  1. Each signer starts the signing session by computing a secret nonce
  (`secnonce`) and a public nonce (`pubnonce`). `pubnonce` is sent to the
  coordinator, which aggregates them (`aggnonce`) and sends the result back to
  signers, together with other pieces of information.

  2. Each signer computes a partial signature using the secret key, `secnonce`,
  the message to sign, and the information provided. Partial signatures are then
  sent to the coordinator, which aggregates them in a single 64-byte signature.

  According to Jahr, one of the possible applications of the proposal would
  be [cross-input signature aggregation (CISA)][topic cisa], a change to Bitcoin
  consensus that would reduce size and thus on-chain fees of multi-input transactions.
  However, the author specified that the consensus change is outside the scope of this BIP.

  The draft BIP, which is now referred to as BIP459, is currently being discussed in [BIPs #2210][]
  and the proposal is gathering feedback from the community.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

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

{% include snippets/recap-ad.md when="2026-07-28 16:30" %}
{% include references.md %}
[aggr ml]: https://groups.google.com/g/bitcoindev/c/TF5mPfy58RQ/m/vAk1Mfg2AwAJ
[news351 dahlias]: /en/newsletters/2025/04/25/#interactive-aggregate-signatures-compatible-with-secp256k1
