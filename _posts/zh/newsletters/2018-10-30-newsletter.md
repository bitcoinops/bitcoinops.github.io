---
title: "Bitcoin Optech Newsletter #19"
permalink: /zh/newsletters/2018/10/30/
name: 2018-10-30-newsletter-zh
slug: 2018-10-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 建议 C-Lightning 用户进行更新；介绍邮件列表上关于 BIP69 确定性输入/输出排序的讨论；提到使用 Antminer S9 的矿工现在可以使用公开的显式 ASICBoost 支持；并给出相关资源链接，内容涉及 Square 开源的、基于 HSM 的 Subzero 多重签名冷存储方案，以及最近在纽约市举办的闪电网络驻留项目（Lightning Network Residency）和黑客日。此外还包含 Bitcoin Stack Exchange 近期精选问答，以及热门 Bitcoin 基础设施项目中值得注意的代码变更介绍。

## 行动项

- **<!--update-to-c-lightning-0-6-2-->****更新到 [C-Lightning 0.6.2][]：** 修复了一个 bug：节点会向对等节点发送过多关于已失效通道的更新公告。

## 新闻

- **<!--bip69-discussion-->****[BIP69][] 讨论：** 这份 2015 年的 BIP 已被若干知名钱包采纳，它规定了一种可选方法，依据交易中公开可见的内容来确定性地排列交易的输入和输出。然而，其他钱包并未采纳它（甚至认为它不适合采纳而予以拒绝），这或许造成了“两头都不落好”的局面：使用 BIP69 的钱包相当容易被识别出来，而不使用 BIP69 的钱包也因此可以通过排除法更容易被识别。

    在 Bitcoin-Dev 邮件列表的这个[讨论帖][bip69 thread]中，Ryan Havar 提出，钱包作者偏爱 BIP69 的一个原因在于：得益于确定性排序，他们的测试可以轻松、快速地确认自己有没有泄露任何关于输入来源或输出去向的信息（例如在早期的一些钱包里，第一个输出总是给收款方，第二个输出总是找零——这让币的追踪变得轻而易举）。Havar 随后提出了一种基于私有信息的替代性确定性排序方案：这些信息对测试套件可用，但生产钱包不会暴露它们，这样那些既想挫败区块链分析、又想保持测试简单快速的开发者，就可以从 BIP69 迁移出去。

- **<!--overt-asicboost-support-for-s9-miners-->****S9 矿工获得显式 ASICBoost 支持：** 本周 [Bitmain][bitmain oab] 和 [Braiins][braiins oab] 都宣布支持这项提升效率的特性。ASICBoost 利用的是这样一个事实：Bitcoin 挖矿所用的 SHA256 算法会先把 80 字节的区块头切分成 64 字节的数据块。如果矿工能找到多个候选区块头，它们的前 64 字节各不相同，但下一个 64 字节块的开头部分相同，那么矿工就可以尝试第一块与第二块的不同组合，从而减少找出有效区块所需的哈希运算总次数。初步估计显示，在现有 Antminer S9 硬件上可获得 10%（或许更多）的提升。

    ASICBoost 的显式形式会改动区块头中的 versionbits 字段，这可能让 Bitcoin Core 之类的程序弹出警告，例如“最近 100 个区块中有 13 个带有意外的版本”。一些 ASICBoost 矿工自愿把自己改动后的 versionbits 范围限制在 [BIP320][] 所定义的区间内，从而让未来的程序可以选择忽略这些位、不把它们当作升级信号。

- **<!--open-sourced-hsm-based-multisig-cold-storage-solution-->****开源的基于 HSM 的多重签名冷存储解决方案：** [Square][] 已发布其用于保护客户存款的冷存储方案的代码与文档，以及一个可在任意时间点审计 HD 钱包余额的 CLI 工具。Optech 尚未评估他们的方案，但我们可以建议感兴趣的人阅读 Square 的这篇优秀[博客文章][subzero blog]，并访问 [Subzero][] 冷存储方案和 [Beancounter][] 审计工具的代码仓库。

- **<!--lightning-residency-and-hackday-->****闪电网络驻留项目与黑客日：** 上周 [Chaincode Labs][] 主办了为期五天的[闪电网络驻留项目][Lightning Network Residency]，帮助开发者上手这一尚在起步阶段的协议。随后，Fulmo 也在纽约市组织了第四届[闪电网络黑客日][Lightning Network Hackday]（实际上为期两天），包含几场演讲、大量演示以及密集的编程实践。

    Pierre Rochard 已经为驻留项目中的全部演讲写了摘要（[第 1 天][lr1]，[第 2 天][lr2]，[第 3 天][lr3]，[第 4 天][lr4]），演讲视频预计很快就会发布。黑客日的视频现已可用：[第 1 天][hd1]、[第 2 天][hd2]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮忙回答他人问题的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

- **<!--does-using-pruning-make-initial-node-sync-faster-->**[使用修剪是否会使初始节点同步更快？][bse 79592] 在区块处理完成后进行修剪，目前可将磁盘空间需求降低 97% 以上，但它也能加快同步吗？Bitcoin Core 开发者 Gregory Maxwell 回答了这个问题。

