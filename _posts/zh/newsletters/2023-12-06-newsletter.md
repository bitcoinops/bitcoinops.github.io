---
title: 'Bitcoin Optech Newsletter #280'
permalink: /zh/newsletters/2023/12/06/
name: 2023-12-06-newsletter-zh
slug: 2023-12-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了关于集群交易池提议的几次讨论，并总结了使用 warnet 进行的测试的结果。此外还有我们的常规部分：其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--cluster-mempool-discussion-->集群交易池讨论：** 致力于[集群交易池][topic cluster mempool]的 Bitcoin Core 开发人员在 Delving Bitcoin 论坛上成立了一个[工作组][wg-cluster-mempool] (WG)。集群交易池是一项旨在在尊重交易顺序的前提下，更容易地操作交易池的提案。父交易在子交易之前得到确认才是有效比特币交易顺序，父交易要么放在比所有子交易早的区块中，要么在同一区块中排在前面。在集群交易池设计中，相关的一笔或多笔交易_集群_被设计并划分为根据交易费率排序的_块_。只要所有之前（更高费率的）未确认的块都在同一个区块中较早地包含，任何块都可以被包含在这一个区块中，直到达到区块的最大重量。

  一旦所有交易都被关联到集群中，并且这些集群被拆分成块，就很容易选择哪些交易要包含在一个区块中：选择最高交易费率的块，然后是第二高的，如此反复，直到区块被填满。当使用这种算法时，很明显，交易池中交易费率最低的块是最不太可能被包括在区块中的块。所以，当交易池已满，需要驱逐一些交易以减小交易池大小时，我们可以使用相反的算法：驱逐最低交易费率的块，然后是第二低的，如此反复，直到本地交易池大小再次低于预期的最大值。

  现在任何人都可以阅读工作组档案，但只有受邀成员才能发帖。他们讨论的一些值得注意的话题包括：

  - [<!--cluster-mempool-definitions-and-theory-->集群交易池定义和理论][clusterdef]定义了设计集群交易池所使用的术语。它还描述了少量用来展示了这种设计的一些有用属性的定理。该主题中目前唯一的帖子（截至写作时）对于理解工作组的其他讨论非常有用，尽管其作者（Pieter Wuille）[警告][wuille incomplete]说它仍然“非常不完整”。

  - [<!--merging-incomparable-linearizations-->合并不可比较的线性化][cluster merge]着眼于如何为同一组交易合并两组不同的块（“分块”），尤其是_不可比较的_分块。通过比较不同的块（“分块”）列表，我们可以确定哪个对矿工更有利。可以通过检查其中一个分块是否总是在任意数值的 vbytes 内累积相同或更大的费用（与块的大小离散）来比较这些分块。例如：

    ![可比较的分块](/img/posts/2023-12-comparable-chunkings.png)

    如果两个分块中，一个在一定数值的 vbytes 内累积了更多的费用，而另一个在更大数值的 vbytes 内累积了更多的费用，那么它们就是无法比较的。例如：

    ![不可比较的分块](/img/posts/2023-12-incomparable-chunkings.png)

    作为先前链接的主题中所注明的定理之一，“如果一个图有两个不可比较的分块，那么肯定存在另一个分块，它严格优于这两个分块”。这意味着用于合并两个不同的不可比较分块的有效方法可以成为改善矿工盈利能力的强大工具。例如，收到了一个与交易池中已有的其他交易相关的新交易，因此它的集群需要更新，这意味着它的分块也需要更新。可以执行两种不同的更新方法：

    1. 从头开始计算更新集群的新分块。对于大型集群，找到最佳的分块可能在计算上不切实际，因此新的分块可能劣于旧的分块。

    2. 通过在有效位置（父交易在子交易之前）插入新交易来更新先前集群的先前分块。这样做的优点是保留未修改分块中的任何现有优化，但缺点是可能将交易放置在次优位置。

    在完成了两种不同类型的更新之后，通过比较可能会发现其中一个严格优于另一个，这种情况下就可以使用它。但是，如果这些更新是无法比较的，那么可以使用一种合并方法来产生一个等同或更好的结果，从而产生一个第三个分块，该分块将捕获到两种方法的最佳方面————在新的分块更好时使用它们，但在旧的分块更接近最佳状态时保留它们。

  - [<!--post-cluster-package-rbf-->集群后的交易包 RBF][cluster rbf]讨论了一种替代当前用于[手续费替换][topic rbf]规则的方法。当接收到一个或多个交易的有效替换时，可以生成所有受其影响的集群的临时版本，并导出集群更新的分块。这可以与当前在交易池中的原始集群（不包括替换交易）的分块进行比较。如果包含替换的分块对于任何数值的 vbytes，总是赚取相等或更多的费用，并且如果它足以支付中继费用而增加交易池中的总费用，则应将其包含在交易池中。

    这种基于证据的评估可以替代当前在 Bitcoin Core 中用于确定是否应替换交易的几个[启发式][mempool replacements]方法，有潜力在几个方面改进手续费替换（RBF）规则，包括拟议的[替换交易包中继][topic package relay]。几个[其他][cluster rbf-old1]主题[也][cluster rbf-old2]讨论了[这个][cluster rbf-old3]话题。

