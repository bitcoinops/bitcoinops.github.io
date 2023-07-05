---
title: 'Bitcoin Optech Newsletter #256'
permalink: /zh/newsletters/2023/06/21/
name: 2023-06-21-newsletter-zh
slug: 2023-06-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了有关扩展 BOLT11 发票以请求两个付款的讨论。还包括我们关于交易池子规则限定系列的另一个条目，以及我们的常规部分描述了客户端和服务的更新、新版本和候选版本以及热门比特币基础设施软件的重大变更。

## 新闻

- **<!--proposal-to-extend-bolt11-invoices-to-request-two-payments-->将 BOLT11 发票扩展为请求两个付款的提案：** Thomas Voegtlin 在 Lightning-Dev 邮件列表中[发帖][v 2p]建议将 [BOLT11][] 发票扩展到可选地允许接收者从付款者那里请求两个单独的付款，每个付款都有单独的秘密值和金额。Voegtlin Voegtlin 解释了这对[潜水艇互换][topic submarine swaps]和即时 [JIT通道][topic jit channels]都有用处：

    - *<!--submarine-swaps-->潜水艇互换*是指支付链下的 LN 发票会导致在链上收到资金（潜水艇互换也可以反向操作，从链上到链下，但这里不讨论）。链上接收方选择一个秘密值，链下支付者向该秘密值的哈希支付一个 [HTLC][topic htlc]，该 HTLC 通过 LN 路由到潜水艇互换服务提供商。服务提供商收到该秘密值的链下 HTLC，并创建一个链上交易，支付给该 HTLC。当用户确认链上交易安全后，他们会揭示秘密值以结算链上 HTLC，并使服务提供商结算链下 HTLC（以及任何依赖于相同秘密值的 LN 上的转发付款）。

        然而，如果接收者不透露他们的秘密，那么服务提供商将不会收到任何补偿，并且需要花费他们刚刚创建的链上输出，而没有任何收益。为了防止这种滥用，现有的潜水艇互换服务要求花费者在服务创建链上交易之前使用 LN 支付费用（如果链上 HTLC 已结算，服务可以选择退还部分或全部费用）。预付款和潜艇交换的金额不同，需要在不同的时间结算，因此需要使用不同的秘密。当前的 BOLT11 发票只能包含一个秘密值的承诺和一个金额，因此任何进行潜水艇互换的钱包目前需要编程以处理与服务器的交互，或者需要花费者和接收者完成多步工作流程。

    - *即时（JIT）通道*，是指没有通道（或没有流动性）的用户与服务提供商创建虚拟通道；当第一笔付款到达该虚拟通道时，服务提供商创建一个区块链交易，既为通道提供资金，又包含该付款。与任何 LN HTLC 一样，链下支付是只有接收者（用户）知道秘密值。如果用户确信 JIT 通道注资交易是安全的，他们会披露秘密值以领取付款。

       然而，同样地，如果用户不披露他们的秘密值，那么服务提供商将不会收到任何补偿，并且将承担链上成本而无所获得。Voegtlin 认为，现有的 JIT 通道服务提供商通过要求用户在注资交易得到保障之前披露他们的秘密值来避免这个问题，他说这可能会产生法律问题，并阻止非托管钱包提供类似的服务。

    Voegtlin 建议允许 BOLT11 发票包含两个不同金额的秘密值承诺，一个用于预付费以支付链上交易成本，另一个用于实际的潜水艇互换或 JIT 通道资金。该提案收到了几个评论，我们将总结其中的一些：

    - *<!--dedicated-logic-required-for-submarine-swaps-->潜水艇互换需要专用逻辑：* Olaoluwa Osuntokun [指出][o 2p]，潜水艇互换的接收方需要创建一个秘密值，分发它，然后在链上结算付款。最便宜的结算方式是与互换服务提供商互动。如果支出者和接收者无论如何都要与服务提供商互动，就像某些现有实现中经常出现的情况一样，其中支出者和接收者是同一个实体，他们不需要使用发票传达额外的信息。Voegtlin [回答说][v 2p2]，一个专门的软件可以处理交互，消除了链下钱包支付资金和链上钱包接收资金过程中需要额外逻辑的需求，但这仅在 LN 钱包可以在同一发票中支付两个独立的秘密值和金额时才可能。

    - *<!--bolt11-ossified-->BOLT11 已经定型：* Matt Corallo [回复说][c 2p]，目前还无法让所有闪电网络实现更新其 BOLT11 支持以支持不包含金额的发票(以允许[自发付款][topic spontaneous payments])，因此他认为在此时添加额外字段是一种不切实际的方法。Bastien Teinturier 发表了[类似的评论][t 2p]，建议改为在[要约 offers][topic offers]中添加这类支持。Voegtlin [不同意][v 2p3]，认为添加支持是可行的。

    - *<!--splice-out-alternative-->Splice-out 的替代方案：* Corallo 还询问了为什么协议应该修改以支持潜水艇互换，如果[splice outs][topic splicing] 变得可用时？在该线程中没有提到，但是潜水艇互换和 splice outs 都允许将链下资金移动到链上输出，但 splice outs 在链上更有效，并且不会受到未经补偿的费用问题的影响。Voegtlin 回答说，潜水艇互换允许 LN 用户增加接收新 LN 支付的能力，而 splice（通道拼接）不行。

    在编写本报告时，讨论似乎仍在进行中。

