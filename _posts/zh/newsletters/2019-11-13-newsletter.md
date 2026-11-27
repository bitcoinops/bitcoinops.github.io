---
title: 'Bitcoin Optech Newsletter #72'
permalink: /zh/newsletters/2019/11/13/
name: 2019-11-13-newsletter-zh
slug: 2019-11-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 披露了一项影响部分旧版 Bitcoin Core 的安全问题，介绍了与 taproot 相关的新进展，提到 LN 支付数据格式可能存在隐私泄露，并介绍了 LN 规范中两项正在讨论的变更提案。此外还有我们介绍热门比特币基础设施项目值得注意的变更的固定栏目。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

*本周无行动项。*

## 新闻

- **<!--cve-2017-18350-socks-proxy-vulnerability-->****CVE-2017-18350 SOCKS 代理漏洞：** 一份关于 Bitcoin Core 0.11.0（2012 年 9 月）至 0.15.1（2017 年 11 月）版本中某个漏洞的完整披露已[发布][cve-2017-18350]到 Bitcoin-Dev 邮件列表。该漏洞仅影响那些把 SOCKS 代理配置为使用不受信任的服务器、或在不受信任的网络上连接的用户。几乎所有受影响的 Bitcoin Core 版本同时也受此前已披露漏洞的影响，例如 CVE-2016-10724（参见 [Newsletter #1][news1 alert]）和 CVE-2018-17144（参见 [Newsletter #14][news14 cve]），因此用户应该早已升级到 Bitcoin Core 0.16.3 或更高版本。

- **<!--taproot-review-discussion-and-related-information-->****Taproot 审查、讨论及相关信息：** 共有 163 人报名参加 [Newsletter #69][news69 taproot review] 中提到的结构化 taproot 审查。上周，他们[开始审阅][tr week 1] [bip-taproot][] 及相关概念的第一部分，并参与了与曾为 taproot 设计做出贡献的比特币专家的问答环节。

  有人提出的一个问题是：为什么 taproot 允许 v1 segwit scriptPubKey 使用少于或多于 34 字节的长度——34 字节正是 Pay-to-Taproot（P2TR）scriptPubKey 所需的长度。这看起来很奇怪，因为 [BIP141][] 的 v0 原生 segwit scriptPubKey 只允许恰好 22 字节（P2WPKH）或 34 字节（P2WSH）。回答是：限制更少，将来的软分叉就能为长度更短或更长的 v1 scriptPubKey 定义其他用途。而在那之前，如果 taproot 被采纳，那些较短和较长的 v1 scriptPubKey 仍可由任何人花费（与今天一样）。

  这引发了专家们的一场讨论：这种灵活性会如何与 bech32 地址编码算法中的一个问题相互作用——该问题在 5 月被[报告][bech32 length change]，最近又被[详细描述][bse bech32 extension]。按照 [BIP173][] 的规定，bech32 地址本应保证：地址被抄错时最多四个错误都能被检测出来，而含五个或更多错误的抄错地址，大约十亿个里也只有一个会漏检。遗憾的是，这些计算的前提是抄错后的地址与原始地址长度相同。如果抄错后的地址变长或变短，bech32 在极少数情况下甚至可能连一个字符的错误都检测不出来。

  对于现有的 P2WPKH 和 P2WSH bech32 地址，这极不可能成为问题，因为 v0 scriptPubKey 必须恰好为 22 或 34 字节这一限制，意味着抄错的 P2WPKH 地址要多出 12 字节，或抄错的 P2WSH 地址要少掉 12 字节；也就是说，用户得多输入或少输入约 19 个 bech32 字符——这几乎是不会犯的错误。<!-- 8 bits per byte * 12 bytes / 5 bits per bech32
  character = 19.2 bech32 characters -->

  但是，如果 P2TR 只针对 34 字节的 v1 scriptPubKey 定义，而 33 字节和 35 字节的 v1 scriptPubKey 仍然任何人都能花费，那么用户只要打错一个字符，就可能损失原本打算花费的全部资金。BIP173 和 taproot 提案的作者 Pieter Wuille 在 Bitcoin-Dev 邮件列表上[发帖][wuille bech32 workaround]，列出了一些应对该问题的选项，并征求大家更希望实现哪个选项的反馈。一个选项是让所有现有的 bech32 实现一律拒绝那些得不出 22 或 34 字节 scriptPubKey 的原生 segwit 地址；之后可以再开发升级版的 bech32，更好地检测字符被插入或删除的情况。

  本周对 taproot 的审查还引发了许多其他不那么重要的讨论，讨论记录可供有兴趣了解细节的读者查阅（[1][tr meet1]，[2][tr meet2]）。

  {:#x-only-pubkeys}
  在其他 schnorr/taproot 消息方面，Jonas Nick 发布了一篇[内容翔实的博客文章][x-only pubkeys]，介绍 [bip-schnorr][] 和 [bip-taproot][] 最近的一项重大变更：把序列化公钥的大小从 33 字节减到 32 字节，同时不降低安全性。此前关于这一优化的讨论，参见 Newsletter [#59][news59 proposed 32B pubkeys] 和 [#68][news68 taproot update]。

- **<!--possible-privacy-leak-in-the-ln-onion-format-->****LN 洋葱格式的潜在隐私泄露：** 正如 [BOLT4][] 所述，LN 使用 [Sphinx][] 协议在 LN 节点之间传递支付信息。Olaoluwa Osuntokun 本周在 Lightning-Dev 邮件列表上[发帖][osuntokun sphinx]，谈到[最近发表][breaking onion routing]的一项研究：Sphinx 最初的描述中存在缺陷，可能让目标节点“推断出路径[返回源节点]长度的下限”。<!-- quote from Osuntokun email -->
修复很简单：洋葱数据包中原本用零字节初始化的部分，改用随机字节即可。Osuntokun 创建了一个 [PR][lnd-onion]，在 LND 使用的洋葱库中实现了这一点，并为 BOLTs 仓库提交了一个[文档 PR][bolts #697]。其他实现也采纳了同样的变更（参见下面的 [C-Lightning 提交][news72 cl onion]）。

- **<!--ln-up-front-payments-->****LN 预付费：** 当前 LN 协议在支付尝试失败或被收款方拒绝时会把全部资金退还给付款方，因此路由节点只有在支付尝试成功时才有收入。然而，一些新应用正利用这种无成本的失败机制，通过 LN 发送数据，却不为自己占用的带宽付费。LN 设计者预料到会出现这种情况，此前也花时间考虑过如何给网络加上预付费——这类手续费无论支付尝试成功与否，都要付给路由节点。

  本周，Rusty Russell 在 Lightning-Dev 邮件列表上发起了一个关于预付费提案的[讨论帖][russell up-front]。Russell 提出了一个把手续费与哈希现金（hashcash）式的工作量证明结合起来的机制，试图防止节点利用额外的预付款信息来猜测路由长度。Anthony Towns 提出了一个不完整的[替代方案][towns up-front]，重点是用退款机制来管理支付金额。

  Joost Jager 认为，预付费只应作为最后手段，因为即便很小的额外手续费也可能让微支付变得不划算。他建议，可以用基于节点信誉的速率限制来应对浪费带宽的网络活动；他还建议，预付费的研究应优先解决流动性滥用问题——即攻击者在一定时间内占住某人的通道资金——因为该问题的解决方案也可能一并防止路由节点带宽被滥用。

  最终没有达成任何结论；截至本文撰写时，相关讨论仍在继续。

- **<!--proposed-bolt-for-ln-offers-->****为 LN offers 提议的新 BOLT：** Rusty Russell [发布][bolt offers]了一份新 BOLT 的草案文本，允许用户通过 LN 路由协议提交 offer 并接收发票。例如，Alice 可以订阅 Bob 提供的服务：每月她向 Bob 提交一个 offer 表示愿意付款，Bob 回复一张发票，Alice 支付该发票后，Bob 提供服务。

  对该提案的早期反馈认为，或许可以采用一种现成的、用于机器可读发票的语言，例如[通用商业语言][Universal Business Language]（UBL）。但也有人担心，完整实现 UBL 规范会给 LN 软件的开发者带来过重的负担。

- **<!--new-topic-index-on-optech-website-->****Optech 网站新增主题索引：** 我们[宣布][topics announcement]在 Optech 网站上新增了一个主题索引，让读者可以轻松找到我们在站内提到某一主题的所有位置。该索引上线时包含 40 个主题，我们希望在未来一年里把它扩充到约 100 个主题。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Bitcoin Core #16110][] 添加了对 Android 原生开发工具包（NDK）构建 Bitcoin Core（包括 GUI）的支持。与 [Android Bitcoin Core][]（ABCore）这类自行针对 Android NDK 构建 Bitcoin Core 二进制文件的独立项目不同，直接把支持加入 Bitcoin Core 项目本身可能简化测试。这也可能让今后的 PR 把 Android 构建纳入确定性生成的可执行文件集合，从而让用户更有把握自己运行的就是代码仓库中那份经过充分审查的同一份代码。

- [Bitcoin Core #16899][] 添加了一个 `dumptxoutset` RPC，以专为将来配合 assumeutxo 引导的节点使用而设计的序列化格式，把当前 UTXO 集的副本写入磁盘（参见 [Newsletter #41][news41 assumeutxo]）。此外，项目的贡献者工具中新增了一个脚本，可以把区块链回退到指定的区块高度，转储该高度上的 UTXO 集，然后正常地重新处理区块。每个区块可能要花上几秒，因此若要把高度回退到几千个区块之前，该脚本可能运行很久。

- [Bitcoin Core #17258][] 更新了 `listsinceblock` RPC，避免列出那些因另一笔交易花费了至少一个相同输入、且该交易在 RPC 调用所评估的区块之前就已被打包进区块链而无法确认的交易。

- [C-Lightning #3246][] 试图修复本周在 LN 邮件列表上描述的潜在数据泄露（参见[相关新闻][news72 sphinx]）。

- [LND #3442][] 让付款方能够手动为简单的多路径支付构建数据包——这类支付被拆成几部分，可以经由不同通道独立路由。它并不打算直接供用户使用，而是作为后续功能的基础，由后续功能添加多路径支付的其他相关能力。有关多路径支付的更多内容，参见 [Newsletter #27][news27 multipath]。

- [BIPs #857][] 修改了 [BIP157][]，把一次可请求的紧凑区块过滤器数量上限从 100 提高到 1,000。这撤销了去年的一个 [PR][BIPs #699]，该 PR 曾把上限从 1,000 降到 100。

- [BIPs #849][] 修改了 [BIP174][]，为部分签名比特币交易（PSBT）分配某些数据类型标识符，供非标准化（专有）应用使用。此外，PSBT 现在会带有一个版本号，以便识别对 PSBT 的向后不兼容变更；不含显式版本号的旧 PSBT，其隐式版本号为 0。这两项变更此前都已在 Bitcoin-Dev 邮件列表上讨论过（参见 [Newsletter #58][news58 psbts]）。

- [BIPs #856][] 添加了 [BIP179][]，该提案建议把现有术语“比特币地址”改名为“比特币发票地址”，或更简单的变体，如“发票地址”乃至“发票”。这一点此前已在 Bitcoin-Dev 邮件列表上[讨论过][bip179 genesis]。

- [BIPs #803][] 添加了 [BIP325][]，其中描述了 signet 协议：基于签名区块而非挖矿产生的区块来创建测试网，让 signet 的运营者能够控制出块速率以及区块链重组的频率和幅度（参见 [Newsletter #37][news37 signet]）。

- [BIPs #851][] 添加了 [BIP330][]，其中描述了交易公告的对账方法，计划作为 [erlay][] 协议的一部分使用（参见 [Newsletter #66][news66 erlay]）。如果节点软件采纳这一功能，它将成为大幅降低交易公告中继带宽开销的第一步——目前这类公告可能占用典型节点 40% 以上的带宽。

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
[cve-2017-18350]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017453.html
[breaking onion routing]: https://arxiv.org/abs/1910.13772
[bech32 length change]: https://github.com/sipa/bech32/issues/51
[lnd-onion]: https://github.com/lightningnetwork/lightning-onion/pull/40
[news72 cl onion]: #c-lightning-3246
[tr week 1]: https://github.com/ajtowns/taproot-review/blob/master/week-1.md
[why v1 flex]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-05-19.00.log.html#l-88
[wuille bech32 workaround]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017443.html
[tr meet1]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-05-19.00.log.html
[tr meet2]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-07-02.00.log.html
[russell up-front]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002275.html
[towns up-front]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002307.html
[bolt offers]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002276.html
[osuntokun sphinx]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002288.html
[universal business language]: https://en.wikipedia.org/wiki/Universal_Business_Language
[android bitcoin core]: https://github.com/greenaddress/abcore
[news72 sphinx]: #possible-privacy-leak-in-the-ln-onion-format
[bip179 genesis]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017369.html
[news52 avoid_reuse]: /zh/newsletters/2019/06/26/#bitcoin-core-13756
[dust flooding]: {{bse}}81509
[news59 proposed 32B pubkeys]: /zh/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[news68 taproot update]: /zh/newsletters/2019/10/16/#taproot-update
[news60 16248]: /zh/newsletters/2019/08/21/#bitcoin-core-16248
[bse bech32 extension]: {{bse}}91602
[topics announcement]: /en/topics-announcement/
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
