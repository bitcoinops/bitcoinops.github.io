---
title: 'Bitcoin Optech Newsletter #270'
permalink: /zh/newsletters/2023/09/27/
name: 2023-09-27-newsletter-zh
slug: 2023-09-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分介绍了一种使用限制条款（covenants）以大幅提高闪电网络可扩展性的提议。此外是我们的常规栏目：Bitcoin Stack Exchange 上的热门问答的总结、软件新版本和候选版本的公告，还有热门的比特币基础设施软件的重大变更。

## 新闻

- **<!--using-covenants-to-improve-ln-scalability-->使用限制条款以提升闪电网络的可扩展性**：John Law 在 Bitcoin-Dev 和 Lightning-Dev 邮件组中%#0%#，总结了他所撰写的[论文][law cov paper]：使用[限制条款][topic covenants]来创建非常大的[通道工厂][topic channel factories]，并使用他之前提出的几种协议的变种来管理其中的通道（见：[周报 #221][news221 law]、[周报 #230][news230 law] 和 [周报 #244][news244 law]）。

    他的论述的起点是，大量用户参与基于签名的协议（比如 [coinjoins][topic coinjoin] 和以前的通道工厂设计）会面临可扩展性问题：如果 1000 个用户都同意参加一个协议，但其中一个在需要签名的时候离线了，那么剩下的 999 个签名就会变成无用的东西。如果在下一次尝试期间，另一个人离线了，那在第二次尝试期间收集起来的 998 个签名也将变得无用。他提议使用 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 和 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 这样的限制条款作为这个问题的一种解决方案：众所周知，这些限制条款允许使用单笔体积较小的交易，将资金限制为只能被预先定义的一笔或连续多笔子交易花费。后续的交易也可以被一个限制条款限制。

    Law 使用这种机制来创建一种 “*超时树（timeout tree）*”：一笔 *注资交易* 会支付给一棵由预定义的子交易组成的树，这些子交易最终会在链下形成大量独立的支付通道。一种类似于 Ark 所用的机制（见[周报 #253][news253 ark]）允许每一个支付通道都可以选择发布到链上，但它也允许工厂的投资者在超时之后重新取回任何没有发布到链上的通道资金。这可以是非常高效的：一个在链下为几百万个通道注资的超时树，可以使用一个小体积的链上交易创建出来。在超时之后，资金可以被工厂投资者用另一笔小体积的链上交易重新取回，个人用户在通道工厂到期之前通过闪电网络将自己的资金取出到其它通道中。

    上述模式兼容当前使用的 LN-Penalty 通道构造以及已经提出的 [LN-Symmetry][topic eltoo] 机制。但是，Law 的论文的剩余部分关注他以前提出的 “全面优化的免瞭望塔通道工厂（FFO-WF）” 协议的修改版，这个协议为基于限制条款的通道设计提供了多种好处。除了前面提到的好处，例如 *低频用户* 只需每几个月上线几分钟，以及 *专业用户* 可以更高效地在多个通道中分配资本，升级后的构造还允许通道投资者为低频用户从一个工厂（基于某一笔链上交易）迁移到另一个工厂（锚定在另一笔链上交易中），而无需跟这个用户交互。这意味着，低频用户 Alice 知道自己应该在所在工厂为期 6 个月的过期时间到来之前回到链上，但当她在第 5 个月回到线上时，她发现自己的资金已经滚动到了另一个还要好几个月才会过期的新工厂中。这减少了 Alice 在临界过期时回到线上、发现自己的通道资金暂时不能动用，只好将超时树关于自己的部分发到链上（导致交易费并降低整体的网络可扩展性）的几率。

    Anthony Towns [回复][towns cov]以一种顾虑，关于他所谓的 “惊群” 问题（在[闪电网络最初论文][ln paper]中称为 “强制过期诈骗”）：一个大体量的专业用户的有意或无意的错误，将要求其他许多用户将许多时间敏感的交易一齐发布到链上。举个例子，一个拥有 100 万用户的工厂，可能需要高达 100 万笔时间敏感型交易得到确认，外加高达 200 万笔非时间敏感的、让这些用户将资金投入新通道的交易得到确认，所以，百万用户的工厂的用户，可能希望工厂在过期前几个星期就滚动资金 —— 甚至提前几个月滚动资金，如果他们担心多个百万用户的工厂同时出问题的话。

    闪电网络初始论文的一个版本提出：这个问题可以使用 Gregory Maxwell 提出的一个[想法][maxwell clock stop]来解决：在 “区块满载”（例如手续费高出正常值）时推迟过期。在 Law 对 Towns 的[回复][law fee stop]中，他指出，他正在为一类解决方案开发一种设计，他将在完成思考后发布。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者有疑问时寻找答案的首选，也是我们在有闲暇时帮助好奇和困惑的用户的地方。在这个月度栏目中，我们会列出自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-did-peer-discovery-work-in-bitcoin-v01-->Bitcoin v0.1 中的对等节点发现是如何工作的？]({{bse}}119507)
  Pieter Wuille 介绍了 Bitcoin Core 中的对等节点发现机制的演化，从 0.1 版本的基于 IRC 的对等节点发现，再到基于硬编码的 IP 地址，最后是当前使用的 DNS 对等节点种子获取。

