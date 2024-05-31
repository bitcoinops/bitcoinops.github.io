---
title: 'Bitcoin Optech Newsletter #54'
permalink: /zh/newsletters/2019/07/10/
name: 2019-07-10-newsletter-zh
slug: 2019-07-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了最新版本的 Eclair 的发布，并描述了一个潜在的 LN 路由改进。此外，还包括我们关于 bech32 发送支持和流行的比特币基础设施项目中值得注意的代码更改的常规部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无。*

## 新闻

- **<!--eclair-0-3-1-released-->****Eclair 0.3.1 发布：** 最新版本的这款 LN 软件包括新的和改进的 API 调用以及其他能够使其性能更快、内存占用更少的更改。建议[升级][Eclair 0.3.1]。

- **<!--brainstorming-just-in-time-routing-and-free-channel-rebalancing-->****及时路由和免费通道再平衡的头脑风暴：** 有时 LN 节点会拒绝一个路由支付，因为其出站通道当前的余额不足以支持该支付。Rene Pickhardt 之前[提出][pickhardt jit]及时 (Just-In-Time, JIT) 路由的想法，节点会尝试从一个或多个其他通道余额中移资金到该通道。如果成功，支付即可完成路由；否则，像往常一样被拒绝。因为路由支付可能由于其他原因失败，导致路由节点无法获得任何费用，任何 JIT 再平衡操作都需要是免费的，否则可能会使节点损失资金，攻击者可能会利用这一点。

  在一个新的[帖子][zmn jit]中，匿名的 LN 开发者 ZmnSCPxj 描述了两种情况下其他以利润为目标的节点可能允许免费再平衡。第一种情况是下一个跃点的节点将在支付成功时收到由支付者支付的路由费用。ZmnSCPxj 描述了一种方法，通过该方法下一个跃点的节点可以使他们的再平衡部分依赖于收到路由收入，从而确保他们要么得到报酬，要么再平衡不会发生。这需要节点之间额外的通信，因此可能需要进一步讨论以纳入 LN 规范。

  ZmnSCPxj 描述的第二种情况是沿再平衡路径的其他节点自身也希望以与路由节点相同的方向重新平衡一个或多个通道。这些节点可以允许在该方向上免费的路由，以鼓励有人进行再平衡。第二种情况不需要对 LN 规范进行任何更改：节点已经可以将他们的路由费用设为零，允许任何其他节点尝试免费的 JIT 路由。最坏的情况是原本就会失败的支付将需要更长的时间向支付者返回失败消息，这一延迟等于任何路由节点尝试再平衡其通道以支持支付所花费的时间。

## Bech32 发送支持

*在 [系列][bech32 series] 中的第 17 周，关于允许你支付的人访问所有 segwit 的好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/17-signmessage.md %}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案 (BIPs)][bips repo] 中值得注意的更改。*

- [Bitcoin Core #15427][] 扩展 `utxoupdatepsbt` RPC，添加了一个 `descriptors` 参数，该参数接收一个 [输出脚本描述符] 并使用它来更新 [BIP174][] 部分签名比特币交易 (PSBT)，包括交易中涉及脚本（地址）的信息。这是对 RPC 以前行为的补充，之前的行为是从节点的内存池和 UTXO 集中添加信息。这个新功能对于硬件钱包和其他配对钱包尤其有用，因为它使得可以向 PSBT 添加 HD 密钥路径信息，这样被要求签名 PSBT 的钱包可以轻松派生签名所需的密钥，或验证找零输出确实支付回钱包。

- [Bitcoin Core #16257][] 如果未签名交易的费率高于 `maxtxfee` 配置选项（默认：0.1 BTC）设置的最大金额，将中止向其添加资金。以前，资金代码会默默地将费用减少到最大值，这可能导致用户由于交易中的输入错误而多付高达 1200 美元的费用（按当前价格计算）。新行为给了用户修复输入错误的机会，消除了任何资金损失。

- [Eclair #1045][] 增加了对标签长度值 (Tag-Length-Value, TLV) 消息编码的支持。LN 实现计划在未来将大多数消息移到这种格式。LND 和 C-Lightning 之前已经实现了 TLV 支持。

{% include linkers/issues.md issues="15427,16326,16257,1045" %}
[bech32 series]: /en/bech32-sending-support/
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[eclair 0.3.1]: https://github.com/ACINQ/eclair/releases/tag/v0.3.1
[tlv pr]: https://github.com/lightningnetwork/lightning-rfc/pull/607
[pickhardt jit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001891.html
[zmn jit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002055.html
