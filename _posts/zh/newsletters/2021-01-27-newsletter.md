---
title: 'Bitcoin Optech Newsletter #133'
permalink: /zh/newsletters/2021/01/27/
name: 2021-01-27-newsletter-zh
slug: 2021-01-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了一次会议，讨论 taproot 激活机制，包含 Bitcoin Core 使用调查的链接，以及我们的定期部分，提供来自 Bitcoin Stack Exchange 的热门问题与答案、发布与候选发布列表，以及对流行比特币基础设施软件的值得注意的更改的描述。

## 新闻

- **<!--scheduled-meeting-to-discuss-taproot-activation-->****预定会议讨论 taproot 激活：** Michael Folkson [宣布][folkson announce]，将在 <time datetime="2021-02-02 19:00-0000">2 月 2 日 19:00 UTC</time> 于 Freenode 的 [##taproot-activation][] IRC 频道举行会议，讨论对 [BIP8][] 的一些期望修订。目前尚未决定是否实际使用 BIP8 进行激活，因此替代提案可能会在会议期间或后续会议中讨论。请参阅 Folkson 的电子邮件，了解有关 [taproot][topic taproot] 激活机制的背景信息以及会议的拟议议程。

- **<!--bitcoin-core-usage-survey-->****Bitcoin Core 使用调查：** Bitcoin Core 开发者 Andrew Chow 创建了一个针对 Bitcoin Core 用户的[调查][chow survey]。正如关于调查的[博客文章][chow blog]所解释的，回答将用于帮助开发者了解用户使用软件的情况和需求。调查将持续到 3 月 2 日。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地点之一——或者当我们有一些空闲时间来帮助好奇或困惑的用户时。在这个每月的特辑中，我们重点介绍自上次更新以来一些投票最高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-is-the-whitepaper-decoded-from-the-blockchain-->**[白皮书如何从区块链中解码？]({{bse}}35959) 在对原始 2015 年问题的跟进中，Steven Roose 提供了一个使用 `getrawtransaction` 对完整节点运行的单行 `bitcoin-cli` 命令，以生成比特币白皮书的 PDF。[jb55 提供][bitcoin whitepaper gettxout]使用 `gettxout` 的类似命令，适用于修剪节点。

- **<!--full-list-of-special-cases-during-bitcoin-script-execution-->**[Bitcoin Script 执行期间的“特殊情况”完整列表？]({{bse}}101142) Pieter Wuille 提供了比特币脚本评估的伪代码概述，包括 [BIP16][] P2SH 和 [BIP141][] segwit 的附加规则条件。

- **<!--would-first-seen-prevent-a-double-spend-attack-->**[首先看到会防止双重支付攻击吗？]({{bse}}101827) David Lynch 询问是否放弃 [Replace-By-Fee (RBF)][topic rbf] 会防止双重支付攻击。Pieter Wuille 描述了围绕网络上交易传播的各种细微考虑和激励，结论是无法信任任何类型的未确认交易，用户应等待确认。

- **<!--how-do-light-clients-using-compact-block-filters-get-relevant-unconfirmed-transactions-->**[使用致密区块过滤器的轻客户端如何获取相关的未确认交易？]({{bse}}101512) 用户 Pseudonymous 解释说，虽然 [BIP37][topic transaction bloom filtering] 布隆交易过滤支持未确认交易，[致密区块过滤器][topic compact block filters]没有这样的考虑，只为轻客户端提供简化的区块数据，因为轻客户端无法验证未确认交易的有效性。

## 发布与候选发布

*流行比特币基础设施项目的新发布与候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [C-Lightning 0.9.3][c-lightning 0.9.3] 是该项目最新的小版本。它包括对用户界面和插件功能的若干改进，以及对提议的洋葱消息协议（参见 [Newsletter #92][news92 cl3600]）和报价协议（参见 [Newsletter #128][news128 cl4255]）的实验性支持。详情请参阅[发布说明][c-lightning 0.9.3]和[变更日志][cl cl]。

- [LND 0.12.0-beta][] 是该 LN 软件下一个主要版本的最新发布。它包括使用[锚定输出][topic anchor outputs]的瞭望塔支持，并添加了用于处理[部分签名的比特币交易][topic psbt]的新 `psbt` 钱包子命令，以及其他改进和错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19866][] 添加了用户级静态定义追踪（USDT）探针的框架。Linux 内核可以在运行时挂钩到这些追踪点，这允许节点运营者使用 eBPF（扩展伯克利包过滤器）工具如 bpftrace，从用户空间添加自定义内省。例如，这可以用于灵活地添加日志记录或剖析，几乎没有开销。问题 [#20981][Bitcoin Core #20981] 已被提出，以探索在框架合并后在 Bitcoin Core 中使用 USDT 探针的潜在用例。

- [Bitcoin Core #17920][] 添加了使用 GNU Guix [可重复构建][topic reproducible builds] Bitcoin Core 二进制文件用于 macOS 的支持。Windows 和多个 Linux 平台已被支持，因此新的 Guix 确定性构建系统现在支持与现有 Gitian 系统相同的所有平台。

- [LND #4908][] 确保使用[锚定输出][topic anchor outputs]的通道在关闭时可以通过强制保留余额在某些情况下进行费用提升其承诺交易。值得注意的是，通用 `SendCoins` RPC 调用尚未强制执行此余额保留，除非设置了 `send_all`。


{% include references.md %}
{% include linkers/issues.md issues="20981,19866,17920,4908" %}
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta
[c-lightning 0.9.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.3
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[news92 cl3600]: /zh/newsletters/2020/04/08/#c-lightning-3600
[news128 cl4255]: /zh/newsletters/2020/12/16/#c-lightning-4255
[cl cl]: https://github.com/ElementsProject/lightning/blob/v0.9.3/CHANGELOG.md#093---2021-01-20
[folkson announce]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018370.html
[chow survey]: https://survey.alchemer.com/s3/6081474/8acd79087feb
[chow blog]: https://achow101.com/2021/01/bitcoin-core-survey
[bitcoin whitepaper gettxout]: https://bitcoinhackers.org/@jb55/105595146491662406
