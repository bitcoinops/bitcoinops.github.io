---
title: 'Bitcoin Optech Newsletter #279'
permalink: /zh/newsletters/2023/11/29/
name: 2023-11-29-newsletter-zh
slug: 2023-11-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了流动性广告规范的一个更新。此外是我们的常规部分：来自 Bitcoin Stack Exchange 的精选问题和回答、软件的新版本和候选版本的发布公告、热门的比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--update-to-the-liquidity-ads-specification-->流动性广告规范的更新**：Lisa Neigut 在 Lightning-Dev 邮件组中[发帖][neigut liqad]宣布“[流动性广告][topic liquidity advertisements]（Liquidity Ads）”规范的一次更新。相关的特性已经在 Core Lightning 客户端中实现，并且 Eclair 客户端正在开发；它允许宣布自己愿意为 “[双向注资通道][topic dual funding]” 贡献资金。如果任何一个节点接受这个条件、请求开启一条通道，那么发起请求的节点就必须为得到请求（也就是发起广告）的节点预付一笔费用。这使得需要入账流动性的节点（例如商家）找出具备充分链接、可以按市场价格提供流动性的节点，而且只需使用开源的软件和去中心化的 LN gossip 协议。

    本次升级包含少量结构性的变更，并增加了合约持续时间以及转发费上限的灵活性。这个帖子已经在邮件组中得到多个回复，而且预计[规范][bolts #878]还会有额外的变更。Neigut 的帖子也指出，当前的流动性广告和通道公告的构造使得我们理论上可以用密码学证明一方违反了合约。而设计一种实际可用的紧凑欺诈证据、用在一种债券合约中以激励守约行为，还是一个开放问题。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者寻找答案的首选之地 —— 也是他们有闲暇时会帮助好奇和困惑的用户的地方。在这个月度栏目中，我们会挑出自上次出刊以来新出现的高票问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--is-the-schnorr-digital-signature-scheme-a-multisignature-interactive-scheme-and-also-not-an-aggregated-noninteractive-scheme-->Schnorr 数字签名方案是一种交互式的多签名方案吗，还是一种非交互式的聚合方案呢？]({{bse}}120402)
  Piter Wuille 介绍了多签名、签名聚合、密钥聚合以及比特币 multisig 之间的差异，并指出了多个相关的方案，包括 [BIP340][] [Schnorr 签名][topic schnorr signatures]、[MuSig2][topic musig]、FROST（最优轮次的 Schnorr 门限签名），以及 Bellare-Neven 2006 。

- [<!--is-it-advisable-to-operate-a-release-candidate-full-node-on-mainnet-->是否建议在主网络上运行一个使用候选版本软件的全节点呢？]({{bse}}120375)
  Vojtěch Strnad 和 Murch 指出，在主网络运行 Bitcoin Core 的候选版本对比特币 *网络* 的威胁很小，但 Bitcoin Core 的 API、钱包以及其它特性的用户应该谨慎操作，并测试自己的节点配置。

- [<!--what-is-the-relation-between-nlocktime-and-nsequence-->nLockTime 和 nSequence 有何关联？]({{bse}}120256)
  Antoine Poinsot 以及 Pieter Wuille 回答了一系列关于 `nLockTime` 和 `nSequence` 的 Stack Exchange 问题，包括[两者之间的关系]({{bse}}120273)、[`nLockTime` 的设计初衷]({{bse}}120276)、[`nSequence` 的可能数值]({{bse}}120254) 以及这跟 [BIP68]({{bse}}120320) 和 [`OP_CHECKLOCKTIMEVERIFY`]({{bse}}120259) 的关系。

- [<!--what-would-happen-if-we-provide-to-opcheckmultisig-more-than-threshold-number-m-of-signatures-->如果我给 OP_CHECKMULTISIG 提供超过阈值数量（m）的签名，会发生什么事？]({{bse}}120604)
  Pieter Wuille 解释道，虽然以前这是可以做到的，但 [BIP147][] 假堆栈元素熔融性软分叉不再允许 OP_CHECKMULTISIG 和 OP_CHECKMULTISIGVERIFY 中的额外堆栈元素是任意数值。

- [<!--what-is-mempool-policy-->什么是 “（交易池）策略”？]({{bse}}120269)
  Antoine Poinsot 在 Bitcoin Core 的语境下定义了术语 *交易池策略（policy）* 和 *标准交易（standardness）*，并提供一些例子。他也链接了 Bitcoin Opteck 关于 policy 的 “[等待确认][policy series]” 系列。

- [<!--what-does-pay-to-contract-p2c-mean-->“支付给合约（P2C）” 是什么意思？]({{bse}}120362)
  Vojtěch Strnad 介绍了 [Pay-to-Contract (P2C)][topic p2c] 并链接到了其 [最初提议][p2c paper]。

- [<!--can-a-nonsegwit-transaction-be-serialized-in-the-segwit-format-->非隔离见证交易可以用隔离见证的格式序列化吗？]({{bse}}120317)
  Pieter Wuille 指出，虽然许多较老版本的 Bitcoin Core 无意中允许非隔离见证交易的延展序列化格式（extended serialization format），[BIP144][] 指明非隔离见证的交易必须使用旧的序列化格式。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 23.11][] 是这个闪电节点实现的下一个大版本的候选版本。它为 *rune* 身份验证机制提供了额外的灵活性，还提供了优化后的备份验证，以及插件可用的新特性。

- [Bitcoin Core 26.0rc3][] 是这个主流全节点实现的下一个大版本的候选版本。这里有一份[测试指南][26.0 testing]。

## 重要的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]*。

- [Rust Bitcoin #2213][] 修正了手续费预测中的 P2WPKH 输入的权重预计。因为从 Bitcoin Core 的 [0.10.3][bcc 0.10.3] 和 [0.11.1][bcc 0.11.1] 版本开始，使用太大 s 值的签名的交易会被认为是非标准的，所以交易的构造流程可以安全地假设任意序列化的 ECDSA 签名都最多会是 72 字节，而不是之前使用的上限 73 字节。

- [BDK #1190][] 加入了一种新的 `Wallet::list_output` 方法，可以检索钱包中所有的输出，包括已经花费的输出和未花费的输出。之前，虽然容易获得未花费输出的列表，但难以获得已经花费的输出的列表。


{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2213,1190,878" %}
[bitcoin core 26.0rc3]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11]: https://github.com/ElementsProject/lightning/releases/tag/v23.11
[neigut liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004217.html
[policy series]: /zh/blog/waiting-for-confirmation/
[p2c paper]: https://arxiv.org/abs/1212.3257
[bcc 0.11.1]: https://bitcoin.org/en/release/v0.11.1#test-for-lows-signatures-before-relaying
[bcc 0.10.3]: https://bitcoin.org/en/release/v0.10.3#test-for-lows-signatures-before-relaying
