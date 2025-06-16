---
title: 'Bitcoin Optech Newsletter #357'
permalink: /zh/newsletters/2025/06/06/
name: 2025-06-06-newsletter-zh
slug: 2025-06-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报分享了一篇关于不需要旧见证数据同步全节点的分析。此外还包括我们的常规部分：总结了关于更改比特币共识规则的讨论、新版本和候选版本的公告，以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--syncing-full-nodes-without-witnesses-->不需要见证数据同步全节点：** Jose SK 在 Delving Bitcoin 上[发布][sk nowit]了他进行的一项[分析][sk nowit gist]的总结，该分析关于允许新启动的具有特定配置的全节点避免下载某些历史区块链数据的安全权衡。默认情况下，Bitcoin Core 节点使用 `assumevalid` 配置设置，跳过对在运行的 Bitcoin Core 版本发布前一两个月创建的区块中的脚本进行验证。虽然默认禁用，但许多 Bitcoin Core 用户也设置了 `prune` 配置，在验证区块后的一段时间删除这些区块（区块保留多长时间取决于区块的大小和用户选择的具体设置）。

  SK 认为，仅用于验证脚本的见证数据不应该由剪枝节点下载用于 assumevalid 区块，因为它们不会用它来验证脚本，并且最终会删除它。他写道，跳过见证数据下载“可以减少超过 40% 的带宽使用”。

  Ruben Somsen [认为][somsen nowit]这在某种程度上改变了安全模型。虽然脚本没有被验证，但下载的数据是根据区块头默克尔根到 coinbase 交易再到见证数据的承诺进行验证的。这确保了数据在节点最初同步时是可用且未损坏的。如果没有人定期验证数据的存在，它可能会丢失，就像至少一种山寨币[已经发生过][ripple loss]的那样。

  在撰写本文时，讨论仍在进行中。

## 共识变更

_每月一次的总结比特币共识规则变更提案和讨论的栏目。_

- **<!--quantum-computing-report-->量子计算报告：** Clara Shikhelman 在 Delving Bitcoin 上[发布][shikelman quantum]了她与 Anthony Milton 共同撰写的一份[报告][sm report]的总结，该报告涉及快速量子计算机对比特币用户的风险、几种[量子抵抗][topic quantum resistance]途径的概述，以及升级比特币协议所涉及的权衡分析。作者发现有 400 万到 1000 万 BTC 可能容易受到量子盗窃的威胁，现在可以进行一些缓解措施，比特币挖矿在短期或中期内不太可能受到量子计算的威胁，并且升级需要广泛的共识。

- **<!--transaction-weight-limit-with-exception-to-prevent-confiscation-->带有防止被没收例外的交易重量限制：** Vojtěch Strnad 在 Delving Bitcoin 上[发布][strnad limit]了一个共识变更的想法，限制区块中大多数交易的最大重量。这个简单的规则只允许一个区块中有一个大于 400000 重量单位（100000 vbytes）的交易，前提是它是该区块中除 coinbase 交易外的唯一交易。Strnad 和其他人描述了限制最大交易重量的动机：

  * _更容易的区块模板优化：_ 与整体限制相比，项目越小，找到[背包问题][knapsack problem]的近似最优解就越容易。这部分是由于最小化最后剩余空间的数量，较小的项目留下的未使用空间更少。

  * _更简单的中继策略：_ 节点之间中继未确认交易的策略预测哪些交易将被挖出，以避免浪费带宽。巨型交易使得准确预测变得更加困难，因为即使顶部费率的微小变化也可能导致它们被延迟或驱逐。

  * _避免挖矿中心化：_ 确保中继全节点能够处理几乎所有交易，防止特殊交易的用户需要支付[协议外手续费用][topic out-of-band fees]，这可能导致挖矿中心化。

  Gregory Sanders [指出][sanders limit]，基于 Bitcoin Core 12 年一贯的中继策略，简单地软分叉一个最大重量限制而不设任何例外可能是合理的。Gregory Maxwell [补充说][maxwell limit]，只花费软分叉前创建的 UTXO 的交易可以允许例外以防止没收，并且[临时软分叉][topic transitory soft forks]将允许限制在社区决定不更新时过期。

  额外的讨论研究了需要大型交易的各方的需求，主要是近期的 [BitVM][topic acc] 用户，以及他们是否有可用的替代方法。

