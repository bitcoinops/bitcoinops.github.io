---
title: 'Bitcoin Optech Newsletter #381'
permalink: /zh/newsletters/2025/11/21/
name: 2025-11-21-newsletter-zh
slug: 2025-11-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报关注了区块传播时间如何影响矿工收益的分析，并描述了解决多方共享资金协议的新方法。此外还包括我们的常规部分：描述服务和客户端软件的最新变更，以及总结对热门比特币基础设施软件的重大合并。

## 新闻

- **<!--modeling-stale-rates-by-propagation-delay-and-mining-centralization-->通过传播延迟和挖矿中心化建模废块率：**
  Antoine Poinsot 在 Delving Bitcoin 上[发布][antoine delving]了关于建模废块率以及区块传播时间如何作为算力函数影响矿工收益的内容。他建立了一个基础情况场景，其中所有矿工都表现得很现实（使用默认的 Bitcoin Core 节点）：如果他们收到一个新区块，他们会立即开始在其上挖矿并发布它。在传播时间为零的情况下，这将导致收益与其算力份额成正比。

  在他的均匀区块传播模型中，他概述了区块变废的两种情况：

  1. 另一个矿工在这个矿工**之前**找到了区块。所有其他矿工首先收到了竞争矿工的区块并开始在其上挖矿。然后这些矿工中的任何一个都可以基于收到的区块找到第二个区块。

  2. 另一个矿工在这个矿工**之后**找到区块。它立即开始在其上挖矿。后续区块也是由同一个矿工找到的。

  Poinsot 指出，在这些情况之间，第一种情况更可能导致区块变废。这表明矿工可能更关心更快地听到其他人的区块，而不是发布自己的区块。他还建议，第二种情况的概率随着矿工中心化显著增加。虽然在两种情况下概率都会随着矿工算力的增加而增加，但 Poinsot 想要计算增加了多少。

  为此，他创建了以下两个模型。

  其中 **h** 是网络算力份额，**s** 是网络其余部分在它之前找到竞争区块的秒数，**H** 是网络上代表其分布的算力集合。

  情况 1 的模型：
  ![另一个矿工之前找到区块的概率图示](/img/posts/2025-11-stale-rates1.png)

  情况 2 的模型：
  ![另一个矿工之后找到区块的概率图示](/img/posts/2025-11-stale-rates2.png)

  他继续展示了矿工区块变废概率作为传播时间函数的图表，给定算力的设定分布。这些图表显示了更大的矿工在传播时间越长时获得的收益显著增加。

  例如，一个拥有 5EH/s 的挖矿操作可以预期 9100 万美元的收益，如果区块需要 10 秒传播，收益将增加 10 万美元。请记住，9100 万美元是收益而不是利润，所以增加的 10 万美元收益将对矿工的净利润产生更大的影响。

  在图表下方，他提供了生成图表的方法，并链接到他的[模拟][block prop simulation]，该模拟证实了用于生成图表的模型的结果。

- **<!--private-key-handover-for-collaborative-closure-->协作关闭的私钥移交：** ZmnSCPxj 在 Delving Bitcoin 上[发布][privkeyhand post]了关于私钥移交的内容，这是一种当之前由两方拥有的资金需要退还给单个实体时协议可以实现的优化。这种增强需要 [taproot][topic taproot] 和 [MuSig2][topic musig] 支持才能以最高效的方式工作。

  这种协议的一个例子是 [HTLC][topic htlc]，其中一方在原像被揭示时向另一方付款，创建一个需要双方签名的退款交易。私钥移交将允许实体在原像被揭示后简单地将临时私钥移交给另一方，从而给接收方完全和单方面的资金访问权。

  实现私钥移交的步骤是：

  - 在建立 HTLC 时，Alice 和 Bob 各自交换一个临时和一个永久公钥。

  - HTLC taproot 输出的密钥路径花费分支被计算为 Alice 和 Bob 临时公钥的 MuSig2。

  - 在协议操作结束时，Bob 向 Alice 提供原像，Alice 反过来将临时私钥移交给他。

  - Bob 现在可以推导出 MuSig2 和的组合私钥，获得对资金的完全控制。

  这种优化带来了一些特殊的好处。首先，在链上费用突然飙升的情况下，Bob 能够在没有另一方协作的情况下 [使用手续费替换（RBF）][topic rbf] 交易。这个功能对协议开发者特别有用，因为他们不需要在简单的概念证明中实现 RBF。其次，接收方能够将声明资金的交易与任何其他操作批处理。

  私钥移交限于要求剩余资金完全转移给单个受益人的协议。因此，[通道拼接][topic splicing]或闪电通道的协作关闭不会从中受益。

