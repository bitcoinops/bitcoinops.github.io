---
title: 'Bitcoin Optech Newsletter #385：2025 年度回顾特刊'
permalink: /zh/newsletters/2025/12/19/
name: 2025-12-19-newsletter-zh
slug: 2025-12-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh

excerpt: >
  本期 Bitcoin Optech 年度回顾特刊（第八期）总结了 2025 年比特币领域的值得关注的发展。
---

{{page.excerpt}} 这是继我们对 [2018][yirs 2018]、[2019][yirs 2019]、[2020][yirs 2020]、[2021][yirs 2021]、[2022][yirs 2022]、[2023][yirs 2023] 和 [2024][yirs 2024] 的年度总结之后的续篇。

## 目录

* 一月
  * [更新的 ChillDKG 草案](#chilldkg)
  * [链下 DLC](#offchaindlcs)
  * [致密区块重构](#compactblockstats)
* 二月
  * [Erlay 进展更新](#erlay)
  * [闪电网络临时锚点脚本](#lneas)
  * [概率支付](#probpayments)
* 三月
  * [比特币分叉指南](#forkingguide)
  * [用于防止 MEV 集中化的私有区块模板市场](#templatemarketplace)
  * [使用可销毁输出的闪电网络预付和保留手续费](#lnupfrontfees)
* 四月
  * [用于初始区块下载的 SwiftSync 加速](#swiftsync)
  * [DahLIAS 交互式聚合签名](#dahlias)
* 五月
  * [族群交易池](#clustermempool)
  * [提高或移除 Bitcoin Core 的 OP_RETURN 大小限制](#opreturn)
* 六月
  * [计算自私挖矿危险阈值](#selfishmining)
  * [使用 addr 消息对节点进行指纹识别](#fingerprinting)
  * [混淆锁（garbled locks）](#garbledlocks)
* 七月
  * [链码委托](#ccdelegation)
* 八月
  * [Utreexo BIP 草案](#utreexo)
  * [降低最小中继费率](#minfeerate)
  * [对等节点区块模板共享](#templatesharing)
  * [对比特币与闪电网络实现进行差分模糊测试](#fuzzing)
* 九月
  * [Simplicity 设计细节](#simplicity)
  * [利用 BGP 劫持进行分区与日蚀攻击](#eclipseattacks)
* 十月
  * [关于任意数据的讨论](#arbdata)
  * [通道阻塞缓解的仿真结果与更新](#channeljamming)
* 十一月
  * [比较 OpenSSL 与 libsecp256k1 的 ECDSA 签名验证性能](#secpperformance)
  * [按传播延迟与挖矿集中度对陈旧率建模](#stalerates)
  * [BIP3 与 BIP 流程](#bip3)
  * [引入 Bitcoin Kernel C API](#kernelapi)
* 十二月
  * [拼接](#lnsplicing)
* 专题总结
  * [漏洞披露](#vulns)
  * [量子计算](#quantum)
  * [软分叉提案](#softforks)
  * [Stratum v2](#stratumv2)
  * [主流基础设施项目的主要发布](#releases)
  * [Bitcoin Optech](#optech)

---

## 一月

{:#chilldkg}

- **<!--updated-chilldkg-draft-->更新的 ChillDKG 草案：** Tim Ruffing 和 Jonas Nick [更新][news335 chilldkg]了他们针对 FROST [门限签名][topic threshold signature]方案的分布式密钥生成协议（DKG）的工作。ChillDKG 旨在提供跟现有的描述符钱包相似的可恢复功能。

{:#offchaindlcs}

- **<!--offchain-dlcs-->链下 DLC：** 开发者 Conduition [发布][news offchain dlc]了一种新的链下 DLC（[谨慎日志合约][topic dlc]）机制，使参与者能够协作创建和扩展 DLC 工厂，允许迭代 DLC 持续运行，直到一方选择在链上解决。这与[之前的工作][news dlc channels]形成对比，之前的链下 DLC 在每次合约展期时都需要交互。

{:#compactblockstats}

- **<!--compact-block-reconstructions-->致密区块重建：** 一月份还出现了 2025 年多个重新审视[之前研究][news315 compact blocks]的项目中的第一个，研究比特币节点如何使用[致密区块中继][topic compact block relay]（BIP152）有效地重建区块，更新了之前的测量并探索了潜在的改进。[一月份发布][news339 compact blocks]的更新统计数据显示，当交易池满时，节点更频繁地需要请求缺失的交易。孤块解析不佳被认为是可能的原因，并已经进行了[一些改进][news 338]。

  在今年晚些时候，分析研究了[致密区块预填充策略][news365 compact blocks]是否能进一步提高重建成功率。测试表明，有选择地预先填充那些更可能在对端节点交易池中缺失的交易，可以在只付出适度的带宽代价的情况下，减少对回退请求（fallback requests）的依赖。后续研究增加了这些额外的测量，并在调整[监控节点最低中继费率](#minfeerate)的前后，更新了[真实世界中的重建测量][news382 compact blocks]的结果，显示具有较低 `minrelayfee` 的节点具有更高的重建率。作者还[发布][news368 monitoring]了关于其监控项目背后架构的内容。

## 二月

{:#erlay}

- **<!--erlay-update-->Erlay 更新：** Sergi Delgado 今年就他在 Bitcoin Core 中实现 [Erlay][erlay] 的工作和进展发表了[多篇帖子][erlay optech posts]。在第一篇帖子中，他概述了 Erlay 提案以及当前交易中继机制（“扇出 / fanout”）的工作原理。在这些帖子中，他讨论了在开发 Erlay 时发现的不同结果，例如[基于交易知识的过滤][erlay knowledge]并不像预期的那样有影响力。他还尝试选择[应该接收扇出的对等节点数量][erlay fanout amount]，发现 8 个出站对等节点可节省 35% 的带宽，12 个出站对等节点可节省 45%，但也发现延迟增加了 240%。在另外两个实验中，他确定了[基于交易接收方式的扇出速率][erlay transaction received]以及[何时选择候选对等节点][erlay candidate peers]。这些实验结合了扇出式广播与集合对账（fanout and reconciliation），帮助他确定何时使用何种方法。

{:#lneas}

- **<!--ln-ephemeral-anchor-scripts-->LN 临时锚点脚本：** 在 [Bitcoin Core 28.0 的交易池策略][28.0 wallet guide]经历了多次更新之后，二月份开始围绕 LN 承诺交易中[临时锚点输出][topic ephemeral anchors]的设计选择展开了讨论。贡献者[研究][news340 lneas]了在基于 [TRUC][topic v3 transaction relay] 的承诺交易中，应该采用哪种脚本构造作为其中一个输出，以替代现有的[锚点输出][topic anchor outputs]。

  权衡包括：不同脚本如何影响 [CPFP][topic cpfp] 手续费追加、交易重量，以及在锚点输出不再需要时，能否安全地花费或丢弃这些锚点输出。[持续的讨论][news341 lneas]强调了与交易池策略和闪电网络安全假设的相互作用。

{:#probpayments}

- **<!--probabilistic-payments-->概率支付：** Oleksandr Kurbatov 在 Delving Bitcoin 上引发了一场[讨论][delving random]，讨论从比特币脚本中产生随机结果的方法。[原始][ok random]方法在挑战者/验证者安排中使用零知识证明，并且现已[发布了概念验证][random poc]。还讨论了其他方法，[包括一种][waxwing random]利用 taproot 的树结构的方案，以及一种通过脚本对由一系列不同哈希函数表示的比特位进行异或（XOR）运算，从而直接生成不可预测比特串的[方法][rl random]。[讨论][dh random]还涉及：这种随机交易结果是否可以用于产生概率型 HTLC，作为 LN 小额支付中[裁剪 HTLC][topic trimmed htlc]的替代方案。

<div markdown="1" class="callout" id="vulns">

## 2025 年终总结：漏洞披露

2025 年，Optech 总结了十多个漏洞披露。漏洞报告帮助开发者和用户从过去的错误中学习，而[负责任的披露][topic responsible disclosures]确保在漏洞被利用之前发布修复程序。

_注意：只有当我们认为漏洞发现者已做出合理努力、尽可能降低对用户造成伤害的风险时，Optech 才会公布其姓名。我们感谢本节提到的所有个人，他们展现了洞见，并对用户安全有明确而真切的关注。_

一月初，Yuval Kogman [公开披露][news335 coinjoin]了当前版本的 Wasabi 和 Ginger 使用的中心化 [coinjoin][topic coinjoin] 协议中长期存在的多个去匿名化弱点，以及过去版本的 Samourai、Sparrow 和 Trezor Suite 中的问题。如果被利用，中心化协调器可以将用户的输入与输出关联起来，从而有效地消除 coinjoin 的预期隐私优势。2024 年底也报告了类似的漏洞（见 [周报 #333][news333 coinjoin]）。

一月底，Matt Morehouse [宣布][news339 ldk]负责任地披露了 LDK 在处理具有多个待处理 [HTLC][topic htlc] 的单方面关闭时的索赔处理漏洞。LDK 旨在通过批量处理多个 HTLC 来降低费用；然而，如果与通道对手方的已确认交易发生冲突，LDK 可能无法更新所有受影响的批次，导致资金卡住甚至存在被盗风险。此问题已在 LDK 0.1 中修复。

同一周，Antoine Riard [披露][news339 cycling]了一个使用[替代循环][topic replacement cycling]攻击的额外漏洞。攻击者可以通过[钉死][topic transaction pinning]受害者的未确认交易、接收但不传播受害者的手续费追加替代交易，然后选择性地挖出受害者的最高手续费版本来利用它。这种场景需要罕见的条件，并且很难在不被发现的情况下持续进行。

二月，Morehouse [披露][news340 htlcbug]了第二个 LDK 漏洞：如果许多 HTLC 具有相同的金额和支付哈希，LDK 将无法结算除一个之外的所有 HTLC，被迫对通道执行强制关闭。虽然这不会直接导致盗窃，但会导致额外费用和路由收入减少，直到该错误在 LDK 0.1.1 中修复（见 周报 [#340][news340 htlcfix]）。

三月，Morehouse [宣布][news344 lnd]负责任地披露了 0.18 版本之前的 LND 中已修复的漏洞：如果攻击者与受害者有通道连接，并且能够以某种方式导致受害者的节点重启，就可以使 LND 同时支付和退款同一个 HTLC。这将允许攻击者窃取几乎整个通道价值。该披露还突出了闪电网络规范中的漏洞，这些漏洞后来得到了纠正（见 [周报 #346][news346 bolts]）。

五月，Ruben Somsen [描述][news353 bip30]了一个与 BIP30 对[重复][topic duplicate transactions]coinbase 交易的历史处理方式相关的、理论上的共识失败边界情形。随着 Bitcoin Core 移除检查点（见 [周报 #346][news346 checkpoints]），如果发生一次极端的区块重组（reorg），回滚深至区块 91842，那么节点可能会因为是否曾观察到这些重复 coinbase 而产生不同的 UTXO 集，从而出现分歧。讨论了几种解决方案，例如为这两个例外情况硬编码额外的特殊情况逻辑；不过整体并未被认为是现实可行的威胁。

同样在五月，Antoine Poinsot [宣布][news354 32bit]负责任地披露了影响 29.0 版本之前的 Bitcoin Core 版本的低严重性漏洞，过量的地址通告（address advertisements）可能导致一个 32 位标识符溢出，从而使节点崩溃。早期的缓解措施已经使得在默认对等节点限制下利用漏洞变得不切实际地缓慢（见周报 [#159][news159 32bit] 和 [#314][news314 32bit]），并且通过在 Bitcoin Core 29.0 中切换到 64 位标识符完全解决了该问题。

七月，Morehouse [宣布][news364 lnd]负责任地披露了 LND 的拒绝服务问题，攻击者可以反复请求历史[Gossip][topic channel announcements]消息，直到节点耗尽内存并崩溃。此错误已在 LND 0.18.3 中修复（见 [周报 #319][news319 lnd]）。九月，Morehouse [披露][news373 eclair]了旧版本 Eclair 中的漏洞：攻击者可以广播旧的承诺交易以窃取通道中的所有当前资金，而 Eclair 会忽略它。Eclair 的修复配备了更全面的测试套件，旨在捕获类似的潜在问题。

十月，Poinsot [发布][news378 four]了四个低严重性、负责任披露的 Bitcoin Core 漏洞，涵盖两个磁盘填充错误、一个影响 32 位系统的极不可能的远程崩溃，以及未确认交易处理中的 CPU DoS 问题。这些问题在 29.1 中部分修复，在 30.0 中完全修复，详见周报[#361][news361 four]、[#363][news363 four] 和 [#367][news367 four] 以了解一些修复。

十二月，Bruno Garcia [披露][news383 nbitcoin]了 NBitcoin 库中与 `OP_NIP` 相关的、理论上的共识失败问题：在某个“栈容量达到上限”的边界情况下，可能触发异常。该问题通过差分模糊测试（differential fuzzing）发现，并很快得到修补。目前未知有任何全节点使用 NBitcoin，因此该披露在实践中并不存在导致链分裂（chain split）的风险。

十二月，Morehouse 还[披露][news384 lnd]了 LND 中的三个关键漏洞，包括两个资金盗窃漏洞和一个拒绝服务漏洞。

</div>

## 三月

{:#forkingguide}

- **<!--bitcoin-forking-guide-->****比特币分叉指南:** Anthony Towns 在 Delving Bitcoin 上发布了一份[指南][news344 fork guide]，
  探讨如何 为比特币共识规则的变更建立社区共识。根据 Towns 的观点，建立共识的过程可以分为四个步骤：[研究与开发][fork guide red]、[资深用户（Power User）探索][fork guide pue]、[行业评估][fork guide ie]以及[投资者审查][fork guide ir]。不过，Towns 提醒读者，该指南旨在提供一个高层级的流程参考，且仅在协作环境下才有效。

{:#templatemarketplace}

- **<!--private-block-template-marketplace-to-prevent-centralizing-mev-->****预防 MEV 中心化的私有区块模板市场:**开发者 Matt Corallo
  和 7d5x9 在 Delving Bitcoin 上发布了一项[提案][news344 template mrkt]，旨在防止未来“MEVil”（一种会导致挖矿中心化的矿工可提取价值 MEV）在比特币上泛滥。该提案被称为 [MEVpool][mevpool gh]，允许各方在公开市场中对矿工区块模板内的特定空间进行竞价（例如：“只要交易 Y 排在任何与智能合约 Z 交互的交易之前，我愿意支付 X [BTC]”）

  虽然区块模板内的优先交易排序服务预计仅由大型矿工提供（这会导致中心化），但这种去信任的公开市场将允许任何矿工基于“盲化区块模板（Blinded block templates）”工作——在矿工产生足够的算力证明（PoW）以发布区块之前，完整的交易内容对矿工是不可见的。作者警告称，该提案需要多个市场竞争，以防止单一受信任市场主导，从而维护去中心化。

{:#lnupfrontfees}

- **<!--ln-upfront-and-hold-fees-using-burnable-outputs-->****利用可销毁输出实现的 LN 预付及持有费:** John Law 针对
  [通道阻塞攻击.（Channel Jamming Attacks）][topic channel jamming attacks]提出了一种[解决方案][news 347 ln fees]。该攻击是闪电网络协议的一个弱点，攻击者可以无成本地阻止其他节点使用其资金。该提案总结了他撰写的[论文][ln fees paper]，探讨了闪电网络节点在转发支付时收取两种额外费用的可能性：预付费（Upfront fee）和持有费（Hold fee）。最终支付者将支付前者，以补偿转发节点因临时占用 [HTLC][topic htlc] 槽位而产生的成本；而后者将由任何延迟 HTLC 结算的节点支付，费用金额随延迟时长增加。

## 四月

{:#swiftsync}

- **<!--swiftsync-speedup-for-initial-block-download-->****SwiftSync 加速全节点区块同步:** Sebastian Falbesoner 在 Delving Bitcoin
  上[发布][news349 swiftsync]了一个示例实现，结果显示通过 SwiftSync 可将“初始区块下载”（IBD）速度提升 5 倍以上。该想法最初由 Ruben Somsen [提出][swiftsync ruben gh]。

  这种提速是在 IBD 期间实现的，原理是仅在 UTXO（未花费交易输出）于 IBD 结束时仍将存在于 UTXO 集中时，才将其添加到该集合中。关于最终 UTXO 集状态的这种“先验知识”被紧凑地编码在一个最小信任的预生成提示（Hints）文件中。除了最小化链状态（Chainstate）操作的开销外，SwiftSync 还通过允许并行区块校验进一步提升了性能。

  Rust版本的开发工作已于 9 月[宣布][swiftsync rust impl]。

{:#dahlias}

- **<!--dahlias-interactive-aggregate-signatures-->****DahLIAS 交互式聚合签名:** 4 月，Jonas Nick、Tim Ruffing 和 Yannick Seurin
  在Bitcoin-Dev 邮件列表中[公布][news351 dahlias]了他们的 [DahLIAS 论文][dahlias paper]。这是第一个与比特币现有密码学原语兼容的 64 字节交互式聚合签名方案。聚合签名是实现[跨输入签名聚合][topic cisa]（CISA）的密码学前提。CISA 是对比特币的一项提议功能，可以减小多输入交易的体积，从而降低包括 [CoinJoins][topic coinjoin] 和 [PayJoins][topic payjoin] 在内的多种支出类型的成本。

<div markdown="1" class="callout" id="quantum">

## 2025 年度总结：量子计算

随着人们日益关注未来量子计算机可能削弱或破解比特币所依赖的椭圆曲线离散对数（ECDL）硬度假设（比特币用其证明代币所有权），这一年出现了多次讨论和提案，旨在讨论并减轻这种发展带来的影响。

Clara Shikhelman 和 Anthony Milton [发表][news357 quantum report]了一篇论文，涵盖了量子计算对比特币的影响，并概述了潜在的缓解策略。

[BIP360][] 获得了[更新][news bip360 update]并被正式授予 BIP 编号。该提案作为比特币实现量子加固的第一步，以及针对不需要内部公钥的 Taproot 使用场景的优化，引起了广泛关注。今年内的随后[研究][news365 quantum taproot]证实了这些 Taproot 承诺（Commitments）具有防御量子计算机操纵的安全性。年底，该提案更名为 P2TSH（Pay to Tapscript Hash），取代了早期的 P2QRH（Pay to Quantum Resistant Hash），反映了其范围的缩减和通用性的提升。

Jesse Posner [强调了现有研究][news364 quantum primatives]，指出比特币现有的原语——如分层确定性（HD）钱包、[静默支付（Silent Payments）][topic silent payments]、密钥聚合和[门限签名][topic threshold signature]——可能与一些常见的抗量子签名算法兼容。

Augustin Cruz [提议][news qr cruz]了一项 BIP，旨在彻底销毁那些具有确定性量子漏洞的钱币。随后，Jameson Lopp [发起了一场讨论][news qr lopp1]，探讨应如何处理易受量子攻击的代币，产生的想法从“任由量子攻击者获取”到“直接销毁”不等。Lopp 随后[提出][news qr lopp2]了一套具体的[软分叉序列][BIPs #1895]，比特币可以在密码学相关量子计算机（CRQC）开发完成前很久就开始实施，以逐步减轻量子对手突然获取大量钱币的威胁，同时给持有者留出安全转移资金的时间。

有两项提案（[1][news qr sha], [2][news qr cr]）被提出，旨在让大多数现有钱币能够以某种方式锁定，以便在比特币未来禁用量子漏洞支出时仍能恢复。简而言之，理论上的事件序列是：0）比特币持有者确保其当前钱包拥有某个支出路径所需的哈希机密；1）CRQC 显示即将出现；2）比特币禁用椭圆曲线签名；3）比特币启用抗量子签名方案；4）比特币启用这些提案之一，允许已做准备的持有者申领其易受量子攻击的钱币。根据具体实现，任何地址类型（包括带有 Scriptpath 的 P2TR）都可以利用这些方法。

开发者 Conduition 证明了 [`OP_CAT`][BIP347] 可用于实现 Winternitz 签名，这种方案提供了抗量子的签名检查，每个输入的成本约为 2000 vbytes。这比之前[提议][rubin lamport]的基于 `OP_CAT` 的 [Lamport 签名][lamport]成本更低。

Matt Corallo 围绕在 [Tapscript][topic tapscript] 中添加抗量子签名校验操作码的通用想法发起了[讨论][news qr corallo]。随后，Abdelhamid Bakhta [提议][abdel stark]将原生 STARK 验证作为此类操作码之一，Conduition 则[撰文][conduition sphincs]介绍了他们在优化 SLH-DSA (SPHINCS) 抗量子签名方面的进展。任何添加到 Tapscript 的抗量子签名校验操作码（包括 `OP_CAT`）都可以与 [BIP360][] 结合，从而实现对比特币输出的全面量子加固。

Tadge Dryja [提议][news qr agg]了一种比特币实现通用跨输入签名聚合的方法，这可以部分缓解后量子签名体积庞大的问题。

年底，Mikhail Kudinov 和 Jonas Nick [发表][nick paper tweet]了一篇[论文][hash-based signature schemes]，概述了基于哈希的签名方案，并讨论了如何调整这些方案以适应比特币的需求。

</div>

## 五月

{:#clustermempool}

- **<!--cluster-mempool-->族群交易池：** 年初，Stefan Richter 通过[发现][news340 richter ggt]一篇 1989 年研究论文中关于 _最大比率闭包问题_ 的高效算法可以用于族群线性化，从而引发了不少期待。Pieter Wuille 当时已经在研究一种线性规划方法，作为对最初“候选集搜索”方案的潜在改进，并把基于最小割（min-cut）的方案作为第三种选项纳入研究。稍后，Wuille 在 Bitcoin Core PR Review Club 上[讲解了][news341 pr-review-club txgraph]新引入的 `TxGraph` 类，它将交易提炼为交易重量、手续费与相互关系，以便高效地与交易池图交互。5 月，Wuille 发布了三种族群线性化方案的基准测试并说明其[权衡][news352 wuille linearization techniques]，结论是：两种更高级的方案都远比简单的候选集搜索高效，但他基于线性规划的“生成森林线性化（spanning-forest linearization）”算法在实用性上优于基于最小割的方法。秋季，Abubakar Sadiq Ismail [描述了][news377 ismail template improvement]族群交易池如何可用于追踪：交易池内容何时相较于某个先前的区块模板已经显著改善。接近年末时，族群交易池的实现[完成][news382 cluster mempool completed]，为随 Bitcoin Core 31.0 发布做好准备。将初始的候选集搜索线性化算法替换为生成森林线性化算法的工作仍在进行中。

{:#opreturn}

- **<!--increasing-or-removing-bitcoin-core-s-op-return-policy-limit-->****提高或移除 Bitcoin Core 的 OP_RETURN 策略限制：** 4 月，协议开发者发现，在某些情形下，OP_RETURN 输出的策略限制会造成一种不良激励：促使人们把数据嵌入支付输出中。此外，开发者也观察到该策略最初的动机已经被网络发展所“超越”，因此出现了一个提议：移除 OP_RETURN 的交易池策略限制。这一提议引发了激烈的[辩论][news352 OR debate]，讨论焦点包括交易池策略的有效性、比特币的目的，以及比特币开发者在“监管或避免监管比特币使用方式”方面应承担的责任。Bitcoin Core 贡献者认为，经济激励使得 OP_RETURN 输出不太可能出现大幅增加，因此这项改动更像是在修复激励漏洞；而批评者则将移除限制解读为对数据嵌入行为的背书，不过他们也同意从经济角度看，用这种方式嵌入数据并不划算。最终，Bitcoin Core 30.0 版本带来了[更新后的策略][Bitcoin Core #32406]：允许出现多个 OP_RETURN 输出，并移除对 OP_RETURN 输出脚本大小的策略限制。在该版本发布之后，又出现了若干软分叉提案，主张在共识层面[抑制数据嵌入](#arbdata)。

## 六月

{:#selfishmining}

- **<!--calculating-the-selfish-mining-danger-threshold-->****计算自私挖矿危险阈值：** Antoine Poinsot 基于 2013 年提出并命名该利用方式的[论文][selfish miner paper]，对[自私挖矿攻击][topic selfish mining]背后的数学给出了[深入解释][news358 selfish miner]。Poinsot 重点复现了论文的一个结论：控制全网总算力 33% 的不诚实矿工，可以通过选择性地延迟宣布自己挖到的部分新区块，使其收益略高于其余矿工。

{:#fingerprinting}

- **<!--fingerprinting-nodes-using-addr-messages-->****使用 addr 消息对节点进行指纹识别：** 开发者 Daniela Brozzoni 和 Naiyoma 展示了其指纹识别研究的[结果][news360 fingerprinting]。该研究聚焦于使用 `addr` 消息在多种网络上识别同一个节点：节点会通过 P2P 协议发送 `addr` 消息，通告其他潜在对等节点。Brozzoni 和 Naiyoma 能够利用特定地址消息中的细节为单个节点做“指纹”，从而识别运行在多个网络（例如 IPv4 与 [Tor][topic anonymity networks]）上的同一节点。研究者提出了两种可能的缓解措施：要么彻底移除地址消息中的时间戳，要么对时间戳做轻微随机化，使其不那么特定于某个具体节点。

{:#garbledlocks}

- **<!--garbled-locks-->****混淆锁：** 6 月，Robin Linus 基于 Jeremy Rubin 的一个[想法][delbrag rubin]，提出了一个用于改进 [BitVM][topic acc] 风格合约的[提案][news359 bitvm3]。新方案利用[混淆电路][garbled circuits wiki]这一密码学原语，使链上 SNARK 验证比 BitVM2 实现高效约一千倍，从而承诺显著减少所需的链上空间；但代价是需要多 TB 级别的链下准备（setup）。

  随后在 8 月，Liam Eagen 在 Bitcoin-Dev 邮件列表上[发帖][news369 eagen]介绍了他的研究[论文][eagen paper]：它描述了一种基于混淆电路的新机制，用于创建[可追责计算合约][topic acc]，称为 Glock（混淆锁）。虽然思路相近，但 Eagen 的研究与 Linus 的工作相互独立。按 Eagen 的说法，相比 BitVM2，Glock 可以将链上数据减少约 550 倍。

<div markdown="1" class="callout" id="softforks">

## 2025 年度总结：软分叉提案

今年围绕软分叉提案出现了大量讨论，范围从“范围少、影响小”的提案到“范围广、能力强”的提案都有涉及。

- *<!--transaction-templates-->交易模板：* 多个围绕交易模板的软分叉提案包得到了讨论。其中范围与能力相近的包括 CTV+CSFS（[BIP119][]+[BIP348][]）以及 [Taproot 原生的可重新绑定签名打包方案][news thikcs]（[`OP_TEMPLATEHASH`][BIPs #1974]+[BIP348][]+[BIP349][]）。它们代表了对比特币脚本能力的“最小增强”：既能实现可重新绑定的签名（即不承诺花费某个特定 UTXO 的签名），也能实现“预先承诺将某个 UTXO 花费到一笔特定的下一笔交易”（有时被称为一种等式[限制条款][topic covenants]）。若被激活，它们将启用 [LN-Symmetry][ctv csfs symmetry] 与[简化版 CTV 保险库][ctv vaults]，并能[降低 DLC 的签名需求][ctv dlcs]、[降低 Ark 的交互性][ctv csfs arks]、[简化 PTLC][ctv csfs ptlcs] 等等。这两类提案的一个差异在于：CTV 能用于[BitVM sibling hack][ctv csfs bitvm]，而 `OP_TEMPLATEHASH` 不能，因为 `OP_TEMPLATEHASH` 不会承诺 `scriptSigs`。

  由于包含了 [OP_CHECKSIGFROMSTACK][topic OP_CHECKSIGFROMSTACK]，这些提案还可通过 [Key Laddering][rubin key ladder] 实现类似默克尔树的“多重承诺”（在锁定脚本或花费脚本中承诺多个相关且可选有序的值）。更新后的 [LNHANCE][lnhance update] 提案还包含 `OP_PAIRCOMMIT`（[BIPs #1699][]），使得无需 Key Laddering 所要求的额外脚本大小与验证成本也能实现多重承诺。多重承诺可用于 LN-Symmetry、复杂委托等更多场景。

  一些开发者[表达了不满][ctv csfs letter]，认为软分叉推进速度过慢；不过，这类提案相关讨论的密度表明，社区兴趣与热情仍然很高。

- *<!--consensus-cleanup-->共识清理：* [共识清理][topic consensus cleanup]提案基于反馈与额外研究进行了[更新][gcc update]；一个 [BIP 草案][gcc bip]被发布并合并为 [BIP54][]，且现在[包含实现与测试向量][gcc impl tests]。年内较早时还讨论了这种清理是否应当在“可能出现非预期没收”的担忧下被设计为临时的[临时软分叉][topic transitory soft forks]；但每次到期都需要重新评估这一必要性，使得临时软分叉显得不那么有吸引力。

- *<!--opcode-proposals-->操作码提案：* 除了上面讨论的捆绑操作码提案之外，2025 年还提出或完善了若干单独的 Script 操作码。

  `OP_CHECKCONTRACTVERIFY`（CCV）[成为了][ccv bip] [BIP443][]，并对其语义（尤其是资金流转相关部分）进行了[细化][ccv semantics]。CCV 通过以特定方式约束某些输入或输出的 `scriptPubKey` 与金额，使得可以实现具备“反应式安全性”的[保险库][topic vaults]，以及大量其他合约。`OP_VAULT` 提案已[撤回][vault withdrawn]，转而支持 CCV。关于 CCV 应用的更多内容，可参见 [Optech 的主题词条][topic MATT]。

  有人[提出][64bit bip]一组 64 位算术操作码。令人意外的是，比特币目前的数学运算并不能覆盖比特币输入/输出金额的完整取值范围。若与其他用于访问和/或约束输入/输出金额的操作码结合，这些扩展算术操作可以启用新的比特币钱包功能。

  一个对 [`OP_TXHASH`][txhash] 的[变体提案][txhash sponsors]将启用[交易赞助（手续费赞助）][topic fee sponsorship]。

  开发者还提出了两种让 Script 具备 `OP_CHECKSIG` 及相关操作之外的椭圆曲线密码学运算能力的方案：一种[提议][tweakadd]使用 `OP_TWEAKADD` 来构造 Taproot `scriptPubKeys`；另一种[提议][ecmath]提供更细粒度的椭圆曲线操作码，例如 `EC_POINT_ADD`，其动机类似但潜在应用更广，例如新的签名验证或多重签名功能。将其中任一方案与 `OP_TXHASH` 和 64 位算术（或类似操作码）结合，可以实现与 CCV 相似的功能。

- *<!--script-restoration-->**脚本恢复（Script Restoration）：* Script Restoration 项目[发布了][gsr bips]一系列四个 BIP。它们提出的 Script 变更与操作码将启用上述操作码提案所提出的全部功能，同时允许更强的脚本表达能力。

</div>

## 七月

{:#ccdelegation}

- **<!--chain-code-delegation-->链码委托**：Jurvis Tan [发布][jt delegation]了他与 Jesse Posner 的合作成果：一种用于协作式托管的方法（现在被称为 “链码委托（[Chain Code Delegation][BIPs #2004]）/BIP89”），由客户（而不是部分受到信任的合作托管供应商）来生成从供应商的签名密钥中派生子密钥的 [BIP32][] 链码（并保持私密）。这样一来，供应商就无法派生出客户的完整的密钥树。这种方法既可以盲化使用（获得完全的隐私性，同时依然能利用供应商的密钥安全性），也可以非盲化使用（允许服务提供商执行策略，但代价是向服务提供商暴露将被签名的具体交易）。

## 八月

{:#utreexo}

- **<!--utreexo-draft-bips-->** **Utreexo BIP 草稿**：Calvin Kim、Tadge Dryja 和 Davidson Souza 联合编写了[三个 BIP 草稿][news366 utreexo]，描述了一种存储完整 UTXO 集的替代性方法，称作 “[Utreexo][topic utreexo]”，它让节点可以获取和验证被一笔交易花费的 UTXO 的信息。这项提议利用了一片默克尔树的森林，来累加对每一个 UTXO 的索引，从而允许节点避免存储这些 UTXO 。

  自八月以来，这项提议得到了一些反馈，这些草稿也被分配了 BIP 编号：

  * *[BIP181][bip181 utreexo]*：描述了 Utreexo 累加器及其操作。

  * *[BIP182][bip182 utreexo]*：定义了使用 Utreexo 累加器来验证区块和交易的规则。

  * *[BIP183][bip183 utreexo]*：定义了为交换 “包含证明” 以确认被花费的 UTXO，节点层面必须作出的变更。

{:#minfeerate}

- **<!--lowering-the-minimum-relay-feerate-->降低交易转发费率门槛**：在过去几年，降低交易转发费率门槛的想法[得到多次讨论][news340 lowering feerates]。今年六月下旬，一些矿工突然开始在区块中包含手续费率低于 `Bitcoin Core` 默认最低转发费率（1 聪/vB）的交易。到了七月底，[85% 的哈希算力][mononautical 85]都已经接受了更低的费率门槛，而且因为一些节点运营者手动配置了更低的限制，低费率交易可以有机地在网络中传播（尽管并不可靠）。到八月中旬，[超过 30% 的得到确认的交易][mononautical 32]所支付的手续费率都低于 1 聪/vB 。比特币协议开发者们观察到，缺失低费率交易的高比例，[导致了致密区块重构成功率降低][0xb10c delving]，因此[提议][news366 lower feerate]调整默认的最低转发费率。九月初发布的 `Bitcoin Core` 29.1 版本降低了默认的转发费率门槛到 0.1 聪/vB 。

{:#templatesharing}

- **<!--peer-block-template-sharing-->对等节点区块模板分享**：Anthony Towns 曾经提出一种[方式][news366 templ share]来提升 “致密区块重构” 在对等节点拥有多样交易池策略的环境中的效率。这项提议将允许全节点们向自己的对等节点发送区块模板，让对等节点缓存会被他们的交易池规则拒绝的交易。这里使用的区块模板所包含的交易标识符，使用跟 “[致密区块转发][topic compact block relay]” 相同的编码格式。

  后来，在八月，Towns 打开了 [BIPs #1937][] 以正式地[讨论][news368 templ share]这项关于区块模板分享的提议。在讨论中，多位开发者表示担心隐私性和潜在的节点指纹识别。到了十月，Towns 决定[将草稿迁移][news376 templ share]到 “比特币调查编号及名称管理局（[BINANA][binana repo]）” 代码库中，以解决这些考虑并提炼文档。这份草案的编号是 [BIN-2025-0002][bin] 。

{:#fuzzing}

- **<!--differential-fuzzing-of-bitcoin-and-ln-implementations-->比特币和闪电节点实现的差异模糊测试**：Bruno Garcia 给出了 [bitcoinfuzz][] 项目所取得的[进展和结果][news369 fuzz]；这是一个为比特币和闪电节点实现和代码库执行模糊测试的库。使用这个代码库，开发者们报告了在比特币相关的项目（比如 btcd、rust-bitcoin、rust-miniscript、LND，等等）中发现的超过 35 个 bug 。

  Garcia 也强调了差异模糊测试在这个生态系统中的重要性。开发者们可以发现完全没有实现模糊测试的项目中的 bug、捕捉比特币软件实现中的差异，以及找出闪电网络规范中的空白。

  最后，Garcia 鼓励维护者们集成更多项目到 bitcoinfuzz 中，扩大对差异模糊测试的支持，并为这个项目提供可能的开发方向。

<div markdown="1" class="callout" id="stratumv2">

## 2025 总结：Stratum V2

[Stratum v2][topic pooled mining] 是一套挖矿协议，设计目的是取代在矿工和矿池之间使用的初版 Stratum 协议。V2 的关键优势之一是，它允许矿池的成员各自选择要在区块中打包哪些交易，也即通过在许多独立矿工之间分散交易选择来提升比特币的抗审查性。

在整个 2025 年，Bitcoin Core 接受了多项更新以更好地支持 Stratum V2 实现。今年早些时候的更新集中在挖矿 RPC 上，通过增加 `nBits`、`target` 和 `next` 字段来[更新它们][news339 sv2fields]，这对构造和验证区块模板有用。

最重要的工作则集中在 `Bitcoin Core` 的实验性 “进程间通信（IPC）” 接口上，它让外部的 Stratum v2 服务可以跟 `Bitcoin Core` 的区块验证模块交互，而无需使用更慢的 JSON-RPC 接口。一种新的 [`waitNext()`][news346 waitnext] 方法在 `BlockTemplate` 接口中引入；仅在链顶端发生变化，或者交易池手续费显著增加的时候，它会返回一个新的区块模板，从而减少不必要的区块模板生成。然后，增加了 [`checkBlock`][news360 checkblock]，它让 矿池可以通过 IPC 来验证矿工所提供的区块模板。IPC 也是默认[启用][news369 ipc]的，并且新的 `bitcoin-node` 和其它多进程二进制文件被添加到了编译好的发行版中。[加入][news357 wrapper]了一种新的可执行的 `bitcoin` 封装器，以便于发行和启动数量不断增加的二进制文件；并且，后续的一项工作[实现][news374 ipcauto]了自动化的多进程挑选，因此不再需要 `-m` 启动标签。今年的 IPC 优化主要是[降低][news377 ipclog]多进程日志记录的 CPU 占用；以及[保证][news381 witness]通过 IPC 提交的区块都重新验证了它们的见证数据承诺。

[Bitcoin Core 30.0][news376 30] 在十月发布，是第一个包含这个实验性 IPC 挖矿接口的发行版 —— 而这个挖矿接口第一次[加入][news323 miningipc]是在去年。

在六月，StarkWare [演示][news359 starkware]了一个修改后的 Stratum v2 客户端，使用 STARK 证据来证明这个区块的手续费属于一个有效的模板，而无需揭示其中的交易。两个新的基于 Stratum v2 的矿池启动了：[Hashpool][news346 hashpool]，它用 [ecash][topic ecash] token 来代表挖矿份额；[DMND][news346 dmnd]，它从独自挖矿拓展成了池化挖矿。

</div>

## 九月

{:#simplicity}

- **<!--details-about-the-design-of-simplicity-->** **Simplicity 编程语言的设计细节**：[Simplicity][topic simplicity] 编程语言在 Liquid 网络上发布之后，Russell O'Connor 在 Delving Bitcoin 论坛上发布了三个帖子，讨论这种语言背后的[哲学和设计][simplicity 370]：

  * *[Part I][simplicity I post]* 考察了三种主要的组合形式，它们将基本的操作转化为复杂的操作。

  * *[Part II][simplicity II post]* 深入了 Simplicity 的类型系统组合符和基本的表达式。

  * *[Part III][simplicity III post]* 解释了如何从比特开始建立逻辑操作，直至密码学操作；仅使用计算性的 Simplicity 组合符。

  从九月份开始，又有两篇帖子发布在 Delving Bitcoin 论坛中：[Part IV][simplicity IV post]，讨论了副作用；[Part V][simplicity V post]，处理了程序和地址的概念。

{:#eclipseattacks}

- **<!--partitioning-and-eclipse-attacks-using-bgp-interception-->****使用 “边界网关协议” 拦截的网络分区和日蚀攻击：** 使用 “边界网关协议” 拦截的网络分区和日蚀攻击：Cedarctic 在 Delving Bitcoin 论坛中[报告][Cedarctic post]了边界网关协议（BGP）中的错误可被用于阻止全节点连接到诚实的对等节点；可能允许网络分区（或者说 “日蚀攻击（[eclipse attacks][eclipse attack]）”。Cedarctic 介绍了几种缓解措施，参与讨论的其他开发者也介绍了其它缓解措施以及观测这种攻击的方法。

<div markdown="1" class="callout" id="releases">

## 2025 总结：热门基础设施项目的主要发行版

- [BDK wallet-1.0.0][] 标志着这个代码库的第一个主要发行版；最初的 `bdk` 库已被重新命名为 `bdk_wallet`，带有一个稳定的 API，而更低层级的模块被抽取到独立的库中。

- [LDK v0.1][] 添加了对 “闪电网络服务商规范（LSPS）” 通道开启协商协议的双方的支持，以及 [BIP353][] 人眼可读域名解析，还在通道强制关闭时解决多个 [HTLC][topic htlc] 时降低了区块链手续费开支。

- [Core Lightning 25.02][] 添加了对 “[对等节点存储][topic peer storage]” 协议的支持，默认不启用。

- [Eclair v0.12.0][] 添加了对创建和管理 [BOLT12 offers][topic offers] 的支持；新的通道关闭协议支持手续费替换（[RBF][topic rbf]），还支持通过对等节点存储协议为对等节点存储少量数据。

- [BTCPay Server 2.1.0][] 为 [RBF][topic rbf] 和 “子为亲偿（[CPFP][topic cpfp]）” 手续费追加法添加了多项优化；使用 BTCPay Server 参与多签名的所有签名器有了更好的流程；还为一些山寨币的用户制作了一些破坏性变更。

- [Bitcoin Core 29.0][] 将 UPnP（通用即插即用网络协议） 特性替换成了 NAT-PMP（NAT 端口映射协议）选项（前者催生了多项以往发现的安全漏洞），为 “[交易包转发][topic package relay]” 提升了孤儿交易的亲交易索取效率，还为矿工优化了 “[时间扭曲][topic time warp]” 的规避措施；将编译系统从 `automake` 迁移为 `cmake`。

- [LND 0.19.0-beta][] 为通道的合作式关闭操作添加了新的基于 RBF 的手续费追加方法。

- [Core Lightning 25.05][] 加入了实验性的 “[通道拼接][topic splicing]” 支持，与 Eclair 兼容，并默认启用对等节点存储协议。

- [BTCPay Server 2.2.0][] 添加了对钱包条款和 [miniscript][topic miniscript] 的支持。

- [Core Lightning v25.09][] 加入了对 `xpay` 命令的支持，用于支付 [BIP353][] 地址和要约（[offer][topic offers]）。

- [Eclair v0.13.0][] 加入了 “[简单 taproot 通道][topic simple taproot channels]” 的一项初步实现、基于近期的规范更新提升了[通道拼接][topic splicing]，并且更好地支持了 BOLT 12 。

- [Bitcoin Inquisition 29.1][] 添加了对 `OP_INTERNALKEY` 的支持；这是一个隶属于多项限制条款（[限制条款][topic covenants]）提议的操作码。

- [Bitcoin Core 30.0][] 让带有多个数据携带（OP_RETURN）输出的交易变成标准交易，并将 `datacarriersize`（允许转发的数据携带交易的最大体积）默认值设为 `100,000`；将默认的[转发费率门槛][topic default minimum transaction relay feerates]设为 0.1 聪/vB；添加了一个实验性的 IPC 挖矿接口，以支持 [Stratum v2][topic pooled mining] 插件；不再支持创建和加载传统数据库格式的钱包。传统格式的钱包可以迁移为[描述符][topic descriptors]格式。

- [Core Lightning v25.12][] 添加了 [BIP39][] 助记种子词作为新的默认备份方法；实验性支持 “按需开设的通道（[JIT channels][topic jit channels]）”。

- [LDK 0.2][] 开始支持[通道拼接][topic splicing]（实验性质）、为 “[异步支付][topic async payments]” 提供和支付静态发票，以及使用[临时锚点输出][topic ephemeral anchors]的[零费用承诺][topic v3 commitments]通道。

</div>

## 十月

{:#arbdata}

- **<!--discussions-about-arbitrary-data-->****关于任意数据的讨论：** 十月的对话重新探讨了一个长期存在的问题：在比特币交易中嵌入任意数据，以及为此使用 UTXO 集所面临的限制。[一篇分析][news375
  arb data]考察了即便在一套更为严格的比特币交易规则下，将数据存入 UTXO 的理论约束。

  随后贯穿全年余下时间的[讨论][news379 arb data]，聚焦于是否应当考虑在共识层面对携带数据的交易施加限制。

{:#channeljamming}

- **<!--channel-jamming-mitigation-simulation-results-and-updates-->****通道阻塞缓解的仿真结果与更新：** Carla Kirk-Cohen 与 Clara Shikhelman 和 elnosh 合作，发布了他们更新后的声誉算法的[闪电网络阻塞仿真结果][channel jamming results]。更新内容包括：为出站通道跟踪声誉，以及跟踪入站通道的资源限制。有了这些更新，他们发现该方案仍能防御[资源型][channel jamming resource]与[汇聚型（sink）][channel jamming sink]攻击。在这一轮更新与仿真之后，他们认为针对[通道阻塞攻击][channel jamming attack]的缓解措施已经成熟到足以进入实现阶段。

## 十一月

{:#secpperformance}

- **<!--comparing-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1-->****比较 OpenSSL 与 libsecp256k1 的 ECDSA 签名验证性能：**
  在 Bitcoin Core 从 OpenSSL 切换到 libsecp256k1 十年后，Sebastian Falbesoner
  [发布][openssl vs libsecp256k1]了一份基准测试分析，对比这两个密码学库在签名验证方面的性能。
  libsecp256k1 于 2015 年为 Bitcoin Core 专门创建，当时就已经快了约 2.5 到 5.5 倍。Falbesoner 发现，此后差距进一步扩大到 8 倍以上：libsecp256k1 持续优化，而 OpenSSL 的 secp256k1 性能几乎原地踏步；考虑到该曲线在比特币之外的相关性有限，这并不令人意外。

  在讨论中，libsecp256k1 的创建者 Pieter Wuille 指出，这些基准测试天然存在偏差：所有版本都在现代硬件和编译器上测试，但历史上的优化往往面向当时存在的硬件与编译器。

{:#stalerates}

- **<!--modeling-stale-rates-by-propagation-delay-and-mining-centralization-->****按传播延迟与挖矿集中度对陈旧率建模：**
  Antoine Poinsot 在 Delving Bitcoin 上[发帖][Antoine post]分析区块传播延迟如何系统性地让更大的矿工受益。他建模了两种会导致区块 A 变成陈旧区块的情形：第一种是竞争区块 B 在 A 之前被找到并率先传播；第二种是 B 在 A 之后不久被找到，但同一个矿工又找到了下一个区块。第一种情形更可能发生，这表明矿工从更快获知他人区块中获得的收益，可能大于更快广播自己区块的收益。

  Poinsot 还表明，传播延迟越大，陈旧率越高，并且对小矿工的影响不成比例。在 10 秒传播延迟的假设下，一个算力 5 EH/s、年收入 9100 万美元的矿工组织，如果从连接最小矿池改为连接最大矿池，可能每年额外获得约 10 万美元收入。由于挖矿利润率很薄，这类小幅收入差异也可能带来显著的利润影响。

{:#bip3}

- **<!--bip3-and-the-bip-process-->****BIP3 与 BIP 流程：** 2025 年，关于更新 BIP 流程的提案推进显著。BIP3 在 1 月[获得编号][news341 bip3 assigned]，2 月发布，4 月推进到 Proposed 状态。随后又经过进一步审阅并进行了若干更新：引入了 SPDX 许可证表达式，更新了一些序言（Preamble）头部字段，并把多项澄清写入提案中。11 月，Murch [提议激活][news382 motion to activate bip3]该提案，请读者在接下来的四周内审阅并评论是否应激活 BIP3。之后一轮密集审阅带来了更多改进，同时也撤回了此前有争议的、禁止在撰写 BIP 时使用 LLM 的指导意见。临近年末，所有审阅意见都已处理完毕，BIP3 再次[寻求粗略共识][bip3 feedback addressed]以推进激活。

{:#kernelapi}

- **<!--bitcoin-kernel-c-api-introduced-->****引入 Bitcoin Kernel C API：** [Bitcoin Core #30595][news380 kernel]
  引入了一个 C 语言头文件，作为 [`bitcoinkernel`][Bitcoin Core #27587] 的 API，使外部项目能够通过可复用的 C 库与 Bitcoin Core 的区块验证与链状态（chainstate）逻辑交互。目前它仅限于对区块的操作，并且在功能上与现已废弃的 `libbitcoin-consensus` 等价（见 [周报 #288][news288 lib]）。

  `bitcoinkernel` 的用例包括：替代性节点实现、Electrum 服务器索引构建器、[静默支付][topic silent payments]扫描器、区块分析工具、脚本验证加速器等。多个语言绑定正在开发中，包括 [Rust][kernel rust]、[Go][kernel go]、[JDK][kernel jdk]、[C#][kernel csharp] 和 [Python][kernel python]。

<div markdown="1" class="callout" id="optech">

## 2025 年总结：Bitcoin Optech

在 Optech 成立第八年，我们发布了 50 期每周 [周报][newsletters]以及本期年度回顾特刊。总计而言，Optech 今年发布了超过 80,000 个英文单词，介绍比特币软件研发与研究进展；粗略相当于一本 225 页的书。

今年每一期周报和博客文章都被翻译成中文、法语和日语；此外还有其他语言的译文。2025 年总计产出了 150 余篇译文。

此外，今年的每一期周报都配有一期[播客][podcast]节目，累计超过 60 小时的音频内容，并配套超过 500,000 个单词的文字转录。许多比特币领域的顶尖贡献者都做客节目，其中一些人不止一次；2025 年共有 75 位不同的嘉宾：

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

Optech 有幸并心怀感激地再次收到 [Human Rights Foundation][] 对我们工作的 20,000 美元捐助。这笔资金将用于支付网站托管、邮件服务、播客转录等费用，以及其他支出，从而帮助我们持续并改进向比特币社区提供技术内容的工作。

### 特别鸣谢

在作为首席作者连续贡献了 376 期 Bitcoin Optech 新闻简报后，Dave Harding 于今年停止了定期投稿。我们对 Harding 深表感激，他八年来始终如一地主持通讯工作，并为社区带来了丰富的比特币知识普及、巨细阐释和深刻理解。我们永远心怀感激，并祝愿他一切顺利。

</div>

## 十二月

{:#lnsplicing}

- **<!--splicing-->****拼接：** 12 月，[LDK 0.2][] 发布并提供了实验性的[通道拼接][topic splicing]支持，使该特性在三大闪电网络实现中都可用：LDK、Eclair 与 Core Lightning。拼接允许节点在不关闭通道的情况下，为通道增加或移除资金。

  这为闪电网络拼接特性在 2025 年取得的重大进展画上句号。Eclair 在 2 月加入了[公开通道拼接支持][news340 eclairsplice]，并在 8 月加入了[简单 taproot 通道中的拼接][news368 eclairtaproot]。同时，Core Lightning 在 5 月[完成][news355 clnsplice]与 Eclair 的互操作性，并在 [Core Lightning 25.05][news359 cln2505] 中发布。

  贯穿全年，LDK 实现所需的各个组件也陆续到位，包括 8 月的 [splice-out 支持][news369 ldksplice]、9 月将拼接与静默（quiescence）协议[集成][news370 ldkquiesce]，以及在 0.2 发布之前交付的多项额外改进。

  各实现团队也在规范细节上协同，例如：为允许拼接状态传播而延长在标记通道关闭前的等待时间（依据 [BOLTs #1270][] 将 12 个区块提高到 [72 个区块][news359 eclairdelay]），以及依据 [BOLTs #1289][] 的同步拼接状态而改进的[重连逻辑][news381 clnreconnect]。

  不过，截至年末，主要的[拼接规范][bolts #1160]仍未合并；预计还会继续更新，并将持续解决跨实现兼容性问题。

*我们感谢上文提及的所有比特币贡献者，以及许多同样关键却未能一一列名的贡献者，在过去一年中为比特币开发作出的卓越贡献。Bitcoin Optech 周报将于 1 月 2 日恢复每周五的常规发布时间表。*

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
[yirs 2018]: /zh/newsletters/2018/12/28/
[yirs 2019]: /zh/newsletters/2019/12/28/
[yirs 2020]: /zh/newsletters/2020/12/23/
[yirs 2021]: /zh/newsletters/2021/12/22/
[yirs 2022]: /zh/newsletters/2022/12/21/
[yirs 2023]: /zh/newsletters/2023/12/20/
[yirs 2024]: /zh/newsletters/2024/12/20/

[newsletters]: /zh/newsletters/
[Human Rights Foundation]: https://hrf.org
[openssl vs libsecp256k1]: /zh/newsletters/2025/11/07/#comparing-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1
[channel jamming results]: /zh/newsletters/2025/10/24/#channel-jamming-mitigation-simulation-results-and-updates
[channel jamming resource]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[channel jamming sink]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[channel jamming attack]: /en/topics/channel-jamming-attacks/
[erlay optech posts]: /zh/newsletters/2025/02/07/#erlay-update
[erlay]: /en/topics/erlay/
[erlay knowledge]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[erlay fanout amount]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[erlay transaction received]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[erlay candidate peers]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[news358 selfish miner]: /zh/newsletters/2025/06/13/#calculating-the-selfish-mining-danger-threshold
[selfish miner paper]: https://arxiv.org/pdf/1311.0243
[news360 fingerprinting]: /zh/newsletters/2025/06/27/#fingerprinting-nodes-using-addr-messages
[news359 bitvm3]: /zh/newsletters/2025/06/20/#improvements-to-bitvmstyle-contracts
[delbrag rubin]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[garbled circuits wiki]: https://en.wikipedia.org/wiki/Garbled_circuit
[news369 eagen]: /zh/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[eagen paper]: https://eprint.iacr.org/2025/1485
[news351 dahlias]: /zh/newsletters/2025/04/25/#interactive-aggregate-signatures-compatible-with-secp256k1
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[news344 fork guide]: /zh/newsletters/2025/03/07/#bitcoin-forking-guide
[fork guide red]: https://ajtowns.github.io/bfg/research.html
[fork guide pue]: https://ajtowns.github.io/bfg/power.html
[fork guide ie]: https://ajtowns.github.io/bfg/industry.html
[fork guide ir]: https://ajtowns.github.io/bfg/investor.html
[news344 template mrkt]: /zh/newsletters/2025/03/07/#private-block-template-marketplace-to-prevent-centralizing-mev-mev
[mevpool gh]: https://github.com/mevpool/mevpool/blob/0550f5d85e4023ff8ac7da5193973355b855bcc8/mevpool-marketplace.md
[news 347 ln fees]: /zh/newsletters/2025/03/28/#ln-upfront-and-hold-fees-using-burnable-outputs
[ln fees paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news349 swiftsync]: /zh/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download-swiftsync
[swiftsync ruben gh]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[swiftsync rust impl]: https://delvingbitcoin.org/t/swiftsync-speeding-up-ibd-with-pre-generated-hints-poc/1562/18
[news288 lib]: /zh/newsletters/2024/02/07/#bitcoin-core-29189
[kernel rust]: https://github.com/sedited/rust-bitcoinkernel
[kernel go]: https://github.com/stringintech/go-bitcoinkernel
[kernel jdk]: https://github.com/yuvicc/bitcoinkernel-jdk
[kernel csharp]: https://github.com/janb84/BitcoinKernel.NET
[kernel python]: https://github.com/stickies-v/py-bitcoinkernel
[gcc update]: /zh/newsletters/2025/02/07/#updates-to-cleanup-soft-fork-proposal
[gcc bip]: /zh/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[news thikcs]: /zh/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[ctv csfs symmetry]: /zh/newsletters/2025/04/04/#ln-symmetry
[ctv csfs arks]: /zh/newsletters/2025/04/04/#ark
[ctv vaults]: /zh/newsletters/2025/04/04/#vaults
[ctv dlcs]: /zh/newsletters/2025/04/04/#dlcs
[lnhance update]: /zh/newsletters/2025/12/05/#lnhance-soft-fork
[rubin key ladder]: https://rubin.io/bitcoin/2024/12/02/csfs-ctv-rekey-symmetry/
[ctv csfs ptlcs]: /zh/newsletters/2025/07/04/#ctv-csfs-advantages-for-ptlcs
[ctv csfs bitvm]: /zh/newsletters/2025/05/16/#description-of-benefits-to-bitvm-from-op-ctv-and-op-csfs
[ctv csfs letter]: /zh/newsletters/2025/07/04/#open-letter-about-ctv-and-csfs
[gcc impl tests]: /zh/newsletters/2025/11/07/#bip54-implementation-and-test-vectors
[ccv bip]: /zh/newsletters/2025/05/30/#bips-1793
[ccv semantics]: /zh/newsletters/2025/04/04/#op-checkcontractverify-semantics
[vault withdrawn]: /zh/newsletters/2025/05/16/#bips-1848
[64bit bip]: /zh/newsletters/2025/05/16/#proposed-bip-for-64-bit-arithmetic-in-script
[txhash sponsors]: /zh/newsletters/2025/07/04/#op-txhash-variant-with-support-for-transaction-sponsorship
[txhash]: /zh/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[tweakadd]: /zh/newsletters/2025/09/05/#draft-bip-for-adding-elliptic-curve-operations-to-tapscript
[ecmath]: /zh/newsletters/2025/09/05/#draft-bip-for-adding-elliptic-curve-operations-to-tapscript
[gsr bips]: /zh/newsletters/2025/10/03/#draft-bips-for-script-restoration
[transitory cleanups]: /zh/newsletters/2025/01/03/#transitory-soft-forks-for-cleanup-soft-forks
[simplicity 370]: /zh/newsletters/2025/09/05/#details-about-the-design-of-simplicity
[simplicity I post]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[simplicity II post]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[simplicity III post]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[simplicity IV post]: https://delvingbitcoin.org/t/delving-simplicity-part-two-side-effects/2091
[simplicity V post]: https://delvingbitcoin.org/t/delving-simplicity-part-programs-and-addresses/2113
[news339 sv2fields]: /zh/newsletters/2025/01/31/#bitcoin-core-31583
[news346 waitnext]: /zh/newsletters/2025/03/21/#bitcoin-core-31283
[news360 checkblock]: /zh/newsletters/2025/06/27/#bitcoin-core-31981
[news359 starkware]: /zh/newsletters/2025/06/20/#stratum-v2-stark-proof-demo
[news369 ipc]: /zh/newsletters/2025/08/29/#bitcoin-core-31802
[news374 ipcauto]: /zh/newsletters/2025/10/03/#bitcoin-core-33229
[news376 30]: /zh/newsletters/2025/10/17/#bitcoin-core-30-0
[news377 ipclog]: /zh/newsletters/2025/10/24/#bitcoin-core-33517
[news381 witness]: /zh/newsletters/2025/11/21/#bitcoin-core-33745
[news346 hashpool]: /zh/newsletters/2025/03/21/#hashpool-v0-1-tagged-hashpool-v0-1
[news323 miningipc]: /zh/newsletters/2024/10/04/#bitcoin-core-30510
[news340 richter ggt]: /zh/newsletters/2025/02/07/#discovery-of-previous-research-for-finding-optimal-cluster-linearization
[news341 pr-review-club txgraph]: /zh/newsletters/2025/02/14/#bitcoin-core-pr-审核俱乐部
[news352 wuille linearization techniques]: /zh/newsletters/2025/05/02/#comparison-of-cluster-linearization-techniques
[news377 ismail template improvement]: /zh/newsletters/2025/10/24/#detecting-block-template-feerate-increases-using-cluster-mempool
[news382 cluster mempool completed]: /zh/newsletters/2025/11/28/#bitcoin-core-33629
[news bip360 update]: /zh/newsletters/2025/03/07/#update-on-bip360-paytoquantumresistanthash-p2qrh
[news qr sha]: /zh/newsletters/2025/04/04/#securely-proving-utxo-ownership-by-revealing-a-sha256-preimage
[news qr cr]: /zh/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[news qr lopp1]: /zh/newsletters/2025/04/04/#should-vulnerable-bitcoins-be-destroyed
[news qr lopp2]: /zh/newsletters/2025/08/01/#migration-from-quantumvulnerable-outputs
[news qr cruz]: /zh/newsletters/2025/04/04/#draft-bip-for-destroying-quantum-insecure-bitcoins
[news qr corallo]: /zh/newsletters/2025/01/03/#quantum-computer-upgrade-path
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[lamport]: https://en.wikipedia.org/wiki/Lamport_signature
[conduition sphincs]: /zh/newsletters/2025/12/05/#lh-dsa-post-quantum-signature-optimizations
[abdel stark]: /zh/newsletters/2025/11/07/#native-stark-proof-verification-in-bitcoin-script
[news364 quantum primatives]: /zh/newsletters/2025/07/25/#research-indicates-common-bitcoin-primitives-are-compatible-with-quantum-resistant-signature-algorithms
[news365 quantum taproot]: /zh/newsletters/2025/08/01/#security-against-quantum-computers-with-taproot-as-a-commitment-scheme
[news357 quantum report]: /zh/newsletters/2025/06/06/#quantum-computing-report
[news qr agg]: /zh/newsletters/2025/11/07/#post-quantum-signature-aggregation
[nick paper tweet]: https://x.com/n1ckler/status/1998407064213704724
[hash-based signature schemes]: https://eprint.iacr.org/2025/2203.pdf
[news335 chilldkg]: /zh/newsletters/2025/01/03/#updated-chilldkg-draft
[news offchain dlc]: /zh/newsletters/2025/01/24/#correction-about-offchain-dlcs
[news dlc channels]: /zh/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs-10101-beta-ln-dlc
[Cedarctic post]: /zh/newsletters/2025/09/19/#partitioning-and-eclipse-attacks-using-bgp-interception
[eclipse attack]: /en/topics/eclipse-attacks/
[Antoine post]: /zh/newsletters/2025/11/21/#modeling-stale-rates-by-propagation-delay-and-mining-centralization
[news340 lowering feerates]: /zh/newsletters/2025/02/07/#discussion-about-lowering-the-minimum-transaction-relay-feerate
[mononautical 85]: https://x.com/mononautical/status/1949452588992414140
[mononautical 32]: https://x.com/mononautical/status/1958559008698085551
[news366 lower feerate]: /zh/newsletters/2025/08/08/#continued-discussion-about-lowering-the-minimum-relay-feerate
[news315 compact blocks]: /zh/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 compact blocks]: /zh/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news365 compact blocks]: /zh/newsletters/2025/08/01/#testing-compact-block-prefilling
[news382 compact blocks]: /zh/newsletters/2025/11/28/#stats-on-compact-block-reconstructions-updates
[news368 monitoring]: /zh/newsletters/2025/08/22/#peerobserver-tooling-and-call-to-action
[28.0 wallet guide]: /zh/bitcoin-core-28-wallet-integration-guide/
[news340 lneas]: /zh/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts
[news341 lneas]: /zh/newsletters/2025/02/14/#continued-discussion-about-ephemeral-anchor-scripts-for-ln
[news380 kernel]: /zh/newsletters/2025/11/14/#bitcoin-core-30595
[news357 wrapper]: /zh/newsletters/2025/06/06/#bitcoin-core-31375
[news346 dmnd]: /zh/newsletters/2025/03/21/#dmnd-launching-pooled-mining-dmnd
[news341 bip3 assigned]: /zh/newsletters/2025/02/14/#updated-proposal-for-updated-bip-process
[news382 motion to activate bip3]: /zh/newsletters/2025/11/28/#motion-to-activate-bip3
[bip3 feedback addressed]: https://groups.google.com/g/bitcoindev/c/j4_toD-ofEc/m/8HTeL2_iAQAJ
[delving random]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[random poc]: https://github.com/distributed-lab/op_rand
[waxwing random]: /zh/newsletters/2025/02/14/#simpler-zeroknowledge-proofs
[ok random]: /zh/newsletters/2025/02/07/#emulating-op-rand
[rl random]: /zh/newsletters/2025/03/14/#probabilistic-payments-using-different-hash-functions-as-as-xor-function
[dh random]: /zh/newsletters/2025/02/14/#suitability-as-an-alternative-to-trimmed-htlcs-htlc
[jt delegation]: /zh/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[news335 coinjoin]: /zh/newsletters/2025/01/03/#deanonymization-attacks-against-centralized-coinjoin
[news333 coinjoin]: /zh/newsletters/2024/12/13/#deanonymization-vulnerability-affecting-wasabi-and-related-software
[news340 htlcbug]: /zh/newsletters/2025/02/07/#channel-force-closure-vulnerability-in-ldk
[news340 htlcfix]: /zh/newsletters/2025/02/07/#ldk-3556
[news339 ldk]: /zh/newsletters/2025/01/31/#vulnerability-in-ldk-claim-processing
[news339 cycling]: /zh/newsletters/2025/01/31/#replacement-cycling-attacks-with-miner-exploitation
[news346 bolts]: /zh/newsletters/2025/03/21/#bolts-1233
[news344 lnd]: /zh/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[news346 checkpoints]: /zh/newsletters/2025/03/21/#bitcoin-core-31649
[news353 bip30]: /zh/newsletters/2025/05/09/#bip30-consensus-failure-vulnerability
[news354 32bit]: /zh/newsletters/2025/05/16/#vulnerability-disclosure-affecting-old-versions-of-bitcoin-core
[news364 lnd]: /zh/newsletters/2025/07/25/#lnd-gossip-filter-dos-vulnerability
[news319 lnd]: /zh/newsletters/2024/09/06/#lnd-9009
[news159 32bit]: /zh/newsletters/2021/07/28/#bitcoin-core-22387
[news314 32bit]: /zh/newsletters/2024/08/02/#addr
[news373 eclair]: /zh/newsletters/2025/09/26/#eclair-vulnerability
[news378 four]: /zh/newsletters/2025/10/31/#disclosure-of-four-low-severity-vulnerabilities-in-bitcoin-core
[news361 four]: /zh/newsletters/2025/07/04/#bitcoin-core-32819
[news363 four]: /zh/newsletters/2025/07/18/#bitcoin-core-32604
[news367 four]: /zh/newsletters/2025/08/15/#bitcoin-core-33050
[news383 nbitcoin]: /zh/newsletters/2025/12/05/#consensus-bug-in-nbitcoin-library
[news384 lnd]: /zh/newsletters/2025/12/12/#critical-vulnerabilities-fixed-in-lnd-0190
[bdk wallet-1.0.0]: /zh/newsletters/2025/01/03/#bdk-wallet-1-0-0
[ldk v0.1]: /zh/newsletters/2025/01/17/#ldk-v0-1
[core lightning 25.02]: /zh/newsletters/2025/03/07/#core-lightning-25-02
[eclair v0.12.0]: /zh/newsletters/2025/03/14/#eclair-v0-12-0
[btcpay server 2.1.0]: /zh/newsletters/2025/04/11/#btcpay-server-2-1-0
[bitcoin core 29.0]: /zh/newsletters/2025/04/18/#bitcoin-core-29-0
[lnd 0.19.0-beta]: /zh/newsletters/2025/05/23/#lnd-0-19-0-beta
[core lightning 25.05]: /zh/newsletters/2025/06/20/#core-lightning-25-05
[btcpay server 2.2.0]: /zh/newsletters/2025/08/08/#btcpay-server-2-2-0
[core lightning v25.09]: /zh/newsletters/2025/09/05/#core-lightning-v25-09
[eclair v0.13.0]: /zh/newsletters/2025/09/12/#eclair-v0-13-0
[bitcoin inquisition 29.1]: /zh/newsletters/2025/10/10/#bitcoin-inquisition-29-1
[bitcoin core 30.0]: /zh/newsletters/2025/10/17/#bitcoin-core-30-0
[core lightning v25.12]: /zh/newsletters/2025/12/05/#core-lightning-v25-12
[ldk 0.2]: /zh/newsletters/2025/12/05/#ldk-0-2
[news340 eclairsplice]: /zh/newsletters/2025/02/07/#eclair-2968
[news368 eclairtaproot]: /zh/newsletters/2025/08/22/#eclair-3103
[news355 clnsplice]: /zh/newsletters/2025/05/23/#core-lightning-8021
[news359 cln2505]: /zh/newsletters/2025/06/20/#core-lightning-25-05
[news369 ldksplice]: /zh/newsletters/2025/08/29/#ldk-3979
[news370 ldkquiesce]: /zh/newsletters/2025/09/05/#ldk-4019
[news359 eclairdelay]: /zh/newsletters/2025/06/20/#eclair-3110
[news381 clnreconnect]: /zh/newsletters/2025/11/21/#core-lightning-8646
[bolts #1270]: https://github.com/lightning/bolts/pull/1270
[bolts #1289]: https://github.com/lightning/bolts/pull/1289
[bolts #1160]: https://github.com/lightning/bolts/pull/1160
[news366 utreexo]: /zh/newsletters/2025/08/08/#draft-bips-proposed-for-utreexo
[bip181 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0181.md
[bip182 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0182.md
[bip183 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0183.md
[news366 templ share]: /zh/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[news368 templ share]: /zh/newsletters/2025/08/22/#draft-bip-for-block-template-sharing
[news376 templ share]: /zh/newsletters/2025/10/17/#continued-discussion-of-block-template-sharing
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bin]: https://github.com/bitcoin-inquisition/binana/blob/master/2025/BIN-2025-0002.md
[news369 fuzz]: /zh/newsletters/2025/08/29/#update-on-differential-fuzzing-of-bitcoin-and-ln-implementations
[bitcoinfuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
[news375 arb data]: /zh/newsletters/2025/10/10/#theoretical-limitations-on-embedding-data-in-the-utxo-set-utxo
[news379 arb data]: /zh/newsletters/2025/11/07/#multiple-discussions-about-restricting-data
[news 338]: /zh/newsletters/2025/01/24/#bitcoin-core-31397
[news352 OR debate]: /zh/newsletters/2025/05/02/#increasing-or-removing-bitcoin-core-s-op-return-size-limit
[0xb10c delving]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/35