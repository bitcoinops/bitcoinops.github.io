---
title: 'Bitcoin Optech Newsletter #78: 2019 Year-in-Review Special'
permalink: /zh/newsletters/2019/12/28/
name: 2019-12-28-newsletter-zh
slug: 2019-12-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh

excerpt: >
  本期特刊总结 2019 年全年比特币的值得注意发展。
---
{{page.excerpt}} 这是我们对 [2018 年总结][2018 summary]的续篇。

{% comment %}
  ## 提交
  $ for d in bitcoin/ c-lightning/ eclair/ lnd/ secp256k1/ bips/ lightning-rfc/ ; do
    cd $d ; git log --oneline --since=2019-01-01 upstream/master | wc -l ; cd -
  done | numsum
  8863

  ## 合并
  $ for d in bitcoin/ c-lightning/ eclair/ lnd/ secp256k1/ bips/ lightning-rfc/ ; do
    cd $d ; git log --oneline --merges --since=2019-01-01 upstream/master | wc -l ; cd -
  done | numsum
  1988

  ## 邮件列表帖子
  $ for d in .lists.bitcoin-devel/ .lists.lightning/ ; do
    find $d -type f | xargs -i sed -n '1,/^$/p' '{}' | grep '^Date: .* 2019 ' | wc -l
  done | numsum
  1529

  ## 通讯字数；除以 350 得到页数
  #
  ## 注意，不包括此总结
  $ cd _posts/en/newsletters   # end italics_
  $ find 2019-* | xargs wc -w | tail -n1   # end italics*
  72450 total
{% endcomment %}

本总结主要基于我们过去一年发布的[每周 Newsletter][weekly newsletters]，我们查阅了近 9,000 个提交（近 2,000 个合并）、超过 1,500 个邮件列表帖子、数千行 IRC 日志，以及其他众多公开来源。最初，我们用了 50 期 Newsletter、超过 200 页印刷量的内容来总结这些出色的工作。即便如此，我们依然遗漏了许多重要贡献，尤其是那些修复错误、编写测试、进行审查和提供支持的人们的贡献——这些工作至关重要，但未必“值得报道”。在进一步压缩、试图把整整一年塞进这篇文章的几页纸里时，我们现在又省略了许多其他重要贡献。

因此，在继续之前，我们想向 2019 年为比特币做出贡献的每一个人表示衷心的感谢。即使以下总结没有提到你或你的项目，也请你知道，我们在 Optech——可能还有所有比特币用户——对你为比特币所做的一切感激不已，难以用言语表达。

## 目录

