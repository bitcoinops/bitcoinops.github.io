---
title: 'Bitcoin Optech Newsletter #338'
permalink: /en/newsletters/2025/01/24/
name: 2025-01-24-newsletter
slug: 2025-01-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a draft BIP for referencing unspendable
keys in descriptors, examines how implementations are using PSBTv2, and
corrects in depth our description last week of a new offchain DLC
protocol.  Also included are our regular sections describing changes to
services and client software, announcing new releases and release
candidates, and summarizing recent changes to popular Bitcoin
infrastructure software.

## News

- **Draft BIP for unspendable keys in descriptors:** Andrew Toth posted
  to [Delving Bitcoin][toth unspendable delv] and the [Bitcoin-Dev
  mailing list][toth unspendable ml] a [draft BIP][bips #1746] for
  referencing provably unspendable keys in [descriptors][topic
  descriptors].  This follows previous discussion (see [Newsletter
  #283][news283 unspendable]).  Using a provably unspendable key, also
  called a _nothing up my sleeve_ (NUMS) point, is particularly relevant
  for the [taproot][topic taproot] internal key.  If it's not possible
  to create a keypath spend using the internal key, then only a scriptpath
  spend using a tapleaf is possible (e.g., using a [tapscript][topic
  tapscript]).

  As of this writing, active discussion is occurring on the [PR][bips
  #1746] for the draft BIP.

- **PSBTv2 integration testing:** Sjors Provoost [posted][provoost
  psbtv2] to the Bitcoin-Dev mailing list to ask about software that had
  implemented support for version 2 [PSBTs][topic psbt] (see [Newsletter
  #141][news141 psbtv2]) in order to help test a [PR][bitcoin core
  #21283] adding support for it to Bitcoin Core.  An updated list of
  software using it may be [found][bse psbtv2] on the Bitcoin Stack
  Exchange.  We found two replies interesting:

  - **Merklized PSBTv2:** Salvatore Ingala [explains][ingala psbtv2]
    that the Ledger Bitcoin App converts the fields of a PSBTv2 into a
    merkle tree and initially sends only the root to a Ledger hardware
    signing device.  When specific fields are needed, they are sent
    along with the appropriate merkle proof.  This allows the device to
    safely work with each piece of information independently without
    having to store the entire PSBT in its constrained memory.  This is
    possible with PSBTv2 because it already has the parts of the
    unsigned transaction separated into distinct fields; for the
    original PSBT format (v0), this required additional parsing.

  - **Silent payments PSBTv2:** [BIP352][] specifying
    [silent payments][topic silent payments] explicitly depends on the
    [BIP370][] specification of PSBTv2.  Andrew Toth [explains][toth
    psbtv2] that silent payments need v2's `PSBT_OUT_SCRIPT` field since
    output script to use can't be known for silent payments until all
    signers have processed the PSBT.

- **Correction about offchain DLCs:** in our description of offchain
  DLCs in [last week's newsletter][news337 dlc], we confused the [new
  scheme][conduition factories] proposed by developer conduition with
  previously published and implemented offchain [DLC][topic dlc]
  schemes.  There's a significant and interesting difference:

  - The _DLC channels_ protocol mentioned in Newsletters
    [#174][news174 channels] and [#260][news260 channels] uses a
    mechanism similar to [LN-Penalty][topic ln-penalty]
    commit-and-revoke where parties _commit_ to a new state by signing
    it and then _revoke_ the old state by releasing a secret that allows
    their private version of the old state to be completely spent by
    their counterparty if it is published onchain.  This allows a DLC to
    be renewed through interaction between the parties.  For example,
    Alice and Bob do the following:

    1. Immediately agree to a DLC for the BTCUSD price a month from now.

    2. Three weeks later, agree to a DLC for the BTCUSD price two months
       from now and revoke the previous DLC.

  - The new _DLC factories_ protocol automatically revokes both parties'
    ability to publish states onchain at the time the contract matures
    by allowing any oracle attestation for the contract to serve as the
    secret that allows a private state to be completely spent by a
    counterparty if it is published onchain.  In effect this
    automatically cancels old states, which allows successive DLCs to be
    signed at the start of the factory without any further interaction
    required.  For example, Alice and Bob do the following:

    1. Immediately agree to a DLC for the BTCUSD price a month from now.

    2. Also immediately agree to a DLC for the BTCUSD price two months
       from now with a transaction [timelock][topic timelocks] that
       prevents it from being published until a month from now.  They
       can repeat this for month three, four, etc...

  In the DLC channels protocol, Alice and Bob can't create the second
  contract until they're ready to revoke the first contract, which
  requires interaction between them at that time.  In the DLC factories
  protocol, all contracts can be created at the time the factory is
  created and no further interaction is required; however, either party
  can still interrupt a series of contracts by going onchain with the
  currently safe-and-publishable version.

  If factory participants are able to interact after the contract is
  established, they can extend it---but they can't decide to use a
  different contract or different oracles until after all previously
  signed contracts have matured (unless they go onchain).  Although it
  may be possible to eliminate this shortcoming, this currently is the
  tradeoff for the reduced interactivity compared to the DLC channels
  protocol, which allows arbitrary contract changes at any time by
  mutual revocation.

  We thank conduition for informing us about our mistake in last week's
  newsletter and for patiently [answering][conduition reply] our
  questions.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BTCPay Server 2.0.6][] contains a "security fix for merchants using
  refunds/pull payments onchain with automated payout processors." Also
  included are several new features and bug fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31397][] improves the [orphan resolution process][news333 prclub] by tracking and
  using all potential peers that can provide missing parent transactions.
  Previously, the resolution process relied solely on the peer that originally
  provided the orphaned transaction. If the peer did not respond or returned a
  `notfound` message, there was no retry mechanism, resulting in likely
  transaction download failures. The new approach attempts to download the
  parent transaction from all candidate peers while maintaining bandwidth
  efficiency, censorship resistance, and effective load balancing. It is
  particularly beneficial for one-parent one-child (1p1c) [package relay][topic
  package relay], and it sets the stage for [BIP331][]'s receiver-initiated
  ancestor package relay.

- [Eclair #2896][] enables the storage of a [MuSig2][topic musig] peer’s partial
  signature instead of a traditional 2-of-2 multisig signature, as a
  prerequisite for a future implementation of [simple taproot channels][topic
  simple taproot channels]. Storing this allows a node to unilaterally broadcast
  a commitment transaction when needed.

- [LDK #3408][] introduces utilities for creating static invoices and their
  corresponding [offers][topic offers] in the `ChannelManager`, to support
  [async payments][topic async payments] in [BOLT12][] as specified in [BOLTs
  #1149][]. Unlike the regular offer creation utility, which requires the
  recipient to be online to serve invoice requests, the new utility accommodates
  recipients who are frequently offline. This PR also adds missing tests for
  paying static invoices (see Newsletter [#321][news321 async]), and ensures
  that invoice requests are retrievable when the recipient comes back online.

- [LND #9405][] makes the `ProofMatureDelta` parameter configurable, which
  determines the number of confirmations required before a [channel
  announcement][topic channel announcements] is processed in the gossip network.
  The default value is 6.

{% include snippets/recap-ad.md when="2025-01-28 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1746,21283,31397,2896,3408,9405,1149" %}
[news337 dlc]: /en/newsletters/2025/01/17/#offchain-dlcs
[conduition factories]: https://conduition.io/scriptless/dlc-factory/
[conduition reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news174 channels]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 channels]: /en/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs
[condution reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news283 unspendable]: /en/newsletters/2024/01/03/#how-to-specify-unspendable-keys-in-descriptors
[toth unspendable delv]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/31
[toth unspendable ml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a594150d-fd61-42f5-91cd-51ea32ba2b2cn@googlegroups.com/
[news141 psbtv2]: /en/newsletters/2021/03/24/#bips-1059
[provoost psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6FDAD97F-7C5F-474B-9EE6-82092C9073C5@sprovoost.nl/
[bse psbtv2]: https://bitcoin.stackexchange.com/a/125393/21052
[ingala psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMhCMoGONKFok_SuZkic+T=yoWZs5eeVxtwJL6Ei=yysvA8rrg@mail.gmail.com/
[toth psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/30737859-573e-40ea-9619-1d18c2a6b0f4n@googlegroups.com/
[btcpay server 2.0.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.6
[news321 async]: /en/newsletters/2024/09/20/#ldk-3140
[news333 prclub]: /en/newsletters/2024/12/13/#bitcoin-core-pr-review-club
