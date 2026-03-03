---
title: 'Bitcoin Optech Newsletter #180: 2021 Year-in-Review Special'
permalink: /zh/newsletters/2021/12/22/
name: 2021-12-22-newsletter-zh
slug: 2021-12-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh

excerpt: >
  本期 Optech Newsletter 特刊总结了 2021 年比特币领域的重大进展。
---

{{page.excerpt}} 这是继我们 [2018][2018 summary]、[2019][2019 summary] 和 [2020][2020 summary] 年度总结后的续篇。

## 目录

* 1 月
  * [Bitcoin Core 中的 Signet](#signet)
  * [Bech32m 地址](#bech32m)
  * [洋葱消息与报价协议](#offers)
* 2 月
  * [签名创建与验证加速](#safegcd)
  * [通道堵塞攻击](#jamming)
* 3 月
  * [量子计算风险](#quantum)
* 4 月
  * [闪电网络原子多路径支付](#amp)
* 5 月
  * [BIP125 选择性手续费追加差异](#bip125)
  * [双向资助通道](#dual-funding)
* 6 月
  * [基于候选集的区块构建](#csb)
  * [默认交易手续费替换](#default-rbf)
  * [内存池包接受与包中继](#mpa)
  * [闪电网络快进机制加速与离线接收](#ff)
* 7 月
  * [闪电网络流动性广告](#liq-ads)
  * [输出脚本描述符](#descriptors)
  * [零确认通道开通](#zeroconfchan)
  * [SIGHASH_ANYPREVOUT](#anyprevout)
* 8 月
  * [保真债券](#fibonds)
  * [闪电网络路径查找](#pathfinding)
* 9 月
  * [OP_TAPLEAF_UPDATE_VERIFY](#tluv)
* 10 月
  * [交易谱系标识符](#txhids)
  * [PTLC 与闪电网络快进](#ptlcsx)
* 11 月
  * [闪电网络开发者峰会](#lnsummit)
* 12 月
  * [进阶手续费追加](#bumping)
* 专题总结
  * [Taproot](#taproot)
  * [主流基础设施项目重大发布](#releases)
  * [Bitcoin Optech](#optech)

## 一月
{:#signet}
经过多年讨论，比特币核心支持[Signet][topic signet]的首个版本于 1 月[发布][bcc21]，此前 C-Lightning 已[支持][cl#2816]，随后 LND 也[支持][lnd#5025]。Signet 是任何人都可以使用的测试网络，用于模拟比特币主网（mainnet）的现状或某些变更（如软分叉共识变更激活）后的可能状态。大多数实现 Signet 的软件还支持默认的 Signet 网络，这为不同团队开发的软件提供了一个特别便捷的安全测试环境，最大程度地模拟真实资金环境。同年还[讨论][signet reorgs]了在 Bitcoin Core 的默认 Signet 网络中引入故意的区块链重组，以帮助开发者测试软件应对此类问题的能力。

{:#bech32m}
一月还[宣布][bech32 bip]了[Bech32m][topic bech32]地址的 BIP 草案。Bech32m 地址是对 Bech32 地址的轻微修改，使其可安全用于[Taproot][topic taproot]及未来协议扩展。同年晚些时候，[比特币 Wiki 页面][bech32m page]更新了 Bech32m 地址在钱包和服务中的采用情况追踪。

{:#offers}
C-Lightning 0.9.3 版本[首次发布][cl 0.9.3]了[洋葱消息][topic onion messages]和[报价协议][topic offers]新协议。洋葱消息允许闪电网络节点以最小化开销的方式向其他节点发送消息，相较基于[HTLC][topic htlc]的消息传递更高效。报价协议利用洋葱消息使节点可主动*报价*支付，接收方节点可返回详细发票及其他必要信息。洋葱消息和报价协议在年内持续作为草案规范，但获得了更多开发进展，包括一项利用它们[降低卡顿支付影响][offers stuck]的提案。

## 二月

{:#safegcd}
比特币贡献者们[推进了][safegcd blog]改进签名生成与验证算法的研究进展，并基于研究成果提出了具备额外优化的变体算法。该算法在 libsecp256k1（[1][secp831]、[2][secp906]）和 Bitcoin Core 中[实现][bcc21573]后，将签名验证时间缩短约 10%——对于验证比特币区块链中近十亿个签名而言意义重大。多位密码学家参与验证了该变更的数学严谨性和安全性。此次优化还显著提升了低功耗硬件签名设备的安全签名生成速度。

{:#jamming}
[通道阻塞攻击][topic channel jamming attacks]作为闪电网络自 2015 年就存在的已知问题，全年持续引发讨论，先后有[多种][jam1][可行][jam2][方案][jam3]被提出。遗憾的是年内未形成广泛认可的解决方案，该问题至年底仍未得到有效缓解。

{:.center}
![阻塞攻击示意图](/img/posts/2020-12-ln-jamming-attacks.png)

## 三月
{:#quantum}
三月围绕量子计算机攻击比特币风险的[讨论][quant]尤为激烈，尤其针对[Taproot][topic taproot]激活并被广泛使用后的场景。比特币的原始特性之一 —— 公钥哈希（可能最初是为缩短比特币地址而设计）—— 在量子计算突然取得重大突破时，或能增加攻击者窃取少数用户资金的难度。而 Taproot 未延续此特性，至少有一位开发者担忧这会带来不合理风险。尽管大量反驳论点被提出，社区对 Taproot 的支持度似乎并未受到影响。

<div markdown="1" class="callout" id="taproot">

## 2021 年度总结<br>Taproot 激活之路

截至 2020 年底，包含 [schnorr 签名][topic schnorr signatures]和 [Tapscript][topic tapscript] 支持的 [Taproot][topic taproot] 软分叉实现已[合并][bcc#19953]至 Bitcoin Core。这标志着协议开发者的主要工作基本完成，社区可自主选择激活 Taproot，钱包开发者则着手添加对其及相关技术（如 [Bech32m][topic bech32] 地址）的支持。

{% comment %}<!-- comments in bold text below tweak auto-anchors to prevent ID conflicts -->{% endcomment %}

- ​**<!--january-taproot-->​**​**1 月**：Bitcoin Core 0.21.0 [发布][bcc21]，首次支持 [Signet][topic signet] 测试网络，其中默认 Signet 已激活 Taproot，为用户和开发者提供便捷的测试环境。

- ​**<!--february-taproot-->​**​**2 月**：`##taproot-activation` IRC 频道召开[首次][tapa1]及[后续][tapa2][会议][tapa3]，该频道成为开发者、用户和矿工讨论 Taproot 激活方案的主要平台。

- ​**<!--march-taproot-->​**​**3 月**：经过多轮讨论，参与者初步同意尝试名为*快速试验（speedy trial）*的激活机制，旨在快速收集矿工反馈的同时给予用户充足升级时间。该机制最终成为 Taproot 的实际[激活方式][topic soft fork activation]。

  同期，针对 Taproot 设计中使用裸公钥可能增加量子计算机攻击风险的[讨论][quant]再度引发关注。多位开发者认为担忧缺乏依据或被过度放大。

  Bitcoin Core 本月还合并了[BIP350][] 支持，使其可支付至 [Bech32m][topic bech32] 地址。这一改进修复了原 Bech32 地址在极端情况下可能导致 Taproot 用户资金丢失的隐患（原隔离见证版本地址不受此影响）。

  {% comment %}
  /zh/newsletters/2021/03/03/#rust-lightning-794
  /zh/newsletters/2021/03/10/#documenting-the-intention-to-use-and-build-upon-taproot
  /zh/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
  /zh/newsletters/2021/03/24/#bitcoin-core-20861
  /zh/newsletters/2021/03/31/#should-block-height-or-mtp-or-a-mixture-of-both-be-used-in-a-soft-fork-activation-mechanism
  {% endcomment %}

- ​**<!--april-taproot-->​**​**4 月**：协议开发者与用户就两种快速试验机制的细微差异[展开辩论][tapa4]，最终通过[妥协方案][bcc#21377]达成一致，Bitcoin Core 发布包含激活机制和参数的[版本][bcctap]。

- ​**<!--may-taproot-->​**​**5 月**：矿工[开始][signal began][发出信号][signal able]表示支持 Taproot，进度追踪网站 [taproot.watch][taproot.watch] 获得广泛关注。

- ​**<!--june-taproot-->​**​**6 月**：矿工[锁定 Taproot 激活][lockin]，承诺在约 6 个月后的区块高度 {{site.trb}} 强制执行。钱包开发者随即[投入][rb#589][适配工作][bcc#22051]，闪电网络等基础设施也[跟进调整][bolts#672]。Optech 启动[《Taproot 准备指南》][p4tr]系列文章。

- ​**<!--july-taproot-->​**​**7 月**：比特币 Wiki 创建[专页][bech32m page]追踪 Bech32m 地址格式支持情况，多数钱包和服务商完成适配。其他[软分叉提案][bip118 update]也吸取 Taproot 经验进行[优化][bip119 update]。

- ​**<!--august-taproot-->​**​**8 月**：Taproot 开发进入平静期，部分[技术文档][reuse risks]完成编写。

- ​**<!--september-taproot-->​**​**9 月**：主流商户软件 BTCPay Server [提前支持][btcpay taproot] Taproot。新操作码 [OP_TLUV][op_tluv] 提案利用 Taproot 特性实现链上[契约][topic covenants]。

- ​**<!--october-taproot-->​**​**10 月**：随着激活日临近，开发者[加速][rb#563][测试][testing taproot]，BIP 文件[扩充测试用例][expanded test vectors]以验证各实现方案。

- ​**<!--november-taproot-->​**​**11 月**：Taproot 成功[激活][taproot activation]。尽管区块 {{site.trb}} 及其后数个区块未包含 Taproot 交易引发短暂困惑，但矿池迅速调整后即正常处理交易。相关软件[持续优化][nov cs][验证流程][cbf verification]。

- ​**<!--december-taproot-->​**​**12 月**：Bitcoin Core 支持[描述符钱包][topic descriptors]生成 Bech32m 收款地址。闪电网络开发者[探讨][ln ptlcs]如何利用 Taproot 特性优化支付。

尽管在 Taproot 激活机制的选择过程中遭遇波折，且激活初期出现短暂困惑，但比特币整体上对 Taproot 软分叉的支持工作进展顺利。这远非 Taproot 故事的终结。随着钱包及基础设施开发者逐步挖掘其众多功能，Optech 预计未来数年将持续投入大量篇幅报道相关进展。

</div>

## 四月

{:#amp}
LND 在 4 月[新增支持][lnd#5709]原子多路径支付（AMP，Atomic Multipath Payments），因提出时间早于当前主流实现支持的[简化多路径支付][topic multipath payments]（SMPs）而被称为原始 AMP。相比 SMP，AMP 具备隐私优势，且确保接收方在申领支付前已收到所有路径款项。其缺点在于无法生成支付密码学证明。LND 将其应用于[即时支付][topic spontaneous payments]场景（该场景本身无需支付证明），从而规避了 AMP 的主要缺陷。

## 五月

{:#bip125}
5 月披露了 [BIP125][] 交易[替换][topic rbf]规范与 Bitcoin Core 实现之间的[不一致性][bip125 discrep]。据我们所知，该问题不会导致比特币资金风险，但引发了多轮关于意外交易中继行为对合约协议（如闪电网络）用户影响的讨论。

{:#dual-funding}
同月，C-Lightning 项目[合并][cl#4489]了[双向资助通道][topic dual funding]管理插件（双方均可提供初始资金的通道）。结合今年早些时候[合并][cl#4410]的双向资助功能，该功能使通道发起方不仅能在通道内发送资金，还能在通道初始状态下接收资金。这种初始收款能力使双向资助特别适用于以接收而非发送为主的商户场景。

<div markdown="1" class="callout" id="releases">

### 2021 年度总结<br>热门基础设施项目主要版本发布

- ​[Eclair 0.5.0][] 新增支持可扩展集群模式（参见[Newsletter #128][news128 akka]）、区块链监控机制（[Newsletter #123][news123 watchdog]）及更多插件钩子。

- ​[Bitcoin Core 0.21.0][] 包含对使用[版本 2 地址广播消息][topic addr v2]的新版 Tor 洋葱服务支持，可选提供[致密区块过滤器][topic compact block filters]功能，并支持 [Signet][topic signet] 测试网络（包含已激活[Taproot][topic taproot]的默认 Signet）。同时实验性支持原生使用[输出脚本描述符][topic descriptors]的钱包。

- ​[Rust Bitcoin 0.26.0][] 新增 Signet 支持、版本 2 地址广播消息，并优化了[部分签名比特币交易（PSBT）][topic psbt]处理。

- ​[LND 0.12.0-beta][] 支持搭配[锚定输出][topic anchor outputs]使用[瞭望塔][topic watchtowers]，新增用于操作[PSBT][topic psbt]的 `psbt` 钱包子命令。

- ​[HWI 2.0.0][] 新增 BitBox02 硬件钱包的多签支持，改进文档，并支持通过 Trezor 支付 `OP_RETURN` 输出。

- ​[C-Lightning 0.10.0][] 增强 API 功能，并实验性支持[双向资助][topic dual funding]通道。

- ​[BTCPay Server 1.1.0][] 集成[闪电网络循环（Lightning Loop）][news53 lightning loop]支持，新增 [WebAuthN/FIDO2][fido2 website] 作为双因素认证选项，优化界面设计，并宣布未来版本号将采用[语义化版本控制][semantic versioning website]。

- ​[Eclair 0.6.0][] 包含多项提升用户安全与隐私的改进，同时兼容未来可能使用[Bech32m][topic bech32]地址的软件。

- ​[LND 0.13.0-beta][] 默认采用[锚定输出][topic anchor outputs]作为承诺交易格式以优化费率管理，新增支持使用剪枝版比特币全节点，支持通过原子多路径支付（[AMP][topic amp]）收发款项，并增强[PSBT][topic psbt]功能。

- ​[Bitcoin Core 22.0][] 支持[I2P][topic anonymity networks]匿名网络连接，移除对[Tor v2][topic anonymity networks]的支持，并强化[硬件钱包][topic hwi]支持。

- ​[BDK 0.12.0][] 新增通过 Sqlite 存储数据的功能。

- ​[LND 0.14.0][] 包含增强的[日蚀攻击][topic eclipse attacks]防护（参见 [Newsletter #164][news164 ping]）、远程数据库支持（[Newsletter #157][news157 db]）、更快的路径搜索（[Newsletter #170][news170 path]）、针对 Lightning Pool 用户的优化（[Newsletter #172][news172 pool]）及可复用的 [AMP][topic amp] 发票（[Newsletter #173][news173 amp]）。

- ​[BDK 0.14.0][] 简化了为交易添加 `OP_RETURN` 输出的流程，并优化了向[Bech32m][topic bech32]地址（用于 Taproot）支付的功能。


</div>

## 六月

{:#csb}
六月讨论的[新分析][csb]提出了一种矿工选择打包交易的替代方案。该方法预计短期内可小幅提升矿工收益。长期来看，若被广泛采用，支持该方案的钱包在使用 [CPFP][topic cpfp] 追加手续费时可实现协同，从而提高该技术的有效性。

{:#default-rbf}
另一项提升手续费追加效率的尝试是[提议][rbf default]允许 Bitcoin Core 中的任何未确认交易进行 [RBF][topic rbf]——而不仅限于通过 [BIP125][] 选择启用的交易。此举或能解决多方协议中的手续费追加难题，并通过统一交易设置提升隐私性。另一项与隐私相关的[提案][nseq default]建议，创建 Taproot 交易的钱包应设置默认 nSequence 值（即使无需使用[BIP68][]的共识级序列功能），使需要 BIP68 功能的交易与普通交易特征趋同。两项提案虽无明显反对意见，但进展有限。

{:#mpa}
六月 Bitcoin Core 合并了实现[内存池包接受][mpa ml]的[首个 PR][bcc#20833]，这是迈向包中继的第一步。[包中继][topic package relay]允许节点和矿工将关联交易包视为单一交易进行费率评估。例如，一个低费率父交易与高费率子交易组成的包中，子交易的高收益将激励矿工同时打包父交易。尽管 Bitcoin Core 自 2016 年已支持[打包挖矿][bitcoin core #7600]，但此前缺乏交易包中继机制，导致高费率时期低费率父交易可能无法触达矿工，使得闪电网络等使用预签名交易的协议依赖的 [CPFP][topic cpfp] 机制可靠性不足。包中继旨在解决这一关键安全问题。

{:#ff}
一项 2019 年提出的闪电网络概念在 6 月重获关注。原始[快速转发（Fast Forwards）][ff orig]方案描述了如何通过减少网络往返次数接收或转发支付，从而降低带宽消耗和支付延迟。今年该方案被[扩展][ff expanded]，提出闪电网络钱包无需每次收款都启用签名密钥即可接收多笔支付，提升了密钥的离线安全性。

## 七月

{:#liq-ads}
经过多年讨论和开发，首个去中心化流动性广告系统实现[合并][cl#4639]至闪电网络实现中。仍处于草案阶段的[流动性广告][bolts #878]提案允许节点通过闪电网络 gossip 协议广播其愿意在一定期限内出租资金的意向，使其他节点能够购买入账容量以实现即时收款。看到广告的节点可以通过[双向资助][topic dual funding]的通道开通方式，在支付的同时获得入账容量。虽然无法强制广告节点实际路由支付，但该提案整合了早期方案（后来也[应用于][lnd#5709] Lightning Pool），确保广告方在约定的租赁期内无法将资金挪作他用。这意味着拒绝路由支付不会带来任何优势，反而会剥夺广告节点赚取路由手续费的机会。

{:#descriptors}
在首次[提出][descriptor gist]比特币核心集成三年后，[输出脚本描述符][topic descriptors]的[草案 BIP][descriptor bips1] [最终定稿][descriptor bips2]。描述符是包含所有必要信息的字符串，能让钱包或其他程序追踪特定脚本（即地址）或相关脚本集合（如[分层确定性钱包][topic bip32]）的资金收支。描述符与[miniscript][topic miniscript]的协同使用，可扩展钱包对多样化脚本的追踪和签名支持。其与[部分签名的比特币交易（PSBTs）][topic psbt]的结合，则能帮助钱包识别多签脚本中自身控制的密钥。截至年底，比特币核心已将基于描述符的钱包设为[新建钱包的默认选项][descriptor default]。

{:#zeroconfchan}
一种从未正式纳入闪电网络协议、但被广泛使用的通道开通方式于七月开始[标准化][0conf channels]。零确认通道开通（亦称*极速通道*）是新型单边资助通道，资助方在通道开通时将部分或全部初始资金转移至接收方。这些资金需在通道开通交易获得足够确认后才具备安全性，因此接收方通过标准闪电网络协议将部分资金转回资助方不存在风险。例如：Alice 在 Bob 的托管交易所持有若干 BTC，她请求 Bob 开通向其支付 1.0 BTC 的新通道。由于 Bob 信任自己不会双花新开通的通道，即使该通道交易尚未获得任何确认，他仍可允许 Alice 通过其节点向第三方 Carol 发送 0.1 BTC。对此行为的标准化将提升闪电网络节点与提供此类服务的商户之间的互操作性。

{:.center}
![零确认通道示意图](/img/posts/2021-07-zeroconf-channels.png)

{:#anyprevout}
两项关于新签名哈希（sighash）类型的关联提案被[整合][sighash combo]至 [BIP118][]。2017 年提出的 `SIGHASH_NOINPUT`（部分源自十年前的相关提案）被 2019 年[首次提出][anyprevout proposed]的[`SIGHASH_ANYPREVOUT` 和 `SIGHASH_ANYPREVOUTANYSCRIPT`][topic sighash_anyprevout]取代。新 sighash 类型将使闪电网络和[保险库][topic vaults]等链下协议减少需保留的中间状态数量，大幅降低存储需求和复杂度。对多方协议而言，其优势可能更为显著——可从根本上减少需要生成的不同状态数量。


## 八月

{:#fibonds}
保真债券（Fidelity bonds）这一概念最早可追溯至[2010年][wiki contract]，其原理是通过锁定比特币一定时间来为第三方系统中的恶意行为设定成本。由于锁定的比特币在时间锁到期前无法再次使用，其他系统中在此期间被封禁或处罚的用户将无法使用同一比特币创建新虚拟身份。八月，JoinMarket 首次在[生产环境][fi bonds]中大规模去中心化应用保真债券机制。该机制上线数日内，超过 50 BTC（当时价值逾 200 万美元）被施加时间锁。

{:#pathfinding}
一种新型闪电网络路径发现方案于八月[引发讨论][0base]。该技术的支持者认为，若路由节点仅按路由金额比例收费且不针对每笔支付收取最低*基础手续费*，方案将最为有效。其他开发者则持不同看法。至年底，该技术的[改良版本][cl#4771]已在 C-Lightning 中实现。

<div markdown="1" class="callout" id="optech">

### 2021 年度总结<br>Bitcoin Optech

在 Optech 成立的第四年，我们发布了 51 期[周报][newsletters]，为[主题索引][topics index]新增 30 个页面，发表了一篇[投稿博文][additive batching]，并（在[两位][zmn guest]客座[作者][darosior guest]协助下）撰写了 21 篇系列文章介绍[如何为 Taproot 升级做准备][p4tr]。全年 Optech 共发布逾 80,000 字比特币软件研发相关内容，相当于一本 250 页的书籍。<!-- wc -w _posts/en/newsletters/2021-* _includes/specials/taproot/en/* -->

</div>

## 九月

{:#tluv}
比特币开发者长期探讨的功能之一是：将比特币发送到某个脚本时，能够限制后续接收资金的脚本类型——这种机制称为[契约][topic covenants]。例如，Alice 将比特币存入一个可由其热钱包支出的脚本，但只能将资金发送至第二个脚本，该脚本会对热钱包的后续支出施加时间延迟。在延迟期内，其冷钱包可申领资金；若未申领且延迟期结束，热钱包即可自由使用资金。九月，新操作码 `OP_TAPLEAF_UPDATE_VERIFY` 被[提议][op_tluv]，用于创建此类契约，其特别利用了 Taproot 可通过单纯签名（密钥路径支出）或[类 MAST][topic mast] 脚本树（脚本路径支出）来使用资金的能力。该操作码对创建[联合资金池][topic joinpools]尤其有用，此类资金池允许多用户轻松且无需信任地共享 UTXO 所有权，可显著提升隐私性。

## 十月

{:#txhids}
十月，比特币开发者探讨了一种新的交易[标识方法][heritage identifiers]来指定其欲花费的比特币集合。当前比特币通过其在上次花费交易中的位置标识，例如"交易 foo 的第零个输出"。新提案允许结合花费交易及其在继承层级中的位置进行标识，例如"交易 bar 的第二个子交易的第零个输出"。该方案被认为可为 [eltoo][topic eltoo]、[通道工厂][topic channel factories]和[瞭望塔][topic watchtowers]等设计带来优势，这些设计均有利于闪电网络等合约协议。

{:#ptlcsx}
同月，多项闪电网络改进方案被[整合][ptlcs extreme]为单一提案，可在无需[`SIGHASH_ANYPREVOUT`][topic sighash_anyprevout]软分叉或其他共识变更的情况下，实现与 eltoo 相近的效益。该提案将支付延迟降低至接近路径上各路由节点单向数据传输所需时间，并通过在通道创建时备份所有必要数据、在多数恢复场景中动态补全数据来增强弹性。此外，该方案支持使用离线密钥接收支付，特别有利于商户节点减少在线设备使用密钥的时间。

## 十一月

{:#lnsummit}
闪电网络开发者举行了[2018 年以来的首次][2018 ln summit]全体峰会，并[讨论][2021 ln summit]了多项议题，包括在闪电网络中应用 [Taproot][topic taproot]（包含 [PTLC][topic ptlc]、用于[多签][topic multisignature]的 [MuSig2][topic musig] 和 [eltoo][topic eltoo]）、将规范讨论从 IRC 迁移至视频会议、当前闪电网络规范（BOLTs）模型的变更、[洋葱消息][topic onion messages]和[支付要约][topic offers]、[无卡支付][stuckless payments]、[通道堵塞攻击][topic channel jamming attacks]及其缓解方案、以及[蹦床路由][topic trampoline payments]。

## 十二月

{:#bumping}
对于单签的链上交易，通过提升手续费（fee bumping）来加速交易确认是相对直接的操作。但对于闪电网络和[保险库][topic vaults]等合约协议，在需要提升手续费时，可能无法获得所有原始签名者的参与。更糟糕的是，合约协议通常要求特定交易在截止时间前确认——否则诚实用户可能蒙受资金损失。十二月，关于为合约协议选择有效手续费提升机制的[研究成果][fee bump research]发布，推动了针对这一长期重要问题的解决方案讨论。

## 总结

我们在今年的总结中尝试了新做法——在不提及任何贡献者姓名的情况下，阐述了 2021 年二十余项重要进展。我们深知所有贡献者的辛勤付出，并衷心希望他们的卓越工作得到认可，但同时也希望表彰那些通常未被提及的无名英雄。

他们花费数小时进行代码审查，为现有功能编写测试以确保其行为不会意外改变，努力调试疑难问题以避免资金风险，以及完成上百项虽不显眼却至关重要的基础工作。

这份 2021 年最终期 Newsletter 谨献给他们。我们虽无法列全这些默默无闻贡献者的姓名，但通过刻意隐去本期所有署名，旨在强调比特币开发是团队协作的成果——其中最关键的工作往往由那些从未在本 Newsletter 中出现过名字的人完成。

我们向这些无名英雄及所有 2021 年比特币贡献者致以谢意。我们迫不及待想见证他们在 2022 年带来的激动人心的新进展。

*Optech Newsletter 将于 1 月 5 日恢复每周三定期发布。*

{% include references.md %}
{% include linkers/issues.md issues="878,7600" %}
[2018 summary]: /zh/newsletters/2018/12/28/
[2019 summary]: /zh/newsletters/2019/12/28/
[2020 summary]: /zh/newsletters/2020/12/23/
[cl 0.9.3]: /zh/newsletters/2021/01/27/#c-lightning-0-9-3
[safegcd blog]: /zh/newsletters/2021/02/17/#faster-signature-operations
[secp831]: /zh/newsletters/2021/03/24/#libsecp256k1-831
[secp906]: /zh/newsletters/2021/04/28/#libsecp256k1-906
[bcc21573]: /zh/newsletters/2021/06/16/#bitcoin-core-21573
[bcc21]: /zh/newsletters/2021/01/20/#bitcoin-core-0-21-0
[cl#2816]: /zh/newsletters/2019/07/24/#c-lightning-2816
[jam1]: /zh/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees
[jam2]: /zh/newsletters/2021/10/20/#lowering-the-cost-of-probing-to-make-attacks-more-expensive
[jam3]: /zh/newsletters/2021/11/10/#ln-summit-2021-notes
[quant]: /zh/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
[tapa1]: /zh/newsletters/2021/01/27/#scheduled-meeting-to-discuss-taproot-activation
[tapa2]: /zh/newsletters/2021/02/10/#taproot-activation-meeting-summary-and-follow-up
[tapa3]: /zh/newsletters/2021/02/24/#taproot-activation-discussion
[tapa4]: /zh/newsletters/2021/04/14/#taproot-activation-discussion
[bcctap]: /zh/newsletters/2021/04/21/#taproot-activation-release-candidate
[speedy trial]: /zh/newsletters/2021/03/10/#taproot-activation-discussion
[bcc#21377]: /zh/newsletters/2021/04/21/#bitcoin-core-21377
[signal began]: /zh/newsletters/2021/05/05/#miners-encouraged-to-start-signaling-for-taproot
[signal able]: /zh/newsletters/2021/05/05/#bips-1104
[taproot.watch]: /zh/newsletters/2021/05/26/#how-can-i-follow-the-progress-of-miner-signaling-for-taproot-activation
[rb#589]: /zh/newsletters/2021/05/12/#rust-bitcoin-589
[bolts#672]: /zh/newsletters/2021/06/02/#bolts-672
[bcc#22051]: /zh/newsletters/2021/06/09/#bitcoin-core-22051
[lockin]: /zh/newsletters/2021/06/16/#taproot-locked-in
[nsequence default]: /zh/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions
[cl#4591]: /zh/newsletters/2021/06/16/#c-lightning-4591
[p4tr]: /zh/preparing-for-taproot/
[bcc#21365]: /zh/newsletters/2021/06/23/#bitcoin-core-21365
[rb#601]: /zh/newsletters/2021/06/23/#rust-bitcoin-601
[p2trhd]: /zh/newsletters/2021/06/30/#key-derivation-path-for-single-sig-p2tr
[bcc#22154]: /zh/newsletters/2021/06/30/#bitcoin-core-22154
[bcc#22166]: /zh/newsletters/2021/06/30/#bitcoin-core-22166
[p4tr begins]: /zh/newsletters/2021/06/23/#preparing-for-taproot-1-bech32m-sending-support
[bech32m page]: /zh/newsletters/2021/07/14/#tracking-bech32m-support
[bip118 update]: /zh/newsletters/2021/07/14/#bips-943
[bip119 update]: /zh/newsletters/2021/11/10/#bips-1215
[reuse risks]: /zh/newsletters/2021/08/25/#are-there-risks-to-using-the-same-private-key-for-both-ecdsa-and-schnorr-signatures
[btcpay taproot]: /zh/newsletters/2021/09/15/#btcpay-server-2830
[op_tluv]: /zh/newsletters/2021/09/15/#covenant-opcode-proposal
[rb#563]: /zh/newsletters/2021/10/06/#rust-bitcoin-563
[rb#644]: /zh/newsletters/2021/10/06/#rust-bitcoin-644
[testing taproot]: /zh/newsletters/2021/10/20/#testing-taproot
[expanded test vectors]: /zh/newsletters/2021/11/03/#taproot-test-vectors
[taproot activation]: /zh/newsletters/2021/11/17/#taproot-activated
[rb#691]: /zh/newsletters/2021/11/17/#rust-bitcoin-691
[cbf verification]: /zh/newsletters/2021/11/10/#additional-compact-block-filter-verification
[lnd#5709]: /zh/newsletters/2021/10/27/#lnd-5709
[bitcoin core 0.21.0]: /zh/newsletters/2021/01/20/#bitcoin-core-0-21-0
[eclair 0.5.0]: /zh/newsletters/2021/01/06/#eclair-0-5-0
[rust bitcoin 0.26.0]: /zh/newsletters/2021/01/20/#rust-bitcoin-0-26-0
[lnd 0.12.0-beta]: /zh/newsletters/2021/01/27/#lnd-0-12-0-beta
[hwi 2.0.0]: /zh/newsletters/2021/03/17/#hwi-2-0-0
[c-lightning 0.10.0]: /zh/newsletters/2021/04/07/#c-lightning-0-10-0
[btcpay server 1.1.0]: /zh/newsletters/2021/05/05/#btcpay-1-1-0
[eclair 0.6.0]: /zh/newsletters/2021/05/26/#eclair-0-6-0
[lnd 0.13.0-beta]: /zh/newsletters/2021/06/23/#lnd-0-13-0-beta
[bitcoin core 22.0]: /zh/newsletters/2021/09/15/#bitcoin-core-22-0
[bdk 0.12.0]: /zh/newsletters/2021/10/20/#bdk-0-12-0
[lnd 0.14.0]: /zh/newsletters/2021/11/24/#lnd-0-14-0-beta
[bdk 0.14.0]: /zh/newsletters/2021/12/08/#bdk-0-14-0
[csb]: /zh/newsletters/2021/06/02/#candidate-set-based-csb-block-template-construction
[rbf default]: /zh/newsletters/2021/06/23/#allowing-transaction-replacement-by-default
[nseq default]: /zh/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions
[bcc#20833]: /zh/newsletters/2021/06/02/#bitcoin-core-20833
[ff expanded]: /zh/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key
[cl#4639]: /zh/newsletters/2021/07/28/#c-lightning-4639
[descriptor bips1]: /zh/newsletters/2021/07/07/#bips-for-output-script-descriptors
[descriptor bips2]: /zh/newsletters/2021/09/08/#bips-1143
[descriptor default]: /zh/newsletters/2021/10/27/#bitcoin-core-23002
[descriptor gist]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82/
[0conf channels]: /zh/newsletters/2021/07/07/#zero-conf-channel-opens
[sighash combo]: /zh/newsletters/2021/07/14/#bips-943
[fi bonds]: /zh/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[0base]: /zh/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[newsletters]: /zh/newsletters/
[topics index]: /en/topics/
[additive batching]: /zh/cardcoins-rbf-batching/
[zmn guest]: /zh/newsletters/2021/09/01/#准备-taproot-11使用-taproot-的闪电网络
[darosior guest]: /zh/newsletters/2021/09/08/#准备-taproot-12使用-taproot-的保险库
[heritage identifiers]: /zh/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[ptlcs extreme]: /zh/newsletters/2021/10/13/#multiple-proposed-ln-improvements
[lnd#5709]: /zh/newsletters/2021/10/27/#lnd-5709
[2018 ln summit]: /zh/newsletters/2018/11/20/#特性新闻闪电网络协议-11-目标
[2021 ln summit]: /zh/newsletters/2021/11/10/#ln-summit-2021-notes
[stuckless payments]: /zh/newsletters/2019/07/03/#stuckless-payments
[bcc#19953]: /zh/newsletters/2020/10/21/#bitcoin-core-19953
[lnd#5025]: /zh/newsletters/2021/06/02/#lnd-5025
[signet reorgs]: /zh/newsletters/2021/09/15/#signet-reorg-discussion
[bech32 bip]: /zh/newsletters/2021/01/13/#bech32m
[offers stuck]: /zh/newsletters/2021/04/21/#using-ln-offers-to-partly-address-stuck-payments
[news128 akka]: /zh/newsletters/2020/12/16/#eclair-1566
[news123 watchdog]: /zh/newsletters/2020/11/11/#eclair-1545
[news53 lightning loop]: /zh/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[semantic versioning website]: https://semver.org/
[fido2 website]: https://fidoalliance.org/fido2/fido2-web-authentication-webauthn/
[news164 ping]: /zh/newsletters/2021/09/01/#lnd-5621
[news157 db]: /zh/newsletters/2021/07/14/#lnd-5447
[news170 path]: /zh/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /zh/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /zh/newsletters/2021/11/03/#lnd-5803
[bcc#22364]: /zh/newsletters/2021/12/01/#bitcoin-core-22364
[ln ptlcs]: /zh/newsletters/2021/12/15/#preparing-ln-for-ptlcs
[anyprevout proposed]: /zh/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes
[cl#4489]: /zh/newsletters/2021/05/12/#c-lightning-4489
[cl#4410]: /zh/newsletters/2021/03/17/#c-lightning-4404
[bip125 discrep]: /zh/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation
[wiki contract]: https://en.bitcoin.it/wiki/Contract#Example_1:_Providing_a_deposit
[cl#4771]: /zh/newsletters/2021/10/27/#c-lightning-4771
[fee bump research]: /zh/newsletters/2021/12/08/#fee-bumping-research
[nov cs]: /zh/newsletters/2021/11/17/#服务和客户端软件的更改
[dec cs]: /zh/newsletters/2021/12/15/#服务和客户端软件的更改
[mpa ml]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019464.html
[ff orig]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[2020 conclusion]: /zh/newsletters/2020/12/23/#conclusion
