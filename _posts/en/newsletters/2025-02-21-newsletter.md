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

FIXME:bitschmidty

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #27432][] utxo-to-sqlite tool

- [Bitcoin Core #30529][] Fix -norpcwhitelist, -norpcallowip, and similar corner case behavior

- [Bitcoin Core #31384][] mining: bugfix: Fix duplicate coinbase tx weight reservation

- [Core Lightning #8059][] see https://github.com/ElementsProject/lightning/pull/8059/commits/c520fad006505e9d2d037ee1aad548aa354fe0c4 and https://github.com/ElementsProject/lightning/pull/8059/commits/91251082d898394052c204129128440a1acb0e78 and https://github.com/ElementsProject/lightning/pull/8059/commits/068d5b1d89d3dec91e60ed47ec12ded3b08720f7

- [Core Lightning #7985][] renepay support for BOLT12

- [Core Lightning #7887][] decode: handle new bip353 fields.

- [Eclair #2967][] Implement `option_simple_close`

- [Eclair #2979][] Check peer features before attempting wake-up (#2979)

- [Eclair #3002][] Secondary mechanism to trigger watches for transactions from past blocks (#3002)

- [LDK #3575][] PeerStorage: Add feature and store peer storage in ChannelManager

- [LDK #3562][] joostjager/merge-scores

- [BOLTs #1205][] option_simple_close

{% include snippets/recap-ad.md when="2025-02-25 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27432,30529,31384,8059,7985,7887,2967,2979,3002,3575,3562,1205" %}
[news239 qos]: /en/newsletters/2023/02/22/#ln-quality-of-service-flag
[news163 pr paper]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news270 ldk2547]: /en/newsletters/2023/09/27/#ldk-2547
[news270 ldk2534]: /en/newsletters/2023/09/27/#ldk-2534
[teinturier mobileclose]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453
[teinturier mobileclose2]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453/3
[jager lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438
[corallo lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438/4
[ldk path]: https://lightningdevkit.org/blog/ldk-pathfinding/
