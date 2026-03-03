---
title: 'Bitcoin Optech Newsletter #383'
permalink: /zh/newsletters/2025/12/05/
name: 2025-12-05-newsletter-zh
slug: 2025-12-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一个已修复、影响 NBitcoin 库的漏洞。此外，还包含我们惯例的几个部分：总结关于改变比特币共识规则 (consensus rules) 的讨论，公布新的发行版本与候选版本，以及说明流行比特币基础设施软件的重要变更。

## 新闻

- **<!--consensus-bug-in-NBitcoin-library-->****NBitcoin 库中的共识漏洞**: BrunoGarcia 在 Delving Bitcoin 上[发帖][bruno delving]，讨论了 NBitcoin 中在使用 `OP_NIP` 时，一个理论上的共识失败情形。当底层数组已满且调用 `_stack.Remove(-2)` 时，Remove 操作会删除索引为 14 的元素，然后尝试将其后续元素整体下移。在这个下移过程中，NBitcoin的实现可能会尝试访问并不存在的 `_array[16]`，从而引发异常。

  该漏洞是通过[差分模糊测试][diff fuzz]发现的，由于失败被一个 try/catch 块捕获，如果只使用传统的模糊测试技术，可能永远不会被发现。发现问题后，Bruno Garcia 于 2025 年 10 月 23 日向 Nicolas Dorier 报告。同一天，Nicolas Dorier 确认了问题并提交了一个用于修复的 [补丁][nbitcoin patch]。目前尚无已知的使用NBitcoin 的全节点实现，因此不存在链分叉风险，这也是为何可以较快披露这一问题的原因。

## 共识变更

*一个月度更新的栏目，总结关于变更比特币共识规则的提议和讨论。*

