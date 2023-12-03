---
title: 'Bitcoin Optech Newsletter #277'
permalink: /zh/newsletters/2023/11/15/
name: 2023-11-15-newsletter-zh
slug: 2023-11-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报介绍了对临时锚点提案的更新，并附上了来自 Wizardsardine 开发人员关于 miniScript 的贡献性工作报告。还包括我们的常规部分：新软件版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--eliminating-malleability-from-ephemeral-anchor-spends-->从临时锚点花费中消除熔融性：** Gregory Sanders 在 Delving Bitcoin 论坛上[发表了][sanders mal]一个对[临时锚点][topic ephemeral anchors]提案的微调。该提案将允许交易包括一个零价值输出，其输出脚本为任何人都可以花费。由于任何人都可以花费输出，因此任何人都可以使用 [CPFP][topic cpfp] 来对创建这个输出的交易进行费用提升。这对于诸如 LN 等多方合同协议非常方便，因为交易通常会在能够准确预测应支付的费率之前签署。临时锚定点允许合约任何一方添加他们认为必要的费用。如果任何其他一方，或者任何其他用户出于任何原因，想要添加更高费用，则他们可以用自己更高费率的 CPFP 费用提升来[替代][topic rbf]之前的 CPFP 费用提升。

    提议使用的任何人都可以花费的脚本类型是一个输出脚本，它由等效的 `OP_TRUE` 组成，可以通过具有空输入脚本的输入进行花费。正如Sanders 本周发布的那样，使用传统输出脚本意味着花费它的子交易具有可熔铸变型的交易索引号（txid），例如，任何矿工都可以向输入脚本添加数据以更改子交易的 txid。这可以使得除了用于费用增加之外，将该子交易用于任何其他用途都是不明智的，因为即使子交易得到确认，也可能以不同的 txid 确认，从而使任何孙交易无效。

    Sanders 建议改用原先为后来隔离见证（Segwit）升级所保留的输出脚本之一。这会使用略多的区块空间————SegWit 使用四个字节，而裸的 `OP_TRUE` 仅使用一个字节，但可以消除关于交易熔融性的任何顾虑。在该主题上进行了一些讨论后，Sanders 随后提出同时提供两种版本：一个 `OP_TRUE` 版本，适用于不关心熔融性且希望尽量减小交易大小的人，以及一个 SegWit 版本，略大但不允许子交易被变异。此讨论主题的进一步探讨侧重于为 SegWit 版本选择额外字节以创建一个易于记忆的 [bech32m 地址][topic bech32]。{% assign timestamp="1:54" %}

## 田野调查：一段 Miniscript 旅程

{% include articles/zh/wizardsardine-miniscript.md extrah="#" %}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.17.1-beta][] 是一个维护版本，用于修复该 LN 节点实现中的几个错误和进行小幅改进。{% assign timestamp="37:27" %}

- [Bitcoin Core 26.0rc2][] 是占主导地位的全节点实现的下一个主要版本的候选版本。包含一个[测试指南][26.0 testing]和 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]专门针对此测试在2023年11月15日进行的预定会议。{% assign timestamp="40:05" %}

- [Core Lightning 23.11rc1][] 是该 LN 节点实现的下一个主要版本的候选版本。{% assign timestamp="53:24" %}

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #28207][] 更新了交易池在磁盘上存储的方式(通常在节点关闭时发生，但也可以通过 `savemempool` RPC 触发)。之前，它是以底层数据的简单序列化形式存储的。现在，该序列化结构被每个节点独立生成的随机值进行异或（XOR）操作，从而模糊化数据。在加载时，使用相同的值进行异或操作以消除模糊化。模糊处理可防止某人能够在交易中放置某些数据以使特定字节序列出现在保存的交易池数据中，这可能导致病毒扫描程序将保存的交易池数据标记为危险。之前已经应用了相同的方法来存储 UTXO 集在[PR #6650][bitcoin core #6650]。任何需要从磁盘读取交易池数据的软件都应该能够轻松地应用异或操作，或者使用配置设置 `-persistmempoolv1` 来请求以未模糊的格式来保存。需要注意的是，向后兼容的配置设置计划在未来的版本中被移除。 {% assign timestamp="55:33" %}

- [LDK #2715][] 允许节点选择性地接受一个小于应交付的 [HTLC][topic htlc]值的支付。当上游节点通过新的[JIT 通道][topic jit channels]向节点支付费用时，这非常有用，因为这样上游节点将从要支付给节点的 HTLC 金额中减去链上交易费用。有关 LDK 对该功能上游部分的先前实现，见[周报 #257][news257 jitfee]。{% assign timestamp="1:02:34" %}

{% include snippets/recap-ad.md when="2023-11-16 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28207,6650,2715" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta
[sanders mal]: https://delvingbitcoin.org/t/segwit-ephemeral-anchors/160
[news257 jitfee]: /zh/newsletters/2023/06/28/#ldk-2319
