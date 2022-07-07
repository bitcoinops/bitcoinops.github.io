---
title: 'Bitcoin Optech Newsletter #206'
permalink: /zh/newsletters/2022/06/29/
name: 2022-06-29-newsletter-zh
slug: 2022-06-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括了我们的常规部分，总结了 Bitcoin Stack Exchange 的热门问答，宣布了新的软件版本和候选版本，并介绍了比特币基础设施软件的最新变更。

## 新闻

*本周在 Bitcoin-Dev 和 Lightning-Dev 邮件列表中没有发现重大新闻。*

## Bitcoin Stack Exchange 网站的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者查找问题答案的首选之地 —— 也是他们有闲暇时会帮助好奇和困惑的用户的地方。在这个每月一次的栏目中，我们会挑出自上次栏目更新以来新出现的高赞问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-is-the-purpose-of-indexing-the-mempool-by-these-five-criteria-->按这五个标准对内存池进行索引的目的是什么？]({{bse}}114216)
  Murch 和 glozow 解释了比特币核心中不同的交易池交易索引（txid、wtxid、交易池的时间、祖先费率和后代费率）以及它们的用途。

- [<!--bip-341-should-key-path-only-p2tr-be-eschewed-altogether-->BIP-341: 是否应该摒弃只用密钥路径的 P2TR？]({{bse}}113989)
  Pieter Wuille 定义了 4 个 [taproot][topic taproot] 密钥路径花费选项，概述了[BIP341 推荐][bip41 constructing] "noscript" 选项的原因，并指出其他选项可能更受欢迎的情况。


- [<!--was-the-addition-of-op-nop-codes-in-bitcoin-0-3-6-a-hard-or-soft-fork-->比特币 0.3.6 中增加的 OP_NOP 代码是硬分叉还是软分叉？]({{bse}}113994)
  Pieter Wuille 解释说，在 Bitcoin Core 0.3.6 中增加 [`OP_NOP` 代码][wiki reserved words]是一个向后不兼容的共识变化，因为旧的软件版本会将使用新的合法 `OP_NOP` 代码的交易视为不合法。然而，由于之前没有使用这些 `OP_NOP` 代码的交易被打包，所以没有分叉。

- [<!--what-is-the-largest-multisig-quorum-currently-possible-->目前可能的最大多签人数是多少？]({{bse}}114048)
  Andrew Chow 列出了不同的可能的多签类型（裸脚本，P2SH，P2WSH，P2TR，P2TR + [MuSig][topic musig]）以及每种类型的多签的人数限制。

- [<!--what-is-the-difference-between-blocksonly-and-block-relay-only-in-bitcoin-core-->比特币核心中的 block-only 和 block-relay-only 之间有什么区别？]({{bse}}114081)
  Lightlike 列出了 block-relay-only 连接和运行 `-blocksonly` 模式的节点之间的区别。

- [<!--where-are-bips-40-and-41-->BIP 40 和 41 在哪里？]({{bse}}114168)
  用户 andrewz 问，为什么[分配给][assigned BIP numbers] Stratum wire 协议的 BIP40 和 Stratum mining 协议的 BIP41 没有内容。在[另一个回答中][se 114179]，Michael Folkson 给出了一些正在编写的 Stratum 的文档链接。

## 新版本和候选版本

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到最新版本或帮助测试候选版本。*

- [LND 0.15.0-beta][] 是这个流行的 LN 节点的下一个主要发布版本。它增加了收据元数据，可以被其他程序（以及潜在的 LND 未来版本）用于[无状态收据][topic stateless invoices]，并增加了对内部钱包的支持，用于接收和花费比特币到 [P2TR][topic taproot] 密钥花费输出，以及实验性的 [MuSig2][topic musig] 支持。

- [Core Lightning 0.11.2][] 是 LN 节点的一个错误修复版本。Core Lightning 开发者“强烈建议”升级。

## 代码和文档的重大变更

*本周内，[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 出现的重大变更。*

- [Core Lightning #5306][] 更新了多个 API，以统一使用 “msat” 来表示毫秒数，并在这些字段中以数字形式返回 JSON 值。一些字段被重新命名以保持与其他字段的一致性。旧的方式已被废弃，但暂时还可以使用。

- [LDK #1531][] 开始对 LN 供资交易使用[反费用狙击][topic fee sniping]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5306,1531" %}
[lnd 0.15.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta
[core lightning 0.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.2
[bip41 constructing]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#user-content-constructing_and_spending_taproot_outputs
[wiki reserved words]: https://en.bitcoin.it/wiki/Script#Reserved_words
[se 114179]: https://bitcoin.stackexchange.com/a/114179/87121
[assigned bip numbers]: https://github.com/bitcoin/bips#readme
