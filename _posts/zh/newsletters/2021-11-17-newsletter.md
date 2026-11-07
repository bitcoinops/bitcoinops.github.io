---
title: 'Bitcoin Optech Newsletter #175'
permalink: /zh/newsletters/2021/11/17/
name: 2021-11-17-newsletter-zh
slug: 2021-11-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 介绍了 taproot 激活的相关信息，以及常规栏目：服务和客户端软件的变更、新版本与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--taproot-activated-->****taproot 已激活：** 如预期一样，[taproot][topic taproot] 软分叉在区块高度 {{site.trb}} 激活。截至本文撰写时，有几家大型矿池没有在挖包含 taproot 花费的区块。这可能说明它们此前只是虚假地表示已准备好执行 taproot 的规则，我们[此前曾警告过这一风险][p4tr what happens]。另一种可能是，它们无风险地用一台强制执行 taproot 规则的节点来选择使用哪条区块链，同时又用较旧的节点或定制软件来决定把哪些交易放进自己的区块。

  对用户和企业来说，最安全的做法是运行自己的、强制执行 taproot 规则的节点（例如 Bitcoin Core 22.0），并且只接受由该节点确认的交易。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--bitcoinj-adds-bech32m-p2tr-support-->****bitcoinj 添加 bech32m 和 P2TR 支持：**
  Andreas Schildbach 向 bitcoinj 仓库添加了[一个提交][bitcoinj bech32m]以支持 [bech32m][topic bech32]，又添加了[一个提交][bitcoinj p2tr]以支持 P2TR。

- **<!--libwally-core-adds-bech32m-support-->****libwally-core 添加 bech32m 支持：**
  该钱包基础库的 [0.8.4 版本][libwally 0.8.4]包含 [bech32m 支持][libwally 297]。

- **<!--spark-lightning-wallet-adds-bolt12-offers-->****Spark 闪电钱包新增 BOLT12 offers 功能：**
  Spark [v0.3.0][spark v0.3.0] 新增 [offers][topic offers] 功能，包括创建 offer、发送 offer 支付和拉取支付。周期性的 offers 功能计划在未来的版本中推出。

- **<!--bitgo-wallets-support-taproot-->****BitGo 钱包支持 Taproot：**
  BitGo [宣布][bitgo taproot blog]其 API 已支持发送和接收 [Taproot][topic taproot] 输出，UI 支持将在后续更新中推出。

- **<!--nthkey-adds-bech32m-send-capabilities-->****NthKey 新增 bech32m 发送功能：**
  iOS 签名服务 [NthKey][nthkey website] 在 [v1.0.4 版本][nthkey v1.0.4]中增加了 Taproot 发送支持。

- **<!--ledger-live-supports-taproot-->****Ledger Live 支持 Taproot：**
  Ledger 客户端软件 Ledger Live 在 [v2.35.0 版本][ledger v2.35.0]中将 Taproot 支持作为实验性功能推出。

- **<!--muun-wallet-supports-taproot-->****Muun 钱包支持 Taproot：**
  Muun 钱包在激活后启用了 Taproot 地址支持，用户可默认使用 Taproot 接收地址。

- **<!--kollider-launches-alpha-ln-based-trading-platform-->****Kollider 推出基于 LN 的 alpha 版交易平台：**
  Kollider 的最新[公告][kollider blog]详细介绍了该衍生品平台的功能，包括 LN 充值与提现，以及对 LNAUTH 和 LNURL 的支持。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.14.0-beta.rc4][] 是候选版本，除许多其他功能与错误修复外，还包含额外的[日食攻击][topic eclipse attacks]防护（见 [Newsletter #164][news164 ping]）、远程数据库支持（[Newsletter #157][news157 db]）、更快的寻路（[Newsletter #170][news170 path]）、Lightning Pool 用户体验改进（[Newsletter #172][news172 pool]），以及可重复使用的 [AMP][topic amp] 发票（[Newsletter #173][news173 amp]）。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 的值得注意的变更。*

- [Bitcoin Core #22934][] 在 ECDSA 签名和 [schnorr 签名][topic schnorr signatures] 生成之后都增加了一步验证。这可以防止软件泄露生成有误的签名，因为这类签名可能泄露生成它时所用私钥或 nonce 的信息。这一做法遵循此前对 [BIP340][] 的一次更新中给出的建议（见 [Newsletter #87][news87 bips886]），相关内容之前在 [Newsletter #83][news83 safety] 中讨论过。

- [Bitcoin Core #23077][] 通过 [CJDNS][] 实现地址中继，使 CJDNS 成为与 IPv4、IPv6、Tor 和 I2P 一样得到完整支持的网络。在 Bitcoin Core 之外完成 CJDNS 的配置后，节点运营者可以开启新的配置选项 `-cjdnsreachable`，让 Bitcoin Core 把 `fc00::/8` 地址视为属于 CJDNS，而不是把它解释为私有 IPv6 地址。

- [Eclair #1957][] 根据 [BOLTs #759][] 新增基础[洋葱消息][topic onion messages]支持，目前仅支持中继功能，暂不支持消息发起与接收。

- [Rust Bitcoin #691][] 新增 API 用于根据公钥和可选 [tapscript][topic tapscript] merkle 根生成 [P2TR][topic taproot] 脚本的 [bech32m][topic bech32] 地址。

- [BDK #460][] 新增为交易添加 `OP_RETURN` 输出的功能。

- [BIPs #1225][] 用 [Newsletter #173][news173 taproot tests] 中描述的 taproot 测试向量更新 BIP341。

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
