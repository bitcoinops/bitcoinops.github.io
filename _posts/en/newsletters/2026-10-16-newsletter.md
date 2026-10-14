---
title: 'Bitcoin Optech Newsletter #427'
permalink: /en/newsletters/2026/10/16/
name: 2026-10-16-newsletter
slug: 2026-10-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the disclosure of two denial-of-service
vulnerabilities in older versions of Eclair and describes a proposed scheme for
running complex multi-round contracts inside Lightning channels. Also included
are our regular sections announcing new releases and release candidates and
describing notable changes to popular Bitcoin infrastructure software.

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

- **Offchain contracts in Lightning channels**: Adam Gibson [posted][lngap ml]
  to the Bitcoin-Dev mailing list about a proposal for protocol,
  called LN-GAP, to run complex, multi-round, two-party contracts inside a
  Lightning channel while settling disputes onchain in a constant number of
  transactions. In order to showcase the proposal, Gibson implemented a game
  of chess, which he deems a good example of a game that is difficult to run
  onchain, in which the winner takes the whole pot. Both a [repository][lngap repo]
  and a [paper][lngap paper] for the proposal are available.

  Two players, Alice and Bob, agree on a certain set of rules. Each player makes
  their own moves. In case of a dispute, Alice can enforce the rules onchain.
  However, Gibson notes that Lightning can enforce rules about a published state,
  but it cannot do so in case a counterparty stalls or stops responding.
  To address this issue, Gibson introduces a venue, a committee of members whose
  role is to attest whether a signed message (a move in a chess game and its
  signature) was published before a certain deadline or not. The venue only needs
  to attest the timeliness of the publication, not the content of the message.
  In case of a dispute, Alice posts a transaction claiming that no event was
  published by Bob; in turn, Bob can post a second transaction containing a
  rebuttal (his move and the venue's attestation); finally, Alice can post a
  disproof, stating that Bob's rebuttal doesn't stand due to the event not being
  compliant with the rules.

  In Gibson's proposal, the venue never holds users' funds. Moreover, it avoids
  relying on FROST-style threshold signature in order to make fraud attributable
  only to malicious members. To do so, attestation is done through per-member
  "one-bit signatures" checked using `OP_CHECKSIGADD`. Members are incentivized
  by fees paid atomically over channels using [adaptors][topic adaptor signatures].
  However, the construction relies on an honest-majority assumption. If more than
  half of the members of the venue collude with one of the parties involved, funds
  can be stolen.

  Other than games, possible applications include proof-of-storage
  contracts, where a provider forfeits a bond for failing to respond to a
  challenge, and offchain dispute resolution similar to what
  [BitVMX][topic acc]-style zero-knowledge verifiers do onchain.

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
[lngap ml]: https://groups.google.com/g/bitcoindev/c/pjv6bL_42kg
[lngap repo]: https://github.com/AdamISZ/ln-gap
[lngap paper]: https://github.com/AdamISZ/ln-gap/blob/master/docs/paper/lngap-short.pdf
