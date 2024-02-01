---
title: 'Bitcoin Optech Newsletter #286'
permalink: /zh/newsletters/2024/01/24/
name: 2024-01-24-newsletter-zh
slug: 2024-01-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了旧版 btcd 软件中的一个已经修复的共识故障、为闪电网络使用 “v3 交易转发” 和 “一次性锚点” 而提出的变更，以及比特币相关规范的一个新仓库。此外是我们的常规栏目：服务和客户端软件的升级介绍、软件新版本和候选版本的介绍，以及热门比特币基础设施软件的重大变更总结。

## 新闻

- **<!--disclosure-of-fixed-consensus-failure-in-btcd-->已修复的 btcd 共识故障披露**：Niklas Gögge 在 Delving Bitcoin 论坛[公开][gogge btcd]了他已经[尽责披露][topic responsible disclosures]的旧版 btcd 软件中的一个共识故障。相对[时间锁][topic timelocks]是通过向交易输入的 sequence 字段添加共识强制的含义的软分叉而[添加到比特币中的][topic soft fork activation]。为了保证在分叉之前创建的任何预签名交易都不会因此而作废，相对时间锁仅对交易版本号为 2 乃至更高数字的数字，以允许原本默认版本号为 1 的交易可以容许任意输入。然而，在最初的比特币软件中，版本号是有符号的整数，即也可能是负数。而 [BIP68][] 的 “参考实现” 部分指出，“版本号为 2 以及更高” 意味着将版本号从有符号的整数[转变][cast]为无符号的整数，从而保证这个规则适用于任何交易版本号不为 0 和 1 的交易。

    Gögge 发现，btcd 并没有实现这种从有符号到无符号整数的转变，所以有可能构造处一笔采用负版本号的交易，Bitcoin Core 将要求它遵循 BIP68 规则，但 btcd 不会。这时候，前者会拒绝这笔交易（以及任何包含了这笔交易的区块），而后者则会接受它（并且不会拒绝包含它的区块），从而导致链分裂。攻击者可以利用这一点来欺骗一个 btcd 节点的运营者（或者连接到 btcd 节点的软件）接受无效的比特币。

    这个 bug 早已被私下披露给 btcd 的维护人员，他们在最近的 v0.24.0 版本中修复了这个故障。强烈推荐任何使用 btcd 来确保共识的人都升级软件。此外，Chris Stewart 还在 Delving Bitcoin 帖子中[回复了][stewart bitcoin-s]一个在 bitcoin-s 库中的相同故障的补丁。任何可能用于验证 BIP68 相对时间锁的代码的作者都应立即检查代码中有无相同的错误。

