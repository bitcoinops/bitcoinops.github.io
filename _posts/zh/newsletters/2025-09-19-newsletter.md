---
title: 'Bitcoin Optech Newsletter #372'
permalink: /zh/newsletters/2025/09/19/
name: 2025-09-19-newsletter-zh
slug: 2025-09-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一个增强闪电网络冗余超额支付的提案，并链接到关于针对全节点的潜在分区攻击的讨论。此外还包括我们的常规部分：描述服务和客户端软件的最新变更、新版本和候选版本的公告，以及对热门比特币基础设施软件重大变更的总结。

## 新闻

- **<!--lsp-funded-redundant-overpayments-->****由 LSP 出资的冗余超额支付：** 开发者 ZmnSCPxj 在 Delving Bitcoin 上[发布][zmnscpxj lspstuck]了一个提案，允许 LSP 为[冗余超额支付][topic redundant overpayments]提供所需的额外资金（流动性）。在冗余超额支付的原始提案中，Alice 通过多条路径发送多笔支付来向 Zed 付款，但只允许 Zed 领取其中一笔支付；其余支付会退还给 Alice。这种方法的优势是，到达 Zed 的第一笔支付尝试可以在其他尝试仍在网络中传输时成功，从而提高闪电网络支付的速度。

  这种方法的缺点是 Alice 必须拥有额外的资本（流动性）来进行冗余支付，Alice 必须保持在线直到冗余超额支付完成，并且任何卡住的支付都会阻止 Alice 花费这笔钱，直到支付尝试超时（使用常用设置最多两周）。

  ZmnSCPxj 的提案允许 Alice 只支付实际支付金额（加上费用），由她的闪电服务提供商（LSP）提供发送冗余支付所需的流动性，从而提供冗余超额支付的速度优势，而无需她拥有额外的流动性，无论是短暂的还是直到超时。LSP 还能够在 Alice 离线时完成支付，因此即使 Alice 连接性较差，支付也可以完成。

  新提案的缺点是 Alice 会向她的 LSP 失去一些隐私，并且该提案除了支持冗余超额支付外，还需要对闪电网络协议进行多项更改。

- **<!--partitioning-and-eclipse-attacks-using-bgp-interception-->****使用 BGP 拦截的分区和日蚀攻击：** 开发者 cedarctic 在 Delving Bitcoin 上[发布][cedarctic bgp]了关于用来拦截全节点连接到对等节点的内容的边界网关协议（BGP）的使用缺陷，这可以用于使网络分区或执行[日蚀攻击][topic eclipse attacks]。cedarctic 描述了几种缓解措施，讨论中的其他开发者描述了其他缓解措施和监控攻击使用的方法。

## 服务和客户端软件变更

*在这个月度栏目中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--zero-knowledge-proof-of-reserve-tool-->零知识储备证明工具：**
  [Zkpoor][zkpoor github] 使用 STARK 证明生成[储备证明][topic proof of reserves]，而不会泄露所有者的地址或 UTXO。

- **<!--alternative-submarine-swap-protocol-proof-of-concept-->替代潜水艇互换协议概念验证：**
  [Papa Swap][papa swap github] 协议概念验证通过只需要一笔交易而不是两笔来实现[潜水艇互换][topic submarine swaps]功能。

## 版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 30.0rc1][] 是这个全验证节点软件下一个主要版本的候选版本。

- [BDK Chain 0.23.2][] 是这个用于构建钱包应用程序的库的发布版本，它引入了对交易冲突处理的改进，重新设计了 `FilterIter` API 以增强 [BIP158][] 过滤功能，并改进了锚点和区块重组管理。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33268][] 通过移除交易输入总金额必须超过零聪的要求，改变了交易被识别为用户钱包一部分的方式。只要交易花费了钱包中的至少一个输出，它就会被识别为该钱包的一部分。这允许具有零值输入的交易（如花费 [P2A 临时锚点][topic ephemeral anchors]）出现在用户的交易列表中。

