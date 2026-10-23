---
title: 'Bitcoin Optech Newsletter #49'
permalink: /zh/newsletters/2019/06/05/
name: 2019-06-05-newsletter-zh
slug: 2019-06-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍提议的 Erlay 协议——它能大幅降低节点之间中继未确认交易的开销；概述 Bitrefill CEO Sergej Kotliar 在一场面向高管的简报会上关于 LN 的演讲；并列出上周介绍的 COSHV 提案最近的一些改动。常规章节照旧包括 bech32 发送支持与热门比特币基础设施项目中值得注意的代码变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}
{% include specials/2019-exec-briefing/zh/lightning.md %}

## 行动项

*本周无。*

## 新闻

- **<!--erlay-proposed-->****Erlay 提议：**Gleb Naumenko、Pieter Wuille、Gregory Maxwell、Sasha Fedorova 和 Ivan Beschastnikh 的一篇新论文描述了一种替代交易中继协议，[Erlay][]。目前，当一个节点得知一笔通过其自身中继策略的新交易时，它会把该交易的 txid 宣告给它的所有对等节点（此前向它宣告过该交易的对等节点除外）。这是一个非常简单有效的策略，但效率不高——节点收到的大多数宣告，都是它片刻之前已经从另一个对等节点得知的那些交易的宣告。论文指出，这种冗余浪费了节点全部带宽的约 44%。

  论文尝试用作者提出的 Erlay 协议来消除这种冗余。该协议把中继分为两个阶段：扇出阶段和集合对账阶段。在扇出阶段，节点只把新得知的交易直接宣告给它从自己的出站对等节点中挑出的最多八个。

  在集合对账阶段，节点会定期向它的每个出站对等节点索取一份*草图（sketch）*，其中包含该对等节点通常会向本节点宣告的全部新交易的短交易标识符（短 txid）。草图由 [libminisketch][] 库生成，该库见 [Newsletter #26][] 的介绍，它基于纠错码实现了一种带宽效率极高的集合对账技术。收到对方发来的草图后，节点也会为自己通常会宣告给该对等节点的所有新交易生成一份草图，再把两份草图合并，得出二者之间的差异清单。这份差异里包含了那些只出现在一方的新交易集合、而不在另一方的交易的短 txid。接着，节点就可以向该对等节点索取自己缺少的交易，然后转向下一个对等节点索取它的草图。每秒针对一个新的对等节点重复一次，节点便能迅速拿到那些没通过扇出宣告收到的交易。这种“扇出 + 对账”的两步协议构成了 Erlay 的主要运作方式；论文中描述并分析的其余部分，则涵盖了草图的优选参数，以及集合对账某次尝试失败时可供采用的一系列后备步骤。

  介绍完 Erlay 协议后，论文用一个 6 万节点的模拟网络（节点数量与使用情况都与当前的比特币网络相近），以及一组分布在多个数据中心、横跨各国的 100 个实时节点，来分析它的性能。最值得注意的结果是：Erlay 把用于宣告新交易存在的带宽减少了 84%。不过，交易传播到全网所有节点所需的时间也拉长了约 80%（2.6 秒）。比特币交易平均每十分钟只能确认一次，因此三秒的延迟似乎是为了大幅减少带宽而支付的合理代价。

  在确认该协议是一项值得做的效率改进之后，论文考察了它最重要的次要方面：对隐私的影响。目前，每个 Bitcoin Core 节点都稍微延迟向其对等节点中继交易；这让间谍节点更难用时间关联去推断：自己最先收到某笔交易的那个对等节点，就是创建这笔交易的对等节点。针对网络对等节点中不同数量的间谍节点（从 5% 到 60% 的间谍节点），进行了多次模拟测试当前中继协议与 Erlay 的有效性。在间谍节点是接受入站连接的公共节点的情况下，Erlay 的表现总是等于或优于当前协议。在间谍节点是向诚实节点发起连接的私有节点的情况下，Erlay 有时更好、有时更差——但差距从未超过 10%（而且这个最坏情况本身不太可能出现）。论文还指出，Erlay 与提议的 [BIP156][] 蒲公英协议兼容，以进一步提高网络对间谍节点的抵抗力。

  考虑到比特币中继策略未来可能的变化，论文指出：若把出站对等节点数量从 8 个增加到 32 个，Erlay 下节点用于宣告新交易存在的带宽只会增加 32%，而沿用当前协议则会增加 300%。正如前面讲 Erlay 两个阶段的段落所述，新交易仍然只通过直接宣告扇出给 8 个对等节点，但节点会与全部 32 个对等节点做集合对账。中继连接数提升到四倍，让 LN 这类合约协议中时间敏感的交易更有机会迅速抵达矿工。

  除 libminisketch 之外，在 Bitcoin Core 中实现 Erlay 所需的代码改动只有 584 行；即使在比实际预期更糟的条件下，集合对账中那部分 CPU 密集型操作的实测耗时也不到一毫秒。如果论文没有遭到反对，Naumenko 已表示打算撰写一份 BIP，并推动 Erlay 进入 Bitcoin Core 的后续版本。交易中继方式属于 P2P 网络协议（而非共识规则），因此只要足够多用户完成升级，这项改动就能开始生效；不过我们预计节点还会提供向后兼容模式，以支持尚未升级的对等节点。

- **<!--presentation-operating-on-lightning-->****演讲：在 LN 上运营业务：**Bitrefill CEO Sergej Kotliar 上个月在 Optech 面向高管的简报会上做了关于 LN 的演讲。[演讲视频][kotliar ln]现已发布。 {{operating-on-lightning-zh}}

- **<!--coshv-proposal-replaced-->****COSHV 提案被替换：**我们在[上周][news48 coshv]描述的 COSHV 提案的作者用一个不同名称的[类似提案][alt-coshv]替换了该提案。新提案检查的不只是交易输出的哈希——现在的哈希还包含交易的版本号、输入数量、sequence 号和 locktime。这一改动消除了交易可延展性带来的隐患：若把该操作码用于某些类型的合约协议（例如 LN），原本会受到这类问题的影响。此外，由于把交易允许的输入数量也纳入哈希，原提案“只能有一个输入”的限制得以解除——不过该提案也提醒，仍建议只允许单个输入，以免产生意料之外的相互作用。（注意：除了新名称外，更改不会影响我们上周撰写的 COSHV 摘要。）

## Optech 推荐

截至本文写作时，Bitcoin Core 项目有[超过 300 个尚未合并的拉取请求（PR）][core prs]。其中一部分仍在开发中，其余大多正等着开发者审阅——或指出需要修复的问题，或认可它们已可以合并。

如果你想通过审阅 PR 来帮助 Bitcoin Core 改进，却不知从何入手，我们建议你看看 [Bitcoin Core PR Review Club][]. 在每周的 IRC 会议中，经验丰富的 Bitcoin Core 贡献者提供有关选定 PR 的背景信息，然后回答新贡献者的现场问题。通常还有 Bitcoin Core 的资深贡献者从旁协助，有时甚至包括正在讨论的那个 PR 的作者。

Optech 建议任何希望更多参与 Bitcoin Core 过程的工程师参加。IRC 会议在每周三 17:00 UTC 举行。

## Bech32 发送支持

*这是 [bech32 系列][bech32 series] 24 周中的第 12 周，该系列讲的是如何让你付款的对象享受到 segwit 的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/12-midway.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中的值得注意的变更。*

- [Bitcoin Core #15741][] 通过批处理数据库更新而不是顺序更新，加快了使用 `importmulti` RPC 导入密钥、地址和其他信息到钱包中的速度。在 PR 作者执行的测试中，这将导入 10,000 个地址的时间从 465 秒减少到 4 秒。

- [LND #2985][] 等待中继 gossip 公告，直到有至少十个要发送的公告，并且距离上一个批次已经过去五秒，从而减少带宽开销。鉴于过去一年 LN 网络规模大幅增长，这也延续了 LND 与其他实现为降低 gossip 协议开销所做的工作。

- [LND #2761][] 改为对转发支付使用持久化状态机，并为该状态机额外保存一些状态数据，从而提升了程序正确处理“守护进程重启时尚未结清”的 HTLC 的能力。

{% include linkers/issues.md issues="15741,2985,2761" %}
[bech32 series]: /zh/bech32-sending-support/
[news48 coshv]: /zh/newsletters/2019/05/29/#提议的交易输出承诺
[alt-coshv]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/016997.html
[kotliar ln]: https://www.youtube.com/watch?v=1UDD9PMFTds
[Bitcoin Core PR Review Club]:https://bitcoin-core-review-club.github.io/
[core prs]: https://github.com/bitcoin/bitcoin/pulls
[newsletter #26]: /zh/newsletters/2018/12/18/#minisketch-library-released
[Erlay]: https://arxiv.org/pdf/1905.10518.pdf