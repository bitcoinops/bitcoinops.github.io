---
title: 'Bitcoin Optech Newsletter #341'
permalink: /zh/newsletters/2025/02/14/
name: 2025-02-14-newsletter-zh
slug: 2025-02-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的新闻部分总结了关于概率性支付的持续讨论，介绍了关于闪电通道临时锚点脚本的其它观点，转发了来自 Bitcoin Core 孤儿交易池驱逐活动的统计数据，并宣布了一个指定新的 BIP 流程的草案的更新。此外是我们的常规部分：最近一次 Bitcoin Core 审核俱乐部会议的总结；软件的新版本和候选版本的发行公告；以及热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--continued-discussion-about-probabilistic-payments-->关于概率性支付的持续讨论**：自 Oleksandr Kurbatov 上周在 Delving Bitcoin 论坛上[发帖][kurbatov pp]介绍一种模拟 `OP_RAND` 的方法（详见[周报#340][news340 pp]）以来，人们讨论了多个话题：

  - *<!--suitability-as-an-alternative-to-trimmed-htlcs-->是否合适作为修剪 HTLC 的替代实现方法：*Dave Harding [询问][harding pp] Kurbatov 的方法是否合适用在 [LN-Penalty][topic ln-penalty] 或 [LN-Symmetry][topic eltoo] 通道中、用于路由在发生时[不经济][topic uneconomical outputs]的 [HTLCs][topic htlc]；当前，这是使用 “[修剪 HTLCs][topic trimmed htlc]” 技术来实现的 —— 如果在这些 HTLC 还未得到解决时，通道就被强制关闭了，那么其中的价值就会丢失。Anthony Towns [不认为][towns pp1]现在这版协议能胜任这个场景，因为现有协议的角色分配跟解决 HTLC 的对应角色正好相反。不过，他认为协议有可能调整到跟 HTLC 的需要一致。

  - *<!--setup-step-required-->需要启动步骤：*Towns [发现][towns pp1]最初发布的协议缺失了一个步骤。Kurbatov 表示同意。

  - *<!--simpler-zeroknowledge-proofs-->更简单的零知识证据*：Adam Gibson [提出][gibson pp1]，使用 [schnorr][topic schnorr signatures] 和 [taproot][topic taproot]，而不是哈希后的公钥，可能会大大简化和加速所需的零知识证据的构造和验证。Towns [提供][towns pp2]了一个试探性的方法，[Gibson][gibson pp2] 也提供了分析。

  截至本刊撰写之时，讨论还在继续。

- **<!--continued-discussion-about-ephemeral-anchor-scripts-for-ln-->关于闪电通道临时锚点脚本的持续讨论**：Matt MoreHouse [回复][morehouse eanchor]了关于未来的闪电通道应该使用何种 “[临时锚点][topic ephemeral anchors]” 脚本的帖子（详见[周报#340][news340 eanchor]）。他表达了对第三方使用 [P2A][topic ephemeral anchors] 输出恶意扰乱（griefing）交易的手续费支付的担心。

  Anthony Towns [指出][towns eanchor]，对手方骚扰是更值得担忧的时，因为对手方更有可能处于偷盗资金的有利地位，如果该通道没有及时关闭或进入合适状态的话。第三方如果尝试推迟你的交易获得确认或稍微提高你的交易的费率，可能会损失一些资金，而且也无法直接从中获利。

  Greg Sanders [建议][sanders eanchor]从概率的角度考虑：如果第三方的骚扰者最多能将你的交易的成本提高 50%，但使用一种抵抗骚扰的技术需要付出额外 10% 的代价，你觉得受到第三方骚扰的概率会比遭遇强制关闭的频率的 1/5 更高吗？尤其是，第三方可能会损失资金并且无法从中获利。

- **<!--stats-on-orphan-evictions-->孤儿交易驱逐的统计数据**：开发者 0xB10C 在 Delving Bitcoin 论坛中[公开][b10c orphan]了从他的节点的孤儿交易池驱逐的交易的数量。对一个节点来说，“孤儿交易” 指的是该节点尚未拥有其所有父交易的未确认交易；而没有这些父交易，该交易就无法进入区块。Bitcoin Core 默认储存最多 100 笔孤儿交易。如果在孤儿交易池满载后一笔新的孤儿交易到达，就会有一笔以前收到的孤儿交易被驱逐。

  0xB10C 发现，在一段时间里，超过 1000 万笔孤儿交易从他的节点驱逐，峰值速率是每分钟驱逐超过 10 万笔交易。经过调查，他发现，“这些交易中超过 99% 都跟[这笔交易][runestone tx]相似，这似乎跟【一种染色币（NFT）协议】 runestone 的铸造有关”。似乎许多孤儿交易都经历了被请求、在短时间内被随机驱逐、然后又被请求的循环。

- **<!--updated-proposal-for-updated-bip-process-->** **新的 BIP 流程的提议焕新**： Mark "Murch" Erhardt 在 Bitcoin-Dev 邮件组中[发帖][erhardt bip3]，宣布他为更新后的 BIP 流程撰写的 BIP 草案已经被分配了 BIP3 的标识符，并且已经准备号经历额外的审核 —— 可能是该草案在被合并和激活之前要经历的最后一轮审核。欢迎任何有意见的人在这个 [PR][bips #1712] 页面留下反馈。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们总结最近一次 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议的成果，列出一些重要的问题和答案。点击下面列出的问题，可以看到会议上出现的答案的总结。*

“[Cluster mempool: introduce TxGraph][review club 31363]” 是由 [sipa][gh sipa] 提出的一项 PR，引入了 `TxGraph` 这个类，其中的数据对象会封装关于交易池中所有交易的（实质）手续费、体积和依赖关系的只是，但不会包含别的东西。这是 “[族群交易池][topic cluster mempool]” 项目的一部分，并且带来了一个全面的接口，允许通过突变测试（mutation）、检查器（inspector）和分段（staging）函数跟交易池图互动。

{% include functions/details-list.md
  q0="<!--what-is-the-mempool-graph-and-to-what-extent-does-it-exist-in-the-mempool-code-on-master-->所谓的交易池 “图” 是什么？它在 master 分支的交易池代码中存在吗？"
  a0="在软件的 master 分支，交易池的图已经作为 `CTxMemPoolEntry` 对象（表示为点）所构成的集合而隐式存在，而这些对象的 祖先/依赖 关系可以用 `GetMemPoolParents()` 和 `GetMemPoolChildren()` 方法递归遍历得到。"
  a0link="https://bitcoincore.reviews/31363#l-26"

  q1="<!--what-are-the-benefits-of-having-a-txgraph-in-your-own-words-can-you-think-of-drawbacks-->用你自己的话来说，使用专门的 `TxGraph` 类有什么好处？你能想到缺点吗？"
  a1="好处包括：（1）`TxGraph` 为[族群交易池][topic cluster mempool]（及其所有好处）的实现铺平了道路；（2）更好地封装交易池的代码，使用更高效的数据结构；（3）让它更容易对接交易池，也更容易分析，将诸如不要重复统计替代交易之类的拓扑细节抽象出去。
  <br><br>缺点包括：（1）需要为引入的巨大变更投入巨大的审核和测试努力；（2）它限制了验证程序在规定每一笔交易的拓扑限制方面的作用，而这种作用跟 “确认前拓扑受限（TRUC）” 和其它交易池规则都有关系；（3）一个非常小的运行时性能开销，是由跟 `TxGraph::Ref*` 指针的来回翻译导致的。"
  a1link="https://bitcoincore.reviews/31363#l-54"

  q2="<!--how-many-clusters-can-an-individual-transaction-be-part-of-within-a-txgraph-->在一个 `TxGraph` 内，一个单体交易可以是多少 `Cluster` 的部分？"
  a2="虽然概念上来说，一笔交易只能属于一个族群，但这里的答案是 2。这是因为一个 `TxGraph` 可以封装两个平行的图：一个是 “main”，另一个是可选的 “staging”。"
  a2link="https://bitcoincore.reviews/31363#l-116"

  q3="<!--what-does-it-mean-for-a-txgraph-to-be-oversized-is-that-the-same-as-the-mempool-being-full-->所谓的 `TxGraph` 体积过大是什么意思？是不是就跟交易池满载一样？"
  a3="如果在一个 `TxGraph` 中，至少一个 `Cluster` 超过了  `MAX_CLUSTER_COUNT_LIMIT`，我们就说它过大了。这跟交易池满载不一样，因为一个 `TxGraph` 可以有不止一个 `Cluster`。"
  a3link="https://bitcoincore.reviews/31363#l-147"

  q4="<!--if-a-txgraph-is-oversized-which-functions-can-still-be-called-and-which-ones-can-t-->如果一个 `TxGraph` 过大了，哪些函数还能调用、哪些不能？"
  a4="可能需要实际上具象化一个族群的操作，例如要求 O(n<sup>2</sup>) 乃至更多计算量的操作，在过大的 `Cluster` 上就不能使用了。者包括（例如）计算一笔交易的 祖先/后代 的操作。而突变操作（`AddTransaction()`、`RemoveTransaction()`、`AddDependency()` 和 `SetTransactionFee()`），以及例如 `Trim()` 的操作（大概需要 `O(n log n)` 的计算量）依然能运行。"
  a4link="https://bitcoincore.reviews/31363#l-162"
%}

## 新版本和候选版本

- [LND v0.18.5-beta][] 是这种流行的闪电节点实现的一个 bug 修复版本。发行说明表示该版本的 bug 修复是 “重要” 和 “关键” 的。

- [Bitcoin Inquisition 28.1][] 是这个专用于实验软分叉提议和其它重大协议变更的 [signet][topic signet] 全节点实现的小版本。它包括了 Bitcoin Core 28.1 所加入的 bug 修复，以及对[临时粉尘][topic ephemeral anchors]的支持。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition
repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #25832][] 添加了 5 种新的跟踪点和说明书，用于监控对等连接事件，比如连接的时长、通过 IP 和网组重连的频率、评分降级（discouragement）、驱逐、不轨行为，等等。启用了 “拓展的伯克利包过滤器（eBPF）” 跟踪的 Bitcoin Core 可以 使用案例脚本钩住跟踪点，也可以编写自己的跟踪脚本（详见周报 [#160][news160 ebpf] 和 [#244][news244 ebpf]）。

- [Eclair #2989][] 在路由器中添加了对[批量][topic payment batching]通道拼接的支持，允许跟踪在一笔[拼接][topic splicing]交易中花费的多条通道。因为无法确定性地匹配新的[通道公告][topic channel announcements]与对应的通道，路由器会更新它发现的第一条匹配的通道。

- [LDK #3440][] 完成了对收取 “[异步支付][topic async payments]” 的支持，办法是验证发送者的发票请求嵌入到了 [HTLC][topic htlc] 的洋葱消息中（该 HTLC 由上游节点扣住），然后生成正确的 `PaymentPurpose` 来领取这笔支付。进入的异步支付会有一个绝对的过期时间，以防止对节点在线状态的无止境打探；并且，在接收者节点回到线上、要求上游节点释放一个 HTLC 的时候，还需使用必要的通信流。要完成异步支付流的完整实现，节点还必须能够扮演 LSP，代表异步支付接收者提供发票。

- [LND #9470][] 给 `BumpFee` 和 `BumpForceCloseFee` RPC 命令添加了一种 `deadline_delta` 参数，用于指定一段时间（以区块数为单位），将（同时指定的）一笔预算逐步转作追加的手续费并执行 [RBF][topic rbf]。此外，`conf_target` 参数被重新定义为执行手续费估算器将被查询以获得最新手续费的时间长度（以区块数为单位），用在上述 PRC 命令以及已经弃用的 `BumpCloseFee` 方法中。

- [BTCPay Server #6580][] 移除了一种验证 [LNURL][topic lnurl]-pay 操作中的 [BOLT11][] 发票的描述哈希值存在性和正确性的检查。这一变更是为了匹配 LNURL 说明书（LUD）规范的一项[提议弃用][ludpr]，该提议认为这一要求只提供了少许安全性好处，但对 LNURL-pay 的实现构成了重大挑战。描述哈希值参数字段在 Core-Lightning 中已经实现（详见周报 [#194][news194 deschash] 和 [#232][news232 deschash]）。

## 勘误

在上周周报的一个[脚注][fn sigops] 中，我们不正确地声称：“在 P2SH 和所提议的输入签名操作统计中，一个使用超过 16 个公钥的 OP_CHECKMULTISIG 操作会被统计为使用了 20 个签名操作。”这是一种过度简化；要了解真正的规则，请看 Anthony Towns 在本周发布的一个[帖子][towns sigops]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25832,2989,3440,9470,6580,1712" %}
[lnd v0.18.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta
[Bitcoin Inquisition 28.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.1-inq
[news340 pp]: /zh/newsletters/2025/02/07/#emulating-op-rand
[towns sigops]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/69
[kurbatov pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[harding pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/2
[towns pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/3
[gibson pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/5
[towns pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/6
[gibson pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/7
[morehouse eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/8
[news340 eanchor]: /zh/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts
[towns eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/9
[sanders eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/11
[b10c orphan]: https://delvingbitcoin.org/t/stats-on-orphanage-overflows/1421/
[runestone tx]: https://mempool.space/tx/ac8990b04469bad8630eaf2aa51561086d81a241deff6c95d96d27e41fa19f90
[erhardt bip3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/25449597-c5ed-42c5-8ac1-054feec8ad88@murch.one/
[fn sigops]: /zh/newsletters/2025/02/07/#fn:2kmultisig
[review club 31363]: https://bitcoincore.reviews/31363
[gh sipa]: https://github.com/sipa
[news244 ebpf]: /zh/newsletters/2023/03/29/#bitcoin-core-26531
[news160 ebpf]: /zh/newsletters/2021/08/04/#bitcoin-core-22006
[ludpr]: https://github.com/lnurl/luds/pull/234
[news232 deschash]: /zh/newsletters/2023/01/04/#btcpay-server-4411
[news194 deschash]: /en/newsletters/2022/04/06/#c-lightning-5121
