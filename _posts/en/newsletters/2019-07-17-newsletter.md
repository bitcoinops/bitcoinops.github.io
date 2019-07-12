---
title: 'Bitcoin Optech Newsletter #55'
permalink: /en/newsletters/2019/07/17/
name: 2019-07-17-newsletter
slug: 2019-07-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal for an update to the LN
gossip protocol. Also included are our regular sections on bech32
sending support and notable changes in popular Bitcoin infrastructure
projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*None this week.*

## News

- **Gossip update proposal:** Rusty Russell made a [short proposal][v2
  gossip proposal] to update the gossip protocol that LN nodes use to
  announce what channels they have available for routing payments and
  what capabilities those channels currently support.  Most notably, the
  proposal significantly reduces the byte size of messages through two
  mechanisms: schnorr signatures and optional message extensions.
  Schnorr signatures based on [bip-schnorr][] save a few bytes because
  of their more efficient encoding compared to DER-encoded ECDSA
  signatures, but their most significant savings in the gossip
  improvement proposal comes from the ability to aggregate the two
  signatures for a channel announcement into a single signature using
  [MuSig][].  Optional message extensions using Type-Length-Value (TLV)
  records allow omitting unnecessary details when the protocol defaults
  are being used (for more information about TLV, see the *notable
  code and documentation changes* section below).

## Bech32 sending support

*Week 18 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/18-real-fees.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #15277][] allows the Linux versions of Bitcoin Core to
  be deterministically compiled using [GNU Guix][] (pronounced "geeks").
  This requires much less setup than the currently-still-supported
  mechanism based on [Gitian][] and so it is hoped that it will lead to a
  greater number of users being able to independently verify that the
  release binaries are derived solely from the Bitcoin Core source code
  and its dependencies.  Additionally, Guix requires fewer build
  environment dependencies and there is ongoing work to essentially
  eliminate its need for any pre-compiled binaries in the typical build
  toolchain, both of which make the build system much easier to audit.
  Altogether this should reduce the amount of trust users need to place
  in the developers of Bitcoin Core and the software used to build
  Bitcoin Core.  Although this merged PR only builds Linux binaries,
  it is expected that support for Windows and macOS will
  follow.  For more information, see PR author Carl Dong's recent talk
  from the Breaking Bitcoin conference ([video][guix vid],
  [transcript][guix transcript]).

- [BOLTs #607][] extends the LN specification to allow packets to contain
  records that start with a *type* identifying their purpose, followed by
  the message *length* and the record's *value*, called TLV records.
  Because each message starts with a type and a length, LN nodes can
  ignore records with a type they don't understand---e.g., optional parts
  of the specification that are newer than the node or experimental
  records that are only being used by a subset of nodes and so aren't
  part of the spec yet.  Existing LN records haven't been converted to
  use TLV, but subsequently-added optional records are expected to use
  this format.  All LN implementations monitored by Optech currently
  support TLV on at least their development branch.

- [BIPs #784][] updates [BIP174][] Partially-Signed Bitcoin Transactions
  (PSBTs) to include a [BIP32][] extended pubkey (xpub) field in the
  global section.  This is described in a new part of the BIP entitled
  "Change Detection" that describes how signing wallets can use this new
  field to identify which outputs belong to that wallet (in whole or as
  part of a set of wallets using multisig).  The idea for this
  modification of the specification was previously discussed on the
  Bitcoin-Dev mailing list as described in [Newsletter #46][].

{% include linkers/issues.md issues="607,16237,784,15277" %}
[bech32 series]: /en/bech32-sending-support/
[v2 gossip proposal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002065.html
[Gitian]: https://github.com/devrandom/gitian-builder
[GNU Guix]: https://www.gnu.org/software/guix/
[guix vid]: https://www.youtube.com/watch?v=DKOG0BQMmmg&feature=youtu.be&t=19828
[guix transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/bitcoin-build-system/
