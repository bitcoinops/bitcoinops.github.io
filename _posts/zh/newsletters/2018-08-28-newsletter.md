---
title: 'Bitcoin Optech Newsletter #10'
permalink: /zh/newsletters/2018/08/28/
name: 2018-08-28-newsletter-zh
slug: 2018-08-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的 Newsletter 包括有关 Bitcoin Core 首次发布候选版本的信息、关于 BIP151 P2P 协议加密和潜在的未来软分叉的消息、来自 Bitcoin Stack Exchange 的热门问题及其答案，以及在流行的 Bitcoin 基础设施项目中一些值得注意的合并。

## 行动项

- **<!--allocate-time-to-test-bitcoin-core-0-17rc2-->****分配时间测试 Bitcoin Core 0.17RC2：** Bitcoin Core 已经上传 0.17RC2 的[二进制文件][bcc 0.17]。测试非常受欢迎，并且可以帮助确保最终发布版本的质量。

## 新闻

- **<!--pr-opened-for-initial-bip151-support-->****为初始 BIP151 支持打开 PR：** Jonas Schnelli 向 Bitcoin Core 提出 PR，提供了点对点网络协议的 [BIP151][] 加密的[初始实现][Bitcoin Core #14032]。他还更新了 BIP151 规范的[更新草案][bip151 update]，其中包含了他在实现开发中所做的更改。如果被接受，这将允许全节点和轻量级客户端在不被 ISP 窃听的情况下通信区块、交易和控制消息，这可以使确定哪个程序发起了交易变得更加困难（尤其是结合 Bitcoin Core 现有的交易起源保护或未来提案，例如[蒲公英协议][Dandelion protocol]）。

    Schnelli 还在与其他开发人员合作实现和测试被认为能抵抗量子计算机攻击的 [NewHope 密钥交换协议][newhope]，以便记录两个对等方之间今天通信的窃听者将来在拥有快速量子计算机时无法解密那些数据。

- **<!--requests-for-soft-fork-solutions-to-the-time-warp-attack-->****请求软分叉解决方案以应对时间扭曲攻击：** Bitcoin 区块包括矿工声称创建区块的时间。这些时间戳被用来调整挖掘区块的难度，以便平均每 10 分钟产生一个区块。然而，时间扭曲攻击允许代表大部分网络哈希率的矿工在很长一段时间内持续撒谎关于区块的创建时间以降低难度，即使区块的产生频率超过每 10 分钟一次。

    Gregory Maxwell 在 Bitcoin 协议开发邮件列表中[询问][timewarp maxwell]关于该攻击的提出的软分叉解决方案，然后他将提出自己的解决方案。到目前为止，Johnson Lau 已经[提出][timewarp lau]了一种技术。

    注意：任何监控区块链以查找此类攻击的人至少会在任何重大损害发生之前有一个月的通知时间。因此，以及因为存在多种已知的对抗攻击方法（具有不同的权衡），修复时间扭曲攻击从未被视为紧急事项。然而，如果攻击风险可以通过非争议性软分叉完全或部分缓解，那肯定是好事。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地之一 —— 或者当我们有一些闲暇时间帮助回答其他人的问题时。在这个月度专栏中，我们突出显示自上次更新以来一些得票最高的问题和答案。*

- **<!--can-you-pay-0-bitcoins-->**[你可以支付 0 个比特币吗？][bse 78355] Andrew Chow 解释说，你不仅可以向一个地址或其他脚本支付零值金额，你还可以从零值输出中支付——但前提是你找到一个不使用 Bitcoin Core 默认设置的矿工。

- **<!--can-you-create-an-spv-proof-of-the-absence-of-a-transaction-->**[你能创建一个不存在交易的 SPV 证明吗？][bse 77764] 简化支付验证（SPV, Simplified Payment Verification）使用默克尔树（Merkle tree）来证明某个交易存在于某个区块中，而该区块本身属于最佳区块链——即工作量证明最多的区块链。但你能做反向操作吗？你能证明某个交易不在某个特定的区块中，或者不在最佳区块链的任何区块中吗？

    Gregory Maxwell 解释说这是可能的，它也会涉及到使用默克尔树，但这可能需要计算量大（但带宽效率高）的零知识证明（ZKPs, Zero-Knowledge Proofs）。

- **<!--can-you-convert-a-p2pkh-address-to-p2sh-or-segwit-->**[你能将 P2PKH 地址转换为 P2SH 或 Segwit 吗？][bse 72775] **不要这样做。**
  Pieter Wuille 解释了为什么这是一个非常糟糕的主意，并且很可能导致资金丢失。注意：这是一个较早的答案，本月因一些用户试图将其他人的地址转换为 Segwit 并因此丢失资金而受到更多关注。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的值得注意的提交。提醒：新的合并到 Bitcoin Core 的代码被提交到其主开发分支，并不太可能成为即将发布的 0.17 版本的一部分——你可能要等到大约六个月后的 0.18 版本。*

{% comment %}<!-- I didn't notice anything interesting in LND this week -harding -->{% endcomment %}

- [Bitcoin Core #12254][] 添加了必要的功能，允许 Bitcoin Core 生成 [BIP158][] 致密区块过滤器。这段代码目前尚未被 Bitcoin Core 使用，但未来的工作预计将使用这些功能提供两个特性：

    1. [BIP157][] 支持通过点对点（P2P）网络协议向轻客户端发送过滤器。这可以允许 P2P 轻钱包更加私密地找到影响其钱包的区块，比目前使用 BIP37 布隆过滤器的方式要私密得多。

    2. 为 Bitcoin Core 内置钱包加快重扫速度。偶尔，Bitcoin Core 的用户需要重扫区块链，以查看任何历史交易是否影响了他们的钱包——例如，当他们导入一个新的私钥、公钥或地址时。即使在现代桌面设备上，这目前也需要超过一个小时，但拥有本地 BIP157 过滤器的用户将能够以更快的速度进行重扫，同时仍然拥有[信息论完美隐私][information theoretic perfect privacy]（轻客户端则没有）。

- [Bitcoin Core #12676][] 在 `getrawmempool`、`getmempoolentry`、`getmempoolancestors` 和 `getmempooldescendants` RPC 结果中添加了一个字段，以显示交易是否选择信号其支出者希望其被一个支付相同输入并且手续费更高的交易替代，如 [BIP125][] 所述。

- [C-Lightning #1874][] 标记了 0.6.1 版本的第一个发布候选版本。

- [C-Lightning #1870][] 减少了它将 1,000 重量单位称为 "sipa" 的地方，并开始使用更广泛接受的术语 "kiloweights"（kw）。

  该 PR 还对其处理费用的方式进行了多项改进，无论是对于打开和关闭通道的链上交易（C-Lightning 将费用估算外包给 Bitcoin Core），还是对于支付通道中的费用。

- [C-Lightning #1854][] 实现了 [BOLT2][] 的额外部分，特别是与 `option_data_loss_protect` 字段相关，以改善处理节点似乎丢失了关键数据（即承诺值）的情况，或者远程节点发送的承诺数据无效并可能故意撒谎的情况。

---

{% include references.md %}
{% include linkers/issues.md issues="14032,12254,12676,1874,1870,1854" %}

[dandelion protocol]: https://arxiv.org/abs/1701.04439
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[timewarp maxwell]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[timewarp lau]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016320.html
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 78355]: {{bse}}78355
[bse 77764]: {{bse}}77764
[bse 72775]: {{bse}}72775
[information theoretic perfect privacy]: https://en.wikipedia.org/wiki/Information-theoretic_security
[bip151 update]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[newhope]: https://newhopecrypto.org/
