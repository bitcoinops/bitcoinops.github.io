---
title: 'Bitcoin Optech Newsletter #318'
permalink: /zh/newsletters/2024/08/30/
name: 2024-08-30-newsletter-zh
slug: 2024-08-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报宣布了一个讨论比特币挖矿的新邮件列表。此外，还包括我们常规的栏目，总结了来自 Bitcoin Stack Exchange 的热门问题和答案，新版本和候选版本的公告，以及对流行比特币基础设施软件的最近更改的描述。

## 新闻

- **<!--new-bitcoin-mining-development-mailing-list-->新比特币挖矿开发邮件列表：** Jay Beddict [宣布][beddict mining-dev]了一个新的邮件列表，用于“讨论新兴的比特币挖矿技术更新，以及比特币相关软件或协议变化对挖矿的影响。”

    Mark “Murch” Erhardt 在邮件列表中[发布][erhardt warp]询问，已在[testnet4][topic testnet]中部署的[时间扭曲攻击][topic time warp]修复程序，是否会在主网上部署时（例如作为[共识清理软分叉][topic consensus cleanup]的一部分）导致矿工创建无效区块。Mike Schmidt [提到][schmidt oblivious]读者可以参考比特币开发邮件列表中的一个关于[不经意份额][topic block withholding]的[讨论线程][towns oblivious]（参见[周报 #315][news315 oblivious]）。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找疑惑解答的首选之地 —— 也是他们有闲暇时会帮助好奇和困惑用户的地方。在这个月度栏目中，我们会举出自上次出刊以来出现的一些高票的问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--can-a-bip152-compact-block-be-sent-before-validation-by-a-node-that-doesn-t-know-all-transactions-->BIP152 致密区块是否可以在节点验证前发送？]({{bse}}123858)
  Antoine Poinsot 指出，在验证被区块头所承诺的所有交易之前就转发[致密区块][topic compact block relay]，是拒绝服务中的一种攻击向量。

- [<!--did-segwit-bip141-eliminate-all-txid-malleability-issues-listed-in-bip62-->Segwit（BIP141）是否消除了 BIP62 中列出的所有 txid 熔融性问题？]({{bse}}124074)
  Vojtěch Strnad 解释了 txid 如何被篡改，Segwit 如何解决熔融性问题，什么是无意的熔融性，以及与策略相关的一个拉取请求。

- [<!--why-are-the-checkpoints-still-in-the-codebase-in-2024-->为什么 2024 年代码库中仍然有检查点？]({{bse}}123768)
  Lightlike 指出，随着[“区块头预同步”][news216 headers presync]的加入，Bitcoin Core 代码库没有 _已知_ 的检查点需求，但他强调检查点可能正在防御着某些 _未知_ 的攻击向量。

- [<!--bulletproof-as-generic-zkp-ala-snarks-->Bulletproof++ 作为类似 SNARK 的通用 ZKP？]({{bse}}119556)
  Liam Eagen 详细描述了当前使用的简洁非交互知识证明（SNARKs）类型，以及 Bulletproofs、[BitVM][topic acc] 和 [OP_CAT][topic op_cat] 如何在比特币脚本中验证这些证明。

- [<!--how-can-op-cat-be-used-to-implement-additional-covenants-->OP_CAT 如何用于实现额外的限制条款功能？]({{bse}}123829)
  Brandon - Rearden 描述了提议的 OP_CAT 操作码如何为比特币脚本提供[限制条款][topic covenants]功能。

- [<!--why-do-some-bech32-bitcoin-addresses-contain-a-large-number-of-q-->为什么有些 Bech32 比特币地址包含大量的 ‘q’？]({{bse}}123902)
  Vojtěch Strnad 揭示了 OLGA 协议如何将任意数据编码到 P2WSH 输出中，该方案中需要用到 0 来填充（0 在[bech32][topic bech32] 中编码为 ‘q’）。

- [<!--how-does-a-0-conf-signature-bond-work-->0-conf 签名债券是如何工作的？]({{bse}}124022)
  Matt Black 概述了如何将资金锁定在基于 OP_CAT 的限制条款中，以激励花费者不通过[RBF][topic rbf]增加他们的交易费用，从而可能增加零确认交易的接受度。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Core Lightning 24.08rc2][] 是此流行闪电网络（LN）节点实现的下一个主要版本的候选版本。

- [LND v0.18.3-beta.rc1][] 是此流行 LN 节点实现的小修补版本的候选版本。

- [BDK 1.0.0-beta.2][] 是此库的候选版本，用于构建钱包和其他比特币应用程序。原始的 `bdk` Rust 包已重命名为 `bdk_wallet`，并将底层模块提取到各自的包中，包括 `bdk_chain`、`bdk_electrum`、`bdk_esplora` 和 `bdk_bitcoind_rpc`。`bdk_wallet` 包“是第一个提供稳定 1.0.0 API 的版本。”

- [Bitcoin Core 28.0rc1][] 是此主流全节点实现的下一个主要版本的候选版本。[测试指南][bcc testing]正在准备中。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [LDK #3263][] 通过从 `ResponseInstruction` 结构体中删除消息类型参数，并基于更新后的 `ResponseInstruction` 引入一个新的枚举类型的 `MessageSendInstructions`，简化了 [洋葱消息][topic onion messages] 响应的处理。该枚举变量可以处理[盲化路由][topic rv routing]和非盲化路由的回复路径。`send_onion_message` 方法现在使用 `MessageSendInstructions`，允许用户直接指定回复路径。一个新的选项 `MessageSendInstructions::ForReply` 允许消息处理程序稍后发送回复，而不会在代码中创建循环依赖。参见周报 [#303][news303 onion]。

- [LDK #3247][] 废弃了 `AvailableBalances::balance_msat` 方法，转而使用 `ChannelMonitor::get_claimable_balances` 方法，这提供了获取通道余额的更直接和准确的方法。已弃用的方法逻辑现已过时，因为它最初设计用于处理余额包含挂起 HTLC（这些 HTLC 可能会在以后被逆转）时的潜在下溢问题。

- [BDK #1569][] 添加了 `bdk_core` 包，并将 `bdk_chain` 中的一些类型迁移到该包中：`BlockId`、`ConfirmationBlockTime`、`CheckPoint`、`CheckPointIter`、`tx_graph::Update` 和 `spk_client`。`bdk_esplora`、`bdk_electrum` 和 `bdk_bitcoind_rpc` 链源已更改为仅依赖于 `bdk_core`。这些更改旨在加快 `bdk_chain` 的重构速度。


{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3247,1569" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[news315 oblivious]: /zh/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[beddict mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/97fkfVmHWYU
[erhardt warp]: https://groups.google.com/g/bitcoinminingdev/c/jjkbeODskIk
[schmidt oblivious]: https://groups.google.com/g/bitcoinminingdev/c/npitVsP9KNo
[towns oblivious]: https://groups.google.com/g/bitcoindev/c/1tDke1a2e_Q
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 headers presync]: /zh/newsletters/2022/09/07/#bitcoin-core-25717
[news303 onion]: /zh/newsletters/2024/05/17/#ldk-2907