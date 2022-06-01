---
title: 'Bitcoin Optech Newsletter #203'
permalink: /en/newsletters/2022/06/08/
name: 2022-06-08-newsletter
slug: 2022-06-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with the summary of
a Bitcoin Core PR Review Club meeting, a list of new software releases
and release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

*No significant news this week.*

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:glozow

{% include functions/details-list.md

  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/21726#l-28FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.0-beta.rc4][] is a release candidate for the next major
  version of this popular LN node.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24408][] rpc: add rpc to get mempool txs spending specific prevouts FIXME:adamjonas

- [LDK #1401][] adds support for zero-conf channel opens.  For related
  information, please see the summary of BOLTs #910 below.

- [BOLTs #910][] updates the LN specification with two changes.  The
  first allows Short Channel Identifier (SCID) aliases which can improve
  privacy and also allow referencing a channel even when its txid is
  unstable (i.e., before its deposit transaction has received a reliable
  number of confirmations).  The second specification change adds an
  `option_zeroconf` feature bit that may be set when a node is willing
  to use [zero-conf channels][topic zero-conf channels].

{% include references.md %}
{% include linkers/issues.md v=2 issues="24408,1401,910" %}
[lnd 0.15.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc4
