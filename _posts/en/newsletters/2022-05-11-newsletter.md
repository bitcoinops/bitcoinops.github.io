---
title: 'Bitcoin Optech Newsletter #199'
permalink: /en/newsletters/2022/05/11/
name: 2022-05-11-newsletter
slug: 2022-05-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's short newsletter summarizes a Bitcoin Core PR Review Club meeting
and describes an update to Rust Bitcoin.

## News

No significant news this week.  Topics we've previously covered,
including [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] and
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout], did receive many
additional comments---but much of the conversation was either
non-technical or about minor details that we don't consider broadly
relevant.  Several interesting posts to the developer mailing lists were
received while this issue of the newsletter was being edited; we will
cover them in detail next week.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:glozow is a PR by FIXME to FIXME.

{% include functions/details-list.md

  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/FIXME#l-17"

%}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Rust Bitcoin #716][] Added `amount::Display` - configurable formatting FIXME:adamjonas

{% include references.md %}
{% include linkers/issues.md v=2 issues="716" %}
