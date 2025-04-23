---
title: 'Bitcoin Optech Newsletter #117'
permalink: /zh/newsletters/2020/09/30/
name: 2020-09-30-newsletter-zh
slug: 2020-09-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个引发对安全系统安全性质疑的编译器错误，并解释了一种可以更高效地验证比特币中的 ECDSA 签名的技术。此外，还包含 Bitcoin Stack Exchange 上的精选问答、新版本和候选发布的公告，以及对流行的比特币基础设施软件值得注意的更改摘要。

## 行动项

*本周无。*

## 新闻

- **<!--discussion-about-compiler-bugs-->****关于编译器错误的讨论：** 上周，由 Russell O'Connor 为 libsecp256k1 编写的一个[测试][oconnor test]因 GNU Compiler Collection (GCC) 内置标准 C 库的 `memcmp`（内存比较）函数的[错误][gcc bug]而失败。此函数接受两块内存区域，将其视为整数值并返回第一块区域是否小于、等于或大于第二块区域的结果。这是一个常用的底层函数。程序几乎从不设计为验证此类基本操作是否正确执行，因此这种类型的错误很容易导致程序生成错误结果。这些错误结果可能出现在代码经过精心审查、严格测试、正式验证并以最大心力构建的情况下。对密码学或共识代码执行中的单一错误结果可能会对代码的用户或依赖于与代码用户保持共识的任何人造成严重后果。

  潜在问题不仅影响到使用 C 语言编写并使用 GCC 编译的软件，还影响任何依赖于使用受影响版本 GCC 编译的软件或库的软件。包括使用 GCC 构建的编译器或解释器的其他语言编写的程序。尽管问题的全部范围尚不明确，Russell O'Connor 已对整个 Linux 系统运行[分析][oconnor blog]，并发现只有少数实例因该错误导致错误编译，表明此错误导致代码错误编译的情况较为罕见。

  已在 [libsecp256k1][libsecp256k1 #823] 和 [Bitcoin Core][bitcoin core #20005] 仓库中创建了问题，以发现并缓解此错误的任何影响。该主题还在每周的 Bitcoin Core 开发者会议中[讨论][irc memcmp]。

  截至撰写本文时，开发者已经测试了 Bitcoin Core 0.20.1，未发现任何直接问题。如在其他软件中发现任何值得注意的问题，我们将在未来的 Newsletter 中提供更新。

- **<!--us-patent-7-110-538-has-expired-->****美国专利 7,110,538 已过期：** 比特币交易使用 [ECDSA][]（椭圆曲线数字签名算法）来保证安全性。验证签名涉及在椭圆曲线上进行点乘操作。通常，每个交易输入都需要一个或多个签名验证，这意味着同步比特币区块链可能需要进行数百万次此类椭圆曲线点乘操作。任何能提高点乘效率的技术都可能显著加快 Bitcoin Core 的初始同步速度。

  在 [2011 年的一篇 bitcointalk 帖子][finney endomorphism]中，Hal Finney 描述了一种 Gallant、Lambert 和 Vanstone (GLV) 提出的使用曲线上[自同态映射][endomorphism]高效计算椭圆曲线点乘的方法。通过使用该 GLV 自同态映射，可以将点乘分解为两个部分，并同时计算以得出解。这样可以减少多达 33% 的高成本计算次数。Finney 编写了 GLV 自同态映射的概念验证实现，并声称其使签名验证速度提升了约 25%。

  Pieter Wuille 独立地在 [libsecp256k1][libsecp] 库中实现了 GLV 自同态映射算法，该库用于在 Bitcoin Core 中验证签名。然而，由于该算法受[美国专利 7,110,538][endomorphism patent] 的约束，为避免任何法律上的不确定性，此实现先前并未向用户分发。9 月 25 日，该专利到期，消除了法律不确定性。[libsecp256k1 仓库中已提出拉取请求][endomorphism PR]，以始终使用 GLV 自同态映射算法，预计这将显著减少 Bitcoin Core 的初始同步时间。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地之一——或者当我们有空闲时间时，会帮助好奇或困惑的用户。在这一月度特色中，我们精选了自上次更新以来一些票数较高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-history-of-nlocktime-in-bitcoin-core-->**[Bitcoin Core 中 nLockTime 的历史是什么？]({{bse}}90229) Martin Harrigan 在查看 Bitcoin Core 的早期版本源代码时，询问是高度基础的还是基于时间的 nLockTime 特性先添加，以及其对分叉的影响。Pieter Wuille 和 David A. Harding 确认首先是基于高度的逻辑，并提供了一些有趣的历史见解。

- **<!--is-there-any-other-p2p-protocol-in-use-besides-a-gossip-protocol-->**[除了“gossip 协议”，是否还有其他 P2P 协议在使用？]({{bse}}99131) Murch 概述了比特币生态系统中使用的不同通信协议，包括[比特币的 P2P 协议][bitcoin p2p messages]、FIBRE 和 stratum 等挖矿协议、LN 相关协议，以及[payjoin][topic payjoin] 等多方协调协议。

- **<!--why-do-anchor-outputs-need-to-enforce-an-nsequence-of-1-->**[为什么锚定输出需要强制设置 nSequence 为 1？]({{bse}}98848) Dalit Sairio 询问关于[锚定输出][topic anchor outputs]以及 LN 脚本中 `OP_CHECKSEQUENCEVERIFY` (CSV) 的必要性。用户 darosior 描述了[CPFP 分离][topic cpfp carve out]的相关考量，以及为何需要 1 个区块的延迟。

## 发布与候选发布

*流行比特币基础设施项目的新版本和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.11.1-beta.rc4][lnd 0.11.1-beta] 是一个小版本的候选发布。其发布说明总结了更改内容，包括“一些可靠性改进、一些 macaroon [认证令牌]升级，以及使我们版本的[锚定承诺][topic anchor outputs]符合规范的更改。”

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #18267][] 和 [#19993][Bitcoin Core #19993] 添加了对 [signet][topic signet] 的支持。如果 Bitcoin Core 使用 `-signet`（或 `-chain=signet`）启动，它将连接到默认的 signet 或通过 `-signetchallenge` 和 `-signetseednode` 参数定义的 signet。