- **<!--lnhance-soft-fork-->****LNHANCE 软分叉**：Moonsettler [提议][ms ml lnhance] 为 LNHANCE 进行一次软分叉，其中包换的四个操作码目前都已有更新后相应的BIP 和参考实现。[BIP119][]（[OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify]）、[BIP348][]（[OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack]）、[BIP349][]（OP_INTERNALKEY）以及 [BIPs #1699][]（OP_PAIRCOMMIT）为 [tapscript][topic tapscript] 引入了可重新绑定的签名与多重承诺（multi-commitments），并为所有 Script 版本增加了对下一笔交易的承诺。一个类似的，仅限 tapscript 操作码，包含 `OP_TEMPLATEHASH`的[打包提案][gs ml thikcs] [近期被提出][news365 oth]，它具备类似的能力，但不提供通用的多重承诺，并且由于是最近提出，因此还在等待更多反馈和审阅。

- **<!--benchmarking-the-varops-budget-->****对 Varops 预算进行基准测试**：Julian [发帖][j ml varops] 号召大家在 [varops 预算][bip varops] 下对比特币脚本执行进行基准测试。Script Restoration 团队（见[第 374 期周报][news374 gsr]）希望用户在各种不同硬件和操作系统环境上运行他们的[基准测试][j gh bench]并分享结果，以便确认或改进选定的 varops 参数。作为对 Russell O'Connor 的回复，Julian 还澄清，在新的 [tapscript][topic tapscript] 版本中，将使用 varops 预算来替代（而不是叠加）原有的 sigops 预算。

- **<!--lh-dsa-post-quantum-signature-optimizations-->****SLH-DSA（SPHINCS）抗量子签名算法优化**：围绕增强比特币抗[量子计算][topic quantum resistance] 的讨论仍在继续，conduition [展示][c ml sphincs] 了他在优化 SPHINCS 签名算法方面的工作。这些优化需要占用数兆字节的内存以及本地编译的着色器（高度优化、针对特定 CPU 的机器码——要么持久缓存，要么在启动时计算）。在适用的场景下，优化后的 SPHINCS 签名和密钥生成操作要比此前的业界最佳快一个数量级，并且只比椭圆曲线运算慢两个数量级。更重要的是，优化后的签名验证速度大致与椭圆曲线签名验证相当。

## 新版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning v25.12][] 是这个主流的闪电网络实现的一个新版本，引入了 [BIP39][] 助记词种子作为新的默认备份方式，改进了地址路径寻找，增加了实验性的 [JIT 通道][topic jit channels] 支持，以及许多其他新特性和错误修复。由于包含破坏性的数据库变更，该版本还附带了一个降级工具，以防升级过程中出现问题（更多信息见下文）。

- [LDK 0.2][] 是这个用于构建闪电网络应用的依赖库一个重大版本更新，为（实验性的）[拼接][topic splicing]提供了支持，增加了为[异步支付][topic async payments]提供和支付静态发票(invoice)的功能，并支持使用[临时锚点][topic ephemeral anchors] 的[零费用承诺][topic v3 commitments]通道，同时还包含许多其他新特性、错误修复和 API 改进。

## 重大的代码和文档变更

_最近在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 以及 [BINANAs][binana repo] 中的一些值得关注的变更。_

- [Core Lightning #8728][] 修复了一个在用户输入错误passphrase时导致 `hsmd` 崩溃的漏洞；现在它会正确处理这一用户错误场景并干净地退出。

- [Core Lightning #8702][] 新增了一个 `lightningd-downgrade` 工具，在升级出错的情况下，可以将数据库版本从 25.12 降级回之前的 25.09。

- [Core Lightning #8735][] 修复了一个长期存在的漏洞：在重启期间，一些链上花费可能会从 CLN 的视图中消失。启动时，CLN 会回滚最近的 15 个区块（默认值），将这些区块中已花费 UTXO 的花费高度重置为 `null`，然后重新扫描。此前，CLN 未能重新监控这些 UTXO，这可能导致 CLN 继续转发已经关闭通道的[通道公告][topic channel announcements]，或错过重要的链上花费。该 PR 确保在启动过程中重新监控这些 UTXO，并增加了一次性回溯扫描，用于恢复此前因该漏洞而错过的花费。

- [LDK #4226][] 开始对收到的[trampoline][topic trampoline payments] onion 中的金额和 CLTV 字段与外层 onion 进行比对验证。该 PR 还新增了三个本地失败原因：`TemporaryTrampolineFailure`、`TrampolineFeeOrExpiryInsufficient` 和 `UnknownNextTrampoline`，作为支持蹦床支付转发的第一步。

- [LND #10341][] 修复了一个漏洞：每当隐藏服务重启时，同一个 [Tor][topic anonymity networks] onion 地址会在节点公告以及 `getinfo` 输出中被重复列出。该 PR 确保 `createNewHiddenService` 函数不会重复生成地址。

- [BTCPay Server #6986][] 引入了 `Monetization` 功能，允许服务器管理员要求用户登录时必须拥有一个 `Subscription`（参见 [第 379 期周报][news379 btcpay]）。这一功能让“推广大使”（在本地环境中帮助新用户和商家上线的比特币用户）能够将他们的工作实现变现。系统默认提供 7 天免费试用和一个免费入门计划，但订阅本身是可自定义的。现有用户不会被自动加入订阅，但可以在之后进行迁移。

- [BIPs #2015][] 为 [BIP54][]（即[共识清理][topic consensus cleanup]提案）新增了测试向量，为四项缓解措施中的每一项都提供了一组向量。这些向量基于 Bitcoin Inquisition 中的 [BIP54][] 实现以及一个定制的 Bitcoin Core 挖矿单元测试生成，并附带了在实现和评审中如何使用它们的说明。更多背景可参见[第 379 期周报][news379 bip54]。

{% include snippets/recap-ad.md when="2025-12-09 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1699,8728,8702,8735,4226,10341,6986,2015" %}
[ms ml lnhance]: https://groups.google.com/g/bitcoindev/c/AlMqLbmzxNA
[gs ml thikcs]: https://groups.google.com/g/bitcoindev/c/5wLThgegha4/m/iUWIZPIaCAAJ
[j ml varops]: https://groups.google.com/g/bitcoindev/c/epbDDH9MHNw/m/OUrIeSHmAAAJ
[news365 oth]: /zh/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[news374 gsr]: /zh/newsletters/2025/10/03/#draft-bips-for-script-restoration
[bip varops]: https://github.com/rustyrussell/bips/blob/guilt/varops/bip-unknown-varops-budget.mediawiki
[j gh bench]: https://github.com/jmoik/bitcoin/blob/gsr/src/bench/bench_varops.cpp
[c ml sphincs]: https://groups.google.com/g/bitcoindev/c/LAll07BHwjw/m/2k7o2VKwAQAJ
[bruno delving]: https://delvingbitcoin.org/t/consensus-bug-on-nbitcoin-out-of-bound-issue-in-remove/2120
[nbitcoin patch]: https://github.com/MetacoSA/NBitcoin/pull/1288
[diff fuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
[LDK 0.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2
[news379 btcpay]: /zh/newsletters/2025/11/07/#btcpay-server-6922
[news379 bip54]: /zh/newsletters/2025/11/07/#bip54-implementation-and-test-vectors
[Core Lightning v25.12]: https://github.com/ElementsProject/lightning/releases/tag/v25.12