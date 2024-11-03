---
title: 'Bitcoin Optech Newsletter #278'
permalink: /zh/newsletters/2023/11/22/
name: 2023-11-22-newsletter-zh
slug: 2023-11-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一项允许用类闪电网络地址的特定 DNS 地址检索闪电网络要约的提议。此外还包括我们的常规部分，总结服务和客户端软件的变化、新版本和候选版本公告以及介绍流行的比特币基础软件的显著变化。

## 新闻

- **<!--offers-compatible-ln-addresses-->兼容要约的闪电网络地址：** Bastien Teinturier 在 Lightning-Dev 邮件列表中[发布][teinturier addy]了关于为闪电网络用户创建电子邮件风格的地址，以利用[要约协议][topic offers]的功能。作为背景，目前流行的[闪电地址][lightning address]标准是以 [LNURL][] 为基础，要求运行始终可用的 HTTP 服务器，以便将电子邮件式地址与闪电网络发票关联起来。Teinturier 指出这产生了几个问题：

  * _缺少隐私：_ 服务器操作员很可能会了解到付款人和收款人的 IP 地址。

  * _偷窃风险：_ 服务器操作员可以对发票进行中间人攻击来窃取资金。

  * _基础设施和依赖性：_ 服务器运营商必须设置 DNS 和 HTTPS 的主机托管，付款软件必须能够使用 DNS 和 HTTPS。

  Teinturier 基于要约提出了三种设计方案：

  * _将域名链接到节点：_ DNS 记录将域名（如 example.com）映射到 LN 节点标识符。花费者发送[洋葱信息][topic onion messages]到该节点，请求来自最终接收方（如 alice@example.com）的要约。该域节点回复一个由其节点密钥签名的要约，这样如果花费者收到的要约不是来自 Alice，花费者以后就可以证明存在欺诈情况了。现在，花费者可以使用要约协议向 Alice 索取发票。花费者还可以将 alice@example.com 与要约关联起来，这样它就不需要为此后向 Alice 付款而联系域节点了。Teinturier 指出，这种设计非常简单。

  * _节点公告中的证书：_ 对闪电网络节点用于向网络公告自身的现有机制进行修改，允许公告包含 SSL 证书链，以证明（根据证书颁发机构）example.com 的所有者声称此特定节点由 alice@example.com 控制。Teinturier 指出，这将要求闪电网络实现 SSL 兼容的密码学技术。

  * _直接在 DNS 中存储要约：_ 一个域名可能有多个 DNS 记录，直接存储特定地址的要约。例如，一条名为 `alice._lnaddress.domain.com` 的 DNS `TXT` 记录包含了 Alice 的要约。另一条 `bob._lnaddress.domain.com` 的记录包含了 Bob 的要约。Teinturier 指出，这就要求域名所有者为每个用户创建一个 DNS 记录（如果用户需要更改默认要约，还需要更新该记录）。

  这封邮件引发了热烈的讨论。其中一个值得注意的建议是可能可以同时使用第一和第三个建议（将域名链接到节点和直接在 DNS 中存储要约）。

## 服务和客户端软件的改变

*在这个月度栏目中，我们将列举比特币钱包和服务的有趣升级*。

- **BitMask 钱包 0.6.3 发布：**
  [BitMask][bitmask website] 是一款基于网页和浏览器扩展的钱包，适用于比特币、闪电币、RGB 和 [payjoin][topic payjoin]。

