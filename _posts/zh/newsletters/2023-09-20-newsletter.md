---
title: 'Bitcoin Optech Newsletter #269'
permalink: /zh/newsletters/2023/09/20/
name: 2023-09-20-newsletter-zh
slug: 2023-09-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报分享了即将举行的比特币研究活动的公告，并包括我们的常规部分：总结了各种服务和客户端软件的重大更新、新的软件发布和候选发布的公告，以及热门的比特币基础设施软件的近期变更的介绍。

## 新闻

- **<!--bitcoin-research-event-->比特币研究活动：** Sergi Delgado Segura 和 Clara Shikhelman
在 Bitcoin-Dev 和 Lightning-Dev 邮件列表中[发帖][ds brd]宣布，将于 10 月 27 日在纽约市举行一次 _比特币研究日_ 活动。这将是一次线下面对面的活动，许多知名的比特币研究人员将发表演讲。参加活动需要预约。在发布本文时，仍有一些申请短时间（5 分钟）报告的位置机会。

## 服务和客户端软件变更

*在这个月度栏目中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **比特币类型脚本的符号追踪器（B'SST）发布：**
  [B'SST][] 是一个比特币和 Elements 脚本分析工具。对脚本的分析反馈包括“脚本强制执行的条件、可能的失败情况、数据可能的值”。

- **STARK 区块头验证器演示：**
  [ZeroSync][news222 zerosync] 项目公告了一个使用 STARKs 来证明和验证一个链的比特币区块头的[演示][zerosync demo]和[代码库][zerosync code]。

- **JoinMarket v0.9.10 发布：**
  [v0.9.10][joinmarket v0.9.10]发布版本添加了对非 [coinjoin][topic coinjoin] 交易的 [RBF][topic rbf] 支持和费用估算更新，以及其他改进。

- **BitBox 添加了 miniscript：**
  [最新的 BitBox02 固件][bitbox blog] 添加了 [miniscript][topic miniscript] 支持，以及一项安全修复和可用性的改进。

- **Machankura 宣布增量批处理功能：**
  比特币服务提供商 [Machankura][] [宣布][machankura tweet]了一项使用 RBF 在一个具有 FROST [阈值][topic threshold signature]花费条件的 [taproot][topic taproot] 钱包中进行增量[批处理][batching]的 beta 版功能。

- **SimLN 闪电网络模拟工具：**
  [SimLN][] 是一个为闪电网络研究人员和协议/应用开发者设计的模拟工具，可以生成真实的闪电网络支付活动。SimLN 支持 LND 和 CLN；对 Eclair 和 LDK-Node 的支持工作在进行中。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 23.08.1][]是一个维护版本，包括了几个错误修订。

- [LND v0.17.0-beta.rc4][] 是这个热门的闪电网络节点实现的下一个主要版本的候选发布版本。这个发布版计划引入一个新的重要实验功能，支持“简单 Taproot 通道”。该功能可能还需要进行测试。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]，和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #26152][] 在之前添加的接口基础上进行了改进（参见[周报 #252][news252 bumpfee]），以为交易中输入的任何 _手续费赤字_ 进行支付。手续费赤字会出现在当钱包必须选择具有低费率的未确认祖先交易的 UTXO 情况下。为了使用户的交易按照用户所选的费率进行支付，该交易必须支付足够高的费用额，以同时确认自己和其低费率的未确认祖先交易。简而言之，这个 PR 确保了，在用户选定一个费率 —— 也即设定了所希望的交易确认优先级 —— 之后，即便钱包必须支付给未确认的 UTXO，也可以获得这样的优先级。我们知道的所有其他钱包只能在仅花费已确认 UTXO 时才能保证费率的优先级。另请参阅[周报 #229][news229 bumpfee]，了解有关这个 PR 的 Bitcoin Core PR Review Club 会议的摘要。

- [Bitcoin Core #28414][] 更新了 `walletprocesspsbt` RPC。如果钱包处理步骤中生成了一笔可广播的交易，调用该 RPC 的结果中将包含这笔交易的一个完整（以十六进制格式的）序列化内容。这样可以为用户节省调用 `finalizepsbt` 的步骤，因为它已经是最终的 [PSBT][topic psbt]。

- [Bitcoin Core #28448][] 弃用了 `rpcserialversion`（RPC 序列化版本）配置参数。此选项是在过渡到 v0 隔离见证时引入的，以允许旧程序继续以剥离的格式（不包含任何隔离见证字段）来访问区块和交易。当前，所有程序都应该更新以处理隔离见证交易。因此，尽管如 PR 的发布说明中所述该选项可以作为废弃 API 被临时性的重新启用，但它已应不再必需。

- [Bitcoin Core #28196][] 添加了对 [BIP324][] 所规定的 [v2 传输协议][topic v2 p2p transport]进行支持所需的大部分代码，以及对代码进行了大量的模糊测试。这不会启用任何新功能，但会减少将来启用这些功能所需添加的代码量。

- [Eclair #2743][] 添加了一个 `bumpforceclose` RPC，它将手动告诉节点从一个通道的[锚点输出][topic anchor outputs]花费，以 [CPFP 手续费提升][topic cpfp]一个承诺交易。Eclair 节点提供在必要时自动提升手续费的功能，但该 RPC 允许操作人员手动获得相同的能力。

- [LDK #2176][] 提升了 LDK 试图以概率方式猜测为其付款进行路由的远端通道中的可用流动性数量的精度。一个 1.00000 BTC 大小的通道中的精度原先最低可到 0.01500 BTC；目前对相同大小的通道，精度可达到约 0.00006 BTC。这可能会稍微增加寻找付款路径所需的时间，但测试表明区别并不明显。

- [LDK #2413][] 支持向[盲化路径][topic rv routing]付款，并允许在仅对发送者隐藏（盲化）最终一跳的路径上接收支付。同样在本周合并的 [PR #2514][ldk #2514]，提供了对 LDK 中盲化支付的其他支持。

- [LDK #2371][] 添加了对使用 [要约（offers）][topic offers] 管理支付的支持。它允许一个使用 LDK 的客户端应用程序使用要约来注册其向一个发票支付的意图；如果发送的要约从未收到发票，可对该支付尝试进行超时处理；否则，使用 LDK 中的现有代码支付给该发票（包括在第一次尝试不成功时进行重试）。


{% include references.md %}
{% include linkers/issues.md v=2 issues="26152,28414,28448,28196,2743,2176,2413,2514,2371" %}
[LND v0.17.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc4
[ds brd]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021959.html
[news252 bumpfee]: /zh/newsletters/2023/05/24/#bitcoin-core-27021
[news229 bumpfee]: /zh/newsletters/2022/12/07/#bitcoin-core-pr-审核俱乐部
[Core Lightning 23.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.08.1
[B'SST]: https://github.com/dgpv/bsst
[news222 zerosync]: /zh/newsletters/2022/10/19/#zerosync
[zerosync demo]: https://zerosync.org/demo/
[zerosync code]: https://github.com/ZeroSync/header_chain
[joinmarket v0.9.10]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.10
[bitbox blog]: https://bitbox.swiss/blog/bitbox-08-2023-marinelli-update/
[Machankura]: https://8333.mobi/
[machankura tweet]: https://twitter.com/machankura8333/status/1695827506794754104
[batching]: /en/payment-batching/
[SimLN]: https://github.com/bitcoin-dev-project/sim-ln
