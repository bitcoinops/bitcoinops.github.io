---
title: 'Bitcoin Optech Newsletter #50'
permalink: /zh/newsletters/2019/06/12/
name: 2019-06-12-newsletter-zh
slug: 2019-06-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了 CoreDev.tech 活动的会议，描述了一项对 BIP125 RBF（Replace-By-Fee）的修订提议，链接了 Optech 有关 Schnorr/Taproot 的高管简报视频，并简短庆祝了 Optech Newsletter 发布的第 50 期。此外，还包括我们常规的 bech32 发送支持部分以及对流行的比特币基础设施项目的值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}
{% include specials/2019-exec-briefing/zh/softfork.md %}

## 行动项

*本周无行动项。*

## 新闻

- **<!--bitcoin-core-contributor-meetings-->****Bitcoin Core 贡献者会议：** 上周，许多贡献者亲自参加了定期举行的 [CoreDev.tech][] 活动，贡献者 Bryan Bishop 提供了实时[会议记录][coredev.tech transcripts]：

  - **<!--code-review-->**6月5日：在一次[代码审查][xs review]会议中，讨论了发给活跃的 Bitcoin Core 贡献者的调查，并提出了几项简化审查流程的建议。

    参与者讨论了将[钱包架构][xs wallet arch]更改为使用[输出脚本描述符][output script descriptors]来生成地址、跟踪付款时间以及查找或推导出用于支付的特定私钥。

  - **<!--consensus-cleanup-soft-fork-->**6月6日：讨论了[共识清理软分叉][xs cleanup sf]，包括它与 [bip-taproot][] 的交互，是否应该删除部分内容，以及是否应该添加任何内容。([更多背景信息][bg consensus cleanup])
    {:#cleanup-discussion}

    小组讨论了如何使[维护者][xs maint]的工作更轻松。除了其他考虑因素外，维护者提到他们非常感谢长期贡献者 Michael Ford 所提供的问题和 PR 管理服务。会议参与者对此的回应是授予 Ford 维护者身份，使他能更有效地工作。

    {:#potential-script-changes}
    讨论了[潜在的脚本更改][xs script change]。讨论围绕 [BIP118][] 和 [bip-anyprevout][] 的签名哈希展开，涉及输出标记（参见 [Newsletter #34][]) 和监护签名（[#47][Newsletter #47]）。同时还审查了更名后的 [bip-coshv][] 操作码（参见 [#48][Newsletter #48]），并考虑了 `OP_CHECKSIGFROMSTACK` 作为一个通用替代方案。

    {:#taproot-accumulator-quantum}
    [Taproot][xs taproot] 议题包括讨论使用默克尔树而非累加器，以及与快速量子计算机相关的风险。([更多背景信息][bg taproot])

    {:#utreexo}
    在关于 [Utreexo][] 累加器的[问答环节][xs utreexo]中，讨论了 UTXO 集的存储要求最小化的这个新兴提案的一些有趣细节。

  - **<!--assumeutxo-->**6月7日：演示并讨论了 [assumeutxo][xs assumeutxo] 提案的代码，包括如何使该提案与其他想法兼容。([更多背景信息][bg assumeutxo])
    {:#assume-utxo-demo}

    {:#hwi}
    贡献者讨论了将[硬件钱包][xs hwi]支持通过 [HWI][] 直接集成到 Bitcoin Core 中。一个特别关注点是代码的分离——确保特定硬件设备的代码由制造商维护而非 Bitcoin Core。([更多背景信息][bg hwi])

    {:#v2-p2p}
    讨论了[版本 2 P2P 传输协议][xs v2 p2p]及相关的对签名协议（参见 [#27][countersign blurb]）。讨论中提到了几种可能的增强。([更多背景信息][bg v2 p2p])

    {:#signet}
    对 [signet][xs signet] 这一类似测试网的链的审查中，重点讨论了分发签名的各种方法。([更多背景信息][bg signet])

    尽管本周才在 Bitcoin-Dev 邮件列表中宣布，[盲状态链][xs blind state]也在会议上进行了讨论。

- **<!--proposal-to-override-some-bip125-rbf-conditions-->****建议覆盖某些 BIP125 RBF 条件：** [BIP125][] 选择性 Replace-By-Fee (RBF) 仅允许以更高费率的替代交易来替换一笔交易，如果替代交易增加了整个内存池中支付的总交易费。这阻止了一种廉价的带宽浪费的拒绝服务（DoS）攻击，但却可能导致对某些 RBF 用例的相对廉价的[交易固定][transaction pinning] DoS 攻击，例如在时间敏感的协议如闪电网络 (LN) 中。

  之前已经有几位开发者尝试解决这个难题，去年年底 Matt Corallo 提出了一个可能的解决方案，即使用 CPFP 费用提升（[CPFP carve out][]，参见 [Newsletter #24][]），并建议通过调整 RBF 来作为替代解决方案。Rusty Russell 之前与 Corallo [讨论][russell-corallo rbf] 了这一 RBF 更改，并进一步完善了它，现在他已将其作为对 BIP125 规则集新增的单一规则[提议][rbf rule 6]给 Bitcoin-Dev 邮件列表。新规则允许内存池中的任何 BIP125 可替换交易在满足两个条件时进行费用提升：

  1. 当前在内存池中的版本低于前 1,000,000 个最具利润的 vbytes（即下一个区块区域）

  2. 替代版本支付的费用足够高，可以进入下一个区块区域

  这将允许任何交易无需考虑其子交易即可进行费用提升，从而消除交易固定问题。然而，使用此规则的任何人都可能减少内存池中的总费用，并可能利用它过度浪费节点带宽。几位人士回复了该提议，提出了这些风险的相关问题并进行了分析。

- **<!--presentation-the-next-softfork-->****演讲：下一个软分叉：** Bitcoin Optech 贡献者 Steve Lee 在上个月的 Optech 高管简报中进行了关于未来比特币软分叉的演讲。该[视频][next sf vid]现已上线。{{the-next-softfork-zh}}

- **<!--optech-celebrates-newsletter-50-->****Optech 庆祝 Newsletter #50：** 去年六月初，John Newbery 给 Dave Harding 发送了一封关于新成立的 Optech 组织计划的电子邮件，其中包括一句话：“我们还将制作一些书面材料[如]每周或每月的新闻摘要。” 那天有点无聊的 Harding 回信时附上了一份未请求的[概念验证 Newsletter][proof-of-concept newsletter]. Newbery 和其他早期的 Optech 贡献者对此很满意，于是他们商定了一些细节，Newsletter 的定期每周出版由此开始。

  五十期之后，Newsletter 现在已有超过 2,500 名电子邮件订阅者，此外还有通过 [RSS][newsletter rss]、[Twitter][optech twitter] 和 Max Hillebrand 的[阅读][hillebrand optech] 订阅的未知数量的额外订阅者。我们总共发布了超过 85,000 字——大约 250 页的内容<!-- 350 words per page -->，并且 Newsletter 草稿版迄今已经从一个了不起的审阅团队那里收到了 948 条评论，他们帮助确保技术的准确性和可读性。新 Newsletter 的公告累计获得了超过 1,300 次转发<!-- 1,359 -->和 3,000 次点赞<!-- 3,087 -->，此外还有在 [Reddit][optech reddit] 上的许多点赞。最重要的是，我们直接听到许多读者表示他们认为 Newsletter 特别有用。

  我们感到惊讶、感激和谦卑，一个纯粹专注于比特币的技术 Newsletter 在其第一年出版中获得了如此惊人的反响。我们知道大家对我们未来的期望很高，希望我们能在接下来的五十期中不负众望。正如往常一样，我们感谢我们的[创始赞助商][founding sponsors]、[会员公司][member companies]、所有为 Newsletter 做出贡献的人以及所有为比特币开发做出贡献的人——没有你们，我们将不得不写一些远没有未来货币那么令人兴奋的东西。

## Bech32 发送支持

*在 [bech32 系列][bech32 series] 中，第 13 周的内容介绍了让你支付的对象能够获得 segwit 所有好处的方法。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/13-adoption-speed.md %}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案 (BIPs)][bips repo] 中的值得注意的变更。*

- [LND #2802][] 允许 LND 计算特定路径成功的概率。然后它结合现有的路径总费用和最大 HTLC 超时时间的计算，使用该概率选择最佳路径。增加了几项新的配置选项，允许用户调整概率计算中使用的常量值，例如“当没有其他信息可用时，假定路径中某跳的成功概率”。拉取请求的作者还在上周末的 Breaking Bitcoin 会议上讨论了[路由成功概率][routing success probability]。

- [C-Lightning #2644][] 改变了 C-Lightning 如何跟踪其向对等节点传递的通道更新。此前，为每个对等节点保留了一个映射，跟踪哪些更新已发送，哪些正在等待发送。现在，整个程序保留一个有序的更新列表，每个对等连接只需跟踪它在该列表中发送到哪个位置。当连接到达列表末尾时，其位置会被标记，以便可以发送随后添加到列表中的任何新条目。当后续更新使之前的更新变得无关紧要时，之前的更新会从全局列表中删除，任何未发送该更新的连接将永远不会看到它。在测试中（可能是作为[百万通道项目][million channels project]的一部分），这将整体内存使用量减少了 35%（约 150 MB），并加快了向所有对等节点发送所有 gossip 公告的速度 62%（约 11 秒）。

{% include linkers/issues.md issues="2802,2644" %}
[bech32 series]: /zh/bech32-sending-support/
[million channels project]: https://github.com/rustyrussell/million-channels-project
[optech reddit]: https://old.reddit.com/domain/bitcoinops.org/
[coredev.tech transcripts]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[xs review]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-05-code-review/
[xs wallet arch]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-05-wallet-architecture/
[xs cleanup sf]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-great-consensus-cleanup/
[bg consensus cleanup]: /zh/newsletters/2019/03/05/#cleanup-soft-fork-proposal
[xs maint]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-maintainers/
[xs script change]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-noinput-etc/
[xs taproot]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-taproot/
[bg taproot]: /zh/newsletters/2019/05/14/#taproot-和-tapscript-提案-bip-概述
[xs utreexo]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-utreexo/
[xs assumeutxo]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-assumeutxo/
[bg assumeutxo]: /zh/newsletters/2019/04/09/#discussion-about-an-assumed-valid-mechanism-for-utxo-snapshots
[xs hwi]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-hardware-wallets/
[bg hwi]: /zh/newsletters/2019/02/19/#bitcoin-core-preliminary-hardware-wallet-support
[xs v2 p2p]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-p2p-encryption/
[bg v2 p2p]: /zh/newsletters/2019/03/26/#version-2-p2p-transport-proposal
[xs signet]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-signet/
[bg signet]: /zh/newsletters/2019/03/12/#feedback-requested-on-signet
[xs blind state]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-statechains/
[coredev.tech]: https://coredev.tech/
[transaction pinning]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning
[rbf rule 6]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/016998.html
[next sf vid]: https://youtu.be/fDJRy6K_3yo
[proof-of-concept newsletter]: /zh/newsletters/2018/06/08/
[newsletter rss]: /feed.xml
[optech twitter]: https://www.twitter.com/bitcoinoptech
[founding sponsors]: /zh/about/#资金
[member companies]: /#members
[countersign blurb]: /zh/newsletters/2018/12/28/#八月
[cpfp carve out]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[russell-corallo rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016530.html
[hillebrand optech]: https://www.youtube.com/playlist?list=PLPj3KCksGbSY9pV6EI5zkHcut5UTCs1cp
[routing success probability]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/lightning-network-routing-security/
[utreexo]: https://eprint.iacr.org/2019/611
[newsletter #34]: /zh/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
[newsletter #47]: /zh/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes
[newsletter #48]: /zh/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments
[newsletter #24]: /zh/newsletters/2018/12/04/#cpfp-carve-out
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[hwi]: https://github.com/bitcoin-core/HWI
[eltoo]: https://blockstream.com/eltoo.pdf
[musig]: https://eprint.iacr.org/2018/068
