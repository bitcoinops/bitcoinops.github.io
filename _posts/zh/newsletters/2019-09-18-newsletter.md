---
title: 'Bitcoin Optech Newsletter #64'
permalink: /zh/newsletters/2019/09/18/
name: 2019-09-18-newsletter-zh
slug: 2019-09-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了上周在特拉维夫举行的 Bitcoin Edge Dev++ 培训课程和 Scaling Bitcoin 会议中的多个演讲。此外，还包括我们常规的关于流行比特币基础设施项目的值得注意的更改部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无。*

## 新闻

- **<!--conference-talk-summaries-->****会议演讲总结：**上周的 Scaling Bitcoin 会议和 Edge Dev++ 培训课程带来了几场有趣的演讲，我们已在本 Newsletter 的后面部分的两个特别章节中对其进行了总结。

## Bitcoin Edge Dev++

Scaling Bitcoin 会议之前，社区组织了 Bitcoin Edge Dev++ 培训课程。培训课程的录音预计很快会公开，但 [Bryan Bishop 撰写的文字记录][edge dev ts]已经可以查看。我们建议至少快速浏览所有主题，但我们发现以下几个文字记录内容既新颖又有趣：

- **<!--bitcoin-core-rebroadcasting-logic-->**[Bitcoin Core 的重广播逻辑][uttarwar rebroadcast]，由 Amiti Uttarwar 讲述，描述了她在消除 Bitcoin Core 钱包隐私泄漏方面的工作。如果钱包交易的首次发送未能快速确认，钱包将重广播该交易，以确保其被矿工接收。然而，没有其他情况会导致全节点重广播其先前发送的交易，因此间谍节点可以假定重广播交易的节点是生成该交易的用户操作的。更糟糕的是，这种行为可以被主动利用，方法是向想要识别的地址发送一笔低费用的小额支付，并等待其钱包重广播该交易。

  Uttarwar 提出的解决方案是让节点将所有交易一视同仁，当启发式规则表明交易本应最近被挖出但未被挖出时，重广播任何交易。这样可以防止间谍节点假设重广播交易的节点就是该交易的创建者。演讲的最后，她还概述了一些边缘案例，分享了她在为 Bitcoin Core 开发时的经验，并列出了未来研究的一些开放问题。参见 [Bitcoin Core #16698][]，这是 Uttarwar 实现这些缓解措施的首个 PR。

- **<!--blockchain-design-patterns-layers-and-scaling-approaches-->**[区块链设计模式：层次和扩展方法][pv patterns]，由 Andrew Poelstra 和 David Vorick 共同讲述，简要介绍了为有效利用空间有限的区块链而存在和提出的众多技术。首先他们比较了比特币的 UTXO 模型和以太坊的余额模型，发现 UTXO 的一次性消费特性极大简化了安全分析和基于缓存的性能提升。这种有效的缓存是带宽减少技术如 [BIP152][] 致密区块、延迟减少的 [FIBRE][] 和节点软件中许多减少 CPU 和内存消耗的改进的基础。然而，Poelstra 和 Vorick 指出，减少带宽、延迟、CPU 和内存的整体最佳方法是在一开始就尽量减少对全局状态的使用，通过寻找使用基于未广播交易的链下协议、允许状态转移的未广播交易替换以及通过哈希锁创建不同交易间依赖关系的机会。

  在介绍了已提出的技术后，演讲者解释了在当前协议中，转发交易的带宽开销随着你增加节点的数量呈线性增长；通过提议的 [erlay][] 协议，这种开销几乎可以保持不变，从而允许你拥有更多的节点，这减少了网络分区攻击的风险。接着在描述各种 taproot 提案的过程中，他们展示了如何通过 schnorr 签名一次性验证多个签名（批量验证）并将多个公钥和签名合并为一个公钥和签名（签名聚合），从而减少一般区块验证的成本和多重签名用户的特定成本。schnorr 还使得可以创建适配器签名，这种签名可以同时提供签名和哈希锁的好处，而只需支付一个签名的成本。最后，taproot 可以承诺一组条件，除非需要，否则不要求任何一方透露这些条件；如果他们的协议允许使用 schnorr 多方签名，他们甚至可能不需要这些条件。所有这些技术，无论单独使用还是组合使用，都可以帮助用户将更多数据保留在链下。

  他们演讲的最后部分讨论了更具前瞻性的技术，如使用 [eltoo][] 改进的 LN、使用 [utreexo][] 最小化存储需求、[客户端验证][todd client side]（几乎将所有数据保留在链下）、基于有向无环图（DAG）的区块链（允许更频繁的区块生成）、隐藏支付金额的隐私交易以及分片技术，包括联邦区块链（目前可用）和其他更具前瞻性的模型。

- **<!--lightning-network-topology-->**[闪电网络拓扑][kc topology]，由 Carla Kirk-Cohen 讲述，描述了当前 LN 节点之间的通道公共拓扑，影响其形状的因素以及我们可以做些什么来重塑它。她首先提到一些节点之间存在的私有通道，这些通道未反映在公开数据中，然后概述了当前的公共网络：“5600 个节点、约 35,218 条公共通道、959 BTC 存放在这些通道中。”许多通道，包括高价值通道，一端连接到少数几个受欢迎的节点，例如 LNbig 节点，它拥有 LN 中约“20-24% 的流动性”。

  在讨论如何形成这种中心辐射型拓扑时，Kirk-Cohen 指出了早期网络中手动连接时著名节点的吸引力，然后是早期 LND 自动驾驶仪对已连接节点的吸引力，最后是当前流行的流动性提供商对于想要接收或路由支付的人的持续吸引力。

  讨论的可能改进措施包括利用各种图形指标帮助自动驾驶仪选择连接良好的通道，但不一定是中心节点（例如距离中心节点一步之遥的节点）。此外，她还在研究一个何时*关闭*通道的评分系统，以便使资金可用于与更有效的节点开通通道。最后，她指出更改通道连接会产生链上费用，因此无法突然改变拓扑结构；任何更改可能会随着通道的有机开闭而缓慢进行，因此我们可能需要等待很长时间才能看到这些更改的效果。

## Scaling Bitcoin

第六届 Scaling Bitcoin 会议于 9 月 11 日至 12 日在以色列特拉维夫举行。许多话题和讨论集中在我们在 Newsletter 中已经详细介绍的主题上（如 [Erlay][], [COSHV][], [signet][signet progress], [miniscript][] 和 [bitcoin vaults][]）。在 Bryan Bishop 撰写的[文字记录][sb ts]中，我们发现以下话题特别有趣：

- **<!--txprobe-discovering-bitcoin-s-network-topology-using-orphan-transactions-->****TxProbe：使用孤儿交易发现比特币的网络拓扑**，由 Sergi Delgado-Segura 主讲（[视频][vid txprobe]、[文字记录][ts txprobe]、[论文][paper txprobe]），描述了能够确定比特币网络拓扑的优缺点——即哪个节点连接到哪个节点——这是 Bitcoin Core 试图防止的事情。Delgado-Segura 然后披露了他和共同作者开发的一种新颖技术，用于探测网络以确定其拓扑，该技术结合了使用孤儿交易（子交易在其至少一个父交易之前接收）和一种暂时延迟节点之间交易转发的方法。该演讲展示了在 P2P 网络层保持比特币安全和私密的一些挑战。

  虽然在演讲中没有详细描述，但值得在此提及的是，Bitcoin Core 开发者已经部署了一些缓解措施以应对该论文的发现。第一个缓解措施是 Bitcoin Core [PR#14626][Bitcoin Core #14626]，作为 0.18.0 版本的一部分发布，减少了孤儿交易探测的效果（即修复了 TxProbe 论文第 4.3 节中描述的问题）。[PR#14897][Bitcoin Core #14897]，在 [Newsletter #33][pr14897] 中介绍，并在 [#43][pr15839] 和 [#51][pr15834] 中跟进，提供了第二个且更为重要的缓解措施，消除了第三方延迟交易在整个网络上传播的能力（该论文第 4.2 节以及共同作者之前发表的一篇[已发表的论文][coinscope]中描述的 *invblock* 技术）。第三个缓解措施是 [PR#15759][Bitcoin Core #15759]，在[上周的 Newsletter][pr15759] 中描述，它为每个节点增加了两个只转发区块的出站连接——使这两个连接从根本上对交易探测具有抵抗力。预计第二和第三个缓解措施将在即将发布的 Bitcoin Core 0.19 版本中包含。

  虽然演讲中描述的几种探测方法正在被处理，但任何对节点如何形成网络并传播信息感兴趣的人都可以考虑浏览该演讲或论文。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的更改。*

- [Bitcoin Core #16680][] 添加了 `-chain` 配置参数，允许用户选择要使用的区块链。目前支持“main”（主网）、“test”（测试网）和“regtest”。后两个链名目前可以使用 `-testnet` 或 `-regtest` 参数选择，但添加通用功能简化了以后引入其他链的操作（例如使用 [Newsletter #56][signet progress] 中描述的 signet 代码）。

- [Bitcoin Core #16787][] 扩展了 `getpeerinfo` 和 `getnetworkinfo` RPC，新增了一个字段，用于解码表示节点或本地节点提供的服务的服务位字段。这是对以前提供位字段本身的字段的补充。例如，位字段 `000000000000040d` 解码为 `["NETWORK", "BLOOM", "WITNESS", "NETWORK_LIMITED"]`。

- [Bitcoin Core #16725][] 现在从 P2PK 输出的解码交易中省略了推断的 `addresses` 字段。P2PK 输出（直接支付到公钥）从未有过地址格式，但之前 RPC 接口会返回该公钥的 P2PKH 地址，令一些用户和开发者感到困惑。

- [Bitcoin Core #16714][] 更新了 GUI 首次使用向导，增加了启用区块数据修剪的选项。向导中的默认值取决于可用的磁盘空间，如果用户没有足够的空间存储估计的区块链大小加上 10 GB，默认启用修剪。

- [Bitcoin Core #16285][] 扩展了 `scantxoutset` 结果，增加了 `height` 和 `bestblock` 字段，以便可以确定扫描的链状态。

- [Bitcoin Core #15584][] 默认禁用 [BIP70][] 支付协议支持。可以通过使用 `--enabled-bip70` 编译参数重新启用。参见我们在 [Newsletter #19][pr14451] 中关于开发者倾向于禁用 BIP70 支持的几个原因的描述。

- [LND #3282][] 允许将 LND 构建为适用于 Android 和 iOS 的移动库。其他程序可以包含该库并通过其常规 gRPC 接口访问 LND。详情见 [mobile readme][]。

- [LND #3485][] 删除了从超过一个主要版本升级的功能，简化了数据库迁移代码，并使测试能够集中于更少的升级路径。仍然可以通过逐步升级较旧的 LND 版本（例如 0.5.2-beta → 0.6-beta → 0.7-beta → 0.7.1-beta）来进行升级。

- [C-Lightning #2945][] 使新的 `sendpay_success` 和 `sendpay_failure` 通知可供插件使用。

- [C-Lightning #3010][] 实现了对 [BOLT3][] 中 `option_static_remotekey` 的实验性支持，允许 C-Lightning 遵循来自通道对等方的请求，始终为其支付相同的公钥，而不是为其派生一个新密钥。这使得远程对等方即使丢失了一些通道状态也可以轻松地花费这些资金。此选项仅在启用了实验性功能编译的情况下可用。

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
