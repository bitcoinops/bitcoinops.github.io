---
title: 'Bitcoin Optech Newsletter #389'
permalink: /zh/newsletters/2026/01/23/
name: 2026-01-23-newsletter-zh
slug: 2026-01-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报链接了一篇关于支付通道网络研究的论文。此外还包括我们常规的部分：介绍服务和客户端软件的近期更新、宣布新版本和候选版本，以及总结热门比特币基础设施软件的重大变更。

## 新闻

- **<!--a-mathematical-theory-of-payment-channel-networks-->支付通道网络的数学理论：** René Pickhardt 在 Delving Bitcoin 上[发布][channels post]了一篇帖子，介绍他的新[论文][channels paper]《A Mathematical Theory of Payment Channel Networks》的发表。在这篇论文中，Pickhardt 将其多年研究中积累的若干观察，统一到一个几何框架之下。

  该论文尤其旨在分析一些常见现象，例如通道耗尽（参见[周报 #333][news333 depletion]）以及双边通道的资金效率低下，并评估这些现象之间如何相互关联、以及为何会成立。

  论文的主要贡献包括：

  - 在给定通道图的情况下，为闪电网络用户的可行财富分布建立模型。

  - 用于估算支付“带宽”上界的公式。

  - 用于估算一次支付可行性概率的方法（参见[周报 #309][news309 feasibility]）。

  - 对多种[缓解通道耗尽策略][mitigation post]的分析。

  - 得出结论：双边通道会对网络对等节点之间流动性流动的能力施加很强的约束

  Pickhardt 表示，他研究所得的洞见也是他近期一篇关于将 Ark 用作通道工厂的文章的动机（参见[周报 #387][new387 ark]）。Pickhardt 还提供了他用于研究的[代码、notebook 与论文资料合集][pickhardt gh]。

  最后，Pickhardt 邀请 LN 开发者社区就他的工作提出问题并给出反馈，包括：他的研究可能如何影响协议设计，以及多方通道的最佳用法。

## 服务和客户端软件变更

*在这个月度栏目中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--electrum-server-for-testing-silent-payments-->用于测试静默支付的 Electrum 服务器：**
  [Frigate Electrum Server][frigate gh] 实现了 [BIP352][] 中的[远程扫描器][bip352 remote scanner]服务，为客户端应用提供[静默支付][topic silent payments]扫描。Frigate 还使用现代 GPU 计算来缩短扫描时间，这对于提供可同时处理大量扫描请求的多用户实例很有帮助。

- **<!--bdk-wasm-library-->BDK WASM 库：**
  [bdk-wasm][bdk-wasm gh] 库最初由 MetaMask 组织开发并[使用][metamask blog]，它让支持 WebAssembly（WASM）的环境能够访问 BDK 的功能。

## 版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 25.12.1][] 是一个维护版本，修复了一个关键 bug：使用 v25.12 创建的节点无法花费发送到非 [P2TR][topic taproot] 地址的资金（见下文）。它还修复了与 v25.12 引入的基于助记词的 `hsm_secret` 新格式相关的恢复问题以及 `hsmtool` 兼容性问题（见[周报 #388][news388 cln]）。

- [LND 0.20.1-beta.rc1][] 是一个小版本的候选版本，它为 gossip 消息处理新增了 panic 恢复机制，改进了对区块重组（reorg）的保护，实现了 LSP 检测启发式规则，并修复了多个 bug 和竞争条件。更多详情请参见[版本说明][release notes]。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #32471][] 修复了一个 bug：当 `listdescriptors` RPC 使用 `private=true` 参数（参见周报 [#134][news134 descriptor] 和 [#162][news162 descriptor]）时，如果钱包中包含某个[描述符][topic descriptors]，且钱包只拥有其中部分私钥而非全部私钥，那么该调用会失败。该 PR 更新了 RPC，使其返回包含可用私钥子集的描述符，从而允许用户备份这些私钥。对仅监视（watch-only）钱包调用 `listdescriptors private=true` 仍会失败。

- [Bitcoin Core #34146][] 通过在单独的 P2P 消息中发送节点的首次自我声明（self-announcement），改进了地址传播。此前，这个自我声明会与多条其他地址一起打包，作为对等节点 `getaddr` 请求的响应发送；这可能导致它被丢弃，或挤掉其他地址。

- [Core Lightning #8831][] 修复了一个关键 bug：使用 v25.12 创建的节点无法花费发送到非 [P2TR][topic taproot] 地址的资金。尽管这些节点的所有地址类型都是基于 [BIP86][] 派生的，但签名代码只在 P2TR 地址上使用 [BIP86][]。该 PR 确保对所有地址类型签名时都使用 [BIP86][] 的派生方式。

- [LDK #4261][] 添加了对混合模式[通道拼接][topic splicing]的支持，允许在同一笔交易中同时 splice-in 和 splice-out。与 splice-in 的情况一样，注资输入（funding input）支付相应的手续费。如果 splice-out 的价值超过 splice-in，净贡献值可能为负。

- [LDK #4152][] 为[盲化][topic rv routing]支付路径添加了对虚假跳点（dummy hops）的支持，与[周报 #370][news370 dummy] 中为盲化消息路径加入的功能类似。加入额外的跳点会让推断接收节点的距离或身份变得困难得多。此前为实现该功能所做的工作见[周报 #381][news381 dummy]。

- [LND #10488][] 修复了一个 bug：使用 `fundMax` 选项（见[周报 #246][news246 fundmax]）打开的通道，其大小会被用户配置的 `maxChanSize` 设置（见[周报 #116][news116 maxchan]）限制；而该设置原本只应限制入站通道请求。该 PR 使 `fundMax` 选项改为使用协议层面的最大通道大小，具体取决于用户与对等节点是否支持[大通道][topic large channels]。

- [LND #10331][] 通过根据通道大小按比例设置确认要求来改进通道关闭在区块重组（reorg）时的处理：最少 1 个确认、最多 6 个确认。链监视器（chain watcher）也被重构，引入状态机，以便更好地检测区块重组，并在这种情况下跟踪彼此竞争的通道关闭交易。

  该 PR 还增加了对“负确认数”（negative confirmations）的监控（即一笔已确认的交易后来被重组出去），不过如何处理这种情况仍未解决。该 PR 解决了 LND 自 2016 年以来[最早仍未关闭的问题][lnd issue]。

- [Rust Bitcoin #5402][] 在解码过程中增加了验证，拒绝包含重复输入的交易，这与 [CVE-2018-17144][topic cve-2018-17144] 相关。包含多个输入花费同一输出点（outpoint）的交易在共识层面是无效的。

- [BIPs #1820][] 将 [BIP3][] 的状态更新为 `Deployed`，使其取代 [BIP2][] 成为比特币改进提案（BIP）流程的指导文档。更多细节见[周报 #388][news388 bip3]。

- [BOLTs #1306][] 在 [BOLT12][] 规范中澄清：`offer_chains` 字段为空的[要约][topic offers]必须被拒绝。如果要约包含该字段但其中没有任何链哈希（chain hash），就会导致无法发起发票请求，因为付款方无法满足“将 `invreq_chain` 设置为 `offer_chains` 中之一”的要求。

- [BLIPs #59][] 更新了 [BLIP51][]（也称 LSPS1），在现有的 [BOLT11][] 和链上支付选项之外，新增将 [BOLT12 要约][topic offers]作为向闪电服务提供商（LSP）付费的一种选择。此前该功能已在 LDK 中实现（见[周报 #347][news347 lsp]）。

{% include snippets/recap-ad.md when="2026-01-27 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32471,34146,8831,4261,4152,10488,10331,5402,1820,1306,59" %}

[channels post]: https://delvingbitcoin.org/t/a-mathematical-theory-of-payment-channel-networks/2204
[channels paper]: https://arxiv.org/pdf/2601.04835
[news309 feasibility]: /zh/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible-ln
[mitigation post]: https://delvingbitcoin.org/t/mitigating-channel-depletion-in-the-lightning-network-a-survey-of-potential-solutions/1640/1
[news333 depletion]: /zh/newsletters/2024/12/13/#insights-into-channel-depletion
[new387 ark]: /zh/newsletters/2026/01/09/#using-ark-as-a-channel-factory
[pickhardt gh]: https://github.com/renepickhardt/Lightning-Network-Limitations
[frigate gh]: https://github.com/sparrowwallet/frigate
[bip352 remote scanner]: https://github.com/silent-payments/BIP0352-index-server-specification/blob/main/README.md#remote-scanner-ephemeral
[bdk-wasm gh]: https://github.com/bitcoindevkit/bdk-wasm
[metamask blog]: https://metamask.io/news/bitcoin-on-metamask-btc-wallet
[Core Lightning 25.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12.1
[LND 0.20.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta.rc1
[news388 cln]: /zh/newsletters/2026/01/16/#core-lightning-8830
[release notes]: https://github.com/lightningnetwork/lnd/blob/v0.20.x-branch/docs/release-notes/release-notes-0.20.1.md
[news134 descriptor]: /zh/newsletters/2021/02/03/#bitcoin-core-20226
[news162 descriptor]: /zh/newsletters/2021/08/18/#bitcoin-core-21500
[news370 dummy]: /zh/newsletters/2025/09/05/#ldk-3726
[news381 dummy]: /zh/newsletters/2025/11/21/#ldk-4126
[news246 fundmax]: /zh/newsletters/2023/04/26/#lnd-6903
[news116 maxchan]: /zh/newsletters/2020/09/23/#lnd-4567
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/53
[news388 bip3]: /zh/newsletters/2026/01/16/#bip-process-updated
[news347 lsp]: /zh/newsletters/2025/03/28/#ldk-3649

{% include references.md %}
{% include linkers/issues.md v=2 issues="32471,34146,8831,4261,4152,10488,10331,5402,1820,1306,59" %}
