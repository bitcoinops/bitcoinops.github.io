---
title: 'Bitcoin Optech Newsletter #276'
permalink: /zh/newsletters/2023/11/08/
name: 2023-11-08-newsletter-zh
slug: 2023-11-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了 Bitcoin-Dev 邮件组的一项即将到来的变更，并简要总结了一项允许聚合多个 HTLC 的提议。此外是我们的常规栏目：Bitcoin Core RP 审核俱乐部会议的总结、软件的新版本和候选版本的公告，以及热门比特币基础设施软件的重大变更的介绍。

## 新闻

- **<!--mailing-list-hosting-->邮件组的托管**：Bitcoin-Dev 邮件组的管理员[宣布][bishop lists]，当前托管邮件组的组织计划在今年结束之后不再托管任何邮件组。在可以预见的时间内，以往的邮件的档案预计会几乎托管在当前的 URL。我们估计邮件转发服务的终止也会影响 Lightning-Dev 邮件组，因为它们也是由同一个组织托管的。

    管理员征求社区的反馈，包括是否接受将邮件组迁移到 Google Groups。如果迁移发生，Optech 将开始使用那个群组作为我们的[新闻信息源][sources]之一。

    我们也注意到，早在这次公告的几个月之前，一些有名的开发者已经开始尝试在 [DelvingBitcoin][] 网上论坛讨论事情。Optech 将立即开始观察这个论坛上的有趣和重要的讨论。{% assign timestamp="1:05" %}

- **<!--htlc-aggregation-with-covenants-->使用限制条款聚合 HTLC**：Johan Torås Halseth 在 Lightning-Dev 邮件组中[提出][halseth agg]了一项使用一种 “限制条款（[covenant][topic covenants]）” 来聚合多个 [HTLCs][topic htlc] 成一个输出的提议；如果一方知道所有的原像，这样的输出就可以一次性花费掉。如果一方只知道一部分原像，TA 就只能取走相应的那部分资金，剩余的资金将由另一方收回。Halseth 指出，这种构造的链上效率更高，而且更能抵御某些类型的 “%#%”。{% assign timestamp="5:36" %}

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们会总结最近一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，列出一些重要的问题和回答。点击下文的问题描述，便可看到会上讨论出的答案。*

“[从  Validation Interface/CScheduler 线程更新手续费估算器][review club 28368]” 是一项由 Abubakar Sadiq Ismail (ismaelsadeeq) 提出的 PR，修改了交易手续费估算器的数据更新方式。（当一个节点的主人要发起一笔交易的时候，就会使用手续费估算。）它将手续费估算在交易池更新（添加或移除交易）时同步更新改成了异步更新。虽然这在整体上加入了更多的处理复杂性，但它提升了关键路径的性能（下文的讨论会证明这一点）。

在发现一个新区块时，交易池内的任何交易，无论与区块所包含的交易重复还是冲突，都会从交易池中移除。因为区块处理和转发是性能关键型（performance-critical）任务，减少处理一个新区块所需的工作量（比如更新手续费估算器）是很有好处的。{% assign timestamp="16:47" %}

