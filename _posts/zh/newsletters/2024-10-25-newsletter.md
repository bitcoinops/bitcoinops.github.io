---
title: 'Bitcoin Optech Newsletter #326'
permalink: /zh/newsletters/2024/10/25/
name: 2024-10-25-newsletter-zh
slug: 2024-10-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于新的闪电网络（LN）通道公告提案的更新，并描述了一份利用 PSBT 发送静默支付的 BIP。此外，还包括我们的常规部分：其中包括 Bitcoin Stack Exchange 的热门问答、新版本和候选版本的公告，以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--updates-to-the-version-1-75-channel-announcements-proposal-->关于 1.75 版本通道公告提案的更新：** Elle Mouton 在 Delving Bitcoin 上[发布了][mouton chanann]一些针对[新的通道公告][topic channel announcements]协议的更改建议，该协议将支持[简单 taproot 通道][topic simple taproot channels]。最重要的计划变更是允许消息也能公告当前样式的 P2WSH 通道；这将允许节点在“网络大部分节点似乎已升级时，后续逐步停止使用传统协议。”

  另一个最近讨论的新增功能(见[周报 #325][news325 chanann])是允许公告包含 SPV 证明，以便任何拥有完整工作量证明区块头的客户端都能验证该通道的注资交易是否已包含在一个区块中。目前，轻客户端必须下载整个区块，才能对通道公告进行同等程度的验证。

  Mouton 的帖子还简要讨论了现有简单 Taproot 通道的选择性公告功能。由于目前不支持非 P2WSH 通道的公告，所有现有的 Taproot 通道都是[未公告（私有）的][topic unannounced channels]。可以添加到提案中的一个可能功能是允许节点向其对等节点发出信号，表明它们想要将未公告的通道转换为公开通道。

- **<!--draft-bip-for-sending-silent-payments-with-psbts-->通过 PSBT 发送静默支付的 BIP 草案：** Andrew Toth 在 Bitcoin-Dev 邮件列表中[发布了][toth sp-psbt]一项 BIP 草案，允许钱包和签名设备使用 [PSBT][topic psbt] 来协调创建[静默支付][topic silent payments]。这是对之前 BIP 草案持续讨论的延续，见周报[#304][news304 sp]和[#308][news308 sp]。如之前的那些内容所述，静默支付相较于大多数其他 PSBT 协调的交易的特殊需求在于，对未完全签名交易的输入进行任何修改都要求重新调整输出。

  该草案仅涵盖了签名者拥有交易中所有输入的私钥的最常见情况。对于多重签名这样的少数情况，Toth 表示“这将在后续的 BIP 中详细说明”。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是他们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--duplicate-blocks-in-blk-dat-files-->blk*.dat 文件中有重复区块?]({{bse}}124368)
  Pieter Wuille 解释道，除了当前的最佳区块链之外，区块数据文件还可以包含废弃的区块或重复的区块数据。

- [<!--how-was-the-structure-of-pay-to-anchor-decided-->支付到锚点(P2A)的结构是如何决定的？]({{bse}}124383)
  Antoine Poinsot 描述了 Bitcoin Core 28.0 [规则变更][bcc28 guide]中包含的[支付到锚点(P2A)][topic ephemeral anchors]输出的结构。一个经过 [bech32m][topic bech32]编码、2-字节长度的 v1 见证程序被选择作为 `bc1pfeessrawgf` “靓号”地址。

- [<!--what-are-the-benefits-of-decoy-packets-in-bip324-->BIP324 中使用诱导包的好处是什么？]({{bse}}124301)
  Pieter Wuille 概述了 [BIP324][] 规范中[包含诱导包][bip324 decoy packets]的设计决策。可选的诱导包可用于混淆流量模式，从而防止观察者在密钥交换、应用和协议的版本协商阶段识别出模式。

- [<!--why-is-the-opcode-limit-201-->为什么操作码限制为 201？]({{bse}}124465)
  Vojtěch Strnad 指出，中本聪在 2010 年的代码更改，原意是将操作码限制为 200，但由于实现错误，实际限制为 201。

- [<!--will-my-node-relay-a-transaction-if-it-is-below-my-minimum-tx-relay-fee-->如果交易低于我的最低交易转发费率，我的节点是否会转发交易？]({{bse}}124387)
  Murch 指出，节点只会转发其自己交易池接受的交易。尽管用户可以调低自己节点的 `minTxRelayFee` 值以让本地交易池接受低费率交易，但要将低费率交易包含在区块中，最终仍需要矿工也使用类似的设置，并且平均费率趋于该低费率。

- [<!--why-doesn-t-the-bitcoin-core-wallet-support-bip69-->为什么 Bitcoin Core 钱包不支持 BIP69？]({{bse}}124382)
  Murch 认为 [BIP69][]的交易输入/输出排序规范如果能得到广泛采用，将有助于减轻[钱包指纹][ishaana fingerprinting]识别。但他指出，鉴于普遍采用的可能性较低，实现 BIP69 本身可能会成为一个指纹识别漏洞。

- [<!--how-can-i-enable-testnet4-when-using-bitcoin-core-28-0-->如何在使用 Bitcoin Core 28.0 时启用 testnet4？]({{bse}}124443)
  Pieter Wuille 提到启用 [BIP94][] 的 [testnet4][topic testnet]的两个配置选项：`chain=testnet4` 和 `testnet4=1`。

- [<!--what-are-the-risks-of-broadcasting-a-transaction-that-reveals-a-scriptpubkey-using-a-low-entropy-key-->广播暴露使用低熵密钥的 `scriptPubKey` 的交易有哪些风险？]({{bse}}124296)
  用户 Quuxplusone 链接了一个最近的交易案例，这个交易与 2015 年的一系列比特币密钥破解[“谜题”][puzzle bitcointalk]有关，[据推测][puzzle stackernews]，该交易被一个监控交易池中低熵密钥的机器人[所替换][topic rbf]。

## 版本和候选版本

_热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning 24.08.2][] 是这个热门的闪电网络实现的维护版本，包含“一些崩溃修复和一项用于记住和更新通道提示的改进”。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Eclair #2925][] 通过新的 `rbfsplice` API 命令在[通道拼接][topic splicing]交易中引入[手续费替换（RBF）][topic rbf] 的支持，该命令会触发 `tx_init_rbf` 和 `tx_ack_rbf` 消息交换，以便对等方同意替换交易。此功能仅适用于非[零确认通道][topic zero-conf channels]，以防止零确认通道上可能的资金盗窃。在零确认通道上允许未确认的通道拼接交易的链条，但在非零确认通道上则不允许。此外，RBF 在[流动性广告][topic liquidity advertisements]协议中的流动性购买交易上被阻止，以避免在卖方未收到付款的情况下添加流动性至通道的极端情况。

- [LND #9172][] 为 `lncli create` 和 `lncli createwatchonly` 命令添加了一个新的 `mac_root_key` 标志，用于生成确定性的 macaroon（身份验证令牌），允许在 LND 节点初始化之前将外部密钥嵌入节点中。这在与 [LND #8754][](见[周报 #172][news172 remote]) 中建议的反向远程签名器设置结合使用时特别有用。

- [Rust Bitcoin #2960][] 将支持附带数据的 [ChaCha20-Poly1305][rfc8439]认证加密算法（AEAD）转化为独立的程序包，使其可以用于 [BIP324][]
  中指定的[v2 传输协议][topic v2 p2p transport]以外的用途，例如用于 [payjoin V2][topic payjoin]。该代码已针对单指令多数据（SIMD）指令支持进行了优化，以提高各种用例下的性能 (见[周报 #264][news264 chacha])。

{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2925,9172,2960,8754" %}
[mouton chanann]: https://delvingbitcoin.org/t/updates-to-the-gossip-1-75-proposal-post-ln-summit-meeting/1202/
[news325 chanann]: /zh/newsletters/2024/10/18/#gossip-upgrade
[toth sp-psbt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cde77c84-b576-4d66-aa80-efaf4e50468fn@googlegroups.com/
[news304 sp]: /zh/newsletters/2024/05/24/#discussion-about-psbts-for-silent-payments-psbt
[news308 sp]: /zh/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments-psbt
[core lightning 24.08.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.2
[news172 remote]: /en/newsletters/2021/10/27/#lnd-5689
[rfc8439]: https://datatracker.ietf.org/doc/html/rfc8439
[news264 chacha]: /zh/newsletters/2023/08/16/#bitcoin-core-28008
[bcc28 guide]: /zh/bitcoin-core-28-wallet-integration-guide/
[bip324 decoy packets]: https://github.com/bitcoin/bips/blob/22660ad3078ee9bd106e64d44662a59a1967c4bd/bip-0324.mediawiki?plain=1#L126
[ishaana fingerprinting]: https://ishaana.com/blog/wallet_fingerprinting/
[puzzle bitcointalk]: https://bitcointalk.org/index.php?topic=1306983.0
[puzzle stackernews]: https://stacker.news/items/683489
