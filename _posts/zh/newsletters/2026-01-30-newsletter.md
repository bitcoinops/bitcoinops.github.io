---
title: 'Bitcoin Optech Newsletter #390'
permalink: /zh/newsletters/2026/01/30/
name: 2026-01-30-newsletter-zh
slug: 2026-01-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一种更高效的混淆电路方案，并链接了 LN-Symmetry 的更新。此外还包括来自 Bitcoin Stack Exchange 的精选问答，新软件发布和候选版本的公告，以及流行比特币基础设施软件的重大变更摘要。

## 新闻

- **<!--argo-a-garbled-circuits-scheme-with-more-efficient-off-chain-computation-->Argo：一种更高效的链下计算混淆电路方案**：
  Robin Linus 在 Delving Bitcoin 上[发布][delving rl garbled]了一篇由 Liam Eagen 和 Ying Tong Lai 撰写的[新论文][iacr le ytl garbled]，描述了一种能够使[混淆锁（garbled locks）][news359 rl garbled]效率提高 1000 倍的技术。这项新技术使用一种消息认证码（MAC），将混淆电路的线路编码为椭圆曲线（EC）点。该 MAC 设计为同态的，使得混淆电路中的许多操作可以直接表示为 EC 点上的操作。关键的改进在于 Argo 适用于_算术_电路，而不是二进制电路。对于二进制电路，需要数百万个二进制门来表示一个曲线点乘法，而对于这种算术电路，只需要一个算术门。目前的论文是将该技术应用于比特币上类似 [BitVM][topic acc] 结构的几部分工作中的第一部分。

