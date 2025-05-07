---
title: 'Bitcoin Optech Newsletter #351'
permalink: /zh/newsletters/2025/04/25/
name: 2025-04-25-newsletter-zh
slug: 2025-04-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报宣布了一个与 secp256k1 兼容的新聚合签名协议，并描述了一个钱包描述符的标准化备份方案。此外还有我们的常规部分：总结了近期的 Bitcoin Stack Exchange 精选问答、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--interactive-aggregate-signatures-compatible-with-secp256k1-->****与 secp256k1 兼容的交互式聚合签名：** Jonas Nick、Tim Ruffing 和 Yannick Seurin 在 Bitcoin-Dev 邮件列表上[发布][nrs dahlias]了他们撰写的一篇[论文][dahlias paper]，内容是关于创建与比特币已使用的密码学原语兼容的 64 字节聚合签名。聚合签名是[跨输入签名聚合][topic cisa]（CISA）的密码学要求，这是一个为比特币提议的功能，可以减少具有多个输入的交易的大小，从而降低多种不同类型花费的成本——包括通过 [coinjoin][topic coinjoin] 和 [payjoin][topic payjoin] 实现的增强隐私的花费。

  除了作者提出的 DahLIAS 这样的聚合签名方案外，为比特币添加 CISA 支持还需要共识变更，以及签名聚合与其他提议的共识变更之间可能的交互，这些变更可能需要进一步研究。

- **<!--standardized-backup-for-wallet-descriptors-->钱包描述符的标准化备份：** Salvatore Ingala 在 Delving Bitcoin 上[发布][ingala backdes]了一份关于备份钱包[描述符][topic descriptors]的各种权衡的总结，以及一个应该对许多不同类型的钱包（包括使用复杂脚本的钱包）有用的提议方案。他的方案使用确定性生成的 32 字节密钥来加密描述符。对于描述符中的每个公钥（或扩展公钥），密钥的副本与公钥的变体进行异或，为 _n_ 个公钥创建 _n_ 个 32 字节的密钥加密。任何知道描述符中使用的一个公钥的人都可以将其与 32 字节的密钥加密进行异或，得到可以解密描述符的 32 字节密钥。这个简单高效的方案允许任何人在多种媒体和网络位置存储描述符的多个加密副本，然后使用他们的 [BIP32 钱包种子][topic bip32]生成他们的 xpub，如果他们丢失了钱包数据，可以用它来解密描述符。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是他们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--practicality-of-half-aggregated-schnorr-signatures-->半聚合 schnorr 签名的实用性？]({{bse}}125982)
  Fjahr 讨论了为什么在[跨输入签名聚合 (CISA)][topic cisa]中验证半聚合签名不需要独立的、未聚合的签名，以及为什么未聚合的签名实际上可能会有问题。

- [<!--what-s-the-largest-size-op-return-payload-ever-created-->有史以来最大的 OP_RETURN 载荷是多少？]({{bse}}126131)
  Vojtěch Strnad [链接][op_return tx]到一个 Runes [元协议][topic client-side validation]交易，其 `OP_RETURN` 大小为 79870 字节，是最大的。

- [<!--non-ln-explanation-of-pay-to-anchor-->对 pay-to-anchor 的非闪电网络解释？]({{bse}}126098)
  Murch 详细说明了 [pay-to-anchor (P2A)][topic ephemeral anchors]输出脚本的原理和结构。

- [<!--up-to-date-statistics-about-chain-reorganizations-->关于链重组的最新统计数据？]({{bse}}126019)
  0xb10c 和 Murch 指出了重组数据的来源，包括 [stale-blocks][stale-blocks github] 库、[forkmonitor.info][] 网站和 [fork.observer][] 网站。

- [<!--are-lightning-channels-always-p2wsh-->闪电网络通道总是 P2WSH 吗？]({{bse}}125967)
  Polespinasa 指出了 P2TR [简单 taproot 通道][topic simple taproot channels]的持续开发，并总结了各闪电网络实现的当前支持情况。

- [<!--child-pays-for-parent-as-a-defense-against-a-double-spend-->子为父偿作为防御双重花费的手段？]({{bse}}126056)
  Murch 列出了使用高手续费的 [CPFP][topic cpfp] 子交易来激励区块链重组以防御已确认的双重花费输出的复杂性。

- [<!--what-values-does-checktemplateverify-hash-->CHECKTEMPLATEVERIFY 哈希哪些值？]({{bse}}126133)
  Average-gray 概述了 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 承诺的字段：nVersion、nLockTime、输入数量、序列哈希、输出数量、输出哈希、输入索引，以及在某些情况下的 scriptSig 哈希。

- [<!--why-can-t-lightning-nodes-opt-to-reveal-channel-balances-for-better-routing-efficiency-->为什么闪电网络节点不能选择透露通道余额以提高路由效率？]({{bse}}125985)
  Rene Pickhardt 解释了对数据的陈旧性和可信度的担忧、隐私影响，并指出了 2020 年的一个[类似提案][BOLTs #780]。

- [<!--does-post-quantum-require-hard-fork-or-soft-fork-->后量子需要硬分叉还是软分叉？]({{bse}}126122)
  Vojtěch Strnad 概述了[后量子][topic quantum resistance]（PQC）签名方案如何通过[软分叉激活][topic soft fork activation]的方法，以及硬分叉或软分叉如何锁定量子易受攻击的币。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.19.0-beta.rc3][] 是这个流行的闪电网络节点的候选版本。可能需要测试的主要改进之一是合作关闭场景中新的基于 RBF 的手续费提升。

## 重大代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #31247][] 添加了对序列化和解析 [BIP373][] 中指定的 [MuSig2][topic musig] [PSBT][topic psbt] 字段的支持，以允许钱包签名和花费 [MuSig2][topic musig] 输入。在输入方面，这包括一个列出参与者公钥的字段，以及每个签名者的单独公共随机数字段和单独的部分签名字段。在输出方面，它是一个列出新 UTXO 的参与者公钥的单一字段。

- [LDK #3601][] 添加了一个新的 `LocalHTLCFailureReason` 枚举来表示每个标准 [BOLT4][] 错误代码，以及一些变体，这些变体向用户提供了先前因隐私原因而被移除的额外信息。

{% include snippets/recap-ad.md when="2025-04-29 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31247,3601,780" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[nrs dahlias]: https://mailing-list.bitcoindevs.xyz/bitcoindev/be3813bf-467d-4880-9383-2a0b0223e7e5@gmail.com/
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[ingala backdes]: https://delvingbitcoin.org/t/a-simple-backup-scheme-for-wallet-accounts/1607
[op_return tx]: https://mempool.space/tx/fd3c5762e882489a62da3ba75a04ed283543bfc15737e3d6576042810ab553bc
[stale-blocks github]: https://github.com/bitcoin-data/stale-blocks
[forkmonitor.info]: https://forkmonitor.info/nodes/btc
[fork.observer]: https://fork.observer/
