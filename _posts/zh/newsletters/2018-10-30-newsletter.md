---
title: "Bitcoin Optech Newsletter #19"
permalink: /zh/newsletters/2018/10/30/
name: 2018-10-30-newsletter-zh
slug: 2018-10-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 建议 C-Lightning 用户进行更新，描述了关于 BIP69 确定性输入/输出排序的邮件列表讨论、注意到 Antminer S9 使用的矿工现在可以公开支持 ASICBoost、提供了有关 Square 开源的基于 HSM 的多签名冷存储解决方案和最近在纽约市举行的闪电网络实习和黑客日的资源链接。还包括从 Bitcoin Stack Exchange 最近的精选问答和流行的 Bitcoin 基础设施项目中值得注意的代码更改的描述。

## 行动项

- **<!--update-to-c-lightning-0-6-2-->****更新到 [C-Lightning 0.6.2][]：** 修复了一个错误，该错误会导致节点向其对等方发送过多关于结束通道的更新公告。

## 新闻

- **<!--bip69-discussion-->****[BIP69][] 讨论：** 该 BIP 从 2015 年开始，被一些著名的钱包采纳，规定了一种基于交易的公开内容的可选方法，用于确定性地排序交易中的输入和输出。然而，其他钱包没有采纳它（甚至拒绝将其视为适合采纳），可能导致了一种“两全其美”的情况，其中使用 BIP69 的钱包可以相当容易地被识别，因此不使用 BIP69 的钱包也可能通过否定更容易识别。

    在这个[线程][bip69 thread]到 Bitcoin-Dev 邮件列表中，Ryan Havar 提议说，钱包作者喜欢 BIP69 的一个原因是，其确定性排序使得他们的测试能够容易且快速地确保他们没有泄露关于他们输入的来源或他们输出的目的地的任何信息（例如，在一些旧钱包中，第一个输出总是发送给收款人，第二个输出总是变化——使得跟踪硬币变得微不足道）。Havar 然后提出了一种基于私有信息的替代确定性排序，这些信息可供测试套件使用，但不会由生产钱包暴露，允许想要挫败区块链分析的开发人员——但也想要简单快速的测试——迁移到 BIP69 之外。

- **<!--overt-asicboost-support-for-s9-miners-->****S9 矿工公开支持 ASICBoost：** 本周 [Bitmain][bitmain oab] 和 [Braiins][braiins oab] 宣布了对这种效率改进特性的支持。ASICBoost 利用 Bitcoin 挖矿中使用的 SHA256 算法首先将 80 字节的区块头分成 64 字节的块的事实。如果矿工可以找到多个提议的区块头，其中第一块 64 字节不同但下一块 64 字节的开始相同，那么他们可以尝试不同的第一块和第二块的组合来减少他们需要进行的总哈希操作数量以找到有效的区块。初步估计表明，在现有的 Antminer S9 硬件上提高了 10%（或可能更多）。

    ASICBoost 的公开形式改变了区块头中的 versionbits 字段，这可能导致像 Bitcoin Core 这样的程序显示警告，如“最近 100 个区块中有 13 个有意外的版本”。一些 ASICBoost 矿工自愿将他们改变的 versionbits 范围限制在 [BIP320][] 定义的范围内，为未来的程序提供了忽略这些位以进行升级信号的选项。

- **<!--open-sourced-hsm-based-multisig-cold-storage-solution-->****开源的基于 HSM 的多签名冷存储解决方案：** [Square][] 已发布他们实现的用于保护客户存款的冷存储解决方案的代码和文档，以及用于在任意时间点审计 HD 钱包余额的 CLI 工具。Optech 尚未评估他们的解决方案，但我们可以推荐感兴趣的人阅读 Square 的优秀[博客文章][subzero blog]并访问 [Subzero][] 冷存储解决方案和 [Beancounter][] 审计工具的仓库。

