---
title: 'Bitcoin Optech Newsletter #81'
permalink: /en/newsletters/2020/01/22/
name: 2020-01-22-newsletter
slug: 2020-01-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests help testing a pre-release of the next
major version of LND, seeks review of a method for sending payments
as part of a chaumian coinjoin mix, links to a work-in-progress protocol
specification for discreet log contracts, and includes our regular
sections about notable changes to popular services, client software, and
infrastructure projects.

## Action items

- **Help test LND 0.9.0-beta-rc3:** this [pre-release][lnd 0.9.0-beta]
  of the next major version of LND brings several new features and bug
  fixes.  Experienced users are encouraged to help test the software so
  that any problems can be identified and fixed prior to release.

## News

- **New coinjoin mixing technique proposed:** Max Hillebrand started a
  [thread][wormhole thread] on the Bitcoin-Dev mailing list about
  *Wormhole*, a method developed during a [Wasabi design discussion][]
  for sending payments as part of a chaumian coinjoin.  The protocol
  prevents even the spender from learning the receiver's Bitcoin address
  (within the limits of the anonymity set).  Developer ZmnSCPxj
  [notes][zmn note] that the technique is similar to [tumblebit][], which
  provides a trustless chaumian payment service.  Hillebrand is
  requesting feedback on the design in the hopes of seeing it
  implemented in the future.

- **Protocol specification for discreet log contracts (DLCs):** [DLCs][] are
  a contract protocol where two or more parties agree to exchange
  money dependent on the outcome of a certain event as determined by an
  oracle (or several oracles).  After the event happens, the oracle
  publishes a commitment to the outcome of the event in the form of a
  digital signature, which the winning party can use to claim their
  funds.  The oracle doesn't need to know the terms of the contract (or
  even that there is a contract).  The contract can look like either the
  onchain part of an LN transaction or it can be executed within an LN
  channel.  This makes DLCs more private and efficient than other known
  oracle-based contract methods, and it's arguably more secure as an
  oracle who commits to a false result generates clear evidence of their
  fraud.

    This week Chris Stewart [announced][stewart dlc] that several
    developers are working on a specification for using DLCs, with the
    goal of creating an interoperable design for use between different
    software, including LN implementations.  See their
    [repository][dlcspecs] for the current specification.  Anyone
    interested in DLCs may also wish to review the [scriptless
    scripts][scriptless scripts examples] repository that documents
    other clever applications of digital signature schemes to contract
    protocols.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- FIXME:bitschmidty Bitcoin Core Merge #17843: wallet: Reset reused transactions cache

- [Eclair #1247][] fixes the Sphinx privacy leak described in
  [Newsletter #72][news72 sphinx] where a routing node might be able to
  deduce a lower bound for the length of a path back to the source node.

- [Eclair #1283][] allows [multipath payments][topic multipath payments]
  (MPP) to traverse unannounced channels, which is necessary for
  eclair-mobile to be able to make MPP payments.

- [LND #3900][] allows a spender to send custom data records along
  with their payment.  Using `lncli`, a user can pass the `--data` flag
  along with the record ID and the data in hex, e.g. `65536=c0deba11ad`.
  One current use of custom records is the [WhatSat][] program that
  routes private messages over LN. <!-- source: "custom record sending"
  in https://github.com/joostjager/whatsat/commit/7c172ff8a63e56ec52005028b0f0d6b0a88867ec -->

{% include references.md %}
{% include linkers/issues.md issues="17843,1247,1283,3900" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta-rc3
[wormhole thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017585.html
[wasabi design discussion]: https://github.com/zkSNACKs/Meta/issues/49
[tumblebit]: https://eprint.iacr.org/2016/575.pdf
[zmn note]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017587.html
[dlcs]: https://adiabat.github.io/dlc.pdf
[stewart dlc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017563.html
[dlcspecs]: https://github.com/discreetlogcontracts/dlcspecs/
[scriptless scripts examples]: https://github.com/ElementsProject/scriptless-scripts
[whatsat]: https://github.com/joostjager/whatsat
[news72 sphinx]: /en/newsletters/2019/11/13/#possible-privacy-leak-in-the-ln-onion-format
