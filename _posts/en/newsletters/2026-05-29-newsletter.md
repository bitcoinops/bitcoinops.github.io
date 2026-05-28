---
title: 'Bitcoin Optech Newsletter #407'
permalink: /en/newsletters/2026/05/29/
name: 2026-05-29-newsletter
slug: 2026-05-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the responsible disclosure of a vulnerability
that allowed a remote peer to crash Core Lightning nodes and links to
transcripts from a recent Bitcoin Core developer meeting. Also included are our
regular sections announcing new releases and release candidates and describing
notable changes to popular Bitcoin infrastructure software.

## News

- **Core Lightning assertion DoS disclosure:** Chandra Pratap [posted][cln dos
  delving] to Delving Bitcoin disclosing a denial-of-service vulnerability
  discovered during a Summer of Bitcoin 2025 internship. The vulnerability
  affected Core Lightning nodes that accept incoming channels.

  During the channel-opening handshake, a remote peer sends a message
  containing the txid of the proposed funding transaction. Core Lightning
  performed an assertion check requiring a non-zero txid. When a peer sent an
  all-zero txid instead, the assertion failed and crashed the node. Since any
  peer can initiate a channel-opening handshake and send the malicious
  message, this allowed a remote attacker to reliably crash any vulnerable node
  that accepted inbound channels.

  The vulnerability was [responsibly disclosed][topic responsible disclosures]
  and discovered through fuzzing. At the time of the report, Rusty Russell had
  independently been working on a separate crash bug and his fix incidentally
  resolved this vulnerability as well. The vulnerability was fixed in [Core
  Lightning 26.04][news402 cln2604].

