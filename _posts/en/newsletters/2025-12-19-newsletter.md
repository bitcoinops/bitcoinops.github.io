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

- **Erlay update:** Sergi Delgado made [several posts][erlay optech posts] this
  year about his work and progress implementing [Erlay][erlay] in Bitcoin Core.
  In the first post, he gave an overview of the Erlay proposal and how the
  current transaction relay mechanism ("fanout") works. In these posts, he
  discussed different results he found while developing Erlay, such as that
  [filtering based on transaction knowledge][erlay knowledge] was not as
  impactful as expected. He also experimented with selecting [how many peers
  should receive a fanout][erlay fanout amount], finding that there was a 35%
  bandwidth savings with 8 outbound peers and 45% with 12 outbound peers, but
  also found a 240% increase in latency. In two other experiments, he
  determined the [fanout rate based on how a transaction was
  received][erlay transaction received] and [when to select candidate
  peers][erlay candidate peers]. These experiments, which combined fanout and
  reconciliation, helped him determine when to use each method.

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

## Summary 2025: Vulnerability disclosures

In 2025, Optech summarized more than a dozen vulnerability disclosures.
Vulnerability reports help both developers and users learn from past mistakes,
and [responsible disclosures][topic responsible disclosures] ensure fixes are
released before vulnerabilities can be exploited.

_Note: Optech only publishes the names of vulnerability discoverers if we think
they made a reasonable effort to minimize the risk of harm to users. We thank
all the individuals mentioned in this section for their insight and clear
concern for user safety._

