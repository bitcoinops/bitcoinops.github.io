---
title: 'Bitcoin Optech Newsletter #201'
permalink: /zh/newsletters/2022/05/25/
name: 2022-05-25-newsletter
slug: 2022-05-25-newsletter
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了一个为交易包转发设计的 BIP 草案，并概述了人们对比特币限制条款（covenant）设计可能引发 “矿工可抽取价值（Miner Extractable Value，MEV）” 的担忧。此外，还有我们的常规栏目：对来自 Bitcoin Stack Exchange 网站的高票问答的总结、软件的新版本和候选版本信息，以及热门比特币基础设施软件的重大变更介绍。

## 新闻

- **交易包转发提案**：Gloria Zhao 在 Bitcoin-Dev 邮件组中[发帖][zhao package]列举了一个为[交易包转发][topic package relay]设计的 BIP 草案。交易包转发的特性可以让 “[CPFP 手续费追加方法][topic cpfp]” 变得更加可靠（CPFP 的用意是让子交易为父交易贡献手续费，从而加快父交易被确认的速度）。许多合约协议，包括闪电网络，已经开始需要可靠的 CPFP 手续费追加方案，所以交易包转发将提升它们的安全性和易用性。这个 BIP 草案提议在比特币的 P2P 协议中加入四种新的消息：

  - `sendpackages`，允许两个对等节点沟通他们所支持的交易包接收特性。
  -  ` getpckgtxns ` ，请求将之前转发的交易标记为某交易包的一部分
  -  ` pckgtxns ` ，提供作为某交易包一部分的交易
  -  ` pckginfo1 ` ，提供关于一个交易包的信息，包括交易的数量、每个交易的标识符（wtxid）、所有交易的总体积（weight），以及所有交易的手续费总和。整个交易包的手续费率就是手续费总和除以总体积。

  此外，现有的  ` inv ` 和 ` getdata ` 将更新到可以使用一种新的详单（inv）类型  ` MSG_PCKG1 ` ，该类型将允许一个节点告知其对等节点，自己希望发送关于一笔交易的一条  ` pckgingo1 ` 消息，而这些对等节点之后就可以用这种类型来请求某一笔交易的  ` pckginfo1 ` 信息。

  虽然这个 [BIP 草案][bip-package-relay] 草案仅关注协议层，Zhao 的邮件也提供了额外的上下文、简要描述了已被发现有缺陷的其它设计，并链接了一份带有额外细节的[演示幻灯片][zhao preso]。

- **关于 MEV 的讨论**：开发者 dev/fd0 邮件组中[发帖][fd0 ctv9]举出了一份关于 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）的[第 9 次 IRC 会议][ctv9]的总结。在会议围绕其它话题的讨论中，Jeremy Rubin 列举了他听到关于递归型[限制条款][topic covenants]的许多担忧（CTV 不属于此类）。其中一种担忧是它会产生 “矿工可抽取价值（MEV）” ，并且其中的 MEV 会远远超过运行简单的交易选择算法（比如  Bitcoin Core 所提供的）可以获得的限度。

  MEV 问题是在以太坊（Ethereum）和相似的协议上显露出来的，在这些平台上，使用公开的链上交易协议将使矿工可以抢跑交易（frontrun trades）。举个例子，假设下面两笔交易都在等待进入下一个区块：

  - Alice 卖出资产 *x* 给 Bob，价格为 1 ETH
  - Bob 卖出 *x* 给 Carol，价格为 2 ETH（Bob 可从中赚取 1 ETH）

  如果这两笔交易是用公开的链上交易协议执行的，知晓了这两笔交易的某矿工可以把 Bob 踢出局。例如：

  - Alice 卖出资产 *x* 给矿工 Mallory，价格为 1 ETH
  - Mallory 卖出 *x* 给 Carol，价格为 2 ETH（Mallory 可从中赚取 1 ETH；Bob 则颗粒无收）

  显然，Bob 在其中利益受损了，但它还为整个网络带来了许多问题。第一个问题是矿工需要发现 MEV 的机会。在上面这样简单的例子中，发现 MEV 并不是什么难事，但只有通过计算密集型的算法才能发现更复杂的机会。确定的计算数量所能发现的 MEV 价值，与单个矿工的挖矿算力大小无关，所以两个矿工可以联合起来，将捕获 MEV 所需花费的计算量（和成本）减半 —— 这就产生了规模经济，并促使挖矿集中化、让网络对交易审查更脆弱。BitMex Research 的一份[报告][bitmex flashbots]声称，在该报告撰写之时，一项代理此类 MEV 交易的中心化服务已经被 90% 的以太坊算力使用。为了获得最大的汇报，这项服务可以被改造成阻止矿工竞争打包交易，也就是说，如果它被所有的矿工所用，它就有权力审查交易（又或者，如果它被超过 50% 的矿工所用，它就可以参与区块链重组）。

  第二个问题是，即使 Mallory 可以生产一个区块来捕获这价值 1 ETH 的 MEV，其他矿工也可以生产相竞争的区块来尝试捕捉它。这种重新挖掘区块的压力会加剧 “[交易费钉死（fee sniping）][topic fee sniping]” 的威力，在最坏的情况下，可以让确认的次数对评估交易的终局性失去意义，最终毁灭使用工作量证明来保护网络的能力。

  比特币使用 UTXO 而不是以太坊那样的账户，所以在比特币上更难实现那些会产生 MEV 问题的协议。但是，在 CTV 会议上，Jeremy Rubin 指出，递归型限制条款涨和在比特币 UXTO 实现基于账户的系统变得更容易，所以会提高 MEV 在未来成为比特币协议设计上的重大考量的风险。

  在回复 /dev/fd0 的帖子时，开发者 ZmnSCPxj 建议，我们只应该采用鼓励协议为最大化链上隐私性而设计的机制。隐私性将阻止矿工获得为执行 MEV 而必需的信息。截至本周报撰写之时，邮件组中尚未有进一步的评论，但在，从推特的引用和其他地方的反响来看，我们发现开发者们开始进一步考虑 MEV 对比特币协议设计的影响。

