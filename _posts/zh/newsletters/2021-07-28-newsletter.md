---
title: 'Bitcoin Optech Newsletter #159'
permalink: /zh/newsletters/2021/07/28/
name: 2021-07-28-newsletter-zh
slug: 2021-07-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括我们定期提供的内容，涵盖过去一个月内 Bitcoin Stack Exchange 上的最佳问答、关于为 Taproot 做准备的最新专栏、新软件的发布与候选发布列表，以及对流行的比特币基础设施软件的显著变更描述。

## 新闻

*本周无重大新闻。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选场所之一——或者当我们有空时，会帮助那些好奇或困惑的用户。在这一每月特辑中，我们将重点介绍自上次更新以来发布的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-this-unusual-transaction-in-the-bitcoin-blockchain-->**[比特币区块链中的这笔异常交易是什么？]({{bse}}107603)
  Murch 描述了在[区块浏览器][topic block explorers]中标记为“UNKNOWN”的输出。该输出是一个使用特殊公钥的 Segwit v1 输出。正如 0xb10c 指出的那样，这笔创建于 2019 年的交易旨在测试 [Optech 兼容性矩阵][compat matrix] 对 Segwit v1 的支持。正如之前警告的（参见 [Newsletter #158][news158 taproot]），在 Taproot 激活之前，P2TR 输出属于“任何人都可以花费”的类型，0xb10c 在[博客文章][0xB10C blog]中对此进行了演示和详细阐述。

- **<!--what-are-miners-signalling-for-when-the-block-header-nversion-field-ends-in-4-i-e-0x3fffe004-->**[当区块头的 nVersion 字段以 4 结尾（例如 0x3fffe004）时，矿工在信号什么？]({{bse}}107443)
  在研究 ASICBoost 的显式形式时，用户 shikaridota 发现最近挖掘的区块在 `nVersion` 字段中设置了 bit 2。Andrew Chow 指出，[Taproot][topic taproot] 使用 bit 2 作为激活信号，具体规定在 [BIP341 的部署][bip341 deployment]部分。

- **<!--where-can-i-find-bitcoin-s-alpha-version-with-15-minute-block-time-intervals-->**[我在哪里可以找到区块时间间隔为 15 分钟的比特币 Alpha 版本？]({{bse}}107407)
  Andrew Chow 指出了一个据称来自中本聪的[源码选择][bitcointalk 15min]，其中包含 15 分钟的区块时间以及 30 天的难度调整周期。

- **<!--what-s-the-purpose-of-using-guix-within-gitian-doesn-t-that-reintroduce-dependencies-and-security-concerns-->**[在 Gitian 中使用 Guix 的目的是什么？这是否会重新引入依赖性和安全问题？]({{bse}}107638)
  Andrew Chow 和 fanquake 介绍了可重复构建的好处，包括使用 [Gitian 构建][github gitian builds]和[基于 Guix 的可引导构建][github contrib guix]，并讨论了它们的结合使用。

- **<!--why-are-there-several-round-number-transactions-with-no-change-->**[为什么有几笔整数字额的交易没有找零？]({{bse}}107418)
  Shm 询问了一系列相关交易，这些交易有多个输入，但仅有一个无找零的整数字额输出。Murch 在回答中描述了[避免找零][bitcoin wiki change avoidance]的概念，尤其是在拥有大量 UTXO 的钱包中。避免找零可以减少交易大小、降低未来手续费、整合 UTXO，并提高隐私性。

## 为 Taproot 做准备 #6：通过使用学习 Taproot

*关于开发者和服务提供商如何为即将到来的 Taproot 激活做好准备的[系列][series preparing for taproot]文章。*

{% include specials/taproot/zh/05-taproot-notebooks.md %}

## 发布与候选发布

*流行的比特币基础设施项目的新版本和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [Rust Bitcoin 0.27.0][]（Bech32m 支持）是一个新发布版本。最显著的变化是新增了对[Bech32m][topic bech32]地址的处理支持。

- [C-Lightning 0.10.1rc1][C-Lightning 0.10.1] 是一个升级的候选版本，包含许多新功能、若干错误修复以及对开发协议的更新（包括[双向资助][topic dual funding]和[报价][topic offers]）。

## 重要的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 中的显著变更。*

- [Bitcoin Core #22387][] 限制每个对等节点平均每 10 秒处理的地址公告数量。超出限制的地址将被忽略。可以将对等节点列入白名单，以允许其超出此限制。此外，节点明确请求的地址公告不受此限制影响。该限制估计约为当前 Bitcoin Core 节点地址公告速率的四倍。

- [C-Lightning #4669][] 修复了其[闪电网络报价][topic offers]解析和验证逻辑中的多个错误。此外，如果用户尝试创建相同参数的新报价，系统将返回先前创建但尚未过期的报价；这对默认不设置到期日期的报价尤为有用。

- [BIPs #1139][] 添加了 [BIP371][]，该文档规范了在 [Taproot][topic taproot] 交易中使用 [PSBT][topic psbt]（包括[版本 0][BIP174]和[版本 2][BIP370]）的新字段。有关详细信息，请参见 [Newsletter #155][news155 tr psbts]。

## 致谢与修改

我们最初对 Bitcoin Core PR #22387 的描述错误地声称新速率限制比测得速率高 40 倍。正确数据应为 4 倍。感谢 Amiti Uttarwar 指出此错误。

{% include references.md %}
{% include linkers/issues.md issues="22387,4669,4639,878,1072,1139" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1rc1
[rust bitcoin 0.27.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.27.0
[sidecar channels]: https://lightning.engineering/posts/2021-05-26-sidecar-channels/
[news123 lightning pool]: /zh/newsletters/2020/11/11/#incoming-channel-marketplace
[news155 tr psbts]: /zh/newsletters/2021/06/30/#psbt-extensions-for-taproot
[zmn liquidity providers]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[lightning pool]: https://lightning.engineering/posts/2020-11-02-pool-deep-dive/
[compat matrix]: /en/compatibility/
[news158 taproot]: /zh/newsletters/2021/07/21/#准备-taproot-5我们为什么要等待
[0xB10C blog]: https://b10c.me/blog/007-spending-p2tr-pre-activation/
[bip341 deployment]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#deployment
[bitcointalk 15min]: https://bitcointalk.org/index.php?topic=382374.msg4108739#msg4108739
[bitcoin wiki change avoidance]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Change_avoidance
[github gitian builds]: https://github.com/bitcoin-core/docs/blob/master/gitian-building.md
[github contrib guix]: https://github.com/bitcoin/bitcoin/blob/master/contrib/guix/README.md
