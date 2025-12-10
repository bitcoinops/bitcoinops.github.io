---
title: 'Bitcoin Optech Newsletter #385: 2025 Year-in-Review Special'
permalink: /en/newsletters/2025/12/19/
name: 2025-12-19-newsletter
slug: 2025-12-19-newsletter
type: newsletter
layout: newsletter
lang: en

excerpt: >
  The eighth annual Bitcoin Optech Year-in-Review special summarizes notable
  developments in Bitcoin during all of 2025.
---

{{page.excerpt}} It's the sequel to our summaries from [2018][yirs 2018],
[2019][yirs 2019], [2020][yirs 2020], [2021][yirs 2021], [2022][yirs 2022],
[2023][yirs 2023], and [2024][yirs 2024].

## Contents

- January
  - [Updated ChillDKG draft](#chilldkg)
  - [Offchain DLCs](#offchaindlcs)
  - [Stats on compact block reconstruction](#compactblockstats)
- February
  - [Erlay update](#erlay)
  - [LN ephemeral anchor scripts](#lneas)
  - [Probabilistic payments](#probpayments)
- March
  - [Bitcoin Forking Guide](#forkingguide)
  - [Private block template marketplace to prevent centralizing MEV](#templatemarketplace)
  - [LN upfront and hold fees using burnable outputs](#lnupfrontfees)
- April
  - [SwiftSync speedup for initial block download](#swiftsync)
  - [DahLIAS interactive aggregate signatures](#dahlias)
- May
  - [Cluster mempool](#clustermempool)
  - [Increasing or removing Bitcoin Core’s OP_RETURN size limit](#opreturn)
- June
  - [Calculating the selfish mining danger threshold](#selfishmining)
  - [Fingerprinting nodes using addr messages](#fingerprinting)
  - [Garbled locks](#garbledlocks)
- July
  - [Chain code delegation](#ccdelegation)
- August
  - [Utreexo draft BIPs](#utreexo)
  - [Lowering the minimum relay feerate](#minfeerate)
  - [Peer block template sharing](#templatesharing)
  - [Differential fuzzing of Bitcoin and LN implementations](#fuzzing)
- September
  - [Details about the design of Simplicity](#simplicity)
  - [Partitioning and eclipse attacks using BGP interception](#eclipseattacks)
- October
  - [Theoretical limitations on embedding data in the UTXO set](#arbdata)
  - [Channel jamming mitigation simulation results and updates](#channeljamming)
- November
  - [Comparing performance of ECDSA signature validation in OpenSSL vs. libsecp256k1](#secpperformance)
  - [Multiple discussions about restricting data](#restrictingdata)
  - [Modeling stale rates by propagation delay and mining centralization](#stalerates)
  - [BIP3 and the BIP process](#bip3)
- December
- Featured summaries
  - [Vulnerabilities](#vulns)
  - [Quantum](#quantum)
  - [Soft fork proposals](#softforks)
  - [Major releases of popular infrastructure projects](#releases)
  - [Bitcoin Optech](#optech)

---

## January

{:#chilldkg}

- **Updated ChillDKG draft:** ...

{:#offchaindlcs}

- **Offchain DLCs:** ...

{:#compactblockstats}

- **Stats on compact block reconstruction:** ...

## February

{:#erlay}

- **Erlay update:** Sergi Delgado made [several posts][erlay optech posts] over
  the last year about his work and progress implementing [Erlay][erlay] for
  Bitcoin Core. In the first post, he gave an overview on the Erlay proposal and
  how the current transaction relay works (called fanout). In these posts, he
  discusses different results that he found while developing Erlay, such as
  [filtering based on transaction knowledge][erlay knowledge] not mattering as
  much as expected. He also experimented with selecting [how many peers should
  receive a fanout][erlay fanout amount], and found that there was a 35%
  bandwidth savings with 8 outbound peers and 45% with 12 outbound peers, but
  also found a 240% increase in latency. In his two other experiments, he
  determined the [fanout rate based on how a transaction was
  received][erlay transaction received] and [when to select canidate
  peers][erlay candidate peers]. These experiments, which combined fanout and
  reconciliation, helped him determine when to use each method.

{:#lneas}

- **LN ephemeral anchor scripts:** ...

{:#probpayments}

- **Probabilistic payments:** ...

<div markdown="1" class="callout" id="vulns">

## Summary 2025: Vulnerabilities

...

</div>

## March

{:#forkingguide}
- **Bitcoin Forking Guide:** ...

{:#templatemarketplace}
- **Private block template marketplace to prevent centralizing MEV:** ...

{:#lnupfrontfees}
- **LN upfront and hold fees using burnable outputs:** ...

## April

{:#swiftsync}
- **SwiftSync speedup for initial block download:** ...

{:#dahlias}
- **DahLIAS interactive aggregate signatures:** ...

<div markdown="1" class="callout" id="quantum">

## Summary 2025: Quantum

...

</div>

## May

{:#clustermempool}
- **Cluster mempool:** ...

{:#opreturn}
- **Increasing or removing Bitcoin Core’s OP_RETURN size limit:** ...

## June

{:#selfishmining}
- **Calculating the selfish mining danger threshold:** Antoine Poinsot
  [posted][selfish miner post] to Delving Bitcoin an expansion of the math from the 2013 [paper][selfish miner paper] that gave the [selfish mining attack][topic selfish mining] its name. Poinsot focused on reproducing one of the conclusions of the paper, proving that a dishonest miner controlling 33% of the total network hashrate, with no additional advantages, can become marginally more profitable on a long term basis than the miners controlling 67% of it.

{:#fingerprinting}
- **Fingerprinting nodes using addr messages:** ...

{:#garbledlocks}
- **Garbled locks:** ...

<div markdown="1" class="callout" id="softforks">

## Summary 2025: Soft fork proposals

...

</div>

## July

{:#ccdelegation}
- **Chain code delegation:** ...

## August

{:#utreexo}
- **Utreexo draft BIPs:** ...

{:#minfeerate}
- **Lowering the minimum relay feerate:** ...

{:#templatesharing}
- **Peer block template sharing:** ...

{:#fuzzing}
- **Differential fuzzing of Bitcoin and LN implementations:** ...

## September

{:#simplicity}
- **Details about the design of Simplicity:** ...

{:#eclipseattacks}
- **Partitioning and eclipse attacks using BGP interception:** ...

<div markdown="1" class="callout" id="releases">

## Summary 2025: Major releases of popular infrastructure projects

FIXME:Gustavojfe

</div>

## October

{:#arbdata}
- **Theoretical limitations on embedding data in the UTXO set:** ...

{:#channeljamming}

- **Channel jamming mitigation simulation results and updates:** Carla
  Kirck-Cohen in collaboration with Clara Shikhelman and elnosh had updated the
  [lightning jamming simulation results][channel jamming results], and updates
  to their reputation algorithm. The updates included reputation tracking for
  outgoing channels, and resources being limited on incoming channels. With
  these new updates, they found that it still protects against
  [resource][channel jamming resource] and [sink][channel jamming sink] attacks.
  After this round of updates and simulations, they feel that [channel jamming
  attack][channel jamming attack] mitigation has reached a point where it is
  good enough.

## November

{:#secpperformance}

- **Comparing performance of ECDSA signature validation in OpenSSL vs.
  libsecp256k1:** Sebastian Falbesoner conducted an
  [analysis][openssl vs libsecp256k1] on the performance of ECDSA signature
  validation between OpenSSL and libsecp256k1. Since 2015, Bitcoin Core has used
  libsecp256k1 over OpenSSL. He wanted to be certain that doing so was the right
  choice and not a wasted effort. From the start, libsecp256k1 was 2.5-5.5 times
  faster than OpenSSL, but this analysis was done to see if OpenSSL had made any
  improvements over the decade and if so did libsecp256k1 keep up. What
  Falbesoner found was that over the years libsecp256k1 had improved
  significantly whereas OpenSSL had remained the same. He also concluded that
  outside the Bitcoin ecosystem, the secp256k1 curve is not that relevant, so it
  is not justified for OpenSSL to put too many resources into improving it
  (evident by the results). Overall, switching to libsecp256k1 was a beneficial
  decision for Bitcoin Core.

{:#restrictingdata}
- **Multiple discussions about restricting data:** ...

{:#stalerates}
- **Modeling stale rates by propagation delay and mining centralization:** ...

{:#bip3}
- **BIP3 and the BIP process:** ...

<div markdown="1" class="callout" id="optech">

## Summary 2025: Bitcoin Optech

FIXME:bitschmidty

Optech was the fortunate and grateful recipient of a $20,000 USD contribution to
our work from the [Human Rights Foundation][]. The funds will be used to pay for
web hosting, email services, podcast transcriptions, and other expenses that
allow us to continue and improve our delivery of technical content to the
Bitcoin community.

</div>

## December

FIXME:bitschmidty

*We thank all of the Bitcoin contributors named above, plus the many
others whose work was just as important, for another incredible year of
Bitcoin development.  The Optech newsletter will return to its regular
Friday publication schedule on January 2nd.*

<style>
#optech ul {
  max-width: 800px;
  display: flex;
  flex-wrap: wrap;
  list-style: none;
  padding: 0;
  margin: 0;
  justify-content: center;
}

#optech li {
  flex: 1 0 220px;
  max-width: 220px;
  box-sizing: border-box;
  padding: 5px;
  margin: 5px;
}

@media (max-width: 720px) {
  #optech li {
    flex-basis: calc(50% - 10px);
  }
}

@media (max-width: 360px) {
  #optech li {
    flex-basis: calc(100% - 10px);
  }
}
</style>

{% include snippets/recap-ad.md when="2025-12-23 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /en/newsletters/2021/12/22/
[yirs 2022]: /en/newsletters/2022/12/21/
[yirs 2023]: /en/newsletters/2023/12/20/
[yirs 2024]: /en/newsletters/2024/12/20/

[Human Rights Foundation]: https://hrf.org
[openssl vs libsecp256k1]: /en/newsletters/2025/11/07/#comparing-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1
[channel jamming results]: /en/newsletters/2025/10/24/#channel-jamming-mitigation-simulation-results-and-updates
[channel jamming resource]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[channel jamming sink]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[channel jamming attack]: /en/topics/channel-jamming-attacks/
[erlay optech posts]: /en/newsletters/2025/02/07/#erlay-update
[erlay]: /en/topics/erlay/
[erlay knowledge]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[erlay fanout amount]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[erlay transaction received]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[erlay candidate peers]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[selfish miner post]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757
[selfish miner paper]: https://arxiv.org/pdf/1311.0243
