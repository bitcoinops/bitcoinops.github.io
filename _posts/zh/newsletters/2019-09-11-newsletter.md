---
title: 'Bitcoin Optech Newsletter #63'
permalink: /zh/newsletters/2019/09/11/
name: 2019-09-11-newsletter-zh
slug: 2019-09-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了 eltoo 的一个示例实现以及围绕它的若干讨论，就“将 LN gossip 更新的常规数量限制为每天一次”公开征求意见，并给出了本刊迄今最长的一份热门比特币基础设施项目值得注意的变更清单。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无。*

## 新闻

- **<!--eltoo-sample-implementation-and-discussion-->****Eltoo 示例实现与讨论：** 在 Lightning-Dev 邮件列表中，Richard Myers [发帖][eltoo sample]，给出了一个在自定义 [signet][] 上、节点之间完成 eltoo 支付流程的示例实现。[eltoo][] 是一项提案，用名为 LN-eltoo 的新层替换 LN 现有的 LN-penalty 执行层。LN-penalty 通过让节点有能力对试图把旧通道状态发布到链上的对手方施加经济惩罚，来防止对手方盗取资金。LN-eltoo 以另一种方式达成同样的目标：它让较新的状态能在特定时间段内花费较早状态中的资金。这样就无需惩罚机制，简化了协议的诸多方面，也降低了许多拟议协议增强的复杂度。Myers 的示例实现借助 Bitcoin Core 的功能测试框架，来模拟 eltoo 支付通道中的付款。

  这引发了讨论（[1][eltoo ms 1]、[2][eltoo ms 2]）：使用 [miniscript][] 是否能让 LN 相比直接使用比特币脚本（Bitcoin Script）“更具前瞻性、更易扩展”。

  讨论还促使 eltoo 的共同作者 Christian Decker 写了一篇[总结][eltoo summary]，说明他为何认为 eltoo 在实现协议层清晰分离方面尤其有价值。例如，让 eltoo 中的状态变更与比特币中的状态变更相似，就可以让为普通比特币交易（状态变更）打造的工具和合约协议，轻松地复用到支付通道中。

- **<!--request-for-comments-on-limiting-ln-gossip-updates-to-once-per-day-->****关于将 LN gossip 更新限制为每天一次的征求意见：** Rusty Russell 在 Lightning-Dev 邮件列表上[发帖][less gossip]，谈了他打算把 C-Lightning 接受的 gossip 更新数量在正常情况下限制为每天一次。按他基于当前网络特征所做的估算，这应能把 gossip 更新占用的带宽限制在每天约 12 MB，从而使 LN 更容易在慢速设备（如单板计算机）和低带宽网络连接上使用。他希望任何认为这会给现有实现的用户带来问题的人反馈意见。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #16185][] 更新了 `gettransaction` RPC，新增了一个 `decode` 参数。如果将其设为 True，RPC 输出中会多出一个 `decoded` 字段，其中包含这笔交易以 JSON 字段形式解码后的内容（与用 `getrawtransaction` RPC 请求详细输出时的格式相同）。

