---
title: 'Bitcoin Optech Newsletter #298'
permalink: /zh/newsletters/2024/04/17/
name: 2024-04-17-newsletter-zh
slug: 2024-04-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了一项关于使用 “族群交易池” 的节点在面对 2023 年网络上可见的所有交易时会如何行动的测试分析。此外就是我们的常规栏目：近期的客户端和服务升级，软件版本和候选版本的发行公告，以及流行的比特币基础设施软件的重大变更总结。

## 新闻

- **<!--what-would-have-happened-if-cluster-mempool-had-been-deployed-a-year-ago-->如果族群交易池提议在一年以前已经部署，那会怎么样？** Suhas Daftuar 在 Delving Bitcoin 论坛中[发帖][daftuar cluster]表示自己向一个启用了[族群交易池][topic cluster mempool]的开发版本 Bitcoin Core 投放了自己的节点在 2023 年收到的所有交易，以量化现有版本与开发版本的差异。他的发现包括：

  - *<!--the-cluster-mempool-node-accepted-001-more-transactions-->族群交易池节点多接纳了 0.01% 的交易*：“在 2023 年，【用作基线的节点的】祖先/后代 交易数量限制导致超过 46000 笔交易在某个时刻被拒绝。【…】但只有约 14000 笔交易因为触及族群体积限制而被拒绝。”其中，大约 10000 笔（14000 的 70%）最初被族群交易池节点拒绝的交易可以在他们的某些祖先交易被确认之后得到交易池接纳，如果它们被重新广播的话（这也是符合我们预期的钱包动作）。

  - *<!--cluster-mempool-was-just-as-good-for-miners-as-legacy-transaction-selection-->对矿工来说，族群交易池至少跟往常的交易选择程序一样好*：Daftuar 指出，至少当前是这样的，因为几乎每一笔交易最终都会进入区块，所以不论是 Bitcoin Core 当前的交易选择算法，还是基于族群交易池的交易选择算法，实际上收集到的手续费是一样多的。不过，在一项 Daftuar 警告可能夸大了结果的分析中，族群交易池捕捉到了比往常的交易选择程度多 73% 的手续费。往常的交易选择算法在大约 8% 的时间里表现更好。Daftuar 的结论是，“虽然基于 2023 年网络上的活动难以断定族群交易池是否显著优于基线，我的强烈印象是族群交易池不太可能在实际上更差。”

  Daftuar 也考虑了族群交易池在 [RBF 交易替换][topic rbf]上的作用。他首先很好地总结了 Bitcoin Core 当前的 RBF 行为与族群交易池模式下的 RBF 行为的差别：

  > *族群交易池 RBF 规则的核心是，替换发生之后，[交易池的手续费图是否会优化][feerate diagram]；而 Bitcoin Core 当前的 RBF 规则大致上是 BIP125 和[这份文档][rbf doc]说的那样。*
  >
  > *不像 BIP125，提议中的【族群交易池】RBF 规则聚焦在替换的结果上。一笔交易可能仅在理论上更好，但在现实中不然：也许基于对什么事情对交易池好的理论理解，它 “应该” 被接纳，但如果最终的手续费率图因为某些原因（比如，因为线性化算法并不是最优的），那么我们就会拒绝这笔替换交易。*

  我们也要重复他在报告的这一节提出的结论，我们认为，他所提供的数据和分析作为充分支撑了这个结论：

  > *总的来说，族群交易池和现有交易池策略在 RBF 上的区别并不是很大。在有差别的地方，新提议的 RBF 规则可以很大程度上保护交易池、不让激励不兼容的替代交易进入 —— 这是一个好的变化。但是，也要意识到，在理论上，我们可以看到在理想世界中应该被拒绝的替代交易【现在】被接纳，因为有时候，看起来好的替代交易可能触发次优的行为，并且这样的行为在以前无法被（BIP125 规则）检出，但可以被新规则检出和防止。

  截至本刊撰写之时，尚未有回复。

## 服务和客户端软件的变更

*在这个月度栏目中，我们会指出比特币钱包和服务的有趣变更。*

- **<!--phoenix-for-server-announced-->用于服务端的 Phoenix 钱包发布**：Phoenix Wallet 推出了一个简化的、“无头的（headless，没有图形界面）” 的闪电节点实现，称作 “[phoenixd][phoenixd github]”，聚焦于发送和收取支付。phoenixd 的目标用户是开发者，基于现有的 Phoenix Wallet 软件，自动化了通道、对等节点和流动性的管理。

- **<!--mercury-layer-adds-lightning-swaps-->Mercury Layer 加入闪电资金互换**：Mercury Layer 的 [statechain][topic statechains] 实现使用 “[暂缓兑付发票][topic hold invoices]”，允许用一笔 statechain 资金来换取一笔闪电支付。

- **<!--stratum-v2-reference-implementation-v100-released-->Stratum V2 参考实现 v1.0.0 发布**：这个 [v1.0.0 版本][sri blog] “是工作团队通力合作及严格测试、优化了 Stratum V2 规范的结果。”

