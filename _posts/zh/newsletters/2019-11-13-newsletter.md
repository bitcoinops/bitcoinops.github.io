---
title: 'Bitcoin Optech Newsletter #72'
permalink: /zh/newsletters/2019/11/13/
name: 2019-11-13-newsletter-zh
slug: 2019-11-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了一项影响某些旧版本 Bitcoin Core 的安全漏洞披露，描述了与 taproot 相关的新进展，提到了与 LN 支付数据格式相关的潜在隐私泄露，并讨论了两个正在讨论的 LN 规范变更提案。此外，我们还包括了我们常规部分，描述流行比特币基础设施项目的值得注意的变化。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无行动项。*

## 新闻

- **<!--cve-2017-18350-socks-proxy-vulnerability-->****CVE-2017-18350 SOCKS 代理漏洞：** 对 Bitcoin Core 版本 0.11.0（2012 年 9 月）到 0.15.1（2017 年 11 月）中的漏洞进行了全面披露，该信息已发布在 Bitcoin-Dev 邮件列表上。该漏洞仅影响那些配置了 SOCKS 代理以使用不受信任的服务器或在不受信任的网络上连接的用户。几乎所有受影响的 Bitcoin Core 版本也受到之前披露的漏洞影响，例如 CVE-2016-10724（请参见 [Newsletter #1][news1 alert]）和 CVE-2018-17144（请参见 [Newsletter #14][news14 cve]），因此用户应该已经升级到 Bitcoin Core 0.16.3 或更高版本。

- **<!--taproot-review-discussion-and-related-information-->****Taproot 审查、讨论及相关信息：** 共有 163 人注册参与在 [Newsletter #69][news69 taproot review] 中提到的结构化 taproot 审查。上周，他们开始审查 [bip-taproot][] 及相关概念的第一部分，包括参与与之前为 taproot 设计做出贡献的比特币专家的问答环节。

  一项被问到的问题是，为什么 taproot 允许 v1 segwit scriptPubKeys 使用少于或多于 34 字节——这是 Pay-to-Taproot（P2TR）scriptPubKey 所需的字节数。这看起来很奇怪，因为 [BIP141][] v0 原生 segwit scriptPubKeys 仅允许使用恰好 22 字节用于 P2WPKH 或 34 字节用于 P2WSH。回应是，减少限制将允许以后进行软分叉，以定义其他用途的 v1 scriptPubKeys，其长度可以更短或更长。同时，如果 taproot 被采纳，那些更短和更长的 v1 scriptPubKeys 将可由任何人支出（如同今天一样）。

  这引发了专家之间的讨论，讨论内容涉及 bech32 地址编码算法中的一个问题，该问题在 5 月份被[报道][bech32 length change]，并在最近[详细描述][bse bech32 extension]。根据 [BIP173][] 的规范，bech32 地址应该保证在一个错误复制的地址中可以检测到最多四个错误，并且在五个或更多错误的情况下，只有大约每十亿个错误复制的地址会漏检。不幸的是，这些计算是在假设复制的地址长度与原始长度相同的情况下进行的。如果复制的地址长度变长或变短，bech32 有时可能无法检测到一个字符的错误。

  对于现有的 P2WPKH 和 P2WSH bech32 地址，这很可能不会成为问题，因为 v0 scriptPubKeys 必须恰好为 22 或 34 字节的限制意味着一个错误复制的 P2WPKH 地址需要包含多出 12 字节，或 P2WSH 地址需要省略 12 字节，这意味着用户需要输入大约 19 个额外或更少的 bech32 字符——这是一个非常大的错误。<!-- 8 bits per byte * 12 bytes / 5 bits per bech32
  character = 19.2 bech32 characters -->

  但是，如果 P2TR 仅为 34 字节的 v1 scriptPubKeys 定义，而任何人仍然可以支出 33 字节和 35 字节的 v1 scriptPubKeys，那么用户可能会犯一个字符错误，从而失去所有他们打算支出的资金。BIP173 和 taproot 提案的作者 Pieter Wuille 在 Bitcoin-Dev 邮件列表上[发布][wuille bech32 workaround]了一些应对这个问题的选项，并请求对人们希望实施的选项提供反馈。一个选项是限制所有当前 bech32 实现拒绝任何不导致 22 或 34 字节 scriptPubKey 的原生 segwit 地址。然后，bech32 的升级版本可以开发出更好的检测插入或删除字符的能力。

  本周的 taproot 审查还引发了许多其他不那么重要的讨论，讨论记录可供有兴趣的读者查看（[1][tr meet1]，[2][tr meet2]）。

  在其他 schnorr/taproot 新闻中，Jonas Nick 发布了一篇[信息丰富的博客文章][x-only pubkeys]，介绍了 [bip-schnorr][] 和 [bip-taproot][] 的最近重大变化，该变化将序列化公钥的大小从 33 字节减少到 32 字节，同时不降低安全性。有关此优化的先前讨论，请参见 Newsletters [#59][news59 proposed 32B pubkeys] 和 [#68][news68 taproot update]。

- **<!--possible-privacy-leak-in-the-ln-onion-format-->****LN 洋葱格式的潜在隐私泄露：** 正如在 [BOLT4][] 中所述，LN 使用 [Sphinx][] 协议在 LN 节点之间传递支付信息。Olaoluwa Osuntokun 本周在 Lightning-Dev 邮件列表上[发布][osuntokun sphinx]了一项关于最近发布的[原始 Sphinx 描述中的缺陷][breaking onion routing] 的帖子，该缺陷可能允许目标节点“推断出路径长度的下限[回到源节点]”。<!-- quote from Osuntokun email -->
修复很简单：使用随机值字节初始化洋葱数据包的一部分，而不是用零字节。Osuntokun 创建了一个 [PR][lnd-onion]，在 LND 使用的洋葱库中实现这一点，并且还为 BOLTs 存储库创建了一个[文档 PR][bolts #697]。其他实现也采纳了相同的更改（请参见下面的 [C-Lightning 提交][news72 cl onion]）。

- **<!--ln-up-front-payments-->****LN 预付款：** 当前 LN 协议在支付尝试失败或被接收方拒绝时会将所有资金退还给支付者，因此路由节点只有在支付尝试成功时才会获得收入。然而，一些新应用程序利用这种无成本失败机制通过 LN 发送数据，而无需支付他们使用的带宽。LN 设计者预料到这种情况，并且之前花时间考虑如何向网络添加预付费——这些费用将在支付尝试成功与否时都支付给路由节点。

  本周，Rusty Russell 在 Lightning-Dev 邮件列表上发起了一场关于预付费提案的[讨论][russell up-front]。Russell 提出了一个结合费用和哈希现金风格的工作量证明的机制，试图防止节点利用额外的预付款信息来猜测路线的长度。Anthony Towns 提出了一个部分的[替代方案][towns up-front]，重点在于通过退款机制管理支付金额。

  Joost Jager 建议预付款应仅在最后手段下要求，因为即使是很小的额外费用也可能使微支付不经济。他建议应该能够通过基于节点信誉的速率限制来解决带宽浪费的网络活动，并进一步建议对预付款的研究应优先解决流动性滥用问题——即攻击者在一定时间内占用某人的通道资金——因为解决该问题的方法也可能防止路由节点带宽的滥用。

  最终，尚未达成任何结论，关于该主题的讨论仍在继续。

- **<!--proposed-bolt-for-ln-offers-->****LN 提供的提案 BOLT：** Rusty Russell [发布][bolt offers]了允许用户通过 LN 路由协议提交报价和接收发票的新 BOLT 草案。例如，Alice 可以订阅 Bob 提供的服务，每月提交支付 Bob 的报价，Bob 则回复一份发票，Alice 支付该发票后，Bob 提供该服务。

  对该提案的初步反馈表明，可能希望使用一种已建立的机器可读发票语言，例如[通用商业语言][Universal Business Language]（UBL）。然而，担心实施完整的 UBL 规范对 LN 软件开发者来说将是一个过大的负担。

- **<!--new-topic-index-on-optech-website-->****Optech 网站上的新主题索引：** 我们[宣布][topics announcement]在 Optech 网站上添加了一个主题索引，使读者可以轻松找到我们提到某一特定主题的所有位置。该索引已发布，初始设置为 40 个主题，我们希望在接下来的一年中将其增加到约 100 个主题。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #16110][] 添加了对 Android 原生开发工具包（NDK）构建 Bitcoin Core（包括 GUI）的支持。与像 [Android Bitcoin Core][] (ABCore) 这样独立的项目不同，后者为 Android NDK 构建自己的 Bitcoin Core 二进制文件，直接向 Bitcoin Core 项目添加支持可能简化测试。这也可能允许未来的拉取请求将 Android 构建添加到确定性生成的可执行文件集中，从而使用户更有保障，确保他们运行的是代码库中经过良好审查的相同代码。

- [Bitcoin Core #16899][] 添加了一个 `dumptxoutset` RPC，将当前的 UTXO 集的副本以一种为未来使用的序列化格式写入磁盘，供使用 assumeutxo 启动的节点使用（参见 [Newsletter #41][news41 assumeutxo]）。此外，项目的贡献者工具中还添加了一个脚本，可以将区块链回滚到指定的区块高度，在该点转储 UTXO 集，然后正常重新处理区块。这可能需要每个区块几秒钟的时间，因此在过去几千个区块高度运行该脚本可能会耗费很长时间。

- [Bitcoin Core #17258][] 更新了 `listsinceblock` RPC，以防止列出任何无法确认的交易，因为另一笔交易花费了至少一个相同的输入，并且已在评估 RPC 调用之前被包含在区块链中。

- [C-Lightning #3246][] 试图修复本周在 LN 邮件列表上描述的潜在数据泄漏（参见 [news item][news72 sphinx]）。

- [LND #3442][] 使得支出者能够手动构建用于简单多路径支付的数据包——这些支付被分成几个部分，并且可以通过不同的通道独立路由。这不是为用户访问而设计的，而是为后续功能提供基础，以增加与多路径支付相关的其他功能。有关多路径支付的更多信息，请参见 [Newsletter #27][news27 multipath]。

- [BIPs #857][] 编辑了 [BIP157][]，将一次可以请求的致密区块过滤器的最大数量从 100 增加到 1,000。这是对去年的 [PR][BIPs #699] 的恢复，该 PR 将其从 1,000 降低到 100。

- [BIPs #849][] 编辑了 [BIP174][]，为部分签名比特币交易（PSBTs）分配某些数据类型标识符，以供非标准化（专有）应用程序使用。此外，PSBTs 现在被赋予一个版本号，以帮助识别对 PSBTs 的向后不兼容更改，未包含显式版本号的旧 PSBTs 隐式版本号为 0。这两个更改之前已在 Bitcoin-Dev 邮件列表上讨论（参见 [Newsletter #58][news58 psbts]）。

- [BIPs #856][] 添加了 [BIP179][]，该提案建议将当前的术语“比特币地址”重命名为“比特币发票地址”或更简单的变体，如“发票地址”或仅“发票”。这一点之前已在 Bitcoin-Dev 邮件列表上[讨论过][bip179 genesis]。

- [BIPs #803][] 添加了 [BIP325][]，描述了一种基于签名区块而非挖矿区块创建测试网的 signet 协议，允许 signet 的运营者控制区块生产速率及区块链重组的频率和幅度（参见 [Newsletter #37][news37 signet]）。

- [BIPs #851][] 添加了 [BIP330][]，描述了交易公告调和方法，旨在作为 [erlay][] 协议的一部分使用（参见 [Newsletter #66][news66 erlay]）。如果该功能被节点软件采纳，将是显著减少转发交易公告带宽开销的第一步，目前这可能占用典型节点带宽的 40% 以上。

{% include linkers/issues.md issues="16110,16899,17258,3246,3442,857,856,803,851,16442,3649,697,849,699" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[x-only pubkeys]: https://medium.com/blockstream/reducing-bitcoin-transaction-sizes-with-x-only-pubkeys-f86476af05d7
[news1 alert]: /zh/newsletters/2018/06/26/#pending-dos-vulnerability-disclosure-for-bitcoin-core-0-12-0-and-earlier-altcoins-may-be-affected
[news63 carve-out]: /zh/newsletters/2019/09/11/#bitcoin-core-16421
[news70 simple commits]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[news14 cve]: /zh/newsletters/2018/09/25/#cve-2018-17144
[news71 ln carve-out]: /zh/newsletters/2019/11/06/#continued-discussion-of-ln-anchor-outputs
[news43 core bip158]: /zh/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core
[news19 bip70]: /zh/newsletters/2018/10/30/#bitcoin-core-14451
[news57 bip37]: /zh/newsletters/2019/07/31/#bloom-filter-discussion
[news37 bip61]: /zh/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[news63 new wallet]: /zh/newsletters/2019/09/11/#bitcoin-core-15450
[news42 core gui bech32]: /zh/newsletters/2019/04/16/#bitcoin-core-15711
[news69 taproot review]: /zh/newsletters/2019/10/23/#taproot-review
[sphinx]: https://cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf
[news41 assumeutxo]: /zh/newsletters/2019/04/09/#discussion-about-an-assumed-valid-mechanism-for-utxo-snapshots
[news27 multipath]: /zh/newsletters/2018/12/28/#multipath-payments
[news58 psbts]: /zh/newsletters/2019/08/07/#bip174-extensibility
[news37 signet]: /zh/newsletters/2019/03/12/#feedback-requested-on-signet
[news66 erlay]: /zh/newsletters/2019/10/02/#draft-bip-for-enabling-erlay-compatibility
[cve-2017-18350]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017453.html
[breaking onion routing]: https://arxiv.org/abs/1910.13772
[bech32 length change]: https://github.com/sipa/bech32/issues/51
[lnd-onion]: https://github.com/lightningnetwork/lightning-onion/pull/40
[news72 cl onion]: #c-lightning-3246
[tr week 1]: https://github.com/ajtowns/taproot-review/blob/master/week-1.md
[why v1 flex]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-05-19.00.log.html#l-88
[wuille bech32 workaround]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017443.html
[tr meet1]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-05-19.00.log.html
[tr meet2]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-07-02.00.log.html
[russell up-front]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002275.html
[towns up-front]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002307.html
[bolt offers]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002276.html
[osuntokun sphinx]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002288.html
[universal business language]: https://en.wikipedia.org/wiki/Universal_Business_Language
[android bitcoin core]: https://github.com/greenaddress/abcore
[news72 sphinx]: #possible-privacy-leak-in-the-ln-onion-format
[bip179 genesis]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017369.html
[news52 avoid_reuse]: /zh/newsletters/2019/06/26/#bitcoin-core-13756
[dust flooding]: {{bse}}81509
[news59 proposed 32B pubkeys]: /zh/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[news68 taproot update]: /zh/newsletters/2019/10/16/#taproot-update
[news60 16248]: /zh/newsletters/2019/08/21/#bitcoin-core-16248
[bse bech32 extension]: {{bse}}91602
[topics announcement]: /en/topics-announcement/
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