- **<!--ln-symmetry-update-->LN-Symmetry 更新**：Gregory Sanders 在 Delving Bitcoin 上[发布][symmetry update]了关于他之前在 [LN-Symmetry][topic eltoo] 上的工作的更新（见[周报 #284][news284 ln sym]）。

  Sanders 将他之前的概念验证工作基于[BOLT 规范][bolts fork]和 [CLN 实现][cln fork]重新变基（rebase）到了最新更新。更新后的实现现在可以在 [signet][topic signet] 上的 [Bitcoin Inquisition][bitcoin inquisition repo] 29.x 上运行，支持 [TRUC][topic v3 transaction relay]、[临时锚点（ephemeral dust/P2A）][topic ephemeral anchors]和 1p1c [包中继][topic package relay]。它支持协作关闭通道，修复了一个导致节点无法正确重启的崩溃问题，并扩展了测试覆盖率。Sanders 邀请其他开发者在 signet 上使用 Bitcoin Inquisition 测试他的新概念验证。

  Sanders 还利用大型语言模型（LLM）的能力将他的工作从 APO 迁移到了 OP_TEMPLATEHASH+OP_CSFS+IK（见[周报 #365][news365 op proposal]），修改了 [BOLT 草案][bolt th]并创建了一个[基于 CLN 的实现][cln th]。然而，Sanders 补充说，由于 OP_TEMPLATEHASH 尚未在 Bitcoin Inquisition 上线，此更新目前只能在 regtest 中测试。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之地，或者当我们有空闲时间时，通过它帮助好奇或困惑的用户。在这个月度栏目中，我们精选了自上次更新以来得票最高的一些问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [dbcache 中存储了什么，优先级如何？]({{bse}}130376)
  Murch 描述了 `dbcache` 数据结构的用途是作为整个 UTXO 集子集的内存缓存，并详细说明了其行为。

- [可以在 Shielded CSV 中进行 coinjoin 吗？]({{bse}}130364)
  Jonas Nick 指出 Shielded CSV 协议目前不支持 [coinjoins][topic coinjoin]，但[客户端验证][topic client-side validation]协议本身并不排除这种功能。

- [在 Bitcoin Core 中，如何仅使用 Tor 广播新交易？]({{bse}}99442)
  Vasil Dimov 对这个较旧的问题进行了跟进，指出通过新的 `privatebroadcast` 选项（见[周报 #388][news388 private broadcast]），Bitcoin Core 可以通过短期的[隐私网络][topic anonymity networks]连接广播交易。

- [Brassard-Høyer-Tapp (BHT) 算法和比特币 (BIP360)]({{bse}}130431)
  用户 bca-0353f40e 解释说，使用 Brassard-Høyer-Tapp (BHT) [量子][topic quantum resistance]算法对[多重签名][topic multisignature]地址进行碰撞攻击以削弱 SHA256 安全性的能力，不会影响在该能力出现之前创建的地址。

- [为什么 BitHash 交替使用 sha256 和 ripmed160？]({{bse}}130373)
  Sjors Provoost 概述了 [BitVM3][topic acc] 的 BitHash 函数（一种为比特币脚本语言量身定制的哈希函数）背后的原理。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Libsecp256k1 0.7.1][] 是该比特币相关密码学操作库的维护版本，其中包括一项安全性改进，增加了库尝试从堆栈中清除秘密的情况数量。它还引入了一个新的单元测试框架和一些构建系统更改。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #33822][] 向 `libbitcoinkernel` API 接口添加了区块头支持（见[周报 #380][news380 kernel]）。新的 `btck_BlockHeader` 类型及其相关方法支持创建、复制和销毁区块头，以及获取区块头字段，如哈希、前一个哈希、时间戳、难度目标、版本和随机数。新的 `btck_chainstate_manager_process_block_header()` 方法在不需要完整区块的情况下验证和处理区块头，`btck_chainstate_manager_get_best_entry()` 返回具有最大累积工作量证明的区块树条目。

- [Bitcoin Core #34269][] 禁止在使用 `createwallet` 和 `restorewallet` RPC 以及钱包工具的 `create` 和 `createfromdump` 命令时创建或恢复未命名钱包（见周报 [#45][news45 wallettool] 和 [#130][news130 wallettool]）。虽然 GUI 已经强制执行了此限制，但 RPC 和底层函数此前并未执行。钱包迁移仍然可以恢复未命名钱包。关于未命名钱包的相关 bug，请参见[周报 #387][news387 unnamed]。

- [Core Lightning #8850][] 移除了几个已弃用的功能：`option_anchors_zero_fee_htlc_tx`，重命名为 `option_anchors` 以反映[锚点输出][topic anchor outputs]的变更；`decodepay` RPC（由 `decode` 取代）；`close` 命令响应中的 `tx` 和 `txid` 字段（由 `txs` 和 `txids` 取代）；以及 `estimatefeesv1`，即 `bcli` 插件用于返回[费用估算][topic fee estimation]的原始响应格式。

- [LDK #4349][] 在解析 [BOLT12 offers][topic offers] 时添加了对 [bech32][topic bech32] 填充的验证，如 [BIP173][] 所述。以前，LDK 会接受填充无效的 offers，而其他实现（如 Lightning-KMP 和 Eclair）会正确拒绝它们。`Bolt12ParseError` 枚举中添加了一个新的 `InvalidPadding` 错误变体。

- [Rust Bitcoin #5470][] 向解码器添加了验证，以拒绝零输出的交易，因为有效的比特币交易必须至少有一个输出。

- [Rust Bitcoin #5443][] 向解码器添加了验证，以拒绝输出值总和超过 `MAX_MONEY`（2100 万比特币）的交易。此检查与 [CVE-2010-5139][topic cves] 相关，这是一个历史漏洞，攻击者可以创建具有极大输出值的交易。

- [BDK #2037][] 添加了 `median_time_past()` 方法，用于计算 `CheckPoint` 结构的过去中位时间 (MTP)。MTP 在 [BIP113][] 中定义，是前 11 个区块的时间戳中位数，用于验证[时间锁][topic timelocks]。关于启用此功能的先前工作，请参见[周报 #372][news372 mtp]。

- [BIPs #2076][] 添加了 [BIP434][]，定义了一种 P2P 特性消息，允许对等节点宣布和协商对新特性的支持。这个想法概括了 [BIP339][] 的机制（见[周报 #87][news87 negotiation]），但 [BIP434][] 不再需要为每个特性提供新的消息类型，而是提供一种单一的、可重用的消息，用于宣布和协商多个 P2P 升级。这有利于各种提议的 P2P 用例，包括[模板共享][news366 template]。有关邮件列表讨论，请参见[周报 #386][news386 feature]。

- [BIPs #1500][] 添加了 [BIP346][]，定义了用于 [tapscript][topic tapscript] 的 `OP_TXHASH` 操作码，该操作码将指定部分的支出交易的哈希摘要推送到堆栈上。这可用于创建[契约][topic covenants]并减少多方协议中的交互性。该操作码概括了 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]，当与 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 结合使用时，可以模拟 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]。有关先前的讨论，请参见周报 [#185][news185 txhash] 和 [#272][news272 txhash]。

{% include snippets/recap-ad.md when="2026-02-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33822,34269,8850,4349,5470,5443,2037,2076,1500" %}
[news359 rl garbled]: /zh/newsletters/2025/06/20/#improvements-to-bitvmstyle-contracts
[news369 le garbled]: /zh/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[delving rl garbled]: https://delvingbitcoin.org/t/argo-a-garbled-circuits-scheme-for-1000x-more-efficient-off-chain-computation/2210
[iacr le ytl garbled]: https://eprint.iacr.org/2026/049.pdf
[symmetry update]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359/17
[news284 ln sym]: /zh/newsletters/2024/01/10/#ln-symmetry-research-implementation-ln-symmetry
[bolts fork]: https://github.com/instagibbs/bolts/tree/eltoo_trucd
[cln fork]: https://github.com/instagibbs/lightning/tree/2026-01-eltoo_rebased
[news365 op proposal]: /zh/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[news388 private broadcast]: /zh/newsletters/2026/01/16/#bitcoin-core-29415
[bolt th]: https://github.com/instagibbs/bolts/tree/2026-01-eltoo_th
[cln th]: https://github.com/instagibbs/lightning/commits/2026-01-eltoo_templatehash
[Libsecp256k1 0.7.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.1
[news380 kernel]: /zh/newsletters/2025/11/14/#bitcoin-core-30595
[news45 wallettool]: /zh/newsletters/2019/05/07/#new-wallet-tool
[news130 wallettool]: /zh/newsletters/2021/01/06/#bitcoin-core-19137-adds-dump-and-createfromdump-commands-to-wallet-tool
[news387 unnamed]: /zh/newsletters/2026/01/09/#bitcoin-core-wallet-migration-bug
[news372 mtp]: /zh/newsletters/2025/09/19/#bdk-1582
[news87 negotiation]: /zh/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[news386 feature]: /zh/newsletters/2026/01/02/#peer-feature-negotiation
[news366 template]: /zh/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[news185 txhash]: /zh/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news272 txhash]: /zh/newsletters/2023/10/11/#op-txhash