- **<!--lightning-residency-and-hackday-->****闪电网络实习和黑客日：** 上周 [Chaincode Labs][] 主办了为期五天的[闪电网络实习][Lightning Network Residency]项目，以帮助开发人员上手这一新兴协议。此后，Fulmo 在纽约市组织了第四届 [闪电网络黑客日][Lightning Network Hackday]（实际上是两天），其中包括一些演讲、许多演示和大量的黑客攻击。

    Pierre Rochard 已编写在实习项目中所有演讲的摘要（[第1天][lr1]，[第2天][lr2]，[第3天][lr3]，[第4天][lr4]），演讲视频预计很快发布。黑客日的视频现已可用：[第1天][hd1]，[第2天][hd2]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地之一——或者当我们有一些空闲时间帮助回答其他人的问题时。在这个月度特辑中，我们突出显示自上次更新以来投票最多的问题和答案。*

- **<!--does-using-pruning-make-initial-node-sync-faster-->**[使用修剪是否会使初始节点同步更快？][bse 79592] 在处理完区块后进行修剪可以在目前减少超过 97% 的磁盘空间需求，但它也会加速同步吗？Bitcoin Core 开发者 Gregory Maxwell 回答了这个问题。

- **<!--can-someone-steal-from-you-by-closing-their-lightning-network-payment-channel-in-a-certain-way-->**[有人能通过以某种方式关闭他们的闪电网络支付通道来从你这里偷东西吗？][bse 80399]** 描述了几种关闭 Lightning Network 支付通道的不同方式，C-Lightning 开发者 Christian Decker 解释了在每种情况下，遵循 LN 协议的程序将如何保护你的资金。

- **<!--how-much-energy-does-it-take-to-create-one-block-->**[创建一个区块需要多少能量？][bse 79691]** Nate Eldredge 提供了一个简单的公式和一组链接，任何人都可以使用它们来估算在当前难度级别生成一个区块平均需要多少能量。对于当前的难度，只使用没有 ASICBoost 的 Antminer S9s，平均每个区块消耗 841,629 千瓦时（kWh）。以 $0.04/kWh 的常见估算，这约等于 $34,000 的电费——远低于当前的约 $80,000 区块奖励——但使用 [AJ Towns 的最近估算][towns mining estimate] 包括超出电费的成本，并试图计算风险溢价，估计的区块成本约为 $135,000。

## 值得注意的合并

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中流行的 Bitcoin 基础设施项目中值得注意的代码更改。*

{% comment %}<!-- no commits to libsecp256k1; one interesting commit
#448 to C-Lightning, but I'm not confident enough of my understanding of
it to write a good description, and I doubt non-LN devs care -->{% endcomment %}

