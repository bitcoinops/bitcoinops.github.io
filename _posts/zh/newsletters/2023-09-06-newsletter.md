---
title: 'Bitcoin Optech Newsletter #267'
permalink: /zh/newsletters/2023/09/06/
name: 2023-09-06-newsletter-zh
slug: 2023-09-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了一种用于压缩比特币交易的新技术，总结了一种关于在联合签名服务中加强隐私性的想法。此外还有我们的常规部分：新版本和候选版本的公告，以及热门的比特币基础设施软件的显著变更的介绍。

## 新闻

- **<!--bitcoin-transaction-compression-->比特币交易压缩**：Tom Briar 在 Bitcoin-Dev 邮件组中[发帖][briar compress]展示了一种比特币交易压缩方法的[规范草案][compress spec]和[提议实现][compress impl]。体积更小的交易更加易于在带宽较小的媒介 —— 比如卫星和隐写术（比如，用一个位图图像来编码一笔交易） —— 上转发。传统的压缩算法的原理是，在大部分结构化的数据中，都有一些元素比另一些元素更常出现。但是，标准的比特币交易主要由无差异的元素（看起来随机的数据）组成，比如公钥和哈希摘要。

    Briar 的提议利用了几种方法来解决这个问题：

    - 对于当前使用 4 个字节来表示一个整数的部分（例如，交易版本号和输出点索引），将它们替换成变长的整数，这可以小 2 个比特。

    - 对于每个输入中的 32 字节长的输出点 txid（这个数值在区间内是均匀分布的），替换成对该交易所在区块的位置的引用，就使用区块高度和该交易在区块内的位置，例如，`123456` 和 `789` 就意味着高度为 123,456 的区块内的第 789 笔交易。因为特定高度的区块可能会因为区块链重组而改变（从而打破这个引用，使人们无法解压缩这个交易），这个方法仅用在被索引的交易得到 100 个区块确认以上的时候。

    - 对于 P2WPKH 交易， 由于其见证脚本结构中需要包含一个签名加上 33 字节的公钥，这个公钥会被省去，并使用一种技术从签名中重建其公钥。

    还有一些别的技术，用来节约标准交易中的少量额外的字节。这个提议的总体缺点在于，与处理一笔常规的序列化交易相比，将一笔压缩交易转化成全节点和其它软件可以处理的东西，需要消耗更多的 CPU、内存和 I/O。这意味着，高带宽的连接将继续使用常规的交易格式，只有低带宽的传输才会使用压缩交易。

    这个想法得到了少量讨论，绝大部分都围绕着为每个输入节约少量额外空间的想法。

- **<!--privacy-enhanced-cosigning-->在联合签名服务中强化隐私**：Nick Farrow 在 Bitcoin-Dev 邮件组中[发帖][farrow cosign]讨论了 “[FROST][]” 这样的[无脚本的门限签名方案][topic threshold signature]如何能够提升使用联合签名服务的用户的隐私性。联合签名服务的一个普通用户可能有多个签名密钥，而且为了安全性存储在多个地点；但是，为了简化日常花费操作，他们也会允许自己的输出可被自己的部分签名密钥加上来自一个或多个服务商的一个或多个密钥花费，服务商们会在签名前以某种方式验证用户的身份。如果有必要，用户可以绕过服务商，但在大部分时候，服务商都会让操作变得更加容易。

    在 2-of-3 `OP_CHECKMULTISIG` 这样的基于脚本的门限签名方案中，服务商的公钥必然跟被花费的输出有关联，所以任何服务商都可以通过观察链上数据，找出自己签过名的交易，从而他们可以积累关于用户的数据。最糟糕的是，我们已知的所有正在使用的协议，都会在签名之前直接向服务商揭晓用户的交易，所以服务商可以拒绝签名某些交易。

    如 Farrow 所述，FROST 允许在整个流程的每一步中都向服务商隐藏交易的信息。从输出脚本的生成、到签名、再到完整签名交易的发布。服务商所知的仅仅是自己签名的时机，以及用户用于证明自己的身份而向服务商提供的数据。

    这个想法在邮件组中得到了一些讨论。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Libsecp256k1 0.4.0][] 是这个 Bitcoin 相关的密码学操作库的最新版本。这个版本包含了一个模块，实现了 ElligatorSwift 编码。见项目的[更新日志][libsecp cl]以获得更多信息。

- [LND v0.17.0-beta.rc2][] 是这个流行的闪电节点实现的下一个大版本的候选版本。为这个版本计划的一个重大的新的实验性功能，也是可能从测试中受益的功能，就是支持 “简单的 taproot 通道”。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]，和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #28354][] 将测试网模式下的 `-acceptnonstdtxn` 的默认值改为 0，这也是所有其它网络模式下的默认值。这个变更将帮助应用避免创建非标准的交易，并因此被主网上使用默认值的节点拒绝。

- [LDK #2468][] 允许用户在发票请求的元数据字段提供一个加密的 `payment_id`。LDK 会在收到的发票中检查元数据，并仅在找出了 id 并确认没有在另一张发票中为之支付之后才支付。这个 PR 是 LND 迈向实现 [BOLT12][topic offers] 的一部分 [工作][ldk bolt12]。


{% include references.md %}
{% include linkers/issues.md v=2 issues="28354,2468" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021924.html
[compress spec]: https://github.com/TomBriar/bitcoin/blob/2023-05--tx-compression/doc/compressed_transactions.md
[compress impl]: https://github.com/TomBriar/bitcoin/pull/3
[farrow cosign]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021917.html
[frost]: https://eprint.iacr.org/2020/852
[libsecp cl]: https://github.com/bitcoin-core/secp256k1/blob/master/CHANGELOG.md
[libsecp256k1 0.4.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.0
[ldk bolt12]: https://github.com/lightningdevkit/rust-lightning/issues/1970
