---
title: 'Bitcoin Optech Newsletter #43'
permalink: /zh/newsletters/2019/04/23/
name: 2019-04-23-newsletter-zh
slug: 2019-04-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 LND 0.6-beta 的发布以及 BIP158 支持合并到 Bitcoin Core 的开发分支中。还包括关于 bech32 发送支持的常规部分和对流行比特币基础设施项目的值得注意的变化。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-release-candidates-->****帮助测试 Bitcoin Core 0.18.0 候选版本：**Bitcoin Core 下一个主要版本的第四个 RC 版本现已[可用][0.18.0]。这解决了先前版本中发现的若干问题，并且回退了之前合并的一项新功能，该功能似乎对少数测试者造成了问题（详情见*值得注意的代码变化*部分）。RC 测试者已经帮助提高了最终版本的质量，尝试此最新 RC 的人将进一步帮助使 0.18 成为有史以来最好的 Bitcoin Core 版本。请使用[这个问题][Bitcoin Core #15555]来报告反馈。

## 新闻

- **<!--lnd-0-6-beta-released-->****LND 0.6-beta 发布：**在 0.5-beta 版本发布七个月后，这个[新的主要版本][lnd 0.6-beta]带来了大量值得注意的变化。最重要的变化是静态通道备份（SCB）。这些允许用户在新通道开启后的任何时间创建单一备份文件，以便在数据丢失（例如硬盘崩溃）的情况下恢复该通道及之前开启的任何通道中的资金。该系统并不完美——例如，当前无法恢复数据丢失时未结算的 HTLC 中的资金——但它代表了 LN 备份安全性的重大改进，并且是可以通过拟议的协议更改和瞭望塔支持进一步改进的基础。

  其他变化包括内存和带宽使用的显著减少，以及改进的自动驾驶仪功能，帮助用户自动打开新的支付路由通道。发布的二进制文件还包含了与 [Lightning Loop][] 一起使用所需的所有内容，以便在不关闭通道的情况下，将 LN 资金信任地转移到链上地址。

  有关更多信息，我们鼓励您阅读全面的[发布说明][lnd 0.6-beta]。

- **<!--basic-bip158-support-merged-in-bitcoin-core-->****Bitcoin Core 中合并了基础的 BIP158 支持：**随着 Jim Posen 提交的 PR [合并][Bitcoin Core #14121]到 Bitcoin Core 的主开发分支中，用户现在可以启用一个新的 `blockfilterindex` 配置选项（默认关闭），该选项将为链上的每个区块生成一个 [BIP158][] 致密区块过滤器及其对应的用于 [BIP157][] 支持的过滤器头[^fn-bip157-bip158]。这将在程序正常运行的情况下在后台操作，在大多数计算机上大约需要一到三个小时。用户随后可以使用新的 `getblockfilter` RPC 检索特定区块的过滤器。目前，整个区块链的过滤器使用约 4 GB 的存储空间。随时间增长的情况可以在以下图表中看到：

  ![过滤器大小随区块高度的变化图](/img/posts/2019-04-bip158-filter-size-cumulative.png)

  这些过滤器目前尚未在程序的其他地方使用，也未通过 Bitcoin Core 的 P2P 协议实现公开。一个似乎在 Bitcoin Core 开发者中广泛支持的下一步提议是允许本地程序使用过滤器快速扫描区块链中的历史交易。例如，如果您在 Bitcoin Core 的多钱包模式中卸载一个钱包，然后稍后重新加载，它需要查看自卸载以来到达的每个区块，以查看其中是否包含影响钱包的交易。使用过滤器，钱包可以先检查较小且较快的过滤器，然后仅对过滤器指示可能包含钱包交易的区块进行全面检查。

## Bech32 发送支持

*第 6 周，共 24 周。在 2019 年 8 月 24 日隔离见证软分叉锁定二周年之前，Optech Newsletter 将包含这一周的部分，为开发者和组织提供信息，以帮助他们实现 bech32 发送支持——支付本地隔离见证地址的能力。这[不需要自己实现隔离见证][bech32 series]，但它确实允许您支付的人访问隔离见证的所有多重好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/06-stackexchange.md %}

## 值得注意的代码和文档变化

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案 (BIPs)][bips repo] 中的值得注意的变化。注意：除非另有说明，所有描述的 Bitcoin Core 合并都是其主开发分支中的；有些可能也会被回移到其待发布的版本中。*

