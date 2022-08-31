---
title: 'Bitcoin Optech Newsletter #216'
permalink: /en/newsletters/2022/09/07/
name: 2022-09-07-newsletter
slug: 2022-09-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes several notable changes to popular
Bitcoin infrastructure software.

## News

*No significant news this week.*

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25717][] p2p: Implement anti-DoS headers sync FIXME:glozow

- [Bitcoin Core #25355][] I2P: add support for transient addresses for outbound connections FIXME:Xekyo

- [BDK #689][] adds an `allow_dust` method which allows a wallet to
  create a transaction that violates the [dust limit][topic uneconomical
  outputs].  Bitcoin Core and other nodes which use the same settings
  won't relay unconfirmed transactions unless every output (except
  `OP_RETURN`) receives more satoshis than the dust limit.  BDK usually
  prevents users from creating such unrelayable transactions by
  enforcing the dust limit on the transactions it creates, but this new
  option allows ignoring that policy.  The author of the PR mentions
  that they're using it for testing their wallet.

- [BDK #682][] Add a custom signer for hardware wallets FIXME:bitschmidty

{% include references.md %}
{% include linkers/issues.md v=2 issues="25717,25355,689,682" %}