- [<!--would-a-series-of-reorgs-cause-bitcoin-to-break-because-of-the-2hour-block-time-difference-restriction-->一连串的重组会导致比特币因为 2 小时的区块时间差限制而崩溃吗？]({{bse}}119677)
  用户 fiatjaf 询问，一连串的区块重组（可能由 “[手续费狙击][topic fee sniping]” 导致）是否会对比特币的区块时间戳限制造成破坏。Antoine Poinsot 和 Pieter Wuille 介绍了两种区块时间戳限制（必须大于[过往中值时间 MTP][news146 mtp]，而且不能越过节点本地时间两个小时以上），并断定这两个限制都不会因为重组而恶化。

- [<!--is-there-a-way-to-download-blocks-from-scratch-without-downloading-block-headers-first-->有没有办法从头开始下载区块而不下载区块头？]({{bse}}119503)
  Pieter Wuille 确认，可以只下载区块而不下载区块头，但指出，这样做的缺点在于，除非下载并处理完所有区块，否则节点将无法知道自己是不是在工作量最多的链上。他对比了这种方法和 “[先下载区块头型同步][headers first pr]”，并列举了每一种方法所需交换的 P2P 消息类型。

- [<!--where-is-the-bitcoin-source-code-is-the-21-million-hard-cap-stated-->声明比特币的 2100 万硬上限的源代码在哪里？]({{bse}}119475)
  Pieter Wuille 解释道，Bitcoin Core 的  `GetBlockSubsidy` 函数定义了补贴的发放计划。他也链接了一份以前的 Stack Exchange 讨论，关于比特币的 [<!--209999999769-btc-limit-->20999999.9769 BTC 限制]({{bse}}38998)，并指出， `MAX_MONEY` 常量也用在共识验证代码的完整性检查中。

- [<!--are-blocks-containing-nonstandard-transactions-relayed-through-the-network-or-not-as-in-the-case-of-nonstandard-transactions-->包含非标准交易的区块也会得到网络转发吗？]({{bse}}119693)
  用户 fiatjaf 回应道，虽然根据[交易池规则][policy series]，这样的非标准交易默认无法在 P2P 网络中转发，但包含非标准交易的区块依然会被转发，只要区块遵守共识规则。

- [<!--when-does-bitcoin-core-allow-you-to-abandon-transaction-->Bitcoin Core 在什么时候会允许你“抛弃”一笔交易？]({{bse}}119771)
  Murch 详细列举了在 Bitcoin Core 中[抛弃][rpc abandontransaction]一笔交易所需满足的 3 个条件：

  - 该交易之前未被抛弃过
  - 这笔交易以及与之冲突的交易都没有得到区块确认
  - 交易不在节点的交易池中

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级道新版本或帮助测试候选版本。*

- [LND v0.17.0-beta.rc5][] 是这个流行的闪电节点实现的下一个大版本的候选版本。为这个大版本计划的一个主要的新的实验性功能，是支持 “简单的 taproot 通道”，—— 有可能从用户测试中受益。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #28492][] 升级了  `descriptorprocesspsbt` RPC，以包含完全序列化的交易，如果 [PSBT][topic psbt] 的处理结果是一笔可以广播的交易的话。见[上周的周报][news269 psbt]对一个类似的 PR 的介绍。

