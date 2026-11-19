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

- **Continued discussion of stale tip relay:** Antoine Poinsot
  [replied][poinsot staletip] to the Bitcoin-Dev mailing list thread about
  [BIP332][] stale tip relay (see Newsletters [#417][news417 staletip] and
  [#423][news423 staletip]) to suggest that nodes initially relay only the
  headers of stale blocks. Poinsot argued that headers are enough to make stale
  blocks observable. Relaying the block data as well lets nodes reorganize
  faster to a chain built on a stale block, which increases the expected
  revenue of a miner that briefly keeps mining on its own block after losing a
  block race. Poinsot [considered][poinsot staletip2] that effect most likely
  small but not worth working out rigorously.

  Anthony Towns [replied][towns staletip] that any miner who would benefit can
  cheaply implement stale block relay itself. Towns
  [estimated][towns staletip2] that a pool with 20% of network hashrate already
  gains about 16.1 BTC per year by mining on its own block instead of a
  competing block it saw first at the same height, and that cutting the relay
  delay of the resulting one-block reorg from five seconds to one would raise
  that to 16.36 BTC. Towns also argued that stale headers can raise concerns,
  such as possible [selfish mining][topic selfish mining], but only the block
  data can settle them. Poinsot [agreed][poinsot staletip3] that the estimate
  appears to cover the effect on honest mining incentives and, while still
  seeing most of the value in headers, did not want to block relaying full
  blocks.

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

- [Bitcoin Core #36757][] fixes a privacy leak in address discovery over [Tor
  and I2P][topic anonymity networks]. Previously, when a node connected
  outbound to a malicious Tor or I2P peer, that peer could claim to see the
  node at an arbitrary routable IP address in its `version` message. Bitcoin
  Core could then advertise that address back to the peer, along with its own
  clearnet listening port. A distinctive port could then help correlate the
  connection with a clearnet node that was observed using the same port (see
  [Newsletter #52][news52 port] for an earlier Tor listening-port fix). Bitcoin
  Core now ignores the address that Tor and I2P peers report seeing the
  node at.

- [BIPs #2356][] replaces the placeholder genesis parameters in [BIP95][] with
  those of the mined [testnet5][topic testnet] genesis block and marks the BIP
  as `Deployed`. The genesis coinbase includes the date 2026-11-14 and the hash
  of mainnet block 975,744. Committing to that hash ensures that the testnet5
  genesis block could only be mined after mainnet reached that height (see
  [Newsletter #431][news431 testnet5]).

- [Core Lightning #9730][] adds the `lightning-hsmtool recoverhtlc` command to
  manually recover [HTLC][topic htlc] outputs after local channel-state loss.
  Once the peer publishes its latest commitment transaction, the recovering
  node can already reclaim its main output using a [static channel
  backup][topic static channel backups] (see [Newsletter #421][news421
  recovery]). Given the local `hsm_secret`, channel and HTLC details, and the
  peer's per-commitment point, the new command identifies matching HTLC
  outputs. The tool constructs signed transactions to reclaim outgoing HTLCs
  after a timeout or to claim incoming HTLCs with known preimages. However, the
  operator must manually review and broadcast the transactions. A cooperative
  CLN peer can export the public point using the
  `dumpcommitments --point-only` command without revealing secrets.

- [LDK #5561][] fixes a potential loss of forwarded funds when a peer sends
  `revoke_and_ack` before LDK sends the corresponding `commitment_signed`
  message. Previously, LDK could accept this premature acknowledgment and
  advance its internal commitment number. Consequently, it could sign a
  commitment that differed from the one recorded by its onchain monitor. If the
  peer published that commitment, LDK might fail to claim the incoming HTLC,
  even after paying the outgoing HTLC, despite knowing its preimage. LDK now
  rejects the premature acknowledgment and force closes the channel. The fix
  was released in LDK 0.2.8 (see [Newsletter #431][news431 ldk]). [Newsletter
  #426][news426 ldk5057] described an earlier bug that left a signed commitment
  unmonitored during reconnection.

- [LDK #5562][] and [#5545][ldk #5545] fix channel ID collisions that a
  malicious peer could create between its channels and an LDK node. In the
  first, the peer could reuse a force-closed channel's known ID as a new
  channel's temporary ID. This could prevent LDK from recording a forwarded
  payment's preimage in the closed channel's monitor, leaving the incoming
  [HTLC][topic htlc] unclaimed after the outgoing HTLC had been paid. In the
  second, the peer could calculate a channel's future final ID from its funding
  transaction and submit another opening request with that temporary ID. If the
  original channel adopted its final ID before the application accepted the new
  request, acceptance could overwrite its funded state. LDK now rejects
  conflicting IDs and rechecks them at acceptance. Both fixes were also
  released in LDK 0.2.8. See [Newsletter #427][news427 channelid] for related
  channel ID collisions that could cause a DoS in Eclair.

- [LDK #5557][] fixes a vulnerability that allowed malicious peers to disrupt
  transaction monitoring on nodes using an Electrum backend. The peer could
  propose a channel whose claimed funding output reused an already-watched
  outpoint, but with a different locking script. Registering that proposal
  could overwrite the legitimate watch's stored script, even if LDK
  subsequently rejected the channel. LDK would then query Electrum for
  transactions associated with the bogus script and might miss a transaction
  spending the real output, preventing a timely response to a channel closure.
  LDK now retains every distinct script registered for an outpoint, so a bogus
  registration cannot suppress the legitimate watch. This fix was also released
  in LDK 0.2.8.

- [LDK #5558][] and [#5482][ldk #5482] fix two ways payments could exceed their
  fee budget. The first PR addresses the handling of an omitted fee-limit
  setting for [async payments][topic async payments] using static
  [BOLT12][topic offers] invoices (see [Newsletter #321][news321 async]). LDK
  now applies its default cap of 1% of the payment amount plus 50 sat when the
  application omits the setting. Previously, omitting it removed the limit
  entirely, allowing a malicious receiver to supply a [blinded path][topic rv
  routing] with excessive fees. This fix was also released in LDK 0.2.8. The
  second PR addresses retries when a route adds value to meet an HTLC minimum.
  LDK treated the extra value as part of the requested payment and restored the
  failed path's fee budget on retry, allowing the total spend to exceed its
  limit. LDK now retries only the remaining amount owed and counts any excess
  against the remaining fee budget.

- [LND #11555][] changes how LND reports non-[AMP][topic amp] invoices as
  settled. Although applications could already monitor when the settlement of
  individual [HTLCs][topic htlc] was locked in offchain (see [Newsletter
  #224][news224 finality]), LND could mark an invoice as settled as soon as the
  preimage was released. The invoice now enters the `PENDING_SETTLE` state on
  preimage release. Once every HTLC in the payment has a final offchain or
  onchain outcome, LND marks the invoice as `SETTLED` if all parts were
  collected or `CANCELED` if any failed. A canceled invoice can still have
  collected some parts, which are not refunded, so applications should credit
  only the amounts from finalized, successful HTLCs. An invoice's
  `preimage_released` flag records whether LND has committed to releasing the
  preimage. AMP payment sets still settle at preimage release.

- [LND #11551][] fixes expiry validation when completing [multipath
  payments][topic multipath payments] and [AMP][topic amp] payments.
  Previously, LND checked each HTLC when it arrived. If more blocks were mined
  while the receiver waited for the remaining parts, LND could release
  preimages even though an earlier HTLC no longer had the required [expiry
  margin][topic cltv expiry delta] for onchain collection. Now, LND rechecks
  every part against the current block height when the final part arrives. If a
  previously accepted part is now too close to expiry, LND fails that set and
  leaves the invoice open for another attempt (see [Newsletter #424][news424
  amp] for earlier work on canceling individual AMP sets).

- [LND #11472][] and [#10842][lnd #10842] fix cases where temporary backend
  errors or one problematic input could block otherwise valid sweeps. The first
  keeps inputs available for retry after temporary or unclassified errors
  during mempool acceptance checks (see [Newsletter #373][news373 sweeper]). It
  was released in LND 0.21.8-beta and 0.20.8-beta (see [Newsletter
  #431][news431 lnd]). The second uses diagnostic transactions that are never
  broadcast to test subsets of a rejected batch. If an invalid or conflicting
  input can be identified, LND excludes it from the next attempt and retries
  the remaining inputs.

- [LND #11542][] fixes recovery of forwarded [HTLCs][topic htlc] after channel
  reconnections. When replaying stored forwarding batches, LND could filter out
  acknowledged HTLCs and then use the remaining entries' new positions to look
  up metadata indexed by their original positions. This could cause unresolved
  HTLCs to be skipped or misassociated. Additionally, if a channel's HTLC
  handler stopped after LND recorded the batch but before handing off an HTLC,
  an incomplete record could be left behind, causing retries to be discarded as
  duplicates. LND now preserves the original batch indexes and removes
  incomplete records after a failed handoff, allowing unresolved HTLCs to be
  retried. The fix was released in LND 0.21.8-beta and 0.20.8-beta (see
  [Newsletter #431][news431 lnd]).

{% include snippets/recap-ad.md when="2026-11-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="36757,2356,9730,5561,5562,5545,5557,5558,5482,11555,11551,11472,10842,11542" %}
[7d5x9 dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060
[news340 braidpool]: /en/newsletters/2025/02/07/#request-for-a-covenant-design-supporting-braidpool
[news397 bip448]: /en/newsletters/2026/03/20/#bips-1974
[lb p2pool]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/2
[jungly dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/5
[roose dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/4
[eclair vuln del]: https://delvingbitcoin.org/t/disclosure-memory-exhaustion-dos-in-eclair-0-14-0/3057
[eclair 0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[eclair 0.14.1]: https://github.com/ACINQ/eclair/releases/tag/v0.14.1
[poinsot staletip]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/qJIADCfABgAJ
[news417 staletip]: /en/newsletters/2026/08/07/#draft-bip-for-stale-tip-relay
[news423 staletip]: /en/newsletters/2026/09/18/#bips-2241
[poinsot staletip2]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/ORRffqwZAgAJ
[towns staletip]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/NF7UNdJoAQAJ
[towns staletip2]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/Kt4orC5bAAAJ
[poinsot staletip3]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/NqK6HjiAAQAJ
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
[LDK #5561]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5561
[LDK #5562]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5562
[LDK #5545]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5545
[LDK #5557]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5557
[LDK #5558]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5558
[LDK #5482]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5482
[news52 port]: /en/newsletters/2019/06/26/#bitcoin-core-15651
[news431 testnet5]: /en/newsletters/2026/11/13/#testnet5-genesis-block-to-be-mined
[news421 recovery]: /en/newsletters/2026/09/04/#core-lightning-9435
[news431 ldk]: /en/newsletters/2026/11/13/#ldk-v0-2-8
[news426 ldk5057]: /en/newsletters/2026/10/09/#ldk-5057
[news427 channelid]: /en/newsletters/2026/10/16/#disclosure-of-two-dos-vulnerabilities-fixed-in-eclair-v0-14-1
[news321 async]: /en/newsletters/2024/09/20/#ldk-3140
[news224 finality]: /en/newsletters/2022/11/02/#lnd-6517
[news424 amp]: /en/newsletters/2026/09/25/#lnd-11198
[news373 sweeper]: /en/newsletters/2025/09/26/#lnd-10189
[news431 lnd]: /en/newsletters/2026/11/13/#lnd-v0-21-8-beta
