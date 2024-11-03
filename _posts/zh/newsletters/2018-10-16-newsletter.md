---
title: "Bitcoin Optech Newsletter #17"
permalink: /zh/newsletters/2018/10/16/
name: 2018-10-16-newsletter-zh
slug: 2018-10-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 简要描述一项用于拼接闪电网络支付通道的提议、链接到在 Edge Dev++ 培训课程中的演讲视频和文本记录并总结上周 CoreDev.tech 活动期间制作的一些文本记录。

## 行动项

本周无。

## 新闻

- **<!--proposal-for-lightning-network-payment-channel-splicing-->****闪电网络支付通道拼接提议：** 拼接是一种允许用户在不关闭并重新打开一个全新通道的延迟下，向现有支付通道添加或移除资金的想法。Rusty Russell 发布了一个[技术提议][complex splice]，允许一次进行单个拼接，尽管他指出该提议复杂。René Pickhardt 描述了一种[更简单的方案][simpler splice]，可能更容易实现和推理，但可能需要更多的链上交易。有人建议，简单但成本更高的解决方案可以是版本 1，更复杂但成本更低的解决方案可以是版本 2。

- **<!--edge-dev-talks-published-->****Edge Dev++ 演讲发布：** 为期两天的一系列来自领先比特币贡献者的演讲面向开发者已经以[视频][dev vids]和[文本记录][dev transcripts]的形式发布。演讲涵盖了从入门到高级的全部主题。三场演讲可能对 Optech 成员特别有趣：

    1. *交易所安全*，作者：Warren Togami。描述了几起比特币和山寨币交易所重大盗窃背后的原因，并列出了一些企业可用来降低损失风险的技术。([视频][warren vid], [文本记录][warren transcript])

    2. *钱包安全、密钥管理和硬件安全模块（HSMs）*，作者：Bryan Bishop。建议了减少私钥被盗或误用风险的方法。([视频][kanzure wallet vid], [文本记录][kanzure wallet transcript])

    3. *处理重组和分叉*，作者：Bryan Bishop。描述了如何保护你的交易不受比特币区块链或共识规则变化的影响，包括如何测试系统的建议。([视频][kanzure reorg vid], [文本记录][kanzure reorg transcript])

## CoreDev.tech

CoreDev.tech 是一个仅限邀请的活动，面向比特币基础设施项目（如 Bitcoin Core 和闪电网络）的知名贡献者。讨论没有被记录，但 Bryan Bishop 有帮助地写下了一些活动期间讨论的粗略非官方文本记录。以下简短摘要基于上周在东京举行的活动的一些文本记录：

- **<!--bitcoin-optech-optech-transcript-->****[Bitcoin Optech][optech transcript]：** 介绍了 Bitcoin Optech 并进行了简短的讨论，随后讨论了使用比特币的企业在使用 Bitcoin Core 和其他开源基础设施项目时遇到的常见问题。

- **<!--using-utxo-accumulators-to-reduce-data-storage-requirements-utreexo-->****[使用 UTXO 累加器减少数据存储需求][utreexo]：** Tadge Dryja 描述了他一直在研究的 UTXO 累加器，这些累加器在功能上与上周通讯中描述的累加器类似，但具有基于哈希的不同构造。他进一步描述了它们如何与 Cory Field 的 [UTXO 哈希集（UHO）][UHO] 想法结合，以使完整节点存储 UTXO 的哈希而非完整的 UTXO，以大幅减少修剪的完整节点所使用的存储量，而不一定需要对共识规则进行任何更改。

- **<!--script-descriptors-and-descript-->****[脚本描述符和 DESCRIPT][Script descriptors and DESCRIPT]：**Bitcoin Core 等钱包默认监视支付给它们的交易输出的方式“含糊不清、缺乏灵活性且扩展性差”。[输出脚本描述符][Output script descriptors]是一种简单的语言，用于向钱包描述脚本，使钱包更容易处理许多常规情况（包括导入 HD 扩展私钥和公钥）。

    与此相关的是 DESCRIPT，一种使用完整比特币脚本语言的子集的语言，使构建一些简单策略变得容易。"我们有一个 DESCRIPT 编译器，它采用我们称之为策略语言（AND、OR、阈值、公钥、哈希锁、时序锁）以及每个 OR 的概率来告诉它是 50/50 还是 OR 的一侧比另一侧更有可能，并且它会找到 [...] 在我们已定义的脚本子集中的最优脚本。" 例如，它可以允许您"做一些像多签名那样的事情，在一段时间后降级为较弱的多签名——像 2-of-3 但一年后我可以仅用其中一个密钥支出它。"

## 值得注意的代码变更

本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的显著代码变更。

{% comment %}<!-- last secp256k1 commit checked: 1e6f1f5ad5e7f1e3ef79313ec02023902bf8175c -->{% endcomment %}

- [LND #1970][]：AbandonChannel RPC 方法（仅在开发者调试模式中可用）现在在用户告诉其节点放弃一个支付通道时提供了额外的信息（如果不小心使用，此方法可能导致金钱损失）。额外的信息足以允许稍后重新启动一个开放的支付通道，或证明程序有足够的信息对现已关闭的支付通道做出更多的承诺。

- [C-Lightning #2000][]：此更新为如何在数据库中存储哈希时间锁定合约（HTLCs）提供了大量修复和安全性相关的改进。

{% include references.md %}
{% include linkers/issues.md issues="1970,2000" %}

[complex splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[simpler splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001437.html
[script descriptors and descript]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-script-descriptors/
[utreexo]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-utxo-accumulators-and-utreexo/
[optech transcript]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-09-bitcoin-optech/
[dev vids]: https://www.youtube.com/channel/UCywSzGiWWcUG1gTp45YdPUQ/videos
[dev transcripts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/
[warren transcript]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/protecting-yourself-and-your-business/
[warren vid]: https://youtu.be/iPt2ekHoEy8
[kanzure wallet transcript]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/wallet-security/
[kanzure wallet vid]: https://youtu.be/WcOIXsOLJ3w?t=3552
[kanzure reorg transcript]: http://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/reorgs/
[kanzure reorg vid]: https://youtu.be/EUUQbveGF5E?t=4
[UHO]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-May/015967.html
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
