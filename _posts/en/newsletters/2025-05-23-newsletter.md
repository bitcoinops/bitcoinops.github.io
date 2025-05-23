---
title: 'Bitcoin Optech Newsletter #355'
permalink: /en/newsletters/2025/05/23/
name: 2025-05-23-newsletter
slug: 2025-05-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections describing changes
to services and client software, announcing new releases and release
candidates, and summarizing recent changes to popular Bitcoin
infrastructure software.

## News

*No significant news this week was found in any of our [sources][].*

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Cake Wallet added payjoin v2 support:**
  Cake Wallet [v4.28.0][cake wallet 4.28.0] adds [the ability][cake blog] to
  receive payments using the [payjoin][topic payjoin] v2 protocol.

- **Sparrow adds pay-to-anchor features:**
  Sparrow [2.2.0][sparrow 2.2.0] displays and can send [pay-to-anchor
  (P2A)][topic ephemeral anchors] outputs.

- **Safe Wallet 1.3.0 released:**
  [Safe Wallet][safe wallet github] is a desktop multisig wallet with hardware
  signing device support that added [CPFP][topic cpfp] fee bumping for incoming
  transactions in [1.3.0][safe wallet 1.3.0].

- **COLDCARD Q v1.3.2 released:**
  COLDCARD Q's [v1.3.2 release][coldcard blog] includes additional multisig
  [spending policy support][coldcard ccc] and new features for [sharing
  sensitive data][coldcard kt].

- **Transaction batching using payjoin:**
  [Private Pond][private pond post] is an [experimental implementation][private
  pond github] of a [transaction batching][topic payment batching] service that
  uses payjoin to generate smaller transactions that pay less in fees.

- **JoinMarket Fidelity Bond Simulator:**
  The [JoinMarket Fidelity Bond Simulator][jmfbs github] provides tools for
  JoinMarket participants to simulate their performance in the market based on
  [fidelity bonds][news161 fb].

- **Bitcoin opcodes documented:**
  The [Opcode Explained][opcode explained website] website documents
  each Bitcoin script opcode.

- **Bitkey code open sourced:**
  The Bitkey hardware signing device [announced][bitkey blog] their [source
  code][bitkey github] is open-source for non-commercial uses.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.19.0-beta][] is the latest major release of this popular LN
  node.  Its contains many [improvements][lnd rn] and bug fixes,
  including new RBF-based fee bumping for cooperative closes.

