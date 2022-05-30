---
title: 'Bitcoin Optech Newsletter #202'
permalink: /en/newsletters/2022/06/01/
name: 2022-06-01-newsletter
slug: 2022-06-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes experimentation by developers working
on silent payments and includes our regular sections with summaries of
new releases and release candidates plus notable changes to popular
Bitcoin infrastructure software.

## News

- **Experimentation with silent payments:** as described in [Newsletter
  #194][news194 silent], *silent payments* make it possible to pay a
  public identifier ("address") without creating a public record of that
  address being paid.  This week, developer w0xlt [posted][w0xlt post]
  to the Bitcoin-Dev mailing list a [tutorial][sp tutorial] for creating
  silent payments for the default [signet][topic signet] using a
  proof-of-concept [implementation][bitcoin core #24897] for Bitcoin
  Core.  Several other developers, including authors of popular wallets,
  have been discussing other details of the proposal, including
  [creating an address format][sp address] for it.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 2.1.1][] fixes two minor bugs affecting Ledger and Trezor devices
  and adds support for the Ledger Nano S Plus.

- [LND 0.15.0-beta.rc3][] is a release candidate for the next major
  version of this popular LN node.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [BTCPay Server #3772][] allows users to turn on experimental features
  for live-testing before release.

- [BTCPay Server #3744][] adds a feature to export the wallet's transactions
  either in CSV or JSON format.

- [BOLTs #968][] adds default TCP ports for nodes using Bitcoin testnet and
  signet.

{% include references.md %}
{% include linkers/issues.md v=2 issues="3772,3744,968,24897" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[hwi 2.1.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.1.1
[news194 silent]: /en/newsletters/2022/04/06/#delinked-reusable-addresses
[w0xlt post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020513.html
[sp tutorial]: https://gist.github.com/w0xlt/72390ded95dd797594f80baba5d2e6ee
[sp address]: https://gist.github.com/RubenSomsen/c43b79517e7cb701ebf77eec6dbb46b8?permalink_comment_id=4177027#gistcomment-4177027