## 等待确认 #6：规则一致性

_这是一个关于交易转发、交易池纳入以及挖矿选择的[限定周刊][policy series]———解释了为什么 Bitcoin Core 设置了比共识规则更严格的交易池规则，以及钱包可以如何更高效地使用这些交易池规则。_

{% include specials/policy/zh/06-consistency.md %}

## 服务和客户端软件变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **Greenlight 库开源：**
  非托管 CLN 节点服务提供商 [Greenlight][news162 greenlight] [宣布][decker twitter]推出包含客户端库和语言绑定库的[repository][github greenlight]，以及[测试框架指南][greenlight testing].

- **Tapscript 调试器 Tapsim：**
  [Tapsim][github tapsim] 是一个脚本执行调试(见 [周报 #254][news254 tapsim])和使用 btcd 的 [tapscript][topic tapscript] 可视化工具。

- **Bitcoin Keeper 1.0.4 发布:**
  [Bitcoin Keeper][] 是一款支持多重签名、硬件签名、[BIP85][]的移动钱包，最新版本还支持使用 [Whirlpool 协议][gitlab whirlpool]的[coinjoin][topic coinjoin]。

- **闪电钱包 EttaWallet 宣布：**
  移动版 [EttaWallet][github ettawallet] 最近[宣布][ettawallet blog]启用了 LDK 的闪电网络功能，其强大的可用性的聚焦是受 Bitcoin Design Community 的[日常消费钱包][bitcoin design guide]参考设计的启发。

- **基于 zkSNARK 的区块头同步 PoC 宣布：**
  [BTC Warp][github btc warp] 是一个轻客户端同步 proof-of-concept，使用 zkSNARK 来证明和验证比特币区块头。一篇[博客][btc warp blog]文章提供了详细的方法。

- **lnprototest v0.0.4 释放：**
  [lnprototest][github lnprototest] 项目是一个测试套件，用于测试LN，包括“一组用 Python3 编写的测试助手，旨在使您在提出闪电网络协议更改建议时编写新测试变得容易，并测试现有实现”。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Eclair v0.9.0][] 是这个 LN 实现的新版本，其中包含了许多为重要（且复杂）闪电网络特性做准备的工作：[双向注资][topic dual funding]，
  [通道拼接][topic splicing]和[BOLT12 要约][topic offers]。这些特性目前还处于实验阶段。此版本还“使插件更加强大，引入了各种类型 DoS 的缓解措施，并在代码库的许多领域提高了性能”。

## 重大的代码和文档变更

*本周的重大变更有 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [LDK #2294][] 增加了对[洋葱消息][topic onion messages]的回复支持，使 LDK 更接近完全支持[要约（offers）][topic offers]。

- [LDK #2156][] 增加了使用[简化的多路径支付][topic multipath payments]的 [keysend 支付][topic spontaneous payments]的支持。LDK之前支持这两种技术，但只能分别使用。多路径支付必须使用[支付秘密值][topic payment secrets]，但LDK以前拒绝使用支付秘密值的 keysend 支付，因此添加了描述性错误、配置选项和有关降级的警告以缓解任何潜在问题。

{% include references.md %}
{% include linkers/issues.md v=2 issues="2294,2156" %}
[policy series]: /zh/blog/waiting-for-confirmation/
[v 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003977.html
[o 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003978.html
[v 2p2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003979.html
[c 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003980.html
[t 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003982.html
[v 2p3]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003981.html
[eclair v0.9.0]: https://github.com/ACINQ/eclair/releases/tag/v0.9.0
[news162 greenlight]: /en/newsletters/2021/08/18/#blockstream-announces-non-custodial-ln-cloud-service-greenlight
[decker twitter]: https://twitter.com/Snyke/status/1666096470884515840
[github greenlight]: https://github.com/Blockstream/greenlight
[greenlight testing]: https://blockstream.github.io/greenlight/tutorials/testing/
[github tapsim]: https://github.com/halseth/tapsim
[news254 tapsim]: /zh/newsletters/2023/06/07/#matt-ctv-joinpools
[Bitcoin Keeper]: https://bitcoinkeeper.app/
[gitlab whirlpool]: https://code.samourai.io/whirlpool/whirlpool-protocol
[github ettawallet]: https://github.com/EttaWallet/EttaWallet
[ettawallet blog]: https://rukundo.mataroa.blog/blog/introducing-ettawallet/
[bitcoin design guide]: https://bitcoin.design/guide/daily-spending-wallet/
[github btc warp]: https://github.com/succinctlabs/btc-warp
[btc warp blog]: https://blog.succinct.xyz/blog/btc-warp
[github lnprototest]: https://github.com/rustyrussell/lnprototest