- [Core Lightning 25.05rc1][] is a release candidate for the next major
  version of this popular LN node implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32423][] removes the deprecation notice for
  `rpcuser/rpcpassword` and replaces it with a security warning about storing
  cleartext credentials in the configuration file. This option was originally
  deprecated when `rpcauth` was introduced in [Bitcoin Core #7044][], which
  supports multiple RPC users and hashes its cookie. The PR also adds a random
  16-byte salt to credentials from both methods and hashes them before they’re
  stored in memory.

- [Bitcoin Core #31444][] extends the `TxGraph` class (see Newsletter
  [#348][news348 txgraph]) with three new helper functions:
  `GetMainStagingDiagrams()` returns the divergences of clusters between the
  main and staged feerate diagrams, `GetBlockBuilder()` iterates through graph
  chunks (sub-cluster feerate-sorted groupings) from highest to lowest feerate
  for optimized block construction, and `GetWorstMainChunk()` pinpoints the
  lowest feerate chunk for eviction decisions. This PR is one of the final
  building blocks of the full initial implementation of the [cluster mempool][topic
  cluster mempool] project.

- [Core Lightning #8140][] enables [peer storage][topic peer storage] of channel
  backups by default (see Newsletter [#238][news238 storage]), making it viable
  for large nodes by limiting storage to peers with current or past channels,
  caching backups and peer lists in memory instead of making repeated
  `listdatastore`/`listpeerchannels` calls, capping concurrent backup uploads at
  two peers, skipping backups larger than 65 kB, and randomizing peer selection when
  sending.

- [Core Lightning #8136][] updates the exchange of announcement signatures to
  occur when the channel is ready rather than after six blocks, to align with
  the recent [BOLTs #1215][] specification update. It's still required to wait
  six blocks to [announce the channel][topic channel announcements].

- [Core Lightning #8266][] adds an `update` command to the Reckless plugin
  manager (see Newsletter [#226][news226 reckless]) that updates a specified
  plugin or all installed plugins if none is specified, except those installed
  from a fixed Git tag or commit. This PR also extends the `install` command to
  take a source path or URL in addition to a plugin name.

- [Core Lightning #8021][] finalizes [splicing][topic splicing] interoperability
  with Eclair (see Newsletter [#331][news331 interop]) by fixing the rotation of
  remote funding keys, resending `splice_locked` on channel re-establishment to
  cover cases where it was originally missed (see Newsletter [#345][news345
  splicing]), relaxing the requirement that commitment-signed messages arrive in
  a particular order, enabling receiving and initiating splice [RBF][topic rbf]
  transactions, automatically converting outgoing [PSBTs][topic psbt] to version
  2 when needed, and other refactoring changes.

- [Core Lightning #8226][] implements [BIP137][] by adding a new
  `signmessagewithkey` RPC command that allows users to sign messages with any
  key from the wallet by specifying a Bitcoin address. Previously, signing a
  message with a Core Lightning key required finding the xpriv and the key
  index, deriving the private key with an external library, and then signing the
  message with Bitcoin Core.

- [LND #9801][] adds a new `--no-disconnect-on-pong-failure` option, which
  controls whether a peer is disconnected if a pong response is late or
  mismatched. This option is set to false by default, preserving the current
  behavior of LND disconnecting from a peer on a pong message failure (see
  Newsletter [#275][news275 ping]); otherwise, LND would only log the event. The
  PR refactors the ping watchdog to continue its loop when disconnection is
  suppressed.

{% include snippets/recap-ad.md when="2025-05-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32423,31444,8140,8136,8266,8021,8226,9801,7044,1215" %}
[lnd 0.19.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[sources]: /en/internal/sources/
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.19.0.md
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[news348 txgraph]: /en/newsletters/2025/04/04/#bitcoin-core-31363
[news238 storage]: /en/newsletters/2023/02/15/#core-lightning-5361
[news226 reckless]: /en/newsletters/2022/11/16/#core-lightning-5647
[news331 interop]: /en/newsletters/2024/11/29/#core-lightning-7719
[news345 splicing]: /en/newsletters/2025/03/14/#eclair-3007
[news275 ping]: /en/newsletters/2023/11/01/#lnd-7828
[cake wallet 4.28.0]: https://github.com/cake-tech/cake_wallet/releases/tag/v4.28.0
[cake blog]: https://blog.cakewallet.com/bitcoin-privacy-takes-a-leap-forward-cake-wallet-introduces-payjoin-v2/
[sparrow 2.2.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.2.0
[safe wallet github]: https://github.com/andreasgriffin/bitcoin-safe
[safe wallet 1.3.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.3.0
[coldcard blog]: https://blog.coinkite.com/ccc-and-keyteleport/
[coldcard ccc]: https://coldcard.com/docs/coldcard-cosigning/
[coldcard kt]: https://github.com/Coldcard/firmware/blob/master/docs/key-teleport.md
[private pond post]: https://njump.me/naddr1qvzqqqr4gupzqg42s9gsae3lu2cketskuzfp778fh2vg9c5x3elx8ttdpzhfkk25qq2nv5nzddgxxdjtd4u9vwrdv939vmnswfzk6j85dxk
[private pond github]: https://github.com/Kukks/PrivatePond
[jmfbs github]: https://github.com/m0wer/joinmarket-fidelity-bond-simulator
[news161 fb]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[opcode explained website]: https://opcodeexplained.com/
[bitkey blog]: https://x.com/BEN0WHERE/status/1918073429791785086
[bitkey github]: https://github.com/proto-at-block/bitkey
