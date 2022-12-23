---
title: 'Bitcoin Optech Newsletter #230'
permalink: /zh/newsletters/2022/12/14/
name: 2022-12-14-newsletter-zh
slug: 2022-12-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一项可能提高通道工厂兼容性的闪电网络修改版本的提案，描述了不修改闪电网络协议而减轻通道阻塞攻击影响的软件，以及用于跟踪未标信号的交易替换的网站链接。此外还包括我们的常规部分，其中包含新客户端和服务软件的公告、Bitcoin Stack Exchange 中热门问题及其回答的摘要，以及对流行的比特币基础设施软件的重大变更的描述。

## 新闻

- **<!--factory-optimized-ln-protocol-proposal-->为通道工厂优化的闪电网络协议提案：** John Law 在 Lightning-Dev 邮件列表中[发帖][law factory]，描述了一个优化创建[通道工厂][topic channel factories]的协议。通道工厂允许多个用户在多对用户之间无需信任地打开多个通道，而链上只有一个交易。例如，20 个用户可以合作创建一个链上交易。该交易比通常两方打开通道的交易要大 10 倍，但它会总共打开 190 个通道<!-- n=20 ; n*(n - 1)/2-->。

    Law 指出，现有的闪电网络通道协议（通常称为 LN-penalty）在从工厂内部打开的通道时会产生两个问题：

    - *<!--long-required-htlc-expiries-->HTLC 过期所需时间长：*无需信任化要求工厂中的任何参与者都能够退出并重新获得对其链上资金的唯一控制权。这是通过参与者在链上工厂中发布当前余额状态来实现的。然而，这需要一种机制来防止参与者发布早前的状态，例如他们控制更多资金的状态。原始的工厂提案通过使用一个或多个时间锁定交易来实现这一点，这些交易确保可以比过时状态更快地确认更新的状态。

        Law 描述这会带来的一个后果是，由工厂中的通道而路由的任何闪电网络支付（[HTLC][topic htlc]）都需要提供足够的时间让最新状态的时间锁到期，以便工厂可以单方面关闭。更糟糕的是，每次通过工厂转发付款时都会发生这种情况。例如，如果付款通过 10 个工厂转发，每个工厂的有效期为 1 天，则付款可能会被意外或故意地[阻塞][topic channel jamming attacks] 10 天（或更长时间，取决于其它 HTLC 设置）。

    - *<!--all-or-nothing-->全有或全无：* 为了让工厂真正达到最佳效率，他们的所有通道也需要在一个链上交易中合作关闭。如果原始参与者中的任何一个不响应，则合作关闭是不可能的——并且随着参与者数量的增加，有参与者不响应的可能性接近 100%，从而限制了工厂所能带来的最大好处。

        Law 引用了以前的工作：这些工作让工厂可在有参与者想离开或是变得不再响应时，仍然保持运营，例如 `OP_TAPLEAF_UPDATE_VERIFY` 和 `OP_EVICT`（参见周报 [#166][news166 tluv] 和 [#189][news189 evict]）。

    Law 提出了三个拟定的协议来解决这些问题。所有这些都源自 Law 在 10 月份[发布][law tp]的一项关于*可调惩罚*的提议——它可以将强制机制（惩罚）的管理与其他资金的管理分开。这个之前的提案尚未在 Lightning-Dev 邮件列表中收到任何讨论。在撰写本文时，Law 的新提案也还没有收到任何讨论。如果这些提案是合理的，那么它们将比其他提案更具优势，因为它们不需要对比特币的共识规则进行任何更改。

- **<!--local-jamming-to-prevent-remote-jamming-->防止远程阻塞的本地阻塞：**Joost Jager 在 Lightning-Dev 邮件列表中为他的项目 [CircuitBreaker][] [发布][jager jam]了链接及其说明。该程序设计为与 LND 兼容，对本地节点替每一个对手方节点转发的待处理付款（[HTLCs][topic htlc]）数量进行限制。例如，考虑最坏情况下的 HTLC 阻塞攻击情况：

    ![两种不同阻塞攻击的图示](/img/posts/2020-12-ln-jamming-attacks.png)

    在当前的闪电网络协议中，Alice 从根本上被限制为最多同时转发 [483 个待处理的 HTLC][483 pending HTLCs]。如果她改用 CircuitBreaker 并将她与 Mallory 的通道限制为并发的转发 10 个待处理 HTLC，则除了 Mallory 保持待处理的前 10 个 HTLC 之外，她与 Bob 的下游通道（未图示）以及此回路中的所有其他通道都将受到保护。要求 Mallory 打开更多通道来阻挡相同数量的 HTLC 存储槽（slot），可使她支付更多的链上费用，增加攻击成本，从而可能会显著降低 Mallory 攻击的有效性。

    尽管 CircuitBreaker 最初被实现用来简单地拒绝接受任何通道中的任何超过其限制的 HTLC，但 Jager 指出，他最近实现了一种可选的附加模式。该模式将任何 HTLC 放入队列中，而不是立即拒绝或转发它们。当通道中并发的待处理的 HTLC 数量低于通道限制时，CircuitBreaker 从队列中转发未过期的最老的 HTLC。Jager 描述了该方法的两个优点：

    - *<!--backpressure-->反向压力：* 如果回路中间的节点拒绝 HTLC，则回路中的所有节点（不仅仅是回路中更远的节点）都可以使用该 HTLC 的存储槽和资金来转发其他付款。这意味着 Alice 拒绝来自 Mallory 的 10 个以上 HTLC 的激励很有限——她可以简单地希望回路中的某个之后的节点将运行 CircuitBreaker 或等效软件。

        然而，如果一个之后的节点（比如 Bob）使用 CircuitBreaker 将多余的 HTLC 排进队列，那么 Alice 仍然可以让她的 HTLC 存储槽或资金被 Mallory 耗尽，即使 Bob 和线路中的后续节点保留与现在相同的收益（除了在某些情况下可能会增加 Bob 通道关闭的成本；有关详细信息，请参阅 Jager 的电子邮件或 CircuitBreaker 文档）。这会是一种温和的方式来迫使 Alice 运行 CircuitBreaker 或类似的东西。

    - *<!--failure-attribution-->失败归因：*当前的闪电网络协议允许（在许多情况下）花费者确定哪个通道拒绝转发 HTLC。一些花费软件会在未来一段时间内的 HTLC 中避免使用这些通道。在拒绝来自 Mallory 等恶意行为者的 HTLC 的情况下，这显然无关紧要，但如果运行 CircuitBreaker 的节点拒绝来自诚实花费者的 HTLC，这不仅可能会减少其从那些被拒绝的 HTLC 中获得的收入，而且还会减少它本应从随后的付款尝试中获得的收入。

        然而，闪电网络协议目前没有一个已广泛部署的方法来确定哪个通道推迟了 HTLC，因此在这方面，延迟转发 HTLC 不如直接拒绝转发它那么重要。Jager 指出，这种情况正在发生变化。由于许多闪电网络实现致力于支持更详细的洋葱路由错误消息（参见[周报 #224][news224 fat]），所以这一比较优势可能有一天会消失。

    Jager 称 CircuitBreaker 为“处理通道阻塞和垃圾邮件的一种简单而不完美的方法”。寻找和部署协议级变更的工作仍在继续。这种变更将更全面地减轻对阻塞攻击的担忧，但 CircuitBreaker 作为一种看似合理的解决方案脱颖而出。它与当前的闪电网络协议兼容，任何 LND 用户都可以立即将其部署在他们的转发节点上。CircuitBreaker 是 MIT 许可并且概念上很简单，因此它应该有可能适配或移植到其他闪电网络实现上。

- **监控全面 RBF 替换：** 开发人员 0xB10C 在 Bitcoin-Dev 邮件列表中[发布][0xb10c rbf]，他们已经开始提供[可公开访问][rbf mpo]的监控其不包含 BIP125 信号的 Bitcoin Core 节点交易池中的交易替换。他们的节点允许使用 `mempoolfullrbf` 配置选项进行全面 RBF 替换（参见[周报 #208][news208 rbf]）。

    用户和服务可以使用该网站作为大型矿池目前可能正在确认未标信号的替换交易（如果有的话）的指标。但是，我们提醒读者，即使矿工在当时似乎没有在挖未标信号的交易替换，也无法保证能在 0 确认的交易中收到付款。

## 服务与客户端软件变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有意思的更新。*

- **Lily钱包新增选币功能：**
  Lily钱包 [v1.2.0][lily v1.2.0] 新增[选币][topic coin selection]功能。

- **Vortex 软件从 coinjoin 创建闪电网络通道：**
  使用 [taproot][topic taproot] 和协作式的 [coinjoin][topic coinjoin] 交易，用户用 [Vortex][vortex github] 软件已在比特币主网上[打开闪电网络通道][vortex tweet]。

- **Mutiny 在一个浏览器中概念验证闪电网络节点：**
  开发人员使用 WASM 和 LDK [演示了][mutiny tweet]在一个手机浏览器中运行的闪电网络节点的[概念验证][mutiny github]实现。

- **Coinkite 上线 BinaryWatch.org：**
  [BinaryWatch.org][] 网站检查来自比特币相关项目的二进制文件并监控所有变更。该公司还运营 [bitcoinbinary.org][]，一项为比特币相关项目存档[可重现构建][topic reproducible builds]的服务。

## 来自 Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们有疑问时寻找答案的首选之地，也是我们有闲暇时会帮助好奇和困惑的用户的地方。在这个月度栏目中，我们会列出自上次出刊以来的高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-is-connecting-to-the-bitcoin-network-exclusively-over-tor-considered-a-bad-practice-->为什么仅通过 Tor 连接到比特币网络被认为是一种不好的做法？]({{bse}}116146)
  几个答案解释说，与 IPv4 和 IPv6 地址相比，生成多个 Tor 地址的成本较低。因此相较于仅在 clearnet 上运行或组合使用[匿名网络][topic anonymity networks]的节点，一个仅使用 Tor 网络的比特币节点运营者会更容易被[日蚀攻击][topic eclipse attacks]

- [<!--why-aren-t-3-party-or-more-channels-realistically-possible-in-lightning-today-->为什么 3 方（或更多方）通道在今天的闪电网络中不现实？]({{bse}}116257)
  Murch 解释说，由于闪电网络通道目前使用的惩罚机制是在违约时将*所有*通道资金分配给单个交易对手方，将这一惩罚机制扩展到处理正常交易的多个接收者可能会过于复杂，并且实施起来会产生过多的开销。然后他解释了 [eltoo 的][topic eltoo]机制以及它如何处理多方通道。

- [<!--with-legacy-wallets-deprecated-will-bitcoin-core-be-able-to-sign-messages-for-an-address-->随着历史钱包被弃用，Bitcoin Core 是否能够为地址签名消息？]({{bse}}116187)
  Pieter Wuille 对 Bitcoin Core 在[弃用中的历史钱包][news125 legacy descriptor wallets]和对旧地址类型（如 P2PKH 地址）持续支持，甚至在较新的[描述符][topic descriptors]钱包中持续支持之间的进行了区分。虽然消息签名目前仅适用于 P2PKH 地址，但围绕 [BIP322][topic generic signmessage] 的一些工作可允许跨其他地址类型进行消息签名。

- [<!--how-do-i-set-up-a-time-decay-multisig-->如何设置一个随时间衰减的多重签名？]({{bse}}116035)
  用户 Yoda 询问如何设置随时间衰减的多重签名。这是一种随着时间的推移，其可花费的公钥集不断扩大的 UTXO。Michael Folkson 提供了一个使用[策略][news74 policy miniscript] 和 [miniscript][topic miniscript] 的示例、相关资源的链接，并指出目前用户友好选项的缺失。

- [<!--when-is-a-miniscript-solution-malleable-->什么时候 miniscript 解决方案是可变形的（malleable）？]({{bse}}116275)
  Antoine Poinsot 定义了不定形（malleability）在 miniscript 上下文中的含义，描述了 miniscript 中不定形的静态分析，并解释了一遍原始问题中的不定形的示例。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 24.0.1][] 是最广泛使用的全节点软件的一个主要版本。它的新功能包括一个用于配置节点的 [Replace-By-Fee][topic rbf]（RBF）策略的选项、一个新的用于在单个交易中轻松花费所有钱包的资金（或以其他方式创建没有找零输出的交易）的 `sendall` RPC、一个可用于验证交易将如何影响一个钱包（例如，用于确保 coinjoin 交易仅从钱包中扣除手续费） `simulaterawtransaction` RPC、提高与其他软件的向前兼容的包含 [miniscript][topic miniscript] 表达式的观察[描述符][topic descriptors]以及将 GUI 中所做的某些设置变更自动应用到基于 RPC 的操作中。有关新功能和错误修复的完整列表，请参阅[发布说明][bcc rn]。

    注意：版本 24.0 已标记并发布了它的二进制文件，但项目维护者从未公告该版本，而是与其他贡献者合作解决[一些最后时刻的问题][bcc milestone 24.0.1]。这使得这个 24.0.1 版本成为 24.x 分支中首个被公告的版本发布。

- [libsecp256k1 0.2.0][] 是这个被广泛用来进行与比特币相关密码学操作的库的第一个标记版本。版本发布的[公告][libsecp256k1 announce]声明：“很长一段时间内，libsecp256k1 的开发只有一个 master 分支，使得 API 兼容性和稳定性并不明确。未来，我们将在合并相关改进时创建标记版本，并遵循语义化版本控制方案。[...]我们跳过版本 0.1.0，因为这个版本号多年来一直设置在我们的自动化工具来构建脚本，并且没有唯一的去标识一组源文件。我们不会创建二进制文件发布，但会在发布说明和版本控制中考虑预期的 ABI 兼容性问题。”

- [Core Lightning 22.11.1][] 是一个小版本发布。它应一些下游开发人员的要求，暂时重新引入了一些在 22.11 中弃用的功能。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #25934][] 向 `listsinceblock` RPC 添加了一个可选的 `label` 参数。当被给定一个标签时，它只会返回与该标签相匹配的交易。

- [LND #7159][] 修改 `ListInvoiceRequest` 和 `ListPaymentsRequest` RPC，在其中新增 `creation_date_start` 和 `creation_date_end` 字段，可用于过滤掉指定日期和时间之前或之后的收据和付款。

- [LDK #1835][] 为拦截的 HTLC 添加了一个假的短通道标识符（SCID）命名空间，使闪电网络服务提供商（LSP）能够为最终用户创建一个[即时][topic jit routing]（JIT）通道接收闪电网络付款。这是通过在最终用户收据中包含伪造的路由提示来实现的。这些收据向 LDK 发出信号，表明这是一个拦截转发，类似于[幻影支付][LDK phantom payments]（参见[周报 #188][news188 phantom]）。然后 LDK 会生成一个事件，让 LSP 有机会打开 JIT 通道。LSP 此后就可以通过这个新打开的通道来转发付款，否则会失败。

- [BOLTs #1021][] 允许洋葱路由错误消息包含一个 [TLV][] 流，将来可能会使用它来包含有关故障的更多信息。这是实现 [BOLTs #1044][] 中提议的[“胖错误”（fat errors）][news224 fat] 的第一步。

## 节日快乐！

这是 Bitcoin Optech 今年最后一次常规周报。 12 月 21 日，星期三，我们将发布第五份年度回顾周报。常规发布将于 1 月 4 日星期三恢复。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25934,7159,1835,1021,1044" %}
[bitcoin core 24.0.1]: https://bitcoincore.org/bin/bitcoin-core-24.0.1/
[bcc rn]: https://bitcoincore.org/en/releases/24.0.1/
[bcc milestone 24.0.1]: https://github.com/bitcoin/bitcoin/milestone/59?closed=1
[libsecp256k1 0.2.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.2.0
[libsecp256k1 announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021271.html
[core lightning 22.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v22.11.1
[news224 fat]: /zh/newsletters/2022/11/02/#ln-routing-failure-attribution
[law factory]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003782.html
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[news189 evict]: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership
[law tp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[jager jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003781.html
[circuitbreaker]: https://github.com/lightningequipment/circuitbreaker
[0xb10c rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021258.html
[rbf mpo]: https://fullrbf.mempool.observer/
[news208 rbf]: /zh/newsletters/2022/07/13/#bitcoin-core-25353
[tlv]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[483 pending htlcs]: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md#rationale-7
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[LDK phantom payments]: https://lightningdevkit.org/blog/introducing-phantom-node-payments/
[news125 legacy descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news74 policy miniscript]: /en/newsletters/2019/11/27/#what-is-the-difference-between-bitcoin-policy-language-and-miniscript
[lily v1.2.0]: https://github.com/Lily-Technologies/lily-wallet/releases/tag/v1.2.0
[vortex tweet]: https://twitter.com/benthecarman/status/1590886577940889600
[vortex github]: https://github.com/ln-vortex/ln-vortex
[mutiny tweet]: https://twitter.com/benthecarman/status/1595395624010190850
[mutiny github]: https://github.com/BitcoinDevShop/mutiny-web-poc
[BinaryWatch.org]: https://binarywatch.org/
[bitcoinbinary.org]: https://bitcoinbinary.org/
