---
title: 'Bitcoin Optech Newsletter #397'
permalink: /zh/newsletters/2026/03/20/
name: 2026-03-20-newsletter-zh
slug: 2026-03-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括我们的常规栏目：服务和客户端软件的变更介绍、新版本和候选版本的公告，以及流行比特币基础设施软件的近期重大变更总结。

## 新闻

*本周未在我们的任何[来源][sources]中发现重大新闻。*

## 服务和客户端软件的变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--cake-wallet-adds-lightning-support-->****Cake Wallet 添加闪电网络支持：** Cake Wallet [宣布][cake ln post]使用 Breez SDK 和 [Spark][topic statechains] 集成支持闪电网络，包括闪电地址。

- **<!--sparrow-2-4-0-and-2-4-2-released-->****Sparrow 2.4.0 和 2.4.2 发布：** Sparrow [2.4.0][sparrow 2.4.0] 添加了用于[静默支付][topic silent payments]硬件钱包支持的 [BIP375][] [PSBT][topic psbt] 字段，并添加了 [Codex32][topic codex32] 导入器。Sparrow [2.4.2][sparrow 2.4.2] 添加了 [v3 交易][topic v3 transaction relay]支持。

- **<!--blockstream-jade-adds-lightning-via-liquid-->****Blockstream Jade 通过 Liquid 添加闪电网络支持：** Blockstream [宣布][jade ln blog] Jade 硬件钱包（通过 Green 应用 5.2.0）现在可以使用[潜水艇互换][topic submarine swaps]与闪电网络交互，将闪电支付转换为 [Liquid][topic sidechains] 比特币（L-BTC），保持密钥离线。

- **<!--lightning-labs-releases-agent-tools-->****Lightning Labs 发布代理工具：** Lightning Labs [发布][ll agent tools]了一个开源工具包，使 AI 代理能够在无需人工干预或 API 密钥的情况下使用 [L402 协议][blip 26]在闪电网络上运行。

- **<!--tether-launches-miningos-->****Tether 推出 MiningOS：** Tether [推出][tether mos] MiningOS，一个用于管理比特币挖矿运营的开源操作系统。该软件采用 Apache 2.0 许可，与硬件无关，采用模块化的 P2P 架构。

- **<!--fibre-network-relaunched-->****FIBRE 网络重新启动：** Localhost Research [宣布][fibre blog]重新启动 FIBRE（Fast Internet Bitcoin Relay Engine），该项目此前于 2017 年关闭。此次重启包括 Bitcoin Core v30 的变基和监控套件，在全球部署了六个公共节点。FIBRE 补充了[致密区块中继][topic compact block relay]以实现低延迟区块传播。

- **<!--tui-for-bitcoin-core-released-->****Bitcoin Core 终端界面发布：** [Bitcoin-tui][btctui tweet]，一个 Bitcoin Core 的终端界面，通过 JSON-RPC 连接以显示区块链和网络数据，功能包括交易池监控、交易搜索和广播以及对等节点管理。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 31.0rc1][] 是主流全节点实现下一个主要版本的候选发布。提供了[测试指南][bcc31 testing]。

- [BTCPay Server 2.3.6][] 是这个自托管支付解决方案的小版本发布，添加了钱包搜索栏中的标签过滤功能，在发票 API 端点中包含了支付方式数据，并允许插件定义自定义权限策略。还包含若干 bug 修复。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #31560][] 扩展了 `dumptxoutset` RPC（见[周报 #72][news72 dump]），使 UTXO 集快照能够写入命名管道。这允许输出直接流式传输到另一个进程，无需将完整转储写入磁盘。这与 `utxo_to_sqlite.py` 工具（见[周报 #342][news342 sqlite]）配合良好，可以即时创建 UTXO 集的 SQLite 数据库。

