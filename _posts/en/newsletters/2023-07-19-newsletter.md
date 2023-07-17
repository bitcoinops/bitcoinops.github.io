---
title: 'Bitcoin Optech Newsletter #260'
permalink: /en/newsletters/2023/07/19/
name: 2023-07-19-newsletter
slug: 2023-07-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes the final entry in our limited weekly
series about mempool policy, plus our regular sections describing
notable changes to clients, services, and popular Bitcoin infrastructure
software.

## News

_No significant news was found this week on the Bitcoin-Dev or
Lightning-Dev mailing lists._

## Waiting for confirmation #10: Get Involved

_The final entry in our limited weekly [series][policy series] about
transaction relay, mempool inclusion, and mining transaction
selection---including why Bitcoin Core has a more restrictive policy
than allowed by consensus and how wallets can use that policy most
effectively._

{% include specials/policy/en/10-get-involved.md %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Wallet 10101 beta testing pooling funds between LN and DLCs:**
  10101 announced a [wallet][10101 github] built with LDK and BDK that allows users to trade
  derivatives non-custodially using [DLCs][topic dlc] in an [offchain contract][10101 blog2]
  that can also be used to send, receive, and forward LN payments. The DLCs rely
  on oracles that use [adaptor signatures][topic adaptor signatures] for price
  [attestation][10101 blog1].

- **LDK Node announced:**
  The LDK team [announced][ldk blog] LDK Node [v0.1.0][LDK Node v0.1.0]. LDK Node is a
  Lightning node Rust library that uses the LDK and BDK libraries to enable developers
  to quickly setup a self-custodial Lightning node while still providing a high degree of
  customization for different use cases.

- **Payjoin SDK announced:**
  [Payjoin Dev Kit (PDK)][PDK github] was [announced][PDK blog] as a Rust
  library that implements [BIP78][] for use in wallets and services that wish to
  integrate [payjoin][topic payjoin] functionality.

- **Validating Lightning Signer (VLS) beta announced:**
  VLS allows the separation of a Lightning node from the keys that control its
  funds. A Lightning node running with VLS will route signing requests to a
  remote signing device instead of local keys. The [beta release][VLS gitlab]
  supports CLN and LDK, layer-1 and layer-2 validation rules, backup/recovery
  capabilities, and provides a reference implementation. The [blog
  post][VLS blog] announcement also calls for testing, feature requests, and feedback from the community.

- **BitGo adds MuSig2 support:**
  BitGo [announced][bitgo blog] support for [BIP327][] ([MuSig2][topic musig])
  and noted the reduced fees and additional privacy compared to their other
  supported address types.

- **Peach adds RBF support:**
  The [Peach Bitcoin][peach website] mobile application for peer-to-peer
  exchange [announced][peach tweet] support for [Replace-By-Fee (RBF)][topic rbf] fee bumping.

- **Phoenix wallet adds splicing support:**
  ACINQ [announced][acinq blog] beta testing for the next version of their
  Phoenix mobile Lightning wallet. The wallet supports a single dynamic channel
  that is rebalanced using [splicing][topic splicing] and
  a mechanism similar to the [swap-in-potentiam][news233 sip] technique (see
  [Podcast #259][pod259 phoenix]).

- **Mining Development Kit call for feedback:**
  The team working on the Mining Development Kit (MDK) has [posted an update][MDK blog] on their
  progress to develop hardware, software, and firmware for Bitcoin mining systems. The post
  calls for feedback from the community about use cases, scope, and approach.

- **Binance adds Lightning support:**
  Binance [announced][binance blog] support for sending (withdrawals) and
  receiving (deposits) using the Lightning Network.

- **Nunchuk adds CPFP support:**
  Nunchuk [announced][nunchuk blog] support for [Child-Pays-For-Parent
  (CPFP)][topic cpfp] fee bumping for both senders and receivers of a transaction.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27411][] prevents a node from advertising its Tor or
  I2P address to peers on other networks (such as plain IPv4 or IPv6)
  and won't advertise its address from non-[anonymity networks][topic
  anonymity networks] to peers on Tor and I2P.  This helps prevent
  someone from associating a node's regular network address to one of its
  addresses on an anonymity network.  CJDNS is treated differently from
  Tor and I2P at the moment, although that may change in the future.

- [Core Lightning #6347][] adds the ability for a plugin to subscribe to
  every event notification using the wildcard `*`.

- [Core Lightning #6035][] adds the ability to request a [bech32m][topic
  bech32] address for receiving deposits to [P2TR][topic taproot] output
  scripts.  Transaction change will also now be sent to a P2TR output by
  default.

- [LND #7768][] implements BOLTs [#1032][bolts #1032] and [#1063][bolts
  #1063] (see [Newsletter #225][news225 bolts1032]), allowing the
  ultimate receiver of a payment (HTLC) to accept a greater amount than
  they requested and with a longer time before it expires than they
  requested.  Previously, LND-based receivers adhered to [BOLT4][]'s
  requirement that the amount and expiry delta equal exactly the amount
  they requested, but that exactitude meant a forwarding node could
  probe the next hop to see if it was the final receiver by slightly
  changing either value.

- [Libsecp256k1 #1313][] begins automatic testing using development
  snapshots of the GCC and Clang compilers which may allow detection of
  changes that could result in certain libsecp256k1 code running in
  variable time.  Non-constant time code that works with private keys
  and nonces may lead to [side-channel attacks][topic
  side channels].  See [Newsletter #246][news246 secp] for one occasion
  where that may have happened and [Newsletter #251][news251 secp] for
  another occasion and an announcement that this sort of testing was
  planned.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27411,6347,6035,7768,1032,1063,1313" %}
[policy series]: /en/blog/waiting-for-confirmation/
[news225 bolts1032]: /en/newsletters/2022/11/09/#bolts-1032
[news246 secp]: /en/newsletters/2023/04/12/#libsecp256k1-0-3-1
[news251 secp]: /en/newsletters/2023/05/17/#libsecp256k1-0-3-2
[10101 github]: https://github.com/get10101/10101
[10101 blog1]: https://10101.finance/blog/dlc-to-lightning-part-1/
[10101 blog2]: https://10101.finance/blog/dlc-to-lightning-part-2
[LDK Node v0.1.0]: https://github.com/lightningdevkit/ldk-node/releases/tag/v0.1.0
[LDK blog]: https://lightningdevkit.org/blog/announcing-ldk-node
[PDK github]: https://github.com/payjoin/rust-payjoin
[PDK blog]: https://payjoindevkit.org/blog/pdk-an-sdk-for-payjoin-transactions/
[VLS gitlab]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.9.1
[VLS blog]: https://vls.tech/posts/vls-beta/
[bitgo blog]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[peach website]: https://peachbitcoin.com/
[peach tweet]: https://twitter.com/peachbitcoin/status/1676955956905902081
[acinq blog]: https://acinq.co/blog/phoenix-splicing-update
[news233 sip]: /en/newsletters/2023/01/11/#non-interactive-ln-channel-open-commitments
[MDK blog]: https://www.mining.build/update-on-the-mining-development-kit/
[binance blog]: https://www.binance.com/en/support/announcement/binance-completes-integration-of-bitcoin-btc-on-lightning-network-opens-deposits-and-withdrawals-eefbfae2c0ae472d9e1e36f1a30bf340
[nunchuk blog]: https://nunchuk.io/blog/cpfp
[pod259 phoenix]: /en/podcast/2023/07/13/#phoenix
