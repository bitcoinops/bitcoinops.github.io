---
title: 'Bitcoin Optech Newsletter #411'
permalink: /zh/newsletters/2026/06/26/
name: 2026-06-26-newsletter-zh
slug: 2026-06-26-newsletter-zh
layout: newsletter
lang: zh
---
本周的周报披露了一项负责任公开的拒绝服务漏洞，该漏洞影响较旧版本的 LND。此外还包括我们的常规栏目：来自 Bitcoin Stack Exchange 的精选问答、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--lnd-zero-timestamp-gossip-dos-disclosure-->****LND 零时间戳 gossip DoS 漏洞披露：** Nishant Bansal 在 Delving Bitcoin 上[发帖][lnd gossip dos delving]，披露了一项他通过对 LND 的 gossip 处理进行状态机模糊测试所发现的拒绝服务漏洞。LND v0.20.1-beta 之前的版本都可能被一条时间戳为零的 `channel_update` 或 `node_announcement` gossip 消息击溃。尽管 [BOLT7][] 要求 `channel_update` 的时间戳必须大于零，但它并未规定节点应如何处理违反该规则的消息，而 LND 对该取值的处理最终导致了崩溃。

  当一个存在漏洞的节点尝试处理此类零时间戳消息时，其内部记账错误会使一个数据结构处于无效状态，从而导致运行时 panic 并终止节点。攻击者可以通过广播一个真实公开通道的公告，或者广播一个伪造通道的公告来触发该 bug；后者可通过为一个由攻击者控制的 2-of-2 输出进行注资来构造，因此在无需运行闪电网络节点的情况下也能更低成本地重复实施。

  该漏洞已进行了[负责任披露][topic responsible disclosures]，并由 Matt Morehouse 独立确认；它已在 [LND 0.20.1-beta][news393 lnd 0201] 中修复，修复方式是在解析阶段就拒绝时间戳为零的 gossip 消息，使其在到达脆弱代码之前就被拦截。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者查找问题答案的首选之地——也是我们在闲暇时帮助好奇或困惑用户的地方。在这个月度专题中，我们重点介绍自上次更新以来投票最高的部分问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [`OP_IF` 属于 tapscript 操作码是否算是一个 bug？]({{bse}}130785) Antoine Poinsot 解释说，虽然任何花费策略都可以表达为“每条路径一个 [taproot][topic taproot] 叶子”，但这并不总是编码效率最高的方式。取决于路径数量及每条路径的使用频率，在单个 [tapscript][topic tapscript] 叶子中使用 `OP_IF`，有时会比将路径分拆到多个叶子中，或切换到 P2WSH 产生更小的花费数据。

- [为什么禁止在 tapscript 中使用 `OP_IF` 会是个问题？]({{bse}}130815) Murch 指出，由于一个 taproot 输出是以哈希形式承诺其叶子脚本，因此不可能知道哪些现有 UTXO 依赖于 `OP_IF`，例如基于 [miniscript][topic miniscript] 的降级多重签名钱包。拥有这类设置的用户可能会在激活之后无意间把新收到的资金锁死，因为相应的花费路径将不再有效。

- [软分叉是否总会成功？]({{bse}}130775) Murch 讲解了一种场景：采用强制信号机制的[软分叉][topic soft fork activation]只得到少数算力支持，在这种情况下，发信号的那条链会在工作量证明上落后并停滞，而不是迫使网络其他部分接受新规则。

- [如何设置 Bitcoin Core，才能在 2026 年 8 月 BIP110 激活之后挖出一个有效区块？]({{bse}}130770) Antoine Poinsot 指出，Bitcoin Core 不会强制执行 BIP110 规则，也没有功能可以构建一个排除 BIP110 所视为无效交易的区块模板。想要挖出符合 BIP110 的区块，节点运营者需要使用外部区块模板构建软件来选择交易，或者直接挖空区块。

- [处于较低难度分支上的 BIP110 区块是否有效？]({{bse}}130827) Pieter Wuille 区分了“链是有效的”和“链是活跃的”这两个概念。每个分支的难度调整只取决于其自身的区块，因此一个可能更慢的 BIP110 分支，对遵循当前规则的节点而言仍然是有效的；但除非它累积的总工作量证明超过主链，否则这些节点永远不会将其视为活跃链。

