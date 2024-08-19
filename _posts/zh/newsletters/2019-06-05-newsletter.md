---
title: 'Bitcoin Optech Newsletter #49'
permalink: /zh/newsletters/2019/06/05/
name: 2019-06-05-newsletter-zh
slug: 2019-06-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了提议的 Erlay 协议，该协议可以显著减少节点之间中继未确认交易的开销，总结了 Bitrefill CEO Sergej Kotliar 关于闪电网络的执行简报，并列出了一些最近对上周描述的 COSHV 提案的更改内容。还包括我们关于 Bech32 发送支持和流行比特币基础设施项目中值得注意的代码更改的常规部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}
{% include specials/2019-exec-briefing/zh/lightning.md %}

## 行动项

*本周无。*

## 新闻

- **<!--erlay-proposed-->****Erlay 提议：**Gleb Naumenko、Pieter Wuille、Gregory Maxwell、Sasha Fedorova 和 Ivan Beschastnikh 的一篇新论文描述了一种替代交易中继协议，[Erlay][]。当前，当一个节点了解到一个新的交易并且该交易通过了其中继策略时，它会将该交易的 txid 通知其所有的节点（除了之前已经通知过的节点）。这是一种非常简单有效的策略，但效率不高——节点接收到的大多数通知是它几分钟前从其他节点已经得知的交易通知。根据论文，这种冗余浪费了大约 44% 的所有节点带宽。

  论文尝试使用作者的 Erlay 协议来减少这种冗余，该协议将中继分为两个阶段：扇出阶段和对账阶段。在扇出阶段，节点仅将其了解到的新交易直接宣布给从节点的出站节点中选出的最多八个节点。

  在对账阶段，节点将定期从其每个出站节点请求一个短交易标识符（短 txids）的*草图*，该草图用于所有该节点通常会宣布给该节点的新交易。草图是使用 [libminisketch][] 库创建的，该库在[Newsletter #26][] 中描述，它基于纠错码实现了一种高效带宽的集合对账技术。收到请求的草图后，节点自身也会生成一个草图，其中包含它通常会宣布给其对等节点的所有新交易。节点将其草图与对等节点的草图结合，以生成任何差异的列表。该差异包含集合中新交易中某一个集合中但不在另一个集合中的交易的短 txids。节点随后可以从该对等节点请求任何缺失的交易，并继续查询其下一个对等节点的草图。每秒钟重复一次，以便节点能够快速接收未通过扇出通知接收到的任何交易。这种简单的两步协议（扇出和对账）描述了 Erlay 的主要操作；论文中描述和分析的协议的其余部分涵盖了用于草图的最佳参数和一系列如果集合对账失败的后备步骤。

  在描述 Erlay 协议之后，论文使用一个模拟的由 60,000 个节点（数量和使用情况与当前比特币网络相似）组成的网络和一组分布在多个数据中心的 100 个国际节点的实时集分析其性能。最值得注意的结果是，Erlay 减少了用于宣布新交易存在的带宽量 84%。然而，交易在网络中传播到所有节点的时间大约增加了 80%（2.6 秒）。比特币交易平均每十分钟只能确认一次，因此三秒的延迟似乎是为了大幅减少带宽而支付的合理代价。

  在确定该协议是一个值得的效率改进之后，论文考虑了其最重要的次要方面：其对隐私的影响。目前，每个 Bitcoin Core 节点都稍微延迟向其对等节点中继交易；这使得间谍节点更难以使用时间关联来猜测他们从中接收到交易的第一个对等节点是创建交易的节点。针对网络对等节点中不同数量的间谍节点（从 5% 到 60% 的间谍节点），进行了多次模拟测试当前中继协议与 Erlay 的有效性。在间谍节点是接受入站连接的公共节点的情况下，Erlay 的表现总是等于或优于当前协议。在间谍节点是向诚实节点发起连接的私有节点的情况下，Erlay 有时表现得更好，有时表现得更差——但从未比当前协议差 10% 以上（这种最坏的情况是不太可能出现的情况）。论文还指出，Erlay 与提议的 [BIP156][] 蒲公英协议兼容，以进一步提高网络对间谍节点的抵抗力。

  考虑到比特币中继策略的未来可能变化，论文指出，如果出站节点数量从 8 增加到 32，Erlay 节点用于宣布新交易存在的带宽仅会增加 32%，而使用当前协议则会增加 300%。正如上述关于 Erlay 两个阶段的段落所描述的，新交易仍然仅通过直接公告扇出给 8 个对等节点，但节点将对所有 32 个对等节点执行集合对账。四倍的中继连接改进增加了时间敏感交易（如闪电网络合约协议）快速到达矿工的机会。

  除了 libminisketch，实现 Erlay 在 Bitcoin Core 中所需的代码更改仅为 584 行代码，并且在比实际预期条件更差的情况下，集合对账的 CPU 密集型部分的基准测试耗时不到一毫秒。如果对该论文没有异议，Naumenko 已宣布计划撰写一份 BIP 并努力将 Erlay 包含在 Bitcoin Core 的后续版本中。用于交易中继的方法是 P2P 网络协议的一部分（不是共识规则），因此该更改可以在多个用户升级后立即开始运行，尽管我们预计节点还将包括一个向后兼容模式以支持尚未升级的对等节点。

- **<!--presentation-operating-on-lightning-->****演讲：闪电网络操作：**Bitrefill CEO Sergej Kotliar 为上个月的 Optech 执行简报做了关于闪电网络的演讲。[视频][kotliar ln]现已发布。 {{operating-on-lightning-zh}}

- **<!--coshv-proposal-replaced-->****COSHV 提案被替换：**我们在[上周][news48 coshv]描述的 COSHV 提案的作者用一个不同名称的[类似提案][alt-coshv]替换了该提案。新提案不仅检查交易输出的哈希——现在哈希还包括交易的版本号、输入数量、序列号和锁定时间。此更改消除了与交易易变性相关的问题，这些问题会影响使用带有某些类型合约协议（如闪电网络）的操作码。此外，通过对交易中允许的输入数量进行哈希处理，原始提案对单个输入的限制被解除——然而，该提案警告称，仍然建议只允许一个输入以避免不必要的交互。（注意：除了新名称外，更改不会影响我们上周撰写的 COSHV 摘要。）

## Optech 推荐

在撰写本文时，Bitcoin Core 项目目前有[超过 300 个开放的拉取请求 (PR)][core prs]。其中一些正在进行中，但其余大部分正在等待开发人员审核，并确定需要修复的任何问题或确认它们可以合并。

如果您想通过审核 PR 来帮助改进 Bitcoin Core，但不确定如何入门，我们建议您查看 [Bitcoin Core PR Review Club][]. 在每周的 IRC 会议中，经验丰富的 Bitcoin Core 贡献者提供有关选定 PR 的背景信息，然后回答新贡献者的现场问题。通常，他们会得到其他知名 Bitcoin Core 贡献者的协助，有时包括正在讨论的 PR 的作者。

Optech 建议任何希望更多参与 Bitcoin Core 过程的工程师参加。IRC 会议在每周三 17:00 UTC 举行。

## Bech32 发送支持

*在 [Bech32 系列][bech32 series] 中为期 24 周的第 12 周，旨在让您支付的对象获得隔离见证的所有好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/12-midway.md %}

