---
title: 'Bitcoin Optech Newsletter #334: 2024 Year-in-Review Special'
permalink: /en/newsletters/2024/12/20/
name: 2024-12-20-newsletter
slug: 2024-12-20-newsletter
type: newsletter
layout: newsletter
lang: en

excerpt: >
  The seventh annual Bitcoin Optech Year-in-Review special summarizes
  notable developments in Bitcoin during all of 2024.

FIXME:
  - Look at all illustrations for this year and see if they can be
    included
  - Replace smart quotes and emdashes and endashes with dumb dashes
---
{{page.excerpt}}  It’s the sequel to our summaries from [2018][yirs
2018], [2019][yirs 2019], [2020][yirs 2020], [2021][yirs 2021],
[2022][yirs 2022], and [2023][yirs 2023].

## Contents

* January
  * FIXME
* Featured summaries
  * FIXME

---

## January

John Law proposed [fee-dependent timelocks][news283 feelocks], a soft
fork allowing [timelocks][topic timelocks] to expire only when median
block feerates drop below a user-specified level. This prevents high
fees near expiration from preventing confirmation, such as Bob claiming
funds in a payment channel.  Instead, the timelock extends until fees
fall, addressing longstanding concerns of [forced expiration
floods][topic expiration floods] during mass channel closures. The
proposal improves security for multi-user setups like [channel
factories][topic channel factories] and [joinpools][topic joinpools]
while incentivizing participants to avoid fee spikes.  Discussions
included storing parameters in the taproot [annex][topic annex], feerate
commitments for lightweight clients, pruned node support, and the impact
of [out-of-band fees][topic out-of-band fees].

Salvatore Ingala proposed a method to [optimize exits][news283 exits]
from multiparty contracts, like joinpools or channel factories, by
enabling users to coordinate a single transaction instead of
broadcasting separate ones.  This reduces onchain size by at least 50%
and up to 99% under ideal circumstances, which is critical when fees are
high. A bond mechanism ensures honest execution: one participant
constructs the transaction but forfeits the bond if proven fraudulent.
Ingala suggests implementing this with [OP_CAT][topic op_cat] and
[MATT][topic acc] soft fork features, with further efficiency possible
using [OP_CSFS][topic op_checksigfromstack] and 64-bit arithmetic.

Gregory Sanders shared a proof-of-concept [implementation][news284
lnsym] of [LN-Symmetry][topic eltoo] using a fork of Core Lightning.
LN-Symmetry enables bi-directional payment channels without penalty
transactions but relies on a soft fork like [SIGHASH_ANYPREVOUT][topic
sighash_anyprevout] to
allow child transactions to spend any parent version. Sanders
highlighted its simplicity compared to [LN-Penalty][topic ln-penalty],
the difficulty of avoiding pinning (inspiring his work on [package
relay][topic package relay] and [ephemeral anchors][topic ephemeral
anchors]), and the potential for faster payments via emulation of
[OP_CTV][topic op_checktemplateverify]. He confirmed penalties are
unnecessary, simplifying channel implementation and avoiding reserved
funds.  However, LN-Symmetry requires longer [CLTV expiry deltas][topic
cltv expiry delta] to prevent misuse.

## February

Peter Todd proposed [Replace by Feerate][news288 rbfr] (RBFr) to address
[transaction pinning][topic transaction pinning] when standard
[RBF][topic rbf] policies fail, with two variations: pure RBFr, allowing
unlimited replacements with much higher feerates (e.g., 2x), and
one-shot RBFr, enabling a single replacement with moderately higher fees
(e.g., 1.25x) if the replacement ranks enters the top of the mempool.
Mark Erhardt identified an initial problem and other developers
discussed the complexities of fully analyzing the idea with available
tools.  Todd released an experimental implementation and other
developers continued working on alternative solutions to address
transaction pinning, including developing the tools necessary to
increase confidence in any solution that is adopted.

Matt Corallo proposed a BIP for DNS-based [human-readable Bitcoin payment
instructions][news290 dns], allowing an email-like string (e.g., example@example.com)
to resolve to a DNSSEC-signed TXT record containing a [BIP21][] URI.
This supports onchain addresses, [silent payments][topic silent
payments], and LN [offers][topic offers]---and can be easily extended to
other payment protocols.  Corallo also drafted a BOLT and BLIP for LN
nodes, enabling wildcard DNS records and secure payment resolution using
offers.

<!-- FIXME
- https://bitcoinops.org/en/newsletters/2024/06/07/#blips-32
- https://bitcoinops.org/en/newsletters/2024/06/14/#bips-1551
- BIP21: https://bitcoinops.org/en/newsletters/2024/03/06/#updating-bip21-bitcoin-uris
- https://bitcoinops.org/en/newsletters/2024/06/07/#proposed-update-to-bip21
- https://bitcoinops.org/en/newsletters/2024/11/15/#ldk-3283
- https://bitcoinops.org/en/newsletters/2024/12/13/#bolts-1180
-->

Fabian Jahr wrote software that allows multiple developers to
[independently create equivalent ASMaps][news290 asmap], which helps
Bitcoin Core diversify peer connections and resist [eclipse attacks][topic
eclipse attacks].  If Jahr's tooling becomes widely accepted, Bitcoin
Core may include ASMaps by default, enhancing protection against attacks
from parties controlling nodes on multiple subnets.

[Support][news290 dualfund] for [dual funding][topic dual funding] was
to the LN specification along with support for the interactive
transaction construction protocol.  Interactive construction allows two
nodes to exchange preferences and UTXO details that allow them to
construct a funding transaction together. Dual funding allows a
transaction to include inputs from either or both parties. For example,
Alice may want to open a channel with Bob. Before this specification
change, Alice had to provide all of the funding for the channel. Now,
when using an implementation that supports dual funding, Alice can open
a channel with Bob where he provides all of the funding or where they
each contribute funds to the initial channel state. This can be combined
with the experimental liquidity advertisements protocol, which has not
yet been added to the specification.

ZmnSCPxj proposed trustless scripts enabling two parties to [bet on
future block feerates][news291 bets].  A user expecting to want a
transaction confirmed by some future block can use this to offset the
risk that [feerates][topic fee estimation] will be unusually high at the
time.  A miner expecting to mine a block around the time the user needs
their transaction confirmed can use this contract to offset the risk
that feerates will be unusually low at the time.  The design prevents
manipulation seen in centralized markets, as the miner's decisions rely
solely on real mining conditions.  The contract is trustless with a
cooperative spend path that minimizes costs for both parties.

<div markdown="1" class="callout" id="vulnreports">
## Summary 2024: Vulnerability disclosures

In 2024, Optech summarized FIXME:n vulnerability disclosures.  The
majority were old disclosures from Bitcoin Core which were being
published for the first time this year.  Vulnerability reports give both
developers and users the opportunity to learn from past problems, and
[responsible disclosures][topic responsible disclosures] allow us all to
thank those who report their discoveries with discretion.

_Note: Optech only publishes the names of vulnerability discoverers if
we think they made a reasonable effort to minimize the risk of harm to
users.  We thank all persons named in this section for their insight and
their clear concern user safety._

Late in 2023, Niklas Gögge [publicly disclosed][news283 lndvuln] two
vulnerabilities he had original reported two years prior, which led to
fixed versions of LND being released.  The first, a DoS vulnerability,
could have led to LND running out of memory and crashing.  The second, a
censorship vulnerability, could allow an attacker to prevent an LND node
from learning about updates to targeted channels across the network; an
attacker could use this to bias a node towards selecting certain routes
for payments it sent, giving the attacker more forwarding fees and more
information about the payments the node sent.

In January, Matt Morehouse [announced a vulnerability][news285 clnvuln]
that affected Core Lightning versions 23.02 through 23.05.2.  When
re-testing nodes that had implemented fixes for fake funding, which he
previously discovered and disclosed, he was able to trigger a race
condition that crashed CLN with about 30 seconds of effort.  If an LN
node is shutdown, it can’t defend a user against malicious or broken
counterparties, which puts the user’s funds at risk.

Also in January, Gögge returned to [announce][news286 btcdvuln] a
consensus failure vulnerability he found in the btcd full node.  The
code could misinterpret a transaction version number and apply to wrong
consensus rules to a transaction using a relative timelock.  This could
prevent btcd full nodes from showing the same confirmed transactions as
Bitcoin Core, putting users at risk of losing money.

February saw Eugene Siegel [publish][news288 bccvuln] a vulnerability
report he had initially disclosed almost three years previously
affecting Bitcoin Core.  The vulnerability could be used to prevent
Bitcoin Core from downloading recent blocks.  This could be used to
prevent a connected LN node from learning about preimages necessary to
resolve [HTLCs][topic htlc], potentially leading to loss of money.

<!-- FIXME
- https://bitcoinops.org/en/newsletters/2024/03/27/#disclosure-of-free-relay-attack
- https://bitcoinops.org/en/newsletters/2024/07/26/#varied-discussion-of-free-relay-and-fee-bumping-upgrades
-->

Morehouse returned in June to [disclose][news308 lndvuln] a
vulnerability that allowed crashing versions of LND before 0.17.0.  As
mentioned earlier, a shutdown LN node can't defend a user against
malicious or broken counterparties, which puts the user’s funds at risk.

July saw the first of [multiple disclosures][news310 disclosures] of
vulnerabilities affecting past versions of Bitcoin Core.  Wladimir J.
Van Der Laan was investigating a vulnerability discovered by Aleksandar
Nikolic in a library used by Bitcoin Core when he [discovered][news310
wlad] a separate vulnerability allowing remote code execution; this was
fixed upstream and the fix incorporated into Bitcoin Core.  Developer
Evil-Knievel [discovered][news310 ek] a vulnerability that could exhaust
the memory of many Bitcoin Core nodes, causing them to crash, which
could be used as part of other attacks to steal money (e.g., from LN
users).  John Newbery, citing co-discovery by Amiti Uttarwar,
[disclosed][news310 jnau] a vulnerability that could be used to censor
unconfirmed transactions, which could also be used as part of attacks to
steal money (again, an example case being from LN users).  A
vulnerability was [reported][news310 unamed] that allowed consuming
excessive CPU and memory, potentially leading to a node crash.
Developer practicalswift [discovered][news310 ps] a vulnerability that
could cause a node to ignore legitimate blocks for a period of time,
delaying reaction to time-sensitive events that could affect contract
protocols like LN.  Developer sec.eine [disclosude][news310 sec.eine] a
vulnerability that could consume excessive CPU, which could be used to
prevent a node from processing new blocks and transactions, potentially
leading to multiple problems that could lead to loss of money.  John
Newbery responsibly [disclosed][news310 jn1] another vulnerability that
could exhaust the memory of many nodes, potentially leading to crashes.
Cory Fields [discovered][news310 cf] a separate memory exhaustion
vulnerability that could crash Bitcoin Core.  John Newbery
[disclosed][news310 jn2] a third vulnerability that could waste
bandwidth and limit a user's number of peer connection slots.  Michael
Ford [reported][news310 mf] a memory exhaustion vulnerability affecting
anyone who clicked on a [BIP72][] URL, which could crash a node.

More disclosures from Bitcoin Core followed in the subsequent months.
Eugene Siegel [discovered][news314 es] a method for crashing Bitcoin
Core using `addr` messages.   Michael Ford, investigating a report by
Ronald Huveneers about the miniupnpc library, discovered a different
method for crashing Bitcoin Core using local network connections.  David
Jaenson, Braydon Fuller, and multiple Bitcoin Core developers
[discovered][news322 checkpoint] a vulnerability that could be used to
prevent a newly started full node from syncing to the best block chain;
the vulnerability was eliminated with a post-merge bug fix by Niklas
Gögge.  Another remote crash vulnerability was [discovered][news324 ng]
by Niklas Gögge, exploiting a problem with compact block message
handling.  Several users [reported][news324 b10caj] excessive CPU
consumption, leading developers 0xB10C and Anthony Towns to investigate
the cause and implement a solution.  Several developers, including
William Casarin and ghost43, reported problems with their nodes, leading
to Suhas Daftuar [isolating][news324 sd] a vulnerability that could
prevent Bitcoin Core from accepting a block for a long time.  The final
Bitcoin Core vulnerability [report][news328 multi] of the year described
a method for delaying blocks by 10 or more minutes.

Lloyd Fournier, Nick Farrow, and Robin Linus [announced Dark
Skippy][news315 exfil], an improved method for key exfiltration from a
Bitcoin signing device which they previously responsibly disclosed to
approximately 15 different hardware signing device vendors. _Key
exfiltration_ occurs when transaction signing code deliberately creates
its signatures in such a way that they leak information about the
underlying key material, such as a private key or a BIP32 HD wallet
seed. Once an attacker obtains a user’s seed, they can steal any of the
user’s funds at any time (including funds spent in the transaction that
results in exfiltration, if the attacker acts quickly).  This led to
[renewed discussion][news317 exfil] of [anti-exfiltration signing
protocols][topic exfiltration-resistant signing].

The introduction of a new testnet also saw the introduction of a [new
timewarp vulnerability][news316 timewarp].  Testnet4 included a fix for
the original [time warp][topic time warp] vulnerability, but developer
Zawy discovered in August a new exploit that could reduce difficulty by
about 94%.  Mark “Murch” Erhardt further developed the attack to allow
reducing difficulty to its minimum value.  Several solutions were
proposed and tradeoffs between them were still being [discussed][news332
ccsf] in December.

![Illustration of new timewarp vulnerability](/img/posts/2024-time-warp/new-time-warp.png)

In October, Antoine Poinsot and Niklas Gögge disclosed another [consensus
failure vulnerability][news324 btcd] affecting the btcd full node.
Since the original version of Bitcoin, it has contained an obscure (but
critical) function used to extract signatures from scripts before
hashing them.  The implementation in btcd differed slightly from
original version inherited by Bitcoin Core, making it possible for an
attacker to create transactions that would be accepted by one node but
rejected by the other, which could be used in various ways to cause
users to lose money.

December saw David Harding [disclosed][news333 if] a vulnerability
affecting the Eclair, LDK, and LND by default (and Core Lightning with
non-default settings).  The party who requested to open a channel
(opener) and who was responsible for paying any [endogenous fees][topic
fee sourcing] necessary to close the channel could commit to paying 98%
of channel value to fees in one state, reduce the commitment to a
minimal amount in a subsequent state, move 99% of channel value to the
other party, and then close the channel in the 98%-fee state.  This
would result in the opener forfeiting 1% of channel value for using an
old state but the other party losing 98% of value.  If the opener mined
the transaction themselves, they could keep the 98% of value paid to
fees.  This method would allow robbing about 3,000 channels per block.

A deanonymization [vulnerability][news333 deanon] affecting Wasabi and
related software was the final disclosure summarized by Optech this
year.  The vulnerability allows a [coinjoin][topic coinjoin] coordinator
of the type used by Wasabi and GingerWallet to provide users with
credentials that are supposed to be anonymous but which can be made
distinct to allow tracking.  Although one method of making credentials
distinct has been eliminated, a more generalized problem allowing a
coordinator to produce distinct credentials was identified in 2021 by
Yuval Kogman and remains unfixed as of this writing.

</div>

