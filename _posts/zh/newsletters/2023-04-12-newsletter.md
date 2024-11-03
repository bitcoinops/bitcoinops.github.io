---
title: 'Bitcoin Optech Newsletter #246'
permalink: /zh/newsletters/2023/04/12/
name: 2023-04-12-newsletter-zh
slug: 2023-04-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了围绕 “闪电通道拼接” 提议的讨论，并给出了一份提议相关交易术语的 BIP 的链接。此外还有我们的常规部分：最近一次 Bitcoin Core PR 审核俱乐部会议的总结、软件的新版本和候选版本的公告 —— 包括 libsecp256k1 库的一个安全更新 —— 以及热门的比特币基础设施软件上出的重大变更的介绍。

## 新闻

- **<!--splicing-specification-discussions-->通道拼接技术规范讨论**：本周内，多位闪电网络的开发者在 Lightning-Dev 邮件组中讨论了开发中的 “[通道拼接][topic splicing]” [规范草案][bolts #863]，这种技术让一个链下的闪电通道中的一些资金可以在链上花费（称为 “splice-out”）、或者链上的资金可以添加在一条链下的通道中（称为 “splice-in”）。在链上的拼接交易等待足够多的区块确认期间，被操作的通道可以不受中断、持续运行。

  {:.center}
  ![Splicing transaction flow](/img/posts/2023-04-splicing1.dot.png)

  本周内出现的讨论有：

  - *<!--which-commitment-signatures-to-send-->要发送哪个承诺签名*： 在实施拼接时，参与者节点将持有平行的承诺交易，一笔花费通道原来的注资交易输出，另一笔为所有未完结的拼接操作花费每一个新的注资输出。每次通道状态更新时，所有平行的承诺交易都需要更新。简单的处理办法是为单笔承诺交易发送相同的信息并不断重复、每一个平行的承诺交易都需要一条消息。

    这就是原来的通道拼接规范草案的处理办法（见[周报 #17][news17 splice] 和[周报 #146][news146 splice]）。但是，就像 Lisa Neigut 在本周[说的][neigut splice]，创建一次新的拼接操作需要签名新的派生承诺交易。在当前的规范草案中，发送任何一个签名都需要发送对所有其它最新的承诺交易的签名。这是多余的：对这些其它承诺交易的签名都已经发过了。此外，在当前的闪电网络协议中，各方承认自己从对手处收到了一个签名的办法是发回上一笔承诺的交易的 “撤销点（revocation point）”。此处，这些信息又是已经发送过的。在此发送签名和旧的撤销点没有坏处，但需要额外的带宽和处理能力。好处在于，对所有的情形都执行相同的操作，可以让规范保持简洁，可以降低实现和测试的复杂性。

    另一种办法是，在特定情况下，仅为新的承诺交易发送尽可能少的签名（在谈判新的拼接操作的时候），加上一个已经收到签名的承认表述。这会高效得多，虽然这会增加一些复杂性。值得指出的是，闪电节点们只需要管理平行的承诺交易，直到一笔拼接交易得到足够多的区块确认，让两方都认可它是安全的。此后，他们就可以回到只需发送一笔承诺交易的操作模式中。

  - *<!--relative-amounts-and-zeroconf-splices-->相对数量与零确认的拼接*：Bastien Teinturier [发帖][teinturier splice]讨论了多项提议中的规范变更。除了上述的承诺签名协议的变更以外，他还建议拼接提议使用相对数量，例如 “20 0000 sats” 表示 Alice 将注入 20 0000 聪，而 “-5 0000 sats” 表示她将取走这个数量。他也提出了一种顾虑，关系到零确认的通道拼接交易，但没有深入讨论。{% assign timestamp="1:24" %}

- **<!--proposed-bip-for-transaction-terminology-->交易术语 BIP**：Mark “Murch” Erhardt 在 Bitcoin-Dev 邮件组中[提出][erhardt terms]了一份[信息型 BIP][terms bip]，提出了一份用于指称交易的不同部分以及相关概念的术语表。截至本文撰写之时，所有的回复都表示支持这项工作。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们会总结最新一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议的成果，列出一些重要的问题和回答。点击问题，即可看到会议对该问题的回答总结。*

“[不为剪枝模式下的 assumed-valid 区块下载 witness 数据][review club 27050]” 是 Niklas Gögge（dergoegge）提出的一项 PR，通过在配置成 “[修剪区块数据][docs pruning]” 模式的节点不为 “[assumevalid][docs assume valid]” 区块下载 witness（见证）数据，提升初始化区块下载（IBD）的性能。这项优化也在最近的一个[stack exchange 问答][se117057]中讨论过。


{% include functions/details-list.md
  q0="<!--if-assume-valid-is-enabled-but-not-pruning-why-does-the-node-need-to-download-non-recent-witness-data-given-that-the-node-won-t-be-checking-this-data-should-this-pr-also-disable-witness-download-in-this-non-pruning-case-->启用了 assume-valid 选项但不是剪枝模式的节点也需要下载（非近期的）见证数据吗？如果这些节点不会检查这些数据的话，为什么要下载呢？这个 PR 是否也应该禁止非剪枝模式下的见证数据下载？"
  a0="需要见证数据，是因为对等节点可能会跟我们请求非近期的区块（我们对外宣称我们是非剪枝的节点。）"
  a0link="https://bitcoincore.reviews/27050#l-31"

  q1="<!--how-much-bandwidth-might-be-saved-by-this-enhancement-during-an-ibd-in-other-words-what-is-the-cumulative-size-of-all-witness-data-up-to-a-recent-block-say-height-781213-->这项措施能在 IBD 期间节约大概多少带宽呢？换句话说，截至最近的一个区块（比如高度为 781213 的区块），所有见证数据的总体积是多少？"
  a1="110.6 GB，大概是所有区块数据的 25%。一位参与者之时，110 GB 是他的互联网服务每个月下载流量上限的 10%，所以是巨大的节约。参与者们也预期，因为近期出现的对见证数据的扩展用法，节约的比例会继续升高。"
  a1link="https://bitcoincore.reviews/27050#l-52"

  q2="<!--would-this-improvement-reduce-the-amount-of-download-data-from-all-blocks-back-to-the-genesis-block-->这项提升能减少自创世区块以来所有区块的数据下载量吗？"
  a2="不行。只有自隔离见证激活（区块高度 481824）以来的区块才能减少下载量；隔离见证以前的区块没有见证数据。"
  a2link="https://bitcoincore.reviews/27050#l-73"

  q3="<!--this-pr-implements-two-main-changes-one-to-the-block-request-logic-and-one-to-block-validation-what-are-these-changes-in-more-detail-->这项 PR 实现了两个重大变更，一个是区块请求逻辑的，另一个是区块验证的。能否具体讲讲？"
  a3="在验证过程中，在脚本检查被跳过时，见证数据默克尔树检查也会被跳过。在区块请求逻辑中，从拉取标签中移除 `MSG_WITNESS_FLAG`，这样对等节点就不会向我们发送见证数据。"
  a3link="https://bitcoincore.reviews/27050#l-83"

  q4="<!--without-this-pr-script-validation-is-skipped-under-assume-valid-but-other-checks-that-involve-witness-data-are-not-skipped-what-are-these-checks-that-this-pr-will-cause-to-be-skipped-->没有这项 PR 的话，assume-valid 选项下会跳过脚本验证，但其它跟见证数据有关的检查不会跳过。那么，这项 PR 导致哪些检查跳过了？"
  a4="coinbase 默克尔树根、见证数据体积、见证数据堆栈上限，以及区块重量。"
  a4link="https://bitcoincore.reviews/27050#l-91"

  q5="<!--the-pr-does-not-include-an-explicit-code-change-for-skipping-all-the-extra-checks-mentioned-in-the-previous-question-why-does-that-work-out-->这项 PR 没有包含用于跳过上一个问题中的所有额外检查的显式代码。这是怎么做到的？"
  a5="事实是，当我们没有任何见证数据的时候，所有这些额外的检查都会跳过。这样做的意义在于隔离见证是一次软分叉。有了这项 PR，我们本质上是在假装我们是一个前隔离见证节点（直至我们到达 assume-valid 的终点。）"
  a5link="https://bitcoincore.reviews/27050#l-117"
%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Libsecp256k1 0.3.1][] 是一项**安全更新**，它修复了一个漏洞：相关代码应该在常量时间内运行，但使用 Clang 版本 14 及更高版本编译代码时，却没有这样运行。这个漏洞可能会影响应用，使它们面临时序[旁路攻击][topic side channels]。作者强烈建议大家升级受到影响的应用。{% assign timestamp="53:10" %}

- [BDK 1.0.0-alpha.0][] 是 BDK 的重大更新的一个测试版本，我们在[Newsletter #243][news243 bdk] 中描述过。建议下游项目的开发者开始集成测试。{% assign timestamp="58:08" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Core Lightning #6012][] 在用于编写 CLN 插件（见[周报 #26][news26 pyln-client]）的 Python 库中实现了多项重大优化，使得它能跟 CLN 的 gossip 仓库更好地协作。这项变更允许为 gossip 开发更好的分析工具，而且让使用 gossip 数据的插件的开发变得更加容易。{% assign timestamp="58:33" %}

- [Core Lightning #6124][] 添加了一项功能，可以禁止某些使用 [commando][commando plugin] 功能的用户（runes），并维护一个所有用户的清单，这可用于追踪和禁用遭到爆破的用户。{% assign timestamp="1:02:01" %}

- [Eclair #2607][] 添加了一种新的 PRC `listreceivedpayments`，可以列出节点收到的所有支付。{% assign timestamp="1:03:06" %}

- [LND #7437][] 已支持备份单个通道到一个文件中。{% assign timestamp="1:04:05" %}

- [LND #7069][] 允许一个客户端向自己的[瞭望塔][topic watchtowers]发送一条消息，请求删除某个会话。这使得瞭望塔可以停止监控使用过期状态来关闭通道的链上交易。这降低了瞭望塔和客户端双方的存储和 CPU 负担。{% assign timestamp="1:04:43" %}

- [BIPs #1372][] 为 [MuSig2][topic musig] 协议分配了编号 [BIP327][]，该协议用于创建可用于 [taproot][topic taproot] 及其它兼容 [BIP340][] 的[Schnorr 签名][topic schnorr signatures]系统的[多签名][topic multisignature]。如该 BIP 所述，使用该协议的好处包括非交互式的密钥聚合以及仅需两轮通信即可完成签名。使用额外的步骤，也可以在参与者之间实现非交互的签名。该协议兼容任何多签名方案的所有好处，例如大大减少链上数据并加强隐私性 —— 既包括参与者自己的，也包括网络所有用户的。{% assign timestamp="1:06:18" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="6012,6124,2607,7437,7069,1372,863" %}

[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[news243 bdk]: /zh/newsletters/2023/03/22/#bdk-793
[neigut splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003894.html
[teinturier splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003895.html
[erhardt terms]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021550.html
[terms bip]: https://github.com/Xekyo/bips/pull/1
[news26 pyln-client]: /en/newsletters/2018/12/18/#c-lightning-2161
[news17 splice]: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[news146 splice]: /en/newsletters/2021/04/28/#draft-specification-for-ln-splicing
[libsecp256k1 0.3.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.1
[review club 27050]: https://bitcoincore.reviews/27050
[docs pruning]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.11.0.md#block-file-pruning
[docs assume valid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[se117057]: https://bitcoin.stackexchange.com/questions/117057/why-is-witness-data-downloaded-during-ibd-in-prune-mode
[commando plugin]: /zh/newsletters/2022/07/27/#core-lightning-5370
