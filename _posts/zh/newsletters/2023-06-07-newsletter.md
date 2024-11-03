---
title: 'Bitcoin Optech Newsletter #254'
permalink: /zh/newsletters/2023/06/07/
name: 2023-06-07-newsletter-zh
slug: 2023-06-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了邮件列表中关于使用 MATT 提案来管理 joinpools 和`OP_CHECKTEMPLATEVERIFY` 提案复制功能的讨论。此外，还包括我们关于交易池策略的限定版周刊系列的另一篇文章，以及我们常规发布新软件版本和发布候选版本，并描述了流行的比特币基础设施软件的重要变更。

## News

- **使用 MATT 复制 CTV 和管理 joinpools：** Johan Torås
  Halseth 在 Bitcoin-Dev 邮件列表中[发布了][halseth matt-ctv]如何使用 Merklize All The Things (MATT) 提案（参见周报[#226][news226 matt] 和[#249][news249 matt]）中的 `OP_CHECKOUTPUTCONTRACTVERIFY` 操作码（COCV）来复刻 [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] 提案中的功能。为了提交具有多个输出的交易，每个输出都需要使用不同的 COCV 操作码。相比之下，单个 CTV 操作码可以提交给所有输出。这使得 COCV 效率较低，但正如他指出的那样，“简单到有趣”。

  除了描述功能，Halseth 还提供了使用 [Tapsim][]（一种用于“调试比特币 Tapscript 交易 [...] 针对希望与比特币脚本原语进行交互、帮助脚本调试并可视化脚本执行时的虚拟机状态的工具”）的操作[演示][halseth demo]。

  在另一个帖子中，Halseth [发布][halseth matt-joinpool]了关于使用 MATT 加上 [OP_CAT][] 创建 [joinpool][topic joinpools]（也称为_coinpool_ 或 _payment pool_）的内容。同样，他提供了一个使用 Tapsim 的[交互式演示][demo joinpool]。基于实验性实现的结果，他也提供了几个对 MATT 提案中操作码的修改建议。MATT 提案的发起人 Salvatore Ingala 对此进行了积极地[回复][ingala matt]。{% assign timestamp="1:23" %}

## 等待确认 #4：费率估算

_这是一个关于交易转发、交易池纳入以及挖矿选择的限定周刊[系列][policy series] —— 解释了为什么 Bitcoin Core 设置了比共识规则更严格的交易池规则，以及钱包可以如何更高效地使用这些交易池规则。_

{% include specials/policy/zh/04-feerate-estimation.md %} {% assign timestamp="24:19" %}

## 发布和发布候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试旧版本。*

- [LND 0.16.3-beta][] 是这个流行的闪电网络节点实现的维护版本。其发布说明称，“此版本仅包含错误修复，旨在优化最近添加的交易池监视逻辑，并修复了几个疑似的意外强制关闭向量”。有关交易池监视逻辑的更多信息，请参见[周报 #248][news248 lnd mempool]。{% assign timestamp="40:31" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]*。

- [Bitcoin Core #26485][] 允许接受 `options` 对象参数的 RPC 方法接受与命名参数相同的字段。例如，现在可以使用 `src/bitcoin-cli -named bumpfee txid fee_rate=10` 调用 `bumpfee` RPC，而不是 `src/bitcoin-cli -named bumpfee txid options`。

- [Eclair #2642][] 添加了一个`closedchannels` RPC，提供有关节点关闭的通道的数据。还可以参考 Core Lightning 中类似的 PR，详见[周报 #245][news245 listclosedchannels]。{% assign timestamp="44:34" %}

- [LND #7645][] 确保 RPC 调用中的任何用户提供的费率在 `OpenChannel`、`CloseChannel`、`SendCoins` 和 `SendMany` 中不低于“中继费率”。更改注释中“‘中继费率’的含义可能因后端而异。对于 bitcoind 来说，它实际上是 max(relay fee, min mempool fee)”。{% assign timestamp="46:05" %}

- [LND #7726][] 将始终花费所有 HTLC 来向本地节点支付，如果需要在链上结算通道。即使结算这些 HTLC 可能会产生比它们的价值更多的交易费用，它也会结算这些 HTLC。与 Eclair 的一个 PR 相比，Eclair 在上周的[周报][news253 sweep]中描述的程序现在不会尝试去索取一个[不经济的][topic uneconomical outputs] HTLC。PR 讨论帖中的评论提到 LND 正在努力实现其他改变，以增强其计算与解决 HTLC 相关的成本和收益的能力（无论是离线还是在线），从而使其能够在未来做出最佳决策。{% assign timestamp="48:20" %}

- [LDK #2293][] 如果对等节点没有在合理的时间内回应，则断开连接然后重新连接。这可能会缓解其他闪电网络软件有时会停止响应导致通道被强制关闭的问题。 {% assign timestamp="50:58" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="2642,26485,7645,7726,2293" %}
[policy series]: /zh/blog/waiting-for-confirmation/
[news226 matt]: /zh/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news249 matt]: /zh/newsletters/2023/05/03/#mattbased-vaults-matt
[news253 sweep]: /zh/newsletters/2023/05/31/#eclair-2668
[news245 listclosedchannels]: /zh/newsletters/2023/04/05/#core-lightning-5967
[halseth matt-ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021730.html
[halseth demo]: https://github.com/halseth/tapsim/blob/b07f29804cf32dce0168ab5bb40558cbb18f2e76/examples/matt/ctv2/README.md
[tapsim]: https://github.com/halseth/tapsim
[halseth matt-joinpool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021719.html
[demo joinpool]: https://github.com/halseth/tapsim/tree/matt-demo/examples/matt/coinpool
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021724.html
[news248 lnd mempool]: /zh/newsletters/2023/04/26/#lnd-7564
[lnd 0.16.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.3-beta
