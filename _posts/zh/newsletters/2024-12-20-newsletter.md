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
  * [共识漏洞清理](#consensuscleanup)
  * [重塑 BIP 流程](#bip2reform)
  * [入账路由费](#inboundrouting)
  * [准区块](#weakblocks)
  * [重启测试网](#testnet)
  * [开发者被逮捕](#devarrests)
* May
  * [静默支付](#silentpayments)
  * [BitVMX](#bitvmx)
  * [匿名使用的 token](#aut)
  * [闪电通道升级](#lnup)
  * [为参加矿池的矿工设计的 Ecash](#minecash)
  * [Miniscript 规范](#miniscript)
  * [Utreexo 的 beta 版](#utreexod)
* June
  * [闪电支付的可行性与通道耗竭](#lnfeasibility)
  * [抗量子计算的交易签名](#quantumsign)
* July
  * [在 BOLT11 发票中包含盲化路径](#bolt11blind)
  * [门限签名的密钥生成算法 ChillDKG](#chilldkg)
  * [MuSig 和门限签名的 BIP](#musigthresh)
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

## 四月

{:#consensuscleanup}
Antoine Poinsot [回顾][news296 ccsf]了 Matt Corallo 在 2019 年提出的 “共识漏洞清理” 提议；该提议尝试解决最慢区块验证、允许盗窃的时间扭曲攻击，以及影响轻客户端和全节点的[虚假交易漏洞][topic merkle tree vulnerabilities]。Poinsot 也着重指出将在区块高度 198 3702 处影响全节点的[交易 ID 重合][topic duplicate transactions]问题。所有问题都有软分叉解决方案，虽然对最慢区块验证的一项提议修复面临可能会让一些罕见的预签名交易作废的担忧。被提议的其中一项更新在八月和九月获得了重要的[讨论][news319 merkle]，目的是寻找影响轻客户端甚至（有些时候的）全节点的默克尔树漏洞的替代性解决方案。虽然 Bitcoin Core 曾经尽可能缓解了漏洞，一次之前的代码重构放弃了必要的保护，所以 Niklas Gögge 为 Bitcoin Core 编写了尽早检测所有可发现的漏洞并拒绝无效区块的代码。在十二月，讨论[转向][news332 zmwarp]使用共识漏洞清理软分叉来修复[时间扭曲漏洞][topic time warp]的 Zawy-Murch 变体，该变体是在最初为共识清理提议设计的规则在 [testnet4][topic testnet] 上实现之后发现的。

{:#bip2reform}
在关于添加新的 BIP 编辑的讨论过程中反映出了人们[革新 BIP2][news297 bips] 的愿望，该 BIP 指明了现在添加新的 BIP 以及更新现有 BIP 的的流程。讨论[持续][news303 bip2]了几个月；在九月，一份关于更新后的流程的[BIP 草案][news322 newbip2]出现了。


{:#inboundrouting}
LND 引入了[对入账路由费的支持][news297 inbound]，该特性是由 Joost Jager 领头支持的，它让节点可以向从对等节点的某一条通道中收到的支付收取手续费。这可以帮助节点管理流动性，比如向管理不善的节点的入账支付收取更高的手续费。入账路由费是后向兼容的，最初会设置成负值（例如，折扣），从而与更老的节点一起工作。虽然这项提议已经提出很多年了，其它闪电实现出于设计上的顾虑和兼容性问题而抵制这一特性。可以看出，该特性在 LND 中的开发贯穿了一整年。

{:#weakblocks}
Greg Sanders 提出[使用 “准区块（weak block）”][news299 weakblocks] —— 包含的都是有效交易但不具备足够工作量证明的区块 —— 来提高多种交易转发策略和挖矿策略中的[致密区块中继][topic compact block relay]的效率。矿工天然会生成与他们的 PoW 占比成比例的准区块，这些准区块会反映处他们尝试确认的交易。准区块可以抵御滥用，因为它的生产成本也是很高的，从而交易池和缓存都可以更新，无需浪费大量额外的带宽。这可以保证致密区块中继保持高效，甚至在矿工在区块中包含了非标准交易也是如此。准区块也可以解决 “[交易钉死攻击][topic transaction pinning]” 并改善[手续费估计][topic fee estimation]。Sander 的概念验证实现演示了这个想法。

{:#testnet}
Jameson Lopp 在四月开启了一项关于当时的比特币公开[测试网][topic testnet]（testnet3）上的问题，并建议[重启它][news297 testnet]，而且可以使用另一组专用的共识规则。五月，Fabian Jahr [宣布][news306 testnet]了一个 BIP 草案，并提议了 testnet4 的实现。这个 [BIP][news315 testnet4bip] 和 Bitcoin Core 的[实现][news315 testnet4imp]在八月合并。

{:#devarrests}
四月在一个不幸的消息中结束：致力于隐私软件的[两位开发者被逮捕][news300 arrest]。同时，还有至少两家其他公司宣布，因为法律风险，他们希望停止服务美国客户。

<div markdown="1" class="callout" id="cluster">
## 2024 总结：族群交易池

在 2024 年一整年，一项来自 2023 年的[重新设计交易池][news251 cluster]的想法变成了多位 Bitcoin Core 开发者的重点关注。“族群交易池（cluster mempool）” 让交易对一个矿工将要创建的所有区块的影响变得更加容易分析，只要这个矿工的交易池跟本地节点的交易池一摸一样。这可以让交易驱逐变得更加理性，并且可以帮助确定一笔（或者一组）[替代交易][topic rbf]是否比它要替代的交易更优。当前交易池的多种局限性，对许多影响合约式协议（比如闪电通道）的问题（有时会置资金于风险中）有负面影响，族群交易池可以解决这些局限性。

此外，如我们在一月 Abubakar Sadiq Ismail 的帖子中看到的，从族群交易池的设计中产生的工具和洞见，也许可以[改善 Bitcoin Core 的交易手续费估计][news283 fees]。今天，Bitcoin Core 将祖先费率挖矿实现为一种支持 [CPFP 手续费追加][topic cpfp] 的激励兼容方式，但手续费估计是在单体交易的基础上操作的，所以 CPFP 手续费追加不会被考虑在内。族群交易池将交易群组切分为 “分家（chunk）”，并且可以在交易池中同时跟踪这些分家，还可以在被挖掘的区块中定位他们，从而允许优化手续费估计（尤其是，如果 CPFP 相关的技术比如 “[交易包转发][topic package relay]”、“（[P2A][topic ephemeral anchors]）” 以及[外生的手续费支付][topic fee sourcing]获得更多采用的话）。

随着族群交易池项目的成熟，架构师们撰写了多份解释和概述。Suhas Daftuar 在一月给出了一份[概述][news285 cluster]，揭示了该提议所面临的挑战之一：它与现有的 “[CPFP carve-out][topic cpfp carve out]” 规则不兼容。这个三难问题的一种解决方案是，让现有的的 carve-out 的用户选择性使用 “确认前拓扑受限的交易（[TRUC transactions][topic v3 transaction relay]）”，它提供了一组更优的特性。Pieter Wuille 在七月提供了另一份[详细描述][news312 cluster]。该文介绍了基本的原理、提议的算法，并链接了多项 PR。[这些 PR][news315 cluster]中的[几项][news314 cluster]以及[其它][news331 cluster]相关 PR 已经先后合并。

Daftuar 参与到了族群交易池和相关提议（比如 TRUC 交易）的研究和后续思考中。在二月，他[评估][news290 incentive]了多种想法（比如 “手续费率替换”）的激励兼容性，并区分了不同算力占比的矿工的不同激励，并寻找了不能抵制 DoS 但激励兼容的行为。在四月，他[研究][news298 cluster]了如果族群交易池能够早一年部署，会有什么样的影响；他发现，这会允许稍微多一些交易进入交易池，但不会显著影响观察盗的数据中的交易替换，也可能帮助矿工在短期内捕获更多手续费。基于最后一点，Pieter Wuille 在八月为构建区块的矿工介绍了原理以及一种高效的[接近最优的交易选择][news314 mine]算法。
</div>

## 五月

{:#silentpayments}
让 “静默支付（[silent payments][topic silent payments]，SP）”能够被[广泛采用][news304 sp]的工作在今年持续。Josie Baker 开始讨论为 SP 设计一些用在 “待签名的比特币交易（PSBT）” 数据格式中的插件，根据的是 Andrew Toth 的一份规范草案。讨论持续到六月，还评估了[使用 ECDH 碎片运行免信任协作][news308 sp]的想法。此外，Setor Blagogee 为一个旨在[帮助轻客户端接收静默支付][news305 splite]的协议提出了规范草案。基本的 SP 规范在六月经历了少量[调整][news309 sptweak]，并且出现了[两种][news326 sppsbt]提议 PSBT 特性的[ BIP][news327 sppsbt]草案。

{:#bitvmx}
Sergio Demian Lerner 和多位联合作者[发表][news303 bitvmx]了一篇论文，部分基于 [BitVM][topic acc] 背后的观念设计了一种新的虚拟 CPU 架构。这个项目名叫 “BitVMX”，其目标是，让任何能够编程到在已有的 CPU 架构（比如 RISC-V）上的程序的合理执行，都能够得到高效证明。就像 BitVM，BitVMX 并不要求任何共识变更，但它需要一个或多个被指定的参与者作为受信任的验证者。这意味着，多位交互式参与一个合约式协议的用户，可以防止任何一个（和多个）参与者从合约中取出资金，除非该参与者能够成功执行一个由该合约指定的任意程序。

{:#aut}
Adam Gibson  介绍了他开发出来的一种[匿名使用的 token][news303 aut]，允许可以通过密钥路径花费一个 UTXO 的人证明自己可以花费它，且无需揭晓这个 UTXO 是哪一个。他着重指出的一个用法是让闪电通道可以公开，但无需所有者们指明通道背后的具体 UTXO（在当前，这是必需的，为了防止浪费带宽的 DoS 攻击）。Gibson 也创建了一个用作概念验证的论坛，要求提供一个匿名证据来登录 —— 这就创造了一种环境，可以认定每个人都是比特币的持有者，但又无需他们提供关于自己和他们的比特币的任何信息。晚些时候，Hohan Halseth [发布][news321 utxozk]了一个概念验证实现，使用另一种机制实现了绝大部分相同的目标。

{:#lnup}
几年来，闪电网络的开发者一直在讨论修改闪电网络协议，以允许现有的通道在多个方面[升级][topic channel commitment upgrades]。在五月，Carla Kirk-Cohen [测试][news304 lnup]了部分场景，并比较了三种支持升级的提议。最终，一种休眠（quiescence）协议在六月被[添加][news309 stfu]到闪电网络规范中，以帮助升级以及其它敏感的操作。在十月，我们看到一项提议中的、更新通道公告消息的协议的[重新开发][news326 ann1.75]，它将支持新的[基于 taproot 的注资交易][topic simple taproot channels]。

{:#minecash}
Ethan Tueele 在 Delving Bitcoin 论坛中发帖建议矿池可以使用跟矿工的贡献数量成比例的[ecash token 来奖励矿工][news304 minecash]。这样，矿工就可以立即卖出或者转移这些 token，或者，他们可以等矿池挖出一个区块，这时候矿池就会用聪来交换撰写 token。不过，Matt Corallo 提出了一种顾虑：大型矿池还没有实现标准化的支付手段，能让矿工在一个较短的时间间隔内计算出自己可以收到多少钱。这就意味着，如果矿工的主要矿池开始欺诈，他们无法迅速切换到另一个矿池，无论矿池是用 ecash 还是其它手段来支付。

{:#miniscript}
Ava Chow 在五月为 [miniscript][topic miniscript] [提出][news304 msbip]了一份 BIP。该 BIP 在[七月][news310 msbip]被命名为[BIP379][]。

{:#utreexod}
同样在五月，[出现][news302 utreexod] utreexod 的一个 beta 版本；该版本允许用户试用这种最小化硬盘空间要求的全节点设计。

## 六月

{:#lnfeasibility}
René Pickhardt 研究了[闪电网络可行性概率][news309 feas]的估计，办法是分析通道容量内可能的财富分布。比如说，如果 Alice 想要通过 Bob 发 1 BTC 给 Carol，成功率取决于 Alice-Bob 和 Bob-Carol 的通道能否支持这样的资金转移。这一指标突出了实际中的支付能力约束，并且可以帮助钱包软件和商用软件作出更聪明的路由选择、提高闪电支付的成功率。在今年的晚些时候，Pickhardt 的研究为通道耗竭 —— 一条通道变得无法转发特定方向的支付 —— 的原因和概率提供了[洞见][news333 deplete]。该研究也指出 k>2 的多方通道管理协议（比如[通道工厂][topic channel factories]）可以大大提高可行支付的数量、减少通道耗竭的概率。

![Example of channel depletion](/img/posts/2024-12-depletion.png)

{:#quantumsign}
开发者 Hunter Beast [发布][news307 quant]了一份 “粗糙的草稿” BIP， 将版本 3 的隔离见证地址分配给了一种[抗量子计算的签名算法][topic quantum resistance]。这份 BIP 草案链接了多种备选的算法，以及它们的问题和它们的预计链上体积。算法的选择和具体实现细节留待后续讨论。

<div markdown="1" class="callout" id="p2prelay">
## 2024 总结：P2P 交易转发

手续费管理一直是去中心化的比特币协议中的一个挑战，但 LN-Penalty 这样的合约式协议的广泛使用、以及对更新更复杂的协议的持续研究，让交易的手续费管理变得前所未有地重要，因为要保证用户支付手续费并按需要追加手续费。Bitcoin Core 的贡献者们几年来一直在克服这个问题，而在 2024 年，我们看到了多项能够显著改善问题的新特性的公开发行。

一月从一项关于 [TRUC][topic v3 transaction relay] 提议在最差条件下克服[交易钉死攻击][topic transaction pinning]的成本的[讨论][news283 trucpin]开始；相比之前部署的 [CPFP carve-out][topic cpfp carve out] 规则，TRUC 提供了一种更健壮的替代方案。虽然 TRUC 在最差条件下的抗攻击成本低得多，开发者们还是考虑了调整少量参数是否能进一步降低成本。在一月发生的另一项[讨论][news284 exo]则分析了一种理论上的风险：“[外生的手续费支付][topic fee sourcing]” 日益获得更多采用，将让用户直接给矿工[暗箱支付][topic out-of-band fees]在链上操作上更高效（因此也更便宜），从而陷挖矿去中心化于风险之中。Peter Todd 建议使用一种替代性的手续费管理手段来解决这个问题：通过预签名每一笔结算交易在不同费率下的多个版本，保证手续费是完全内生于交易的。然而，人们指出这种办法有多个问题。

一月份还发生了另一项讨论：Gregory Sanders [研究][news285 mev]了在闪电网络协议中将[被修剪得 HTLC][topic trimmed htlc]中的价值放到 [P2A][topic ephemeral anchors] 输出有无风险；这可能会给在挖掘交易池交易的必要软件之外还运行了专用软件的矿工带来 “*矿工可抽取价值*（MEV）”。Bastien Teinturier 开始[讨论][news286 lntruc]闪电网络协议处理使用 TRUC 和 P2A 输出的承诺交易所需的必要变更；这包括 Sanders 所考虑的修建 HTLC 提议、消除不再必要的 1 区块时延，以及减少链上交易体积。这一讨论也引出了一种 “[渗透式 TRUC][news286 imtruc]” 提议：自动对看起来像是闪电网络现有 CPFP carve-out 用法的交易应用 TRUC 规则，从而提供 TRUC 的好处、无需闪电网络软件升级。

在一月结束的时候，Golria Zhao 为 “[亲属间手续费替代][topic kindred rbf]” 提出了一份[提议][news287 sibrbf]。常规的[RBF][topic rbf]规则只应用在相互冲突的交易上、在一个节点决定要接受一笔交易某个版本的时候，因为最终只有一个版本能进入有效的区块链。然而，在 TRUC 中，一个节点只会接受一笔未确认的版本 3 父交易的一个子交易，非常类似于处理冲突交易的情形。允许一笔子交易替代同一父交易的另一笔子交易 —— 即，*亲属驱逐* —— 将改善 TRUC 交易的手续费支付，尤其在渗透式 TRUC 被采用的情况下，非常有好处。

二月份的起始是关于将闪电网络协议从 CPFP carve-out 迁移到 TRUC 的后果的额外讨论。Matt Corallo 发现了现有的[零确认的通道开启操作][topic zero-conf channels]在使用 TRUC 时会面临的[挑战][news288 truc0c]：注资交易和一笔紧随其后的关闭交易可能都是未确认的， 这就阻止了包含 CPFP 手续费追加的第三笔交易被使用，因为 TURC 限制智能使用两笔未确认的交易。Teinturier 指出，在形成一条 “[通道拼接][topic splicing]” 的链条时，也有类似的问题。这项讨论一直没有得到一个清晰的结论，但一个迂回的解决方案 —— 保证每一笔交易都包含一个自身的锚点输出、用于 CPFP 手续费追加（就像在使用 TRUC 之前要求的那样）—— 似乎已经能够解决问题，同时，每个人都希望[族群交易池][topic cluster mempool]可以在未来放宽 TRUC 的一些要求，并允许更加灵活的 CPFP 手续费支付。 

关于由族群交易池进步可以带来的 TRUC 规则变更的话题，Gregory Sanders 介绍了关于[未来的规则变更][news289 pcmtruc]的多种想法。相对应的是，Suhas Daftuar [分析][news289 oldtruc]了他的节点在过去一年中收到的所有交易，以检验渗透式 TURC 规则会如何影响这些交易的接纳。大部分在 CPFP carve-out 规则下被交易池接纳的交易，在一种渗透式 TRUC 规则下也会被接纳，但也有少数例外，可能要求软件在采用渗透式规则之前改变。 

经历了年初的讨论丰收之后，五月和六月出现了一系列的 PR 合并，为 Bitcoin Core 带来了对新的交易转发特性的支持。一种[受限形式][news301 1p1c]的 “一父一子（1p1c）”[交易包转发][topic package relay]规则 —— 不要求对 P2P 协议的任何变更 —— 被添加到了 Bitcoin Core 中。[一项后续的合并][news304 bcc30000]通过加强 Bitcoin Core 对故而交易的处理，提高了 1p1c 交易包转发的可靠性。TRUC 规范作为 [BIP431][] 被[合并到了 BIP 仓库][news306 bip431]。TRUC 交易也因为[另一次合并][news307 bcc29496]而变成默认可转发的。对 1p1c 族群（包括 TRUC 交易包）的 [RBF][topic rbf] 的支持也[加入了][news309 1p1crbf]。

两位长期的开发者在七月提出了对 TRUC 的[延伸批评][news313 crittruc]，虽然其他开发者回应了他们的顾虑。这两位开发者在八月又提出了[进一步批评][news315 crittruc]。

Bitcoin Core 的开发者们继续开发交易转发的优化、在八月合并对 “[支付到锚点][topic ephemeral anchors]（P2A）” 标准化输出的[支持][news315 p2a]，并在十月发布 Bitcoin Core 28.0；该版本支持 1p1c 交易包转发、TRUC 交易转发、交易包 PBF 以及亲属替代，还有一种标准化的 P2A 输出脚本类型。作为所有这些特性的开发贡献者，Gregory Sanders [建议][news324 guide] 了钱包软件和其他软件的开发者如何使用 Bitcoin Core 来创建和广播可以利用这些新功能的交易。 

晚些时候，对使用 P2A 的%#192%#输出的支持也在一次[合并][news330 dust]中变得标准化。这让一笔支付零手续费的交易也可以靠一笔子交易来支付所有相关的手续费 —— 这是一种完全外生的[手续费来源][topic fee sourcing]。

Optech 在今年的最后一期常规周报总结了一次 Bitcoin Core PR 审核俱乐部的[会议][news333 prclub]，人们在会上讨论了对 1p1c 交易包转发的进一步优化。
</div>

## July

{:#bolt11blind}
Elle Mouton 提出了一项 BLIP，[向 BOLT11 发票添加一个盲化路径字段][news310 path]，从而允许支付的接收者隐藏自己的身份和通道对手。比如说，Bob 可以添加一条盲化路径到他的发票中，然后 Alice 能够私密地给他支付，如果她的软件支持的话，不然，她会收到一条报错。Mouton 认为这是一种在 [offer][topic offers]（原生支持盲化路径）得到广泛采用之前的过渡解决方案。这份提议在[八月][news317 blip39]变成了 [BLIP39][]。

{:#chilldkg}
Tim Ruffing 和 Jonas Nick 提出了 ChillDKH，这是一个 BIP 草案和参考实现，用于为兼容比特币 [Schnorr 签名][topic schnorr signatures] 的 [FROST 类型的无脚本门限签名方案安全地生成密钥][news312 chilldkg]。ChillDKG 结合了为 FROST 设计的一种著名的密钥生成算法以及前沿的密码学原语，以在参与者之间安全地分享随机密钥元素，同时保证完整性和抗审查性。它使用基于椭圆曲线的 Diffie Hellman 密钥交换（ECDH）来加密和运行带有身份验证的广播，以验证签过名的会话记录。参与者们在接受最终的公钥前要确认会话的完整性。这一协议简化了密钥管理，仅要求用户备份自己的秘密种子以及一些不敏感的复原数据。使用种子来加密复原数据的方案旨在加强隐私性并进一步简化用户的备份手续。

{:#musigthresh}
在七月，多项帮助不同软件交互以创建 [MuSig2][topic musig] 签名的 BIP [合并][news310 musig]。同一个月的晚些时候，Sivaram Dhakshinamoorthy [宣布][news315 threshsig] 了用于为比特币的 [Schnorr 签名][topic schnorr signatures] 创建无脚本[门限签名][topic threshold signature]的 BIP 提议。这让一组已经执行过一次初始化流程（例如使用 ChillDKG）的签名者可以安全地创建签名，只要求这些签名者的一个动态的子集的交互。这个签名在链上跟 单签名用户/无脚本多签名用户 所创建的 Schnorr 签名是无法区分的，可以提高隐私性和货币同质性。

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
[news307 quant]: /zh/newsletters/2024/06/14/#draft-bip-for-quantumsafe-address-format-bip
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