- [Bitcoin Core #31774][] 开始使用 `secure_allocator` 保护用于钱包加密的 AES-256 加密密钥材料，以防止操作系统在内存不足时将其交换到磁盘，并在不再使用时将其从内存中清零。当用户加密或解锁钱包时，密码短语用于派生 AES 密钥来加密或解密钱包的私钥。此前，该密钥材料使用标准分配器分配，意味着它可能被交换到磁盘或留存在内存中。

- [Core Lightning #8817][] 修复了在跨实现测试中发现的若干与 Eclair 的[拼接][topic splicing]互操作性问题（此前的互操作工作见周报 [#331][news331 interop] 和 [#355][news355 interop]）。CLN 现在可以处理 Eclair 在拼接重新建立期间恢复协商之前可能发送的 `channel_ready` 消息，修复了可能导致崩溃的 RPC 错误处理，并通过新的 `channel_reestablish` TLV 实现了公告签名重传。

- [Eclair #3265][] 和 [LDK #4324][] 开始拒绝 `offer_amount` 设置为零的 [BOLT12 要约][topic offers]，以与 BOLT 规范的最新变更保持一致（见[周报 #396][news396 amount]）。

- [LDK #4427][] 通过重新进入[通道静默（quiescence）][topic channel commitment upgrades]状态，添加了对已协商但尚未锁定的[拼接][topic splicing]注资交易进行 [RBF][topic rbf] 手续费追加的支持。当双方同时尝试 RBF 时，通道静默的打破平衡机制会选出失败方，失败方可以作为接受者贡献资金。当对方发起 RBF 时，先前的贡献会被自动重用，防止手续费追加悄悄移除对等节点的拼接资金。基础的拼接接受者贡献支持见[周报 #396][news396 splice]。

- [LDK #4484][] 将具有零手续费 [HTLC][topic htlc] 的[锚点][topic anchor outputs]通道（包括[零确认通道][topic zero-conf channels]）的最大可接受通道[粉尘][topic uneconomical outputs]限额提高到 10,000 聪。这实现了 [BOLTs #1301][]（见[周报 #395][news395 dust]）中的建议。

- [BIPs #1974][] 发布了 [BIP446][] 和 [BIP448][] 作为草案 BIP。[BIP446][] 定义了 `OP_TEMPLATEHASH`，一个新的 [tapscript][topic tapscript] 操作码，将花费交易的哈希推入栈中（初始提案见[周报 #365][news365 op]）。[BIP448][] 将 `OP_TEMPLATEHASH` 与 [OP_INTERNALKEY][BIP349] 和 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 组合，提出"Taproot 原生（可重新）绑定交易"。这个[限制条款][topic covenants]组合将使 [LN-Symmetry][topic eltoo] 成为可能，并减少其他第二层协议的交互需求和复杂度。

{% include snippets/recap-ad.md when="2026-03-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31560,31774,8817,3265,4324,4427,4484,1974,1301" %}
[sources]: /en/internal/sources/
[cake ln post]: https://blog.cakewallet.com/our-lightning-journey/
[sparrow 2.4.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.0
[sparrow 2.4.2]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.2
[jade ln blog]: https://blog.blockstream.com/jade-lightning-payments-are-here/
[ll agent tools]: https://github.com/lightninglabs/lightning-agent-tools
[blip 26]: https://github.com/lightning/blips/pull/26
[x402 blog]: https://blog.cloudflare.com/x402/
[tether mos]: https://mos.tether.io/
[fibre blog]: https://lclhost.org/blog/fibre-resurrected/
[btctui tweet]: https://x.com/_jan__b/status/2031741548098896272
[bitcoin core 31.0rc1]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[BTCPay Server 2.3.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.6
[news72 dump]: /zh/newsletters/2019/11/13/#bitcoin-core-16899
[news342 sqlite]: /zh/newsletters/2025/02/21/#bitcoin-core-27432
[news331 interop]: /zh/newsletters/2024/11/29/#core-lightning-7719
[news355 interop]: /zh/newsletters/2025/05/23/#core-lightning-8021
[news396 amount]: /zh/newsletters/2026/03/13/#bolts-1316
[news396 splice]: /zh/newsletters/2026/03/13/#ldk-4416
[news395 dust]: /zh/newsletters/2026/03/06/#bolts-1301
[news365 op]: /zh/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