## March

Ongoing problems getting BIPs merged led to the creation in January of a
[new BINANA repository][news286 binana] for specifications and other
documentation.  February and March saw the existing BIPs editor request
help and the beginning of a [process to add new editors][news292 bips].
After extensive public discussion culminating in April, several Bitcoin
contributors were [made BIP editors][news299 bips].

<!-- FIXME
- https://bitcoinops.org/en/newsletters/2024/03/06/#bitcoin-core-29412
- BIPs https://bitcoinops.org/en/newsletters/2024/09/27/#draft-of-updated-bip-process
-->

Abubakar Sadiq Ismail proposed [enhancing Bitcoin Core's feerate
estimation][news295 fees] by using real-time mempool data. Currently,
estimates rely on confirmed transaction data, which updates slowly but
resists manipulation. Ismail developed preliminary code comparing the
current approach with a new mempool-based algorithm. Discussions
highlighted whether mempool data should adjust estimates up and down or
only lower them. Dual adjustment improves utility, but limiting
adjustments to lowering estimates may better prevent manipulation.

Martin Habovštiak proposed a method to [boost unrelated transaction
priorities][news295 sponsor] using the taproot annex, significantly
reducing space requirements compared to earlier [fee sponsorship][topic
fee sponsorship] methods.  David Harding suggested an even more
efficient approach using signature commitment messages, requiring no
on-chain space but relying on block ordering. For overlapping sponsor
transactions, Harding and Anthony Towns proposed alternatives that use
as little as 0.5 vbytes per boost.  Towns noted that these sponsorship
methods are compatible with the proposed [cluster mempool][topic cluster
mempool] design, although the most efficient versions present mild
challenges for transaction validity caching by making it harder for
nodes to precompute and store validity information.  This sponsorship
approach enables dynamic fee bumping at minimal cost, making it
attractive for protocols needing [exogenous fees][topic fee sourcing],
though trustless outsourcing remains an issue. Suhas Daftuar cautioned
that sponsorship could create problems for non-participating users,
suggesting it be opt-in if adopted to avoid unintended impacts.

## April

Antoine Poinsot [revisited][news296 ccsf] Matt Corallo's 2019 consensus
cleanup proposal, addressing issues like slow block verification, time
warp attacks allowing theft, and fake transaction vulnerabilities
affecting light clients and full nodes. Poinsot also highlighted the
duplicate transactions problem set to impact full nodes at block
1,983,702. All issues have soft-fork solutions, though one proposed fix
for slow-verification blocks faced concerns over potentially
invalidating rare presigned transactions.  FIXME:later discussion

<!-- FIXME
- https://bitcoinops.org/en/newsletters/2024/09/06/#mitigating-merkle-tree-vulnerabilities
- https://bitcoinops.org/en/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
-->

A spin off of the discussion about adding new BIPs editor saw a desire
to [reform BIP2][news297 bips], which specifies the current process for adding new
BIPs and updating existing BIPs.  FIXME:later developments

<!-- FIXME
- BIPs https://bitcoinops.org/en/newsletters/2024/05/17/#continued-discussion-about-updating-bip2
-->

LND introduced [support for inbound routing fees][news297 inbound],
championed by Joost Jager, which allows nodes to charge channel-specific
fees for payments received from peers.  This helps nodes manage
liquidity, such as charging higher fees for inbound payments from poorly
managed nodes and lower fees for reliable nodes.  Inbound fees are
backward-compatible, initially set negative (e.g., discounts) to work
with older nodes.  Although proposed years ago, other LN implementations
have resisted the feature, citing design concerns and compatibility
issues.  The feature saw continued development in LND throughout the
year.

Greg Sanders proposed [using weak blocks][news299 weakblocks]---blocks
with insufficient proof-of-work (PoW) but valid transactions---to
improve [compact block relay][topic compact block relay] amid divergent
transaction relay and mining policies. Miners naturally produce weak
blocks proportional to their PoW percentage, reflecting transactions
they attempt to mine. Weak blocks resist abuse due to high creation
costs, allowing mempools and caches to be updated without allowing
excessive bandwidth waste. This could ensure compact block relay remains
effective even when miners include non-standard transactions in blocks.
Weak blocks could also address [pinning attacks][topic transaction
pinning] and enhance [feerate estimation][topic fee estimation].
Sanders's proof-of-concept implementation demonstrates the idea.

Jameson Lopp started a discussion in April about problems with the
current public Bitcoin testnet (testnet3) and suggested [restarting
it][news297 testnet], potentially with a different set of special-case
consensus rules. FIXME:later

<!-- FIXME
- TESTNET https://bitcoinops.org/en/newsletters/2024/06/07/#bip-and-experimental-implementation-of-testnet4
- TESTNET https://bitcoinops.org/en/newsletters/2024/08/09/#bitcoin-core-29775
- TESTNET https://bitcoinops.org/en/newsletters/2024/08/09/#bips-1601

- https://bitcoinops.org/en/newsletters/2024/04/10/#dsl-for-experimenting-with-contracts
- https://bitcoinops.org/en/newsletters/2024/05/01/#analyzing-a-contract-protocol-with-alloy
-->

April came to an unfortunately close with news of the [arrest of two
Bitcoin developers][news300 arrest] focused on privacy software, along with at least
two other companies announcing their intention to stop serving U.S.
customers due to the legal risks.

<div markdown="1" class="callout" id="cluster">
## Summary 2024: Cluster mempool

An idea for a [mempool redesign][news251 cluster] from 2023 became a
particular focus for several Bitcoin Core developers throughout 2024.
Cluster mempool makes it much easier to reason about the effect of
transactions on all the blocks a miner would create if it has an
identical mempool to the local node’s mempool.  This can make
transaction eviction more rational and help in determining whether a
[replacement transaction][topic rbf] (or set of transactions) is better
than the transactions it replaces.  This can help various address
mempool limitations that are implicated in multiple problems affecting
contract protocols such as LN (including sometimes putting funds at
risk).

Additionally, as seen in a January post by Abubakar Sadiq Ismail, the
tools and insights from the design of cluster mempool may allow
[improving fee estimation in Bitcoin Core][news283 fees].  Today,
Bitcoin Core implements ancestor feerate mining as an incentive
compatible way to support [CPFP fee bumping][topic cpfp], but fee
estimation operates on individual transactions, so CPFP fee bumps aren't
considered.  Cluster mempool divides groups of transactions into chunks
that can be tracked together in the mempool and then potentially located
within mined blocks, allowing improved fee estimation (especially if
there is increased use of CPFP-related technology like [package
relay][topic package relay], [P2A][topic ephemeral anchors], and
[exogenous fee sourcing][topic fee sourcing].

As the cluster mempool project matured, multiple explanations and
overviews were made by its architects.  Suhas Daftuar an
[overview][news285 cluster] in January, which revealed one of the
challenges of the proposal: its incompatibility with the existing [CPFP
carve-out][topic cpfp carve out] policy.  A solution to the dilemma
would be for existing users of carve out to opt in to [TRUC
transactions][topic v3 transaction relay], which provides an improved
feature set.  Another [detailed description][news312 cluster] of cluster
mempool was posted in July by Pieter Wuille.  It described fundamental
principles, proposed algorithms, and linked to several pull requests.
[Several][news314 cluster] of [those PRs][news315 cluster] and
[others][news331 cluster] were subsequently merged.

Daftuar engaged in further thinking and research behind cluster mempool
and related proposals like TRUC transactions.  In February, he
[considered][news290 incentive] incentive compatibility of ideas such as
replace-by-feerate, the differing incentives of miners with
disproportionate amounts of hashrate, and looked for incentive compatible
behavior that wasn't DoS resistant.  In April, he [researched][news298
cluster] what would have happened if cluster mempool had been deployed a
year earlier, finding that it allowed slightly more transactions into
the mempool, didn't significantly affect transaction replacement in the
data, and may help miners to capture more fees in the short term.
Pieter Wuille built on the final point in August by describing
principles and an efficient algorithm for [nearly optimal transaction
selection][news314 mine] for miners building blocks.
</div>

