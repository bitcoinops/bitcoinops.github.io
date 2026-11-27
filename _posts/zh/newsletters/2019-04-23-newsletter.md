---
title: 'Bitcoin Optech Newsletter #43'
permalink: /zh/newsletters/2019/04/23/
name: 2019-04-23-newsletter-zh
slug: 2019-04-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 LND 0.6-beta 发布，以及 BIP158 支持已合并进 Bitcoin Core 的开发分支。此外还有照例的 bech32 发送支持栏目，以及热门比特币基础设施项目中值得注意的变更。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-release-candidates-->****帮助测试 Bitcoin Core 0.18.0 候选版本：**Bitcoin Core 下一个主要版本的第四个 RC 已[可供下载][0.18.0]。它解决了先前版本中发现的若干问题，并回退了此前合并的一项新功能，该功能似乎给少数测试者带来了问题（详情见*值得注意的代码变更*部分）。RC 测试者已经帮助提升了正式版本的质量，而试用这个最新 RC 的人，也将进一步帮助 0.18 成为迄今为止最好的 Bitcoin Core 版本。请通过[这个问题][Bitcoin Core #15555]报告反馈。

## 新闻

- **<!--lnd-0-6-beta-released-->****LND 0.6-beta 发布：**在 0.5-beta 发布七个月后，这个[新的主要版本][lnd 0.6-beta]带来了大量值得注意的变化。其中最引人注目的是静态通道备份（SCB）。借助它，用户可以在新通道开通后的任意时刻创建单个备份文件，以便在数据丢失（例如硬盘崩溃）时，从该通道以及此前开通的任意通道中恢复资金。这套机制并不完美——例如，数据丢失时仍处于未结算 HTLC 中的资金目前就无法恢复——但它代表了 LN 备份安全性的一大进步，也为通过拟议的协议变更和瞭望塔支持进一步改进打下了基线。

  其他变化还包括内存与带宽占用的大幅下降，以及改进的自动导航（autopilot）功能，可帮助用户自动开通新通道用于支付路由。发布的二进制文件也已内置所需的一切，可配合 [Lightning Loop][] 使用，在不关闭通道的情况下以无须信任的方式把 LN 资金转到链上地址。

  更多信息，建议你阅读详尽的[发布说明][lnd 0.6-beta]。

- **<!--basic-bip158-support-merged-in-bitcoin-core-->****Bitcoin Core 合并了基础的 BIP158 支持：**随着 Jim Posen 的 PR [合并][Bitcoin Core #14121]进 Bitcoin Core 的 master 开发分支，用户现在可以启用新的 `blockfilterindex` 配置选项（默认关闭）。该选项会为链上每个区块生成一个 [BIP158][] 紧凑区块过滤器，以及 [BIP157][] 支持所需的对应过滤器头（filter header）[^fn-bip157-bip158]。它在后台运行，程序其他部分照常工作；在大多数计算机上大约需要 1 到 3 小时。之后，用户可以用新增的 `getblockfilter` RPC 取回指定区块的过滤器。目前整条区块链的过滤器共占用约 4 GB。其随时间的增长可见下图：

  ![过滤器大小随区块高度的变化图](/img/posts/2019-04-bip158-filter-size-cumulative.png)

  这些过滤器目前尚未用于程序的其他部分，也没有通过 Bitcoin Core 的 P2P 协议实现对外提供。关于这些过滤器，下一步的提案似乎得到了 Bitcoin Core 开发者的广泛支持：允许本地程序利用过滤器快速扫描区块链中的历史交易。例如，如果你在 Bitcoin Core 的多钱包模式下卸载某个钱包、之后又重新加载，它需要逐个检查卸载之后到达的每个区块，看其中是否有影响该钱包的交易。有了过滤器，钱包可以先检查更小、更快的过滤器，只对过滤器指示可能包含钱包交易的区块做完整检查。

## Bech32 发送支持

*第 6 周，共 24 周。在 2019 年 8 月 24 日隔离见证软分叉锁定满两周年之前，Optech Newsletter 每周都会包含这一栏目，提供信息帮助开发者和组织实现 bech32 发送支持——也就是能够向原生隔离见证地址付款。你[不需要自己实现隔离见证][bech32 series]，但你付款的对象却能享受到隔离见证带来的种种好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/06-stackexchange.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案 (BIPs)][bips repo] 中值得注意的变更。注意：除非另有说明，文中描述的 Bitcoin Core 合并都发生在它的 master 开发分支上；其中一些也可能被向后移植到待发布的版本中。*

- [Bitcoin Core #15839][] 只在 0.18 分支（而非 master 开发分支）中回退了 [#14897][Bitcoin Core #14897]。关于 #14897 的详细描述，见 [Newsletter #33][] 的*值得注意的代码变更*部分——该 PR 于 2 月初合并。几位仔细测试 0.18.0 候选版本（RC）的人注意到，他们的节点在启动后不久有时会停止请求新交易。这个间歇性问题似乎与 #14897 为降低拒绝服务风险而对请求交易方式所做的改进有关。目前至少已有两个 PR（[1][Bitcoin Core #15776]、[2][Bitcoin Core #15834]）试图解决该问题，但项目内普遍同意在 0.18.0 中移除这项新功能，让它和它的补丁先在开发分支接受更多测试，之后再进入正式版本。RC 周期的目的就是在影响普通用户之前发现这类潜在问题，因此我们相信可以代表这些用户，感谢迄今为止参与测试的每一个人。

- [Bitcoin Core #15557][] 增强了 `bumpfee` RPC 以及 GUI 中等效菜单项背后的底层函数：如果无法仅靠减少某个现有找零输出的金额来支付手续费增加，它就会纳入额外的输入。这消除了 Optech [RBF 可用性研究][rbf usability study]中描述的 Bitcoin Core 的[失败模式][rbf core fail]，因此 Bitcoin Core 用户发起的手续费追加更容易成功。

- [C-Lightning #2541][]、[#2545][c-lightning #2545] 和 [#2546][c-lightning #2546] 对 gossip 子系统做了多处改动，该子系统用于跟踪哪些通道可用并据此计算路由。这项工作源于[百万通道项目][million channels project]，该项目的性能结果出现在许多提交消息中。如果 Optech 对结果的解读无误，那么从该系列的[第一个提交][417e1ba]到[最后一个提交][0fc4241]：内存占用减少了 79%，从 2.6 GiB 降到 0.6 GiB；构建一条通往随机选定节点（20 跳以内）的路由，耗时减少 80%，从 60 秒降到 12 秒。（即使改进后的数值看起来仍然偏高，请记得这是一个规模超过当前主网 25 倍的模拟网络，也是一年多以前网络规模的 1,000 倍。）这项改动中值得注意的一点是，C-Lightning 从它相当独特的 [Bellman--Ford--Gibson（BFG）][bfg post] 路由算法，切换到[稍作定制的][e197956] [Dijkstra][] 算法。

- [Eclair #885][] 新增了一个 UUID 形式的单一标识符来跟踪支付：无论该支付涉及哪些 HTLC，都能简化对这笔支付最终成功还是失败的跟踪。这解决的是这样一种情况：程序用不同路由自动重试暂时失败的支付，因而产生并非最终结果的失败信息，以及其他对高层 API 使用者未必有用的信息。尽管实现与动机不同，但这在概念上与 [Newsletter #36][] 的*值得注意的代码变更*部分描述的 [C-Lightning #2382][] 相似。

- [Eclair #951][] 实现了通道备份机制，并提供了使用它的[文档][eclair backup]。与本 Newsletter 前面描述的 LND 静态通道备份不同，这一机制需要在每次支付后重新备份。有一个配置选项可以让 Eclair 调用你指定的脚本，在需要备份时自动完成数据文件的备份。

- [Eclair #927][] 增加了对用 Scala、Java 或其他兼容 JVM 的语言编写的插件的支持。插件是[插件接口][eclair plugin interface]的具体实现。详情参见新增的[文档][eclair plugin doc]。

## 脚注

[^fn-bip157-bip158]:
    [BIP158][] 引入了*紧凑区块过滤器*，它基于一种高效编码等长条目列表的方法。对于 BIP 中所述的“基本”区块过滤器，这个列表包含当前区块中所有可花费输出的 scriptPubKey，以及本区块各输入所花费的输出（开发者称之为 prevout）的 scriptPubKey。每个 scriptPubKey 都会被哈希，使各条目长度一致，然后这些条目会被排序、去重，得到一个列表。随后用 BIP158 中同样描述的 [Golomb--Rice 编码集合][gcs]（GCS）算法对该列表编码，无损地缩小其体积。这种基本过滤器所提供的信息，足以让任何知道某个比特币地址的人找出所有相关区块——无论其中的交易是向该地址付款（输出 scriptPubKey），还是花费了此前发往该地址的资金（prevout scriptPubKey）。这类搜索可能产生假阳性（即结果中会包含不含该地址交易的区块），但绝不会出现假阴性（即含有该地址交易的区块绝不会被漏掉）。

    另一个 BIP，即 [BIP157][]，描述了如何通过比特币 P2P 协议在网络上提供这些紧凑区块过滤器。BIP157 设计为与 BIP158 的“基本”过滤器配合使用，但也可以扩展以支持编码其他条目列表的附加过滤器。BIP157 中特别值得注意的一点是引入了*过滤器头*的概念：每个过滤器的头都承诺了前一个区块过滤器头的哈希，再加上当前过滤器的哈希。这形成了一条类似比特币区块的过滤器链，目的是让比较来自多个对等节点的过滤器变得容易：每个对等节点只需发送过滤器头（32 字节），一旦发现有不匹配的头，客户端就可以沿链请求更早的头，直到找到分歧点。按需为某个区块生成过滤器头需要把所有先前的过滤器都哈希一遍，因此尽管 Bitcoin Core 的实现目前还不支持 BIP157，它仍会把这些头存到磁盘上，以备将来使用。用新增的 `getblockfilter` RPC 取回过滤器时，会同时返回 BIP158 过滤器和 BIP157 头：

    ```text
    $ bitcoin-cli getblockfilter $( bitcoin-cli getblockhash 170 )
    {
      "filter": "0357e49590040c79b0",
      "header": "349eaecc8bb7793c9f3c28e78df6675ef904515e9a310e4532785aeb45526090"
    }
    ```

    我们选择区块 170，是因为它的过滤器是第一个包含多个元素（3 个）的过滤器；而截至本文写作时的最新区块（区块 572,879），其过滤器包含 8,599 个元素——实在太多，没法漂亮地打印出来。

{% include linkers/issues.md issues="15555,14121,15839,14897,15776,15834,15557,885,2541,2545,2546,951,927,2382" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[bech32 series]: /zh/bech32-sending-support/
[rbf core fail]: /zh/rbf-in-the-wild/#bitcoin-core差点增加交易费用
[million channels project]: https://github.com/rustyrussell/million-channels-project
[bfg post]: https://medium.com/@rusty_lightning/routing-dijkstra-bellman-ford-and-bfg-7715840f004
[dijkstra]: https://en.wikipedia.org/wiki/Dijkstra's_algorithm
[417e1ba]: https://github.com/ElementsProject/lightning/commit/417e1bab7d58f05aebb72825063e97b09fb8a6b9
[0fc4241]: https://github.com/ElementsProject/lightning/commit/0fc42415c24c12634b7e219ef80faf0223225c96
[e197956]: https://github.com/ElementsProject/lightning/commit/e197956032ec68470644766f52f9e50470b66a1c
[eclair backup]: https://github.com/ACINQ/eclair/#backup
[eclair plugin interface]: https://github.com/ACINQ/eclair/blob/master/eclair-node/src/main/scala/fr/acinq/eclair/Plugin.scala
[eclair plugin doc]: https://github.com/ACINQ/eclair#plugins
[lnd 0.6-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.6-beta
[lightning loop]: https://github.com/lightninglabs/loop
[rbf usability study]: /en/rbf-in-the-wild/
[gcs]:  https://en.wikipedia.org/wiki/Golomb_coding#Rice_coding
[newsletter #33]: /zh/newsletters/2019/02/12/#bitcoin-core-14897
[newsletter #36]: /zh/newsletters/2019/03/05/#c-lightning-2382
