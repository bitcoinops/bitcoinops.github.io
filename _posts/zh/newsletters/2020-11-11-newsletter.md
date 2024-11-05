---
title: 'Bitcoin Optech Newsletter #123'
permalink: /zh/newsletters/2020/11/11/
name: 2020-11-11-newsletter-zh
slug: 2020-11-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了一个新的用于购入 LN 入口通道的市场。同时还包括我们的常规部分，总结了 Bitcoin Core PR 审查俱乐部的会议内容以及对流行的比特币基础设施软件的值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--incoming-channel-marketplace-->****入口通道市场：** Olaoluwa Osuntokun [宣布][pool announce]了一个新的 *Lightning Pool* 市场，用户可以在其中购买入口 LN 通道。用户和商家需要具备有入口容量的通道，以便能够在 LN 上快速接收资金。当前一些节点运营者已提供入口通道服务，部分是免费提供，部分则为付费服务，而 Lightning Pool 希望通过该平台使这项服务更加标准化和具有竞争力。最初的重点是让高度排名的[节点][node rankings]提供一个为期 2,016 个区块（约两周）的入口通道。未来计划增加其他的合约期限及其他功能。

## Bitcoin Core PR 审查俱乐部

*在这个月度部分中，我们总结了最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问答。点击下面的问题可以查看会议中答案的总结。*

[添加 MuHash3072 实现][review club #19055-2] 是由 Fabian Jahr 提交的 PR ([#19055][Bitcoin Core #19055])（其中包含了 Pieter Wuille 最初编写的代码），在 C++ 中实现了 [MuHash 算法][muhash mailing list]。MuHash 是一种滚动哈希算法，可用于计算对象集合的哈希摘要，并在集合中添加或移除项目时高效地更新该摘要。该算法可以用于计算完整 UTXO 集的摘要，这对于数据库一致性检查或诸如 [assumeutxo][topic assumeutxo] 之类的快速同步方法非常有用。

关于 MuHash 的高级概念已在[之前的审查俱乐部会议][review club #19055]中讨论过，因此此次会议专注于该算法的具体规范和实现。

{% include functions/details-list.md
  q0="**<!--q0-->**MuHash3072 滚动哈希对象内部存储了多少状态？请求集合哈希的用户将收到多少数据？"
  a0="MuHash3072 对象存储了 3072 位（384 字节）的内部状态。该状态通过 256 位的哈希函数进行哈希处理，以向最终用户返回 256 位（32 字节）的数据。一个优化方案是存储一个分子（用于添加的项目）和一个分母（用于移除的项目），这将需要 6144 位（768 字节）的内部状态，但可以减少所需的大量模运算次数。"
  a0link="https://bitcoincore.reviews/19055-2#l-47"

  q1="**<!--q1-->**如何测试某个对象是否在 MuHash 集合中？"
  a1="MuHash 不是一个累加器，因此无法有效地测试集合成员资格。唯一的方式是从整个对象集合重新计算 MuHash 摘要，然后对比摘要。"
  a1link="https://bitcoincore.reviews/19055-2#l-131"

  q2="**<!--q2-->**MuHash 实现中的 `#ifdef HAVE___INT128` 代码的作用是什么？"
  a2="`#ifdef HAVE___INT128` 是一个 C++ 预处理指令。它确保只有在支持 128 位整数的平台上才会编译该指令内的代码。由于 MuHash 代码操作的数值远大于内置整数类型所能处理的范围，这些数值被分解为多个“位段”，这些位段组合成完整的数值。较大的位段意味着更少的运算，从而 [提高性能][muhash performance]。支持 128 位整数使我们可以使用 64 位位段，并且可以安全地将这些位段中的数值相乘（两个 64 位数相乘的结果是一个 128 位数）。如果不能使用 64 位位段，则改用 32 位位段。"
  a2link="https://bitcoincore.reviews/19055-2#l-190"

  q3="**<!--q3-->**1437 mod 99 是多少？"
  a3="1437 mod 99 = 51。此问题作为一个示例，展示了一种计算除以接近某个数的幂的模数的余数的高效方法。在此示例中，99 稍小于 10^2，因此我们可以将低位部分（这里为 37）加到高位部分乘以模数和基数之间的差值（在此例中为 14 * (10^2 - 99)）。在 MuHash 实现中采用了相同的技术，并解释了为何选择接近 2^3072 的模数。"
  a3link="https://bitcoincore.reviews/19055-2#l-246"
%}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [BOLTs #807][] 修改了 [BOLT2][]，规定节点应将接收的非标准高-*S* 签名视为无效签名，并立即关闭通道或断开连接。这有助于减轻之前在 [Newsletter #121][news121 lows-sig-cve] 中提到的 [CVE-2020-26895][]。

- [Eclair #1545][] 增加了一个区块链监视器，用于检测 [eclipse 攻击][eclipse attacks]。Eclair 从多个第三方来源获取区块头，以核对其节点提供的最佳链。如 [Newsletter #101][news101 time-dilation] 中所述，攻击者可以利用 eclipse 攻击在争议期过期之前隐藏恶意的通道关闭尝试。

- [LND #4735][] 增加了一个 `max_local_csv` 配置参数，用于拒绝需要本地节点在单方面关闭通道后等待超过指定区块数才能支配其资金的通道。默认最大值为 10,000 个区块，同时设置了最小值 144 个区块，以确保用户不会设置过低的值。

- [LND #4701][] 在默认构建中添加了 `assumechanvalid`（假设通道有效）配置选项。对于使用 Neutrino 客户端检索[致密区块过滤器][topic compact block filters]的节点，这允许节点假设通过 LN gossip 学到的通道是可用的，而无需花费额外带宽检查最近区块中的相关交易。如果假设错误且通道实际上不可用（例如通道最近已关闭），LND 尝试通过这些通道进行的支付将失败。这可能导致延迟或不必要的支付失败，但不会造成资金损失。

{% include references.md %}
{% include linkers/issues.md issues="807,1545,4735,4701,19055,19055-2" %}
[node rankings]: https://nodes.lightning.computer/availability/v1/btc.json
[pool announce]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-November/002874.html
[muhash mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[muhash performance]: https://github.com/bitcoin/bitcoin/pull/19055#discussion_r508093977
[news101 time-dilation]: /zh/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[eclipse attacks]: /en/topics/eclipse-attacks/
[news121 lows-sig-cve]: /zh/newsletters/2020/10/28/#cve-2020-26895-acceptance-of-non-standard-signatures
[CVE-2020-26895]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26895