## May

Work continued this year on making [silent payments][topic silent
payments] more [broadly accessible][news304 sp].  Josie Baker started a
discussion about PSBT extensions for silent payments (SPs), based on a
draft specification by Andrew Toth.  That discussion was continued into
June with the discussion of [using ECDH shares for trustless
coordination][news308 sp].  Separately, Setor Blagogee posted a draft
specification for a protocol to [help lightweight clients receive silent
payments][news305 splite].

<!-- FIXME
- https://bitcoinops.org/en/newsletters/2024/06/28/#bips-1620
- SP https://bitcoinops.org/en/newsletters/2024/10/25/#draft-bip-for-sending-silent-payments-with-psbts
- SP https://bitcoinops.org/en/newsletters/2024/11/01/#draft-bip-for-dleq-proofs

- PSUEDO-COVENANT https://bitcoinops.org/en/newsletters/2024/05/08/#consensus-enforced-lamport-signatures-on-top-of-ecdsa-signatures
- https://bitcoinops.org/en/newsletters/2024/05/15/#release-of-utreexod-beta
- ACC https://bitcoinops.org/en/newsletters/2024/05/17/#alternative-to-bitvm

- https://bitcoinops.org/en/newsletters/2024/05/17/#anonymous-usage-tokens
- https://bitcoinops.org/en/newsletters/2024/09/20/#proving-utxo-set-inclusion-in-zero-knowledge

- LN UP: https://bitcoinops.org/en/newsletters/2024/05/24/#upgrading-existing-ln-channels
- LN UP: https://bitcoinops.org/en/newsletters/2024/06/28/#bolts-869
- LN UP: https://bitcoinops.org/en/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal

- https://bitcoinops.org/en/newsletters/2024/05/24/#challenges-in-rewarding-pool-miners
- https://bitcoinops.org/en/newsletters/2024/05/24/#proposed-miniscript-bip
-->

## June

René Pickhardt researched estimating the [likelihood of LN payment
feasibility][news309 feas] by analyzing possible wealth distributions
within channel capacities. For example, if Alice wants to send 1 BTC to
Carol via Bob, the likelihood depends on whether the Alice-Bob and
Bob-Carol channels can support the transfer. This metric highlights
practical payment constraints and could help wallets and business
software make smarter routing decisions, improving success rates for LN
payments. FIXME:later developments

<!-- FIXME
- https://bitcoinops.org/en/newsletters/2024/12/13/#insights-into-channel-depletion

- https://bitcoinops.org/en/newsletters/2024/06/14/#draft-bip-for-quantum-safe-address-format
-->

<div markdown="1" class="callout" id="p2prelay">
## Summary 2024: P2P transaction relay

Fee management has always been a challenge in the decentralized Bitcoin
protocol, but widespread use of contract protocols such as LN-Penalty
and ongoing research into newer and more complex protocols has made it
more important than ever to ensure users can pay and increase fees on
demand.  Bitcoin Core contributors have been working on this problem for
years, and 2024 saw the public release of several new features that
significantly improve the situation.

January began with discussion of a [discussion][news283 trucpin] of the
worst-case [pinning][topic transaction pinning] costs for the
[TRUC][topic v3 transaction relay] proposal that provides a more robust
alternative to the previously deployed [CPFP carve-out][topic cpfp
carve out] policy.  Although the worst-case costs are much lower for
TRUC, developers considered whether tweaking a few parameters might be
able to lower costs further.  Another [discussion][news284 exo] in
January examined the theoretical risk that increased use of [exogenous
fee sourcing][topic fee sourcing] would make it more efficient onchain
(and thus cheaper) to use [out-of-band fee payments][topic out-of-band
fees] to miners, which puts mining decentralization at risk.  Peter Todd
suggested addressing this concern with an alternative fee management
method: keep fees entirely endogenous by presigning multiple variations
of each settlement transactions at varying feerates.  However, multiple
problems were identified with this approach.

Additional discussion in January by Gregory Sanders [looked][news285
mev] at whether there was any risk of the LN protocol putting [trimmed
HTLC][topic trimmed htlc] value into [P2A][topic ephemeral anchors]
outputs, which would potentially allow _miner extractable value_ (MEV)
for miners who ran special software beyond what was necessary to mine
mempool transactions.  Bastien Teinturier started a [discussion][news286
lntruc] about what changes would be necessary to the LN protocol to
handle commitment transactions that used TRUC and P2A outputs; this
included the trimmed HTLC proposal considered by Sanders, eliminating
no-longer-necessary one-block delays, and a reduction in onchain
transaction size.  The discussion also led to an [imbued TRUC][news286
imtruc] proposal that would automatically apply TRUC rules to
transactions that looked like LN's existing use of CPFP carve-out,
providing the benefits of TRUC without LN software needing to upgrade.

January came to an end with a [proposal][news287 sibrbf] by Gloria Zhao
for [sibling replace by fee][topic kindred rbf].  The normal [RBF][topic
rbf] rules only apply to conflicting transactions where a node only
accepts one version of the transaction into its mempool because only one
version is permitted to exist in a valid blockchain.  However, in TRUC a
node only accepts one descendant of an unconfirmed version 3 parent
transaction, a very similar situation to a conflicting transaction.
Allowing one descendant to replace another descendant of the same
transaction, _sibling eviction_, would improve fee bumping of TRUC
transaction and be especially beneficial if imbued TRUC were to be
adopted.

February began with additional discussions of the consequences of moving
the LN protocol from CPFP carve-out to TRUC.  Matt Corallo found
[challenges][news288 truc0c] in adapting existing [zero-conf channel
opens][topic zero-conf channels] to using TRUC due to both the funding
transaction and an immediate close transaction potentially both being
unconfirmed, preventing a third transaction containing a CPFP fee bump
from being used due to TRUC's limit of two unconfirmed transactions.
Teinturier identified a similar problem if a chain of [splices][topic
splicing] was used.  The discussion never reached a clear conclusion,
but a workaround solution of ensuring each transaction contained its own
anchor for CPFP fee bumping (as is required before TRUC) seemed
satisfactory, with everyone hoping that [cluster mempool][topic cluster
mempool] could allow relaxing some TRUC rules in the future to allow
more flexible CPFP fee bumping.

On the topic of TRUC policy changes powered by cluster mempool
advancements, Gregory Sanders described several ideas for [future policy
changes][news289 pcmtruc].  By contrast, Suhas Daftuar
[analyzed][news289 oldtruc] all transactions received by his node from
the prior year to see how an imbued TRUC policy would have affected the
acceptance of those transactions.  Most transactions that were
previously accepted under the CPFP carve-out policy would also have been
accepted under an imbued TRUC policy, but there were a few exceptions
that might require changes to software before an imbued policy could be
adopted.

After the flurry of discussion early in the year, May and June saw a
series of merges adding support for new relay features to Bitcoin Core.
A [limited form][news301 1p1c] of one-parent-one-child (1p1c) [package
relay][topic package relay] not requiring any changes to the P2P
protocol was added.  A [subsequent merge][news304 bcc30000] increased
the reliability of 1p1c package relay by enhancing Bitcoin Core's orphan
transaction handling.  The specification for TRUC was [merged into the
BIPs repository][news306 bip431] as [BIP431][].  TRUC transactions
became relayable by default with [another merge][news307 bcc29496].
Support was also [added][news309 1p1crbf] for [RBF][topic rbf] of 1p1c
clusters (including TRUC packages).

