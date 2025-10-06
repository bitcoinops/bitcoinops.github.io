---
title: 'Bitcoin Optech Newsletter #375'
permalink: /en/newsletters/2025/10/10/
name: 2025-10-10-newsletter
slug: 2025-10-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes research into tradeoffs between usability and
security in threshold signatures, summarizes an approach to convert nested
threshold signatures into a single-layer signing group, and examines the
extent to which data could be embedded in the UTXO set under a restrictive set
of rules. Also included are our regular sections summarizing a Bitcoin Core PR
Review Club meeting, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

FIXME:harding

- **Optimal Threshold Signatures**: Sindura Saraswathi [posted][sindura post]
  research, co-authored by her and Korok Ray, to Delving Bitcoin about determining the optimal threshold for a
  [multisignature][topic multisignature] scheme. In this research, the parameters of usability and
  security are explored, along with their relationship and how it affects the
  threshold that the user should select. By defining p(τ) and q(τ) and then
  combining them into a closed-form solution, they chart the gap between
  security and usability.

  Saraswathi also explores the use of degrading [threshold signatures][topic
  threshold signature] where early stages use higher thresholds, which gradually
  decline in later stages. This means that over time, the attacker gains more
  access to take the funds. She also says that using [taproot][topic taproot],
  there may be new possibilities to be unlocked with these through taptrees and
  more complex contracts, including [timelocks][topic timelocks] and multiple signatures.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/31829#l-12FIXME"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2025-10-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[sindura post]: https://delvingbitcoin.org/t/optimal-threshold-signatures-in-bitcoin/2023
