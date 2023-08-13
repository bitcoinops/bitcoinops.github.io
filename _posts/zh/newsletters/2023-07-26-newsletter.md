---
title: 'Bitcoin Optech Newsletter #261'
permalink: /zh/newsletters/2023/07/26/
name: 2023-07-26-newsletter-zh
slug: 2023-07-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报介绍了一种用于简化闪电通道合作式关闭的通信的协议，还总结了来自最近一期闪电网络开发者会议的笔记。此外是我们的常规栏目：Bitcoin Stack Exchange 上的热门问题和回答，新版本和候选版本的公告，以及热门比特币基础设施项目的重大变更的介绍。

## 新闻

- **<!--simplified-ln-closing-protocol-->简化的闪电通道关闭协议**：Rusty Russell 在 Lightning-Dev 邮件组中[发帖][russell closing]，提出了一种可以简化两个闪电节点合作关闭通道的流程的提议。在这种新的关闭协议中，其中一个节点告知对手自己想关闭通道，并说明自己愿意支付的手续费金额。这个关闭操作的发起人将负责支付全部手续费，但在标准的合作关闭通道交易中，双方的输出都是立即可以花费的，所以每一方都可以在常规情况下使用 “子为父偿（[CPFP][topic cpfp]）” 来追加手续费。这套新的协议也兼容于在基于 [MuSig2][topic musig] 的 “[无脚本式多签名合约][topic multisignature]” 中交换信息，后者是闪电网络正在开发的升级的一部分，可以提高隐私性并降低链上手续费开销。

    截至本刊撰写的时间，还没有人评论 Russell 的提议，但一些初步评论出现在他带有完整提议的 [pull request][bolts #1096] 上。{% assign timestamp="1:03" %}

-  **<!--ln-summit-notes-->闪电峰会笔记**：Carla Kirk-Cohen 在  Lightning-Dev 邮件组中[发帖][kc notes]，总结了闪电网络开发者在纽约的最新一次会议的多项讨论。一些主题如下：{% assign timestamp="10:48" %}

    - *<!--reliable-transaction-confirmation-->可靠的交易确认*：“[交易包转发][topic package relay]”、“[v3 交易转发][topic v3 transaction relay]”、“[临时锚点][topic ephemeral anchors]”、“[集群交易池][topic cluster mempool]”，以及其它跟交易转发和挖矿有关的提议，都在会上得到了讨论：它们如何能提供更清晰的路径、让闪电网络的链上交易能更可靠地确认，而不会受到 “[交易钉死攻击][topic transaction pinning]” 的威胁、在使用 [CPFP][topic cpfp] 和 “手续费替换（[RBF][topic rbf]）” 时也不需要过度支付手续费？我们强烈建议对交易转发策略 —— 它会影响几乎所有的二层协议 —— 有兴趣的读者阅读这份笔记，了解闪电网络开发者对这些倡议提出的富有启发的反馈。

    - *<!--taproot-and-musig2-channels-->Taproot 和 Musig2 通道*：简短讨论了使用 [P2TR][topic taproot] 输出和 [MuSig2][topic musig] 签名的通道的开发进度。关于这次讨论的笔记的一个重大部分是关于一种简化的合作式关闭协议的；见上一条新闻，了解这次讨论的结果之一。

    - *<!--updated-channel-announcements-->升级的通道公告*：当前的闪电网络 gossip 协议只转发使用一个 P2WSH 输出、承诺了一个 2-of-2 `OP_CHECKMULTISIG` 脚本的通道的创建和更新公告。若要迁移到使用基于 [MuSig2][topic musig] 的[无脚本式多签名合约][topic multisignature]承诺的 [P2TR][topic taproot] 输出，gossip 协议就需要相应升级。在闪电网络开发者的上一次面对面会议期间，另一个被讨论的[话题][topic channel announcements]（见[周报 #204][news204 gossip]）是：仅对协议作最小量的升级（叫做 “v1.5 gossip”）、仅添加对 P2TR 的支持，还是对协议作更通用的升级（“v2.0”）、允许任何类型的 UTXO 的一个有效签名用在公告中。允许使用任何输出，意味着用在通道公告中的输出（相比当前）更有可能不是用来操作通道的输出，从而打破输出与通道注资交易之间的公开关联。

    人们讨论的一个额外的顾虑是，一个价值为 *n* 的 UTXO 是否允许用来宣布容量大于 *n* 的通道。如果可以，通道参与者可以让自己的一些注资交易保持私密。举个例子，Alice 和 Bob 可以开启两条独立的通道；他们可以使用其中一个通道输出来公告一条容量大于该输出的价值的通道、表明自己可以使用无法跟该输出关联起来的其它通道、路由比该输出价值更大的闪电支付，所以可以更加隐私。这可以帮助提高模糊性：网络中的任何输出，甚至是从未在闪电网络中 gossip 过的输出，都可以用在一条闪电通道中。

    - *<!--ptlcs-and-redundant-overpayment-->PTLC 和超额支付*：从笔记来看，会议简要讨论了协议对 “点时间锁合约（[PTLCs][topic ptlc]）” 的支持，讨论主要跟 “超额支付（[适配器签名][topic adaptor signatures]）” 有关。笔记的更多篇幅分配给了可能影响协议的类似部分的一项改进：[redundantly overpay][topic redundant overpayments]一张发票、并从大部分甚至全部超额部分中获得回款的能力。举个例子，Alice 希望最终给 Bob 支付 1 BTC。她一开始给 Bob 发送了 20 个 “[多路径支付][topic multipath payments]”、每个都价值 0.1 BTC 。使用数学（通过一种叫做 “*Boomerang*” 的技术，详见[周报 #86][news86 boomerang]）或者 “分层承诺（layered commitments）” 或者额外的沟通轮次（叫做 “*Spear*”），Bob 只能领取最多 10 笔支付；任何到达他的节点的多余支付都会被拒绝。这种方法的好处是，最多可以允许 10 笔多路径支付的碎片不送达 Bob 的节点，但依然不会推迟支付。缺点则是额外的复杂性，以及，在所有碎片都到达 Bob 的节点的情况下，可能降低支付速度（使用 Spear 时；相比于当前）。参与者们讨论了是否存在某些变更，既是 PTLC 所需的，又能帮助支持超额支付。

    - *<!--channel-jamming-mitigation-proposals-->通道阻塞攻击的缓解提议*：笔记相当大一部分篇幅总结了关于缓解 “[通道阻塞攻击][topic channel jamming attacks]” 的提议的讨论。讨论的起点是，有人声称已知的解决方案（比如声誉机制和预付费）中，没有哪一种仅凭自身就能令人满意地解决这个问题并且没有不可接受的缺点。声誉机制必须考虑到没有声誉的新节点，以及 HTLC 的自然失败几率 —— 攻击者可以利用这些规定造成某种程度的伤害，即使伤害程度比当前可造成的要轻。预付手续费必须设置得足够高，以阻遏攻击者，但这样可能也会阻遏诚实得用户，并产生一种不正当的激励机制，让节点故意不转发支付。然后，有人提出综合多种机制也许能获得一些好处，而不至于陷入最糟糕的情形中。

    在测试了对这些机制的理解之后，笔记集中于对[周报 #226][news226 jamming] 所述的本地声誉机制的测试的细节，并为一种后续实现、与之搭配的低预付费机制奠定了基础。从笔记来看，似乎参与者们都支持测试这些提议。

    - *<!--simplified-commitments-->简化的承诺*：参与者们讨论了简化的承诺协议的想法（详见[周报 #120][news120 commitments]），该协议定义了哪一个节点应该向对手提议承诺交易的下一次变更，而不是允许任何一方随时提议一笔新的承诺交易。让其中一个通道参与者来主导，消除了双方几乎同时发送两个提议的复杂性，比如 Alice 和 Bob 同时希望给承诺交易增加 [HTLC][topic htlc] 输出的情况。笔记讨论了一个特殊的复杂问题：其中一方不想接受另一方的提议的情形，这在当前的协议中是复杂难解的情形。简化承诺方法的一个缺点是它可能会增加某些情况下的时延，比如当前不负责提议变更的一方需要向对手请求提议的特权，然后才能发出提议。笔记并没有表明讨论中出现了清楚的解决。

    - *<!--the-specification-process-->形成规范的流程*：参与者们还讨论了关于优化形成规范的流程及其管理的文档（比如当前的 BOLT 和 BLIP 以及其它已经成文的提议）的多种想法。讨论似乎非常发散，从笔记中看没有明确的结论。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是它们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-can-i-manually-on-paper-calculate-a-bitcoin-public-key-from-a-private-key-->如何能手动（在纸上）从一个私钥计算出它的比特币公钥？]({{bse}}118933)
  Andrew Poelstra 给出了手动计算验证技术（比如 [codex32][news239 codex32]）的概述，然后逐步分解如何用纸笔从一个私钥中推算出其公钥，他估计这个过程会花费至少 1500 小时（即使优化了流程也是如此）。{% assign timestamp="57:18" %}

- [<!--why-are-there-17-native-segwit-versions-->为什么隔离见证会有 17 种原生版本？]({{bse}}118974)
  Murch 解释道，[隔离见证][topic segwit]为[见证脚本的版本][bip141 witness program]定义了 17 个值（0 - 16），这是因为[比特币 Script][wiki script] 的常数操作码只有 17 个可用（OP_0 ... OP_16）。他指出，其他的数字需要使用数据效率更低的 `OP_PUSHDATA` 操作码实现。{% assign timestamp="59:43" %}

- [<!--does-0-opcsv-force-the-spending-transaction-to-signal-bip125-replaceability-->`0 OP_CSV` 是否强制让花费交易使用 BIP125 可替换性信号？]({{bse}}115586)
  Murch 指出一场[讨论][rbf csv discussion]确认了，因为 `OP_CHECKSEQUENCEVERIFY`（CSV）[时间锁][topic timelocks]和手续费替换（[RBF][topic rbf]）都使用 `nSequence` 字段来[<!--enforced-->实现]({{bse}}87376)，所以一个带有 `0 OP_CSV` 的输出将要求花费交易使用 [BIP125][] 可替换性信号。{% assign timestamp="1:03:04" %}

- [<!--how-do-route-hints-affect-pathfinding-->“路由提示” 会如何影响寻路？]({{bse}}118755)
  Christian Decker 解释了闪电支付的接收方想给发送方提供路由提示的两个原因。一个原因是接收者希望使用[未公开的通道][topic unannounced channels]，需要提示来帮助找出路径。另一个原因是，给发送者提供一个具有充足余额的通道的列表，以完成支付；他将这种技术称为 “加速路由”。{% assign timestamp="1:08:23" %}

- [<!--what-does-it-mean-that-the-security-of-256bit-ecdsa-and-therefore-bitcoin-keys-is-128-bits-->256 位的 ECDSA 的安全性如何？为什么比特币的公钥是 128 位的？]({{bse}}118928)
  Pieter Wuille 解释道，因为有算法可以比暴力搜索更高效地从公钥中推导出私钥，所以 256 位的 ECDSA 只能提供 128 位的安全性。他接着指出纯密钥安全性与[种子][topic bip32]安全性的区别。{% assign timestamp="1:12:26" %}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [HWI 2.3.0][] 是这个让软件钱包可以跟硬件签名设备沟通的中间件的新版本。它添加了对 DIY 的 Jade 设备的支持以及一个二进制文件，可以在安装了 MacOS 12.0+ 的 Apple Silicon 硬件上运行 `hwi` 主程序。{% assign timestamp="1:15:09" %}

- [LDK 0.0.116][] 是这个用于创建闪电网络赋能的应用的库的新版本。它包含了对 “[锚点输出][topic anchor outputs]” 和使用 [keysend][topic spontaneous payments] 的 [多路径支付][topic multipath payments] 的支持。{% assign timestamp="1:16:37" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core GUI #740][] 升级了 [PSBT][topic psbt] 操作对话，以将给你自己的钱包支付的输出标记为 “你自己的地址”。这简化了对导入的 PSBT 的结果的评估，尤其是将找零返回给发送者的交易。{% assign timestamp="1:17:18" %}


{% include references.md %}
{% include linkers/issues.md v=2 issues="740,1096" %}
[russell closing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004013.html
[kc notes]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004014.html
[news193 gossip]: /en/newsletters/2022/03/30/#continued-discussion-about-updated-ln-gossip-protocol
[news204 gossip]: /en/newsletters/2022/06/15/#gossip-network-updates
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[news226 jamming]: /zh/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news120 commitments]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[hwi 2.3.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.0
[ldk 0.0.116]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.116
[news239 codex32]: /zh/newsletters/2023/02/22/#codex32-bip
[bip141 witness program]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#witness-program
[wiki script]: https://en.bitcoin.it/wiki/Script#Constants
[rbf csv discussion]: https://twitter.com/SomsenRuben/status/1683056160373391360
