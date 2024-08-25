---
title: 'Bitcoin Optech Newsletter #65'
permalink: /zh/newsletters/2019/09/25/
name: 2019-09-25-newsletter-zh
slug: 2019-09-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求对不允许用于 taproot 的 P2SH 包装地址提供反馈，描述了对 tapscript 中脚本资源限制的提议变更，并提到了一场关于 watchtower 存储成本的讨论。此外，还包括了一些来自 Bitcoin Stack Exchange 的热门问题和答案的精选，以及对流行的比特币基础设施项目的值得注意的更改的简短列表。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--comment-if-you-expect-to-need-p2sh-wrapped-taproot-addresses-->****如果你预计需要 P2SH 包装的 taproot 地址，请发表评论：**
  最近在 Bitcoin-Dev 邮件列表上的[讨论][p2sh taproot]表明，可能会修改 [bip-taproot][] 提案，以不允许通过支付 P2SH 输出创建 taproot 输入（就像你目前可以使用由 P2SH 输出创建的 P2WPKH 和 P2WSH 输入一样）。任何预计需要 P2SH 包装的 taproot 的人都应在邮件列表上描述他们计划的使用案例或通过私人联系 bip-taproot 作者。

## 新闻

- **<!--tapscript-resource-limits-->****Tapscript 资源限制：**[bip-tapscript][] 提案将交易限制为每 12.5 vbytes 的见证数据添加到交易大小中进行一次签名检查操作 (sigop)（每个输入另加一次免费的 sigop）。由于签名预计为 16.0 vbytes，这一限制在不影响普通用户的情况下防止滥用。与早期的防滥用解决方案相比，这意味着任何有效的 taproot 交易都可以包含在一个区块中，而不管它包含多少 sigops——使矿工的交易代码简单快速。

  在邮件列表的[帖子][tapscript limits]中，bip-tapscript 作者 Pieter Wuille 提到他和 Andrew Poelstra 检查了其他对脚本的资源限制，这些限制是为了防止节点在验证期间使用过多的 CPU 或内存。他描述了他们的一些发现，并倡导以下规则更改：

  > * 用“执行的 sigops 不得超过（见证大小 / [12.5 vbytes]） + 1”的规则替换单独的 sigops 计数器（已在 BIP 中）。
  > * 取消脚本大小的 10,000 字节限制（和 3,600 字节的标准性限制）。
  > * 取消每个脚本 201 个非推操作的限制。
  > * 取消 100 个输入栈元素的标准性限制，并替换为（共识）1,000 个限制。

  删除不需要的规则将简化高级比特币脚本的构建及其必要的工具。

- **<!--watchtower-storage-costs-->****Watchtower 存储成本：**在 Lightning-Dev 邮件列表上的一场[讨论][watchtower discussion]中，检查了当前 watchtowers 的存储需求以及基于 eltoo 的提议支付通道的 watchtowers。在线程中，Christian Decker 指出，无论是当前的 watchtowers（由 LND 实现）还是未来基于 eltoo 的 watchtowers，都可以通过让每个人使用会话密钥来更新他们在 watchtower 上的最新状态信息，从而拥有基本的 O(1) 成本（固定成本）。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地之一——或者当我们有一些闲暇时间帮助好奇或困惑的用户时。在这个每月特辑中，我们会重点介绍自上次更新以来发布的一些最高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-this-coinbase-transaction-have-two-op-return-outputs-->**[为什么这个 coinbase 交易有两个 OP_RETURN 输出？]({{bse}}90127)
Murch 概述了虽然对见证承诺输出有一些限制，但对于其他 coinbase 交易输出没有额外的脚本或数量限制。

- **<!--what-happens-to-transactions-included-in-invalid-blocks-->**[包含在无效区块中的交易会发生什么？]({{bse}}90026)
RedGrittyBrick 和 Murch 解释说，交易包含在无效区块中不会对该交易的有效性或其在后续区块中的确认能力产生任何影响。

- **<!--why-was-550-mib-chosen-as-a-minimum-storage-size-for-prune-mode-->**[为什么选择 550 MiB 作为修剪模式的最小存储大小？]({{bse}}90140)
Behrad Khodayar 回答了他自己关于为什么选择 550 MiB 作为修剪节点的最小存储大小的问题。存储量最初在（隔离见证之前）选择，以保持 288 个区块的状态转换数据，大约两天的时间。

- **<!--how-do-orphan-blocks-affect-the-network-->**[孤块如何影响网络？]({{bse}}90577)
Pieter Wuille 澄清说，自 0.10.0 版本以来，比特币核心使用 [headers-first][] IBD（初始区块下载），这消除了孤块的可能性（根据提问者的定义）。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案 (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 中的值得注意的更改。*

- [Bitcoin Core #16400][] 重构了部分内存池交易接受代码。我们通常不报道重构，但这次重构有一个诱人的评论：“这是为了重新使用这些验证组件为 `AcceptToMemoryPool()` 的新版本做准备，该版本可以对多个交易（‘包传递’）进行操作。”包传递可以允许节点接受低于节点最低费率的交易，如果交易捆绑了子交易，其费用足以支付父交易和子交易的最低费率。如果广泛部署，包传递将允许那些在广播交易之前很长时间创建交易的用户（例如，时间锁定交易或 LN 承诺交易）安全地支付最低可能费用。当需要广播交易时，他们可以使用 Child-Pays-For-Parent (CPFP) 费用提升来为当前的网络条件设置适当的费用。

- [BOLTs #557][] 更新了 [BOLT7][] 以允许“扩展查询”，这允许节点请求他们只接收指定日期之后或与指定哈希不同的 gossip 更新。

{% include linkers/issues.md issues="16400,557" %}
[p2sh taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017307.html
[tapscript limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017306.html
[watchtower discussion]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002156.html
[headers-first]: https://developer.bitcoin.org/devguide/p2p_network.html#headers-first
