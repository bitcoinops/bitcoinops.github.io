---
title: 'Bitcoin Optech Newsletter #175'
permalink: /zh/newsletters/2021/11/17/
name: 2021-11-17-newsletter-zh
slug: 2021-11-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报涵盖 Taproot 软分叉的激活信息，以及常规的服务和客户端软件变更、新版本发布与候选版本、热门比特币基础设施软件的重要更新。

## 新闻

- ​**<!--taproot-activated-->****Taproot 激活：** 如预期所料，[Taproot][topic taproot] 软分叉在区块高度 {{site.trb}} 完成激活。截至发稿时，多个大型矿池仍未开采包含 Taproot 支出的区块。这可能表明它们此前错误地信号了准备就绪状态（我们[曾警告过此风险][p4tr what happens]），或者它们可能在使用 Taproot 强制节点选择主链的同时，仍通过旧节点或定制软件选择交易打包。

  用户和企业最安全的做法是运行自己的 Taproot 强制节点（如 Bitcoin Core 22.0），并仅接受经其确认的交易。

## 服务和客户端软件的更改

*本月流行比特币基础设施项目的重大变更包括：*

- ​**<!--bitcoinj-adds-bech32m-p2tr-support-->****bitcoinj 添加 bech32m 和 P2TR 支持：**
  Andreas Schildbach 在 bitcoinj 仓库提交了 [bech32m][topic bech32] 支持[提交][bitcoinj bech32m]和 [P2TR 支持][bitcoinj p2tr]代码。

- ​**<!--libwally-core-adds-bech32m-support-->****libwally-core 添加 bech32m 支持：**
  该钱包基础库的 [0.8.4 版本][libwally 0.8.4]包含 [bech32m 支持][libwally 297]。

- ​**<!--spark-lightning-wallet-adds-bolt12-offers-->****Spark 闪电钱包新增 BOLT12 报价功能：**
  Spark [v0.3.0][spark v0.3.0] 新增报价创建、发送支付和拉取支付等 [offer][topic offers] 功能，计划在未来版本中实现周期性支付。

- ​**<!--bitgo-wallets-support-taproot-->****BitGo 钱包支持 Taproot：**
  BitGo [宣布][bitgo taproot blog]其 API 已支持发送和接收 [Taproot][topic taproot] 输出，UI 支持将在后续更新中推出。

- ​**<!--nthkey-adds-bech32m-send-capabilities-->****NthKey 新增 bech32m 发送功能：**
  iOS 签名服务 [NthKey][nthkey website] 在 [v1.0.4 版本][nthkey v1.0.4]中增加了 Taproot 发送支持。

- ​**<!--ledger-live-supports-taproot-->****Ledger Live 支持 Taproot：**
  Ledger 客户端软件 Ledger Live 在 [v2.35.0 版本][ledger v2.35.0]中将 Taproot 支持作为实验性功能推出。

- ​**<!--muun-wallet-supports-taproot-->****Muun 钱包支持 Taproot：**
  Muun 钱包在激活后启用了 Taproot 地址支持，用户可默认使用 Taproot 接收地址。

- ​**<!--kollider-launches-alpha-ln-based-trading-platform-->****Kollider 推出基于闪电网络的交易平台测试版：**
  Kollider 的最新[公告][kollider blog] 详述了其衍生品平台功能，包括闪电网络存取款、LNAUTH 和 LNURL 支持。

## 发布与候选发布

*新版本发布与候选版本：*

- [LND 0.14.0-beta.rc4][] 候选版本新增：增强[抗日蚀攻击][topic eclipse attacks]保护（参见[周报 #164][news164 ping]），远程数据库支持（[周报 #157][news157 db]），快速路径发现（[周报 #170][news170 path]），Lightning Pool 改进（[周报 #172][news172 pool]），可复用 [AMP][topic amp] 发票（[周报 #173][news173 amp]），其他多项功能优化与错误修复。

## 重要代码与文档变更

*本周重要代码变更涉及 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]。*

- [Bitcoin Core #22934][] 新增 ECDSA 和 [schnorr 签名][topic schnorr signatures] 生成后的验证步骤，防止软件泄露可能暴露私钥或随机数的错误签名。该变更遵循 [BIP340][] 更新建议（参见[周报 #87][news87 bips886] 和[周报 #83][news83 safety]）。

- [Bitcoin Core #23077][] 通过 [CJDNS][] 实现地址中继，使 CJDNS 成为与 IPv4、IPv6、Tor 和 I2P 并列的受支持网络。用户配置新选项 `-cjdnsreachable` 后，Bitcoin Core 将把 `fc00::/8` 地址识别为 CJDNS 地址而非私有 IPv6 地址。

- [Eclair #1957][] 根据 [BOLTs #759][] 新增基础[洋葱消息][topic onion messages]支持，目前仅支持中继功能，暂不支持消息发起与接收。

- [Rust Bitcoin #691][] 新增 API 用于根据公钥和可选 [tapscript][topic tapscript] merkle 根生成 [P2TR][topic taproot] 脚本的 [bech32m][topic bech32] 地址。

- [BDK #460][] 新增为交易添加 `OP_RETURN` 输出的功能。

- [BIPs #1225][] 更新 BIP341 测试向量至[周报 #173][news173 taproot tests] 描述的版本。

{% include references.md %}
{% include linkers/issues.md issues="22934,23077,1957,691,460,1225,759" %}
[lnd 0.14.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta.rc4
[news164 ping]: /zh/newsletters/2021/09/01/#lnd-5621
[news157 db]: /zh/newsletters/2021/07/14/#lnd-5447
[news170 path]: /zh/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /zh/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /zh/newsletters/2021/11/03/#lnd-5803
[news87 bips886]: /zh/newsletters/2020/03/04/#bips-886
[news83 safety]: /zh/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news173 taproot tests]: /zh/newsletters/2021/11/03/#taproot-test-vectors
[p4tr what happens]: /zh/preparing-for-taproot/#激活时会发生什么
[cjdns]: https://github.com/cjdelisle/cjdns
[bitcoinj bech32m]: https://github.com/bitcoinj/bitcoinj/pull/2099
[bitcoinj p2tr]: https://github.com/bitcoinj/bitcoinj/pull/2225
[libwally 0.8.4]: https://github.com/ElementsProject/libwally-core/releases/tag/release_0.8.4
[libwally 297]: https://github.com/ElementsProject/libwally-core/pull/297
[spark v0.3.0]: https://github.com/shesek/spark-wallet/releases/tag/v0.3.0
[bitgo taproot blog]: https://blog.bitgo.com/taproot-support-for-bitgo-wallets-9ed97f412460
[nthkey website]: https://nthkey.com/
[nthkey v1.0.4]: https://github.com/Sjors/nthkey-ios/releases/tag/v1.0.4
[ledger v2.35.0]: https://github.com/LedgerHQ/ledger-live-desktop/releases/tag/v2.35.0
[kollider blog]: https://kollider.medium.com/kollider-alpha-version-h1-3bec739df1d4
