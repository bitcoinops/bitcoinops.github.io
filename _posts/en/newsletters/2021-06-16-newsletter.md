---
title: 'Bitcoin Optech Newsletter #153'
permalink: /en/newsletters/2021/06/16/
name: 2021-06-16-newsletter
slug: 2021-06-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter celebrates the lock-in of the taproot soft fork,
describes a draft BIP for improving transaction
privacy by varying the fields used to implement anti fee sniping, and
features an article about the challenges of combining transaction
replacement with payment batching.  Also included are our regular
sections with announcements of new software releases and release
candidates, plus notable changes to popular Bitcoin infrastructure
software.

## News

- **🟩  Taproot locked in:** the [taproot][topic taproot] soft fork and
  related changes specified in BIPs [340][bip340], [341][bip341], and
  [342][bip342] were locked in by signaling miners last weekend.
  Taproot will be safe to use after block 709,632, which is expected in
  early or mid November.  The delay gives time for users to upgrade
  their nodes to a release (such as Bitcoin Core 0.21.1 or later) that will
  enforce taproot's rules, ensuring that funds received to taproot
  scripts after block 709,632 are safe even if there's a problem with
  miners.

    Developers are encouraged to start [implementing taproot][taproot
    uses] so they can
    be ready to take advantage of greater efficiency, privacy, and
    fungibility as soon as the activation is complete.

    Readers celebrating the lock-in of taproot may also wish to read a
    [short thread][wuille taproot] about taproot's origins and history by
    developer Pieter Wuille.

- **BIP proposed for wallets to set nSequence by default on taproot transactions:**
  Chris Belcher [posted][belcher post] a draft BIP to the Bitcoin-Dev
  mailing list suggesting an alternative way wallets can implement [anti
  fee sniping][topic fee sniping].  The alternative method would enhance
  the privacy and fungibility of transactions made by single-sig users,
  [multisignature][topic multisignature] users, and users of certain
  contract protocols such as taproot-enabled LN or advanced
  [coinswaps][topic coinswap].

    Anti fee sniping is a technique some wallets implement to discourage
    miners from trying to steal fees from each other in a way that would
    reduce the amount of proof of work expended on securing Bitcoin and
    limit users' ability to rely on confirmation scores.  All wallets
    that implement anti fee sniping today use nLockTime height locks,
    but it's also possible to implement the same protection using
    [BIP68][] nSequence height locks.  This wouldn't be any more
    effective at preventing fee sniping, but it would provide a good
    reason for regular wallets to set their nSequence values to the same
    values that are required for transactions in certain
    multisignature-based contract protocols, such as ideas for coinswaps
    and taproot-enabled LN.  This helps make regular wallet transactions
    look like contract protocol transactions and vice versa.

    Belcher's proposal suggests wallets randomly choose between using
    either nLockTime or nSequence with 50% probability when both options
    are available.  Overall, if the proposal is implemented, it will
    allow users of regular single-sig transactions or uncomplicated
    multisignatures to join together with users of contract protocols to
    mutually improve each others' privacy and fungibility.

## Field Report: Using RBF and Additive Batching

{% include articles/cardcoins-rbf-batching.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Rust Bitcoin 0.26.2][] is the project's latest minor release.
  Compared to the previous major version, it contains a several API
  improvements and bug fixes.  See the [changelog][rb changelog] for
  details.

- [Rust-Lightning 0.0.98][] is a minor release containing several
  improvements and bug fixes.  <!-- there's no release notes or
  changelog I can see, so not much to say here. -->

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta] is a release candidate that
  adds support for using a pruned Bitcoin full node, allows receiving
  and sending payments using Atomic MultiPath ([AMP][topic multipath payments]),
  and increases its [PSBT][topic psbt] capabilities, among other improvements
  and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core GUI #4][] adds initial support for using [Hardware Wallet
  Interface (HWI)][topic hwi] external signers via the GUI. Once this feature is
  finalized, users will be able to use their HWI-compatible hardware wallets
  directly from the Bitcoin Core GUI.

    {:.center}
    ![Screenshot of HWI path configuration option](/img/posts/2021-06-gui-hwi.png)

- [Bitcoin Core #21573][] updates the version of libsecp256k1 included
  in Bitcoin Core.  The most notable change is the use of the
  optimized modular inverse code described in Newsletters [#136][news136
  safegcd] and [#146][news146 safegcd].  Performance evaluations posted
  to the PR found it accelerated old block verification by about 10%.

- [C-Lightning #4591][] adds support for parsing [bech32m][topic bech32]
  addresses. C-Lightning will now permit a peer that has negotiated the feature
  `option_shutdown_anysegwit` to specify any v1+ native segwit address as
  a closing or withdrawal destination.

{% include references.md %}
{% include linkers/issues.md issues="4,21573,4591" %}
[Rust Bitcoin 0.26.2]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.26.2
[Rust-Lightning 0.0.98]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.98
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[belcher post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019048.html
[news136 safegcd]: /en/newsletters/2021/02/17/#faster-signature-operations
[news146 safegcd]: /en/newsletters/2021/04/28/#libsecp256k1-906
[taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
[wuille taproot]: https://twitter.com/pwuille/status/1403725170993336322
[rb changelog]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/CHANGELOG.md#0262---2021-06-08
