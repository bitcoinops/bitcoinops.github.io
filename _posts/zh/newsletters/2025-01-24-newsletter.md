---
title: 'Bitcoin Optech Newsletter #338'
permalink: /zh/newsletters/2025/01/24/
name: 2025-01-24-newsletter-zh
slug: 2025-01-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分宣布了一个在描述符中索引不可花费密钥的 BIP 草案、测验了各实现在如何使用 PSBTv2，以及深入纠正了我们上周对新的链下 DLC 协议的介绍。此外是我们的常规栏目：介绍服务和客户端软件的变更、宣布软件的新版本和候选版本，总结热门的比特币基础设施软件的新变更。

## 新闻

- **<!--draft-bip-for-unspendable-keys-in-descriptors-->** **在描述符中索引不可花费密钥的 BIP 草案**：Andrew Toth 在 [Delving Bitcoin][toth unspendable delv] 论坛和 [Bitcoin-Dev 邮件组][toth unspendable ml] 中发布了一份关于在[描述符][topic descriptors]中索引可证明不可花费的密钥的 [BIP 草案][bips #1746]。这项工作跟随了以往的谈论（详见[周报 #283][news283 unspendable]）。使用一个可证明不可花费的公钥，也叫  “此中无后门（NUMS）” 点，跟 [taproot][topic taproot] 内部公钥的关系最密切。如果不可能使用内部公钥创建密钥路径花费，那么就只可能创建使用某个脚本树叶子的脚本路径花费（例如，使用一个 [tapscript][topic tapscript]）。

  截至本刊发布之时，该 BIP 草案的 [PR][bips #1746] 页面还在发生活跃的讨论。

- **<!--psbtv2-integration-testing-->** **PSBTv2 集成测试**：Sjors Provoost 在 Bitcoin-Dev 邮件组中[发帖][provoost psbtv2]询问那些软件已经实现对版本 2 的 “待签名比特币交易（[PSBTs][topic psbt]）” 数据格式（详见[周报 #141][news141 psbtv2]）的支持，以测试一项为 Bitcoin Core 添加支持的 [PR][bitcoin core #21283] 。一个更新后的支持软件清单可以在 Bitcoin Stack Exchange 网站中[找到][bse psbtv2]。我们发现了两个有意思的回复：

  - **<!--merklized-psbtv2-->** **默克尔化的 PSBTv2**：Salvatore Ingala [解释道][ingala psbtv2]，Ledger Bitcoin 应用会将一项 PSBTv2 数据的各字段转化成一棵默克尔树，并且最初仅发送树根到 Ledger 硬件签名器。在需要具体字段时，再发送数值以及相应的默克尔树证据。这让设备可以安全地跟每一段信息独立工作，而无需再有限的内存中存储完整的 PSBT 数据。在 PSBTv2 可以做到，是因为它已经将待签名交易的部分分割到了不同的字段中；而对初版的 PSBT 格式（v0），这就需要额外的解析。
  - **<!--silent-payments-psbtv2-->** **静默支付 PSBTv2**：[BIP352][] 指定 “[静默支付][topic silent payments]” 显式地依赖于 [解释道][toth psbtv2] PSBTv2 规范。Andrew Toth [解释道][toth psbtv2]，静默支付需要 v2 的 `PSBT_OUT_SCRIPT` 字段，因为静默支付所需使用的输出脚本，在所有输入的签名人处理完这个 PSBT 之前，是无法知晓的。

- **<!--correction-about-offchain-dlcs-->** **关于链下 DLC 的勘误**：在[上周新闻部分][news337 dlc]对链下 DLC 的介绍中，我们混淆了由开发者 conduition 提出的[新方案][conduition factories]，与此前已经发布并得到实现的链下 DLC（谨慎日志合约）方案。它们有以下重大且有趣的区别：

  * 周报 [#174][news174 channels] 和 [LN-Penalty][topic ln-penalty] 所提到的 *DLC 通道* 协议使用了一种类似于 [LN-Penalty][topic ln-penalty] 的 “先承诺后撤销（commit-and-revoke）” 机制：各参与者先通过签名来 *承诺* 一个新状态，然后通过释放一个秘密值、允许对手方从本地私有的旧状态（如果真的被发布上链）中完全花费来 *撤销* 旧状态。这让一个 DLC 可以通过双方的交互来刷新。比如说，Alice 和 Bob 可以这样做：

    1. 立即启动一个打赌一个月后 BTCUSD 价格的 DLC；

    2. 在三周后，同意启动一个打赌两个月后 BTCUSD 价格的 DLC，并撤销前一个合约。

  * 而新的 *DLC 工厂* 协议则会在合约到期时自动撤销双方在链上发布状态的能力，因为合约的任何断言机（oracle）见证，都可以作为秘密值，让一方的私有状态（如果被发布上链）被对方完全花费。实际上，这就自动取消了旧状态，让工厂从建立之始就可以签名连续的 DLC，无需任何额外的交互。比如说，Alice 和 Bob 可以这样做：

    1. 立即开启一个打赌一个月后 BTCUSD 价格的 DLC；

    2. 同时立即开启一个打赌两个月后 BTCUSD 价格的 DLC，使用一个交易[时间锁][topic timelocks]来防止它在一个月内发布。他们还可以重复这一技巧，从而建立三个月后、四个月后 …… 到期的合约。

  在 DLC 通道协议中，Alice 和 Bob 不能同时创建两个合约：必须在准备好撤销第一个合约之后，才能创建第二个合约，这就需要在某个时间发生交互。而在 DLC 工厂协议中，所有合约都可以在工厂建立时就创建，而且不需要额外的交互；不过，任何一方都依然可以将最新的 “安全可发布” 交易版本发布到链上，从而中断这一系列的合约。

  如果工厂的参与者们可以在合约建立之后交互，就可以延伸这份合约 —— 但他们无法决定使用另一份合约，或其他断言机，除非以前签名过的所有合约都已经到期（或他们使用一次链上操作）。虽然有可能消除这一缺点，这就是它（相比 DLC 通道协议）削减交互需求的代价（在 DLC 通道协议中，合作撤销可以随时任意改变合约）。

  感谢 conduition 提醒我们在上周新闻部分犯下的错误，并耐心地[回答][conduition reply]我们的问题。

## 服务和客户端软件的变更

*在这个月度栏目中，我们会突出比特币钱包和服务的有趣更新。*

- **<!--bull-bitcoin-mobile-wallet-adds-payjoin-->** **Bull Bitcoin 移动钱包添加 payjoin 特性**：Bull Bitcoin [宣布][bull bitcoin blog]在发送和收款时支持由[提议中][BIPs #1483]的 BIP77 Payjoin Version2：免服务器的 Payjoin 规范定义的 “[payjoin][topic payjoin]” 功能。

- **<!--bitcoin-keeper-adds-miniscript-support-->** **Bitcoin Keeper 添加 miniscript 支持**：Bitcoin Keeper [宣布][bitcoin keeper twitter] 在 [v1.3.0 版本][bitcoin keeper v1.3.0] 中支持 “[miniscript][topic miniscript]” 。

- **<!--nunchuk-adds-taproot-musig2-features-->** **Nunchuk 添加 taproot MuSig2 特性**：Nunchuk [宣布][nunchuk blog] 实验性支持 [MuSig2][topic musig]：可在 [taproot][topic taproot] 密钥路径中使用[多重签名][topic multisignature]花费，同时使用一棵 MuSig2 脚本路径脚本树，从而激活 k-of-n 的[门限签名][topic threshold signature]花费。

- **<!--jade-plus-signing-device-announced-->** **Jade Plus 签名设备发布**：[Jade Plus][blockstream blog] 签名设备加入了%#%#以及空气隔离（air-gapped）功能，还有别的特性。

- **<!--coinswap-v010-released-->** **Coinswap v0.1.0 发布**：[Coinswap v0.1.0][coinswap v0.1.0] 是一个测试版软件，建立在形式化的 [coinswap][topic coinswap] 协议%43%#之上，支持 [testnet4][topic testnet]，还包含了跟这个协议交互的命令行应用。

- **<!--bitcoin-safe-100-released-->** **Bitcoin Safe 1.0.0 发布**：[Bitcoin Safe][bitcoin safe website] 桌面钱包应用 [1.0.0 版本][bitcoin safe 1.0.0]，支持多种硬件签名设备。

- **<!--bitcoin-core-280-policy-demonstration-->** **Bitcoin Core 28.0 交易池规则演示**：Super Testnet [发布][zero fee sn] 了一个名为 “[零费率交易游乐园][zero fee website]” 的网站，解释来自 Bitcoin Core 28.0 的[交易池规则则行][28.0 guide]。

- **<!--rustpayjoin-0210-released-->** **Rust-payjoin 0.21.0 发布**：[rust-payjoin 0.21.0][rust-payjoin 0.21.0] 版本加入了 “交易提炼（[transaction cut-through][]）” 功能（详情听 [Podcast #282][pod282 payjoin]）。

- **<!--peerswap-v40rc1-->** **PeerSwap v4.0rc1**：闪电通道流动性软件 PeerSwap 发布了 [v4.0rc1][peerswap v4.0rc1]，包含了协议升级。[PeerSwap FAQ][peerswap faq] 页面概述了 PeerSwap 如何不同于 “[潜水艇互换][topic submarine swaps]”、“[通道拼接][topic splicing]” 和 “[流动性广告][topic liquidity advertisements]”。

- **<!--joinpool-prototype-using-ctv-->** **使用 CTV 的 Joinpool 原型**：这个 “[ctv payment pool][ctv payment pool github]” 概念验证项目使用了提议中的 [OP_CHECKTEMPLATEVERIFY (CTV)][topic op_checktemplateverify] 操作嘛来创建一种 [joinpool][topic joinpools] 。

- **<!--rust-joinstr-library-announced-->Rust joinstr 库发布**：这个实验性的 [rust 库][rust joinstr github] 实现了 joinstr [coinjoin][topic coinjoin] 协议。

- **<!--strata-bridge-announced-->** **Strata bridge 发布**：[Strata bridge][strata blog] 是一个基于 [BitVM2][topic acc] 的桥，可以在比特币主链和[侧链][topic sidechains]（在这个案例中是一个 validity roolup，详见 [周报 #222][news222 validity rollups]）间来回移动比特币。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试旧版本。*

- [BTCPay Server 2.0.6][] 包含了一项 “安全修复，针对使用自动化支付处理器在链上处理 退款/拉取支付 的商家”。此外还有多项新特性和 bug 修复。

## 重大的代码和文档变更

*重大更新出现在：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]*。

- [Bitcoin Core #31397][] 通过跟踪和使用所有可以提供缺失父交易的潜在对等节点，优化[孤儿交易确定程序][news333 prclub]。以往，这个确定程序仅依赖于最初提供孤儿交易的对等节点；如果该对等节点不响应或返回一个 `notfound` 消息，程序是没有重试机制的，导致可能的交易下载失败。新方法尝试从所有候选的对等节点处下载父交易，同时保持带宽效率、抗审查性以及实质的负载均衡。这对 “一父一子（1p1c）”[交易宝转发][topic package relay]尤其有好处，并且为 [BIP331][] 的 “接受方发起的祖先交易宝转发” 奠定了基础。

- [Eclair #2896][] 启用了 [MuSig2][topic musig] 的对等节点碎片签名存储，而不是传统的 2-of-2 多签名的存储，作为未来实现 “[简单 taproot 通道][topic simple taproot channels]” 的前置。存储该碎片签名允许一个节点在需要时单方面广播一笔承诺交易。

- [LDK #3408][] 引入了在 `ChannelManager` 中创建静态发票及其对应的 [offers][topic offers] 的用法，以支持在 [BOLT12][] 中实现[异步支付][topic async payments]，如 [BOLTs #1149][] 的规定。常规的 offer 创建用法要求接收者在线以服务发票请求，这种新方法则适合经常离线的接收者。这项 PR 也为给静态发票支付（详见周报 [#321][news321 async]）添加了缺失的测试，并保证当接收者回到线上时，发票请求是可以检索的。

- [LND #9405][] 让 `ProofMatureDelta` 参数变成可配置的，该参数决定 gossip 网络中的一条 [通道宣告][topic channel announcements] 在得到处理之前需要积累多少确认数量。默认数值是 6 。


{% include references.md %}
{% include linkers/issues.md v=2 issues="1746,21283,31397,2896,3408,9405,1149,1483" %}
[news337 dlc]: /zh/newsletters/2025/01/17/#offchain-dlcs
[conduition factories]: https://conduition.io/scriptless/dlc-factory/
[conduition reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news174 channels]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 channels]: /zh/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs-10101-beta-ln-dlc
[condution reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news283 unspendable]: /zh/newsletters/2024/01/03/#how-to-specify-unspendable-keys-in-descriptors
[toth unspendable delv]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/31
[toth unspendable ml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a594150d-fd61-42f5-91cd-51ea32ba2b2cn@googlegroups.com/
[news141 psbtv2]: /zh/newsletters/2021/03/24/#bips-1059
[provoost psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6FDAD97F-7C5F-474B-9EE6-82092C9073C5@sprovoost.nl/
[bse psbtv2]: https://bitcoin.stackexchange.com/a/125393/21052
[ingala psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMhCMoGONKFok_SuZkic+T=yoWZs5eeVxtwJL6Ei=yysvA8rrg@mail.gmail.com/
[toth psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/30737859-573e-40ea-9619-1d18c2a6b0f4n@googlegroups.com/
[btcpay server 2.0.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.6
[news321 async]: /zh/newsletters/2024/09/20/#ldk-3140
[news333 prclub]: /zh/newsletters/2024/12/13/#bitcoin-core-pr-审核俱乐部
[bull bitcoin blog]: https://www.bullbitcoin.com/blog/bull-bitcoin-wallet-payjoin
[bitcoin keeper twitter]: https://x.com/bitcoinKeeper_/status/1866147392892080186
[bitcoin keeper v1.3.0]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.3.0
[nunchuk blog]: https://nunchuk.io/blog/taproot-multisig
[blockstream blog]: https://blog.blockstream.com/introducing-the-all-new-blockstream-jade-plus-simple-enough-for-beginners-advanced-enough-for-cypherpunks/
[coinswap v0.1.0]: https://github.com/citadel-tech/coinswap/releases/tag/v0.1.0
[coinswap spec]: https://github.com/citadel-tech/Coinswap-Protocol-Specification
[bitcoin safe website]: https://bitcoin-safe.org/en/
[bitcoin safe 1.0.0]: https://github.com/andreasgriffin/bitcoin-safe
[zero fee sn]: https://stacker.news/items/805544
[zero fee website]: https://supertestnet.github.io/zero_fee_playground/
[28.0 guide]: /zh/bitcoin-core-28-wallet-integration-guide/
[rust-payjoin 0.21.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-0.21.0
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[pod282 payjoin]: /en/podcast/2023/12/21/#payjoin-transcript
[peerswap v4.0rc1]: https://github.com/ElementsProject/peerswap/releases/tag/v4.0rc1
[peerswap faq]: https://github.com/ElementsProject/peerswap?tab=readme-ov-file#faq
[ctv payment pool github]: https://github.com/stutxo/op_ctv_payment_pool
[rust joinstr github]: https://github.com/pythcoiner/joinstr
[strata blog]: https://www.alpenlabs.io/blog/introducing-the-strata-bridge
[news222 validity rollups]: /zh/newsletters/2022/10/19/#rollup
