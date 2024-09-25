---
title: 'Bitcoin Optech Newsletter #321'
permalink: /zh/newsletters/2024/09/20/
name: 2024-09-20-newsletter-zh
slug: 2024-09-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了一个零知识证明的概念验证实现，用于证明某个输出是 UTXO 集的一部分，描述了一个新的和两个先前提出的离线 LN 支付方案，并总结了关于非 IP 网络地址 DNS 种子研究的内容。此外，还包括我们常规的客户和服务变化描述、新版本发布和候选版本的公告，以及对流行比特币基础设施软件显著变化的总结。

## 新闻

- **<!--proving-utxo-set-inclusion-in-zero-knowledge-->****零知识证明 UTXO 集的包含性**：Johan Halseth 在 Delving Bitcoin 上发布了一个概念验证工具，允许用户在不暴露具体输出的情况下，证明自己控制当前 UTXO 集中的某个输出。最终目标是让 LN 资金输出的共同所有者能够证明自己控制一个通道，而无需披露任何链上交易的具体信息。该证明可以附加到下一代的[通道公告消息][topic channel announcements]中，这些消息可用于为 LN 构建去中心化的路由信息。

  该方法不同于[周报 #303][news303 aut-ct] 中的 aut-ct 方法。当前的一部分讨论主要集中在澄清其差异上。Halseth 也描述了几个未解决的问题，因此该方法还需要进一步研究。

- **<!--ln-offline-payments-->****LN 离线支付**：Andy Schroder 在 Delving Bitcoin 上[发布][schroder lnoff]了一种 LN 钱包可以用来生成令牌的通信流程草图，这些令牌可以提供给联网钱包进行支付。例如，Alice 的钱包通常连接到她控制的一个始终在线的 LN 节点或由 _Lightning 服务提供商（LSP）_ 控制的节点。当在线时，Alice 会预生成身份验证令牌。

  之后，当 Alice 的节点离线且她需要支付给 Bob 时，她将身份验证令牌交给 Bob，允许他连接到她的在线节点或 LSP，并提取 Alice 指定的金额。Alice 可以通过 [NFC][] 或其他无需联网的数据传输协议向 Bob 提供令牌，保持协议的简单性并使其易于在资源有限的设备（例如智能卡）上实现。

  开发者 ZmnSCPxj [提到][zmn lnoff]了他之前描述的另一种方法，Bastien Teinurier [引用][t-bast lnoff]了他为这种情况设计的一种节点远程控制方法（见[周报 #271][news271 noderc]）。

- **<!--dns-seeding-for-non-ip-addresses-->****非 IP 地址的 DNS 种子**：开发者 Virtu 在 Delving Bitcoin 上[发布][virtu seed]了一项关于[匿名网络][topic anonymity networks]（例如 Tor 等）种子节点可用性的调查，并讨论了让仅使用这些网络的新节点通过 DNS 种子找到对等节点的方法。

  背景是，比特币节点或 P2P 客户端需要了解对等节点的网络地址，以便下载数据。新安装的软件或离线时间较长的软件可能不知道任何活动对等节点的网络地址。通常，Bitcoin Core 节点通过查询返回多个可用对等节点的 IPv4 或 IPv6 地址的 DNS 种子来解决此问题。如果 DNS 种子查询失败或不可用（例如，对于不使用 IPv4 或 IPv6 地址的匿名网络），Bitcoin Core 会包含软件发布时可用的对等节点的网络地址；这些地址会作为种子节点，节点会从这些种子节点请求额外的对等节点地址，并使用它们作为潜在的对等节点。DNS 种子比种子节点更受欢迎，因为它们的地址通常更及时，而全球 DNS 缓存基础设施可以防止 DNS 种子知道每个查询节点的网络地址。

  Virtu 检查了过去四个主要版本的 Bitcoin Core 中列出的种子节点，发现其中大部分仍然可用，这表明匿名网络的用户应该能够找到对等节点。他们和其他讨论参与者还讨论了修改 Bitcoin Core 以允许匿名网络使用 DNS `NULL` 记录或编码替代网络地址到伪 IPv6 地址的方法。

## 服务和客户端软件变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **<!--strike-adds-bolt12-support-->****Strike 添加 BOLT12 支持**：
  Strike [宣布][strike blog]支持 [BOLT12 offer][topic offers]，包括使用带有 [BIP353][] DNS 支付指令的 offer。

- **<!--bitbox02-adds-silent-payment-support-->****BitBox02 添加静默支付支持**：
  BitBox02 [公告][bitbox blog sp]支持[静默支付][topic silent payments]以及一个[支付请求][bitbox blog pr]的实现。

- **<!--the-mempool-open-source-project-v3-0-0-released-->****Mempool 开源项目 v3.0.0 发布**：
  [v3.0.0 版本][mempool github 3.0.0]包括新的 [CPFP][topic cpfp] 费用计算、包含支持 fullrbf 的 [RBF][topic rbf] 功能、对 P2PK 的支持、新的交易池和区块链分析功能等。

- **<!--zeus-v0-9-0-released-->****ZEUS v0.9.0 发布**：
  [v0.9.0 帖子][zeus blog 0.9.0] 概述了版本包含的 LSP 功能、仅观察钱包、硬件签名设备支持、交易[批量][scaling payment batching]处理支持包括通道开启等功能。

- **<!--live-wallet-adds-consolidation-support-->****Live Wallet 添加合并支持**：
  Live Wallet 应用程序分析不同费率下花费 UTXO 集的成本，以及确定何时花费 UTXO 集是[不经济][topic uneconomical outputs]的。[0.7.0 版本][live wallet github 0.7.0] 包括了一个模拟[合并][consolidate info]交易并生成合并交易 [PSBT][topic psbt] 的功能。

- **<!--bisq-adds-lightning-support-->****Bisq 添加闪电网络支持**：
  [Bisq v2.1.0][bisq github v2.1.0] 版本允许用户通过闪电网络结算交易。

## 版本发布和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [HWI 3.1.0][] 是这个支持多种硬件签名设备的接口包的下一个发布版本，增加了对 Trezor Safe 5 的支持以及许多其他改进和错误修复。

- [Core Lightning 24.08.1][] 是一次维护更新，修复了最近发布的 24.08 版本中的崩溃和其他错误。

- [BDK 1.0.0-beta.4][] 是这个库的发布候选版本，主要用于构建钱包和比特币应用程序。最初 `bdk` Rust crate 已重命名为 `bdk_wallet`，较低层模块已提取到自己的 crate，包括 `bdk_chain`、`bdk_electrum`、`bdk_esplora` 和 `bdk_bitcoind_rpc`。`bdk_wallet` crate 是“第一个提供稳定 1.0.0 API 的版本”。

- [Bitcoin Core 28.0rc2][] 是即将发布的全节点实现的候选版本。它有一项[测试指南][bcc testing] 可供参考。

## 重大的代码和文档变更

_本周出现重要变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 。_

_注：下文提到的 Bitcoin Core 的代码提交会应用在其主开发分支上，所以这些变更可能要等到六个月后、版本 28 发行时才会启用。_

- [Bitcoin Core #28358][] 移除了 `dbcache` 限制。因为在不将 UTXO 集从 RAM 刷新到磁盘的情况下，之前的 16GB 限制不再足以完成初始区块同步（IBD）。此次移除可以[带来][lopp cache]大约 25% 的速度提升。决定移除限制而不是提高它，因为没有一个理想的值可以既在未来有效，也给用户完全的灵活性。

- [Bitcoin Core #30286][] 优化了用于族群线性化的候选搜索算法。该优化基于 [Delving Bitcoin 帖子][delving cluster]第 2 部分中的框架，但有一些修改。这些优化可以减少迭代次数，提高线性化性能，但可能增加启动和每次迭代的成本。这是[族群交易池][topic cluster mempool]项目的一部分。见[周报 #315][news315 cluster]。

- [Bitcoin Core #30807][] 将 `assumeUTXO` 节点的同步信号从 `NODE_NETWORK` 改为 `NODE_NETWORK_LIMITED`，以防止对等节点请求超过约一周的旧区块。这将修复一个 bug，即对等节点请求一个历史区块但得不到响应，从而导致它与 `assumeUTXO` 节点断开连接。

- [LND #8981][] 重构了 `paymentDescriptor` 类型，只使用在 `lnwallet` crate 中。之后会用一个叫做 `LogUpdate` 的新结构体替换 `paymentDescriptor`，以简化更新日志和处理，这是实施动态承诺的一系列 PR 的一部分，动态承诺是一种[通道承诺升级][topic channel commitment upgrades]。

- [LDK #3140][] 添加了支付静态 [BOLT12][topic offers] 发票的支持以便进行[异步支付][topic async payments]，正如 [BOLTs #1149][] 中所定义的需要时刻在线的发送者，但不需要包含发票请求在支付的[洋葱消息][topic onion messages]中。发送静态发票或接收异步支付目前还不可用，所以无法进行端到端的测试。

- [LDK #3163][] 在 BOLT12 发票中引入了一个 `reply_path`，更新了 [offer][topic offers] 消息流。这将允许付款方向付款方发送错误信息，如果发票有错误的话。

- [LDK #3010][] 添加了一个功能，如果一个节点还没有收到对应的发票，则重试发送发票请求到 [offer][topic offers] 的回复路径。之前，如果在一个单回复路径的 offer 中由于网络断开而失败，则不会重试。

- [BDK #1581][] 对[钱币选择][topic coin selection]算法进行了改进，允许在 `BranchAndBoundCoinSelection` 策略中使用可定制的回退算法。`coin_select` 方法的签名更新为允许直接将随机数生成器传递给钱币选择算法。此次 PR 还包括其他重构、内部回退处理和简化错误处理。

- [BDK #1561][] 从项目中移除了 `bdk_hwi` crate，以简化依赖和 CI。`bdk_hwi` crate 包含的 `HWISigner` 现在已移至 `rust_hwi` 项目。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28358,30286,30807,8981,3140,3163,3010,1581,1561,1149" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[halseth utxozk]: https://delvingbitcoin.org/t/proving-utxo-set-inclusion-in-zero-knowledge/1142/
[schroder lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/
[virtu seed]: https://delvingbitcoin.org/t/hardcoded-seeds-dns-seeds-and-darknet-nodes/1123
[news303 aut-ct]: /zh/newsletters/2024/05/17/#anonymous-usage-tokens
[nfc]: https://zh.wikipedia.org/wiki/%E8%BF%91%E5%A0%B4%E9%80%9A%E8%A8%8A
[zmn lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/2
[t-bast lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/4
[news271 noderc]: /zh/newsletters/2023/10/04/#ln
[hwi 3.1.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.1.0
[core lightning 24.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.1
[delving cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303#h-2-finding-high-feerate-subsets-5
[lopp cache]: https://github.com/bitcoin/bitcoin/pull/28358#issuecomment-2186630679
[news315 cluster]: /zh/newsletters/2024/08/02/#bitcoin-core-30126
[strike blog]: https://strike.me/blog/bolt12-offers/
[bitbox blog sp]: https://bitbox.swiss/blog/understanding-silent-payments-part-one/
[bitbox blog pr]: https://bitbox.swiss/blog/using-payment-requests-to-securely-send-bitcoin-to-an-exchange/
[mempool github 3.0.0]: https://github.com/mempool/mempool/releases/tag/v3.0.0
[zeus blog 0.9.0]: https://blog.zeusln.com/new-release-zeus-v0-9-0/
[live wallet github 0.7.0]: https://github.com/Jwyman328/LiveWallet/releases/tag/0.7.0
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[bisq github v2.1.0]: https://github.com/bisq-network/bisq2/releases/tag/v2.1.0
