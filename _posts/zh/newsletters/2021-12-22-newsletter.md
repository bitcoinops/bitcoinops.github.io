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
  * [洋葱消息与 offers 协议](#offers)
* 2 月
  * [签名创建与验证加速](#safegcd)
  * [通道堵塞攻击](#jamming)
* 3 月
  * [量子计算风险](#quantum)
* 4 月
  * [闪电网络原子多路径支付](#amp)
* 5 月
  * [BIP125 自愿启用的手续费替换（RBF）分歧](#bip125)
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
  * [忠诚债券](#fibonds)
  * [闪电网络寻路](#pathfinding)
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
经过多年讨论，支持 [Signet][topic signet] 的 Bitcoin Core 版本于 1 月[首次发布][bcc21]，此前 C-Lightning 已[支持][cl#2816]，随后 LND 也[支持][lnd#5025]。Signet 是任何人都可以使用的测试网络，可用来模拟比特币主网（mainnet）的现状，或它在某些变更（例如激活某项软分叉共识变更）之后可能呈现的样子。大多数实现 Signet 的软件还支持一个默认 signet，这为不同团队开发的软件提供了一个特别方便的测试环境，尽可能贴近它们在真实资金攸关时所面对的环境。今年还[讨论][signet reorgs]了在 Bitcoin Core 的默认 signet 网络中刻意加入区块链重组，以帮助开发者测试自己的软件应对这类问题的能力。

{:#bech32m}
一月还[宣布][bech32 bip]了 [bech32m][topic bech32] 地址的 BIP 草案。bech32m 地址是 bech32 地址的轻微修改，使其可安全用于 [taproot][topic taproot] 及未来的协议扩展。同年晚些时候，一个[比特币 Wiki 页面][bech32m page]更新了 bech32m 地址在钱包和服务中的采用情况追踪。

{:#offers}
C-Lightning 0.9.3 的另一项[首次发布][cl 0.9.3]带来了一项新协议：[洋葱消息][topic onion messages]和 [offers 协议][topic offers]。洋葱消息让 LN 节点可以向另一个节点发送消息，其开销比基于 [HTLC][topic htlc] 的消息传递方式更小。offers 使用洋葱消息，让一个节点可以*提议*向另一个节点付款，并让接收方节点返回详细的发票及其他必要信息。洋葱消息和 offers 在当年余下的时间里一直是草案规范，但获得了更多开发，其中还包括一项利用它们来[减轻支付卡住的影响][offers stuck]的提案。

## 二月

{:#safegcd}
比特币贡献者[推进][safegcd blog]了一项改进签名生成与验证算法的研究，随后又利用研究成果做出了一个带有更多改进的变体。该算法先后在 libsecp256k1（[1][secp831]、[2][secp906]）和 [Bitcoin Core][bcc21573] 中实现，把验证签名所需的时间缩短了约 10%——在验证比特币区块链中大约十亿个签名时，这是相当可观的改进。多位密码学家参与了工作，以确保该变更在数学上站得住脚、使用起来是安全的。这一变更还显著提升了在低功耗硬件签名设备上安全生成签名的速度。

{:#jamming}
[通道堵塞攻击][topic channel jamming attacks]是 LN 自 2015 年起就已知的问题，全年持续引发讨论，先后讨论了[多种][jam1][可能][jam2]的[解决方案][jam3]。遗憾的是，年内并未形成被广泛接受的方案，该问题到年底仍未得到缓解。

{:.center}
![通道堵塞攻击示意图](/img/posts/2020-12-ln-jamming-attacks.png)

## 三月

{:#quantum}
三月围绕量子计算机攻击比特币风险的[讨论][quant]尤为激烈，尤其针对[Taproot][topic taproot]激活并被广泛使用后的场景。比特币的原始特性之一 —— 公钥哈希（可能最初是为缩短比特币地址而设计）—— 如果量子计算突然取得重大突破，它也很可能增加了攻击者窃取少数用户资金的难度。而 Taproot 未延续此特性，至少有一位开发者担忧这会带来不合理风险。尽管大量反驳论点被提出，社区对 Taproot 的支持度似乎并未受到影响。

<div markdown="1" class="callout" id="taproot">

### 2021 年度总结<br>Taproot 激活

截至 2020 年底，包含 [schnorr 签名][topic schnorr signatures] 与 [tapscript][topic tapscript] 支持的 [taproot][topic taproot] 软分叉实现已[合并][bcc#19953]到 Bitcoin Core。协议开发者的工作至此基本完成；接下来是否激活 taproot 取决于社区，钱包开发者则要开始支持 taproot 及相关技术，例如 [bech32m][topic bech32] 地址。

{% comment %}<!-- comments in bold text below tweak auto-anchors to prevent ID conflicts -->{% endcomment %}

- **1 月<!--taproot-->**：Bitcoin Core 0.21.0 [发布][bcc21]，这是首个支持 [signet][topic signet] 的版本，其中包括已激活 taproot 的默认 signet——为用户和开发者提供了一个便于开始测试的环境。

- **2 月<!--taproot-->**：`##taproot-activation` IRC 频道召开了[首次][tapa1]及后续[多次][tapa2]预定[会议][tapa3]。该频道随后成为开发者、用户和矿工讨论如何激活 taproot 的主要枢纽。

- **3 月<!--taproot-->**：月初，许多讨论参与者初步同意[尝试][speedy trial]一种名为 *speedy trial* 的激活方案。该方案旨在快速收集矿工反馈，同时给用户留出足够时间升级软件以执行 taproot 规则。speedy trial 后来成为实际用于激活 taproot 的[机制][topic soft fork activation]。

  在激活讨论进行期间，围绕一项设计决定——使用裸公钥——展开了最后一轮[讨论][quant]。有人认为这可能让用户资金更容易被未来的量子计算机盗取；许多开发者则认为这种担忧没有依据，至少被夸大了。

  同样在 3 月，Bitcoin Core 合并了对 [BIP350][] 的支持，使其可以支付到 [bech32m][topic bech32] 地址。这是对用于支付原始 segwit 版本地址的 bech32 地址的小幅修改，修复了一个在极少数情况下可能让 taproot 用户损失资金的 bug。（由 bech32 地址创建的原始 segwit 输出是安全的，不受该 bug 影响。）

- **4 月<!--taproot-->**：激活进程几乎脱轨，协议开发者和部分用户就两个略有差异的 speedy trial 版本[展开辩论][tapa4]。不过，两个不同版本的实现作者最终达成[妥协][bcc#21377]，使一个带有激活机制和参数的 Bitcoin Core [版本][bcctap]得以发布。

- **5 月<!--taproot-->**：矿工[得以][signal able][开始][signal began]发出准备执行 taproot 的信号，一个追踪信号进度的网站 [taproot.watch][taproot.watch] 也流行起来。

- **6 月<!--taproot-->**：矿工[锁定 taproot][lockin]，承诺在约六个月后的区块高度 {{site.trb}} 执行激活。这意味着[是时候][rb#589]让[钱包开发者][bcc#22051]和[其他基础设施开发者][bolts#672]更加[关注][bcc#21365]、并[着手][cl#4591]让[自己的软件][p2trhd][适配][rb#601] taproot 了——[许多人][bcc#22154]确实[这样做了][bcc#22166]。此外，有人[提议][nsequence default]让链上 taproot 钱包能够方便地为使用 LN、[coinswap][topic coinswap] 等合约协议的钱包贡献隐私。Optech 也[启动][p4tr begins]了[《为 Taproot 做准备》][p4tr]系列。

- **7 月<!--taproot-->**：Bitcoin Wiki 上出现了一个[页面][bech32m page]，专门追踪各钱包在 taproot 激活后使用所需的 bech32m 地址格式的支持情况。许多钱包和服务开发者积极响应，确保用户在激活后即可使用 taproot。其他[软分叉提案][bip118 update]也做了更新，以利用 taproot 或[吸取其激活过程中的经验][bip119 update]。

- **8 月<!--taproot-->**：taproot 开发相对平静，不过一些与 taproot 相关的[文档][reuse risks]已经写出。

- **9 月<!--taproot-->**：比特币最受欢迎的开源商户软件在计划激活之前就[加入][btcpay taproot]了对 taproot 的支持。同月还出现了新操作码 [OP_TLUV][op_tluv] 的提案，它利用 taproot 的特性实现基于脚本的[契约][topic covenants]。

- **10 月<!--taproot-->**：随着 taproot 激活[临近][testing taproot]，开发[活动][rb#563][重新活跃][rb#644]。taproot 的 BIP 扩充了[测试向量][expanded test vectors]，帮助钱包和基础设施开发者验证各自实现。

- **11 月<!--taproot-->**：人们庆祝 [taproot 激活][taproot activation]。最初出现了一些困惑：区块 {{site.trb}} 及其后几个区块的矿工没有打包任何 taproot 花费交易。但在多位开发者和矿池管理员的努力下，随后几天挖出的大多数区块都已准备好包含 taproot 花费交易。对 [taproot-ready][dec cs] 软件的[开发][nov cs]与[测试][cbf verification]仍在[继续][rb#691]。

- **12 月<!--taproot-->**：Bitcoin Core 合并了一个 PR，允许[描述符钱包][topic descriptors]生成 [bech32m][topic bech32] 地址以接收 taproot 支付。LN 开发者还进一步讨论了[如何利用][ln ptlcs] taproot 的特性。

尽管在 taproot 激活机制的选择上遇到波折，激活后也出现过短暂困惑，但为比特币整体加入 taproot 软分叉支持的最后几步看来进展顺利。这远不是 taproot 故事的终点。随着钱包和基础设施开发者开始利用它的众多特性，Optech 预计未来几年仍会花大量篇幅报道 taproot。

</div>

## 四月

{:#amp}
LND 在 4 月[新增支持][lnd#5709]原子多路径支付（Atomic Multipath Payments，AMP）。由于提出时间早于当前所有主流 LN 实现都支持的[简化多路径支付][topic multipath payments]（SMP），它也被称为“原始 AMP”。相比 SMP，AMP 具备隐私优势，还能确保接收方在领取支付之前已经收到所有部分。它的缺点是产生不了密码学意义上的支付证明。LND 把它用于[自发支付][topic spontaneous payments]——这种支付本质上就无法提供支付证明，因此 AMP 唯一显著的缺点也就无从谈起。

## 五月

{:#bip125}
5 月披露了 [BIP125][] 交易[替换][topic rbf]规范与 Bitcoin Core 实现之间的[不一致][bip125 discrep]。据我们所知，这并没有让任何比特币面临风险，但它确实引发了几场讨论，主题是意外的交易中继行为会给合约协议（如 LN）的用户带来哪些风险。

{:#dual-funding}
同样在 5 月，C-Lightning 项目[合并][cl#4489]了一个用于管理[双向资助通道][topic dual funding]的插件——在这类通道中，双方都可以提供一部分初始资金。加上今年早些时候[合并][cl#4410]的双向资助工作，这让发起通道开通的一方不仅能通过通道花费资金，还能在通道的初始状态下接收资金。这种一开始就能收款的能力，使双向资助特别适用于那些主要用 LN 收款而非付款的商户。

<div markdown="1" class="callout" id="releases">

### 2021 年度总结<br>热门基础设施项目的主要版本发布

- ​[Eclair 0.5.0][] 新增支持可扩展集群模式（参见[Newsletter #128][news128 akka]）、区块链监控机制（[Newsletter #123][news123 watchdog]）及更多插件钩子。

- ​[Bitcoin Core 0.21.0][] 包含对使用[版本 2 地址广播消息][topic addr v2]的新版 Tor 洋葱服务支持，可选提供[紧凑区块过滤器][topic compact block filters]功能，并支持 [Signet][topic signet] 测试网络（包含已激活[Taproot][topic taproot]的默认 Signet）。同时实验性支持原生使用[输出脚本描述符][topic descriptors]的钱包。

- ​[Rust Bitcoin 0.26.0][] 新增 Signet 支持、版本 2 地址广播消息，并优化了[部分签名比特币交易（PSBT）][topic psbt]处理。

- ​[LND 0.12.0-beta][] 支持搭配[锚定输出][topic anchor outputs]使用[瞭望塔][topic watchtowers]，并新增了用于操作 [PSBT][topic psbt] 的 `psbt` 钱包子命令。

- ​[HWI 2.0.0][] 新增 BitBox02 硬件钱包的多重签名支持，改进文档，并支持通过 Trezor 支付 `OP_RETURN` 输出。

- ​[C-Lightning 0.10.0][] 增强 API 功能，并实验性支持[双向资助][topic dual funding]通道。

- ​[BTCPay Server 1.1.0][] 集成[闪电网络循环（Lightning Loop）][news53 lightning loop]支持，新增 [WebAuthN/FIDO2][fido2 website] 作为双因素认证选项，优化界面设计，并宣布未来版本号将采用[语义化版本控制][semantic versioning website]。

- ​[Eclair 0.6.0][] 包含多项提升用户安全与隐私的改进，同时兼容未来可能使用[Bech32m][topic bech32]地址的软件。

- ​[LND 0.13.0-beta][] 通过把[锚定输出][topic anchor outputs]设为默认的承诺交易格式来改进费率管理，新增对使用剪枝后的比特币全节点的支持，允许用原子多路径支付（[AMP][topic amp]）收发款项，并增强了 LND 的 [PSBT][topic psbt] 能力。

- ​[Bitcoin Core 22.0][] 支持[I2P][topic anonymity networks]匿名网络连接，移除对[Tor v2][topic anonymity networks]的支持，并强化[硬件钱包][topic hwi]支持。

- ​[BDK 0.12.0][] 新增通过 Sqlite 存储数据的功能。

- ​[LND 0.14.0][] 包含额外的[日食攻击][topic eclipse attacks]防护（见 [Newsletter #164][news164 ping]）、远程数据库支持（[Newsletter #157][news157 db]）、更快的寻路（[Newsletter #170][news170 path]）、Lightning Pool 用户体验改进（[Newsletter #172][news172 pool]），以及可重复使用的 [AMP][topic amp] 发票（[Newsletter #173][news173 amp]）。

- ​[BDK 0.14.0][] 简化了为交易添加 `OP_RETURN` 输出的流程，并优化了向[Bech32m][topic bech32]地址（用于 Taproot）支付的功能。


</div>

## 六月

{:#csb}
六月讨论的一项[新分析][csb]描述了矿工在选择要把哪些交易放进自己创建的区块时可以采用的另一种方法。据预测，这种新方法短期内会小幅提高矿工收入。长期来看，如果矿工采用了这项技术，了解它的钱包就可以在通过[子为父付（CPFP）][topic cpfp]追加手续费时相互配合，从而提高这项技术的效果。

{:#default-rbf}
另一项让手续费追加更有效的尝试是[提议][rbf default]在 Bitcoin Core 中允许任何未确认交易被[手续费替换][topic rbf]（RBF）——而不仅仅是那些通过 [BIP125][] 自愿启用替换的交易。这有助于解决多方协议中手续费追加的一些问题，也能让更多交易采用一致的设置，从而提升隐私性。与隐私相关的另一项[提案][nseq default]则建议，创建 taproot 花费的钱包即使用不到 [BIP68][] 的共识强制序列值所提供的功能，也应当设置默认的 nSequence 值；这样，那些确实需要使用 BIP68 的软件所创建的交易就能与更常见的交易混在一起。两项提案尽管没有多少重大反对意见，但似乎都没有取得太大进展。

{:#mpa}
六月，Bitcoin Core 合并了实现[内存池包接受][mpa ml]的一系列 PR 中的[第一个][bcc#20833]，这是迈向[交易包中继][topic package relay]的第一步。交易包中继将允许中继节点和矿工在计算费率时把一组相关交易当作一笔交易来处理。一个包可能包含一笔低费率的父交易和一笔高费率的子交易；挖出子交易带来的收益会激励矿工也挖出父交易。尽管 Bitcoin Core 自 2016 年起就已[实现][bitcoin core #7600]打包挖矿，但到目前为止节点还无法以包为单位中继交易，这意味着在高费率时期，即使低费率的父交易有高费率的子交易，它们也可能到不了矿工手里。这让使用预签名交易的合约协议（如 LN）中的 [CPFP][topic cpfp] 手续费追加变得不可靠。交易包中继有望解决这一关键的安全问题。

{:#ff}
一项 2019 年为 LN 提出的想法在 6 月重获生机。最初的[快进][ff orig]（fast forwards）方案描述了 LN 钱包如何以更少的网络往返来接收或中继支付，从而减少网络带宽占用和支付延迟。今年这一想法被[扩展][ff expanded]：LN 钱包无需为每一笔支付都让签名密钥上线，就能接收多笔支付，这让密钥更容易保持安全。

## 七月

{:#liq-ads}
经过多年讨论和开发，首个去中心化流动性广告系统的实现被[合并][cl#4639]进一个 LN 实现。仍处于草案阶段的[流动性广告][bolts #878]提案允许节点利用 LN 的 gossip 协议广播自己愿意在一段时间内出租资金的意向，让其他节点可以购买入站容量，从而即时接收支付。看到广告的节点可以通过一次[双向资助][topic dual funding]的通道开通，在付款的同时获得入站容量。虽然无法强制广告节点真的去路由支付，但该提案纳入了更早的一个提案（后来也[用于][lnd#5709] Lightning Pool），使广告方在约定的租赁期结束前无法把钱挪作他用。这意味着拒绝路由支付不会带来任何好处，反而会剥夺广告节点赚取路由手续费的机会。

{:#descriptors}
在首次为 Bitcoin Core [提出][descriptor gist]三年之后，[输出脚本描述符][topic descriptors]的[草案 BIP][descriptor bips1] 得以[创建][descriptor bips2]。描述符是一种字符串，包含追踪发往某个脚本或某组相关脚本（即某个地址，或[HD 钱包][topic bip32] 中的一组相关地址）的支付、以及从这些脚本花费的支付所需的全部信息。描述符与 [miniscript][topic miniscript] 结合得很好，能让钱包追踪和签名更多种类的脚本。它们与 [PSBT][topic psbt] 也结合得很好，能让钱包确定自己在某个多重签名脚本中控制哪些密钥。到年底时，Bitcoin Core 已把基于描述符的钱包作为新建钱包的[默认选项][descriptor default]。

{:#zeroconfchan}
一种在 LN 中很常见、但此前从未被纳入 LN 协议的通道开通方式，在 7 月开始被[规范化][0conf channels]。零确认通道开通（也叫*极速通道*）是一种新型单方资助通道：资助方在开通时把自己的一部分或全部初始资金交给接受方。这些资金要等通道开通交易获得足够确认后才安全，因此接受方通过标准的 LN 协议把其中一部分资金花回资助方那边并没有风险。例如，Alice 在 Bob 的托管交易所有若干 BTC，她请 Bob 开一个新通道付给她 1.0 BTC。因为 Bob 相信自己不会双花自己刚开的通道，所以即使通道开通交易还没有一个确认，他也可以允许 Alice 通过他的节点向第三方 Carol 发送 0.1 BTC。把这种行为写入规范，应当有助于改善 LN 节点与提供这项服务的商户之间的互操作性。

{:.center}
![零确认通道示意图](/img/posts/2021-07-zeroconf-channels.png)

{:#anyprevout}
两项关于新签名哈希（sighash）类型的关联提案被[合并][sighash combo]进 [BIP118][]。2017 年提出的 `SIGHASH_NOINPUT`（部分基于更早十年间的提案）被 2019 年[首次提出][anyprevout proposed]的 [`SIGHASH_ANYPREVOUT` 和 `SIGHASH_ANYPREVOUTANYSCRIPT`][topic sighash_anyprevout] 所取代。新的 sighash 类型将使 LN 和[保险库][topic vaults]等链下协议减少需要保留的中间状态数量，从而大幅降低存储需求和复杂度。对多方协议而言，由于一开始就需要生成的不同状态减少了，好处可能更加显著。


## 八月

{:#fibonds}
忠诚债券（fidelity bonds）这一概念至少在 [2010 年][wiki contract] 就已被描述，其原理是把比特币锁定一段时间，从而为第三方系统中的不当行为制造成本。由于锁定的比特币在时间锁到期前无法再次使用，其他系统中在锁定期间被封禁或以其他方式受到惩罚的用户，就无法用同一批比特币再创建一个新的虚拟身份。八月，JoinMarket 首次在[生产环境][fi bonds]中大规模、去中心化地使用忠诚债券。上线数日内，锁定（时间锁）的比特币就超过了 50 BTC（当时价值超过 200 万美元）。

{:#pathfinding}
一种新的 LN 寻路变体在八月[引发了讨论][0base]。该技术的支持者认为，如果路由节点只按所路由金额的百分比收费，而不对每笔支付收取最低的*基础手续费*，这种方案会最有效。其他人则不这么看。到年底，该技术的一个[变体][cl#4771]已在 C-Lightning 中实现。

<div markdown="1" class="callout" id="optech">

### 2021 年度总结<br>Bitcoin Optech

在 Optech 成立的第四年，我们发布了 51 期 [Newsletter][newsletters]，为[主题索引][topics index]新增 30 个页面，发表了一篇[投稿博文][additive batching]，并（在[两位][zmn guest]客座[作者][darosior guest]协助下）撰写了 21 篇系列文章，介绍[如何为 taproot 激活做准备][p4tr]。全年 Optech 共发布逾 80,000 字比特币软件研发相关内容，相当于一本 250 页的书籍。<!-- wc -w _posts/en/newsletters/2021-* _includes/specials/taproot/en/* -->

</div>

## 九月

{:#tluv}
比特币开发者长期探讨的功能之一是：将比特币发送到某个脚本时，能够限制后续接收资金的脚本类型——这种机制称为[契约][topic covenants]。例如，Alice 将比特币存入一个可由其热钱包支出的脚本，但只能将资金发送至第二个脚本，该脚本会对热钱包的后续支出施加时间延迟。在延迟期内，其冷钱包可申领资金；若未申领且延迟期结束，热钱包即可自由使用资金。九月，新操作码 `OP_TAPLEAF_UPDATE_VERIFY` 被[提议][op_tluv]，用于创建此类契约，其特别利用了 Taproot 可通过单纯签名（密钥路径支出）或[类 MAST][topic mast] 脚本树（脚本路径支出）来使用资金的能力。该操作码对创建[联合资金池][topic joinpools]尤其有用，此类资金池允许多用户轻松且无需信任地共享 UTXO 所有权，可显著提升隐私性。

## 十月

{:#txhids}
十月，比特币开发者讨论了一种新方法，让交易能够[指明][heritage identifiers]自己想花费的是哪一组比特币。目前，比特币是靠它在最后一次花费它的那笔交易中的位置来标识的，例如“交易 foo 的第零个输出”。一项新提案则允许用此前花费过它们的那笔交易、它们在派生层级中的位置以及它们的位置来标识比特币，例如“交易 bar 的第二个子交易的第零个输出”。有人提出，这会给 [eltoo][topic eltoo]、[通道工厂][topic channel factories]和[瞭望塔][topic watchtowers]等设计带来好处，而这些设计都有利于 LN 等合约协议。

{:#ptlcsx}
同月，若干已有的 LN 改进想法被[打包][ptlcs extreme]成一份单一提案，它能带来 eltoo 的部分好处，却无需 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 软分叉或任何其他共识变更。该提案将把支付延迟降低到几乎等同于数据在特定路径上所有路由节点之间单向传输所需的时间。它还会增强弹性：节点可以在创建通道时备份它需要的全部信息，并在数据恢复时于多数情况下取得其他所需信息。它还将允许用离线密钥接收支付，这尤其能让商户节点缩短其密钥需要被联网计算机使用的时间。

## 十一月

{:#lnsummit}
LN 开发者举行了[2018 年以来][2018 ln summit]的首次全体 LN 峰会，并[讨论][2021 ln summit]了多个议题，包括在 LN 中使用 [taproot][topic taproot]（含 [PTLC][topic ptlc]、用于[多重签名][topic multisignature]的 [MuSig2][topic musig] 以及 [eltoo][topic eltoo]）；把规范讨论从 IRC 转到视频聊天；当前 BOLTs 规范模型的变更；[洋葱消息][topic onion messages]与 [offers][topic offers]；[无阻支付][stuckless payments]；[通道堵塞攻击][topic channel jamming attacks]及各种缓解措施；以及[蹦床路由][topic trampoline payments]。

## 十二月

{:#bumping}
对于单签的链上交易，通过手续费追加（fee bumping）提高一笔交易的费率、促使矿工更早确认它，是相对直接的操作。但对 LN 和[保险库][topic vaults]等合约协议来说，在需要追加手续费时，当初授权这笔花费的签名者未必都能到场。更糟的是，合约协议常常要求某些交易必须在截止时间前得到确认，否则诚实用户就可能损失资金。十二月，一份关于如何为合约协议选择有效手续费追加机制的研究成果[发表][fee bump research]，推动了对这一重要的长期问题所需解决方案的讨论。

## 总结

我们在今年的总结中尝试了新做法：在不提及任何一位贡献者姓名的情况下，描述 2021 年的二十多项值得注意的进展。我们感激所有这些贡献者，也非常希望他们的出色工作得到认可，但同样想表彰那些我们通常不会提到的贡献者。

他们花数小时做代码审查，为已有行为编写测试以确保它不会意外改变，努力调试疑难问题以便在资金面临风险之前修复故障，或者在做上百项其他工作——这些工作只有在没人做的时候才会成为新闻。

这份 2021 年的最后一期 Newsletter 谨献给他们。我们没有简单的方法列出这些未得到充分认可的贡献者的名字。于是我们选择隐去本期中的所有名字，以此表明：开发比特币是一项团队工作，其中一些最重要的工作正是由那些名字从未出现在本刊任何一期的人完成的。

我们感谢他们，也感谢 2021 年所有为比特币做出贡献的人。我们迫不及待想看到他们在 2022 年带来哪些激动人心的新进展。

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
[darosior guest]: /zh/newsletters/2021/09/08/#准备-taproot-12配合-taproot-的保险库
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
[nov cs]: /zh/newsletters/2021/11/17/#服务和客户端软件的变更
[dec cs]: /zh/newsletters/2021/12/15/#服务和客户端软件的变更
[mpa ml]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019464.html
[ff orig]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[2020 conclusion]: /zh/newsletters/2020/12/23/#conclusion
