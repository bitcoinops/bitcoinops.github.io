---
title: 'Bitcoin Optech Newsletter #63'
permalink: /zh/newsletters/2019/09/11/
name: 2019-09-11-newsletter-zh
slug: 2019-09-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了 eltoo 的一个演示实现以及与之相关的多个讨论，征求了关于将 LN gossip 更新频率限制为每天一次的评论，并提供了迄今为止我们所列出的有关比特币基础设施项目的最长的值得注意的更改列表。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无。*

## 新闻

- **<!--eltoo-sample-implementation-and-discussion-->****Eltoo 示例实现和讨论：** 在 Lightning-Dev 邮件列表中，Richard Myers [发布][eltoo sample]了一个 eltoo 节点之间在自定义 [signet][] 上进行支付流的示例实现。[Eltoo][] 是一个提议，用以替换 LN 目前的 LN-penalty 强制层，使用一个名为 LN-eltoo 的新层。LN-penalty 通过赋予节点对试图将旧的通道状态发布到链上的对手方进行经济惩罚的能力，来防止对手方的盗窃行为。而 LN-eltoo 实现了相同的目标，但允许较新的状态在特定时间段内花费早期状态中的资金，从而消除了惩罚的必要性，简化了协议的许多方面，并降低了许多拟议协议增强的复杂性。Myers 的示例实现通过使用 Bitcoin Core 功能测试框架来模拟 eltoo 支付通道中的支付流程。

  这引发了关于是否使用 [miniscript][] 能使 LN 比直接使用比特币脚本“更具未来可扩展性”的讨论（[1][eltoo ms 1], [2][eltoo ms 2]）。

  此外，eltoo 的共同作者 Christian Decker 撰写了一篇[总结][eltoo summary]，说明他认为 eltoo 在提供协议层的清晰分离方面特别有价值。例如，通过使 eltoo 中的状态变化与比特币中的状态变化相似，这将允许为常规比特币交易（状态变化）构建的工具和合约协议能够轻松地在支付通道中重复使用。

- **<!--request-for-comments-on-limiting-ln-gossip-updates-to-once-per-day-->****关于将 LN gossip 更新频率限制为每天一次的评论请求：** Rusty Russell 在 Lightning-Dev 邮件列表中[发布][less gossip]了他计划将 C-Lightning 接受的 gossip 更新数量限制为每天一次。根据他基于当前网络特征的计算，这应该将 gossip 更新使用的带宽限制在每天约 12 MB，从而使 LN 更容易在慢速设备（如单板计算机）和低带宽网络连接上使用。他请求任何认为这会对当前实现的用户造成问题的人提供反馈。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #16185][] 更新了 `gettransaction` RPC，新增了一个 `decode` 参数。如果设置为 True，则在 RPC 输出中将添加一个 `decoded` 字段，其中包含以 JSON 字段解码的交易版本（与请求带详细输出时的 `getrawtransaction` RPC 输出格式相同）。

