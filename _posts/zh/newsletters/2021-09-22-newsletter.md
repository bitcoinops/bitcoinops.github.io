---
title: 'Bitcoin Optech Newsletter #167'
permalink: /zh/newsletters/2021/09/22/
name: 2021-09-22-newsletter-zh
slug: 2021-09-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了对 BIP 流程的拟议修改，总结了在 Bitcoin Core 中添加包中继支持的计划，并链接了关于将 LN 节点信息添加至 DNS 的讨论。此外还包括常规的客户端更新、如何为 Taproot 做准备、新版本发布以及流行比特币基础设施软件的显著变更等内容。

## 新闻

- ​**<!--bip-extensions-->****BIP 扩展提案：​**​ Karl-Johan Alm 在 Bitcoin-Dev 邮件列表[发布][alm bips]提案，建议对已达到一定稳定性的 BIP 仅允许进行小范围修改。任何对稳定 BIP 条款的变更需通过新的 BIP 来扩展原有文档。

  Anthony Towns [反对][towns bips]该提案，并提出对现有流程的若干调整建议，包括在 BIPs 仓库中设立 Drafts 目录，以及取消 BIPs 维护者自主分配提案编号的权限。

- ​**<!--package-mempool-acceptance-and-package-rbf-->****打包内存池接受与打包 RBF（Replace-By-Fee）：​**​ Gloria Zhao 在 Bitcoin-Dev 邮件列表[发布][zhao post]关于[包中继][topic package relay]的设计方案，该方案将增强 CPFP（Child-Pays-For-Parent）和 RBF 手续费追加的灵活性与可靠性。[初始实现][bitcoin core #22290]仅允许通过 Bitcoin Core 的 RPC 接口提交交易包，但最终目标是使其支持 P2P 网络。Zhao 简要总结了对比特币核心交易接受规则的拟议修改：

  > - 交易包可包含已存在于内存池的交易
  > - 交易包为两代结构（多父单子）
  > - 手续费相关检查使用交易包整体费率。这意味着钱包可创建利用 CPFP 的交易包
  > - 允许父交易根据类似 [BIP125][] 的规则进行 RBF。这实现了 CPFP 与 RBF 的结合，即子交易的手续费可用于替换内存池中的冲突交易

  该邮件呼吁开发者对提案进行反馈，特别是预期使用该功能或可能受变更影响的开发者。

- ​**<!--dns-records-for-ln-nodes-->****LN 节点的 DNS 记录：​**​ Andy Schroder 在 Lightning-Dev 邮件列表[提议][schroder post]标准化使用 DNS 记录解析域名至 LN 节点的 IP 地址和公钥。截至本文撰写时，该讨论仍在进行中。

## 服务和客户端软件的更改

*本月重点比特币钱包和服务的有趣更新。*

- ​**<!--lightning-address-identifiers-announced-->**​**闪电网络地址标识符发布：​**​ André Neves [宣布][tla tweet][Lightning Address][lightningaddress website]协议，该协议将 [LNURL-pay][lnurl pay] 流程封装为类似电子邮件的地址格式[示意图][lightningaddress diagram]。

- ​**<!--zebedee-releases-ln-wallet-browser-extension-->**​**ZEBEDEE 发布 LN 钱包浏览器扩展：​**​ ZEBEDEE [宣布][zbe blog]推出 Chrome 和 Firefox 扩展程序，集成其[游戏专用钱包][zebedee wallet]。

- ​**<!--specter-v1-6-0-supports-single-key-taproot-->**​**Specter v1.6.0 支持单密钥 Taproot：​**​ Specter 的 [v1.6.0][specter v1.6.0] 版本新增对 regtest 和 [signet][topic signet] 上 Taproot 地址的支持。

- ​**<!--impervious-releases-ln-p2p-data-api-->**​**Impervious 发布 LN P2P 数据 API：​**​ 基于 LND 构建的 [Impervious][impervious website] 框架允许开发者通过[API][impervious api]在闪电网络上构建 P2P 数据流应用。

- ​**<!--fully-noded-v0-2-26-released-->**​**Fully Noded v0.2.26 发布：​**​ macOS/iOS 钱包 [Fully Noded][fully noded website] 新增对 [Taproot][topic taproot]、[BIP86][] 和 signet 的支持。

## 准备 Taproot #14：在 signet 上测试

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 Taproot 做准备的每周[系列][series preparing for taproot]。*

{% include specials/taproot/zh/13-signet.md %}

## 发布与候选发布

*主流比特币基础设施项目的新版本：[版本发布][releases]。*

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] 是 Bitcoin Core 的维护版本候选发布，包含多个错误修复和小幅改进。

## 显著代码和文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]的显著变更。*

- [Eclair #1932][] 实现了 [BOLTs #824][] 中修订的[锚定输出][topic anchor outputs]协议，所有预签名的 HTLC 花费均使用零手续费，从而避免手续费被窃取。详见 [Newsletter #165][news165 bolts 842]。

- [LND #5405][] 扩展了 `updatechanpolicy` RPC 功能，使其能够报告因当前策略（或因其他问题如通道注资交易未确认）而无法使用的通道。

- [LND #5304][] 使 LND 能够创建和验证包含 LND 自身未知权限的 macaroon。该变更允许 [Lightning Terminal][] 等工具使用单一 macaroon 在多个与同一 LND 节点通信的守护进程中进行身份验证。

- [Rust Bitcoin #628][] 新增对 Taproot 支付 sighash 构造的支持，并优化了传统、隔离见证和 Taproot 输入的 sighash 缓存存储。

- [Rust Bitcoin #580][] 添加了对 [BIP37][] 规范中定义的[交易布隆过滤器][topic transaction bloom filtering] P2P 网络消息的支持。

- [Rust Bitcoin #626][] 新增获取区块剥离大小（移除所有隔离见证数据的区块）和交易虚拟字节大小的函数。

- [Rust-Lightning #1034][] 新增可检索完整通道余额列表的功能，包括正在关闭过程中的通道。这使得终端软件即使在部分资金仍需确认时也能显示一致的余额信息。

{% include references.md %}
{% include linkers/issues.md issues="1932,5405,5304,628,580,626,1034,824,22290" %}
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[alm bips]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019457.html
[towns bips]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019462.html
[zhao post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019464.html
[schroder post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003224.html
[news165 bolts 842]: /zh/newsletters/2021/09/08/#bolts-824
[lightning terminal]: /zh/newsletters/2020/08/19/#lightning-labs-releases-lightning-terminal
[tla tweet]: https://twitter.com/andreneves/status/1425651740502892550
[lnurl pay]: https://github.com/fiatjaf/lnurl-rfc/blob/master/lnurl-pay.md
[lightningaddress website]: https://lightningaddress.com/
[lightningaddress diagram]: https://github.com/andrerfneves/lightning-address/blob/master/README.md#tldr
[zbe blog]: https://blog.zebedee.io/browser-extension/
[zebedee wallet]: https://zebedee.io/wallet
[specter v1.6.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.6.0
[impervious website]: https://www.impervious.ai/
[impervious api]: https://docs.impervious.ai/
[fully noded website]: https://fullynoded.app/
[series preparing for taproot]: /zh/preparing-for-taproot/
