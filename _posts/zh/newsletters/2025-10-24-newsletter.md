---
title: 'Bitcoin Optech Newsletter #377'
permalink: /zh/newsletters/2025/10/24/
name: 2025-10-24-newsletter-zh
slug: 2025-10-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分总结了一个使用族群交易池来侦测区块模板费率上升的想法，并分享了通道阻塞缓解措施模拟实验的进展。此外是我们的常规部分：介绍服务和客户端软件的更新、宣布软件的新版本和候选版本、热门的比特币基础设施软件的显著更新总结。

## 新闻

- **<!--detecting-block-template-feerate-increases-using-cluster-mempool-->使用 “族群交易池” 来侦测区块模板费率上升**：Abubakar Sadiq Ismail 最近在 Delving Bitcoin 论坛[提出][ismail post]了跟踪每一次交易池更新所带来的手续费变化、仅在手续费率的提升值得之时才给矿工提供一个新的挖矿模板的可能性。这种方法可以减少构建多余区块模板的次数，而多余的构建可能会拖慢交易处理和转发。这一提议利用了[族群交易池][topic cluster mempool]来评估是否可能存在手续费率提升，无需重新构造区块模板。

  当一笔新交易进入交易池时，它可能没有连接、也可能连接到了现有的交易族群，因此会触发受影响族群的重新线性化，从而能产生旧的（更新之前的）费率图和新的（更新之后的）费率图（关于 “线性化”，周报 [#312][news312 lin] 提供了更多信息）。旧的费率图标识了可能要从区块模板中驱逐的潜在部分，而新的费率图则标识了可以添加到区块模板中、带来更高费率的部分。然后，这个系统可以遵循下列 4 个步骤来模拟更新（区块模板）的影响：

  1. 驱逐：从一个区块模板副本中移除匹配的部分，从而更新变更之后的手续费和体积。

  2. 天真合并：贪婪地添加候选部分，同时，根据区块重量的限制来评估潜在的手续费收益（ΔF）。

  3. 迭代式合并：如果天真合并无法得到结果，就使用一种更富细节的模拟来提炼 ΔF 。

  4. 决策：对比 ΔF 和一个阈值；如果它超过了这个阈值，就重新构建区块模板、发送给矿工。否则，就跳过，以避免不必要的计算。

  当前的提议还在讨论阶段，没有可用的原型。

- **<!--channel-jamming-mitigation-simulation-results-and-updates-->通道阻塞缓解措施的模拟结果及其更新**：Carla Kirk-Cohen 与 Clara Shikhelman 和 elnosh 合作，在 Delving Bitcoin 论坛[发布][carla post]了他们为自己的[通道阻塞攻击缓解措施提议][channel jamming bolt]使用声誉算法的模拟结果和更新。一些重要的变化有：为出站通道（outgoing channels）跟踪声誉，同时限制入站通道（incoming channels）的资源。Bitcoin Optech 曾经介绍 “[闪电通道阻塞攻击][topic channel jamming attacks]” 和来自 Carla 的一篇较早的 [Delving Bitcoin 帖子][carla earlier delving post]。阅读这些帖子可以获得对闪电通道阻塞攻击的基础理解。

  在最新的更新中，他们使用自己的模拟器来运行[资源型攻击][resource attacks]和 “[沉船攻击][sink attacks]”（声誉型攻击）。他们发现，在使用更新之后，应对资源型攻击的保护保持不变，同时，在沉船攻击中，攻击者节点会更快切断自己的攻击动作。值得指出的是，如果一个攻击者已经建立起了声誉，然后瞄准了一连串的节点，那么只有最后一个节点会得到补偿。不过，要瞄准多个节点，攻击者本身要付出高昂的代价。

  这篇文章的结论是，[通道阻塞攻击][topic channel jamming attacks]的缓解措施已经达成了一个里程碑，鼓励读者尝试他们的模拟来测试攻击。

## 服务和客户端软件的变更

*在这个月度栏目中，我们会列出比特币钱包和服务的有趣更新。*

- **<!--bull-wallet-launches-->** **BULL 钱包启动**：开源的 [BULL 移动端钱包][bull blog]基于 BDK 开发，并且支持[描述符][topic descriptors]、[交易（地址）标签][topic wallet labels]、钱币选择、闪电通道、[payjoin][topic payjoin]、Liquid 侧链、硬件签名其和仅观察钱包；还有其它特性。

- **<!--sparrow-230-released-->** **Sparrow 2.3.0 版本发布**：[Sparrow 2.3.0][sparrow github] 添加了发送到 “[静默支付][topic silent payments]” 地址和 [BIP353][] 肉眼可读比特币支付指令的支持，还有其它特性和 bug 修复。

## 新版本和候选版本

*热门比特币基础设施软件的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 25.09.1][] 是这种流行的闪电节点实现的当前主要版本的一个维护版本，包含了多项 bug 修复。