## 值得注意的代码和文档更改

*[Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案（BIPs）][bips repo] 本周的值得注意的更改。*

- [Bitcoin Core #15741][] 通过批处理数据库更新而不是顺序更新，加快了使用 `importmulti` RPC 导入密钥、地址和其他信息到钱包中的速度。在 PR 作者执行的测试中，这将导入 10,000 个地址的时间从 465 秒减少到 4 秒。

- [LND #2985][] 等待中继 gossip 公告，直到有至少十个要发送的公告，并且距离上一个批次已经过去五秒，从而减少带宽开销。这延续了 LND 和其他实现为减少 gossip 协议开销而进行的工作，因为闪电网络在过去一年中显著增长。

- [LND #2761][] 切换为使用持久状态机进行路由支付，并为机器存储一些额外的状态数据，提高了程序正确处理守护进程重启时未解决的 HTLC 的能力。

{% include linkers/issues.md issues="15741,2985,2761" %}
[bech32 series]: /zh/bech32-sending-support/
[news48 coshv]: /zh/newsletters/2019/05/29/#提议的交易输出承诺
[alt-coshv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/016997.html
[kotliar ln]: https://www.youtube.com/watch?v=1UDD9PMFTds
[Bitcoin Core PR Review Club]:https://bitcoin-core-review-club.github.io/
[core prs]: https://github.com/bitcoin/bitcoin/pulls
[newsletter #26]: /zh/newsletters/2018/12/18/#minisketch-library-released
[Erlay]: https://arxiv.org/pdf/1905.10518.pdf