---
title: 'Bitcoin Optech Newsletter #133'
permalink: /en/newsletters/2021/01/27/
name: 2021-01-27-newsletter
slug: 2021-01-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a meeting to discuss taproot activation
mechanisms, includes a link to a Bitcoin Core usage survey, and includes our
regular sections with top questions and answers from the Bitcoin StackExchange,
a list of releases and release candidates, and descriptions of notable changes
to popular Bitcoin infrastructure software.

## News

- **Scheduled meeting to discuss taproot activation:** Michael Folkson
  [announced][folkson announce] that a meeting will be held at <time
  datetime="2021-02-02 19:00-0000">19:00 UTC on February 2nd</time> in
  the [##taproot-activation][] IRC channel on Freenode to
  discuss some desired revisions to [BIP8][].  It has not yet been
  decided that BIP8 will actually be used for the activation, so
  alternative proposals may also be discussed during the meeting or at a
  subsequent meeting.  Please see Folkson's email for background
  information about [taproot][topic taproot] activation mechanisms and a proposed agenda
  for the meeting.

- **Bitcoin Core Usage Survey:** Bitcoin Core developer Andrew Chow
  created a [survey][chow survey] for users of Bitcoin Core.  As
  explained in a [blog post][chow blog] about the survey, answers
  will be used to help inform developers about what people use and want
  from the software.  The survey will run until March 2nd.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [How is the whitepaper decoded from the blockchain?]({{bse}}35959)
  In a follow up to the original 2015 question, Steven Roose provides a one line
  `bitcoin-cli` command using `getrawtransaction` against a full node to
  generate a PDF of the Bitcoin whitepaper. [jb55 provides][bitcoin whitepaper gettxout]
  a similar command using `gettxout` which works against a pruned node.

- [Full list of "special cases" during Bitcoin Script execution?]({{bse}}101142)
  Pieter Wuille provides an overview of Bitcoin script evaluation in pseudocode
  including the conditions for additional rules for both [BIP16][] P2SH and
  [BIP141][] segwit.

- [Would first-seen prevent a double spend attack?]({{bse}}101827)
  David Lynch asks if moving away from [Replace-By-Fee (RBF)][topic rbf] would
  prevent double spend attacks. Pieter Wuille describes a variety of nuanced
  considerations and incentives surrounding transaction propagation on the
  network concluding that no type of unconfirmed transaction can be trusted and
  users should wait for confirmations.

- [How do light clients using compact block filters get relevant unconfirmed transactions?]({{bse}}101512)
  User Pseudonymous explains that while [BIP37][topic transaction bloom
  filtering] bloom transaction filtering supports unconfirmed transactions,
  [compact block filters][topic compact block filters] have no such
  consideration and only service light clients with condensed block data since
  light clients have no way of verifying that unconfirmed transactions are valid.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.9.3][c-lightning 0.9.3] is the project's newest minor release.
  It includes several improvements to the user interface and plugin
  capabilities, plus experimental support for the proposed onion
  messages protocol (see [Newsletter #92][news92 cl3600]) and the offers protocol (see
  [Newsletter #128][news128 cl4255]).  See the [release
  notes][c-lightning 0.9.3] and [changelog][cl cl] for details.

- [LND 0.12.0-beta][] is the latest release for the next major version
  of this LN software.  It includes support for using watchtowers with
  [anchor outputs][topic anchor outputs] and adds a new `psbt` wallet
  subcommand for working with [PSBTs][topic psbt], among other
  improvements and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #19866][] eBPF Linux tracepoints FIXME:Xekyo

- [Bitcoin Core #17920][] adds support for using GNU Guix to
  [reproducibly build][topic reproducible builds] Bitcoin Core binaries for macOS.  Windows and
  several Linux platforms were already supported, so the new Guix
  deterministic build system now supports all the same platforms as the
  existing Gitian system.

- [LND #4908][] ensures that channels using [anchor outputs][topic anchor outputs] can fee-bump their
  commitment transactions on closure by enforcing a reserve balance in some
  instances. Notably, the general `SendCoins` RPC call does not yet enforce this
  balance reserve, other than in the case of when `send_all` is set.

{% include references.md %}
{% include linkers/issues.md issues="19866,17920,4908" %}
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta
[c-lightning 0.9.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.3
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[news92 cl3600]: /en/newsletters/2020/04/08/#c-lightning-3600
[news128 cl4255]: /en/newsletters/2020/12/16/#c-lightning-4255
[cl cl]: https://github.com/ElementsProject/lightning/blob/v0.9.3/CHANGELOG.md#093---2021-01-20
[folkson announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018370.html
[chow survey]: https://survey.alchemer.com/s3/6081474/8acd79087feb
[chow blog]: https://achow101.com/2021/01/bitcoin-core-survey
[bitcoin whitepaper gettxout]: https://bitcoinhackers.org/@jb55/105595146491662406