## Bitcoin Stack Exchange 上的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者查找问题答案的首选之地 —— 也是他们有闲暇时会帮助好奇和困惑的用户的地方。在这个每月一次的栏目中，我们会挑出自上次栏目更新以来新出现的高票问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [如果按照字母顺序来记录助记词，会损失多少熵？]({{bse}}113432)HansBKK 好奇如果按照字母顺序来排列 12 词或者 24 词的种子词（seed phrase），会损失多少熵？Pieter Wuille 提出了一系列的指标，包括可能性的数量、熵、用暴力来猜测 12 词和 24 词的平均猜测次数，还提出了词语重复的因素。
- [使用 PSBT 来签名 Taproot 交易：如何确定签名方法？]({{bse}}113489)Guggero 列出了在 taproot 种提供有效的  [Schnorr 签名][topic schnorr signatures]的三种方法：使用带有 [BIP86][] 承诺的密钥路径；使用带有脚本树根值承诺的密钥路径；脚本花费路径。Andrew Chow 确认了 Guggero 列举的每一种签名方法在 [PSBT][topic psbt] 中是如何指定的。
- [更快的出块速度会导致挖矿的集中化吗？]({{bse}}113505)Murch 集中解释了为什么更短的出块时间会导致更频繁的区块重组，以及这种情形在区块传播有时延的背景会如何有益于更大的矿工。
- [在选择要花哪个币时，“浪费指标（waste metric）” 是什么意思？]({{bse}}113622)Murch 解释道，在花费资金时，Bitcoin Core 软件会使用一个 “[浪费指标][news165 waste]” 启发法，来 “衡量输入集按当前费率来花费，与（同样的输入）按假设的长期费率来花费相比的划算程度”。这个启发法会用来[选币算法][topic coin selection]的候选结果，后者是 Branch and Bound（BnB）、Single Random Draw（SRD）和 knapsack 算法的结果。
- [为什么 ` OP_CHECKMULTISIG ` 不能跟 Schnorr 签名的批量验证相兼容？]({{bse}}113816)Pieter Wuille 指出，因为 [`OP_CHECKMULTISIG`][wiki op_checkmultisig] 不能指定哪个签名与哪个公钥成对，所以它跟批量验证不能兼容，这也[促使][bip342 fn4]人们提出了 BIP342 的新的  ` OP_CHECKSIGADD ` 操作码。

## 软件的新版本和候选版本

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到最新版本或帮助测试候选版本。*

- [Core Lightning 0.11.1][] 是一个修复 bug 的版本，消除了会导致不必要地广播单方通道关闭交易的一个问题，以及另一个会导致 C-Lightning 节点宕机的问题。
- [LND 0.15.0-beta.rc3][] 是为了下一个大版本而发布的候选版本。

## 重大代码及文档变更

本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 以及 [Lightning BOLTs][bolts repo]。

- [Bitcoin Core #20799][] 移除了对一号版本的 “[致密区块中继][topic compact block relay]” 的支持，这个特性允许更快地、带宽效率更高地向不支持隔离见证的对等节点转发区块和交易。二号版本保持启用，并允许向支持隔离见证的对等节点更快、更高效地转发数据。
- [LND #6529][] 加入了一条  ` constrainmacaroon ` 命令，允许限制一个已经创建的 macaroon （身份校验 token）的权限。此前，变更权限需要创建一个新的 macaroon。
- [LND #6524][] 将 LND 的 aezeed 备份方案的版本号从 0 提高到 1。它将指示未来的软件从一个 aezeed 备份中恢复钱包时去扫描该钱包收到的 [taproot][topic taproot] 输出。

## 特别感谢

除了我们日常的周报贡献者，我们要特别感谢 Jeremy Rubin 对本周关于 MEV 的额外内容的贡献。所有的错误和错失，依然完全由我们负责。

{% include references.md %}
{% include linkers/issues.md v=2 issues="20799,6529,6524" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[Core Lightning 0.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.1
[zhao package]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020493.html
[bip-package-relay]: https://github.com/bitcoin/bips/pull/1324
[zhao preso]: https://docs.google.com/presentation/d/1B__KlZO1VzxJGx-0DYChlWawaEmGJ9EGApEzrHqZpQc/edit#slide=id.p
[fd0 ctv9]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[ctv9]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[bitmex flashbots]: https://blog.bitmex.com/flashbots/
[news165 waste]: /en/newsletters/2021/09/08/#bitcoin-core-22009
[wiki op_checkmultisig]: https://en.bitcoin.it/wiki/OP_CHECKMULTISIG
[bip342 fn4]: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki#cite_note-4