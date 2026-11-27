---
title: 'Bitcoin Optech Newsletter #94'
permalink: /zh/newsletters/2020/04/22/
name: 2020-04-22-newsletter-zh
slug: 2020-04-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到一个使用预签名交易创建保险库的原型，并包含我们的常设栏目：服务、客户端软件以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--vaults-prototype-->****保险库原型：** Bryan Bishop 已[宣布][bishop vaults]了 [Newsletter #59][news59 vaults] 中描述的保险库[契约][topic covenants]（vault covenant）的 [Python 原型][vaults prototype]。该机制使用临时密钥和预签名的时间锁定交易，让你能检测到有人曾在一次盗窃企图中使用你的某个私钥。随后，你（或代你行动的瞭望塔）可以启动应急协议，追回大部分受保护的资金。该原型还包含用 [BIP119][] 提议的操作码 `OP_CHECKTEMPLATEVERIFY` 实现同一基本机制的版本。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--btcpay-adds-support-for-sending-and-receiving-payjoined-payments-->****BTCPay 增加对发送和接收 payjoin 支付的支持：** [payjoin][topic payjoin] 是一种通过在链上交易中包含付款方和收款方的输入来增强比特币支付隐私的协议。这可以防止检查区块链数据的外部观察者认定该交易的所有输入都属于同一用户（例如[^payjoin-table]）。如果有很多人使用 payjoin，区块链分析师常用的[公共输入启发式][common input heuristic]就会大打折扣，从而连不使用 payjoin 的比特币用户也能获得更好的隐私保护。

  本周，BTCPay [宣布][btcpay pj announce]发布 1.0.4.0 版，其中实现了 payjoin 支持：既能在支付处理模式（payment processor mode）下接收支付，也能用 BTCPay 内置钱包发送支付。有关如何使用该协议，请参见其[用户指南][btcpay pj ug]。有关该实现的技术细节，请参见其[规范][btcpay pj spec]，或参见正在积极讨论后续改进的 [issue][btcpay-doc 486]。要让这项变更发挥最大作用，其他主流钱包也需要实现创建兼容 payjoin 支付的能力。

- **<!--lightning-labs-drafts-lightning-service-authentication-tokens-lsat-specification-->****Lightning Labs 起草闪电服务认证令牌（LSAT）规范：** Lightning Labs 已[宣布][ll lsat announcement] LSAT，这是一份[规范][lsat spec]，概述了一种通过闪电网络购买令牌（macaroons）并在应用程序中将其用作认证和 API 支付机制的协议。

- **<!--lightning-labs-announces-faraday-for-channel-management-->****Lightning Labs 宣布用于通道管理的 Faraday：** [Faraday][ll faraday announcement] 是面向 LND 节点运营者的工具，它分析现有通道，并就关闭有问题或表现不佳的通道给出建议。这类通道往往呈现交易量低、在线时间短或手续费高等特征。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] 是 Bitcoin Core 下一个大版本的候选发布。

- [LND 0.10.0-beta.rc4][lnd 0.10.0-beta] 允许测试 LND 的下一个大版本。我们鼓励有意测试者阅读 LND 开发者 Olaoluwa Osuntokun 在 [LND 工程邮件列表][lnd engineering mailing list] 上发布的[候选发布版本介绍][lnd rc intro]。

- [C-Lightning 0.8.2-rc1][c-lightning 0.8.2] 是 C-Lightning 下一版本的首个候选发布。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Rust-Lightning][rust-lightning repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Bitcoin Core #17595][] 增加了使用 [GNU Guix][] 可复现构建 Bitcoin Core Windows 版本的支持。Guix 可复现构建仅剩的目标平台 macOS，目前有一个尚未合并的[草案 PR][Bitcoin Core #17920]。

- [C-Lightning #3611][] 添加了一个 `keysend` 插件，使节点能够安全接收[自发支付][topic spontaneous payments]——即无需先生成发票就能发起的支付。其工作方式是：付款方自行选择支付原像（preimage，通常由收款方选择），推导出支付哈希（通常写在发票里），用收款方的节点公钥加密原像，再把加密数据随支付一并发送给收款方，由支付哈希为这笔支付提供保障。收款方解密出原像后，像普通支付那样用它领取款项。为了让支付可以被跟踪，`lightningd` 在领取自发支付之前，会先为解密后的原像自动创建一个内部发票。自发支付的一个明显用途是捐赠，另一个不那么明显的用途是在支付中附带聊天消息，例如通过兼容 LND 的 [WhatSat][] 软件和兼容 C-Lightning 的 [noise][] 插件。

- [C-Lightning #3623][] 增加了使用[盲化路径][blinded paths]支付的最小实现（仅在设置配置参数 `--enable-experimental-features` 时可用）。如 [Newsletter #92][news92 blinded paths] 中所述，盲化路径使得在发起方不知道目的节点网络身份或所走完整路径的情况下路由支付成为可能。这不仅提升了起点与终点的隐私，也提升了盲化路径上任何未公开节点的隐私。此 PR 中的最小实现主要用于测试，例如配合 Eclair 正在开发中的实现进行测试。

- [LND #4163][] 增加了一个 `version` RPC，它返回 LND 服务器版本与构建标志的信息。这使得应用程序更容易确保自身与当前运行的 LND 版本兼容。

- [Rust-Lightning #441][] 增加了对发送和接收基本[多路径支付][topic multipath payments]的支持。该实现目前尚不能完全使用，因为还需要后续拉取请求来[增加路由查找支持][rl mpp next]和[处理部分支付的超时][rust-lightning #587]。

## 脚注

    {% capture today-private %}Inputs:<br>&nbsp;&nbsp;Alice (1 BTC)<br>&nbsp;&nbsp;Alice (4 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Alice's change (2 BTC)<br>&nbsp;&nbsp;Bob's revenue (3 BTC){% endcapture %}
    {% capture today-public %}Inputs:<br>&nbsp;&nbsp;Spender (1 BTC)<br>&nbsp;&nbsp;Spender (4 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Spender or Receiver (2 BTC)<br>&nbsp;&nbsp;Spender or Receiver (3 BTC){% endcapture %}
    {% capture payjoin-private %}Inputs:<br>&nbsp;&nbsp;Alice (1 BTC)<br>&nbsp;&nbsp;Alice (4 BTC)<br>&nbsp;&nbsp;Bob (3 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Alice's change (2 BTC)<br>&nbsp;&nbsp;Bob's revenue & change (6 BTC){% endcapture %}
    {% capture payjoin-public %}Inputs:<br>&nbsp;&nbsp;Spender or Receiver (1 BTC)<br>&nbsp;&nbsp;Spender or Receiver (4 BTC)<br>&nbsp;&nbsp;Spender or Receiver (3 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Spender or Receiver (2 BTC)<br>&nbsp;&nbsp;Spender or Receiver (6 BTC){% endcapture %}

[^payjoin-table]:
    一个示例，说明参与 payjoin 的用户对一笔交易的了解，与区块链分析师能够推断出的内容之间的差别。

    <div markdown="1" class="xoverflow">

    | | Alice 和 Bob 了解的 | 网络看到的 |
    |-|-|-|
    | **当前常态** | {{today-private}} | {{today-public}} |
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
[bishop vaults]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017755.html
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