## 服务和客户端软件变更

*在这个月度栏目中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--arkade-launches-->****Arkade 启动：**
  [Arkade][ark labs blog] 是一个 [Ark 协议][topic ark]实现，还包括多种编程语言 SDK、钱包、BTCPayServer 插件和其他功能。

- **<!--mempool-monitoring-mobile-application-->交易池监控移动应用：**
  [Mempal][mempal gh] Android 应用提供关于比特币网络的各种指标和警报，从自托管的交易池服务器获取数据。

- **<!--web-based-policy-and-miniscript-ide-->****基于网络的策略和 miniscript IDE：**
  [Miniscript Studio][miniscript studio site] 提供与 [miniscript][topic miniscript] 和策略语言交互的界面。[博客文章][miniscript studio blog]描述了功能，[源代码][miniscript studio gh]可用。

- **<!--phoenix-wallet-adds-taproot-channels-->****Phoenix 钱包添加 taproot 通道：**
  Phoenix 钱包[添加][phoenix post]了对 [taproot][topic taproot] 通道的支持、现有通道的迁移工作流程和多钱包功能。

- **<!--nunchuk-20-launches-->****Nunchuk 2.0 启动：**
  [Nunchuk 2.0][nunchuk blog] 支持使用多重签名、[时间锁][topic timelocks]和 miniscript 的钱包配置。它还包括降级多重签名功能。

