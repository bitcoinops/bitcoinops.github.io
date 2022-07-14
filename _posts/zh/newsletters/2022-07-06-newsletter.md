---
title: 'Bitcoin Optech Newsletter #207'
permalink: /zh/newsletters/2022/07/06/
name: 2022-07-06-newsletter-zh
slug: 2022-07-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报汇总了关于长期的区块奖励融资计划、BIP47 可复用支付码的替代方案、闪电网络通道拼接的公告选项、闪电网络路由费收集策略以及洋葱消息速率限制的讨论。此外还有我们的常规部分：软件的新版本和候选版本、热门比特币基础设施的重大变更。

## 新闻

- **<!--longterm-block-reward-funding-->长期的区块奖励融资**：在 Bitcoin-Dev 邮件组的一篇表面上讨论限制条款（[covenants][topic covenants]）的帖子中，作者提到，在当前的模式下，比特币的长期安全性依赖于对区块空间的需求。这种需求必须能产生足够高的手续费，超过攻击者愿意为摧毁比特币用户而向矿工支付的价格。开发者 Peter Todd [指出][todd subsidy]，如果比特币协议能被修改成包含一项永续的补贴，这种依赖就可以移除。许多回复表示，他们认为这个系统没有永续补贴会更好，不过也有人在寻找替代方案或明显等价的方案（比如 “[保管费用][demurrage]”）。

  截至本文撰写之时，这个帖子里似乎只有随意的对话，而算不上是为在可见的未来改变比特币而提出的实际提议。

