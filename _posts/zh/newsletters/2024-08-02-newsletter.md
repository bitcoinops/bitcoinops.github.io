---
title: 'Bitcoin Optech Newsletter #314'
permalink: /zh/newsletters/2024/08/02/
name: 2024-08-02-newsletter-zh
slug: 2024-08-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报披露了影响旧版本 Bitcoin Core 的两个漏洞，并总结了一种在使用族群交易池时优化矿工交易选择的提议的方法。此外还有我们的常规部分：其中包括新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-22-0-->影响 Bitcoin Core 22.0 之前的早期版本的漏洞披露：**
  Niklas Gögge 在 Bitcoin-Dev 邮件列表中[发布了][goegge disclosure]两个影响旧版 Bitcoin Core 的漏洞公告链接，这些版本自 2022 年 10 月以来就已经停止支持。此公告紧随上个月对旧版漏洞的披露（见[周报 #310][news310 disclosure]）。我们在此总结了这些披露内容：

  - [通过发送过多的 `addr` 消息导致的远程崩溃][Remote crash by sending excessive `addr` messages]：在 Bitcoin Core 22.0(2021 年 9 月发布)之前，如果一个节点被告知超过 2<sup>32</sup> 个其他可能的节点，该节点会因 32 位计数器的耗尽而崩溃。攻击者可以通过发送大量 P2P `addr` 消息 (至少 400 万条消息)来实现这一点<!-- assuming 1,000 addresses per addr message -->。Eugene Siegel [负责任地披露了][topic responsible disclosures]该漏洞，并且在 Bitcoin Core 22.0 中包含了修复程序。在[周报 #159][news159 bcc22387]中，我们总结了该修复程序，当时并不知道它修复了一个漏洞。

  - [在本地网络上启用 UPnP 时导致的远程崩溃][Remote crash on local network when UPnP enabled]：在 Bitcoin Core 22.0 之前，启用 [UPnP][] 来自动配置 [NAT 遍历][NAT traversal](默认情况下已禁用，因之前的漏洞，见[周报 #310][news310 miniupnpc])的节点易受本地网络上恶意设备反复发送 UPnP 消息变体的攻击。每条消息都可能导致内存的额外分配，直到节点崩溃或被操作系统终止。Bitcoin Core 的依赖项 miniupnpc 中的无限循环错误由 Ronald Huveneers 报告给 miniupnpc 项目，Michael Ford 发现并负责任地披露了如何利用此漏洞让 Bitcoin Core 崩溃。该漏洞的修复已包含在 Bitcoin Core 22.0 中。

  预计在几周内还会披露影响更新版本 Bitcoin Core 的其他漏洞。

- **<!--optimizing-block-building-with-cluster-mempool-->使用族群交易池优化区块构建：** Pieter Wuille 在 Delving Bitcoin 上[发表了][wuille selection]一篇关于确保矿工区块模板在使用[族群交易池][topic cluster mempool]时能包含最佳交易集的帖子。族群交易池的设计将相关交易的_族群_划分为有序的_块_列表，每个块遵循两个约束条件：

  1. 如果块中的任何交易依赖于其他未确认的交易，则这些其他交易必须是该块的一部分或出现在有序列表中更早的块中。

  2. 每个块必须具有在有序列表中与之后块的相同或更高的费率。

  这样，交易池中的每个族群块都可以按费率顺序放入一个单一列表中————从最高费率到最低费率。面对按照费率顺序“块”化的交易池，矿工可以通过简单地遍历每个块并将其包含在模板中，直到达到其期望的最大区块大小(通常略低于 1 百万 vbytes，以留出矿工的 coinbase 交易空间)来构建区块模板。

  然而，族群和块的大小各不相同，Bitcoin Core 中的族群默认上限约为 100,000 vbytes。这意味着，如果一个矿工在目标 998,000 vbytes 时已填充了 899,001 vbytes，则可能会遇到一个 99,000 vbytes 的块无法容纳，从而使其区块空间约有 10% 未被使用。矿工无法简单地跳过这个 99,000 vbytes 的块并尝试包括下一个块，因为下一个块可能包含依赖于这个 99,000 vbytes 块的交易。如果矿工未能在区块模板中包括依赖交易，则他们生产的区块将是无效的。

  为了解决这一极端案例，Wuille 描述了如何将大块分解为较小的_子块_，以根据它们的费率考虑是否纳入剩余的区块空间。通过移除任何现有块或至少拥有两个或更多交易的子块的最后一个交易，可以创建子块。这将始终产生至少一个比原始块更小的子块，有时可能会产生几个子块。Wuille 论证了块和子块的数量等于交易的数量，每个交易都属于一个唯一的块或子块。这样就可以预先计算每个交易的块或子块，称为该交易的_吸收集_，并将其与该交易相关联。Wuille 展示了现有的“分块”算法如何计算每个交易的吸收集。

  当矿工填充了所有可能的完整块后，可以为尚未包含在区块中的所有交易获取预先计算的吸收集，并按照费率顺序考虑它们。这样只需要对列表进行一次排序，列表中的元素数量与交易池中的交易数量相同(在当前默认情况下几乎总是少于 1 百万)。然后可以使用最佳费率的吸收集(块和子块) 来填补剩余的区块空间。这需要跟踪到目前为止已被包含的族群中的交易数量，并跳过任何不适合或已经有被包含一些交易的子块。

  尽管可以将块与块之间进行比较以确定区块包含的最佳顺序，但块或子块内的个别交易可能不会按照最佳顺序排列，这可能导致在区块几乎填满时出现非最优选择。例如，当仅剩 300 vbytes 时，算法可能会选择一个 200 vbytes 的交易，费率为 5 sats/vbyte(总计 1000 sats)，而不是选择两个 150 vbytes 的交易，费率为 4 sats/vbyte(总计 1200 sats)。

  Wuille 描述了预先计算的吸收集在这种情况下的特别有用之处：因为它们只需要跟踪每个族群中已包含的交易数量，因此可以轻松恢复到模板填充算法的较早状态，并替换先前的选择以查看是否可以收集更多的总费用。这允许实现一个[分支定界法][branch-and-bound]搜索，可以尝试多种组合来填充最后一点区块空间，以期找到比简单算法更好的结果。

- **<!--hyperion-network-event-simulator-for-the-bitcoin-p2p-network-->****比特币 P2P 网络事件模拟器 Hyperion：**
  Sergi Delgado 在 Delving Bitcoin 上[发布了][delgado hyperion]一篇关于[Hyperion][]帖子，这是一款他编写的网络模拟器，用于跟踪数据如何通过模拟的比特币网络传播。这个工作的初衷是为了比较比特币当前的交易公告传播方式 (`inv` 库存消息) 和提议的 [Erlay][topic erlay] 方法。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BDK 1.0.0-beta.1][] 是 “`bdk_wallet` 稳定 1.0.0 API 的首个测试版本”的候选版本。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #30515][] 在 `scantxoutset` RPC 命令响应中添加了 UTXO 的区块哈希和确认计数作为附加字段。这提供了比仅使用区块高度更可靠的区块标识符，特别是在可能发生链重组的情况下。

- [Bitcoin Core #30126][] 引入了一个[族群线性化][wuille cluster] 函数 `Linearize`，该函数在[族群交易池][topic cluster mempool]项目的一部分中操作相关交易的族群以创建或改进线性化。族群线性化建议了将族群的交易添加到区块模板中的最大化费用顺序(或在满交易池中可以被逐出的最小费用损失顺序)这些函数尚未集成到交易池中，因此此 PR 中没有行为更改。

- [Bitcoin Core #30482][] 改进了 REST 端点 `getutxos` 的参数验证，通过拒绝被截断或拒绝超大的 txid 并抛出 `HTTP_BAD_REQUEST` 解析错误。以前，这也会失败，但会以静默方式处理。

- [Bitcoin Core #30275][] 将 `estimatesmartfee` RPC 命令的默认模式从保守更改为经济模式。此更改基于用户和开发者的观察，认为保守模式在估算费用时经常导致支付过高的交易费用，因为当[估算费用][topic fee estimation]时，它比经济模式对短期费用市场下降的反应较慢。

- [Bitcoin Core #30408][] 将以下 RPC 命令帮助文本中对 `scriptPubKey` 的“公钥脚本”一词的使用替换为“输出脚本”：`decodepsbt`、 `decoderawtransaction`、`decodescript`、`getblock` (如果 verbosity=3)、`getrawtransaction` (如果 verbosity=2,3) 和 `gettxout`。这与在交易术语的拟议 BIP 中使用的措辞相同(见周报[#246][news246 bipterminology])。

- [Core Lightning #7474][] 更新了[offers（要约）][topic offers]插件，允许在 offers（要约）、发票请求 和发票中使用的类型-长度-值（TLV）类型的新的实验范围。这最近已添加到 BOLTs 库中未合并的[BOLT12 PR][bolt12 pr]中。

- [LND #8891][] 向外部[费用估算][topic fee estimation] API 源的预期响应中添加了新的`min_relay_fee_rate` 字段，以允许服务指定最小中继费率。如果未指定，将使用默认的 1012 sats/kvB（1.012 sats/vbyte）的 `FeePerKwFloor`。该 PR 还通过在费用估算器完全初始化之前返回 `EstimateFeePerKW` 调用的错误来提高启动可靠性。

- [LDK #3139][] 通过对[盲化路径][topic rv routing]的使用进行认证来提高 BOLT12 [offers（要约）][topic offers]的安全性。如果没有这种认证，攻击者 Mallory 可以接受 Bob 的报价，并向网络上的每个节点请求发票，以确定哪个节点属于 Bob，从而削弱使用盲化路径的隐私优势。为了解决这个问题，现在每个 offer 的加密盲路径中包含一个 128 位的随机数，而不是在 offer 的未加密元数据中。此更改使得先前版本中创建的具有非空盲化路径的出账支付和退款无效。另一方面，在先前版本中创建的 offers 仍然有效，但容易受到去匿名化攻击，因此用户可能希望在更新到包含此修补程序的 LDK 版本后重新生成它们。

- [Rust Bitcoin #3010][] 向 `sha256::Midstate` 引入了长度字段，允许在增量生成 SHA256 摘要时更灵活和准确地跟踪哈希状态。 此更改可能会影响依赖于以前 `Midstate` 结构的现有实现。


{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30515,30126,30482,30275,30408,7474,8891,3139,3010" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[wuille selection]: https://delvingbitcoin.org/t/cluster-mempool-block-building-with-sub-chunk-granularity/1044
[branch-and-bound]: https://zh.wikipedia.org/wiki/%E5%88%86%E6%94%AF%E5%AE%9A%E7%95%8C
[delgado hyperion]: https://delvingbitcoin.org/t/hyperion-a-discrete-time-network-event-simulator-for-bitcoin-core/1042
[hyperion]: https://github.com/sr-gi/hyperion
[news310 disclosure]: /zh/newsletters/2024/07/05/#disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-0210-0-21-0-bitcoin-core
[Remote crash by sending excessive `addr` messages]: https://bitcoincore.org/en/2024/07/31/disclose-addrman-int-overflow/
[news159 bcc22387]: /en/newsletters/2021/07/28/#bitcoin-core-22387
[news310 miniupnpc]: /zh/newsletters/2024/07/05/#remote-code-execution-due-to-bug-in-miniupnpc-miniupnpc
[Remote crash on local network when UPnP enabled]: https://bitcoincore.org/en/2024/07/31/disclose-upnp-oom/
[upnp]: https://zh.wikipedia.org/wiki/UPnP
[nat traversal]: https://zh.wikipedia.org/wiki/NAT%E7%A9%BF%E9%80%8F
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[goegge disclosure]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bf5287e8-0960-45e8-9c90-64ffc5fdc9aan@googlegroups.com/
[news246 bipterminology]: /zh/newsletters/2023/04/12/#proposed-bip-for-transaction-terminology-bip
[bolt12 pr]: https://github.com/lightning/bolts/pull/798
