---
title: 'Bitcoin Optech Newsletter #78: 2019 Year-in-Review Special'
permalink: /zh/newsletters/2019/12/28/
name: 2019-12-28-newsletter-zh
slug: 2019-12-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh

excerpt: >
  本期特刊总结了 2019 年比特币的值得注意的发展。
---
{{page.excerpt}} 这是我们 [2018 年总结][2018 summary]的续集。

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

本总结主要基于我们过去一年发布的[每周通讯][weekly newsletters]，我们审查了近 9,000 个提交（近 2,000 个合并）、超过 1,500 个邮件列表帖子、数千行 IRC 日志，以及其他众多公开来源。最初，我们用了 50 期通讯和超过 200 页的内容来总结这些出色的工作。即便如此，我们依然遗漏了许多重要贡献，特别是那些修复错误、编写测试、进行审核和提供支持的人们的贡献——这些工作至关重要，但未必“值得报道”。在进一步总结并试图将整整一年的内容压缩成几页文章时，我们现在也省略了许多其他重要贡献。

因此，在继续之前，我们想向 2019 年对比特币做出贡献的每一个人表示衷心的感谢。即使以下总结没有提到您或您的项目，请您知道我们在 Optech ——可能所有比特币用户——对您为比特币所做的贡献感激不已，难以用言语表达。

## 目录

