---
title: 'Bitcoin Optech Newsletter #250'
permalink: /zh/newsletters/2023/05/10/
name: 2023-05-10-newsletter-zh
slug: 2023-05-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一篇关于 PoWswap 协议的论文，并包括我们的常规部分，其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。还包括一个简短的对 Bitcoin Optech 五周年和我们第 250 期周报的庆祝。

## 新闻

- **关于 PoWswap 协议的论文：** Thomas Hartman 在 Bitcoin-Dev 邮件列表上[发布了][hartman powswap]一篇关于他与 Gleb Naumenko 和 Antoine Riard 共同撰写的关于 Jeremy Rubin 首次提出的 [PoWSwap][] 协议的[论文][hnr powswap]。Powswap 允许创建与哈希率变化相关的链上可执行合约。基本思想利用了时间和区块生产之间的协议层强制关系，以及在时间或区块中表达时间锁的能力。例如，考虑以下脚本：

  ```
  OP_IF
    <Alice's key> OP_CHECKSIGVERIFY <time> OP_CHECKLOCKTIMEVERIFY
  OP_ELSE
    <Bob's key> OP_CHECKSIGVERIFY <height> OP_CHECKLOCKTIMEVERIFY
  OP_ENDIF
  ```

  让我们设想当前时间为 _t_ 并且区块高度为 _x_。如果区块平均间隔 10 分钟生成，那么如果我们将 `<time>` 设置为 _t + 1000_ 分钟，将 `<height>` 设置为 _x + 50_，我们希望 Bob 能够花费上述脚本控制的输出，且比 Alice 能够花费的时间早平均 500 分钟。然而，如果出块率突然增加一倍以上，Alice 可能会在 Bob 之前花掉此输出。

  这种类型的合同有几种设想的应用：

  - *<!--hashrate-increase-insurance-->哈希率增长保险：* 矿工必须先购买设备，然后才能确定设备将产生多少收入。例如，一名矿工购买了足够多的设备以获得网络当前总奖励的 1%，他可能会惊讶地发现其他矿工也购买了足够多的设备来使网络总哈希率翻倍，从而使矿工获得 0.5% 的奖励而不是 1%。通过 PoWSwap，矿工可以与有意愿的某人签订无信任合同，如果在特定日期之前哈希率增加，此人向矿工付款，以抵消矿工意外的低收入。作为交换，如果全网哈希率保持不变或下降，矿工会向该人支付预付费用或同意向他们支付更多金额。

  - *<!--hashrate-decrease-insurance-->哈希率下降保险：* 比特币出现的各种问题都会导致全网哈希率大幅下降。如果矿工被强大的政党关闭，或者如果老矿工之间突然开始发生大量[手续费狙击][topic fee sniping]，或者如果 BTC 对矿工的价值突然下降，哈希率就会下降。想要针对此类情况投保的 BTC 持有者可以与矿工或第三方签订免信任合约。

  - *<!--exchange-rate-contracts-->汇率合约：* 一般来说，如果 BTC 的购买力增加，矿工愿意增加他们提供的哈希率（以增加他们获得的奖励）。如果购买力下降，哈希率就会下降。许多人可能对与比特币未来购买力相关的无信任合约感兴趣。

  虽然 PoWSwap 的想法已经流传了好几年，该论文提供了比我们之前看到的更多的细节和分析。

## 版本和替代版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 23.05rc2][]是此 LN 实施的下一版本的候选版本。

- [Bitcoin Core 24.1rc2][]是当前 Bitcoin Core 版本的维护版本的候选版本。