- **Opcode 文档网站发布：**
  [https://opcodeexplained.com/] 网站近日[公布][OE tweet]，提供了许多比特币操作码的解释。这项工作正在进行中，[欢迎贡献][OE github]。

- **Athena Bitcoin 增加闪电支持：**
  这个比特币 ATM [运营商][athena website]最近[宣布][athena tweet]支持通过闪电支付来取现。

- **Blixt v0.6.9 发布：**
  [v0.6.9][blixt v0.6.9] 版本包括对简单 taproot 通道的支持，默认为 [bech32m][topic bech32] 接收地址，并增加了额外的[零确认通道][topic zero-conf channels]的支持。

- **Durabit 白皮书公布：**
  [Durabit 白皮书][Durabit whitepaper]概述了一种综合使用[时间锁][topic timelocks]的比特币交易和 Chaumian 式铸币厂来激励大文件做种的协议。

- **BitStream 白皮书发布：**
  [BitStream 白皮书][BitStream whitepaper]和[早期原型][bitstream github]设计了一个使用时间锁和梅克尔树以及验证和欺诈证明的数字内容托管和原子交换协议。有关付费数据传输协议的先前讨论，请参阅[周报 #53][news53 data]。

- **BitVM 概念验证：**
  两个基于 [BitVM][news273 bitvm] 的概念证明已发布，其中一个[实现][bitvm tweet blake3]了 [BLAKE3][] 哈希函数，[另一个][bitvm techmix poc] [实现了][bitvm sha256] SHA256。

- **Bitkit 增加了 taproot 发送支持：**
  比特币和闪电移动端钱包 [Bitkit][bitkit website] 在 [v1.0.0-beta.86][bitkit v1.0.0-beta.86] 版本中添加了对 [taproot][topic taproot] 付款的支持。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.17.2-beta][] 是一个维护版本，只包含一个小改动，以修复 [LND #8186][] 中报告的错误。

- [Bitcoin Core 26.0rc2][] 是主流全节点实现的下一个主要版本的候选发布版。[测试指南][26.0 testing]已可用。

- [Core Lightning 23.11rc3][] 是该闪电网络实现的下一个主要版本的候选发布版。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Core Lightning #6857][] 更新了用于 REST 接口的几个配置项的名称，以防止它们与 [c-lightning-rest][] 插件冲突。

- [Eclair #2752][] 允许[要约][topic offers]中的数据使用节点的公钥或其中一个通道的身份来引用节点。公钥是识别节点的典型方法，但它需要使用 33 个字节。使用 [BOLT7][] _短信道标识符_（SCID）可以识别信道，它只使用 8 个字节。由于通道是由两个节点共享的，因此在 SCID 前还要预留一个比特，专门用来辨识两个节点中的一个。由于要约可能经常用于大小受限的媒介，因此这些节省下来的空间会非常可观。

{% include snippets/recap-ad.md when="2023-11-22 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="6857,2752,8186" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc3
[c-lightning-rest]: https://github.com/Ride-The-Lightning/c-lightning-REST
[teinturier addy]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004204.html
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[lightning address]: https://lightningaddress.com/
[lnd v0.17.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.2-beta
[bitmask website]: https://bitmask.app/
[https://opcodeexplained.com/]: https://opcodeexplained.com/opcodes/
[OE tweet]: https://twitter.com/thunderB__/status/1722301073585475712
[OE github]: https://github.com/thunderbiscuit/opcode-explained
[athena website]: https://athenabitcoin.com/
[athena tweet]: https://twitter.com/btc_penguin/status/1722008223777964375
[blixt v0.6.9]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.9
[Durabit whitepaper]: https://github.com/4de67a207019fd4d855ef0a188b4519c/Durabit/blob/main/Durabit%20-%20A%20Bitcoin-native%20Incentive%20Mechanism%20for%20Data%20Distribution.pdf
[BitStream whitepaper]: https://robinlinus.com/bitstream.pdf
[bitstream github]: https://github.com/robinlinus/bitstream
[news273 bitvm]: /zh/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[bitvm tweet blake3]: https://twitter.com/robin_linus/status/1721969594686926935
[BLAKE3]: https://en.wikipedia.org/wiki/BLAKE_(hash_function)#BLAKE3
[bitvm techmix poc]: https://techmix.github.io/tapleaf-circuits/
[bitvm sha256]: https://raw.githubusercontent.com/TechMiX/tapleaf-circuits/abc38e880872150ceec08a8b67ac2fddaddd06dc/scripts/circuits/bristol_sha256.js
[bitkit website]: https://bitkit.to/
[bitkit v1.0.0-beta.86]: https://github.com/synonymdev/bitkit/releases/tag/v1.0.0-beta.86
[news53 data]: /en/newsletters/2019/07/03/#standardized-atomic-data-delivery-following-ln-payments
