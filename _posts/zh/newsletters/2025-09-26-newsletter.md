---
title: 'Bitcoin Optech Newsletter #373'
permalink: /zh/newsletters/2025/09/26/
name: 2025-09-26-newsletter-zh
slug: 2025-09-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了一个影响 Eclair 旧版本的漏洞，以及对全节点手续费设置的研究。此外是我们的常规栏目：Bitcoin Stack Exchange 的热门问答总结、新版本和候选版本的发行通告，以及热门的比特币基础设施软件的显著变更描述。

## 新闻

- **<!--eclair-vulnerability-->****Eclair 漏洞：**Matt Morehouse 在 Delving Bitcoin 论坛[发帖][morehouse eclair]宣布[负责任地披露][topic responsible disclosures]了一个影响 Eclair 旧版本的漏洞。建议所有 Eclair 用户升级到 0.12 或更高版本。该漏洞允许攻击者广播一个旧的承诺交易来窃取通道中的所有当前资金。除了修复该漏洞，Eclair 开发者还添加了一个全面的测试套件，旨在捕获类似问题。

- **<!--research-into-feerate-settings-->****手续费设置研究：**Daniela Brozzoni 在 Delving Bitcoin 论坛[发布][brozzoni feefilter]了对近 30,000 个接受传入连接的全节点的扫描结果。每个节点都被查询其 [BIP133][] 手续费过滤器。该过滤器会表明这个节点当前接受中继未确认交易的最低手续费率。当节点交易池未满时，这是该节点的[默认最小交易中继手续费率][topic default minimum transaction relay feerates]。结果表明，大多数节点使用默认的 1 聪/虚拟字节 (s/v)，长期以来这一直是 Bitcoin Core 的默认值。约 4% 的节点使用 0.1 s/v，这是即将发布的 Bitcoin Core 30.0 版本的默认值。约 8% 的节点没有响应查询——表明它们可能是间谍节点。

  少部分节点使用的手续费过滤器值为 9,170,997（10,000 s/v），开发者 0xB10C [指出][0xb10c feefilter]这是当节点比区块链最前端落后超过 100 个区块且专注于接收区块数据而非可能在后续区块中才确认的交易时，Bitcoin Core 通过四舍五入设置的值。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地之一——或者当我们有一些空闲时间来帮助好奇或困惑的用户时。在这个月度栏目中，我们重点介绍自上次更新以来发布的一些获得最多投票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--implications-of-op-return-changes-in-upcoming-bitcoin-core-version-30-0-->即将发布的 Bitcoin Core 30.0 版本中 OP_RETURN 变更的影响？]({{bse}}127895)
  Pieter Wuille 描述了他对使用[交易池和中继策略][policy series]来影响挖出区块内容的有效性和缺点的看法。

- [<!--if-op-return-relay-limits-are-ineffective-why-remove-the-safeguard-instead-of-keeping-it-as-a-default-discouragement-->如果 OP_RETURN 中继限制无效，为什么要移除这个安全措施而不是将其作为默认的阻止措施保留？]({{bse}}127904)
  Antoine Poinsot 解释了 Bitcoin Core 中当前 OP_RETURN 默认限制值造成的不良激励，以及移除它的理由。

- [<!--what-are-the-worst-case-stress-scenarios-from-uncapped-op-returns-in-bitcoin-core-v30-->Bitcoin Core v30 中取消 OP_RETURN 上限的最坏情况压力场景是什么？]({{bse}}127914)
  Vojtěch Strnad 和 Pieter Wuille 回应了一系列可能因 OP_RETURN 限制策略默认设置改变而发生的极端场景。

- [<!--if-op-return-needed-more-room-why-was-the-80-byte-cap-removed-instead-of-being-raised-to-160-->如果 OP_RETURN 需要更多空间，为什么移除 80 字节上限而不是将其提高到 160？]({{bse}}127915)
  Ava Chow 和 Antoine Poinsot 概述了反对 160 字节默认 OP_RETURN 值的考虑，包括对持续设置上限的厌恶、现有大型矿工已经绕过上限，以及无法预测未来链上活动的风险。