- **<!--testing-with-warnet-->使用 warnet 进行测试：** Matthew Zipkin 在 Delving Bitcoin 上[发帖][zipkin warnet]，介绍了他使用 [warnet][] 运行的一些模拟结果，warnet 是一个启动大量 Bitcoin 节点并在它们之间定义一组连接（通常在测试网上）的程序。Zipkin 的结果显示，如果合并几个对等节点管理代码的拟议更改（独立或一起更改），将使用多少额外内存。他还指出，他很高兴使用仿真来测试其他拟议更改，并定量分析拟议攻击的影响。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[测试 Bitcoin Core 26.0 候选版本][review club v26-rc-testing]是一次并没有审核特定 PR 的审核俱乐部会议，而是一个集体测试活动。

在每次[主要的 Bitcoin Core 版本][major Bitcoin Core release]发布之前，社区的广泛测试被认为是至关重要的。因此，一个志愿者会为一个[候选版本][release candidate]编写测试指南，以便尽可能多的人可以进行有效的测试，而无需独自确定版本中的新内容或更改，并重新设计各种设置步骤来测试这些功能或更改。

测试可能会很困难，因为当遇到意外行为时，往往不清楚是由于实际的错误还是测试人员犯了错误。向开发人员报告“假”的错误会浪费他们的时间。为了缓解这些问题并促进测试工作，我们的审核俱乐部会为特定发布候选版本（在此例中为26.0rc2）举行一次审核会议。

[26.0 候选版本测试指南][26.0 testing]是由 Max Edwards 撰写的，他还在 Stéphan（stickies-v）的帮助下主持了审核会议。

与会者也被鼓励通过阅读[26.0 版本说明][26.0 release notes]来获得测试想法。

本次审核俱乐部会议涉及两个 RPC，即 [`getprioritisedtransactions`][PR getprioritisedtransactions](也在[之前的审核俱乐部会议][news250 pr review]中讨论过，尽管该 RPC 的名称在那次审核俱乐部会议后被更改了)，以及 [`importmempool`][PR importmempool]。版本说明中，“[新 RPCs][New RPCs]” 的部分描述了这些以及其他新增的 RPC。会议还覆盖了 [V2 传输(BIP324)][topic v2 p2p transport]，并打算涵盖 [TapMiniscript][PR TapMiniscript]，但由于时间限制，这个话题没有讨论。

{% include functions/details-list.md
  q0="<!--which-operating-systems-are-people-running-->人们正在运行哪些操作系统？"
  a0="Ubuntu 22.04 在 WSL (适用于 Linux 的 Windows 子系统)；macOS 13.4 (M1 芯片)."
  a0link="https://bitcoincore.reviews/v26-rc-testing#l-18"

  q1="<!--what-are-your-results-testing-getprioritisedtransactions-->你测试 `getprioritisedtransactions` 的结果是什么？"
  a1="与会者报告说，它按预期工作，但有人注意到 [`prioritisetransaction`][prioritisetransaction] 的影响是叠加的；也就是说，对同一笔交易运行两次会使其费用翻倍。这是预期的行为，因为费用参数会被_添加到_交易已有的优先级中。"
  a1link="https://bitcoincore.reviews/v26-rc-testing#l-32"

  q2="<!--what-are-your-results-testing-importmempool-->你对 `importmempool` 的测试结果是什么？"
  a2="一位与会者收到错误消息，“只有在区块下载和同步完成后才能导入交易池”，但等待 2 分钟后，RPC 成功了。另一位参与者指出这需要很长时间才能完成。"
  a2link="https://bitcoincore.reviews/v26-rc-testing#l-45"

  q3="<!--what-happens-if-we-interrupt-the-cli-process-during-the-import-then-restart-it-without-stopping-bitcoind-->如果在导入过程中中断 CLI 进程，然后重新启动它(而不停止 `bitcoind`)，会发生什么？"
  a3="这似乎并没有造成任何问题；第二个导入请求如期完成。似乎即使在中断 CLI 命令之后，导入过程仍在继续进行，并且第二个请求并没有（例如）导致两个导入线程同时运行并互相冲突。"
  a3link="https://bitcoincore.reviews/v26-rc-testing#l-91"

  q4="<!--what-are-your-results-running-v2-transport-->你运行 V2 传输的结果如何？"
  a4="与会者无法连接到已知的启用了主网 V2 的节点；它似乎没有接受连接请求。有人提出，也许该节点所有的入站槽都已被占用（因此无法接受新的连接请求）。因此，会议期间无法进行 P2P 测试。"
  a4link="https://bitcoincore.reviews/v26-rc-testing#l-115"
%}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 26.0][] 是占主导地位的全节点实现的下一个主要版本。此版本包括对[版本 2 传输协议][topic v2 p2p transport]的实验性支持，对 [taproot][topic taproot] 中 [miniscript][topic miniscript] 的支持，用于 [assumeUTXO][topic assumeutxo] 状态的新 RPC，以及用于处理交易[包][topic package relay]的实验性 RPC(目前尚不支持中继)，以及其他众多改进和错误修复。

