---
title: 'Bitcoin Optech Newsletter #432'
permalink: /en/newsletters/2026/11/20/
name: 2026-11-20-newsletter
slug: 2026-11-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an analysis of decentralized mining pool
payouts, describes the disclosure of a fixed denial-of-service vulnerability
in Eclair, and links to continued discussion about whether stale tip relay
should include block data. Also included are our regular sections describing
recent changes to services and client software, announcing new releases and
release candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Framework for decentralized mining pool payouts:** Developer 7d5x9
  [posted][7d5x9 dcpp] to Delving Bitcoin an analysis of how decentralized
  [mining pools][topic pooled mining] can pay miners directly from coinbase
  transactions, which the post calls decentralized coinbase payout protocols
  (DCPPs). Giving every miner its own output does not scale because mining
  firmware limits coinbase transaction size and each output displaces
  fee-paying transactions. The post argues that when a pool has more miners
  than outputs, any rule ranking miners by work allows a _rich list attack_,
  where a large miner splits its hashrate across identities that each still
  outrank the smallest miners, pushing them out of the coinbase transaction.

  According to 7d5x9, earlier designs only move this problem. Braidpool shifts
  it from who receives an output to who controls the pool's threshold key (see
  [Newsletter #340][news340 braidpool]). For a single coinbase output paying a
  [joinpool][topic joinpools] with unilateral exits, the obstacle is that
  miners vary the coinbase transaction for extra nonce space, so its txid is
  unknown and exit transactions cannot be signed until a block is found. 7d5x9
  believes this leaves the output controlled by a single key or threshold of
  keys until a soft fork enables rebindable signatures, such as those proposed
  in [BIP448][] (see [Newsletter #397][news397 bip448]). In sketches based on
  Spark-style [statechains][topic statechains] and on [Ark][topic ark], an
  attacker keeping one small claim per subtree can block cheap cooperative
  settlement, raising miners' costs, though the post considers this less
  severe for Ark.

  The post concludes that a joinpool does not decide which outputs enter the
  coinbase transaction. It sees two options for that: a value-weighted random
  draw (an idea credited to Matt Corallo) or outputs reserved for designated
  operators.

  LearnBitcoin.com, who ran a public P2Pool node, [examined][lb p2pool] 2,545
  P2Pool coinbase transactions and argued that growth alone, without any
  attacker, squeezed out small miners because P2Pool raised the share
  difficulty of miners expected to earn under 0.001 BTC per block. For its
  successor P2Poolv2, jungly [suggested][jungly dcpp] a limit of 16 outputs
  given current firmware. Steven Roose [replied][roose dcpp] that he could not
  think of a scheme worth exploring without [covenants][topic covenants],
  which would let a coinbase output deterministically commit to an Ark
  transaction tree that pays every miner who uses the same Ark server.

- **Disclosure of a DoS vulnerability in Eclair:** rorp [posted][eclair vuln del]
  to Delving Bitcoin the [responsible disclosure][topic responsible disclosures] of a memory-exhaustion denial-of-service (DoS)
  vulnerability affecting Eclair version [0.14.0][eclair 0.14.0] and fixed in July
  2026 in release [0.14.1][eclair 0.14.1]. Any peer able to connect to a vulnerable node could crash
  it, even without having a channel with it. The bug gave an attacker no
  direct access to funds, but repeatedly crashing a node could put its channel
  funds at risk. Users still running 0.14.0 should upgrade.

  The attack vector leveraged a missing size check in Eclair. According to [BOLT2][],
  messages can be sent in batches to be treated as a single logical update through the
  `start_batch` message, which among other fields carries the `batch_size`. According
  to the specifications, the size must be at most `20` and strictly greater than `1`.
  While Eclair checked for the upper bound, it did not enforce the lower one.

  An attacker would have been able to use this vulnerability by sending a `start_batch`
  message with `batch_size = 0`, followed by `commitment_signed` messages, which are
  sent in batches during [splicing][topic splicing]. Since the code stopped adding
  messages to its internal batch only once the number of received messages reached the
  `batch_size` (which was `0`, thus always lower than the number of messages received),
  the list never stopped growing, leading to memory exhaustion.
  The vulnerability was fixed by having the code check the lower bound, too, as
  specified in BOLT2.

FIXME:bitschmidty

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Liana v16.0 released:** [Liana v16.0][liana v16.0] writes its encrypted
  [descriptor][topic descriptors] backups in the [BIP138][] format (see
  [Newsletter #424][news424 bip138]) and makes [taproot][topic taproot] the
  default for new wallets.

- **COLDCARD firmware adds codex32 backups:** Coinkite
  [announced][coldcard 5.6.3] COLDCARD firmware versions 5.6.3 and 1.5.3Q,
  which add support for generating and importing [codex32][topic codex32]
  secrets and for splitting the device's wallet into two to nine Shamir shares
  for later recovery. The releases also add support for per-input height and
  time locktimes in [PSBTv2][topic psbt] transactions.

- **Wavelength released on mainnet:** Lightning Labs
  [announced][wavelength mainnet] that Wavelength, its [Ark][topic ark]-like
  payments toolkit (see [Newsletter #415][news415 wavelength]), is available
  on mainnet as an alpha with accounts limited to 300,000 sats.

- **Bull Bitcoin makes payjoin the default for exchange orders:** Bull Bitcoin
  [announced][bull payjoin blog] that onchain purchases and sales made on its
  exchange through the Bull Bitcoin Mobile wallet now use
  [payjoin][topic payjoin] by default (see [Newsletter #338][news338 bull]).
  Version [6.14.0][bull 6.14.0] of the wallet also adds experimental support
  for sending and receiving [silent payments][topic silent payments].

- **Breez SDK adds silent payment sending:** Version [0.28.0][breez 0.28.0] of
  the Spark-based Breez SDK adds support for sending to
  [silent payment][topic silent payments] addresses.

- **Silent payments scanner for Electrum plugin:** Ali Sherief
  [announced][spscand delving] spscand, a watch-only
  [silent payments][topic silent payments] scanner that works with the
  Electrum sending plugin covered in [Newsletter #419][news419 sp electrum].
  It can scan for payments using the user's own Bitcoin Core node, a BlindBit
  server, or a BlindBit server combined with
  [compact block filters][topic compact block filters] from P2P peers.

- **Stratum v2 releases and pool adoption:** The
  [Stratum v2][topic pooled mining] reference implementation released
  [sv2-apps v0.9.0][], which adds support for Bitcoin Core 32.x, including
  submitting found blocks over its IPC interface, and hardens its Job
  Declarator Client (see [Newsletter #384][news384 sv2] for previous
  coverage). Separately, MARA Foundation [announced][mara sv2] that MARA mined
  its first block using Stratum v2, and Foundry [announced][foundry sv2] that
  it has begun testing Stratum v2 on its pool.

- **Coinswap renamed to OpenSwap:** [OpenSwap v0.2.3][] is the first release
  under the new name of the [coinswap][topic coinswap] protocol implementation
  formerly called Coinswap (see [Newsletter #415][news415 coinswap]). It adds
  an Electrum server backend option, swaps that pay a third-party address,
  and, when built with Lightning support, swaps between onchain funds and LN
  through LDK Server (see [Newsletter #406][news406 ldk server]).

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

{% include snippets/recap-ad.md when="2026-11-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[7d5x9 dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060
[news340 braidpool]: /en/newsletters/2025/02/07/#request-for-a-covenant-design-supporting-braidpool
[news397 bip448]: /en/newsletters/2026/03/20/#bips-1974
[lb p2pool]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/2
[jungly dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/5
[roose dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/4
[eclair vuln del]: https://delvingbitcoin.org/t/disclosure-memory-exhaustion-dos-in-eclair-0-14-0/3057
[eclair 0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[eclair 0.14.1]: https://github.com/ACINQ/eclair/releases/tag/v0.14.1
[liana v16.0]: https://github.com/wizardsardine/liana/releases/tag/v16.0
[news424 bip138]: /en/newsletters/2026/09/25/#bips-1951
[coldcard 5.6.3]: https://blog.coinkite.com/coldcard-firmware-563-153q/
[wavelength mainnet]: https://lightning.engineering/posts/2026-10-23-wavelength-mainnet-launch/
[news415 wavelength]: /en/newsletters/2026/07/24/#wavelength-alpha-released
[bull payjoin blog]: https://www.bullbitcoin.com/blog/payjoin-trading
[news338 bull]: /en/newsletters/2025/01/24/#bull-bitcoin-mobile-wallet-adds-payjoin
[bull 6.14.0]: https://github.com/SatoshiPortal/bullbitcoin-mobile/releases/tag/v6.14.0
[breez 0.28.0]: https://github.com/breez/spark-sdk/releases/tag/0.28.0
[spscand delving]: https://delvingbitcoin.org/t/silent-payments-for-electrum/3078
[news419 sp electrum]: /en/newsletters/2026/08/21/#silent-payments-sender-plugin-for-electrum
[sv2-apps v0.9.0]: https://github.com/stratum-mining/sv2-apps/releases/tag/v0.9.0
[news384 sv2]: /en/newsletters/2025/12/12/#stratum-v2-updates
[mara sv2]: https://x.com/MARAFoundation_/status/2120520367500308580
[foundry sv2]: https://x.com/FoundryServices/status/2121279504475709625
[openswap v0.2.3]: https://github.com/citadel-foss/openswap/releases/tag/v0.2.3
[news415 coinswap]: /en/newsletters/2026/07/24/#coinswap-v0-2-2-released
[news406 ldk server]: /en/newsletters/2026/05/22/#ldk-server-announced