- [比特币测试网络背后的故事是什么？]({{bse}}130806) Murch 和 Antoine Poinsot 回顾了 [testnet][topic testnet] 从 testnet1 到拟议中的 testnet5 的历史，包括每次网络被赋予经济价值后所进行的重置，以及导致 testnet3 反复出现区块风暴的“20 分钟难度例外规则”（见[周报 #311][news311 block storm]）。

- [为什么 `-datacarriersize` 在 2022 年被重新定义，而 2023 年扩大它的提案没有被合并？]({{bse}}128027) 这是对去年首次作答问题的再次补充，Murch 新增了一份互补性回答，说明自 Bitcoin Core 0.10.0 引入以来，`datacarrier` 和 `datacarriersize` 选项一直仅指 `OP_RETURN` 输出，并引用了原始代码和发行说明作为依据。

- [Bitcoin Core 31.0 中，钱包是否禁止由 26 笔未确认交易组成的链？]({{bse}}130777) Pol Espinasa 澄清说，交易池本身在新的[族群交易池][topic cluster mempool]限制下允许更长的链，但 Bitcoin Core 钱包在币选择时仍然强制执行 25 笔交易上限，因此更长的链必须在不借助钱包的情况下构造。

- [Bitcoin Core 29.0 中是否有影响内存使用的变更？]({{bse}}127887) Antoine Poinsot 澄清说，表面上的增长是统计口径造成的假象，而不是进程内存使用真的更高。Bitcoin Core 29.0 会在空闲内存可用时让其 chainstate 数据库缓存更多数据，而当其他进程需要内存时，这部分缓存会被释放。

- [Bitcoin Core 的发布节奏是什么？]({{bse}}130817) Murch 介绍说，Bitcoin Core 现在会在每年 4 月和 10 月按固定节奏发布主要版本，取代此前以“前一个版本发布后约六个月”为目标、时间表可能延后的做法。小版本则继续按需发布 bug 修复。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [LDK v0.1.10][] 是这个用于构建支持闪电网络的钱包和应用的库的一个维护版本。它修复了若干拒绝服务漏洞和一个净化问题，以及影响异步通道监视器持久化、Electrum 同步、[BOLT12 要约][topic offers]验证、洋葱消息处理、[MPP][topic multipath payments] [keysend][topic spontaneous payments] [HTLC][topic htlc] 以及基于路由的支付发送的若干 bug。

- [LDK v0.2.3][] 是这个用于构建支持闪电网络的钱包和应用的库的一个维护版本。它修复了若干安全问题，包括拒绝服务漏洞、锚点通道的储备金计算错误以及一个净化问题，同时还修复了影响异步通道监视器持久化、LSPS 处理、[零手续费承诺通道][topic v3 commitments]、BOLT12 要约、洋葱消息以及 rapid gossip sync 内存使用的若干 bug。

- [BTCPay Server 2.4.0][] 是这个自托管支付处理器的一个版本发布。它增加了全局搜索、passkey 身份鉴别、引导式多重签名钱包设置、更细粒度的钱包权限、订阅和 POS 机改进、钱包交易搜索与过滤、插件生态改进以及更新后的闪电网络支持，同时移除了若干已弃用的闪电网络后端。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35070][] 防止重复条目被加入 `m_blocks_unlinked`。这是一个验证内部数据结构，用于追踪那些已经下载、但由于缺少更早区块数据而暂时无法连接的区块。此前，一个面对深度重组的修剪节点可能会意外向该结构加入重复条目，导致 `ReceivedBlockTransactions()` 在收到缺失数据后，对同一个区块重复 reconsider，并在修改其 `nSequenceId` 后再次将它加入 `setBlockIndexCandidates`。这可能破坏候选链尖集合在内存中的排序，从而导致未定义行为。该 PR 通过新的 `AddUnlinkedBlock()` 辅助函数统一插入流程，以去重条目，并强化 `CheckBlockIndex()`，确保其中不存在重复。

- [Bitcoin Core #35182][]、[#34411][bitcoin core #34411] 用 Bitcoin Core 自行维护的一套新 HTTP 与套接字处理实现，替换了基于 libevent 的 HTTP 服务器（用于 RPC 和 REST）。新的服务器运行自己的 I/O 线程、直接处理套接字，并将接收到的请求分发给现有 HTTP worker 池。后续 PR 移除了剩余的 libevent 构建、CI、依赖项和 CMake 相关配置。这些变更延续了该项目减少外部依赖、简化从源码构建 Bitcoin Core 的努力。

- [BIPs #2198][] 更新了 [BIP360][] 的 P2MR 提案（见[周报 #393][news393 p2mr]）：任何知道并揭示深度为零的脚本树中的单个叶子的人，都可以在不执行该脚本的情况下花费该输出。这一设计有意让单路径 P2MR 输出变得不安全：一旦用户在尝试花费时揭示该叶子，矿工就可以利用同样已揭示的叶子把输出花到自己手里。该变更意在阻止钱包为了节省见证字节，而省略[后量子][topic quantum resistance]或其他后备叶子。

- [LDK #4713][] 为 Rapid Gossip Sync（RGS）增加了拒绝服务加固（见[周报 #308][news308 rgs]）；RGS 是 LDK 用来快速导入闪电网络 gossip 数据的格式。文档现在警告说，RGS 数据源应被视为“半可信”的，因为它们可以通过省略数据阻止路径查找成功，也可能试图膨胀客户端的网络图。LDK 现在会拒绝节点或通道更新数量明显荒谬的快照；并且一旦网络图中包含的通道数量超过预期值的十倍，就会跳过添加新的[通道公告][topic channel announcements]。

- [LDK #4684][] 修复了一个罕见的异步签名器与通道监视器排序 bug：重连后可能会发送重复的 `revoke_and_ack`。此前，如果某条被签名器解除阻塞的路径在监视器更新仍处于待处理状态时重新生成并发送了一个应发送的 `revoke_and_ack`，那么之后由监视器恢复的路径可能再次生成相同消息，导致对等节点拒绝重复的 secret 并强制关闭。现在，当签名器待处理路径返回一个 `revoke_and_ack` 时，LDK 会清除监视器待处理的 `revoke_and_ack` 标志，因为这一消息也同时满足了监视器待处理的重发要求。

{% include snippets/recap-ad.md when="2026-06-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2198,34411,35070,35182,4684,4713" %}

[news311 block storm]: /zh/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[lnd gossip dos delving]: https://delvingbitcoin.org/t/lnd-zero-timestamp-gossip-dos-disclosure/2621
[news393 lnd 0201]: /zh/newsletters/2026/02/20/#lnd-0-20-1-beta
[LDK v0.1.10]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.10
[LDK v0.2.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.3
[BTCPay Server 2.4.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.0
[news393 p2mr]: /zh/newsletters/2026/02/20/#bips-1670
[news308 rgs]: /zh/newsletters/2024/06/21/#ldk-3098
