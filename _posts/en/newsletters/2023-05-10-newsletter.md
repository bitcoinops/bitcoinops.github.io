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
  seen. {% assign timestamp="1:36" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.05rc2][] is a release candidate for the next
  version of this LN implementation. {% assign timestamp="19:17" %}

- [Bitcoin Core 24.1rc2][] is a release candidate for a maintenance
  release of the current version of Bitcoin Core. {% assign timestamp="23:05" %}

- [Bitcoin Core 25.0rc1][] is a release candidate for the next major
  version of Bitcoin Core. {% assign timestamp="25:35" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Add getprioritisationmap, delete a mapDeltas entry when delta==0][review club 27501]
is a PR by Gloria Zhao (glozow) that improves the Bitcoin Core
feature that allows miners to modify the effective mempool fee, and
thus the mining priority (higher or lower), of particular transactions
(see the [prioritisetransaction RPC][]).
The fee increment (if positive) or decrement (if negative) is called
the _fee delta_.  Transaction prioritization values are persisted to
disk within the `mempool.dat` file and are restored on node restart.

One reason a miner might prioritize a transaction is to account for an
out-of-band transaction fee payment; the affected transaction will be
treated as if it has a higher fee when choosing which transactions to
include in the miner's block template.

The PR adds a new RPC, `getprioritisationmap`, that returns the set of
prioritized transactions.  The PR also removes unnecessary prioritization
entries, which can arise if the user sets deltas back to zero. {% assign timestamp="26:26" %}

{% include functions/details-list.md
  q0="What is the [mapDeltas][] data structure, and why is it needed?"
  a0="It's where the per-transaction prioritization values are stored.
      These values affect local mining and eviction decisions, as well
      as the ancestor and descendant feerate calculations."
  a0link="https://bitcoincore.reviews/27501#l-26"

  q1="Do transaction prioritizations affect the fee estimation algorithm?"
  a1="No. Fee estimation needs to accurately predict
      the expected decisions of miners (in this case, _other_ miners),
      and these miners don't have the same prioritizations that we do,
      since those are local."
  a1link="https://bitcoincore.reviews/27501#l-31"

  q2="How is an entry added to `mapDeltas`? When is it removed?"
  a2="It's added by the `prioritisetransaction` RPC, and also when the
      node restarts, due to an entry in `mempool.dat`.
      They are removed when a block containing the transaction is
      added to the chain, or when the transaction is [replaced][topic rbf]."
  a2link="https://bitcoincore.reviews/27501#l-34"

  q3="Why shouldn’t we delete a transaction’s entry from `mapDeltas` when
      it leaves the mempool (because, for example, it has expired or been
      evicted due to feerate dropping below the minimum feerate)?"
  a3="The transaction may come back into the mempool. If its `mapDeltas` entry
      had been removed, the user would have to re-prioritize the transaction."
  a3link="https://bitcoincore.reviews/27501#l-84"

  q4="If a transaction is removed from `mapDeltas` because it's included in
      a block, but then the block is re-orged out, won't the transaction's
      priority have to be reestablished?"
  a4="Yes, but reorgs are expected to be rare. Also, the out-of-band payment
      may actually be in the form of a Bitcoin transaction, and so it may
      need to be redone as well."
  a4link="https://bitcoincore.reviews/27501#l-90"

  q5="Why should we allow prioritizing a transaction that isn’t present in
      the mempool?"
  a5="Because the transaction may not be in the mempool _yet_. And it may
      not even be able to enter the mempool in the first place on its own
      fee (without the prioritization)."
  a5link="https://bitcoincore.reviews/27501#l-89"

  q6="What is the problem if we don't clean up `mapDeltas`?"
  a6="The main problem is wasteful memory allocation."
  a6link="https://bitcoincore.reviews/27501#l-107"

  q7="When is `mempool.dat` (including `mapDeltas`) written from memory to
      disk?"
  a7="On clean shutdown, and by running the `savemempool` RPC."
  a7link="https://bitcoincore.reviews/27501#l-114"

  q8="Without the PR, how do miners clean up `mapDeltas` (that is,
      remove entries with a zero prioritization value)?"
  a8="The only way is to restart the node, since zero-value
      prioritizations are not loaded into `mapDeltas` during restart.
      With the PR, the `mapDeltas` entry is deleted as soon as its
      value is set to zero. This has the additional beneficial effect
      that zero-value prioritizations aren't written to disk."
  a8link="https://bitcoincore.reviews/27501#l-127"
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
  height in the response. {% assign timestamp="45:42" %}

- [Bitcoin Core #27195][] makes it possible to remove all external receivers from
  a transaction that is being [replaced][topic rbf] using the `bumpfee`
  RPC from Bitcoin Core's internal wallet.  The user does this by making
  the only output of the replacement transaction pay the user's own
  address.  If the replacement transaction gets confirmed, this prevents
  any of the original receivers from being paid, which is sometimes
  described as "canceling" a Bitcoin payment. {% assign timestamp="46:42" %}

- [Eclair #1783][] adds a `cpfpbumpfees` API for [CPFP][topic cpfp] fee
  bumping one or more transactions.  The PR also updates the list of
  [recommended parameters][eclair bitcoin.conf] for running Bitcoin Core
  to ensure that creating a fee-bump transaction is a viable option. {% assign timestamp="48:34" %}

- [LND #7568][] adds the ability to define additional LN feature bits
  when the node is started up.  It also removes the ability to disable any
  hardcoded or defined feature bits during runtime (but additional bits
  may be still be added and later disabled).  A related proposal update
  in [BLIPs #24][] notes that custom [BOLT11][] feature bits are limited
  to a maximum expressed value of 5114. {% assign timestamp="50:11" %}

- [LDK #2044][] makes several changes to LDK's route hinting for
  [BOLT11][] invoices, the mechanism that a receiving LN node can use to
  suggest routes for a spending node to use.  With this merge, only
  three channels are suggested, support for LDK's phantom nodes is
  improved (see [Newsletter #188][news188 phantom]), and the three
  channels chosen are selected for efficiency and privacy.  The PR
  discussion includes [several][carman hints] insightful
  [comments][corallo hints] about the implications for privacy of
  providing route hints. {% assign timestamp="52:45" %}

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
publish the next 250 newsletters. {% assign timestamp="54:17" %}

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
[review club 27501]: https://bitcoincore.reviews/27501
[prioritisetransaction rpc]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[mapDeltas]: https://github.com/bitcoin/bitcoin/blob/fc06881f13495154c888a64a38c7d538baf00435/src/txmempool.h#L450