* 一月
    * [BIP127 储备证明](#bip127)
* 二月
    * [Bitcoin Core 与 HWI 兼容](#core-hwi)
    * <a href="#miniscript">Miniscript</a>
* 三月
    * [共识清理软分叉提案](#cleanup)
    * <a href="#signet">Signet</a>
    * [Lightning Loop](#loop)
* 四月
    * <a href="#assumeutxo">AssumeUTXO</a>
    * [蹦床支付](#trampoline)
* 五月
    * <a href="#taproot">Taproot</a>
    * [SIGHASH_ANYPREVOUT](#anyprevout)
    * [OP_CHECKTEMPLATEVERIFY](#ctv)
* 六月
    * [Erlay 及其他 P2P 中继改进](#erlay-and-other-p2p-improvements)
    * <a href="#watchtowers">瞭望塔</a>
* 七月
    * [可重复构建](#reproducibility)
* 八月
    * [不使用契约的保险库](#vaults)
* 九月
    * <a href="#snicker">SNICKER</a>
    * [LN 漏洞](#ln-cve)
* 十月
    * [LN 锚定输出](#anchor-outputs)
* 十一月
    * <a href="#bech32-mutability">bech32 可变性</a>
    * [Bitcoin Core 移除 OpenSSL](#openssl)
    * [Bitcoin Core 移除 BIP70](#bip70)
* 十二月
    * [多路径支付](#multipath)
* 精选总结
    * [流行基础设施项目的主要发布](#releases)
    * [值得注意的技术会议和其他活动](#conferences)
    * [Bitcoin Optech](#optech)
    * [新的开源基础设施解决方案](#new-infrastructure)

## 一月

{:#bip127}
在一月，Steven Roose [提议][roose reserves]为 *储备证明* 伪交易制定一种标准化格式，供比特币托管方用来说明自己控制着一定数量的比特币。这类工具都无法保证存款人一定能从托管方处取回自己的币，但可以让托管方更难隐瞒币的丢失或被盗。Roose 随后基于部分签名比特币交易（[PSBT][topic psbt]）做出了一种生成储备证明的[工具][news33 reserves]，并最终推动该规范发布为 [BIP127][]。

## 二月

{:#core-hwi}
在二月，Bitcoin Core 的主开发分支合并了最后一组拉取请求，使其能够配合[硬件钱包接口（HWI）][topic hwi]的 Python 库和命令行工具使用。HWI 随后在三月发布首个稳定版本，Wasabi 钱包在[四月][wasabi hwi]添加了对其的支持，BTCPay 也在十一月通过一个[附加包][btcpayserver.vault]添加了支持<!--
https://github.com/btcpayserver/btcpayserver/pull/1152 -->。HWI 让硬件钱包和软件钱包可以借助[输出脚本描述符][topic descriptors]与部分签名比特币交易（[PSBT][topic psbt]）的组合进行交互。2019 年，对标准化格式与 API 的支持不断增加，使用户更容易按需选择合适的硬件与软件组合，而不必在两种方案中二选一。

<div markdown="1" id="miniscript">

同样在二月，Pieter Wuille 在[斯坦福区块链会议][Stanford Blockchain Conference]上做了关于 [miniscript][topic miniscript] 的[演讲][wuille sbc miniscript]，这是他在输出脚本描述符工作中的衍生项目。Miniscript 提供了比特币脚本的结构化表示，简化了软件执行的自动化分析。分析可以确定钱包需要提供哪些数据才能满足脚本（例如一个签名或一个哈希原像）、脚本及满足它的数据会占用多少交易数据，以及脚本是否符合已知的共识规则和流行的交易中继政策。

除了 miniscript，Wuille、Andrew Poelstra 和 Sanket Kanjalkar 还提供了一种可组合的策略语言，可编译为 miniscript（后者本身又会转换为比特币脚本）。借助这种策略语言，用户可以轻松描述自己花费币时希望满足的条件。当多个用户希望共同控制某个币时，策略语言的可组合性使得把每个用户各自的签名策略合并成一个脚本变得很容易。

如果被广泛采用，miniscript 可以让不同的比特币系统更容易协作签署同一笔交易，显著减少为集成钱包前端、LN 节点、coinjoin 系统、多重签名钱包、消费级硬件钱包、工业硬件签名模块（HSM）以及其他软硬件而需要编写的自定义代码量。

Wuille 和他的合作者在当年余下的时间里继续研究 miniscript，随后[请求社区反馈][news61 miniscript feedback]并[提交了一个拉取请求][Bitcoin Core #16800]，以便向 Bitcoin Core 添加支持。12 月，LN 开发者还用 miniscript 来[分析和优化][anchor miniscript]若干新脚本，这些脚本用于他们部分链上交易的升级版本。

</div>

## 三月

<div markdown="1" id="cleanup">

在三月，Matt Corallo 提出了[共识清理软分叉][topic consensus cleanup]的建议，以消除比特币共识代码中的潜在问题。如果被采纳，这些修复将消除[时间扭曲攻击][time warp attack]，降低传统脚本的[最坏情况下的 CPU 使用率][worst case CPU usage]，使交易验证状态缓存更可靠，并消除已知（但昂贵的）[对轻量客户端的攻击][news37 merkle tree attacks]。

尽管该提案的某些部分（例如时间扭曲修复）似乎吸引了各种人的兴趣，但提案的其他部分（例如对最坏情况下 CPU 使用率和有效性缓存的修复）则受到了一些[批评][news37 cleanup discussion]。或许正因为如此，该提案在下半年没有明显的实施进展。

</div>

<div markdown="1" id="signet">

三月，Kalle Alm 也请求对 [signet][topic signet] 的初步反馈，该协议最终将成为 [BIP325][]。signet 协议允许创建所有有效新块都必须由集中方签名的测试网。尽管这种集中化与比特币的理念背道而驰，但对于测试网来说，它是理想的，因为测试者有时希望创建一个破坏性的场景（例如链重组），而其他时候只想要一个稳定的平台来测试软件互操作性。在比特币现有的测试网上，重组和其他中断可能频繁发生并持续较长时间，使得常规测试变得不切实际。

signet 在这一年中逐渐成熟，最终被[集成][cl signet]到 C-Lightning 等软件中，并用于 [eltoo][] 的演示。一项向 Bitcoin Core 添加支持的[拉取请求][Bitcoin Core #16411]仍未合并。

</div>

{:#loop}
此外，在三月，Lightning Labs 宣布推出 [Lightning Loop][]，为希望把部分资金从 LN 通道提取到链上 UTXO 又不想关闭通道的用户提供一个非托管方案。在六月，他们又[升级][loop-in]了 Loop，让用户也能把 UTXO 花进现有通道。Loop 使用与常规链下 LN 交易类似的哈希时间锁定合约（HTLC），确保用户的资金要么按预期转移，要么退还除链上交易手续费以外的全部费用。这使得 Loop 几乎完全无需信任。

<div markdown="1" class="callout" id="releases">

### 2019 总结<br>流行基础设施项目的主要发布

- [C-Lightning 0.7][] 于三月发布，增加了插件系统，到年底时已被大量使用。这也是第一个支持[可重复构建][topic reproducible builds]的 C-Lightning 版本，通过改善可审计性提高了安全性。

- [LND 0.6-beta][] 于四月发布，支持[静态通道备份（SCBs）][lnd scb]，即使丢失了最近的通道状态，用户也能恢复已在 LN 通道中结算的任何资金。该版本还提供了改进的自动巡航（autopilot）功能，帮助用户开启新通道，并内置与 [Lightning Loop][] 的兼容性，以便在不关闭通道、也不使用托管的情况下在链上转移资金。

- [Bitcoin Core 0.18][] 于五月发布，改善了部分签名比特币交易（[PSBT][topic psbt]）支持，并增加了对[输出脚本描述符][topic descriptors]的支持。这两项功能结合，使其能够配合 硬件钱包接口（[HWI][]）的首个发布版本使用。

- [Eclair 0.3][] 于五月发布，提高了备份安全性，增加了对插件的支持，并可以以 Tor 隐藏服务的方式运行。

- [LND 0.7-beta][] 于七月发布，增加了使用[瞭望塔][topic watchtowers]在你离线时看护通道的支持。

- [LND 0.8-beta][] 于十月发布，增加了对可扩展性更好的洋葱格式的支持，提高了备份安全性，并改进了对瞭望塔的支持。

- [Bitcoin Core 0.19][] 于十一月发布，实现了新的 [CPFP 豁免（carve-out）][topic cpfp carve out]内存池策略，初步支持 [BIP158][] 式[紧凑区块过滤器][topic compact block filters]（目前仅支持 RPC），并通过默认禁用 [BIP37][] 布隆过滤器和 [BIP70][] 支付请求提高了安全性。它还会默认把 GUI 用户切换到 bech32 地址。

- [C-Lightning 0.8][] 于十二月发布，增加了对[多路径支付][topic multipath payments]的支持，并将默认网络从测试网切换到主网。这也是第一个支持其他数据库的主要 C-Lightning 版本，除默认的 sqlite 外还可使用 postgresql。

</div>

## 四月

{:#assumeutxo}
在四月，James O’Beirne 提出了 [AssumeUTXO][topic assumeutxo]，这是一种让全节点推迟验证旧区块链历史的方法：节点下载一份可信的近期 UTXO 集副本并暂时使用。这样一来，使用该全节点的钱包和其他软件在节点启动几分钟内就能开始收发交易，而不像现在新启动的节点那样要等上数小时甚至数天。AssumeUTXO 让节点在后台下载并验证旧的区块链历史，直到最终验证完自己的初始 UTXO 状态，从而最终获得与不使用 AssumeUTXO 的节点相同的无需信任的安全性。O'Beirne 在这一年中持续推进该项目，逐步添加[新功能][dumptxoutset]并重构现有代码，目标是最终把 AssumeUTXO 加入 Bitcoin Core。

<div markdown="1" id="trampoline">

同样在四月，Pierre-Marie Padiou [提出][trampoline proposed]了[蹦床支付][topic trampoline payments]的想法，这是一种让轻量级 LN 节点把寻路外包给重量级路由节点的方法。轻量级节点（例如移动应用）可能并不掌握完整的 LN 路由图，因此无法找到通往其他节点的路径。Padiou 的提议让轻量级节点先把支付路由到附近的一个节点，再由该节点计算余下的路径。本质上，支付在前往目的地的途中会从蹦床节点上弹开。为了增加隐私，最初的付款方可以要求支付依次从多个蹦床节点弹开，这样它们之中谁都不知道自己是在把支付路由给最终收款方，还是只是路由给另一个蹦床节点。

一个向 LN 规范添加蹦床支付功能的[拉取请求][trampolines pr]目前仍未合并，而 LN 的 Eclair 实现已经添加了中继蹦床支付的[实验性支持][exp tramp]。

</div>

## 五月

<div markdown="1" id="taproot">

在五月，Pieter Wuille 提出了一个 [taproot 软分叉][topic taproot]，包括 [bip-taproot][] 和 [bip-tapscript][]（这两个提案都依赖于去年的 [bip-schnorr][] 提案）。如果实施，这一变更将允许单签、多重签名以及许多合约都使用同一种风格的 scriptPubKey。许多来自多重签名和复杂合约的花费，彼此之间以及和单签花费之间看起来也会完全相同。这可以显著改善用户隐私和币的可替代性，同时减少多重签名和合约用例占用的区块链空间。

即使在多重签名和合约花费无法完全享有 taproot 的隐私与空间节省的情况下，它们也可能只需要把一部分代码放到链上，从而获得比今天更好的隐私和空间节省。除了 taproot，[tapscript][topic tapscript] 还对比特币的脚本能力做了小幅改进，主要是让将来添加新操作码变得更容易、更清爽。

这些提案在这一年余下的时间里得到了大量讨论和审查，包括 Anthony Towns 组织的一系列[小组审查会议][taproot review]，有超过 150 人报名参与审查。

</div>

<div markdown="1" id="anyprevout">

Towns 还在五月提出了两个新的签名哈希，配合 tapscript 使用，分别是 `SIGHASH_ANYPREVOUT` 和 `SIGHASH_ANYPREVOUTANYSCRIPT`。签名哈希（sighash）是对交易若干字段及相关数据所做的哈希，签名即对该哈希作出承诺。比特币中不同的 sighash 承诺交易的不同部分，使签名者可以选择让其他人对自己的交易做某些修改。这两个新提议的 sighash 与 [BIP118][] 的 [SIGHASH_NOINPUT][topic sighash_anyprevout] 类似，故意不指明自己要花费的是哪一个 UTXO，从而让签名可以花费任何其脚本能被该签名满足的 UTXO（例如使用同一公钥的 UTXO）。

noinput 式 sighash 的主要建议用途，是启用此前提出的 [eltoo][topic eltoo] LN 更新层。Eltoo 可以简化通道构建与管理的多个方面；对于简化[涉及两个以上参与者的通道][topic channel factories]尤其理想，因为这类通道能显著降低链上通道成本。

</div>

<div markdown="1" id="ctv">

本月提出的第三个软分叉来自 Jeremy Rubin，他[描述][coshv]了一个现在称为 `OP_CHECKTEMPLATEVERIFY`（CTV）的新操作码。这将允许一种有限形式的[契约][topic covenants]：一笔交易的某个输出会要求花费它的后续交易必须包含某些其他输出。一个建议用途是承诺式未来支付：付款方支付一笔小额的单个输出，而该输出只能通过一笔交易（或一棵交易树）来花费，那笔交易随后向数十、数百甚至数千个不同的收款方付款。这可以催生新技术，用来增强 coinjoin 式的隐私、支持提升安全性的保险库，或在交易费率飙升时控制付款方的成本。

Rubin 在当年余下的时间里继续研究 CTV，包括针对 Bitcoin Core 的若干部分提交拉取请求（[1][Bitcoin Core #17268]，[2][Bitcoin Core #17292]）进行改进——这些地方的优化能让实际部署的 CTV 版本更有效。

</div>

<div markdown="1" class="callout" id="conferences">

### 2019总结<br>值得注意的技术会议和其他活动

- **<!--stanford-blockchain-conference-->**[斯坦福区块链会议][Stanford Blockchain Conference], 一月，斯坦福大学
- **<!--mit-bitcoin-expo-->**[MIT 比特币博览会][MIT Bitcoin Expo], 三月，麻省理工学院
- **<!--optech-executive-briefing-->**[Optech 高管简报][Optech Executive Briefing], 五月，纽约市
- **<!--magical-crypto-friends-technical-track-->**[魔法加密朋友（技术专场）][mcf]，五月，纽约市
- **<!--breaking-bitcoin-->**[突破比特币][Breaking Bitcoin], 六月，阿姆斯特丹
- **<!--bitcoin-core-developers-meetup-->**[Bitcoin Core 开发者聚会][coredevtech amsterdam]，六月，阿姆斯特丹
- **<!--edge-dev-->**[Edge Dev++][Edge Dev++], 九月，特拉维夫
- **<!--scaling-bitcoin-->**[比特币扩展][Scaling Bitcoin]，九月，特拉维夫
- **<!--cryptoeconomic-systems-summit-->**[加密经济系统峰会][Cryptoeconomic Systems Summit], 十月，麻省理工学院

</div>

## 六月

<div markdown="1" id="erlay-and-other-p2p-improvements">

Gleb Naumenko、Pieter Wuille、Gregory Maxwell、Sasha Fedorova 和 Ivan Beschastnikh 发表了一篇关于 [erlay][topic erlay] 的[论文][erlay]，这是一种在节点之间中继未确认交易公告的协议，它利用基于 [libminisketch][topic minisketch] 的集合对账，据估算可将公告带宽减少 84%。论文还表明，erlay 会让节点大幅提高默认出站连接数变得更加可行。这能增强每个节点抵御 [日食攻击][eclipse attacks]的能力——这类攻击可以诱使节点接受不在工作量最大的区块链上的区块。更多出站连接还能增强节点抵御其他攻击的能力，这些攻击可能被用来追踪或延迟源自该节点的支付。erlay 的工作在这一年中持续推进，并针对集合对账协议提出了 [BIP330][]。

今年 P2P 中继方面的其他改进包括 Bitcoin Core 的[交易中继隐私改进][#14897]（消除了 Sergi Delgado-Segura 等人在 [TxProbe][] 论文中描述的一个问题），以及新增[两个额外的出站连接][two extra outbound connections]专门用于新块的中继，提高了抵御 日食攻击的能力。

</div>

<div markdown="1" id="watchtowers">

在经过大量前期工作之后，六月还见证了[利他型 LN 瞭望塔][topic watchtowers]被[合并][altruist watchtowers]进 LND。利他型瞭望塔不会因帮助保护客户的通道而从协议中获得任何奖励，因此用户需要运行自己的瞭望塔，或者依赖瞭望塔运营者的善意；但这已足以证明，瞭望塔能够可靠地代表其他用户发送惩罚交易——确保长时间离线的用户不会损失任何资金。

利他型瞭望塔最终在 [LND 0.7.0-beta][lnd 0.7-beta] 中发布，并在当年余下的时间里继续开发，包括一份[提议的规范][watchtower spec]，以及关于如何把它们与 [eltoo][topic eltoo] 等下一代支付通道结合的[讨论][eltoo watchtowers]。

</div>

## 七月

<div markdown="1" id="reproducibility">

在七月，Bitcoin Core 项目[合并][guix merge]了 Carl Dong 的拉取请求，增加了对使用 GNU Guix（读作“geeks”）构建 Bitcoin Core Linux 二进制文件的可重复构建的支持。虽然 Bitcoin Core 早已通过 [Gitian][] 系统提供可重复构建，但 Gitian 配置起来可能很困难，而且要依赖数百个 Ubuntu 软件包的安全性。相比之下，Guix 的安装和运行可能容易得多，目前用它构建 Bitcoin Core 所依赖的软件包也少得多。长远来看，Guix 的贡献者还在努力消除 [trusting trust][] 问题，以便用户能轻松验证 `bitcoind` 等二进制文件是否完全由可审计的源代码生成。

Guix 构建支持的工作在这一年中持续推进，一些贡献者希望 2020 年发布的第一个 Bitcoin Core 主要版本就能用上 Guix（也许与较旧的、基于 Gitian 的机制并行使用）。

另外，今年还分别在 [C-Lightning][cl repro] 和 [LND][lnd repro] 仓库中添加了文档，说明如何使用可信编译器创建可重复构建。

</div>

## 八月

<div markdown="1" id="vaults">

在八月，Bryan Bishop 描述了一种[不使用契约在比特币上实现保险库][vaults on Bitcoin without using covenants]的方法。*保险库*这个术语用来描述一种脚本，它即使攻击者拿到了用户的常规私钥，也能限制其窃取资金的能力。*[契约][topic covenants]*是只能花费到某些特定其他脚本的脚本。目前还没有已知的办法用现有的 Bitcoin Script 语言创建契约，但事实证明，只要用户愿意在把资金存入保险库合约时多执行几个步骤，就不需要契约。

或许更值得注意的是，Bishop 还指出了一个存在于以往保险库提案中的新弱点，以及针对该弱点的一种缓解措施，可以限制攻击者从保险库中窃取资金的最大金额。实用的保险库对个人用户和交易所等大型托管机构都可能有用。

</div>

<div markdown="1" class="callout" id="optech">

### 2019 总结<br>Bitcoin Optech

在 Optech 的第二年，我们新增了六家会员公司，在纽约区块链周期间举办了一场[高管简报会][optech executive briefing]，发布了[为期 24 周的系列文章][bech32 sending support]推广 bech32 发送支持，在网站上添加了钱包和服务的[兼容性矩阵][compatibility matrix]，发布了 51 期每周 [Newsletter][newsletters]<!-- #28 to #78, inclusive -->，有几期 Newsletter 和博客文章被翻译成[日语][xlation ja]和[西班牙语][xlation es]，创建了[主题索引][topics index]，为[可扩展性工作手册][Scalability Workbook]增加了一章，举办了两次 [schnorr/taproot 工作坊][schnorr/taproot workshops]并公开发布了 [Jupyter notebook][jupyter notebooks]，还发表了来自 [BTSE][] 和 [BRD][] 的实地报告。

我们对 2020 年有宏大的计划，希望你能继续在[推特][Twitter]上关注我们、订阅我们的[每周 Newsletter][weekly newsletter]，或者跟踪我们的 [RSS 源][RSS feed]。

</div>

## 九月

<div markdown="1" id="snicker">

Adam Gibson [提出][snicker]了一种针对现有比特币系统的新颖非交互式 [coinjoin][topic coinjoin] 形式，称为 SNICKER。该协议中，用户挑选自己的一个 UTXO，再从全局 UTXO 集中随机选一个 UTXO，让二者在同一笔交易中被花费。发起提议的用户签署这笔交易中属于自己的部分，然后把整笔交易以部分签名比特币交易（[PSBT][topic psbt]）格式上传到一台公共服务器。如果另一个用户查看该服务器并看到这个 PSBT，就可以下载、签名并广播，从而完成 coinjoin，而双方无须同时在线。发起提议的用户可以用自己同一个 UTXO 创建并上传任意数量的 PSBT，直到有其他用户接受这次 coinjoin。

SNICKER 相比其他 coinjoin 方法的主要优势在于，它不要求用户同时在线，而且凡是已经支持 [BIP174][] PSBT 的钱包，应该都很容易加上对它的支持——这样的钱包正在越来越多。

</div>

{:#ln-cve}
同样在九月，C-Lightning、Eclair 和 LND 的维护者[披露][ln missed validation]了一个影响其软件先前版本的漏洞。看起来在某些情况下，各实现都未能确认通道注资交易支付的脚本或金额是否正确（或者两者是否都正确）。如果被利用，可能导致通道支付无法在链上得到确认，使节点因把支付从无效通道中继到有效通道而损失资金。Optech 未听说有任何用户在漏洞首次公开之前因此损失资金。闪电网络规范已[更新][news67 bolts676]，以帮助未来的实现者避开此问题；人们也预期，对 LN 通信协议的[其他提议修改][dual-funding serialization]将有助于避免同类的其他故障。

## 十月

<div markdown="1" id="anchor-outputs">

LN 开发者在十月和十一月取得重大进展，着手解决一个由来已久的担忧：确保用户总能关闭自己的通道，而且不会被拖延太久。如果用户决定关闭某个通道，却联系不上对端，就会广播该通道最新的 *承诺交易*——一笔预先签名的交易，按双方链下合约的最新版本，把通道资金在链上分给各方。这种安排有一个潜在问题：承诺交易可能是在几天或几周前、手续费还较低的时候创建的，因此它支付的手续费可能不足以让它迅速确认，从而赶不上那些对安全至关重要的时间锁到期。

解决这个问题的办法一直都很明确：让承诺交易也能追加手续费。可惜的是，Bitcoin Core 这类节点必须限制手续费追加的使用，以防有人用浪费带宽和 CPU 的拒绝服务（DoS）攻击。在 LN 这种无需信任的多用户协议中，你的对手可能就是攻击者，他可以故意触发反 DoS 策略，拖慢你的 LN 承诺交易确认，这种攻击有时被称为[交易钉住][topic transaction pinning]。被钉住的交易可能无法在时间锁到期前确认，对手就能借此偷走你的资金。

去年，Matt Corallo [建议][carve-out proposed]在 Bitcoin Core 交易中继策略中与子为父付（CPFP）手续费追加有关的部分划出一项特殊豁免。这项有限的豁免确保双方合约协议（例如当前一代 LN）能保证每一方都有能力自行追加手续费。Corallo 的想法被称为 [CPFP 豁免][topic cpfp carve out]，其实现随 Bitcoin Core 0.19 发布。甚至在该版本发布之前，其他 LN 开发者就已经着手对 LN 脚本和协议消息做必要的[修订][anchor outputs]，以便开始使用这一变更。截至本文写作时，这些规范变更仍在等待最终实现和被接受，之后才会在网络中部署。

</div>

<div markdown="1" class="callout" id="new-infrastructure">

### 2019 总结<br>新的开源基础设施解决方案

- **<!--proof-of-reserves-tool-->**[储备证明工具][Proof of reserves tool] 于二月发布，让交易所和其他比特币托管方可以用 [BIP127][] 储备证明来证明自己控制着特定的一组 UTXO。

- **<!--hardware-wallet-interface-->**[硬件钱包接口][topic hwi] 于三月发布，让已经兼容部分签名比特币交易（[PSBT][topic psbt]）和[输出脚本描述符][topic descriptors]的钱包，可以借助多种不同型号的硬件钱包来安全存储密钥并签名。

- <a href="/zh/newsletters/2019/03/26/#loop-announced">Lightning Loop</a> 于三月发布（六月又加入 loop-in 支持），提供非托管服务，让用户无需关闭现有通道或新开通道，就能向自己的 LN 通道添加或取出资金。

</div>

## 十一月

<div markdown="1" id="bech32-mutability">

关于用 bech32 地址进行 [taproot][topic taproot] 支付的讨论，让更多人注意到五月发现的一个[问题][bech32 malleability issue]。按照 [BIP173][]，抄错的 bech32 字符串在最坏情况下的失败率约为十亿分之一。然而人们发现，以 `p` 结尾的 bech32 字符串，可以在前面任意添加或删除若干个 `q` 字符。这对 segwit 的 P2WPKH 或 P2WSH bech32 地址实际上没有影响，因为要把一种地址类型变成另一种，至少得添加或删除 19 个连续的 `q` 字符——而 v0 segwit 地址若长度发生其他任何变化都是无效的。 <!-- "19 characters" math in _posts/zh/newsletters/2019-11-13-newsletter.md -->

但对 v1 及更高版本的 segwit 地址（例如为 taproot 提议的那些地址）就不是这样了：在易受影响的地址中添加或删除一个 `q` 字符，就可能导致资金损失。BIP173 的共同作者 Pieter Wuille 做了[进一步分析][bech32 analysis]，发现这是 bech32 的预期纠错能力唯一的偏差，因此他提议把比特币中 BIP173 地址的使用限制为仅 20 字节或 32 字节的见证程序。这将确保 v1 及之后的 segwit 地址版本提供与 v0 segwit 地址同样可靠的纠错能力。他还描述了对 bech32 算法的一处小调整，让其他使用 bech32 的应用以及下一代比特币地址格式，都能用上 BCH 错误检测而不受这个问题影响。

</div>

{:#openssl}
同样在十一月，Bitcoin Core [移除了对 OpenSSL 的依赖][rm openssl]，而 OpenSSL 从 2009 年最初的 Bitcoin 0.1 发布起就一直是其代码库的一部分。OpenSSL 曾引发[共识漏洞][non-strict der]、[远程内存泄漏][heartbleed]（可能泄漏私钥）、[其他 bug][cve-2014-3570]以及[性能不佳][libsecp256k1 sig speedup]。大家希望移除它之后，未来出现漏洞的频率会降低。

{:#bip70}
作为移除 OpenSSL 的一部分，Bitcoin Core 在 0.18 版中弃用对 [BIP70][] 支付协议的支持，随后在 0.19 版中默认禁用该支持。2019 年仍在继续使用 BIP70 的少数公司之一，其 CEO [支持][ceo bitpay]这一决定。

## 十二月

{:#multipath}
在十二月，LN 开发者实现了去年[规划会议][ln1.1]的主要目标之一：[基本多路径支付][topic multipath payments]的[实现][mpp implementation]。这类支付可以拆成几个部分，每个部分通过不同通道单独路由。这使用户可以同时用上自己的多个通道来支出或收款，从而能在单笔支付中花掉全部链下余额，或在某些安全限制之内最多收到自己的全部容量。 <!-- safety restrictions: non-wumbo and channel reserve funding -->预计这会消除付款方对具体通道余额的顾虑，让 LN 对用户友好得多。

## 总结

上面的总结里，我们看不到任何革命性的提案或改进。看到的是一连串渐进式改良——都是在比特币和 LN 已经成功的场景上继续构建，让整个系统更好。我们看到开发者在让硬件钱包更易用（HWI）、让钱包之间针对多重签名和合约用例的通信更通用（输出脚本描述符、PSBT、miniscript），在加强共识安全（共识清理软分叉）、简化测试（signet）、消除不必要的托管（Loop）、让启动节点更容易（assumeutxo）、改善隐私并节省区块空间（taproot）、简化 LN 的执行（anyprevout）、更好地应对费率飙升（CTV）、减少节点带宽（erlay）、在离线时保障 LN 用户安全（瞭望塔）、减少对信任的依赖（可重复构建）、防止盗币（保险库）、让隐私更易获得（SNICKER）、更好地管理 LN 用户的链上手续费（锚定输出），以及让 LN 支付更常自动成功（多路径支付）。

（而这还只是这一年的亮点！）

我们只能猜测比特币贡献者明年会做出什么，但我们猜多半还是同类事情——几十项温和的改动，每一项都让系统更好，同时不破坏任何已经满意的用户。

*Optech Newsletter 将于 1 月 8 日恢复正常的周三发布节奏。*

{% include references.md %}
{% include linkers/issues.md issues="16800,16411,17268,17292" %}
[#14897]: /zh/newsletters/2019/02/12/#bitcoin-core-14897
[2018 summary]: /zh/newsletters/2018/12/28/
[altruist watchtowers]: /zh/newsletters/2019/06/19/#lnd-3133
[anchor miniscript]: https://github.com/lightningnetwork/lightning-rfc/pull/688#pullrequestreview-326862133
[anchor outputs]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[bech32 analysis]: /zh/newsletters/2019/12/18/#analysis-of-bech32-error-detection
[bech32 malleability issue]: https://github.com/sipa/bech32/issues/51
[bech32 sending support]: /zh/bech32-sending-support/
[bitcoin core 0.18]: /zh/newsletters/2019/05/07/#bitcoin-core-0-18-0-released
[bitcoin core 0.19]: /zh/newsletters/2019/11/27/#bitcoin-core-0-19-released
[brd]: /zh/newsletters/2019/08/07/#bech32-发送支持
[breaking bitcoin]: /zh/newsletters/2019/06/19/#breaking-bitcoin
[btcpayserver.vault]: https://github.com/btcpayserver/BTCPayServer.Vault
[btse]: /zh/btse-exchange-operation/
[carve-out proposed]: /zh/newsletters/2018/12/04/#cpfp-carve-out
[ceo bitpay]: /zh/newsletters/2018/10/30/#bitcoin-core-14451
[c-lightning 0.7]: /zh/newsletters/2019/03/05/#upgrade-to-c-lightning-0-7
[c-lightning 0.8]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.0
[cl repro]: https://github.com/ElementsProject/lightning/blob/master/doc/REPRODUCIBLE.md
[cl signet]: /zh/newsletters/2019/07/24/#c-lightning-2816
[coredevtech amsterdam]: /zh/newsletters/2019/06/12/#bitcoin-core-contributor-meetings
[coshv]: /zh/newsletters/2019/05/29/#提议的交易输出承诺
[cryptoeconomic systems summit]: /zh/newsletters/2019/10/16/#conference-summary-cryptoeconomic-systems-summit
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[dual-funding serialization]: https://twitter.com/rusty_twit/status/1179976386619928576
[dumptxoutset]: /zh/newsletters/2019/11/13/#bitcoin-core-16899
[eclair 0.3]: https://github.com/ACINQ/eclair/releases/tag/v0.3
[eclipse attacks]: https://eprint.iacr.org/2015/263.pdf
[edge dev++]: /zh/newsletters/2019/09/18/#bitcoin-edge-dev
[eltoo watchtowers]: /zh/newsletters/2019/12/11/#watchtowers-for-eltoo-payment-channels
[exp tramp]: /zh/newsletters/2019/11/20/#eclair-1209
[gitian]: https://github.com/devrandom/gitian-builder
[guix merge]: /zh/newsletters/2019/07/17/#bitcoin-core-15277
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[jupyter notebooks]: https://github.com/bitcoinops/taproot-workshop#readme
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation
[lightning loop]: /zh/newsletters/2019/03/26/#loop-announced
[ln1.1]: /zh/newsletters/2018/11/20/#特性新闻闪电网络协议-11-目标
[lnd 0.6-beta]: /zh/newsletters/2019/04/23/#lnd-0-6-beta-released
[lnd 0.7-beta]: /zh/newsletters/2019/07/03/#lnd-0-7-0-beta-released
[lnd 0.8-beta]: /zh/newsletters/2019/10/16/#upgrade-lnd-to-version-0-8-0-beta
[lnd repro]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[lnd scb]: /zh/newsletters/2019/04/09/#lnd-2313
[ln missed validation]: /zh/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[loop-in]: /zh/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[mcf]: /zh/newsletters/2019/05/21/#talks-of-technical-interest-at-magical-crypto-friends-conference
[mit bitcoin expo]: /zh/newsletters/2019/03/19/#mit-bitcoin-club-2019-expo-videos-available
[mpp implementation]: /zh/newsletters/2019/12/18/#ln-implementations-add-multipath-payment-support
[news33 reserves]: /zh/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[news37 cleanup discussion]: /zh/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[news37 merkle tree attacks]: /zh/newsletters/2019/03/05/#merkle-树攻击
[news61 miniscript feedback]: /zh/newsletters/2019/08/28/#miniscript-request-for-comments
[news67 bolts676]: /zh/newsletters/2019/10/09/#bolts-676
[newsletters]: /zh/newsletters/
[non-strict der]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[optech executive briefing]: /zh/2019-exec-briefing/
[proof of reserves tool]: /zh/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[rm openssl]: /zh/newsletters/2019/11/27/#bitcoin-core-17265
[roose reserves]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016633.html
[scalability workbook]: https://github.com/bitcoinops/scaling-book
[scaling bitcoin]: /zh/newsletters/2019/09/18/#scaling-bitcoin
[schnorr/taproot workshops]: /zh/schnorr-taproot-workshop/
[snicker]: /zh/newsletters/2019/09/04/#snicker-proposed
[stanford blockchain conference]: /zh/newsletters/2019/02/05/#斯坦福区块链会议上的值得注意的演讲
[sybil attacks]: https://en.wikipedia.org/wiki/Sybil_attack
[taproot review]: /zh/newsletters/2019/10/23/#taproot-review
[time warp attack]: /zh/newsletters/2019/03/05/#时间扭曲攻击
[topics index]: /en/topics/
[trampoline proposed]: /zh/newsletters/2019/04/02/#trampoline-payments-for-ln
[trampolines pr]: /zh/newsletters/2019/08/07/#trampoline-payments
[trusting trust]: https://www.archive.ece.cmu.edu/~ganger/712.fall02/papers/p761-thompson.pdf
[twitter]: https://twitter.com/bitcoinoptech/
[two extra outbound connections]: /zh/newsletters/2019/09/11/#bitcoin-core-15759
[txprobe]: /zh/newsletters/2019/09/18/#txprobe-discovering-bitcoin-s-network-topology-using-orphan-transactions
[vaults on bitcoin without using covenants]: /zh/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[wasabi hwi]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v1.1.4
[watchtower spec]: /zh/newsletters/2019/12/04/#proposed-watchtower-bolt
[weekly newsletter]: /zh/newsletters/
[weekly newsletters]: /zh/newsletters/
[worst case cpu usage]: /zh/newsletters/2019/03/05/#传统交易验证
[wuille sbc miniscript]: /zh/newsletters/2019/02/05/#miniscript
[xlation es]: /es/publications/
[xlation ja]: /ja/publications/
[eltoo]: https://blockstream.com/eltoo.pdf
[hwi]: https://github.com/bitcoin-core/HWI
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