- **Bitcoin Core developer meeting transcripts:** many Bitcoin Core
  developers met in person in May, and transcripts from the meeting have
  been [published][coredev 2026-05]. Topics included
  [SwiftSync][coredev swiftsync], [post-cluster mempool][coredev post-cluster],
  an [Erlay redesign][coredev erlay], [package relay][coredev pkg relay],
  [silent payments][coredev silent payments], [TCP hole punching][coredev tcp holepunch]
  (see [Newsletter #406][news406 tcp holepunch]),
  [private broadcast][coredev private broadcast], a [modern crypto
  library][coredev modern crypto], and [mutation testing][coredev mutation
  testing], among others.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Eclair v0.14.0][] is the latest release of this popular LN node
  implementation.  It includes the final versions for [splicing][topic
  splicing], [simple taproot channels][topic simple taproot channels], and
  [zero-fee commitments][topic v3 commitments], removes support for
  non-[anchor output][topic anchor outputs] channels, and adds experimental
  peer scoring for liquidity and routing optimization.

- [Core Lightning 26.06rc2][] is a release candidate for the next major
  version of this popular LN node which includes new `graceful`, `sendamount`,
  and `xkeysend` RPCs, begins the `pay` deprecation cycle in favor of `xpay`,
  and adds [BOLT12][topic offers] payer-proof RPC support.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33966][] refactors the way it handles mining block template
  options for the Mining IPC interface (See Newsletters [#310][news310 mining]
  and [#323][news323 mining]). Previously, startup mining options such as
  `blockmaxweight`, `blockreservedweight`, and `blockmintxfee` were handled
  separately from the runtime options passed by IPC mining clients. Now, these
  options are parsed into a shared `BlockCreateOptions` object and merged when
  creating or updating block templates. Invalid combinations, such as a
  reserved block weight that exceeds the maximum block weight, are now rejected
  instead of being silently adjusted to a valid range value.

- [Bitcoin Core #34917][] stops returning the deprecated `bip125-replaceable`
  field in wallet transaction RPCs `listtransactions`, `listsinceblock`, and
  `gettransaction`, though users can still request the field with the
  `-deprecatedrpc=bip125` option. The PR also deprecates the `-walletrbf`
  startup option, which now emits a warning and is scheduled for removal in the
  next release. See [Newsletter #403][news403 rbf] for previous removal of
  [RBF][topic rbf]-related fields.

- [Bitcoin Core #35017][] updates the [package][topic package relay]
  transaction submission process to prevent later transactions from remaining
  in the mempool after an unexpected validation failure. During package
  submission, transactions are processed sequentially, allowing later
  transactions to spend earlier ones that have already been added to the
  mempool. Previously, if one transaction failed a late validation check (such
  as a consensus script check), Bitcoin Core would only remove that
  transaction. Now, it also removes all subsequent transactions in the package,
  preventing children from remaining in the mempool after a parent has been
  removed.

- [BIPs #1944][] adds [BIP449][], a draft soft fork proposal for
  `OP_TWEAKADD`, a [tapscript][topic tapscript] opcode for computing a tweaked
  x-only public key (see [Newsletter #370][news370 tweak]). Given a 32-byte
  x-only public key and a 32-byte scalar tweak, the opcode pushes the x-only
  key for `P + tG`. This would allow scripts to directly verify key-tweak
  relationships, enabling constructions such as tweak-reveal scripts, proof of
  signing order, and [signing delegation][topic signer delegation] protocols.

- [BIPs #2108][] adds [BIP450][], Formosa, a draft specification for encoding
  [BIP39][]-compatible wallet entropy as story-like mnemonic phrases. Instead
  of using random BIP39 words, Formosa uses theme-defined word lists to
  encode entropy, producing short, structured sentences. These stories can be
  decoded back into the original entropy and converted into a standard
  BIP39 mnemonic before seed derivation, thus preserving compatibility with
  BIP39.

- [Eclair #3192][] adds experimental support for [zero-fee commitment][topic
  v3 commitments] (0FC) channels, following the specification covered in
  [Newsletter #404][news404 0fc]. The feature is disabled by default and can be
  enabled with `eclair.features.zero_fee_commitments = optional`.

- [LDK #4584][] adds `payment_metadata` maps to [BOLT12][topic offers] blinded
  message and payment path contexts. This adds the plumbing to carry
  recipient-side metadata through [blinded paths][topic rv routing] and recover
  it when the payment is received, similar to [BOLT11][]'s `payment_metadata`.
  Building offers with metadata is not yet supported. The metadata is stored as
  a map from numeric keys to byte arrays, allowing multiple independent pieces
  of data to be attached to the same payment.

- [LDK #4628][] starts encrypting [BOLT11][] `payment_metadata` when creating
  inbound payments, building on the metadata commitment covered in [Newsletter
  #405][news405 metadata].  After verifying the payment, LDK decrypts the
  metadata, enabling applications to access invoice metadata without exposing
  it to the payer or implementing encryption themselves.

- [LND #10552][] adds a fast initial sync for [Neutrino][topic compact block
  filters]-backed LND nodes by allowing them to import prebuilt Bitcoin block
  headers and compact filters from local files or HTTP(S) sources before
  resuming normal P2P sync. The new `neutrino.blockheaderssource` and
  `neutrino.filterheaderssource` options must be configured together. Imported
  headers are validated locally, and then Neutrino fetches any headers after
  the imported tip from network peers.

- [LND #10820][] prevents LND from implicitly selecting [simple taproot
  channels][topic simple taproot channels] when opening public channels because
  taproot [channel announcements][topic channel announcements] are not yet
  supported. Previously, if both peers advertised support for this type of
  channel, LND could select it and then reject the open. Now, simple taproot
  channels must be explicitly requested, while implicit negotiation can still
  select legacy, static remote key, or [anchor][topic anchor outputs] channel
  types. The PR also updates `lncli openchannel --channel_type=taproot` to
  select the production simple taproot channel type.

{% include snippets/recap-ad.md when="2026-06-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33966,34917,35017,3192,4584,4628,10552,10820,2108,1944" %}
[cln dos delving]: https://delvingbitcoin.org/t/vulnerability-disclosure-assertion-dos-in-core-lightning/2507
[news402 cln2604]: /en/newsletters/2026/04/24/#core-lightning-26-04
[coredev 2026-05]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05
[coredev swiftsync]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/swiftsync
[coredev post-cluster]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/post-cluster-mempool
[coredev erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/erlay-redesign
[coredev pkg relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/package-relay
[coredev silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/silent-payments
[coredev tcp holepunch]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/tcp-holepunch
[news406 tcp holepunch]: /en/newsletters/2026/05/22/#tcp-hole-punching-for-bitcoin-nodes-behind-nats
[coredev private broadcast]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/private-broadcast
[coredev modern crypto]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/modern-crypto-library
[coredev mutation testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/mutation-testing
[Eclair v0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[Core Lightning 26.06rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc2
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /en/newsletters/2024/10/04/#bitcoin-core-30510
[news403 rbf]: /en/newsletters/2026/05/01/#bitcoin-core-34911
[news404 0fc]: /en/newsletters/2026/05/08/#bolts-1228
[news405 metadata]: /en/newsletters/2026/05/15/#ldk-4528
[news370 tweak]: /en/newsletters/2025/09/05/#draft-bip-for-op-tweakadd