---
title: 'Bitcoin Optech 周报 #402'
permalink: /zh/newsletters/2026/04/24/
name: 2026-04-24-newsletter-zh
slug: 2026-04-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了 Hornet Node 团队在使用声明式、可执行的方式来定义共识规则方面所做的工作，并总结了一场关于闪电网络中洋葱消息阻塞攻击的讨论。此外还包括我们的常规栏目：来自 Bitcoin Stack Exchange 的精选问答、新版本和候选版本的公告，以及流行比特币基础设施软件的重要变更摘要。

## 新闻

- **<!--hornet-nodes-declarative-executable-specification-of-bitcoin-consensus-rules-->****Hornet Node 对比特币共识规则的声明式可执行规范：** Toby Sharp 在 Delving Bitcoin 和 Bitcoin-Dev [邮件列表][hornet ml post]上[发帖][topic hornet update]，介绍了 Hornet 节点项目的最新进展。Sharp 此前曾[介绍过][topic hornet]一种新的节点实现 Hornet，它将初始区块下载时间从 167 分钟缩短到了 15 分钟。在这次更新中，他报告说，自己已经完成了对非脚本类区块验证规则的声明式规范；该规范由 34 条语义不变量构成，并使用一种简单的代数方式组合起来。

  Sharp 还概述了未来的工作，包括将这一规范扩展到脚本验证，并回应 Eric Voskuil 的反馈，讨论了与 libbitcoin 等其他实现进行比较的可能性。

