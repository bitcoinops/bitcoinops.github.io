---
title: 'Bitcoin Optech Newsletter #132'
permalink: /zh/newsletters/2021/01/20/
name: 2021-01-20-newsletter-zh
slug: 2021-01-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了 Bitcoin-Dev 邮件列表中关于 Payjoin 采用和使硬件钱包兼容更多高级比特币功能的讨论帖子。同时，还包括我们常规的栏目：服务和客户端软件的更改概述、新发布与候选发布以及流行比特币基础设施软件的更改。

## 新闻

- **<!--payjoin-adoption-->****Payjoin 的采用：** Chris Belcher 在 Bitcoin-Dev 邮件列表中[发布了][belcher payjoin]一份请求，邀请人们寻找方法来增加 [Payjoin][topic payjoin] 的采用，并提供了一个[维基页面][payjoin wiki]，跟踪支持 Payjoin 发送或接收功能的项目。其中一个由 Craig Raw 提出的[建议][raw payjoin]是扩展协议，使其即使在接收方未运行服务器时也能工作。

- **<!--making-hardware-wallets-compatible-with-more-advanced-bitcoin-features-->****使硬件钱包兼容更多高级比特币功能：** Kevin Loaec 在 Bitcoin-Dev 邮件列表中[发起了一场讨论][loaec hww]，探讨如何改变硬件钱包以使其能够处理比单签或多签更复杂的脚本。例如，允许硬件钱包处理链上 LN 支付或来自[保险库][topic vaults]的支付。他的帖子很好地描述了当前硬件钱包无法处理的各种问题，但他指出所需的“变更可能非常困难”。

## 服务和客户端软件的更改

*在本月的栏目中，我们突出比特币钱包和服务的有趣更新。*

- **<!--blockstream-announces-jade-hardware-wallet-->****Blockstream 宣布 Jade 硬件钱包：**
  Blockstream 的[新 Jade 硬件钱包][blockstream jade blog]是开源的，支持比特币和 Liquid 网络，并与 Android 版 Blockstream Green 兼容。

- **<!--coldcard-adds-payjoin-signing-->****Coldcard 增加 Payjoin 签名：**
  Coldcard 的 [3.2.1 版本][coldcard 3.2.1] 添加了 [BIP78][] 的 Payjoin 签名支持，并改进了多签功能。

- **<!--mempool-v2-0-0-released-->****Mempool v2.0.0 发布：**
  开源[区块浏览器][topic block explorers] Mempool（支持 [mempool.space][mempool.space website] 网站）发布了 [2.0.0 版本][mempool v2]。Mempool 支持 Bitcoin Core、Electrum 和 Esplora 后端，并通过 API 提供区块、交易和地址信息。

- **<!--bluewallet-adds-multisig-->****BlueWallet 增加多签功能：**
  [BlueWallet 6.0.0 版本][bluewallet 6.0.0. tweet]添加了创建和管理隔空通信的原生隔离见证多签金库的功能。

- **<!--sparrow-supports-connecting-to-bitcoin-core-->****Sparrow 支持连接到 Bitcoin Core：**
  [Sparrow 0.9.10][sparrow 0.9.10] 通过 [Bitcoin Wallet Tracker v0.2.1][bwt 0.2.1] 的 Java Native Interface 绑定功能，现在支持直接连接到比特币 Core 节点。

## 发布与候选发布

*流行比特币基础设施项目的新发布与候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [Bitcoin Core 0.21.0][Bitcoin Core 0.21.0] 是这个全节点实现及其相关钱包和其他软件的下一个主要版本。主要新功能包括支持使用[版本 2 地址公告消息][topic addr v2]的新 Tor Onion 服务、可选的[致密区块过滤器][topic compact block filters]服务能力，以及支持 [signet][topic signet]（包括已激活 [Taproot][topic taproot] 的默认 signet）。此外，它还为原生使用[输出脚本描述符][topic descriptors]的钱包提供了实验性支持。有关完整更改列表，请参阅[发布说明][bcc 0.21.0 notes]。

