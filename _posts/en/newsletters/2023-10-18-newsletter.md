---
title: 'Bitcoin Optech Newsletter #273'
permalink: /en/newsletters/2023/10/18/
name: 2023-10-18-newsletter
slug: 2023-10-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter briefly mentions a recent security disclosure
affecting LN users, describes a paper about making payments
contingent on the result of running arbitrary programs, and announces a
proposed BIP to add fields to PSBTs for MuSig2.  Also included
are our regular sections that summarize improvements to clients and
services, announce new releases and release candidates, and describe
notable changes to popular Bitcoin infrastructure software.

## News

- **Security disclosure of issue affecting LN:** Antoine Riard
  [posted][riard cve] to the Bitcoin-Dev and Lightning-Dev mailing lists
  the full disclosure of an issue he had previously [responsibly
  disclosed][topic responsible disclosures] to developers working on the
  Bitcoin protocol and various popular LN implementations.  The most
  recent versions of Core Lightning, Eclair, LDK, and LND all contain
  mitigations that make the attack less practical, although they do not
  eliminate the underlying concern.

  The disclosure was made after Optech's usual news deadline, so we
  are only able to provide the above link in this week's newsletter.
  We will provide a regular summary in next week's newsletter. {% assign timestamp="1:09" %}

- **Payments contingent on arbitrary computation:** Robin Linus
  [posted][linus post] to the Bitcoin-Dev mailing list a [paper][linus paper] he's
  written about _BitVM_, a combination of methods that allows bitcoins
  to be paid to someone who successfully proves that an arbitrary
  program executed successfully.  Notably, this is possible on Bitcoin
  today---no consensus change is required.

  To provide context, a well-known feature of Bitcoin is to require
  someone to satisfy a programming expression (called a _script_) in
  order to spend bitcoins associated with that script.  For example, a
  script containing a public key that can only be satisfied if the
  corresponding private key creates a signature committing to a
  spending transaction.  Scripts must be written in Bitcoin's language
  (called _Script_) in order to be enforced by consensus, but Script
  is deliberately limited in its flexibility.

  Linus's paper gets around some of those limits.  If Alice trusts Bob
  to take action if a program was run incorrectly, but does not want
  to trust him with anything else, she can pay funds to a [taproot][topic taproot] tree
  that will allow Bob to claim the funds if he demonstrates that Alice
  failed to run an arbitrary program correctly.  If Alice does run the
  program correctly, then she can spend the funds even if Bob attempts
  to stop her.

  To use an arbitrary program, it must be broken down into a very
  basic primitive (a [NAND gate][]) and a commitment must be made for each
  gate.  This requires the offchain exchange of a very large amount of
  data, potentially multiple gigabytes for even a fairly basic
  arbitrary program---but Alice and Bob only need a single onchain
  transaction in the case that Bob agrees that Alice ran the program
  correctly.  In the case that Bob disagrees, he should be able to
  demonstrate Alice's failure within a relatively small number of
  onchain transactions.  If the setup was performed in a payment
  channel between Alice and Bob, multiple programs could be run both in
  parallel and in sequence with no onchain footprint except
  channel setup and either a mutual close or a force close where Bob
  attempts to demonstrate that Alice failed to follow the arbitrary
  program logic correctly.

  BitVM can be applied trustlessly in cases where Alice and Bob are
  natural adversaries, such as where they pay funds to an output that
  will be paid to whichever one of them wins in a game of chess.  They
  can then use two (almost identical) arbitrary programs, each of
  which takes the same arbitrary set of chess moves.  One program will
  return true if Alice won and one will return true if Bob won.  One
  party will then publish onchain the transaction that claims their
  program evaluates to true (that they won); the other party will
  either accept that claim (conceding the loss of funds) or will
  demonstrate the fraud (receiving the funds if successful).  In cases
  where Alice and Bob would not naturally be adversaries, Alice may be
  able to incentivize him to verify correct computation, such by
  offering her funds to Bob if he can prove she failed to compute
  correctly.

  The idea received a significant amount of discussion on the mailing
  list as well as on Twitter and various Bitcoin-focused podcasts.  We
  expect continued discussion in the coming weeks and
  months. {% assign timestamp="8:15" %}

