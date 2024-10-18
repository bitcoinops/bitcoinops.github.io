---
title: 'Bitcoin Optech Newsletter #323'
permalink: /zh/newsletters/2024/10/04/
name: 2024-10-04-newsletter-zh
slug: 2024-10-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报宣布了一个即将发布的安全披露，还包括了我们常规的部分：描述新版本、候选版本以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--impending-btcd-security-disclosure-->****即将到来的 btcd 安全披露：** Antoine Poinsot 在 Delving Bitcoin 中[发布][poinsot btcd]消息，宣布将在 10 月 10 日披露影响 btcd 全节点的共识漏洞。根据活跃节点的粗略调查数据，Poinsot 推测约有 36 个 btcd 节点容易受到攻击(其中 20 个节点也易受已公开的漏洞影响见[周报 #286][news286 btcd vuln])。在[回复][osuntokun btcd]中，btcd 维护者 Olaoluwa Osuntokun 证实了该漏洞的存在，并指出该漏洞已在 btcd 版本 0.24.2 中修复。鼓励运行较旧版本的用户升级到[最新版本][btcd v0.24.2]，该版本已经被宣布为安全的关键版本。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 28.0][] 是主流全节点实现的最新主要版本，这是首个包含了 [testnet4][topic testnet]、机会性一父一子（1p1c）[包中继][topic package relay]、默认中继选择性拓扑限制直到确认([TRUC][topic v3 transaction relay])交易、默认中继支付到锚点[pay-to-anchor][topic ephemeral anchors]交易、有限的包手续替换 [RBF][topic rbf]中继以及默认全面的手续费替换 [full-RBF][topic rbf] 的版本。已添加 [assumeUTXO][topic assumeutxo] 的默认参数，以允许使用在比特币网络之外下载的 UTXO 集（例如通过 torrent 下载）来使用`loadtxoutset` RPC。该版本还包括许多其他改进和错误修复，详情请见其[版本说明][bcc 28.0 rn]。

- [BDK 1.0.0-beta.5][] 是这个用于构建钱包和其他支持比特币的应用程序的库的候选版本（RC）。这个最新的 RC 版本“默认启用了 RBF（手续费替换），更新了 bdk_esplora 客户端以重试因速率限制而失败的服务器请求。`bdk_electrum` 包现在还提供了一个 use-openssl 功能。”

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #30043][] 引入了[端口控制协议(PCP)][rfcpcp]的内置实现，以支持 IPv6 pinholing，允许节点在不需要手动配置路由器的情况下变得可访问。此更新用 PCP 替换了现有的用于 IPv4 端口映射的 `libnatpmp` 依赖，同时还实现了一个回退机制到 [NAT 端口映射协议(NAT-PMP)][rfcnatpmp]。虽然 PCP / NAT-PMP 功能默认是禁用的，但在未来的版本中可能会改变。见周报[#131][news131 natpmp]。

- [Bitcoin Core #30510][] 为 `Mining` 接口添加了一个进程间通信(IPC)包装器 (见周报[#310][news310 stratumv2])，允许独立的 [Stratum v2][topic pooled mining] 挖矿进程通过连接和控制 `bitcoin-node` 进程来创建、管理和提交区块模板(见周报[#320][news320 stratumv2])。[Bitcoin Core #30409][]扩展了 `Mining` 接口，增加了一个新的 `waitTipChanged()` 方法，该方法可以检测新区块的到来，然后将新的区块模板推送给已连接的客户端。`waitfornewblock`、`waitforblock` 和 `waitforblockheight` RPC 方法已被重构以使用它。

- [Core Lightning #7644][] 为 `hsmtool` 工具添加了 `nodeid`命令，该命令返回给定的 `hsm_secret` 备份文件的节点标识符，以将备份与其特定节点匹配，并避免与其他节点混淆。

- [Eclair #2848][] 实现了可扩展的[流动性广告][topic liquidity advertisements]，如 [BOLTs #1153][]所指出的那样，允许卖家在其 `node_announcement` 消息中广告他们愿意向买家出售流动性的费率，然后买家可以连接并请求流动性。这可以在创建[双向注资通道][topic dual funding]时使用，或在通过[通道拼接][topic splicing]向现有通道添加额外流动性时使用。

- [Eclair #2860][] 添加了一个可选的 `recommended_feerates` 消息，供节点向其对等节点告知他们希望用于注资通道交易的可接受费率。如果一个节点拒绝了对等节点的注资请求，对等节点将理解这是由于费率原因。

- [Eclair #2861][] 实现了“空中加油”（on-the-fly）注资，如 [BLIPs #36][]所指出的那样，允许没有足够入账流动性的客户端通过[流动性广告][topic liquidity advertisements]协议(见上面 PR)向对等节点请求额外流动性，以接收付款。流动性卖家承担[双向注资通道][topic dual funding]或是[通道拼接][topic splicing]交易的链上交易费用，但后续便可在路由支付时得到买方的支付。如果金额不足以支付交易确认所需的链上费用，卖家可以双花它以在其他地方使用他们的流动性。

- [Eclair #2875][] 实现了注资费用积分，如 [BLIPs #41][] 所指出的那样，允许 on-the-fly 注资 (见上面 PR) 客户端接受太小而不足以支付通道链上费用的付款（但同时积累费用积分）。一旦积累了足够的费用积分，对手就会创建一个链上交易，如通道注资或[通道拼接][topic splicing]。客户端要依赖流动性提供者在未来的交易中兑现费用积分。

- [LDK #3303][] 为入账支付添加了一个新的 `PaymentId`，以改善幂等事件处理。这允许用户在节点重启期间重放事件时轻松检查事件是否已被处理。依赖 `PaymentHash` 时可能出现的重复处理风险被消除。`PaymentId` 是支付中包含的 [HTLC][topic htlc] 通道标识符和 HTLC 标识符对的基于哈希的消息认证码（HMAC）。

- [BDK #1616][] 在 `TxBuilder` 类中默认启用选择性-[RBF][topic rbf]信号。调用者可以通过更改序列号来禁用该信号。

- [BIPs #1600][] 对[BIP85][] 规范进行了几项更改，包括指定 `drng_reader.read` (负责读取随机数) 是一个一级函数而不是一个评估。此更新还澄清了字节序处理，增加了对 [testnet][topic testnet]的支持，包括一个新的 Python 参考实现，澄清 [HD 钱包][topic bip32]种子钱包导入格式(WIF) 使用最高有效位，添加了葡萄牙语语言代码，并修正了测试向量。最后，为 BIP 规范指定了一个新的拥护者。

- [BOLTs #798][] 合并了 [offers][topic offers] 协议规范，引入了 [BOLT12][]，同时也对 [BOLT1][] 和 [BOLT4][]进行了几项更新。

{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30043,30510,7644,2875,2861,2860,2848,3303,1616,1600,798,30409,1153,36,41" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[bitcoin core 28.0]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[poinsot btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177
[osuntokun btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177/3
[news286 btcd vuln]: /zh/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd-btcd
[btcd v0.24.2]: https://github.com/btcsuite/btcd/releases/tag/v0.24.2
[bcc 28.0 rn]: https://github.com/bitcoin/bitcoin/blob/5de225f5c145368f70cb5f870933bcf9df6b92c8/doc/release-notes.md
[rfcpcp]: https://datatracker.ietf.org/doc/html/rfc6887
[rfcnatpmp]: https://datatracker.ietf.org/doc/html/rfc6886
[news131 natpmp]: /en/newsletters/2021/01/13/#bitcoin-core-18077
[news310 stratumv2]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news320 stratumv2]: /zh/newsletters/2024/09/13/#bitcoin-core-30509