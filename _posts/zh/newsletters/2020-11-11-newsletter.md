---
title: 'Bitcoin Optech Newsletter #123'
permalink: /zh/newsletters/2020/11/11/
name: 2020-11-11-newsletter-zh
slug: 2020-11-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 分享了一则关于 LN 入站通道交易市场的公告。常规部分还包括 Bitcoin Core PR 审查俱乐部会议摘要，以及热门比特币基础设施软件的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--incoming-channel-marketplace-->****入站通道市场：** Olaoluwa Osuntokun [宣布][pool announce]了一个新的 *Lightning Pool* 市场，用于购买 LN 入站通道。用户和商家需要有具备入站容量的通道，才能通过 LN 快速收款。已有一些节点运营者在提供入站通道，有的免费，有的作为付费服务，而 Lightning Pool 希望让这项服务更加标准化、更具竞争力。最初的重点是一份合约：由排名较高的[节点][node rankings]提供一个为期 2,016 个区块（约两周）的入站通道。未来计划支持更多合约期限和其他功能。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍其中一些重要的问答。点击下面的问题即可查看会议中答案的摘要。*

[添加 MuHash3072 实现][review club #19055-2] 是 Fabian Jahr 提交的一个 PR（[#19055][Bitcoin Core #19055]），其中纳入了 Pieter Wuille 最初编写的代码，在 C++ 中实现了 [MuHash 算法][muhash mailing list]。MuHash 是一种滚动哈希算法，可用于计算一组对象的哈希摘要，并在向集合添加或移除条目时高效地更新该摘要。该算法可用于计算整个 UTXO 集合的摘要，这对数据库一致性检查，或对 [assumeutxo][topic assumeutxo] 之类的快速同步方法都很有用。

MuHash 的总体概念已在[此前的一次审查俱乐部会议][review club #19055]中讨论过，因此本次会议专门聚焦该算法的规范和实现。

{% include functions/details-list.md
  q0="**<!--q0-->**MuHash3072 滚动哈希对象内部存储了多少状态？请求集合哈希的用户将收到多少数据？"
  a0="MuHash3072 对象存储了 3072 位（384 字节）的内部状态。这份状态经 256 位哈希函数处理，向最终用户返回 256 位（32 字节）的数据。一种优化方案是同时存储分子（对应添加的条目）和分母（对应移除的条目），这需要 6144 位（768 字节）的内部状态，但能减少所需的代价高昂的模运算次数。"
  a0link="https://bitcoincore.reviews/19055-2#l-47"

  q1="**<!--q1-->**如何测试某个对象是否在 MuHash 集合中？"
  a1="MuHash 不是累加器，因此没有高效的办法测试集合成员资格。唯一的办法是从整个对象集合重新计算 MuHash 摘要，再比较摘要。"
  a1link="https://bitcoincore.reviews/19055-2#l-131"

  q2="**<!--q2-->**MuHash 实现中的 `#ifdef HAVE___INT128` 代码的作用是什么？"
  a2="`#ifdef HAVE___INT128` 是一个 C++ 预处理指令。它确保 `#ifdef` 与 `#endif` 之间的代码只在支持 128 位整数的平台上编译。由于 MuHash 代码要处理的数值远大于内置整数类型能表示的范围，这些数值被拆成多个“limb”（大数分段），再由这些分段拼出完整的数值。分段越大，运算次数越少，因而[性能越好][muhash performance]。支持 128 位整数让我们可以使用 64 位的分段，并安全地把这些分段中的数值相乘（两个 64 位数相乘得到一个 128 位数）。如果无法使用 64 位分段，就改用 32 位分段。"
  a2link="https://bitcoincore.reviews/19055-2#l-190"

  q3="**<!--q3-->**1437 mod 99 是多少？"
  a3="1437 mod 99 = 51。这个问题的用意是举例说明一种高效算法：当模数略小于基数的某个幂时，如何计算一个数除以该模数的余数。在本例中，99 略小于 10^2，因此求余数时可以把低位部分（这里是 37）加到“高位部分乘以模数与基数幂之差”上（本例中为 14 * (10^2 - 99)）。MuHash 的实现采用了同样的技巧，这也解释了为何把模数选为略小于 2^3072 的数。"
  a3link="https://bitcoincore.reviews/19055-2#l-246"
%}

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [BOLTs #807][] 修订了 [BOLT2][]，规定节点应将收到非标准高-*S* 签名视同收到无效签名，并立即让通道或连接失败。这有助于缓解此前在 [Newsletter #121][news121 lows-sig-cve] 中介绍过的 [CVE-2020-26895][]。

- [Eclair #1545][] 增加了一个区块链看门狗（watchdog），用于检测 [日食攻击][eclipse attacks]。Eclair 从多个第三方来源获取区块头，以核对其对等方提供的最佳链。如 [Newsletter #101][news101 time-dilation] 中所述，攻击者可以利用 日食攻击，把恶意的通道关闭尝试一直隐藏到争议期结束。

- [LND #4735][] 增加了一个 `max_local_csv` 配置参数，用于拒绝来自对等方的这类通道：对方要求本地节点在单方面关闭通道后等待超过指定区块数才能动用资金。默认上限为 10,000 个区块，同时设有 144 个区块的下限，以免用户把该值设得低于合理水平。

- [LND #4701][] 在默认构建中加入 `assumechanvalid`（假设通道有效）配置选项。对于使用 Neutrino 客户端获取[紧凑区块过滤器][topic compact block filters]的节点，这允许节点直接假定通过 LN gossip 获知的通道可用，而无需额外消耗带宽去检查最近区块中的相关交易。如果假设有误、通道实际上不可用（例如最近刚刚关闭），LND 尝试经由这些通道路由的支付就会失败。这可能造成延迟或不必要的支付失败，但不会导致资金损失。

{% include references.md %}
{% include linkers/issues.md issues="807,1545,4735,4701,19055,19055-2" %}
[node rankings]: https://nodes.lightning.computer/availability/v1/btc.json
[pool announce]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-November/002874.html
[muhash mailing list]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[muhash performance]: https://github.com/bitcoin/bitcoin/pull/19055#discussion_r508093977
[news101 time-dilation]: /zh/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[eclipse attacks]: /en/topics/eclipse-attacks/
[news121 lows-sig-cve]: /zh/newsletters/2020/10/28/#cve-2020-26895-acceptance-of-non-standard-signatures
[CVE-2020-26895]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26895