- **Proposed BIP for MuSig2 fields in PSBTs:** Andrew Chow [posted][chow
  mpsbt] to the Bitcoin-Dev mailing list with a [draft BIP][mpsbt-bip],
  partly based on [prior work][kanjalkar mpsbt] by Sanket Kanjalkar, for
  adding several fields to all versions of [PSBTs][topic psbt] for the
  "keys, public nonces, and partial signatures produced with
  [MuSig2][topic musig]."

  Anthony Towns [asked][towns mpsbt] whether the proposed BIP would
  also include fields for [adaptor signatures][topic adaptor
  signatures], but continued discussion indicated that would likely
  need to be defined in a separate BIP. {% assign timestamp="26:44" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **BIP-329 Python library released:**
  The [BIP-329 Python Library][] is a set of tools that can read, write,
  encrypt, and decrypt [BIP329][]-compliant wallet label files. {% assign timestamp="29:10" %}

- **LN testing tool Doppler announced:**
  Recently [announced][doppler announced], [Doppler][] supports defining Bitcoin and Lightning
  node topologies and onchain/offchain payment activity using a Domain-Specific
  Language (DSL) to test LND, CLN, and Eclair implementations together. {% assign timestamp="30:19" %}

- **Coldcard Mk4 v5.2.0 released:**
  The firmware [updates][coldcard blog] include [BIP370][] support for
  version 2 [PSBTs][topic psbt], additional [BIP39][] support, and multiple seed capabilities. {% assign timestamp="31:54" %}

- **Tapleaf circuits: a BitVM demo:**
  [Tapleaf circuits][] is a proof-of-concept implementation of Bristol circuits
  using the BitVM approach outlined earlier in the newsletter. {% assign timestamp="32:27" %}

- **Samourai Wallet 0.99.98i released:**
  The [0.99.98i][samourai blog] release includes additional PSBT, UTXO labeling,
  and batch-sending features. {% assign timestamp="34:24" %}

- **Krux: signing device firmware:**
  [Krux][krux github] is an open-source firmware project for building hardware
  signing devices using commodity hardware. {% assign timestamp="35:12" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 24.2rc2][] and [Bitcoin Core 25.1rc1][] are release
  candidates for maintenance versions of Bitcoin Core. {% assign timestamp="36:06" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27255][] ports [miniscript][topic miniscript] to [tapscript][topic tapscript]. This code change makes
  miniscript an option for P2TR [output descriptors][topic descriptors], adding support for both
  watching and signing "TapMiniscript descriptors". Previously, miniscript was
  available only for P2WSH output descriptors. The author notes that a new
  `multi_a` fragment is introduced exclusively for P2TR descriptors that
  matches the semantics of `multi` in P2WSH descriptors. The discussion on the
  PR notes that a majority of the work went towards proper tracking of the
  changed resource limits for tapscript. {% assign timestamp="38:07" %}

- [Eclair #2703][] discourages spenders from forwarding payments through
  the local node when the node's balance is low and it would probably
  need to reject those payments.  This is accomplished by the node
  advertising that its maximum HTLC amount has been lowered.  Preventing
  rejected payments improves the experience for spenders and helps avoid
  the local node being penalized by pathfinding systems that discount
  nodes that have failed to forward a payment in the recent past. {% assign timestamp="45:54" %}

- [LND #7267][] makes it possible to create routes to [blinded
  paths][topic rv routing], bringing LND much closer to full support for
  making blinded payments. {% assign timestamp="47:06" %}

- [BDK #1041][] adds a module for getting data about the block chain
  from Bitcoin Core using that program's RPC interface. {% assign timestamp="47:39" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27255,2703,7267,1041" %}
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021984.html
[linus paper]: https://bitvm.org/bitvm.pdf
[nand gate]: https://en.wikipedia.org/wiki/NAND_gate
[Bitcoin Core 24.2rc2]: https://bitcoincore.org/bin/bitcoin-core-24.2/
[Bitcoin Core 25.1rc1]: https://bitcoincore.org/bin/bitcoin-core-25.1/
[riard cve]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html
[mpsbt-bip]: https://github.com/achow101/bips/blob/musig2-psbt/bip-musig2-psbt.mediawiki
[kanjalkar mpsbt]: https://gist.github.com/sanket1729/4b525c6049f4d9e034d27368c49f28a6
[chow mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021988.html
[towns mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021991.html
[BIP-329 Python Library]: https://github.com/Labelbase/python-bip329
[Doppler]: https://github.com/tee8z/doppler
[doppler announced]: https://twitter.com/voltage_cloud/status/1712171748144070863
[coldcard blog]: https://blog.coinkite.com/5.2.0-seed-vault/
[Tapleaf circuits]: https://github.com/supertestnet/tapleaf-circuits
[samourai blog]: https://blog.samourai.is/wallet-update-0-99-98i/
[krux github]: https://github.com/selfcustody/krux