- [Bitcoin Core #15759][] 将节点建立的出站连接数量从 8 个增加到 10 个。两个新连接将仅用于宣布和中继新的区块，它们不会宣布或中继未确认的交易或 `addr` 节点发现消息。仅宣布区块可以最大程度地减少新连接的带宽和内存开销，并使攻击者更难以绘制节点之间的连接图。如果攻击者能够绘制节点的所有连接图，则可以攻击该节点，无论是通过识别哪些交易源自该节点（隐私泄漏），还是通过将节点与网络的其余部分隔离（可能导致节点资金被盗）。有关攻击者如何通过交易中继绘制网络拓扑的详细信息，请参阅 [TxProbe 论文][TxProbe paper]。

- [Bitcoin Core #15450][] 允许用户通过图形界面为多钱包模式创建新钱包，完成了一套图形界面操作，这套操作还允许用户加载和卸载钱包。此操作会打开一个对话框，允许用户为钱包命名并设置各种钱包选项。

- [Bitcoin Core #16421][] 是对 [PR#15681][Bitcoin Core #15681]（在 [Newsletter #56][carve-out] 中描述）的后续更新，允许通过 RBF 替换 carve-out 交易。carve-out 交易可以稍微超过 Bitcoin Core 对交易大小和祖先数量的限制。当 carve-out 功能添加时，这些规则的例外没有应用于交易替换，因此节点会接受 carve-out，但不会接受它们的 RBF 费用提升。有了这个 PR，现在可以对 carve-out 进行 RBF 费用提升，使其成为管理双边 LN 支付通道结算交易费用的更有用工具。

- [LND #3401][] 限制了节点在通道更新交易（承诺交易）中提议支付的链上费用金额，将其限制为节点当前通道余额的 50%（默认的 50% 是可调整的）。理论上，通道仍然可以继续使用，因此不会关闭，尽管节点可能没有足够的资金来发起支付，因此除非链上费用率下降，否则接收可能是其唯一的选择。LN 协议只允许打开通道的节点提出费率变化的新的承诺交易，因此此更改仅适用于通道发起者。

- [LND #3390][] 将 HTLC 的跟踪与发票分离。以前，每个发票仅与一个 HTLC 关联，因此细节相同。最近的一些创新，如原子多路径支付（AMP），将允许通过多个 HTLC 分阶段支付同一发票，因此此更改使得能够独立跟踪单个 HTLC 或整个发票。该更改还改进了对已多次支付的现有 HTLC 的跟踪，并简化了 [Newsletter #38][lnd hold invoices] 中描述的持有发票的逻辑。

- [C-Lightning #3025][] 更新了 `listfunds` RPC，添加了一个 `blockheight` 字段，用于已确认交易，表示包含它们的区块高度。

- [C-Lightning #2938][] 将启动时处理传入 HTLC 的时间推迟到所有插件加载完成之后。这防止了在插件加载之前调用插件挂钩。

- [C-Lightning #3004][] 删除了 C-Lightning 0.7.0 中弃用的所有功能，包括：

  - 弃用的 `listpayments` RPC 以及 `pay`、`sendpay` 和 `waitsendpay` 中弃用的 `description` 参数或输出字段。（参见 [Newsletter #36][listpayments deprecated]）

  - 弃用的旧式冒号分隔的短通道标识符（`Block:Transaction_index:Output_index`）。请改用使用 x 分隔的标准化 [BOLT7 格式][BOLT7 format]（`BxTxO`）。

- [C-Lightning #2924][] 抽象化了 C-Lightning 的数据库处理代码和 SQL 查询，以便可以适配除默认的 sqlite3 之外的其他后端。预计未来的 PR 将“添加其他数据库驱动程序的具体实现”。

- [C-Lightning #2964][] 更新了 `txprepare` RPC，允许其在同一交易中支付多个输出。

- [Libsecp256k1 #337][] 使得配置库中用于加速签名生成的预计算表的大小变得更加容易。这可以节省大约 32 KB 的内存，这对使用 libsecp256k1 的某些嵌入式设备来说是一个重要的量。

- [BOLTs #656][] 为 [BOLT11][] 增加了功能位规范，允许支付指示它们支持或需要哪些功能。这计划用于开发中的几个新功能。

{% include linkers/issues.md issues="16185,627,1106,3449,3401,3390,15759,15450,16421,656,337,3004,3025,2938,2924,2964,15681" %}

[bolt7 format]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md#definition-of-short_channel_id
[lnd hold invoices]: /zh/newsletters/2019/03/19/#lnd-2022
[listpayments deprecated]: /zh/newsletters/2019/03/05/#c-lightning-2382
[carve-out]: /zh/newsletters/2019/07/24/#bitcoin-core-15681
[eltoo sample]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002131.html
[eltoo ms 1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002132.html
[eltoo ms 2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002135.html
[eltoo summary]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002136.html
[signet]: https://en.bitcoin.it/wiki/Signet
[less gossip]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002134.html
[txprobe paper]: https://arxiv.org/pdf/1812.00942.pdf
[eltoo]: https://blockstream.com/eltoo.pdf
[miniscript]: /en/topics/miniscript/
