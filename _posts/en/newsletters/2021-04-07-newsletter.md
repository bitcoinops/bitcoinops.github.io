---
title: 'Bitcoin Optech Newsletter #143'
permalink: /en/newsletters/2021/04/07/
name: 2021-04-07-newsletter
slug: 2021-04-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter contains our regular sections with announcements
of new releases and release candidates, plus notable changes to popular
Bitcoin infrastructure projects.

## News

*No noteworthy news to report this week.*

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*


- [C-Lightning 0.10.0][C-Lightning 0.10.0] is the newest major release
  of this LN node software. It contains a number of enhancements to its
  API and includes experimental support for [dual funding][topic dual
  funding].

- [BTCPay 1.0.7.2][] fixes minor issues discovered after last
  week's security release.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #20286][] removes the fields `addresses` and `reqSigs` from the
  responses of the RPCs `gettxout`, `getrawtransaction`,
  `decoderawtransaction`, `decodescript`, `gettransaction`, and the REST
  endpoints `/rest/tx`, `/rest/getutxos`, `/rest/block`. When a well-defined
  address exists, the responses now include the optional field `address`
  instead. The deprecated fields had been used in the context of bare multisig
  which has no substantial use on the network today. The deprecated fields can
  be output via the configuration option `-deprecatedrpc=addresses` until the
  option is removed in Bitcoin Core 23.0.

- [Bitcoin Core #20197][] improves the diversity of peer connections by updating
  the inbound peer eviction logic to protect the longest-running
  onion peers.  It also adds unit test coverage for the current
  eviction protection logic.  Onion peers have historically been disadvantaged
  by the eviction criteria due to their higher latency relative to IPv4 and IPv6
  peers, leading to users filing [multiple][Bitcoin Core #11537] [issues][Bitcoin Core #19500].
  An [initial response][news114 core19670] to the issue
  began reserving slots for localhost peers as a proxy for onion peers.
  Later, [explicit detection of inbound onion connections][news118 core19991] was added.

  With the updated logic, half of the protected slots are allocated to any onion
  and localhost peers, with onion peers receiving precedence over localhost
  peers.  Now that support for the I2P privacy network has been added to Bitcoin
  Core (see [Newsletter #139][news139 i2p]), a next step will be to extend
  eviction protection to I2P peers, as they generally have higher latency than
  onion peers.

- [Eclair #1750][] removes support for Electrum and the corresponding 10,000 lines
  of code. Electrum was previously used by Eclair for mobile wallets. However, a new
  implementation, [Eclair-kmp][eclair-kmp github], is now recommended for use by
  mobile wallets, making Electrum support for Eclair unnecessary.

- [Eclair #1751][] Add blocking option to payinvoice API FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="20286,20197,1750,1751,19500,11537,19670,19991" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0
[btcpay 1.0.7.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.2
[news139 i2p]: /en/newsletters/2021/03/10/#bitcoin-core-20685
[news114 core19670]: /en/newsletters/2020/09/09/#bitcoin-core-19670
[news118 core19991]: /en/newsletters/2020/10/07/#bitcoin-core-19991
[eclair-kmp github]: https://github.com/ACINQ/eclair-kmp