- **<!--onion-message-jamming-in-the-lightning-network-->****闪电网络中的洋葱消息阻塞攻击：** Erick Cestari 在 Delving Bitcoin 上[发帖][onion del]，讨论影响闪电网络的[洋葱消息][topic onion messages]阻塞问题。BOLT4 已承认洋葱消息本身并不可靠，并建议采用速率限制技术。按照 Cestari 的说法，恰恰是这些技术让消息阻塞成为可能。攻击者可以启动恶意节点，并向网络洪泛垃圾消息，触发对等节点的速率限制，迫使它们丢弃合法消息。此外，BOLT4 并未强制规定消息长度上限，这使攻击者可以最大化单条消息的传播范围。

  Cestari 回顾了几种缓解洋葱消息阻塞的方案，并对他认为较合适的技术作了全面概述：

  * *预付手续费*：这种技术最早由 Carla Kirk-Cohen 在 [BOLTs #1052][] 中提出，用作解决通道阻塞的一种方案，但也很容易扩展到这里。节点会公布按每条消息收取的固定手续费；该手续费会被包含在洋葱负载中，并在每一跳被扣除。如果手续费未支付，节点就会直接丢弃该消息。这种方法也有一些局限，例如消息只能被转发给通道对等节点，而且会增加 p2p 开销。

  * *基于通道余额的跳数限制与权益证明*：这项技术由阿尔伯塔大学的 Bashiri 和 Khabbazian [提出][mitig2 onion]，包含两个不同组成部分：

    * 限制跳数：要么对消息可经过的最大跳数设定硬上限（例如 3 跳），要么要求发送者求解一个工作量证明谜题，而该谜题的难度会随着跳数增加而呈指数级上升。

    * 基于权益证明的转发规则：每个节点根据对等节点聚合后的通道余额来设置针对每个对等节点的速率限制，从而让资金更充足的节点获得更强的转发能力。

    这种方法的权衡在于，它会带来中心化压力，因为较大的节点更有优势；与此同时，3 跳的硬上限还可能缩小匿名集。

  * *按带宽计量的支付*：这项技术由 Olaoluwa Osuntokun [提出][mitig3 onion]，其适用范围与预付手续费类似，但增加了按会话保存的状态，并通过 [AMP 支付][topic amp]来结算。发送者会先发送 AMP 支付，在每个中间步骤支付手续费，并交付一个会话 ID。随后，发送者会在洋葱消息中包含该 ID。该方法已知的局限包括：消息仍然只能转发给通道对等节点，而且同一会话中的所有消息都有可能被关联起来。

  * *基于回传传播的速率限制*：这种方法由 Bastien Teinturier [提出][mitig4 onion]，使用一种回压机制，能够以统计意义上的方式追溯垃圾消息的来源。当针对每个对等节点的速率限制被触发时，节点会向发送者回送一条丢弃消息；发送者随后再把这条消息转发给最后一个转发原始消息的对等节点，并将其速率限制减半。虽然这种方法能以统计意义识别出真正的发送者，但错误的对等节点也可能受到惩罚。此外，攻击者还可以伪造这类丢弃消息，从而降低诚实节点的速率限制。

  最后，Cestari 邀请闪电网络开发者参与讨论，并表示在类似 [Tor 最近遭遇的情况][tor issue]那样的长期 DDoS 攻击命中网络之前，仍然还有一个时间窗口可以缓解这一问题。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选场所之一——当然，也是我们在有一些空闲时间时帮助好奇或困惑用户的地方。在这个每月栏目中，我们会重点介绍自上次更新以来得票较高的一些问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [为什么 BIP342 要用一个新操作码取代 CHECKMULTISIG，而不是仅仅移除其中的 FindAndDelete？]({{bse}}130665)
  Pieter Wuille 解释说，在 [tapscript][topic tapscript] 中用 `OP_CHECKSIGADD` 取代 `OP_CHECKMULTISIG`，是为了让未来潜在的协议变更能够支持对 [schnorr][topic schnorr signatures] 签名进行批量验证（见[周报 #46][news46 batch]）。

- [SIGHASH_ANYPREVOUT 承诺的是 tapleaf 哈希值，还是完整的 taproot 默克尔路径？]({{bse}}130637)
  Antoine Poinsot 确认，[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 签名目前只承诺 tapleaf 哈希值，而不承诺 [taproot][topic taproot] 树中的完整默克尔路径。不过，这一设计仍在讨论中，因为有一位 BIP 联合作者建议改为承诺完整的默克尔路径。

- [在 MuSig2 闪电网络通道中，除地址格式外，BIP86 tweak 还保证了什么？]({{bse}}130652)
  Ava Chow 指出，这个 tweak 能阻止隐藏脚本路径的使用，因为 [MuSig2][topic musig] 的签名协议要求所有参与者都应用同一个 [BIP86][] tweak，签名聚合才能成功。如果某一方试图使用不同的 tweak，比如从隐藏脚本树导出的 tweak，那么它的部分签名就无法聚合成有效的最终签名。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 31.0][] 是网络中占主导地位的全节点实现的最新主要版本。[发行说明][notes31]介绍了多项重要改进，包括实现了 [族群交易池][topic cluster mempool]设计，为 `sendrawtransaction` 增加了新的 `-privatebroadcast` 选项（见[周报 #388][news388 private]），将 `asmap` 数据可选地嵌入到二进制文件中以防御[日蚀攻击][topic eclipse attacks]，以及在至少拥有 4096 MiB RAM 的系统上，将默认的 `-dbcache` 提升到 1024 MiB，此外还有许多其他更新。

- [Core Lightning 26.04][] 是这一流行闪电网络节点实现的一个主要版本。它默认启用了[拼接][topic splicing]，增加了新的 `splicein` 和 `spliceout` 命令，其中包括一种 `cross-splice` 模式，可将第二条通道作为 splice-out 的目标位置；重新设计了 `bkpr-report` 用于收入汇总；在 `askrene` 中增加了并行路径查找和多项 bug 修复；在 `offer` RPC 中新增了 `fronting_nodes` 选项和 `payment-fronting-node` 配置；并移除了对旧式洋葱格式的支持。更多细节请见[发行说明][notes cln]。

- [LND 0.21.0-beta.rc1][] 是这一流行闪电网络节点下一个主要版本的首个候选版本。对于使用 `--db.use-native-sql` 标志并搭配 SQLite 或 PostgreSQL 后端运行节点的用户，需要注意此版本会将支付存储从键值（KV）格式迁移到原生 SQL；如果希望退出这一迁移，可使用 `--db.skip-native-sql-migration`。详见其[发行说明][notes lnd]。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #33477][] 更新了 `dumptxoutset` RPC 的 `rollback` 模式（见[周报 #72][news72 dump]）构建历史 UTXO 集转储的方式，这种转储会用于 [assumeUTXO][topic assumeutxo] 快照。Bitcoin Core 不再通过使区块失效来回滚主 chainstate，而是创建一个临时 UTXO 数据库，将其回滚到请求的区块高度，然后从这个临时数据库写出快照。这样可以保留主 chainstate，消除了暂停网络活动以及回滚过程受到分叉相关干扰的需要，但代价是需要额外的临时磁盘空间，而且转储速度会更慢。新的 `in_memory` 选项会让临时 UTXO 数据库完全驻留在 RAM 中，使回滚更快，但在主网上需要超过 10 GB 的空闲内存。对于深度回滚，建议不要设置 RPC 超时（`bitcoin-cli -rpcclienttimeout=0`），因为这可能需要数分钟。

- [Bitcoin Core #35006][] 为 `bitcoin-cli` 增加了 `-rpcid` 选项，可将 JSON-RPC 请求的 `id` 设置为自定义字符串，而不再使用默认硬编码的 `1`。这使得在多个客户端并发发起调用时，可以对请求与响应进行对应。这个标识符也会被写入服务端的 RPC 调试日志中。

- [BIPs #1895][] 发布了 [BIP361][]；这是一个关于[后量子][topic quantum resistance]迁移以及逐步淘汰旧签名方案的抽象提案。该提案假设某种独立的后量子（PQ）签名方案已经完成标准化并被部署，在此基础上，它描述了一条分阶段迁移、逐步弃用 ECDSA/[schnorr][topic schnorr signatures] 签名方案的路径。当前版本分为两个阶段。A 阶段禁止将资金发送到易受量子攻击的地址，从而加速采用 PQ 地址类型。B 阶段限制使用 ECDSA/schnorr 来花费资金，并包含一种量子安全的救援协议，以防止易受量子攻击的 UTXO 被盗。

- [BIPs #2142][] 更新了 [BIP352][] 这一[静默支付][topic silent payments] BIP 提案，增加了一组发送/接收测试向量，用于覆盖这样一种边界情形：输入密钥的运行中求和在前两个输入后恰好变成零，但对全部输入求和后的最终结果又是非零。这可以捕捉那些在增量求和过程中提早拒绝，而不是先对全部输入完成求和的实现。

- [LDK #4555][] 修复了转发节点执行 [`max_cltv_expiry`][topic cltv expiry delta] 约束的方式，该字段适用于[盲化支付路径][topic rv routing]。它的设计目的是确保已经过期的盲化路由会在引入跳处被拒绝，而不是被继续转发穿过盲化路径段，直到更接近接收者时才失败。此前，LDK 会拿这一约束去比较该跳的传出 CLTV 值；现在则会按照原本意图，检查传入的 CLTV 到期值。

- [LND #10713][] 为传入的[洋葱消息][topic onion messages]增加了按对等节点和全局两个层面的令牌桶速率限制，在流量进入时就丢弃超额流量，避免其抵达洋葱消息处理器。这强化了 LND 最近新增的洋葱消息转发支持（见[周报 #396][news396 lnd onion]），使其更能抵御来自高速对等节点的大流量滥用。按对等节点与全局拆分的设计，沿用了 LND 早先对 gossip 带宽限制的做法（见[周报 #370][news370 lnd gossip]）。

- [LND #10754][] 在选中的下一跳恰好是交付该[洋葱消息][topic onion messages]的同一对等节点时，会停止继续转发该消息，从而避免在同一连接上立即发生反弹。

{% include snippets/recap-ad.md when="2026-04-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1052,33477,35006,4555,10713,10754,1895,2142" %}
[news46 batch]: /zh/newsletters/2019/05/14/#new-script-based-multisig-semantics
[topic hornet update]: https://delvingbitcoin.org/t/hornet-update-a-declarative-executable-specification-of-consensus-rules/2420
[hornet ml post]: https://groups.google.com/g/bitcoindev/c/M7jyQzHr2g4
[topic hornet]: /zh/newsletters/2026/02/06/#a-constant-time-parallelized-utxo-database
[onion del]: https://delvingbitcoin.org/t/onion-message-jamming-in-the-lightning-network/2414
[mitig2 onion]: https://ualberta.scholaris.ca/items/245a6a68-e1a6-481d-b219-ba8d0e640b5d
[mitig3 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-February/003498.txt
[mitig4 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-June/003623.txt
[tor issue]: https://blog.torproject.org/tor-network-ddos-attack/
[Bitcoin Core 31.0]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[notes31]: https://bitcoincore.org/en/releases/31.0/
[news388 private]: /zh/newsletters/2026/01/16/#bitcoin-core-29415
[Core Lightning 26.04]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[notes cln]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[LND 0.21.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta.rc1
[notes lnd]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.21.0.md
[news72 dump]: /zh/newsletters/2019/11/13/#bitcoin-core-16899
[news396 lnd onion]: /zh/newsletters/2026/03/13/#lnd-10089
[news370 lnd gossip]: /zh/newsletters/2025/09/05/#lnd-10103
