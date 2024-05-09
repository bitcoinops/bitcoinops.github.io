---
title: 'Bitcoin Optech Newsletter #167'
permalink: /en/newsletters/2021/09/22/
name: 2021-09-22-newsletter
slug: 2021-09-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed modification to the BIP
process, summarizes a plan to add support for package relay to Bitcoin
Core, and links to a discussion about adding LN node information to DNS.
Also included are our regular sections with descriptions of changes to
services and client software, how you can prepare for taproot, new
releases and release candidates, and notable changes to popular Bitcoin
infrastructure software.

## News

- **BIP extensions:** Karl-Johan Alm [posted][alm bips] to the
  Bitcoin-Dev mailing list a proposal that BIPs which have
  achieved a certain stability no longer be modifiable except for
  small fixes.  Any modification of the terms of a stable BIP would need
  to be made through a new BIP which extends the earlier document.

  Anthony Towns [argued][towns bips] against the idea and suggested
  several alternative tweaks to the current process, including a
  Drafts folder in the BIPs repository and removing the ability of the
  BIPs maintainers to choose which numbers to give particular
  proposals.

- **Package mempool acceptance and package RBF:** Gloria Zhao [posted][zhao
  post] to the Bitcoin-Dev mailing list about a design for the [package
  relay][topic package relay] of multiple related transactions that
  would enhance the flexibility and reliability of both [CPFP][topic
  cpfp] and [RBF][topic rbf] fee bumping.  An [initial
  implementation][bitcoin core #22290] only allows packages to be
  submitted via Bitcoin Core's RPC interface, but the ultimate goal is
  to make the feature available over the P2P network.  Zhao succinctly
  summarizes her proposed changes to Bitcoin Core's transaction
  acceptance rules:

  > - Packages may contain already-in-mempool transactions.
  > - Packages are two generations, multi-parent-one-child.
  > - Fee-related checks use the package feerate. This means that wallets can
  >   create a package that utilizes CPFP.
  > - Parents are allowed to RBF mempool transactions with a set of rules
  >   similar to [BIP125][]. This enables a combination of CPFP and RBF,
  >   where a transaction's descendant fees pay for replacing mempool
  >   conflicts.

  The email requests feedback on the proposal from developers who expect
  to use the features or who think they might be affected by the
  changes.

- **DNS records for LN nodes:** Andy Schroder [posted][schroder post] to
  the Lightning-Dev mailing list a suggestion to standardize the use of
  a set of DNS records for resolving a domain name to an LN node IP
  address and public key.  The idea was still being discussed at the
  time of this writing.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Lightning Address identifiers announced:**
  André Neves [announced][tla tweet] the [Lightning Address][lightningaddress
  website] protocol which wraps [LNURL-pay][lnurl pay] flows into familiar
  [email-like addresses][lightningaddress diagram].

- **ZEBEDEE releases LN wallet browser extension:**
  ZEBEDEE [announces][zbe blog] Chrome and Firefox extensions which integrate with its
  [gaming-focused wallet][zebedee wallet].

- **Specter v1.6.0 supports single-key taproot:**
  Specter's [v1.6.0][specter v1.6.0] release includes support for both regtest
  and [signet][topic signet] taproot addresses.

- **Impervious releases LN P2P data API:**
  the [Impervious][impervious website] framework, built on LND, allows developers
  to [build][impervious api] P2P data streaming applications over the Lightning Network.

- **Fully Noded v0.2.26 released:**
  [Fully Noded][fully noded website], a Bitcoin and Lightning wallet for macOS/iOS, adds support for
  [taproot][topic taproot], [BIP86][], and signet.

## Preparing for taproot #14: testing on signet

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/13-signet.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] is a release candidate
  for a maintenance version of Bitcoin Core.  It contains several bug
  fixes and small improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Eclair #1932][] implements the revised [anchor outputs][topic anchor
  outputs] protocol specified in [BOLTs #824][], where all presigned
  HTLC spends use zero fee, so no fees can be stolen.  See [Newsletter
  #165][news165 bolts 842] for details.

- [LND #5405][] extends the `updatechanpolicy` RPC so that it reports
  any channels that are currently unusable due to the current policy (or
  because of other issues, such as the channel funding transaction still
  being unconfirmed).

- [LND #5304][] enables LND to create and validate macaroons with external
  permissions unknown to LND itself. This change enables tools such as [Lightning
  Terminal][] to use a single macaroon to authenticate across multiple daemons that
  all talk to the same LND.

- [Rust Bitcoin #628][] adds support for Pay to Taproot's sighash
  construction and tidies up storage of the sighash cache for legacy,
  segwit and taproot inputs.

- [Rust Bitcoin #580][] adds support for the P2P network messages
  defined in the [BIP37][] specification for [transaction bloom
  filtering][topic transaction bloom filtering].

- [Rust Bitcoin #626][] adds functions to get the stripped size of a
  block (a block with all its segwit data removed) and the vbyte size of
  a transaction.

- [Rust-Lightning #1034][] adds a function that can be used to retrieve
  the complete list of channel balances, including for channels that are
  currently in the process of closing.  This allows end-user software to
  display a consistent user balance even when some funds are still
  waiting for confirmation before they can be used again.

{% include references.md %}
{% include linkers/issues.md issues="1932,5405,5304,628,580,626,1034,824,22290" %}
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[alm bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019457.html
[towns bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019462.html
[zhao post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019464.html
[schroder post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003224.html
[news165 bolts 842]: /en/newsletters/2021/09/08/#bolts-824
[lightning terminal]: /en/newsletters/2020/08/19/#lightning-labs-releases-lightning-terminal
[tla tweet]: https://twitter.com/andreneves/status/1425651740502892550
[lnurl pay]: https://github.com/fiatjaf/lnurl-rfc/blob/master/lnurl-pay.md
[lightningaddress website]: https://lightningaddress.com/
[lightningaddress diagram]: https://github.com/andrerfneves/lightning-address/blob/master/README.md#tldr
[zbe blog]: https://blog.zebedee.io/browser-extension/
[zebedee wallet]: https://zebedee.io/wallet
[specter v1.6.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.6.0
[impervious website]: https://www.impervious.ai/
[impervious api]: https://docs.impervious.ai/
[fully noded website]: https://fullynoded.app/