* 一月
    * [BIP127 证明储备](#bip127)
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
    * [无需契约的保险库](#vaults)
* 九月
    * <a href="#snicker">SNICKER</a>
    * [LN 漏洞](#ln-cve)
* 十月
    * [LN 锚定输出](#anchor-outputs)
* 十一月
    * <a href="#bech32-mutability">Bech32 可变性</a>
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
在一月，Steven Roose [提议][roose reserves]一种标准化格式，用于比特币保管人生成 *证明储备* 的伪交易，以证明他们控制了一定数量的比特币。这类工具无法保证存款人能从保管人处提取其硬币，但可以使保管人更难隐瞒硬币的丢失或被盗。Roose 随后基于部分签名比特币交易（[PSBTs][topic psbt]）开发了一种用于创建储备证明的[工具][news33 reserves]，并最终将该规范发布为 [BIP127][]。

## 二月

{:#core-hwi}
在二月，Bitcoin Core 的主开发分支合并了与[硬件钱包接口（HWI）][topic hwi] Python 库和命令行工具相关的最后一组拉取请求。HWI随后在三月发布了其第一个稳定版本，Wasabi 钱包在[四月][wasabi hwi]中添加了对其的支持，BTCPay 也在十一月通过一个[附加包][btcpayserver.vault]添加了支持<!--
https://github.com/btcpayserver/btcpayserver/pull/1152 -->。HWI使硬件钱包和软件钱包能够通过[输出脚本描述符][topic descriptors]和部分签名比特币交易（[PSBTs][topic psbt]）的组合进行交互。2019年对标准化格式和 API 的不断支持使用户可以更轻松地选择适合其需求的硬件和软件解决方案，而不必局限于某一种解决方案。

<div markdown="1" id="miniscript">

同样在二月，Pieter Wuille 在[斯坦福区块链会议][Stanford Blockchain Conference]上做了关于 [miniscript][topic miniscript] 的[演讲][wuille sbc miniscript]，这是他在输出脚本描述符工作中的衍生项目。Miniscript 提供了比特币脚本的结构化表示，简化了软件的自动化分析。分析可以确定钱包需要提供的数据以满足脚本（例如签名或哈希预图像）、脚本将使用的交易数据量及满足该脚本的数据，以及脚本是否通过已知的共识规则和流行的交易中继政策。

除了miniscript，Wuille、Andrew Poelstra 和 Sanket Kanjalkar 还提供了一种可组合的策略语言，能够编译成 miniscript（后者本身又会转化为比特币脚本）。通过这种策略语言，用户可以轻松描述他们希望在花费其比特币时满足的条件。当多个用户希望共享对某个比特币的控制时，策略语言的可组合性使得将每个用户的签名策略组合成一个单一脚本变得容易。

如果被广泛采用，miniscript 可以简化不同比特币系统之间的交易签名，显著减少为集成钱包前端、LN 节点、Coinjoin 系统、多签钱包、消费者硬件钱包、工业硬件签名模块（HSM）以及其他软件和硬件而需要编写的自定义代码量。

Wuille 和他的合作者在全年继续研究 miniscript，随后[请求社区反馈][news61 miniscript feedback]并[提交了一个拉取请求][Bitcoin Core #16800]，以便向 Bitcoin Core 添加支持。Miniscript还将在 12 月被 LN 开发者用来[分析和优化][anchor miniscript]他们一些链上交易的新脚本的升级版本。

</div>

## 三月

<div markdown="1" id="cleanup">

在三月，Matt Corallo 提出了[共识清理软分叉][topic consensus cleanup]的建议，以消除比特币共识代码中的潜在问题。如果被采纳，这些修复将消除[时间扭曲攻击][time warp attack]，降低传统脚本的[最坏情况下的 CPU 使用率][worst case CPU usage]，使交易验证状态缓存更可靠，并消除已知（但昂贵的）[对轻量客户端的攻击][news37 merkle tree attacks]。

尽管该提案的某些部分（例如时间扭曲修复）似乎吸引了各种人的兴趣，但提案的其他部分（例如对最坏情况下 CPU 使用率和有效性缓存的修复）则受到了一些[批评][news37 cleanup discussion]。或许正因为如此，该提案在下半年没有明显的实施进展。

</div>

<div markdown="1" id="signet">

三月，Kalle Alm 也请求对 [signet][topic signet] 的初步反馈，该协议最终将成为 [BIP325][]。signet 协议允许创建所有有效新块都必须由集中方签名的测试网。尽管这种集中化与比特币的理念背道而驰，但对于测试网来说，它是理想的，因为测试者有时希望创建一个破坏性的场景（例如链重组），而其他时候只想要一个稳定的平台来测试软件互操作性。在比特币现有的测试网上，重组和其他干扰可能频繁发生并持续较长时间，使得常规测试变得不切实际。

signet将在全年成熟，并最终被[集成][cl signet]到C-Lightning等软件中，并用于 [eltoo][] 的演示。一项[拉取请求][Bitcoin Core #16411]仍在开放中，以便向 Bitcoin Core 添加支持。

</div>

{:#loop}
此外，在三月，Lightning Labs 宣布推出 [Lightning Loop][]，为希望从 LN 通道中提取部分资金到链上 UTXO 而不关闭通道的用户提供非托管解决方案。在六月，他们将[升级][loop-in] Loop，以允许用户将 UTXO 花费到现有通道中。Loop 使用与常规的链下 LN 交易类似的哈希时间锁定合约（HTLC），确保用户的资金要么按预期转移，要么用户收到退款，退款中扣除的只有链上交易费用。这使得 Loop 几乎完全无需信任。

<div markdown="1" class="callout" id="releases">

### 2019 总结<br>流行基础设施项目的主要发布

- [C-Lightning 0.7][] 于三月发布，增加了插件系统，年底将得到广泛应用。这也是第一个支持[可重复构建][topic reproducible builds]的 C-Lightning 版本，通过改善审计能力提高安全性。

- [LND 0.6-beta][] 于四月发布，支持[静态通道备份（SCBs）][lnd scb]，帮助用户恢复在LN通道中结算的任何资金，即使他们丢失了最近的通道状态。该版本还提供了改进的自动驾驶功能，以帮助用户开启新通道，并内置与 [Lightning Loop][] 的兼容性，以便在不关闭通道或使用托管的情况下在链上转移资金。

- [Bitcoin Core 0.18][] 于五月发布，改善了部分签名比特币交易（[PSBT][topic psbt]）的支持，并增加了对[输出脚本描述符][topic descriptors]的支持。这两项功能的结合使其能够与硬件钱包接口（[HWI][]）的第一个发布版本一起使用。

- [Eclair 0.3][] 于五月发布，提高了备份安全性，增加了对插件的支持，并能够作为Tor隐藏服务运行。

- [LND 0.7-beta][] 于七月发布，增加了支持[瞭望塔][topic watchtowers]来保护您在离线时的通道。

- [LND 0.8-beta][] 于十月发布，增加了对更可扩展的洋葱格式的支持，提高了备份安全性，并改善了看守塔的支持。

- [Bitcoin Core 0.19][] 于十一月发布，实现了新的 [CPFP 分离][topic cpfp carve out]内存池策略，增加了对[BIP158][]样式的[致密区块过滤器][topic compact block filters]（目前仅支持RPC）的初步支持，通过默认禁用[BIP37][]布隆过滤器和[BIP70][]支付请求来提高安全性。它还默认将 GUI 用户切换到 bech32 地址。

- [C-Lightning 0.8][] 于十二月发布，增加了对[多路径支付][topic multipath payments]的支持，并将默认网络从测试网切换到主网。这也是第一个支持替代数据库的主要 C-Lightning 版本，postgresql 支持可用，除了默认的 sqlite 支持。

</div>

## 四月

{:#assumeutxo}
在四月，James O’Beirne 提出了 [AssumeUTXO][topic assumeutxo]，一种允许全节点推迟验证旧区块链历史的方法，方法是下载并暂时使用最近的 UTXO 集的可信副本。这将允许使用全节点的钱包和其他软件在节点启动后的几分钟内开始接收和发送交易，而不必像现在新启动节点那样等待数小时或数天。AssumeUTXO 建议节点在后台下载并验证旧的区块链历史，直到最终验证其初始 UTXO 状态，从而使其最终获得与不使用 AssumeUTXO 的节点相同的无需信任的安全性。O'Beirne 在全年继续推进该项目，逐步添加[新功能][dumptxoutset]并重构现有代码，以最终将 AssumeUTXO 添加到 Bitcoin Core 中。

<div markdown="1" id="trampoline">

同样在四月，Pierre-Marie Padiou [提出][trampoline proposed]了[蹦床支付][topic trampoline payments]的想法，这是一种允许轻量级 LN 节点将路径查找功能外包给重量级路由节点的方法。轻量级节点（例如移动应用程序）可能不会跟踪完整的 LN 路由图，因此无法找到到其他节点的路径。Padiou 的提议允许轻量级节点将支付路由到附近的节点，然后由该节点计算剩余的路径。本质上，支付会在前往目的地的途中弹跳到蹦床节点。为了增加隐私，原始支付者可能会要求支付依次经过多个蹦床节点，以确保其中任何一个节点都无法知道它是否在将支付路由到最终接收者，或者只是路由到下一个蹦床节点。

一个添加蹦床支付功能到 LN 规范的[拉取请求][trampolines pr]目前已经开放，并且 Eclair 的 LN 实现已经添加了[实验性支持][exp tramp]，以便转发蹦床支付。

</div>

## 五月

<div markdown="1" id="taproot">

在五月，Pieter Wuille 提出了一个 [Taproot 软分叉][topic taproot]，包括 [bip-taproot][] 和 [bip-tapscript][]（这两个提案都依赖于去年的 [bip-schnorr][] 提案）。如果实施，此更改将允许单签名、多签名以及许多合约使用相同风格的scriptPubKeys。许多来自多签名和复杂合约的支出将看起来与单签名支出相同。这可以显著改善用户隐私和币的可替代性，同时减少多签名和合约用例所占用的区块链空间。

即使在多签名和合约支出无法完全利用 Taproot 的隐私和空间节省的情况下，它们仍然可能只需要将一部分代码放在链上，从而比当前情况获得更多的隐私和空间节省。除了 Taproot，[tapscript][topic tapscript] 对比特币的脚本能力进行了一些小的改进，主要是通过更容易和更清晰地添加新的操作码。

这些提案在全年得到了广泛讨论和审查，包括由 Anthony Towns 组织的一系列[小组审查会议][taproot review]，共有超过 150 人报名参与审查。

</div>

<div markdown="1" id="anyprevout">

Towns 还在五月提出了两个新的签名哈希，将与 tapscript 结合使用，分别是 `SIGHASH_ANYPREVOUT` 和 `SIGHASH_ANYPREVOUTANYSCRIPT`。签名哈希（sighash）是指对交易字段及相关数据的哈希，签名通过它进行承诺。比特币中的不同sighashes承诺交易的不同部分，允许签名者选择让其他人对其交易进行某些修改。这两个新提议的 sighashes 类似于 [BIP118][] 的 [SIGHASH_NOINPUT][topic sighash_anyprevout]，故意不识别它们所花费的UTXO，从而允许签名花费任何它能够满足其脚本的 UTXO（例如，使用相同的公钥）。

无输入风格的 sighashes 的主要建议用途是启用之前提议的 [eltoo][topic eltoo] LN 更新层。Eltoo 可以简化通道构建和管理的多个方面；特别是在涉及多个参与者的通道中，这种简化是非常期望的，能够显著降低链上通道成本。

</div>

<div markdown="1" id="ctv">

本月提出的第三个软分叉来自 Jeremy Rubin，他[描述][coshv]了一种现在称为 `OP_CHECKTEMPLATEVERIFY`（CTV）的新操作码。这将允许一种有限形式的[契约][topic covenants]，其中一个交易的输出要求后续支出该输出的交易包含某些其他输出。一个建议用途是承诺未来的支付，其中支出者支付一个只能通过一笔交易（或一系列交易）支出的单个小输出，随后支付给数十、数百或甚至数千个不同的接收者。这可以启用新的技术，以增强类似 Coinjoin 的隐私，支持增强安全性的保险库，或者在交易费用飙升时管理支出者的成本。

Rubin 将在接下来的一年中继续致力于 CTV，包括为 Bitcoin Core 中的一些部分优化开设拉取请求（[1][Bitcoin Core #17268]，[2][Bitcoin Core #17292]），使得 CTV 的实际部署版本更有效。

</div>

<div markdown="1" class="callout" id="conferences">

### 2019总结<br>值得注意的技术会议和其他活动

- **<!--stanford-blockchain-conference-->**[斯坦福区块链会议][Stanford Blockchain Conference], 一月，斯坦福大学
- **<!--mit-bitcoin-expo-->**[MIT 比特币博览会][MIT Bitcoin Expo], 三月，麻省理工学院
- **<!--optech-executive-briefing-->**[Optech 高管简报][Optech Executive Briefing], 五月，纽约市
- **<!--magical-crypto-friends-technical-track-->**[魔法加密朋友（技术轨道）][mcf]，五月，纽约市
- **<!--breaking-bitcoin-->**[突破比特币][Breaking Bitcoin], 六月，阿姆斯特丹
- **<!--bitcoin-core-developers-meetup-->**[Bitcoin Core 开发者聚会][coredevtech amsterdam]，六月，阿姆斯特丹
- **<!--edge-dev-->**[Edge Dev++][Edge Dev++], 九月，特拉维夫
- **<!--scaling-bitcoin-->**[比特币扩展][Scaling Bitcoin]，九月，特拉维夫
- **<!--cryptoeconomic-systems-summit-->**[加密经济系统峰会][Cryptoeconomic Systems Summit], 十月，麻省理工学院

</div>

## 六月

<div markdown="1" id="erlay-and-other-p2p-improvements">

Gleb Naumenko、Pieter Wuille、Gregory Maxwell、Sasha Fedorova 和 Ivan Beschastnikh 发表了一篇关于 [erlay][topic erlay] 的[论文][erlay]，这是一种在节点之间中继未确认交易公告的协议，利用 [libminisketch][topic minisketch] 进行集合协调，预计能减少 84% 的公告带宽。论文还表明，erlay 将使节点显著增加默认的外向连接数量变得更为实用。这可以提高每个节点抵御 [eclipse 攻击][eclipse attacks]的能力，这种攻击可能使其接受不在最大工作量区块链上的区块。更多的外向连接也改善了节点抵御其他可能用于追踪或延迟来自该节点支付的攻击。

今年在 P2P 中继方面的其他改进包括 Bitcoin Core 的[交易中继隐私改进][#14897]（消除了 Sergi Delgado-Segura 等人描述的 [TxProbe][] 论文中的问题）以及增加了[两个额外的外向连接][two extra outbound connections]，仅用于新块的中继，提高了抵御 eclipse 攻击的能力。

</div>

<div markdown="1" id="watchtowers">

在进行大量先前工作的基础上，六月还见证了 [LN 瞭望塔][topic watchtowers]的[合并][altruist watchtowers]，将其整合进LND。观察塔不会通过协议获得任何奖励以帮助保护客户的通道，因此用户需要运行自己的观察塔或依赖于观察塔运营者的善意，但这足以证明观察塔能够可靠地代表其他用户发送惩罚交易——确保长时间离线的用户不会失去任何资金。

观察塔最终将在 [LND 0.7.0-beta][lnd 0.7-beta] 中发布，并将在剩下的年份中继续开发，包括[提出的规范][watchtower spec]和关于如何将它们与下一代支付通道（如 [eltoo][topic eltoo]）结合的[讨论][eltoo watchtowers]。

</div>

## 七月

<div markdown="1" id="reproducibility">

在七月，Bitcoin Core 项目合并了 Carl Dong 的拉取请求，增加了对使用 GNU Guix（发音为“geeks”）构建 Bitcoin Core Linux 二进制文件的可重复构建的支持。虽然 Bitcoin Core 长期以来一直支持使用 [Gitian][] 系统的可重复构建，但其设置较为复杂，并依赖于数百个 Ubuntu 软件包的安全性。相比之下，Guix 的安装和运行要容易得多，而且目前使用 Guix 构建的 Bitcoin Core 仅依赖于较少数量的软件包。从长远来看，Guix 的贡献者们也在努力消除 [trusting trust][] 问题，以便用户能够轻松验证 `bitcoind` 等二进制文件是否仅由可审计的源代码生成。

在全年中，Guix 的构建支持工作持续进行，部分贡献者希望 Guix 能在 2020 年发布的第一个主要版本的 Bitcoin Core 中得到使用（或许会与较旧的基于 Gitian 的机制并行）。

此外，今年还为 [C-Lightning][cl repro] 和 [LND][lnd repro] 存储库添加了文档，描述如何使用受信任的编译器创建可重复构建。

</div>

## 八月

<div markdown="1" id="vaults">

在八月，Bryan Bishop 描述了一种[在比特币上实现无需契约使用保险库][vaults on Bitcoin without using covenants] 的方法。*保险库*是一个术语，用于描述一种脚本，限制攻击者在获得用户的正常私钥后窃取资金的能力。*[契约][topic covenants]*是只能支出到特定其他脚本的脚本。目前没有已知的方法可以使用当前的比特币脚本语言创建契约，但如果用户愿意在将资金存入保管合同时运行一些额外步骤的代码，就不需要契约。

更值得注意的是，Bishop 还描述了以往保险库提案中的新弱点，以及一种减轻该弱点的措施，以限制攻击者从保险库中窃取的资金的最大金额。实用保险库的开发可能对个人用户和大型托管组织（如交易所）都很有用。

</div>

<div markdown="1" class="callout" id="optech">

### 2019 总结<br>Bitcoin Optech

在 Optech 的第二年，我们新增了六家会员公司，在 NYC 区块链周期间举办了[高管简报][optech executive briefing]，发布了一系列[为期 24 周的文章][bech32 sending support] ，推广 Bech32 发送支持，向我们的网站添加了钱包和服务的 [兼容性矩阵][compatibility matrix]，发布了 51 期每周[通讯][newsletters]<!-- #28 to #78, inclusive -->，我们的几期新闻通讯和博客文章被翻译成[日语][xlation ja]和[西班牙语][xlation es]，创建了[主题索引][topics index]，为我们的 [可扩展性工作手册][Scalability Workbook] 添加了一章，举办了两次 [Schnorr/Taproot 研讨会][schnorr/taproot workshops]，并发布了来自 [BTSE][] 和 [BRD][] 的实地报告。

我们对 2020 年有大计划，因此希望您能继续关注我们的[推特][Twitter], 订阅我们的[每周通讯][weekly newsletter], 或跟踪我们的 [RSS 源][RSS feed]。

</div>

## 九月

<div markdown="1" id="snicker">

Adam Gibson [提出][snicker]了一个新颖的非交互式 [coinjoin][topic coinjoin] 方法，称为 SNICKER。该协议涉及用户选择其 UTXO 和全球 UTXO 集中随机选择的 UTXO 以在同一交易中进行支出。提议的用户签署该交易的一部分，并将其以部分签名比特币交易（[PSBT][topic psbt]）格式上传到公共服务器。如果其他用户检查服务器并看到 PSBT，他们可以下载、签署并广播，从而完成 coinjoin，而无需两个用户同时在线。提议的用户可以使用相同的 UTXO 创建并上传任意数量的 PSBT，直到其他用户接受 coinjoin。

SNICKER 相比其他 coinjoin 方法的主要优势在于，它不要求用户同时在线，并且应当很容易将其支持添加到已经具有 [BIP174][] PSBT 支持的任何钱包中，而这些钱包的数量正在增加。

</div>

{:#ln-cve}
同样在九月，C-Lightning、Eclair 和 LND 的维护者们[披露][ln missed validation]了一个影响其先前版本的软件的漏洞。似乎在某些情况下，各实现未能确认通道融资交易支付了正确的脚本或正确的金额（或两者都未确认）。如果利用该漏洞，可能导致通道支付无法在链上确认，从而使节点在从无效通道中转发支付到有效通道时损失资金。Optech 未知晓在漏洞首次公开披露之前有用户因此损失资金。闪电网络规范已被[更新][news67 bolts676]，以帮助未来的实现者避免此问题，并期待对闪电网络通信协议的[其他提议更改][dual-funding serialization]有助于避免其他类型的故障。

## 十月

<div markdown="1" id="anchor-outputs">

闪电网络（LN）开发者在十月和十一月取得了重要进展，旨在解决用户总能在不受过度延迟的情况下关闭通道的长期担忧。如果用户决定关闭某个通道但无法联系到远程对等方，他们会广播该通道的最新 *承诺交易*——一笔预签名的交易，将通道资金按最新版本的离线合约在链上分配给每个参与方。这种安排的潜在问题在于，承诺交易可能是在几天或几周前创建的，当时交易费用较低，因此可能无法支付足够的费用以快速确认，导致任何安全必需的时间锁到期。

一直以来，解决此问题的方案是使承诺交易能够提高费用。不幸的是，像 Bitcoin Core 这样的节点必须限制费用提升的使用，以防止浪费带宽和 CPU 的拒绝服务（DoS）攻击。在像闪电网络这样的无需信任的多用户协议中，您的对手可能是攻击者，他们可能故意触发反 DoS 策略，以延迟确认您的闪电网络承诺交易，这种攻击有时被称为[交易固定][topic transaction pinning]。被固定的交易可能无法在其时间锁到期之前确认，从而允许攻击对手盗取您的资金。

去年，Matt Corallo [建议][carve-out proposed]在 Bitcoin Core 的交易中继策略中划出与 CPFP 费用提升相关的特殊豁免。这项有限的豁免确保了双方合同协议（例如当前一代闪电网络）能够保证每个参与方都有能力创建自己的费用提升。Corallo 的想法被称为 [CPFP 分离][topic cpfp carve out]，并且他的实现作为 Bitcoin Core 0.19 的一部分发布。早在该版本发布之前，其他闪电网络开发者已经在对闪电网络脚本和协议消息进行必要的[修订][anchor outputs]，以开始使用这一变化。截至本文撰写时，这些规范更改正在等待最终实施和接受，然后才能在网络上部署。

</div>

<div markdown="1" class="callout" id="new-infrastructure">

### 2019 年总结<br>新开源基础设施解决方案

- **<!--proof-of-reserves-tool-->**[储备证明工具][Proof of reserves tool] 于二月发布，允许交易所和其他比特币保管人使用 [BIP127][] 储备证明证明他们对特定 UTXO 集的控制。

- **<!--hardware-wallet-interface-->**[硬件钱包接口][topic hwi] 于三月发布，使得与部分签名比特币交易（[PSBTs][topic psbt]）和[输出脚本描述符][topic descriptors]兼容的钱包可以使用多种不同型号的硬件钱包进行安全密钥存储和签名。

- <a href="/zh/newsletters/2019/03/26/#loop-announced">闪电环</a> 于三月发布（并于六月添加了环入支持），提供了一种无需托管的服务，允许用户在不关闭现有通道或开启新通道的情况下添加或移除其闪电网络通道中的资金。

</div>

## 十一月

<div markdown="1" id="bech32-mutability">

关于使用 bech32 地址进行 [taproot][topic taproot] 支付的讨论使人们进一步关注到在五月发现的一个[问题][bech32 malleability issue]。根据 [BIP173][]，错误复制的 bech32 字符串的最坏情况失败率约为十亿分之一。然而，发现以 `p` 结尾的 bech32 字符串可以添加或删除任意数量的前导 `q` 字符。这在实际操作中并不会影响 segwit P2WPKH 或 P2WSH 地址的 bech32 地址，因为至少需要添加或删除 19 个连续的 `q` 字符才能将一种地址类型转换为另一种——并且对于 v0 segwit 地址的任何其他长度变化都是无效的。 <!-- "19 characters" math in _posts/zh/newsletters/2019-11-13-newsletter.md -->

但对于 v1+ segwit 地址（例如那些提议用于 taproot 的地址），在一个脆弱地址中添加或删除一个 `q` 字符可能会导致资金损失。BIP173 的共同作者 Pieter Wuille 进行了[额外分析][bech32 analysis]，发现这是 bech32 预期错误更正能力的唯一偏差，因此他建议将比特币中 BIP173 地址的使用限制为仅 20 字节或 32 字节的见证程序。这将确保 v1 和后续的 segwit 地址版本提供与 v0 segwit 地址相同的可靠错误更正。他还描述了对 bech32 算法的小调整，这将允许其他使用 bech32 的应用程序，以及下一代比特币地址格式，使用 BCH 错误检测而不出现此问题。

</div>

{:#openssl}
同样在十一月，Bitcoin Core [移除了对 OpenSSL 的依赖][rm openssl]，该依赖自 2009 年 Bitcoin 0.1 版本发布以来一直存在。OpenSSL 是[共识漏洞][non-strict der]、[远程内存泄漏][heartbleed]（潜在的私钥泄漏）、[其他错误][cve-2014-3570]和[性能不佳][libsecp256k1 sig speedup]的根源。希望它的移除能减少未来漏洞的频率。

{:#bip70}
作为 OpenSSL 移除的一部分，Bitcoin Core 在版本 0.18 中弃用了对 [BIP70][] 支付协议的支持，并在版本 0.19 中默认禁用了该支持。这一决定得到了在 2019 年继续使用 BIP70 的少数几家公司之一的 CEO 的[支持][ceo bitpay]。

## 十二月

{:#multipath}
在十二月，闪电网络开发者实现了去年[计划会议][ln1.1]的主要目标之一：基本[多路径支付][topic multipath payments]的[实现][mpp implementation]。这些支付可以分成几个部分，每部分通过不同通道单独路由。这使得用户能够在一次支付中同时使用多个通道进行支出或接收资金，从而在某些安全限制内花费他们的全部离线余额或一次性接收其全部容量。 <!-- safety restrictions: non-wumbo and channel reserve funding -->预计这将通过消除支出者担心特定通道余额的需要，使闪电网络变得更加用户友好。

## 结论

在上述总结中，我们没有看到革命性的提案或改进。相反，我们看到了一系列渐进的改进——这些解决方案利用比特币和闪电网络已经成功的案例，并在此基础上进一步优化系统。我们看到开发者努力使硬件钱包更易于使用（HWI），使钱包间的多重签名和合约用例的通信更加通用（描述符、PSBT、miniscript），增强共识安全（清理软分叉），简化测试（signet），消除不必要的托管（环），使运行节点更容易（assumeutxo），改善隐私和节省区块空间（taproot），简化闪电网络执行（anyprevout），更好地管理费用率波动（CTV），减少节点带宽（erlay），确保闪电网络用户在离线时安全（瞭望塔），减少对信任的需求（可重复构建），防止盗窃（金库），使隐私更易获得（SNICKER），更好地管理闪电网络用户的链上费用（锚定输出），并使闪电网络支付更频繁地自动生效（多路径支付）。

（而这些仅仅是年度亮点而已！）

我们只能猜测比特币贡献者在明年会取得什么成就，但我们怀疑会有更多类似的变化——数十项温和的变更，每一项都能在不破坏任何已满足用户的情况下改善系统。

*Optech 新闻通讯将于 1 月 8 日恢复正常的周三发布安排。*

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
[non-strict der]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[optech executive briefing]: /zh/2019-exec-briefing/
[proof of reserves tool]: /zh/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[rm openssl]: /zh/newsletters/2019/11/27/#bitcoin-core-17265
[roose reserves]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016633.html
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
