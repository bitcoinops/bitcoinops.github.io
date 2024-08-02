---
title: 'Bitcoin Optech Newsletter #44'
permalink: /zh/newsletters/2019/04/30/
name: 2019-04-30-newsletter-zh
slug: 2019-04-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 再次迎来了一个新闻较少的周，但仍包含了关于 bech32 发送支持、Bitcoin Stack Exchange 精选问答以及流行的 Bitcoin 基础设施项目中的值得注意的变化的常规部分。

{% include references.md %}

## 行动项

*撰写时无事项。* 注意：如果 Bitcoin Core 发布团队认为上周分发的第四个[候选版本][0.18.0]中没有发现阻塞问题，他们打算在本周发布此 Newsletter 时标记最终版本 0.18.0。如果发生这种情况，我们将在下周的 Newsletter 中提供详细的版本发布报道。但如果你计划升级，请不要等待我们——所有你需要了解的新版本信息都在其发行说明中解释，这些说明将在不同平台（如 [BitcoinCore.org][]）的各种发布公告中发布或链接。

## 新闻

*本周无新闻。希望大家享受一个美好的春天、秋天或旱季。*

## Bech32 发送支持

*第 7 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定的二周年纪念日前，Optech Newsletter 将包含此每周部分，为开发人员和组织提供有关实现 bech32 发送支持（支付本机 segwit 地址的能力）的信息。这[不需要实现 segwit][bech32 series] 本身，但确实允许你支付的人访问 segwit 的所有多个好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/07-altbech32.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首选地之一——或者当我们有一些空闲时间时，我们会帮助好奇或困惑的用户。在这个每月特辑中，我们会重点介绍自上次更新以来一些投票最高的问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--do-htlcs-work-for-micropayments-->**["HTLC 适用于小额支付吗？"]({{bse}}85650) David Harding 和 Gregory Maxwell 都指出，在路由过程中，输出有太小的金额无法在链上花费是有风险的。少于 546 聪的小额支付不会被 Bitcoin 网络中继。目前的缓解措施是 LN 暂时将这些小额支付变为矿工费而不是输出，取决于博弈论，即如果攻击者无法偷钱，他们就不会花钱攻击。

- **<!--how-was-the-dust-limit-of-546-satoshis-was-chosen-why-not-550-satoshis-->**[为什么 546 聪被选择为尘埃限制？为什么不是 550 聪？]({{bse}}86068) Bitcoin Core 交易中继政策将 546 聪设置为输出的最低金额，这似乎是一个奇怪的数额。Raghav Sood 描述了 546 是创建和花费 P2PKH 输出的最低成本的三倍。参考 [2013 年的讨论][dust convo]。

- **<!--history-of-transactions-in-lightning-network-->**[闪电网络中的交易历史。]({{bse}}85901) 一位 LN 初学者询问如何保存用户在 LN 上进行的交易历史，以及付款人如何接收付款证明。Mark H 回应说，LN 钱包需要为用户保存交易历史，并详细解释了提供给付款人的付款哈希如何生成作为付款证明的付款前映像。

- **<!--how-can-my-private-key-be-revealed-if-i-use-the-same-nonce-while-generating-the-signature-->**[如果在生成签名时使用相同的随机数，我的私钥如何暴露？]({{bse}}85638) Pieter Wuille 提供了一个详细的答案，如果你熟悉公钥密码学中使用的数学，他演示了在这种情况下如何暴露私钥。

- **<!--why-do-lightning-invoices-expire-->**[为什么闪电网络发票会过期？]({{bse}}85981) Rene Pickhardt 猜测主要原因是存储能力相对较低的大量接收者可能会用完存储或内存。另一个原因是如果支付未启动或完成，而不是让它悬而未决，设置过期日期可以提供一些结束。David Harding 指出，传统企业在发票上设置到期日期以避免在以前的报价价格下交付商品的义务。

- **<!--are-there-still-miners-or-mining-pools-which-refuse-to-implement-segwit-->**[是否仍有矿工或矿池拒绝实现 SegWit？]({{bse}}86208) Mark Erhardt 提供了广泛的分析，证明答案基本上是“否”。过去一年中，只有 0.03% 的非空块没有 SegWit 交易，这些少数块的两个主要矿工在 2019 年证明他们正在挖掘包含 SegWit 交易的块。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的更改。注意：除非另有说明，所有描述的 Bitcoin Core 合并都是在其主开发分支上；有些可能也会回移到其待定版本。*

- [Bitcoin Core #14039][] 使 Bitcoin Core 拒绝通过 RPC 提交或通过 P2P 网络接收的交易，如果它们使用 segwit 风格的扩展交易编码但不包括任何 segwit 输入。扩展交易编码包括 segwit 标记、segwit 标志和见证数据字段。包含在传统输入中的签名不承诺这些字段，因此将这些字段添加到完全由传统输入组成的交易中会在交易中产生（小）带宽浪费。[BIP144][] 规定不需要扩展格式的交易应使用传统格式。之前 Bitcoin Core 接受格式不正确的交易并通过在计算其大小（权重）或将其中继到其他节点之前剥离不必要的 segwit 部分来规范它们；现在它将拒绝接受不使用适当格式的交易。

- [Bitcoin Core #15846][] 更新了节点以接受交易进入其内存池以便中继和挖矿，如果交易中的任何输出支付给 segwit 地址版本 1 到 16——为未来的协议升级保留的版本。之前，这样的交易会被拒绝。任何发送到未来版本地址的资金在用户强制实施软分叉以赋予该地址特殊含义之前（类似于 segwit 版本 0 地址对于 P2WPKH 和 P2WSH 的特殊含义），都不安全（任何矿工都可以花费）。这意味着今天没有人应该使用版本 1+ 地址。但是，如果有人确实创建了这样的地址并要求支持 segwit 的钱包或服务支付它，此更改确保交易将像其他交易一样中继和挖矿。（未来版本的此 Newsletter 的 *bech32 发送支持* 部分将深入探讨未来 segwit 版本的地址。）

- [Eclair #950][] 停止在每次节点断开连接时发送通道禁用更新，而是仅在有人请求节点通过断开连接的通道路由支付时发送它们。这可以防止向网络通知没有人实际尝试使用的通道。该 PR 对节点处理网络 gossip 的方式进行了几处其他小改动，旨在减少不必要的流量。

{% include linkers/issues.md issues="14039,15846,950" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[dust convo]: https://github.com/bitcoin/bitcoin/pull/2577#issuecomment-17738577
[bitcoincore.org]: https://bitcoincore.org/
[bech32 series]: /zh/bech32-sending-support/
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
