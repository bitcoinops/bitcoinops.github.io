---
title: 'Bitcoin Optech Newsletter #371'
permalink: /zh/newsletters/2025/09/12/
name: 2025-09-12-newsletter-zh
slug: 2025-09-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分宣布了一本专论可证明的密码学的手册的问世。此外是我们的常规栏目：软件的新版本和候选版本的发行，以及热门的比特币基础设施软件的显著变更描述。

## 新闻

- **<!--provable-cryptography-workbook-->可证明的密码学手册**：Jonas Nick 在 Delving Bitcoin 论坛中[公开][nick workbook]了他为一场为期四天的活动而撰写的手册，旨在 “教导开发者们可证明的密码学的基础知识，……，包含了密码学的定义、命题、证据和练习。”该手册的[PDF][workbook pdf]版本已经公开，且有免费许可的[源代码][workbook source]。

## 发行和候选发行

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Bitcoin Core 29.1][] 是这个主流全节点实现的一个维护版本的候选发行。

- [Eclair v0.13.0][] 是这个闪电节点实现的发行版。该发行版 “包含了大量的重构（refactoring）、taproot 通道的一个初步实现，……，基于近期的规范更新优化了通道拼接，以及对 BOLT12 的更好支持。”Taproot 通道和通道拼接特性的完整详述尚未完成，所以普通用户不应该使用。发行公告也警告：“这是最后一个依然支持非锚点输出通道的 eclair 版本。如果你有不使用锚点输出的通道，你应该关闭它。”

- [Bitcoin Core 30.0rc1][] 是这个全验证节点实现软件的下一个主要版本的候选发行。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core 30.0rc1][]、[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #30469][] 将 `m_total_prevout_spent_amount`、`m_total_new_outputs_ex_coinbase_amount` 和 `m_total_coinbase_amount` 的值从 `CAmount` 类型（64 位）变为 `arith_uint256` 类型（256 位），以防止在默认的 [signet][topic signet] 上已经观察到的数值溢出故障。新版本的 coinstats 索引会存储在 `/indexes/coinstatsindex/`，而一个升级后的节点将需要从头同步来重建这个索引。旧版本保留，用于降级保护，但可能会在未来的更新中移除。

- [Eclair #3163][] 添加了一个测试向量，以保证一个收款方的公钥可以从带有高 S 签名的 [BOLT11][] 发票中复原（原本已允许从低 S 签名中复原）。这跟 libsecp256k1 的动作和 [BOLTs #1284][] 提议保持一致。

- [Eclair #2308][] 加入了新的 `use-past-relay-data` 选项（默认为假），当该选项设为真时，使用一个基于过往支付尝试的概率方法来提升选路效果。这取代了以往假设通道余额均匀分布的方法。

- [Eclair #3021][] 允许一条[双向注资通道][topic dual funding]的非发起方 [RBF][topic rbf] 注资交易（相同的效果在[通道拼接][topic splicing]交易中已经实现）。不过，[流动性广告][topic liquidity advertisements]的购买交易将是例外。该特性已在 [BOLTs #1236][] 中提出。

- [Eclair #3142][] 为 `forceclose` API 端点加入了新的 `maxClosingFeerateSatByte` 参数，它将为不紧急的强制关闭交易覆盖全局的费率配置，转变为按通道配置。全局设定 `max-closing-feerate` 在 [Eclair #3097][] 中引入。

- [LDK #4053][] 通过将两个锚点输出替代为一个共享的 [Pay-to-Anchor (P2A)][topic ephemeral anchors] 输出、引入了承诺交易零费率的通道（P2A 输出的数值上限为 240 聪）。此外，它将承诺交易零费率通道中的 [HTLC][topic htlc] 交易的签名切换为 `SIGHASH_SINGLE|ANYONECANPAY` 模式，并将 HTLC 交易的版本号改为[版本 3][topic v3 transaction relay]。

- [LDK #3886][] 使用两个 `funding_locked_txid` TLV 字段（节点最后发送和收到的东西）延申了用于[通道拼接][topic splicing]的 `channel_reestablish`，从而对等节点可以在重新连接后重新协调激活的注资交易。此外，它还通过重新发送 `commitment_signed` （早于 `tx_signatures`）、处理隐式的 `splice_locked`、接受 `next_funding` 并按需重新请求宣告消息签名，将重新连接的流程平滑化了。

{% include references.md %}
{% include linkers/issues.md v=2 issues="30469,3163,2308,3021,3142,4053,3886,1284,1236,3097" %}
[bitcoin core 29.1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[nick workbook]: https://delvingbitcoin.org/t/provable-cryptography-for-bitcoin-an-introduction-workbook/1974
[workbook pdf]: https://github.com/cryptography-camp/workbook/releases
[workbook source]: https://github.com/cryptography-camp/workbook
[Eclair v0.13.0]: https://github.com/ACINQ/eclair/releases/tag/v0.13.0