- [<!--if-arbitrary-data-is-inevitable-does-removing-op-return-limits-shift-demand-toward-more-harmful-storage-methods-like-utxo-inflating-addresses-->如果任意数据不可避免，移除 OP_RETURN 限制是否会将需求转向更有害的存储方法（如导致 UTXO 膨胀的地址）？]({{bse}}127916)
  Ava Chow 指出，在某些情况下，取消 OP_RETURN 限制为输出数据存储使用危害较小的替代方案提供了激励。

- [<!--if-op-return-uncapping-doesn-t-increase-the-utxo-set-how-does-it-still-contribute-to-blockchain-bloat-and-centralization-pressure-->如果取消 OP_RETURN 上限不会增加 UTXO 集，它如何仍然导致区块链膨胀和中心化压力？]({{bse}}127912)
  Ava Chow 解释了增加使用 OP_RETURN 输出如何影响比特币节点的资源利用率。

- [<!--how-does-uncapping-op-return-impact-long-term-fee-market-quality-and-security-budget-->取消 OP_RETURN 上限如何影响长期手续费市场质量和安全预算？]({{bse}}127906)
  Ava Chow 回答了一系列关于假设的 OP_RETURN 使用及其对未来比特币挖矿收入影响的问题。

- [<!--assurance-blockchain-will-not-suffer-from-illegal-content-with-100kb-op-return-->能保证区块链不会因 100KB OP_RETURN 而遭受非法内容之害吗？]({{bse}}127958)
  用户 jb55 提供了几个潜在数据编码方案的例子，得出结论：“所以不，一般来说，你无法在一个抗审查的去中心化网络中真正阻止这些事情。”

- [<!--what-analysis-shows-op-return-uncapping-won-t-harm-block-propagation-or-orphan-risk-->什么分析表明取消 OP_RETURN 上限不会损害区块传播或孤块风险？]({{bse}}127905)
  Ava Chow 指出，虽然没有专门分离大型 OP_RETURN 的数据集，但之前对[致密区块][topic compact block relay]和废弃区块的分析表明，目前没有理由期望它们会有不同的行为。

- [<!--where-does-bitcoin-core-keep-the-xor-obfuscation-keys-for-both-block-data-files-and-level-db-indexes-->Bitcoin Core 将区块数据文件和 level DB 索引的 XOR 混淆密钥存储在哪里？]({{bse}}127927)
  Vojtěch Strnad 指出，chainstate 密钥存储在 LevelDB 的 "\000obfuscate_key" 键下，区块和撤销数据密钥存储在 blocks/xor.dat 文件中。

- [<!--how-robust-is-1p1c-transaction-relay-in-bitcoin-core-28-0-->bitcoin core 28.0 中的 1p1c 交易中继有多健壮？]({{bse}}127873)
  Glozow 澄清，最初的机会性[一父一子（1P1C）中继][28.0 1p1c]拉取请求中提到的非健壮性意味着“不保证能起作用，特别是在存在对手或交易量非常高以至于我们会有遗漏时。”

- [<!--how-can-i-allow-getblocktemplate-to-include-sub-1-sat-vbyte-transactions-->如何允许 getblocktemplate 包含低于 1 聪/虚拟字节的交易？]({{bse}}127881)
  用户 inersha 发现了中继低于 1 聪/虚拟字节的交易还将它们包含在候选区块模板中所需要的设置。

