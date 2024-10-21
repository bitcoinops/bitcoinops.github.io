---
title: 'Bitcoin Optech Newsletter #90'
permalink: /zh/newsletters/2020/03/25/
name: 2020-03-25-newsletter-zh
slug: 2020-03-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了来自 Bitcoin Stack Exchange 的一些问题和答案，并描述了比特币基础设施项目的值得注意的变化。

## 行动项

*本周无。*

## 新闻

*本周没有关于比特币基础设施开发的重大新闻。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选平台之一——或者在我们有空时，帮助好奇或困惑的用户。在这个每月特色中，我们重点介绍自上次更新以来发布的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-the-banscore-default-to-100-->**[为什么 banscore 默认是 100？]({{bse}}93795) 用户 Anonymous 描述了 `banscore` 的一些历史背景，它用于保护节点免受行为不端的节点的影响。虽然一些违规行为会导致 banscore 增加 100 分——从而在默认的 `banscore` 设置下立即封禁违规节点——但 [`net_processing.cpp`][bitcoin net processing] 中详细列出的一些其他违规行为则有不同的分数。

- **<!--why-is-block-620826-s-timestamp-1-second-before-block-620825-->**[为什么区块 620826 的时间戳比区块 620825 早 1 秒？]({{bse}}93696) Andrew Chow 和 Raghav Sood 阐明了区块头的时间戳字段并不要求必须比前一个区块的值大。要求是新区块的时间戳必须大于过去 11 个区块的中位时间戳，但不能晚于运行该节点的计算机的当前时间两个小时之后。

- **<!--where-can-i-find-the-miniscript-policy-language-specification-->**[我在哪里可以找到 miniscript 策略语言规范？]({{bse}}93764) Andrew Chow 和 Pieter Wuille 解释说，目前没有 miniscript 策略语言如何编译成 miniscript 的规范，现有的 C++ 和 Rust 实现实际上会尝试每一种可能性，并选择生成最小 `scriptWitness` 大小的 miniscript。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]的值得注意的变化。*

- [Eclair #1339][] 防止用户将他们的 htlc-minimum 设置为 0 msat（毫聪），因为这将违反 [BOLT2][].<!-- "A receiving node [...] receiving an `amount_msat` equal to 0 [...] SHOULD fail the channel." --> 新的最低值为 1 毫聪。

- [LND #4051][] 记录每个对等节点最多 10 个错误，如果需要，会在重新连接时保留这些错误。最新的错误消息会作为 `ListPeers` 结果的一部分返回，使诊断问题变得更加容易。

- [BOLTs #751][] 更新了 [BOLT7][]，允许节点宣布多个相同类型的 IP 地址（例如 IPv4、IPv6 或 Tor）。这确保了多网节点能够更好地向网络通告其网络连接性。几种闪电网络实现已经允许或宣布了多个相同类型的地址，因此此更改使 BOLT 规范与现有实现保持一致。

{% include references.md %}
{% include linkers/issues.md issues="1339,3697,4051,751" %}
[bitcoin net processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.cpp