- [Bitcoin Core #14451][] 允许可选地构建不支持 [BIP70][] 支付协议的 Bitcoin-Qt，并添加了一个弃用警告，表明默认支持可能会在未来的版本中被移除。BitPay 的 CEO，这是 BIP70 的最大用户（但希望使用不同版本的协议），[表示][bitpay bip70 comment] 他们支持 Bitcoin Core 移除 BIP70。开发者似乎支持出于安全原因以及使用量下降而移除协议。BIP70 对 OpenSSL 的依赖导致了 [Bitcoin Core 0.9.1][] 的紧急发布，作为[心脏出血漏洞][heartbleed vulnerability]的结果，预计移除它将消除未来类似漏洞的风险。

- [Bitcoin Core #14296][] 移除了不推荐使用的 `addwitnessaddress` RPC。此 RPC 在 0.13.0 版本中添加，用于在 mainnet 激活和构建到钱包之前，在 regtest 和 testnet 上测试隔离见证。自 0.16.0 版本以来，Bitcoin Core 的钱包已经支持使用常规的 [getnewaddress][rpc getnewaddress] 机制直接获取地址。

- [Bitcoin Core #14468][] 弃用了 `generate` RPC。此方法在 regtest 模式下生成新的区块，但它需要从 Bitcoin Core 的内置钱包获取新地址，以支付他们的挖矿[区块奖励][term block reward]。在 0.13.0 版本中引入了一种替代方法，[generatetoaddress][rpc generatetoaddress]，它允许任何 regtest 钱包生成将获得区块奖励的地址。这是一个持续的努力的一部分，目的是允许尽可能多的 RPC 在没有钱包的情况下功能，以提高非钱包节点的测试覆盖率，以及为将来可能将钱包完全与节点分离的过渡提供便利。

- [Bitcoin Core #14150][] 为 [输出脚本描述符][output script descriptors] 添加了[关键源][key origin]支持。除了允许你向 [scantxoutset][rpc scantxoutset] RPC 传递一个额外的参数外，这目前不会为 Bitcoin Core 添加任何功能——但它将允许在这些软件部分已更新以使用描述符时，使用关键源与 [BIP174][] PSBTs 和只观察钱包一起使用。有关输出脚本描述符的先前讨论，请参阅 Newsletter [#5][newsletter #5]、[#7][newsletter #7]、[#9][newsletter #9]、[#12][newsletter #12] 和 [#17][newsletter #17]。关键源支持使得可以使用已从使用 [BIP32][] 硬化派生来保护祖先私钥的 HD 钱包导出的扩展公钥，这有助于使输出脚本描述符与大多数硬件钱包兼容。

- [LND #1981][] 确保 LND 不会泄露关于其任何未将自己宣传为公共节点的对等方的信息。

- {:#lnd-1535-1512}
  LND [#1535][LND #1535] 和 [#1512][LND #1512] 添加了用于监视器的服务器端通信协议以及许多验证其正确操作的测试。正确使用 LN 协议需要定期监控哪些交易被添加到区块链中，因此监视器是旨在帮助保护预计将离线长时间的用户的支付通道的服务器。因此，监视器被认为是使 LN 通过不太先进的用户获得更广泛采用的关键功能。然而，LN 的多个实现尚未就监视器的标准规范达成一致，因此 LND 仅将此功能用于初始测试，并将其使用限制在 testnet 上。

{% include references.md %}
{% include linkers/issues.md issues="14451,14296,14468,14150,1981,1535,1512" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 79592]: {{bse}}79592
[bse 80399]: {{bse}}80399
[bse 79691]: {{bse}}79691

[hd1]: https://www.youtube.com/watch?v=FGxFd944jMg
[hd2]: https://www.youtube.com/watch?v=o87GVYFvwIk
[lr1]: https://medium.com/@pierre_rochard/day-1-of-the-chaincode-labs-lightning-residency-ab4c29ce2077
[lr2]: https://medium.com/@pierre_rochard/day-2-of-the-chaincode-labs-lightning-residency-669aecab5f16
[lr3]: https://medium.com/@pierre_rochard/day-3-of-the-chaincode-labs-lightning-residency-5a7fad88bc62
[lr4]: https://medium.com/@pierre_rochard/day-4-of-the-chaincode-labs-lightning-residency-f28b046fc1a6
[c-lightning 0.6.2]: https://github.com/ElementsProject/lightning/releases
[bip69 thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-October/016457.html
[bitmain oab]: https://blog.bitmain.com/en/new-firmware-activate-overt-asicboost-bm1387-antminer-models/
[braiins oab]: https://twitter.com/braiins_systems/status/1055153228772503553
[subzero blog]: https://medium.com/square-corner-blog/open-sourcing-subzero-ee9e3e071827
[subzero]: https://github.com/square/subzero
[beancounter]: https://github.com/square/beancounter/
[lightning network residency]: https://lightningresidency.com/
[chaincode labs]: https://chaincode.com/
[lightning network hackday]: https://lightninghackday.fulmo.org/
[bitpay bip70 comment]: https://github.com/bitcoin/bitcoin/pull/14451#issuecomment-431496319
[bitcoin core 0.9.1]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.9.1.md
[heartbleed vulnerability]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[term block reward]: https://btcinformation.org/en/glossary/block-reward
[key origin]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82#key-origin-identification
[towns mining estimate]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/playing-with-fire-adjusting-bitcoin-block-subsidy/
[square]: https://cash.app/bitcoin
[newsletter #5]: /zh/newsletters/2018/07/24/#first-use-of-output-script-descriptors
[newsletter #7]: /zh/newsletters/2018/08/07/#bitcoin-core-13697
[newsletter #9]: /zh/newsletters/2018/08/21/#output-script-descriptors-enhancements
[newsletter #12]: /zh/newsletters/2018/09/11/#bitcoin-core-14096
[newsletter #17]: /zh/newsletters/2018/10/16/#script-descriptors-and-descript
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
