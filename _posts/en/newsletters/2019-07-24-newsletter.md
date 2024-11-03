---
title: 'Bitcoin Optech Newsletter #56'
permalink: /en/newsletters/2019/07/24/
name: 2019-07-24-newsletter
slug: 2019-07-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes progress on signet and an idea for just-in-time
routing on LN.  Also included are our regular sections about bech32
sending support and notable changes to popular Bitcoin infrastructure
projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Help test Bitcoin Core 0.18.1 release candidates:** this upcoming
  maintenance release fixes several bugs that affected some RPC
  commands and caused unnecessarily high CPU use in certain cases.
  Production users are encouraged to test the current [release
  candidate][core rc] to ensure that it operates as expected.

## News

- **Progress on signet:** signet is a testnet alternative where valid
  blocks are signed by a trusted authority.  The authority generally produces
  a regular series of blocks but may occasionally produce forks leading
  to block chain reorganizations.  This avoids commonly-encountered
  problems on testnet such as too-fast block production, too-slow block
  production, and reorganizations involving thousands of blocks.
  Subsequent to our earlier report on signet in [Newsletter #37], its
  author has created an implementation, documented it on a [wiki
  page][signet wiki], opened a [PR][Bitcoin Core #16411] proposing to
  add support for signet to Bitcoin Core, and posted a [draft
  BIP][signet bip post] to the Bitcoin-Dev mailing list.
  The proposed implementation also makes it easy for teams to create
  their own independent signets for specialized group testing, e.g.
  signet author Kalle Alm reports that "someone is already working on a
  signet with [bip-taproot][] patched on top of it."
  Signet has the
  potential to make it much easier for developers to test their
  applications in a multi-user environment, so we encourage all current
  testnet users and anyone else interested in signet to review the
  above code and documentation to ensure signet will fulfill your needs.

- **Additional Just-In-Time (JIT) LN routing discussion:** in the JIT
  discussion described in the [newsletter][Newsletter #54] two weeks ago,
  contributor ZmnSCPxj explained why routing nodes needed zero-fee
  rebalance operations in many cases for JIT routing to be incentive
  compatible.  This week he [posted][jit with fee] a suggestion to the C-Lightning
  mailing list on how nodes could be less incentive compatible but still
  prevent abuse when performing paid rebalancing for JIT routing.
  Nodes would keep track of how much routing fee they had earned from each
  channel and spend up to that amount on rebalancing.  This would ensure
  that a dishonest channel counterparty couldn't steal any more than it
  had already allowed its honest peers to claim in routing fees.

## Bech32 sending support

*Week 19 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/19-real-fees.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #15891][] changes the node defaults when using
  regtest mode to enforce the same standard transaction rules used on
  mainnet.  Those rules determine which transactions nodes relay and
  accept into the mempool.  This change should make it easier for
  developers to test their custom transactions against the default
  policy.  Anyone who needs the old behavior of relaying and accepting
  any consensus-valid transaction may use the `acceptnonstdtxn`
  configuration parameter.

- [Bitcoin Core #16152][] disables [BIP37][] bloom filter support by
  default.  This feature allowed lightweight wallets to create a [bloom
  filter][] from a list of their addresses, send that filter to a node,
  ask the node to scan historic blocks or new incoming transactions, and
  receive back only those transactions that matched the filter.  This
  allowed the lightweight client to only receive the transactions it was
  interested in (plus maybe a few extra false-positive matches),
  reducing its bandwidth requirements.  However, it also meant that
  clients could require full nodes to scan and rescan through the entire
  historic block chain over and over at no cost to the client---creating
  the vector for a DoS attack.

  For that reason and others (including [privacy concerns][filter
  privacy]) a number of Bitcoin Core contributors have wanted to disable
  the feature for several years now.  Early efforts to that end
  included adding a [BIP111][] services flag to indicate whether or
  not a node supports bloom filters so that clients can find
  supporting nodes, and a `peerbloomfilters` configuration option that
  allows node users to disable bloom filters in case they're worried
  about the DoS attack.  Additionally, bloom filter support was never
  updated for checking the contents of the new witness field after
  segwit was activated, making it less useful than it could be for
  segwit wallets.

  With this PR #16152, the bloom filter configuration option is now
  set by default to off.  Users who still want to serve bloom filters
  can re-enable it.  More notably, many nodes continue to run old versions
  for years after newer versions have become available, so it's
  expected that developers of wallets using bloom filters will have
  some time after the release of Bitcoin Core 0.19
  ([estimated][Bitcoin Core #15940] late 2019) to find a replacement
  source of data.

- [Bitcoin Core #15681][] adds an exception to Bitcoin Core's
  package limitation rules used to prevent CPU- and memory-wasting DoS
  attacks.  Previously, if a transaction in the mempool had 25
  descendants, or it and all of its descendants were over 101,000 vbytes,
  any newly-received transaction that was also a descendant would be
  ignored.  Now, one extra descendant will be allowed provided it is an
  immediate descendant (child) and the child's size is 10,000 vbytes or
  less.  This makes it possible for two-party contract protocols such as
  LN to give each participant an output they can spend immediately for
  Child-Pays-For-Parent (CPFP) fee bumping without allowing one malicious
  participant to fill the entire package and thus prevent the other
  participant from spending their output.  This proposal was previously
  [discussed][carve-out] on the Bitcoin-Dev mailing list (see
  [Newsletter #24][]).

- [C-Lightning #2816][] adds support for testing on the signet network
  (see signet description in the *news* section above).

## Footnotes

{% include linkers/issues.md issues="15891,16152,15681,16411,15940,2816" %}
[bech32 series]: /en/bech32-sending-support/
[bloom filter]: https://en.wikipedia.org/wiki/Bloom_filter
[filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/
[carve-out]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[core rc]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[signet wiki]: https://en.bitcoin.it/wiki/Signet
[signet bip post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017123.html
[jit with fee]: https://lists.ozlabs.org/pipermail/c-lightning/2019-July/000160.html
[newsletter #54]: /en/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[newsletter #24]: /en/newsletters/2018/12/04/#cpfp-carve-out
