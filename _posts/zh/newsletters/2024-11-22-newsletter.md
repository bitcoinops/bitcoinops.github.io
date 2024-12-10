---
title: 'Bitcoin Optech Newsletter #330'
permalink: /zh/newsletters/2024/11/22/
name: 2024-11-22-newsletter-zh
slug: 2024-11-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了闪电网络规范的一项拟议更改，该更改允许可插拔通道工厂；链接到一份报告和一个新网站，用于检查默认 signet 上使用提议的软分叉的交易；描述了 LNHANCE 多模块软分叉提案的更新；并讨论了一篇关于基于研磨而非共识更改的限制条款的论文。此外还包括我们的常规部分，总结了服务、客户端软件和流行比特币基础设施软件的最新变更。

## 新闻

- **<!--pluggable-channel-factories-->可插拔通道工厂：** ZmnSCPxj 在 Delving Bitcoin 上[发布][zmnscpxj plug]了一项提案，建议对 [BOLT][bolts repo] 规范进行一系列小的更改，以允许现有的闪电网络软件通过软件插件管理通道工厂内的 [LN-Penalty][topic ln-penalty] 支付通道。这些规范更改将允许工厂管理者（例如闪电服务提供商，LSP）向闪电节点发送消息，这些消息将传递给本地工厂插件。许多工厂操作与[通道拼接][topic splicing]操作类似，允许插件重用大量代码。工厂内的 LN-Penalty 通道操作类似于[零确认通道][topic zero-conf channels]，因此也可以重用现有代码。

  ZmnSCPxj 的设计主要针对 SuperScalar 风格的工厂（参见[周报 #327][news327 superscalar]），但可能与其他工厂风格（以及可能的其他多方合约协议）兼容。Rene Pickhardt [回复][pickhardt plug]询问是否可以进行额外的规范更改，以允许工厂内的通道进行[公告][topic channel announcements]，但 ZmnSCPxj [表示][zmnscpxj plug2]他在设计中故意不考虑这些，以便规范更改能够尽快被采用。

- **<!--signet-activity-report-->****Signet 活动报告：** Anthony Towns 在 Delving Bitcoin 上[发布][towns signet]了一份关于默认 [signet][topic signet] 上与通过 [Bitcoin Inquisition][bitcoin inquisition repo] 提供的提议软分叉相关活动的总结。该帖子研究了 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 的使用情况，包括 [LN-Symmetry][topic eltoo] 的测试和 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 的模拟；然后查看了直接使用 `OP_CHECKTEMPLATEVERIFY` 的情况，包括可能是几种不同的[保险库][topic vaults]构造和一些数据载体交易。最后，该帖子查看了 [OP_CAT][topic op_cat] 的使用情况，包括用于工作量证明水龙头（参见[周报 #306][news306 powfaucet]）、可能的保险库或其他[限制条款][topic covenants]，以及验证 [STARK][] 零知识证明。

  Vojtěch Strnad [回复][strnad i.o]说，他受到 Towns 的帖子启发，创建了一个网站，列出了“在比特币 signet 上使用部署的软分叉而进行的[每笔交易][inquisition.observer]”。

- **<!--update-to-lnhance-proposal-->****LNHANCE 提案更新：** Moonsettler 在 [Delving Bitcoin][moonsettler paircommit delving] 和 Bitcoin-Dev 邮件列表上[发布][moonsettler paircommit list]了一项提案，建议在包含 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 和 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 的 LNHANCE 软分叉提案中添加一个新的操作码 `OP_PAIRCOMMIT`。这个新操作码允许对一对元素进行哈希承诺；这类似于使用提议的 [OP_CAT][topic op_cat] 连接操作码或流式 SHA 操作码（如 Elements 基础的[侧链][topic sidechains]中[可用][streaming sha]的那些）所能实现的功能，但被刻意限制以避免启用递归[限制条款][topic covenants]。

  Moonsettler 还在邮件列表上[讨论][moonsettler other lnhance]了 LNHANCE 提案的其他一些小的潜在调整。

- **<!--covenants-based-on-grinding-rather-than-consensus-changes-->基于研磨而非共识更改的限制条款：** Ethan Heilman 在 Bitcoin-Dev 邮件列表上[发布][heilman collider]了他与 Victor Kolobov、Avihu Levy 和 Andrew Poelstra 合著的[论文][hklp collider]的摘要。该论文描述了如何在不进行共识更改的情况下轻松创建[限制条款][topic covenants]，尽管从这些限制条款中花费将需要非标准交易和价值数百万（或数十亿）美元的专用硬件和电力。Heilman 指出，该工作的一个应用是允许用户今天轻松包含一个备用 taproot 支出路径，如果突然需要[抗量子能力][topic quantum resistance]并且比特币上的椭圆曲线签名操作被禁用，可以安全使用。

## 服务和客户端软件变更

*在这个月度专题中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--spark-layer-two-protocol-announced-->****Spark 二层协议发布：**
  [Spark][spark website] 是一个链下的、类似[状态链][topic statechains]的协议，支持闪电网络。

- **<!--unify-wallet-announced-->****Unify 钱包发布：**
  [Unify][unify github] 是一个兼容 [BIP78][] 的 [payjoin][topic payjoin] 钱包，使用 Bitcoin Core 并通过 nostr 来协调 [PSBTs][topic psbt]。

- **<!--bitcoinutils-dev-launches-->****bitcoinutils.dev 上线：**
  [bitcoinutils.dev][] 网站提供各种比特币的实用工具，包括脚本调试以及各种编码和哈希函数。

- **<!--great-restored-script-interpreter-available-->****Great Restored Script Interpreter 可用：**
  [Great Restored Script Interpreter][greatrsi github] 是 [Great Script Restoration][gsr youtube] 提案的实验性解释器。

## 重要代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #30666][] 添加了 `RecalculateBestHeader()` 函数，通过迭代区块索引重新计算最佳区块头，当使用 `invalidateblock` 和 `reconsiderblock` RPC 命令时，或当区块索引中的有效区块头在完整验证期间被发现无效时，会自动触发。这修复了这些事件后该值设置错误的问题。此 PR 还把从无效区块延伸出的区块头标记为 `BLOCK_FAILED_CHILD`，防止认定它们为 `m_best_header`。

- [Bitcoin Core #30239][] 使[临时粉尘][topic ephemeral anchors]输出成为标准输出，允许具有一个[粉尘][topic uneconomical outputs]输出的零手续费交易出现在交易池中，前提是它们在交易[包][topic package relay]中同时被花费。这一变更改善了高级构造的可用性，如连接器输出、有密钥和无密钥（[P2A][topic ephemeral anchors]）锚点，这些可以使闪电网络、[Ark][topic ark]、[超时树][topic timeout trees]、[BitVM2][topic acc] 等协议的扩展受益。此更新建立在现有功能之上，如 1P1C 中继、[TRUC][topic v3 transaction relay] 交易和[亲属间驱逐][topic kindred rbf]（参见[周报 #328][news328 ephemeral]）。

- [Core Lightning #7833][] 默认启用了 [offer][topic offers] 协议，移除了其之前的实验性状态。这是在其 PR 合并到 BOLTs 仓库后的举措（参见[周报 #323][news323 offers]）。

- [Core Lightning #7799][] 引入了 `xpay` 插件，通过构建最优[多路径支付][topic multipath payments]来发送支付，使用 `askrene` 插件（参见[周报 #316][news316 askrene]）和 `injectpaymentonion` RPC 命令。它支持支付 [BOLT11][] 和 [BOLT12][topic offers] 发票，设置重试持续时间和支付截止时间，通过层添加路由数据，以及为单个发票的多方贡献进行部分支付。这个插件比旧的 “pay” 插件更简单和更精密，但没有包含全部原有功能。

- [Core Lightning #7800][] 添加了新的 `listaddresses` RPC 命令，返回 CLN 节点生成的所有比特币地址列表。此 PR 还将 [P2TR][topic taproot] 设置为[锚点输出][topic anchor outputs]支出和单方面关闭找零地址的默认脚本类型。

- [Core Lightning #7102][] 扩展了 `generatehsm` 命令，使其可以通过命令行选项非交互式运行。以前，你只能通过终端的交互式过程生成硬件安全模块（HSM）密钥，所以这个变更对自动化安装特别有用。

- [Core Lightning #7604][] 为记账插件添加了 `bkpr-editdescriptionbypaymentid` 和 `bkpr-editdescriptionbyoutpoint` RPC 命令，分别用于更新或设置匹配支付 ID 或输出点的事件描述。

- [Core Lightning #6980][] 引入了新的 `splice` 命令，该命令接受 JSON 负载或定义复杂[拼接][topic splicing]和相关操作的拼接脚本，并将所有这些多通道操作组合到单个交易中。此 PR 还添加了 `addpsbtinput` RPC 命令，允许用户直接向 [PSBT][topic psbt] 添加输入，并添加了 `stfu_channels` 和 `abort_channels` RPC 命令，允许用户暂停通道活动或中止多个通道以启用[通道承诺升级][topic channel commitment upgrades]，这在执行复杂的拼接操作时至关重要。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30666,30239,7833,7799,7800,7102,7604,6980,3283" %}
[zmnscpxj plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/
[news327 superscalar]: /zh/newsletters/2024/11/01/#timeout-tree-channel-factories
[pickhardt plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/2
[zmnscpxj plug2]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/3
[towns signet]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257
[news306 powfaucet]: /zh/newsletters/2024/06/07/#op-cat-script-to-validate-proof-of-work
[stark]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[moonsettler paircommit delving]: https://delvingbitcoin.org/t/op-paircommit-as-a-candidate-for-addition-to-lnhance/1216
[moonsettler paircommit list]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xyv6XTAFIPmbG1yvB0l2N3c9sWAt6lDTG-xjIbogOZ-lc9RfsFeJ-JPuXuXKzVea8T9TztlCvSrxZOWXKCwogCy9tqa49l3LXjF5K2cLtP4=@protonmail.com/
[streaming sha]: https://github.com/ElementsProject/elements/blob/011feab4c45d6e23985dbd68294e6aeb5a7c0237/doc/tapscript_opcodes.md#new-opcodes-for-additional-functionality
[moonsettler other lnhance]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZzZziZOy4IrTNbNG@console/
[heilman collider]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W2jyFoJAq9XrE9whQ7EZG4HRST01TucWHJtBhQiRTSNQ@mail.gmail.com/
[hklp collider]: https://eprint.iacr.org/2024/1802
[strnad i.o]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257/4
[inquisition.observer]: https://inquisition.observer/
[news323 offers]: /zh/newsletters/2024/10/04/#bolts-798
[news316 askrene]: /zh/newsletters/2024/08/16/#core-lightning-7517
[news328 ephemeral]: /zh/newsletters/2024/11/08/#bitcoin-core-pr-审核俱乐部
[spark website]: https://www.spark.info/
[unify github]: https://github.com/Fonta1n3/Unify-Wallet
[bitcoinutils.dev]: https://bitcoinutils.dev/
[greatrsi github]: https://github.com/jonasnick/GreatRSI
[gsr youtube]: https://www.youtube.com/watch?v=rSp8918HLnA
