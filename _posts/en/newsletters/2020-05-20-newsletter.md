---
title: 'Bitcoin Optech Newsletter #98'
permalink: /en/newsletters/2020/05/20/
name: 2020-05-20-newsletter
slug: 2020-05-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME:harding

## Action items

FIXME:harding

## News

FIXME:harding

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

FIXME:harding to update Tuesday afternoon with latest releases and RCs

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] is a release candidate
  for the next major version of Bitcoin Core.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until version 0.21, about six months after the release of the upcoming
version 0.20.*

- [Bitcoin Core #18877][] Serve cfcheckpt requests FIXME:jnewbery

- [Bitcoin Core #18894][] fixes a UI bug that affected users of both
  multi-wallet mode in the GUI and manual coin control.  The bug was
  described as a [known issue][coin control bug] in the Bitcoin Core
  0.18 release notes.  This is tagged to be included in the second
  release candidate for Bitcoin Core 0.20.

- [C-Lightning #3614][] coinmoves: FIXME:dongcarl

- [Bitcoin #18808][] causes Bitcoin Core to ignore any P2P protocol
  `getdata` requests that specify an unknown type of data.  The new
  logic will also ignore requests for types of data that aren't expected
  to be sent over the current connection, such as requests for
  transactions (type: `tx`) on block-relay-only connections.
  Previously, Bitcoin Core wouldn't process any further requests from
  a peer after it received an unknown type, effectively stalling that
  connection.

- [Eclair #1395][] updates the route pathfinding used by Eclair to
  factor in channel balances and to use [Yen's algorithm][].  Testing
  quoted in the PR description says, "The new algorithm consistently
  finds more routes and cheaper ones. The route prefix are more diverse,
  which is good as well (especially for MPP).  [...] and the new [code]
  is consistently 25% faster on my machine (when looking for 3 routes)."

{% include references.md %}
{% include linkers/issues.md issues="18877,18894,3614,18808,1395" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[coin control bug]: https://bitcoincore.org/en/releases/0.18.0/#wallet-gui
[yen's algorithm]: https://en.wikipedia.org/wiki/Yen's_algorithm