Two long-term developers wrote [extended criticisms][news313 crittruc]
of TRUC in July, although other developers responded to their concerns.
[Further criticism][news315 crittruc] by the same two developers was
published in August.

Bitcoin Core developers continued working on relay improvements, merging
[support][news315 p2a] for [pay-to-anchors][topic ephemeral anchors]
(P2A) in August and releasing Bitcoin Core 28.0 in FIXME:month with
support for 1p1c package relay, TRUC transaction relay, package RBF and
sibling replacement, and a standard P2A output script type.  Gregory
Sanders, who contributed to the development of all those features,
[described][news324 guide] how developers of wallets and other software
that uses Bitcoin Core to create or broadcast transactions can take
advantage of the new capabilities.

Later in the year, support for [emphemeral dust][topic ephemeral
anchors] outputs using P2A were made standard in a [merge][news330
dust].  This allows a transaction paying zero fee to be bumped by a
child transaction paying all the relevant fee---a type of purely
[exogenous fee sourcing][topic fee sourcing].

Optech's final regular newsletter for the year summarized a Bitcoin Core
PR Review Club [meeting][news333 prclub] that discussed further
improvements for 1p1c package relay.
</div>

## July

Elle Mouton proposed a BLIP to [add a blinded path field to
BOLT11][news310 path] invoices, allowing payment recipients to hide
their node identity and channel peers. For example, Bob could add a
blinded path to his invoice, enabling Alice to pay privately if her
software supports it; otherwise, she would receive an error. Mouton sees
this as a temporary solution until [offers][topic offers], which
natively support blinded paths, are widely adopted.

<!-- FIXME
- blinded path invoice: https://bitcoinops.org/en/newsletters/2024/08/23/#blips-39
-->

Tim Ruffing and Jonas Nick proposed ChillDKG, a BIP draft and reference
implementation for [securely generating keys for FROST-style scriptless
threshold signatures][news312 chilldkg] compatible with Bitcoin’s schnorr signatures.
ChillDKG combines a well-known key generation algorithm for FROST with
modern cryptographic primitives to securely share random key components
among participants while ensuring integrity and non-censorship. It uses
elliptic curve Diffie-Hellman (ECDH) for encryption and authenticated
broadcast for verifying signed session transcripts. Participants confirm
session integrity before accepting the final public key. This protocol
simplifies key management, requiring users to back up only their private
seed and some non-sensitive recovery data. Plans to encrypt recovery
data using the seed aim to enhance privacy and further simplify user
backups.

<!-- FIXME
- threshold BIP: https://bitcoinops.org/en/newsletters/2024/08/09/#proposed-bip-for-scriptless-threshold-signatures
- MUSIG https://bitcoinops.org/en/newsletters/2024/07/05/#bips-1540

- meh, LSP https://bitcoinops.org/en/newsletters/2024/07/19/#blips-25
- meh https://bitcoinops.org/en/newsletters/2024/07/19/#bips-1599
-->

## August

<!-- FIXME
- https://bitcoinops.org/en/newsletters/2024/08/02/#hyperion-network-event-simulator-for-the-bitcoin-p2p-network
- https://bitcoinops.org/en/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
- https://bitcoinops.org/en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
- https://bitcoinops.org/en/newsletters/2024/08/09/#bitcoin-core-30493
- https://bitcoinops.org/en/newsletters/2024/08/16/#onion-message-dos-risk-discussion
- https://bitcoinops.org/en/newsletters/2024/08/16/#optional-identification-and-authentication-of-ln-payers
- CMAKE https://bitcoinops.org/en/newsletters/2024/08/16/#bitcoin-core-switch-to-cmake-build-system
- CMAKE https://bitcoinops.org/en/newsletters/2024/09/06/#bitcoin-core-30454
- ASK RENE: https://bitcoinops.org/en/newsletters/2024/08/16/#core-lightning-7517
- https://bitcoinops.org/en/newsletters/2024/08/23/#simple-but-imperfect-anti-exfiltration-protocol
-->

<div markdown="1" class="callout" id="covs">
## 2024 summary: Covenants and script upgrades

Several developers devoted a large amount of their time in 2024 towards
advancing proposals for [covenants][topic covenants], scripting
upgrades, and other changes that would support advanced contract
protocols such as [joinpools][topic joinpools] and [channel
factories][topic channel factories].

In late December 2023, Johan Torås Halseth [announced][news283 elftrace]
a a proof of concept program that can use the `OP_CHECKCONTRACTVERIFY`
opcode from the [MATT][topic acc] soft fork proposal to allow a party in a
contract protocol to claim money if an arbitrary program executed
successfully. It is similar in concept to [BitVM][topic acc] but simpler
in its Bitcoin implementation due to using an opcode specifically
designed for program execution verification.  Elftrace works with
programs compiled for the RISC-V architecture using Linux’s ELF format;
almost any programmer can easily create programs for that target, making
using elftrace highly accessible.  Halseth provided an update on
Elftrace in August when it gained the [ability][news315 elftracezk] to
verify zero-knowledge proofs in combination with the [OP_CAT][topic
op_cat] opcode.

January saw the [announcement][news285 lnhance] of the LNHANCE
combination soft fork proposal that includes previous proposals for
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) and
[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) along with a
new proposal for an `OP_INTERNALKEY` that places the taproot internal
key on the stack.  Later in the year the proposal would be
[updated][news330 paircommit] to also include an `OP_PAIRCOMMIT` opcode
that provides a capability that's similar to `OP_CAT` but deliberately
limited in its composability.  The proposal aims to allow deployment of
[LN-Symmetry][topic eltoo], [Ark][topic ark]-style joinpools,
reduced-signature [DLCs][topic dlc], and [vaults][topic vaults], among
other described benefits of the underlying proposals, such as CTV-style
congestion control and CSFS-style signature delegation.

Chris Stewart [posted][news285 64bit] a draft BIP for enabling 64-bit
arithmetic operations on Bitcoin in a future soft fork. Bitcoin
currently only allows 32-bit operations (using signed integers, so
numbers over 31 bits can’t be used). Support for 64-bit values would be
especially useful in any construction that needs to operate on the
number of satoshis paid in an output, as that is specified using a
64-bit integer.  The proposal received additional discussion in both
[February][news290 64bit] and [June][news306 64bit].

Also in February, developer Rijndael created a [proof-of-concept
implementation][news291 catvault] for a [vault][topic vaults] that only
depends on the current consensus rules plus the proposed [OP_CAT][topic
op_cat] opcode.  Optech compared the `OP_CAT` vault against vaults
possible today with presigned transactions and vaults possible if
[BIP345][] `OP_VAULT` was added to Bitcoin.

