---
title: 'Bitcoin Optech Newsletter #427'
permalink: /en/newsletters/2026/10/16/
name: 2026-10-16-newsletter
slug: 2026-10-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **Disclosure of two DoS vulnerabilities fixed in Eclair v0.14.1**: Erick
  Cestari [posted][ec eclair dos] to Delving Bitcoin the [responsible
  disclosure][topic responsible disclosures] of two denial-of-service (DoS)
  vulnerabilities in the channel opening process of Eclair v0.14.0 and earlier.
  Both were fixed in [Eclair #3324][] and released in [v0.14.1][news416 eclair
  0.14.1] in July, and users running an older version should upgrade.

  The first, found by Matt Morehouse with his [smite][smite repo] fuzzer, is a
  race condition in a duplicate `temporary_channel_id` check. Eclair checked
  whether the ID was already in use before accepting an `open_channel` message,
  but did not record the new channel until a later step, so an attacker sending
  several identical `open_channel` messages in quick succession could get two
  past the check. Eclair then created two channel states for one ID, and the
  second replaced the first, leaving an unreachable channel state that held
  about 25 kB of memory until the peer disconnected. Repeating the attack leaked
  about 1 MB per second until the node ran out of memory or spent all of its CPU
  on garbage collection.

  The second, found by Cestari, bypasses Eclair's limit on the number of pending
  channels whose funding transaction has not confirmed. The duplicate check only
  looked at temporary IDs, so an attacker could start opening a channel, then
  reuse that channel's final `channel_id` as the `temporary_channel_id` of the
  next `open_channel`. The limiter counted the reused ID twice and dropped both
  entries once the new channel received its final ID, so its count never rose
  above two while the number of pending channels grew without bound. Each
  pending channel stores a copy of the peer's `init` features, and setting a
  single unknown odd feature bit at a very high position inflated that copy to
  about 65 kB. In Cestari's test, one connection with no onchain cost exhausted
  a node's 4 GB of memory in about 48 minutes. Because pending channels are
  written to the database, the node crashed again on every restart until its
  memory limit was raised or the rows were deleted by hand.

  Replying to a question, Morehouse noted that mobile wallets that use an Eclair
  node as their LSP, such as Phoenix, are unaffected because ACINQ patched its
  nodes months ago.

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

{% include snippets/recap-ad.md when="2026-10-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3324" %}

[ec eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-1/2928
[news416 eclair 0.14.1]: /en/newsletters/2026/07/31/#eclair-0-14-1
[smite repo]: https://github.com/lnfuzz/smite
