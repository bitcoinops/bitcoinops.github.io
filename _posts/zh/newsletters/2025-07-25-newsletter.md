---
title: 'Bitcoin Optech Newsletter #364'
permalink: /zh/newsletters/2025/07/25/
name: 2025-07-25-newsletter-zh
slug: 2025-07-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了影响旧版本 LND 的漏洞，描述了在使用协同签名服务时改善隐私的想法，并检视了切换到抗量子签名算法对 HD 钱包、无脚本多重签名和静默支付的影响。此外还包括我们的常规栏目：总结了 Bitcoin Stack Exchange 上的热门问答、宣布新版本和候选版本，以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--lnd-gossip-filter-dos-vulnerability-->****LND gossip 过滤器 DoS 漏洞：** Matt Morehouse 在 Delving Bitcoin 上[发布][morehouse gosvuln]了关于影响旧版本 LND 的漏洞，他之前已经[尽责披露][topic responsible disclosures]了该漏洞。攻击者可以反复请求 LND 节点的历史 gossip 消息，直到节点内存耗尽并被终止。该漏洞已在 2024 年 9 月发布的 LND 0.18.3 中修复。

- **<!--chain-code-withholding-for-multisig-scripts-->****多重签名脚本的链码隐藏：** Jurvis Tan 在 Delving Bitcoin 上[发布][tan ccw]了他与 Jesse Posner 进行的研究，该研究关于改善多重签名协作托管的隐私和安全性。在典型的协作托管服务中，可能使用 2-of-3 多重签名，三个密钥分别是：

  - 用户_热密钥_，存储在联网设备上，为用户签名交易（手动或通过软件自动化）。

  - 服务提供商热密钥，存储在提供商专门控制的独立联网设备上。该密钥只根据用户之前定义的策略签名交易，比如每天只允许花费不超过 _x_ BTC。

  - 用户_冷密钥_，离线存储，只有在用户热密钥丢失或提供商停止签名授权交易时才使用。

  虽然上述配置可以显著提高安全性，但几乎总在使用的设置方法涉及用户与提供商共享用户热钱包和冷钱包的 [BIP32 扩展公钥][topic bip32]。这允许提供商检测用户钱包收到的所有资金，并跟踪这些资金的所有花费，即使用户在没有提供商协助的情况下花费。之前已经描述了几种缓解这种隐私损失的方法，但它们要么与典型使用不兼容（例如使用单独的 tapleave），要么复杂（例如需要 [MPC][]）。Tan 和 Posner 描述了一个简单的替代方案：

  - 提供商生成 BIP32 HD 扩展密钥的一半（仅密钥部分）。他们将公钥给用户。

  - 用户生成另一半（链码）。他们保持这个私有。

  当接收资金时，用户可以组合两个部分来创建扩展公钥（xpub），然后像往常一样派生多重签名地址。提供商不知道链码，无法派生 xpub 或发现地址。

  当花费资金时，用户可以从链码派生出提供商需要与其私钥结合以创建有效签名的必要_调整值_。他们只需与提供商分享这个调整值。提供商除了知道它对从特定 scriptPubKey 收到资金的花费有效外，无法从调整值中获知到其他任何信息。

  一些提供商可能要求花费交易的找零输出将钱发送回相同的脚本模板。Tan 的帖子描述了如何轻松实现这一点。

- **<!--research-indicates-common-bitcoin-primitives-are-compatible-with-quantum-resistant-signature-algorithms-->****研究指出常见的比特币原语与抗量子签名算法兼容：** Jesse Posner 在 Delving Bitcoin 上[发布][posner qc]了几个研究论文链接，这些论文表明[抗量子][topic quantum resistance]签名算法提供了可比拟于当前用在比特币 [BIP32 HD 钱包][topic bip32]、[静默支付地址][topic silent payments]、[无脚本多重签名][topic multisignature]和[无脚本阈值签名][topic threshold signature]的原语。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者首先查找答案的地方---或者当我们有空闲时间帮助好奇或困惑的用户。在
这个每月功能中，我们突出显示一些投票最多的问题和答案，这些答案自上次更新以来发布。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-does-bitcoin-core-handle-reorgs-larger-than-10-blocks-->Bitcoin Core 如何处理大于 10 个区块的重组？]({{bse}}127512)
  TheCharlatan 链接到了 Bitcoin Core 的代码，该代码通过仅重新添加最多 10 个区块的交易来处理链重组。

- [<!--advantages-of-a-signing-device-over-an-encrypted-drive-->签名设备相对于加密驱动器的优势是什么？]({{bse}}127596)
  RedGrittyBrick 指出，加密驱动器上的数据可以在驱动器未加密时提取，而硬件签名设备设计用于防止这种数据提取攻击。

