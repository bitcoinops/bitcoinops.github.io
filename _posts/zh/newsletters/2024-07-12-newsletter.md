---
title: 'Bitcoin Optech Newsletter #311'
permalink: /zh/newsletters/2024/07/12/
name: 2024-07-12-newsletter-zh
slug: 2024-07-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括我们的常规部分：其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

*本周在我们的任何信息[来源][sources]中都没有发现任何重大新闻。为了好玩，您可能想查看最近一笔[有趣的交易][interesting transaction]。*

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[包括 PoW 难度调整修复的 Testnet4][review club 29775]是 [Fabian Jahr][gh fjahr] 提出的 PR ，引入的新的测试网络以取代 Testnet3 。Testnet4 同时修复了长期存在的难度调整和时间扭曲漏洞。它是
[邮件列表讨论的][ml testnet4]结果，并附有[BIP 提案][bip testnet4]。

{% include functions/details-list.md
  q0="<!--aside-from-the-consensus-changes-what-differences-do-you-see-between-testnet-4-and-testnet-3-particularly-the-chain-params-->除了共识变化外，你在 Testnet 4 和 Testnet 3 之间看到的其他区别是什么，特别是在链参数方面？"
  a0="过去软分叉的部署高度都设置为 1，这意味着这些软分叉从一开始就处于激活状态。Testnet4 还使用不同的端口(`48333`)和消息开始(messagestart)，并且它有一个新的创世区块消息。"
  a0link="https://bitcoincore.reviews/29775#l-29"

  q1="<!--how-does-the-20-min-exception-rule-work-in-testnet-3-how-does-this-lead-to-the-block-storm-bug-->Testnet 3 中的 20 分钟例外规则如何工作？这如何导致区块风暴漏洞？"
  a1="如果一个新区块的时间戳比上一个区块的时间戳晚出超过 20 分钟，则允许其具有最低工作量证明难度。下一个区块再次受“真实”难度的约束，除非它也符合 20 分钟例外规则。这个例外是为了在算力高度可变的环境中使链能够出块。由于 `GetNextWorkRequired()` 实现中的一个漏洞，当难度周期的最后一个区块是最低难度区块时，难度实际上会被重置(而不是仅对一个区块暂时降低)。"
  a1link="https://bitcoincore.reviews/29775#l-47"

  q2="<!--why-was-the-time-warp-fix-included-in-the-pr-how-does-the-time-warp-fix-work-->为什么在 PR 中包含了时间扭曲的修复？时间扭曲修复是如何工作的？"
  a2="[时间扭曲][topic time warp]攻击允许攻击者显著改变区块生产速率，因此在修复最低难度错误的同时修复它是有意义的。由于它也是[共识清理软分叉][topic consensus cleanup]的一部分，首先在 Testnet4 中测试该修复提供了有用的早期反馈。这个 PR 通过检查新难度 epoch 的第一个区块不会早于上一个 epoch 最后一个区块 2 小时来修复时间扭曲错误。"
  a2link="https://bitcoincore.reviews/29775#l-68"

  q3="<!--what-is-the-message-in-the-genesis-block-in-testnet-3-->Testnet 3 中创世区块的消息是什么？"
  a3="Testnet 3 以及所有其他网络（在 Testnet 4 之前）都有相同的知名创世区块消息：“泰晤士报 2009 年 1 月 3 日：财政大臣即将进行第二轮银行紧急救援（'The Times
  03/Jan/2009 Chancellor on brink of second bailout for banks'）”。Testnet4 是第一个拥有自己创世区块消息的网络，该消息包括最近主网区块的哈希 (目前为
  `000000000000000000001ebd58c244970b3aa9d783bb001011fbe8ea8e98e00e`)，以提供强有力的保证，即在这个主网区块被挖出之前，Testnet4 链上没有预挖矿行为。"
  a3link="https://bitcoincore.reviews/29775#l-17"
%}


## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 26.2][] 是 Bitcoin Core 旧版本系列的维护版本。任何无法或不愿升级到最新版本（27.1）的用户都被鼓励升级到此维护版本。

- [LND v0.18.2-beta][] 是一个次要版本，用于修复影响使用旧版本 btcd 后端用户的错误。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Rust Bitcoin #2949][] 增加了一种新方法 `is_standard_op_return()` 以根据当前标准规则验证 OP_RETURN 输出，允许程序员测试 OP_RETURN 数据是否超过 Bitcoin Core 强制执行的 80 字节最大限制。不担心超过当前默认 Bitcoin Core 限制的程序员可以继续使用 Rust Bitcoin 现有的 `is_op_return` 功能。

- [BDK #1487][] 通过在 `TxOrdering` 枚举中添加 `Custom` 变体，引入对自定义输入和输出排序功能的支持，以增强交易构建的灵活性。明确的 [BIP69][] 支持已移除，因为其低采用率可能不会提供所需的隐私(见周报[#19][news19 bip69]和[#151][news151 bip69])，但用户仍然可以通过实现适当的自定义排序来创建符合 BIP69 的交易。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2949,1487" %}
[bitcoin core 26.2]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[sources]: /en/internal/sources/
[interesting transaction]: https://stacker.news/items/600187
[LND v0.18.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.2-beta
[news19 bip69]: /zh/newsletters/2018/10/30/#bip69-discussion
[news151 bip69]: /en/newsletters/2021/06/02/#bolts-872
[gh fjahr]: https://github.com/fjahr
[review club 29775]: https://bitcoincore.reviews/29775
[ml testnet4]: https://groups.google.com/g/bitcoindev/c/9bL00vRj7OU
[bip testnet4]: https://github.com/bitcoin/bips/pull/1601
