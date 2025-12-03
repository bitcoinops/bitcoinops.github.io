---
title: 'Bitcoin Optech Newsletter #92'
permalink: /zh/newsletters/2020/04/08/
name: 2020-04-08-newsletter-zh
slug: 2020-04-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了简化版 ECDSA 适配器签名的工作，并包括我们定期提供的 Bitcoin Core PR 审查俱乐部讨论摘要、发布公告以及值得注意的比特币基础设施项目的变更。

## 行动项

*本周无。*

## 新闻

- **<!--work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures-->****使用简化的 ECDSA 适配器签名为闪电网络 (LN) 实现 PTLCs 的工作：**
  点时间锁定合约 (PTLCs) 是当前用于支持 LN 路由支付的哈希时间锁定合约 (HTLCs) 的替代方案。现有 HTLC 机制的问题在于，支付路径上的每个跳点都使用相同的哈希摘要来保护其条件支付。这意味着如果用户控制了同一路径上的两个节点，则可以确定这两个节点之间的跳点既不是支付的最终支付方，也不是接收方。这不仅减少了 LN 的洋葱路由提供的隐私，还允许恶意用户窃取中间跳点的路由费用（这被称为[虫洞攻击][wormhole attack]）。例如，在以下路径中，Mallory 可以窃取 Bob 和 Carol 的路由费用，并推断出他们都不是支付的最终支付方或接收方。

  ```
  Alice → Mallory → Bob → Carol → Mallory' → Dan
  ```

  PTLCs 通过使用适配器签名（表示椭圆曲线上的 *点*）而非哈希，使每个跳点可以使用不同的标识符来处理支付。适配器签名最初是为 [Schnorr 签名][topic schnorr signatures]描述的。已知可以在比特币当前的 ECDSA 签名方案中使用它们（参见 [Newsletter #16][news16 2pecdsa scriptless]），但该过程依赖于双方 ECDSA 签名（2pECDSA），这种方式比较复杂，并且需要超出比特币 ECDSA 签名通常要求的安全假设。然而，最近 Lloyd Fournier 发表了一篇[论文][fournier otves]，描述了如何使用常规的 2-of-2 比特币多重签名（例如 `OP_CHECKMULTISIG`）和简单离散对数等价（DLEQ）来安全地使用适配器签名；该内容已在去年 11 月的 [Lightning-Dev 邮件列表][uSEkaCIO email]中进行了总结。

  上周在 [Lightning HackSprint][] 活动中，几位开发者[参与了][ptlc challenge]这些 2-of-2 多重签名适配器签名的工作。成果包括关于该主题的出色[博文][gibson blog]以及 C 语言 [libsecp256k1][jonasnick otves] 和 Scala [bitcoin-s][nkohen otves] 库的概念验证实现。虽然这些代码尚未经过审查且可能存在安全隐患，但它为开发者在主网上开始实验适配器签名提供了帮助，既可以用于 LN 中的 PTLCs，也可以用于其他无需信任的合约协议中。

## Bitcoin Core PR 审查俱乐部

_在本节中，我们总结了一次最近的 Bitcoin Core PR 审查俱乐部会议，重点介绍了一些重要的问答。点击下面的问题以查看会议中答案的摘要。_

[更紧急地重试 `notfound`][review club 18238] 是 Anthony Towns 提出的一个 PR（[#18238][Bitcoin Core #18238]），该 PR 将更改点对点行为，使得当节点在请求交易时收到 `notfound` 消息时，它们将跳过当前的超时周期，而是尽快从另一个节点获取交易。

讨论从 PR 的基本原因开始：

{% include functions/details-list.md
  q0="为什么更快重试 `notfound` 会有所帮助？"
  a0="防止 DoS 攻击、提高交易传播速度、增强隐私以及未来可能移除 `mapRelay`。"

  q1="可能的 DoS 攻击担忧是什么？"
  a1="拥有小内存池的节点可能通过宣布交易但无法交付它来无意中减慢交易中继速度。"

  q2="为什么交易传播速度很重要？"
  a2="几秒钟的短暂延迟并不是问题（甚至对隐私有益），但几分钟的较长延迟会损害交易的传播和 [BIP152][] 致密区块的中继。"

  q3="**<!--q3-maprelay-->**`mapRelay` 是什么时候、为什么添加的？"
  a3="`mapRelay` 在比特币的第一个版本中就已存在。它确保如果节点宣布了某笔交易，即使该交易在被请求之前已经被确认在区块中，也可以下载该交易。"

  q4="**<!--q4-maprelay-->**描述移除 `mapRelay` 的一个问题？"
  a4="它可能导致在诚实情况下，请求的交易更频繁地返回 `notfound`，延迟可达 2 分钟，从而影响传播。"
%}

在会议的后期，讨论了 `TxDownloadState` 数据结构：

{% include functions/details-list.md
  q0="**<!--q0-txdownloadstate-->**描述 `TxDownloadState` 结构的作用？"
  a0="这是一个每对等方的状态机，带有定时器，用于协调从对等方请求交易。"

  q1="**<!--q1-txdownloadstate-->**我们如何改进 `TxDownloadState`，以减少未来引入交易中继错误的可能性？"
  a1="向该结构添加内部一致性检查，或用具有良好定义接口的类替换它。"
%}

随后讨论深入探讨了 PR 的实现、潜在问题以及未来的改进及其与 [wtxid 交易中继][wtxid transaction relay]提案的交互。更多详情，请参阅[学习笔记和会议记录][review club 18238]。

## 发布与候选发布

*受欢迎的比特币基础设施项目的新发布版本和候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [Eclair 0.3.4][] 已发布，支持开启价值超过 0.168 BTC 的通道（参见 [Newsletter #88][news88 eclair1323]）并支持[可重复构建][topic reproducible builds]（参见 [Newsletter #87][eclair determ]）。此外还包括错误修复和许多其他改进。详情请参阅他们的[发布说明][eclair 0.3.4]。

## 值得注意的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [C-Lightning #3612][] 添加了启动参数 `--large-channels` 和 `--wumbo`（二者等效）。如果使用该参数，节点将在其 `init` 消息中广播对 `option_support_large_channel` 的支持，这意味着它将接受价值高于先前约 0.168 BTC 限制的通道开启。如果远程对等方也支持此选项，C-Lightning 的 `fundchannel` RPC 将允许用户创建超过先前限制的通道。参见 [Newsletter #88][news88 eclair1323] 中描述的 Eclair 对此选项的支持。

- [C-Lightning #3600][] 添加了对使用*盲化路径*的*洋葱消息*的实验性支持：

  - **<!--onion-messages-->***洋葱消息*（在 [Newsletter #86][news86 ln dm] 中称为 "LN 直接消息"）允许节点在不使用 LN 支付机制的情况下通过网络发送加密消息。这可以替代应用程序如 [Whatsat][] 使用的消息-支付机制。与消息-支付相比，洋葱消息具有几个优势：

    1. 它们有一个[草案规范][onion messages draft spec]，如果被采用，将使多个实现支持它们变得更容易。

    2. 它们不需要链上可强制执行的支付通道的安全性，因此即使在没有共享支付通道的对等方之间，洋葱消息也可以路由。

    3. 它们不需要像 HTLC 或错误消息那样进行双向信息传输，因此一旦节点转发消息，它不需要保留与该消息相关的任何信息。这种无状态性将最大限度地减少节点的内存需求。如果发送节点希望接收回复，草案规范允许它在消息中包含一个盲化的 `reply_path` 字段，接收节点可以使用该字段通过新消息发送回复。

  - **<!--blinded-paths-->***盲化路径*（在 [Newsletter #85][news85 lw rv] 中称为“轻量级汇合路由”并现在有[草案提案][blinded path gist]）使得在发送方不知道接收方网络身份或完整路径的情况下路由支付或消息成为可能。这是通过以下步骤实现的：

    1. 目的节点从中间节点选择一条路径到自己，然后将该路径信息进行洋葱加密，以便路径中的每个跳点只能解密下一个应该接收消息的节点标识符。目的节点将这个加密的（“盲化的”）路径信息提供给发送节点（例如，通过 [BOLT11][] 发票中的一个字段或使用前面提到的洋葱消息 `reply_path` 字段）。

    2. 发送节点使用常规的洋葱路由将消息转发到中间节点。

    3. 中间节点从盲化路径中解密出下一个应该使用的跳点，并将消息发送给该跳点。下一个节点解密自己的下一个跳点字段并进一步转发消息；这一过程一直持续到消息到达目的节点。

    就像普通的洋葱路由一样，任何路由节点都不应了解盲化路径的更多信息，除了哪个节点向它发送了消息以及哪个节点应该在它之后接收消息。与普通路由不同的是，起点节点和终点节点都不需要了解对方的身份或它们使用的确切路径。这不仅提高了这些端点的隐私，也提高了盲化路径中的任何未公布节点的隐私。

  该 PR 指出，“目前尚未定义[消息]的内容，除了路由和回复所需的内容，但目的是使用这种机制实现报价。”报价将允许节点通过 LN 请求和发送发票；详情参见 [Newsletter #72][news72 offers]。

- [LND #4087][] 添加了支持在[命令行][watchtower tor]启用时自动创建瞭望塔的 Tor 隐藏服务的功能。

- [LND #4079][] 添加了使用[部分签名比特币交易][topic psbt]（PSBTs）为通道提供资金的支持，允许任何兼容 PSBT 的钱包为通道开启提供资金。之前，通道资金只能通过 LND 的内部钱包完成。一旦通道获得资金，LND 将像往常一样管理所有其他操作。用户可以通过在 `lncli openchannel` 中提供 `--psbt` 标志来启动交互式对话以完成资金流；详情参见[文档][lnd psbt]。

- [LND #3970][] 将对[多路径支付][topic multipath payments]的支持添加到 LND 的支付生命周期系统中，该系统负责跟踪“完成支付所需的所有状态信息”。<!-- routing/payment_lifecycle.go --> 这使 LND 更接近其 0.10 版本的目标，即能够完全支持多路径支付。<!-- Alex Bosworth email, "In 0.10.0 I think the main new feature will be the ability to multipath." -->

{% include references.md %}
{% include linkers/issues.md issues="3612,3600,4087,4079,3970,18238" %}
[news86 ln dm]: /zh/newsletters/2020/02/26/#ln-direct-messages
[news85 lw rv]: /zh/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news88 eclair1323]: /zh/newsletters/2020/03/11/#eclair-1323
[news72 offers]: /zh/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[whatsat]: https://github.com/joostjager/whatsat
[onion messages draft spec]: https://github.com/lightningnetwork/lightning-rfc/pull/759
[blinded path gist]: https://github.com/lightningnetwork/lightning-rfc/blob/route-blinding/proposals/route-blinding.md
[ptlc challenge]: https://wiki.fulmo.org/index.php?title=Challenges#Point_Time_Locked_Contracts_.28PTLC.29
[gibson blog]: https://joinmarket.me/blog/blog/schnorrless-scriptless-scripts/
[wormhole attack]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/privacy-preserving-multi-hop-locks/
[lightning hacksprint]: https://wiki.fulmo.org/index.php?title=Main_Page
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[news16 2pecdsa scriptless]: /zh/newsletters/2018/10/09/#多方-ecdsa-用于无脚本的闪电网络支付通道
[uSEkaCIO email]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002316.html
[jonasnick otves]: https://github.com/jonasnick/secp256k1/pull/14/
[nkohen otves]: https://github.com/bitcoin-s/bitcoin-s/pull/1302
[lnd psbt]: https://github.com/lightningnetwork/lnd/blob/master/docs/psbt.md
[review club 18238]: https://bitcoincore.reviews/18238.html
[wtxid transaction relay]: https://bitcoincore.reviews/18044
[watchtower tor]: https://github.com/lightningnetwork/lnd/blob/master/docs/watchtower.md#tor-hidden-services
[eclair 0.3.4]: https://github.com/ACINQ/eclair/releases/tag/v0.3.4
[eclair determ]: /zh/newsletters/2020/03/04/#eclair-1307
