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

* January
  * [Updated ChillDKG draft](#chilldkg)
  * [Offchain DLCs](#offchaindlcs)
  * [Compact block reconstructions](#compactblockstats)
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
  * [Discussions about arbitrary data](#arbdata)
  * [Channel jamming mitigation simulation results and updates](#channeljamming)
* November
  * [Comparing performance of ECDSA signature validation in OpenSSL vs. libsecp256k1](#secpperformance)
  * [Modeling stale rates by propagation delay and mining centralization](#stalerates)
  * [BIP3 and the BIP process](#bip3)
  * [Bitcoin Kernel C API introduced](#kernelapi)
* December
  * [Splicing](#lnsplicing)
* Featured summaries
  * [Vulnerabilities](#vulns)
  * [Quantum](#quantum)
  * [Soft fork proposals](#softforks)
  * [Stratum v2](#stratumv2)
  * [Major releases of popular infrastructure projects](#releases)
  * [Bitcoin Optech](#optech)

---

## January

{:#chilldkg}
- **Updated ChillDKG draft:** ...

{:#offchaindlcs}
- **Offchain DLCs:** ...

{:#compactblockstats}

- **Compact block reconstructions:** January also saw the first of several items
  in 2025 that revisited [previous research][news315 compact blocks] into how
  effectively Bitcoin nodes reconstruct blocks using [compact block relay][topic
  compact block relay] (BIP152), updating previous measurements and exploring
  potential refinements. Updated statistics [published in
  January][news339 compact blocks] showed that when mempools are full,
  nodes more frequently need to request missing transactions. Poor
  orphan resolution was identified as a possible cause, with [some
  improvements][news 338] already made.

  Later in the year, analysis examined whether [compact block
  prefilling strategies][news365 compact blocks] could further improve
  reconstruction success. Testing suggested that selectively prefilling
  transactions that were more likely to be missing from peers’ mempools could
  reduce fallback requests with only modest bandwidth tradeoffs. Follow-up
  research added these additional measurements and updated [real-world
  reconstruction measurements][news382 compact blocks] before and after changes
  to the [monitoring nodes' minimum relay feerates](#minfeerate),
  showing nodes with lower `minrelayfee` have a higher reconstruction
  rate. The author also [posted][news368 monitoring] about the
  architecture behind his monitoring project.

## February

{:#erlay}
- **Erlay update:** ...

{:#lneas}

- **LN ephemeral anchor scripts:** After several updates to [mempool policies in
  Bitcoin Core 28.0][28.0 wallet guide], discussion began in February around
  design choices for [ephemeral anchor outputs][topic ephemeral anchors] in LN
  commitment transactions. Contributors [examined][news340 lneas] which script
  constructions should be used as one of the outputs of [TRUC][topic v3
  transaction relay]-based commitment transactions as a replacement for
  existing [anchor outputs][topic anchor outputs].

  The tradeoffs included how different scripts affect [CPFP][topic cpfp] fee
  bumping, transaction weight, and the ability to safely spend or discard anchor
  outputs when they are no longer needed. [Continued discussion][news341 lneas]
  highlighted interactions with mempool policy and Lightning’s security
  assumptions.

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

- **Discussions about arbitrary data:** Conversation in October revisited
  longstanding questions about embedding arbitrary data in Bitcoin transactions
  and the limits of using the UTXO set for that purpose. [One analysis][news375
  arb data] examined the theoretical constraints on storing data in UTXOs, even
  under a restrictive set of Bitcoin transaction rules.

  Subsequent [discussions][news379 arb data] through the rest of the year
  focused on whether consensus restrictions on data-carrying transactions should
  be considered.

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

In Optech's eighth year, we published 50 weekly [newsletters][] and this
Year-in-Review special.  Altogether, Optech published over 80,000 English words
about Bitcoin software research and development this year, the rough equivalent
of a 225-page book.

Each newsletter and blog post was translated into Chinese, French, and Japanese,
with other languages also receiving translations, for a total of over 150
translations in 2025.

In addition, every newsletter this year was accompanied by a [podcast][]
episode, totaling over 60 hours in audio form and over 500,000 words in
transcript form.  Many of Bitcoin's top contributors were guests on the show,
some of them on more than one episode, with a total of 75 unique
guests in 2025:

- 0xB10C
- Abubakar Sadiq Ismail (x3)
- Alejandro De La Torre
- Alex Myers
- Andrew Toth
- Anthony Towns
- Antoine Poinsot (x5)
- Bastien Teinturier (x3)
- Bob McElrath
- Bram Cohen
- Brandon Black
- Bruno Garcia
- Bryan Bishop
- Carla Kirk-Cohen (x2)
- Chris Stewart
- Christian Kümmerle
- Clara Shikhelman
- Constantine Doumanidis
- Dan Gould
- Daniela Brozzoni (x2)
- Daniel Roberts
- Davidson Souza
- David Gumberg
- Elias Rohrer
- Eugene Siegel (x2)
- Francesco Madonna
- Gloria Zhao (x2)
- Gregory Sanders (x2)
- Hunter Beast
- Jameson Lopp (x2)
- Jan B
- Jeremy Rubin (x2)
- Jesse Posner
- Johan Halseth
- Jonas Nick (x4)
- Joost Jager (x2)
- Jose SK
- Josh Doman (x2)
- Julian
- Lauren Shareshian
- Liam Eagen
- Marco De Leon
- Matt Corallo
- Matt Morehouse (x7)
- Moonsettler
- Naiyoma
- Niklas Gögge
- Olaoluwa Osuntokun
- Oleksandr Kurbatov
- Peter Todd
- Pieter Wuille
- PortlandHODL
- Rene Pickhardt
- Robin Linus (x3)
- Rodolfo Novak
- Ruben Somsen (x2)
- Russell O’Connor
- Salvatore Ingala (x4)
- Sanket Kanjalkar
- Sebastian Falbesoner (x2)
- Sergi Delgado
- Sindura Saraswathi (x2)
- Sjors Provoost (x2)
- Steve Myers
- Steven Roose (x3)
- Stéphan Vuylsteke (x2)
- supertestnet
- Tadge Dryja (x3)
- TheCharlatan (x2)
- Tim Ruffing
- vnprc
- Vojtěch Strnad
- Yong Yu
- Yuval Kogman
- ZmnSCPxj (x3)

Optech was the fortunate and grateful recipient of another $20,000 USD contribution to
our work from the [Human Rights Foundation][]. The funds will be used to pay for
web hosting, email services, podcast transcriptions, and other expenses that
allow us to continue and improve our delivery of technical content to the
Bitcoin community.

### A special thank you

After contributing as the primary author for 376 consecutive Bitcoin Optech
newsletters, Dave Harding stepped back from contributing regularly this year. We
cannot thank Harding enough for anchoring the newsletter for eight years and all of
the Bitcoin education, elucidation, and understanding he brought the community.
We are eternally grateful and wish him all the best.

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
{% include linkers/issues.md v=2 issues="1699,1895,1974,2004,27587,33629,1937,32406" %}
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /en/newsletters/2021/12/22/
[yirs 2022]: /en/newsletters/2022/12/21/
[yirs 2023]: /en/newsletters/2023/12/20/
[yirs 2024]: /en/newsletters/2024/12/20/

[newsletters]: /en/newsletters/
[Human Rights Foundation]: https://hrf.org
[news315 compact blocks]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 compact blocks]: /en/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news365 compact blocks]: /en/newsletters/2025/08/01/#testing-compact-block-prefilling
[news382 compact blocks]: /en/newsletters/2025/11/28/#stats-on-compact-block-reconstructions-updates
[news368 monitoring]: /en/newsletters/2025/08/22/#peer-observer-tooling-and-call-to-action
[28.0 wallet guide]: /en/bitcoin-core-28-wallet-integration-guide/
[news340 lneas]: /en/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts
[news341 lneas]: /en/newsletters/2025/02/14/#continued-discussion-about-ephemeral-anchor-scripts-for-ln
[news375 arb data]: /en/newsletters/2025/10/10/#theoretical-limitations-on-embedding-data-in-the-utxo-set
[news379 arb data]: /en/newsletters/2025/11/07/#multiple-discussions-about-restricting-data
[news 338]: /en/newsletters/2025/01/24/#bitcoin-core-31397
