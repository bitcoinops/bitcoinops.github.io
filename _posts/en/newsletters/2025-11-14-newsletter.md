---
title: 'Bitcoin Optech Newsletter #380'
permalink: /en/newsletters/2025/11/14/
name: 2025-11-14-newsletter
slug: 2025-11-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with announcements of new
releases and release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

_No significant news this week was found in any of our [sources][optech sources]._

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.20.0-beta.rc4][] is a release candidate for a new version of this
  popular LN node implementation that introduces multiple bug fixes, a new
  noopAdd [HTLC][topic htlc] type, support for [P2TR][topic taproot] fallback
  addresses on BOLT11 invoices, and many RPC and `lncli` additions and
  improvements. See the [release notes][]. {% assign timestamp="1:30" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30595][] introduces a C header that serves as an API for
  `libbitcoinkernel` (see Newsletter [#191][news191 lib], [#198][news198 lib],
  [#367][news367 lib]), enabling external projects to interface with Bitcoin
  Core’s block validation and chainstate logic via a reusable C library.
  Currently, it is limited to operations on blocks and has feature parity with
  the now-defunct `libbitcoin-consensus` (see [Newsletter #288][news288 lib]).
  Use cases `libbitcoinkernel` include alternative node implementations, an Electrum server index
  builder, a [silent payment][topic silent payments] scanner, a block analysis
  tool, and a script validation accelerator, among others. {% assign timestamp="2:56" %}

- [Bitcoin Core #33443][] reduces excessive logging when replaying blocks after
  a restart that interrupted a reindex. Now, it emits one message for the full
  range of blocks being processed, as well as additional progress logs every
  10,000 blocks, rather than one log per block. {% assign timestamp="28:03" %}

- [Core Lightning #8656][] makes [P2TR][topic taproot] the default address when
  using the `newaddr` endpoint without specifying an address type, replacing
  P2WPSH. {% assign timestamp="29:42" %}

- [Core Lightning #8671][] adds an `invoice_msat` field to the `htlc_accepted`
  hook, enabling plugins to override the effective invoice amount during payment
  checks. Specifically, it uses the [HTLC][topic htlc]’s amount when it differs
  from the invoice amount. This is useful in cases when an LSP charges a fee to
  forward an HTLC. {% assign timestamp="30:22" %}

- [LDK #4204][] enables peers to abort a [splice][topic splicing] without
  force-closing the channel, as long as it happens before signatures are
  exchanged. Previously, any `tx_abort` during splice negotiation would
  unnecessarily trigger a force close; now this only happens after signatures
  have been exchanged. {% assign timestamp="33:09" %}

- [BIPs #2022][] updates [BIP3][] (see [Newsletter #344][news344 bip3]) to
  clarify how BIP numbers are assigned. "A number may be considered assigned
  only after it has been publicly announced in the pull request by a BIP
  Editor." Announcements on social media or a provisional entry to the internal
  editor notes should not constitute an assignment. {% assign timestamp="34:45" %}

{% include snippets/recap-ad.md when="2025-11-18 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30595,33443,8656,8671,4204,2022" %}
[LND 0.20.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc4
[release notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[news191 lib]: /en/newsletters/2022/03/16/#bitcoin-core-24304
[news198 lib]: /en/newsletters/2022/05/04/#bitcoin-core-24322
[news367 lib]: /en/newsletters/2025/08/15/#bitcoin-core-33077
[news288 lib]: /en/newsletters/2024/02/07/#bitcoin-core-29189
[news344 bip3]: /en/newsletters/2025/03/07/#bips-1712