---
title: 'Bitcoin Optech Newsletter #383'
permalink: /en/newsletters/2025/12/05/
name: 2025-12-05-newsletter
slug: 2025-12-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a fixed vulnerability affecting the NBitcoin
library.  Also included are our regular sections summarizing discussion about
changing Bitcoin's consensus rules, announcing new releases and release
candidates, and describing notable changes to popular Bitcoin infrastructure
software.

## News

- **Consensus bug in NBitcoin library:** Bruno Garcia [posted][bruno delving] to
  Delving Bitcoin about a theoretical consensus failure in NBitcoin that could
  occur when using `OP_NIP`. When the underlying array is at full capacity and
  `_stack.Remove(-2)`is called, the Remove operation deletes the item at index
  14 and then attempts to shift the subsequent elements down. During this shift,
  the implementation may try to access `_array[16]`, which does not exist,
  leading to an exception.

  This bug was found through [differential fuzzing][diff fuzz], and since
  the failure was caught in a try/catch block it may never have been found with
  traditional fuzzing techniques. After finding the problem, Bruno Garcia
  reported it to Nicolas Dorier on October 23rd, 2025. On the same day, Nicolas
  Dorier confirmed the issue and opened a [patch][nbitcoin patch] to resolve it.
  There is no known full node implementation using NBitcoin, so there is no risk
  of a chain split, which is why the disclosure was made quickly.

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

{% include snippets/recap-ad.md when="2025-12-09 17:30" %}
{% include references.md %}
[bruno delving]: https://delvingbitcoin.org/t/consensus-bug-on-nbitcoin-out-of-bound-issue-in-remove/2120
[nbitcoin patch]: https://github.com/MetacoSA/NBitcoin/pull/1288
[diff fuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