- [Bitcoin Core GUI #119][] 升级了图形用户界面中的交易列表，不再为 “给你自己的支付” 提供一个特殊的分类。现在，输入和输出都会影响本钱包的交易会显示在单独的行中，用于花费和接受。这可能会让 [coinjoins][topic coinjoin] 和 [payjoins][topic payjoin] 显得更清楚，虽然当前的 Bitcoin Core 自身并不支持这两种交易。

- [Bitcoin Core GUI #738][] 添加了一个菜单选项，允许迁移一个基于密钥、在 BerkeleyDB（BDB）存储中隐含输出脚本类型的老式钱包，成为存储在 SQLite 中、使用[描述符][topic descriptors]的新式钱包。

- [Bitcoin Core #28246][] 升级了 Bitcoin Core 钱包在内部决定一笔交易要支付给哪个输出脚本（脚本公钥）的方式。以前，交易直接支付给用户指定的输出脚本，但是，如果 “[静默支付][topic silent payments]” 添加到了 Bitcoin Core 中，输出脚本将需要从为交易选定的输入中推导出来。这个升级将让推导更加简单。

- [Core Lightning #6311][] 移除了  `--developer` 编译选项（该选项会生成比标准的 CLN 具有额外选项的二进制文件）。现在，实验性的、非默认的特性可以通过使用  `--developer` 运行时配置选项来启动  `lightningd` 来获得。一个  `--enable-debug` 编译选项将产生稍有区别的二进制文件，提供一些有益于测试的修改。

- [Core Lightning #6617][] 升级了  `showrunes` PRC，以提供一个新的结果字段  `last_used`，会显示 *rune*（授权 token）最后一次使用的时间。

- [Core Lightning #6686][] 给 CLN 的 API 的 REST 接口添加了可配置的内容安全策略（CSP）和跨域资源分享（CORS）头。

- [Eclair #2613][] 允许 Eclair 管理自己所有的私钥，并将 Bitcoin Core 仅用作一个观察钱包（只拥有公钥、不拥有私钥的钱包）。如果 Eclair 自身运行在比 Bitcoin Core 更安全的环境中，这个功能将非常有用。具体细节见这个 PR 中添加的[说明书][eclair keys]。

- [LND #7994][] 为远程的签名器 RPC 接口提供了支持，可以开启 taproot 通道，这需要指定一个公钥以及 [MuSig2][topic musig] 的两半型 nonce。

- [LDK #2547][] 更新了概率型寻路的代码，假设远程的通道的大部分流动性大概率会位于其中一端（而非两端平分）。举个例子，在 Alice 和 Bob 的一个容量为 1.00 BTC 的远程通道中，最不可能的通道状态就是 Alice 和 Bob 各拥有 0.50 BTC。更有可能的是其中一方拥有 0.90 BTC —— 甚至最有可能的是其中一方拥有 0.99 BTC。

- [LDK #2534][] 添加了  `ChannelManager::send_preflight_probes`  方法，用于在尝试发送一笔支付之前[打探][topic payment probes]支付路径。打探会由发送者生成，就像一笔常规的闪电支付一样，但其 [HTLC][topic htlc] 的原像被设成了一个不可用的数值（例如，只有发送者才知道的值）；当它到达目的地时，接收者不知道原像，因此会拒绝它，回传一个错误。如果收到了错误，打探者就知道这个支付路径拥有足够多的流动性来支持目标支付，因此，当带有相同数额的实际支付沿着相同的路径发送时，它很可能会成功。如果收到的错误不是目标类型，例如，暗示了路径上的某一跳无法转发支付，那么可以在发送实际支付前打探一条新的路径。

    支付前（“飞行前”）打探是非常有用的，可以用少量资金找出可能导致时延的跳。如果几百聪（或更小的数额）卡住几个小时，对大部分支付者来说都不是什么问题 —— 但如果大额的支付（代表着一个节点的资本的极大比例）也被卡住这么久，那会非常烦人。还可以同时打探多个路径，并使用得到的结果来为片刻后的支付选出最佳的路径。

{% include references.md %}
{% include linkers/issues.md v=2 issues="28492,119,738,28246,6311,6617,6686,2613,7994,2547,2534" %}
[LND v0.17.0-beta.rc5]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc5
[news253 ark]: /zh/newsletters/2023/05/31/#joinpool
[maxwell clock stop]: https://www.reddit.com/r/Bitcoin/comments/37fxqd/it_looks_like_blockstream_is_working_on_the/crmr5p2/
[law cov post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004092.html
[law cov paper]: https://github.com/JohnLaw2/ln-scaling-covenants
[towns cov]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004095.html
[ln paper]: https://lightning.network/lightning-network-paper.pdf
[law fee stop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004102.html
[news221 law]: /zh/newsletters/2022/10/12/#ln-with-long-timeouts-proposal
[news230 law]: /zh/newsletters/2022/12/14/#factory-optimized-ln-protocol-proposal
[news244 law]: /zh/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[eclair keys]: https://github.com/ACINQ/eclair/blob/d3ac58863fbb76f4a44a779a52a6893b43566b29/docs/ManagingBitcoinCoreKeys.md
[news269 psbt]: /zh/newsletters/2023/09/20/#bitcoin-core-28414
[news146 mtp]: /en/newsletters/2021/04/28/#what-are-the-different-contexts-where-mtp-is-used-in-bitcoin
[headers first pr]: https://github.com/bitcoin/bitcoin/pull/4468
[policy series]: /zh/blog/waiting-for-confirmation/
