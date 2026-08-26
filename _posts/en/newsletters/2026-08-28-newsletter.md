---
title: 'Bitcoin Optech Newsletter #420'
permalink: /en/newsletters/2026/08/28/
name: 2026-08-28-newsletter
slug: 2026-08-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter relays advance notice of a planned Core Lightning
security release, summarizes a discussion about opt-in replay protection for
potential future forks, notes that the Hardware Wallet Interface (HWI) project
will enter maintenance mode, and describes a request for comments on using
block-range filters. Also included are our regular sections announcing new
releases and release candidates and describing notable changes to popular
Bitcoin infrastructure software.

## Action items

## News

- **Discussion on universal opt-in replay protection**: Moonsettler
  [posted][replay del] to Delving Bitcoin to discuss the possibility
  of introducing an opt-in replay protection mechanism in case of future
  forks. The idea followed recent events in which a minority chain was subject
  to replay attacks, a type of attack in which a valid signed transaction on one
  chain of a fork is rebroadcast on the other, unintentionally spending the
  equivalent coins on both networks. The author proposes to use the [taproot
  annex][topic annex]
  by committing a 34-byte payload that includes the previous block
  hash (i.e. `<0xFAF0><32-byte-prior-block-hash>`).

  Discussion followed with Anthony Towns proposing to use the block height
  and a hash suffix of the block instead, so as to reduce the amount of
  data to 6 bytes. Moonsettler agreed on the approach and added that it
  would be valuable for nodes to annotate UTXOs with the block commitment
  to provide that information to users. The author also proposed a limit on new
  commitment depth, ideally the `assumevalid` height, and for nodes to keep
  track of the commitment for up to `100` blocks. Moreover, Towns proposed
  to add a mechanism similar to a maturity constraint by setting an explicit
  `nLocktime` to prevent a transaction from being mined before a certain number
  of blocks to account for block reorgs.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

{% include snippets/recap-ad.md when="2026-09-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[replay del]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792
