---
title: "Bitcoin Optech Newsletter #19"
permalink: /en/newsletters/2018/10/30/
name: 2018-10-30-newsletter
slug: 2018-10-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter suggests an update for C-Lightning users,
describes a discussion about BIP69 deterministic input/output ordering
on the mailing list, notes public overt ASICBoost support is available
for miners using Antminer S9, and provides links to resources about both
Square's open sourced Subzero HSM-based multisig cold storage solution
and the recent Lightning Network Residency and Hackday in New York City.
Also included are selected recent Q&A from Bitcoin StackExchange and
descriptions of notable code changes in popular Bitcoin infrastructure
projects.

## Action items

- **Update to [C-Lightning 0.6.2][]:** fixes a bug where the node would
  send an excessive number of update announcements to its peers about
  dead channels.

## News

- **[BIP69][] discussion:** this BIP from 2015 adopted by several notable
  wallets specifies an optional method for deterministically ordering
  inputs and outputs within a transaction based on the public contents
  of the transaction.  However, other wallets have not adopted it (or
  even rejected it as unsuitable for adoption), leading perhaps to a
  "worst of both worlds" situation where wallets using BIP69 can be
  fairly easily identified and so wallets not using BIP69 may also be
  easier to identify by negation.

    In this [thread][bip69 thread] to the Bitcoin-Dev mailing list, Ryan
    Havar suggests that one reason wallet authors like BIP69 is that its
    deterministic ordering makes it easy and fast for their tests to
    ensure that they haven't leaked any information about the source of
    their inputs or the destination of their outputs (e.g.  in some old
    wallets, the fist output always went to the recipient and the second
    output was always change---making coin tracking trivial).  Havar
    then suggests an alternative deterministic ordering based on private
    information that would be available to the test suite but not
    exposed by production wallets, allowing developers who want to
    thwart block chain analysis---but also have simple and fast
    tests---to migrate away from BIP69.

- **Overt ASICBoost support for S9 miners:** support for this
  efficiency-improving feature was announced by both [Bitmain][bitmain oab]
  and [Braiins][braiins oab] this week.  ASICBoost takes advantage of the fact
  that the SHA256 algorithm used in Bitcoin mining first splits the 80 byte block
  header into 64 byte chunks.  If a miner can find multiple proposed block
  headers where the first chunk of 64 bytes are different but start of the next
  chunk of 64 bytes are the same, then they can try different combinations of
  the first chunk and second chunk to reduce the total number of hashing
  operations they need to carry out to find a valid block.  Early estimates
  indicate an improvement of 10% (or perhaps more) on existing Antminer S9
  hardware.

    The overt form of ASICBoost alters the versionbits field in the
    block header, which can cause programs such as Bitcoin Core to display
    a warning such as "13 of last 100 blocks have unexpected version".
    Some ASICBoost miners have voluntarily restricted their altered
    versionbits range to that defined by [BIP320][], giving future
    programs the option to ignore those bits for upgrade signaling.

- **Open sourced HSM-based multisig cold storage solution:** [Square][] has
  released code and documentation for the cold storage solution they've
  implemented to protect customer deposits, as well as a CLI tool for
  auditing HD wallet balances at arbitrary points in time.  Optech has
  not evaluated their solution, but we can recommend interested parties
  read Square's excellent [blog post][subzero blog] and visit the
  repositories for the [Subzero][] cold storage solution and
  [Beancounter][] auditing tool.

- **Lightning Residency and Hackday:** last week [Chaincode Labs][]
  hosted a five-day [Lightning Network Residency][] program to help
  onboard developers to the fledgling protocol.  Following this, Fulmo
  organized their fourth [Lightning Network Hackday][] (actually two
  days) also in New York City with a few speeches, many demos, and lots
  of hacking.

    Pierre Rochard has written summaries of all the presentations
    given at the residency program ([day 1][lr1], [day 2][lr2],
    [day 3][lr3], [day 4][lr4]) and videos of the
    presentations are expected to be posted soon.  Videos of the
    hackday are available now: [day 1][hd1], [day 2][hd2].

