---
title: 'Bitcoin Optech Newsletter #324'
permalink: /zh/newsletters/2024/10/11/
name: 2024-10-11-newsletter-zh
slug: 2024-10-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报宣布了影响旧版本 Bitcoin Core 全节点的三个漏洞，宣布了一个影响旧版本 btcd 全节点的单独漏洞，并指向到了为 Optech 贡献的一份指南。该指南描述了如何使用 Bitcoin Core 28.0 中 P2P 网络的多项新功能。此外还包括我们常规的部分，总结了一次 Bitcoin Core PR 审核俱乐部会议、新版本和候选版本的公告，以及对流行的比特币基础设施软件的重要变更描述。

## 新闻

- **<!--disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-prior-to-25-0-->披露影响 Bitcoin Core 25.0 之前版本的漏洞：**
  Niklas Gögge 在 Bitcoin-Dev 邮件列表中[发布][gogge corevuln]了三个漏洞的公告链接。这些漏洞影响了 2024 年 4 月之后已结束生命周期的 Bitcoin Core 版本。

  - [<!--cve-2024-35202-remote-crash-vulnerability-->CVE-2024-35202 远程崩溃漏洞][CVE-2024-35202 remote crash vulnerability]: 攻击者可以发送一个精心设计的[致密区块][topic compact block relay]消息，使得区块重建失败。即使诚实地使用协议，有时也会重建失败，接收节点就会请求完整的区块。

    然而，攻击者可以不回复完整区块，而是为同一个区块头发送第二个致密区块消息。在 Bitcoin Core 25.0 之前，这会导致节点崩溃，因为代码的设计会防止在同一个致密区块会话上重复运行致密区块重建的代码。

    这个易被利用的漏洞可能被用来使任何 Bitcoin Core 节点崩溃，并且作为其他攻击中的一个环节来窃取用户的资金。例如，一个崩溃的 Bitcoin Core 节点将无法警告连接的闪电网络节点，通道对手正试图窃取资金。

    这个漏洞由 Niklas Gögge 发现、[进行了负责任地披露][topic responsible disclosures]并修复。修复[方案][bitcoin core #26898]在 Bitcoin Core 25.0 中发布。

  - [<!--dos-from-large-inventory-sets-->大型库存集导致的拒绝服务攻击][DoS from large inventory sets]: 对于每个对等节点，Bitcoin Core 节点保留一个要发送给该对等节点的交易列表。列表中的交易根据它们的费率和它们之间的关系进行排序，以确保最佳交易快速中继，并使探测中继网络拓扑变得更加困难。

    然而，在 2023 年 5 月的网络活动激增期间，几个用户开始注意到他们的节点使用了过多的 CPU。开发者 0xB10C 确认该问题是由于 CPU 被排序函数消耗。开发者 Anthony Towns 做了进一步调查并[修复][bitcoin core #27610]了这个问题。实现方法是确保交易以可变费率离开队列，因为费率会在需求高企时增加。这个修复包含在 Bitcoin Core 25.0 中。

  - [<!--slow-block-propagation-attack-->慢速区块传播攻击][slow block propagation attack]: 在 Bitcoin Core 25.0 之前，来自攻击者的无效区块可能会阻止 Bitcoin Core 继续处理来自诚实对等节点的具有相同区块头的有效区块。这会影响到需要请求额外交易的致密区块重建：因为如果节点从不同的对等节点收到无效区块，它会不再等待交易。即使后来收到了交易，节点也会忽略它们。

    在 Bitcoin Core 拒绝无效区块（并可能断开发送它的对等节点的连接）之后，它会重新开始尝试从其他对等节点请求区块。多个攻击对等节点就可以使它长时间处在这个循环中。不是攻击者的故障节点也可能意外触发这种相同的行为。

    <!-- 我之前已确认他们希望被称呼为"ghost43"（全小写） -->

    这个问题是在几位开发者（包括 William Casarin 和 ghost43）报告他们的节点出现问题后被发现的。几位其他开发者进行了调查，Suhas Daftuar 排查出了这个漏洞。Daftuar 还[修复][bitcoin core #27608]了它，方法是防止任何对等节点影响其他对等节点的下载状态，除非区块已通过验证并存储到磁盘。这个修复包含在 Bitcoin Core 25.0 中。

- **<!--CVE-2024-38365-btcd-consensus-failure-->****CVE-2024-38365 btcd 共识失败：** 如[上周的周报][news323 btcd]所宣布的，Antoine Poinsot 和 Niklas Gögge [披露][pg btcd]了一个影响 btcd 全节点的共识失败漏洞。在传统的比特币交易中，签名存储在签名脚本字段中。然而，签名也承诺了签名脚本字段。签名不可能承诺自身，所以签名者会承诺到签名脚本字段中除签名之外的所有数据。验证者必须相应地在检查签名承诺的准确性之前移除签名。

  Bitcoin Core 的移除签名函数 `FindAndDelete` 只从签名脚本中移除签名的精确匹配。btcd 实现的函数 `removeOpcodeByData` 移除签名脚本中 _任何_ 包含签名的数据。这可能导致 btcd 在验证承诺之前从签名脚本中移除比 Bitcoin Core 更多的数据，导致一个程序认为承诺有效而另一个认为无效。任何包含无效承诺的交易都是无效的，任何包含无效交易的区块也都是无效的，这会打破 Bitcoin Core 和 btcd 之间的共识。失去共识的节点可能被欺骗接受无效交易，并且可能看不到已被网络其余部分确认的最新交易。这两种情况都可能导致大量资金损失。

  Poinsot 和 Gögge 的负责任披露使得 btcd 维护者秘密地修复了漏洞，并在大约三个月前发布了包含了修订代码的 0.24.2 版本。

- **<!--guide-for-wallet-developers-using-bitcoin-core-28-0-->****使用 Bitcoin Core 28.0 的钱包指南：** 如[上周的周报][news323 bcc28]所提到的，新发布的 Bitcoin Core 28.0 版本包含了几个 P2P 网络的新功能，包括一父一子（1P1C）[包中继][topic package relay]、确认前拓扑受限（[TRUC][topic v3 transaction relay]）的交易中继、[包 RBF][topic rbf] 和[亲属间驱逐][topic kindred rbf]，以及标准的支付到锚点（[P2A][topic ephemeral anchors]）输出脚本类型。这些新功能可以显著提高几个常见用例的安全性和可靠性。

  Gregory Sanders 为 Optech 编写了一份[指南][sanders guide]，针对使用 Bitcoin Core 创建或广播交易的钱包和其他软件的开发者。该指南介绍了几个功能的使用，并描述了这些功能如何对多个协议有用，包括简单支付和 RBF 费用提升、闪电网络承诺交易和 [HTLC][topic htlc] 交易、[Ark][topic ark] 和[闪电通道拼接][topic splicing]。

## Bitcoin Core PR 审核俱乐部

**在这个月度部分，我们总结了最近一次 [Bitcoin Core PR 审核俱乐部会议][Bitcoin Core PR Review Club]会议，标出了一些重要的问题和答案。点击下面的问题以查看会议的答案摘要。*

[添加 getorphantxs][review club 30793] 是 [tdb3][gh tdb3] 提出的一个 PR。它添加了一个新的实验性 RPC 方法 `getorphantxs`。由于它主要面向开发者，所以是隐藏的。这个新方法为调用者提供了当前所有孤儿交易的列表，这在检查孤儿交易的行为、场景（例如在功能测试如 `p2p_orphan_handling.py` 中）或为统计、可视化提供额外数据时很有帮助。

{% include functions/details-list.md
  q0="<!--what-is-an-orphan-transaction-at-what-point-do-transactions-enter-the-orphanage-->什么是孤儿交易？交易在什么时候进入孤儿交易池？"
  a0="孤儿交易是其输入引用未知或缺失的父交易的交易。当从对等节点接收到交易但在 `ProcessMessage` 中验证失败并返回 `TX_MISSING_INPUTS` 时，交易进入孤儿交易池。"
  a0link="https://bitcoincore.reviews/30793#l-16"
  q1="<!--what-commands-can-you-run-to-get-a-list-of-available-rpcs-->你可以运行什么命令来获取可用的 RPC 列表？"
  a1="`bitcoin-cli help` 提供了可使用的 RPC 列表。注意：由于 `getorphantxs` 被[标记隐藏][gh getorphantxs hidden]，作为仅供开发者使用的 RPC，所以它不在这个列表中。"
  a1link="https://bitcoincore.reviews/30793#l-26"
  q2="<!--if-an-rpc-has-a-non-string-arguments-does-anything-special-need-to-be-done-to-handle-it-->如果一个 RPC 有非字符串参数，是否需要做任何特殊处理？"
  a2="非字符串 RPC 参数必须添加到 `src/rpc/client.cpp` 中的 `vRPCConvertParams` 列表中，以确保类型转换正确。"
  a2link="https://bitcoincore.reviews/30793#l-72"
  q3="<!--what-is-the-maximum-size-of-the-result-from-this-rpc-is-there-a-limit-to-how-many-orphans-are-retained-is-there-a-limit-to-how-long-orphans-can-stay-in-the-orphanage-->这个 RPC 返回的大小最大是多少？可保留的孤儿交易数量是否有限制？孤儿交易在孤儿交易池中停留的时间是否有限制？"
  a3="孤儿交易的最大数量是 100（`DEFAULT_MAX_ORPHAN_TRANSACTIONS`）。在 `verbosity=0` 时，每个 txid 是一个 32 字节的二进制值，但当为 JSON-RPC 结果进行十六进制编码时，它变成一个 64 字符的字符串（因为每个字节由两个十六进制字符表示）。这意味着最大结果大小约为 6.4 kB（100 个 txid * 64 字节）。<br><br>
  在 `verbosity=2` 时，十六进制编码的交易是结果中最大的字段，所以为了简单起见，我们在这个计算中忽略其他字段。交易的最大序列化大小可以达到 400 kB（在近乎不可能的极端情况下，它只包含见证数据），或者十六进制编码后为 800 kB。因此，最大结果大小约为 80 MB（100 个交易 * 800 kB）。<br><br>
  孤儿交易有时间限制，20 分钟后会被移除，这由 `ORPHAN_TX_EXPIRE_TIME` 定义。"
  a3link="https://bitcoincore.reviews/30793#l-94"
  q4="<!--since-when-has-there-been-a-maximum-orphanage-size-->孤儿交易池大小的最大值是从什么时候开始有的？"
  a4="`MAX_ORPHAN_TRANSACTIONS` 变量早在 2012 年的提交 [142e604][gh commit 142e604] 中引入。"
  a4link="https://bitcoincore.reviews/30793#l-105"
  q5="<!--using-the-getorphantxs-rpc-would-we-be-able-to-tell-how-long-a-transaction-has-been-in-the-orphanage-if-yes-how-would-you-do-it-->使用 `getorphantxs` RPC，我们能否知道一个交易在孤儿交易池中停留了多长时间？如果能，是如何做的？"
  a5="是的，通过使用 `verbosity=1`，你可以获得每个孤儿交易的过期时间戳。减去 `ORPHAN_TX_EXPIRE_TIME`（即 20 分钟）就得到了进入孤儿交易池的时间。"
  a5link="https://bitcoincore.reviews/30793#l-128"
  q6="<!--using-the-getorphantxs-rpc-would-we-be-able-to-tell-what-the-inputs-of-an-orphan-transaction-are-if-yes-how-would-you-do-it-->使用 `getorphantxs` RPC，我们能否知道孤儿交易的输入是什么？如果能，是如何做的？"
  a6="是的，使用 `verbosity=2`，RPC 会返回十六进制的原始交易，然后可以使用 `decoderawtransaction` 解码以显示其输入。"
  a6link="https://bitcoincore.reviews/30793#l-140"
%}

## 发布和候选发布

*流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Inquisition 28.0][] 是这个 [signet][topic signet] 全节点的最新版本，设计用于实验提议的软分叉和其他重大协议变更。更新后的版本是基于最近发布的 Bitcoin Core 28.0。

- [BDK 1.0.0-beta.5][] 是这个用于构建钱包和其他启用比特币功能的应用程序的库的候选版本（RC）。这个最新的 RC 版本“默认启用 RBF”，更新了 `bdk_esplora` 客户端以重试因速率限制而失败的服务器请求，并添加了 `bdk_electrum` crate 的 use-openssl 功能。

## 重要代码和文档变更

_本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Core Lightning #7494][] 为 `channel_hints` 引入了 2 小时的生命周期，允许从支付中学习到的路径查找信息在未来的尝试中被重用，以跳过不必要的尝试。被认为是不可用的通道将逐渐恢复，并在 2 小时后完全可用，以确保过时的信息不会导致可能已经恢复的路由被跳过。

- [Core Lightning #7539][] 添加了一个 `getemergencyrecoverdata` RPC 命令，用于从 `emergency.recover` 文件中获取和返回数据。这将允许使用 API 的开发者在他们的应用程序中添加钱包备份功能。

- [LDK #3179][] 引入了新的 `DNSSECQuery` 和 `DNSSECProof` [洋葱消息][topic onion messages]，以及一个 `DNSResolverMessageHandler` 来处理这些消息，作为实现 [BLIP32][] 的核心功能。这个 PR 还添加了一个 `OMNameResolver`，用于验证 DNSSEC 证明并将它们转换为 [offer][topic offers]。参见周报 [#306][news306 blip32]。

- [LND #8960][] 通过覆盖一层 taproot 成为一种新的实验性通道类型来实现自定义通道功能。这与[简单 taproot 通道][topic simple taproot channels]相同，但在通道脚本的 [tapscript][topic tapscript] 叶子中提交额外的元数据。更新了主要的通道状态机和数据库，以处理和存储自定义 tapscript 叶子。必须设置配置选项 `TaprootOverlayChans` 以启用对 taproot 覆盖通道的支持。自定义通道计划增强了 LND 对 [taproot asset][topic client-side validation]的支持。参见周报 [#322][news322 customchans]。

- [Libsecp256k1 #1479][] 添加了一个 [MuSig2][topic musig] 模块，用于 [BIP340][] 兼容的多重签名方案，如 [BIP327][] 中所规定。这个模块几乎与 [secp256k1-zkp][zkpmusig2] 中实现的模块相同，但有一些小的变化，比如移除了对[适配器签名][topic adaptor signatures]的支持，使其成为非实验性的。

- [Rust Bitcoin #2945][] 通过添加 `TestNetVersion` 枚举，重构代码，并包含 testnet4 所需的参数和区块链常量，引入了对 [testnet4][topic testnet] 的支持。

- [BIPs #1674][] 撤销了 [周报 #323][news323 bip85] 中描述的对 [BIP85][] 规范的更改。这些更改破坏了与已部署版本协议的兼容性。PR 上的讨论支持为重大更改创建一个新的 BIP。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7494,7539,3179,8960,1479,2945,1674,26898,27610,27608" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[news323 bip85]: /zh/newsletters/2024/10/04/#bips-1600
[sanders guide]: /zh/bitcoin-core-28-wallet-integration-guide/
[gogge corevuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2df30c0a-3911-46ed-b8fc-d87528c68465n@googlegroups.com/
[cve-2024-35202 remote crash vulnerability]: https://bitcoincore.org/en/2024/10/08/disclose-blocktxn-crash/
[dos from large inventory sets]: https://bitcoincore.org/en/2024/10/08/disclose-large-inv-to-send/
[slow block propagation attack]: https://bitcoincore.org/en/2024/10/08/disclose-mutated-blocks-hindering-propagation/
[news323 btcd]: /zh/newsletters/2024/10/04/#impending-btcd-security-disclosure
[pg btcd]: https://delvingbitcoin.org/t/cve-2024-38365-public-disclosure-btcd-findanddelete-bug/1184
[news323 bcc28]: /zh/newsletters/2024/10/04/#bitcoin-core-28-0
[bitcoin inquisition 28.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.0-inq
[review club 30793]: https://bitcoincore.reviews/30793
[gh tdb3]: https://github.com/tdb3
[gh getorphantxs hidden]: https://github.com/bitcoin/bitcoin/blob/a9f6a57b6918b2f92c7d6662e8f5892bf57cc127/src/rpc/mempool.cpp#L1131
[gh commit 142e604]: https://github.com/bitcoin/bitcoin/commit/142e604184e3ab6dcbe02cebcbe08e5623182b81
[news306 blip32]: /zh/newsletters/2024/06/07/#blips-32
[news322 customchans]: /zh/newsletters/2024/09/27/#lnd-9095
[zkpmusig2]: https://github.com/BlockstreamResearch/secp256k1-zkp
