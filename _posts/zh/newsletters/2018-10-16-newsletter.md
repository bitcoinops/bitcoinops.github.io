---
title: "Bitcoin Optech Newsletter #17"
permalink: /zh/newsletters/2018/10/16/
name: 2018-10-16-newsletter-zh
slug: 2018-10-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 简要介绍一项为闪电网络支付通道实现拼接（splicing）的提议，给出 Edge Dev++ 培训课程中演讲的视频与文字记录链接，并概述上周 CoreDev.tech 活动期间整理的部分文字记录。

## 行动项

本周无。

## 新闻

- **<!--proposal-for-lightning-network-payment-channel-splicing-->****闪电网络支付通道拼接提议：** 拼接是一种思路：让用户可以向现有支付通道增加或取出资金，而不必经历关闭旧通道、再打开全新通道的等待。Rusty Russell 发布了一份[技术提案][complex splice]，一次只允许进行一次拼接，不过他坦言这份提案相当复杂。René Pickhardt 描述了另一种[更简单的方案][simpler splice]，它可能更容易实现、也更容易推理，但可能需要更多链上交易。有人建议，把更简单但成本更高的方案定为版本 1，把更复杂但成本更低的方案定为版本 2。

- **<!--edge-dev-talks-published-->****Edge Dev++ 演讲发布：** 一个为期两天、面向开发者的系列演讲，演讲者都是比特币领域的顶尖贡献者，现已发布[视频][dev vids]和[文字记录][dev transcripts]。演讲涵盖从入门到高级的全部主题。其中三场演讲 Optech 成员可能特别感兴趣：

    1. *交易所安全*，演讲者：Warren Togami。介绍比特币和山寨币交易所几起著名重大盗窃案的成因，并列出企业可用于降低损失风险的若干技术手段。([视频][warren vid], [文字记录][warren transcript])

    2. *钱包安全、密钥管理和硬件安全模块（HSMs）*，演讲者：Bryan Bishop。提出降低私钥被盗或被滥用风险的方法。([视频][kanzure wallet vid], [文字记录][kanzure wallet transcript])

    3. *处理重组和分叉*，演讲者：Bryan Bishop。介绍如何保护你的交易，使其不受比特币区块链或共识规则变化的影响，并就如何测试你的系统给出建议。([视频][kanzure reorg vid], [文字记录][kanzure reorg transcript])

## CoreDev.tech

CoreDev.tech 是一个仅限受邀者参加的活动，面向 Bitcoin Core、闪电网络等比特币基础设施项目的知名贡献者。讨论过程不做录音，但 Bryan Bishop 热心地为活动中部分讨论写下了粗略、非权威的文字记录。以下简短摘要基于上周东京活动中部分文字记录整理：

- **<!--bitcoin-optech-optech-transcript-->****[Bitcoin Optech][optech transcript]：** 会上介绍了 Bitcoin Optech 并做了简短讨论，随后讨论了使用比特币的企业在使用 Bitcoin Core 及其他开源基础设施项目时遇到的常见问题。

- **<!--using-utxo-accumulators-to-reduce-data-storage-requirements-utreexo-->****[使用 UTXO 累加器减少数据存储需求][utreexo]：** Tadge Dryja 介绍了他一直在研究的 UTXO 累加器，这些累加器在功能上与上周 Newsletter 中描述的累加器类似，但采用了基于哈希的不同构造方式。他还进一步说明，这套方案可以与 Cory Field 的 [UTXO 哈希集（UHO）][UHO] 之类的想法结合：让完整节点只存 UTXO 的哈希而不存完整 UTXO，从而大幅减少已修剪（pruned）完整节点的存储占用，且不必对共识规则作任何改动。

- **<!--script-descriptors-and-descript-->****[脚本描述符和 DESCRIPT][Script descriptors and DESCRIPT]：**像 Bitcoin Core 这样的钱包默认依靠向后兼容的方式来监视支付给自己的交易输出，而这种方式“含糊不清、缺乏灵活性，扩展性也差”。[输出脚本描述符][Output script descriptors]是一种向钱包描述脚本的简单语言，能让钱包更容易处理许多常见情形（包括导入 HD 扩展私钥和公钥）。

    与此相关的是 DESCRIPT，这门语言使用完整比特币脚本语言的一个子集，便于构造一些简单的策略。“我们有一个 DESCRIPT 编译器，它接收我们称之为策略语言的东西（AND、OR、阈值、公钥、哈希锁、时间锁），再加上每个 OR 的概率，用来说明是 50/50，还是 OR 的某一侧比另一侧更可能发生；然后它会找出……在我们定义的这个脚本子集中的最优脚本。”例如，它可以让你“做出类似多重签名的结构，在一段时间之后降级为较弱的多重签名——比如 2-of-3，但一年后我可以用其中一个密钥就把它花掉”。

## 值得注意的代码变更

本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的代码变更。

{% comment %}<!-- last secp256k1 commit checked: 1e6f1f5ad5e7f1e3ef79313ec02023902bf8175c -->{% endcomment %}

- [LND #1970][]：AbandonChannel RPC 方法（仅在开发者调试模式下可用）现在会在用户让节点放弃某个支付通道时提供额外信息（若使用不慎，该方法可能造成资金损失）。这些额外信息足以让你稍后重新开启该支付通道，或证明程序当时掌握的信息足够对现已关闭的支付通道作出更多承诺。

- [C-Lightning #2000][]：本次更新针对 HTLC 在数据库中的存储方式，提供了大量修复和与安全性相关的改进。

{% include references.md %}
{% include linkers/issues.md issues="1970,2000" %}

[complex splice]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[simpler splice]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001437.html
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
[UHO]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-May/015967.html
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