## Selected Q&A from Bitcoin StackExchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help answer other people's questions.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

- [Does using pruning make initial node sync faster?][bse 79592] Pruning
  blocks after they've been processed can reduce disk space requirements
  by over 97% at present, but do they also speed up sync?  Bitcoin Core
  developer Gregory Maxwell answers.

- [Can someone steal from you by closing their Lightning Network payment channel in a certain way?][bse 80399]
  Several different ways to close
  a Lightning Network payment channel are described, and C-Lightning
  developer Christian Decker explains how a program following the LN
  protocol will protect your money in each case.

- [How much energy does it take to create one block?][bse 79691]
  Nate Eldredge provides a simple formula and set of links to data that
  anyone can use to estimate the average amount of energy it would take
  to generate a block at the current difficulty level.  For the present
  difficulty using only Antminer S9s without ASICBoost, an average block
  consumes 841,629 kilowatt hours (kWh).  At a common estimate of
  $0.04/kWh, this is about $34,000 of electricity---well below the
  current block subsidy of about $80,000---but using [AJ Towns's recent
  estimate][towns mining estimate] of $0.16/kWh that includes costs
  beyond electricity and attempts to factor in risk premiums, the
  estimated block cost is about $135,000.

## Notable merges

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

{% comment %}<!-- no commits to libsecp256k1; one interesting commit
#448 to C-Lightning, but I'm not confident enough of my understanding of
it to write a good description, and I doubt non-LN devs care -->{% endcomment %}

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="5c25409d6851182c5e351720cee36812c229b77a"
  end="f1e2f2a85962c1664e4e55471061af0eaa798d40"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="e5b84cfadab56037ae3957e704b3e570c9368297"
  end="6b19df162a161079ab794162b45e8f4c7bb8beec"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="7eec2253e962e524f8fd92b74f411f0b99706ba9"
  end="22b8a88b488faa94a009b2c58415ae825152f709"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="1086fda4c1975d0cad8d3cad96794a64ec12dca4"
  end="1086fda4c1975d0cad8d3cad96794a64ec12dca4"
%}

