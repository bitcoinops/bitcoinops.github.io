---
title: 'Bitcoin Optech Newsletter #336'
permalink: /zh/newsletters/2025/01/10/
name: 2025-01-10-newsletter-zh
slug: 2025-01-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个可能影响矿工的 Bitcoin Core 变更，总结了关于创建合约级相对时间锁（relative timelocks）的讨论，讨论了一个带有可选惩罚机制的 LN-Symmetry 变体提案。此外，还包括我们的常规部分：新版本和候选版本的公告、以及对热门比特币基础设施项目的重大变更介绍。

## News

- **<!--investigating-pool-behavior-before-before-a-bitcoin-core-bug-->在修复 Bitcoin Core 漏洞前调查矿池行为：**
  Abubakar Sadiq Ismail 在 Delving Bitcoin [发布了][ismail double]一篇关于 2021 年由 Antoine Riard 发现的[漏洞][bitcoin core #21950]的帖子。该漏洞会导致节点在区块模板中为 coinbase 交易保留 2000 vbytes，而非预期的 1000 vbytes。如果取消这种双倍保留，大约可以多包含五笔小交易。然而，这可能导致依赖双倍保留的矿工生成无效区块，从而造成大量收入损失。Ismail 分析了过去的区块，以确定哪些矿池可能存在风险。他指出 Ocean.xyz、F2Pool 和一个未知的矿工显然正在使用非默认设置，尽管如果漏洞得到修复，这些矿工似乎都没有亏损的风险。

  然而，为了将风险降至最低，目前建议引入一个新的启动选项，默认情况下仍为 coinbase 交易保留 2000 vbytes。对于不需要向后兼容性的矿工，可以轻松将保留值减少到 1000 vbytes（或者更少，如果他们的需求更低）。

  Jay Beddict 将这一消息[转发到][beddict double]了 Mining-Dev 邮件列表中。

- **<!--contract-level-relative-timelocks-->合约级相对时间锁：** Gregory Sanders 在 Delving Bitcoin 上[发布了][sanders clrt]一篇帖子，讨论他在一年前创建 [LN-Symmetry][topic eltoo]概念验证实现时发现的一个问题的解决方案(见[周报#284][news284 deltas])。在该协议中，每个通道状态都可以在链上确认，但只有在截止日期之前确认的最新状态才能分配通道资金。通常，通道的双方会尝试只确认最新状态；然而，如果 Alice 发起一个新的状态更新，通过部分签署交易并将其发送给 Bob，则只有 Bob 可以完成这笔交易。如果此时 Bob 停止合作，Alice 只能在倒数第二个状态下关闭通道。如果 Bob 等到 Alice 的倒数第二个状态接近截止日期时才确认最新状态，通道的解决时间将约为截止时间的两倍，_即 2x 延迟问题_。这意味着 LN-Symmetry 中 [HTLC][topic htlc] 的[时间锁][topic timelocks] 必须设置为原来的两倍，从而增加了攻击者(通过[通道阻塞攻击][topic channel jamming attacks]等手段)阻止转发节点获得资本收益的难度。

  Sanders 建议使用相对时间锁定来解决这个问题，该时间锁定将适用于结算合同所需的所有交易。如果 LN-Symmetry 具有这样的功能，而 Alice 确认了倒数第二个状态，Bob 将需要在倒数第二个状态的截止日期之前确认最新状态。在[后续帖子][sanders tpp]中，Sanders 链接到 John Law 的一个通道协议(见[周报#244][news244 tpp])，该协议使用两个交易级别的相对时间锁来提供合约级别的相对时间锁，而无需共识变更。然而，这对 LN-Symmetry 无法奏效，因为 LN-Symmetry 允许每个状态从任何先前状态进行花费。

  Sanders 描绘了一种解决方案，但指出它存在缺点。他还提到可以通过 Chia 的 `coinid` 功能解决该问题，这与 John Law 在 2021 年提出的“继承标识符（Inherited Identifiers，IIDs）”的想法类似。Jeremy Rubin [回复了][rubin muon]一条链接，提到他去年提出的_muon_输出提案，该提案要求创建它们的交易和消费它们的交易必须在同一块中完成，并展示了这些输出如何有助于解决问题。Sanders 提到，并由 Anthony Towns [扩展了][towns coinid]关于 Chia 区块链中 `coinid` 功能的讨论，展示了它如何将所需数据减少到恒定数量。Salvatore Ingala [发布了][ingala cat]一种使用 [OP_CAT][topic op_cat] 的类似机制，他从开发者 Rijndael 那里了解到，后者后来[提供了详细信息][rijndael cat]。Brandon Black [ 描述了][black penalty]一种替代方案：一种基于惩罚的 LN-Symmetry 变体，并引用了 Daniel Roberts 的相关工作(见下一个新闻项目)。

- **<!--multiparty-ln-symmetry-variant-with-penalties-for-limiting-published-update-->带有惩罚机制的多方 LN-Symmetry 变体：限制已发布的更新：**
  Daniel Roberts 在 Delving Bitcoin 上[发布了][roberts sympen]一篇帖子，讨论如何防止恶意的通道对手方(Mallory)通过故意以比诚实对手方(Bob)更高的用来支付最终状态的费率广播旧状态来延迟通道结算的行为。理论上，Bob 可以将其最终状态重新绑定到 Mallory 的旧状态，并且这两个交易可能在同一区块中确认，从而导致 Mallory 因支付费用而损失金钱，而 Bob 则以他已经愿意支付的相同费用确认最终状态。然而，如果 Mallory 能够反复阻止 Bob 在她的旧状态广播被确认之前获知这一行为，她可以阻止他做出反应，直到通道中的 [HTLC][topic htlc] 到期并使 Mallory 能够窃取资金。

  Roberts 提出了一个方案，允许通道参与者仅确认一个状态。如果之前的状态被确认，则提交最终状态的参与者以及未提交任何状态的参与者可以没收任何提交了过时旧状态的参与者的资金。

  然而，在发布该方案后，Roberts 发现并自我披露了其中的一个关键缺陷：类似于前述新闻中描述的_2x 延迟问题_，最后签名的参与者可以完成一个其他参与者无法完成的状态，从而使最终签名者独占当前最终状态。如果其他参与者试图以先前状态关闭通道，他们将在最终签名者利用最终状态时损失资金。

  Roberts 正在研究替代方案，但这一话题激发了关于是否为 LN-Symmetry 添加惩罚机制的有趣讨论。Gregory Sanders，他的 LN-Symmetry 概念验证实现让他认为惩罚机制没有必要，(见[周报#284][news284 sympen])，他指出，重复旧状态攻击类似于一种[替代循环攻击（replacement cycling attack）][topic replacement cycling]。他认为，“这种攻击相当弱，因为即使防御方资源有限，也可以轻松让[攻击者]处于负期望值（negative EV）状态[expected value]”，即使防御方资源有限，并且无法了解矿工试图确认的交易。

## 版本和候选版本

_热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 28.1][] 是主流全节点实现的维护版本。

- [BDK 0.30.1][] 是之前发布系列的维护版本，包含了一些错误修复。建议项目升级到 BDK Wallet 1.1.1.0（已在上周的周报中宣布），并提供了[迁移指南][bdk migration]帮助升级。

- [LDK v0.1.0-beta1][] 是该库的候选版本，用于构建支持闪电网络的钱包和应用程序。


## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #28121][] 在 `testmempoolaccept` RPC 命令的响应中新增了一个 `reject-details` 字段，仅当交易因共识或规则违规而被拒绝加入交易池时才包含该字段。此错误消息与 `sendrawtransaction` 命令中被拒绝交易时返回的消息相同。

- [BDK #1592][] 引入了架构决策记录（Architectural Decision Records，ADRs），用于记录重要的变更，明确所解决的问题、决策驱动因素、考虑的替代方案、优缺点以及最终的决策。这有助于新贡献者熟悉库的历史。此 PR 添加了一个 ADR 模板以及前两个 ADR：第一个 ADR 描述了从 `bdk_chain` 中移除 `persist` 模块的决策。第二个 ADR 引入了一个新的 `PersistedWallet` 类型，它包装了一个 `BDKWallet`。

{% include references.md %}
{% include linkers/issues.md v=2 issues="28121,1592,21950" %}
[bitcoin core 28.1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[bdk migration]: https://bitcoindevkit.github.io/book-of-bdk/getting-started/migrating/
[ismail double]: https://delvingbitcoin.org/t/analyzing-mining-pool-behavior-to-address-bitcoin-cores-double-coinbase-reservation-issue/1351
[beddict double]: https://groups.google.com/g/bitcoinminingdev/c/aM9SDXSMZDs
[sanders clrt]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/
[news284 deltas]: /zh/newsletters/2024/01/10/#expiry-deltas
[sanders tpp]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/2
[news244 tpp]: /zh/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[rubin muon]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/3
[towns coinid]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/7
[ingala cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/8
[rijndael cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/11
[black penalty]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/12
[roberts sympen]: https://delvingbitcoin.org/t/broken-multi-party-eltoo-with-bounded-settlement/1364/
[news284 sympen]: /zh/newsletters/2024/01/10/#penalties
[bdk 0.30.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.1
