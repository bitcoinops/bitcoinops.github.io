---
title: 'Bitcoin Optech Newsletter #398'
permalink: /zh/newsletters/2026/03/27/
name: 2026-03-27-newsletter-zh
slug: 2026-03-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括我们的常规栏目：来自 Bitcoin Stack Exchange 的精选问答、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

*本周未在我们的任何[来源][sources]中发现重大新闻。*

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者查找问题答案的首选之地——也是我们在闲暇时帮助好奇或困惑用户的地方。在这个月度专题中，我们重点介绍自上次更新以来投票最高的部分问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- ["比特币不使用加密"是什么意思？]({{bse}}130576) Pieter Wuille 区分了用于对未授权方隐藏数据的加密（比特币的 ECDSA 不能用于此目的）和比特币用于验证和认证的数字签名。

- [比特币脚本何时以及为何转向了承诺-揭示结构？]({{bse}}130580) 用户 bca-0353f40e 解释了从比特币最初的用户直接向公钥支付的方式，到 P2PKH、再到 P2SH、[隔离见证][topic segwit]和 [taproot][topic taproot] 方式的演变过程，其中花费条件在输出中被承诺，仅在花费时才揭示。

- [P2TR-MS（Taproot M-of-N 多重签名）是否会泄露公钥？]({{bse}}130574) Murch 确认，单叶 taproot 脚本路径多重签名在花费时会暴露所有合格的公钥，因为 OP_CHECKSIG 和 OP_CHECKSIGADD 都要求与签名对应的公钥必须存在。

- [OP_CHECKSIGFROMSTACK 是否有意允许跨 UTXO 签名重用？]({{bse}}130598) 用户 bca-0353f40e 解释说 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（[BIP348][]）故意不将签名绑定到特定输入，这允许 CSFS 与其他[限制条款][topic covenants]操作码结合使用，以启用可重新绑定的签名——这是 [LN-Symmetry][topic eltoo] 的底层机制。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 28.4][] 是主流全节点实现前一个主要版本系列的维护版本。主要包含钱包迁移修复和移除一个不可靠的 DNS 种子。详情见[发行说明][bcc 28.4 rn]。

- [Core Lightning 26.04rc1][] 是这个流行闪电网络节点下一个主要版本的候选发布，包含许多拼接更新和 bug 修复。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #33259][] 为使用 [assumeUTXO][topic assumeutxo] 快照的节点在 `getblockchaininfo` RPC 响应中添加了一个 `backgroundvalidation` 字段。该新字段报告快照高度、后台验证的当前区块高度和哈希、中位时间、链上工作量以及验证进度。此前，`getblockchaininfo` 的响应只是简单地表明验证和 IBD 已完成，没有提供后台验证的任何信息。

