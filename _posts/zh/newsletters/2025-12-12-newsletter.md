---
title: 'Bitcoin Optech Newsletter #384'
permalink: /zh/newsletters/2025/12/12/
name: 2025-12-12-newsletter-zh
slug: 2025-12-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分公开了 LND 软件中的漏洞，还介绍了一个在嵌入式安全芯片中运行虚拟机的项目。此外是我们的常规栏目：介绍服务和客户端软件的变化、总结 Bitcoin Stack Exchange 网站上的热门问题和回答，还有热门的比特币基础设施软件的近期变更。

## 新闻

- **<!--critical-vulnerabilities-fixed-in-lnd-0190-->** **LND 0.19.0 所修复的致命漏洞**：Matt Morehouse 在 Devling Bitcoin 论坛中[披露][morehouse delving]了在 LND 0.19.0 中修复的致命漏洞。本次披露提到了三项漏洞，包括一项拒绝服务式（DoS）攻击漏洞和两项资金盗窃漏洞。

  - *<!--message-processing-outofmemory-dos-vulnerability-->消息处理耗尽内存的拒绝服务式攻击漏洞：*这项[DoS 漏洞][lnd vln1]利用了 LND 允许像可用的文件描述符一样多的对等节点数量。攻击者可以与受害者开启多个连接，然后不断发送 64 KB 的 `query_short_channel_ids` 消息，同时确保连接开启，直到 LND 用尽内存。这一漏洞的缓解措施已于 2015 年 3 月 12 日在 LND 0.19.0 中实现。

  - *<!--loss-of-funds-due-to-new-excessive-failback-vulnerability-->新的超量回调所导致的资金丢失漏洞：*[这种攻击][lnd vln2]是 “超量回调 bug（[excessive failback bug][morehouse failback bug]）” 的一个变种；原漏洞的最早修复措施在 LND 0.18.0 发布，然而，一个微小的变种依然存在，当通道使用 LND 的承诺交易（而非攻击者的承诺交易）来强制关闭的时候。这一漏洞于 2025 年 3 月 20 日在 LND 0.19.0 中修复。

  - *<!--loss-of-funds-vulnerability-in-htlc-sweeping-->* *在 HTLC 清扫中出现的资金丢失漏洞：*这项[资金盗窃漏洞][lnd vln3]利用了 LND 的清扫系统的漏洞。该漏洞让攻击者可以阻止 LND 尝试在区块链内领取超时的 HTLC 。在阻止受害者长达 80 各区块之后，攻击者实质上能偷取整条通道的余额。

  Morehouse 催促用户升级到 [LND 0.19.0][lnd version] 或更高版本，以避免遭受这些攻击。

- **<!--a-virtualized-secure-enclave-for-hardware-signing-devices-->一种用于硬件签名设备的虚拟化安全飞地**：Salvatoshi 在 Delving Bitcoin 论坛中%#%#了 [Vanadium][vanadium github]，一种用于硬件签名设备的虚拟化安全飞地。Vanadium 是一种 RISC-V 的虚拟机，设计成可以在一个潜入的安全芯片中运行任何应用（叫做 “V-Apps”），并将内存和存储需要外包给一个不受信任的主机。根据 Salvatoshi 的说法，Vanadium 的目标是抽象掉嵌入式开发的复杂性，比如有限的内存和存储空间、供应商专用的 SDK 、缓慢的开发周期、调试，从而让它在自主保管领域的创新更加快速、开放和标准化。

  Salvatoshi 指出，从性能的角度看，虚拟机自身只运行应用的业务逻辑，而重度操作（即密码学）通过 ECALLs 原生运行。

  虽然它的威胁模型跟现有的硬件签名器是一样的，Salvatoshi 指出，这种方法可能泄露内存的访问模式（access-pattern）：主机可以观察到哪一段代码和数据页面被访问了、何时访问的。这对密码学开发者来说是尤为重要的。

  这个项目仍未被认为已准备好进入生产环境，因为还有一些已知的局限性，比如性能和用户体验。不过，Salvatoshi 请求开发者们试用它并提供反馈，以确定该项目的路线图。

## 服务与客户端软件的变更

*在这个月度栏目中，我们会列出比特币钱包软件和服务的有趣更新*。

- **<!--interactive-transaction-visualization-tool-->交互式交易可视化工具**：[RawBit][rawbit delving] 是一个[基于网页的][rawbit website]、[开源的][rawbit github]交易可视化工具。它主要提供了多种交易类型的交互式课程，还计划增加关于 taproot、待签名的比特币交易（[PSBTs][topic psbt]）、哈希时间锁合约（[HTLCs][topic htlc]）、[coinjoins][topic coinjoin] 和限制条款提议的额外课程。

