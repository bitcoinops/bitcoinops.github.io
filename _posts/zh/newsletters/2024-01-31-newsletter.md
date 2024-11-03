---
title: 'Bitcoin Optech Newsletter #287'
permalink: /zh/newsletters/2024/01/31/
name: 2024-01-31-newsletter-zh
slug: 2024-01-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项提案，以允许使用 RBF 规则替换 v3 交易，以便更容易地过渡到族群交易池，并总结了反对 `OP_CHECKTEMPLATEVERIFY` 的论点，因为它通常需要外生费用。此外还有我们的常规部分：其中包括 Bitcoin Stack Exchange 的热门问题和答案的总结，新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--kindred-replace-by-fee-->亲属间手续费替换：** Gloria Zhao 在 Delving Bitcoin 上[发帖][zhao v3kindred]，讨论允许一笔交易在交易池中替换其关联交易，即使两笔交易之间没有冲突。当两笔交易不能同时存在于同一个有效的区块链中时，它们被认为是_冲突的_，这通常是因为它们都试图花费同一个 UTXO，违反了双重花费的规则。[RBF][topic rbf] 的规则将交易池中的交易与新收到的与其冲突的交易进行比较。Zhao 提出了一种理想化的方法来思考冲突策略：如果一个中继节点有两个交易，但只能接受一个，它不应该选择先到达的那个—————它应该选择最适合节点运营商目标的那个（例如，在防止实质免费中继的前提下最大化矿工收入）。RBF 规则试图对冲突交易来做到这一点。Zhao 在她的帖子中，试图将这一思想扩展到关联交易，而不仅仅是冲突交易。

  Bitcoin Core 对交易池中同时允许的关联交易的数量和规模施加了_规则_限制。这缓解了几种 DoS 攻击，但也意味着它可能会拒绝交易 B，因为 B 之前收到了相关的交易 A，交易 A 已达限制上限。这种情况违反了赵的原则：相反，Bitoin Core 应该接受对 A 或 B 中其目标更好的那一笔。

  [v3 交易中继][topic v3 transaction relay]的拟议规则只允许一个未确认的 v3 父交易在交易池中有一个子交易。因为两笔交易在交易池中都不能有任何祖先或后代，将现有的 RBF 规则应用于 v3 子交易的替换很简单，Zhao 已经[实现了这一点][zhao kindredimpl]。如[上周周报][news286 imbued]所述，如果使用[锚点输出][topic anchor outputs]的现有 LN 承诺交易自动纳入到 v3 策略中，这将确保任何一方始终可以提升承诺交易的费用：

  - Alice 可以发送带有子交易（用于支付手续费）的承诺交易。

  - Alice 随后可以对现有子交易进行 RBF 以提升费用。

  - Bob 可以使用亲属替换来驱逐 Alice 的子交易，即发送一笔支付更高费用的他自己的子交易。

  - Alice 随后可以使用亲属替换对 Bob 的子交易进行操作，即发送一笔她自己的费用更高子交易（移除Bob的子交易）。

  添加此策略并自动将其应用于当前的 LN 锚点，将允许删除 [CPFP carve-out 规则][topic cpfp carve out]，这是实现[族群交易池][topic cluster mempool]所必需的，这应该有助于未来使各种替换更具激励兼容性。

  在撰写本文时，论坛上还没有对该想法的异议。一个显著的问题是这是否消除了对[临时锚点][topic ephemeral anchors]的需要，但该提案的作者（Gregory Sanders）回复说：“我没有计划放弃临时锚点的工作。零聪输出在 LN 之外还有许多重要的使用案例。”

