---
title: 'Bitcoin Optech Newsletter #268'
permalink: /en/newsletters/2023/09/13/
name: 2023-09-13-newsletter
slug: 2023-09-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to draft specifications related to taproot
assets and describes a summary of several alternative message protocols
for LN that can help enable the use of PTLCs.  Also included are our
regular sections with the summary of a Bitcoin Core PR Review Club
meeting, announcements of new software releases and release candidates,
and descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **Specifications for taproot assets:** Olaoluwa Osuntokun posted
  separately to the Bitcoin-Dev and Lightning-Dev mailing lists about
  the _Taproot Assets_ [client-side validation protocol][topic client-side
  validation].  To the Bitcoin-Dev mailing list, he [announced][osuntokun
  bips] seven draft BIPs---one more than in the initial announcement of
  the protocol, then under the name _Taro_ (see [Newsletter
  #195][news195 taro]).  To the Lightning-Dev mailing list, he
  [announced][osuntokun blip post] a [draft BLIP][osuntokun blip] for
  spending and receiving taproot assets using LN, with the protocol
  based on the experimental "simple taproot channels" feature planned to
  be released in LND 0.17.0-beta.

    Note that, despite its name, Taproot Assets is not part of the
    Bitcoin Protocol and does not change the consensus protocol in any
    way.  It uses existing capabilities to provide new features for
    users that opt-in to its client protocol.

    None of the specifications had received any discussion on the
    mailing list as of this writing.

- **LN messaging changes for PTLCs:** as the first LN implementation
  with experimental support for channels using [P2TR][topic taproot]
  and [MuSig2][topic musig] is expected to be released soon, Greg
  Sanders [posted][sanders post] to the Lightning-Dev mailing list a
  [summary][sanders ptlc] of several different previously-discussed
  changes to LN messages to allow them to support sending payments with
  [PTLCs][topic ptlc] instead of [HTLCs][topic htlc].  For most
  approaches, the changes to messages do not seem large or invasive,
  but we note that most implementations will probably continue using one
  set of messages for handling legacy HTLC forwarding while also
  offering upgraded messages to support PTLC forwarding, creating two
  different paths that will need to be maintained concurrently until
  HTLCs are phased out.  If some implementations add experimental PTLCs
  support before the messages are standardized, then implementations
  might even be required to support three or more different protocols
  simultaneously, to the disadvantage of all.

    Sander's summary has not received any comments as of this writing.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:LarryRuane

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/28122#l-126FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.17.0-beta.rc2][] is a release candidate for the next major
  version of this popular LN node implementation.  A major new
  experimental feature planned for this release, which could likely
  benefit from testing, is support for "simple taproot channels".

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26567][] Wallet: estimate the size of signed inputs using descriptors FIXME:Murchandamus

{% include references.md %}
{% include linkers/issues.md v=2 issues="26567" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[osuntokun bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021938.html
[osuntokun blip post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004089.html
[osuntokun blip]: https://github.com/lightning/blips/pull/29
[sanders post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004088.html
[sanders ptlc]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
