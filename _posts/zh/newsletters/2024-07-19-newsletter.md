---
title: 'Bitcoin Optech Newsletter #312'
permalink: /zh/newsletters/2024/07/19/
name: 2024-07-19-newsletter-zh
slug: 2024-07-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的简报描述了 FROST 无脚本门限签名方案的分布式密钥生成协议，并链接到一个关于族群线性化的全面介绍。此外，还包括我们常规部分，描述了最近对客户端、服务和流行比特币基础设施项目的变更。

## 新闻

- **<!--distributed-key-generation-protocol-for-frost-->****FROST 的分布式密钥生成协议：** Tim Ruffing 和 Jonas Nick 在 Bitcoin-Dev 邮件列表上[发布][ruffing nick post]了一份 [BIP 草案][chilldkg bip]以及 ChillDKG 的[参考实现][chilldkg ref]，这是一个用于安全生成密钥的协议，这些密钥将用于与 [FROST][] 风格的[无脚本门限签名][topic threshold signature]，兼容比特币的 [schnorr 签名][topic schnorr signatures]。

  无脚本门限签名可以创建 `n` 个密钥，其中任何 `t` 个密钥可以合作生成一个有效的签名。例如，一个 2-of-3 方案创建三个密钥，任何两个都可以生成一个有效签名。作为无脚本方案，该方案完全依赖于共识和区块链之外的操作，与比特币内置的脚本门限签名操作（例如使用 `OP_CHECKMULTISIG`）不同。

  与生成常规比特币私钥类似，每个为无脚本门限签名生成密钥的人必须生成一个大的类似随机的数字，而不向其他任何人透露该数字。然而，每个人还必须在其他用户之间分配该数字的派生分片，以便如果某个密钥不可用时，达到阈值数量的成员可以生成签名。执行这些步骤的几个密钥生成协议已经存在，但它们假定密钥生成用户可以访问一个加密和认证的通信通道，该通道在各个用户对之间进行加密和认证，还允许每个用户向所有其他用户进行不可审查的认证广播。ChillDKG 协议结合了 FROST 的一个知名密钥生成算法，以及现代密码学原语和简单算法，提供必要的安全、认证和可证明的不可审查通信。

  参与者之间的加密和认证开始于 [椭圆曲线 diffie-hellman][ecdh]（ECDH）交换。每个参与者使用其基本密钥签署会话从开始到生成无脚本门限公钥（即会话结束）的记录来创建不可审查的证明。在接受门限公钥为正确之前，每个参与者都必须验证每个其他参与者的签名会话记录。

  协议目标是提供一个完全通用的协议，可用于所有希望生成用于基于 FROST 的无脚本门限签名的密钥的情况。此外，该协议有助于简化备份：用户只需其私有种子和一些不涉及安全性（但影响隐私）的恢复数据。在 [后续消息][nick follow-up]中，Jonas Nick 提到他们正在考虑扩展协议，通过从种子派生的密钥加密恢复数据，以便用户只需保密其种子。

- **<!--introduction-to-cluster-linearization-->族群线性化介绍：** Pieter Wuille 在 Delving Bitcoin 上[发布][wuille cluster]了一个关于族群线性化所有主要部分的详细描述，这是[族群交易池][topic cluster mempool]的基础。以前的 Optech 周报曾尝试介绍该主题的关键概念，但这个概述更加全面。它按顺序将读者从基本概念带到正在实施的具体算法。最后，链接到几个实现族群交易池部分的 Bitcoin Core 拉取请求。

## 服务和客户端软件的变更

_在这个每月专题中，我们重点介绍比特币钱包和服务的有趣更新。_