- **<!--Opposition-to-CTV-based-on-commonly-requiring-exogenous-fees-->鉴于通常需要外生费用而反对 CTV：**
  Peter Todd 向 Bitcoin-Dev 邮件列表[发布了][pt ctv]他反对[外生费用][topic fee sourcing](见[周报 #284][news284 ptexogenous])的一个适用情况，即当适用于  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 提案时。他指出，“在许多（如果不是大多数）CTV 使用案例中，旨在允许多方共享单个 UTXO，很难或者不可能提供足够的 CTV 变体来覆盖所有可能的手续费率。预计 CTV 通常会与[锚点输出][topic ephemeral anchors]一起使用来支付手续费[...]或者可能通过[手续费赞助][topic fee sponsorship]的软分叉升级。[...]这要求所有用户都必须有一个 UTXO 来支付手续费，抵消了 CTV 共享 UTXO 方案的效率[...]唯一现实的替代方案是使用第三方，例如通过闪电网络支付来为 UTXO 支付费用，但在这一点上，支付[协议外矿工费][topic out-of-band fees]会更有效率。这当然从挖矿集中化的角度来看非常不可取。（链接由 Optech添加）”。他建议放弃CTV，转而致力于与 [RBF][topic rbf] 兼容的[限制条款][topic covenants]。

  John Law 回复说，如果特定版本的交易需要在截止日期之前确认，依赖手续费的时间锁(见 [周报 #283][news283 fdt])可以使 CTV 安全地用于内生费用，尽管如果费用过低,依赖手续费的时间锁可能会无限期地延迟交易。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是它们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-does-block-synchronization-work-in-bitcoin-core-today-->目前 Bitcoin Core 中的块同步是如何工作的？]({{bse}}121292)
  Pieter Wuille 描述了区块头树、区块数据和活跃的 chaintip 区块链数据结构，并继续解释了作用于它们的区块头同步、区块同步和区块激活过程。

- [<!--how-does-headers-first-prevent-disk-fill-attack-->区块头优先如何防止磁盘写满攻击？]({{bse}}76018)
  Pieter Wuille 跟进了一个老问题，解释了最近在比 Bitcoin Core 24.0 中添加的IBD“区块头预同步”(见 [周报 #216][news216 headers presync])，区块头垃圾邮件缓解措施，以防止磁盘写满攻击。

- [<!--is-bip324-v2transport-redundant-on-tor-and-i2p-connections-->在 Tor 和 I2P 连接上，BIP 324 v2 传输是否冗余？]({{bse}}121360)
  Pieter Wuille 承认在使用[匿名网络][topic anonymity networks]时，[v2 传输][topic v2 p2p transport]加密的效益不足，但指出相比 v1 未加密传输，可能存在潜在的计算性能提升。

- [<!--what-s-a-rule-of-thumb-for-setting-the-maximum-number-of-connections-->设置最大连接数的经验法则是什么？]({{bse}}121088)
  Pieter Wuille 区分了[出站和入站连接]({{bse}}121015)，并列出了设置较高 `-maxconnections` 值时需要考虑的因素。

- [<!--why-isn-t-the-upper-bound-2h-on-the-block-timestamp-set-as-a-consensus-rule-->为什么不将区块时间戳的上限（+2h）设置为共识规则？]({{bse}}121248)
  在这个问题和[其他]({{bse}}121247)相关[问题]({{bse}}121253)中，Pieter Wuille 解释了新区块时间戳必须早于未来 2 小时要求的重要性，以及为什么“共识规则只能依赖于通过区块哈希所承诺的信息”。

- [<!--sigop-count-and-its-influence-on-transaction-selection-->Sigop 计数及其对交易选择的影响？]({{bse}}121355)
  用户 Cosmik Debris 询问，签名检查操作“sigops”的限制如何影响矿工的区块模板构建和基于交易池的[费用估算][topic fee estimation]？用户 mononaut 概述了 sigops 在区块模板构建中成为限制因素的罕见性，并讨论了 `-bytespersigop` 选项。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [HWI 2.4.0][]是此软件包的下一个版本，为多个不同的硬件签名设备提供通用接口。新版本增加了对 Trezor Safe 3 的支持，并包含一些小的改进。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana
repo]。_

- [Bitcoin Core #29291][] 添加了一个测试，如果一个执行了 `OP_CHECKSEQUENCEVERIFY` 操作码的交易似乎具有负版本号，该测试会失败。如果替代共识实现运行了这个测试，就可以发现[上周周报][news286 bip68ver]中提到的共识失败错误。

- [Eclair #2811][]、[#2813][eclair #2813] 和 [#2814][eclair #2814]添加了为最终接收者使用[盲路径][topic rv routing]的[蹦床支付][topic trampoline payments]能力。
  蹦床路由本身继续使用常规洋葱加密节点 ID，即每个蹦床节点都将了解下一个蹦床节点的 ID。但是，如果使用了盲路径，最后一个蹦床节点现在只会了解盲路径中入口节点的节点 ID；它不会了解最终接收方的 ID。

  以前，强大的蹦床隐私依赖于使用多个蹦床转发器，从而没有一个转发器可以确定他们是最终的转发器。这种方法的缺点是它使用了更长的路径，增加了转发失败的可能性，并且需要支付更多的转发费用才能成功。现在，即使是通过单个蹦床节点转发付款，也可以阻止该节点知晓最终的接收者。

- [LND #8167][] 允许 LND 节点相互关闭仍具有一个或多个待处理([HTLC][topic htlc])的通道。[BOLT2][] 规范表明，正确的程序是让一方发送 `shutdown` 消息，之后将不接受新的 HTLC。在链下解决所有待处理的 HTLC 后，双方协商并签署相互关闭的交易。此前，当 LND 收到 `shutdown` 消息时，会强制关闭通道，需要额外的链上交易和费用结算。

- [LND #7733][] 更新了[瞭望塔（watchtower）][topic watchtowers]支持，以便备份并强制正确关闭现在在 LND 上实验性支持的[简单 taproot 通道][topic simple taproot channels]。

- [LND #8275][] 开始要求对等节点支持特定的在 [BOLTs #1092][] (见[周报 #259][news259 lncleanup])中指定的一些普遍部署的功能。

- [Rust Bitcoin #2366][] 弃用 `Transaction` 对象上的 `.txid()` 方法，并开始提供一个名为 `.compute_txid()` 的替代方法。每次调用 `.txid()` 方法时，都会计算交易的 txid，这会消耗足够多的 CPU，对在大型交易或许多更小交易上运行该函数的任何人来说都是个问题。希望这个方法的新名称将帮助下游程序员意识到其潜在成本。类似地，`.wtxid()` 和 `.ntxid()` 方法 (分别基于 [BIP141][] 和 [BIP140][]) 同样重命名为 `.compute_wtxid()` 和 `.compute_ntxid()`。

- [HWI #716][] 增加了对 Trezor Safe 3 硬件签名设备的支持。

- [BDK #1172][] 为钱包添加了逐块 API。有权访问一系列区块的用户可以迭代这些区块，以根据这些区块中的任何交易更新钱包。这可以简单地用于迭代链中的每个区块。或者，软件可以使用某种过滤方法(例如[致密区块过滤][topic compact block filters])来仅查找可能具有影响钱包交易的区块，并迭代该区块的子集。

- [BINANAs #3][] 添加了 [BIN24-5][]，其中列出了与比特币相关的规范存储库，如 BIP、BOLT、BLIP、SLIP、LNPBP 和 DLC 规范。还列出了一些其他相关项目的规范存储库。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29291,2811,2813,2814,8167,7733,8275,1092,2366,716,1172,3" %}
[hwi 2.4.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0
[news286 bip68ver]: /zh/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd-btcd
[trezor safe 3]: https://trezor.io/trezor-safe-3
[news283 fdt]: /zh/newsletters/2024/01/03/#feedependent-timelocks
[zhao v3kindred]: https://delvingbitcoin.org/t/sibling-eviction-for-v3-transactions/472
[news259 lncleanup]: /zh/newsletters/2023/07/12/#ln
[news284 ptexogenous]: /zh/newsletters/2024/01/10/#frequent-use-of-exogenous-fees-may-risk-mining-decentralization
[zhao kindredimpl]: https://github.com/bitcoin/bitcoin/pull/29306
[pt ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022309.html
[news286 imbued]: /zh/newsletters/2024/01/24/#imbued-v3-logic-v3
[news216 headers presync]: /zh/newsletters/2022/09/07/#bitcoin-core-25717
