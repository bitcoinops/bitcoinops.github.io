---
title: 'Bitcoin Optech Newsletter #250'
permalink: /en/newsletters/2023/05/10/
name: 2023-05-10-newsletter
slug: 2023-05-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a paper about the PoWswap protocol and
includes our regular sections with the summary of a Bitcoin
Core PR Review Club meeting, announcements of new releases and
release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.  Also included is a short section
celebrating five years of Bitcoin Optech and our 250th newsletter.

## News

- **Paper about PoWswap protocol:** Thomas Hartman [posted][hartman
  powswap] to the Bitcoin-Dev mailing list about a [paper][hnr powswap]
  he has written with Gleb Naumenko and Antoine Riard about the
  [PoWSwap][] protocol first proposed by Jeremy Rubin.  Powswap allows
  the creation of onchain-enforceable contracts related to the change in
  hash rate.  The basic idea takes advantage of the protocol-enforced
  relationship between time and block production plus the ability to
  express time locks in either time or blocks.  For example, consider the
  following script:

  ```
  OP_IF
    <Alice's key> OP_CHECKSIGVERIFY <time> OP_CHECKLOCKTIMEVERIFY
  OP_ELSE
    <Bob's key> OP_CHECKSIGVERIFY <height> OP_CHECKLOCKTIMEVERIFY
  OP_ENDIF
  ```

  Let's imagine the current time is _t_ and the current block height is
  _x_.  If blocks are produced an average of 10 minutes apart, then if
  we set `<time>` to _t + 1000 minutes_ and `<height>` to _x + 50_, we'd
  expect that Bob would be able to spend the output controlled by the
  above script on average 500 minutes before Alice can spend it.
  However, if the rate of block production were to suddenly more than
  double, Alice might be able to spend the output before Bob.

  There are several envisioned applications of this type of contract:

  - *Hashrate increase insurance:* miners must purchase their equipment
    before they know for certain how much income it will generate.  For
    example, a miner who purchases enough equipment to receive 1% of the
    network's current total of rewards might be surprised to find that
    other miners also purchased enough equipment to double the total
    network hashrate, leaving the miner with 0.5% of the reward instead
    of 1%.  With PoWSwap, the miner can make a trustless contract with
    someone who is willing to pay the miner if hashrate increases before
    a certain date, offsetting the miner's unexpectedly low income.
    In exchange, the miner pays that person an upfront premium or agrees
    to pay them a larger amount if the network-wide hashrate stays the same
    or decreases.

  - *Hashrate decrease insurance:* a wide variety of problems with
    Bitcoin would result in a significant decrease in network-wide
    hashrate.  Hashrate would decrease if miners were being shut down by
    powerful parties, or if a significant amount of [fee sniping][topic fee
    sniping] began to suddenly occur among established miners, or if the
    value of BTC to miners suddenly decreased.  Holders of BTC who
    wanted to insure against such situations could enter trustless
    contracts with miners or third parties.

  - *Exchange rate contracts:* in general, if the purchasing power of
    BTC increases, miners are willing to increase the amount of hashrate
    they provide (to increase the rewards they receive).  If purchasing
    power decreases, hashrate decreases.  Many people may be interested
    in trustless contracts related to the future purchasing power of
    Bitcoin.

  Although the idea for PoWSwap has been circulated for several years,
  the paper provides more detail and analysis than we've previously
  seen.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.05rc2][] is a release candidate for the next
  version of this LN implementation.

- [Bitcoin Core 24.1rc2][] is a release candidate for a maintenance
  release of the current version of Bitcoin Core.

- [Bitcoin Core 25.0rc1][] is a release candidate for the next major
  version of Bitcoin Core.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:LarryRuane

[Don't download witnesses for assumed-valid blocks when running in prune mode][review club 27050]
is a PR by Niklas Gögge (dergoegge) that improves the performance of Initial Block Download
(IBD) by not downloading witness data on nodes that are configured to both
[prune block data][docs pruning] and use [assumevalid][docs assume valid]. This
optimization was discussed in a recent [stack exchange question][se117057]. {% assign timestamp="43:42" %}

{% include functions/details-list.md
  q0=""
  a0=""
  a0link="https://bitcoincore.reviews/27050#FIXMEl-31"
%}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26094][] adds the block hash and height fields to
  `getbalances`, `gettransaction`, and `getwalletinfo`. These RPC calls
  lock the chainstate to make sure they are up-to-date with the latest
  block and so they benefit from including the valid block hash and
  height in the response.