- [Rust Bitcoin 0.26.0][] 是此库的新版本。主要新功能包括对 signet、版本 2 地址公告消息的支持，以及对 [PSBT][topic psbt] 处理的改进。详情请参阅[发布说明][rb notes]。

- [BTCPay Server 1.0.6.7][] 是上周发布的 [1.0.6.5][btcpay server 1.0.6.5] 的第二个维护版本，其中增加了“在钱包设置中支持部分输出描述符”（见下方 *值得注意的更改* 部分）。同时包含其他功能和错误修复。

- [C-Lightning 0.9.3rc2][c-lightning 0.9.3] 是此 LN 节点新次要版本的候选发布。

- [LND 0.12.0-beta.rc5][LND 0.12.0-beta] 是此 LN 节点的下一个主要版本的最新候选发布。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo] 的值得注意的更改。*

- [Bitcoin Core #19937][] 添加了一个新的独立可执行文件 `bitcoin-util` 和 `miner` 脚本，用于挖掘 [signet][topic signet] 区块，从而简化了新 signet 网络的创建和维护。该工具还附带了广泛的[文档][signet miner tool docs]。

- [LND #4917][] 默认禁用了[锚定输出][topic anchor outputs]，这一功能原计划在即将发布的 0.12.0-beta 中启用。高级用户仍然可以选择使用锚定输出。提交消息中提到，“计划在以后的版本中默认启用锚定输出。”

- [Rust-Lightning #742][] 改进了签名者 API，提供了每笔交易所需的信息，使签名者能够执行附加检查并生成签名。这一 PR 是支持 Rust-Lightning 外部签名者的更大努力的一部分，该工作可在 [Rust-Lightning #408][] 中跟踪。

- [BTCPay Server #2169][] 添加了支持解码[输出脚本描述符][topic descriptors]的功能，涉及按以下 BIPs 创建的钱包：[44][BIP44]（P2PKH HD 钱包）、[45][BIP45]（P2SH 多签 HD 钱包）、[49][BIP49]（P2SH-P2WPKH HD 钱包）、[84][BIP84]（原生 P2WPKH HD 钱包）以及 [BIP44 的提议修订][bips #253]（用于其他多签派生，并具有未记录的 P2SH-P2WSH 和原生 P2WSH 扩展）。

{% include references.md %}
{% include linkers/issues.md issues="19937,4917,742,2169,253,408" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[bcc 0.21.0 notes]: https://bitcoincore.org/en/releases/0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc5
[rust bitcoin 0.26.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.26.0
[rb notes]: https://github.com/apoelstra/rust-bitcoin/blob/010068ba321268704bc9da9fe311b45b9c0937b6/CHANGELOG.md#0260---2020-12-21
[btcpay server 1.0.6.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.6.7
[btcpay server 1.0.6.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.6.5
[c-lightning 0.9.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.3rc2
[belcher payjoin]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018356.html
[raw payjoin]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018358.html
[payjoin wiki]: https://en.bitcoin.it/wiki/PayJoin_adoption
[loaec hww]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018352.html
[blockstream jade blog]: https://blockstream.com/2021/01/03/en-secure-your-bitcoin-and-liquid-assets-with-blockstream-jade/
[coldcard 3.2.1]: https://blog.coinkite.com/version-3.2.1-released/
[mempool.space website]: https://mempool.space/
[mempool v2]: https://github.com/mempool/mempool/releases/tag/v2.0.0
[bluewallet 6.0.0. tweet]: https://twitter.com/bluewalletio/status/1338943580245790722
[sparrow 0.9.10]: https://github.com/sparrowwallet/sparrow/releases/tag/0.9.10
[bwt 0.2.1]: https://github.com/bwt-dev/bwt/releases/tag/v0.2.1
[signet miner tool docs]: https://github.com/bitcoin/bitcoin/blob/43f3ada27b835e6b198f9a669e4955d06f5c4d08/contrib/signet/README.md#miner