- [Bitcoin Core 25.0rc1][]是 Bitcoin Core 下一个主要版本的候选版本。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了[Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[添加 getprioritisationmap，delta==0 时删除一个 mapDeltas 条目][review club 27501]是 Gloria Zhao (glozow)的 PR，它改进了 Bitcoin Core 的功能，允许矿工修改有效交易池费用，从而修改特定交易的挖矿优先级（更高或更低）(参见 [prioritisetransaction RPC][])。费用增加（如果为正）或减少（如果为负）称为 _fee delta_。交易优先级值在 `mempool.dat` 文件中持久保存到磁盘，并在节点重启时恢复。

矿工可能优先处理交易的一个原因是考虑到场外支付的交易费用；在选择将哪些交易包含在矿工的区块模板中时，受影响的交易将被视为具有更高的费用。

PR 添加了一个新的 RPC，`getprioritisationmap`，它返回一组优先交易事务。PR 还删除了不必要的优先级条目，如果用户将增量设置回零，则可能会出现这些条目。

{% include functions/details-list.md
  q0="<!--what-is-the-mapdeltas-data-structure-and-why-is-it-needed-->什么是 [mapDeltas][] 数据结构，为什么需要它？"
  a0="这是存储每笔交易优先级值的地方。这些值会影响本地的采矿和丢弃决策，以及祖先和后代的费率计算。"
  a0link="https://bitcoincore.reviews/27501#l-26"

  q1="<!--do-transaction-prioritizations-affect-the-fee-estimation-algorithm-->交易优先级会影响费用估算算法吗？"
  a1="不会。费用估算需要准确预测矿工（在这种情况下是其他矿工）的预期决策，而这些矿工没有我们的相同优先级，因为这是本地的。"
  a1link="https://bitcoincore.reviews/27501#l-31"

  q2="<!--how-is-an-entry-added-to-mapdeltas-when-is-it-removed-->如何将条目添加到 `mapDeltas`？何时会被移除？"
  a2="它由 `prioritisetransaction` RPC 添加，并且由于 `mempool.dat` 中的条目而在节点重新启动时添加。当包含交易的区块被添加到链中或交易被[替换][topic rbf]，它们将被删除。"
  a2link="https://bitcoincore.reviews/27501#l-34"

  q3="<!--why-shouldn-t-we-delete-a-transaction-s-entry-from-mapdeltas-when-it-leaves-the-mempool-because-for-example-it-has-expired-or-been-evicted-due-to-feerate-dropping-below-the-minimum-feerate-->为什么我们不应该在交易条目离开交易池时从 `mapDeltas` 中删除它（因为，例如，它已经过期或由于费率低于最低费率而被丢弃）？"
  a3="交易可能会回到交易池中。如果删除了其 `mapDeltas` 条目，则用户将不得不重新确定交易事务的优先级。"
  a3link="https://bitcoincore.reviews/27501#l-84"

  q4="<!--if-a-transaction-is-removed-from-mapdeltas-because-it-s-included-in-a-block-but-then-the-block-is-re-orged-out-won-t-the-transaction-s-priority-have-to-be-reestablished-->如果一个交易事务因为它包含在一个块中而从 `mapDeltas` 中删除，但随后该块被重组，是否必须重新建立事务的优先级？"
  a4="是的，但重组预计很少见。此外，场外支付实际上可能是比特币交易的形式，因此可能也需要重做。"
  a4link="https://bitcoincore.reviews/27501#l-90"

  q5="<!--why-should-we-allow-prioritizing-a-transaction-that-isn-t-present-in-the-mempool-->为什么我们应该允许优先处理交易池中不存在的交易？"
  a5="因为交易可能还没有在交易池中。而且它的费用甚至不足以进入交易池（不考虑优先级）。"
  a5link="https://bitcoincore.reviews/27501#l-89"

  q6="<!--what-is-the-problem-if-we-don-t-clean-up-mapdeltas-->如果我们不清理 `mapDeltas` 会有什么问题？"
  a6="主要问题是浪费内存分配。"
  a6link="https://bitcoincore.reviews/27501#l-107"

  q7="<!--when-is-mempool-dat-including-mapdeltas-written-from-memory-to-disk-->什么时候将 `mempool.dat`(包括 `mapDeltas`)从内存写入磁盘？"
  a7="在正确关机时，通过运行 `savemempool` RPC。"
  a7link="https://bitcoincore.reviews/27501#l-114"

  q8="<!--without-the-pr-how-do-miners-clean-up-mapdeltas-that-is-remove-entries-with-a-zero-prioritization-value-->如果没有 PR，矿工如何清理 `mapDeltas`（即删除优先级值为零的条目）？"
  a8="唯一的方法是重新启动节点，因为在重新启动期间零值优先级不会加载到 `mapDeltas` 中。使用 PR，一旦 `mapDeltas` 条目的值设置为零，它就会被删除。这具有额外的有益效果，即零值优先级不会写入磁盘。"
  a8link="https://bitcoincore.reviews/27501#l-127"
%}

## 重大的代码和文档变更

*本周的重大变更有[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和
[Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #26094][]将区块哈希和高度字段添加到 `getbalances`，`gettransaction` 和 `getwalletinfo`。这些 RPC 请求锁定了链状态以确保它们与最新区块保持同步，因此它们从响应中包含的有效的区块哈希和高度中受益。

- [Bitcoin Core #27195][]可以从使用 Bitcoin Core 内部钱包的 `bumpfee` RPC [替换][topic rbf]的交易中删除所有外部接收者。用户通过令替换交易的唯一输出支付到用户自己的地址来做到这一点。如果替换交易得到确认，这将阻止任何原始接收者获得支付，这有时被描述为“取消”比特币支付。

- [Eclair #1783][]添加了一个 `cpfpbumpfees` API，用于[CPFP][topic cpfp]来提升一个或多个交易费用。PR 还更新了运行 Bitcoin Core 的[推荐参数][eclair bitcoin.conf]列表，以确保创建费用提升交易是一个可行的选择。

- [LND #7568][]添加了在节点启动时定义额外 LN 特征位的能力。它还删除了在运行时禁用任何硬编码或定义的特征位的能力（但可能仍会添加其他位并在以后禁用）。[BLIPs #24][]中的相关提案更新指出，自定义[BOLT11][]特征位限制为最大表达值 5114。

- [LDK #2044][]对 LDK 的[BOLT11][]发票路由提示进行了一些更改，LN 接收节点可以使用该机制来建议支出节点使用的路由。此次合并仅建议使用三个通道，且改进了对 LDK 幻影节点的支持 (见[周报 #188][news188 phantom])，并选择了三个通道以提高效率和隐私性。PR 讨论包括了[一些][carman hints]关于提供路线提示对隐私的影响的有见地的[评论][corallo hints]。

## 庆祝 Optech 周报第250期

Bitcoin Optech 的成立，部分是为了“帮助促进改善商业与开源社区之间的关系”。这份周报旨在让使用比特币的企业内部的高管和开发人员更深入地了解开源社区正在构建的内容。因此，我们最初专注于记录可能影响业务的工作。

我们很快发现，不仅企业读者对这些信息感兴趣。许多比特币项目的贡献者没有时间阅读协议开发邮件列表上的所有讨论，或监控其他项目的重大变化。有人整理贡献者们可能感兴趣或影响工作发展的内容，并通知他们，贡献者们表示感谢。

近五年来，我们很高兴提供这项服务。我们试图通过提供[钱包技术兼容性][compatibility matrix]指南，超过 100 个[感兴趣话题][topics]的索引，以及与嘉宾进行的每周讨论[播客][podcast]来扩展这一简单的使命，嘉宾中包括许多贡献者，我们有幸撰写了他们的工作。

如果没有众多贡献者，这一切都不可能实现，过去一年包括： <!-- alphabetical -->
Adam Jonas、
Copinmalin、
David A. Harding、
Gloria Zhao、
Jiri Jakes、
Jon Atack、
Larry Ruane、
Mark "Murch" Erhardt、
Mike Schmidt、
nechteme、
Patrick Schwegler、
Shashwat Vangani、
Shigeyuki Azuchi、
Vojtěch Strnad、
Zhiwei "Jeffrey" Hu
和其他几个对特定主题做出特殊贡献的人。

我们也永远感谢我们的[创始赞助商][founding sponsors] Wences Casares、John Pfeffer、and Alex Morcos，以及我们的许多[财务支持者][financial supporters]。

感谢您阅读。我们希望您在我们发布接下来的 250 份周报时继续这样做。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26094,27195,1783,7568,24,2044" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 24.1rc2]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc1]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[eclair bitcoin.conf]: https://github.com/ACINQ/eclair/pull/1783/files#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5
[carman hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1448840896
[corallo hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1461049958
[hartman powswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021605.html
[hnr powswap]: https://raw.githubusercontent.com/blockrate-binaries/paper/master/blockrate-binaries-paper.pdf
[powswap]: https://powswap.com/
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[founding sponsors]: /en/about/#founding-sponsors
[financial supporters]: /#members
[review club 27501]: https://bitcoincore.reviews/27501
[prioritisetransaction rpc]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[mapDeltas]: https://github.com/bitcoin/bitcoin/blob/fc06881f13495154c888a64a38c7d538baf00435/src/txmempool.h#L450
