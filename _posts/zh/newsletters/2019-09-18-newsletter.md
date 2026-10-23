---
title: 'Bitcoin Optech Newsletter #64'
permalink: /zh/newsletters/2019/09/18/
name: 2019-09-18-newsletter-zh
slug: 2019-09-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了上周在特拉维夫举行的 Bitcoin Edge Dev++ 培训课程和 Scaling Bitcoin 会议上的多场演讲。此外还照例包含热门比特币基础设施项目值得注意的变更一节。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无。*

## 新闻

- **<!--conference-talk-summaries-->****会议演讲摘要：**上周的 Scaling Bitcoin 会议和 Edge Dev++ 培训课程带来了多场有趣的演讲，我们已在本期稍后的两个专题章节中做了总结。

## Bitcoin Edge Dev++

Scaling Bitcoin 会议之前，社区先组织了 Bitcoin Edge Dev++ 培训课程。课程录像预计不久后会公开，但由 Bryan Bishop 整理的[文字记录][edge dev ts]现在就可以查看。我们建议至少把所有主题都快速浏览一遍；我们认为以下这几份记录既新颖又有趣：

- **<!--bitcoin-core-rebroadcasting-logic-->**[Bitcoin Core 的重广播逻辑][uttarwar rebroadcast]，Amiti Uttarwar 主讲，介绍她为消除 Bitcoin Core 钱包中一处隐私泄露所做的工作。如果钱包交易首次发送后没有较快得到确认，钱包就会重广播该交易，以确保它被中继给矿工。然而除此之外，全节点不会再重广播自己先前发送过的交易，因此间谍节点可以断定：凡是重广播某笔交易的节点，都是由创建该交易的用户运行的。更糟的是，这种行为还能被主动利用——向某个你想查明所有者身份的地址发送一笔手续费很低的小额付款，然后等对方的钱包重广播这笔交易。

  Uttarwar 提出的解决办法是让节点对所有交易一视同仁：只要某种启发式判断表明某笔交易本该在近期被打包却迟迟没有，就重广播它。这样一来，间谍节点就无法再假定重广播某笔交易的节点就是该交易的创建者。演讲最后概述了一些边缘情况，分享了她在 Bitcoin Core 开发经历中得到的一点洞见，并列出若干有待未来研究的开放问题。Uttarwar 实现这些缓解措施的首个 PR 见 [Bitcoin Core #16698][]。

- **<!--blockchain-design-patterns-layers-and-scaling-approaches-->**[区块链设计模式：分层与扩展方式][pv patterns]，Andrew Poelstra 与 David Vorick 主讲，简要梳理了一长串现有和拟议中的技术，目的是高效利用空间有限的区块链。从现有功能讲起，他们先比较比特币的 UTXO 模型与以太坊的余额模型，发现 UTXO 只能花费一次的特性大大简化了安全分析，也简化了基于缓存的性能优化。这种高效的缓存正是若干技术的基础：降低带宽的 [BIP152][] 紧凑区块（compact blocks）、降低延迟的 [FIBRE][]，以及节点软件中许多降低 CPU 和内存占用的改进。不过 Poelstra 和 Vorick 指出，要整体上降低带宽、延迟、CPU 和内存占用，最好的办法还是从一开始就尽量减少全局状态的使用：寻找机会采用基于未广播交易的链下协议，通过替换这些未广播交易来实现状态转换，并用哈希锁在不同交易之间建立依赖关系。

  谈到拟议中的技术，两位讲者解释说，在现有协议下，中继交易带来的带宽开销会随对等节点数量线性增长；而采用拟议的 [erlay][] 协议后，这项开销几乎可以保持恒定，让你能拥有多得多的对等节点，从而降低网络分区攻击的风险。接着他们介绍 taproot 提案的各个部分，说明 schnorr 签名如何让一次性验证多个签名（批量验证）成为可能，并把多个公钥和签名合并成一个公钥和一个签名（签名聚合），从而降低一般区块验证的成本，也降低多重签名用户的专门成本。schnorr 还能构造出适配器签名（adaptor signature），可以同时兼具签名和哈希锁的好处，而只需付出一份成本。最后，taproot 可以承诺一组条件，却不要求任何一方公开这些条件，除非他们确实需要——而如果其协议允许改用 schnorr 多方签名，他们可能根本不需要。这些技术无论单独使用还是组合使用，都能帮助用户把更多数据留在链下。

  演讲的最后一部分探讨了更具推测性的技术，例如用 [eltoo][] 改进 LN、用 [utreexo][] 最小化存储需求、几乎把所有数据都留在链下的[客户端验证][todd client side]、允许更频繁出块的基于有向无环图（DAG）的区块链、隐藏支付金额的机密交易，以及分片——既有联邦区块链的形式（现已可用），也有其他更偏理论探索的模型。

- **<!--lightning-network-topology-->**[闪电网络拓扑][kc topology]，Carla Kirk-Cohen 主讲，介绍了目前 LN 节点之间通道的公开拓扑、影响这一形态的因素，以及我们或许能做些什么来重塑它。她首先指出，部分节点之间存在未反映在公开数据中的私有通道，接着概述了当前的公共网络：“5600 个节点、约 35,218 条公共通道，通道中存放着 959 BTC 的公开资金。”许多通道（包括高价值通道）的一端只连接到少数几个热门节点，例如 LNbig 节点，其通道中聚集了 LN 约“20-24% 的流动性”。

  在回顾这种中心辐射型（hub-and-spoke）拓扑是怎么形成时，Kirk-Cohen 提到：早期所有连接都靠手动建立，因此知名节点很有吸引力；随后是连接良好的节点对早期 LND 自动巡航（autopilot）的吸引力；最后是热门流动性提供商对想要收款或路由支付的人始终如一的吸引力。

  谈及可能的改进，她提到可以利用各种图论指标，帮助自动巡航挑选连接良好、但未必是中心的通道（例如通往距离某个中心节点一跳的节点的通道）。此外，她一直在研究一套评分系统，用来判断何时该*关闭*通道，好把资金腾出来去与更高效的对等节点开通通道。最后她指出，更改通道连接要花链上手续费，因此突然改变拓扑并不现实；任何变化多半只能随着通道的自然开闭慢慢发生，所以我们可能要等上很久才能看出这些变化的效果。

## Scaling Bitcoin

第六届 Scaling Bitcoin 会议于 9 月 11 日至 12 日在以色列特拉维夫举行。许多话题和讨论都集中在 Newsletter 已经详细介绍过的主题上（如 [Erlay][]、[COSHV][]、[signet][signet progress]、[miniscript][] 和 [bitcoin vaults][]）。在 Bryan Bishop [转录][sb ts]的其余话题中，我们认为下面这个尤其有趣：

- **<!--txprobe-discovering-bitcoin-s-network-topology-using-orphan-transactions-->****TxProbe：利用孤儿交易推断比特币的网络拓扑**，Sergi Delgado-Segura 主讲（[视频][vid txprobe]、[文字记录][ts txprobe]、[论文][paper txprobe]），介绍的是能够推断出比特币网络拓扑——即哪些节点与哪些节点相连——这件事的利与弊，而这正是 Bitcoin Core 想要防范的。随后 Delgado-Segura 公开了他与共同作者开发的一种新颖探测手法，用于探测网络、推断其拓扑：他们把孤儿交易（即在至少一个父交易之前就收到的子交易）与一种在对等节点间暂时拖延交易中继的方法结合起来。该演讲展示了在 P2P 网络层面维持比特币安全与隐私所面临的一些挑战。

  演讲中没有详述、但这里值得一提的，是 Bitcoin Core 开发者针对这篇论文的发现已经部署的几项缓解措施。第一项是 Bitcoin Core [PR#14626][Bitcoin Core #14626]，随 0.18.0 一起发布，使孤儿交易不那么适合用于探测（即修复了 TxProbe 论文第 4.3 节所述的问题）。第二项是 [PR#14897][Bitcoin Core #14897]（在 [Newsletter #33][pr14897] 中介绍，后续报道见 [#43][pr15839] 和 [#51][pr15834]），它消除了第三方拖延交易在整个网络中传播的能力，是重要得多的一项缓解（对应论文第 4.2 节所述 *invblock* 手法，以及同一批共同作者中几位此前[发表的一篇论文][coinscope]）。第三项是 [PR#15759][Bitcoin Core #15759]，在[上周的 Newsletter][pr15759] 中介绍，它为每个节点增加两条只中继区块的出站连接——使这两条连接从根本上不受交易探测影响。预计第二、第三项缓解措施将随即将发布的 Bitcoin Core 0.19 一起提供。

  虽然演讲中提到的若干具体探测手法正在被修补，但任何想进一步了解节点如何组网并传递信息的人，都不妨翻阅这份演讲或其论文。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #16680][] 新增了 `-chain` 配置参数，允许用户选择使用哪条区块链。目前支持“main”（主网）、“test”（测试网）和“regtest”。后两个链名目前也可以分别用 `-testnet` 或 `-regtest` 参数选择，但引入这个通用参数之后，以后再添加其他链就更省事了（例如使用 [Newsletter #56][signet progress] 中介绍的 signet 代码）。

- [Bitcoin Core #16787][] 扩展了 `getpeerinfo` 和 `getnetworkinfo` RPC，新增一个字段，用于解码 services 位字段，该字段表示对等节点或本地节点提供哪些服务。此前已有一个字段直接给出位字段本身，这次是额外的补充。例如位字段 `000000000000040d` 解码后为 `["NETWORK", "BLOOM", "WITNESS", "NETWORK_LIMITED"]`。

- [Bitcoin Core #16725][] 现在对 P2PK 输出不再在解码后的交易中给出推断的 `addresses` 字段。P2PK 输出（直接支付给公钥）从来没有地址格式，但 RPC 接口过去会返回该公钥对应的 P2PKH 地址，令一些用户和开发者困惑。

- [Bitcoin Core #16714][] 在图形界面的首次使用向导中新增了一个启用区块数据修剪（pruning）的选项。向导里的默认值取决于可用磁盘空间：如果用户没有足够空间存储估算的区块链大小再加上 10 GB，就默认启用修剪。

- [Bitcoin Core #16285][] 为 `scantxoutset` 的结果新增了 `height` 和 `bestblock` 字段，以便判断扫描的是哪一份链状态。

- [Bitcoin Core #15584][] 默认关闭对 [BIP70][] 支付协议的支持。可以用 `--enabled-bip70` configure 参数重新编译开启。关于开发者主张关闭 BIP70 支持的几点理由，参见我们在 [Newsletter #19][pr14451] 中的介绍。

- [LND #3282][] 允许把 LND 构建成适用于 Android 和 iOS 的移动端库。其他程序可以引入该库，通过 LND 常规的 gRPC 接口访问它。详情见 [mobile readme][]。

- [LND #3485][] 不再支持从隔了一个以上大版本的旧版本升级，从而简化了数据库迁移代码，也让测试可以集中在更少的升级路径上。较旧的 LND 版本仍然可以通过逐步升级来升到新版本（例如 0.5.2-beta → 0.6-beta → 0.7-beta → 0.7.1-beta）。

- [C-Lightning #2945][] 让插件可以使用新增的 `sendpay_success` 和 `sendpay_failure` 通知。

- [C-Lightning #3010][] 实现了对 [BOLT3][] `option_static_remotekey` 的实验性支持，使 C-Lightning 能响应通道对等方“始终向同一个公钥付款、而不是为它派生新密钥”的要求。这样一来，即使远端对等方丢失了某些通道状态，也能轻松花掉这笔钱。只有在编译时启用了实验性功能，该选项才可用。

{% include linkers/issues.md issues="16680,16787,16725,16714,16285,15584,3282,3485,2945,3010,16698,14897,14626,15759" %}
[mobile readme]: https://github.com/lightningnetwork/lnd/blob/master/mobile/README.md
[uttarwar rebroadcast]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/edgedevplusplus/rebroadcasting/
[todd client side]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/milan/client-side-validation/
[pv patterns]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/edgedevplusplus/blockchain-design-patterns/
[kc topology]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/edgedevplusplus/lightning-network-topology/
[pr14897]: /zh/newsletters/2019/02/12/#bitcoin-core-14897
[pr15839]: /zh/newsletters/2019/04/23/#bitcoin-core-15839
[pr15834]: /zh/newsletters/2019/06/19/#bitcoin-core-15834
[pr15759]: /zh/newsletters/2019/09/11/#bitcoin-core-15759
[signet progress]: /zh/newsletters/2019/07/24/#progress-on-signet
[pr14451]: /zh/newsletters/2018/10/30/#bitcoin-core-14451
[edge dev ts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/edgedevplusplus/
[utreexo]: https://eprint.iacr.org/2019/611.pdf
[coshv]: /zh/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments
[bitcoin vaults]: /zh/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[fibre]: http://bitcoinfibre.org/
[vid txprobe]: https://youtu.be/-gdfxNalDIc?t=11757
[ts txprobe]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/txprobe/
[paper txprobe]: https://arxiv.org/pdf/1812.00942.pdf
[coinscope]: https://www.cs.umd.edu/projects/coinscope/coinscope.pdf
[sb ts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tel-aviv-2019/
[eltoo]: https://blockstream.com/eltoo.pdf
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
[miniscript]: /en/topics/miniscript/