- [Bitcoin Core #33414][] 在连接的 Tor 守护进程支持的情况下，为自动创建的洋葱服务启用了 Tor [工作量证明防御][tor pow]。当 Tor 守护进程具有可访问的控制端口且 Bitcoin Core 的 `listenonion` 设置为开启状态（默认）时，它会自动创建隐藏服务。这不适用于手动创建的洋葱服务，但建议用户添加 `HiddenServicePoWDefensesEnabled 1` 以启用工作量证明防御。

- [Bitcoin Core #34846][] 向 `libbitcoinkernel` C API（见[周报 #380][news380 kernel]）添加了 `btck_transaction_get_locktime` 和 `btck_transaction_input_get_sequence` 函数，用于访问[时间锁][topic timelocks]字段：交易的 `nLockTime` 和输入的 `nSequence`。这允许在不手动反序列化交易的情况下检查 [BIP54][]（[共识清理][topic consensus cleanup]）规则（如 coinbase `nLockTime` 约束），而其他 BIP54 规则（如 sigop 限制）仍需单独处理。

- [Core Lightning #8450][] 扩展了 CLN 的[拼接][topic splicing]脚本引擎，以处理跨通道拼接、多通道拼接（超过三个）和动态手续费计算。这解决的一个关键问题是手续费估算中的循环依赖：添加钱包输入会增加交易权重从而增加所需手续费，这又可能需要额外的输入。该基础设施支撑着新的 `splicein` 和 `spliceout` RPC。

- [Core Lightning #8856][] 和 [#8857][core lightning #8857] 添加了 `splicein` 和 `spliceout` RPC 命令，分别用于将内部钱包的资金添加到通道中、以及将通道资金取出到内部钱包、比特币地址或另一个通道（实际上是跨拼接）。新命令使运营者无需再使用实验性的 `dev-splice` RPC 手动构建[拼接][topic splicing]交易。

- [Eclair #3247][] 添加了一个可选的对等节点评分系统，跟踪每个对等节点的转发收入和支付量随时间的变化。启用后，它会定期按盈利能力对对等节点排名，并可选择自动为高收益对等节点注资通道、自动关闭低产通道以回收流动性、以及根据交易量自动调整中继手续费，所有操作都在可配置的范围内进行。运营者可以先仅启用可见性功能，再逐步选择启用自动化。

- [LDK #4472][] 修复了通道注资和[拼接][topic splicing]过程中一个潜在的资金损失场景，此前 `tx_signatures` 可能在对方的承诺签名被持久存储之前就被发送。如果交易确认后节点崩溃，它将失去强制执行通道状态的能力。修复方案是延迟释放 `tx_signatures`，直到相应的监视器更新完成。

- [LND #10602][] 向实验性的 `switchrpc` 子系统（见[周报 #386][news386 sendonion]）添加了一个 `DeleteAttempts` RPC，允许外部控制器从 LND 的尝试存储中显式删除已完成（成功或失败，非待处理）的 [HTLC][topic htlc] 尝试记录。

- [LND #10481][] 向 LND 的集成测试框架添加了 `bitcoind` 矿工后端。此前，即使使用 `bitcoind` 作为链后端，`lntest` 也假定使用基于 `btcd` 的矿工。此变更允许测试执行依赖于 Bitcoin Core 交易池和挖矿策略的行为，包括 [v3 交易中继][topic v3 transaction relay]和[交易包中继][topic package relay]。

- [BOLTs #1160][] 将[拼接][topic splicing]协议合并到闪电网络规范中，用更新的流程和边缘情况的测试向量替换了 [BOLTs #863][] 中的草案（该草案的讨论见[周报 #246][news246 splicing draft]）。拼接允许对等节点在不关闭通道的情况下添加或移除资金；协商从通道静默（quiescence）状态开始（[BOLTs #869][]，[周报 #309][news309 quiescence]）。合并的 BOLT2 文本涵盖了拼接交易的交互式构建、在拼接未确认时继续操作通道、待处理拼接的 [RBF][topic rbf]、重连行为、达到足够深度后的 `splice_locked`，以及更新的[通道公告][topic channel announcements]。

{% include snippets/recap-ad.md when="2026-03-31 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33259,33414,34846,8450,8856,8857,3247,4472,10602,10481,1160,863,869" %}
[sources]: /en/internal/sources/
[Bitcoin Core 28.4]: https://bitcoincore.org/en/2026/03/18/release-28.4/
[bcc 28.4 rn]: https://bitcoincore.org/en/releases/28.4/
[Core Lightning 26.04rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc1
[tor pow]: https://tpo.pages.torproject.net/onion-services/ecosystem/technology/security/pow/
[news380 kernel]: /zh/newsletters/2025/11/14/#bitcoin-core-30595
[news386 sendonion]: /zh/newsletters/2026/01/02/#lnd-9489
[news246 splicing draft]: /zh/newsletters/2023/04/12/#splicing-specification-discussions
[news309 quiescence]: /zh/newsletters/2024/06/28/#bolts-869
