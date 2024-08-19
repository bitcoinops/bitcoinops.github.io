---
title: 'Bitcoin Optech Newsletter #317'
permalink: /en/newsletters/2024/08/23/
name: 2024-08-23-newsletter
slug: 2024-08-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion about an anti-exfiltration
protocol that only requires one round trip of communication between
a wallet and a signing device.  Also included are our regular sections
describing updates to clients and services, announcing new releases and
release candidates, and summarizing recent changes to popular Bitcoin
infrastructure software.

## News

- **Simple (but imperfect) anti-exfiltration protocol:** developer
  Moonsettler [posted][moonsettler exfil1] to Delving Bitcoin to describe an
  [anti-exfiltration][topic exfiltration-resistant signing] protocol.
  The same protocol has been described before (see Newsletters
  [#87][news87 exfil] and [#88][news88 exfil]), with Pieter Wuille
  [citing][wuille exfil1] the earliest known description of the
  technique for anti-exfil being a [2014 post][maxwell exfil] by Gregory
  Maxwell.

  The protocol uses the sign-to-contract protocol to allow a software
  wallet to contribute entropy to the nonce selected by a hardware
  signing device in a way that allows the software wallet to later
  verify the entropy was used.  Sign-to-contract is a variation on
  [pay-to-contract][topic p2c]: in pay-to-contract, the receiver's
  public key is tweaked; in sign-to-contract, the spender's signature
  nonce is tweaked.

  The advantage of this protocol, compared to the protocol implemented
  for BitBox02 and Jade hardware signing devices (see [Newsletter
  #136][news136 exfil]), is that it only requires one round trip of
  communication between the software wallet and the hardware signing
  device.  That one round trip can be combined with the other steps
  necessary to sign for a single-sig or scripted multisig transaction,
  meaning the technique doesn't affect user workflows.  The currently
  deployed technique, which is also based on sign-to-contract, requires
  two round trips; that's more than required for most users today,
  although multiple round trips may be required for users who upgrade to
  using [scriptless multisignatures][topic multisignature] and
  [scriptless threshold signatures][topic threshold signature].  For
  users who connect their signing devices directly to their computers or
  who use an interactive wireless communication protocol like Bluetooth,
  the number of round trips doesn't matter.  But, for users who prefer
  to keep their devices airgapped, each roundtrip requires two manual
  interventions---which can quickly add up to an annoying amount of work
  when signing frequently or using multiple devices for scripted
  multisignatures.

  The disadvantage of this protocol was mentioned by Maxwell in his
  original description, it "leaves open a [side-channel][topic side
  channels] that has exponential cost per additional bit, via grinding
  [...] but it eliminates the obvious and very powerful attacks where
  everything is leaked in a single signature.  This is clearly less
  good, but it's only a two-move protocol, so many places that wouldn't
  consider using a countermeasure could pick this up for free just as an
  element of a protocol spec."

  This protocol is a clear upgrade over not using anti-exfiltration at
  all and Pieter Wuille [notes][wuille exfil2] that it is probably the
  best possible anti-exfiltration with single-round signing.
  However, Wuille advocates for the deployed two-round anti-exfiltration
  protocol to prevent even grinding-based exfiltration.

  Discussion was ongoing at the time of writing.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 24.08rc2][] is a release candidate for the next major
  version of this popular LN node implementation.

- [LND v0.18.3-beta.rc1][] is a release candidate for a minor bug fix
  release of this popular LN node implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #28553][] validation: assumeutxo params mainnet

- [Bitcoin Core #30246][] contrib: asmap-tool - Compare ASMaps with respect to specific addresses

- [Bitcoin Core GUI #824][] Migrate legacy wallets that are not loaded

- [Core Lightning #7540][] renepay: add const probability cost

- [Core Lightning #7403][] renepay: add a channel filtering paymod

- [LND #8943][] Roasbeef/alloy-linear-fee-model <!-- mainly looking for a mention of Alloy and how it could be useful to other Bitcoin projects; probably only need a short mention of the fee function bug fix -->

- [BDK #1478][] Allow opting out of getting `LocalChain` updates with `FullScanRequest`/`SyncRequest` structures

- [BDK #1533][] Enable support for single descriptor wallets

- [BOLTs #1182][] BOLT 4: clarify blinded path requirements.

- [BLIPs #39][] blip-0039: BOLT 11 Invoice Blinded Path Tagged Field

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28553,30246,824,7540,7403,8943,1478,1533,1182,39" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[moonsettler exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081
[wuille exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/3
[wuille exfil2]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/7
[news87 exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 exfil]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[maxwell exfil]: https://bitcointalk.org/index.php?topic=893898.msg9861102#msg9861102
[news136 exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
