---
title: 'Bitcoin Optech Newsletter #293'
permalink: /zh/newsletters/2024/03/13/
name: 2024-03-13-newsletter-zh
slug: 2024-03-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一篇关于潜在软分叉的免信任链上下注的文章，并为比特币人链接到了一篇 Chia Lisp 的详细概述。此外还有我们的常规部分：其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--Trustless-onchain-betting-on-potential-soft-forks-->关于潜在软分叉的免信任链上下注：** ZmnSCPxj 在 Delving Bitcoin 上[发布了][zmnscpxj bet]一个协议，用于将 UTXO 的控制权交给正确预测某特定软分叉是否会激活的一方。例如，Alice 认为某特定软分叉将会激活，她有兴趣获得更多比特币；Bob 也有兴趣获得更多比特币，但他认为该分叉不会激活。他们同意按照双方商定的比率（例如 1：1）合并一些比特币，如果在某个时间点之前该分叉被激活，Alice 将获得所有合并的比特币；如果未被激活，Bob 将获得所有合并的比特币。如果在截止日期之前发生持续的链分裂，其中一条链激活了该分叉，另一条链禁止该分叉，Alice 将在激活链上获得合并的比特币，Bob 将在禁止激活链上获得合并的比特币。

    这个基本想法以前已经被提出过([示例][rubin bet])，但 ZmnSCPxj 的版本涉及到了至少一个潜在的未来软分叉，即 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 的具体情况。ZmnSCPxj 还简要考虑了将该构造推广到其他提议的软分叉的挑战，尤其是那些升级了 `OP_SUCCESSx` 操作码的软分叉。

- **<!--Overview-of-Chia-Lisp-for-Bitcoiners-->为比特币人概述 Chia Lisp：** Anthony Towns 在 Delving Bitcoin 上[发布了][towns lisp]一篇关于 Chia 密码货币所使用的 [Lisp][] 变体的详细概述。Towns 之前曾提议通过软分叉将基于 Lisp 的脚本语言引入比特币(见[周报 #191][news191 lisp])。强烈建议对这个话题感兴趣的人都阅读他的文章。

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了 Bitcoin Core PR 审核俱乐部会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[重新启用 `OP_CAT`][review club bitcoin-inquisition 39]是 Armin Sabouri（GitHub 0xBEEFCAF3）的 PR，它重新引入了 [OP_CAT][topic op_cat] 操作码，但仅限于 [signet][topic signet] [Bitcoin Inquisition][bitcoin inquisition repo] 和 [tapscript][topic tapscript] (taproot 脚本)。中本聪（Satoshi Nakamoto）在 2010 年禁用了此操作码，可能是出于过度谨慎。该操作将脚本评估堆栈上的前两个元素替换为这些元素的串联。

没有讨论 `OP_CAT` 的动机。

{% include functions/details-list.md
  q0="<!--what-are-the-various-conditions-under-which-the-execution-of-op-cat-may-result-in-failure-->在哪些条件下，执行 `OP_CAT` 可能导致失败？"
  a0="堆栈上少于 2 个项目、生成的项目太大、被脚本验证标志禁止（例如，软分叉尚未激活），并出现在非 Taproot 脚本中（见证版本 0 或传统版本）。"
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-46"

  q1="<!--op-cat-redefines-one-of-the-op-successx-opcodes-why-doesn-t-it-redefine-one-of-the-op-nopx-opcodes-which-have-also-been-used-to-implement-soft-fork-upgrades-in-the-past-->`OP_CAT` 重新定义了 `OP_SUCCESSx` 操作码之一。为什么它不重新定义 `OP_NOPx` 操作码之一（过去也用于实现软分叉升级）？"
  a1="`OP_SUCCESSx` 和 `OP_NOPx` 操作码都可以重新定义以实现软分叉，因为它们限制了验证规则（它们总是成功，而重新定义的操作码可能会失败）。
      由于脚本执行在 `OP_NOP` 后继续执行，因此重新定义 `OP_NOP` 操作码不会影响执行堆栈（否则，过去失败的脚本可能会成功，这将放宽规则）。
      重新定义 `OP_SUCCESS` 操作码可能会影响堆栈，因为 `OP_SUCCESS` 立即终止脚本（成功）。由于 `OP_CAT` 需要影响堆栈，因此它无法重新定义 `OP_NOP` 操作码之一。"
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-33"

  q2="<!--this-pr-adds-both-script-verify-op-cat-and-script-verify-discourage-op-cat-why-are-both-needed-->这个 PR 同时增加了 `SCRIPT_VERIFY_OP_CAT` 和 `SCRIPT_VERIFY_DISCOURAGE_OP_CAT`。为什么两者都是必要的？"
  a2="它允许软分叉被逐步引入。首先，两者都设为 `true` (启用共识但不中继或挖掘)，直到大多数网络节点升级。然后将 `SCRIPT_VERIFY_DISCOURAGE_OP_CAT` 设置为 `false` 以启用实际使用。如果 Bitcoin Inquisition 实验以后失败，该过程可以逆向运行。如果两者都被设置为 `false`，`OP_CAT` 只是 `OP_SUCCESS`。"
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-60"
%}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning v24.02.1][] 是这个 LN 节点实现的一个小型更新，包含“一些小修复[和]路径算法成本函数的改进”。

- [Bitcoin Core 26.1rc1][] 是网络主要全节点实现的维护版本的一个候选版本。

- [Bitcoin Core 27.0rc1][] 是网络主要全节点实现的下一个主要版本的候选版本。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [LND #8136][] 更新了 `EstimateRouteFee` RPC，新增接收发票和超时参数。将选择支付发票的路径并发送[支付探针][topic payment probes]。如果探针在超时之前成功完成，则返回被选择路线的成本。否则，将返回错误。

- [LND #8499][] 对用于[简单 taproot 通道][topic simple taproot channels]的 Type-Length-Value (TLV) 类型进行了重大更改，以改进 LND 的 API。我们目前并不清楚是否有其他 LN 实现正在使用简单 taproot 通道，但如果有任何实现在使用它，请注意这可能构成重大更改。

- [LDK #2916][] 为将支付原象转换为支付哈希添加了一个简单的 API。LN 发票包括一个支付哈希；要领取支付，最终接收者释放与该哈希对应的原象（并且沿着路径的每个跳使用其从下游对等节点接收的原象来领取来自上游对等节点的支付）。由于可以从原象派生哈希（但反之不行），接收者和转发节点可能只存储原象。这个 API 可以让他们根据需求轻松地派生哈希值。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8136,8499,2916" %}
[zmnscpxj bet]: https://delvingbitcoin.org/t/economic-majority-signaling-for-op-ctv-activation/635
[rubin bet]: https://blog.bitmex.com/taproot-you-betcha/
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[towns lisp]: https://delvingbitcoin.org/t/chia-lisp-for-bitcoiners/636
[lisp]: https://zh.wikipedia.org/wiki/LISP
[bitcoin core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[Core Lightning v24.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.1
[review club bitcoin-inquisition 39]: https://bitcoincore.reviews/bitcoin-inquisition-39