{% include functions/details-list.md
  q0="<!--why-is-it-beneficial-to-remove-ctxmempool-s-dependency-on-cblockpolicyestimator-->移除 `CTxMempool` 对 `CBlockPolicyEstimator` 的依赖有什么好处？"
  a0="当前，在收到一个新区块时，`CTxMempool` 的处理会被阻断，同时更新手续费估算器。这会拖慢新区块的处理，因此也会拖延区块的转发。移除 `CTxMempool` 对 `CBlockPolicyEstimator` 的依赖将允许手续费估算异步（在另一个线程中）更新，从而区块验证和转发都可以更快地完成。这项更新也让 `CTxMempool` 的测试变得更加容易。最后，它还允许在未来引入更加复杂的手续费估计算法，而无需担心影响区块验证和转发的性能。"
  a0link="https://bitcoincore.reviews/28368#l-30"

  q1="<!--isn-t-fee-estimation-currently-updated-synchronously-when-transactions-are-added-to-or-removed-from-the-mempool-even-without-a-new-block-arriving-->现在的手续费估算更新跟交易池添加或移除交易（即使没有新区块到达）不是同步的吗？"
  a1="是同步的，但这时候的性能没有在区块验证和转发的时候那么重要。"
  a1link="https://bitcoincore.reviews/28368#l-41"

  q2="<!--are-there-any-benefits-of-the-cblockpolicyestimator-being-a-member-of-ctxmempool-and-updating-it-synchronously-the-current-arrangement-are-there-downsides-to-removing-it-->`CBlockPolicyEstimator` 称为 `CTxMempool` 的一个成员并同步地更新（即当前的安排）有什么好处的吗？移除它又会有什么坏处？"
  a2="同步模式的代码会更加简单，也更易于分析。此外，手续费估算器也对整个交易池了解更充分；一个缺点是需要将手续费估算器所需的所有信息都封装到一个新的 `NewMempoolTransactionInfo` 结构中。不过，手续费估算器并不需要太多信息。"
  a2link="https://bitcoincore.reviews/28368#l-43"

  q3="<!--what-do-you-think-are-the-advantages-and-disadvantages-of-the-approach-taken-in-this-pr-compared-with-the-one-taken-in-pr-11775-that-splits-cvalidationinterface-->你认为这项 PR 所采取的方法，与 [PR 11775][] 所采取的分拆 `CValidationInterface` 的方法相比，有何 优点/缺点？"
  a3="虽然分拆它们似乎很棒，但它们依然有共享的后端（以保证事件的排序良好），所以也做不到非常独立。所以分拆似乎并没有很多实际上的好处。当前这个 PR 更加聚焦，而且尽可能小范围地让手续费估算异步更新。"
  a3link="https://bitcoincore.reviews/28368#l-71"

  q4="<!--in-a-subclass-why-is-implementing-a-cvalidationinterface-method-equivalent-to-subscribing-to-the-event-->在一个子类中，为什么实现一种 `CValidationInterface` 等价于订阅这个事件？"
  a4="`CValidationInterface` 的所有子类都是客户端。这些子类可以实现一些或全部的 `CValidationInterface` 方法（回调），举个例子，连接或断开一个区块、连接一个加入交易池的交易或断开一个从交易池中驱逐的交易。在（通过调用 `RegisterSharedValidationInterface()`）注册之后，任何实现了 `CValidationInterface` 的方法都会在使用 `CMainSignals` 触发这种方法的回调时执行。而每次相应事件发生时，都会触发回调。"
  a4link="https://bitcoincore.reviews/28368#l-90"

  q5="<!--blockconnected-blockconnected-and-newpowvalidblock-newpowvalidblock-are-different-callbacks-which-one-is-asynchronous-and-which-one-is-synchronous-how-can-you-tell-->[`BlockConnected`][BlockConnected] 和 [`NewPoWValidBlock`][NewPoWValidBlock] 是不同的回调。哪一种是异步的、哪一种是同步的？你是怎么辨别的？"
  a5="`BlockConnected` 是异步的； `NewPoWValidBlock` 是同步的。异步的回调会形成一个 “事件”并排队，等待在 `CScheduler` 线程中执行。"
  a5link="https://bitcoincore.reviews/28368#l-105"

  q6="<!--in-commit-4986edb-why-are-we-adding-a-new-callback-mempooltransactionsremovedforconnectedblock-instead-of-using-blockconnected-which-also-indicates-a-transaction-being-removed-from-the-mempool-->为什么我们要在 [commit 4986edb][] 中增加一种新的回调 `MempoolTransactionsRemovedForConnectedBlock`，而不是使用
`BlockConnected` 呢（后者也会暗示一笔交易正从交易池中移除）？"
  a6="手续费估算器需要在任何交易从交易池中移除时知晓（不论出于什么理由），而不能仅仅是在连接着一个区块时才能知晓。此外，手续费估算器还需要一笔交易的基本手续费（base fee），而 `BlockConneted` 是无法提供的（它只能提供一个 `CBlock`）。我们可以将基本手续费添加到 `block.vtx`（交易列表）条目中，但仅仅是为了支持手续费估算就改变这样一个重要而且无处不在的数据结构，是不可取的。"
  a6link="https://bitcoincore.reviews/28368#l-130"

  q7="<!--why-don-t-we-use-a-std-vector-ctxmempoolentry-as-a-parameter-of-mempooltransactionsremovedforblock-callback-this-would-eliminate-the-requirement-for-a-new-struct-type-to-hold-the-per-transaction-information-needed-for-fee-estimation-->为什么不使用 `std::vector<CTxMempoolEntry>` 作为 `MempoolTransactionsRemovedForBlock` 回调的一个参数？这就不需要一种新的结构体类型来保存手续费估算所需的每一笔交易的信息了。"
  a7="手续费估算不需要来自 `CTxMempoolEntry` 的所有字段。"
  a7link="https://bitcoincore.reviews/28368#l-159"

  q8="<!--how-is-the-base-fee-of-a-ctransactionref-computed-->一个 `CTransactionRef` 的基本手续费是如何计算的？"
  a8="所有输入的价值的和减去所有输出的价值的和。但是，回调无法读取输入的价值，因为这是存储在前序交易的输出中的。这就是 `TransactionInfo` 结构体要包含基本手续费的原因。"
  a8link="https://bitcoincore.reviews/28368#l-166"
%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 26.0rc2][] 是这个占主导地位的全节点实现的下一个大版本的候选版本。一份简单的概述[建议了一些测试主题][26.0 testing]，而且 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 也计划在 2023 年 11 月 15 日举行一次会议，致力于测试。{% assign timestamp="26:14" %}