<table>
  <tr>
    <th></th>
    <th>Presigned</th>
    <th markdown="span">

    BIP345 `OP_VAULT`

    </th>
    <th markdown="span">

    `OP_CAT` with schnorr

    </th>
  </tr>

  <tr>
    <th>Availability</th>
    <td markdown="span">

    **Now**

    </td>
    <td markdown="span">

    Requires soft fork of `OP_VAULT` and [OP_CTV][topic op_checktemplateverify]

    </td>
    <td markdown="span">

    Requires soft fork of `OP_CAT`

    </td>
  </tr>

  <tr>
    <th markdown="span">Last-minute address replacement attack</th>
    <td markdown="span">Vulnerable</td>
    <td markdown="span">

    **Not vulnerable**

    </td>
    <td markdown="span">

    **Not vulnerable**

    </td>
  </tr>

  <tr>
    <th markdown="span">Partial amount withdrawals</th>
    <td markdown="span">Only if prearranged</td>
    <td markdown="span">

    **Yes**

    </td>
    <td markdown="span">No</td>
  </tr>

  <tr>
    <th markdown="span">Static and non-interactive computable deposit addresses</th>
    <td markdown="span">No</td>
    <td markdown="span">

    **Yes**

    </td>
    <td markdown="span">

    **Yes**

    </td>
  </tr>

  <tr>
    <th markdown="span">Batched re-vaulting/quarantining for fee savings</th>
    <td markdown="span">No</td>
    <td markdown="span">

    **Yes**

    </td>
    <td markdown="span">No</td>
  </tr>

  <tr>
    <th markdown="span">

    Operational efficiency in best case, i.e. only legitimate spends<br>*(only very roughly estimated by Optech)*

    </th>
    <td markdown="span">

    **2x size of regular single-sig**

    </td>
    <td markdown="span">3x size of regular single-sig</td>
    <td markdown="span">4x size of regular single-sig</td>
  </tr>
</table>

In March, developer ZmnSCPxj [described][news293 forkbet] a protocol for
giving control over a UTXO to a party that correctly predicts whether or
not a particular soft fork will activate.  The basic idea has been
proposed before but ZmnSCPxj’s version deals with the specifics expected
for at least one potential future soft fork, [OP_CHECKTEMPLATEVERIFY][topic
op_checktemplateverify].

March also saw Anthony Towns begin working on an alternative scripting
language for Bitcoin based on the Lisp language.  He provided an
[overview][news293 chialisp] of the Lisp-style language already used by the Chia altcoin
and [proposed][news294 btclisp] a BTC Lisp language.  Later in the year,
inspired by the relationship between Bitcoin Script and [miniscript][topic
miniscript], he [split][news331 bll] his Lisp project into two parts: a
low-level bitcoin lisp language (bll) that could be added to Bitcoin in
a soft fork and a symbolic bll (symbll) high-level language that is
converted into bll.  He also [described][news331 earmarks] a generic
construction compatible with symbll (and probably [Simplicity][topic
simplicity]) that allows partitioning a UTXO into specific amounts and
spending conditions.   He showed how these _flexible coin earmarks_ can
be used, including improvements in the security and usability of LN
channels (including [LN-Symmetry][topic eltoo]-based channels), an
alternative to the [BIP345][] version of vaults, and a [payment
pool][topic joinpools] design.

Jeremy Rubin proposed [two updates][news302 ctvext] to the
`OP_CHECKTEMPLATEVERIFY` design in May: optional support for a shorter
hash digest and support for additional commitments.  These helped
optimize CTV for use in certain data publication schemes that might be
useful for recovering critical data in [LN-Symmetry][topic eltoo] and
similar protocols.

Pierre Rochard [asked][news305 overlap] if proposed soft forks that can provide much of the
same features at a similar cost should be considered mutually exclusive,
or whether it would make sense to activate multiple proposals and let
developers use whichever alternative they prefer.

Jeremy Rubin [published][news306 fecov] a paper about theoretically
using functional encryption to add a full range of covenant behavior to
Bitcoin with no required consensus changes.  In essence, functional
encryption would allow the creation of a public key that would
correspond to a particular program. A party who could satisfy the
program would be able to create a signature that corresponded to the
public key (without ever learning a corresponding private key).  This is
always more private and will often save space compared to previously
proposed covenants.  Unfortunately, a major downside of functional
encryption according to Rubin is that it is "under-developed
cryptography that makes it impractical to use presently".

Anthony Towns posted a [script][news306 catfaucet] for [signet][topic
signet] that uses [OP_CAT][topic op_cat] to allow anyone to spend coins
sent to the script using proof of work (PoW). This can be used as a
decentralized signet-bitcoin faucet: when a miner or a user obtains
excess signet bitcoins, they send them to the script. When a user wants
more signet bitcoins, they search the UTXO set for payments to the
script, generate PoW, and create a transaction that uses their PoW to
claim the coins.

Victor Kolobov [announced][news319 catmillion] a $1 million fund for
research into a proposed soft fork to add an `OP_CAT` opcode.
Submissions must be received by 1 January 2025.

In November, Towns [summarized][news330 sigactivity] activity on the
default signet related to proposed soft forks available through Bitcoin
Inquisition.  Vojtěch Strnad was inspired by Towns's post and created a
website that lists “every transaction made on the Bitcoin signet that
uses one of the deployed soft forks.”

Ethan Heilman [posted][news330 covgrind] a paper he coauthored with
Victor Kolobov, Avihu Levy, and Andrew Poelstra about how covenants can
be created easily without consensus changes, although spending from
those covenants would require non-standard transactions and millions (or
billions) of dollars worth of specialized hardware and electricity.
Heilman notes that one application of the work is allowing users today
to easily include a backup taproot spending path that can be securely
used if quantum resistance is suddenly needed and elliptic curve
signature operations on Bitcoin are disabled.

December concluded with a [poll of developer opinions][news333 covpoll]
about selected covenant proposals.

_Starting in January 2025, Optech will begin summarizing notable
research and developments related to covenants, script upgrades, and
related chages in a special section published in the first newsletter of
each month.  We encourage everyone working on these proposals to publish
anything of interest to our usual [sources][optech sources] so that
we write about it._

</div>

## September

Carla Kirk-Cohen described testing and adjustments to a [hybrid channel
jamming mitigation][news322 jam] originally proposed by Clara Shikhelman
and Sergei Tikhomirov.  Attempts to jam a channel for an hour mostly
failed, as attackers either spent more than using known attacks or
unintentionally increased the target’s income.  However, a _sink attack_
was effective by undermining a node's reputation by sabotaging payments
through shorter routes. To counter this, bidirectional reputation was
added to [HTLC endorsement][topic htlc endorsement], bringing the
proposal closer to an idea originally proposed in 2018 by Jim Posen.
Nodes now assess both the sender’s and receiver’s reliability when
deciding to forward payments.  Reliable nodes receive endorsed HTLCs,
while less reliable senders or receivers face rejection or non-endorsed
forwarding.  This testing followed a [specification of HTLC
endorsement][news316 htlce] and an [implementation in Eclair][news315
htlce]; an [implementation for LND][news332 htlce] would also be added
by the end of the year.

Jonas Nick, Liam Eagen, and Robin Linus introduced a new [client-side
validation][topic client-side validation] (CSV) protocol, [Shielded
CSV][news322 csv], which enables token transfers secured by Bitcoin’s
proof-of-work without revealing token details or transfer histories.
Unlike existing protocols, where clients must validate extensive token
histories, Shielded CSV uses zero-knowledge proofs to ensure
verification requires fixed resources while preserving privacy.
Additionally, Shielded CSV reduces on-chain data requirements by
bundling thousands of token transfers into a single 64-byte update per
Bitcoin transaction, enhancing scalability. The paper explores trustless
Bitcoin-to-CSV bridging via [BitVM][topic acc], account-based
structures, handling blockchain reorganizations, unconfirmed
transactions, and potential extensions. This protocol promises
significant efficiency and privacy improvements over other token
systems.

Andy Schroder outlined a process for [enabling LN offline
payments][news321 lnoff] by generating authentication tokens while
online, allowing the spender's wallet to authorize payments through her
always-online node or LSP when offline. Tokens can be transferred to the
receiver via NFC or other simple protocols, enabling payments without
internet access. Developer ZmnSCPxj proposed an alternative, and Bastien
Teinturier referenced his remote node control method for similar use
cases, enhancing offline payment solutions for limited-resource devices
like smart cards.

## October

