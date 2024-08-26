---
title: 'Bitcoin Optech Newsletter #54'
permalink: /zh/newsletters/2019/07/10/
name: 2019-07-10-newsletter-zh
slug: 2019-07-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了最新版本的 Eclair 发布，并描述了一个针对闪电网络（LN）的潜在路由改进。此外，还包括我们常规的关于 Bech32 发送支持的部分，以及流行比特币基础设施项目中的值得注意的代码变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无内容。*

## 新闻

- **<!--eclair-0-3-1-released-->****Eclair 0.3.1 发布：** 最新版本的这款 LN 软件包含新的和改进的 API 调用，以及其他使其性能更快、内存占用更少的更改。推荐[升级][Eclair 0.3.1]。

- **<!--brainstorming-just-in-time-routing-and-free-channel-rebalancing-->****即时路由和免费通道再平衡的头脑风暴：** 有时 LN 节点会拒绝接受路由的支付，因为该支付的出站通道目前余额不足以支持该支付。Rene Pickhardt 之前[提出][pickhardt jit]了即时路由（JIT）方案，其中节点会尝试将资金从其其他通道余额中移到该通道中。如果成功，则支付可以继续路由；否则，支付将像往常一样被拒绝。由于路由支付可能由于其他原因失败，从而使路由节点无法获得任何费用，因此任何 JIT 再平衡操作都需要免费，否则可能会导致节点因攻击者的利用而蒙受损失。

  在 Lightning-Dev 邮件列表上的一篇新[帖子][zmn jit]中，化名为 ZmnSCPxj 的 LN 开发者描述了其他最大化利润的节点可能允许免费再平衡的两种情况。第一种情况是观察到路径中的下一个跳点节点如果支付成功将会从支付者那里收到其路由费用。ZmnSCPxj 描述了一种方法，下一跳的节点可以将其再平衡操作与收到路由收入挂钩，确保他们要么获得报酬，要么再平衡不会发生。这需要节点之间的额外通信，因此可能需要进一步讨论以将其考虑纳入 LN 规范。

  ZmnSCPxj 描述的第二种情况是再平衡路径中的其他节点本身希望将一个或多个通道重新平衡到与路由节点相同的方向。这些节点可以允许在该方向上免费路由，以鼓励其他人进行再平衡。第二种情况不需要对 LN 规范进行任何更改：节点已经可以将其路由费用设置为零，从而允许其他节点尝试使用免费再平衡进行即时路由。最坏的情况是，支付本来就会失败，只是需要更长时间返回一个失败消息给支付者，而这段延迟时间等于任何路由节点尝试重新平衡其通道以支持支付所花费的时间。

## Bech32 发送支持

*第 24 周中的第 17 周，这一[系列][bech32 series]旨在让您支付的对象可以访问隔离见证的所有好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/17-signmessage.md %}

## 值得注意的代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案（BIPs）][bips repo] 中的值得注意的变更。*

- [Bitcoin Core #15427][] 扩展了 `utxoupdatepsbt` RPC，添加了一个 `descriptors` 参数，该参数接受一个[输出脚本描述符]，并使用它来更新 [BIP174][] 部分签名的比特币交易（PSBT），以获取与交易相关的脚本（地址）信息。这是对之前 RPC 行为的补充，之前的行为是从节点的内存池和 UTXO 集中添加信息。此新功能对于硬件钱包和其他配对钱包特别有用，因为它可以将 HD 密钥路径信息添加到 PSBT 中，使得钱包在签署 PSBT 时可以轻松派生出所需的密钥或验证找零输出是否确实支付回了钱包。

- [Bitcoin Core #16257][] 当其费率高于 `maxtxfee` 配置选项设置的最大金额（默认值：0.1 BTC）时，终止向未签名交易中添加资金。之前，资金代码会悄悄地将费用降低到最大值，这可能导致用户在交易中输入错误时多支付高达 1200 美元的费用（按当前价格计算）。新行为让用户有机会修正错误，避免任何资金损失。

- [Eclair #1045][] 增加了对 Tag-Length-Value（TLV）消息编码的支持。LN 实现[计划][tlv pr]未来将大部分消息转移到此格式。LND 和 C-Lightning 之前已实现 TLV 支持。

{% include linkers/issues.md issues="15427,16326,16257,1045" %}
[bech32 series]: /zh/bech32-sending-support/
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[eclair 0.3.1]: https://github.com/ACINQ/eclair/releases/tag/v0.3.1
[tlv pr]: https://github.com/lightningnetwork/lightning-rfc/pull/607
[pickhardt jit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001891.html
[zmn jit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002055.html
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