- **<!--zeus-adds-bolt12-offers-and-bip353-support-->****ZEUS 添加 BOLT12 offer 和 BIP353 支持：** [v0.8.5][zeus v0.8.5] 版本利用 [TwelveCash][twelve cash website] 服务支持 [offer][topic offers] 和 [BIP353][]（参见[周报 #307][news307 bip353]）。

- **<!--phoenix-adds-bolt12-offers-and-bip353-support-->****Phoenix 添加 BOLT12 offer 和 BIP353 支持：** [Phoenix 2.3.1][phoenix 2.3.1] 版本增加了 offer 支持，[Phoenix 2.3.3][phoenix 2.3.3] 版本增加了 [BIP353][] 支持。

- **<!--stack-wallet-adds-rbf-and-cpfp-support-->****Stack Wallet 添加 RBF 和 CPFP 支持：** Stack Wallet 的 [v2.1.1][stack wallet v2.1.1] 版本增加了通过 [RBF][topic rbf] 和 [CPFP][topic cpfp] 进行费用提升的支持，以及 [Tor][topic anonymity networks] 支持。

- **<!--bluewallet-adds-silent-payment-send-support-->****BlueWallet 添加静默支付发送支持：** 在 [v6.6.7][bluewallet v6.6.7] 版本中，BlueWallet 增加了发送到[静默支付][topic silent payments]地址的能力。

- **<!--bolt12-playground-announced-->****BOLT12 Playground 公布：** Strike [公布][strike bolt12 playground]了一个测试环境，用于 BOLT12 offer。该项目使用 Docker 发起和自动化不同 LN 实现之间的钱包、通道和支付。

- **<!--moosig-testing-repository-announced-->****Moosig 测试库公布：** Ledger 发布了一个基于 Python 的测试[库][moosig github]，用于 [MuSig2][topic musig] 和 [BIP388][] 钱包[描述符钱包策略][news302 bip388]。

- **<!--real-time-stratum-visualization-tool-released-->****实时 Stratum 可视化工具发布：** 基于 [以前的研究][b10c nostr]的 [stratum.work 网站][stratum.work]显示来自各种比特币矿池的实时 Stratum 消息，同时也有可用的[源代码][stratum work github]。

- **<!--bmm-100-mini-miner-announced-->****BMM 100 迷你矿机公布：** Braiins 的[挖矿硬件][braiins mini miner]，默认启用 [Stratum V2][topic pooled mining]的一部分功能。

- **<!--coldcard-publishes-url-based-transaction-broadcast-specification-->****Coldcard 发布基于 URL 的交易广播规范：** 该[协议][pushtx spec]允许使用 HTTP GET 请求广播比特币交易，并可用于 NFC 基础的硬件签名设备等用例。

## 重要代码和文档更改

*近期出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]*