- **<!--updated-alternative-to-bip47-reusable-payment-codes-->BIP47 可复用支付码的升级替代方案**：开发者 Alfred Hodler 在 Bitcoin-Dev 邮件组中[发帖][hodler new codes]，提出了 [BIP47][] 的一种替代方案，旨在解决 BIP47 在生产环境中发现的一些问题。BIP47 使得 Alice 可以公开一个支付码，任何人都可以用这个支付码和自己的私钥来创建无限数量的私密地址，只有 Alice 和创建者知道这些地址属于 Alice，从而避免了[地址复用][topic output linking]最糟糕的问题。

  但是，BIP47 的问题之一是，支付者 Bob 第一次发给接收者 Alice 的交易是一笔 *通知交易*，使用了跟支付码相关的一个特殊地址。这就毫无疑问会向知道 Alice 的支付码的第三方泄露信息，使其知道有人准备给 Alice 支付。如果 Bob 的钱包没有安排好隔离的资金来发起通知交易，交易也会泄露 Bob 正准备给 Alice 支付 —— 这就减少甚至完全抵消了 BIP47 的好处。

  Holder 的方案似乎更少泄露信息的个能，但会提高实现其协议的客户端需要从区块链上获得的数据量，因此更不适合搭配轻客户端。Ruben Somsen 指出了几种同样值得探究的替代方案，包括 Somsen 的 “静默支付”（见[周报 #194][news194 silent payments]）、Rubin Linus 的 “[2022 隐身地址][2022 stealth addresses]”，以及此前发表在关于优化 BIP47 的邮件组中[讨论][prauge bip47]。

- **<!--announcing-splices-->宣布拼接（splices）**：在一个 [PR][bolts #1004] 和 Lihtning-Dev 邮件组的一场[讨论][osuntokun splice]中，开发者们讨论了宣布某个正在关闭的通道实际上是在[拼接][topic splicing]的最好办法。通道拼接的意思是，这条通道实际上并没有消失，只是会增加或减少容量。

  一种提议是，节点在看到一笔链上的通道关闭交易后，一段时间内并不认为这个通道关闭了。这会为宣布新的（拼接后的）通道留出时间。在此期间，节点仍会尝试通过这个似乎已经关闭的通道路由支付，因为一个拼接了的通道依然能够安全地路由支付，即使其新通道的开启交易还没有得到足够多的区块确认数。

  另一个提议是在链上的通道关闭交易中包含一个信号，表明正在拼接，从而告诉节点依然可以通过该通道来路由支付。

- **<!--fundamental-feecollection-strategies-for-ln-forwarding-nodes-->闪电网络路由节点的手续费收集基本策略**：开发者 ZmnSCPxj [总结了][zmnscpxj forwarding]三种闪电网络路由节点可以使用的手续费收集策略（也包括完全不收手续费）。然后 ZmnSCPxj 分析了不同策略的可能后果。这似乎跟他的 “节点可以用路由费率来提高支付成功率” 的提议有关，见[周报 #204][news204 fee signal]；那个提议在上周也收到了来自 Anthony Towns 的重要[附加性评论][towns fee signal]。

- **<!--onion-message-rate-limiting-->洋葱消息速率限制**：Bastien Teinturier [发帖][teinturier rate limit] 总结了一个他归功于 Rusty Russell 的关于限制[洋葱消息][topic onion messages]速率限制的想法。这个想法是让每个节点都为自己的每一个对等节点存储额外的 32 字节信息，让他们可以概率性地惩罚发送了太多流量的对等节点。提议建议的惩罚是让发送了太多流量的节点在接下来约 30 秒内速率限制减半。这是可以接受的，因为这种轻微的惩罚是偶尔对出错的节点实施的。这个提议也让一条消息的发起者知道哪个下游节点限制住了这条消息的传播速率（同样只是概率性的），给了他们使用另一条路径重发消息的机会。

  Olaoluwa Osuntokyn [建议][osuntokun onion pay] 重新考虑他之前提出的、按照流量收费来防止洋葱消息滥用的想法（见[周报 #190][news190 onion pay]）。截至本周报撰写之时，来自其他开发者的恢复表明，他们会先尝试这种轻量的速率限制方案，看看它能不能工作，然后再考虑为洋葱消息加入支付。

## 新版本和候选版本

*流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LDK 0.0.109][] 是这个闪电节点代码库的新版本，包含了 “重大变更” 一节将提到的 LDK 两项新功能。

## 重大的代码和文档变更

本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币升级提议（BIP）][bips repo] 和 [闪电网络技术基础（BOLT）][bolts repo]。

- [Bitcoin Core #24836][] 加入了一个只能在 regtest 模式下使用的 RPC 方法  ` submitpackage ` ，以帮助希望在未来使用[交易包转发][topic package relay]功能的 L2 协议和应用开发者测试他们的交易能否使用 Bitcoin Core 默认的设置。当前的设置可在[此处][packages doc]知晓。这个 RPC 方法也可以用来测试未来的增加和变更，比如交易包 RBF 规则提议。
- [Bitcoin Core #22558][] 添加了 [BIP371][] 对额外 [PSBT][topic psbt] 字段的支持，该字段用于 [taproot][topic taproot]（见[周报 #155][news155 psbt extensions]）。
- [Core Lightning #5281][] 增加支持，可以多次指定  ` log-file ` 的配置选项，从而写入多个日志文件。
- [LDK #1555][] 升级了其寻路代码，使其稍微偏向于使用那些宣布自己不会接受数额超过通道容量一半的交易的通道来路由支付。有人认为这可以通过限制第三方通过侦测（发送自己并不准备完成的 [HTLC][topic htlc]）所能获得的信息，来提供轻微的隐私性提升。如果一组数额高达通道容量的交易也可以通过一个通道，则侦测者就可以知道准确的通道余额（通过不断尝试不同组合的支付，直到一个组合完全被接受）。但是，如果可以发送的支付的数额限制在通道容量的一半，那么侦测者就更难确定交易是因为缺乏资金还是因为节点自己实施的限制（ ` max_htlc_in_flight_msat ` ）而被拒绝了。[BOLT2][] 的  ` max_htlc_in_flight_msat ` 限制不会被广播，所以 LDD 会使用每个通道被广播的 [BOLT7][]  ` htlc_maximum_msat ` 数值作为一个代理数值。
- [LDK #1550][] 增加了一个功能，用户可以维护一个节点黑名单，路由支付时将不再通过这些节点。
- [LND #6592][] 增加了一种新的钱包 RPC 方法 ` requiredreserve ` ，可以打印出钱包正在接收的 UTXO 如果有必要使用为[锚点输出][topic anchor outputs]追加手续费的话，最终能得到多少聪。一个额外的  ` --additionalChannels ` RPC 参数，可以接收一个整数，返回如果额外开启这么多的通道的话，钱包将剩余多少聪。
- [Rust Bitcoin #1024][] 加入额外的代码来帮助开发者解决 [ ` SIGHASH_SINGLE ` “bug”][shs1]。这个 “bug” 是说，当包含了  ` SIGHASH_SINGLE ` 签名的输入的索引号高于交易的所有输出的索引号时，比特币协议会预期需要签名一个  ` 1 ` 。
- [BTCPay Server #3709][] 加入了对通过 [LNURL 取款功能][LNURL withdraw]拉取支付的接收支持。
- [BDK #611][] 开始默认为新交易设置 nLockTime 字段到最新的区块高度，以[抵抗交易费狙击][topic fee sniping]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24836,22558,5281,1555,1550,1024,3709,611,1004,6592" %}
[ldk 0.0.109]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.109
[lnurl withdraw]: https://github.com/fiatjaf/lnurl-rfc/blob/luds/03.md
[todd subsidy]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020551.html
[hodler new codes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020605.html
[news194 silent payments]: /en/newsletters/2022/04/06/#delinked-reusable-addresses
[prauge bip47]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020549.html
[osuntokun splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003616.html
[zmnscpxj forwarding]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003617.html
[news204 fee signal]: /zh/newsletters/2022/06/15/#using-routing-fees-to-signal-liquidity
[towns fee signal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003624.html
[teinturier rate limit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003623.html
[osuntokun onion pay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003631.html
[news190 onion pay]: /en/newsletters/2022/03/09/#paying-for-onion-messages
[2022 stealth addresses]: https://gist.github.com/RobinLinus/4e7467abaf0a0f8a521d5b512dca4833
[demurrage]: https://en.wikipedia.org/wiki/Demurrage_%28currency%29
[shs1]: https://www.coinspect.com/capture-coins-challenge-1-sighashsingle/
[packages doc]: https://github.com/bitcoin/bitcoin/blob/09f32cffa6c3e8b2d77281a5983ffe8f482a5945/doc/policy/packages.md
[news155 psbt extensions]: /en/newsletters/2021/06/30/#psbt-extensions-for-taproot
