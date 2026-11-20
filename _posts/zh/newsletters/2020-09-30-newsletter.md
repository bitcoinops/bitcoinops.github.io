---
title: 'Bitcoin Optech Newsletter #117'
permalink: /zh/newsletters/2020/09/30/
name: 2020-09-30-newsletter-zh
slug: 2020-09-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一个动摇安全系统可信度的编译器缺陷，并解释了一种可更高效验证比特币 ECDSA 签名的技术。此外，还包括 Bitcoin Stack Exchange 精选问答、新版本与候选发布公告，以及热门比特币基础设施软件值得注意的变更摘要。

## 行动项

*本周无。*

## 新闻

- **<!--discussion-about-compiler-bugs-->****关于编译器缺陷的讨论：** 上周，Russell O'Connor 为 libsecp256k1 编写的一个[测试][oconnor test]因 GNU Compiler Collection（GCC）内置标准 C 库的 `memcmp`（内存比较）函数的[缺陷][gcc bug]而失败。该函数接收两块内存区域，把它们当作整数，返回第一块区域小于、等于还是大于第二块区域。这是一个常用的底层函数。程序几乎从不会去验证这类基本操作是否正确执行，因此此类缺陷很容易让程序产生错误结果。即使程序代码经过精心审查、严格测试、形式化验证，并以最大心力构建，这些错误结果仍可能出现。在密码学或共识代码的执行中，哪怕只出现一个错误结果，也可能给该代码的用户，以及任何需要与该代码用户保持共识的人，带来严重后果。

  潜在问题不仅影响用 C 语言编写、由 GCC 编译的软件，也影响任何依赖“用受影响版本 GCC 编译的软件或库”的软件；还包括那些编译器或解释器本身由 GCC 构建的其他语言程序。尽管问题的完整范围仍不清楚，Russell O'Connor 已对整个 Linux 系统[运行分析][oconnor blog]，只发现少数几处因该缺陷而被错误编译，说明这种情况相当罕见。

  已在 [libsecp256k1][libsecp256k1 #823] 和 [Bitcoin Core][bitcoin core #20005] 仓库提交 issue，以发现并缓解该缺陷的影响。该问题也在每周的 Bitcoin Core 开发者会议上[讨论][irc memcmp]过。

  截至撰写本文时，开发者已经测试了 Bitcoin Core 0.20.1，未发现任何直接问题。如在其他软件中发现任何值得注意的问题，我们将在未来的 Newsletter 中提供更新。

- **<!--us-patent-7-110-538-has-expired-->****美国专利 7,110,538 已到期：** 比特币交易使用 [ECDSA][]（椭圆曲线数字签名算法）保障安全。验证签名需要把椭圆曲线上的点与标量相乘。通常，每个交易输入都需要一次或多次签名验证，这意味着同步比特币区块链可能需要进行数百万次这种椭圆曲线点乘运算。因此，任何能提高点乘效率的技术，都有可能显著加快 Bitcoin Core 的初始同步。

  在 [2011 年的一篇 bitcointalk 帖子][finney endomorphism]中，Hal Finney 介绍了 Gallant、Lambert 和 Vanstone（GLV）提出的一种方法：利用曲线上的[自同态][endomorphism]来高效计算椭圆曲线点乘（自同态是从曲线到自身、并保持点之间所有关系的映射）。借助这种 GLV 自同态，可以把点乘拆成两部分并行计算，从而得到结果。这样做最多能减少 33% 的昂贵运算。Finney 为 GLV 自同态编写了概念验证实现，并声称它把签名验证速度提升了约 25%。

  Pieter Wuille 另外在 [libsecp256k1][libsecp] 库中实现了 GLV 自同态算法，该库用于在 Bitcoin Core 中验证签名。但该算法受[美国专利 7,110,538][endomorphism patent] 阻碍；为避免任何法律上的不确定性，这一实现此前并未分发给用户。9 月 25 日专利到期，这一法律障碍随之消失。[libsecp256k1 仓库已提交拉取请求][endomorphism PR]，准备改为始终使用 GLV 自同态算法，预计会显著缩短 Bitcoin Core 的初始同步时间。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-history-of-nlocktime-in-bitcoin-core-->**[Bitcoin Core 中 nLockTime 的历史是什么？]({{bse}}90229) Martin Harrigan 在查阅 Bitcoin Core 早期版本源代码时，询问基于高度和基于时间的 nLockTime 功能哪个先加入，以及这对分叉有何影响。Pieter Wuille 和 David A. Harding 确认基于高度的逻辑先出现，并提供了一些有趣的历史见解。

- **<!--is-there-any-other-p2p-protocol-in-use-besides-a-gossip-protocol-->**[除了“gossip 协议”，是否还有其他 P2P 协议在使用？]({{bse}}99131) Murch 概述了比特币生态系统中使用的不同通信协议，包括[比特币的 P2P 协议][bitcoin p2p messages]、FIBRE 和 stratum 等挖矿协议、LN 相关协议，以及[payjoin][topic payjoin] 等多方协调协议。

- **<!--why-do-anchor-outputs-need-to-enforce-an-nsequence-of-1-->**[为什么锚定输出需要强制设置 nSequence 为 1？]({{bse}}98848) Dalit Sairio 询问关于[锚定输出][topic anchor outputs]以及 LN 脚本中 `OP_CHECKSEQUENCEVERIFY`（CSV）的必要性。用户 darosior 描述了 [CPFP 豁免（carve-out）][topic cpfp carve out]的相关考量，以及为何需要延迟 1 个区块。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.11.1-beta.rc4][lnd 0.11.1-beta] 是一个小版本的候选发布。其发布说明把变更概括为“若干可靠性改进、一些 macaroon [认证令牌]升级，以及一项改动——让我们实现的[锚点承诺][topic anchor outputs]符合规范”。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #18267][] 和 [#19993][Bitcoin Core #19993] 添加了对 [signet][topic signet] 的支持。如果 Bitcoin Core 使用 `-signet`（或 `-chain=signet`）启动，它将连接到默认的 signet 或通过 `-signetchallenge` 和 `-signetseednode` 参数定义的 signet。

- [Bitcoin Core #19572][] 新增了一个 “sequence” [ZMQ][bitcoin ZMQ] 主题，在区块连接/断开、交易被加入/移出内存池时通知订阅者。交易加入/移除的通知消息包含一个“内存池序列号”，订阅者可用它确定这些加入/移除的先后顺序，并与 `getrawmempool` RPC 的结果对照——该 RPC 现在也包含这个新字段。

- [C-Lightning #4068][] 和 [#4078][C-Lightning #4078] 更新了 C-Lightning 的 signet 实现，使其兼容 [BIP325][] 中最终选择的参数和 Bitcoin Core 的默认 signet。

- [Eclair #1501][] 增加了使用[锚定输出][topic anchor outputs]单边关闭通道的支持，完成了 Eclair 对这一 LN 协议新特性的基本实现。根据 PR 说明，Eclair 仍需加入为承诺交易和 HTLC 追加手续费所需的功能，但这会紧接着实现。

- [LND #4576][] 是计划为 LND 的[瞭望塔][topic watchtowers]实现加入锚定输出支持的一系列 PR 中的第一个。该 PR 特别加入了一个标志，用来指示被关闭的通道使用了锚定输出，以便瞭望塔作出相应处理。PR 说明称：“[这些]改动无需修改加密载荷格式。锚点载荷大小相同，包含的见证信息与传统载荷完全相同，只需对重构逻辑做小幅修改。”

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