- [Bitcoin Core #27195][] makes it possible to remove all external receivers from
  a transaction that is being [replaced][topic rbf] using the `bumpfee`
  RPC from Bitcoin Core's internal wallet.  The user does this by making
  the only output of the replacement transaction pay the user's own
  address.  If the replacement transaction gets confirmed, this prevents
  any of the original receivers from being paid, which is sometimes
  described as "canceling" a Bitcoin payment.

- [Eclair #1783][] adds a `cpfpbumpfees` API for [CPFP][topic cpfp] fee
  bumping one or more transactions.  The PR also updates the list of
  [recommended parameters][eclair bitcoin.conf] for running Bitcoin Core
  to ensure that creating a fee-bump transaction is a viable option.

- [LND #7568][] adds the ability to define additional LN feature bits
  when the node is started up.  It also removes the ability to disable any
  hardcoded or defined feature bits during runtime (but additional bits
  may be still be added and later disabled).  A related proposal update
  in [BLIPs #24][] notes that custom [BOLT11][] feature bits are limited
  to a maximum expressed value of 5114.

- [LDK #2044][] makes several changes to LDK's route hinting for
  [BOLT11][] invoices, the mechanism that a receiving LN node can use to
  suggest routes for a spending node to use.  With this merge, only
  three channels are suggested, support for LDK's phantom nodes is
  improved (see [Newsletter #188][news188 phantom]), and the three
  channels chosen are selected for efficiency and privacy.  The PR
  discussion includes [several][carman hints] insightful
  [comments][corallo hints] about the implications for privacy of
  providing route hints.

## Celebrating Optech Newsletter #250

Bitcoin Optech was founded, in part, to "help facilitate improved
relations between businesses and the open source community."  This
weekly newsletter was started to give executives and developers inside
Bitcoin-using businesses more insight into what the open source
community was building.  As such, we initially focused on documenting work that
might affect businesses.

We quickly discovered that not just business readers were interested in
this information.  Many contributors to Bitcoin projects didn't have the
time to read all the discussions on the protocol development mailing
lists or to monitor other projects for major changes.  They appreciated
someone notifying them about developments that they might find
interesting or which might affect their work.

For almost five years now, it's been our pleasure to provide that
service.  We've tried to expand on that simple mission by also providing
a guide to [wallet technology compatibility][compatibility matrix], an index to
over 100 [topics of interest][topics], and a weekly
discussion [podcast][podcast] with guests that have included many of the
contributors whose work we've been privileged to write about.

None of that would be possible without our many contributors, who in the
past year have included:
<!-- alphabetical -->
Adam Jonas,
Copinmalin,
David A. Harding,
Gloria Zhao,
Jiri Jakes,
Jon Atack,
Larry Ruane,
Mark "Murch" Erhardt,
Mike Schmidt,
nechteme,
Patrick Schwegler,
Shashwat Vangani,
Shigeyuki Azuchi,
Vojtěch Strnad,
Zhiwei "Jeffrey" Hu,
and several others who made special contributions to particular subjects.

We also remain eternally grateful to our [founding sponsors][] Wences
Casares, John Pfeffer, and Alex Morcos, as well as our many [financial
supporters][].

Thank you for reading.  We hope that you'll continue to do so as we
publish the next 250 newsletters.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26094,27195,1783,7568,24,2044" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 24.1rc2]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc1]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[eclair bitcoin.conf]: https://github.com/ACINQ/eclair/pull/1783/files#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5
[carman hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1448840896
[corallo hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1461049958
[hartman powswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021605.html
[hnr powswap]: https://raw.githubusercontent.com/blockrate-binaries/paper/master/blockrate-binaries-paper.pdf
[powswap]: https://powswap.com/
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[founding sponsors]: /about/#founding-sponsors
[financial supporters]: /#members
