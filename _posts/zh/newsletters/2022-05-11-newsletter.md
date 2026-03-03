---
title: 'Bitcoin Optech Newsletter #199'
permalink: /zh/newsletters/2022/05/11/
name: 2022-05-11-newsletter-zh
slug: 2022-05-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的简短 Newsletter 总结了一次 Bitcoin Core PR 审查俱乐部会议，并描述了 Rust Bitcoin 的一次更新。

## 新闻

本周没有重要新闻。我们之前已经报道的话题，包括 [OP_CHECKTEMPLATEVERIFY 操作码][topic op_checktemplateverify]和 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]，收到了更多评论——但大部分讨论要么是非技术性的，要么是关于一些我们认为对广大读者并不重要的细节。在本期 Newsletter 编辑期间，开发者邮件列表收到几篇有趣的帖子；我们将在下周详细介绍它们。

## Bitcoin Core PR 审查俱乐部

*本月专栏，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 的会议，突出一些重要问题与解答。点击下面的问题可查看会议回答摘要。*

[通过修剪阻挡器改进裁剪节点上的索引][review club pr] 是 Fabian Jahr 提交的一个 PR，引入了一种新的方法来决定何时可以安全地从区块存储中裁剪区块。该新方法使得裁剪节点能够维护 Coinstats 索引，并移除了验证模块对索引相关代码的依赖。

{% include functions/details-list.md

  q0="<!--q0-->Bitcoin Core 目前有哪些索引，它们各自的作用是什么？"
  a0="一个节点最多可以维护三种可选索引，以帮助高效地从磁盘检索数据。交易索引（`-txindex`）将交易哈希映射到包含该交易的区块。区块过滤器索引（`-blockfilterindex`）为每个区块索引 BIP157 区块过滤器。Coinstats 索引（`-coinstatsindex`）存储 UTXO 集的统计信息。"
  a0link="https://bitcoincore.reviews/21726#l-28"

  q1="<!--q1-->什么是循环依赖？为什么我们要尽量避免循环依赖？"
  a1="当两个代码模块彼此都离不开对方才能工作时，就存在循环依赖。循环依赖本身不是安全问题，但它意味着代码组织不良，并通过增加单独构建、使用和测试特定模块或功能的难度来阻碍开发。"
  a1link="https://bitcoincore.reviews/21726#l-44"

  q2="<!--q2-->在 [此提交][review club commit]中引入的修剪阻挡器是如何工作的？"
  a2="该 PR 引入了一张“修剪锁”列表，为每个索引记录必须保留的最早区块高度。在 `CChainState::FlushStateToDisk` 中，当节点决定要裁剪哪些区块时，它会避免裁剪高度高于这些值的区块。每当某个索引更新其已知的最佳区块高度时，相应的修剪锁也会被更新。"
  a2link="https://bitcoincore.reviews/21726#l-68"

  q3="<!--q3-->与旧方法相比，这种修剪方式的优缺点是什么？"
  a3="此前，`CChainState::FlushStateToDisk` 中的逻辑会向索引查询其最佳高度，以确定停止裁剪的区块位置；因此索引与验证逻辑相互依赖。现在，修剪锁被主动计算，可能计算得更频繁，但验证过程不再需要查询索引。"
  a3link="https://bitcoincore.reviews/21726#l-92"
%}

## Notable code and documentation changes

*本周 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的代码和文档更改。*

- [Rust Bitcoin #716][Rust Bitcoin #716] 新增了 `amount::Display`，一种可配置的显示类型，用于面向用户的金额或其他数值表达。该补丁默认将所有数字表示压缩到最小宽度，从而减少多余的零，这些多余的零会让 [BIP21][BIP21] URI 不必要地变长，常常导致二维码尺寸更大或更难扫描。


{% include references.md %}
{% include linkers/issues.md v=2 issues="716" %}
[review club commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/527ef4463b23ab8c80b8502cd833d64245c5cfc4
[review club pr]: https://bitcoincore.reviews/21726
