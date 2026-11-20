---
title: 'Bitcoin Optech Newsletter #192'
permalink: /zh/newsletters/2022/03/23/
name: 2022-03-23-newsletter-zh
slug: 2022-03-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概述了关于 speedy trial 软分叉激活机制的讨论，并链接到一种经过优化的 LN 寻路算法的最新进展。此外，我们照例提供了对服务和客户端软件最近变更的描述、新版本与候选版本的发布公告，以及对热门比特币基础设施软件值得注意的变更的摘要。

## 新闻

- **<!--speedy-trial-discussion-->****speedy trial 讨论：** 最近一次关于提议中的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 操作码的会议，其摘要中提到了 speedy trial [软分叉激活方法][topic soft fork activation]，这部分内容随后被拆分出来，在 Bitcoin-Dev 邮件列表上单独开了一个讨论帖继续讨论，起因是 Jorge Timón [表达][timon st]了对在他认为有争议的软分叉上采用 speedy trial 的担忧。

  Russell O'Connor [解释][oconnor st]了这些担忧此前是如何得到解决的。Anthony Towns 进一步[描述][towns st]了反对的用户可以如何抵制用 speedy trial 激活一个他们并不想要的软分叉。

- **<!--payment-delivery-algorithm-update-->****支付投递算法更新：** René Pickhardt 在 Lightning-Dev 邮件列表[发帖][pickhardt payment delivery]表示，他为自己与 Stefan Richter 去年发表的寻路算法找到了一个计算效率高得多的近似算法。关于该算法的早期讨论见 [Newsletter #163][news163 pp]。

  Pickhardt 的邮件还提出了一些可以提高快速支付成功率的方法，例如实现 [stuckless 支付][news53 stuckless]，以及按照[多篇][boomerang]学术[论文][spear]中的提议，允许[可退款的超额支付][news86 boomerang]。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--coinswap-implementation-teleport-transactions-announced-->****公布 coinswap 实现 Teleport Transactions：** 在最近的一封 Bitcoin-Dev 邮件列表[帖子][belcher teleport]中，Chris Belcher 公布了实现 [coinswap][topic coinswap] 协议的 Teleport Transactions alpha 版本 [0.1][teleport transactions 0.1]。

- **<!--joinmarket-adds-taproot-sends-->****JoinMarket 新增 taproot 发送支持：** [JoinMarket v0.9.5][joinmarket v0.9.5] 增加了向 [bech32m][topic bech32] 地址发送资金的能力。

- **<!--mercury-wallet-adds-rbf-support-->****Mercury Wallet 新增 RBF 支持：** Mercury Wallet 是面向 Mercury [statechain][topic statechains] 的钱包，它发布了 [v0.6.5][mercury v0.6.5]，其中支持对提现交易进行手续费替换（[RBF][topic rbf]）。

- **<!--hexa-wallet-adds-lightning-support-->****Hexa Wallet 新增闪电网络支持：** 移动端钱包 Hexa 在 [v2.0.71 版本][hexa v2.0.71] 中为运行自有 LND 节点的用户加入了闪电网络功能。

- **<!--sparrow-adds-bip47-support-->****Sparrow 新增 BIP47 支持：** [Sparrow 1.6.0][sparrow 1.6.0]（以及后续的 1.6.1 与 1.6.2 版本）为 [BIP47][] 可重复使用的付款码及相关功能提供了支持，并[介绍了这些功能][sparrow wallet tweet]。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [HWI 2.1.0-rc.1][HWI 2.1.0-rc.1] 是 HWI 的一个候选发布版本，为多款硬件签名设备新增了 taproot 支持，并包含其他改进与缺陷修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [Eclair #2203][Eclair #2203] 增加了若干配置参数，使用户可以为[未公开通道][topic unannounced channels]指定不同于公开通道默认值的最小注资额。

- [LDK #1311][LDK #1311] 增加了对 [BOLTs #910][] 中提议的短通道标识符（SCID） `alias` 字段的支持，允许节点请求其对等节点用一个任意值（而非由锚定该通道的链上交易派生出的值）来标识某个通道。这有助于提升隐私，防止 SCID 向第三方泄露节点创建了哪些交易；此外，正如 [Newsletter #156][news156 zcc] 所述，该字段也被提议用于自愿启用的零确认通道（有时称为 *turbo channels*）规范。

- [LDK #1286][LDK #1286] 按照 [BOLT7 的推荐][bolt7 route rec]，为用于路由支付的 CLTV（`OP_CHECKLOCKTIMEVERIFY`）值加上了偏移量。这让只观察到支付尝试一部分的旁观者（例如为这笔支付做路由的某个节点）更难正确猜出哪个节点可能是预期的收款方。

- [HWI #584][HWI #584] 增加了在搭配最新固件版本使用 BitBox02 硬件签名设备时向 [bech32m][topic bech32] 地址支付的支持。

- [HWI #581][HWI #581] 在搭配未来固件版本的 Trezor 使用时，禁用了对含外部输入的交易（例如 [coinjoin][topic coinjoin] 中的交易）的签名支持。这个 PR 是在一次固件变更之后提出的，该变更破坏了 HWI 此前用于实现该支持的变通做法。后续的 PR（[HWI #590][HWI #590]）似乎表明，Trezor 正在考虑将来为用户提供签署这类交易的途径。

- [BDK #515][BDK #515] 开始在内部数据库中保留已花费的交易输出。这对创建[替换交易][topic rbf]很有用，也简化了对 [BIP47][] 可复用支付码的[持续实现][bdk #549]。


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
