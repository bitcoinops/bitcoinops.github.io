---
title: 'Bitcoin Optech Newsletter #294'
permalink: /en/newsletters/2024/03/20/
name: 2024-03-20-newsletter
slug: 2024-03-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a project to create a BIP324 proxy for
light clients and summarizes discussion about a proposed BTC Lisp
language.  Also included are our regular sections describing recent
changes to clients and services, announcing new releases and release
candidates, and summarizing notable changes to popular Bitcoin
infrastructure software.

## News

- **BIP324 proxy for light clients:** Sebastian Falbesoner
  [posted][falbesoner bip324] to Delving Bitcoin to announce a TCP proxy
  for translating between the version 1 (v1) Bitcoin P2P protocol and
  the [v2 protocol][topic v2 p2p transport] defined in [BIP324][].  This
  is especially intended to allow light client wallets written for v1 to
  take advantage of v2's traffic encryption.

  Light clients typically only announce transactions belonging to their
  own wallets, so anyone capable of eavesdropping on an unencrypted v1
  connection can reasonably conclude that a transaction sent by a light
  client belonged to someone using the origin IP address.  When v2
  encryption is used, only the full nodes receiving the transaction will
  be able to definitively identify it as originating from the light
  client's IP address, assuming none of the light client connections is
  subject to a man-in-the-middle attack (which is possible to detect in
  some cases and which [later upgrades][topic countersign] may
  automatically defend against).

  Falbesoner's initial work pulls together BIP324 functions written in
  Python for Bitcoin Core's testing suite, which results in a proxy that
  is "terribly slow and vulnerable to side-channel attacks [and] not
  recommended to use it for anything but tests right now".  However, he
  is working on rewriting the proxy in Rust and may also make some or
  all of its functions available as a library for light clients or other
  software that wants to natively support the v2 Bitcoin P2P protocol. {% assign timestamp="1:20" %}

- **Overview of BTC Lisp:** Anthony Towns [posted][towns lisp] to
  Delving Bitcoin about his experiments over the past couple of years
  creating a variant of the [Lisp][] language for Bitcoin, called BTC
  Lisp.  See Newsletters [#293][news293 lisp] and [#191][news191 lisp]
  for previous discussions.  The post goes into significant detail; we
  encourage anyone interested in the idea to read it directly.  We will
  briefly quote from its _conclusion_ and _future work_ sections:

  "[BTC Lisp] can be a little expensive on-chain, but it seems like you
  can do pretty much anything [...] I don’t think implementing either a
  Lisp interpreter or the bucket of opcodes that would need to accompany
  it is too hard [but] it is pretty annoying to write Lisp code without
  a compiler translating from a higher level representation down to the
  consensus-level opcodes, [though] that seems solvable.  [T]his could
  be taken further [by] implementing a language like this and deploying
  it on signet/inquisition."

  Russell O'Connor, developer of the [Simplicity][topic simplicity]
  language that may also one day be considered as an alternative
  consensus scripting language, [replied][oconnor lisp] with some
  comparisons between Bitcoin's current Script language, Simplicity, and
  Chia/BTC Lisp.  He concludes, "Simplicity and the clvm [Chia Lisp Virtual
  Machine] are both low level languages that are meant to be easy
  for machines to evaluate, which causes tradeoffs that make them hard
  for humans to read. They are intended to be compiled from some
  different, human-readable, non-consensus-critical language.
  Simplicity and the clvm are different ways of expressing the same old
  things: fetching data from an environment, tupling up bits of data,
  running conditional statements, and a whole bunch of primitive
  operations of some sorts.  [...] Since we want this [split between
  efficient low-level consensus language and high-level non-consensus
  comprehensible language] regardless, the details of the low-level
  language become somewhat less important. I.e., with some effort, your
  high level BTC lisp language could probably be translated/compiled to
  Simplicity [...] Similarly, wherever the design of [Simplicity-based]
  Simphony [high-level non-consensus language] ends up, it can probably
  be translated/compiled [to] your low level BTC lisp language, with each
  translator/compiler language pair offering different potential
  complexity/optimization opportunities." {% assign timestamp="10:44" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **BitGo adds RBF support:**
  In a [recent blog][bitgo blog], BitGo announced support for fee bumping using
  [replace-by-fee (RBF)][topic rbf] in their wallet and API. {% assign timestamp="38:59" %}