- [Eclair #3157][] 更新了重新连接时签名和广播远程承诺交易的方式。它不再重新发送之前签名的承诺，而是使用来自 `channel_reestablish` 的最新随机数重新签名。在[简单 taproot 通道][topic simple taproot channels]中不使用确定性随机数的对等节点在重新连接时会有新的随机数，使之前的承诺签名无效。

- [LND #9975][] 向 [BOLT11][] 发票添加了 [P2TR][topic taproot] 后备链上地址支持，遵循在 [BOLTs #1276][] 中添加的测试向量。BOLT11 发票有一个可选的 `f` 字段，允许用户在无法通过闪电网络完成支付时包含后备链上地址。

- [LND #9677][] 向 `PendingChannels` RPC 命令返回的 `PendingChannel` 响应消息添加了 `ConfirmationsUntilActive` 和 `ConfirmationHeight` 字段。这些字段告知用户通道激活所需的确认数量以及资金交易被确认的区块高度。

- [LDK #4045][] 实现了 LSP 节点接收[异步支付][topic async payments]，通过代表经常离线的接收者接受传入的 [HTLC][topic htlc]，持有它，并在收到信号时稍后将其释放给接收者。此 PR 引入了实验性的 `HtlcHold` 功能位，在 `UpdateAddHtlc` 上添加了新的 `hold_htlc` 标志，并定义了释放路径。

- [LDK #4049][] 实现了从 LSP 节点向在线接收者转发 [BOLT12][topic offers] 发票请求，接收者然后回复一个新的发票。如果接收者离线，LSP 节点可以回复后备发票，这由[异步支付][topic async payments]的服务器端逻辑实现启用（参见周报 [#363][news363 async]）。

- [BDK #1582][] 重构了 `CheckPoint`、`LocalChain`、`ChangeSet` 和 `spk_client` 类型，使其成为通用的并接受 `T` 载荷，而不是固定为区块哈希。这为 `bdk_electrum` 在检查点中存储完整区块头做准备，从而避免重新下载头部并启用缓存的默克尔证明和中位时间过去（MTP）。

- [BDK #2000][] 向重构的 `FilterIter` 结构添加了区块重组处理（参见周报 [#339][news339 filters]）。此 PR 不是将其流程分散到多个方法中，而是将所有内容绑定到 `next()` 函数，从而避免时序风险。在每个区块高度都会发出检查点，以确保区块不是陈旧的，并且 BDK 在有效链上。`FilterIter` 扫描所有区块并获取包含与脚本公钥列表相关的交易的区块，使用 [BIP158][] 中指定的[致密区块过滤器][topic compact block filters]。

- [BDK #2028][] 向 `TxNode` 结构添加了 `last_evicted` 时间戳字段，以指示交易通过 [RBF][topic rbf] 被替换后从内存池中排除的时间。此 PR 还移除了 `TxGraph::get_last_evicted` 方法（参见周报 [#346][news346 evicted]），因为新字段替代了它。

{% include references.md %}
{% include linkers/issues.md v=2 issues="33268,3157,9975,1276,9677,4045,4049,1582,2000,2028" %}
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[zkpoor github]: https://github.com/AbdelStark/zkpoor
[papa swap github]: https://github.com/supertestnet/papa-swap
[news363 async]: /zh/newsletters/2025/07/18/#ldk-3628
[news339 filters]: /zh/newsletters/2025/01/31/#bdk-1614
[news346 evicted]: /zh/newsletters/2025/03/21/#bdk-1839
[BDK Chain 0.23.2]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.2
[zmnscpxj lspstuck]: https://delvingbitcoin.org/t/multichannel-and-multiptlc-towards-a-global-high-availability-cp-database-for-bitcoin-payments/1983/
[cedarctic bgp]: https://delvingbitcoin.org/t/eclipsing-bitcoin-nodes-with-bgp-interception-attacks/1965/