The [BOLT12][] specification of [offers][topic offers] was
[merged][news323 offers].  [Originally proposed][news72 offers] in 2019,
offers allows two nodes to negotiate invoices and payments over LN using
[onion messages][topic onion messages].  Both onion messages and
offer-compatible payments can use [blinded paths][topic rv routing]
to prevent the spender from learning the identity of the receiver's
node.

A [new mining interface][news325 mining] for Bitcoin Core saw
development with the goal to support miners using the [Stratum v2][topic
pooled mining] protocol that can be set to allow each miner to select
their own transactions.  However, Anthony Towns noted earlier in the
year that independent transaction selection could [raise share validation
costs][news315 shares] for mining pools.  If those pools responded by
limiting validation, it could allow a invalid shares attack that's
similar to the well-known [block withholding attack][topic block
withholding].  A 2011 proposed solution to withholding attacks was
discussed, although it would require a challenging consensus change.

<!-- FIXME
- meh, on-the-fly funding:
  https://bitcoinops.org/en/newsletters/2024/10/04/#eclair-2861
- meh, on-the-fly funding:
  https://bitcoinops.org/en/newsletters/2024/10/04/#eclair-2875

-->

<div markdown="1" class="callout" id="releases">

### Summary 2024: Major releases of popular infrastructure projects

FIXME:harding

</div>

## November

ZmnSCPxj proposed the [SuperScalar design][news327 superscalar] for a
[channel factory][topic channel factories] design using [timeout
trees][topic timeout trees] to enable LN users to open channels and
access liquidity more affordably while maintaining trustlessness. The
design uses a layered timeout tree that requires the service provider
pay any costs of putting the tree onchain or lose any funds remaining in
the tree.  This encourages the service provider to incentivize users to
cooperatively close their channels to avoid the need to go onchain.  The
design uses both [duplex micropayment channels][topic duplex
micropayment channels] and [LN-Penalty][topic ln-penalty] payment
channels, both of which are possible without any consensus changes.
Despite its complexity---combining multiple channel types and managing
offchain state---the design can be implemented by a single vendor
without requiring major protocol changes.  To support the design,
ZmnSCPxj later proposed a [pluggable channel factory tweak][news330
plug] to the LN specification.

<!-- FIXME
- https://bitcoinops.org/en/newsletters/2024/11/15/#mad-based-offchain-payment-resolution-opr-protocol

- https://bitcoinops.org/en/newsletters/2024/11/29/#lisp-dialect-for-bitcoin-scripting
- splice:
  https://bitcoinops.org/en/newsletters/2024/11/29/#core-lightning-7719
  -->

<div markdown="1" class="callout" id="optech">
## Summary 2024: Bitcoin Optech

In Optech's seventh year, we published 51 weekly [newsletters][] and
added 35 new pages to our [topics index][].  Altogether, Optech
published over 120,000 English words about Bitcoin software research and
development this year, the rough equivalent of a 350-page book.

In addition, every newsletter this year was accompanied by a [podcast][]
episode, totaling over FIXME:n hours in audio form and 488,000 words in
transcript form.  Many of Bitcoin's top contributors were guests on the
show---some of them on more than one episode---with a total of FIXME:n
different unique guests in 2024:

- FIXME:names

</div>

## December

FIXME:harding