- **<!--teleport-transactions-update-->Teleport Transactions 更新**：[原版 Teleprot Transactions][news192 tt] 代码库的一个复刻[发布][tt tweet]，带有多项完整的更新和优化。

- **<!--bitcoin-keeper-v121-released-->Bitcoin Keeper v1.2.1 发布**：[v1.2.1 版本][bitcoin keeper v.1.2.1] 添加了对 [taproot][topic taproot] 钱包的支持。

- **<!--bip329-label-management-software-->BIP-329 标签管理软件**：[Labelbase][labelbase blog] 的第二版放出，包含了一个自保管选项以及 [BIP329][] 导入/导出 能力，以及其它特性。

- **<!--key-agent-sigbash-launches-->密钥代理软件 Sigbash 推出**：[Sigbash][] 签名服务允许用户购买一个 xpub 并用在一个多签名装置中；仅在用户指定的条件（比如挖矿哈希率、比特币汇率、地址余额、某个时间之后）满足之时，该 xpub 才参与 [PSBT][topic psbt] 签名。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [Bitcoin Core 27.0][] 是这个在网络中占据主流的全节点实现的下一个大版本。该新版本弃用了 libbitcoinconsensus（见周报 [#288][news288 libconsensus] 和 [#297][news297 libconsensus]）、默认启用 [#297][news297 libconsensus]（见[周报 #288][news288 v2 p2p]）、允许选择性使用 “确认之前拓扑受限（[TRUC][topic v3 transaction relay]）” 的交易转发规则（也称为 “*v3 交易转发*”）（见[周报 #289][news289 truc]），还添加了一种新的[钱币选择][topic coin selection]策略，可以用在高手续费时期（详见[周报 #290][news290 coingrinder]）。想要获得主要变更的完整清单，请看这个[更新公告][bcc27 rn]。

- [BTCPay Server 1.13.1][] 是这个自主托管的支付处理器的最新版本。自我们上一次在[周报 #262][news262 btcpay] 介绍 BTCPay Server 的更新以来，他们已经让 “网络钩子（webhooks）” [更易延展][btcpay server #5421]、为 [BIP129][] 多签名钱包导入功能（详见[周报 #281][news281 bip129]）增加了支持、优化了插件的灵活性并开始将所有的另类币支持迁移到插件中，还添加了对 BBQr 编码的 [PSBTs][topic psbt]（详见[周报 #295][news295 bbqr]）的支持。此外还有不计其数的新特性和 bug 修复。

- [LDK 0.0.122][] 是这个用于开发内嵌闪电网络的应用的库的最新版本；它紧跟在修复了一项 DoS 漏洞的 [0.0.121][ldk 0.0.121] 之后发行。这个最新版本也修复了多个 bug。

## 重大的代码和文档变更

*最近出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [LDK #2704][] 显著地更新和延伸了关于其 `ChannelManager` 类的文档。这种 “通道管理器” 是 “一种闪电节点的通道状态机和支付管理逻辑，可以协助通过闪电通道发送、转发和接收支付。”

{% include references.md %}
{% include linkers/issues.md v=2 issues="2704,5421" %}
[Bitcoin Core 27.0]: https://bitcoincore.org/bin/bitcoin-core-27.0/
[feerate diagram]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553/1
[rbf doc]: https://github.com/bitcoin/bitcoin/blob/0de63b8b46eff5cda85b4950062703324ba65a80/doc/policy/mempool-replacements.md
[daftuar cluster]: https://delvingbitcoin.org/t/research-into-the-effects-of-a-cluster-size-limited-mempool-in-2023/794
[bcc27 rn]: https://github.com/bitcoin/bitcoin/blob/c7567d9223a927a88173ff04eeb4f54a5c02b43d/doc/release-notes/release-notes-27.0.md
[news288 libconsensus]: /zh/newsletters/2024/02/07/#bitcoin-core-29189
[news297 libconsensus]: /zh/newsletters/2024/04/10/#bitcoin-core-29648
[news288 v2 p2p]: /zh/newsletters/2024/02/07/#bitcoin-core-29347
[news289 truc]: /zh/newsletters/2024/02/14/#bitcoin-core-28948
[news290 coingrinder]: /zh/newsletters/2024/02/21/#bitcoin-core-27877
[news281 bip129]: /zh/newsletters/2023/12/13/#btcpay-server-5389
[news295 bbqr]: /zh/newsletters/2024/03/27/#btcpay-server-5852
[news262 btcpay]: /zh/newsletters/2023/08/02/#btcpay-server-1-11-1
[ldk 0.0.122]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.122
[ldk 0.0.121]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.121
[btcpay server 1.13.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.1
[phoenixd github]: https://github.com/ACINQ/phoenixd
[sri blog]: https://stratumprotocol.org/blog/sri-1-0-0/
[news192 tt]: /en/newsletters/2022/03/23/#coinswap-implementation-teleport-transactions-announced
[tt tweet]: https://twitter.com/RajarshiMaitra/status/1768623072280809841
[bitcoin keeper v.1.2.1]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.2.1
[labelbase blog]: https://labelbase.space/ann-v2/
[Sigbash]: https://sigbash.com/
