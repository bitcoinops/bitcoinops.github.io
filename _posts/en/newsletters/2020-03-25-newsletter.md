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
Bitcoin Stack Exchange and describes notable changes to popular Bitcoin
infrastructure projects.

## Action items

*None this week.*

## News

*No significant news about Bitcoin infrastructure development this week.*

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why does the banscore default to 100?]({{bse}}93795) User Anonymous
describes some history behind `banscore`, which protects nodes
from misbehaving peers. Although some offenses result in a 100
point increase---and thus the immediate banning of the offending peer under the default
`banscore` setting---other offenses detailed in
[`net_processing.cpp`][bitcoin net processing] have different scores.

- [Why is block 620826's timestamp 1 second before block 620825?]({{bse}}93696)
Andrew Chow and Raghav Sood clarify that a block header's timestamp field is not
required to have a greater value than previous blocks. The requirements are
instead that a new block's timestamp must be greater than the median
timestamp of the past 11 blocks but no later than two hours after the
present time according to the clock on the computer running the node.

- [Where can I find the miniscript policy language specification?]({{bse}}93764)
Andrew Chow and Pieter Wuille explain that there is not a specification for how
the [miniscript][topic miniscript] policy language is compiled to miniscript and
that both the current C++ and Rust implementations effectively try every
possibility and choose the miniscript resulting in the smallest `scriptWitness` size.

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

- [BOLTs #751][] updates [BOLT7][] to allow nodes to announce multiple
  IP addresses of a given type (e.g. IPv4, IPv6, or Tor). This ensures
  that multi-homed nodes can better inform the network of their network
  connectivity.  Several LN implementations were already announcing or
  allowing multiple addresses of a given type, so this change brings the
  BOLT specification in line with what the implementations were already
  doing.

{% include references.md %}
{% include linkers/issues.md issues="1339,3697,4051,751" %}
[bitcoin net processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.cpp
