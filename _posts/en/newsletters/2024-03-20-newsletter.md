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
  software that wants to natively support the v2 Bitcoin P2P protocol.

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
  complexity/optimization opportunities."

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.1rc2][] is a release candidate for a maintenance release
  of the network's predominant full node implementation.

- [Bitcoin Core 27.0rc1][] is a release candidate for the next major
  version of the network's predominant full node implementation.

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
  tradeoffs.

- [Bitcoin Core #27114][] allows adding "in" and "out" to the
  `whitelist` configuration parameter to give special access to
  particular _incoming_ and _outgoing_ connections.  By default, a peer
  listed in the whitelist will only receive special access when it
  connects to the user's local node (an incoming connection).  By
  specifying "out", the user can now ensure a peer receives special
  access if the local node connects to it, such as by the user calling
  the `addnode` RPC.

- [Bitcoin Core #29306][] adds [sibling eviction][topic kindred
  rbf] for transactions descended from an unconfirmed [v3
  parent][topic v3 transaction relay].  This can provide a satisfactory
  alternative to [CPFP carve-out][topic cpfp carve out], which is
  currently used by [LN anchor outputs][topic anchor outputs].  V3
  transaction relay, including sibling eviction, is not currently
  enabled for mainnet.

- [LND #8310][] allows the `rpcuser` and `rpcpass` (password)
  configuration parameters to be retrieved from the system environment.
  This can allow, for example, a `lnd.conf` file to be managed using a
  non-private revision control system without storing the private
  username and password.

- [Rust Bitcoin #2458][] adds support for signing [PSBTs][topic psbt]
  that include taproot inputs.

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
