---
title: 'Bitcoin Optech Newsletter #350'
permalink: /zh/newsletters/2025/04/18/
name: 2025-04-18-newsletter-zh
slug: 2025-04-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报包含了我们的常规栏目：近期出现的服务和客户端软件上的更改、新版本和候选版本的发行公告、热门比特币基础设施软件的显著变更。此外，是一些对我们上周对 “SwiftSync” 报道的勘误。

## 新闻

*从我们的[消息源][sources]来看，本周没有重大的新闻。*

## 服务和客户端软件商的变更

*在这个月度栏目中，我们列举出比特币钱包和服务的有趣更新。*

- **<!--bitcoin-knots-version-281knots20250305-released-->** **Bitcoin Knots 版本 28.1.knots20250305 发行**：本次的 Bitcoin Knots [发行版][knots 28.1]包含了对隔离见证和 taproot 地址的[签名消息][topic generic signmessage]的支持，同时支持验证 [BIP137][]、[BIP322][]和 Electrum 签名的消息，还有其它变更。

- **<!--psbtv2-explorer-announced-->** **PSBTv2 浏览器发布**：[Bitcoin PSBTv2 Explorer][bip370 website]可以校验以版本 2 数据格式编码的 [PSBTs][topic psbt]。

- **<!--lnbits-v100-released-->** **LNbits v1.0.0 发行**：[LNbits][lnbits github] 软件在多种底层的闪电网络钱包之上提供了记账功能和其它功能。

- **<!--the-mempool-open-source-project®-v320-released-->** **Mempool Open Source Project® v3.2.0 发布**：[v3.2.0 版本][mempool 3.2.0] 添加了对 “[v3 交易][topic v3 transaction relay]”、锚点输出和 “[1P1C 交易包][topic package relay]” 广播、Stratum 矿池任务可视化的支持，还添加了其它特性。

- **<!--coinbase-mpc-library-released-->** **Coinbase MPC 库发布**：[Coinbase MPC][coinbase mpc blog] 项目是一个 [C++ 语言的库][coinbase mpc github]，用于保管用在多方计算（MPC）方案中的密钥，还包含了一种定制化的 secp256k1 实现。

- **<!--lightning-network-liquidity-tool-released-->闪电网络流动性工具发布**：[Hydrus][hydrus github]使用闪电网络的状态（包括以往的表现），在 LND 客户端上自动化开启和关闭闪电通道。它也支持[批处理][topic payment batching]。

- **<!--versioned-storage-service-announced-->** **Versoined Storage Service 发布**：[Versioned Storage Service (VSS)][vss blog] 框架是一种开源的云存储解决方案，用于保存闪电钱包和比特币钱包的状态数据，专注于非托管的钱包。

- **<!--fuzz-testing-tool-for-bitcoin-nodes-->比特币节点的模糊测试工具**：[Fuzzamoto][fuzzamoto github]是一种使用模糊测试来发现不同比特币协议实现的 bug 的框架，它使用外部接口，比如 P2P 和 RPC。

- **<!--bitcoin-control-board-components-opensourced-->比特币控制板模块开源**：Braiins [宣布][braiins tweet]他们的 BCB100 挖矿控制板已经有部分硬件和软件模块开源了。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 29.0][] 是这个网络主流全节点实现的最新主要版本。其[发行说明][bcc rn]介绍了多项重大提升：使用一个 NAT-PMP 选项（同样默认关闭）取代了默认关闭的 UPnP 特性（过去多项安全漏洞都与此有关），加强了孤儿交易的父交易的调取能力（或能提高 Bitcoin Core 当前的[交易包][topic package relay]支持的可靠性），默认区块模板将可获得稍微多一些空间（也许可能提高挖矿收益），增强了避免矿工意外触发[时间扭曲攻击][topic time warp]的动作（如果时间扭曲在[未来的一次软分叉][topic consensus cleanup]中被禁止，可能会造成意外的收益损失），并且，将编译系统从 autotools 迁移到 cmake。

