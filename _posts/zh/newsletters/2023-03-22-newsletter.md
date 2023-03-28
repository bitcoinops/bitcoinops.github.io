---
title: 'Bitcoin Optech Newsletter #243'
permalink: /zh/newsletters/2023/03/22/
name: 2023-03-22-newsletter-zh
slug: 2023-03-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报包含了我们的常规部分：服务和客户端软件的变更介绍，以及热门比特币基础设施软件的重大变更总结。

## 新闻

*本周 Bitcoin-Dev 和 Lightning-Dev 邮件组中都无重大新闻。*

## 服务和客户端软件的变更

*在这个月度栏目中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--xapo-bank-supports-lightning-->Xapo Bank 开始支持闪电支付**：Xapo Bank [宣布][xapo lightning blog]其客户现在可以通过 Xapo Bank 手机 app 发送闪电支付了；这项服务的底层基础设施来自 Lightsaprk。
- **<!--typescript-library-for-miniscript-descriptors-released-->miniscript 描述符的 TypeScript 库发布**：这个基于 TypeScript 的[比特币描述符代码库][github descriptors library]已经支持 “部分签名的比特币交易（[PSBTs][topic psbt]）”、[描述符][topic descriptors] 和 [miniscript][topic miniscript]。这个库还支持直接签名，以及使用特定的硬件签名设备。
- **<!--breez-lightning-sdk-announced-->Breez 闪电网络软件开发工具发布**：在最近的一篇[博文][breez blog]中，Breez 宣布为希望集成比特币和闪电网络支付的移动应用开发者开源[Breez SDK][github breez sdk]。这个软件开发工具支持 [Greenlight][blockstream greenlight]、闪电网络服务供应商（LSP）以及其它服务。
- **<!--psbtbased-exchange-openordex-launches-->基于 PSBT 的交易所 OpenOrdex 启动**：这个[开源][github openordex]交易软件允许 Ordinal 聪的卖方使用[PSBTs][topic psbt]创建一个订单簿，与买方配合签名后即可广播道网络中、完成交换。
- **<!--btcpay-server-coinjoin-plugin-released-->BTCPay Server 的 coinjoin 插件发布**：Wasabi Wallet 的[公告][wasabi blog]指出，任何 BTCPay Server 的商家都可以激活一个支持 [WabiSabi][news102 wabisabi] 协议的插件以使用 [coinjoins][topic coinjoin]。
- **<!--mempoolspace-explorer-enhances-cpfp-support-->mempool.space 浏览器强化了 CPFP 支持**：[浏览器][topic block explorers] mempool.space 宣布为 “子为父偿（[CPFP][topic cpfp]）” 交易提供了[额外的支持][mempool tweet]。
- **<!--sparrow-v173-released-->Sparrow 钱包 v1.7.3 发布**：Sparrow 的 [1.7.3 版本][sparrow v1.7.3] 为多签名钱包添加了[BIP129][]支持（详见[周报 #136][news136 bsms]），并增设了定制化的区块浏览器以及其它特性。
- **<!--stack-wallet-adds-coin-control-bip47-->Stack Wallet 添加了款项控制功能以及 BIP47**：[Stack Wallet][github stack wallet] 的最新版本添加了 “款项控制（[coin control][topic coin selection]）” 特性以及 [BIP47][] 支持。
- **<!--wasabi-wallet-v203-released-->Wasabi Wallet 发布 2.0.3 版本**：Wasabi 的 [2.0.3 版本][Wasabi v2.0.3]包括了 taproot 输出的 coinjoin 签名，以及 taproot 的找零输出，支付时刻可选的手动款项控制，速度优化的钱包导入，等等。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.16.0-beta.rc3][] 是这个热门的闪电节点实现的新的大版本的候选版本。

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [LND #7448][] 添加了一个新的再广播接口，以重新提交未确认的交易，尤其是已经从交易池中逐出的交易。启用该功能以后，再广播器会每隔一个区块就提交一次目标未确认交易到连带的全节点，直至该笔交易得到确认。LND 在 Neutrino 模式下运行时，已经可用类似的方式再广播交易。如之前引用的 Stack Exchange 问答所说，[Bitcoin Core 现在不会再广播交易][no rebroadcast]，虽然从隐私性和可靠性上来说，如果全节点的行为改成重新广播该节点预期应当包含在以往区块中的任意交易，将是可取的。在实现这一点之前，保证目标交易能长久留在交易池中，是钱包的责任。
- [BDK #793][] 是这个库基于 [bdk_core 子项目][bdk_core sub-project]的工作的重大重构版本。根据 PR 描述，它 “尽可能保持了现有的钱包 API，只添加了非常少的东西”。该 RP 描述列出了 3 个看上其稍微修改了的 API 端点。

{% include references.md %}
{% include linkers/issues.md v=2 issues="7448,793" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[bdk_core sub-project]: https://bitcoindevkit.org/blog/bdk-core-pt1/
[no rebroadcast]: /en/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools
[xapo lightning blog]: https://www.xapobank.com/blog/another-first-xapo-bank-now-supports-lightning-network-payments
[github descriptors library]: https://github.com/bitcoinerlab/descriptors
[breez blog]: https://medium.com/breez-technology/lightning-for-everyone-in-any-app-lightning-as-a-service-via-the-breez-sdk-41d899057a1d
[github breez sdk]: https://github.com/breez/breez-sdk
[blockstream greenlight]: https://blockstream.com/lightning/greenlight/
[github openordex]: https://github.com/orenyomtov/openordex
[wasabi blog]: https://blog.wasabiwallet.io/wasabiwalletxbtcpayserver/
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[mempool tweet]: https://twitter.com/mempool/status/1630196989370712066
[news136 bsms]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[sparrow v1.7.3]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.3
[github stack wallet]: https://github.com/cypherstack/stack_wallet
[Wasabi v2.0.3]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.3