- [<!--spending-a-taproot-output-through-the-keypath-and-scriptpath-->通过密钥路径和脚本路径花费 taproot 输出？]({{bse}}127601)
  Antoine Poinsot 详细说明了如何通过 merkle 树、密钥调整值和叶子脚本来实现 taproot 的密钥路径和脚本路径花费的能力。

## 发布和候选版本

_新版本和候选版本，用于流行的比特币基础设施项目。请考虑升级到新版本或帮助测试候选版本。_

- [Libsecp256k1 v0.7.0][] 是这个包含兼容比特币的密码学原语的库的一个发布。它包含一些小的更改，与之前版本的 API/ABI 不兼容。

## 显著代码和文档变更

_最近在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo]和 [BINANAs][binana repo]._

- [Bitcoin Core #32521][] 使多于 2500 个签名操作（sigops）的旧交易成为非标准交易，为潜在的[共识清理软分叉][topic consensus cleanup]升级做准备，该升级将在共识级别强制执行限制。如果未来的软分叉不包含此项变更，不升级的矿工可能会被轻而易举的 DoS 所攻击。请参阅周报 [#340][news340 sigops] 了解有关旧输入 sigops 限制的更多详细信息。

- [Bitcoin Core #31829][] 在对孤儿交易的处理程序 `TxOrphanage`（请参阅周报 [#304][news304 orphan]）中添加了资源限制，以在 DoS 垃圾交易攻击中保留机会性的单父单子（1p1c）[包中继][topic package relay]。四个限制会被强制要求：全局上限为 3,000 个孤儿交易公告（以最小化 CPU 和延迟成本）、按对等节点比例的孤儿交易公告上限、每个对等节点权重预留 24 × 400 kWU、可变全局内存上限。当任何限制超出时，节点会驱逐来自使用最多 CPU 或内存的对等节点的最早孤立公告（最高的节点 DoS 分数）。PR 还删除了 `‑maxorphantxs` 选项（默认 100），其驱逐随机公告的政策允许攻击者替换整个孤立集并使 [1p1c 中继][1p1c relay] 无用。另请参阅 [周报 #362][news362 orphan]。

- [LDK #3801][] 扩展了[可归因失败][topic attributable failures]到支付成功路径，记录节点持有 [HTLC][topic htlc] 的时间并向上游在属性负载中传播这些持有时间值。以前，LDK 仅跟踪失败支付的持有时间（请参阅周报 [#349][news349 attributable]）。

- [LDK #3842][] 扩展了其[交互式交易构建][topic dual funding]的状态机（请参阅周报 [#295][news295 dual]）以处理[拼接][topic splicing]交易中的共享输入签名协调。`TxAddInput` 消息的 `prevtx` 字段变为可选，以减少内存使用并简化验证。

- [BIPs #1890][] 将分隔符参数从 `+` 更改为 `-` 在 [BIP77][] 中，因为一些 HTML 2.0 URI 库将 `+` 视为空白。此外，片段参数现在必须按字典顺序排列，而不是反向，以简化异步 [payjoin][topic payjoin] 协议。

- [BOLTs #1232][] 使 `channel_type` 字段（请参阅周报 [#165][news165 type]）在打开通道时成为必需，因为每个实现都强制执行它。此 PR 还更新了 [BOLT9][] ，通过添加一个新的上下文类型 `T` 来包含可以包含在 `channel_type` 字段中的功能。

{% include snippets/recap-ad.md when="2025-07-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32521,31829,3801,3842,1890,1232" %}
[morehouse gosvuln]: https://delvingbitcoin.org/t/disclosure-lnd-gossip-timestamp-filter-dos/1859
[tan ccw]: https://delvingbitcoin.org/t/chain-code-delegation-private-access-control-for-bitcoin-keys/1837
[mpc]: https://zh.wikipedia.org/wiki/%E5%AE%89%E5%85%A8%E5%A4%9A%E6%96%B9%E8%AE%A1%E7%AE%97
[posner qc]: https://delvingbitcoin.org/t/post-quantum-hd-wallets-silent-payments-key-aggregation-and-threshold-signatures/1854
[Libsecp256k1 v0.7.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.0
[news340 sigops]: /zh/newsletters/2025/02/07/#introduce-legacy-input-sigops-limit-sigops
[news304 orphan]: /zh/newsletters/2024/05/24/#bitcoin-core-30000
[1p1c relay]: /zh/bitcoin-core-28-wallet-integration-guide/#一父一子交易1p1c中继
[news349 attributable]: /zh/newsletters/2025/04/11/#ldk-2256
[news295 dual]: /zh/newsletters/2024/03/27/#ldk-2419
[news165 type]: /zh/newsletters/2021/09/08/#bolts-880
[news362 orphan]: /zh/newsletters/2025/07/11/#bitcoin-core-rp-审核俱乐部
