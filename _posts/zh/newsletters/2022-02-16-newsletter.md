---
title: 'Bitcoin Optech Newsletter #187'
permalink: /zh/newsletters/2022/02/16/
name: 2022-02-16-newsletter-zh
slug: 2022-02-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了围绕比特币契约的持续讨论，并包含我们常规的版块，概述了服务和客户端软件的变化，以及流行比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--simplified-alternative-to-op-txhash-->****简化版 `OP_TXHASH` 的替代方案：** 在关于启用[契约][topic covenants]的操作码（参见 [Newsletter #185][news185 composable]）的持续讨论中，Rusty Russell [提议][russell op_tx]，`OP_TXHASH` 所提供的功能可以通过现有的 `OP_SHA256` 操作码加上一个新的 `OP_TX` 操作码来实现，后者接受与 `OP_TXHASH` 相同的输入。新的操作码会将支出交易中的序列化字段暴露给 [tapscript][topic tapscript]。脚本随后可以直接检测这些字段（例如：交易版本号是否大于 1？），或者对数据进行哈希并与此前提议的 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 操作码验证的签名进行比较。

## 服务与客户端软件的变更

*在这个每月专栏中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--blockchain-com-wallet-adds-taproot-sends-->****Blockchain.com Wallet 新增 taproot 发送功能：** Android 版 Blockchain.com Wallet 的 [v202201.2.0(18481)][blockchain.com v202201.2.0(18481)] 现已支持向 [bech32m][topic bech32] 地址发送。在撰写本文时，iOS 版本尚未支持向 bech32m 地址发送。

- **<!--sensei-lightning-node-implementation-launches-->****Sensei 闪电网络节点实现发布：** 处于 beta 阶段的 [Sensei][sensei website] 基于 [Bitcoin Dev Kit (BDK)][bdk website] 与 [Lightning Dev Kit (LDK)][ldk website] 构建。目前该节点需要 Bitcoin Core 与 Electrum Server，未来计划支持更多后端选项。

- **<!--bitmex-adds-taproot-sends-->****BitMEX 新增 taproot 发送功能：** BitMEX 在最近的[博客文章][bitmex blog]中宣布已支持 bech32m 提现。文章还指出，73% 的 [BitMEX 用户充值][news141 bitmex bech32 receive]使用 P2WSH 输出，可节省约 65% 的手续费。

- **<!--bitbox02-adds-taproot-sends-->****BitBox02 新增 taproot 发送功能：** [v9.9.0 - Multi][bitbox02 v9.9.0 multi] 和 [v9.9.0 - Bitcoin-only][bitbox02 v9.9.0 bitcoin] 两个版本都已支持向 bech32m 地址发送。

- **<!--fulcrum-1-6-0-adds-performance-improvements-->****Fulcrum 1.6.0 提升性能：** 地址索引软件 Fulcrum 在 [1.6.0 版本][fulcrum 1.6.0]中加入了[性能改进][sparrow docs performance]。

- **<!--kraken-announces-proof-of-reserves-scheme-->****Kraken 公布储备证明方案：** Kraken [详细介绍][kraken por]其包含受信审计方的储备证明方案，同时指出其不足并计划未来改进。Kraken 通过数字签名证明链上地址归属，生成用户账户余额的默克尔树，邀请审计方证明链上余额大于账户总额，并提供工具让用户验证自己的余额已包含在该树中。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Eclair #2164][Eclair #2164] 在多个场景中改进了对特性位的处理。特别是，要求强制但非发票特性的发票将不再被拒绝，因为缺乏对非发票特性的支持并不会影响发票的兑付能力。

- [BTCPay Server #3395][BTCPay Server #3395] 为发票收到的付款和钱包发送的交易新增了 [CPFP（Child Pays For Parent）][topic cpfp] 手续费加速支持。

- [BIPs #1279][BIPs #1279] 更新了 [BIP322][] 关于通用 Signmessage 协议的规范，补充了若干说明及测试向量。


{% include references.md %}
{% include linkers/issues.md v=1 issues="2164,3395,1279" %}
[russell op_tx]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019871.html
[news185 composable]: /zh/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[blockchain.com v202201.2.0(18481)]: https://github.com/blockchain/My-Wallet-V3-Android/releases/tag/v202201.2.0(18481)
[sensei website]: https://l2.technology/sensei
[bdk website]: https://bitcoindevkit.org/
[ldk website]: https://lightningdevkit.org/
[bitmex blog]: https://blog.bitmex.com/bitmex-supports-sending-to-taproot-addresses/
[news141 bitmex bech32 receive]: /en/newsletters/2021/03/24/#bitmex-announces-bech32-support
[bitbox02 v9.9.0 multi]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware%2Fv9.9.0
[bitbox02 v9.9.0 bitcoin]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware-btc-only%2Fv9.9.0
[fulcrum 1.6.0]: https://github.com/cculianu/Fulcrum/releases/tag/v1.6.0
[sparrow docs performance]: https://www.sparrowwallet.com/docs/server-performance.html
[kraken por]: https://www.kraken.com/proof-of-reserves
