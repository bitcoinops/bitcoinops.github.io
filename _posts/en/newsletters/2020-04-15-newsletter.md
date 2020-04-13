---
title: 'Bitcoin Optech Newsletter #93'
permalink: /en/newsletters/2020/04/15/
name: 2020-04-15-newsletter
slug: 2020-04-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal for creating a unified
multi-wallet backup that circumvents the inability to import BIP32
extended private keys into many wallets that support deterministic key
derivation.  Also included are our regular sections describing release
candidates and changes to popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **Proposal for using one BIP32 keychain to seed multiple child keychains:**
  several weeks ago, Ethan Kosakovsky [posted][kosakovsky post] to the
  Bitcoin-Dev mailing list a [proposal][kosakovsky proposal] for using
  one [BIP32][] Hierarchical Deterministic (HD) keychain to create seeds
  for child HD keychains that can be used in different contexts.  This
  may seem unnecessary given that BIP32 already provides extended
  private keys (xprvs) that can be shared between signing wallets.  The
  problem is that many wallets don't implement the ability to import
  xprvs---they only allow importing either an HD seed or some precursor
  data that is transformed into the seed (e.g.  [BIP39][] or [SLIP39][]
  seed words).

    Kosakovsky's proposal is to create a super-keychain whose child keys
    are transformed into seeds, seed words, or other data that can be
    input into various wallets' HD keychain recovery fields.  That way a
    user with multiple wallets can backup all of them using just the
    super-keychain's seed (plus the derivation paths and the library for
    transforming deterministic entropy into input data).

    {% assign img="/img/posts/2020-04-subkeychains.dot.png" %}
    [![Using one BIP32 keychain to seed child BIP32 keychains]({{img}})]({{img}})

    Reaction to the proposal was mixed (pro: [1][react gray], [2][react back]; con: [1][react allen], [2][react rusnak]), but this week one hardware wallet
    manufacturer [stated][novak post] their intent to implement support
    for the protocol and requested additional review of the proposal.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] the first release
  candidate for the next major version of Bitcoin Core is available for
  testing by experienced users.  Please [report][bitcoin core issue] any
  problems you discover so that they can be fixed before the final
  release.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #3967][] adds support for sending [multipath payments][topic
  multipath payments], complementing the already-existing receiving logic.
  Previously, LND would fail to pay invoices whose full amount couldn't be
  carried by a single route. With multipath payments, LND can now split
  invoices into smaller HTLCs which can each take a different route, making
  better use of the liquidity in LN. Users can control the maximum
  number of partial payments using an RPC parameter or
  command line option.

- [LND #4075][] allows invoices to be created for payments greater than the
  previous limit of around 0.043 BTC. The network-wide HTLC limit of 0.043 BTC
  prevents payments greater than that amount over a single channel. With the
  implementation of sending multipath payments also
  merged in [LND this week](#lnd-3967), invoices can be issued for an aggregate
  payment amount greater than 0.043 BTC, which the sender then splits into
  partial payments.

{% include references.md %}
{% include linkers/issues.md issues="3967,4075" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[kosakovsky post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017683.html
[kosakovsky proposal]: https://gist.github.com/ethankosakovsky/268c52f018b94bea29a6e809381c05d6
[slip39]: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
[novak post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017751.html
[bitcoin core issue]: https://github.com/bitcoin/bitcoin/issues/new/choose
[react gray]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017687.html
[react back]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017713.html
[react allen]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017688.html
[react rusnak]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017684.html
