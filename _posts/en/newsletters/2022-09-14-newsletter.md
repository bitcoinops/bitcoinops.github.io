---
title: 'Bitcoin Optech Newsletter #217'
permalink: /en/newsletters/2022/09/14/
name: 2022-09-14-newsletter
slug: 2022-09-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular section with the summary of
a Bitcoin Core PR Review Club meeting, a list of new software releases and
release candidates, and summaries of notable changes to popular Bitcoin
infrastructure projects.

## News

*No significant news this week.*

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:LarryRuane

{% include functions/details-list.md
  q0=""
  a0=""
  a0link="https://bitcoincore.reviews/25527#l-FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.111][] adds support for creating, receiving, and relaying
  [onion messages][topic onion messages], among several other new
  features and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25614][] severity-based logging FIXME:adamjonas

- [Bitcoin Core #25768][] fixes a bug where the wallet wouldn't always
  rebroadcast unconfirmed transactions' child transactions.  Bitcoin
  Core's built-in wallet periodically attempts to broadcast any of its
  transactions which haven't been confirmed yet.  Some of those
  transactions may spend outputs from other unconfirmed transactions.
  Bitcoin Core was randomizing the order of transactions before sending
  them to a different Bitcoin Core subsystem that expected to receive
  unconfirmed parent transactions before child transactions (or, more
  generally, all unconfirmed ancestors before any descendants).  When a
  child transaction was received before its parent, it was internally
  rejected instead of being rebroadcast.

- [Bitcoin Core #19602][] adds a `migratewallet` RPC that will convert a
  wallet to natively using [descriptors][topic descriptors].  This works for pre-HD wallets (those
  created before [BIP32][] existed or was adopted by Bitcoin Core), HD
  wallets, and watch-only wallets without private keys.  Before calling
  this function, read the [documentation][managing wallets] and be aware
  that there are some API differences between non-descriptor wallets and
  those that natively support descriptors.

<!-- TODO:harding to separate dual funding from interactive funding -->

- [Eclair #2406][] adds an option for configuring the experimental
  [interactive funding protocol][topic dual funding] implementation to
  require that channel open transactions only include *confirmed
  inputs*---inputs which spend outputs that are a part of a confirmed
  transaction.  If enabled, this can prevent an initiator from delaying
  a channel open by basing it off of a large unconfirmed transaction
  with a low feerate.

- [Eclair #2190][] removes support for the original fixed-length onion
  data format, which is also proposed for removal from the LN
  specification in [BOLTs #962][].  The upgraded variable-length format
  was [added to the specification][bolts #619] more than three
  years ago and network scanning results mentioned in the BOLTs #962 PR
  indicate that it is supported by all but 5 out of over 17,000 publicly
  advertised nodes.  Core Lightning also removed support earlier this
  year (see [Newsletter #193][news193 cln5058]).

- [Rust Bitcoin #1196][] modifies the previously-added `LockTime` type
  (see [Newsletter #211][news211 rb994]) to be a `absolute::LockTime`
  and adds a new `relative::LockTime` for representing locktimes used
  with [BIP68][] and [BIP112][].

{% include references.md %}
{% include linkers/issues.md v=2 issues="25614,25768,19602,2406,2190,962,619,1196" %}
[managing wallets]: https://github.com/bitcoin/bitcoin/blob/master/doc/managing-wallets.md
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news211 rb994]: /en/newsletters/2022/08/03/#rust-bitcoin-994
[ldk 0.0.111]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.111