## 发行和候选发行

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Bitcoin Core 30.0rc1][] 是这个全验证节点软件下一个主要版本的候选发行。请参阅[版本 30 候选发行测试指南][bcc30 testing]。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33333][] 如果节点的 `dbcache` 设置超过从节点系统 RAM 推导出的上限，会发出启动警告消息，以防止内存不足错误或大量内存交换。对于 RAM 少于 2GB 的系统，`dbcache` 警告阈值为 450MB；否则，阈值为总 RAM 的 75%。`dbcache` 16GB 限制已在 2024 年 9 月移除（参见周报 [#321][news321 dbcache]）。

- [Bitcoin Core #28592][] 由于网络上较小交易的增加，将入站对等节点的每个对等节点交易中继速率从 7 增加到 14。出站对等节点的速率高 2.5 倍，增加到每秒 35 个交易。交易中继速率限制了节点向其对等节点发送的交易数量。

- [Eclair #3171][] 移除了 `PaymentWeightRatios`。这是一种假设通道余额均匀性的路径查找方法，被替换为一个新引入的基于过去支付尝试历史的概率方法（参见周报 [#371][news371 path]）。

- [Eclair #3175][] 开始拒绝无法支付的 [BOLT12][] [要约][topic offers]，其中字段 `offer_chains`、`offer_paths`、`invoice_paths` 和 `invoice_blindedpay` 存在但为空。

- [LDK #4064][] 更新其签名验证逻辑，以确保如果 `n` 字段（收款方的公钥）存在，则对其验证签名。否则，收款方的公钥从 [BOLT11][] 发票中提取，使用高 S 或低 S 签名。此 PR 使签名检查与提议的 [BOLTs #1284][] 以及 Eclair 等其他实现保持一致（参见周报 [#371][news371 pubkey]）。

- [LDK #4067][] 添加了对从[零手续费承诺][topic v3 commitments]交易中花费 [P2A 临时锚点][topic ephemeral anchors]输出的支持，确保通道对等节点可以在链上索回他们的资金。参见周报 [#371][news371 p2a] 了解 LDK 的零手续费承诺通道实现。

- [LDK #4046][] 使经常离线的发送方能够向经常离线的接收方发送[异步支付][topic async payments]。发送方在 `update_add_htlc` 消息中设置一个标志，指示 [HTLC][topic htlc] 应该由 LSP 持有，直到接收方重新上线并发送 `release_held_htlc` [洋葱消息][topic onion messages]来索取这笔付款。

- [LDK #4083][] 弃用 `pay_for_offer_from_human_readable_name` 端点以移除重复的 [BIP353][] HRN 支付 API。鼓励钱包使用 `bitcoin-payment-instructions` crate 来解析和解决支付指令，然后调用 `pay_for_offer_from_hrn` 从 [BIP353][] HRN（例如 satoshi@nakamoto.com）支付[要约][topic offers]。

- [LND #10189][] 更新其 `sweeper` 系统（参见周报 [#346][news346 sweeper]）以正确识别 `ErrMinRelayFeeNotMet` 错误代码，并通过[手续费替换][topic rbf]重试失败的交易，直到广播成功。以前，错误会被错误匹配，交易不会被重试。此 PR 还通过考虑可能的额外找零输出来改进权重估计，这在用于增强 LND 的 [Taproot Assets][topic client-side validation] 的 [taproot][topic taproot] 覆盖通道中是相关的。

- [BIPs #1963][] 将指定[致密区块过滤器][topic compact block filters]的 BIP，即 [BIP157][] 和 [BIP158][]，的状态从 `Draft` 更新为 `Final`，因为它们自 2020 年以来已在 Bitcoin Core 和其他软件中部署。

{% include snippets/recap-ad.md when="2025-09-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33333,28592,3171,3175,4064,4067,4046,4083,10189,1963,1284" %}
[morehouse eclair]: https://delvingbitcoin.org/t/disclosure-eclair-preimage-extraction-exploit/2010
[brozzoni feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989
[0xb10c feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989/3
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[news321 dbcache]: /zh/newsletters/2024/09/20/#bitcoin-core-28358
[news371 path]: /zh/newsletters/2025/09/12/#eclair-2308
[news371 pubkey]: /zh/newsletters/2025/09/12/#eclair-3163
[news371 p2a]: /zh/newsletters/2025/09/12/#ldk-4053
[news346 sweeper]: /zh/newsletters/2025/03/21/#discussion-of-lnd-s-dynamic-feerate-adjustment-system-lnd
[policy series]: /zh/blog/waiting-for-confirmation/
[28.0 1p1c]: /zh/bitcoin-core-28-wallet-integration-guide/#一父一子交易1p1c中继
