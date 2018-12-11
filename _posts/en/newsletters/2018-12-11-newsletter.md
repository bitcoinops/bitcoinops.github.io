---
title: "Bitcoin Optech Newsletter #25"
permalink: /en/newsletters/2018/12/11/
name: 2018-12-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter suggests helping test a Bitcoin Core maintenance
release candidate, provides a link to a modern block explorer whose code
has been open sourced, and briefly describes a suggestion for signature
hashes to optionally cover transaction size.  Notable code changes made
in the past week to popular infrastructure projects are also described.

## Action items

- **Help test Bitcoin Core 0.17.1RC1:** the first release candidate for
  this [maintenance release][] has been [uploaded][V0.17.1rc1].  Testing by businesses
  and individual users of both the daemon and the GUI is greatly
  appreciated and helps ensure the highest-quality release.

## News

- **Modern block explorer open sourced:** after recently
  [announcing][explorer announce] a new block explorer website,
  Blockstream has announced the [open source release][explorer code
  announce] of both its backend and frontend code.  The code supports
  Bitcoin mainnet, Bitcoin testnet, and the Liquid sidechain.

    Although block explorers have been a mainstay of Bitcoin web
    applications since 2010, we do note that the method used by block
    explorers of maintaining multiple indexes over all block chain data
    inherently has a poor scalability characteristic---their cost
    increases over time as the block chain grows---and so it is
    generally inadvisable to build software or services that depend upon
    your own block explorer.  Trusting someone else's block explorer
    (which is a common cost-cutting measure when indexing data yourself
    becomes too expensive) introduces third party trust into Bitcoin
    software, increases centralization, and decreases privacy.  If at
    all possible, it is preferable to build software and services in a
    way that doesn't require the types of fast and arbitrary searches
    that block explorers make convenient.

    That said, the new open source explorer appears to be quite
    efficient compared to earlier open source alternatives such as
    BitPay Insight.  It also includes modern features (such as bech32
    address support) and a very nice default theme.

- **Sighash options for covering transaction weight:** as part of the
  signature hashes discussion described in the *News* section of
  [newsletter #23][], Russell O'Connor has [proposed][weight sighash]
  that there should be an opt-in ability for transaction signatures to
  commit to the weight (size) of the transaction.  This mitigates a
  perceived problem with some advanced scripts where it might be
  possible for a counterparty or third party to add extra data to a
  transaction, lowering its feerate and likely making it take longer to
  confirm.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

- [LND #2007][] adds a new `MaxBackoff` configuration option that allows
  changing the longest amount of time the node will wait before
  giving up attempting to reconnect one of its persistent peers.
  The same current exponential backoff algorithm will be used up until
  the maximum is reached.

- [LND #2006][] makes it easier to use the autopilot recommendation
  engine with alternative recommendation engines.  The current method
  simply returns a list of peers with whom it is recommended to open new
  channels.  The new method allows specifying what data to consider and
  returns a list of nodes scored by the algorithm (higher scores being
  better).  Alternative recommendation engines can return their own scored
  recommendations, and the user (or their software) can decide how to
  aggregate or otherwise use the scores to actually decide which nodes
  should receive channel open attempts.

- [C-Lightning #2123][] adds a new `check` RPC that checks whether an
  RPC call uses valid parameters without running the call.

- [C-Lightning #2127][] adds a new `--plugin-dir` configuration option
  that will load plugins in the indicated directory.  The parameter may
  be passed multiple times for different directories.  A `--plugin`
  option also allows loading individual plugins.

- [C-Lightning #2121][] allows plugins to add new JSON-RPC methods.  To
  the user, these will look no different than the built-in methods,
  including appearing in the list of supported methods returned by the
  `help` RPC.

- [C-Lightning #2147][] adds a new `announce` parameter to the
  `fundchannel` RPC that allows marking the channel as private, meaning
  it won't be publicly announced to the network.  The default is for
  channels to be public.

{% include references.md %}
{% include linkers/issues.md issues="2007,2006,2123,2127,2121,2147" %}
{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="ed12fd83ca7999a896350197533de5e9202bc2fe"
  end="89cdcfedcac776fec6101654f98e87112ca0de5d"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="f4b6e0b7755982fc571e2763e0a2ec93c8e89900"
  end="5451211d1947de5b2376aff5eb39c6e9f969cbbb"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="3ba751797bcc54e7e071518f680b08a3ae7f42fc"
  end="dc7b76e5e6a9cd8a28731a7634db50f33287619b"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="e34ceb333b1c0e6f4115ecbb80c632ac1042fa49"
  end="e34ceb333b1c0e6f4115ecbb80c632ac1042fa49"
%}

[V0.17.1rc1]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[explorer announce]: https://blockstream.com/2018/11/06/explorer-launch/
[explorer code announce]: https://blockstream.com/2018/12/06/esplora-source-announcement/
[weight sighash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016534.html
