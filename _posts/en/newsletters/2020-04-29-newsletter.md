---
title: 'Bitcoin Optech Newsletter #95'
permalink: /en/newsletters/2020/04/29/
name: 2020-04-29-newsletter
slug: 2020-04-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

## Action items

FIXME:harding

- LN security, see news item about BlueMatt thing

## News

FIXME:harding

- BlueMatt LN HTLC thing dual-list
- Vaults bitcoin-dev
- Maybe PTLC post lightning-dev

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

## Releases and release candidates

FIXME:harding update

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] is a release candidate
  for the next major version of Bitcoin Core.

- [LND 0.10.0-beta.rc4][lnd 0.10.0-beta] allows testing the next major
  version of LND.

- [C-Lightning 0.8.2-rc1][c-lightning 0.8.2] is the first release
  candidate for the next version of C-Lightning.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Rust-Lightning][rust-lightning repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

FIXME:harding mention core commits apply only to 0.21

- [Bitcoin Core #15761][] Replace -upgradewallet startup option with upgradewallet RPC FIXME:adamjonas

- [Bitcoin Core #17509][] gui: save and load PSBT FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="15761,17509" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta.rc4
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2rc1
