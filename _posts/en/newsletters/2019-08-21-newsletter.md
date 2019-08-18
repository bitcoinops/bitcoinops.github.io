---
title: 'Bitcoin Optech Newsletter #60'
permalink: /en/newsletters/2019/08/21/
name: 2019-08-21-newsletter
slug: 2019-08-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter notes a change to Bitcoin Core's consensus logic
and announces a new feature on the Optech website for tracking
technology adoption between different wallets and services.  Also
included are our regular sections about bech32 sending support and notable
changes in popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Upgrade to C-Lightning 0.7.2.1:** this [release][cl release]
  contains several bug fixes as well as new features for plugin
  management and support for the in-development alternative to testnet,
  signet.

## News

- **Hardcoded previous soft fork activation blocks:** the heights of the
  blocks where two previous soft forks activated have now been hardcoded
  into Bitcoin Core as the point where those forks activate.  This
  means any block chain reorganization that extends further back than
  those blocks can create a chainsplit between nodes with this
  hardcoding and those without it.  However, such a reorganization would
  require an amount of proof of work roughly equal to the annual output
  of all active Bitcoin miners (at the time of writing), so this is
  considered to be both very unlikely and indicative of a threat that
  could prevent consensus formation anyway.  The hardcoding, which is
  similar to the [BIP90][] hardcoding made a couple of years ago,
  simplifies Bitcoin Core's consensus code.  For more information, see
  the [mailing list post][buried post] or [PR #16060][Bitcoin Core
  #16060].

- **New Optech Compatibility Matrix:** a [new feature][compatibility
  matrix] on the Optech
  website shows what wallets and services support certain recommended
  features, currently opt-in Replace-by-Fee (RBF) and segwit (with more
  comparisons planned for the future).  The matrix is designed to help
  developers gauge how well supported features are and learn from the
  designs of early adopters.  For details, please see our [announcement
  post][compat announce].

## Bech32 sending support

*Week 23 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

The *News* section from this week's newsletter introduced a new feature
on the Optech website.  {% include specials/bech32/23-compat.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16248][] extends the whitelisting configuration options
  in Bitcoin Core to allow specifying which services should be provided
  to different IP addresses or ranges.  For example, a motivation for
  the change was allowing bloom filters to be provided to particular
  peers (such as a user's own lightweight wallet) even if the filters
  are disabled by default.  This can be done with
  `-whitelist=bloomfilter@1.2.3.4/32`.  If only an IP
  address is provided (i.e., no permissions are specified), the behavior
  is the same as before.

- [Bitcoin Core #16383][] changes RPC commands that accept an
  `include_watchonly` parameter so that it is automatically set to True
  for wallets that have private keys disabled (i.e. that are only useful
  as watch-only wallets).  This ensures results for watch-only addresses
  are included in results.

- [Bitcoin Core #15986][] extends the `getdescriptorinfo` RPC described
  in [Newsletter #34][news34 pr15368] with an additional `checksum`
  field.  The RPC already added a checksum to any descriptor provided
  without one, but it also normalized the descriptor by removing private
  keys and making other changes users might not want.  The new field
  added in this merge returns the checksum for the descriptor exactly as
  it was provided by the user.  Descriptor checksums follow a `#`
  character at the end of the string as described in the [output script
  descriptor][] documentation.

- [Bitcoin Core #16060][] adds the hardcoded block heights for previous
  soft forks as [described in the *news* section.][hc heights]

- [LND #3391][] always returns the same error message for failed
  payments in order to avoid leaking whether or not an invoice exists.
  See [BOLTs #516][] for more details about the
  information leak and [BOLTs #608][] for a related leak.

- [LND #3355][] extends the `GetInfo` RPC with a `SyncedToGraph` bool
  that indicates whether or not the node thinks it has the latest gossip
  information so that it can efficiently route payments.

{% include linkers/issues.md issues="16248,16383,15986,3391,516,608,3355,16060" %}
[bech32 series]: /en/bech32-sending-support/
[buried post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017266.html
[compat announce]: /en/2019-compatibility-matrix/
[news34 pr15368]: {{news34}}#bitcoin-core-15368
[hc heights]: #hardcoded-previous-soft-fork-activation-blocks
[cl release]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.2.1