- **<!--removing-outputs-from-the-utxo-set-based-on-value-and-time-->****基于价值和时间从 UTXO 集中移除输出：** Robin Linus 在 Delving Bitcoin 上[发布][linus dust]了一个软分叉提案，用于在一段时间后从 UTXO 集中移除低价值输出。讨论了该想法的几种变体，主要有两种替代方案：

  * _销毁旧的不经济资金：_ 长时间未花费的小额输出将变得不可花费。

  * _要求旧的不经济资金与存在证明一起花费：_ [utreexo][topic utreexo] 或类似系统可用于允许交易证明它花费的输出是 UTXO 集的一部分。旧的和[不经济的输出][topic uneconomical outputs]需要包含这个证明，但较新和较高价值的输出仍将存储在 UTXO 集中。

  任何一种解决方案都将有效限制 UTXO 集的最大大小（假设有最小值和 2100 万比特币限制）。讨论了设计的几个有趣的技术方面，包括在这种应用中可能更实用的 utreexo 证明的替代方案。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 25.05rc1][] 是这个热门的闪电网络节点实现的下一个主要版本的候选版本。

- [LND 0.19.1-beta.rc1][] 是这个热门的闪电网络节点实现的维护版本的候选版本。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #32582][] 添加了新的日志记录来测量[致密区块重建][topic compact block relay]的性能，通过跟踪节点从其对等节点请求的交易总大小（`getblocktxn`），节点发送给其对等节点的交易数量和总大小（`blocktxn`），并在 `PartiallyDownloadedBlock::InitData()` 开始时添加时间戳，以跟踪仅交易池查找步骤需要多长时间（在高带宽和低带宽模式下）。参见周报 [#315][news315 compact] 了解之前关于致密区块重建的统计报告。

- [Bitcoin Core #31375][] 添加了一个新的 `bitcoin -m` CLI 工具，它包装并执行[多进程][multiprocess project]二进制文件 `bitcoin node`（`bitcoind`）、`bitcoin gui`（`bitcoinqt`）、`bitcoin rpc`（`bitcoin-cli -named`）。目前，这些功能与单体二进制文件的方式相同，只是它们支持 `-ipcbind` 选项（参见周报 [#320][news320 ipc]），但未来的改进将使节点运行者能够在不同的机器和环境中独立启动和停止组件。参见[周报 #353][news353 pr review] 了解涵盖此 PR 的 Bitcoin Core PR 审核俱乐部。

- [BIPs #1483][] 合并了 [BIP77][]，该提案提出了 [payjoin v2][topic payjoin]，一种异步无服务器变体，其中发送者和接收者将其加密的 PSBT 交给一个 payjoin 目录服务器，该服务器只存储和转发消息。由于目录无法读取或更改有效载荷，因此任何一个钱包都不需要托管公共服务器或同时在线。参见周报 [#264][news264 payjoin] 了解关于 payjoin v2 的更多背景。

{% include snippets/recap-ad.md when="2025-06-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32582,31375,1483" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ripple loss]: https://x.com/JoelKatz/status/1919233214750892305
[sk nowit]: https://delvingbitcoin.org/t/witnessless-sync-for-pruned-nodes/1742/
[sk nowit gist]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1
[somsen nowit]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1?permalink_comment_id=5597316#gistcomment-5597316
[shikelman quantum]: https://delvingbitcoin.org/t/bitcoin-and-quantum-computing/1730/
[sm report]: https://chaincode.com/bitcoin-post-quantum.pdf
[strnad limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/
[knapsack problem]: https://zh.wikipedia.org/wiki/%E8%83%8C%E5%8C%85%E9%97%AE%E9%A2%98
[sanders limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/2
[maxwell limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/4
[linus dust]: https://delvingbitcoin.org/t/dust-expiry-clean-the-utxo-set-from-spam/1707/
[lnd 0.19.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta.rc1
[news315 compact]: /zh/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news320 ipc]: /zh/newsletters/2024/09/13/#bitcoin-core-30509
[news264 payjoin]: /zh/newsletters/2023/08/16/#serverless-payjoin-payjoin
[news353 pr review]: /zh/newsletters/2025/05/09/#bitcoin-core-pr-审核俱乐部