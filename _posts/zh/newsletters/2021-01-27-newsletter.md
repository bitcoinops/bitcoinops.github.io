---
title: 'Bitcoin Optech Newsletter #133'
permalink: /zh/newsletters/2021/01/27/
name: 2021-01-27-newsletter-zh
slug: 2021-01-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了一次讨论 taproot 激活机制的会议，包含 Bitcoin Core 使用调查的链接，以及我们的常规栏目：Bitcoin Stack Exchange 的热门问答、发布与候选发布列表，以及热门比特币基础设施软件值得注意的变更介绍。

## 新闻

- **<!--scheduled-meeting-to-discuss-taproot-activation-->****已安排的 taproot 激活讨论会议：** Michael Folkson [宣布][folkson announce]，将于 <time datetime="2021-02-02 19:00-0000">2 月 2 日 19:00 UTC</time> 在 Freenode 的 [##taproot-activation][] IRC 频道举行会议，讨论希望对 [BIP8][] 做出的一些修订。目前尚未决定是否真的用 BIP8 来激活，因此会上或后续会议中也可能讨论其他替代提案。Folkson 的电子邮件中有 [taproot][topic taproot] 激活机制的背景信息，以及会议的拟定议程。

- **<!--bitcoin-core-usage-survey-->****Bitcoin Core 使用情况调查：** Bitcoin Core 开发者 Andrew Chow 面向 Bitcoin Core 用户创建了一份[调查][chow survey]。正如一篇介绍该调查的[博客文章][chow blog]所解释的，回答将用于帮助开发者了解人们在使用什么、希望软件提供什么。调查将持续到 3 月 2 日。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-is-the-whitepaper-decoded-from-the-blockchain-->**[白皮书是如何从区块链中解码出来的？]({{bse}}35959) 在对 2015 年那个原始问题的跟进回答中，Steven Roose 给出了一条单行 `bitcoin-cli` 命令，对全节点调用 `getrawtransaction` 来生成比特币白皮书的 PDF。[jb55 也提供][bitcoin whitepaper gettxout]了一条使用 `gettxout` 的类似命令，可在修剪节点上使用。

- **<!--full-list-of-special-cases-during-bitcoin-script-execution-->**[Bitcoin Script 执行期间的“特殊情况”完整列表？]({{bse}}101142) Pieter Wuille 用伪代码概述了比特币脚本的求值过程，包括 [BIP16][] P2SH 和 [BIP141][] segwit 各自附加规则的触发条件。

- **<!--would-first-seen-prevent-a-double-spend-attack-->**[先见规则能防止双花攻击吗？]({{bse}}101827) David Lynch 询问，如果不再使用[手续费替换（RBF）][topic rbf]，是否能防止双花攻击。Pieter Wuille 论述了围绕交易在网络中传播的各种微妙考量和激励，结论是任何类型的未确认交易都不可信任，用户应等待确认。

- **<!--how-do-light-clients-using-compact-block-filters-get-relevant-unconfirmed-transactions-->**[使用紧凑区块过滤器的轻客户端如何获取相关的未确认交易？]({{bse}}101512) 用户 Pseudonymous 解释说，[BIP37][topic transaction bloom filtering] 布隆交易过滤支持未确认交易，而[紧凑区块过滤器][topic compact block filters]没有这种考虑，只向轻客户端提供经过压缩的区块数据，因为轻客户端无法验证未确认交易是否有效。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.9.3][c-lightning 0.9.3] 是该项目最新的次要版本。它包含对用户界面和插件能力的若干改进，以及对提议的洋葱消息协议（参见 [Newsletter #92][news92 cl3600]）和 offers 协议（参见 [Newsletter #128][news128 cl4255]）的实验性支持。详情请参阅[发布说明][c-lightning 0.9.3]和[变更日志][cl cl]。

- [LND 0.12.0-beta][] 是该 LN 软件下一个主要版本的最新发布。它支持搭配[锚定输出][topic anchor outputs]使用瞭望塔，并新增了用于处理[部分签名比特币交易（PSBT）][topic psbt]的 `psbt` 钱包子命令，此外还有其他改进和错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]中值得注意的变更。*

- [Bitcoin Core #19866][] 添加了一套用户级静态定义追踪（USDT）探针框架。Linux 内核可以在运行时挂接到这些追踪点，让节点运营者能够借助 eBPF（扩展伯克利包过滤器）工具（如 bpftrace）从用户空间加入自定义的内省观测。例如，可以用它灵活地添加日志或剖析，而几乎没有开销。框架合并后，已创建 issue [#20981][Bitcoin Core #20981]，用以探索 USDT 探针在 Bitcoin Core 中的潜在用例。

- [Bitcoin Core #17920][] 增加了用 GNU Guix 为 macOS [可重复构建][topic reproducible builds] Bitcoin Core 二进制文件的支持。Windows 和若干 Linux 平台此前已获支持，因此新的 Guix 确定性构建系统现在支持的平台与现有 Gitian 系统完全相同。

- [LND #4908][] 确保使用[锚定输出][topic anchor outputs]的通道在关闭时也能对承诺交易进行手续费追加：在某些情况下，它会强制保留一笔储备余额。值得注意的是，通用的 `SendCoins` RPC 调用尚未强制执行这一余额保留，除非设置了 `send_all`。


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
