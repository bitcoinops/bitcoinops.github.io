---
title: 'Bitcoin Optech Newsletter #367'
permalink: /en/newsletters/2025/08/15/
name: 2025-08-15-newsletter
slug: 2025-08-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections announcing new
release candidates and summarizing notable changes to popular Bitcoin
infrastructure software.

## News

_No significant news this week was found in any of our [sources][optech sources]._

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND v0.19.3-beta.rc1][] is a release candidate for a maintenance
  version for this popular LN node implementation containing "important
  bug fixes".  Most notably, "an optional migration [...] lowers disk
  and memory requirements for nodes significantly."

- [Bitcoin Core 29.1rc1][] is a release candidate for a maintenance
  version of the predominant full node software.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33050][] removes peer discouragement (see Newsletter
  [#309][news309 peer]) for consensus-invalid transactions because its DoS
  protection was ineffective. An attacker could circumvent the protection by
  spamming policy-invalid transactions without penalty. This update eliminates
  the need for double script validation because it is no longer necessary to
  distinguish between consensus and standardness failures, saving CPU costs.

- [Bitcoin Core #32473][] introduces a per-input cache for sighash
  pre-computation to the script interpreter for legacy (e.g. baremultisig),
  P2SH, P2WSH (and incidentally P2WPKH) inputs to reduce the impact of quadratic
  hashing attacks in standard transactions. Core caches an almost finished hash
  computed just before appending the sighash byte to reduce repeated hashing for
  standard multisig transactions and similar patterns. Another signature in the
  same input with the same sighash mode that commits to the same portion of the
  script can reuse most of the work. It is enabled in both policy (mempool) and
  consensus (block) validation. [Taproot][topic taproot] inputs already have
  that behavior by default, so this update doesn't need to be applied to them.

- [Bitcoin Core #33077][] creates a monolithic static library
  [`libbitcoinkernel.a`][libbitcoinkernel project] that bundles all the object
  files of its private dependencies into a single archive, allowing downstream
  projects to link to just this one file. See [Newsletter #360][news360 kernel]
  for related `libsecp256k1` groundwork.

- [Core Lightning #8389][] makes the `channel_type` field mandatory when opening
  a channel, aligning with a recent specification update (see [Newsletter
  #364][news364 spec]). The RPC commands `fundchannel` and `fundchannel_start`
  now report a channel type with the [zero-conf channel][topic zero-conf
  channels] option when a zero `minimum_depth` implies it.

{% include snippets/recap-ad.md when="2025-08-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33050,32473,33077,8389" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[news309 peer]: /en/newsletters/2024/06/28/#bitcoin-core-29575
[news360 kernel]: /en/newsletters/2025/06/27/#libsecp256k1-1678
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
[news364 spec]: /en/newsletters/2025/07/25/#bolts-1232
