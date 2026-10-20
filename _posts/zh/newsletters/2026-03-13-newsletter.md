---
title: 'Bitcoin Optech Newsletter #396'
permalink: /zh/newsletters/2026/03/13/
name: 2026-03-13-newsletter-zh
slug: 2026-03-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一种使用比特币脚本实现的抗碰撞哈希函数，并总结了关于闪电网络流量分析的持续讨论。此外还包括我们的常规栏目：新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--collision-resistant-hash-function-for-bitcoin-script-->****比特币脚本的抗碰撞哈希函数：** Robin Linus 在 Delving Bitcoin 上[发帖][bino del]介绍了 Binohash，一种使用比特币脚本实现的新型抗碰撞哈希函数。在他分享的[论文][bino paper]中，Linus 指出 Binohash 允许进行有限的交易内省而无需新共识变更。这进而使 [BitVM][topic acc] 桥等协议能够实现类似[限制条款][topic covenants]的免信任内省功能，而无需依赖受信任的断言机（oracles）。

  该提议的哈希函数通过两步过程间接推导交易摘要：

  - 锁定交易字段：通过要求花费者解决多个签名谜题来绑定交易字段，每个谜题需要 `W1` 比特的工作量，使得授权之外的修改在计算上成本高昂。

  - 推导哈希值：利用传统 `OP_CHECKMULTISIG` 中 `FindAndDelete` 的行为来计算哈希值。用 `n` 个签名初始化一个 nonce 池。花费者产生一个包含 `t` 个签名的子集，使用 `FindAndDelete` 从池中移除这些签名，然后计算剩余签名的 sighash。该过程反复迭代，直到某个 sighash 生成符合要求的谜题签名。由此产生的摘要——即 Binohash——将由获胜子集的 `t` 个索引组成。

  输出摘要具有三个与比特币应用相关的属性：它可以完全在比特币脚本内提取和验证；它提供约 84 位的抗碰撞强度；并且它可以使用 [Lamport 签名][lamport wiki]进行签名，从而在 BitVM 程序内进行承诺。这些属性综合起来意味着开发者可以仅使用现有的脚本原语，在当前的链上构建推理交易数据的协议。

