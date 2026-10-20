---
title: 'Bitcoin Optech Newsletter #90'
permalink: /zh/newsletters/2020/03/25/
name: 2020-03-25-newsletter-zh
slug: 2020-03-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了 Bitcoin Stack Exchange 上的一些问答，并介绍了热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

*本周没有关于比特币基础设施开发的重大新闻。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-the-banscore-default-to-100-->**[为什么 banscore 默认是 100？]({{bse}}93795) 用户 Anonymous 介绍了 `banscore` 的一些历史背景，它用于保护节点免受行为不端的对等节点影响。虽然某些违规行为会让 banscore 增加 100 分——从而在默认的 `banscore` 设置下立即封禁违规的对等节点——但 [`net_processing.cpp`][bitcoin net processing] 中列出的其他违规行为对应的分数并不相同。

- **<!--why-is-block-620826-s-timestamp-1-second-before-block-620825-->**[为什么区块 620826 的时间戳比区块 620825 早 1 秒？]({{bse}}93696) Andrew Chow 和 Raghav Sood 说明，区块头的时间戳字段并不要求比之前区块的值更大。实际的要求是：新区块的时间戳必须大于过去 11 个区块时间戳的中位数，同时不能比运行该节点的计算机时钟所表示的当前时间晚两小时以上。

- **<!--where-can-i-find-the-miniscript-policy-language-specification-->**[我在哪里可以找到 miniscript 策略语言规范？]({{bse}}93764) Andrew Chow 和 Pieter Wuille 解释说，目前没有规范说明 [miniscript][topic miniscript] 策略语言如何编译成 miniscript；C++ 和 Rust 的现有实现实际上会穷举每一种可能性，并选择使 `scriptWitness` 大小最小的那种 miniscript。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Eclair #1339][] 防止用户将他们的 htlc-minimum 设置为 0 msat（毫聪），因为这将违反 [BOLT2][].<!-- "A receiving node [...] receiving an `amount_msat` equal to 0 [...] SHOULD fail the channel." --> 新的最低值为 1 毫聪。

- [LND #4051][] 为每个对等节点最多记录 10 条错误，必要时会将这些错误保留到重连之后。最新的错误消息会作为 `ListPeers` 结果的一部分返回，让诊断问题更容易。

- [BOLTs #751][] 更新了 [BOLT7][]，允许节点宣告同一类型的多个 IP 地址（例如 IPv4、IPv6 或 Tor）。这确保多宿主（multi-homed）节点能更好地向网络告知自己的网络连接情况。已有多个 LN 实现会宣告或允许同一类型的多个地址，因此这项变更让 BOLT 规范与各实现此前的做法保持一致。

{% include references.md %}
{% include linkers/issues.md issues="1339,3697,4051,751" %}
[bitcoin net processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.cpp
