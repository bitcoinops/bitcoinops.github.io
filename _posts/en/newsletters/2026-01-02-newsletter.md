---
title: 'Bitcoin Optech Newsletter #386'
permalink: /en/newsletters/2026/01/02/
name: 2026-01-02-newsletter
slug: 2026-01-02-newsletter
type: newsletter
layout: newsletter
lang: en
---

This week's newsletter summarizes a vault-like scheme using blinded MuSig2 and
describes a proposal for Bitcoin clients to announce and negotiate support for new
P2P features. Also included are our regular sections describing discussion
related to consensus changes, announcing new releases and release candidates,
and summarizing notable changes to popular Bitcoin infrastructure software.

## News

- **Building a vault using blinded co-signers:** Jonathan T. Halseth
  [posted][halseth post] to Delving Bitcoin a prototype of a
  [vault][topic vaults]-like scheme using blinded co-signers. Unlike traditional
  setups using co-signers, this scheme uses a [blinded version][blinded musig]
  of [MuSig2][topic musig] to ensure the signers know as little as possible about
  the funds they are involved in signing. To prevent signers from having to
  blindly sign what is given to them, this scheme attaches a zero-knowledge proof
  to the signing request proving that the transaction is valid according to a
  pre-determined policy, in this case a [timelock][topic timelocks].

  Halseth provided a graph of the scheme showing four transactions where the
  initial deposit, recovery, unvault, and the unvault recovery transactions will
  be pre-signed. At the time of unvaulting, the co-signers will require a
  zero-knowledge proof that the tx they are signing has the relative
  timelock set correctly. This gives assurance that the user
  or a watchtower will have time to sweep the funds in the case of an
  unauthorized unvault.

  Halseth also provided a [prototype implementation][halseth prototype]
  available for regtest and signet.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

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

{% include snippets/recap-ad.md when="2026-01-06 17:30" %}
[halseth post]: https://delvingbitcoin.org/t/building-a-vault-using-blinded-co-signers/2141
[halseth prototype]: https://github.com/halseth/blind-vault
[blinded musig]: https://github.com/halseth/ephemeral-signing-service/blob/main/doc/general.md