- [LND 0.19.0-beta.rc2][] 是这个流行的闪电节点的候选发行。可能需要测试的其中一个主要提升是合作关闭场景中，新的基于 RBF 的手续费追加。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [LDK #3593][] 允许用户通过在 `PaymentSent` 事件中包含 BOLT12 发票来提供一个 [BOLT12][topic offers] 支付证据（需在支付完成之前）。这是通过在 `PendingOutboundPayment::Retryable` 枚举中添加 `bolt12` 字段来实现的；该枚举可在稍后附加到 `PaymentSent` 事件中。

- [BOLTs #1242][] 让 “支付秘密值（[payment secret][topic payment secrets]）” 变成 [BOLT11][] 发票支付的强制要求：如果发票的读取者（支付者）发现发票的 `s` （支付秘密值）字段为空，就终止支付。以往，规范仅仅要求发票的编写者（接收者）强制编写支付秘密值，但读取者可以忽略掉长度不正确的 `s` 字段（详见周报 [#163][news163 secret]）。这一 PR 也在 [BOLT9][] 中将支付秘密值特性的状态更新为 `ASSUMED`。

## 勘误

上周的新闻中关于 SwiftSync 的[介绍][news349 ss]包含了多项错误和令人迷惑的表述：

- *<!--no-cryptographic-accumulator-used-->并未使用密码学累加器*：我们说 SwiftSync 正在使用一种密码学累加器，这是不正确的。如果是密码学累加器，它会允许测试一个交易输出（TXO）是否在集合中。但 SwiftSync 并不需要这个特性。相反，它只需要在一个 TXO 被创建出来的时候，向一个聚合值添加一个代表该 TXO 的数值，然后在该 TXO 被花费的时候从聚合值中减去同一个数值。在对 SwiftSync 终点区块之前被花费掉的所有 TXO 都执行一遍这样的操作之后，节点会检查聚合值是不是 0 —— 意味着所有创建出来的 TXO 后面都被花费掉了。

- *<!--parallel-block-validation-does-not-require-assumevalid-->* *并行区块验证特性不需要 assumevalid*：我们描述了并行验证可以跟 SwiftSync 配合的一种方式，就是在终点区块之前，不验证脚本 —— 类似于今天的 Bitcoin Core 在使用 *assumevalid* 模式的初始化同步中那样。然而，在 SwiftSync 中，也可以验证以往的脚本，虽然者可能需要改变 Bitcoin P2P 协议，从而可选在区块中加入额外数据。Bitcoin Core 节点已经为本地存储的所有区块存储了这些额外数据，所以我们不认为加入一种 P2P 消息插件会很困难 —— 只要我们预计会有许多人想要使用 SwiftSync，同时禁用 assumevalid。

- *<!--parallel-block-validation-is-for-different-reasons-than-utreexo-->* *Utreexo 可实现并行区块验证的原理完全不同*：我们还说 SwiftSync 能够并行验证区块的原理类似于 [Utreexo][topic utreexo]，但实际上，它们采用了不同的方法。Utreexo 验证一个区块（或出于效率理由而验证一串区块）的时候，它会从一个对 UTXO 集的承诺开始，执行完对 UTXO 集的所有变更之后，产生一个对新的 UTXO 集的承诺。因此，验证工作可以基于 CPU 线程的数量来分割；比如说：一个线程验证某 1000 个区块，另一个线程验证随后的 1000 个区块。在验证结束的时候，节点可以检查验证完头 1000 个区块之后的承诺，跟它验证随后 1000 个区块的初始承诺相同。

  SwiftSync 使用一个聚合状态，可以在加入之前先减去。设想一个 TXO 在区块高度 1 处创建出来，在区块高度 2 处又被花掉。如果我们先处理区块高度 2，我们可以先从聚合值中减去代表这个 TXO 的值。然后我们再处理区块高度 1，再把表示该 TXO 的值加进聚合值。两个操作的净效应是零，这可以再 SwiftSync 结束的时候检查。

我们为这些错误向所有读者道歉。感谢 Ruben Somsen 指出这些错误。

{% include references.md %}
{% include linkers/issues.md v=2 issues="3593,1242" %}
[bitcoin core 29.0]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[sources]: /en/internal/sources/
[news349 ss]: /zh/newsletters/2025/04/11/#swiftsync-speedup-for-initial-block-download-swiftsync
[bcc rn]: https://bitcoincore.org/en/releases/29.0/
[knots 28.1]: https://github.com/bitcoinknots/bitcoin/releases/tag/v28.1.knots20250305
[bip370 website]: https://bip370.org/
[lnbits github]: https://github.com/lnbits/lnbits
[mempool 3.2.0]: https://github.com/mempool/mempool/releases/tag/v3.2.0
[coinbase mpc blog]: https://www.coinbase.com/blog/innovation-matters-coinbase-breaks-new-ground-with-mpc-security-technology
[coinbase mpc github]: https://github.com/coinbase/cb-mpc
[hydrus github]: https://github.com/aftermath2/hydrus
[vss blog]: https://lightningdevkit.org/blog/announcing-vss/
[fuzzamoto github]: https://github.com/dergoegge/fuzzamoto
[braiins tweet]: https://x.com/BraiinsMining/status/1904601547855573458
[news163 secret]: /zh/newsletters/2021/08/25/#bolts-887