---
title: 'Bitcoin Optech Newsletter #74'
permalink: /zh/newsletters/2019/11/27/
name: 2019-11-27-newsletter-zh
slug: 2019-11-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
这周的 Newsletter 宣布 Bitcoin Core 新版本的发布，提供了关于比特币和闪电网络（LN）开发者邮件列表的一些更新，并描述了当前 schnorr/taproot 评审的最新进展。此外，还有我们常规的部分，包括 Bitcoin Stack Exchange 精选问答和对流行比特币基础设施项目的值得注意的更改。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--upgrade-to-bitcoin-core-0-19-0-1-->****升级到 Bitcoin Core 0.19.0.1：** 鼓励用户升级到最新的 [release][bitcoin core 0.19.0.1]，该版本包含新特性和多个漏洞修复。这是 0.19 系列的第一个发布版本，之前发现并修复了一个影响 0.19.0 标记版本的 [bug][Bitcoin Core #17449]。

## 新闻

- **<!--bitcoin-core-0-19-released-->****Bitcoin Core 0.19 发布：** 新版包含来自 100 多位贡献者的超过 1000 次提交，最新的 [Bitcoin Core release][bitcoin core 0.19.0.1] 提供了多个用户可见的特性、众多的漏洞修复以及多个对内部系统（如 P2P 网络处理）的改进。一些可能对 Newsletter 读者特别感兴趣的更改包括：

  - **<!--cpfp-carve-out-->***CPFP carve-out：* 这一[新内存池政策][topic cpfp carve out]帮助双方合同协议（如当前的闪电网络）确保双方能够使用 Child-Pays-For-Parent (CPFP) 的费用增加功能（详见 [Newsletter #63][news63 carve-out]）。闪电网络开发者已经在讨论如何利用这一特性简化承诺交易的费用管理（详见 [Newsletter #70][news70 simple commits] 和 [Newsletter #71][news71 ln carve-out]）。

  - **<!--bip158-block-filters-rpc-only-->***BIP158 区块过滤器（仅限 RPC）：* 如果用户希望 Bitcoin Core 生成[致密区块过滤器][topic compact block filters]，可以设置新的配置选项 `blockfilterindex`，按照 [BIP158][] 的要求生成每个区块的过滤器。然后可以使用新的 RPC `getblockfilter` 检索每个区块的过滤器。过滤器可以提供给兼容的轻量客户端，以帮助其确定某个区块是否可能包含与其密钥相关的交易（有关更多信息，详见 [Newsletter #43][news43 core bip158]）。当前正在开放的 [PR#16442][Bitcoin Core #16442] 旨在为相应的 [BIP157][] 协议添加支持，以便在 P2P 网络上与客户端共享这些过滤器。

  - **<!--deprecated-or-removed-features-->***弃用或移除的功能：* 默认情况下，已禁用对 [BIP70][] 支付协议、[BIP37][] P2P 协议布隆过滤器和 [BIP61][] P2P 协议拒绝消息的支持，从而消除了各种问题的源头（分别详见 [Newsletter #19][news19 bip70]、[Newsletter #57][news57 bip37] 和 [Newsletter #37][news37 bip61]）。支付协议和拒绝消息计划在下一个主要的 Bitcoin Core 版本中彻底移除，预计约在六个月后。

  - **<!--customizable-permissions-for-whitelisted-peers-->***可定制的白名单对等节点权限：* 在指定哪些对等节点或接口应被列入白名单时，用户现在可以指定这些白名单对等节点可以访问的特殊功能。之前，白名单对等节点不会被禁止，并且接收转发交易的速度更快。这些默认设置没有改变，但现在可以按每个对等节点的基础切换这些设置，或允许指定的白名单对等节点请求 BIP37 布隆过滤器，尽管默认情况下对非白名单对等节点禁用。有关详细信息，参见 [Newsletter #60][news60 16248]。

  - **<!--gui-improvements-->***图形用户界面改进：* 图形用户现在可以通过 GUI 的 *文件* 菜单为多钱包模式创建新钱包（详见 [Newsletter #63][news63 new wallet]）。GUI 现在默认为用户提供 [bech32][topic bech32] 比特币地址，但用户可以轻松请求向后兼容的 P2SH-P2WPKH 地址，只需在生成地址的按钮旁边勾选一个复选框即可（详见 [Newsletter #42][news42 core gui bech32]）。

  - **<!--optional-privacy-preserving-address-management-->***可选的隐私保护地址管理：* 可以通过新的 `avoid_reuse` 钱包标志防止钱包支出先前使用过的地址收到的比特币，该标志可以通过新的 `setwalletflag` RPC 切换（详见 [Newsletter #52][news52 avoid_reuse]）。这可以防止某些基于区块链分析的隐私泄露，例如 [dust flooding][]。

  有关值得注意的更改的完整列表、这些更改的 PR 链接以及对节点操作员有用的其他信息，请参见 Bitcoin Core 项目的 [release notes][notes 0.19.0]。

- **<!--new-lnd-mailing-list-and-new-host-of-existing-mailing-lists-->****新的 LND 邮件列表和现有邮件列表的新主机：** 宣布了一个由 Google Groups 托管的[新邮件列表][lnd engineering]，面向 LND 应用开发者，并由 Olaoluwa Osuntokun 发布了[初始帖子][osuntokun lnd plans]，描述了 LND 下一个版本的短期目标。此外，现有的 [Bitcoin-Dev][] 和 [Lightning-Dev][] 邮件列表的托管最近已转移到俄勒冈州立大学的 [Open Source Lab][osl] (OSL)，这是一个备受尊敬的组织，为多种开源项目提供托管。Optech 对 Warren Togami、Bryan Bishop 以及其他所有参与维护比特币众多开放通信渠道的人表示感谢，没有他们，这份 Newsletter 将无法存在。

- **<!--schnorr-taproot-updates-->****Schnorr/Taproot 更新：** [taproot review group][] 的参与者继续评审对比特币的提议软分叉更改，许多有趣的问题在 Freenode 网络的 [logged][tbr log] ##taproot-bip-review IRC 聊天室中被提出和回答。此外，一些参与者正在编写 BIPs 部分的自己的实现，包括 libbitcoin 和 bcoin 完整验证节点。

  本周还发布了两篇与多方 schnorr 签名安全性相关的博文。Blockstream 工程师 Jonas Nick [描述][nick musig]了旨在允许 [bip-schnorr][] 用户将多个公钥聚合为单个公钥的 [MuSig][] 多方签名方案。他们可以随后使用在自己之间协作生成的单个签名为该公钥签名。Nick 描述了 MuSig 签名协议的三个步骤——非对称承诺的交换、非对称数的交换和部分签名的交换（其中非对称数和部分签名随后被聚合以生成最终签名）。为了在速度至关重要时节省时间（例如在创建 LN 通道承诺交易时），一些人可能希望在知道想要承诺的交易之前先交换非对称承诺和非对称数——但由于 Wagner 算法，这样做是不安全的，正如 Nick 简要解释的那样。每个参与者知道要签名的交易之前，唯一可以安全共享的信息是非对称承诺。（博客中没有提到，但在 IRC 中讨论的是，Pieter Wuille 和其他人一直在研究基于零知识证明（ZKP）的构造，这可能允许减少交互。）博客的结尾建议感兴趣的读者查看 [libsecp256k1-zkp][] 中的 MuSig 实现，以帮助开发人员安全使用该协议。

  受到 Jonas Nick 在柏林闪电网络会议上对这一主题的演讲的影响，Adam Gibson 撰写了另一篇[博客帖子][gibson wagners]，更详细地描述了 Wagner 算法，结合了数学、直观分析和比特币爱好者可能感兴趣的主题信息（例如 Wagner 的论文中提到 Adam Back 和 Wei Dai 的趣闻，早于中本聪[同样][bitcoin.pdf]的引用，尽管是出于不同的工作）。任何有兴趣开发自己加密协议的人都建议阅读这两篇帖子，因为它们互为补充，而不重复相关主题。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或在我们有空闲时间时帮助好奇或困惑的用户。在这个每月的专栏中，我们突出自上次更新以来发布的一些高投票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--would-a-schnorr-pubkey-be-a-different-length-than-a-taproot-pubkey-like-p2wpkh-and-p2wsh-->**[schnorr 公钥的长度会与 taproot 公钥不同吗，比如 P2WPKH 和 P2WSH？]({{bse}}91531)
  Murch 解释说，与具有不同 P2WPKH 和 P2WSH 输出类型和长度的 segwit v0 不同，所有 segwit v1 Pay-to-Taproot (P2TR) 输出的长度始终相同。

- **<!--musig-signature-interactivity-->**[MuSig 签名交互性]({{bse}}91534)
  Justinmoon 询问为什么 [MuSig][] 签名总是需要交互以及关于安全的离线交互签名。Nickler 解释了 MuSig 签名中每一轮的过程以及在签名时需要避免的一些陷阱。

- **<!--how-does-the-bech32-length-extension-mutation-weakness-work-->**[bech32 的长度扩展突变弱点是如何工作的？]({{bse}}91602)
  Jnewbery 询问为什么在地址最后一个 p 字符之前立即添加或删除 q 字符有时会生成一个有效的新 bech32 地址。Pieter Wuille 提供了一些代数细节，说明这一问题比任何随机长度变化错误未被发现的概率（大约 1/十亿）更容易发生。MCCCS 提供了一个第二种解释，使用了一些来自 Bitcoin Core 的适用代码。

- **<!--what-is-the-difference-between-bitcoin-policy-language-and-miniscript-->**[比特币政策语言与 Miniscript 之间的区别是什么？]({{bse}}91565)
  Pieter Wuille、James C. 和 sanket1729 解释了比特币脚本、政策语言（用于人类设计支出条件的工具）和 miniscript（用于通信和分析的比特币脚本的更结构化表示）之间的关系。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的显著更改。*

- [Bitcoin Core #17265][] 和 [#17515][Bitcoin Core #17515] 完成了对 OpenSSL 依赖的移除，自比特币 0.1 版本以来一直使用，但造成了[共识漏洞][non-strict der]、[远程内存泄漏][heartbleed]（可能的私钥泄漏）、[其他错误][cve-2014-3570]和[性能差][libsecp256k1 sig speedup]。

- [Bitcoin Core #16944][] 更新 GUI 以生成 [BIP174][] 部分签名比特币交易 (PSBT)，如果用户尝试在禁用私钥的观察钱包中创建交易，系统会自动将其复制到剪贴板。PSBT 可以复制到其他应用程序进行签名（例如 [HWI][topic hwi]）。GUI 目前尚未提供特定对话框以将签名后的 PSBT 复制回来以进行广播。

- [Bitcoin Core #17290][] 更改用户请求某些输入或要求从支付金额中选择费用时使用的币选择算法。现在使用 Bitcoin Core 的正常默认算法分支和边界（BnB）。BnB 被设计为通过优化创建无零钱交易来最小化费用并最大化隐私。

- [C-Lightning #3264][] 包含了多个针对 [LND #3728][] 的缓解措施，这是在 gossip 查询实现中的一个错误。此更改还添加了两个新的命令行参数，方便测试和调试，分别为 `--hex` 和 `--features`。

- [C-Lightning #3274][] 导致 `lightningd` 如果检测到 `bitcoind` 的区块高度低于上次运行时的高度，则拒绝启动。如果在 `lightningd` 运行时检测到较低高度，它将等待直到看到更高的高度。区块高度可能在区块链重组、区块链重新索引期间降低，或用户运行某些开发测试命令时降低。对于 `lightningd` 来说，等待这些情况由 `bitcoind` 解决比尝试绕过问题要更容易和安全。然而，如果 LN 用户真的想使用被截断的链，他们可以使用 `--rescan` 参数重新处理区块链。

- [Eclair #1221][] 添加了一个 `networkstats` API，返回本地节点观察到的闪电网络的各种信息，包括已知通道的数量、已知 LN 节点的数量、LN 节点的容量（按百分位数分组）以及节点收取的费用（也按百分位数分组）。

- [LND #3739][] 使用户能够指定在支付送达接收者之前，哪个节点应成为最后一跳。结合其他仍在待处理的工作，如 [LND #3736][]，这将使用户能够使用内置的 LND 功能对其通道进行重新平衡（而不是目前需要外部工具）。

- [LND #3729][] 使生成具有毫微比特（millisatoshi）精度的发票成为可能。以前，LND 不会生成具有亚比特（sub-satoshi）精度的发票。

- [LND #3499][] 扩展了几个 RPC，例如 `listpayments` 和 `trackpayment`，以提供有关[多路径支付][topic multipath payments]的信息，这些支付可以分成多个部分通过不同路径发送。虽然 LND 目前尚未完全支持这些，但此合并的 PR 使后续添加支持变得更容易。此外，之前发送的仅包含一部分的支付被转换为用于多路径支付的相同结构，但它们仅显示为一部分。

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
[bitcoin-dev]: https://lists.linuxfoundation.org/mailman/listinfo/bitcoin-dev
[lightning-dev]: https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[osl]: https://osuosl.org/
[taproot review group]: https://github.com/ajtowns/taproot-review
[tbr log]: http://www.erisian.com.au/taproot-bip-review/
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[wagner's paper]: https://people.eecs.berkeley.edu/~daw/papers/genbday-long.ps
[non-strict der]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation
[musig]: https://eprint.iacr.org/2018/068