- [Core Lightning 23.11rc1][] 是这种闪电节点实现的下一个大版本的候选。{% assign timestamp="29:26" %}

- [LND 0.17.1-beta.rc1][] 是这种闪电节点实现的一个维护版本的候选。{% assign timestamp="31:28" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Core Lightning #6824][] 更新了 “[交互式注资协议][topic dual funding]” 的实现，以 “在发送 `commitment_signed` 时存储状态，并给 `chennel_reestablish`【添加】一个 `next_funding_txid` 字段，以向对等节点请求重新发送己方没有收到的签名。”本更新基于拟议的 “[双向注资 PR][bolts #851]” 的一个[更新][36c04c8ac]。{% assign timestamp="32:38" %}

- [Core Lightning #6783][] 弃用了 `large-channels` 配置选项，让[大容量通道][topic large channels]和大额支付总是启用。{% assign timestamp="34:59" %}

- [Core Lightning #6780][] 提升了对使用 “锚点输出（[anchor outputs][topic anchor outputs]）” 的链上交易手续费追加手段的支持。{% assign timestamp="36:29" %}

- [Core Lightning #6773][] 允许 `decode` RPC 验证一个备份文件的内容是有效的、并包含了执行一次完整的复原所需的最新信息。{% assign timestamp="39:06" %}

- [Core Lightning #6734][] 更新了 `listfunds` RPC，以在用户想要运用 “子为父偿（[CPFP][topic cpfp]）” 为合作关闭交易追加手续费时提供所需的信息。{% assign timestamp="39:58" %}

- [Eclair #2761][] 允许转发有限数量的 [HTLCs][topic htlc] 给对方，即使对方的余额已低于通道保证金的要求。这可以帮助解决 “通道拼接（[splicing][topic splicing]）” 或者[双向注资][topic dual funding]之后可能发生的 *资金滞留问题（suck funds problem）*。见[周报 #253][news253 stuck] 了解 Eclair 为资金滞留问题提出的另一项缓解措施。{% assign timestamp="41:02" %}

<div markdown="1" class="callout">
## 想要了解更多？

想要了解更多本周新闻部分提到的话题的讨论，请加入我们于每周四（周报发布的后一天）的 UTC 时间 15:00 在 [Twitter Spaces][@bitcoinoptech] 举办的 Bitcoin Optech 回顾。聊天室里的讨论也会记录在我们的[播客][podcast]页面并长期留存。
</div>


{% include references.md %}
{% include linkers/issues.md v=2 issues="6824,6783,6780,6773,6734,2761,851" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta.rc1
[sources]: /internal/sources/
[bishop lists]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022134.html
[delvingbitcoin]: https://delvingbitcoin.org/
[halseth agg]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-October/004181.html
[36c04c8ac]: https://github.com/lightning/bolts/pull/851/commits/36c04c8aca48e04d1fba64d968054eba221e63a1
[news253 stuck]: /zh/newsletters/2023/05/31/#eclair-2666
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Testing-Guide-Topics
[review club 28368]: https://bitcoincore.reviews/28368
[pr 11775]: https://github.com/bitcoin/bitcoin/pull/11775
[tx add]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/validation.cpp#L1217
[tx remove]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/txmempool.cpp#L504
[BlockConnected]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L227
[NewPoWValidBlock]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L260
[commit 4986edb]: https://github.com/bitcoin-core-review-club/bitcoin/commit/4986edb99f8aa73f72e87f3bdc09387c3e516197
