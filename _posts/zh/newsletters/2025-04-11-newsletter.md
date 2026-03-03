---
title: 'Bitcoin Optech Newsletter #349'
permalink: /zh/newsletters/2025/04/11/
name: 2025-04-11-newsletter-zh
slug: 2025-04-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报介绍了一项旨在加速 Bitcoin Core 初始区块下载的提案，其概念验证实现显示，与 Bitcoin Core 的默认设置相比，速度提高了约 5 倍。此外还包括我们的常规栏目，总结了 Bitcoin Core PR Review Club 会议，宣布了新版本和候选版本，并描述了热门比特币基础设施项目的显著变更。

## 新闻

- **<!--swiftsync-speedup-for-initial-block-download-->SwiftSync 加速初始区块下载：** Sebastian Falbesoner 在 Delving Bitcoin 上[发布][falbesoner ss1]了 _SwiftSync_ 的示例实现和性能结果。这个想法是由 Ruben Somsen 在最近一次 Bitcoin Core 开发者会议上[提出][somsen ssgist]的，后来又[发布][somsen ssml]到了邮件列表。截至撰写本文时，该讨论帖下发布的[最新结果][falbesoner ss2]显示，与 Bitcoin Core 的默认 IBD 设置（使用 [assumevalid][] 但未使用 [assumeUTXO][topic assumeutxo]）相比，_初始区块下载_（IBD）速度提高了 5.28 倍，将初始同步时间从大约 41 小时减少到大约 8 小时。

  在使用 SwiftSync 之前，已经将其节点同步到最新区块的人会创建一个 _hints 文件_，该文件指示在该区块高度 UTXO 集中将包含哪些交易输出（即哪些输出未被花费）。对于当前的 UTXO 集大小，这可以高效地编码为几百兆字节。该 hints 文件还指示了生成它的区块，我们称之为_终端 SwiftSync 区块_。

  执行 SwiftSync 的用户下载 hints 文件，并在处理终端 SwiftSync 区块之前的每个区块时使用它，仅当 hints 文件指示该输出在到达终端 SwiftSync 区块时仍将保留在 UTXO 集中时，才将输出存储在 UTXO 数据库中。这大大减少了 IBD 期间添加到 UTXO 数据库然后又被删除的条目数量。

  为了确保 hints 文件的正确性，每个创建出来但不存储在最终 UTXO 数据库中的输出，都会被添加到一个[密码学累加器][cryptographic accumulator]中。而花掉的输出都会从这个累加器中移除。当节点到达终点 SwiftSync 区块时，它会确保累加器为空，这意味着所有看到的输出后来都被花费了。如果失败，则意味着 hints 文件不正确，需要从头开始重新执行 IBD 而不使用 SwiftSync。通过这种方式，用户无需信任 hints 文件的创建者——恶意文件不会导致错误的 UTXO 状态；它最多只能浪费用户几个小时的计算资源。

  SwiftSync 另一个尚未实现的特性是允许在 IBD 期间并行验证区块。这是可能的，因为 assumevalid 不检查旧区块的脚本，在终点 SwiftSync 区块之前永远不会从 UTXO 数据库中删除条目，并且使用的累加器仅跟踪输出被添加（创建）和移除（花费）的净效果。这消除了终点 SwiftSync 区块之前区块之间的任何依赖关系。由于类似的原因，IBD 期间的并行验证也是 [Utreexo][topic utreexo] 的一个特性。

  该讨论检视了该提案的几个方面。Falbesoner 的原始实现使用了 [MuHash][] 累加器（参见[周报 #123][news123 muhash]），[已被证明][wuille muhash]可以抵抗[广义生日攻击][generalized birthday attack]。Somsen [描述][somsen ss1]了一种可能更快的替代方法。由于它很简单，Falbesoner 质疑该替代方法是否具有密码学安全性，但还是实现了它，并进一步发现它可加速 SwiftSync。

  James O'Beirne [提问][obeirne ss]鉴于 assumeUTXO 提供了更大的加速，SwiftSync 是否还有用。Somsen [回复][somsen ss2]说 SwiftSync 加速了 assumeUTXO 的后台验证，使其成为 assumeUTXO 用户的一个很好的补充。他进一步指出，任何下载 assumeUTXO 所需数据（特定区块时刻的 UTXO 数据库）的人，如果使用同一区块作为终端 SwiftSync 区块，则不需要单独的 hints 文件。

  Vojtěch Strnad、0xB10C 和 Somsen [讨论][b10c ss]了压缩 hint 文件数据，预计可节省约 75%，将测试 hints 文件（针对区块 850,900）的大小减少到约 88 MB。

  截至撰写本文时，讨论仍在进行中。

## Bitcoin Core PR Review Club

*在本月度栏目中，我们总结了最近一次 [Bitcoin Core PR Review Club][] 会议，重点介绍了其中一些重要的问题和回答。点击下面的问题，即可查看会议中该问题的回答摘要。*

[添加手续费率预测器管理器][review club 31664] 是由 [ismaelsadeeq][gh ismaelsadeeq] 提交的一个 PR，它升级了交易手续费预测（也称为[估算][topic fee estimation]）逻辑。它引入了一个新的 `ForecasterManager` 类，可以向其注册多个 `Forecaster`。现有的 `CBlockPolicyEstimator`（仅考虑已确认交易）被重构为其中一个预测器，但值得注意的是，还引入了一个新的 `MemPoolForecaster`。`MemPoolForecaster` 考虑了交易池中未确认的交易，因此可以更快地对费率变化做出反应。

{% include functions/details-list.md
  q0="<!--why-is-the-new-system-called-a-forecaster-and-forecastermanager-rather-than-an-estimator-and-fee-estimation-manager-->为什么新系统被称为“预测器（Forecaster）”和“预测器管理器（ForecasterManager）”，而不是“估算器（Estimator）”和“手续费估算管理器（Fee Estimation Manager）”？"
  a0="该系统根据当前和过去的数据预测未来的结果。与估算器不同（估算器通过一些随机化来近似当前状况），预测器预测未来事件，这与该系统的预测性质及其不确定性/风险水平的输出相符。"
  a0link="https://bitcoincore.reviews/31664#l-19"

  q1="<!--why-is-cblockpolicyestimator-not-modified-to-hold-the-mempool-reference-similar-to-the-approach-in-pr-12966-what-is-the-current-approach-and-why-is-it-better-than-holding-a-reference-to-mempool-hint-see-pr-28368-->为什么不像 PR #12966 中的方法那样修改 `CBlockPolicyEstimator` 来持有交易池引用？当前的方法是什么？为什么它比持有交易池引用更好？（提示：参见 PR #28368）"
  a1="`CBlockPolicyEstimator` 继承自 `CValidationInterface` 并实现了其虚方法 `TransactionAddedToMempool`、`TransactionRemovedFromMempool` 和 `MempoolTransactionsRemovedForBlock`。这使得 `CBlockPolicyEstimator` 能够获得所需的所有交易池信息，而无需通过引用与交易池不必要地紧密耦合。"
  a1link="https://bitcoincore.reviews/31664#l-26"

  q2="<!--what-are-the-trade-offs-between-the-new-architecture-and-a-direct-modification-of-cblockpolicyestimator-->新架构与直接修改 `CBlockPolicyEstimator` 相比，有哪些权衡？"
  a2="采用 `FeeRateForecasterManager` 类并可以注册多个 `Forecaster` 的新架构是一种更模块化的方法，可以实现更好的测试，并强制执行更好的关注点分离。它允许以后轻松插入新的预测策略。这样做的代价是需要维护更多的代码，并且可能会让用户对使用哪种估算方法感到困惑。"
  a2link="https://bitcoincore.reviews/31664#l-43"
%}

## 新版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning 25.02.1][] 是这个流行的闪电网络节点当前主要版本的维护版本，其中包含几个错误修复。

- [Core Lightning 24.11.2][] 是这个流行的闪电网络节点先前主要版本的维护版本。它包含几个错误修复，其中一些与 25.02.1 版本中发布的错误修复相同。

- [BTCPay Server 2.1.0][] 是这款自托管支付处理软件的主要版本。它包含对某些山寨币用户的非兼容变更，改进了[手续费替换 (RBF)][topic rbf] 和 [CPFP][topic cpfp] 手续费提升功能，并为所有签名者都使用 BTCPay Server 的多重签名提供了更好的流程。

- [Bitcoin Core 29.0rc3][] 是该网络主要全节点下一个主要版本的候选版本。请参阅[版本 29 测试指南][bcc29 testing guide]。

- [LND 0.19.0-beta.rc2][] 是这个流行的闪电网络节点的候选版本。可能需要测试的主要改进之一是用于协作关闭的基于[手续费替换][topic rbf]的新手续费提升。

## 重要代码和文档变更

_以下是 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[闪电网络 BOLTs][bolts repo]、[闪电网络 BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的重要变更。_

- [LDK #2256][] 和 [LDK #3709][] 改进了 [BOLTs #1044][] 中指定的可归因故障（参见周报 [#224][news224 failures]），通过向 `UpdateFailHTLC` 结构添加可选的 `attribution_data` 字段并引入 `AttributionData` 结构。在此协议中，每个转发节点向失败消息追加一个 `hop_payload` 标志、一个记录节点持有 HTLC 时长的 duration 字段，以及对应于路由中不同假定位置的 HMAC。如果某个节点损坏了失败消息，HMAC 链中的不匹配有助于识别发生这种情况的节点对。

- [LND #9669][] 将[简单 taproot 通道][topic simple taproot channels]降级为始终使用传统的协作关闭流程，即使配置了[手续费替换 (RBF)][topic rbf] 协作关闭流程（参见周报 [#347][news347 coop]）。以前，同时配置了这两个功能的节点将无法启动。

- [Rust Bitcoin #4302][] 向脚本构建器 API 添加了一个新的 `push_relative_lock_time()` 方法，该方法接受一个相对[时间锁][topic timelocks]参数，并弃用了接受原始序列号作为参数的 `push_sequence()`。此更改解决了一个潜在的混淆问题，即开发人员可能会错误地在脚本中推送原始序列号而不是相对时间锁值，后者随后会使用 `CHECKSEQUENCEVERIFY` 根据输入的序列号进行检查。

{% include snippets/recap-ad.md when="2025-04-15 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2256,3709,9669,4302,1044" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[wuille muhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[falbesoner ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/
[somsen ssgist]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[falbesoner ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/7
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[cryptographic accumulator]: https://zh.wikipedia.org/wiki/%E7%B4%AF%E5%8A%A0%E5%99%A8_(%E5%AF%86%E7%A2%BC%E5%AD%B8)
[news123 muhash]: /zh/newsletters/2020/11/11/#bitcoin-core-pr-审查俱乐部
[muhash]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
[generalized birthday attack]: https://www.iacr.org/archive/crypto2002/24420288/24420288.pdf
[somsen ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/2
[obeirne ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/5
[somsen ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/6
[b10c ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/4
[somsen ssml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjaM0tfbcBTRa0_713Bk6Y9jr+ShOC1KZi2V3V2zooTXyg@mail.gmail.com/T/#u
[core lightning 25.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.02.1
[core lightning 24.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.2
[btcpay server 2.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.1.0
[news224 failures]: /zh/newsletters/2022/11/02/#ln-routing-failure-attribution
[news347 coop]: /zh/newsletters/2025/03/28/#lnd-8453
[review club 31664]: https://bitcoincore.reviews/31664
[gh ismaelsadeeq]: https://github.com/ismaelsadeeq
[forecastresult compare]: https://github.com/bitcoin-core-review-club/bitcoin/commit/1e6ce06bf34eb3179f807efbddb0e9bca2d27f28#diff-5baaa59bccb2c7365d516b648dea557eb50e63837de71531dc460dbcc62eb9adR74-R77
