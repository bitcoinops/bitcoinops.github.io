---
title: 'Bitcoin Optech Newsletter #94'
permalink: /zh/newsletters/2020/04/22/
name: 2020-04-22-newsletter-zh
slug: 2020-04-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到一个使用预签名交易创建保险库的原型，并包含我们关于服务、客户端软件和流行的比特币基础设施项目的定期更新。

## 行动项

*本周无。*

## 新闻

- **<!--vaults-prototype-->****保险库原型：** Bryan Bishop 已[宣布][bishop vaults]了一个使用 Python 语言编写的保险库[原型][vaults prototype]，这是在 [Newsletter #59][news59 vaults] 中描述的保险库[契约][topic covenants]。该机制使用临时密钥和预签名的时间锁定交易，允许您检测是否有人使用了您的私钥进行盗窃尝试。此时，您（或代表您的瞭望塔）可以启动应急协议，恢复大部分受保护的资金。该原型还包括使用 [BIP119][] 提议的 `OP_CHECKTEMPLATEVERIFY` 操作码实现的同一基本机制。

## 服务和客户端软件的更改

*在这个每月特辑中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--btcpay-adds-support-for-sending-and-receiving-payjoined-payments-->****BTCPay 增加对发送和接收 payjoined 支付的支持：** [payjoin][topic payjoin] 是一种通过在链上交易中包含支付方和接收方的输入来增强比特币支付隐私的协议。这可以防止外部观察者通过区块链数据推断该交易的所有输入都属于同一用户（例如[^payjoin-table]）。如果大量用户使用 payjoin，这将大大降低区块链分析师使用的[公共输入启发式][common input heuristic]的可靠性，从而改善即使不使用 payjoin 的比特币用户的隐私。

  本周，BTCPay [宣布][btcpay pj announce]发布版本 1.0.4.0，其中包括在支付处理器模式下接收支付和使用 BTCPay 内部钱包发送支付的 payjoin 支持实现。有关使用该协议的详细信息，请参见他们的[用户指南][btcpay pj ug]。有关其实现的技术细节，请参见他们的[规范][btcpay pj spec]或未来改进正在积极讨论的[问题][btcpay-doc 486]。为了使这一变化达到最大效果，其他流行的钱包也需要实现创建兼容 payjoin 支付的支持。

- **<!--lightning-labs-drafts-lightning-service-authentication-tokens-lsat-specification-->****Lightning Labs 起草闪电服务认证令牌 (LSAT) 规范：** Lightning Labs 已[宣布][ll lsat announcement] LSAT，这是一份[规范][lsat spec]，概述了一种通过闪电网络购买令牌（macaroons）并在应用程序中将其用作认证和 API 支付机制的协议。

- **<!--lightning-labs-announces-faraday-for-channel-management-->****Lightning Labs 宣布 Faraday 用于通道管理：** [Faraday][ll faraday announcement] 是一个为 LND 节点操作员提供的工具，它分析现有通道并建议关闭问题通道或表现不佳的通道。此类通道通常具有低交易量、低在线时间或高费用等属性。

## 发布与候选发布

*流行的比特币基础设施项目的新发布与候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] 是下一版本 Bitcoin Core 的候选发布。

- [LND 0.10.0-beta.rc4][lnd 0.10.0-beta] 允许测试下一版本 LND。潜在测试者被鼓励阅读 LND 开发者 Olaoluwa Osuntokun 在 [LND 工程邮件列表][lnd rc intro]中的发布候选版本介绍。

