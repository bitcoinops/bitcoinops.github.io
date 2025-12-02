---
title: 'Bitcoin Optech Newsletter #385: 2025 Year-in-Review Special'
permalink: /en/newsletters/2025/12/19/
name: 2025-12-19-newsletter
slug: 2025-12-19-newsletter
type: newsletter
layout: newsletter
lang: en

excerpt: >
  The eighth annual Bitcoin Optech Year-in-Review special summarizes
  notable developments in Bitcoin during all of 2025.

---
{{page.excerpt}}  It's the sequel to our summaries from [2018][yirs
2018], [2019][yirs 2019], [2020][yirs 2020], [2021][yirs 2021],
[2022][yirs 2022], [2023][yirs 2023], and [2024][yirs 2024].

## Contents

* January
  * [Updated ChillDKG draft](#chilldkg)
  * [Offchain DLCs](#offchaindlcs)
  * [Stats on compact block reconstruction](#compactblockstats)
* February
  * [Erlay update](#erlay)
  * [LN ephemeral anchor scripts](#lneas)
  * [Probabilistic payments](#probpayments)
* March
  * [Bitcoin Forking Guide](#forkingguide)
  * [Private block template marketplace to prevent centralizing MEV](#templatemarketplace)
  * [LN upfront and hold fees using burnable outputs](#lnupfrontfees)
* April
  * [SwiftSync speedup for initial block download](#swiftsync)
  * [DahLIAS interactive aggregate signatures](#dahlias)
* May
  * [Cluster mempool](#clustermempool)
  * [Increasing or removing Bitcoin Core’s OP_RETURN size limit](#opreturn)
* June
  * [Calculating the selfish mining danger threshold](#selfishmining)
  * [Fingerprinting nodes using addr messages](#fingerprinting)
  * [Garbled locks](#garbledlocks)
* July
  * [Chain code delegation](#ccdelegation)
* August
  * [Utreexo draft BIPs](#utreexo)
  * [Lowering the minimum relay feerate](#minfeerate)
  * [Peer block template sharing](#templatesharing)
  * [Differential fuzzing of Bitcoin and LN implementations](#fuzzing)
* September
  * [Details about the design of Simplicity](#simplicity)
  * [Partitioning and eclipse attacks using BGP interception](#eclipseattacks)
* October
  * [Theoretical limitations on embedding data in the UTXO set](#arbdata)
  * [Channel jamming mitigation simulation results and updates](#channeljamming)
* November
  * [Comparing performance of ECDSA signature validation in OpenSSL vs. libsecp256k1](#secpperformance)
  * [Multiple discussions about restricting data](#restrictingdata)
  * [Modeling stale rates by propagation delay and mining centralization](#stalerates)
  * [BIP3 and the BIP process](#bip3)
* December
* Featured summaries
  * [Vulnerabilities](#vulns)
  * [Quantum](#quantum)
  * [Soft fork proposals](#softforks)
  * [Major releases of popular infrastructure projects](#releases)
  * [Bitcoin Optech](#optech)

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
- **Erlay update:** ...

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
- **Calculating the selfish mining danger threshold:** ...

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
- **Channel jamming mitigation simulation results and updates:** ...

## November

{:#secpperformance}
- **Comparing performance of ECDSA signature validation in OpenSSL vs. libsecp256k1:** ...

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
