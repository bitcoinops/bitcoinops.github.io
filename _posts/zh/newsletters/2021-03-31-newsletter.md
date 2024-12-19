---
title: 'Bitcoin Optech Newsletter #142'
permalink: /zh/newsletters/2021/03/31/
name: 2021-03-31-newsletter-zh
slug: 2021-03-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一篇关于在闪电网络中进行概率路径选择的论文及简短讨论，并包含我们的常设栏目：Bitcoin Stack Exchange 精选问答、新版本和候选发布，以及对比特币基础设施软件值得注意的更改。

## 行动项

- **<!--upgrade-btcpay-server-to-1-0-7-1-->****升级 BTCPay Server 至 1.0.7.1：** 根据项目的发布说明，此[版本][btcpay server 1.0.7.1]修复了 “一个严重和多个低影响的漏洞，这些漏洞影响 1.0.7.0 及更早版本的 BTCPay Server”。

## 新闻

- **<!--paper-on-probabilistic-path-selection-->****关于概率路径选择的论文：**
  René Pickhardt 在 Lightning-Dev 邮件列表中[发布][pickhardt post]了一篇由他与 Sergei Tikhomirov、Alex Biryukov、Mariusz Nowostawski 共同撰写的[论文][pickhardt et al]。该论文对拥有统一分布余额（在各自通道容量范围内）的网络通道进行建模。例如，对于 Alice 和 Bob 之间容量为 1 亿聪的通道，论文假定该通道可能处于下表中所有状态的概率相同，并假设网络中的每个其他通道也是如此：

  | Alice | Bob |
  | 0 sat | 100,000,000 sat |
  | 1 sat | 99,999,999 sat |
  | ... | ...|
  | 100,000,000 sat | 0 sat |

  基于这一假设，作者得出关于支付成功概率的结论，这些结论与支付金额及其需要经过的跳数（通道数）相关。这些结论支持若干已知的启发式方法的优点——例如保持路径短以及使用 [multipath payments（多路径支付）][topic multipath payments] 将大额支付拆分为小额支付（在特定其他假设下）。他们还使用该模型评估新提议，如允许通过 [bolts #780][] 的 [Just-In-Time (JIT) rebalancing（及时再平衡）][topic jit routing]。

  该论文利用其结论提供了一种路由算法，据称可在与他们简化的现有路由算法相比下减少 20% 的支付重试次数。新算法偏好具有较高计算成功概率的路由，而现有算法则采用启发式方法。如果结合 JIT 再平衡，他们估计可获得 48% 的改进。鉴于每次重试通常需要数秒，有时更长，这可能显著改善用户体验。该算法在多个示例网络中进行了测试，包括从近 1000 个真实存在的通道中获取快照的网络。

  该论文有意不考虑路由费用，多数邮件列表中的回应集中于如何在不让用户支付过高费用的前提下利用这些研究结果。

- **<!--updated-article-about-payment-batching-->****更新后的支付批处理文章：**
  Optech 已发布一篇[关于支付批处理的文章][batching post]，相较于我们在 [Newsletter #37][news37 batching] 中的最初公告进行了更新。支付批处理是一种技术，可帮助支付方节省多达 80% 的交易手续费。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之地之一——或在我们有空时帮助好奇或困惑的用户。在本月特刊中，我们会重点展示自上次更新以来获得高票的问题和解答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-hard-is-it-for-an-exchange-to-adopt-native-segwit-->**[交易所采用原生 Segwit 有多难？]({{bse}}103674)
  比特币开发者 instagibbs 列出交易所实施原生 Segwit 时需考虑的几点，包括地址生成、确保可花费性、支持与商业考虑以及硬件安全模块（HSM）等签名基础设施的兼容性。

- **<!--how-do-you-calculate-when-98-of-bitcoin-will-be-mined-->**[如何计算 98% 的比特币何时被挖出？]({{bse}}103159)
  Murch 提供了一个估测，大约在 2030-2031 年达到 98% 的比特币已被挖出，并附上 [奖励时间表的 Google 表格][reward schedule google sheet] 以参考更多指标。

- **<!--how-can-i-use-bitcoin-core-with-the-anonymous-network-protocol-i2p-->**[如何在 Bitcoin Core 中使用匿名网络协议 I2P？]({{bse}}103402)
  随着 [Bitcoin Core #20685][news139 i2p] 的合并，比特币支持 I2P 网络。Michael Folkson 总结了 [Jon Atack 的原始讨论主题][jonatack twitter i2p]，介绍了如何配置 Bitcoin Core 使用 I2P。

- **<!--will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools-->**[具有大于默认内存池的节点会重传那些从较小内存池中已丢弃的交易吗？]({{bse}}103104)
  Pieter Wuille 指出当前的交易重广播由[钱包负责][se 103261]，也许节点也应重广播未确认交易，并指向 [Bitcoin Core #21061][] 这一进展中的目标。

- **<!--should-block-height-or-mtp-or-a-mixture-of-both-be-used-in-a-soft-fork-activation-mechanism-->**[软分叉激活机制应使用区块高度还是 MTP（中位时间过去值），或两者混合？]({{bse}}103854)
  David A. Harding 概述了 MTP 与区块高度这两种计时机制的优缺点。MTP 大致对应实时时间，但矿工可操纵以跳过某个信号区间。区块高度不一致，但也不像 MTP 那样能被矿工轻易操控。

- **<!--why-is-it-recommended-to-not-send-round-number-amounts-when-making-payments-for-increased-privacy-->**[为何为提高隐私性而建议在支付时不要使用整数数额？]({{bse}}103260)
  用户 chytrik 提供了不同示例说明[整数金额启发式][wiki privacy round numbers]及为何避免整数支付金额有助于提高隐私性。

## 发布与候选发布

*流行的比特币基础设施项目的新版本和候选发布。请考虑升级到新版本或协助测试候选发布。*

- [BTCPay Server 1.0.7.1][] 修复了若干安全漏洞，同时包含诸多改进和非安全性错误修复。

- [HWI 2.0.1][] 是一个修正版本，解决了 Trezor T 输入密码和 `hwi-qt` 用户界面键盘快捷键的轻微问题。

- [C-Lightning 0.10.0-rc2][C-Lightning 0.10.0] 是该闪电网络节点软件下一个主版本的候选发布。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #17227][] 为构建系统添加了新的 `make apk` 目标，用于为 Android 操作系统打包 bitcoin-qt。这延续了[此前的工作][news 72 android ndk]，即为打包 Android NDK 提供支持。该合并还包括[构建 Bitcoin Core 的 Android 文档][android build doc]以及一个[持续集成任务][android ci]用于测试 Android 构建系统。

- [Rust-Lightning #849][] 使通道的 `cltv_expiry_delta` 可配置，并将默认值从 72 个区块降低至 36 个区块。该参数设定了在节点从下游节点获知支付成功与否后，需在与上游节点完成支付尝试结算的截止时间。它必须足够长以在必要时上链确认，但又要足够短以在与尝试最小化延迟的其他节点竞争中保持竞争力。另见 [Newsletter #40][news40 cltv_expiry_delta]，当时 LND 将其值降至 40 个区块。

- [C-Lightning #4427][] 通过使用 `--experimental-dual-fund` 配置选项，使得可实验[双向资助][topic dual funding]的支付通道成为可能。双向资助允许初始通道余额由发起通道的节点和接受通道的节点共同出资，这对希望在通道完成开启后立即开始接收付款的商户和其他用户很有用。

- [Eclair #1738][] 在使用[锚定输出][topic anchor outputs]时更新了针对撤销 [HTLC][topic HTLC] 所实施的惩罚机制。当在协议中添加 anchor outputs 时引入的一项与其无关的变更，使得可将多个 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 的 HTLC 输出合并为单笔交易（参见 [Newsletter #128][news128 bolts803]）。此拉取请求确保所有可由撤销密钥花费的输出在同一笔交易中申领，而不是每笔交易仅申领一个输出。

- [BIPs #1080][] 使用 `minimum_activation_height` 参数更新了 [BIP8][]，该参数在锁定软分叉后延迟节点开始执行该软分叉规则的时间，直到达到指定的高度。这使 BIP8 与 *Speedy Trial* 提案（参见 [Newsletter #139][news139 speedy trial]）兼容，该提案允许矿工激活 [taproot][topic taproot]，但在大约六个月后才开始强制执行 taproot 规则，这通常是在实现 Speedy Trial 的软件发布之后。


{% include references.md %}
{% include linkers/issues.md issues="17227,849,4427,1738,1080,1080,780,21061" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0rc2
[hwi 2.0.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.1
[news40 cltv_expiry_delta]: /zh/newsletters/2019/04/02/#lnd-2759
[pickhardt post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002984.html
[pickhardt et al]: https://arxiv.org/abs/2103.08576
[news139 speedy trial]: /zh/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[btcpay server 1.0.7.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.1
[batching post]: /en/payment-batching/
[news37 batching]: /zh/newsletters/2019/03/12/#optech-publishes-book-chapter-about-payment-batching
[news 72 android ndk]: /zh/newsletters/2019/11/13/#bitcoin-core-16110
[android build doc]: https://github.com/bitcoin/bitcoin/blob/11840509/doc/build-android.md
[android ci]: https://github.com/bitcoin/bitcoin/blob/11840509/.cirrus.yml#L184-L192
[reward schedule google sheet]: https://docs.google.com/spreadsheets/d/12tR_9WrY0Hj4AQLoJYj9EDBzfA38XIVLQSOOOVePNm0/edit#gid=0
[news139 i2p]: /zh/newsletters/2021/03/10/#bitcoin-core-20685
[jonatack twitter i2p]: https://twitter.com/jonatack/status/1366764964896075776?s=20
[se 103261]: https://bitcoin.stackexchange.com/questions/103261/does-my-node-rebroadcast-its-mempool-transactions-on-startup/103262#103262
[wiki privacy round numbers]: https://en.bitcoin.it/wiki/Privacy#Round_numbers
[news128 bolts803]: /zh/newsletters/2020/12/16/#bolts-803