- [Bitcoin Core #15759][] 将节点建立的出站连接数从 8 个增加到 10 个。这两个新连接只用来宣告和中继新出的区块；它们不会宣告或中继未确认交易，也不会传播 `addr` 节点发现消息。只宣告区块能把新连接的带宽和内存开销降到最低，并使攻击者更难绘制节点之间的连接关系。若攻击者能绘制出某节点的全部连接，就能攻击该节点：既可以识别哪些交易源自该节点（隐私泄露），也可以把该节点与网络的其他部分隔离（有可能导致该节点的资金被盗）。关于攻击者如何利用交易中继绘制网络拓扑的细节，请参阅 [TxProbe 论文][TxProbe paper]。

- [Bitcoin Core #15450][] 允许用户通过图形界面为多钱包模式创建新钱包，补齐了图形界面上一整套操作，其中也包括加载和卸载钱包。该操作会打开一个对话框，让用户为钱包命名并设置各项钱包选项。

- [Bitcoin Core #16421][] 延续了 [PR#15681][Bitcoin Core #15681]（在 [Newsletter #56][carve-out] 中介绍）的工作，允许用 RBF 替换 CPFP 豁免交易。carve-out 交易可以略微超出 Bitcoin Core 对交易大小和祖先数量的限制。当初加入 carve-out 时，这些规则上的例外没有一并适用于交易替换，因此节点会接受 carve-out 交易，却不接受对其做 RBF 手续费追加。有了这个 PR，现在可以对 carve-out 交易做 RBF 手续费追加，使其成为管理双边 LN 支付通道结算交易手续费时更加有用的工具。

- [LND #3401][] 为节点在通道更新交易（承诺交易）中提议支付的链上手续费设了上限，最多为节点当前通道内余额的 50%（这 50% 的默认值可调整）。理论上，此后通道仍可继续使用——这也是它不会被关闭的原因——但节点可能已没有足够资金发起支出，除非链上费率下降，否则可能只剩收款这一个选择。LN 协议只允许开设通道的一方提议更改费率的新承诺交易，因此这一改动只适用于通道发起方。

- [LND #3390][] 把 HTLC 的跟踪与发票分开。以前每张发票只对应一个 HTLC，所以两者的记录细节是一回事。原子多路径支付（AMP）等较新的创新将允许用多个 HTLC 分批支付同一张发票，因此这一改动使得既能单独跟踪各个 HTLC，也能跟踪整张发票。该改动还改善了对于那些被支付过多次的现有 HTLC 的跟踪，并简化了 [Newsletter #38][lnd hold invoices] 中所述挂起发票（hold invoice）的处理逻辑。

- [C-Lightning #3025][] 更新了 `listfunds` RPC，为已确认交易新增 `blockheight` 字段，用来表示包含该交易的区块高度。

- [C-Lightning #2938][] 把启动时对传入 HTLC 的重新处理推迟到所有插件加载完成之后。这样就不会在插件尚未加载时调用该插件的钩子。

- [C-Lightning #3004][] 删除了 C-Lightning 0.7.0 中已弃用的全部功能，包括：

  - 已弃用的 `listpayments` RPC，以及 `pay`、`sendpay`、`waitsendpay` 中已弃用的 `description` 参数或输出字段。（参见 [Newsletter #36][listpayments deprecated]）

  - 已弃用的旧式冒号分隔短通道标识符（`Block:Transaction_index:Output_index`）。请改用标准化的 [BOLT7 格式][BOLT7 format]，以 x 分隔（`BxTxO`）。

- [C-Lightning #2924][] 把 C-Lightning 的数据库处理代码和 SQL 查询抽象出来，使其可以适配除默认 sqlite3 之外的其他后端。预计未来的 PR 将“为其他数据库驱动添加具体实现”。

- [C-Lightning #2964][] 更新了 `txprepare` RPC，允许其在同一交易中支付多个输出。

- [Libsecp256k1 #337][] 让配置该库用于加速签名生成的预计算表大小变得更容易。这样可以省下约 32 KB 内存，对某些使用 libsecp256k1 的嵌入式设备来说是一笔可观的数目。

- [BOLTs #656][] 为 [BOLT11][] 增加了功能位（feature bits）规范，让付款能够表明自己支持或要求哪些功能。这一机制计划用于若干仍在开发中的新功能。

{% include linkers/issues.md issues="16185,627,1106,3449,3401,3390,15759,15450,16421,656,337,3004,3025,2938,2924,2964,15681" %}

[bolt7 format]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md#definition-of-short_channel_id
[lnd hold invoices]: /zh/newsletters/2019/03/19/#lnd-2022
[listpayments deprecated]: /zh/newsletters/2019/03/05/#c-lightning-2382
[carve-out]: /zh/newsletters/2019/07/24/#bitcoin-core-15681
[eltoo sample]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002131.html
[eltoo ms 1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002132.html
[eltoo ms 2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002135.html
[eltoo summary]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002136.html
[signet]: https://en.bitcoin.it/wiki/Signet
[less gossip]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002134.html
[txprobe paper]: https://arxiv.org/pdf/1812.00942.pdf
[eltoo]: https://blockstream.com/eltoo.pdf
[miniscript]: /en/topics/miniscript/