- [Bitcoin Core #14451][] allows optionally building Bitcoin-Qt without
  support for the [BIP70][] payment protocol and adds a deprecation
  warning indicating the default support may be removed in a future
  release.  The CEO of BitPay, which is the largest user of BIP70 (but
  which wants to use a different version of the protocol),
  [indicated][bitpay bip70 comment] that they supported Bitcoin Core
  removing BIP70.  Developers seem to be in favor of removing the
  protocol for security reasons and because it's seeing declining use.
  The BIP70 dependency on OpenSSL resulted in the emergency release of
  [Bitcoin Core 0.9.1][] in 2014 as a result of the [heartbleed
  vulnerability][], and it is expected that removing it will eliminate
  the risk of future similar vulnerabilities.

- [Bitcoin Core #14296][] removes the deprecated `addwitnessaddress`
  RPC.  This RPC was added in version 0.13.0 to enable testing segwit
  on regtest and testnet before it was activated on mainnet and built
  into the wallet.  Since version 0.16.0, Bitcoin Core's wallet has
  supported getting addresses directly using the regular
  [getnewaddress][rpc getnewaddress] mechanism.

- [Bitcoin Core #14468][] deprecates the `generate` RPC.  This method
  generates new blocks in regtest mode but it requires getting new
  addresses from Bitcoin Core's built-in wallet in order to pay them the
  mining [block reward][term block reward].  A replacement method,
  [generatetoaddress][rpc generatetoaddress] was introduced in version
  0.13.0, which allows any regtest wallet to generate an address that
  will be paid the block reward.  This is part of an ongoing effort to
  allow as many RPCs as possible to function without the wallet in order
  to improve test coverage of non-wallet nodes as well as to ease a
  future possible transition to fully separating the wallet from the
  node.

- [Bitcoin Core #14150][] adds [key origin][] support to [output script
  descriptors][].  Besides allowing you to pass an additional argument
  to the [scantxoutset][rpc scantxoutset] RPC, this doesn't currently add any features
  to Bitcoin Core---but it will enable using key origin with [BIP174][]
  PSBTs and watch-only wallets when those parts of the software have
  been updated to use descriptors.  See Newsletters [#5][newsletter #5],
  [#7][newsletter #7], [#9][newsletter #9], [#12][newsletter #12], and
  [#17][newsletter #17] for previous discussion of output script
  descriptors.  Key origin support makes it possible to use extended
  pubkeys that have been exported from an HD wallet that uses [BIP32][]
  hardened derivation for protecting ancestor private keys, which
  helps make output script descriptors compatible with most hardware
  wallets.

- [LND #1981][] ensures that LND doesn't leak information about any of
  its peers that aren't advertising themselves as public nodes.

- {:#lnd-1535-1512}
  LND [#1535][LND #1535] and [#1512][LND #1512] adds the server-side
  communication protocol for watchtowers along with many tests verifying
  its proper operation.  Correct use of the LN protocol requires regular
  monitoring of which transactions get added to the block chain, so
  watchtowers are servers designed to help defend the payment channels
  of users who expect to be offline for an extended period of time.  As
  such, watchtowers are considered to be a key feature for enabling
  wider adoption of LN by less advanced users.  However, a standard
  specification for watchtowers has not been agreed upon by the multiple
  implementations of LN, so LND is only putting this feature out for
  initial testing and is restricting its use to testnet.

{% include references.md %}
{% include linkers/issues.md issues="14451,14296,14468,14150,1981,1535,1512" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 79592]: {{bse}}79592
[bse 80399]: {{bse}}80399
[bse 79691]: {{bse}}79691

[hd1]: https://www.youtube.com/watch?v=FGxFd944jMg
[hd2]: https://www.youtube.com/watch?v=o87GVYFvwIk
[lr1]: https://medium.com/@pierre_rochard/day-1-of-the-chaincode-labs-lightning-residency-ab4c29ce2077
[lr2]: https://medium.com/@pierre_rochard/day-2-of-the-chaincode-labs-lightning-residency-669aecab5f16
[lr3]: https://medium.com/@pierre_rochard/day-3-of-the-chaincode-labs-lightning-residency-5a7fad88bc62
[lr4]: https://medium.com/@pierre_rochard/day-4-of-the-chaincode-labs-lightning-residency-f28b046fc1a6
[c-lightning 0.6.2]: https://github.com/ElementsProject/lightning/releases
[bip69 thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-October/016457.html
[bitmain oab]: https://blog.bitmain.com/en/new-firmware-activate-overt-asicboost-bm1387-antminer-models/
[braiins oab]: https://twitter.com/braiins_systems/status/1055153228772503553
[subzero blog]: https://medium.com/square-corner-blog/open-sourcing-subzero-ee9e3e071827
[subzero]: https://github.com/square/subzero
[beancounter]: https://github.com/square/beancounter/
[lightning network residency]: https://lightningresidency.com/
[chaincode labs]: https://chaincode.com/
[lightning network hackday]: https://lightninghackday.fulmo.org/
[bitpay bip70 comment]: https://github.com/bitcoin/bitcoin/pull/14451#issuecomment-431496319
[bitcoin core 0.9.1]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.9.1.md
[heartbleed vulnerability]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[term block reward]: https://btcinformation.org/en/glossary/block-reward
[key origin]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82#key-origin-identification
[towns mining estimate]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/playing-with-fire-adjusting-bitcoin-block-subsidy/
[square]: https://cash.app/bitcoin
