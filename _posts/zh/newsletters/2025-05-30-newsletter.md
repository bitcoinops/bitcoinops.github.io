---
title: 'Bitcoin Optech Newsletter #356'
permalink: /zh/newsletters/2025/05/30/
name: 2025-05-30-newsletter-zh
slug: 2025-05-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分总结了一段关于故障可归因机制对闪电网络隐私性的可能影响的讨论。此外是我们的常规栏目：来自 Bitcoin Stack Exchange 网站的精选问答、软件的新版本和候选版本发行公告，还有热门的比特币基础设施软件的近期变更的讲解。

## 新闻

- **<!--do-attributable-failures-reduce-ln-privacy-->故障归因机制会削弱闪电网络的隐私性吗？**Carla Kirk-Cohen 在 Delving Bitcoin 论坛[发布][kirkcohen af]了一份分析，讨论了如果闪电网络采用了故障归因机制（[attributable failures][topic attributable failures]）（尤其是告知发送者转发支付的每一跳花费了多少时间），对发送者和接收者的隐私性可能有什么样的影响。她引用了多份论文，介绍了两种去匿名化攻击：

  * 攻击者操作一个或多个转发节点，使用时机数据来确定一笔支付（[HTLC][topic htlc]）使用了多少跳；再结合对公开网络的拓扑的知识，就可以缩小可能的接收者的范围。

  * 攻击者使用一个 IP 网络流量转发器（自治系统，[autonomous system][]）从而被动地监控流量，然后结合对节点之间 IP 网络时延知识（比如说它们的 ping 时间）以及对闪电网络公开拓扑（以及其它特征）的知识。

  然后，她介绍了可能的解决方案，包括：

  * 鼓励接收者以随机的短时间延迟来接受一个 HTLC，从而防止尝试定位接收者节点的时机攻击尝试。

  * 鼓励发送者以随机的短时间延迟来推迟重新发送失败的交易（或者 “多路径支付（[MPP][topic multipath payments]）” 的碎片）、并使用替代性路径，以防止尝试定位发送者节点的时机攻击和故障攻击。

  * 增加 MPP 中的支付碎片数量，让花费数额的猜测变得更困难。

  * 允许发送者选择性让自己的支付转发慢一些，如之前的提议（详见[周报 #208][news208 slowln]）。这可以跟 HTLC 批处理相结合，后者在 LND 中已经实现了（虽然加入随机的时延依然能增强隐私性）。

  * 降低故障归因中的时间戳的精度，以避免惩罚添加了随机短时延的转发节点。

  来自多位参与者的讨论更细致地评估了担忧事项和作者所提议的解决方案，还考虑了其它可能的攻击和缓解措施。

## 来自 Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们有困惑时寻找答案的首选之地，也是他们有闲暇时会帮助好奇和困惑用户的地方。在这个月度栏目中，我们会列出自上次出刊以来出现的一些高票的问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--which-transactions-get-into-blockreconstructionextratxn-->哪些交易会进入 blockreconstructionextratxn？]({{bse}}116519) Glozow 解释了 extrapool 数据结构是如何缓存被节点拒绝的交易和节点观察到的替换交易的（详见[周报 #339][news339 extrapool]），并列出了排除交易和驱逐交易的依据。

- [<!--why-would-anyone-use-op-return-over-inscriptions-aside-from-fees-->除了交易手续费因素外，为什么人们会使用 OP_RETURN 而非铭文？]({{bse}}126208) Sjors Provoost 指出，除了有些时候 `OP_RETURN` 更加便宜之外，它还能用在需要保证数据在交易被花费前可得的协议中，而铭刻（inscriptions）用到了见证数据，在花费交易中才会公开。

- [<!--why-is-my-bitcoin-node-not-receiving-incoming-connections-->为什么我的比特币节点收不到入站连接？]({{bse}}126338) Lightlike 指出，刚加入网络的节点可能需要一些时间才能将自己的网络地址广泛告知给 P2P 网络，而且，在初始化区块下载还未完成之前，节点是不会广告自己的地址的。

- [<!--how-do-i-configure-my-node-to-filter-out-transactions-larger-than-400-bytes-->有办法配置我的节点过滤掉体积大于 400 字节的交易吗？]({{bse}}126347) Antoine Poinsot 确认了，Bitcoin Core 中没有配置选项可以定制化设定标准交易的体积上限。他指出，希望定制化这个数值的用户可以修改软件的源代码，但提醒了过大或过小的交易体积上限会带来的可能缺点。

- [<!--what-does-not-publicly-routable-node-in-bitcoin-core-p2p-mean-->Bitcoin Core 点对点连接中的 “不可公开路由的” 节点是什么意思？]({{bse}}126225) Pieter Wuille 和 Vasil Dimov 提供了不能在全球互联网中路由的 P2P 连接（例如 [Tor][topic anonymity networks]）的例子，以及出现在 Bitcoin Core 的 “npr” 桶中的 `netinfo` 输出中的例子。

- [<!--why-would-a-node-would-ever-relay-a-transaction-->节点究竟为什么要转发交易呢？]({{bse}}127391) Pieter Wuille 列出了转发交易对节点操作者的好处：隐私性（在你使用自己的节点转发自己的交易时就体现出来）、更快的区块传播速度（如果用户挖矿的话），以及提升网络的去中心化；在转发区块的基础成本之上，只需极小的增量成本，就可以获得这些好处。

- [<!--is-selfish-mining-still-an-option-with-compact-blocks-and-fibre-->有了致密区块和 FIBRE，“自私挖矿” 依然是可行的攻击吗？]({{bse}}49515) Antoine Poinsot 回答这个于 2016 年提出的问题时指出，“没错，自私挖矿依然是一种可行的策略，即使区块传播速度已经得到提升。断定自私挖矿只在理论上能够成立是不正确的。”他也附带了一个他创建的[挖矿模拟器][miningsimulation github]。

## 软件的新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 25.05rc1][] 是一个这个流行的闪电节点实现的下一个主要版本的候选发行。

- [LDK 0.1.3][] 和 [0.1.4][ldk 0.1.4] 是这个用于构建闪电网络赋能应用的热门库的新版本。0.1.3 版本的发布时间是上个月，但本周才在 GitHub 上标记发行，包含了漏洞修复。0.1.4 版本是最新版本，“修复了一个在极其罕见的情形中会导致资金被盗的漏洞”。两个版本都包含了其它 bug 修复。

## 显著的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [BINANAs][binana repo] 向 [PSBTs][topic psbt] 添加了一种签名哈希模式（sighash）类型字段，用在 sighash 不是 `SIGHASH_DEFAULT` 和 `SIGHASH_ALL` 的时候。[MuSig2][topic musig] 要求每个签名人都使用相同的签名哈希模式，所以这个字段必须出现在 PSBT 中。此外，`descriptorprocesspsbt` RPC 命令更新成使用 `SignPSBTInput` 函数，这保证了 PSBT 的签名哈希类型与在命令行中提供的一致（如果有的话）。

- [Eclair #3065][] 添加了对故障归因机制（详见周报 [#224][news224 failures]）的支持，如 [BOLTs #1044][] 所述。在默认设置中这是禁用的，因为其规范尚未敲定，但可以通过设定 `eclair.features.option_attributable_failure = optional` 来启用。与 LDK 的交叉兼容性已经测试成功；关于 LDK 的实现以及这个协议如何工作，详见周报 [#349][news349 failures]。

- [LDK #3796][] 收紧了通道余额检查，从而让注资者拥有充分的资金来覆盖承诺交易的手续费以及两个价值 330 聪的[锚点输出][topic anchor outputs]，以及通道保证金。以前，注资者可以动用通道保证金来生成两个锚点输出。

- [BIPs #1760][] 合并了 [BIP53][]，该 BIP 详述了一种共识软分叉规则，会禁用 64 字节长的交易（以不含见证数据的形态度量），以禁止一种针对 SPV 客户端的可利用的[默克尔树漏洞][topic merkle tree vulnerabilities]。这一 PR 提出了一种跟[“共识清理” 软分叉][topic consensus cleanup]所包含的一种修复措施类似的做法。

- [BIPs #1850][] 逆转了早前对 [BIP48][] 的一项更新，该更新将 “脚本类型” 的数值 “3” 保留给 [taproot][topic taproot]（P2TR）的变种（详见周报 [#353][news353 bip48]）。这是因为 [tapscript][topic tapscript] 没有 `OP_CHECKMULTISIG` 操作码，所以 [BIP67][] 中的参考输出脚本（也正是 [BIP48][] 所依赖的）并不能用 P2TR 表达出来。这一 PR 也将 [BIP48][] 的状态标记为 `Final`（定稿），反映出它的目的与引入它的时候保持不变 —— 定义 `m/48’` [HD 钱包][topic bip32]派生路径的行业用法，而不是规定新的行为。

- [BIPs #1793][] 合并了 [BIP443][]，该 BIP 提议了 [OP_CHECKCONTRACTVERIFY][topic matt]（OP_CCV）操作码，以允许检查一个公钥（不论来自输出还是输入）承诺了一段任意的数据。回顾周报 [#348][news348 op_ccv] 以了解这种[限制条款][topic covenants] 提议的更多信息。

{% include references.md %}
{% include linkers/issues.md v=2 issues="31622,3065,3796,1760,1850,1793,1044" %}

[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ldk 0.1.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.3
[ldk 0.1.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.4
[news208 slowln]: /zh/newsletters/2022/07/13/#allowing-deliberately-slow-ln-payment-forwarding
[autonomous system]: https://zh.wikipedia.org/wiki/%E8%87%AA%E6%B2%BB%E7%B3%BB%E7%BB%9F
[kirkcohen af]: https://delvingbitcoin.org/t/latency-and-privacy-in-lightning/1723
[news224 failures]: /zh/newsletters/2022/11/02/#ln-routing-failure-attribution
[news349 failures]: /zh/newsletters/2025/04/11/#ldk-2256
[news353 bip48]: /zh/newsletters/2025/05/09/#bips-1835
[news348 op_ccv]: /zh/newsletters/2025/04/04/#op-checkcontractverify-semantics
[news339 extrapool]: /zh/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[miningsimulation github]: https://github.com/darosior/miningsimulation