- **<!--ln-gossip-traffic-analysis-tool-announced-->****LN Gossip 流量分析工具公布：**
  [Gossip Observer][gossip observer gh] 从多个节点收集闪电网络 Gossip 消息并提供摘要指标。结果可能会为闪电网络提供类似 [minisketch][topic minisketch] 的集合协调协议。[Delving Bitcoin 主题][gossip observer delving]包括关于该方法的讨论。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33745][] 确保通过新的挖矿进程间通信 (IPC) `submitSolution()` 接口（参见[周报 #325][news325 ipc]）由外部 [StratumV2][topic pooled mining] 客户端提交的区块重新验证其见证承诺。之前，Bitcoin Core 只在原始模板构建期间检查这一点，这允许具有无效或缺失见证承诺的区块被接受为最佳链尖。

- [Core Lightning #8537][] 在首次尝试使用 [MPP][topic multipath payments] 支付非公开可达节点时，将 `xpay` 上的 `maxparts` 限制（参见[周报 #379][news379 parts]）设置为六。这符合基于 Phoenix 的节点对即时资助（参见[周报 #323][news323 fly]）的六个 [HTLC][topic htlc] 的接收限制，这是一种 [JIT 通道][topic jit channels]。如果在该上限下路由失败，`xpay` 会移除限制并重试。

- [Core Lightning #8608][] 为 `askrene`（参见[周报 #316][news316 askrene]）引入了节点级偏好，与现有的通道偏好一起。添加了新的 `askrene-bias-node` RPC 命令，用于偏好或不偏好指定节点的所有传出或传入通道。向偏好添加了 `timestamp` 字段，以便它们在一定时间后过期。

- [Core Lightning #8646][] 更新了[通道拼接][topic splicing]通道的重新连接逻辑，与 [BOLTs #1160][] 和 [BOLTs #1289][] 中提议的规范变更保持一致。具体来说，它增强了 `channel_reestablish` TLV，以便对等节点可以可靠地同步拼接状态并传达需要重传的内容。此更新对拼接通道是一个破坏性变更，所以双方必须同时升级以避免中断。参见[周报 #374][news374 ldk]了解 LDK 中的类似变更。

- [Core Lightning #8569][] 在 `lsp-trusts-client` 模式下添加了对 [JIT 通道][topic jit channels]的实验性支持，如 [BLIP52][] (LSPS2) 所规定，但不支持 [MPP][topic multipath payments]。此功能在 `experimental-lsps-client` 和 `experimental-lsps2-service` 选项后面，它代表了提供 JIT 通道完全支持的第一步。

- [Core Lightning #8558][] 添加了 `listnetworkevents` RPC 命令，显示对等连接、断开连接、失败和 ping 延迟的历史。它还引入了 `autoclean-networkevents-age` 配置选项（默认 30 天）来控制网络事件日志的保留时间。

- [LDK #4126][] 在[盲化支付路径][topic rv routing]上引入了基于 `ReceiveAuthKey` 的身份验证验证，替换了较旧的逐跳 HMAC/nonce 方案（参见[周报 #335][news335 hmac]）。这建立在 [LDK #3917][] 的基础上，后者为盲化消息路径添加了 `ReceiveAuthKey`。减少逐跳数据缩小了有效载荷，并为将来的 PR 中的虚拟支付跳铺平了道路，类似于虚拟消息跳（参见[周报 #370][news370 dummy]）。

- [LDK #4208][] 更新其权重估算，始终假设 72 字节 DER 编码签名，而不是在某些地方使用 72 字节，在其他地方使用 73 字节。73 字节签名是非标准的，LDK 从不产生它们。参见[周报 #379][news379 sign]了解 Eclair 中的相关变更。

- [LND #9432][] 添加了新的全局 `upfront-shutdown-address` 配置选项，为协作通道关闭指定默认比特币地址，除非在打开或接受特定通道时被覆盖。这建立在 [BOLT2][] 中规定的提前关闭功能之上。参见[周报 #76][news76 upfront]了解 LND 实现的之前报道。

- [BOLTs #1284][] 更新 BOLT11 以澄清，当发票中存在 `n` 字段时，签名必须是规范化的低 S 形式，当它不存在时，公钥恢复可以接受高 S 和低 S 签名。参见周报 [#371][news371 eclair] 和 [#373][news373 ldk]了解实现此行为的最新 LDK 和 Eclair 变更。

- [BOLTs #1044][] 规定了可选的[可归因失败][topic attributable failures]功能，它向失败消息添加归因数据，以便跳跃对它们发送的消息进行承诺。如果节点损坏失败消息，发送者可以稍后识别并惩罚该节点。有关机制和 LDK 及 Eclair 实现的更多详细信息，请参见周报 [#224][news224 fail]、[#349][news349 fail] 和 [#356][news356 fail]。

{% include snippets/recap-ad.md when="2025-11-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33745,8537,8608,8646,1160,1289,8569,8558,4126,3917,4208,9432,1284,1044" %}
[antoine delving]: https://delvingbitcoin.org/t/propagation-delay-and-mining-centralization-modeling-stale-rates/2110
[block prop simulation]: https://github.com/darosior/miningsimulation
[privkeyhand post]: https://delvingbitcoin.org/t/private-key-handover/2098
[news325 ipc]: /zh/newsletters/2024/10/18/#bitcoin-core-30955
[news379 parts]: /zh/newsletters/2025/11/07/#core-lightning-8636
[news323 fly]: /zh/newsletters/2024/10/04/#eclair-2861
[news316 askrene]: /zh/newsletters/2024/08/16/#core-lightning-7517
[news374 ldk]: /zh/newsletters/2025/10/03/#ldk-4098
[news335 hmac]: /zh/newsletters/2025/01/03/#ldk-3435
[news370 dummy]: /zh/newsletters/2025/09/05/#ldk-3726
[news379 sign]: /zh/newsletters/2025/11/07/#eclair-3210
[news76 upfront]: /zh/newsletters/2019/12/11/#lnd-3655
[news371 eclair]: /zh/newsletters/2025/09/12/#eclair-3163
[news373 ldk]: /zh/newsletters/2025/09/26/#ldk-4064
[news224 fail]: /zh/newsletters/2022/11/02/#ln-routing-failure-attribution
[news349 fail]: /zh/newsletters/2025/04/11/#ldk-2256
[news356 fail]: /zh/newsletters/2025/05/30/#eclair-3065
[ark labs blog]: https://blog.arklabs.xyz/press-start-arkade-goes-live/
[mempal gh]: https://github.com/aeonBTC/Mempal
[miniscript studio gh]: https://github.com/adyshimony/miniscript-studio
[miniscript studio blog]: https://adys.dev/blog/miniscript-studio-intro
[miniscript studio site]: https://adys.dev/miniscript
[phoenix post]: https://x.com/PhoenixWallet/status/1983524047712391445
[nunchuk blog]: https://nunchuk.io/blog/autonomous-inheritance
[gossip observer gh]: https://github.com/jharveyb/gossip_observer
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
