---
title: 'Bitcoin Optech Newsletter #142'
permalink: /zh/newsletters/2021/03/31/
name: 2021-03-31-newsletter-zh
slug: 2021-03-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一篇关于闪电网络（LN）概率路径选择的论文及相关简短讨论，并包含我们的固定栏目：Bitcoin Stack Exchange 热门问答摘要、发布与候选发布，以及比特币基础设施软件的值得注意的变更。

## 行动项

- **<!--upgrade-btcpay-server-to-1-0-7-1-->****升级 BTCPay Server 至 1.0.7.1：** 根据项目的发布说明，此[版本][btcpay server 1.0.7.1]修复了“一个严重漏洞和若干低影响漏洞，这些漏洞影响 1.0.7.0 及更早版本的 BTCPay Server”。

## 新闻

- **<!--paper-on-probabilistic-path-selection-->****关于概率路径选择的论文：**
  René Pickhardt 在 Lightning-Dev 邮件列表中[发布][pickhardt post]了一篇由他与 Sergei Tikhomirov、Alex Biryukov、Mariusz Nowostawski 共同撰写的[论文][pickhardt et al]。该论文建模了一个通道网络，其中各通道的余额在其通道容量范围内呈均匀分布。例如，对于 Alice 和 Bob 之间容量为 1 亿 sat 的通道，论文假定该通道处于下表中所有状态的概率相同，并假设网络中的其他每个通道也是如此：

  | Alice | Bob |
  | 0 sat | 100,000,000 sat |
  | 1 sat | 99,999,999 sat |
  | ... | ...|
  | 100,000,000 sat | 0 sat |

  基于这一假设，作者可以就支付成功的概率得出结论：该概率取决于支付金额以及需要经过的跳数（通道数）。这也让他们得以证明若干已知启发式方法的优势——例如保持路径较短，以及使用[多路径支付（multipath payments）][topic multipath payments]将大额支付拆分为小额支付（在其他一些假设之下）。他们还用该模型评估新提议，例如通过 [bolts #780][] 允许[即时再平衡（Just-In-Time，JIT）][topic jit routing]。

  该论文利用其结论给出了一种路由算法，并称相比他们对现有路由算法的简化版本，该算法可将支付重试次数减少 20%。新算法偏好计算成功概率更高的路由，而现有算法采用启发式方法。若与 JIT 再平衡结合，他们估计可提升 48%。由于每次重试通常需要几秒钟，某些情况下还可能更久，这可能带来更好的用户体验。该算法已在多个示例网络上测试，其中之一取自近 1,000 个在线通道的快照。

  该论文刻意不考虑路由手续费，邮件列表上的多数回应也集中在如何在不使用户支付过高手续费的前提下利用这些研究结果。

- **<!--updated-article-about-payment-batching-->****更新后的支付批处理文章：**
  Optech 已发布一篇[关于支付批处理的文章][batching post]，在我们于 [Newsletter #37][news37 batching] 中首次公告的基础上做了更新。支付批处理是一种技术，可帮助付款方节省最多 80% 的交易手续费。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--how-hard-is-it-for-an-exchange-to-adopt-native-segwit-->**[交易所采用原生 segwit 有多难？]({{bse}}103674)
  比特币开发者 instagibbs 列出交易所实施原生 segwit 时需考虑的几点，包括地址生成、确保可花费性、支持与业务方面的考量，以及硬件安全模块（HSM）等签名基础设施的兼容性。

- **<!--how-do-you-calculate-when-98-of-bitcoin-will-be-mined-->**[如何计算 98% 的比特币何时被挖出？]({{bse}}103159)
  Murch 给出的估计是 2030–2031 年，届时全部比特币的 98% 将被挖出；他还给出了一个[奖励发放时间表 Google 表格][reward schedule google sheet] 的链接，其中包含更多指标。

- **<!--how-can-i-use-bitcoin-core-with-the-anonymous-network-protocol-i2p-->**[如何在 Bitcoin Core 中使用匿名网络协议 I2P？]({{bse}}103402)
  随着 [Bitcoin Core #20685][news139 i2p] 的合并，比特币支持 I2P 网络。Michael Folkson 总结了 [Jon Atack 的原始推文串][jonatack twitter i2p]，介绍了如何配置 Bitcoin Core 使用 I2P。

- **<!--will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools-->**[内存池大于默认值的节点，会重传那些已被较小内存池丢弃的交易吗？]({{bse}}103104)
  Pieter Wuille 指出，交易重广播目前是[钱包的职责][se 103261]，也许节点也应重广播未确认交易，并指出 [Bitcoin Core #21061][] 正是朝这一目标推进的工作。

- **<!--should-block-height-or-mtp-or-a-mixture-of-both-be-used-in-a-soft-fork-activation-mechanism-->**[软分叉激活机制该用区块高度、MTP（Median Time Past，过去中位时间），还是两者混用？]({{bse}}103854)
  David A. Harding 概述了 MTP 与区块高度作为比特币内部计时机制各自的优缺点。MTP 大致对应时钟时间，但矿工可以操纵它以跳过某个信号期。区块高度的间隔并不一致，但也不像 MTP 那样可被矿工博弈。

- **<!--why-is-it-recommended-to-not-send-round-number-amounts-when-making-payments-for-increased-privacy-->**[为何为提高隐私性而建议在支付时不要使用整数数额？]({{bse}}103260)
  用户 chytrik 提供了不同示例说明[整数金额启发式][wiki privacy round numbers]及为何避免整数支付金额有助于提高隐私性。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [BTCPay Server 1.0.7.1][] 修复了若干安全漏洞，同时包含诸多改进和非安全性错误修复。

- [HWI 2.0.1][] 是一个错误修复版本，解决了 Trezor T 密码短语输入和 `hwi-qt` 用户界面键盘快捷键的一些小问题。

- [C-Lightning 0.10.0-rc2][C-Lightning 0.10.0] 是该闪电网络节点软件下一个主版本的候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #17227][] 为构建系统添加了新的 `make apk` 目标，用于为 Android 操作系统打包 bitcoin-qt。这延续了[此前的工作][news 72 android ndk]，即增加对打包 Android NDK 的支持。该 PR 还包含[在 Android 上构建 Bitcoin Core 的文档][android build doc]，以及一个用于测试 Android 构建系统的[持续集成任务][android ci]。

- [Rust-Lightning #849][] 使通道的 `cltv_expiry_delta` 可配置，并将默认值从 72 个区块降低至 36 个区块。该参数设定了一个截止时间：节点从下游节点得知该笔支付是否成功之后，必须在此时间前与上游节点结清这次支付尝试。它必须足够长，以便必要时能在链上确认交易；但又应足够短，才能与那些尽量缩短可能延迟的其他节点竞争。另见 [Newsletter #40][news40 cltv_expiry_delta]，当时 LND 将该值降至 40 个区块。

- [C-Lightning #4427][] 让你可以通过 `--experimental-dual-fund` 配置选项试验[双向资助][topic dual funding]的支付通道。双向资助允许初始通道余额由发起通道的节点和接受通道的节点共同出资，这对那些希望在通道开启完成后立即开始接收支付的商户和其他用户很有用。

- [Eclair #1738][] 更新了使用[锚定输出][topic anchor outputs]时对已撤销 [HTLC][topic HTLC] 的惩罚执行机制。有一项与锚定输出无关、却是在将其加入协议时一并引入的变更，使得可以把多个 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 的 HTLC 输出合并到一笔交易中（参见 [Newsletter #128][news128 bolts803]）。该 PR 确保所有可用撤销密钥花费的输出都在同一笔交易中申领，而不是每笔交易只申领一个输出。

- [BIPs #1080][] 用 `minimum_activation_height` 参数更新了 [BIP8][]，该参数把节点开始执行已锁定软分叉的时间推迟到指定高度之后。这使 BIP8 与 *Speedy Trial* 提案（参见 [Newsletter #139][news139 speedy trial]）兼容：该提案允许矿工激活 [taproot][topic taproot]，但要等到实现 Speedy Trial 的软件发布约六个月之后，才开始强制执行 taproot 的规则。


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
