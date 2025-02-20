---
title: 'Bitcoin Optech Newsletter #342'
permalink: /en/newsletters/2025/02/21/
name: 2025-02-21-newsletter
slug: 2025-02-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an idea for allowing mobile wallets to
settle LN channels without extra UTXOs and summarizes continued
discussion about adding a quality-of-service flag for LN pathfinding.
Also included are our regular sections describing recent changes to
clients, services, and popular Bitcoin infrastructure software.

## News

- **Allowing mobile wallets to settle channels without extra UTXOs:**
  Bastien Teinturier [posted][teinturier mobileclose] to Delving Bitcoin
  about an opt-in variation of [v3 commitments][topic v3 commitments]
  for LN channels that would allow mobile wallets to settle channels
  using the funds within the channel for all cases where theft is
  possible.  They wouldn't need to keep an onchain UTXO in reserve to
  pay closing fees.

  Teinturier starts by outlining the four cases that require a mobile
  wallet to broadcast a transaction:

  1. Their peer broadcasts a revoked commitment transaction, e.g. the
     peer is attempting to steal funds.  In this case, the mobile wallet
     immediately gains the ability to spend all of the channel's funds,
     allowing it to use those funds to pay for fees.

  2. The mobile wallet has sent a payment that hasn't been settled yet.
     Theft is impossible in this case, as their remote peer can only
     claim the payment by providing the [HTLC][topic htlc] preimage
     (i.e., proof that the ultimate recipient was paid).  Since theft
     isn't possible, the mobile wallet can take its time finding a UTXO
     to pay for closing fees.

  3. There are no pending payments but the remote peer is unresponsive.
     Again, theft isn't possible here, so the mobile wallet can take its
     time closing.

  4. The mobile wallet is receiving an HTLC.  In this case, the remote
     peer can accept the HTLC preimage (allowing it to claim funds from
     its upstream peers) but not update the settled channel balance and
     revoke the HTLC.  In this case, the mobile wallet must force-close
     the channel within a relatively small number of blocks.  This is
     the case addressed in the rest of the post.

  Teinturier proposes having the remote peer sign two different versions
  of each HTLC paying the mobile wallet: a zero-fee version according
  to the default policy for zero-fee commitments and a fee-paying
  version at feerate that will currently confirm quickly.  The fees are
  deducted from the HTLC value paid to the mobile wallet, so it doesn't
  cost the remote peer anything to offer this option and the mobile
  wallet has an incentive to only use it if really necessary.
  Teinturier does [note][teinturier mobileclose2] that there are some
  safety considerations for the remote peer paying too much to fees, but
  he expects those to be easy to address.

