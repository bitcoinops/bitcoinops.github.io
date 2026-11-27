---
title: 'Bitcoin Optech Newsletter #74'
permalink: /zh/newsletters/2019/11/27/
name: 2019-11-27-newsletter-zh
slug: 2019-11-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 Bitcoin Core 新版本发布，介绍了比特币和闪电网络（LN）开发者邮件列表的一些动态，并描述了当前 schnorr/taproot 审查的最新进展。此外还有我们的固定栏目，包括 Bitcoin Stack Exchange 精选问答，以及热门比特币基础设施项目的值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-bitcoin-core-0-19-0-1-->****升级到 Bitcoin Core 0.19.0.1：** 我们鼓励用户升级到最新的[发布版本][bitcoin core 0.19.0.1]，该版本包含新功能和多项错误修复。这是影响 0.19.0 标记版本的一个 [bug][Bitcoin Core #17449] 被发现并修复之后，0.19 系列发布的第一个版本。

## 新闻

- **<!--bitcoin-core-0-19-released-->****Bitcoin Core 0.19 发布：** 最新的 [Bitcoin Core 发布版本][bitcoin core 0.19.0.1] 包含来自 100 多位贡献者的 1,000 多次提交，提供了多项用户可见的新功能、大量错误修复，以及对 P2P 网络处理等内部系统的多项改进。其中一些变更可能特别值得 Newsletter 读者关注：

  - **<!--cpfp-carve-out-->***CPFP 豁免（carve-out）：* 这一[新的内存池策略][topic cpfp carve out]能帮助双方合约协议（如当前的闪电网络）确保双方都能使用子为父付（CPFP）手续费追加（详见 [Newsletter #63][news63 carve-out]）。闪电网络开发者已有一个正在讨论的提案，说明他们将如何用这一功能简化承诺交易的手续费管理（详见 [Newsletter #70][news70 simple commits] 和 [Newsletter #71][news71 ln carve-out]）。

  - **<!--bip158-block-filters-rpc-only-->***BIP158 区块过滤器（仅限 RPC）：* 用户现在可以设置新的配置选项 `blockfilterindex`，让 Bitcoin Core 按 [BIP158][] 的规定生成[紧凑区块过滤器][topic compact block filters]。随后可用新的 RPC `getblockfilter` 获取每个区块对应的过滤器。把这些过滤器提供给兼容的轻量客户端，就能让它判断某个区块是否可能包含涉及自己密钥的交易（更多信息参见 [Newsletter #43][news43 core bip158]）。目前尚未合并的 [PR#16442][Bitcoin Core #16442] 旨在添加对相应 [BIP157][] 协议的支持，以便通过 P2P 网络与客户端分享这些过滤器。

  - **<!--deprecated-or-removed-features-->***弃用或移除的功能：* 对 [BIP70][] 支付协议、[BIP37][] P2P 协议布隆过滤器和 [BIP61][] P2P 协议拒绝消息的支持已默认禁用，从而消除了多个问题的源头（分别参见 [Newsletter #19][news19 bip70]、[Newsletter #57][news57 bip37] 和 [Newsletter #37][news37 bip61]）。支付协议和拒绝消息计划在约六个月后发布的下一个 Bitcoin Core 主要版本中彻底移除。

  - **<!--customizable-permissions-for-whitelisted-peers-->***可为白名单对等节点定制权限：* 在指定哪些对等节点或接口应列入白名单时，用户现在可以指定这些白名单对等节点能访问哪些特殊功能。此前，白名单对等节点不会被封禁，收到中继交易也更快。这些默认行为没有改变，但现在可以逐个对等节点地开关这些设置，也可以允许指定的白名单对等节点请求 BIP37 布隆过滤器——尽管这些过滤器默认对非白名单对等节点是禁用的。详情参见 [Newsletter #60][news60 16248]。

  - **<!--gui-improvements-->***图形界面改进：* 使用图形界面的用户现在可以通过 GUI 的 *文件* 菜单为多钱包模式创建新钱包（详见 [Newsletter #63][news63 new wallet]）。GUI 现在默认提供 [bech32][topic bech32] 比特币地址，但用户只需勾选生成地址按钮旁的复选框，就能轻松请求向后兼容的 P2SH-P2WPKH 地址（详见 [Newsletter #42][news42 core gui bech32]）。

  - **<!--optional-privacy-preserving-address-management-->***可选的隐私保护地址管理：* 新的 `avoid_reuse` 钱包标志可以通过新的 `setwalletflag` RPC 切换，启用后可以防止钱包花掉发送到曾用地址的比特币（详见 [Newsletter #52][news52 avoid_reuse]）。这可以防止某些基于区块链分析的隐私泄露，例如[粉尘洪水攻击][dust flooding]。

  关于值得注意的变更的完整列表、这些变更对应的 PR 链接，以及对节点运营者有用的其他信息，请参见 Bitcoin Core 项目的 [发布说明][notes 0.19.0]。

- **<!--new-lnd-mailing-list-and-new-host-of-existing-mailing-lists-->****新的 LND 邮件列表与现有邮件列表的新托管方：** 面向 LND 应用开发者的一个[新邮件列表][lnd engineering]已宣布成立，由 Google Groups 托管，Olaoluwa Osuntokun 在其中发表了[首帖][osuntokun lnd plans]，描述了 LND 下一个版本的短期目标。另外，现有的 [Bitcoin-Dev][] 和 [Lightning-Dev][] 邮件列表最近已把托管[迁移][togami ml update]到俄勒冈州立大学的 [Open Source Lab][osl]（OSL）——这是一家广受尊敬的组织，为众多开源项目提供托管。Optech 感谢 Warren Togami、Bryan Bishop 以及所有参与维护比特币众多开放沟通渠道的人；没有他们，这份 Newsletter 就不会存在。

- **<!--schnorr-taproot-updates-->****Schnorr/taproot 更新：** [taproot 审查小组][taproot review group]的参与者一直在继续审查比特币拟议的软分叉变更，并在 Freenode 网络上[有日志存档][tbr log]的 ##taproot-bip-review IRC 聊天室中提出并回答了许多有趣的问题。此外，一些参与者还在自行实现 BIP 的部分内容，包括为 libbitcoin 和 bcoin 完整验证节点所做的实现。

  本周还发布了两篇与多方 schnorr 签名安全性相关的博客文章。Blockstream 工程师 Jonas Nick [介绍][nick musig]了 [MuSig][] 多方签名方案，该方案旨在让 [bip-schnorr][] 的用户能把多个公钥聚合成单个公钥；之后，他们可以用彼此协作生成的单个签名对该公钥签名。Nick 描述了 MuSig 签名协议的三个步骤——交换随机数承诺、交换随机数，以及交换部分签名（随后把随机数和部分签名聚合起来，生成最终签名）。在速度至关重要的场合（例如创建 LN 通道承诺交易时），有些人可能希望在知道要用签名承诺哪笔交易之前，就先交换随机数承诺再交换随机数——但正如 Nick 简要解释的那样，由于 Wagner 算法，这样做并不安全。在每个参与者知道要签名的交易之前，唯一能安全共享的信息就是随机数承诺。（博客文章中没有提到、但在 IRC 上讨论过的是：Pieter Wuille 等人一直在研究一种基于零知识证明（ZKP）的构造，它有望减少交互轮数。）文章最后建议有兴趣的读者研读 [libsecp256k1-zkp][] 中的 MuSig 实现，该实现旨在帮助开发者安全地使用这一协议。

  受 Jonas Nick 在柏林闪电网络会议上就此主题所做演讲的启发，Adam Gibson 另外写了一篇[博客文章][gibson wagners]，用数学推导、直观分析和比特币爱好者可能觉得有趣的趣闻（例如 Wagner 的论文引用了 Adam Back 和 Wei Dai，而几年后中本聪也[做了同样的事][bitcoin.pdf]，只不过引用的是另一项工作），更详细地讲解了 Wagner 算法。任何有兴趣开发自己加密协议的人都应阅读这两篇文章：两者互为补充，内容并不重复。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--would-a-schnorr-pubkey-be-a-different-length-than-a-taproot-pubkey-like-p2wpkh-and-p2wsh-->**[schnorr 公钥的长度会与 taproot 公钥不同吗，比如 P2WPKH 和 P2WSH？]({{bse}}91531)
  Murch 解释说，与具有不同 P2WPKH 和 P2WSH 输出类型和长度的 segwit v0 不同，所有 segwit v1 Pay-to-Taproot (P2TR) 输出的长度始终相同。

- **<!--musig-signature-interactivity-->**[MuSig 签名交互性]({{bse}}91534)
  Justinmoon 询问为什么 [MuSig][] 签名总是需要交互，以及如何进行安全的离线交互式签名。Nickler 解释了 MuSig 签名涉及的每一轮流程，以及在签名过程中需要避免的一些陷阱。

- **<!--how-does-the-bech32-length-extension-mutation-weakness-work-->**[bech32 的长度扩展突变弱点是如何工作的？]({{bse}}91602)
  Jnewbery 询问为什么在地址最后一个 p 字符之前紧接着添加或删除 q 字符，有时会生成一个仍然有效的新 bech32 地址。Pieter Wuille 给出了一些代数细节，说明这种情况出现的概率远高于人们预期的、任何随机长度变化错误漏检的约十亿分之一。MCCCS 又借助 Bitcoin Core 中的一些相关代码给出了第二种解释。

- **<!--what-is-the-difference-between-bitcoin-policy-language-and-miniscript-->**[比特币策略语言与 Miniscript 之间的区别是什么？]({{bse}}91565)
  Pieter Wuille、James C. 和 sanket1729 解释了比特币脚本、策略语言（供人设计花费条件的工具）和 Miniscript（比特币脚本更结构化的表示，便于交流和分析）三者之间的关系。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Bitcoin Core #17265][] 和 [#17515][Bitcoin Core #17515] 完成了对 OpenSSL 依赖的移除。OpenSSL 自最初的 Bitcoin 0.1 版本起就一直在用，但它曾导致[共识漏洞][non-strict der]、[远程内存泄漏][heartbleed]（可能泄露私钥）、[其他 bug][cve-2014-3570] 和[性能低下][libsecp256k1 sig speedup]。

- [Bitcoin Core #16944][] 更新 GUI：当用户试图在一个已禁用私钥的仅观察（watch-only）钱包中创建交易时，GUI 会生成 [BIP174][] 部分签名比特币交易（PSBT），并自动把它复制到剪贴板。随后可以把该 PSBT 粘贴到其他应用中去签名（例如 [HWI][topic hwi]）。GUI 目前还没有提供专门的对话框，用来把签名后的 PSBT 导回并广播。

- [Bitcoin Core #17290][] 改变了一些场景下所用的选币（coin selection）算法，即用户指定使用某些输入，或要求从支付金额中扣除手续费时。这些场景现在使用 Bitcoin Core 的常规默认算法——分支定界（BnB）。BnB 的设计目标是通过尽量生成无找零交易，来最小化手续费并最大化隐私。

- [C-Lightning #3264][] 加入了若干针对 [LND #3728][] 的缓解措施，后者是 gossip 查询实现中的一个 bug。此变更还新增了两个便于测试和调试的命令行参数：`--hex` 和 `--features`。

- [C-Lightning #3274][] 让 `lightningd` 在检测到 `bitcoind` 的区块高度低于 `lightningd` 上次运行时的高度时拒绝启动。如果在 `lightningd` 运行期间发现高度变低，它只会等下去，直到看到更高的高度。区块链重组、区块链重建索引，或用户运行某些供开发测试的命令时，区块高度都可能下降。<!-- e.g.  invalidateblock --> 对 `lightningd` 来说，等 `bitcoind` 把这些情况处理好，比自己去绕过问题更简单也更安全。不过，如果 LN 用户确实想使用这条被截断的链，可以用 `--rescan` 参数启动 `lightningd`，让它重新处理区块链。<!-- yes, that parameter is for lightningd (not bitcoind); see test in this PR -->

- [Eclair #1221][] 新增了一个 `networkstats` API，返回从本地节点观察到的 LN 网络的各种信息，包括已知通道数量、已知 LN 节点数量、LN 节点容量（按百分位分组），以及各节点收取的手续费（同样按百分位分组）。

- [LND #3739][] 让用户能够指定在支付送达收款方之前，应由哪个节点作为路由上的最后一跳。与其他仍在推进的工作（例如 [LND #3736][]）结合，用户将能利用 LND 内置功能对自己的通道做再平衡（而不像现在这样需要借助外部工具）。

- [LND #3729][] 让生成精度为 millisatoshi 的发票成为可能。此前，LND 不会生成精度低于 1 聪的发票。

- [LND #3499][] 扩展了几个 RPC（例如 `listpayments` 和 `trackpayment`），以提供[多路径支付][topic multipath payments]的相关信息——这类支付可以拆成多个部分，经由不同路由发送。LND 目前尚未完全支持它们，但这个已合并的 PR 让日后再添加支持变得更容易。此外，以前发送的只有单个部分的支付会被转换为多路径支付所用的同一结构，但仍显示为只有一个部分。

{% include linkers/issues.md issues="17449,3499,3729,3739,1221,16442,17265,17515,16944,3264,3728,3274,17290,3736" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bitcoin core 0.19.0.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.0.1/
[notes 0.19.0]: https://bitcoincore.org/en/releases/0.19.0.1/
[news63 carve-out]: /zh/newsletters/2019/09/11/#bitcoin-core-16421
[news70 simple commits]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[news71 ln carve-out]: /zh/newsletters/2019/11/06/#continued-discussion-of-ln-anchor-outputs
[news43 core bip158]: /zh/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core
[news19 bip70]: /zh/newsletters/2018/10/30/#bitcoin-core-14451
[news57 bip37]: /zh/newsletters/2019/07/31/#bloom-filter-discussion
[news37 bip61]: /zh/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[news63 new wallet]: /zh/newsletters/2019/09/11/#bitcoin-core-15450
[news42 core gui bech32]: /zh/newsletters/2019/04/16/#bitcoin-core-15711
[news52 avoid_reuse]: /zh/newsletters/2019/06/26/#bitcoin-core-13756
[dust flooding]: {{bse}}81509
[news60 16248]: /zh/newsletters/2019/08/21/#bitcoin-core-16248
[togami ml update]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-11-21.html#l-23
[nick musig]: https://medium.com/blockstream/insecure-shortcuts-in-musig-2ad0d38a97da
[gibson wagners]: https://joinmarket.me/blog/blog/avoiding-wagnerian-tragedies/
[news55 tlv]: /zh/newsletters/2019/07/17/#bolts-607
[lnd engineering]: https://groups.google.com/a/lightning.engineering/forum/#!forum/lnd
[osuntokun lnd plans]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/GtcrXNhTLqQ
[bitcoin-dev]: https://gnusha.org/url/https://lists.linuxfoundation.org/mailman/listinfo/bitcoin-dev
[lightning-dev]: https://gnusha.org/url/https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[osl]: https://osuosl.org/
[taproot review group]: https://github.com/ajtowns/taproot-review
[tbr log]: http://www.erisian.com.au/taproot-bip-review/
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[wagner's paper]: https://people.eecs.berkeley.edu/~daw/papers/genbday-long.ps
[non-strict der]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation
[musig]: https://eprint.iacr.org/2018/068
