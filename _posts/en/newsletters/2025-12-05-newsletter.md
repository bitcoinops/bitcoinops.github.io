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

- **Benchmarking the varops budget**: Julian [posted][j ml varops] a call to
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
  machine code either durably cached or computed on startup). Where
  applicable, the optimized SPHINCS signing and key generation operations are an
  order of magnitude faster than the previous state of the art and only two
  orders of magnitude slower than elliptic curve operations. More importantly,
  the optimized signature verification is approximately as fast as elliptic
  curve signature verification.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning v25.12][] is a release of this major LN implementation that
  adds [BIP39][] mnemonic seed phrases as the new default backup method,
  improves pathfinding, adds experimental [JIT channels][topic jit channels]
  support, and many other features and bug fixes. Due to breaking database
  changes, this release includes a downgrade tool in case something goes wrong
  (see below for more information).

- [LDK 0.2][] is a major release of this library for building Lightning
  applications that adds support for [splicing][topic splicing] (experimental),
  serving and paying static invoices for [async payments][topic async payments],
  [zero-fee-commitment][topic v3 commitments] channels using [ephemeral anchors][topic ephemeral
  anchors] as well as many other features, bug fixes, and API improvements.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #8728][] fixes a bug that caused `hsmd` to crash when a user
  entered the wrong passphrase; it now properly handles this user error case and
  exits cleanly.

- [Core Lightning #8702][] adds a `lightningd-downgrade` tool that downgrades
  the database version from 25.12 to the previous 25.09 in case of an upgrade
  error.

- [Core Lightning #8735][] fixes a long-standing bug where some on-chain spends
  could disappear from CLN’s view during a restart. Upon startup, CLN rolls back
  the latest 15 blocks (by default), resets the spend height of UTXOs spent in
  those blocks to `null`, and then rescans. Previously, CLN failed to rewatch
  those UTXOs, which could cause CLN to keep relaying [channel
  announcements][topic channel announcements] that had already been closed, or
  to miss important on-chain spends. This PR ensures that these UTXOs are
  rewatched during startup and adds a one-time backward scan to recover any
  spends that were previously missed due to this bug.

- [LDK #4226][] begins validating the amount and CLTV fields of received
  [trampoline][topic trampoline payments] onions against the outer onion. It
  also adds three new local failure reasons:
  `TemporaryTrampolineFailure`,`TrampolineFeeOrExpiryInsufficient`, and
  `UnknownNextTrampoline` as a first step towards supporting trampoline payment
  forwarding.

- [LND #10341][] fixes a bug where the same [Tor][topic anonymity networks]
  onion address was duplicated in the node announcement and in the `getinfo`
  output whenever the hidden service was restarted. The PR ensures the
  `createNewHiddenService` function never duplicates an address.

- [BTCPay Server #6986][] introduces `Monetization`, which allows server admins
  to require a `Subscription` (see [Newsletter #379][news379 btcpay]) for user
  login. This feature enables ambassadors, Bitcoin users who onboard new users
  and merchants in local contexts, to monetize their work. There’s a default
  seven-day free trial period and a free starter plan; however, subscriptions
  are customizable. Existing users will not be automatically enrolled in a
  subscription, though they can be migrated later.

- [BIPs #2015][] adds test vectors to [BIP54][], the [consensus cleanup][topic
  consensus cleanup] proposal, by introducing a set of vectors for each of the
  four mitigations. The vectors are generated from the [BIP54][] implementation
  in Bitcoin Inquisition and a custom Bitcoin Core mining unit test, and are
  documented with instructions for their use in implementation and review.
  See [Newsletter #379][news379 bip54] for additional context.

{% include snippets/recap-ad.md when="2025-12-09 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1699,8728,8702,8735,4226,10341,6986,2015" %}
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
[LDK 0.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2
[news379 btcpay]: /en/newsletters/2025/11/07/#btcpay-server-6922
[news379 bip54]: /en/newsletters/2025/11/07/#bip54-implementation-and-test-vectors
[Core Lightning v25.12]: https://github.com/ElementsProject/lightning/releases/tag/v25.12