- **<!--proposed-changes-to-ln-for-v3-relay-and-ephemeral-anchors-->为闪电网络使用 v3 交易转发和一次性锚点而提出的变更**：Bastien Teinturier 在 Delving Bitcoin 论坛中[提出][teinturier v3]了他认为闪电网络规范应该采取、以实质上利用 “[v3 交易转发][topic v3 transaction relay]” 和 “[一次性锚点][topic ephemeral anchors]” 的变更。这些变更似乎是简单的：

  - *<!--anchor-swap-->锚点切换*：当前为了在 “[CPFP carve out][topic cpfp carve out]” 规则下保证 [CPFP 手续费追加][topic cpfp] 能力而放置在承诺交易中的两个[锚点输出][topic anchor outputs]需要移除，代之以一个一次性锚点输出。

  - *<!--reducing-delays-->减少延迟*：承诺交易输出的额外 1 个区块的时延需要移除。使用它们是为了保证 CPFP carve out 总是能工作，但在 v3 交易转发规则下已不再必要。

  - *<!--trimming-redirect-->隐式 HTLC 重定向* ：不再将所有 “[隐式 HTLC][topic trimmed htlc]” 的价值放到承诺交易的手续费中，而将它们的总价值加到锚点输出的价值中，以保证额外的手续费会被用来保证承诺交易以及一次性锚点的确认（见[上周的周报][news285 mev]的讨论）。

  - *<!--other-changes-->其它变更*：其它一些较小的变更以及简化。

  后续的讨论检查了这些变更的一些有趣的后果，包括：

  - *<!--reduced-utxo-requirements-->减少 UTXO 需求*：得益于额外 1 区块时延的移除，保证正确的通道状态上链变得更加简单。如果欺诈的一方广播了一笔已经撤销的承诺交易，另一方可以立即使用该承诺交易中属于自己的主要输出、以 CPFP 法增加该承诺交易的手续费。他们不再需要保留一个单独的、已经确认的 UTXO 以备 CPFP 使用。为了确保安全，通道的参与者应该保留足够的储备余额，因为 [BOLT2][] 中指定的 1% 下限可能不足以覆盖手续费。对于保留了足够多储备的非转发节点，出于安全理由而需要额外 UTXO 的唯一场景只剩他们要接收一笔进入的支付的时候。

  - *<!--imbued-v3-logic-->渗透 v3 逻辑*：在回应闪电网络规范会议中出现的担忧（闪电网络可能需要很长时间来设计、实现和部署这些变更）时，Gregory Snders [提议][sanders transition]采用一个过渡阶段，对看起来像当前锚点风格的闪电网络承诺交易进行临时的特殊处理，以允许 Bitcoin Core 部署族群交易池而不会被闪电网络的开发阻碍。当软件已经得到广泛部署、所有的闪电客户端实现都升级到使用 v3 时，可以抛弃过渡的特殊规则。

  - *<!--request-for-max-child-size-->请求为子交易体积设置上限*：v3 交易转发的提议草案将待确认交易的子交易的体积上限设为 1000 vbyte。这个体积越大，诚实用户需要为克服 “[交易钉死][topic transaction pinning]” 而支付的手续费就越多（见[周报 #283][news283 v3pin]）。这个体积越小，诚实用户可以用来贡献手续费的输入位置就越少。

- **<!--new-documentation-repository-->新的文档仓库**：Anthony Towns 在 Bitcoin-Dev 邮件组中[公布][towns binana]了一个用于存放协议规范的新仓库：*Bitcoin Inquisition Numbers And Names Authority*（[BINANA][binana repo]）。截至本刊撰写之时，仓库内已有 4 个规范：

    - [BIN24-1][] `OP_CAT`，由 Ethan Heilman 和 Armin Sabouri 撰写。[周报 #274][news274 cat] 有他们的软分叉提议的介绍。

    - [BIN24-2][] Heretical Deployments，由 Anthony Towns 撰写，介绍了 [Bitcoin Inquisition][bitcoin inquisition repo] 软件在默认的 [signet][topic signet] 上测试软分叉提议和其它变更的用法。详细介绍见[周报 #232][news232 inqui]。

    - [BIN24-3][]  `OP_CHECKSIGFROMSTACK`，由 Brandon Black 撰写，说明了这个[提出了很长时间的想法][topic OP_CHECKSIGFROMSTACK]。[上周的周报][news285 lnhance]介绍了 Black 将该操作码放进 LNHANCE 软分叉组合的的提议。

    - [BIN24-4][]  `OP_INTERNALKEY`，由 Brandon Black 撰写，说明了一个从脚本解释器中检索 taproot 内部公钥的操作码。它也是上周介绍的 LNHANCE 软分叉组合的一部分。

    Bitcoin Optech 已经将 BINANA 仓库加入我们观察更新的文档资源清单，该清单也包括 BIP、BOLT 和 BLIP。未来的更新可能会出现在 “重大代码和文档变更” 栏目中。

## 服务和客户端软件的变更

*在这个月度栏目中，我们列出比特币钱包和服务的有趣更新。*

- **<!--envoy-15-released-->Envoy 1.5 推出**：[Envoy 1.5][]增加了对 [taproot][topic taproot] 花费和接收的支持，并改变了处理[不经济的输出][topic uneconomical outputs]的方法；此外还有一些 bug 修复和[其它更新][envoy blog]。

- **<!--liana-v40-released-->Liana v4.0 推出**：[Liana v4.0][] 已经 [released][liana blog]，包含了对 [RBF 手续费追加法][topic rbf]、使用 RBF 取消交易、自动化[选币][topic coin selection]以及硬件签名设备地址验证的支持。

- **<!--mercury-layer-announced-->Mercury Layer 推出**：[Mercury Layer][] 是一种 [statechain][topic statechains] 实现，它使用了 [MuSig2][topic musig] 的一个[变种][mercury blind musig]以实现 statechain 运营者的盲签名。

- **<!--aqua-wallet-announced-->AQUA 钱包推出**：[AQUA wallet][]是一款[开源][aqua github]的移动端钱包，支持比特币、闪电网络以及 Liquid [侧链][topic sidechains]。

- **<!--samourai-wallet-announces-atomic-swap-feature-->Samourai Wallet 推出原子化互换特性**：这种[跨链原子化互换][samourai gitlab swap]特性，基于以前的[研究][samourai gitlab comit]，允许在比特币和 Monero 链之间一对一交换资金。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LDK 0.0.120][] 是这个用于开发闪电网络嵌入应用的库的安全更新。它 “修复了一个拒绝服务式攻击攻击漏洞；在本地启用 `UserConfig::manually_accept_inbound_channels` 选项时，该漏洞可被对等节点的不可信任的输入触及”。多项其它 bug 修复和少量提升也包含在其中。

- [HWI 2.4.0-rc1][] 是这个为多种硬件签名器提供通用接口的包的下一个版本的候选。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #29239][] 更新了 `addnode` RPC，以在启用 `-v2transport` 配置选项时连接使用 [v2 传输协议][topic v2 p2p transport] 的节点。

- [Eclair #2810][] 允许在 “[蹦床路由][topic trampoline payments]” 中使用的洋葱加密消息超过 400 字节，当前使用的上限是 [BOLT4][] 指定的 1300 字节。小于 400 字节的蹦床路由信息会被填充到 400 字节。

- [LDK #2791][]、[#2801][ldk #2801] 和 [#2812][ldk #2812] 完成了对 “[盲化路由][topic rv routing]” 的支持，并开始广告这个特性位。

- [Rust Bitcoin #2230][] 加入了一种计算一个输入的 *实质价值* 的函数，就是用它的面额减去花费它所需付出的代价。

{% include references.md %}
{% include linkers/issues.md v=2 issues="29239,2810,2791,2801,2812,2230" %}
[teinturier v3]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/
[towns binana]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022289.html
[sanders transition]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/2
[news283 v3pin]: /zh/newsletters/2024/01/03/#v3-transaction-pinning-costs-v3
[news274 cat]: /zh/newsletters/2023/10/25/#proposed-bip-for-op-cat-op-cat-bip
[news232 inqui]: /zh/newsletters/2023/01/04/#bitcoin-inquisition
[news285 mev]: /zh/newsletters/2024/01/17/#mev
[news285 lnhance]: /zh/newsletters/2024/01/17/#lnhance
[stewart bitcoin-s]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455/2
[gogge btcd]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455
[hwi 2.4.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0-rc.1
[ldk 0.0.120]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.120
[cast]: https://en.wikipedia.org/wiki/Type_conversion#Explicit_type_conversion
[Envoy 1.5]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.5.1
[envoy blog]: https://foundationdevices.com/2024/01/envoy-version-1-5-1-is-now-live/
[Liana v4.0]: https://github.com/wizardsardine/liana/releases/tag/v4.0
[liana blog]: https://www.wizardsardine.com/blog/liana-4.0-release/
[Mercury Layer]: https://mercurylayer.com/
[mercury blind musig]: https://github.com/commerceblock/mercurylayer/blob/dev/docs/blind_musig.md
[mercury layer github]: https://github.com/commerceblock/mercurylayer/tree/dev/docs
[AQUA Wallet]: https://aquawallet.io/
[aqua github]: https://github.com/AquaWallet/aqua-wallet
[samourai gitlab swap]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/SWAPS.md
[samourai gitlab comit]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/files/Atomic_Swaps_between_Bitcoin_and_Monero-COMIT.pdf
