---
title: 'Bitcoin Optech Newsletter #218'
permalink: /zh/newsletters/2022/09/21/
name: 2022-09-21-newsletter-zh
slug: 2022-09-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了有关使用 `SIGHASH_ANYPREVOUT` 来模拟 drivechains 各方面的一个讨论；周报还包括我们的常规部分，介绍近期服务、客户端软件和热门比特币基础设施软件的变更。

## News

- **使用 APO 和可信设置创建 drivechains：** Jeremy Rubin [发表][rubin apodc]到 Bitcoin-Dev 邮件列表，描述了可信设置过程如何结合提议的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 操作码，以实现类似于 [Drivechain][topic sidechains] 提议的行为。Drivechain 是这样一种侧链，矿工通常会负责保护该侧链资金的安全（对比于负责保护比特币主链上资金的完整节点）。试图窃取 Drivechain 资金的矿工必须提前几天或几周公布他们的恶意意图，让用户有机会更改他们的完整节点以执行侧链规则。Drivechain 主要被提议作为软分叉包含在比特币中（参见 BIP [300][bip300] 和 [301][bip301]），但之前在邮件列表中的一个帖子（参见 [周报 #190][news190 dc]）描述了对比特币合约语言的一些其他灵活提议的补充内容也可以支持 Drivechain 的实施。

    在本周的帖子中，Rubin 描述了另一种可以使用比特币合约语言中的一个提议增加来实现 Drivechain 的方式。这种方式将使用 [BIP118][] 中提议的 `SIGHASH_ANYPREVOUT`（APO）。与 BIP300 相比，帖子所描述的基于 APO 的 Drivechain 有几个缺点，但可能提供了足够相似的行为，以至于 APO 可以被视作是启用了 Drivechain。一些人可能认为这有益处，而另一些人可能认为这是一个问题。

## 服务与客户端软件变更

*在这个月度专题中，我们重点介绍比特币钱包和服务的有意思的更新。*

- **Mempool Project 推出闪电网络浏览器：**
  Mempool 的开源项目[闪电网络面板][mempool Lightning]显示网络的聚合统计数据以及单个节点流动性和连接性数据。

- **联盟软件 Fedimint 添加了闪电网络：**
  在最近的[博客文章][blockstream blog fedimint] 中，Blockstream 概述了对 [Fedimint][] Chaumian e-cash 联盟项目的更新，其中包括对闪电网络的支持。该项目还[宣布][fedimint signet tweet]有公共 [signet][topic signet] 和水龙头可用。

- **Bitpay 钱包改进了 RBF 支持：**
  Bitpay 通过更好地处理多个接收者的交易碰撞来[改进][bitpay 12051]其[现有][bitpay 11935]发送 [RBF][topic rbf] 交易的支持。

- **Mutiny 闪电网络钱包公布：**
  Mutiny（以前被称为 pLN）[公布][mutiny wallet]。该钱包是一个专注于隐私的闪电钱包，每个通道会使用单独的节点。

## 重大代码及文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]*。

- [Core Lightning #5581][] 新增事件通知主题“block_added”。每次从 bitcoind 收到新块时，订阅插件都会收到通知。

- [Eclair #2418][] 和 [#2408][eclair #2408] 添加了对通过[盲化路由][topic rv routing]发送来付款的接收支持。创建盲化支付的付款者不会被提供接收付款节点的身份。这可能会改善隐私，尤其是与[未公布的通道][topic unannounced channels]一起使用时。

- [Eclair #2416][] 添加支持接收使用[提议 BOLT12][proposed bolt12] 中定义的[要约][topic offers]协议请求的付款。该功能使用了最近添加的接收盲化付款的支持（请参阅 Eclair #2418 的上一个列表项）。  

- [LND #6335][] 添加了一个 `TrackPayments` API，允许订阅所有本地支付尝试。如 PR 描述中所述，这可用于收集有关付款的统计信息，以帮助将来更好地发送和路由付款，例如用于执行 [trampoline 路由][topic trampoline payments]的节点。

- [LDK #1706][] 添加了对使用 [BIP158][] 中定义的[致密区块过滤器][topic compact block filters]下载已确认交易的支持。使用时，如果过滤器表明一个块可能包含影响钱包的交易，则下载最多 4 兆字节的完整块。如果确定该块不包含任何影响钱包的交易，则不会下载其他数据。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5581,2418,2408,2416,6335,1706" %}
[rubin apodc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020919.html
[news190 dc]: /en/newsletters/2022/03/09/#enablement-of-drivechains
[proposed bolt12]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[mempool lightning]: https://mempool.space/lightning
[blockstream blog fedimint]: https://blog.blockstream.com/fedimint-update/
[bitpay 12051]: https://github.com/bitpay/wallet/pull/12051
[bitpay 11935]: https://github.com/bitpay/wallet/pull/11935
[mutiny wallet]: https://bc1984.com/make-lightning-payments-private-again/
[Fedimint]: https://github.com/fedimint/fedimint
[fedimint signet tweet]: https://twitter.com/EricSirion/status/1572329210727010307
