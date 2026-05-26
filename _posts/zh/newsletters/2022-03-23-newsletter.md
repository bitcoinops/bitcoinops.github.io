---
title: 'Bitcoin Optech Newsletter #192'
permalink: /zh/newsletters/2022/03/23/
name: 2022-03-23-newsletter-zh
slug: 2022-03-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概述了关于 speedy trial 软分叉激活机制的讨论，并链接到针对 LN 路径寻找算法的优化更新。此外，我们照例提供了对服务和客户端软件最近更改的描述、新版发布与候选发布的公告，以及对流行比特币基础设施软件值得注意的更改摘要。

## 新闻

- **<!--speedy-trial-discussion-->****speedy trial 讨论：** 在最近一次关于提议中的 OP_CHECKTEMPLATEVERIFY opcode 的会议纪要中提到 speedy trial 软分叉激活方法，该内容随后被拆分出来，在 Bitcoin-Dev 邮件列表上单独开设了讨论线程，因为 Jorge Timón 表达了对在他认为具有争议的软分叉上使用 speedy trial 的担忧。Russell O'Connor 解释了这些担忧此前已如何得到解决。Anthony Towns 进一步描述了反对者如何抵制利用 speedy trial 激活一个他们并不希望发生的软分叉。

- **<!--payment-delivery-algorithm-update-->****支付路径算法更新：** René Pickhardt 在 Lightning-Dev 邮件列表中发帖表示，他为去年与 Stefan Richter 发布的路径寻找算法找到了计算效率更高的近似实现。关于该算法的早期讨论可见 Newsletter #163。Pickhardt 的邮件还提出了一些可以提高快速支付成功率的方法，例如实现 [stuckless 支付][news53 stuckless]，以及按照[多篇][boomerang]学术[论文][spear]中的提议，允许[可退款的超额支付][news86 boomerang]。

## 服务和客户端软件的更改

*在这一月度栏目中，我们重点介绍比特币钱包与服务的有趣更新。*

- **<!--coinswap-implementation-teleport-transactions-announced-->****Coinswap 实现 Teleport Transactions 发布：** 在最近的 Bitcoin-Dev 邮件列表[帖子][belcher teleport]中，Chris Belcher 公布了实现 [coinswap][topic coinswap] 协议的 Teleport Transactions alpha 版 [0.1][teleport transactions 0.1]。

- **<!--joinmarket-adds-taproot-sends-->****JoinMarket 新增 taproot 转账：** [JoinMarket v0.9.5][joinmarket v0.9.5] 增加了向 [bech32m][topic bech32] 地址发送资金的能力。

- **<!--mercury-wallet-adds-rbf-support-->****Mercury Wallet 增加 RBF（Replace-by-Fee） 支持：** 面向 Mercury [statechain][topic statechains] 的钱包发布了 [v0.6.5][mercury v0.6.5]，其中为提现交易引入了 RBF（Replace-by-Fee） 替换功能。

- **<!--hexa-wallet-adds-lightning-support-->****Hexa Wallet 新增闪电网络支持：** 移动端钱包 Hexa 在 [v2.0.71 版本][hexa v2.0.71] 中为运行自有 LND 节点的用户加入了闪电网络功能。

- **<!--sparrow-adds-bip47-support-->****Sparrow 新增 BIP47 支持：** [Sparrow 1.6.0][sparrow 1.6.0]（以及后续的 1.6.1 与 1.6.2 版本）为 [BIP47][] 可重复使用的付款码及相关功能提供了支持，并[介绍了这些功能][sparrow wallet tweet]。

## 发布与候选发布

*面向流行比特币基础设施项目的新版本发布与候选发布。请考虑升级到新版本或协助测试候选版本。*

- [HWI 2.1.0-rc.1][HWI 2.1.0-rc.1] 是 HWI 的一个候选发布，新增了对多款硬件签名设备的 taproot 支持，并包含其他改进和漏洞修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [Eclair #2203][Eclair #2203] 添加了额外的配置参数，使用户可以为[未公开通道][topic unannounced channels]指定与公开通道默认值不同的最小资金金额。

- [LDK #1311][LDK #1311] 实现了 [BOLTs #910][] 中提议的短通道标识符（SCID） `alias` 字段，允许节点请求其对等方使用任意值而非锚定通道的链上交易所派生的值来标识通道。这有助于通过防止 SCID 向第三方泄露节点创建了哪些交易来提升隐私，并且在 Newsletter #156 中描述的可选零确认通道（有时称为 *turbo channels*）规范里也被提议使用。

- [LDK #1286][LDK #1286] 按 [BOLT7 的推荐][bolt7 route rec]，为用于路由付款的 CLTV（`OP_CHECKLOCKTIMEVERIFY`）值增加了偏移量。这使得观察到部分支付过程的实体（例如中继该支付的节点）更难准确猜测哪个节点可能是最终收款人。

- [HWI #584][HWI #584] 在使用 BitBox02 硬件签名设备的最新固件版本时，加入了向 [bech32m][topic bech32] 地址付款的支持。

- [HWI #581][HWI #581] 在使用未来固件版本的 Trezor 时，禁用了包含外部输入（例如在 [coinjoin][topic coinjoin] 中）的交易签名支持。该拉取请求紧随一次固件更新之后，该更新破坏了 HWI 先前用于实现此支持的变通方案。后续拉取请求（[HWI #590][HWI #590]）显示 Trezor 正在研究为用户提供签署此类交易的途径。

- [BDK #515][BDK #515] 开始在内部数据库中保留已花费的交易输出，这对于创建[替换交易][topic rbf]很有用，并简化了对 [BIP47][] 可重复使用付款码的[持续实现][bdk #549]。


{% include references.md %}
{% include linkers/issues.md v=1 issues="2203,1311,910,1286,584,581,515,549,590" %}
[hwi 2.1.0-rc.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.1.0-rc.1
[bolt7 route rec]: https://github.com/lightning/bolts/blob/master/07-routing-gossip.md#recommendations-for-routing
[oconnor st]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020106.html
[timon st]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020102.html
[towns st]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020127.html
[pickhardt payment delivery]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003510.html
[news163 pp]: /zh/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news53 stuckless]: /zh/newsletters/2019/07/03/#stuckless-payments
[spear]: https://dl.acm.org/doi/10.1145/3479722.3480997
[news156 zcc]: /zh/newsletters/2021/07/07/#zero-conf-channel-opens
[boomerang]: https://arxiv.org/pdf/1910.01834.pdf
[news86 boomerang]: /zh/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[belcher teleport]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/020026.html
[teleport transactions 0.1]: https://github.com/bitcoin-teleport/teleport-transactions/releases/tag/0.1
[joinmarket v0.9.5]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.5
[mercury v0.6.5]: https://github.com/layer2tech/mercury-wallet/releases/tag/v0.6.5
[hexa v2.0.71]: https://github.com/bithyve/hexa/releases/tag/v2.0.71
[sparrow 1.6.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.6.0
[sparrow wallet tweet]: https://twitter.com/SparrowWallet/status/1504458210366922759
