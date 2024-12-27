---
title: 'Bitcoin Optech Newsletter #334：2024 年度回顾特刊'
permalink: /zh/newsletters/2024/12/20/
name: 2024-12-20-newsletter-zh
slug: 2024-12-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh

excerpt: >
  第 7 篇比特币 Optech 年度回顾，总结了 2024 年比特币的重大发展。

---
{{page.excerpt}} 这是继 [2018][yirs 2018]、[2019][yirs 2019]、[2020][yirs 2020]、[2021][yirs 2021]、[2022][yirs 2022] 和 [2023][yirs 2023] 年度总结之后的又一篇年度回顾。

## Contents

* January
  * [Fee-dependent timelocks](#feetimelocks)
  * [Optimized contract protocol exits](#optimizedexits)
  * [LN-Symmetry proof-of-concept implementation](#poclnsym)
* February
  * [Replace by feerate](#rbfr)
  * [Human-readable payment instructions](#hrpay)
  * [Improved ASMap generation](#asmap)
  * [LN dual funding](#dualfunding)
  * [Trustless betting on future feerates](#betfeerates)
* March
  * [BINANAs and BIPs](#binanabips)
  * [Enhanced feerate estimation](#enhancedfeeestimates)
  * [More efficient transaction sponsorship](#efficientsponsors)
* April
  * [Consensus cleanup](#consensuscleanup)
  * [Reforming the BIPs process](#bip2reform)
  * [Inbound routing fees](#inboundrouting)
  * [Weak blocks](#weakblocks)
  * [Restarting testnet](#testnet)
  * [Developers arrested](#devarrests)
* May
  * [Silent payments](#silentpayments)
  * [BitVMX](#bitvmx)
  * [Anonymous usage tokens](#aut)
  * [LN channel upgrades](#lnup)
  * [Ecash for pool miners](#minecash)
  * [Miniscript specification](#miniscript)
  * [Utreexo beta](#utreexod)
* June
  * [LN payment feasibility and channel depletion](#lnfeasibility)
  * [Quantum-resistant transaction signing](#quantumsign)
* July
  * [Blinded paths for BOLT11 invoices](#bolt11blind)
  * [ChillDKG key generation for threshold signatures](#chilldkg)
  * [BIPs for MuSig and threshold signatures](#musigthresh)
* 八月
  * [Hyperion网络模拟器](#hyperion)
  * [完全 RBF](#fullrbf)
* 九月
  * [混合阻塞攻击缓解测试和调整](#hybridjamming)
  * [暗影 CSV](#shieldedcsv)
  * [闪电网络离线支付](#lnoff)
* 十月
  * [BOLT12 offer](#offers)
  * [挖矿接口、区块扣留和份额验证成本](#pooledmining)
* 十一月
  * [SuperScalar 超时树通道工厂](#superscalar)
  * [快速且低成本的小额链下支付结算](#opr)
* 十二月
* 重点总结
  * [漏洞披露](#vulnreports)
  * [族群交易池](#cluster)
  * [P2P 交易中继](#p2prelay)
  * [限制条款和脚本升级](#covs)
  * [主流基础设施项目的重大版本发布](#releases)
  * [Bitcoin Optech](#optech)

---

## January

{:#feetimelocks}
John Law proposed [fee-dependent timelocks][news283 feelocks], a soft
fork allowing [timelocks][topic timelocks] to expire only when median
block feerates drop below a user-specified level. This prevents high
fees near expiration from preventing confirmation, which can lead to
funds loss.  Instead, the timelock extends until fees
fall to a predetermined value, addressing longstanding concerns of [forced expiration
floods][topic expiration floods] during mass channel closures. The
proposal improves security for multi-user setups like [channel
factories][topic channel factories] and [joinpools][topic joinpools]
while incentivizing participants to avoid fee spikes.  Discussions
included storing parameters in the taproot [annex][topic annex], feerate
commitments for lightweight clients, pruned node support, and the impact
of [out-of-band fees][topic out-of-band fees].

{:#optimizedexits}
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

{:#poclnsym}
Gregory Sanders shared a proof-of-concept [implementation][news284
lnsym] of [LN-Symmetry][topic eltoo] using a fork of Core Lightning.
LN-Symmetry enables bi-directional payment channels without penalty
transactions but relies on a soft fork like [SIGHASH_ANYPREVOUT][topic
sighash_anyprevout] to
allow child transactions to spend any parent version. Sanders
highlighted its simplicity compared to [LN-Penalty][topic ln-penalty],
the difficulty of avoiding [pinning][topic transaction pinning] (inspiring his work on [package
relay][topic package relay] and [ephemeral anchors][topic ephemeral
anchors]), and the potential for faster payments via emulation of
[OP_CTV][topic op_checktemplateverify]. He confirmed penalties are
unnecessary, simplifying channel implementation and avoiding reserved
funds.  However, LN-Symmetry requires longer [CLTV expiry deltas][topic
cltv expiry delta] to prevent misuse.

## February

{:#rbfr}
Peter Todd proposed [Replace by Feerate][news288 rbfr] (RBFr) to address
[transaction pinning][topic transaction pinning] when standard
[RBF][topic rbf] policies fail, with two variations: pure RBFr, allowing
unlimited replacements with much higher feerates (e.g., 2x), and
one-shot RBFr, enabling a single replacement with moderately higher fees
(e.g., 1.25x) if the replacement enters the top of the mempool.
Mark Erhardt identified an initial problem and other developers
discussed the complexities of fully analyzing the idea with available
tools.  Todd released an experimental implementation and other
developers continued working on alternative solutions to address
transaction pinning, including developing the tools necessary to
increase confidence in any solution that is adopted.

{:#hrpay}
Matt Corallo proposed a BIP for DNS-based [human-readable Bitcoin payment
instructions][news290 dns], allowing an email-like string (e.g., example@example.com)
to resolve to a DNSSEC-signed TXT record containing a [BIP21][] URI.
This supports onchain addresses, [silent payments][topic silent
payments], and LN [offers][topic offers]---and can be easily extended to
other payment protocols.  A [specification][news307 bip353] of this was
added as [BIP353][].  Corallo also drafted a [BOLT][news333 dnsbolt] and
[BLIP][news306 dnsblip] for LN nodes, enabling wildcard DNS records and
secure payment resolution using offers.  An [implementation][news329
dnsimp] was merged into LDK in November.  Development of this protocol
and silent payments led Josie Baker to start a [discussion][news292
bip21] about revising [BIP21][] payment URIs, which [continued][news306
bip21] later in the year.

{:#asmap}
Fabian Jahr wrote software that allows multiple developers to
[independently create equivalent ASMaps][news290 asmap], which helps
Bitcoin Core diversify peer connections and resist [eclipse attacks][topic
eclipse attacks].  If Jahr's tooling becomes widely accepted, Bitcoin
Core may include ASMaps by default, enhancing protection against attacks
from parties controlling nodes on multiple subnets.

{:#dualfunding}
[Support][news290 dualfund] for [dual funding][topic dual funding] was
added to the LN specification along with support for the interactive
transaction construction protocol.  Interactive construction allows two
nodes to exchange preferences and UTXO details they can use to
construct a funding transaction together. Dual funding allows a
transaction to include inputs from either or both parties. For example,
Alice may want to open a channel with Bob. Before this specification
change, Alice had to provide all the funding for the channel. Now,
when using an implementation that supports dual funding, Alice can open
a channel with Bob where he provides all of the funding or where
each contributes funds to the initial channel state. This can be combined
with the experimental [liquidity advertisements][topic liquidity
advertisements] protocol, which has not
yet been added to the specification.

{:#betfeerates}
ZmnSCPxj proposed trustless scripts enabling two parties to [bet on
future block feerates][news291 bets].  A user wanting a
transaction confirmed by some future block can use this to offset the
risk that [feerates][topic fee estimation] will be unusually high at the
time.  A miner expecting to mine a block around the time the user needs
their transaction confirmed can use this contract to offset the risk
that feerates will be unusually low.  The design prevents
manipulation seen in centralized markets, as the miner's decisions rely
solely on actual mining conditions.  The contract is trustless with a
cooperative spend path that minimizes costs for both parties.

<div markdown="1" class="callout" id="vulnreports">
## Summary 2024: Vulnerability disclosures

In 2024, Optech summarized more than two dozen vulnerability disclosures.  The
majority were old disclosures from Bitcoin Core which were being
published for the first time this year.  Vulnerability reports give both
developers and users the opportunity to learn from past problems, and
[responsible disclosures][topic responsible disclosures] allow us all to
thank those who report their discoveries with discretion.

_Note: Optech only publishes the names of vulnerability discoverers if
we think they made a reasonable effort to minimize the risk of harm to
users.  We thank all persons named in this section for their insight and
clear concern for user safety._

Late in 2023, Niklas Gögge [publicly disclosed][news283 lndvuln] two
vulnerabilities he had reported two years earlier, leading to
the release of fixed versions of LND.  The first, a DoS vulnerability,
could have led to LND running out of memory and crashing.  The second, a
censorship vulnerability, could allow an attacker to prevent an LND node
from learning about updates to targeted channels across the network; an
attacker could use this to bias a node towards selecting specific routes
for payments it sent, giving the attacker more forwarding fees and more
information about the payments the node sent.

In January, Matt Morehouse [announced a vulnerability][news285 clnvuln]
that affected Core Lightning versions 23.02 through 23.05.2.  When
re-testing nodes that had implemented fixes for fake funding, which he
previously discovered and disclosed, he was able to trigger a race
condition that crashed CLN after about 30 seconds.  If an LN
node is shut down, it can't defend a user against malicious or broken
counterparties, which puts the user's funds at risk.

Also in January, Gögge returned to [announce][news286 btcdvuln] a
consensus failure vulnerability he found in the btcd full node.  The
code could misinterpret a transaction version number and apply the wrong
consensus rules to a transaction using a relative timelock.  This could
prevent btcd full nodes from showing the same confirmed transactions as
Bitcoin Core, putting users at risk of losing money.

February saw Eugene Siegel [publish][news288 bccvuln] a Bitcoin Core vulnerability
report he had initially disclosed almost three years previously.
The vulnerability could be used to prevent
Bitcoin Core from downloading recent blocks.  This could be leveraged to
prevent a connected LN node from learning about preimages necessary to
resolve [HTLCs][topic htlc], potentially leading to loss of money.

Morehouse returned in June to [disclose][news308 lndvuln] a
vulnerability that allowed crashing versions of LND before 0.17.0.  As
mentioned earlier, a shutdown LN node can't defend a user against
malicious or broken counterparties, which puts the user's funds at risk.

July saw the first of [multiple disclosures][news310 disclosures] of
vulnerabilities affecting past versions of Bitcoin Core.  Wladimir J.
Van Der Laan was investigating a vulnerability discovered by Aleksandar
Nikolic in a library used by Bitcoin Core when he [discovered][news310
wlad] a separate vulnerability allowing remote code execution; this was
fixed upstream, and the fix was incorporated into Bitcoin Core.  Developer
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
protocols like LN.  Developer sec.eine [disclosed][news310 sec.eine] a
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
seed. Once an attacker obtains a user's seed, they can steal any of the
user's funds at any time (including funds spent in the transaction that
results in exfiltration, if the attacker acts quickly).  This led to
[renewed discussion][news317 exfil] of [anti-exfiltration signing
protocols][topic exfiltration-resistant signing].

The introduction of a new testnet also saw the discovery of a [new
timewarp vulnerability][news316 timewarp].  Testnet4 included a fix for
the original [time warp][topic time warp] vulnerability, but developer
Zawy discovered in August a new exploit that could reduce difficulty by
about 94%.  Mark "Murch" Erhardt further developed the attack to allow
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

December saw David Harding [disclose][news333 if] a vulnerability
affecting Eclair, LDK, and LND by default (and Core Lightning with
non-default settings).  The party who requested to open a channel
(opener) and who was responsible for paying any [endogenous fees][topic
fee sourcing] necessary to close the channel could commit to paying 98%
of channel value to fees in one state, reduce the commitment to a
minimal amount in a subsequent state, move 99% of channel value to the
other party, and then close the channel in the 98%-fee state.  This
would result in the opener forfeiting 1% of channel value for using an
old state but the other party losing 98% of channel value.  If the opener mined
the transaction themselves, they could keep the 98% of channel value paid to
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

<!-- Not summarized here but discussed in the P2P improvements section
- https://bitcoinops.org/en/newsletters/2024/03/27/#disclosure-of-free-relay-attack
- https://bitcoinops.org/en/newsletters/2024/07/26/#varied-discussion-of-free-relay-and-fee-bumping-upgrades
-->

</div>

## March

{:#binanabips}
Ongoing problems getting BIPs merged led to the creation in January of a
[new BINANA repository][news286 binana] for specifications and other
documentation.  February and March saw the existing BIPs editor request
help and the beginning of a [process to add new editors][news292 bips].
After extensive public discussion culminating in April, several Bitcoin
contributors were [made BIP editors][news299 bips].

{:#enhancedfeeestimates}
Abubakar Sadiq Ismail proposed [enhancing Bitcoin Core's feerate
estimation][news295 fees] by using real-time mempool data. Currently,
estimates rely on confirmed transaction data, which updates slowly but
resists manipulation. Ismail developed preliminary code comparing the
current approach with a new mempool-based algorithm. Discussions
highlighted whether mempool data should adjust estimates up and down, or
only lower them. Dual-adjustment improves utility, but limiting
adjustments to lowering estimates may better prevent manipulation.

{:#efficientsponsors}
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

{:#consensuscleanup}
Antoine Poinsot [revisited][news296 ccsf] Matt Corallo's 2019 consensus
cleanup proposal, addressing issues like slow block verification, time
warp attacks allowing theft, and [fake transaction vulnerabilities][topic merkle tree vulnerabilities]
affecting light clients and full nodes. Poinsot also highlighted the
[duplicate transactions][topic duplicate transactions] problem that will affect full nodes at block
1,983,702. All issues have soft-fork solutions, though one proposed fix
for slow-verification blocks faced concerns over potentially
invalidating rare presigned transactions.  One of the proposed updates
received significant [discussion][news319 merkle] in August and
September that looked at alternative methods for mitigating merkle tree
vulnerabilities that affect lightweight clients and even (sometimes)
full nodes.  Although Bitcoin Core mitigated vulnerabilities as far as
possible, a previous refactor dropped essential protections, so Niklas
Gögge wrote code for Bitcoin Core that detects all currently detectable
vulnerabilities as early as possible and rejects invalid blocks.  In
December, discussion [turned][news332 zmwarp] to using the consensus cleanup
soft fork to fix the Zawy-Murch variant of the [time warp
vulnerability][topic time warp] that was discovered after the
implementation on [testnet4][topic testnet] of rules designed for the
original consensus cleanup proposal.

{:#bip2reform}
A spin-off of the discussion about adding a new BIPs editor saw a desire
to [reform BIP2][news297 bips], which specifies the current process for
adding new BIPs and updating existing BIPs.   Discussion
[continued][news303 bip2] the following month, and September saw the
publication of a [draft BIP][news322 newbip2] for an updated process.

{:#inboundrouting}
LND introduced [support for inbound routing fees][news297 inbound],
championed by Joost Jager, which allows nodes to charge channel-specific
fees for payments received from peers.  This helps nodes manage
liquidity, such as charging higher fees for inbound payments from poorly
managed nodes.  Inbound fees are
backward-compatible, initially set to negative (e.g., discounts) to work
with older nodes.  Although proposed years ago, other LN implementations
have resisted the feature, citing design concerns and compatibility
issues.  The feature saw continued development in LND throughout the
year.

{:#weakblocks}
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

{:#testnet}
Jameson Lopp started a discussion in April about problems with the
current public Bitcoin [testnet][topic testnet] (testnet3) and suggested
[restarting it][news297 testnet], potentially with a different set of
special-case consensus rules.  In May, Fabian Jahr [announced][news306
testnet] a draft BIP and proposed implementation for testnet4.  The
[BIP][news315 testnet4bip] and Bitcoin Core [implementation][news315
testnet4imp] were merged in August.

{:#devarrests}
April came to an unfortunate close with news of the [arrest of two
Bitcoin developers][news300 arrest] focused on privacy software, along with at least
two other companies announcing their intention to stop serving U.S.
customers due to the legal risks.

<div markdown="1" class="callout" id="cluster">
## Summary 2024: Cluster mempool

An idea for a [mempool redesign][news251 cluster] from 2023 became a
particular focus for several Bitcoin Core developers throughout 2024.
Cluster mempool makes it much easier to reason about the effect of
transactions on all the blocks a miner would create if it has an
identical mempool to the local node's mempool.  This can make
transaction eviction more rational and help in determining whether a
[replacement transaction][topic rbf] (or set of transactions) is better
than the transactions it replaces.  This can help address various
mempool limitations that are implicated in multiple problems affecting
contract protocols such as LN (including sometimes putting funds at
risk).

Additionally, as seen in a January post by Abubakar Sadiq Ismail, the
tools and insights from the design of cluster mempool may allow
[improving fee estimation in Bitcoin Core][news283 fees].  Today,
Bitcoin Core implements ancestor feerate mining as an incentive
compatible way to support [CPFP fee-bumping][topic cpfp], but fee
estimation operates on individual transactions, so CPFP fee bumps aren't
considered.  Cluster mempool divides groups of transactions into chunks
that can be tracked together in the mempool and then potentially located
within mined blocks, allowing improved fee estimation (especially if
there is an increased use of CPFP-related technology like [package
relay][topic package relay], [P2A][topic ephemeral anchors], and
[exogenous fee sourcing][topic fee sourcing].

As the cluster mempool project matured, multiple explanations and
overviews were made by its architects.  Suhas Daftuar gave an
[overview][news285 cluster] in January, which revealed one of the
challenges of the proposal: its incompatibility with the existing [CPFP
carve-out][topic cpfp carve out] policy.  A solution to the dilemma
would be for existing users of carve-out to opt in to [TRUC
transactions][topic v3 transaction relay], which provides an improved
feature set.  Another [detailed description][news312 cluster] of cluster
mempool was posted in July by Pieter Wuille.  It described fundamental
principles, proposed algorithms, and linked to several pull requests.
[Several][news314 cluster] of [those pull requests][news315 cluster] and
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

{:#silentpayments}
Work continued this year on making [silent payments][topic silent
payments] more [broadly accessible][news304 sp].  Josie Baker started a
discussion about PSBT extensions for silent payments (SPs), based on a
draft specification by Andrew Toth.  That discussion continued into
June with an examination of [using ECDH shares for trustless
coordination][news308 sp].  Separately, Setor Blagogee posted a draft
specification for a protocol to [help lightweight clients receive silent
payments][news305 splite].  A few [tweaks][news309 sptweak] were made to
the base SP specification in June and [two][news326 sppsbt] draft
[BIPs][news327 sppsbt] for the proposed PSBT features were posted.

{:#bitvmx}
Sergio Demian Lerner and several co-authors [published][news303 bitvmx]
a paper about a new virtual CPU architecture based in part on the ideas
behind [BitVM][topic acc].  The goal of their project, BitVMX, is to be
able to efficiently prove the proper execution of any program that can
be compiled to run on an established CPU architecture, such as RISC-V.
Like BitVM, BitVMX does not require any consensus changes, but it does
require one or more designated parties to act as a trusted verifier.
That means multiple users interactively participating in a contract
protocol can prevent any one (or more) of the parties from withdrawing
money from the contract unless that party successfully executes an
arbitrary program specified by the contract.

{:#aut}
Adam Gibson described an [anonymous usage token][news303 aut] scheme he
developed to allow anyone who can keypath-spend a UTXO to prove they
could spend it without revealing which UTXO it is.  One use he highlights
is allowing LN channels to be announced without requiring owners
identify the specific UTXOs backing those channels, which is required
now to prevent bandwidth-wasting denial-of-service attacks.  Gibson also
created a proof-of-concept forum that requires providing an anonymous
proof to sign up---creating an environment where everyone is known to
be a holder of bitcoins but no one needs to provide any identifying
information about themselves or their bitcoins.
Later in the year, Johan Halseth [announced][news321 utxozk] a proof-of-concept
implementation that accomplishes most of the same goals using a
different mechanism.

{:#lnup}
For years, LN developers have discussed modifying the LN protocol to
allow existing channels to be [upgraded][topic channel commitment
upgrades] in various ways.  In May, Carla Kirk-Cohen [examined][news304
lnup] some of these cases and compared three different proposals for
upgrades.  A quiescence protocol was [added][news309 stfu] to the LN
specification in June to help support upgrades and other sensitive
operations.  October saw [renewed development][news326 ann1.75] of a proposed
updated channel announcements protocol that would support new
[taproot-based funding transactions][topic simple taproot channels].

{:#minecash}
Ethan Tuttle posted to Delving Bitcoin to suggest that mining pools
could [reward miners with ecash tokens][news304 minecash] proportionate
to the number of shares they mined. The miners could then immediately
sell or transfer the tokens, or they could wait for the pool to mine a
block, at which point the pool would exchange the tokens for satoshis.
However, a concern was raised by Matt Corallo that there are no
standardized payment methods implemented by large pools that allow pool
miners to calculate how much they're supposed to be paid over short
intervals.  This means miners won't quickly switch to a different pool
if their main pool begins cheating them of payments, whether those
payments are made with ecash or any other mechanism.

{:#miniscript}
Ava Chow [proposed][news304 msbip] a BIP for [miniscript][topic
miniscript] in May, which became [BIP379][] in [July][news310 msbip].

{:#utreexod}
Also in May, a beta release of utreexod was [published][news302
utreexod], allowing users to experiment with this full node design that
minimizes disk space requirements.

## June

{:#lnfeasibility}
René Pickhardt researched estimating the [likelihood of LN payment
feasibility][news309 feas] by analyzing possible wealth distributions
within channel capacities. For example, if Alice wants to send 1 BTC to
Carol via Bob, the likelihood of success depends on whether the Alice-Bob and
Bob-Carol channels can support the transfer. This metric highlights
practical payment constraints and could help wallets and business
software make smarter routing decisions, improving success rates for LN
payments.  Later in the year, Pickhardt's research provided
[insights][news333 deplete] into the cause and likelihood of channel
depletion---a channel becoming unable to forward funds in a particular
direction.  It also pointed to k>2 multiparty channel management
protocols, such as [channel factories][topic channel factories], being
able to greatly increase the number of feasible payments and reduce the
rate of channel depletion.

![Example of channel depletion](/img/posts/2024-12-depletion.png)

{:#quantumsign}
Developer Hunter Beast [posted][news307 quant] a "rough draft" BIP for
assigning version 3 segwit addresses to a [quantum-resistant signature
algorithm][topic quantum resistance]. The draft BIP describes the
problem and links to several potential algorithms along with their
expected onchain size. The choice of algorithms and the specific
implementation details was left for future discussion.

<div markdown="1" class="callout" id="p2prelay">
## Summary 2024: P2P transaction relay

Fee management has always been a challenge in the decentralized Bitcoin
protocol, but widespread use of contract protocols such as LN-Penalty
and ongoing research into newer and more complex protocols has made it
more important than ever to ensure users can pay and increase fees on
demand.  Bitcoin Core contributors have been working on this problem for
years, and 2024 saw the public release of several new features that
significantly improve the situation.

January began with a [discussion][news283 trucpin] of the
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
of each settlement transaction at varying feerates.  However, multiple
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
providing the benefits of TRUC without LN software needing to be upgraded.

January came to an end with a [proposal][news287 sibrbf] by Gloria Zhao
for [sibling replace by fee][topic kindred rbf].  The normal [RBF][topic
rbf] rules only apply to conflicting transactions where a node
accepts just one version of the transaction into its mempool because only one
version is permitted to exist in a valid blockchain.  However, with TRUC, a
node accepts only one descendant of an unconfirmed version 3 parent
transaction, a very similar situation to a conflicting transaction.
Allowing one descendant to replace another descendant of the same
transaction---i.e., _sibling eviction_---would improve fee-bumping of TRUC
transaction and be especially beneficial if imbued TRUC is
adopted.

February began with additional discussions of the consequences of moving
the LN protocol from CPFP carve-out to TRUC.  Matt Corallo found
[challenges][news288 truc0c] in adapting existing [zero-conf channel
opens][topic zero-conf channels] to using TRUC due to both the funding
transaction and an immediate close transaction potentially being
unconfirmed, preventing a third transaction containing a CPFP fee bump
from being used due to TRUC's limit of two unconfirmed transactions.
Teinturier identified a similar problem if a chain of [splices][topic
splicing] was used.  The discussion never reached a clear conclusion,
but a workaround solution of ensuring each transaction contained its own
anchor for CPFP fee-bumping (as is required before TRUC) seemed
satisfactory, with everyone hoping that [cluster mempool][topic cluster
mempool] could allow relaxing some TRUC rules in the future to allow
more flexible CPFP fee-bumping.

On the topic of TRUC policy changes powered by cluster mempool
advancements, Gregory Sanders described several ideas for [future policy
changes][news289 pcmtruc].  By contrast, Suhas Daftuar
[analyzed][news289 oldtruc] all transactions received by his node from
the prior year to see how an imbued TRUC policy would have affected the
acceptance of those transactions.  Most transactions
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
(P2A) in August and releasing Bitcoin Core 28.0 in October with support
for 1p1c package relay, TRUC transaction relay, package RBF and sibling
replacement, and a standard P2A output script type.  Gregory Sanders,
who contributed to the development of all those features,
[described][news324 guide] how developers of wallets and other software
that uses Bitcoin Core to create or broadcast transactions can take
advantage of the new capabilities.

Later in the year, support for [ephemeral dust][topic ephemeral
anchors] outputs using P2A were made standard in a [merge][news330
dust].  This allows a transaction paying zero fee to be bumped by a
child transaction paying all the relevant fee---a purely
exogenous type of [fee sourcing][topic fee sourcing].

Optech's final regular newsletter for the year summarized a Bitcoin Core
Pull Request Review Club [meeting][news333 prclub] that discussed further
improvements for 1p1c package relay.
</div>

## July

{:#bolt11blind}
Elle Mouton proposed a BLIP to [add a blinded path field to
BOLT11][news310 path] invoices, allowing payment recipients to hide
their node identity and channel peers. For example, Bob could add a
blinded path to his invoice, enabling Alice to pay privately if her
software supports it; otherwise, she would receive an error. Mouton sees
this as a temporary solution until [offers][topic offers], which
natively support blinded paths, are widely adopted.  The proposal became
[BLIP39][] in [August][news317 blip39].

{:#chilldkg}
Tim Ruffing and Jonas Nick proposed ChillDKG, a BIP draft and reference
implementation for [securely generating keys for FROST-style scriptless
threshold signatures][news312 chilldkg] compatible with Bitcoin's
[schnorr signatures][topic schnorr signatures].
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

{:#musigthresh}
July saw the [merge][news310 musig] of several BIPs that will help
different software interact to create [MuSig2][topic musig] signatures.
Later in the month, Sivaram Dhakshinamoorthy [announced][news315
threshsig] a proposed BIP for creating scriptless [threshold
signatures][topic threshold signature] for Bitcoin's implementation of
[schnorr signatures][topic schnorr signatures].  This allows a set of
signers that have already performed a setup procedure (e.g. using
ChillDKG) to securely create signatures that only require interaction
from a dynamic subset of those signers. The signatures are
indistinguishable onchain from schnorr signatures created by single-sig
users and scriptless multisignature users, improving privacy and
fungibility.

## 八月

{:#hyperion}
Sergi Delgado [发布][news314 hyperion] 了 Hyperion，这是一个网络模拟器，用于追踪数据在模拟的比特币网络中的传播情况。这项工作最初的动机是为了比较比特币当前的交易公告传播方法与提议的 [Erlay][topic erlay] 方法。

{:#fullrbf}
开发者 0xB10C [研究][news315 cb] 了最近 [致密区块][topic compact block relay] 重建的可靠性。有时新区块会包含节点之前未见过的交易。在这种情况下，接收致密区块的节点通常需要向发送节点请求这些交易，并等待对方响应。这会减慢区块传播速度。该研究帮助推动了考虑在 Bitcoin Core 中默认启用 [mempoolfullrbf][topic rbf] 的拉取请求，该请求后来被[合并][news315 rbfdefault]。

<div markdown="1" class="callout" id="covs">
## 2024 总结：限制条款和脚本升级

2024 年，一些开发者投入了大量时间推进[限制条款][topic covenants]、脚本升级以及其他支持高级合约协议（如 [joinpools][topic joinpools] 和[通道工厂][topic channel factories]）的提案。

2023 年 12 月底，Johan Torås Halseth [宣布][news283 elftrace]了一个概念验证程序，该程序可以使用来自 [MATT][topic acc] 软分叉提案的 `OP_CHECKCONTRACTVERIFY` 操作码，允许合约协议中的一方在任意程序成功执行时认领资金。这在概念上类似于 [BitVM][topic acc]，但由于使用了专门为程序执行验证设计的操作码，其比特币实现更为简单。Elftrace 可以处理使用 Linux ELF 格式为 RISC-V 架构编译的程序；几乎任何程序员都可以轻松地为该目标创建程序，这使得使用 elftrace 变得非常容易。8 月份，Halseth 提供了一个更新。Elftrace 与 [OP_CAT][topic op_cat] 操作码结合，可以[验证][news315 elftracezk]零知识证明。

1 月份，LNHANCE 组合软分叉提案[公布][news285 lnhance]。该提案包括此前提出的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）和 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（CSFS），以及一个新提案的 `OP_INTERNALKEY`，用于将 taproot 内部密钥放在堆栈上。今年晚些时候，该提案[更新][news330 paircommit]还包括了一个 `OP_PAIRCOMMIT` 操作码，该操作码提供了类似于 `OP_CAT` 的功能，但在其组合性上有刻意的限制。该提案旨在允许部署 [LN-Symmetry][topic eltoo]、[Ark][topic ark] 风格的 joinpools、减少签名的 [DLC][topic dlc] 和[保险库][topic vaults]，以及底层提案的其他描述的好处，如 CTV 风格的拥塞控制和 CSFS 风格的签名委托。

Chris Stewart [发布][news285 64bit]了一份 BIP 草案，用于在未来的软分叉中启用比特币脚本中的 64 位算术运算。比特币目前只允许 32 位运算（使用有符号整数，所以超过约 20 亿的数字无法使用）。对 64 位值的支持在任何需要操作输出中支付的聪数的构造中都特别有用，因为这是使用 64 位整数指定的。该提案在[二月][news290 64bit]和[六月][news306 64bit]都有进一步讨论。

同样在 2 月，开发者 Rijndael 创建了一个[概念验证程序][news291 catvault]，实现一个只需要在当前共识规则上增加提议的 [OP_CAT][topic op_cat] 操作码的[保险库][topic vaults]。Optech 将 `OP_CAT` 保险库、当前使用预签名交易就可实现的保险库与添加 [BIP345][] `OP_VAULT` 到比特币后可实现的保险库进行了比较。

<table>
  <tr>
    <th></th>
    <th>预签</th>
    <th markdown="span">

    BIP345 `OP_VAULT`

    </th>
    <th markdown="span">

    使用 schnorr 的 `OP_CAT`

    </th>
  </tr>

  <tr>
    <th>可用性</th>
    <td markdown="span">

    **当前**

    </td>
    <td markdown="span">

    需要 `OP_VAULT` 和 [OP_CTV][topic op_checktemplateverify] 的软分叉

    </td>
    <td markdown="span">

    需要 `OP_CAT` 的软分叉

    </td>
  </tr>

  <tr>
    <th markdown="span">最后时刻地址替换攻击</th>
    <td markdown="span">易受攻击</td>
    <td markdown="span">

    **不受影响**

    </td>
    <td markdown="span">

    **不受影响**

    </td>
  </tr>

  <tr>
    <th markdown="span">部分金额提现</th>
    <td markdown="span">仅在预先有设置的情况下允许</td>
    <td markdown="span">

    **允许**

    </td>
    <td markdown="span">不允许</td>
  </tr>

  <tr>
    <th markdown="span">静态且非交互地计算存款地址</th>
    <td markdown="span">不允许</td>
    <td markdown="span">

    **允许**

    </td>
    <td markdown="span">

    **允许**

    </td>
  </tr>

  <tr>
    <th markdown="span">批量的重新保管/隔离以节省费用</th>
    <td markdown="span">不允许</td>
    <td markdown="span">

    **允许**

    </td>
    <td markdown="span">不允许</td>
  </tr>

  <tr>
    <th markdown="span">

    最优情况下的操作效率，即仅有合法花费<br>*(仅由 Optech 非常粗略地估计)*

    </th>
    <td markdown="span">

    **常规单签名大小的 2 倍**

    </td>
    <td markdown="span">常规单签名大小的 3 倍</td>
    <td markdown="span">常规单签名大小的 4 倍</td>
  </tr>
</table>

三月，开发者 ZmnSCPxj [描述][news293 forkbet]了一个协议，该协议将 UTXO 的控制权交给能正确预测特定软分叉是否会激活的一方。虽然其他人之前也提出过这个基本想法，但 ZmnSCPxj 的版本有至少一个潜在的未来软分叉 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 的具体细节。

三月还见证了 Anthony Towns 开始基于 Lisp 语言为比特币开发一种替代性脚本语言。他提供了一个 Chia 山寨币已在使用的 Lisp 风格语言的[概述][news293 chialisp]，并[提出][news294 btclisp]了一个 BTC Lisp 语言。在今年晚些时候，受比特币脚本和 [miniscript][topic miniscript] 之间关系的启发，他将他的 Lisp 项目[分成][news331 bll]两部分：一个可以通过软分叉添加到比特币中的低级比特币 lisp 语言（bll）和一个可以转换为 bll 的符号化 bll（symbll）高级语言。他还[描述][news331 earmarks]了一个与 symbll（可能还有 [Simplicity][topic simplicity]）兼容的通用结构，该结构允许将 UTXO 划分为特定金额和支出条件。他展示了这些 _灵活币标记_ 的使用方式，包括改进闪电网络通道的安全性和可用性（包括基于 [LN-Symmetry][topic eltoo] 的通道）、[BIP345][] 版本保险库的替代方案，以及[支付池][topic joinpools]设计。

五月，Jeremy Rubin 对 `OP_CHECKTEMPLATEVERIFY` 设计提出了[两个更新][news302 ctvext]：可选的支持更短的哈希摘要，以及支持额外的承诺。这些更新有助于优化 CTV 在数据发布方案中的使用，这些方案可能对恢复 [LN-Symmetry][topic eltoo] 和类似协议中的关键数据有用。

Pierre Rochard [询问][news305 overlap]，对于那些能以相似成本提供许多相同功能的软分叉提案，是否应该将它们视为互斥的，还是激活多个提案更合理，因为可以让开发者使用任何他们所偏好的方案。

Jeremy Rubin [发表][news306 fecov]了一篇论文，论述了如何在理论上使用函数加密来为比特币添加完整的限制条款功能，而无需任何共识变更。从本质上说，函数加密允许创建一个对应于特定程序的公钥。任何能满足该程序的一方都能创建与该公钥对应的签名（无需知道相应的私钥）。与之前提出的一些限制条款相比，这种方式总是更私密的，而且通常能节省空间。不幸的是，根据 Rubin 的说法，函数加密的一个主要缺点是“加密技术尚未成熟，目前无法实际使用”。

Anthony Towns 发布了一个用于 [signet][topic signet] 的[脚本][news306 catfaucet]，该脚本使用 [OP_CAT][topic op_cat] 允许任何人通过工作量证明（PoW）来花费发送到该脚本的币。这可以用作去中心化的 signet 比特币水龙头：当矿工或用户获得过多的 signet 比特币时，他们可以将其发送到该脚本。当用户需要更多 signet 比特币时，他们可以在 UTXO 集中搜索支付给该脚本的交易，生成工作量证明，并使用他们的工作量证明创建一笔交易来获取这些币。

Victor Kolobov [宣布][news319 catmillion]设立了一个 100 万美元的基金，用于研究提议的添加 `OP_CAT` 操作码的软分叉。提交截止日期为 2025 年 1 月 1 日。

11 月，Towns [总结][news330 sigactivity]了与通过 Bitcoin Inquisition 提供的提议软分叉相关的默认 signet 活动。Vojtěch Strnad 受 Towns 的帖子启发，创建了一个网站，列出了“在比特币 signet 上使用已部署软分叉的所有交易”。

Ethan Heilman [发布][news330 covgrind]了一篇与 Victor Kolobov、Avihu Levy 和 Andrew Poelstra 合著的论文，论述了如何在不改变共识的情况下轻松创建限制条款，尽管从这些限制条款中花费需要非标准交易和价值数百万（或数十亿）美元的专用硬件和电力。Heilman 指出，该工作的一个应用是允许用户今天轻松包含一个备用的 taproot 花费路径，如果突然需要量子抗性并且比特币上的椭圆曲线签名操作被禁用，就可以安全地使用该路径。这项工作似乎部分受到了几位作者之前关于比特币 lamport 签名[研究][news301 lamport]的启发。

12 月以一项对精选了若干项限制条款提案的[开发者意见调查][news333 covpoll]结束。

_从 2025 年 1 月开始，Optech 将在每月第一期周报中的特别专栏中开始总结与限制条款、脚本升级和相关变更有关的重要研究和发展。我们鼓励所有从事这些提案工作的人将任何有趣的内容发布到我们的常规[来源][optech sources]中，以便我们可以对其进行报道。_

</div>

## 九月

{:#hybridjamming}
Carla Kirk-Cohen 描述了对 Clara Shikhelman 和 Sergei Tikhomirov 最初提出的[混合通道阻塞缓解方案][news322 jam]的测试和调整。试图去阻塞一个通道一小时大多会失败，因为攻击者要么花费会超过现有攻击所需的成本，要么无意中为攻击目标增加收入。然而，_沉没攻击_ 通过破坏通过较短路由的支付，有效地破坏了节点的声誉。为了应对这一问题，在 [HTLC 背书][topic htlc endorsement]中添加了双向声誉机制，使提案更接近 Jim Posen 在 2018 年最初提出的想法。节点现在在决定转发支付时会评估发送方和接收方的可靠性。可靠的节点会收到背书的 HTLC，而较不可靠的发送方或接收方则面临拒绝或非背书转发。这项测试是在 [HTLC 背书规范][news316 htlce]和 [Eclair 实现][news315 htlce]之后进行的。年底前还添加了 [LND 的实现][news332 htlce]。

{:#shieldedcsv}
Jonas Nick、Liam Eagen 和 Robin Linus 介绍了一个新的[客户端验证][topic client-side validation]（CSV）协议，[暗影 CSV][news322 csv]，它能够在不透露代币详情或转账历史的情况下，实现由比特币工作量证明保护的代币转账。与现有协议不同，在现有协议中客户端必须验证大量代币历史，暗影 CSV 使用零知识证明来确保验证只需要固定的资源，同时保护隐私。此外，暗影 CSV 通过将数千个代币转账捆绑到每个比特币交易中的单个 64 字节更新中，减少了链上数据需求，提高了可扩展性。该论文探讨了通过 [BitVM][topic acc] 实现无信任的比特币到 CSV 桥接、基于账户的结构、处理区块链重组、未确认交易以及潜在的扩展。该协议承诺在效率和隐私方面比其他代币系统有显著改进。

{:#lnoff}
Andy Schroder 概述了一个[启用闪电网络离线支付][news321 lnoff]的流程，通过在在线时生成认证令牌，允许支付者的钱包在离线时通过其始终在线的节点或 LSP 授权支付。令牌可以通过 NFC 或其他简单协议传输给接收者，实现无需互联网的支付。开发者 ZmnSCPxj 提出了一个替代方案。而 Bastien Teinturier 则引用了他的远程节点控制方法用于类似用例，这种方法增强了智能卡等有限资源设备的离线支付解决方案。

## 十月

{:#offers}
[BOLT12][] 规范中的 [offer][topic offers] 被[合并][news323 offers]。这个在 2019 年[最初提出][news72 offers]的报价功能允许两个节点使用[洋葱消息][topic onion messages]在闪电网络上协商发票和支付。洋葱消息和兼容报价的支付都可以使用[盲化路径][topic rv routing]来防止支付者了解接收者节点的身份。

{:#pooledmining}
Bitcoin Core 开发了一个[新的挖矿接口][news325 mining]，目标是为使用 [Stratum v2][topic pooled mining] 协议的矿工提供支持。该协议可以设置为允许每个矿工选择自己的交易。然而，Anthony Towns 在今年早些时候指出，独立的交易选择可能会[提高矿池的份额验证成本][news315 shares]。如果矿池通过限制验证来应对这个问题，那么又可能会带来一种类似于著名的[扣块攻击][topic block withholding]的无效份额攻击。2011 年就已提出过一个解决扣块攻击的方案，但该方案需要一个具有挑战性的共识变更。

<div markdown="1" class="callout" id="releases">
## 2024 年总结：流行的基础设施项目的主要版本

- [LDK 0.0.119][] 增加了对多跳[盲化路径][topic rv routing]的支持。

- [HWI 2.4.0][] 增加了对 Trezor Safe 3 的支持。

- [Core Lightning 24.02][] 包含了对 `recover` 插件的改进，“使紧急恢复变得不那么紧张”，改进了[锚点输出通道][topic anchor outputs]，区块链同步速度提高了 50%，并修复了测试网上发现的一个大型交易解析错误。

- [Eclair v0.10.0][] "正式支持[双重注资功能][topic dual funding]，最新的 BOLT12 [offer][topic offers] 实现，以及一个完整可用的[通道拼接][topic splicing]原型"。

- [Bitcoin Core 27.0][] 弃用了 libbitcoinconsensus，默认启用了 [v2 加密 P2P 传输][topic v2 p2p transport]，允许在测试网络上使用选择性拓扑限制直到确认（[TRUC][topic v3 transaction relay]）交易策略，并添加了一个在高手续费率时使用的新[选币][topic coin selection]策略。

- [BTCPay Server 1.13.1][]（及之前版本）使 webhooks 更具扩展性，增加了对 [BIP129][] 多重签名钱包导入的支持，改进了插件灵活性并开始将所有山寨币支持迁移到插件中，并添加了对 BBQr 编码的 [PSBTs][topic psbt] 的支持。

- [Bitcoin Inquisition 25.2][] 在 signet 上添加了对 [OP_CAT][topic op_cat] 的支持。

- [Libsecp256k1 v0.5.0][] 加快了密钥生成和签名速度，并减少了编译大小，“这特别有利于嵌入式用户”。

- [LDK v0.0.123][] 包括对其[修剪 HTLC][topic trimmed htlc] 设置的更新以及对 [offer][topic offers] 支持的改进。

- [Bitcoin Inquisition 27.0][] 按照 [BIN24-1][] 和 [BIP347][] 的规范在 signet 上强制执行了 [OP_CAT][]。它还包括“一个新的 `evalscript` 子命令用于 `bitcoin-util`，可用于测试脚本操作码行为”。放弃了对 `annexdatacarrier` 和伪[临时锚点][topic ephemeral anchors]的支持。

- [LND v0.18.0-beta][] 添加了对入站路由费用的实验性支持，[盲化路径][topic rv routing]的路径查找，[简单 taproot 通道][topic simple taproot channels]的[瞭望塔][topic watchtowers]支持，并简化了加密调试信息的发送。

- [Core Lightning 24.05][] 改进了与修剪全节点的兼容性，允许 `check` RPC 与插件一起工作，允许更稳健地传递 [offer][topic offers] 发票，并修复了使用 `ignore_fee_limits` 配置选项时的手续费超额支付问题。

- [HWI 3.1.0][] 添加了对 Trezor Safe 5 的支持。

- [Bitcoin Core 28.0][] 添加了对 [testnet 4][topic testnet] 的支持，机会性一父一子（1p1c）[交易包中继][topic package relay]，默认中继选择性拓扑限制直到确认（[TRUC][topic v3 transaction relay]）交易，默认中继[支付到锚点][topic ephemeral anchors]交易，有限的交易包 [RBF][topic rbf] 中继，以及默认[完全 RBF][topic rbf]。添加了 [assumeUTXO][topic assumeutxo] 的默认参数，允许 `loadtxoutset` RPC 使用在比特币网络之外下载的 UTXO 集（例如通过种子）。

- [BTCPay Server 2.0.0][] 添加了“改进的本地化、侧边栏导航、改进的入门流程、改进的品牌选项和可插拔汇率提供者支持”。此升级包含一些重大更改和数据库迁移。

- [Libsecp256k1 0.6.0][] “添加了 [MuSig2][topic musig] 模块，一个显著更强大的从堆栈中清理密钥的方法，并移除了未使用的 `secp256k1_scratch_space` 函数”。

- [BDK 0.30.0][] 为该库预期的 1.0 版本升级做准备。

- [Eclair v0.11.0][] “正式支持 BOLT12 [offer][topic offers]，并在流动性管理功能方面取得进展（[通道拼接][topic splicing]、[流动性广告][topic liquidity advertisements] 和[即时通道][topic jit channels]）”。该版本还停止接受新的非[锚点通道][topic anchor outputs]。

- [Core Lightning 24.11][] 包含一个用于使用高级路由选择进行支付的实验性新插件；默认启用了 [offer][topic offers]的支付和接收；并添加了多项[通道拼接][topic splicing]改进。
</div>

## 十一月

{:#superscalar}
ZmnSCPxj 提出了 [SuperScalar 设计][news327 superscalar]，这是一个使用[超时树][topic timeout trees]的[通道工厂][topic channel factories]，使闪电网络用户能够以更低的成本开通通道并获取流动性，同时保持无需信任。该设计使用分层超时树，要求服务提供商支付将树上链的任何成本，否则将失去树中剩余的任何资金。这鼓励服务提供商激励用户合作关闭他们的通道，以避免需要上链。该设计同时使用[双工微支付通道][topic duplex micropayment channels]和 [LN-Penalty][topic ln-penalty] 支付通道，这两种通道都不需要任何共识变更就可以实现。尽管其复杂性——结合多种通道类型和管理链下状态——该设计可以由单个供应商实现，而无需大规模的协议更改。为了支持该设计，ZmnSCPxj 后来向闪电网络规范提出了[可插拔通道工厂调整][news330 plug]。

{:#opr}
John Law [提出][news329 opr]了一个链下支付解决方案（OPR）微支付协议，该协议要求双方参与者都向一个保证金池注入资金，这些资金可以在任何时候被任何一方有效销毁。这为双方创造了一个互相妥协的激励机制，否则就会面临保证金资金的相互确保摧毁（MAD）风险。该协议并非无需信任，但它比其他替代方案更具可扩展性，能提供快速解决方案，并且在时间锁到期前不会强制各方在链上发布数据。这使得 OPR 在[通道工厂][topic channel factories]、[超时树][topic timeout trees]或其他理想情况下保持嵌套部分在链下的嵌套结构中更加高效。

<div markdown="1" class="callout" id="optech">
## 2024 年总结： Bitcoin Optech

在 Optech 的第七个年头，我们发布了 51 期每周[周报][newsletters]，并在我们的[主题索引][topics index]中新增了 35 个页面。总的来说，Optech 今年发布了超过 120,000 个英文单词的比特币软件研究和开发内容，相当于一本 350 页的书。

每期周报和博客文章都被翻译成中文、捷克语、法语和日语，2024 年总共完成了超过 200 篇翻译。

此外，今年的每期通讯都配有一期[播客][podcast]节目，总计超过 59 小时的音频内容和 488,000 字的文字记录。比特币领域的许多顶尖贡献者都作为嘉宾参与了节目——有些人甚至多次参与——2024 年共有 75 位不同的嘉宾：

- Abubakar Sadiq Ismail (x2)
- Adam Gibson
- Alex Bosworth
- Andrew Toth (x3)
- Andy Schroder
- Anthony Towns (x5)
- Antoine Poinsot (x5)
- Antoine Riard (x2)
- Armin Sabouri
- Bastien Teinturier (x4)
- Bob McElrath
- Brandon Black (x3)
- Bruno Garcia
- callebtc
- Calvin Kim
- Chris Stewart (x3)
- Christian Decker
- Dave Harding (x3)
- David Gumberg
- /dev/fd0
- Dusty Daemon
- Elle Mouton (x2)
- Eric Voskuil
- Ethan Heilman (x2)
- Eugene Siegel
- Fabian Jahr (x5)
- Filippo Merli
- Gloria Zhao (x10)
- Gregory Sanders (x7)
- Hennadii Stepanov
- Hunter Beast
- Jameson Lopp (x2)
- Jason Hughes
- Jay Beddict
- Jeffrey Czyz
- Johan Torås Halseth
- Jonas Nick (x2)
- Joost Jager
- Josie Baker
- Kulpreet Singh
- Lorenzo Bonazzi
- Luke Dashjr
- Matt Corallo (x3)
- Moonsettler (x2)
- Nicholas Gregory
- Niklas Gögge (x2)
- Oghenovo Usiwoma
- Olaoluwa Osuntokun
- Oliver Gugger
- Peter Todd
- Pierre Corbin
- Pierre Rochard
- Pieter Wuille
- René Pickhardt (x2)
- Richard Myers
- Rijndael
- rkrux
- Russell O’Connor
- Salvatore Ingala (x2)
- Sebastian Falbesoner
- SeedHammer Team
- Sergi Delgado
- Setor Blagogee
- Shehzan Maredia
- Sivaram Dhakshinamoorthy
- Stéphan Vuylsteke
- Steven Roose
- Tadge Dryja
- TheCharlatan
- Tom Trevethan
- Tony Klausing
- Valentine Wallace
- Virtu
- Vojtěch Strnad (x2)
- ZmnSCPxj (x3)

Optech 很幸运且感激地收到了来自[人权基金会][Human Rights Foundation]的 20,000 美元捐赠。这笔资金将用于支付网站托管、电子邮件服务、播客转录以及其他费用，使我们能够继续并改进向比特币社区提供技术内容的工作。

</div>

## 十二月

十二月延续了此前的几个讨论，并宣布了多个漏洞。所有这些内容在本期通讯的前文已有总结。

*我们感谢上述提到的所有比特币贡献者们，以及其他有着同样重要工作的贡献者们。他们为比特币开发带来了又一个令人难以置信的年份。Optech 周报将于 1 月 3 日恢复其常规的周五发布时间表。*
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

{% include snippets/recap-ad.md when="2024-12-23 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[topics index]: /en/topics/
[yirs 2018]: /zh/newsletters/2018/12/28/
[yirs 2019]: /zh/newsletters/2019/12/28/
[yirs 2020]: /zh/newsletters/2020/12/23/
[yirs 2021]: /en/newsletters/2021/12/22/
[yirs 2022]: /zh/newsletters/2022/12/21/
[yirs 2023]: /zh/newsletters/2023/12/20/
[news283 feelocks]: /zh/newsletters/2024/01/03/#feedependent-timelocks
[news283 exits]: /zh/newsletters/2024/01/03/#pool-exit-payment-batching-with-delegation-using-fraud-proofs
[news284 lnsym]: /zh/newsletters/2024/01/10/#ln-symmetry-research-implementation-ln-symmetry
[news288 rbfr]: /zh/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[news290 dns]: /zh/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-dns
[news290 asmap]: /zh/newsletters/2024/02/21/#improved-reproducible-asmap-creation-process-asmap
[news290 dualfund]: /zh/newsletters/2024/02/21/#bolts-851
[news291 bets]: /zh/newsletters/2024/02/28/#trustless-contract-for-miner-feerate-futures
[news295 fees]: /zh/newsletters/2024/03/27/#mempoolbased-feerate-estimation
[news295 sponsor]: /zh/newsletters/2024/03/27/#transaction-fee-sponsorship-improvements
[news286 binana]: /zh/newsletters/2024/01/24/#new-documentation-repository
[news292 bips]: /zh/newsletters/2024/03/06/#discussion-about-adding-more-bip-editors-bip
[news296 ccsf]: /zh/newsletters/2024/04/03/#revisiting-consensus-cleanup
[news299 bips]: /zh/newsletters/2024/04/24/#bip-editors-update-bip
[news297 bips]: /zh/newsletters/2024/04/10/#bip2
[news297 inbound]: /zh/newsletters/2024/04/10/#lnd-6703
[news299 weakblocks]: /zh/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation
[news297 testnet]: /zh/newsletters/2024/04/10/#discussion-about-resetting-and-modifying-testnet-testnet
[news300 arrest]: /zh/newsletters/2024/05/01/#arrests-of-bitcoin-developers
[news308 sp]: /zh/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments-psbt
[news304 sp]: /zh/newsletters/2024/05/24/#discussion-about-psbts-for-silent-payments-psbt
[news305 splite]: /zh/newsletters/2024/05/31/#light-client-protocol-for-silent-payments
[news309 feas]: /zh/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible-ln
[news310 path]: /zh/newsletters/2024/07/05/#adding-a-bolt11-invoice-field-for-blinded-paths-bolt11
[news312 chilldkg]: /zh/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[news315 htlce]: /zh/newsletters/2024/08/09/#eclair-2884
[news316 htlce]: /zh/newsletters/2024/08/16/#blips-27
[news322 jam]: /zh/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[news332 htlce]: /zh/newsletters/2024/12/06/#lnd-8390
[news322 csv]: /zh/newsletters/2024/09/27/#shielded-clientside-validation-csv
[news321 lnoff]: /zh/newsletters/2024/09/20/#ln-offline-payments
[news323 offers]: /zh/newsletters/2024/10/04/#bolts-798
[news72 offers]: /zh/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[news324 guide]: /zh/newsletters/2024/10/11/#guide-for-wallet-developers-using-bitcoin-core-28-0
[news315 shares]: /zh/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[news327 superscalar]: /zh/newsletters/2024/11/01/#timeout-tree-channel-factories
[news330 plug]: /zh/newsletters/2024/11/22/#pluggable-channel-factories
[news283 lndvuln]: /zh/newsletters/2024/01/03/#disclosure-of-past-lnd-vulnerabilities-lnd
[news285 clnvuln]: /zh/newsletters/2024/01/17/#core-lightning
[news286 btcdvuln]: /zh/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd-btcd
[news288 bccvuln]: /zh/newsletters/2024/02/07/#bitcoin-core-ln
[news308 lndvuln]: /zh/newsletters/2024/06/21/#disclosure-of-vulnerability-affecting-old-versions-of-lnd-lnd
[news310 wlad]: /zh/newsletters/2024/07/05/#remote-code-execution-due-to-bug-in-miniupnpc-miniupnpc
[news310 ek]: /zh/newsletters/2024/07/05/#node-crash-dos-from-multiple-peers-with-large-messages
[news310 jnau]: /zh/newsletters/2024/07/05/#censorship-of-unconfirmed-transactions
[news310 unamed]: /zh/newsletters/2024/07/05/#unbound-ban-list-cpumemory-dos-cpu-dos
[news310 ps]: /zh/newsletters/2024/07/05/#netsplit-from-excessive-time-adjustment
[news310 sec.eine]: /zh/newsletters/2024/07/05/#cpu-dos-and-node-stalling-from-orphan-handling-cpu-dos
[news310 jn1]: /zh/newsletters/2024/07/05/#memory-dos-from-large-inv-messages-inv-dos
[news310 cf]: /zh/newsletters/2024/07/05/#memory-dos-using-lowdifficulty-headers-dos
[news310 jn2]: /zh/newsletters/2024/07/05/#cpuwasting-dos-due-to-malformed-requests-cpu-dos
[news310 mf]: /zh/newsletters/2024/07/05/#memoryrelated-crash-in-attempts-to-parse-bip72-uris-bip72-uri
[news310 disclosures]: /zh/newsletters/2024/07/05/#disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-0210-0-21-0-bitcoin-core
[news314 es]: /zh/newsletters/2024/08/02/#addr
[news314 mf]: /zh/newsletters/2024/08/02/#upnp
[news322 checkpoint]: /zh/newsletters/2024/09/27/#disclosure-of-vulnerability-affecting-bitcoin-core-versions-before-2401
[news324 ng]: /zh/newsletters/2024/10/11/#cve-2024-35202-remote-crash-vulnerability-cve-2024-35202
[news324 b10caj]: /zh/newsletters/2024/10/11/#dos-from-large-inventory-sets
[news324 sd]: /zh/newsletters/2024/10/11/#slow-block-propagation-attack
[news328 multi]: /zh/newsletters/2024/11/08/#disclosure-of-a-vulnerability-affecting-bitcoin-core-versions-before-251
[news317 exfil]: /zh/newsletters/2024/08/23/#simple-but-imperfect-anti-exfiltration-protocol
[news315 exfil]: /zh/newsletters/2024/08/09/#faster-seed-exfiltration-attack
[news332 ccsf]: /zh/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
[news316 timewarp]: /zh/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4
[news324 btcd]: /zh/newsletters/2024/10/11/#cve-2024-38365-btcd-consensus-failure
[news333 if]: /zh/newsletters/2024/12/13/#vulnerability-allowing-theft-from-ln-channels-with-miner-assistance
[news333 deanon]: /zh/newsletters/2024/12/13/#deanonymization-vulnerability-affecting-wasabi-and-related-software
[news251 cluster]: /zh/newsletters/2023/05/17/#mempool-clustering
[news283 fees]: /zh/newsletters/2024/01/03/#cluster-fee-estimation
[news285 cluster]: /zh/newsletters/2024/01/17/#overview-of-cluster-mempool-proposal
[news312 cluster]: /zh/newsletters/2024/07/19/#introduction-to-cluster-linearization
[news314 cluster]: /zh/newsletters/2024/08/02/#bitcoin-core-30126
[news315 cluster]: /zh/newsletters/2024/08/09/#bitcoin-core-30285
[news314 mine]: /zh/newsletters/2024/08/02/#optimizing-block-building-with-cluster-mempool
[news331 cluster]: /zh/newsletters/2024/11/29/#bitcoin-core-31122
[news290 incentive]: /zh/newsletters/2024/02/21/#thinking-about-mempool-incentive-compatibility
[news298 cluster]: /zh/newsletters/2024/04/17/#what-would-have-happened-if-cluster-mempool-had-been-deployed-a-year-ago
[news283 trucpin]: /zh/newsletters/2024/01/03/#v3-transaction-pinning-costs-v3
[news284 exo]: /zh/newsletters/2024/01/10/#discussion-about-ln-anchors-and-v3-transaction-relay-proposal-ln-v3
[news285 mev]: /zh/newsletters/2024/01/17/#mev
[news286 lntruc]: /zh/newsletters/2024/01/24/#proposed-changes-to-ln-for-v3-relay-and-ephemeral-anchors-v3
[news286 imtruc]: /zh/newsletters/2024/01/24/#imbued-v3-logic-v3
[news287 sibrbf]: /zh/newsletters/2024/01/31/#kindred-replace-by-fee
[news288 truc0c]: /zh/newsletters/2024/02/07/#v3
[news289 pcmtruc]: /zh/newsletters/2024/02/14/#ideas-for-relay-enhancements-after-cluster-mempool-is-deployed
[news289 oldtruc]: /zh/newsletters/2024/02/14/#what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago-v3
[news301 1p1c]: /zh/newsletters/2024/05/08/#bitcoin-core-28970
[news304 bcc30000]: /zh/newsletters/2024/05/24/#bitcoin-core-30000
[news306 bip431]: /zh/newsletters/2024/06/07/#bips-1541
[news29496]: /zh/newsletters/2024/06/14/#bitcoin-core-29496
[news309 1p1crbf]: /zh/newsletters/2024/06/28/#bitcoin-core-28984
[news313 crittruc]: /zh/newsletters/2024/07/26/#varied-discussion-of-free-relay-and-fee-bumping-upgrades
[news315 crittruc]: /zh/newsletters/2024/08/09/#replacement-cycle-attack-against-pay-to-anchor
[news315 p2a]: /zh/newsletters/2024/08/09/#bitcoin-core-30352
[news330 dust]: /zh/newsletters/2024/11/22/#bitcoin-core-30239
[news333 prclub]: /zh/newsletters/2024/12/13/#bitcoin-core-pr-审核俱乐部
[news283 elftrace]: /zh/newsletters/2024/01/03/#verification-of-arbitrary-programs-using-proposed-opcode-from-matt-matt
[news285 lnhance]: /zh/newsletters/2024/01/17/#lnhance
[news285 64bit]: /zh/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork-64
[news290 64bit]: /zh/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode-64-op-inout-amount
[news306 64bit]: /zh/newsletters/2024/06/07/#updates-to-proposed-soft-fork-for-64-bit-arithmetic
[news291 catvault]: /zh/newsletters/2024/02/28/#simple-vault-prototype-using-op-cat-op-cat
[news293 forkbet]: /zh/newsletters/2024/03/13/#trustless-onchain-betting-on-potential-soft-forks
[news294 btclisp]: /zh/newsletters/2024/03/20/#btc-lisp
[news293 chialisp]: /zh/newsletters/2024/03/13/#overview-of-chia-lisp-for-bitcoiners-chia-lisp
[news331 bll]: /zh/newsletters/2024/11/29/#lisp-dialect-for-bitcoin-scripting
[news331 earmarks]: /zh/newsletters/2024/11/29/#flexible-coin-earmarks
[news302 ctvext]: /zh/newsletters/2024/05/15/#bip119-extensions-for-smaller-hashes-and-arbitrary-data-commitments-bip119
[news305 overlap]: /zh/newsletters/2024/05/31/#should-overlapping-soft-fork-proposals-be-considered-mutually-exclusive
[news306 fecov]: /zh/newsletters/2024/06/07/#functional-encryption-covenants
[newsletters]: /zh/newsletters/
[news306 catfaucet]: /zh/newsletters/2024/06/07/#op-cat-script-to-validate-proof-of-work
[topics index]: /en/topics/
[news315 elftracezk]: /zh/newsletters/2024/08/09/#optimistic-verification-of-zero-knowledge-proofs-using-cat-matt-and-elftrace
[news319 catmillion]: /zh/newsletters/2024/09/06/#opcat-research-fund
[news330 sigactivity]: /zh/newsletters/2024/11/22/#signet-activity-report
[news330 paircommit]: /zh/newsletters/2024/11/22/#update-to-lnhance-proposal
[news330 covgrind]: /zh/newsletters/2024/11/22/#covenants-based-on-grinding-rather-than-consensus-changes
[news333 covpoll]: /zh/newsletters/2024/12/13/#poll-of-opinions-about-covenant-proposals
[news307 bcc29496]: /zh/newsletters/2024/06/14/#bitcoin-core-29496
[news325 mining]: /zh/newsletters/2024/10/18/#bitcoin-core-30955
[news315 shares]: /zh/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[news333 dnsbolt]: /zh/newsletters/2024/12/13/#bolts-1180
[news306 dnsblip]: /zh/newsletters/2024/06/07/#blips-32
[news292 bip21]: /zh/newsletters/2024/03/06/#updating-bip21-bitcoin-uris-bip21-bitcoin-uri
[news307 bip353]: /zh/newsletters/2024/06/14/#bips-1551
[news306 bip21]: /zh/newsletters/2024/06/07/#proposed-update-to-bip21
[news329 dnsimp]: /zh/newsletters/2024/11/15/#ldk-3283
[news303 bip2]: /zh/newsletters/2024/05/17/#continued-discussion-about-updating-bip2
[news322 newbip2]: /zh/newsletters/2024/09/27/#draft-of-updated-bip-process
[news306 testnet]: /zh/newsletters/2024/06/07/#bip-and-experimental-implementation-of-testnet4
[news315 testnet4imp]: /zh/newsletters/2024/08/09/#bitcoin-core-29775
[news315 testnet4bip]: /zh/newsletters/2024/08/09/#bips-1601
[news309 sptweak]: /zh/newsletters/2024/06/28/#bips-1620
[news326 sppsbt]: /zh/newsletters/2024/10/25/#draft-bip-for-sending-silent-payments-with-psbts-psbt-bip
[news327 sppsbt]: /zh/newsletters/2024/11/01/#draft-bip-for-dleq-proofs
[news303 bitvmx]: /zh/newsletters/2024/05/17/#alternative-to-bitvm
[news303 aut]: /zh/newsletters/2024/05/17/#anonymous-usage-tokens
[news321 utxozk]: /zh/newsletters/2024/09/20/#proving-utxo-set-inclusion-in-zero-knowledge
[news304 lnup]: /zh/newsletters/2024/05/24/#upgrading-existing-ln-channels
[news309 stfu]:  /zh/newsletters/2024/06/28/#bolts-869
[news326 ann1.75]: /zh/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal-1-75
[news304 minecash]: /zh/newsletters/2024/05/24/#challenges-in-rewarding-pool-miners
[news310 msbip]: /zh/newsletters/2024/07/05/#bips-1610
[news304 msbip]: /zh/newsletters/2024/05/24/#proposed-miniscript-bip-miniscript-bip
[news333 deplete]: /zh/newsletters/2024/12/13/#insights-into-channel-depletion
[news307 quant]: /zh/newsletters/2024/06/14/#draft-bip-for-quantum-safe-address-format
[news317 blip39]: /zh/newsletters/2024/08/23/#blips-39
[news319 merkle]: /zh/newsletters/2024/09/06/#mitigating-merkle-tree-vulnerabilities
[news292 merkle]: /zh/newsletters/2024/03/06/#bitcoin-core-29412
[news332 zmwarp]: /zh/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
[news302 utreexod]: /zh/newsletters/2024/05/15/#release-of-utreexod-beta-utreexod
[news301 lamport]: /zh/newsletters/2024/05/08/#consensusenforced-lamport-signatures-on-top-of-ecdsa-signatures-ecdsa-lamport
[news314 hyperion]: /zh/newsletters/2024/08/02/#hyperion-network-event-simulator-for-the-bitcoin-p2p-network
[news315 cb]: /zh/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news315 rbfdefault]: /zh/newsletters/2024/08/09/#bitcoin-core-30493
[news329 opr]: /zh/newsletters/2024/11/15/#mad-based-offchain-payment-resolution-opr-protocol
[news315 threshsig]: /zh/newsletters/2024/08/09/#proposed-bip-for-scriptless-threshold-signatures
[news310 musig]: /zh/newsletters/2024/07/05/#bips-1540
[LDK 0.0.119]: /zh/newsletters/2024/01/17/#ldk-0-0-119
[HWI 2.4.0]: /zh/newsletters/2024/01/31/#hwi-2-4-0
[Core Lightning 24.02]: /zh/newsletters/2024/02/28/#core-lightning-24-02
[Eclair v0.10.0]: /zh/newsletters/2024/03/06/#eclair-v0-10-0
[Bitcoin Core 27.0]: /zh/newsletters/2024/04/17/#bitcoin-core-27-0
[BTCPay Server 1.13.1]: /zh/newsletters/2024/04/17/#btcpay-server-1-13-1
[Bitcoin Inquisition 25.2]: /zh/newsletters/2024/05/01/#bitcoin-inquisition-25-2
[Libsecp256k1 v0.5.0]: /zh/newsletters/2024/05/08/#libsecp256k1-v0-5-0
[LDK v0.0.123]: /zh/newsletters/2024/05/15/#ldk-v0-0-123
[Bitcoin Inquisition 27.0]: /zh/newsletters/2024/05/24/#bitcoin-inquisition-27-0
[LND v0.18.0-beta]: /zh/newsletters/2024/05/31/#lnd-v0-18-0-beta
[Core Lightning 24.05]: /zh/newsletters/2024/06/14/#core-lightning-24-05
[HWI 3.1.0]: /zh/newsletters/2024/09/20/#hwi-3-1-0
[Bitcoin Core 28.0]: /zh/newsletters/2024/10/04/#bitcoin-core-28-0
[BTCPay Server 2.0.0]: /zh/newsletters/2024/11/01/#btcpay-server-2-0-0
[Libsecp256k1 0.6.0]: /zh/newsletters/2024/11/08/#libsecp256k1-0-6-0
[BDK 0.30.0]: /zh/newsletters/2024/11/29/#bdk-0-30-0
[Eclair v0.11.0]: /zh/newsletters/2024/12/06/#eclair-v0-11-0
[Core Lightning 24.11]: /zh/newsletters/2024/12/13/#core-lightning-24-11
[Human Rights Foundation]: https://hrf.org
