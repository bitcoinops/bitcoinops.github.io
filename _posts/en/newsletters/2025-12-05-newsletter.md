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

- **LNHANCE soft fork**: Moonsettler [proposes][ms ml lnhance] a soft fork for
  LNHANCE now that all four of its constituent opcodes have updated BIPs and
  reference implementations. [BIP119][] ([OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify]), [BIP348][] ([OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack]), [BIP349][] (OP_INTERNALKEY), and [BIPs #1699][]
  (OP_PAIRCOMMIT) add re-bindable signatures and multi-commitments to
  [tapscript][topic tapscript], and next transaction commitments to all Script
  versions. A similar tapscript-only opcode [package][gs ml thikcs] including
  `OP_TEMPLATEHASH` was [recently proposed][news365 oth] and has similar
  capabilities, but without general multi-commitments and, being newer, is
  awaiting further feedback and review.

- **Benchmarking The Varops Budget**: Julian [posted][j ml varops] a call to
  action to benchmark Bitcoin script execution under the [varops budget][bip
  varops]. The Script Restoration (see [Newsletter #374][news374 gsr]) team asks
  that users run their [benchmark][j gh bench] and share the results from a wide
  variety of hardware and operating systems to confirm or improve the chosen
  varops parameters. In response to Russell O'Connor, Julian also clarified that
  the varops budget would be used instead of (not in addition to) the sigops
  budget in the new [tapscript][topic tapscript] version.

- **SLH-DSA (SPHINCS) post-quantum signature optimizations**: Continuing the
  discussions around hardening Bitcoin against [quantum computing][topic
  quantum resistance], conduition [presented][c ml sphincs] his work on
  optimizing the SPHINCS signing algorithm. These optimizations require several
  megabytes of RAM and locally compiled shaders (highly optimized, cpu-specific
  machine code — either durably cached or computed on startup). Where
  applicable, the optimized SPHINCS signing and key generation operations are an
  order of magnitude faster than the previous state of the art and only two
  orders of magnitude slower than elliptic curve operations. More importantly,
  the optimized signature verification is approximately as fast as elliptic
  curve signature verification.

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
[ms ml lnhance]: https://groups.google.com/g/bitcoindev/c/AlMqLbmzxNA
[gs ml thikcs]: https://groups.google.com/g/bitcoindev/c/5wLThgegha4/m/iUWIZPIaCAAJ
[j ml varops]: https://groups.google.com/g/bitcoindev/c/epbDDH9MHNw/m/OUrIeSHmAAAJ
[news365 oth]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[news374 gsr]: /en/newsletters/2025/10/03/#draft-bips-for-script-restoration
[bip varops]: https://github.com/rustyrussell/bips/blob/guilt/varops/bip-unknown-varops-budget.mediawiki
[j gh bench]: https://github.com/jmoik/bitcoin/blob/gsr/src/bench/bench_varops.cpp
[c ml sphincs]: https://groups.google.com/g/bitcoindev/c/LAll07BHwjw/m/2k7o2VKwAQAJ
[bruno delving]: https://delvingbitcoin.org/t/consensus-bug-on-nbitcoin-out-of-bound-issue-in-remove/2120
[nbitcoin patch]: https://github.com/MetacoSA/NBitcoin/pull/1288
[diff fuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