- **<!--bluewallet-v722-released-->** **BlueWallet v7.2.2 发布**：BlueWallet 的 [v7.2.2 版本][bluewallet v7.2.2] 发布，开始支持 [taproot][topic taproot] 钱包，包括发送、接收、观察、钱币挑选和硬件签名器特性。

- **<!--stratum-v2-updates-->** **Stratum V2 更新**：Stratum v2 [v1.6.0][sv2 v1.6.0] 重新设计了 Stratum v2 代码库的架构，添加了一个 [sv2-apps 代码库以及它的 v.01 版本][sv2-apps]，支持使用 IPC与未修改的 Bitcoin Core 30.0 节点直接通信（详见[周报 #369][news369 ipc]）。这一发行版还提供了给[矿工][sv2 wizard miners]和[开发者][sv2 wizard devs]的网页工具，用于测试；还带有其它特性。

- **<!--auradine-announces-stratum-v2-support-->** **Auradine 宣布支持 Stratum v2**：Auradine [宣布][auradine tweet] 在他们的矿机中支持 Stratum v2 的特性。

- **<!--ldk-node-070-released-->** **LDK Node 0.7.0 发布**：[LDK Node 0.7.0][ldk node blog] 为 “通道拼接（[splicing][topic splicing]）” 添加了实验性支持；还支持为 “异步支付（[async payments][topic async payments]）” 提供和支付静态发票；还有其它特性和 bug 修复。

- **<!--bip329-python-library-100-release-->** **BIP-329 的 Python 库 1.0.0 发布**：[BIP-329 Python 库][news273 329 lib] 版本 [1.0.0][bip329 python 1.0.0] 支持 [BIP329][] 的额外字段，包括类型验证和覆盖率测试。

- **<!--bitcoin-safe-160-released-->** **Bitcoin Safe 1.6.0 发布**：[1.6.0 版本][bitcoin safe 1.6.0]添加了对[致密区块过滤器][topic compact block filters]和[可复现编译][topic reproducible builds]的支持。

## 来自 Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地 —— 也是我们有闲暇时会帮助好奇和困惑的用户的地方。在这个月度栏目中，我们会挑选出自上次出刊以来出现的部分高票问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--does-a-clearnet-connection-to-my-lightning-node-require-a-tls-certificate-->连接到我的闪电节点的明网连接需要 TLS 证书吗？]({{bse}}129303) Pieter Wuille 指出，在闪电网络中，用户可以指定一个公钥作为跟一个对等节点的连接的一部分，所以，“不需要一个受信任的第三方来见证这个公钥的正确性，因为正确地配置公钥是用户的责任。”

- [<!--why-do-different-implementations-produce-different-der-signatures-for-the-same-private-key-and-hash-->为什么同一个私钥和哈希值在不同实现上会产生不同的 DER 签名？]({{bse}}129270) 用户 “dave_thompson_085” 解释说，不同的实现可能会产生不同的有效 ECDSA 签名，是因为算法是天然随机化的，除非使用了 RFC 6979 “确定性 nonce 值生成”。

- [<!--why-is-the-miniscript-after-value-limited-at-0x80000000-->为什么 miniscript 语言的 `after` 数值限制在 0x80000000？]({{bse}}129253) Murch 回答说，[miniscript][topic miniscript] 限制了 `after(n)` 基于数值的 CLTV [时间锁][topic timelocks] 的最大值为 2<sup>31</sup> - 1（表示一个 2038 年的时间点），是因为比特币脚本的整数是 4 字节长的 *有符号* 数值，而基于区块高度的锁定时间可以超过这个 2038 年的阈值。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #33528][] 防止钱包模块花费带有一笔未确认祖先交易的未确认 [TRUC][topic v3 transaction relay] 交易，以符合 TRUC 的规则限制。以往，钱包可以创建出这样的交易，只是会在广播的时候被拒绝。

- [Bitcoin Core #33723][] 从 DNS 种子列表中移除了 `dnsseed.bitcoin.dashjr-list-of-p2p-nodes.us`。维护者们发现，这是唯一一个忽略较新的 Bitcoin Core 版本（29 和 30）的种子，违反了 “种子所返回的结果必须完全由在公开网络中公平挑选且正在运行的节点组成” 的条款。

- [Bitcoin Core #33993][] 为 `stopatheight` 启动选项更新了帮助文档，说明了为该选项指定的停止同步的目标高度仅是一种预估，该高度之后的区块依然有可能在停机期间被处理。

- [Bitcoin Core #33553][] 添加了一条警告消息，在收到以往被标记为无效的区块的区块头时，暗示可能的数据库损坏。这可以帮助用户发现他们可能困在了区块头同步循环中。这项 PR 也启用了一种分叉检测警告消息（此前在初始化区块下载中关闭）。

- [Eclair #3220][] 为 “[taproot 通道][topic simple taproot channels]” 延展了现有的 `spendFromChannelAddress` 帮助器，添加了一个 `spendfromtaprootchanneladdress` 端点，让用户可以合作式花费意外发送到 [taproot][topic taproot] 通道注资地址的 UTXO，使用 [MuSig2][topic musig] 签名。

- [LDK #4231][] 在区块重组导致通道注资交易的区块确认取消的时候，停止强制关闭 “零确认的通道（[zero-conf channels][topic zero-conf channels]）”。LDK 有一种机制，在通道因为重复花费风险而失去确认之时强制关闭它。但是，零确认通道的信任模式有所不同。这种罕见情形下的 SCID 变更也得到了妥善的处理。

- [LND #10396][] 收紧了用于探测 LSP 助力节点的路由者启发式分析：使用公开节点作为目的地的发票，或者其路由提示中的跳跃全是私密节点的发票，现在会被当成普通节点，而使用私密节点作为目的地、带有至少一个公开节点跳跃的发票，才会被分类为有 LSP 支持的。以往，松散的启发式分析可能会将节点错误归类为带有 LSP 辅助的，从而产生更多的侦测错误。现在，当侦测到一个 LSP 助力节点时，LND 会打探最多三个候选的 LSP，然后使用最差情形的路线（最高手续费和最大的 CLTV），以提供保守的手续费估计。

- [BTCPay Server #7022][] 为 `Subscriptions` 特性（详见[周报 #379][news379 btcpay]）加入了一个 API，让商家可以创建和管理出价、计划、会员和付款。每一个具体的操作都添加了十多个端点。

- [Rust Bitcoin #5379][] 添加了一种方法来构造 [支付到锚点（P2A）][topic ephemeral anchors] 地址，与现有的验证 P2A 地址的方法互补。

- [BIPs #2050][] 更新了 [BIP390][]，它详细说明了 [MuSig2][topic musig] 描述符：在已经允许的 `tr()` 描述符基础上，它允许在 `rawtr()` 中放置 `musig()` 密钥表达式。本次更新让文档描述与现有的测试向量和 Bitcoin Core 的描述符实现一致。

{% include references.md %}
{% include linkers/issues.md v=2 issues="33528,33723,33993,33553,3220,4231,10396,7022,5379,2050" %}
[morehouse delving]: https://delvingbitcoin.org/t/disclosure-critical-vulnerabilities-fixed-in-lnd-0-19-0/2145
[lnd vln1]: https://morehouse.github.io/lightning/lnd-infinite-inbox-dos/
[lnd vln2]: https://morehouse.github.io/lightning/lnd-excessive-failback-exploit-2/
[lnd vln3]: https://morehouse.github.io/lightning/lnd-replacement-stalling-attack/
[lnd version]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[morehouse failback bug]: /zh/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[vanadium post]: https://delvingbitcoin.org/t/vanadium-a-virtualized-secure-enclave-for-hardware-signing-devices/2142
[vanadium github]: https://github.com/LedgerHQ/vanadium
[rawbit delving]: https://delvingbitcoin.org/t/raw-it-the-visual-raw-transaction-builder-script-debugger/2119
[rawbit github]: https://github.com/rawBit-io/rawbit
[rawbit website]: https://rawbit.io/
[bluewallet v7.2.2]: https://github.com/BlueWallet/BlueWallet/releases/tag/v7.2.2
[sv2 v1.6.0]: https://github.com/stratum-mining/stratum/releases/tag/v1.6.0
[sv2-apps]: https://github.com/stratum-mining/sv2-apps/releases/tag/v0.1.0
[news369 ipc]: /zh/newsletters/2025/08/29/#bitcoin-core-31802
[sv2 wizard miners]: https://stratumprotocol.org/get-started
[sv2 wizard devs]: https://stratumprotocol.org/developers
[auradine tweet]: https://x.com/Auradine_Inc/status/1991159535864803665?s=20
[ldk node blog]: https://newreleases.io/project/github/lightningdevkit/ldk-node/release/v0.7.0
[news273 329 lib]: /zh/newsletters/2023/10/18/#bip329-python-library-released-bip-329-python
[bip329 python 1.0.0]: https://github.com/Labelbase/python-bip329/releases/tag/1.0.0
[bitcoin safe 1.6.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.6.0
[news379 btcpay]: /zh/newsletters/2025/11/07/#btcpay-server-6922