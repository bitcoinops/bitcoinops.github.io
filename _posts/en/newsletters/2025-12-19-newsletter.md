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

- **Updated ChillDKG draft:** Tim Ruffing and Jonas Nick
  [updated][news335 chilldkg] their work on a distributed key generation
  protocol (DKG) for use with the FROST [threshold signature][topic
  threshold signature] scheme. ChillDKG aims to provide similar
  recoverability features to existing descriptor wallets.

{:#offchaindlcs}

- **Offchain DLCs:** Developer Conduition [posted about][news offchain dlc] a
  new offchain DLC ([discreet log contract][topic dlc]) mechanism that enables
  participants to collaborate on the creation and extension of a DLC factory,
  which allows iterative DLCs that roll along until one party chooses to
  resolve onchain. This contrasts with [prior work][news dlc channels] on
  offchain DLCs which required interaction at each roll of the contract.

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

- **Probabilistic payments:** Oleksandr Kurbatov sparked a
  [discussion][delving random] on Delving Bitcoin of methods to produce random
  outcomes from Bitcoin scripts. The [original][ok random] method uses
  zero-knowledge proofs in a challenger/verifier arrangement and now has a
  [published proof of concept][random poc]. Other methods were discussed,
  [including one][waxwing random] leveraging the tree structure of
  taproot, and a [method][rl random] that scripted the XOR of bits
  represented by a sequence of different hashing functions to directly produce
  an unpredictable bitstring. There was [discussion][dh random] of whether
  such random transaction outcomes could be used to produce probabilistic
  HTLCs as an alternative to [trimmed HTLCs][topic trimmed htlc] for small amounts in LN.

<div markdown="1" class="callout" id="vulns">

## Summary 2025: Vulnerabilities

...

</div>

## March

{:#forkingguide}

- **Bitcoin Forking Guide:** Anthony Towns posted to Delving Bitcoin [a
  guide][news344 fork guide] on how to build community consensus for changes to
  Bitcoin’s consensus rules. According to Towns, the process of establishing
  consensus can be divided into four steps: [research and development][fork
  guide red], [power user exploration][fork guide pue], [industry
  evaluation][fork guide ie], and [investor review][fork guide ir]. However,
  Towns warned readers that the guide aims to be only a high-level procedure,
  and that it could work only in a cooperative environment.

{:#templatemarketplace}

- **Private block template marketplace to prevent centralizing MEV:** Developers
  Matt Corallo and 7d5x9 posted to Delving Bitcoin [a proposal][news344 template
  mrkt] that could help prevent a future in which MEVil, a form of miner
  extractable value (MEV) leading to mining centralization, proliferates on
  Bitcoin. The proposal, referred to as [MEVpool][mevpool gh], would allow
  parties to bid in public markets for selected space within miner block
  templates (e.g., "I’ll pay X [BTC] to include transaction Y as long as it
  comes before any other transaction which interacts with the smart contract
  identified by Z").

  While services of preferential transaction ordering within block
  templates are expected to be provided only by large miners, leading to
  centralization, a trust-reduced public market would allow any miner to work on
  blinded block templates, whose complete transactions aren’t revealed to miners
  until they’ve produced sufficient proof of work to publish the block. The
  authors warned that this proposal would require multiple marketplaces to
  compete to help preserve decentralization against the dominance of a single
  trusted marketplace.

{:#lnupfrontfees}

- **LN upfront and hold fees using burnable outputs:** John Law proposed [a
  solution][news 347 ln fees] to [channel jamming attacks][topic channel jamming
  attacks], a weakness in the Lightning Network protocol that allows an attacker
  to costlessly prevent other nodes from using their funds. The proposal
  summarizes a [paper][ln fees paper] he has written about the possibility for
  Lightning nodes to charge two additional types of fees for forwarding
  payments, an upfront fee and a hold fee. The ultimate spender would pay the
  former to compensate forwarding nodes for temporarily using an [HTLC][topic
  htlc] slot, while the latter would be paid by any node that delays the
  settlement of an HTLC, with the fee amount scaling up with the length of the
  delay.

## April

{:#swiftsync}
- **SwiftSync speedup for initial block download:** ...

{:#dahlias}

- **DahLIAS interactive aggregate signatures:** In April, Jonas Nick, Tim
  Ruffing, and Yannick Seurin [announced][news351 dahlias] to the Bitcoin-Dev
  mailing list their [DahLIAS paper][dahlias paper], the first interactive
  64-byte aggregate signature scheme compatible with the cryptographic
  primitives already used in Bitcoin. Aggregate signatures are the cryptographic
  requirement for [cross-input signature aggregation][topic cisa] (CISA), a
  feature proposed for Bitcoin that could reduce the size of transactions with
  multiple inputs, thus reducing the cost of many different types of spending,
  [coinjoins][topic coinjoin] and [payjoins][topic payjoin] included.

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

- **Calculating the selfish mining danger threshold:** Antoine Poinsot provided
  an [in-depth explanation][news358 selfish miner] of the math behind the
  [selfish mining attack][topic selfish mining], based on the 2013
  [paper][selfish miner paper] that gave this exploit its name. Poinsot focused
  on reproducing one of the paper's conclusions, proving that a dishonest miner
  controlling 33% of the total network hashrate can become marginally more
  profitable than the remaining miners by selectively delaying the announcement
  of some of the new blocks it finds.

{:#fingerprinting}

- **Fingerprinting nodes using addr messages:** Developers Daniela Brozzoni and
  Naiyoma presented the [results][news360 fingerprinting] of their
  fingerprinting research, which focused on identifying the same node on
  multiple networks using `addr` messages, which are sent by the nodes, through
  the P2P protocol, to advertise other potential peers. Brozzoni and Naiyoma
  were able to fingerprint individual nodes using details from their specific
  address messages, allowing them to identify the same node running on multiple
  networks (such as IPv4 and [Tor][topic anonymity networks]). Researchers
  suggested two possible mitigations: either removing timestamps from address
  messages entirely or randomizing them slightly to make them less specific to
  particular nodes.

{:#garbledlocks}

- **Garbled locks:** In June, Robin Linus presented [a proposal][news359 bitvm3]
  for improving [BitVM][topic acc]-style contracts, based on an [idea][delbrag
  rubin] by Jeremy Rubin. The new approach leverages [garbled circuits][garbled
  circuits wiki], a cryptographic primitive that makes onchain SNARK
  verification a thousand times more efficient than the BitVM2 implementation,
  promising a significant reduction in the amount of onchain space required.
  However, it comes at the cost of requiring a multi-terabyte offchain setup.

  Later, in August, Liam Eagen [posted][news369 eagen] to the Bitcoin-Dev mailing
  list about his research [paper][eagen paper] describing a new mechanism for
  creating [accountable computing contracts][topic acc] based on garbled
  circuits, called Glock (garbled locks). While the approach is similar, Eagen's
  research is independent from Linus'. According to Eagen, Glock allows for a
  550x reduction of onchain data compared to BitVM2.

<div markdown="1" class="callout" id="softforks">

## Summary 2025: Soft fork proposals

This year saw a bevvy of discussions around soft fork proposals, ranging from
the tightly scoped and minimally impactful, to the broadly scoped and
powerful.

- *Transaction templates:* Several soft fork packages were discussed around
  transaction templates. With similar scope and capability are CTV+CSFS
  ([BIP119][]+[BIP348][]) and the [taproot-native re-bindable signature
  package][news thikcs] ([`OP_TEMPLATEHASH`][BIPs #1974]+[BIP348][]+[BIP349][]).
  These represent the minimal capability enhancement for Bitcoin Script to
  enable both re-bindable signatures (signatures that do not commit to spending
  a specific UTXO), and pre-commitment to spending a UTXO to a specific next
  transaction (sometimes called an equality [covenant][topic covenants]). If
  activated, they would enable [LN-Symmetry][ctv csfs symmetry] and [simple CTV
  vaults][ctv vaults], [reduce DLC signature requirements][ctv dlcs], [reduce
  interactivity for Arks][ctv csfs arks], [simplify PTLCs][ctv csfs ptlcs], and
  more. One difference between these proposals is that `OP_TEMPLATEHASH` cannot
  be used in the [BitVM sibling hack][ctv csfs bitvm] where CTV can, because
  `OP_TEMPLATEHASH` does not commit to `scriptSigs`.

  By including [OP_CHECKSIGFROMSTACK][topic OP_CHECKSIGFROMSTACK], these
  proposals also enable multi-commitments (committing to multiple related and
  optionally ordered values in a locking or spend script) similar to merkle
  trees through [Key Laddering][rubin key ladder]. The updated [LNHANCE][lnhance
  update] proposal includes `OP_PAIRCOMMIT` ([BIPs #1699][]) to enable
  multi-commitments without the additional script size and validation cost
  required for Key Laddering. Multi-commitments are useful in LN-Symmetry,
  complex delegations, and more.

  Some developers [expressed frustration][ctv csfs letter] about the (from their
  perspective) slow progress toward a soft fork, but the volume of discussion
  around this category of proposal suggests that interest and enthusiasm remain
  high.

- *Consensus cleanup:* The [consensus cleanup][topic consensus cleanup] proposal
  was [updated][gcc update] based on feedback and additional research, a [draft
  bip][gcc bip] was published and merged as [BIP54][] and now [includes an
  implementation and test vectors][gcc impl tests]. Earlier this year, there was
  [discussion][transitory cleanups] of whether such cleanups should be made
  temporary in case of unintentional confiscation, but the necessity of
  reevaluating such a [temporary soft fork][topic transitory soft forks] every
  time it expires makes such temporary soft forks less appealing.

- *Opcode proposals:* In addition to the bundled opcode proposals discussed
  above, there were several other individual Script opcodes proposed or refined
  in 2025.

  `OP_CHECKCONTRACTVERIFY` (CCV) [became][ccv bip] [BIP443][] with [refined][ccv
  semantics] semantics, especially around the flow of funds. CCV enables
  reactive security [vaults][topic vaults], and a wide array of other contracts
  by constraining the `scriptPubKey` and amount of an input or output in certain
  ways. The `OP_VAULT` proposal was [withdrawn][vault withdrawn] in favor of
  CCV. For more on CCV's applications, see [Optech's topic entry][topic MATT].

  A set of 64-bit arithmetic opcodes were [proposed][64bit bip]. Bitcoin's
  current math operations are (surprisingly) not able to operate on the full
  range of Bitcoin input and output amounts. Combined with other opcodes to
  access and/or constrain input/output amounts, these expanded arithmetic
  operations could enable new Bitcoin wallet functionality.

  A proposed [variant][txhash sponsors] of [`OP_TXHASH`][txhash] would enable
  [transaction sponsorship][topic fee sponsorship].

  Developers proposed two options for giving Script elliptic curve cryptographic
  operations other than `OP_CHECKSIG` and related operations. One
  [proposes][tweakadd] `OP_TWEAKADD` to enable constructing taproot
  `scriptPubKeys`. The other [proposes][ecmath] more granular elliptic curve
  opcodes, such as `EC_POINT_ADD`, motivated by similar functionality, but with
  broader potential applications, such as new signature verifications or
  multisignature functionality. Combining either of these proposals with
  `OP_TXHASH` and 64-bit arithmetic (or similar opcodes) would enable
  functionality similar to CCV.

- *Script Restoration:* A series of four BIPs were [posted][gsr bips] for the
  Script Restoration project. The Script changes and opcodes proposed in these
  four BIPs would enable all of the functionality proposed in the above opcode
  proposals while allowing more script expressivity.

</div>

## July

{:#ccdelegation}

- **Chain code delegation:** Jurvis Tan [posted][jt delegation] about his work
  with Jesse Posner on a method (now called [Chain Code Delegation][BIPs
  #2004]/BIP89) for collaborative custody where the customer, rather than the
  partially trusted collaborative custody provider, generates (and keeps
  private) the [BIP32][] chain code to derive child keys from the provider's
  signing key. This way, the provider cannot derive the customer's full key
  tree. The method can be used either blinded (for complete privacy while still
  leveraging the provider's key security) or non-blinded (allowing the provider
  to enforce policy at the cost of revealing the specific transactions being
  signed to the provider).

## August

{:#utreexo}

- **Utreexo draft BIPs:** Calvin Kim, Tadge Dryja, and Davidson Souza
  co-authored [three draft BIPs][news366 utreexo] for an alternative to storing
  the entire UTXO set, called [Utreexo][topic utreexo], which allows nodes to
  obtain and verify information about UTXOs being spent in a transaction. The
  proposal makes use of a forest of merkle trees to accumulate references to
  every UTXO, allowing nodes to avoid storing the outputs.

  Since August, the proposal has received some feedback, and the BIPs have been
  assigned numbers:

  * *[BIP181][bip181 utreexo]*: Describes the Utreexo accumulator and its
    operations.

  * *[BIP182][bip182 utreexo]*: Defines the rules for validating blocks and
    transactions using the Utreexo accumulator.

  * *[BIP183][bip183 utreexo]*: Defines the changes needed for nodes to exchange
    an inclusion proof, confirming the UTXOs being spent.

{:#minfeerate}
- **Lowering the minimum relay feerate:** ...

{:#templatesharing}

- **Peer block template sharing:** Anthony Towns proposed a [way][news366 templ
  share] to improve the effectiveness of compact block reconstruction in an
  environment where peers have divergent mempool policies. The proposal would
  allow full nodes to send block templates to their peers, which in turn would
  cache those transactions that would otherwise be rejected by their mempool
  policies. The provided template contains transaction identifiers encoded in
  the same format used by [compact block relay][topic compact block relay].

  Later, in August, Towns opened [BIPs #1937][] to formally [discuss the
  proposal][news368 templ share] for block template sharing. During the
  discussion, several developers raised concerns about privacy and potential
  node fingerprinting. In October, Towns decided to [move the draft][news376
  templ share] to the [Bitcoin Inquisition Numbers and Names Authority][binana
  repo] (BINANA) repository to address these considerations and to refine the
  document. The draft was given the code [BIN-2025-0002][bin].

{:#fuzzing}

- **Differential fuzzing of Bitcoin and LN implementations:** Bruno Garcia gave
  an update on the [progress and results][news369 fuzz] obtained by
  [bitcoinfuzz][], a library to perform fuzz testing of Bitcoin and Lightning
  implementations and libraries. Using the library, developers reported more
  than 35 bugs in Bitcoin-related projects, such as btcd, rust-bitcoin,
  rust-miniscript, LND, and more.

  Garcia also highlighted the importance of differential fuzzing in the
  ecosystem. Developers are able to discover bugs in projects that do not
  implement fuzzing at all, catch discrepancies across Bitcoin implementations,
  and find gaps in the Lightning specifications.

  Finally, Garcia encouraged maintainers to integrate more projects into
  bitcoinfuzz, expanding support for differential fuzzing, and provided possible
  directions for the future development of the project.

## September

{:#simplicity}

- **Details about the design of Simplicity:** After the release of
  [Simplicity][topic simplicity] on the Liquid Network, Russell O'Connor made
  three posts to Delving Bitcoin to discuss the [philosophy and the
  design][simplicity 370] behind the language:

  * *[Part I][simplicity I post]* examines the three major forms of composition
    for transforming basic operations into complex ones.

  * *[Part II][simplicity II post]* dives into Simplicity’s type system
    combinators and basic expressions.

  * *[Part III][simplicity III post]* explains how to build logical operations
    starting from bits up to cryptographic operations using just computational
    Simplicity combinators.

  Since September, two more posts have been published to Delving Bitcoin, [Part
  IV][simplicity IV post], discussing side effects, and [Part V][simplicity V
  post], dealing with programs and addresses.

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
[news358 selfish miner]: /en/newsletters/2025/06/13/#calculating-the-selfish-mining-danger-threshold
[selfish miner paper]: https://arxiv.org/pdf/1311.0243
[news360 fingerprinting]: /en/newsletters/2025/06/27/#fingerprinting-nodes-using-addr-messages
[news359 bitvm3]: /en/newsletters/2025/06/20/#improvements-to-bitvm-style-contracts
[delbrag rubin]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[garbled circuits wiki]: https://en.wikipedia.org/wiki/Garbled_circuit
[news369 eagen]: /en/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[eagen paper]: https://eprint.iacr.org/2025/1485
[news351 dahlias]: /en/newsletters/2025/04/25/#interactive-aggregate-signatures-compatible-with-secp256k1
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[news344 fork guide]: /en/newsletters/2025/03/07/#bitcoin-forking-guide
[fork guide red]: https://ajtowns.github.io/bfg/research.html
[fork guide pue]: https://ajtowns.github.io/bfg/power.html
[fork guide ie]: https://ajtowns.github.io/bfg/industry.html
[fork guide ir]: https://ajtowns.github.io/bfg/investor.html
[news344 template mrkt]: /en/newsletters/2025/03/07/#private-block-template-marketplace-to-prevent-centralizing-mev
[mevpool gh]: https://github.com/mevpool/mevpool/blob/0550f5d85e4023ff8ac7da5193973355b855bcc8/mevpool-marketplace.md
[news 347 ln fees]: /en/newsletters/2025/03/28/#ln-upfront-and-hold-fees-using-burnable-outputs
[ln fees paper]: https://github.com/JohnLaw2/ln-spam-prevention
[gcc update]: /en/newsletters/2025/02/07/#updates-to-cleanup-soft-fork-proposal
[gcc bip]: /en/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[news thikcs]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[ctv csfs symmetry]: /en/newsletters/2025/04/04/#ln-symmetry
[ctv csfs arks]: /en/newsletters/2025/04/04/#ark
[ctv vaults]: /en/newsletters/2025/04/04/#vaults
[ctv dlcs]: /en/newsletters/2025/04/04/#dlcs
[lnhance update]: /en/newsletters/2025/12/05/#lnhance-soft-fork
[rubin key ladder]: https://rubin.io/bitcoin/2024/12/02/csfs-ctv-rekey-symmetry/
[ctv csfs ptlcs]: /en/newsletters/2025/07/04/#ctv-csfs-advantages-for-ptlcs
[ctv csfs bitvm]: /en/newsletters/2025/05/16/#description-of-benefits-to-bitvm-from-op-ctv-and-op-csfs
[ctv csfs letter]: /en/newsletters/2025/07/04/#open-letter-about-ctv-and-csfs
[gcc impl tests]: /en/newsletters/2025/11/07/#bip54-implementation-and-test-vectors
[ccv bip]: /en/newsletters/2025/05/30/#bips-1793
[ccv semantics]: /en/newsletters/2025/04/04/#op-checkcontractverify-semantics
[vault withdrawn]: /en/newsletters/2025/05/16/#bips-1848
[64bit bip]: /en/newsletters/2025/05/16/#proposed-bip-for-64-bit-arithmetic-in-script
[txhash sponsors]: /en/newsletters/2025/07/04/#op-txhash-variant-with-support-for-transaction-sponsorship
[txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[tweakadd]: /en/newsletters/2025/09/05/#draft-bip-for-adding-elliptic-curve-operations-to-tapscript
[ecmath]: /en/newsletters/2025/09/05/#draft-bip-for-adding-elliptic-curve-operations-to-tapscript
[gsr bips]: /en/newsletters/2025/10/03/#draft-bips-for-script-restoration
[transitory cleanups]: /en/newsletters/2025/01/03/#transitory-soft-forks-for-cleanup-soft-forks
[simplicity 370]: /en/newsletters/2025/09/05/#details-about-the-design-of-simplicity
[simplicity I post]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[simplicity II post]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[simplicity III post]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[simplicity IV post]: https://delvingbitcoin.org/t/delving-simplicity-part-two-side-effects/2091
[simplicity V post]: https://delvingbitcoin.org/t/delving-simplicity-part-programs-and-addresses/2113
[news335 chilldkg]: /en/newsletters/2025/01/03/#updated-chilldkg-draft
[news offchain dlc]: /en/newsletters/2025/01/24/#correction-about-offchain-dlcs
[news dlc channels]: /en/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs
[news315 compact blocks]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 compact blocks]: /en/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news365 compact blocks]: /en/newsletters/2025/08/01/#testing-compact-block-prefilling
[news382 compact blocks]: /en/newsletters/2025/11/28/#stats-on-compact-block-reconstructions-updates
[news368 monitoring]: /en/newsletters/2025/08/22/#peer-observer-tooling-and-call-to-action
[28.0 wallet guide]: /en/bitcoin-core-28-wallet-integration-guide/
[news340 lneas]: /en/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts
[news341 lneas]: /en/newsletters/2025/02/14/#continued-discussion-about-ephemeral-anchor-scripts-for-ln
[delving random]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[random poc]: https://github.com/distributed-lab/op_rand
[waxwing random]: /en/newsletters/2025/02/14/#suggested
[ok random]: /en/newsletters/2025/02/07/#emulating-op-rand
[rl random]: /en/newsletters/2025/03/14/#probabilistic-payments-using-different-hash-functions-as-an-xor-function
[dh random]: /en/newsletters/2025/02/14/#asked
[jt delegation]: /en/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[news366 utreexo]: /en/newsletters/2025/08/08/#draft-bips-proposed-for-utreexo
[bip181 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0181.md
[bip182 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0182.md
[bip183 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0183.md
[news366 templ share]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[news368 templ share]: /en/newsletters/2025/08/22/#draft-bip-for-block-template-sharing
[news376 templ share]: /en/newsletters/2025/10/17/#continued-discussion-of-block-template-sharing
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bin]: https://github.com/bitcoin-inquisition/binana/blob/master/2025/BIN-2025-0002.md
[news369 fuzz]: /en/newsletters/2025/08/29/#update-on-differential-fuzzing-of-bitcoin-and-ln-implementations
[bitcoinfuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
[news375 arb data]: /en/newsletters/2025/10/10/#theoretical-limitations-on-embedding-data-in-the-utxo-set
[news379 arb data]: /en/newsletters/2025/11/07/#multiple-discussions-about-restricting-data
[news 338]: /en/newsletters/2025/01/24/#bitcoin-core-31397
