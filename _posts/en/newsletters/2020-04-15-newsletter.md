---
title: 'Bitcoin Optech Newsletter #93'
permalink: /en/newsletters/2020/04/15/
name: 2020-04-15-newsletter
slug: 2020-04-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

## Action items

*None this week.*

## News

FIXME

- BIP32/39 seed thing (bitcoin-dev)

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #4075][] allows invoices to be created for payments greater than the
  previous limit of around 0.043 BTC. The network-wide HTLC limit of 0.043 BTC
  prevents payments greater than that amount over a single channel. With the
  implementation of sending multipath payments also
  merged in [LND this week](#lnd-3967), invoices can be issued for an aggregate
  payment amount greater than 0.043 BTC, which the sender then splits into
  partial payments.

{% include references.md %}
{% include linkers/issues.md issues="3967,4075" %}
