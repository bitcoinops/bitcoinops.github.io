---
title: 'Bitcoin Optech Newsletter #158'
permalink: /en/newsletters/2021/07/21/
name: 2021-07-21-newsletter
slug: 2021-07-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes recent changes to services and client
software, discusses why wallets should wait before generating taproot
addresses, lists new software releases and release candidates, and
summarizes notable changes to popular Bitcoin infrastructure software.

## News

*No significant news this week.*

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Preparing for taproot #5: why are we waiting?

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/04-why-wait.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.13.1-beta][] is a maintenance release with
  minor improvements and bug fixes for features introduced in
  0.13.0-beta.

- [Rust-Lightning 0.0.99][] is a release with a few API and
  configuration changes.  See its [release notes][rl 0.0.99 rn] for
  details.

- [Eclair 0.6.1][] is a new release with performance improvements, a few
  new features, and several bug fixes.  In addition to its [release
  notes][eclair 0.6.1], see the descriptions of Eclair #1871 and #1846
  in the *notable changes* section below.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22112][] Force port 0 in I2P FIXME:jnewbery

- [C-Lightning #4611][] updates the plugin-provided `keysend` RPC to
  add a `routehints` parameter which allows providing information for
  routing payments to [unannounced channels][topic unannounced
  channels].

- [C-Lightning #4646][] makes two changes in preparation for removing
  old behavior.  The first change assumes nodes support the
  TLV-style encoding added in 2019 (see [Newsletter #55][news55 tlv]).
  Only nodes that explicitly indicate they don't support TLV encoding
  will be treated differently.
  The second change makes payment secrets required (see [Newsletter
  #75][news75 payment secrets] for previous discussion and [Newsletter
  #126][news126 lnd4752] for when LND began requiring it).

- [C-Lightning #4614][] updates the `listchannels` RPC with a new
  optional `destination` parameter that can be used to only return
  channels that lead to the requested node.

- [Eclair #1871][] changes its SQLite settings to increase by 5x the
  number of [HTLCs][topic htlc] it can process per second and also
  increase its robustness against data loss.  Referenced in the PR is a
  [blog post][jager ln perf] by Joost Jager comparing HTLC throughput in
  various node software.

- [Eclair #1846][] adds opt-in support for using an *upfront shutdown
  script*---an address the node specifies when negotiating a new channel
  that the remote peer agrees will be the only address it'll allow to be
  used in a later mutual close of the channel.  See also [Newsletter
  #76][news76 upfront shutdown] describing LND's implementation of this
  feature.

- [Rust-Lightning #975][] Make the base fee configurable in ChannelConfig FIXME:dongcarl

- [BTCPay Server #2462][] makes it easier to use BTCPay to track
  payments made from a separate wallet, such as the case where the
  operator of an instance wants to pay a refund using their own personal
  wallet.

## Footnotes

{% include references.md %}
{% include linkers/issues.md issues="22112,4611,4646,4614,1871,1846,975,2462" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta
[eclair 0.6.1]: https://github.com/ACINQ/eclair/releases/tag/v0.6.1
[news76 upfront shutdown]: /en/newsletters/2019/12/11/#lnd-3655
[rl 0.0.99 rn]: https://github.com/rust-bitcoin/rust-lightning/blob/main/CHANGELOG.md#0099---2021-07-09
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[news75 payment secrets]: /en/newsletters/2019/12/04/#c-lightning-3259
[news126 lnd4752]: /en/newsletters/2020/12/02/#lnd-4752
[jager ln perf]: https://bottlepay.com/blog/bitcoin-lightning-node-performance/
[rust-lightning 0.0.99]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.99
