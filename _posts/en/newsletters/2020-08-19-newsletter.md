---
title: 'Bitcoin Optech Newsletter #111'
permalink: /en/newsletters/2020/08/19/
name: 2020-08-19-newsletter
slug: 2020-08-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a possible update to the BIP340
specification of schnorr signatures and a new proposed BIP that
specifies how Bitcoin nodes should handle P2P protocol feature
negotiation in a forward compatible way.  Also included are our
regular sections with notable changes to services and client software,
releases and release candidates, and changes to popular Bitcoin
infrastructure software.

## Action items

*None this week.*

## News

- **Proposed uniform tiebreaker in schnorr signatures:** the [elliptic
  curve cryptography][] used in Bitcoin requires identifying points on
  Elliptic Curves (ECs).  This can be done unambiguously using a 32-byte X
  coordinate and a 32-byte Y coordinate.  However, if you know a point's
  X coordinate, then you can calculate the two possible locations
  for its Y coordinate.  This small ambiguity can be resolved either by
  providing a single bit of extra data to indicate which of the two
  coordinates to use or by using a type of method known as a
  *tiebreaker* to automatically choose one Y coordinate or the other for
  each X coordinate.

  The [BIP340][] specification of schnorr signatures for Bitcoin
  currently uses a tiebreaker method to minimize the amount of data
  needed to identify EC points in public keys
  and signatures.  Earlier, BIP340
  used a tiebreaker algorithm based on the squaredness of the Y
  coordinates for both the point in public keys and the point in
  signatures.  This was recently changed so that public keys used a
  different algorithm based on the evenness of the coordinates, which
  was believed to be easier to implement for existing software that
  created public keys (see Newsletters [#83][news83 tiebreaker] and
  [#96][news96 bip340 update]).

  This week, Pieter Wuille [posted][wuille tiebreaker] to the
  Bitcoin-Dev mailing list a tentative proposal to update BIP340 again
  so that both public keys and signatures would use the evenness
  algorithm.  It was previously thought that the squared version would
  be faster to compute during signature verification and so would help
  speed up full nodes, but a [recent PR][libsecp256k1 #767] to
  libsecp256k1 by Peter Dettman with a significant performance
  improvement caused developers to question this belief and revealed
  that an earlier benchmark that favored the squared version wasn't
  actually providing a fair comparison between the two tiebreaking
  methods.  It now seems that both methods should be about equal in
  performance.

  Several respondents replied that, even though they already
  implemented code using both tiebreaker methods, they'd prefer to see
  the specification changed to use just the evenness method.  Anyone
  else with an opinion is encouraged to respond to the mailing list
  thread.

- **Proposed BIP for P2P protocol feature negotiation:** Suhas Daftuar
  [posted][daftuar negotiation] a suggestion to create a [separate
  BIP][bip-negotiation] for the P2P feature negotiation method that
  became a part of [BIP339][] (see [Newsletter #87][news87
  negotiation]).  The protocol change is simple: when a node receives a
  P2P `version` message from a newly connected peer, the node should
  ignore any messages it doesn't understand until a `verack` message has
  been received from that peer.  Those messages, like the new BIP339
  `wtxidrelay` message, may signal what features the remote peer
  supports.

  This behavior is already implemented in an unreleased development
  version of Bitcoin Core.  If the maintainers of other
  implementations, or anyone else, opposes this change, please respond
  to the mailing list thread.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Crypto Garage announces P2P Derivatives beta application on Bitcoin:**
  In a [blog post][cg p2p derivatives blog], Crypto Garage outlines a beta
  application for conducting P2P [DLC-based][dlcs] derivatives on Bitcoin regtest
  and testnet. The application allows the specification of a financial
  agreement and creation of a corresponding locking transaction of funds between
  the two parties of that agreement. Upon contract maturity, a price oracle
  provides a signature for the closing transaction spending the amounts
  corresponding to agreement.

- **Specter Desktop adds batching:**
  [Specter Desktop][specter github], a hardware wallet multisig-focused GUI
  for Bitcoin Core, added the ability to send transactions to multiple receivers.

- **Lightning Labs releases Lightning Terminal:**
  [Lightning Terminal][lightning terminal blog] is a visual, browser-based tool
  for LN channel management, initially focusing on [Lightning Loop][news39 lightning loop announced].

- **Wasabi adds support for PayJoin:**
  [Wasabi 1.1.12][] adds support for the [BIP78][] PayJoin specification that
  also works over Tor.

- **BlueWallet for Desktop alpha announced:**
  BlueWallet announced an [alpha desktop version][bluewallet desktop] for macOS
  of their Lightning and Bitcoin wallet supporting bech32, hardware wallets, PSBTs,
  watch-only addresses, and more.

- **BitcoinIsSafe.com lists Bitcoin software marked as malicious by antivirus products:**
  The [bitcoinissafe.com][] website tracks the detection rate of Bitcoin software
  including Bitcoin Core, Electrum, and Wasabi within popular antivirus
  products. The website also provides contact information for notifying
  antivirus vendors about potential false positives.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.11.0-beta.rc4][lnd 0.11.0-beta] is a release candidate for the
  next major version of this project.  It allows accepting [large
  channels][topic large channels] (by default, this is off) and contains
  numerous improvements to its backend features that may be of interest
  to advanced users (see the [release notes][lnd 0.11.0-beta]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19658][] modifies the `getnodeaddresses` RPC to allow returning
  all known addresses when `0` is specified as the number of addresses to retrieve.
  Previously, there was a limit on the maximum number of addresses returned,
  mostly due to an internal implementation quirk.

- [Bitcoin Core #18654][] adds a new `psbtbumpfee` RPC that takes the
  txid of a transaction currently in the local node's mempool and
  creates a [PSBT][topic psbt] that increases its feerate (either by an
  automatic amount or by an amount specified via a parameter).  Other
  RPCs or external tools can then sign and finalize the PSBT.

  The existing `bumpfee` RPC previously created PSBT fee bumps for
  watch-only wallets (see [Newsletter #80][news80 bumpfee]).  This
  behavior is now deprecated and a message will be printed to tell
  those users to use `psbtbumpfee`.  Use of `bumpfee` with regular
  key-containing wallets still creates, signs, and broadcasts the fee bump.
  This change helps make `bumpfee` more consistent since its previous
  behavior for watch-only wallets of creating PSBTs couldn't include
  the signing or broadcast steps.

- [Bitcoin Core #19070][] allows Bitcoin Core to advertise its support
  for [compact block filters][topic compact block filters] when the
  `peerblockfilters` and `blockfilterindex` configuration options have been enabled (default:
  disabled).  This will allow services such as [DNS seeders][] to tell
  lightweight clients the IP addresses of nodes that serve filters.
  This PR is the last in a series of patches that enable [BIP157][] and
  [BIP158][] support in Bitcoin Core.

- [Bitcoin Core #15937][] updates the `createwallet`, `loadwallet`, and
  `unloadwallet` RPCs to provide a `load_on_startup` option that will
  add the wallet's name to the list of wallets automatically loaded on
  start up (or, if the option is set to false, remove the wallet's name
  from that list).  It's expected that a future PR will allow the GUI to
  add or remove wallet names from the same list.

- [C-Lightning #3830][] adds experimental support for using [anchor
  outputs][topic anchor outputs], which can both reduce onchain
  transaction fees in normal cases and increase fees when necessary for
  security.  This initial implementation is only available if
  C-Lightning is compiled with experimental features enabled.

- [LND #4521][] updates the method it uses for adding
  routing hints to invoices.  The previous method didn't consider
  [multipath payments][topic multipath payments] and so wouldn't include
  routing hints if you tried to generate an invoice larger than any of
  your current channels.  The new method includes more hints and also
  randomizes the order of the hints so that there's less chance of a
  single channel running out of liquidity.

{% include references.md %}
{% include linkers/issues.md issues="767,19658,18654,19070,3830,4521,15937" %}

[lnd 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta.rc4
[elliptic curve cryptography]: https://en.wikipedia.org/wiki/Elliptic_curve_cryptography
[news83 tiebreaker]: /en/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[news96 bip340 update]: /en/newsletters/2020/05/06/#bips-893
[wuille tiebreaker]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018081.html
[daftuar negotiation]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018084.html
[bip-negotiation]: https://github.com/sdaftuar/bips/blob/2020-08-generalized-feature-negotiation/bip-p2p-feature-negotiation.mediawiki
[news87 negotiation]: /en/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[news80 bumpfee]: /en/newsletters/2020/01/15/#bitcoin-core-16373
[dns seeders]: https://btcinformation.org/en/glossary/dns-seed
[specter github]: https://github.com/cryptoadvance/specter-desktop
[cg p2p derivatives blog]:https://medium.com/@cryptogarage/announcing-the-global-launch-of-p2p-derivatives-beta-application-7ecc02fa02a1
[dlcs]: https://adiabat.github.io/dlc.pdf
[Wasabi 1.1.12]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v1.1.12
[bluewallet desktop]: https://bluewallet.io/desktop-bitcoin-wallet/
[bitcoinissafe.com]: https://bitcoinissafe.com/
[lightning terminal blog]: https://lightning.engineering/posts/2020-08-04-lightning-terminal/
[news39 lightning loop announced]: /en/newsletters/2019/03/26/#loop-announced
[hwi]: https://github.com/bitcoin-core/HWI
