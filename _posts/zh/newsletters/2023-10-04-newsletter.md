---
title: 'Bitcoin Optech Newsletter #271'
permalink: /zh/newsletters/2023/10/04/
name: 2023-10-04-newsletter-zh
slug: 2023-10-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一项关于通过硬件签名设备远程控制 LN 节点的提案，并描述了允许 LN 中继节点动态地拆分 LN 支付的代码及其隐私性研究，同时还提出了一项提高 LN 流动性的建议，即允许一组中继节点将资金单独汇集到与正常通道分开的池中。此外，还有我们的常规栏目：包括新版本的公告和对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **LN 节点的安全远程控制：** Bastien Teinturier 在 Lightning-Dev 邮件列表中[发帖][teinturier remote post]，提出了一个 [BLIP 提议][blips #28]，该提议将指定用户如何从硬件签名设备（或任何其他钱包）向他们的 LN 节点发送签名命令。签名设备只需要实现 BLIP 加上 [BOLT8][] 对等通信，而 LN 节点只需要实现 BLIP。这类似于 Core Lightning 的 _commando_ 插件(见[周报 #210][news210 commando])，该插件允许对 LN 节点进行几乎所有的远程控制。但 Teinturier 设想他提议的功能主要是用于控制最敏感的节点操作，例如授权支付——可以假设用户愿意不厌其烦地连接和解锁硬件安全设备并授权操作的那种操作。这将使终端用户更容易使用保护其链上余额的硬件签名设备来保护他们的 LN 余额。{% assign timestamp="1:48" %}

- **<!--payment-splitting-and-switching-->支付拆分和切换：** Gijs van Dam 在 Lightning-Dev 邮件列表中[发帖][van dam pss post]，介绍了他为 Core Lightning 编写的一个[插件][pss plugin]，以及与之相关的一些[研究][pss research]。该插件允许转发节点告诉它们的对等节点，它们支持 _支付拆分和切换_ (PSS)。如果 Alice 和 Bob 共享一个通道，而且他们都支持 PSS，那么当 Alice 收到要转发给 Bob 的支付时，该插件可能会将其拆分为两个或多个[支付部分][topic multipath payments]。其中一个支付可能像正常一样转发给 Bob，但其他支付可能遵循替代路径（例如，从 Alice 到 Carol 再到 Bob）。Bob 等待接收所有部分，然后像正常一样继续将支付转发给下一跳。

    这种方法的主要优点是，它更难执行 _余额发现攻击_ (BDAs)，在这种攻击中，第三方反复[探测][topic payment probes]通道以跟踪其余额。如果频繁执行，BDA 可以跟踪通过通道的支付金额。如果在许多通道上执行，它可能能够跟踪该支付在整个网络上的路径。当使用 PSS 时，攻击者不仅需要跟踪 Alice 和 Bob 通道的余额，还需要跟踪 Alice 和 Carol 以及 Carol 和 Bob 通道，才能跟踪支付。即使攻击者确实跟踪了所有这些通道的余额，跟踪支付的计算难度也会增加，因为通过这些通道同时传输的其他用户支付的部分可能会与被追踪的原始支付的部分混淆。van Dam 的[论文][pss research]显示，部署PSS时，攻击者获得的信息量减少了62%。

    van Dam 关于 PSS 的论文中提到，增加 LN 吞吐量以及作为缓解[通道阻塞攻击][topic channel jamming attacks]的一部分，这两点也是 PSS 的额外好处。截至本文写作时，关于 PSS 的想法在邮件列表中得到了少量讨论。{% assign timestamp="12:23" %}

- **<!--pooled-liquidity-for-ln-->LN 的池化流动性：** ZmnSCPxj 在 Lightning-Dev 邮件列表中[发帖][zmnscpxj sidepools1]，提出了他称之为 _sidepools_ 的建议。这将涉及转发节点小组共同将资金存入多方状态合同——这是一种链下合同（类似于 LN 通道，带有链上的锚），该合同将允许通过更新链下合同状态在参与者之间移动资金。例如，最初将 Alice、Bob 和 Carol 分别给予 1 BTC 的状态可以更新为一个新的状态，其中 Alice 有 2 BTC，Bob 有 0 BTC，Carol 有 1 BTC。

    转发节点也将继续使用并公布节点对之间的普通 LN 通道；例如，前面描述的三个用户可以有三个独立的通道：Alice 和 Bob、Bob 和 Carol 以及 Alice 和 Carol。他们将完全按照现有的方式在这些通道上转发支付。

    如果一个或多个普通通道变得不平衡，例如，Alice 和 Bob 之间的通道中的资金现在大部分属于 Alice，则可以通过在状态合同中执行链下 [peerswap][] 来解决不平衡。例如，Carol 可以在状态合同中向 Alice 提供一些资金，前提是 Alice 通过 Bob 在普通的 LN 通道中将相同金额的资金转发给 Carol，以此来恢复 Alice 和 Bob 之间 LN 通道的平衡。

    这种方法的一个优点是，除了每个特定合同中的参与者之外，没有人需要知道状态合同的存在。对于所有普通的 LN 用户和所有不参与特定合同的转发节点来说，LN 将继续使用当前协议运行。与现有的通道再平衡操作相比，另一个优点是，状态合同方法允许大量转发节点以很小的链上空间维护直接的对等关系，可能消除了这些对等节点之间的任何离线再平衡费用。将再平衡费用保持在最低有助于转发节点保持通道平衡，从而提高其收入潜力并使得通过 LN 的支付更可靠。

    该方法的一个缺点是，它需要一个多方状态合同，而这在我们所知的范围内，从未在产品化中实现过。ZmnSCPxj 提到了两个可能有用的合同协议，可以用作基础，即 [LN-Symmetry][topic eltoo] 和 [duplex 支付通道][duplex payment channels]。LN-Symmetry 将需要共识更改，这在近期似乎不太可能发生，因此 ZmnSCPxj 的[后续贴文][zmnscpxj sidepools2]似乎正在关注 duplex 支付通道(ZmnSCPxj 根据最早提出它们的研究人员将其称为“Decker-Wattenhofer”)。一个关于 duplex 支付通道的缺点是，它们无法无限期地保持打开状态，尽管 ZmnSCPxj 的分析表明，它们可能可以保持打开足够长的时间，并在足够多的状态更改中摊销它们的成本。

    在撰写本文时，对这些帖子还没有公开回复，尽管我们从与 ZmnSCPxj 的私人通信中了解到，他正在进一步开发该想法。{% assign timestamp="34:31" %}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.17.0-beta][] 是此热门 LN 节点实现的下一主要版本。此版本包括一项重大的实验性功能，即支持“简单 [taproot][topic taproot] 通道”，以允许使用 P2TR 输出在链上注资[未公开通道][topic unannounced channels]。这是向 LND 通道添加其他功能的第一步，例如支持 [Taproot Assets][topic client-side validation] 和 [PTLCs][topic ptlc]。此版本还包括对 Neutrino 后端用户的显著性能提升，包括支持[致密区块过滤器][topic compact block filters]，以及对 LND 内置[瞭望塔][topic watchtowers]功能的改进。有关更多信息，请见[版本说明][lnd rn]和[版本博客贴文][lnd 17 blog]。{% assign timestamp="55:26" %}

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo][Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Eclair #2756][] 引入监控[通道拼接][topic splicing]操作的功能。提供的指标收集操作的发起者，并区分了三种类型的拼接：splice-in，splice-out 和 splice-cpfp。{% assign timestamp="58:26" %}

- [LDK #2486][] 增加了在单笔交易中为多个通道注资的支持，确保无论批处理通道是全部注资和打开，还是全部关闭，都可以实现原子性。{% assign timestamp="1:01:33" %}

- [LDK #2609][] 允许请求在过往交易中用于接收支付的[描述符][topic descriptors]。之前，用户必须自行存储这些数据；通过更新的API，现在可以从其他存储的数据中重建这些描述符。{% assign timestamp="1:02:34" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="2756,2486,2609,28" %}
[LND v0.17.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta
[teinturier remote post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004084.html
[news210 commando]: /zh/newsletters/2022/07/27/#core-lightning-5370
[van dam pss post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004114.html
[pss plugin]: https://github.com/gijswijs/plugins/tree/master/pss
[pss research]: https://eprint.iacr.org/2023/1360
[zmnscpxj sidepools1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004099.html
[peerswap]: https://github.com/ElementsProject/peerswap
[duplex payment channels]: https://www.tik.ee.ethz.ch/file/716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[zmnscpxj sidepools2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004108.html
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.17.0.md
[lnd 17 blog]: https://lightning.engineering/posts/2023-10-03-lnd-0.17-launch/