In early January, Yuval Kogman [publicly disclosed][news335 coinjoin] several
longstanding deanonymization weaknesses in centralized [coinjoin][topic
coinjoin] protocols used by current versions of Wasabi and Ginger, as well as in
past versions of Samourai, Sparrow, and Trezor Suite. If exploited, a
centralized coordinator could link a user’s inputs to their outputs, effectively
removing the expected privacy benefits of the coinjoin. A similar vulnerability was
also reported in late 2024 (see [Newsletter #333][news333 coinjoin]).

At the end of January, Matt Morehouse [announced][news339 ldk] the responsible
disclosure of a vulnerability in LDK’s claim processing during unilateral closes
with many pending [HTLCs][topic htlc]. LDK aimed to reduce fees by batching
multiple HTLC resolutions; however, if conflicts arose with confirmed
transactions from a channel counterparty, LDK could fail to update all affected
batches, leading to stuck funds and even theft risk. This issue was fixed in
LDK 0.1.

That same week, Antoine Riard [disclosed][news339 cycling] an additional
vulnerability using the [replacement cycling][topic replacement cycling] attack.
An attacker could exploit it by [pinning][topic transaction pinning] a victim’s
unconfirmed transaction, receiving and not propagating the victim's fee-bumping
replacements, and then selectively mining the victim’s highest-fee version. This
scenario required rare conditions and would be difficult to sustain without
being detected.

In February, Morehouse [disclosed][news340 htlcbug] a second LDK vulnerability:
if many HTLCs had the same amount and payment hash, LDK would fail to settle
all HTLCs except one, leading honest counterparties to force-close the channels.
While this didn’t enable direct theft, it resulted in extra fees and reduced
routing revenue until the bug was fixed in LDK 0.1.1 (see Newsletter [#340][news340
htlcfix]).

In March, Morehouse [announced][news344 lnd] the responsible disclosure of a
fixed LND vulnerability in versions before 0.18: an attacker with a
channel to the victim could cause LND to both pay and refund the same HTLC if
they could also somehow cause the victim’s node to restart. This would allow the
attacker to steal nearly the entire channel value. The disclosure also
highlighted gaps in the Lightning specification, which were later corrected (see
[Newsletter #346][news346 bolts]).

In May, Ruben Somsen [described][news353 bip30] a theoretical consensus-failure
edge case related to BIP30’s historical handling of [duplicate][topic duplicate
transactions] coinbase transactions. With checkpoints removed from Bitcoin Core
(see [Newsletter #346][news346 checkpoints]), an extreme block reorg up to block
91,842 could leave nodes with different UTXO sets, depending on whether or not
they observed the duplicate coinbases. Several solutions were discussed, such as
hardcoding additional special-case logic for these two exceptions; however, it
wasn't deemed a realistic threat.

Also in May, Antoine Poinsot [announced][news354 32bit] the responsible
disclosure of a low-severity vulnerability affecting Bitcoin Core versions
before 29.0 where excessive address advertisements could overflow a 32-bit
identifier and crash the node. Earlier mitigations had already made exploitation
impractically slow under the default peer limits (see Newsletters [#159][news159
32bit] and [#314][news314 32bit]), and the issue was fully resolved by switching
to 64-bit identifiers in Bitcoin Core 29.0.

In July, Morehouse [announced][news364 lnd] the responsible disclosure of an LND
denial-of-service issue in which an attacker could repeatedly request historic
[gossip][topic channel announcements] messages until the node exhausted its
memory and crashed. This bug was fixed in LND 0.18.3 (see [Newsletter
#319][news319 lnd]). In September, Morehouse [disclosed][news373 eclair] a
vulnerability in older versions of Eclair: an attacker could
broadcast an old commitment transaction to steal all current funds from a
channel, and Eclair would ignore it. Eclair’s fix was paired with a more
comprehensive test suite intended to catch similar potential issues.

In October, Poinsot [published][news378 four] four low-severity, responsibly
disclosed Bitcoin Core vulnerabilities, covering two disk-filling bugs, a highly
unlikely remote crash affecting 32-bit systems, and a CPU DoS issue in
unconfirmed transaction processing. These were partially fixed in 29.1 and fully
fixed in 30.0, see Newsletters [#361][news361 four], [#363][news363 four], and
[#367][news367 four] for a few of the fixes.

In December, Bruno Garcia [disclosed][news383 nbitcoin] a theoretical consensus
failure in the NBitcoin library related to `OP_NIP` that could trigger an
exception in a specific full-capacity stack edge case. It was found using
differential fuzzing and quickly patched. No full node is known to use NBitcoin
so there was no practical chain-split risk from the disclosure.

In December, Morehouse also [disclosed][news384 lnd] three critical
vulnerabilities in LND including two theft-of-funds vulnerabilities and one
denial-of-service vulnerability.

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

With the increased attention on the potential for a future [quantum][topic
quantum resistance] computer to weaken or break the Elliptic Curve Discrete
Logarithm (ECDL) hardness assumption that Bitcoin relies on to prove the
ownership of coins, several conversations and proposals were put forward
throughout the year to discuss and mitigate the impact of such a development.

Clara Shikhelman and Anthony Milton [published][news357 quantum report] a paper
covering the impacts of quantum computing on Bitcoin and outlining potential
mitigation strategies.

[BIP360][] was [updated][news bip360 update] and received its BIP number. This
proposal has drawn interest both as a first step toward quantum-hardening
Bitcoin and an optimization for taproot use cases that do not require an
internal key. [Research][news365 quantum taproot] later in the year confirmed
the security of these taproot commitments against manipulation by quantum
computers. Near the end of the year, the proposal was renamed to P2TSH (pay to
tapscript hash) instead of the earlier name P2QRH (pay to quantum resistant
hash), reflecting its reduced scope and increased generality.

Jesse Posner [highlighted existing research][news364 quantum primatives] that
indicates existing Bitcoin primitives like hierarchical deterministic (HD)
wallets, [silent payments][topic silent payments], key aggregation, and
[threshold signatures][topic threshold signature] could be compatible with some
of the commonly referenced quantum-resistant signature algorithms.

Augustin Cruz [proposed][news qr cruz] a BIP to destroy coins that are
quantum-vulnerable with certainty. Subsequently, Jameson Lopp [started a
discussion][news qr lopp1] of how quantum-vulnerable coins should be handled,
which led to several ideas ranging from letting the quantum adversary have them
to destroying them. Lopp later [proposed][news qr lopp2] a concrete [sequence of
soft forks][BIPs #1895] that Bitcoin could implement, beginning long before a
Cryptographically Relevant Quantum Computer (CRQC) is developed to gradually
mitigate the threat of a quantum adversary suddenly gaining access to many
coins, while allowing holders time to secure their coins.

Two proposals ([1][news qr sha], [2][news qr cr]) were made to enable most
existing coins to be secured in a way that could be recovered in the event that
Bitcoin disables quantum-vulnerable spends at some later point. Briefly, the
theorized sequence of events is 0) bitcoin holders ensure that their current
wallets have some hashed secret required for some spend path
1) a CRQC is shown to be imminent, 2) Bitcoin disables elliptic curve
signatures, 3) Bitcoin enables a quantum secure signature scheme, 4) Bitcoin
enables one of these proposals enabling prepared holders to claim their
quantum-vulnerable coins. Depending on the exact implementation, any address
type (including P2TR with a scriptpath) could take advantage of these methods.

Developer Conduition demonstrated that [`OP_CAT`][BIP347] can be used to
implement Winternitz signatures, which provide a quantum-resistant signature
check at a cost of ~2000 vbytes per input. This is less costly than the
previously [proposed][rubin lamport] `OP_CAT`-based [Lamport
signatures][lamport].

Matt Corallo started a [discussion][news qr corallo] around the general idea of
adding a quantum-resistant signature-checking opcode to [tapscript][topic
tapscript]. Later, Abdelhamid Bakhta [proposed][abdel stark] native STARK
verification as one such opcode, and Conduition [wrote][conduition sphincs]
about their work optimizing SLH-DSA (SPHINCS) quantum-resistant signatures as
another option. Any quantum-resistant signature checking opcode including
`OP_CAT` added to tapscript could be combined with [BIP360][] to fully
quantum-harden Bitcoin outputs.

Tadge Dryja [proposed][news qr agg] one way in which Bitcoin could implement
general cross-input signature aggregation which would partially mitigate the
large size of post-quantum signatures.

At the end of the year, Mikhail Kudinov and Jonas Nick [published][nick paper
tweet] a [paper][hash-based signature schemes] that provides an overview of
hash-based signature schemes and discusses how those could be adapted to suit
Bitcoin’s needs.

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

- **Partitioning and eclipse attacks using BGP interception:** Cedarctic
  [posted][Cedarctic post] to Delving Bitcoin about flaws in Border Gateway
  Protocol (BGP) which could be used to prevent full nodes from being able to
  connect to honest peers, potentially allowing network partitions or [eclipse
  attacks][eclipse attack]. Several mitigations were described by cedarctic,
  with other developers in the discussion describing other mitigations and ways
  to monitor for the attack.

<div markdown="1" class="callout" id="releases">

## Summary 2025: Major releases of popular infrastructure projects

- [BDK wallet-1.0.0][] marked the first major release of this library, where the
  original `bdk` crate was renamed to `bdk_wallet` with a stable API and lower
  layer modules were extracted into their own crates.

- [LDK v0.1][] added support for both sides of the LSPS channel open negotiation
  protocols, [BIP353][] Human Readable Names resolution, and reduced onchain fee
  costs when resolving multiple [HTLCs][topic htlc] for a single channel
  force-closure.

- [Core Lightning 25.02][] added support for [peer storage][topic peer storage],
  off by default.

- [Eclair v0.12.0][] added support for creating and managing [BOLT12
  offers][topic offers], a new channel closing protocol that supports
  [RBF][topic rbf], and support for storing small amounts of data for peers
  through [peer storage][topic peer storage].

- [BTCPay Server 2.1.0][] added several improvements for [RBF][topic rbf] and
  [CPFP][topic cpfp] fee bumping, a better flow for multisig when all signers
  are using BTCPay Server, and made some breaking changes for users of some
  altcoins.

- [Bitcoin Core 29.0][] replaced the UPnP feature (responsible in part for
  several past security vulnerabilities) with a NAT-PMP option, improved
  fetching of parents of orphan transactions for [package relay][topic package
  relay], improved [timewarp][topic time warp] avoidance for miners, and
  migrated the build system from `automake` to `cmake`.

- [LND 0.19.0-beta][] added new RBF-based fee bumping for cooperative closes.

- [Core Lightning 25.05][] introduced experimental [splicing][topic splicing]
  support compatible with Eclair, and enabled peer storage by default.

- [BTCPay Server 2.2.0][] added support for wallet policies and
  [miniscript][topic miniscript].

- [Core Lightning v25.09][] added support to the `xpay` command for paying
  [BIP353][] addresses and [offers][topic offers].

- [Eclair v0.13.0][] introduced an initial implementation of [simple taproot
  channels][topic simple taproot channels], improvements to [splicing][topic
  splicing] based on recent specification updates, and better BOLT12 support.

- [Bitcoin Inquisition 29.1][] added support for `OP_INTERNALKEY`, an opcode
  part of multiple [covenant][topic covenants] proposals.

- [Bitcoin Core 30.0][] made multiple data carrier (OP_RETURN) outputs standard,
  increased the default `datacarriersize` to 100,000, set a default [minimum
  relay feerate][topic default minimum transaction relay feerates] of 0.1
  sat/vbyte, added an experimental IPC mining interface for [Stratum v2][topic
  pooled mining] integrations, and removed support for creating or loading
  legacy wallets. Legacy wallets can be migrated to the [descriptor][topic
  descriptors] wallet format.

- [Core Lightning v25.12][] added [BIP39][] mnemonic seed phrases as the new
  default backup method and experimental [JIT channels][topic jit channels]
  support.

- [LDK 0.2][] added support for [splicing][topic splicing] (experimental),
  serving and paying static invoices for [async payments][topic async payments],
  and [zero-fee-commitment][topic v3 commitments] channels using [ephemeral
  anchors][topic ephemeral anchors].

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

- **Channel jamming mitigation simulation results and updates:** Carla
  Kirk-Cohen, in collaboration with Clara Shikhelman and elnosh, posted the
  [Lightning jamming simulation results][channel jamming results] for their
  updated reputation algorithm. The updates included reputation tracking for
  outgoing channels and tracking incoming channel resource limitations. With
  these new updates, they found that it still protects against
  [resource][channel jamming resource] and [sink][channel jamming sink] attacks.
  After this round of updates and simulations, they feel that [channel jamming
  attack][channel jamming attack] mitigation has reached a point where it is
  sufficient for implementation.

## November

{:#secpperformance}

- **Comparing performance of ECDSA signature validation in OpenSSL vs. libsecp256k1:**
  Ten years after Bitcoin Core switched from OpenSSL to libsecp256k1, Sebastian
  Falbesoner [posted][openssl vs libsecp256k1] a benchmark analysis comparing
  the performance of both cryptographic libraries for signature validation.
  Libsecp256k1 was created in 2015 specifically for Bitcoin Core, and was
  already between 2.5 and 5.5 times faster at the time. Falbesoner found the gap
  has since widened to more than 8x, as libsecp256k1 continued to improve while
  OpenSSL's secp256k1 performance remained static, which is unsurprising given
  the curve's limited relevance outside Bitcoin.

  In the discussion, libsecp256k1 creator Pieter Wuille notes that the
  benchmarks have inherent biases: all versions were tested on modern hardware
  and compilers, but historical optimizations targeted the hardware and
  compilers that existed at the time.

{:#stalerates}

- **Modeling stale rates by propagation delay and mining centralization:**
  Antoine Poinsot [posted][Antoine post] to Delving Bitcoin analyzing how block
  propagation delays systematically advantage larger miners. He modeled two
  scenarios in which block A goes stale. In the first, a competing block B is
  found before A and propagates first. In the second, B is found shortly after
  A, but the same miner also finds the next block. The first scenario is more
  likely, suggesting miners benefit more from hearing others' blocks quickly
  than from broadcasting their own.

  Poinsot showed that stale rates increase with propagation delay and
  disproportionately affect smaller miners. He found that with 10-second
  propagation, a 5 EH/s operation earning $91M annually could gain about $100k
  in additional revenue by connecting to the largest pool instead of the
  smallest. Since mining operates on thin margins, small revenue differences can
  translate to significant profit impacts.

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

{:#lnsplicing}

- **Splicing:** In December, [LDK 0.2][] was released with experimental
  [splicing][topic splicing] support, making the feature available across three
  major Lightning implementations: LDK, Eclair, and Core Lightning. Splicing
  allows nodes to add or remove funds from a channel without closing it.

  This wrapped up a year of significant progress towards LN's splicing feature.
  Eclair added [support for splicing on public channels][news340 eclairsplice]
  in February and [splicing in simple taproot channels][news368 eclairtaproot]
  in August. Meanwhile, Core Lightning [finalized][news355 clnsplice]
  interoperability with Eclair in May and shipped it in [Core Lightning
  25.05][news359 cln2505].

  Throughout the year, all the pieces required for the LDK implementation were
  added, including [splice-out support][news369 ldksplice] in August,
  [integrating][news370 ldkquiesce] splicing with the quiescence protocol in
  September, and shipping numerous additional refinements before the 0.2 release.

  The implementation teams also coordinated on specification details, such as
  increasing the delay before marking a channel as closed to allow for splice
  propagation (raised from 12 to [72 blocks][news359 eclairdelay] per [BOLTs
  #1270][]) and [reconnection logic][news381 clnreconnect] for synchronized
  splice state per [BOLTs #1289][].

  However, the main [splicing specification][bolts #1160] remains unmerged as of
  the end of the year, with updates still expected and cross-compatibility
  issues continuing to be resolved.

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
[news bip360 update]: /en/newsletters/2025/03/07/#update-on-bip360-pay-to-quantum-resistant-hash-p2qrh
[news qr sha]: /en/newsletters/2025/04/04/#securely-proving-utxo-ownership-by-revealing-a-sha256-preimage
[news qr cr]: /en/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[news qr lopp1]: /en/newsletters/2025/04/04/#should-vulnerable-bitcoins-be-destroyed
[news qr lopp2]: /en/newsletters/2025/08/01/#migration-from-quantum-vulnerable-outputs
[news qr cruz]: /en/newsletters/2025/04/04/#draft-bip-for-destroying-quantum-insecure-bitcoins
[news qr corallo]: /en/newsletters/2025/01/03/#quantum-computer-upgrade-path
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[lamport]: https://en.wikipedia.org/wiki/Lamport_signature
[conduition sphincs]: /en/newsletters/2025/12/05/#slh-dsa-sphincs-post-quantum-signature-optimizations
[abdel stark]: /en/newsletters/2025/11/07/#native-stark-proof-verification-in-bitcoin-script
[news364 quantum primatives]: /en/newsletters/2025/07/25/#research-indicates-common-bitcoin-primitives-are-compatible-with-quantum-resistant-signature-algorithms
[news365 quantum taproot]: /en/newsletters/2025/08/01/#security-against-quantum-computers-with-taproot-as-a-commitment-scheme
[news357 quantum report]: /en/newsletters/2025/06/06/#quantum-computing-report
[news qr agg]: /en/newsletters/2025/11/07/#post-quantum-signature-aggregation
[nick paper tweet]: https://x.com/n1ckler/status/1998407064213704724
[hash-based signature schemes]: https://eprint.iacr.org/2025/2203.pdf
[news335 chilldkg]: /en/newsletters/2025/01/03/#updated-chilldkg-draft
[news offchain dlc]: /en/newsletters/2025/01/24/#correction-about-offchain-dlcs
[news dlc channels]: /en/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs
[Cedarctic post]: /en/newsletters/2025/09/19/#partitioning-and-eclipse-attacks-using-bgp-interception
[eclipse attack]: /en/topics/eclipse-attacks/
[Antoine post]: /en/newsletters/2025/11/21/#modeling-stale-rates-by-propagation-delay-and-mining-centralization
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
[news335 coinjoin]: /en/newsletters/2025/01/03/#deanonymization-attacks-against-centralized-coinjoin
[news333 coinjoin]: /en/newsletters/2024/12/13/#deanonymization-vulnerability-affecting-wasabi-and-related-software
[news340 htlcbug]: /en/newsletters/2025/02/07/#channel-force-closure-vulnerability-in-ldk
[news340 htlcfix]: /en/newsletters/2025/02/07/#ldk-3556
[news339 ldk]: /en/newsletters/2025/01/31/#vulnerability-in-ldk-claim-processing
[news339 cycling]: /en/newsletters/2025/01/31/#replacement-cycling-attacks-with-miner-exploitation
[news346 bolts]: /en/newsletters/2025/03/21/#bolts-1233
[news344 lnd]: /en/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[news346 checkpoints]: /en/newsletters/2025/03/21/#bitcoin-core-31649
[news353 bip30]: /en/newsletters/2025/05/09/#bip30-consensus-failure-vulnerability
[news354 32bit]: /en/newsletters/2025/05/16/#vulnerability-disclosure-affecting-old-versions-of-bitcoin-core
[news364 lnd]: /en/newsletters/2025/07/25/#lnd-gossip-filter-dos-vulnerability
[news319 lnd]: /en/newsletters/2024/09/06/#lnd-9009
[news159 32bit]: /en/newsletters/2021/07/28/#bitcoin-core-22387
[news314 32bit]: /en/newsletters/2024/08/02/#remote-crash-by-sending-excessive-addr-messages
[news373 eclair]: /en/newsletters/2025/09/26/#eclair-vulnerability
[news378 four]: /en/newsletters/2025/10/31/#disclosure-of-four-low-severity-vulnerabilities-in-bitcoin-core
[news361 four]: /en/newsletters/2025/07/04/#bitcoin-core-32819
[news363 four]: /en/newsletters/2025/07/18/#bitcoin-core-32604
[news367 four]: /en/newsletters/2025/08/15/#bitcoin-core-33050
[news383 nbitcoin]: /en/newsletters/2025/12/05/#consensus-bug-in-nbitcoin-library
[news384 lnd]: /en/newsletters/2025/12/12/#critical-vulnerabilities-fixed-in-lnd-0-19-0
[bdk wallet-1.0.0]: /en/newsletters/2025/01/03/#bdk-wallet-1-0-0
[ldk v0.1]: /en/newsletters/2025/01/17/#ldk-v0-1
[core lightning 25.02]: /en/newsletters/2025/03/07/#core-lightning-25-02
[eclair v0.12.0]: /en/newsletters/2025/03/14/#eclair-v0-12-0
[btcpay server 2.1.0]: /en/newsletters/2025/04/11/#btcpay-server-2-1-0
[bitcoin core 29.0]: /en/newsletters/2025/04/18/#bitcoin-core-29-0
[lnd 0.19.0-beta]: /en/newsletters/2025/05/23/#lnd-0-19-0-beta
[core lightning 25.05]: /en/newsletters/2025/06/20/#core-lightning-25-05
[btcpay server 2.2.0]: /en/newsletters/2025/08/08/#btcpay-server-2-2-0
[core lightning v25.09]: /en/newsletters/2025/09/05/#core-lightning-v25-09
[eclair v0.13.0]: /en/newsletters/2025/09/12/#eclair-v0-13-0
[bitcoin inquisition 29.1]: /en/newsletters/2025/10/10/#bitcoin-inquisition-29-1
[bitcoin core 30.0]: /en/newsletters/2025/10/17/#bitcoin-core-30-0
[core lightning v25.12]: /en/newsletters/2025/12/05/#core-lightning-v25-12
[ldk 0.2]: /en/newsletters/2025/12/05/#ldk-0-2
[news340 eclairsplice]: /en/newsletters/2025/02/07/#eclair-2968
[news368 eclairtaproot]: /en/newsletters/2025/08/22/#eclair-3103
[news355 clnsplice]: /en/newsletters/2025/05/23/#core-lightning-8021
[news359 cln2505]: /en/newsletters/2025/06/20/#core-lightning-25-05
[news369 ldksplice]: /en/newsletters/2025/08/29/#ldk-3979
[news370 ldkquiesce]: /en/newsletters/2025/09/05/#ldk-4019
[news359 eclairdelay]: /en/newsletters/2025/06/20/#eclair-3110
[news381 clnreconnect]: /en/newsletters/2025/11/21/#core-lightning-8646
[bolts #1270]: https://github.com/lightning/bolts/pull/1270
[bolts #1289]: https://github.com/lightning/bolts/pull/1289
[bolts #1160]: https://github.com/lightning/bolts/pull/1160
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