- [Bitcoin Core #15839][] 仅在 0.18 分支中回退了 [#14897][Bitcoin Core #14897]（未在主开发分支中）。参见 [Newsletter #33][] 的*值得注意的代码变化*部分，我们对 #14897 进行了详细描述，该内容于 2 月初合并。一些 0.18.0 候选版本的仔细测试者注意到，他们的节点在启动后不久有时会停止请求新交易。这个间歇性问题似乎与#14897 中进行的交易请求改进以减少拒绝服务风险有关。至少已有两个 PR（[1][Bitcoin Core #15776]、[2][Bitcoin Core #15834]）试图解决这个问题，但项目中普遍同意在 0.18.0 中移除新功能，以便在发布生产版本之前在开发分支中对其及其补丁进行更多测试。RC 周期的目标是识别潜在问题，以便在影响普通用户之前解决它们，因此我们认为我们代表这些用户感谢所有参与测试的人。

- [Bitcoin Core #15557][] 增强了 `bumpfee` RPC 和 GUI 中等效菜单选项的底层功能，以便在费用增加无法通过简单地减少现有找零输出的值来支付时，包含额外的输入。这消除了 Optech 在 [RBF 可用性研究][rbf core fail]中描述的 Bitcoin Core 的[失败模式][rbf core fail]，因此使得 Bitcoin Core 用户的费用提升更常成功。

- [C-Lightning #2541][]、[#2545][c-lightning #2545] 和 [#2546][c-lightning #2546] 实现了用于跟踪可用通道并计算其路由的 gossip 子系统的多个变化。这项工作是由[百万通道项目][million channels project]推动的，该项目的性能结果包含在许多提交消息中。如果 Optech 正确解释这些结果，则该系列中第一个提交 [417e1ba] 和最后一个提交 [0fc4241] 之间的区别是内存使用量减少了 79%，从 2.6 GiB 减少到 0.6 GiB，随机选择节点（在 20 跳内）构建路由的时间减少了 80%，从 60 秒减少到 12 秒。（如果即使改进后的值看起来仍然很高，请记住这是一个比当前主网网络大 25 倍以上的模拟网络，并且是大约一年前网络规模的 1,000 倍。）此更改的一个值得注意的部分是 C-Lightning 从其相当独特的 [Bellman--Ford--Gibson (BFG)][bfg post] 路由算法切换到[稍作定制的][e197956] [Dijkstra][] 版本。

- [Eclair #885][] 添加了一个用于跟踪支付的单一 UUID 样式标识符，无论使用了什么 HTLC，与其相关的支付都可以简化跟踪支付本身最终是否成功或失败。这解决了程序自动重试暂时失败的支付使用不同路由并因此生成非最终失败和其他可能对高级 API 消费者无用的信息的情况。尽管在实现和动机上存在差异，但这在概念上与 [C-Lightning #2382][] 在 [Newsletter #36][] 的*值得注意的代码变化*部分中描述的情况有关。

- [Eclair #951][] 实现了通道备份机制并提供了使用它的[文档][eclair backup]。与本 Newsletter 前面描述的 LND 静态通道备份不同，这需要在每次支付后进行备份。一个配置选项允许 Eclair 调用您指定的脚本，以便在需要备份时自动处理备份数据文件。

- [Eclair #927][] 增加了对用 Scala、Java 或兼容 JVM 的语言编写的插件的支持。插件是[插件接口][eclair plugin interface]的实现。请参阅新增的[文档][eclair plugin doc]了解详细信息。

## 脚注

[^fn-bip157-bip158]:
    [BIP158][] 引入了 _致密区块过滤器_，这是基于一种高效编码相同大小项目列表的方法。对于 BIP 中描述的“基本”区块过滤器，这是当前区块中所有可支配输出 scriptPubKey 的列表，加上这个区块的输入所花费的输出（开发人员称之为前输出（prevouts））的 scriptPubKey 列表。这些 scriptPubKey 中的每一个都被散列，使每个项目具有相同的大小，然后将这些项目排序到一个删除重复元素的列表中。然后使用 BIP158 中也描述的 [Golomb--Rice 编码集合][gcs]（GCS）算法对这个列表进行编码，无损地减少列表的大小。这个特定的基本过滤器提供了足够的信息，使任何知道比特币地址的人都能找到包含支付该地址（输出 scriptPubKey）或花费先前收到该地址的资金（prevout scriptPubKey）的交易的任何区块。搜索可能会产生假阳性匹配（因此不包含该地址交易的区块将包含在结果中），但不会产生假阴性（因此包含该地址交易的区块永远不会从结果中省略）。

    一个单独的 BIP，[BIP157][]，描述了如何通过比特币 P2P 协议在网络上传输这些致密区块过滤器。BIP157 设计为与 BIP158“基本”过滤器一起工作，但也可以扩展以支持编码其他项目列表的附加过滤器。BIP157 的一个特别值得注意的部分是它引入了 *过滤器头* 的概念，其中每个过滤器的头部承诺前一个区块的过滤器头的哈希加上当前过滤器的哈希。这创建了一个类似于比特币区块链的过滤器链，旨在使比较多个对等方的过滤器变得容易：每个对等方只需发送过滤器头（32 字节），如果有任何头不匹配，客户端可以请求更早的头链，直到找到分歧点。按需生成特定区块的过滤器头将需要对所有先前的过滤器进行哈希处理，因此尽管 Bitcoin Core 的实现目前不支持 BIP157，它仍然将这些头存储在磁盘上以备将来使用。使用新的 `getblockfilter` RPC 检索过滤器时，将返回 BIP158 过滤器和 BIP157 头：

    ```text
    $ bitcoin-cli getblockfilter $( bitcoin-cli getblockhash 170 )
    {
      "filter": "0357e49590040c79b0",
      "header": "349eaecc8bb7793c9f3c28e78df6675ef904515e9a310e4532785aeb45526090"
    }
    ```

    我们选择了区块 170，因为它的过滤器是第一个包含多个元素的过滤器（包含 3 个元素），并且截至本文撰写时的最新区块（区块 572,879）具有包含 8,599 个元素的过滤器——对我们来说，太多了，无法优雅地打印出来。

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
