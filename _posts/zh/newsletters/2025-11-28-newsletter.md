---
title: 'Bitcoin Optech Newsletter #382'
permalink: /zh/newsletters/2025/11/28/
name: 2025-11-28-newsletter-zh
slug: 2025-11-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报更新了关于致密区块重建的讨论，并转述了激活 BIP3 的提议信息。此外，我们照例总结了 Bitcoin Stack Exchange 上的热门问答、宣布新版本和候选版本，并描述了流行比特币基础设施项目的显著变更。

## 新闻

- **<!--stats-on-compact-block-reconstructions-updates-->****致密区块重建统计更新：** 0xB10C 在 [Delving Bitcoin][0xb10c delving] 上发布了关于致密区块重建统计的最新情况（参见周报 [#315][news315 cb] 和 [#339][news339 cb]）。0xB10C 围绕自己的重建分析分享了三项更新：

  * 他根据 David Gumberg 的[先前反馈][news365 cb]，开始以 kB 为单位跟踪请求交易的平均大小。

  * 他将自己的一个节点更新为采用 [Bitcoin Core #33106][news368 minrelay] 中较低的 `minrelayfee` 配置。更新后，该节点的区块重建成功率显著提升，以 kB 为单位的请求交易平均大小也有所改善。

  * 随后，他让其余节点也运行在降低过 `minrelayfee` 的设置下，使大多数节点的重建率提升并向对等节点请求更少数据。他还[提到][0xb10c third update]，事后看来，如果保留部分节点运行在 v29 以便比较不同版本和配置，可能会更好。

  总体而言，降低 `minrelayfee` 提高了他节点的区块重建成功率，并减少了向对等节点请求的数据量。

- **<!--motion-to-activate-bip3-->****激活 BIP3 的动议：** Murch 在 Bitcoin-Dev 邮件列表[发布][murch ml]了一项正式动议，呼吁激活 [BIP3][]（参见[周报 #341][news341 bip3]）。该改进提案旨在为拟定新 BIP 提供新的指导，从而取代现有的 [BIP2][] 流程。

  作者表示，该提案已处于“Proposed”状态超过 7 个月，尚无未解决的反对意见，且越来越多的贡献者在 [BIPs #1820][] 上留下 ACK。因此，遵循 BIP2 对流程类 BIP 的激活程序，他给予了 4 周（截至 2025-12-02）的时间来评估提案、ACK 该 PR，或提出疑虑并给出反对意见。若无异议，届时 BIP3 将取代 BIP2，成为新的 BIP 流程。

  目前讨论贴中仅有一些关于在 BIP 投稿流程中使用 AI/LLM 工具的轻微异议（参见[周报 #378][news378 bips2006]），作者正在回应这些问题。我们邀请 Optech 读者熟悉该提案并提供反馈。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找答案的首选之地之一；当我们有空时，也会在那里帮助好奇或困惑的用户。在这个月度栏目中，我们会挑选自上次更新以来点赞最高的问题与回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--do-pruned-nodes-store-witness-inscriptions-->修剪节点会保存见证铭文吗？]({{bse}}129197)
  Murch 解释说，修剪节点会保留所有区块数据（包括见证数据），直到较早的区块最终被删除。他还概述了使用 OP_RETURN 与铭文方案之间的权衡。

- [<!--increasing-probability-of-block-hash-collisions-when-difficulty-is-too-high-->当难度过高时，区块哈希碰撞概率会增加吗？]({{bse}}129265)
  Vojtěch Strnad 指出，除非 SHA256 被攻破，否则区块哈希碰撞几乎不可能发生，并进一步说明为何区块头的哈希值可作为区块标识符。

- [<!--what-is-the-purpose-of-the-initial-0x04-byte-in-all-extended-public-and-private-keys-->所有扩展公钥和私钥开头的 0x04 字节有什么作用？]({{bse}}129178)
  Pieter Wuille 指出，这些 0x04 前缀只是他们各自 Base58 目标编码的巧合。

## 新版本和候选版本

_热门比特币基础设施项目的新版本与候选版本。请考虑升级至最新版本，或帮助测试候选版本。_

- [LND v0.20.0-beta][] 是这个流行闪电网络节点实现的一个主要版本，带来多项错误修复、新的 noopAdd [HTLC][topic htlc] 类型、[BOLT11][] 发票上对 [P2TR][topic taproot] 备用地址的支持，以及大量 RPC 与 `lncli` 的新增与改进。详情见[发行说明][lnd notes]。

- [Core Lightning v25.12rc1][] 是这个主要闪电网络节点实现的新版本候选版，引入以 [BIP39][] 助记词作为新备份方式、`xpay` 的改进、`askrene-bias-node` RPC 以统一偏好或不偏好某个对等节点的全部通道、用于获取对等节点信息的 `networkevents` 子系统，以及用于实验性 [JIT 通道][topic jit channels] 的 `experimental-lsps-client` 与 `experimental-lsps2-service` 选项。

## 值得关注的代码和文档变更

_近期在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 以及 [BINANAs][binana repo] 中值得关注的变更。_

- [Bitcoin Core #33872][] 移除了此前已弃用的 `-maxorphantx` 启动选项（参见[周报 #364][news364 orphan]）。再使用该选项将导致启动失败。

- [Bitcoin Core #33629][] 通过将交易池划分为多个族群，完成了[族群交易池][topic cluster mempool]的实现。默认情况下，每个族群限制为不超过 101 kvB 和 64 笔交易。每个族群会线性化为按手续费率排序的块（子族群排序），从而在构建区块模板时优先选择较高手续费率的区块，在交易池饱和时首先驱逐最低手续费率的区块。该 PR 移除了 [CPFP carve out][topic cpfp carve out] 规则及祖先/后代限制，并更新交易中继逻辑以优先传播较高手续费率的块。最后，它更新了 [手续费替换][topic rbf] 规则：删除“替换交易不得引入新的未确认输入”的限制，改为要求整体族群手续费率分布得到改善，并用“直接冲突族群数量”取代此前的直接冲突数量上限。

- [Core Lightning #8677][] 通过限制同时处理的 RPC 与插件命令数量、减少只读命令不必要的数据库事务，并重构数据库查询以高效处理数百万条 `chainmoves`/`channelmoves` 事件，显著提升大节点的性能。该 PR 还为 `rpc_command` 和 `custommsg` 钩子新增 `filters` 选项，使 `xpay`、`commando`、`chanbackup` 等插件仅在特定调用场景下注册。

- [Core Lightning #8546][] 为 `fundchannel_complete` 新增 `withhold` 选项（默认为 false），可在调用 `sendpsbt` 或通道关闭之前延迟广播通道注资交易。这让 LSP 能够等到用户提供足够资金覆盖网络手续费后再开启通道，这是实现 [JIT 通道][topic jit channels] 中 `client-trusts-lsp` 模式所必需的。

- [Core Lightning #8682][] 更新了[盲化路径][topic rv routing]的构建方式，要求对等节点除了启用 `option_route_blinding` 外，还必须启用 [`option_onion_messages`][topic onion messages]，即使规范未强制要求。此举解决了当 LND 节点未启用该特性时无法转发 [BOLT12][topic offers] 支付的问题。

- [LDK #4197][] 在 `ChannelManager` 中缓存最近撤销的两个承诺点，以便在重连后响应对等节点的 `channel_reestablish` 消息。这样就无需从可能在远程的签名器获取承诺点，避免在对方仅落后一个承诺高度时暂停状态机。如果对等节点呈现不同状态，签名器会验证承诺点；若状态有效，LDK 将崩溃，否则会强制关闭通道。有关 `channel_reestablish` 的先前 LDK 更新，参见周报 [#335][news335 ldk]、[#371][news371 ldk] 和 [#374][news374 ldk]。

- [LDK #4234][] 将注资赎回脚本添加到 `ChannelDetails` 与 `ChannelPending` 事件，使 LDK 的链上钱包能重建通道的 `TxOut`，并在构建 [splice-in][topic splicing] 交易时精确估算手续费率。

- [LDK #4148][] 通过将 `rust-bitcoin` 依赖更新至 0.32.4（参见[周报 #324][news324 testnet]），为 [testnet4][topic testnet] 提供支持，并要求 `lightning` 与 `lightning-invoice` crate 至少使用该版本。

- [BDK #2027][] 为 `TxGraph` 新增 `list_ordered_canonical_txs` 方法，以拓扑顺序返回规范化交易，确保父交易总在子交易之前。现有的 `list_canonical_txs` 与 `try_list_canonical_txs` 已被弃用，建议改用新的有序版本。关于 BDK 规范化工作的历史，参见周报 [#335][news335 txgraph]、[#346][news346 txgraph] 和 [#374][news374 txgraph]。

{% include snippets/recap-ad.md when="2025-12-02 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1820,33872,33629,8677,8546,8682,4197,4234,4148,2027" %}
[0xb10c delving]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/35
[news365 cb]: /zh/newsletters/2025/08/01/#testing-compact-block-prefilling
[news339 cb]: /zh/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news315 cb]: /zh/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[david delving post]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[news368 minrelay]: /zh/newsletters/2025/08/22/#bitcoin-core-33106
[0xb10c third update]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/44
[murch ml]: https://groups.google.com/g/bitcoindev/c/j4_toD-ofEc
[news341 bip3]: /zh/newsletters/2025/02/14/#updated-proposal-for-updated-bip-process
[news378 bips2006]: /zh/newsletters/2025/10/31/#bips-2006
[LND v0.20.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[lnd notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[Core Lightning v25.12rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12rc1
[news364 orphan]: /zh/newsletters/2025/07/25/#bitcoin-core-31829
[news335 ldk]: /zh/newsletters/2025/01/03/#ldk-3365
[news374 ldk]: /zh/newsletters/2025/10/03/#ldk-4098
[news371 ldk]: /zh/newsletters/2025/09/12/#ldk-3886
[news324 testnet]: /zh/newsletters/2024/10/11/#rust-bitcoin-2945
[news335 txgraph]: /zh/newsletters/2025/01/03/#bdk-1670
[news346 txgraph]: /zh/newsletters/2025/03/21/#bdk-1839
[news374 txgraph]: /zh/newsletters/2025/10/03/#bdk-2029