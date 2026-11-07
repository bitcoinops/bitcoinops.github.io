---
title: 'Bitcoin Optech Newsletter #54'
permalink: /zh/newsletters/2019/07/10/
name: 2019-07-10-newsletter-zh
slug: 2019-07-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布发布最新版本的 Eclair，并介绍了一项可能改进闪电网络（LN）路由的方案。此外，还包括我们常规的 bech32 发送支持部分，以及流行比特币基础设施项目中值得注意的代码变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无内容。*

## 新闻

- **<!--eclair-0-3-1-released-->****Eclair 0.3.1 发布：** 这款 LN 软件的最新版本新增并改进了 API 调用，还包含其他更改，使其运行更快、内存占用更少。推荐[升级][Eclair 0.3.1]。

- **<!--brainstorming-just-in-time-routing-and-free-channel-rebalancing-->****即时路由与免费通道再平衡的头脑风暴：** 有时 LN 节点会收到一笔路由支付，但由于该支付的出站通道当前余额不足而拒绝它。Rene Pickhardt 之前[提出][pickhardt jit]了即时（Just-In-Time，JIT）路由，即节点会尝试从自己的一个或多个其他通道余额中把资金转入该通道。如果转账成功，这笔支付就能继续路由；否则就会像平常一样被拒绝。由于该路由支付可能因其他原因失败，使路由节点赚不到任何手续费，因此任何 JIT 再平衡操作都必须免费，否则最终会让节点损失资金，而攻击者可以利用这一点。

  在 Lightning-Dev 邮件列表的一篇新[帖子][zmn jit]中，化名 ZmnSCPxj 的 LN 开发者描述了其他以利润最大化为目标的节点可能允许免费再平衡的两种情况。第一种情况是：如果支付成功，路由中的下一跳节点会收到由付款方支付的、属于自己的那份路由手续费。ZmnSCPxj 描述了一种方法，让下一跳节点可以把自己参与的那部分再平衡设为以收到路由收入为前提，从而确保它们要么拿到报酬，要么再平衡就不会发生。这需要在节点之间增加通信，因此这个改动要想被考虑纳入 LN 规范，可能还需要进一步讨论。

  ZmnSCPxj 描述的第二种情况是：再平衡路径上的其他节点自己也希望沿与路由节点相同的方向再平衡它们的一个或多个通道。这些节点可以允许在该方向上免费路由，以鼓励别人去做这种再平衡。第二种情况不需要对 LN 规范做任何更改：节点已经可以把路由手续费设置为零，从而允许其他节点尝试带有免费再平衡的 JIT 路由。最坏的情况是：一笔本来就会失败的支付，向付款方返回失败消息的时间会稍长一些，延迟时长等于各个路由节点为支持这笔支付而尝试再平衡其通道所花的时间。

## Bech32 发送支持

*这是共 24 周的[系列][bech32 series]中的第 17 周，目的是让你支付的对象也能获得隔离见证的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/17-signmessage.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的变更。*

- [Bitcoin Core #15427][] 扩展了 `utxoupdatepsbt` RPC，新增 `descriptors` 参数。该参数接受一个[输出脚本描述符]，并用它把交易中涉及的脚本（地址）信息更新到一个 [BIP174][] 部分签名比特币交易（PSBT）中。这是对该 RPC 原有行为的补充：原来的行为是从节点的内存池（mempool）和 UTXO 集中为 PSBT 添加信息。这项新功能对硬件钱包和其他配对钱包特别有用，因为它可以把 HD 密钥路径信息加到 PSBT 里，让被要求签署 PSBT 的钱包能轻松派生出签名所需的密钥，或验证某个找零输出是否确实付回了该钱包。

- [Bitcoin Core #16257][] 当未签名交易的费率高于 `maxtxfee` 配置选项设定的上限（默认值：0.1 BTC）时，中止向该交易添加资金。此前，注资代码会悄悄把手续费降到上限，这可能让交易写错的用户多付最高 1200 美元的手续费（按当时价格计算）。新行为让用户有机会修正错误，避免资金损失。

- [Eclair #1045][] 增加了对 Tag-Length-Value（TLV）消息编码的支持。LN 实现[计划][tlv pr]今后将大部分消息改用这种格式。LND 和 C-Lightning 此前已经实现了 TLV 支持。

{% include linkers/issues.md issues="15427,16326,16257,1045" %}
[bech32 series]: /zh/bech32-sending-support/
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[eclair 0.3.1]: https://github.com/ACINQ/eclair/releases/tag/v0.3.1
[tlv pr]: https://github.com/lightningnetwork/lightning-rfc/pull/607
[pickhardt jit]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001891.html
[zmn jit]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002055.html
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
