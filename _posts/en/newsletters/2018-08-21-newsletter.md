---
title: 'Bitcoin Optech Newsletter #9'
permalink: /en/newsletters/2018/08/21/
name: 2018-08-21-newsletter
slug: 2018-08-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes a request to help test the next version of Bitcoin Core,
short descriptions of projects Bitcoin Core contributors are working on,
and a list of notable merges during the past week.

## Action items

- **Allocate time to test Bitcoin Core 0.17 release candidates:**
  in the coming days, Bitcoin Core will begin releasing Release
  Candidates (RCs) for version 0.17.0.  Organizations and individual
  users planning to use 0.17 are encouraged to test the RCs to ensure
  that they contain all the features you need and don't have any bugs
  that would affect your operation.  There are often multiple RCs for a
  major release such as this, but each RC can theoretically be the last
  RC, so we encourage you to test as early as possible.

## News

No significant news was posted to the bitcoin-dev or lightning-dev
mailing list last week, so this week's news focuses on some projects
discussed during the Bitcoin Core weekly meeting.

The Bitcoin Core project, like most free and open source software
projects, is organized bottom-up with each contributor working on the
things they think are important rather than top-down with project
leaders directing the work, so occasionally---as happened last
week---developers briefly summarize to each other what they're working
on for the future.  It's possible some of these initiatives may fail,
but it's also possible that some will become future parts of Bitcoin
Core.  Here's a summary of the projects discussed:

- **P2P protocol encryption** being worked on by Jonas Schnelli with
  a short-term focus on unauthenticated encryption in the [BIP151][]
  style (but perhaps using a different mechanism than described in that
  BIP).  Peer authentication (e.g. [BIP150][]) is probably further off
  as a criticism against it is that the simplest way of implementing it
  makes it easy to fingerprint particular peers and reduce privacy---so
  a more advanced mechanism is desired for the cases that need it.

- **Output script descriptors enhancements** being worked on by
  Pieter Wuille.  The basic idea for this was described in
  [Newsletter #5][news5 news] but Wuille is investigating adding
  support for nested and threshold constructions, e.g.: "import `and(xpub/...,or(xpub/...,xpub/...))`
  into your wallet as watch-only chain for example and get
  [PSBT][BIP174] to sign for it."  This would make adding hardware
  wallet support to Bitcoin Core easier.  The support would also be
  compatible with timelocks and hashlocks for use with LN-compatible
  wallets (hardware or software).

- **RISC-V support** being worked on by Wladimir van der Laan.  This
  is a CPU architecture rapidly increasing in popularity as a
  potential competitor with ARM-based chipsets, especially among
  hobbyists as the CPU design is open source.  A project of
  several developers including Van der Laan's is ultimately
  providing deterministically-generated hashes of Bitcoin Core
  binaries produced using RISC-V cross-compiling to ensure known
  problems and backdoors in the prevalent x86_64 chipsets aren't
  being used to compromise Bitcoin Core binary builds.  Van der Laan
  had several recent successes and started "probably the first
  RISC-V bitcoin node in the world" which has already synced part of
  the chain.

- **Bandwidth-efficient set reconciliation protocol for transactions**
  being worked on by Gregory Maxwell, Gleb Naumenko, and Pieter Wuille.
  This may allow a node that has new transactions in its mempool to tell
  a peer about those transactions by communicating an amount of data
  "equal to the expected size of the differences themselves".  This is
  in comparison to the current protocol where nodes communicate the
  existence of a transaction by sending a 32 byte hash of it to their
  peers.  Well-connected nodes can receive or send more than hundred of
  these notifications for each 224-byte median-sized transaction they
  process, resulting in significant amount of long-lived nodes'
  bandwidth being wasted (up to 90% [according][nmnkgl relay] to
  measurements by Naumenko, although recent improvements in Bitcoin Core
  may have reduced this figure).  Maxwell is also working on making it
  possible for a newly-started (or long-disconnected) node to
  efficiently sync the high feerate part of its mempool from its peers using this same basic
  mechanism.

- **Dandelion protocol DoS-resistant stem routing** being worked on
  by Suhas Daftuar.  The [Dandelion protocol][] is expected to make
  it extremely difficult for an adversary to determine the IP
  address of any program that creates a Bitcoin transaction (even if
  they don't use Tor), but the new method of handling unconfirmed
  transactions privately for a time during the "stem" phase has to
  be secured against attacks that could waste node bandwidth and
  memory.

For additional details, please see the [conversation log][2018-08-16
meeting log].

## Notable commits

*Notable commits this week in [Bitcoin Core][core commits], [LND][lnd
commits], and [C-lightning][cl commits].*

{% comment %}<!-- IMO, c-lightning only had 6 commits this week, mostly
minor doc updates, so no news for them.  I'm still leaving them
mentioned above for easy copy/paste next week. -harding -->{% endcomment %}

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="1b04b55f2d22078ca79cd38fc1078e15fa9cbe94"
  end="df660aa7717a6f4784e90535a13a95d82244565a"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="6989316b11c51922b4c6ae3507ac06680ec530b9"
  end="3f5ec993300e38369110706ac83301b8875500d6"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="a97955845ff43d4780b33a7301695db33823c57c"
  end="80a875a9a54e26c2ea4c90aee8fe606ddcc27c55"
%}

- Bitcoin Core 0.17 branched: this allows developers to focus on
  ensuring stability, translation completeness, and other release
  features on that branch while development of new features continues on
  the master branch.  This Notable Commits section only focuses on the
  master development branch of each project, so commits mentioned from
  this point forward are much less likely to be included in the 0.17
  version of Bitcoin Core and should not be expected before the 0.18
  version.

- [Bitcoin Core #13917][] and [Bitcoin Core #13960][] improve the
  [BIP174][] Partially Signed Bitcoin Transaction (PBST) handling in
  ambiguous situations.

- [Bitcoin Core #11526][] makes it much easier to build Bitcoin Core
  with Microsoft Visual Studio 2017, including being able to use the Visual
  Studio debugger.

- [Bitcoin Core #13918][] provides the 10th, 25th, 50th, 75th, and 90th
  percentile feerates for a historic block with the `getblockstats` RPC
  introduced to the master development branch a couple months ago.

- [LND #1693][] allows LND's autopilot funding mechanism to optionally
  use its own unconfirmed change outputs for funding transactions,
  allowing it to potentially open multiple channels in the next block.

    Note: this was only the most notable of several minor (but useful)
    improvements to the autopilot feature merged this week.

- [LND #1460][] the payinvoice and sendpayment commands now require
  extra confirmation, although this can be bypassed with the `--force`
  or `-f` parameter.

{% include references.md %}
{% include linkers/issues.md issues="13917,11526,13918,1693,1460,13960" %}

[news5 news]: {{news5}}#news
[dandelion protocol]: https://arxiv.org/abs/1701.04439
[2018-08-16 meeting log]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-08-16-19.03.log.html
[nmnkgl relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-April/015863.html
