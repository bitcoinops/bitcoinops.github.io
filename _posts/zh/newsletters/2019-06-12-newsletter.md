---
title: 'Bitcoin Optech Newsletter #50'
permalink: /zh/newsletters/2019/06/12/
name: 2019-06-12-newsletter-zh
slug: 2019-06-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概述 CoreDev.tech 活动上的各场会议，介绍一项修订 BIP125 手续费替换（RBF）规则的提议，给出 Optech 一场关于 Schnorr/Taproot 的面向高管的简报会视频，并为 Optech Newsletter 出满 50 期小小庆祝一番。常规章节照旧包括 bech32 发送支持，以及热门比特币基础设施项目中的值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}
{% include specials/2019-exec-briefing/zh/softfork.md %}

## 行动项

*本周无行动项。*

## 新闻

- **<!--bitcoin-core-contributor-meetings-->****Bitcoin Core 贡献者会议：** 上周，许多贡献者亲自参加了定期举行的 [CoreDev.tech][] 活动，贡献者 Bryan Bishop 提供了实时[会议记录][coredev.tech transcripts]：

  - **<!--code-review-->**6月5日：在一次[代码审查][xs review]会议中，讨论了发给活跃的 Bitcoin Core 贡献者的调查，并提出了几项简化审查流程的建议。

    与会者讨论了把[钱包架构][xs wallet arch]改为使用[输出脚本描述符][output script descriptors]，以生成地址、跟踪这些地址何时收到付款，并查找或推导出花费所需的那个特定私钥。

  - **<!--consensus-cleanup-soft-fork-->**6月6日：讨论了[共识清理软分叉][xs cleanup sf]，包括它与 [bip-taproot][] 的交互，是否应该删除部分内容，以及是否应该添加任何内容。([更多背景信息][bg consensus cleanup])
    {:#cleanup-discussion}

    小组还讨论了能做些什么来减轻[维护者][xs maint]的负担。维护者们特别提到，很感激长期贡献者 Michael Ford 承担了 issue 与 PR 的管理工作。与会者随即授予 Ford 维护者身份，让他能更有效地发挥作用。

    {:#potential-script-changes}
    会上还讨论了[若干可能的脚本改动][xs script change]。关于 [BIP118][] 和 [bip-anyprevout][] 的 sighash，讨论围绕输出标记（见 [Newsletter #34][]）与陪护签名（见 [#47][Newsletter #47]）展开。会上审查了更名后的 [bip-coshv][] 操作码（见 [#48][Newsletter #48]），并把 `OP_CHECKSIGFROMSTACK` 作为通用替代方案一并考虑。

    {:#taproot-accumulator-quantum}
    [Taproot][xs taproot] 议题包括讨论使用默克尔树而非累加器，以及与快速量子计算机相关的风险。([更多背景信息][bg taproot])

    {:#utreexo}
    一场关于 UTXO 集所用 [Utreexo][] 累加器的[问答][xs utreexo]，点出了这个仍在发展中的提案的一些有趣细节——该提案旨在把全节点的存储需求降到最低。

  - **<!--assumeutxo-->**6月7日：演示并讨论了 [assumeutxo][xs assumeutxo] 提案的代码，包括如何使该提案与其他想法兼容。([更多背景信息][bg assumeutxo])
    {:#assume-utxo-demo}

    {:#hwi}
    贡献者讨论了将[硬件钱包][xs hwi]支持通过 [HWI][] 直接集成到 Bitcoin Core 中。一个特别关注点是代码的分离——确保特定硬件设备的代码由制造商维护而非 Bitcoin Core。([更多背景信息][bg hwi])

    {:#v2-p2p}
    会上讨论了[版本 2 P2P 传输协议][xs v2 p2p]以及相关的 countersign 协议（见 [#27][countersign blurb]），过程中提到了几种可能的增强。([更多背景信息][bg v2 p2p])

    {:#signet}
    对 [signet][xs signet] 构想的审议——这是一种类似测试网的链，所有区块都由某个受信任方签名——重点讨论了分发这些签名的各种办法。([更多背景信息][bg signet])

    尽管本周才在 Bitcoin-Dev 邮件列表中宣布，[盲状态链][xs blind state]也在会议上进行了讨论。

- **<!--proposal-to-override-some-bip125-rbf-conditions-->****建议覆盖某些 BIP125 RBF 条件：** [BIP125][] 的自愿启用手续费替换（RBF）只有在替代交易提高了整个内存池中支付的手续费总额时，才允许用费率更高的交易替换原有交易。这挡住了一种针对全节点、成本很低却白白浪费带宽的拒绝服务（DoS）攻击，但也让针对某些 RBF 用法的[交易钉住][transaction pinning] DoS 攻击变得相对廉价，例如在 LN 这类时间敏感的协议中。

  此前已有好几位开发者试图解开这个两难，去年年底 Matt Corallo 提出的一个方案用子为父付（CPFP）追加手续费（[CPFP 豁免（carve-out）][]，见 [Newsletter #24][]），同时建议了一种调整 RBF 的替代变通办法。Rusty Russell 早先与 Corallo [讨论][russell-corallo rbf]过这处 RBF 改动，此后又做了进一步完善，如今已把它作为给 BIP125 规则集新增的一条规则[提交][rbf rule 6]到 Bitcoin-Dev 邮件列表。这条新规则允许内存池里任何 BIP125 可替换交易在满足以下两个条件时追加手续费：

  1. 当前在内存池中的版本，排在最有利可图的前 1,000,000 vbytes 之外（即不在“下一个区块”的范围内）

  2. 替代版本支付的手续费足够高，能挤进“下一个区块”的范围

  这样，任何交易都能在不顾及其子交易的情况下追加手续费，交易钉住的问题也就消失了。不过，利用这条规则的人可能压低内存池中的手续费总额，也可能借它过度浪费节点带宽。有几个人回复了该提议，就这些风险提出疑问并给出分析。

- **<!--presentation-the-next-softfork-->****演讲：下一个软分叉：** Bitcoin Optech 贡献者 Steve Lee 在上个月 Optech 面向高管的简报会上，就未来可能的比特币软分叉做了演讲。该[视频][next sf vid]现已上线。{{the-next-softfork-zh}}

- **<!--optech-celebrates-newsletter-50-->****Optech 庆祝 Newsletter #50：** 去年 6 月初，John Newbery 给 Dave Harding 发邮件，谈到他对新组建的 Optech 组织的一些打算——其中有一句是：“我们还会做一些书面材料，[比如]每周或每月的新闻摘要。”那天 Harding 正好有点闲，就回了封信，顺手附上一份没人要求他做的[概念验证 Newsletter][proof-of-concept newsletter]。Newbery 和其他早期 Optech 贡献者都觉得不错，于是敲定了一些细节，这份 Newsletter 便开始了每周定期发布。

  五十期下来，这份 Newsletter 已有超过 2,500 名邮件订阅者，另有数量不详的读者通过 [RSS][newsletter rss]、[Twitter][optech twitter] 和 Max Hillebrand 的[朗读节目][hillebrand optech] 订阅。我们累计发布了超过 85,000 词——大约 250 页印刷内容<!-- 350 words per page -->；Newsletter 的草稿迄今收到了一支了不起的审阅团队给出的 948 条评论，他们帮我们确保技术准确、文字通顺。新一期 Newsletter 的公告累计获得超过 1,300 次转发<!-- 1,359 -->和 3,000 次点赞<!-- 3,087 -->，此外在 [Reddit][optech reddit] 上还有不少好评。最重要的是，许多读者亲口告诉我们，他们觉得这份 Newsletter 特别有用。

  一份只谈比特币的纯技术 Newsletter，在问世第一年就得到如此热烈的回应，我们既惊讶，又感激，也深感惶恐。我们知道大家对我们的期待很高，希望接下来的五十期能不辜负这份期待。一如既往，我们感谢[创始赞助商][founding sponsors]、[会员公司][member companies]、所有为本刊出过力的人，以及所有为比特币开发出过力的人——没有你们，我们要写的题材会比“货币的未来”乏味得多。

## Bech32 发送支持

*这是 [bech32 系列][bech32 series] 24 周中的第 13 周，该系列讲的是如何让你付款的对象享受到 segwit 的全部好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/13-adoption-speed.md %}

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo] 中的值得注意的变更。*

- [LND #2802][] 让 LND 能够计算某条路径成功的概率，再结合已有的“路径手续费总额”和“该路径最大 HTLC 超时时间”计算结果，用这个概率挑出最佳路径。增加了几项新的配置选项，允许用户调整概率计算中使用的常量值，例如“当没有其他信息可用时，假定路径中某跳的成功概率”。拉取请求的作者还在上周末的 Breaking Bitcoin 会议上讨论了[路由成功概率][routing success probability]。

- [C-Lightning #2644][] 改变了 C-Lightning 记录“哪些通道更新已 gossip 给对等节点”的方式。此前，为每个对等节点保留了一个映射，跟踪哪些更新已发送，哪些正在等待发送。现在，整个程序保留一个有序的更新列表，每个对等连接只需跟踪它在该列表中发送到哪个位置。当连接到达列表末尾时，其位置会被标记，以便可以发送随后添加到列表中的任何新条目。当后续更新使之前的更新变得无关紧要时，之前的更新会从全局列表中删除，任何未发送该更新的连接将永远不会看到它。在测试中（可能是作为[百万通道项目][million channels project]的一部分），这将整体内存使用量减少了 35%（约 150 MB），并加快了向所有对等节点发送所有 gossip 公告的速度 62%（约 11 秒）。

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
[rbf rule 6]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/016998.html
[next sf vid]: https://youtu.be/fDJRy6K_3yo
[proof-of-concept newsletter]: /zh/newsletters/2018/06/08/
[newsletter rss]: /feed.xml
[optech twitter]: https://www.twitter.com/bitcoinoptech
[founding sponsors]: /zh/about/#资金
[member companies]: /#members
[countersign blurb]: /zh/newsletters/2018/12/28/#八月
[cpfp carve out]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[russell-corallo rbf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016530.html
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
