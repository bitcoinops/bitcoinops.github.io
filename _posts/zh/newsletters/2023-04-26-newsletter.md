---
title: 'Bitcoin Optech Newsletter #248'
permalink: /zh/newsletters/2023/04/26/
name: 2023-04-26-newsletter-zh
slug: 2023-04-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报转发了一个关于从 Bitcoin Core 中删除对 BIP35 `mempool` P2P 协议消息支持提案的反馈请求，并包括我们的常规部分，其中包括来自 Bitcoin Stack Exchange 的热门问题和答案、新版本和发布候选版本的公告以及流行的比特币基础设施软件的重要变更摘要。

## 新闻

- **建议删除 BIP35 `mempool` P2P 消息：** Will Clark 在 Bitcoin-Dev 邮件列表中发布了一篇文章，介绍了他开放的 [PR][bitcoin core #27426]，旨在删除最初在 [BIP35][] 中指定的 P2P `mempool` 消息的支持。在其最初的实现中，接收到 `mempool` 消息的节点将用包含其交易池中所有交易的 txids 的 `inv` 消息响应请求的对等节点。然后，请求的对等节点可以发送一个常规的 `getdata` 消息，其中包含它想要接收的任何交易的 txids。该 BIP 描述了这个消息的三个动机：网络诊断、允许轻量级客户端轮询未确认的交易，以及允许最近重新启动的矿工了解未确认的交易（当时，Bitcoin Core 在关闭时没有将其交易池保存到持久存储中）。

    然而，后来出现了各种导致隐私降低的技术，通过滥用“交易池”消息或使用“getdata”请求任何交易池交易的能力，使得更容易确定哪个节点首先广播了交易。为了提高[交易来源隐私][topic transaction origin privacy]，Bitcoin Core 后来删除了从其他节点请求未公布交易的能力，并将“交易池”消息限制为仅与[交易布隆过滤器][topic transaction bloom filtering]（如[BIP37]中指定的那样）一起使用，以供轻量级客户端使用。更晚一些，Bitcoin Core 默认禁用了布隆过滤器支持（请参见[Newsletter＃56][news56 bloom]），仅允许将其用于配置了“-whitelist”选项的对等节点（请参见[Newsletter＃60][news60 bloom]）；这有效地使 BIP35 “交易池”也默认禁用。

    Clark 的 Bitcoin Core PR 得到了项目内部的支持，尽管一些支持者认为应该先删除 BIP37 布隆过滤器。在邮件列表中，截至本文撰写时，唯一的[回复][harding mempool]指出，连接到自己的可信节点的轻量级客户端目前可以使用 BIP35 和 BIP37 以比目前通过 Bitcoin Core 可轻易获得的任何其他方法都更节省带宽地获知未确认的交易。回复者建议在删除当前接口之前，Bitcoin Core 提供一种替代机制。

    请所有使用 BIP35 `mempool` 消息的人提供额外反馈。你可以回复邮件列表或之前链接的 PR。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首批场所之一，也是我们有空闲时间帮助好奇或困惑用户的地方。在这个月度专题中，我们重点介绍自上次更新以来发布的一些投票最多的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-many-sigops-are-in-the-invalid-block-783426-->无效区块 783426 中有多少个 sigops？]({{bse}}117837)
  Vojtěch Strnad 提供了一个脚本，遍历区块中的所有交易并计算 [sigops]({{bse}}117359)，同时指出该区块中有 80,003 个 sigops，使其成为[无效区块][max sigops]。

- [<!--how-would-an-adversary-increase-the-required-fee-to-replace-a-transaction-by-up-to-500-times-->对手如何将替换交易所需费用增加至 500 倍？]({{bse}}117734)
  Michael Folkson 问如何实现交易替换所需费用的 500 倍增加。该问题的内容也参考了[短暂锚点][topic ephemeral anchors]的 BIP 草案。Antoine Poinsot 举例说明了攻击者如何使用[手续费替换（RBF）][topic rbf]的费用提高规则，要求额外的替换交易来支付明显更高的费用。

- [<!--best-practices-with-multiple-cpfps-cpfp-rbf-->使用多个 CPFP 和 CPFP + RBF 的最佳实践？]({{bse}}117877)
  Sdaftuar 解释了在初始 CPFP 费用提高尝试未能提供足够费率以确认初始交易的情况下，使用 RBF 和 [Child Pays For Parent（CPFP）][topic cpfp] 费用提高技术的注意事项。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LDK 0.0.115][] 是这个用于构建支持闪电网络的钱包和应用程序的库的一个版本。它包括了一些新功能和错误修复，包括更多对实验性 [offers][topic offers] 协议的支持以及改进的安全性和隐私保护。

- [LND v0.16.1-beta][] 是这个闪电网络实现的一个小版本，包括了几个错误修复和其他改进。它的发布说明指出，其默认 CLTV delta 从 40 个区块增加到了 80 个区块（请参见 [Newsletter #40][news40 cltv]。我们在其中介绍了 LND 默认 CLTV delta 此前的更改）。

- [Core Lightning 23.05rc1][] 是这个闪电网络实现的下一个版本的候选发布版本。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [LND #7564][] 现在允许有交易池访问权限的后端用户监视未确认交易，其中包含节点通道中 HTLC 的原像。这使得节点可以更快地解决 HTLC，而不必等待这些交易确认。

- [LND #6903][] 更新了 `openchannel` RPC，增加了一个新的 `fundmax` 选项。该选项将所有通道资金分配给新通道，除了需要保留在链上的任何金额以用于使用[锚点输出][topic anchor outputs] 向通道添加费用的情况。

- [LDK #2198][] 提高了 LDK 发送通告的消息以宣布通道已关闭（例如，由于远程对等节点不可用）前的等待时间。以前，LDK 在大约一分钟后会广播通道已关闭。其他 LN 节点等待更长时间，而更新 LN gossip 协议的[提案][bolts #1059] 建议将时间戳字段替换为块高度，而不是 [Unix epoch 时间][Unix epoch time]，这将只允许每个区块更新一次 gossip 消息（平均每 10 分钟一次）。尽管 PR 注意到发送较慢的更新涉及权衡，即它在广播通道禁用消息之前，需要为更新 LDK 等待约 10 分钟。

- [Bitcoin Inquisition #23][] 添加了对[临时锚点][topic ephemeral anchors]的部分支持。它不包括 [v3 交易中继][topic v3 transaction relay] 的支持，这是临时锚点所依赖的，以防止[交易钉死攻击][topic transaction pinning]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="7564,6903,2198,1059,23,27426" %}
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[news56 bloom]: /en/newsletters/2019/07/24/#bitcoin-core-16152
[news60 bloom]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[clark mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021562.html
[harding mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021563.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[ldk 0.0.115]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.115
[lnd v0.16.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.1-beta
[news40 cltv]: /en/newsletters/2019/04/02/#lnd-2759
[max sigops]: https://github.com/bitcoin/bitcoin/blob/e9262ea32a6e1d364fb7974844fadc36f931f8c6/src/consensus/consensus.h#L17
