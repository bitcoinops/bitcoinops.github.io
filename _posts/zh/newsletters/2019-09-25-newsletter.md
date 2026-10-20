---
title: 'Bitcoin Optech Newsletter #65'
permalink: /zh/newsletters/2019/09/25/
name: 2019-09-25-newsletter-zh
slug: 2019-09-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 就“不允许 taproot 使用 P2SH 包装地址”一事征求意见，介绍了 tapscript 中脚本资源限制的拟议变更，并提到一场关于瞭望塔存储成本的讨论。此外还精选了 Bitcoin Stack Exchange 上的一些热门问答，并简要列出热门比特币基础设施项目值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--comment-if-you-expect-to-need-p2sh-wrapped-taproot-addresses-->****如果你预计会需要 P2SH 包装的 taproot 地址，请发表意见：**
  Bitcoin-Dev 邮件列表上最近的[讨论][p2sh taproot]表明，[bip-taproot][] 提案可能会被修改，不再允许通过支付 P2SH 输出创建 taproot 输入（目前你还可以用 P2SH 输出创建 P2WPKH 和 P2WSH 输入）。任何预计会需要 P2SH 包装 taproot 的人，都应在邮件列表上说明自己计划中的用例，或私下联系 bip-taproot 的作者。

## 新闻

- **<!--tapscript-resource-limits-->****Tapscript 资源限制：**[bip-tapscript][] 提案规定，见证数据每给交易大小增加 12.5 vbytes，交易中就只能有一次签名检查操作（sigop），每个输入另加一次免费的 sigop。由于预计签名为 16.0 vbytes，这一限制既能防范滥用，又不影响普通用户。与早先的防滥用方案相比，这意味着无论一笔有效的 taproot 交易包含多少 sigop，它都能被打包进区块——从而让矿工的交易处理代码保持简单、快速。

  在邮件列表的一则[帖子][tapscript limits]中，bip-tapscript 作者 Pieter Wuille 提到，他和 Andrew Poelstra 考察了脚本上其他一些资源限制，这些限制原本是为了防止节点在验证期间消耗过多 CPU 或内存。他介绍了两人的部分发现，并主张做以下规则调整：

  > * 用一个“实际执行的 sigop 数不得超过（见证大小 / [12.5 vbytes]）+ 1”的规则取代单独的 sigop 计数器（BIP 中已采用）。
  > * 取消脚本大小 10,000 字节的限制（以及 3,600 字节的标准性限制）。
  > * 取消每个脚本 201 次非推送操作的限制。
  > * 取消输入栈元素 100 个的标准性限制，改为（共识层）1,000 个的限制。

  去掉这些不必要的规则，可以简化高级比特币脚本的编写，也能简化与之配套的工具。

- **<!--watchtower-storage-costs-->****瞭望塔存储成本：**Lightning-Dev 邮件列表上的一场[讨论][watchtower discussion]考察了现有瞭望塔（watchtower）的存储需求，以及拟议中[基于 eltoo 的][eltoo]支付通道所需瞭望塔的存储需求。在讨论帖中，Christian Decker 指出，无论是当前由 LND 实现的瞭望塔，还是未来为 eltoo 服务的瞭望塔，只要让每个人用一个会话密钥去更新其在瞭望塔上的最新状态信息，每个用户的成本基本上都可以是 O(1)（固定成本）。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-this-coinbase-transaction-have-two-op-return-outputs-->**[为什么这个 币基交易有两个 OP_RETURN 输出？]({{bse}}90127)
Murch 概述了虽然对见证承诺输出有一些限制，但对于其他 币基交易输出没有额外的脚本或数量限制。

- **<!--what-happens-to-transactions-included-in-invalid-blocks-->**[包含在无效区块中的交易会发生什么？]({{bse}}90026)
RedGrittyBrick 和 Murch 解释说，交易包含在无效区块中不会对该交易的有效性或其在后续区块中的确认能力产生任何影响。

- **<!--why-was-550-mib-chosen-as-a-minimum-storage-size-for-prune-mode-->**[为什么选择 550 MiB 作为修剪模式的最小存储大小？]({{bse}}90140)
Behrad Khodayar 回答了他自己提出的问题：为什么把 550 MiB 选为修剪节点的最小存储大小。这个存储量最初是在隔离见证之前选定的，目的是在磁盘上保留 288 个区块、约两天的状态转换数据。

- **<!--how-do-orphan-blocks-affect-the-network-->**[孤块如何影响网络？]({{bse}}90577)
Pieter Wuille 澄清说，自 0.10.0 版本以来，Bitcoin Core 使用 [headers-first][] IBD（初始区块下载），这消除了孤块的可能性（根据提问者的定义）。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #16400][] 重构了内存池交易接受代码的一部分。我们通常不报道重构，但这次有一个很吸引人的注释：“这是为了复用这些验证组件，为 `AcceptToMemoryPool()` 的新版本做准备，该版本可以同时处理多笔交易（‘交易包中继’）。”交易包中继（package relay）可以让节点接受一笔低于本节点最低费率的交易——前提是这笔交易与一笔子交易捆绑而来，且子交易的手续费足以同时付清它自己和父交易的最低手续费。如果得到广泛部署，交易包中继就能让那些在广播前很久就构造好交易的用户（例如时间锁交易或 LN 承诺交易）放心地只支付最低可能的手续费。等到需要广播时，他们再用子为父付（CPFP）手续费追加，按当前网络状况设定合适的手续费。

- [BOLTs #557][] 更新了 [BOLT7][]，允许使用“扩展查询”：节点可以请求只接收比指定时间更新的 gossip 更新，或与指定哈希不同的更新。

{% include linkers/issues.md issues="16400,557" %}
[p2sh taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017307.html
[tapscript limits]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017306.html
[watchtower discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002156.html
[headers-first]: https://developer.bitcoin.org/devguide/p2p_network.html#headers-first
[eltoo]: https://blockstream.com/eltoo.pdf
