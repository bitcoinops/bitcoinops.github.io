---
title: 'Bitcoin Optech Newsletter #71'
permalink: /zh/newsletters/2019/11/06/
name: 2019-11-06-newsletter-zh
slug: 2019-11-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求帮助测试 Bitcoin Core 候选版本，汇总了关于 LN 锚定输出的持续讨论，并描述了一个提议：让全节点和轻量级客户端都能表示自己是否支持 IP 地址中继。此外还有我们介绍热门比特币基础设施项目值得注意的变更的固定栏目。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-release-candidate-->****帮助测试 Bitcoin Core 候选版本：**我们鼓励有经验的用户帮助测试即将发布的 [Bitcoin Core][Bitcoin Core 0.19.0] 的最新候选版本。

## 新闻

- **<!--continued-discussion-of-ln-anchor-outputs-->****关于 LN 锚定输出的持续讨论：**正如[上周的 Newsletter][news70 simplified commitments]中所述，LN 开发者正努力让通道的任一方都能通过 CPFP 为结算交易追加手续费，所用手段是预计随 Bitcoin Core 0.19.0 一同发布的 CPFP 豁免（carve-out）内存池策略。本周在[邮件列表][jager anchor]和 [BOLTs 仓库][bolts #688] 中讨论的主题包括：

  - 单方面关闭通道的一方（“本地”方）与另一方（“远程”方）是否都应等待相同的延迟才能取回自己的资金，还是双方都应能在通道创建过程中协商各自作为远程方时要用的延迟时长。目前只有本地方会被延迟，有人担心这可能导致某些人设法操纵另一方去关闭通道，好让操纵者更快拿到自己的资金。

  - 锚定输出使用什么脚本。此前曾提议，脚本中应包含一个子句，允许任何人在经过适当延迟后花费该输出，以免大量小额输出污染 UTXO 集。但这里有个复杂之处：脚本可能需要包含一个第三方无从知晓的唯一公钥，这会使第三方无法独立生成花费该 P2WSH 输出所需的见证脚本。

  - 锚定输出应放入多少比特币。发起通道开启的一方负责支付这笔金额（因为在当前协议中所有手续费都由它支付），所以它大概希望金额越低越好——但该金额必须高于大多数节点的最小输出金额（“粉尘限制”）。讨论中还提到，这一金额是否应当可配置。

  - 每笔 LN 支付是否应支付到不同的公钥（采用公钥调整）。有人提议移除公钥调整，以减少需要跟踪的状态量，但随之而来的担忧是这会让通道状态过于确定。这可能使瞭望塔在收到来自通道某一方的一系列加密违约补救交易后，不仅能解密所需的那笔违约补救交易，还能解密该通道中所有其他违约补救交易——从而使瞭望塔能够重建该通道中每笔支付的金额和哈希锁，严重削弱隐私。

  针对上述问题的解决方案不断被提出，提案也在接受更多审查，讨论仍在继续。

- **<!--signaling-support-for-address-relay-->****表示支持地址中继：**全节点通过 P2P 协议的 `addr`（地址）消息，与对等节点分享自己听说过的其他全节点的 IP 地址，从而实现完全去中心化的对等节点发现。SPV 客户端也能借助这一机制了解全节点，不过大多数客户端目前采用某种中心化的节点发现方式，因此发给它们的 `addr` 消息只会浪费带宽。

  Gleb Naumenko 向 Bitcoin-Dev 邮件列表发送了一封[邮件][naumenko addr relay]，建议节点和客户端应向对等节点表明自己是否愿意参与地址中继。这样既能避免向不需要地址的客户端浪费带宽，也更容易判断与地址中继相关的某些网络行为会带来什么后果。

  有两种方法可以让节点表明自己是否愿意参与地址中继——按节点的方法和按连接的方法。按节点的方法可以很方便地建立在已为 addrv2 消息开展的工作之上（参见 [Newsletter #37][news37 addrv2]），但不如按连接的方法灵活。特别是，按连接的方法可以让节点把一部分连接专门用于交易中继，另一部分专门用于地址中继，从而可能带来隐私上的好处。Naumenko 的邮件希望全节点和轻量级客户端的实现者反馈更倾向于哪种方法。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Bitcoin Core #16943][] 添加了一个 `generatetodescriptor` RPC，允许在测试期间生成的新区块（例如在 regtest 模式下）支付给由[输出脚本描述符][output script descriptor]表示的脚本。在此变更之前，只有 `generatetoaddress` RPC 可用，而且它只能支付给 P2PKH、P2SH 或 P2WSH 地址。

- [C-Lightning #3220][] 开始一律使用低 *r* 值生成签名，使签名的最大长度减少一个字节，并在与 C-Lightning 对等节点的链上交易中平均节省约 0.125 vbyte。Bitcoin Core 此前也已在其钱包的签名生成代码中采用了这一变更（参见 [Newsletter #8][news8 lowr]）。

- [LND #3558][] 针对两个特定节点之间开有多个通道的所有情形，合成出一套统一的路由策略，并在考虑经其中任一通道路由时使用这套统一策略。[BOLT4][bolt4 non-strict rec] 建议同一对节点之间的多个通道应使用相同的策略，但实际情况并不总是如此，因此这一变更尝试找出节点之间所有策略的“最大公约数”。使用单一策略可以减少节点在付款时需要评估的路由数量。

- [LND #3556][] 添加了一个新的 `queryprob` RPC，在给定源节点、目标节点和支付金额的情况下，返回支付成功的预期概率。它取代了此前从 `querymc` RPC 中移除的功能。

- [BOLTs #660][] 更新了 [BOLT1][]，把小于 2<sup>16</sup> 的 TLV（类型-长度-值）类型标识符保留给 LN 规范（BOLT 文档）中定义的类型使用。其余取值可由任何 LN 实现自由用作自定义记录。更新后的规范还给出了如何为自定义记录类型选取编号的指引。

{% include linkers/issues.md issues="16943,3558,3556,660,3220,688" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[bolt4 non-strict rec]: https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#recommendation
[news37 addrv2]: /zh/newsletters/2019/03/12/#version-2-addr-message-proposed
[news8 lowr]: /zh/newsletters/2018/08/14/#bitcoin-core-wallet-to-begin-only-creating-low-r-signatures
[naumenko addr relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017428.html
[news70 simplified commitments]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[jager anchor]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002264.html
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