- **Continued discussion about an LN quality of service flag:** Joost
  Jager [posted][jager lnqos] to Delving Bitcoin to continue discussion
  about adding a quality of service (QoS) flag to the LN protocol to
  allow nodes to signal that one of their channels was highly available
  (HA)---able to forward payments up to a specified amount with 100%
  reliability (see [Newsletter #239][news239 qos]).  If a spender
  chooses an HA channel and the payment fails at that channel, then the
  spender will penalize the operator by never using that channel again.
  Since previous discussion, Jager has proposed node-level signaling
  (perhaps by simply appending "HA" to the node's text alias), noted
  that the protocol's current error messages don't guarantee detection
  of the channel where a payment failed, and suggested that this isn't
  something that can be both signaled and used on an entirely opt-in
  basis---so not requiring widespread agreement---so it should be
  specified for compatibility even if very few spending and forwarding
  nodes end up using it.

  Matt Corallo [replied][corallo lnqos] that LN pathfinding currently
  works well and linked to a [detailed document][ldk path] describing
  LDK's approach to pathfinding, which extends the approach originally
  described by René Pickhardt and Stefan Richter (see [Newsletter
  #163][news163 pr paper] and [two items][news270 ldk2547] in
  [Newsletter #270][news270 ldk2534]).  However, he's concerned that a
  QoS flag will encourage future software to implement less reliable
  pathfinding and to simply prefer only using HA channels.  In that
  case, large nodes can sign agreements with their large peers to
  temporarily use trust-based liquidity when a channel is depleted, but
  smaller nodes dependent on trustless channels will have to use
  expensive [JIT rebalancing][topic jit routing] that will make their
  channels less profitable (if they absorb the cost) or less desirable
  (if they pass the cost on to spenders).

  Jager and Corallo continued discussing without coming to a clear
  resolution.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Ark Wallet SDK released:**
  The [Ark Wallet SDK][ark sdk github] is TypeScript library for building
  wallets that support both onchain Bitcoin and the [Ark][topic ark] protocol
  across [testnet][topic testnet], [signet][topic signet], [Mutinynet][new252
  mutinynet], and mainnet (not currently recommended).

- **Zaprite adds BTCPay Server support:**
  Bitcoin and Lightning payment integrator [Zaprite][zaprite website] adds
  BTCPay Server to their list of supported wallet connections.

- **Iris Wallet desktop released:**
  [Iris Wallet][iris github] supports sending, receiving, and issuing assets
  using the [RGB][topic client-side validation] protocol.

- **Sparrow 2.1.0 released:**
  The Sparrow [2.1.0 release][sparrow 2.1.0] replaces the previous [HWI][topic hwi]
  implementation with [Lark][news333 lark] and adds [PSBTv2][topic psbt] support, among other updates.

- **Scure-btc-signer 1.6.0 released:**
  [Scure-btc-signer][scure-btc-signer github]'s [1.6.0][scure-btc-signer 1.6.0]
  release adds support for version 3 ([TRUC][topic v3 transaction relay])
  transactions and [pay-to-anchors (P2A)][topic ephemeral anchors]. Scure-btc-signer is part
  of the [scure][scure website] suite of libraries.

- **Py-bitcoinkernel alpha:**
  [Py-bitcoinkernel][py-bitcoinkernel github] is a Python library for
  interacting with [libbitcoinkernel][Bitcoin Core #27587], a library
  [encapsulating Bitcoin Core's validation logic][kernel blog].

- **Rust-bitcoinkernel library:**
  [Rust-bitcoinkernel][rust-bitcoinkernel github] is an experimental Rust library for
  using libbitcoinkernel to read block data and validate transaction outputs and blocks.

- **BIP32 cbip32 library:**
  The [cbip32 library][cbip32 library] implements [BIP32][] in C using
  libsecp256k1 and libsodium.

- **Lightning Loop moves to MuSig2:**
  Lightning Loop's swap service now uses [MuSig2][topic musig] as outlined in a
  [recent blog post][loop blog].

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #27432][] introduces a Python script that converts the compact
  serialized UTXO set generated by the `dumptxoutset` RPC command (designed
  specifically for [AssumeUTXO][topic assumeutxo] snapshots) into a SQLite3
  database. While extending the `dumptxoutset` RPC itself to output a SQLite3
  database was considered, it was ultimately rejected due to the increased
  maintenance burden. The script adds no additional dependencies and the
  resulting database is about twice the size of the compact serialized UTXO set.

- [Bitcoin Core #30529][] fixes the handling of negated options such as
  `noseednode`, `nobind`, `nowhitebind`, `norpcbind`, `norpcallowip`,
  `norpcwhitelist`, `notest`, `noasmap`, `norpcwallet`, `noonlynet`, and
  `noexternalip` to behave as expected. Previously, negating these options
  caused confusing and undocumented side effects, but now it simply clears the
  specified settings to restore the default behaviour.

- [Bitcoin Core #31384][] resolves an issue where the 4,000 weight units (WU)
  reserved for the block header, transaction count and coinbase transaction were
  inadvertently applied twice, reducing the maximum block template size by an
  unnecessary 4,000 WU to 3,992,000 WU (see Newsletter [#336][news336
  weightbug]). This fix consolidates the reserved weight into a single instance
  and introduces a new `-blockreservedweight` startup option to allow users to
  customize the reserved weight. Safety checks are added to ensure that the
  reserved weight is set to a value between 2,000 WU and 4,000,000 WU, otherwise
  Bitcoin Core will fail to start.

- [Core Lightning #8059][] implements suppression of [multipath payments][topic
  multipath payments] (MPP) on the `xpay` plugin (see Newsletter [#330][news330
  xpay]) when paying a [BOLT11][] invoice that doesn't support this feature. The
  same logic will be extended to [BOLT12][topic offers] invoices, but will have
  to wait until the next release, as this PR also enables advertising BOLT12
  features to plugins, explicitly allowing BOLT12 invoices to be paid with MPP.

- [Core Lightning #7985][] adds support for paying [BOLT12][topic offers]
  invoices in the `renepay` plugin (see Newsletter [#263][news263 renepay]) by
  enabling routing through [blinded paths][topic rv routing] and replacing
  renepay's internal usage of the `sendpay` RPC command with `sendonion`.

- [Core Lightning #7887][] adds support for handling the new [BIP353][] fields
  for Human Readable Name (HRN) resolution to conform with the latest BOLTs
  updates (see Newsletter [#290][news290 hrn] and [#333][news333 hrn]). The PR
  also adds the `invreq_bip_353_name` field to invoices, enforces restrictions
  on incoming BIP353 name fields, and allows users to specify BIP353 names on
  the `fetchinvoice` RPC, as well as wording changes.

- [Eclair #2967][] adds support for the `option_simple_close` protocol as
  specified in [BOLTs #1205][]. This simplified variant of the mutual close
  protocol is a prerequisite for [simple taproot channels][topic simple taproot
  channels], as it enables nodes to safely exchange nonces during the
  `shutdown`, `closing_complete` and `closing_sig` phases, which is required to
  spend a [MuSig2][topic musig] channel output.

- [Eclair #2979][] adds a verification step to confirm that a node supports
  wake up notifications (see Newsletter [#319][news319 wakeup]) before
  initiating the wake up flow to relay a [trampoline payment][topic trampoline
  payments]. For standard channel payments, this check is unnecessary because
  the [BOLT11][] or [BOLT12][topic offers] invoice already indicates support for
  wake-up notifications.

- [Eclair #3002][] introduces a secondary mechanism to process blocks and their
  confirmed transactions to trigger watches, for added security. This is
  particularly useful when a channel is spent but the spending transaction
  hasn't been detected in the mempool. While the ZMQ `rawtx` topic handles this,
  it can be unreliable and may silently drop events when using remote `bitcoind`
  instances. Whenever a new block is found, the secondary system fetches the
  last N blocks (6 by default) and reprocesses their transactions.

- [LDK #3575][] implements the [peer storage][topic peer storage] protocol as a
  feature that allows nodes to distribute and store backups for channel peers.
  It introduces two new message types, `PeerStorageMessage` and
  `PeerStorageRetrievalMessage`, along with their respective handlers, to enable
  the exchange of these backups between nodes.  Peer data is stored persistently
  within `PeerState` in the `ChannelManager`.

- [LDK #3562][] introduces a new scorer (see Newsletter [#308][news308 scorer])
  that merges scoring benchmarks based on frequent [probing][topic payment
  probes] of actual payment paths from an external source. This allows light
  nodes, which typically have a limited view of the network, to improve payment
  success rates by incorporating external data such as scores provided by a
  Lightning Service Provider (LSP). The external score can either be combined
  with or override the local score.

- [BOLTs #1205][] merges the `option_simple_close` protocol, which is a
  simplified variant of the mutual close protocol required for [simple taproot
  channels][topic simple taproot channels]. Changes are made to [BOLT2][] and
  [BOLT3][].

{% include snippets/recap-ad.md when="2025-02-25 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27432,30529,31384,8059,7985,7887,2967,2979,3002,3575,3562,1205,27587" %}
[news239 qos]: /en/newsletters/2023/02/22/#ln-quality-of-service-flag
[news163 pr paper]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news270 ldk2547]: /en/newsletters/2023/09/27/#ldk-2547
[news270 ldk2534]: /en/newsletters/2023/09/27/#ldk-2534
[teinturier mobileclose]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453
[teinturier mobileclose2]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453/3
[jager lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438
[corallo lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438/4
[ldk path]: https://lightningdevkit.org/blog/ldk-pathfinding/
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[news263 renepay]: /en/newsletters/2023/08/09/#core-lightning-6376
[news290 hrn]: /en/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-instructions
[news333 hrn]: /en/newsletters/2024/12/13/#bolts-1180
[news319 wakeup]: /en/newsletters/2024/09/06/#eclair-2865
[news308 scorer]: /en/newsletters/2024/06/21/#ldk-3103
[news336 weightbug]: /en/newsletters/2025/01/10/#investigating-mining-pool-behavior-before-fixing-a-bitcoin-core-bug
[ark sdk github]: https://github.com/arklabshq/wallet-sdk
[new252 mutinynet]: /en/newsletters/2023/05/24/#mutinynet-announces-new-signet-for-testing
[zaprite website]: https://zaprite.com
[iris github]: https://github.com/RGB-Tools/iris-wallet-desktop
[sparrow 2.1.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.1.0
[news333 lark]: /en/newsletters/2024/12/13/#java-based-hwi-released
[scure-btc-signer github]: https://github.com/paulmillr/scure-btc-signer
[scure-btc-signer 1.6.0]: https://github.com/paulmillr/scure-btc-signer/releases
[scure website]: https://paulmillr.com/noble/#scure
[py-bitcoinkernel github]: https://github.com/stickies-v/py-bitcoinkernel
[rust-bitcoinkernel github]: https://github.com/TheCharlatan/rust-bitcoinkernel
[kernel blog]: https://thecharlatan.ch/Kernel/
[cbip32 library]: https://github.com/jamesob/cbip32
[loop blog]: https://lightning.engineering/posts/2025-02-13-loop-musig2/