- [Bitcoin Core #19572][] 添加了一个新的“sequence”[ZMQ][bitcoin ZMQ] 主题，用于在区块连接/断开和交易被添加/移除到内存池时通知订阅者。交易添加/移除通知消息包含“内存池序列号”，订阅者可以使用该序列号确定这些添加/移除的顺序，并与 `getrawmempool` RPC 结果进行交叉引用，该结果现在也包含该新字段。

- [C-Lightning #4068][] 和 [#4078][C-Lightning #4078] 更新了 C-Lightning 的 signet 实现，使其兼容 [BIP325][] 中最终选择的参数和 Bitcoin Core 的默认 signet。

- [Eclair #1501][] 增加了使用[锚定输出][topic anchor outputs]单边关闭通道的支持，完成了 Eclair 对此 LN 协议新特性的基本实现。根据 PR 说明，Eclair 仍需添加用于费用提升承诺交易和 HTLC 的必要功能，但这将在接下来完成。

- [LND #4576][] 是计划为 LND 的[瞭望塔][topic watchtowers]实现添加锚定输出支持的一系列 PR 中的第一个。该 PR 特别添加了一个标志，指示在关闭的通道中使用了锚定输出，以便瞭望塔能够做出相应响应。PR 说明称，“[这些]更改无需修改加密有效负载格式。锚定负载的大小相等，并包含与传统负载完全相同的见证信息，仅需对重构逻辑进行轻微调整。”

- [BIPs #907][] 更新了 [BIP155][] 中对[版本 2 `addr` 消息][topic addr v2]的规范，以允许最长达 512 字节的地址，并添加了一条新的 `sendaddrv2` 消息，节点可以使用该消息表示希望接收 `addrv2` 消息。

{% include references.md %}
{% include linkers/issues.md issues="18267,19993,19572,4068,4078,1501,4576,907,823,20005" %}
[lnd 0.11.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.1-beta.rc4
[oconnor test]: https://github.com/bitcoin-core/secp256k1/pull/822#issuecomment-696790289
[gcc bug]: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=95189
[irc memcmp]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2020/bitcoin-core-dev.2020-09-24-19.02.log.html#l-18
[oconnor blog]: http://r6.ca/blog/20200929T023701Z.html
[ecdsa]: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
[finney endomorphism]: https://bitcointalk.org/index.php?topic=3238.msg45565#msg45565
[endomorphism]: https://en.wikipedia.org/wiki/Endomorphism
[endomorphism patent]: https://patents.google.com/patent/US7110538B2/en
[libsecp]: https://github.com/bitcoin-core/secp256k1
[endomorphism pr]: https://github.com/bitcoin-core/secp256k1/pull/826
[bitcoin p2p messages]: https://developer.bitcoin.org/reference/p2p_networking.html
[bitcoin ZMQ]: https://github.com/bitcoin/bitcoin/blob/master/doc/zmq.md
