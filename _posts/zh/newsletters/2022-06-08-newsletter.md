---
title: 'Bitcoin Optech Newsletter #203'
permalink: /zh/newsletters/2022/06/08/
name: 2022-06-08-newsletter-zh
slug: 2022-06-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括我们的常规部分，有比特币核心 PR 审查俱乐部会议的总结，新软件发布和候选发布的清单，以及流行的比特币基础设施软件中值得注意的变更的介绍。

## 新闻

本周没有重大新闻。

## 比特币核心 PR 审核俱乐部
*在这个每月一次的栏目中，我们会总结最近的一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，提炼出一些重要的问题和答案。点击下方的问题描述，就可以看到来自会议的答案。*

[输出描述符中的 Miniscript 支持][reviews 24148]是由 Antoine Poinsot 和 Pieter Wuille 撰写的 PR，旨在介绍[描述符][topic descriptors]中对 [Miniscript][topic miniscript] 的只读支持。与会者在两次会议上审核了该 PR。讨论的主题包括 Miniscript 的用途，对可延展性的考虑，以及描述符解析器的实现。

{% include functions/details-list.md

  q0="Miniscript 实现的哪些类型的分析对哪些用例或应用有帮助？"
  a0="我们讨论了几种使用情况和分析类型。Miniscript 能够分析最大见证规模，从而分析在给定费率前提下花费输出的"最坏情况"的成本。可预测的交易权重有助于 L2 协议的开发者编写更可靠的费用碰撞机制。此外，给定一些策略，编译器会生成一个最小的 Miniscript 脚本（不一定是最小的，因为 Miniscript 只对所有脚本的一个子集进行编码），它可能比手写的脚本要小。与会者指出，Miniscript 在过去曾帮助优化 LN 模板。最后，组合允许多方结合复杂的支出条件，并在不完全了解所有条件的情况下保证所产生的脚本的正确性。"
  a0link="https://bitcoincore.reviews/24148#l-41"

  q1="Miniscript 表达式可以表示为节点树，其中每个节点代表一个片段。当一个节点是"理智的"或"有效的"是什么意思？它们的意思相同吗？"
  a1="每个节点都有一个片段类型（如 `and_v`、`thresh`、`multi`等）和参数。一个有效的节点的参数与片段类型所期望的一致。一个理智的节点必须是有效的，它的脚本语义必须与它的策略相匹配，是共识有效的和符合标准的，只具有不可延展的解决方案，不混合时间锁单位（即同时使用块高度和时间），并且没有重复的键。按照定义，这两个属性并不完全相同；每个理智的节点都是有效的，但不是每个有效的节点都是理智的。"
  a1link="https://bitcoincore.reviews/24148#l-107"

  q2="一个表达式是不可延展的意味着什么？在 segwit 之后，我们为什么还需要担心可延展性呢？"
  a2="如果一个脚本被第三方（也就是那些无法获得相应私钥的人）修改后仍然满足支出条件，那么这个脚本就是可延展的。Segwit 并没有消除交易延展的可能性；它确保了交易延展不会破坏未确认的后续交易的有效性，但延展性仍然会因为其他原因而产生问题。例如，如果攻击者可以把额外的数据塞进见证中，并且仍然满足支出条件，他们就可以降低交易的费率，对其传播产生负面影响。一个"满足不可延展性的表达式"不会给第三方这样的选择，以修改现有的满足为另一个有效的满足。更完整的答案可以在[这里][sipa miniscript]找到。"
  a2link="https://bitcoincore.reviews/24148#l-170"

  q3="哪个函数负责解析输出描述符的字符串？它如何确定字符串是否代表一个 `MiniscriptDescriptor`？它是如何解析一个可以用多种方式解析的描述符的？"
  a3="script/descriptor.cpp 中的函数 `ParseScript` 负责解析输出描述符字符串。它首先尝试所有其他描述符类型，然后调用 `miniscript::FromString` 来查看字符串是否是有效的 Miniscript 表达式。由于这种操作顺序，可以被解释为 miniscript 和非 miniscript 的描述符（例如 `wsh(pk(...))`）会被解析为非 miniscript。"
  a3link="https://bitcoincore.reviews/24148-2#l-30"

  q4="当在两个可用的选项之间进行选择时，为什么要优先选择涉及较少签名的，而不是产生较小脚本的？"
  a4="试图篡改交易的第三方（即无法接触到私钥）可以删除签名，但不能创建新的签名。选择有额外签名的满足方式为第三方留下了篡改脚本但仍然满足支出条件的选择。例如，策略 `or(and(older(21), pk(B)), thresh(2, pk(A), pk(B))` 有两条支出路径：当 A 和 B 都签名时，它可以被支出，或者在 21 个区块之后，只有 B 签名也可被支出。在 21 个区块之后，两种满足方式都可以使用，但如果带有 A 和 B 的签名的交易被广播，第三方可以删除 A 的签名，仍然可以满足另一种支出路径。另一方面，如果被广播的交易只包含 B 的签名，攻击者就不能满足其他花费条件，除非它伪造 A 的签名。"
  a4link="https://bitcoincore.reviews/24148-2#l-106"
%}

## 软件的新版本和候选版本
*流行比特币基础设施项目的新版本和候选版本。请考虑升级到最新版本或帮助测试候选版本。*

- [LND 0.15.0-beta.rc4][] 是这个流行的 LN 节点的下一个主要版本的候选版本。

## 重大代码及文档变更
*本周内，[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 出现的重大变更。*

- [Bitcoin Core #24408][] 增加了一个 RPC 来获取从一个给定的 outpoint 支出的交易池交易，通过单独选择交易而不是从 `getrawmempool` 检索的 txid 列表来简化 outpoint 的搜索。这在闪电网络中是很有用的，当在一个通道资金交易被花费后定位一个花费交易，或者通过获取冲突的交易来检查为什么一个 [RBF][topic rbf] 交易未能广播。

- [LDK #1401][] 增加了对 zero-conf 通道打开的支持。相关信息，请参见下面的 BOLTs #910 的摘要。

- [BOLTs #910][] 更新了 LN 规范，有两个变更。第一个允许短通道标识符（SCID）别名，这可以提高隐私性，也允许在一个通道的 txid 不稳定时（即在其存款交易收到可靠数量的确认之前）引用该通道。第二个规范变更增加了一个 `option_zeroconf` 功能位，当一个节点愿意使用 [zero-conf][topic zero-conf channels] 通道时可以设置。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24408,1401,910" %}
[lnd 0.15.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc4
[reviews 24148]: https://bitcoincore.reviews/24148
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