- [Bitcoin Core 28.3][] 是这个主流的全节点实现的旧版本的维护版本，包含了多项 bug 修复，也为 `blockmintxfee`、`incrementalrelayfee` 和 `minrelaytxfee` 使用了新的默认数值。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33157][] 通过为单交易族群加入一种 `SingletonClusterImpl` 类型、压缩多个 `TxGraph` 的内部组件，优化了[族群交易池][topic cluster mempool]的内存使用。这项 PR 也加入了一种 `GetMainMemoryUsage()` 来评估 `TxGraph` 的内存用量。

- [Bitcoin Core #29675][] 开始支持通过导入 `musig(0)` [描述符][topic descriptors] 到钱包，使用由 [MuSig2][topic musig] 聚合公钥控制的 [taproot][topic taproot] 输出收款和花费。关于更早的支持性工作，请看 [周报 #366][news366 musig2]。

- [Bitcoin Core #33517][] 和 [Bitcoin Core #33518][] 通过加入日志层级和类型、避免序列化已被丢弃的线程间通信（IPC）日志消息，减少了多线程日志编撰的 CPU 消耗。该 PR 的作者发现，在应用该 PR 以前，日志编撰会占用他的 [Stratum v2][topic pooled mining] 客户端应用 50% 的 CPU 时间和比特币节点的 10% 的处理量。而应用该 PR 之后，就降低到近乎 0 比例。周报 [#323][news323 ipc] 和 [#369][news369 ipc] 提供了更多的上下文。

- [Eclair #2792][] 加入了一种新的 “多路径支付（[MPP][topic multipath payments]）” 分割策略 `max-expected-amount`，它通过考虑每一条路径的容量和成功率来分配支付碎片。加入了一个新的 `mpp.splitting-strategy` 配置选项，带有三个选项：`max-expected-amount`、`full-capacity`（仅考虑一条路线的容量）和 `randomize`（是该配置的默认值，随机分割支付碎片）。后面两种策略已经能够通过 `randomize-route-selection` 配置选项的布尔值来使用。这个 PR 还添加了对远端通道的 [HTLC][topic htlc] 最大数额强制执行。

- [LDK #4122][] 支持在一个对等节点离线时排队（queuing）一次[通道拼接][topic splicing]请求，在该节点重新连接时再开始协商。对于[零确认][topic zero-conf channels]的通道拼接，LDK 现在会在交换了 `tx_signatures`（交易签名）之后，立即发送一条 `splice_locked` 消息给对等节点。LDK 也将会在并发通道拼接期间排队一个通道拼接，在另一个通道拼接锁定之后尽快尝试它。

- [LND #9868][] 定义了一种 `OnionMessage` 类型，并添加了两种新的 RPC 端点：`SendOnionMessage`，它会发送一条洋葱信息给某一个对等节点；`SubscribeOnionMessages`，它会订阅一个入站的洋葱消息流。这些是支持 [BOLT12 offers][topic offers] 所需的第一个步骤。

- [LND #10273][] 修复了一个问题：传统的资金清扫器 `utxonursery` 在尝试清扫一个在[锁定时间][topic timelocks]（区块高度提示）中使用 0 数值的 [HTLC][topic htlc] 时，LND 会崩溃。现在，LND 会通过从通道的关闭高度中派生出区块高度提示，从而成功清扫这些 HTLC 。


{% include references.md %}
{% include linkers/issues.md v=2 issues="33157,29675,33517,33518,2792,4122,9868,10273" %}
[carla post]: https://delvingbitcoin.org/t/outgoing-reputation-simulation-results-and-updates/2069
[channel jamming bolt]: https://github.com/lightning/bolts/pull/1280
[resource attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[sink attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[bull blog]: https://www.bullbitcoin.com/blog/bull-by-bull-bitcoin
[sparrow github]: https://github.com/sparrowwallet/sparrow/releases/tag/2.3.0
[ismail post]: https://delvingbitcoin.org/t/determining-blocktemplate-fee-increase-using-fee-rate-diagram/2052
[carla earlier delving post]: /zh/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[Core Lightning 25.09.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.09.1
[Bitcoin Core 28.3]: https://bitcoincore.org/en/2025/10/17/release-28.3/
[news366 musig2]: /zh/newsletters/2025/08/08/#bitcoin-core-31244
[news323 ipc]: /zh/newsletters/2024/10/04/#bitcoin-core-30510
[news369 ipc]: /zh/newsletters/2025/08/29/#bitcoin-core-31802
[news312 lin]: /zh/newsletters/2024/07/19/#introduction-to-cluster-linearization