- **<!--can-someone-steal-from-you-by-closing-their-lightning-network-payment-channel-in-a-certain-way-->**[有人能通过以某种方式关闭他们的闪电网络支付通道来从你这里偷东西吗？][bse 80399] 文中介绍了几种关闭闪电网络支付通道的不同方式，C-Lightning 开发者 Christian Decker 逐一解释了在每种情况下，遵循 LN 协议的程序会如何保护你的资金。

- **<!--how-much-energy-does-it-take-to-create-one-block-->**[创建一个区块需要多少能量？][bse 79691] Nate Eldredge 给出了一个简单的公式和一组数据链接，任何人都可以用它们来估算在当前难度下生成一个区块平均需要多少能源。按当前难度、仅使用未启用 ASICBoost 的 Antminer S9，平均每个区块耗电 841,629 千瓦时（kWh）。按每千瓦时 0.04 美元的常见估算，电费约合 34,000 美元——远低于目前约 80,000 美元的区块奖励——但若采用 [AJ Towns 的近期估算][towns mining estimate]，即每千瓦时 0.16 美元，其中还包含电费之外的成本并尝试计入风险溢价，则每个区块的成本估计约为 135,000 美元。

## 值得注意的合并

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

{% comment %}<!-- no commits to libsecp256k1; one interesting commit
#448 to C-Lightning, but I'm not confident enough of my understanding of
it to write a good description, and I doubt non-LN devs care -->{% endcomment %}

- [Bitcoin Core #14451][] 允许可选地构建不支持 [BIP70][] 支付协议的 Bitcoin-Qt，并添加了一个弃用警告，说明默认的 BIP70 支持可能在未来的版本中被移除。BIP70 的最大用户 BitPay（但它希望改用该协议的另一版本）的 CEO [表示][bitpay bip70 comment]，他们支持 Bitcoin Core 移除 BIP70。开发者似乎也赞成移除该协议，理由既有安全性，也有其使用量不断下降。由于依赖 OpenSSL，BIP70 曾在 2014 年导致 [Bitcoin Core 0.9.1][] 因[心脏出血（Heartbleed）漏洞][heartbleed vulnerability]而紧急发布；预计移除该协议将消除未来出现类似漏洞的风险。

- [Bitcoin Core #14296][] 移除了已弃用的 `addwitnessaddress` RPC。该 RPC 在 0.13.0 版本中加入，用于在隔离见证于主网激活、并集成进钱包之前，在 regtest 和 testnet 上测试它。自 0.16.0 版本起，Bitcoin Core 的钱包已经支持通过常规的 [getnewaddress][rpc getnewaddress] 机制直接获取地址。

- [Bitcoin Core #14468][] 弃用了 `generate` RPC。该方法可在 regtest 模式下生成新区块，但它需要从 Bitcoin Core 的内置钱包取得新地址，才能向该地址支付挖矿[区块奖励][term block reward]。0.13.0 版本引入了替代方法 [generatetoaddress][rpc generatetoaddress]，允许任意 regtest 钱包生成一个用于接收区块奖励的地址。这是一项长期工作的一部分：让尽可能多的 RPC 在没有钱包的情况下也能工作，既提高非钱包节点的测试覆盖率，也为将来可能把钱包与节点彻底分离的过渡做好准备。

- [Bitcoin Core #14150][] 为[输出脚本描述符][output script descriptors]添加了[密钥来源（key origin）][key origin]支持。除了允许你向 [scantxoutset][rpc scantxoutset] RPC 多传一个参数外，目前它并没有给 Bitcoin Core 增加任何功能——但等到软件的相应部分更新为使用描述符后，密钥来源就能用于 [BIP174][] 部分签名比特币交易（PSBT）和只读钱包。有关输出脚本描述符的先前讨论，请参阅 Newsletter [#5][newsletter #5]、[#7][newsletter #7]、[#9][newsletter #9]、[#12][newsletter #12] 和 [#17][newsletter #17]。密钥来源支持让以下做法成为可能：使用从 HD 钱包导出的扩展公钥，而该钱包采用 [BIP32][] 硬化派生来保护祖先私钥；这有助于让输出脚本描述符与大多数硬件钱包兼容。

- [LND #1981][] 确保 LND 不会泄露任何未把自己宣传为公开节点的对等节点的信息。

- {:#lnd-1535-1512}
  LND [#1535][LND #1535] 和 [#1512][LND #1512] 为瞭望塔（watchtower）添加了服务端通信协议，并附有大量验证其正常工作的测试。正确使用 LN 协议需要定期监控哪些交易被加入区块链，因此瞭望塔是这样一类服务器：它帮助保护那些预计会长时间离线的用户的支付通道。正因如此，瞭望塔被视为让 LN 被更多普通用户采用的关键特性。然而，LN 的多个实现尚未就瞭望塔的标准规范达成一致，因此 LND 只是把该功能拿出来做初步测试，并限定仅在 testnet 上使用。

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
[bip69 thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-October/016457.html
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