- **<!--continued-discussion-of-gossip-observer-traffic-analysis-tool-->****Gossip Observer 流量分析工具的持续讨论：** 去年 11 月，Jonathan Harvey-Buschel [宣布][news 381 gossip observer]了 Gossip Observer，它可以收集闪电网络 gossip 流量以及计算指标，从而评估用基于集合协调的协议替代消息洪流的可行性。

  此后，Rusty Russell 和其他人在[讨论][gossip observer delving]中探讨了传输 sketch 的最佳方式。Russell 建议改进编码以提高效率，包括使用区块号后缀作为消息的集合键来跳过 `GETDATA` 往返，从而在接收方已经可以推断相关区块上下文时避免不必要的 请求/响应 交换。

  作为回应，Harvey-Buschel [更新][gossip observer github]了他正在运行的 Gossip Observer 版本并继续收集数据。他[发布][gossip observer update]了平均每日消息的分析、检测到的社区的模型以及传播延迟。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [BDK wallet 3.0.0-rc.1][] 是这个用于构建钱包应用的库的新主要版本的候选发布。主要变更包括在两次重启之间持久化的 UTXO 锁定、链更新时返回的结构化的钱包事件，以及在整个 API 中采用 `NetworkKind` 来区分主网和测试网。该版本还添加了 Caravan（见[周报 #77][news77 caravan]）钱包格式的 导入/导出 以及 1.0 版本之前 SQLite 数据库的迁移工具。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #26988][] 更新了 `-addrinfo` CLI 命令（见[周报 #146][news146 addrinfo]），现在返回完整的已知地址集合，而非经过质量和时效过滤的子集。在内部实现上，使用了 `getaddrmaninfo` RPC（见[周报 #275][news275 addrmaninfo]）替代 `getnodeaddresses` RPC（见[周报 #14][news14 rpc]）。现在，返回的数量将与用来选择出站对等节点的未过滤集合一致。

- [Bitcoin Core #34692][] 在拥有至少 4 GiB RAM 的 64 位系统上，将默认 `dbcache` 从 450 MiB 增加到 1 GiB，否则回退到 450 MiB。此变更仅影响 `bitcoind`；kernel 库仍保持 450 MiB 作为默认值。

- [LDK #4304][] 重构了 [HTLC][topic htlc] 转发机制以支持每次转发多个传入和传出 HTLC，为[蹦床][topic trampoline payments]路由奠定基础。与常规转发不同，蹦床节点可以在两端充当[多路径支付][topic multipath payments]端点：它积累传入的 HTLC 部分，为下一跳找到路由，并将转发拆分为多个传出 HTLC。新增的 `HTLCSource::TrampolineForward` 变体跟踪蹦床转发的所有 HTLC。认领和失败被正确处理，通道监视器恢复也被扩展以在重启时重建蹦床转发状态。

- [LDK #4416][] 使接受方在双方同时尝试发起[拼接][topic splicing]时也能贡献资金，有效地为拼接添加了[双向注资][topic dual funding]支持。当双方同时发起时，“[通道静默][topic channel commitment upgrades]（quiescence）” 会打破平衡、选择其中一方作为发起者。此前，只有发起者可以添加资金，接受方必须等待后续的拼接才能添加自己的资金。由于接受方已准备好作为发起者，其手续费从发起者费率（覆盖公共交易字段）调整为接受者费率。`splice_channel` API 现在还接受一个 `max_feerate` 参数来设定最大费率目标。

- [LND #10089][] 添加了[洋葱消息][topic onion messages]转发支持，基于[周报 #377][news377 onion]中的消息类型和 RPC。它引入了 `OnionMessagePayload` 连接类型来解码洋葱消息的内层载荷，并为每个对等节点安排一个行动器来处理解密和转发决策。该功能可以通过 `--protocol.no-onion-messages` 启动标签来禁用。这是 LND 实现 [BOLT12 要约][topic offers]支持路线图的一部分。

- [Libsecp256k1 #1777][] 添加了新的 `secp256k1_context_set_sha256_compression()` API，允许应用在运行时提供自定义的 SHA256 压缩函数。此 API 使得像 Bitcoin Core 这样在启动时已经检测过 CPU 功能的环境，能够通过硬件加速的 SHA256 来短路 libsecp256k1 的哈希运算，而无需重新编译库。

- [BIPs #2047][] 发布了 [BIP392][]，定义了[静默支付][topic silent payments]钱包的[描述符][topic descriptors]格式。新的 `sp()` 描述符指示钱包软件如何扫描和花费静默支付输出，这些输出是 [BIP352][] 中指定的 [P2TR][topic taproot] 输出。单密钥表达式参数形式接受一个 [bech32m][topic bech32] 密钥：`spscan` 编码扫描私钥和花费公钥（用于仅供观察的钱包），或 `spspend` 编码扫描和花费两个私钥。双参数形式 `sp(KEY,KEY)` 接受一个私有扫描密钥作为第一个表达式，以及一个单独的花费密钥表达式（可以是公钥或私钥），并通过 [BIP390][] 支持 [MuSig2][topic musig] 聚合密钥。初始邮件列表讨论见[周报 #387][news387 sp]。

- [BOLTs #1316][] 明确规定 [BOLT12 要约][topic offers]中的 `offer_amount` 在存在时必须大于零。写入方必须将 `offer_amount` 设置为大于零的值，读取方不得响应金额为零的要约。添加了无效零金额要约的测试向量。

- [BOLTs #1312][] 为带有无效 [bech32][topic bech32] 填充的 [BOLT12][topic offers] 要约添加了测试向量，明确此类要约必须按照 [BIP173][] 规则被拒绝。该问题是通过跨闪电网络实现的差分模糊测试发现的，结果显示 CLN 和 LDK 接受了带有无效填充的要约，而 Eclair 和 Lightning-KMP 正确地拒绝了它们。LDK 的修复见[周报 #390][news390 bech32]。

{% include snippets/recap-ad.md when="2026-03-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26988,34692,4304,4416,10089,1777,2047,1316,1312" %}

[bino del]: https://delvingbitcoin.org/t/binohash-transaction-introspection-without-softforks/2288
[bino paper]: https://robinlinus.com/binohash.pdf
[lamport wiki]: https://en.wikipedia.org/wiki/Lamport_signature
[news146 addrinfo]: /zh/newsletters/2021/04/28/#bitcoin-core-21595
[news275 addrmaninfo]: /zh/newsletters/2023/11/01/#bitcoin-core-28565
[news14 rpc]: /zh/newsletters/2018/09/25/#bitcoin-core-13152
[news377 onion]: /zh/newsletters/2025/10/24/#lnd-9868
[news387 sp]: /zh/newsletters/2026/01/09/#draft-bip-for-silent-payment-descriptors
[news390 bech32]: /zh/newsletters/2026/01/30/#ldk-4349
[news77 caravan]: /zh/newsletters/2019/12/18/#unchained-capital-open-sources-caravan-a-multisig-coordinator
[BDK wallet 3.0.0-rc.1]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/v3.0.0-rc.1
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
[gossip observer update]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105/23
[gossip observer github]: https://github.com/jharveyb/gossip_observer
[news 381 gossip observer]: /zh/newsletters/2025/11/21/#ln-gossip-traffic-analysis-tool-announced
