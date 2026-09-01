---
title: 'Bitcoin Optech Newsletter #421'
permalink: /en/newsletters/2026/09/04/
name: 2026-09-04-newsletter
slug: 2026-09-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an idea for pools to pay miners using silent
payments in the coinbase transaction and summarizes the responsible disclosure
of a denial-of-service vulnerability affecting older versions of Core
Lightning. Also included are our regular sections summarizing proposals and
discussion about changing Bitcoin's consensus rules, announcing new releases
and release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Using silent payments for miner payouts in coinbase transaction**:
  average_gary [posted][spc del] to Delving Bitcoin about his idea for
  how [pools][topic pooled mining] could pay miners to different addresses
  directly in the coinbase transaction. Instead of providing an `xpub` to
  the pool to derive a fresh address for each payout, which could result in
  privacy issues if the pool's database gets compromised, a miner could
  share a [silent payment][topic silent payments] address, which is static and
  can be used several times without privacy leaks, through the encrypted
  communication channel provided by Stratum v2.

  For [BIP352][] silent payments, the receiver derives the shared secret from
  the transaction's input public keys, which a coinbase transaction does not
  have. The pool can create an ephemeral private key to be used to derive the
  sending public key `A_send`. To prevent the pool from grinding a malicious
  `a_send` private key, `A_send` is hashed with the height of the block being
  mined, which replaces the outpoint-derived uniqueness.
  The 34-byte `A_send` is finally included in the coinbase scriptSig replacing
  the so-called pool tag, so that the miner can scan the chain for the funds.

  The author is looking for feedback and critiques on the proposed idea,
  so that it can be formalized into a real specification.

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

{% include snippets/recap-ad.md when="2026-09-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[spc del]: https://delvingbitcoin.org/t/silent-payments-coinbase/2833
