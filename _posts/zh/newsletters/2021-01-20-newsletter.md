---
title: 'Bitcoin Optech Newsletter #132'
permalink: /zh/newsletters/2021/01/20/
name: 2021-01-20-newsletter-zh
slug: 2021-01-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了 Bitcoin-Dev 邮件列表中关于 payjoin 采用、以及让硬件钱包兼容更多高级比特币功能的讨论帖。此外，还包括我们常规的栏目：服务和客户端软件的变更概述、新版本与候选发布，以及热门比特币基础设施软件的变更。

## 新闻

- **<!--payjoin-adoption-->****payjoin 的采用：** Chris Belcher 在 Bitcoin-Dev 邮件列表中[发布][belcher payjoin]了一份请求，呼吁人们想办法提高 [payjoin][topic payjoin] 的采用率，并提供了一个[维基页面][payjoin wiki]，用来跟踪支持 payjoin 发送或接收功能的项目。其中一个由 Craig Raw 提出的[建议][raw payjoin]是扩展协议，使其即使在收款方不运行服务器时也能工作。

- **<!--making-hardware-wallets-compatible-with-more-advanced-bitcoin-features-->****让硬件钱包兼容更多高级比特币功能：** Kevin Loaec 在 Bitcoin-Dev 邮件列表中[发起了一场讨论][loaec hww]，探讨如何改造硬件钱包，使它们能够处理比单签或多重签名更复杂的脚本。例如，允许硬件钱包处理通道内的 LN 支付，或来自[保险库][topic vaults]的支付。他的帖子很好地描述了当前硬件钱包无法处理的各种问题，但他指出所需的“改动可能非常困难”。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--blockstream-announces-jade-hardware-wallet-->****Blockstream 宣布 Jade 硬件钱包：**
  Blockstream 的[新 Jade 硬件钱包][blockstream jade blog]是开源的，支持比特币和 Liquid 网络，并兼容 Android 版 Blockstream Green。

- **<!--coldcard-adds-payjoin-signing-->****Coldcard 增加 payjoin 签名：**
  Coldcard 的 [3.2.1 版本][coldcard 3.2.1] 增加了 [BIP78][] 的 payjoin 签名支持，并对多重签名做了多项改进。

- **<!--mempool-v2-0-0-released-->****mempool v2.0.0 发布：**
  开源[区块浏览器][topic block explorers] mempool 为 [mempool.space][mempool.space website] 网站提供后端，它发布了 [2.0.0 版本][mempool v2]。mempool 支持 Bitcoin Core、Electrum 和 Esplora 后端，并通过 API 公开区块、交易和地址信息。

- **<!--bluewallet-adds-multisig-->****BlueWallet 增加多重签名功能：**
  [BlueWallet 6.0.0 版本][bluewallet 6.0.0. tweet]增加了创建和管理 air-gapped 的原生 segwit 多重签名保险库的功能。

- **<!--sparrow-supports-connecting-to-bitcoin-core-->****Sparrow 支持连接到 Bitcoin Core：**
  [Sparrow 0.9.10][sparrow 0.9.10] 借助 [Bitcoin Wallet Tracker v0.2.1][bwt 0.2.1] 的 Java Native Interface 绑定功能，现在支持直接连接作为后端的 Bitcoin Core 节点。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.21.0][Bitcoin Core 0.21.0] 是该全节点实现及其配套钱包等软件的下一个主要版本。主要新功能包括：支持使用[版本 2 地址公告消息][topic addr v2]的新 Tor 洋葱服务；可选择提供[紧凑区块过滤器][topic compact block filters]；支持 [signet][topic signet]（包括已激活 [taproot][topic taproot] 的默认 signet）。它还为原生使用[输出脚本描述符][topic descriptors]的钱包提供实验性支持。完整变更列表请参阅[发布说明][bcc 0.21.0 notes]。

- [Rust Bitcoin 0.26.0][] 是该库的一个新版本。主要新功能包括支持 signet、版本 2 地址公告消息，以及对[部分签名比特币交易（PSBT）][topic psbt]处理的改进。详情请参阅[发布说明][rb notes]。

- [BTCPay Server 1.0.6.7][] 是上周 [1.0.6.5][btcpay server 1.0.6.5] 之后的第二个维护版本；1.0.6.5 增加了“在钱包设置中支持部分输出描述符”（见下方*值得注意的变更*部分）。此版本也包含其他功能和错误修复。

- [C-Lightning 0.9.3rc2][c-lightning 0.9.3] 是该 LN 节点一个新次要版本的候选发布。

- [LND 0.12.0-beta.rc5][LND 0.12.0-beta] 是该 LN 节点下一个主要版本的最新候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范 (BOLTs)][bolts repo]中值得注意的变更。*

- [Bitcoin Core #19937][] 新增了一个独立的 `bitcoin-util` 可执行文件和一个用于挖掘 [signet][topic signet] 区块的 `miner` 脚本，让创建和维护新的 signet 网络变得更容易。这些新工具还附有详尽的[文档][signet miner tool docs]。

- [LND #4917][] 默认禁用[锚定输出][topic anchor outputs]，而这一功能原计划在即将发布的 0.12.0-beta 中启用。高级用户仍可选择使用锚定输出。提交信息中指出，“计划在以后的版本中默认启用锚定输出。”

- [Rust-Lightning #742][] 改进了签名器 API，提供签名器执行额外检查并生成签名所需的逐交易信息。该 PR 是支持 Rust-Lightning 外部签名器这一更大工作的一部分，相关进展在[此处][Rust-Lightning #408]跟踪。

- [BTCPay Server #2169][] 增加了相关函数，可解码指向按以下 BIP 创建的钱包的[输出脚本描述符][topic descriptors]：[44][BIP44]（P2PKH HD 钱包）、[45][BIP45]（P2SH 多重签名 HD 钱包）、[49][BIP49]（P2SH-P2WPKH HD 钱包）、[84][BIP84]（原生 P2WPKH HD 钱包），以及[对 BIP44 的一项提议修订][bips #253]（涉及其他多重签名派生方式，其中包含使用 P2SH-P2WSH 和原生 P2WSH 的未记录扩展）。

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