- [C-Lightning 0.8.2-rc1][c-lightning 0.8.2] 是下一版本 C-Lightning 的首个候选发布版本。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Rust-Lightning][rust-lightning repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #17595][] 增加了使用 [GNU Guix][] 可重复构建 Windows 版本的支持。Guix 可重复构建的最后一个目标平台 macOS 还有一个待处理的[草案 PR][Bitcoin Core #17920]。

- [C-Lightning #3611][] 添加了一个 `keysend` 插件，使节点能够安全接收[自发支付][topic spontaneous payments]——即未生成发票的支付。这些支付通过让支付发送方选择支付前镜像（通常由接收方选择），生成其支付哈希（通常包含在发票中），并将前镜像加密到接收方的节点公钥来工作。发送方会连同加密数据一起发送支付，由支付哈希来保障安全。接收方解密前镜像并使用它像正常支付一样认领支付。为了允许支付跟踪，`lightningd` 在认领自发支付前，会自动为解密后的前镜像创建一个内部发票。自发支付的一个明显用途是捐赠，但另一个不太明显的用途是通过支付发送聊天消息，例如通过与 LND 兼容的 [WhatSat][] 软件和与 C-Lightning 兼容的 [noise][] 插件。

- [C-Lightning #3623][] 增加了对使用[隐藏路径][blinded paths]的支付的最小实现（仅在配置参数 `--enable-experimental-features` 可用）。如 [Newsletter #92][news92 blinded paths] 中所述，隐藏路径使得可以在发送方不了解目标节点身份或完整路径的情况下路由支付。这不仅改善了源头和目标节点的隐私，还增强了隐藏路径中任何未公布节点的隐私。此 PR 中的最小实现主要是为了测试，例如与 Eclair 正在开发的工作中的实现一起测试。

- [LND #4163][] 增加了一个 `version` RPC，它返回 LND 服务器版本和构建标志的信息。这使得应用程序更容易确保它们与当前运行的 LND 版本兼容。

- [Rust-Lightning #441][] 增加了发送和接收基本[多路径支付][topic multipath payments]的支持。该实现目前尚未完全可用，因为需要后续拉取请求来[增加路由查找支持][rl mpp next]和[超时部分支付][rust-lightning #587]。

## 脚注

[^payjoin-table]:
    一个参与 payjoin 的用户了解的交易信息与区块链分析师能推断出的信息的示例。

    <div markdown="1" class="xoverflow">

    | | Alice 和 Bob 了解的 | 网络看到的 |
    |-|-|-|
    | **当前规范** | {{today-private}} | {{today-public}} |
    | **使用 payjoin** | {{payjoin-private}} | {{payjoin-public}} |

    </div>

{% include references.md %}
{% include linkers/issues.md issues="17595,3611,3623,4163,441,587,17920" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta.rc4
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2rc1
[noise]: https://github.com/lightningd/plugins/tree/master/noise
[blinded paths]: https://github.com/lightningnetwork/lightning-rfc/blob/route-blinding/proposals/route-blinding.md
[rl mpp next]: https://github.com/rust-bitcoin/rust-lightning/issues/431#issuecomment-571757632
[btcpay pj ug]: https://docs.btcpayserver.org/features/payjoin
[btcpay pj spec]: https://docs.btcpayserver.org/features/payjoin/payjoin-spec
[btcpay-doc 486]: https://github.com/btcpayserver/btcpayserver-doc/issues/486
[lnd rc intro]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/UoyCGu-RvnM
[lnd engineering mailing list]: https://groups.google.com/a/lightning.engineering/forum/#!forum/lnd
[bishop vaults]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017755.html
[vaults prototype]: https://github.com/kanzure/python-vaults
[news59 vaults]: /zh/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[btcpay pj announce]: https://blog.btcpayserver.org/btcpay-server-1-0-4-0/
[news92 blinded paths]: /zh/newsletters/2020/04/08/#blinded-paths
[whatsat]: https://github.com/joostjager/whatsat
[common input heuristic]: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
[GNU Guix]: https://www.gnu.org/software/guix/
[ll lsat announcement]: https://lightning.engineering/posts/2020-03-30-lsat/
[lsat spec]: https://lsat.tech/
[ll faraday announcement]: https://lightning.engineering/posts/2020-04-02-faraday/