- [Bitcoin Core #26596][] 使用新的只读历史数据库来迁移遗留钱包到[描述符][topic descriptors]钱包。此更改不会弃用遗留钱包或遗留 `BerkeleyDatabase`。创建了一个新的 `LegacyDataSPKM` 类，只包含迁移遗留钱包所需的基本数据和功能。参见周报 [#305][news305 bdb] 了解 `BerkeleyRODatabase` 的介绍。

- [Core Lightning #7455][] 通过实现通过 `short_channel_id` (SCID) 和 `node_id` 转发的方式增强了 `connectd` 的 [洋葱消息][topic onion messages]处理（参考[周报 #307][news307 ldk3080]以了解关于 LDK 相似变更的讨论）。洋葱消息功能现在总是启用，传入消息的速率限制为每秒 4 条。

- [Eclair #2878][] 使[盲化路由][topic rv routing]和通道静止功能变成可选，因为它们现在已经完全实现并成为 BOLT 规范的一部分（参考周报 [#245][news245 blind] 和 [#309][news309 stfu]）。Eclair 节点向其对等节点广告支持这些功能，但默认情况下禁用 `route_blinding`，因为它不会转发不使用[蹦床路由][topic trampoline payments]的[盲化支付][topic rv routing]。

- [Rust Bitcoin #2646][] 引入新的脚本和见证结构的检查器，例如 `redeem_script` 以确保符合 [BIP16][] 关于 P2SH 花费的规则，`taproot_control_block` 和 `taproot_annex` 以确保符合 [BIP341][] 规则，`witness_script` 以确保 P2WSH 见证脚本符合 [BIP141][] 规则。更多内容可参考周报 [#309][news309 p2sh]。

- [BDK #1489][] 更新 `bdk_electrum` 以使用默克尔证明进行简化支付验证 (SPV)。它获取默克尔证明和区块头以及交易，验证交易在确认区块中，然后再插入锚点，并从 `full_scan` 中移除重组处理。该 PR 还引入 `ConfirmationBlockTime` 作为新的锚点类型，替代之前的类型。

- [BIPs #1599][] 添加 [BIP46][] 作为 HD 钱包的派生方案，用于创建用于[忠诚保证保险][news161 fidelity]的[时间锁定][topic timelocks]地址，这些地址用于 JoinMarket 风格的 [coinjoin][topic coinjoin]市场撮合。忠诚保证保险通过创建一个声誉系统来提高协议的抗女巫能力，挂单者通过时间锁定比特币来证明他们有意地牺牲了金钱的时间价值。

- [BOLTs #1173][] 使故障[洋葱消息][topic onion messages]中的 `channel_update` 字段成为可选。节点现在忽略当前支付之外的此字段，以防止 [HTLC][topic htlc] 发送者的指纹识别。此更改旨在防止因过时的通道参数导致的支付延迟，同时仍允许具有过时八卦数据的节点在需要时受益于更新。

- [BLIPs #25][] 添加 [BLIP25][]，描述如何允许转发少于洋葱编码数值的 HTLC。例如，Alice 向 Bob 提供一个闪电发票，但她没有支付通道，所以当 Bob 付款时，Carol（Alice 的 LSP）即时创建一个通道。为了允许 Carol 向 Alice 收取费用以支付创建 [JIT 通道][topic jit channels]的初始链上费用，可以使用此协议并向 Alice 转发一个少于洋葱编码数值的 HTLC。关于此前 LDK 中的一个实现的讨论，请查阅[周报 #257][news257 jit htlc]。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26596,7455,2878,2646,1489,1599,1173,25" %}
[ruffing nick post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8768422323203aa3a8b280940abd776526fab12e.camel@timruffing.de/T/#u
[chilldkg bip]: https://github.com/BlockstreamResearch/bip-frost-dkg
[chilldkg ref]: https://github.com/BlockstreamResearch/bip-frost-dkg/tree/master/python/chilldkg_ref
[nick follow-up]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7084f935-0201-4909-99ff-c76f83572a7c@gmail.com/
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[frost]: https://eprint.iacr.org/2020/852.pdf
[ecdh]: https://zh.wikipedia.org/wiki/%E6%A9%A2%E5%9C%93%E6%9B%B2%E7%B7%9A%E8%BF%AA%E8%8F%B2-%E8%B5%AB%E7%88%BE%E6%9B%BC%E9%87%91%E9%91%B0%E4%BA%A4%E6%8F%9B
[zeus v0.8.5]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.5
[twelve cash website]: https://twelve.cash/
[news307 bip353]: /zh/newsletters/2024/06/14/#bips-1551
[phoenix 2.3.1]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.1
[phoenix 2.3.3]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.3
[stack wallet v2.1.1]: https://github.com/cypherstack/stack_wallet/releases/tag/build_235
[bluewallet v6.6.7]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.6.7
[strike bolt12 playground]: https://strike.me/blog/bolt12-playground/
[moosig github]: https://github.com/LedgerHQ/moosig
[news302 bip388]: /zh/newsletters/2024/05/15/#bips-1389
[stratum.work]: https://stratum.work/
[stratum work github]: https://github.com/bboerst/stratum-work
[b10c nostr]: https://primal.net/e/note1qckcs4y67eyaawad96j7mxevucgygsfwxg42cvlrs22mxptrg05qtv0jz3
[braiins mini miner]: https://braiins.com/hardware/bmm-100-mini-miner
[pushtx spec]: https://pushtx.org/#url-protocol-spec
[news305 bdb]: /zh/newsletters/2024/05/31/#bitcoin-core-26606
[news309 p2sh]: /zh/newsletters/2024/06/28/#rust-bitcoin-2794
[news161 fidelity]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[news257 jit htlc]: /zh/newsletters/2023/06/28/#ldk-2319
[news307 ldk3080]: /zh/newsletters/2024/06/14/#ldk-3080
[news245 blind]: /zh/newsletters/2023/04/05/#bolts-765
[news309 stfu]: /zh/newsletters/2024/06/28/#bolts-869