*We thank all of the Bitcoin contributors named above, plus the many
others whose work was just as important, for another incredible year of
Bitcoin development.  The Optech newsletter will return to its regular
Wednesday publication schedule on January 3rd.*

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
  flex: 1 0 180px;
  max-width: 180px;
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

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %} {% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /en/newsletters/2021/12/22/
[yirs 2022]: /en/newsletters/2022/12/21/
[yirs 2023]: /en/newsletters/2023/12/20/
[news283 feelocks]: /en/newsletters/2024/01/03/#fee-dependent-timelocks
[news283 exits]: /en/newsletters/2024/01/03/#pool-exit-payment-batching-with-delegation-using-fraud-proofs
[news284 lnsym]: /en/newsletters/2024/01/10/#ln-symmetry-research-implementation
[news288 rbfr]: /en/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[news290 dns]: /en/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-instructions
[news290 asmap]: /en/newsletters/2024/02/21/#improved-reproducible-asmap-creation-process
[news290 dualfund]: /en/newsletters/2024/02/21/#bolts-851
[news291 bets]: /en/newsletters/2024/02/28/#trustless-contract-for-miner-feerate-futures
[news295 fees]: /en/newsletters/2024/03/27/#mempool-based-feerate-estimation
[news295 sponsor]: /en/newsletters/2024/03/27/#transaction-fee-sponsorship-improvements
[news286 binana]: /en/newsletters/2024/01/24/#new-documentation-repository
[news292 bips]: /en/newsletters/2024/03/06/#discussion-about-adding-more-bip-editors
[news296 ccsf]: /en/newsletters/2024/04/03/#revisiting-consensus-cleanup
[news299 bips]: /en/newsletters/2024/04/24/#bip-editors-update
[news297 bips]: /en/newsletters/2024/04/10/#updating-bip2
[news297 inbound]: /en/newsletters/2024/04/10/#lnd-6703
[news299 weakblocks]: /en/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation
[news297 testnet]: /en/newsletters/2024/04/10/#discussion-about-resetting-and-modifying-testnet
[news300 arrest]: /en/newsletters/2024/05/01/#arrests-of-bitcoin-developers
[news308 sp]: /en/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments
[news304 sp]: /en/newsletters/2024/05/24/#discussion-about-psbts-for-silent-payments
[news305 splite]: /en/newsletters/2024/05/31/#light-client-protocol-for-silent-payments
[news309 feas]: /en/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible
[news310 path]: /en/newsletters/2024/07/05/#adding-a-bolt11-invoice-field-for-blinded-paths
[news312 chilldkg]: /en/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[news315 htlce]: /en/newsletters/2024/08/09/#eclair-2884
[news316 htlce]: /en/newsletters/2024/08/16/#blips-27
[news322 jam]: /en/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[news332 htlce]: /en/newsletters/2024/12/06/#lnd-8390
[news322 csv]: /en/newsletters/2024/09/27/#shielded-client-side-validation-csv
[news321 lnoff]: /en/newsletters/2024/09/20/#ln-offline-payments
[news323 offers]: /en/newsletters/2024/10/04/#bolts-798
[news72 offers]: /en/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[news324 guide]: /en/newsletters/2024/10/11/#guide-for-wallets-employing-bitcoin-core-28-0
[news315 shares]: /en/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[news327 superscalar]: /en/newsletters/2024/11/01/#timeout-tree-channel-factories
[news330 plug]: /en/newsletters/2024/11/22/#pluggable-channel-factories
[news283 lndvuln]: /en/newsletters/2024/01/03/#disclosure-of-past-lnd-vulnerabilities
[news285 clnvuln]: /en/newsletters/2024/01/17/#disclosure-of-past-vulnerability-in-core-lightning
[news286 btcdvuln]: /en/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd
[news288 bccvuln]: /en/newsletters/2024/02/07/#public-disclosure-of-a-block-stalling-bug-in-bitcoin-core-affecting-ln
[news308 lndvuln]: /en/newsletters/2024/06/21/#disclosure-of-vulnerability-affecting-old-versions-of-lnd
[news310 wlad]: /en/newsletters/2024/07/05/#remote-code-execution-due-to-bug-in-miniupnpc
[news310 ek]: /en/newsletters/2024/07/05/#node-crash-dos-from-multiple-peers-with-large-messages
[news310 jnau]: /en/newsletters/2024/07/05/#censorship-of-unconfirmed-transactions
[news310 unamed]: /en/newsletters/2024/07/05/#unbound-ban-list-cpu-memory-dos
[news310 ps]: /en/newsletters/2024/07/05/#netsplit-from-excessive-time-adjustment
[news310 sec.eine]: /en/newsletters/2024/07/05/#cpu-dos-and-node-stalling-from-orphan-handling
[news310 jn1]: /en/newsletters/2024/07/05/#memory-dos-from-large-inv-messages
[news310 cf]: /en/newsletters/2024/07/05/#memory-dos-using-low-difficulty-headers
[news310 jn2]: /en/newsletters/2024/07/05/#cpu-wasting-dos-due-to-malformed-requests
[news310 mf]: /en/newsletters/2024/07/05/#memory-related-crash-in-attempts-to-parse-bip72-uris
[news310 disclosures]: /en/newsletters/2024/07/05/#disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-0-21-0
[news314 es]: /en/newsletters/2024/08/02/#remote-crash-by-sending-excessive-addr-messages
[news314 mf]: /en/newsletters/2024/08/02/#remote-crash-on-local-network-when-upnp-enabled
[news322 checkpoint]: /en/newsletters/2024/09/27/#disclosure-of-vulnerability-affecting-bitcoin-core-versions-before-24-0-1
[news324 ng]: /en/newsletters/2024/10/11/#cve-2024-35202-remote-crash-vulnerability
[news324 b10caj]: /en/newsletters/2024/10/11/#dos-from-large-inventory-sets
[news324 sd]: /en/newsletters/2024/10/11/#slow-block-propagation-attack
[news328 multi]: /en/newsletters/2024/11/08/#disclosure-of-a-vulnerability-affecting-bitcoin-core-versions-before-25-1
[news317 exfil]: /en/newsletters/2024/08/23/#simple-but-imperfect-anti-exfiltration-protocol
[news315 exfil]: /en/newsletters/2024/08/09/#faster-seed-exfiltration-attack
[news332 ccsf]: /en/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
[news316 timewarp]: /en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4
[news324 btcd]: /en/newsletters/2024/10/11/#cve-2024-38365-btcd-consensus-failure
[news333 if]: /en/newsletters/2024/12/13/#vulnerability-allowing-theft-from-ln-channels-with-miner-assistance
[news333 deanon]: /en/newsletters/2024/12/13/#deanonymization-vulnerability-affecting-wasabi-and-related-software
[news251 cluster]: /en/newsletters/2023/05/17/#mempool-clustering
[news283 fees]: /en/newsletters/2024/01/03/#cluster-fee-estimation
[news285 cluster]: /en/newsletters/2024/01/17/#overview-of-cluster-mempool-proposal
[news312 cluster]: /en/newsletters/2024/07/19/#introduction-to-cluster-linearization
[news314 cluster]: /en/newsletters/2024/08/02/#bitcoin-core-30126
[news315 cluster]: /en/newsletters/2024/08/09/#bitcoin-core-30285
[news314 mine]: /en/newsletters/2024/08/02/#optimizing-block-building-with-cluster-mempool
[news331 cluster]: /en/newsletters/2024/11/29/#bitcoin-core-31122
[news290 incentive]: /en/newsletters/2024/02/21/#thinking-about-mempool-incentive-compatibility
[news298 cluster]: /en/newsletters/2024/04/17/#what-would-have-happened-if-cluster-mempool-had-been-deployed-a-year-ago
[news283 trucpin]: /en/newsletters/2024/01/03/#v3-transaction-pinning-costs
[news284 exo]: /en/newsletters/2024/01/10/#discussion-about-ln-anchors-and-v3-transaction-relay-proposal
[news285 mev]: /en/newsletters/2024/01/17/#discussion-of-miner-extractable-value-mev-in-non-zero-ephemeral-anchors
[news286 lntruc]: /en/newsletters/2024/01/24/#proposed-changes-to-ln-for-v3-relay-and-ephemeral-anchors
[news286 imtruc]: /en/newsletters/2024/01/24/#imbued-v3-logic
[news287 sibrbf]: /en/newsletters/2024/01/31/#kindred-replace-by-fee
[news288 truc0c]: /en/newsletters/2024/02/07/#securely-opening-zero-conf-channels-with-v3-transactions
[news289 pcmtruc]: /en/newsletters/2024/02/14/#ideas-for-relay-enhancements-after-cluster-mempool-is-deployed
[news289 oldtruc]: /en/newsletters/2024/02/14/#what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago
[news301 1p1c]: /en/newsletters/2024/05/08/#bitcoin-core-28970
[news304 bcc30000]: /en/newsletters/2024/05/24/#bitcoin-core-30000
[news306 bip431]: /en/newsletters/2024/06/07/#bips-1541
[news29496]: /en/newsletters/2024/06/14/#bitcoin-core-29496
[news309 1p1crbf]: /en/newsletters/2024/06/28/#bitcoin-core-28984
[news313 crittruc]: /en/newsletters/2024/07/26/#varied-discussion-of-free-relay-and-fee-bumping-upgrades
[news315 crittruc]: /en/newsletters/2024/08/09/#replacement-cycle-attack-against-pay-to-anchor
[news315 p2a]: /en/newsletters/2024/08/09/#bitcoin-core-30352
[news330 dust]: /en/newsletters/2024/11/22/#bitcoin-core-30239
[news333 prclub]: /en/newsletters/2024/12/13/#bitcoin-core-pr-review-club
[news283 elftrace]: /en/newsletters/2024/01/03/#verification-of-arbitrary-programs-using-proposed-opcode-from-matt
[news285 lnhance]: /en/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed
[news285 64bit]: /en/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork
[news290 64bit]: /en/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode
[news306 64bit]: /en/newsletters/2024/06/07/#updates-to-proposed-soft-fork-for-64-bit-arithmetic
[news291 catvault]: /en/newsletters/2024/02/28/#simple-vault-prototype-using-op-cat
[news293 forkbet]: /en/newsletters/2024/03/13/#trustless-onchain-betting-on-potential-soft-forks
[news294 btclisp]: /en/newsletters/2024/03/20/#overview-of-btc-lisp
[news293 chialisp]: /en/newsletters/2024/03/13/#overview-of-chia-lisp-for-bitcoiners
[news331 bll]: /en/newsletters/2024/11/29/#lisp-dialect-for-bitcoin-scripting
[news331 earmarks]: /en/newsletters/2024/11/29/#flexible-coin-earmarks
[news302 ctvext]: /en/newsletters/2024/05/15/#bip119-extensions-for-smaller-hashes-and-arbitrary-data-commitments
[news305 overlap]: /en/newsletters/2024/05/31/#should-overlapping-soft-fork-proposals-be-considered-mutually-exclusive
[news306 fecov]: /en/newsletters/2024/06/07/#functional-encryption-covenants
[newsletters]: /en/newsletters/
[news306 catfaucet]: /en/newsletters/2024/06/07/#op-cat-script-to-validate-proof-of-work
[topics index]: /en/topics/
[news315 elftracezk]: /en/newsletters/2024/08/09/#optimistic-verification-of-zero-knowledge-proofs-using-cat-matt-and-elftrace
[news319 catmillion]: /en/newsletters/2024/09/06/#op-cat-research-fund
[news330 sigactivity]: /en/newsletters/2024/11/22/#signet-activity-report
[news330 paircommit]: /en/newsletters/2024/11/22/#update-to-lnhance-proposal
[news330 covgrind]: /en/newsletters/2024/11/22/#covenants-based-on-grinding-rather-than-consensus-changes
[news333 covpoll]: /en/newsletters/2024/12/13/#poll-of-opinions-about-covenant-proposals
[news307 bcc29496]: /en/newsletters/2024/06/14/#bitcoin-core-29496
[news325 mining]: /en/newsletters/2024/10/18/#bitcoin-core-30955
[news315 shares]: /en/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
