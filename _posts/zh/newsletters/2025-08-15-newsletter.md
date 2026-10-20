---
title: 'Bitcoin Optech Newsletter #367'
permalink: /zh/newsletters/2025/08/15/
name: 2025-08-15-newsletter-zh
slug: 2025-08-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报包含我们的常规部分，宣布新的候选发布版本，并总结流行比特币基础设施软件的值得注意的变更。

## 新闻

_本周在我们的[消息来源][optech sources]中未发现值得注意的新闻。_

## 发布与候选发布

_流行比特币基础设施项目的新版本与候选版本。请考虑升级至新版本，或帮助测试候选版本。_

- [LND v0.19.3-beta.rc1][] 是这个流行闪电网络节点实现的维护版本候选发布，包含“重要的错误修复”。最值得注意的是，“一个可选的迁移[...] 显著降低了节点的磁盘和内存需求。”

- [Bitcoin Core 29.1rc1][] 是这个主流全节点软件的维护版本的候选发布。

## 值得注意的代码与文档变更

_[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 中值得注意的最近变更。_

- [Bitcoin Core #33050][] 移除了对共识无效交易的对等节点的阻拦（见[周报 #309][news309 peer]），因为其 DoS 保护是无效的。攻击者可以通过大量发送在转发策略上属于无效的垃圾交易来绕过该保护而不受惩罚。此更新消除了双重脚本验证的需要，因为不再需要把交易失败是从共识还是标准性上进行区分，从而节省 CPU 成本。

- [Bitcoin Core #32473][] 为脚本解释器引入了针对传统（例如裸多签）、P2SH、P2WSH（以及偶尔出现的 P2WPKH）输入的每输入签名哈希预计算缓存，以减少标准交易中二次哈希攻击的影响。Core 缓存了一个几乎完成的哈希，该哈希在附加签名哈希字节之前计算，以减少标准多重签名交易和类似模式的重复哈希。同一输入中具有相同签名哈希模式且提交到脚本相同部分的另一个签名可以重用大部分工作。它在策略（交易池）和共识（区块）验证中都启用。[Taproot][topic taproot] 输入默认已具有此行为，因此此更新不需要应用于它们。

- [Bitcoin Core #33077][] 创建了一个单体静态库 [`libbitcoinkernel.a`][libbitcoinkernel project]，将其私有依赖项的所有目标文件打包到单个存档中，允许下游项目仅链接到此一个文件。有关相关的 `libsecp256k1` 基础工作，请参见[周报 #360][news360 kernel]。

- [Core Lightning #8389][] 在打开通道时使 `channel_type` 字段成为强制性的，与最近的规范更新保持一致（见[周报 #364][news364 spec]）。RPC 命令 `fundchannel` 和 `fundchannel_start` 现在通过零值的 `minimum_depth` 来隐含地告知一个具有[零确认通道][topic zero-conf channels]选项的通道类型。

{% include snippets/recap-ad.md when="2025-08-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33050,32473,33077,8389" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[news309 peer]: /zh/newsletters/2024/06/28/#bitcoin-core-29575
[news360 kernel]: /zh/newsletters/2025/06/27/#libsecp256k1-1678
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
[news364 spec]: /zh/newsletters/2025/07/25/#bolts-1232