- **Phoenix Wallet v2.2.0 released:**
  With this release, Phoenix can now support [splices][topic splicing] while
  making LN payments using the quiescence protocol (see [Newsletter
  #262][news262 eclair2680]). Additionally, Phoenix improved the swap-in feature
  privacy and fees by using their [swaproot][swaproot blog] protocol. {% assign timestamp="40:11" %}

- **Bitkey hardware signing device released:**
  The [Bitkey][bitkey website] device is designed to be used in a 2-of-3
  multisig setup with a mobile device and a Bitkey server key. Source code for
  the firmware and various components are [available][bitkey github] under a
  Commons Clause modified MIT License. {% assign timestamp="44:19" %}

- **Envoy v1.6.0 released:**
  The [release][envoy blog] adds features for fee bumping transactions as well as canceling
  transactions, both enabled using replace-by-fee (RBF). {% assign timestamp="47:49" %}

- **VLS v0.11.0 released:**
  The [beta release][vls beta 3] allows multiple signing devices for the same
  Lightning node, a feature they call [tag team signing][vls blog]. {% assign timestamp="49:22" %}

- **Portal hardware signing device announced:**
  The [recently announced][portal tweet] Portal device works with smartphones
  using NFC with hardware and software source [available][portal github]. {% assign timestamp="50:54" %}

- **Braiins mining pool adds Lightning support:**
  The Braiins mining pool [announced][braiins tweet] a beta for mining payouts through Lightning. {% assign timestamp="51:44" %}

- **Ledger Bitcoin App 2.2.0 released:**
  The [2.2.0 release][ledger 2.2.0] adds [miniscript][topic miniscript] support
  for [taproot][topic taproot]. {% assign timestamp="54:14" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.1rc2][] is a release candidate for a maintenance release
  of the network's predominant full node implementation. {% assign timestamp="55:51" %}

- [Bitcoin Core 27.0rc1][] is a release candidate for the next major
  version of the network's predominant full node implementation. {% assign timestamp="56:48" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until about six months after the release of the upcoming version 27.*

- [Bitcoin Core #27375][] adds support to the `-proxy` and `-onion`
  features for using Unix domain sockets rather than local TCP ports.
  Sockets can be faster than TCP ports and offer different security
  tradeoffs. {% assign timestamp="57:43" %}

- [Bitcoin Core #27114][] allows adding "in" and "out" to the
  `whitelist` configuration parameter to give special access to
  particular _incoming_ and _outgoing_ connections.  By default, a peer
  listed in the whitelist will only receive special access when it
  connects to the user's local node (an incoming connection).  By
  specifying "out", the user can now ensure a peer receives special
  access if the local node connects to it, such as by the user calling
  the `addnode` RPC. {% assign timestamp="58:59" %}

- [Bitcoin Core #29306][] adds [sibling eviction][topic kindred
  rbf] for transactions descended from an unconfirmed [v3
  parent][topic v3 transaction relay].  This can provide a satisfactory
  alternative to [CPFP carve-out][topic cpfp carve out], which is
  currently used by [LN anchor outputs][topic anchor outputs].  V3
  transaction relay, including sibling eviction, is not currently
  enabled for mainnet. {% assign timestamp="1:02:19" %}

- [LND #8310][] allows the `rpcuser` and `rpcpass` (password)
  configuration parameters to be retrieved from the system environment.
  This can allow, for example, a `lnd.conf` file to be managed using a
  non-private revision control system without storing the private
  username and password. {% assign timestamp="1:09:04" %}

- [Rust Bitcoin #2458][] adds support for signing [PSBTs][topic psbt]
  that include taproot inputs. {% assign timestamp="1:10:12" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27375,27114,29306,8310,2458" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[lisp]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[news293 lisp]: /en/newsletters/2024/03/13/#overview-of-chia-lisp-for-bitcoiners
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[falbesoner bip324]: https://delvingbitcoin.org/t/bip324-proxy-easy-integration-of-v2-transport-protocol-for-light-clients-poc/678
[towns lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682
[oconnor lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682/7
[bitgo blog]: https://blog.bitgo.com/available-now-for-clients-bitgo-introduces-replace-by-fee-f74e2593b245
[news262 eclair2680]: /en/newsletters/2023/08/02/#eclair-2680
[swaproot blog]: https://acinq.co/blog/phoenix-swaproot
[bitkey website]: https://bitkey.world/
[bitkey github]: https://github.com/proto-at-block/bitkey
[envoy blog]: https://foundation.xyz/2024/03/envoy-version-1-6-0-is-now-live/
[vls beta 3]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.11.0
[vls blog]: https://vls.tech/posts/tag-team/
[portal tweet]: https://twitter.com/afilini/status/1766085500106920268
[portal github]: https://github.com/TwentyTwoHW
[braiins tweet]: https://twitter.com/BraiinsMining/status/1760319741560856983
[ledger 2.2.0]: https://github.com/LedgerHQ/app-bitcoin-new/releases/tag/2.2.0
