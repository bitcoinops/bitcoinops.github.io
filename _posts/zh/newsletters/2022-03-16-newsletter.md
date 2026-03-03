---
title: 'Bitcoin Optech Newsletter #191'
permalink: /zh/newsletters/2022/03/16/
name: 2022-03-16-newsletter-zh
slug: 2022-03-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了扩展或替换 Bitcoin Script 的新 opcode 的提案，总结了最近关于改进 RBF 政策的讨论，并链接了对 `OP_CHECKTEMPLATEVERIFY` opcode 持续进行的工作。此外，还包括我们的常规版块，介绍热门比特币基础设施项目的值得注意的变更。

## 新闻

- **<!--extensions-and-alternatives-to-bitcoin-script-->****对 Bitcoin Script 的扩展与替代：**
  几位开发者在 Bitcoin-Dev 邮件列表上讨论了改进 Bitcoin 的 Script 和 [tapscript][topic tapscript] 语言的想法；收款方通过这些脚本语言来指定其日后如何证明自己已授权花费相应的比特币。

  - **<!--looping-folding-->***循环（折叠）：* 开发者 ZmnSCPxj [描述][zmnscpxj fold]了一条名为 `OP_FOLD` 的 opcode 提案，用以在 Bitcoin Script 中实现类似循环的行为。他提出了一系列约束，确保循环不会消耗超出 Bitcoin Script 与 tapscript 目前允许的 CPU 或内存——同时通过消除脚本中的重复代码来减少带宽占用。

  - **<!--using-chia-lisp-->***使用 Chia Lisp：* Anthony Towns [发布][towns btc-lisp]了一项提议，计划为 Bitcoin 引入一种基于 [Chia Lisp][]（Chia 山寨币所使用的 Lisp 方言）的变体。这将成为传统 Bitcoin Script 与 tapscript 的一种全然不同的替代方案，并可带来与先前提出的 [Simplicity][topic simplicity] 类似的“重新起步”优势。Towns 提出的替代方案——“Binary Tree Coded Script” 或 “btc-script”——据称比 Simplicity 更易于理解和使用，但可能更难以进行形式化验证。

- **<!--ideas-for-improving-rbf-policy-->****改进 RBF 政策的想法：**
  Gloria Zhao [发布][zhao rbf]了在伦敦举行的 [CoreDev.Tech][] 会议以及相关讨论中，关于 Replace-by-Fee（RBF）政策的总结。主要观点是尝试限制用于转发交易及其替代交易的最大资源消耗，例如在特定时间窗口内限制可转发的相关交易数量。

  Zhao 还在另一份 [gist][daftuar limits] 中概述了允许交易自行建议其子孙交易限制的讨论。例如，一笔交易可以建议将其及其子孙在内存池中可占用的最大空间限制为 1,000 vbytes，而非默认的 100,000 vbytes。这样可降低诚实方在应对最坏情况下的[交易固定][topic transaction pinning]攻击时需要花费的成本。

  此外，Zhao 正寻求对一套算法的反馈，该算法用于在当前内存池状态下计算一笔交易对矿工的价值，从而使节点软件在是否接受替代交易的决策上更加灵活。

- **<!--continued-ctv-discussion-->****持续的 CTV 讨论：**
  如 [Newsletter #183][news183 ctv meeting] 所述，围绕提议的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）opcode 的会议仍在继续，Jeremy Rubin 提供了会议摘要：[1][news183 ctv meeting]、[2][ctv2]、[3][ctv3]、[4][ctv4]、[5][ctv5]。此外，上周 James O'Beirne [发布][obeirne vault]了基于 CTV 的[保险库][topic vaults]的代码和设计文档。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #24198][] 扩展了 `listsinceblock`、`listtransactions` 与 `gettransaction` 这三个 RPC，新增 `wtxid` 字段，用于包含每笔交易的见证交易标识符（Witness Transaction Identifier），该标识符在 [BIP141][] 中进行了定义。

- [Bitcoin Core #24043][Bitcoin Core #24043] 新增 `multi_a` 与 `sortedmulti_a` [描述符][topic descriptors]，可使用 [tapscript][topic tapscript] 的 `OP_CHECKSIGADD` opcode 来创建支出授权策略，而非旧版 Script 中的 `OP_CHECKMULTISIG` 与 `OP_CHECKMULTISIGVERIFY`。更多背景可参阅 [Newsletter #46][news46 csa] 中关于 tapscript 这一特性的介绍。

- [Bitcoin Core #24304][Bitcoin Core #24304] 添加了新的演示可执行文件 `bitcoin-chainstate`。该程序接受一个 Bitcoin Core 数据目录与一个区块作为输入，对区块进行验证并将其写入数据目录。虽然该工具本身用处有限，但它为 [libbitcoinkernel][bitcoin core #24303] 项目奠定了基础，后续可为其他项目提供与 Bitcoin Core 完全一致的区块和交易验证功能库。

- [C-Lightning #5068][C-Lightning #5068] 将 C-Lightning 每天为单个节点中继的 [BOLT7][] `node_announcement` 消息最小数量从 1 条提升至 2 条，以减轻节点更换 IP 地址或因维护而短暂离线所带来的一些问题。

- [BIPs #1269][BIPs #1269] 将 [BIP326][] 指派给一项建议：即便协议不需要，依然为 [taproot][topic taproot] 交易设置 nSequence，以便在需要共识强制的 [BIP68][] nSequence 值时提高隐私性。BIP326 还描述了如何利用 nSequence 为当前通过交易 locktime 字段实现的[反手续费抢先攻击][topic fee sniping]保护提供一种替代方案。关于最初的邮件列表提案，可参阅 [Newsletter #153][news153 nseq]。



{% include references.md %}
{% include linkers/issues.md v=1 issues="24198,24043,24304,24303,5068,1269" %}
[news46 csa]: /zh/newsletters/2019/05/14/#new-script-based-multisig-semantics
[zmnscpxj fold]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/020021.html
[towns btc-lisp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020036.html
[lisp]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[chia lisp]: https://chialisp.com/
[zhao rbf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020095.html
[daftuar limits]: https://gist.github.com/glozow/25d9662c52453bd08b4b4b1d3783b9ff?permalink_comment_id=4058140#gistcomment-4058140
[news183 ctv meeting]: /zh/newsletters/2022/01/19/#irc-meeting
[ctv2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019855.html
[ctv3]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019874.html
[ctv4]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019974.html
[ctv5]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020086.html
[obeirne vault]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020067.html
[coredev.tech]: https://coredev.tech/
[news153 nseq]: /zh/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions
