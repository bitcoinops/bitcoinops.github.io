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

FIXME:bitschmidty

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
