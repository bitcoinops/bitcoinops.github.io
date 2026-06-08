---
title: 'Bitcoin Optech 周报 #404'
permalink: /zh/newsletters/2026/05/08/
name: 2026-05-08-newsletter-zh
slug: 2026-05-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了解决节点指纹识别问题的可能方案，并链接到关于使用公开欺诈证明来改善即时通道激励机制的讨论。此外还包括我们的常规栏目：介绍流行比特币基础设施软件的重大变更。

## 新闻

- **<!--possible-solutions-to-node-fingerprinting-->****解决节点指纹识别问题的可能方案：** Naiyoma 在 Delving Bitcoin 上[发帖][fing del]，讨论了节点指纹识别问题的可能解决方案。该问题利用 `addr` 消息的时间戳在多个网络上识别同一个节点（见[周报 #360][news360 fing]）。

  自上次更新以来，研究人员对这个问题有了更多认识，并发现了需要考虑的新因素。其中一个关键认识与 `AddrMan` 有关，也就是管理地址的代码结构。`AddrMan` 会将时间戳超过 30 天的地址视为陈旧地址，这通常意味着相应对等节点已离线。因此，任何可能的缓解措施都需要考虑两个重要因素：将旧时间戳刷新为较新的时间戳，可能导致旧地址被持续地 gossip 出去；而把时间戳调得更老，则可能导致它们过早停止被 gossip。

  基于这些考虑，一些此前被设想的方案被放弃，同时提出了新的方案：

  1. **简单模糊化**：对地址时间戳施加 `[-5, +5]` 天范围内的随机扰动。不过，这种扰动可能会随着时间推移而平均掉。

  2. **跨网络使用固定时间戳**：在响应请求时，对特定网络保留真实时间戳，而在其他网络上将时间戳设置为过去某个随机值。不过，旧地址可能会在网络中保留得比必要更久。

  3. **模糊化——只让地址变旧**：只把地址时间戳调旧、绝不调新，对其施加 `[1, 10]` 天范围内的随机扰动。不过，地址可能会过快触及 30 天阈值。

  4. **模糊化——偏向老化的时间戳噪声**：施加 `[-1, +5]` 天范围内的随机扰动，从而使地址主要变得更旧，只有很小概率变得更新。不过，旧地址可能会在网络中保留得比必要更久。

  5. **混合方案**：最后一个选项是将前述两种方案结合起来。

  Naiyoma 向其他对此感兴趣的开发者征求对这项工作的反馈，并分享了她正在测试第 2 种方案的 [PR][fing gh]。

- **<!--public-fraud-proof-for-just-in-time-channels-->****用于即时通道的公开欺诈证明：** Thomas Voegtlin 在 Delving Bitcoin 上[发帖][jit del]，介绍了一项新提案，旨在通过使用公开欺诈证明来展示 LSP 的不当行为，从而改进[即时（JIT）通道][topic jit channels]背后的博弈论设计。

  Alice 与 LSP Bob 协商开启一个 JIT 通道。当 Alice 需要从 Carol 接收 sats 时，她会创建一个原像。Carol 向 Bob 发送一笔 [HTLC][topic htlc]。Alice 将原像披露给 Bob，并期望这位 LSP 广播通道注资交易。如果 Bob 在未为 Alice 开启通道的情况下就领取了这笔 HTLC，会发生什么？

  Voegtlin 提议将区块链用作公开仲裁层。Alice 应该使用 `OP_RETURN` 发布原像，以便任何人都能验证该披露，并将其日期锚定到某个区块高度。与此同时，Bob 创建一个在若干区块 `n` 内有效的 UTXO 承诺。如果他用与其所承诺交易不同的交易来花费同一组 UTXO、未广播注资交易，或试图双花，他就会留下一个欺诈证明，在无需其他客户端信任 Alice 的情况下损害其作为 LSP 的声誉。

  Voegtlin 提供了完整的[论文][jit paper gist]，其中包含对该提案的深入说明，并邀请其他开发者提供反馈。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #33796][] 向 `libbitcoinkernel` 的 C API（见[周报 #380][news380 kernel]）添加了 `btck_check_transaction()`，用于对交易结构执行与上下文无关、共识层面的检查。这包括拒绝空输入或输出列表、无效的 coinbase scriptSig 长度、重复输入、非 coinbase 交易中的空 prevout，以及超出有效货币范围的输出值，而无需依赖 chainstate、UTXO 集或脚本验证。

- [Bitcoin Core #21283][] 实现了 [BIP370][] [PSBTv2][topic psbt] 支持，同时保持与 PSBTv0 的向后兼容。PSBTv2 将交易构造数据（如版本号、锁定时间、输入、输出以及交易可修改性）直接存储在 PSBT 字段中，而无需提供完整的未签名交易。

- [BIPs #2150][] 添加了 [BIP451][]，即 Dust UTXO Disposal Protocol 的规范。它定义了一种标准，使钱包可以安全地处置不需要的[粉尘][topic uneconomical outputs] UTXO：将其花费到单个面额为零的 `OP_RETURN` 输出，并将全部输入值作为交易手续费支付。该协议包含保护隐私的构造规则，例如按地址分别处置已确认的粉尘 UTXO，以及使用 `ALL|ANYONECANPAY` 签名，使得交易池中彼此无关的粉尘处置交易可以通过 [RBF][topic rbf] 被打包在一起。

- [Eclair #3144][] 更新了[简单 taproot 通道][topic simple taproot channels]，改用正式的特性位，并默认启用这类通道，不过暂时仍不支持公告这些通道。该 PR 还添加了测试向量，以与 BOLTs 规范以及 LND 的实现保持一致（见[周报 #401][news401 lnd]）。

- [Eclair #2887][] 添加了对已合并进 BOLTs 规范的正式[拼接][topic splicing]协议的支持（见[周报 #398][news398 splicing]），同时保持与 Eclair 早期实验性拼接实现的向后兼容。

- [LDK #4592][] 开始在开启新的[零手续费承诺][topic v3 commitments]（0FC）通道之前检查节点是否拥有足够的储备金，方法是将它们按[锚点][topic anchor outputs]通道计入计算。此前，LDK 的储备金检查只统计使用旧 `anchors_zero_fee_htlc_tx` 特性的通道，因此节点可能开启比其钱包在同时发生强制关闭时所能安全进行手续费追加的更多 0FC 通道。

- [LND #9153][] 向 `Route` proto 消息添加了 `source_pub_key` 字段，用于从本地节点以外的某个节点视角来构造和反序列化路由。如果未提供 source，LND 会像以前一样继续使用本地节点。

- [Rust Bitcoin #5835][] 为 `V1MessageHeader` 添加了一个构造器，用于计算比特币 P2P 消息头中使用的四字节载荷校验和。这简化了网络消息的构造，使调用方能够先为序列化后的载荷和命令构建消息头，再将消息发送到网络上。

- [BOLTs #995][] 为[简单 taproot 通道][topic simple taproot channels]添加了一份扩展 BOLT，并分配了特性位 80/81。该规范定义了一种最小化的、基于 [taproot][topic taproot] 的通道类型：它使用带有 [MuSig2][topic musig] 密钥聚合的 P2TR 注资输出、taproot 承诺脚本和 HTLC 脚本，以及新的 TLV 字段，用于在开启通道、更新承诺、协作关闭和重连期间交换 MuSig2 部分签名和 nonce。`revoke_and_ack` 和 `channel_reestablish` 中的 nonce 字段按注资交易 txid 建立索引，以支持多个同时有效的承诺交易，例如在[拼接][topic splicing]期间。该扩展刻意排除了 gossip 变更，因此[已公告的 taproot 通道][topic channel announcements]仍是未来工作。

- [BOLTs #1228][] 规定了[零手续费承诺][topic v3 commitments]（0FC）通道，并分配了特性位 40/41。对于这种通道类型，`feerate_per_kw` 被设为 0，承诺交易和 [HTLC][topic htlc] 交易使用 [v3 交易中继][topic v3 transaction relay]（TRUC），挖矿手续费则由子交易通过 [CPFP][topic cpfp] 提供。承诺交易包含一个共享的 [pay-to-anchor (P2A)][topic ephemeral anchors] 输出，由被裁剪的输出和向下取整的 millisatoshi 提供资金，上限为 240 sats，从而使父级承诺交易在大多数情况下无需直接支付手续费。由于 TRUC 的 10 kvB 交易大小限制，该规范还将此类通道的 HTLC 最大数量限制为 114 个。

- [BOLTs #1327][] 更新了 [RBF][topic rbf] 的费率追加规则，以确保在低费率下仍符合 [BIP125][] 的替换规则。规范现在不再只应用现有的 25/24 费率乘数，而是要求替换交易的费率至少增加以下两者中的较大者：该乘数所要求的增量，或额外增加 25 sat/kw。这与[周报 #400][news400 rbf]所记述的 LDK 行为一致。

{% include snippets/recap-ad.md when="2026-05-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33796,21283,2150,3144,2887,4592,9153,5835,995,1228,1327" %}
[fing del]: https://delvingbitcoin.org/t/fingerprinting-nodes-possible-solutions/2466
[news360 fing]: /zh/newsletters/2025/06/27/#fingerprinting-nodes-using-addr-messages
[fing gh]: https://github.com/naiyoma/bitcoin/pull/16
[jit del]: https://delvingbitcoin.org/t/proposal-public-fraud-proofs-for-just-in-time-channels/2451
[jit paper gist]: https://gist.github.com/ecdsa/dfa2d76a5fe845fd283c01b5ed12d274
[news380 kernel]: /zh/newsletters/2025/11/14/#bitcoin-core-30595
[news398 splicing]: /zh/newsletters/2026/03/27/#bolts-1160
[news400 rbf]: /zh/newsletters/2026/04/10/#ldk-4494
[news401 lnd]: /zh/newsletters/2026/04/17/#lnd-9985
