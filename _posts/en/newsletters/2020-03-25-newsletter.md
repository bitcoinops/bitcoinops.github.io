---
title: 'Bitcoin Optech Newsletter #90'
permalink: /en/newsletters/2020/03/25/
name: 2020-03-25-newsletter
slug: 2020-03-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes several questions and answers from the
Bitcoin StackExchange and describes notable changes to popular Bitcoin
infrastructure projects.

## Action items

*None this week.*

## News

*No significant news about Bitcoin infrastructure development this week.*

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #1339][] prevents users from setting their htlc-minimum
  amount to 0 milli-satoshis, which would violate [BOLT2][].<!-- "A
  receiving node [...] receiving an `amount_msat` equal to 0 [...]
  SHOULD fail the channel." --> The new minimum is 1 milli-satoshi.

- [LND #4051][] tracks up to ten errors per peer, storing them across
  reconnections if necessary.  The latest error message is returned as
  part of the `ListPeers` results, making it easier to diagnose
  problems.

- [BOLTs #751][] Allow More than one Address of a given type FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="1339,3697,4051,751" %}