- [LND 0.17.3-beta.rc1][] 是一个包含多个错误修复的候选版本。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #28848][] 更新了 `submitpackage` RPC，使得在任何交易失败时更加有帮助。它不是只在遇到第一个错误时抛出失败信息 `JSONRPCError`，而会在可能的情况下返回每个交易的错误结果。

- [LDK #2540][] 建立在 LDK 最近的[盲路径][topic rv routing]工作(见周报 [#257][news257 ldk2120]和[#266][news266 ldk2411])的基础上，它通过支持在盲路径中作为引路节点（intro node）进行转发，并且是 LDK 的 BOLT12 [offers][topic offers] 关于跟踪[问题][LDK #1970]的一部分。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28848,2540,1970" %}
[bitcoin core 26.0]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[wg-cluster-mempool]:  https://delvingbitcoin.org/c/implementation/wg-cluster-mempool/9
[clusterdef]: https://delvingbitcoin.org/t/clustermempool-definitions-theory/202
[cluster merge]: https://delvingbitcoin.org/t/merging-incomparable-linearizations/209/38
[cluster rbf]: https://delvingbitcoin.org/t/post-clustermempool-package-rbf-per-chunk-processing/190
[cluster rbf-old1]: https://delvingbitcoin.org/t/defunct-post-clustermempool-package-rbf/173
[cluster rbf-old2]: https://delvingbitcoin.org/t/defunct-cluster-mempool-package-rbf-sketch/171
[cluster rbf-old3]: https://delvingbitcoin.org/t/cluster-mempool-rbf-thoughts/156
[zipkin warnet]: https://delvingbitcoin.org/t/warnet-simulations/232
[warnet]: https://github.com/bitcoin-dev-project/warnet
[wuille incomplete]: https://github.com/bitcoinops/bitcoinops.github.io/pull/1421#discussion_r1414487021
[mempool replacements]: https://github.com/bitcoin/bitcoin/blob/fa9cba7afb73c01bd2c8fefd662dfc80dd98c5e8/doc/policy/mempool-replacements.md
[LND 0.17.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta.rc1
[review club v26-rc-testing]: https://bitcoincore.reviews/v26-rc-testing
[major bitcoin core release]: https://bitcoincore.org/en/lifecycle/#major-releases
[26.0 release notes]: https://github.com/bitcoin/bitcoin/blob/44d8b13c81e5276eb610c99f227a4d090cc532f6/doc/release-notes.md
[new rpcs]: https://github.com/bitcoin/bitcoin/blob/44d8b13c81e5276eb610c99f227a4d090cc532f6/doc/release-notes.md#new-rpcs
[news250 pr review]: /zh/newsletters/2023/05/10/#bitcoin-core-pr-审核俱乐部
[release candidate]: https://bitcoincore.org/en/lifecycle/#versioning
[pr getprioritisedtransactions]: https://github.com/bitcoin/bitcoin/pull/27501
[pr importmempool]: https://github.com/bitcoin/bitcoin/pull/27460
[pr tapminiscript]: https://github.com/bitcoin/bitcoin/pull/27255
[prioritisetransaction]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[news257 ldk2120]: /zh/newsletters/2023/06/28/#ldk-2120
[news266 ldk2411]: /zh/newsletters/2023/08/30/#ldk-2411
