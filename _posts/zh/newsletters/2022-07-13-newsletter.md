---
title: 'Bitcoin Optech Newsletter #208'
permalink: /zh/newsletters/2022/07/13/
name: 2022-07-13-newsletter-zh
slug: 2022-07-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了有关 schnorr 签名减半聚合的讨论、可用于无法可靠地使用 x-only 公钥的协议的变通方法、允许刻意放慢闪电网络支付转发。此外还有我们的常规栏目：比特币核心 PR 审查俱乐部会议的总结、软件的新版本和候选版本总结、热门的比特币基础设施软件的重大变更。

## 新闻

- **BIP340 签名的减半聚合：** Jonas Nick 在 Bitcoin-Dev 邮件列表中[发表][nick agg]了一个关于比特币 [schnorr 签名][topic schnorr signatures]的减半聚合的 [BIP 草案][bip-agg]并发表了一个[博客文章][blog agg]。博文中提到，该提案“允许将多个 schnorr 签名聚合成单个签名，其长度约为单个签名总和的一半。重要的是，该方案是非交互式的，这意味着一组签名可以由第三方进行减半聚合，而无需签名者参与。”

    一个[单独的文档][cia doc]提供了减半聚合如何使比特币和闪电网络节点的运营商受益的示例，以及在为共识协议添加减半聚合的软分叉设计中需要考虑的几个问题。

- **X-only 变通解决方法：** 比特币公钥是二维图上的点，由 *x* 坐标和 *y* 坐标的交点标记。对于任何给定的 *x* 坐标，只有两个有效的 *y* 坐标并且可以从 *x* 值计算出来。这个性质可支持对 [taproot][topic taproot] 的设计进行优化，以要求与 [BIP340][] 样式的 schnorr 签名一起使用的所有公钥仅使用这些 *y* 坐标中的某个坐标，从而允许交易中包含的任何公钥完全省略包括 *y* 点，与原始的主根设计相比，每个签名节省一个 vbyte。

    当时，这种技术（称为 *x-only 公钥*）被认为是一种无需明显权衡的优化，但后来对 OP_TAPLEAF_UPDATE_VERIFY ([TLUV][news166 tluv]) 的设计工作表明，x-only 公钥需要计算限制提议或在区块链或 UTXO 集中存储额外数据。该问题也可能影响公钥的其他高级用途。

    本周，Tim Ruffing 在 Bitcoin-Dev 邮件列表中[发表][ruffing xonly]了一个可能的变通解决方法，只需要签名者进行少量额外计算——即使是资源受限的硬件签名设备也可能执行的计算量，而不会让用户等待太久。

- **<!--allowing-deliberately-slow-ln-payment-forwarding-->允许刻意放慢闪电网络支付转发：**在对有关递归/嵌套 [MuSig2][topic musig] 的讨论主题帖的回复中（参见 [Newsletter #204][news204 rmusig]）以及使用它的节点在路由付款时会增加的延迟，开发人员 Peter Todd 在 Lightning-Dev 邮件列表上[询问][todd delay]是否“值得让人们选择更慢地进行支付以保护隐私？”例如，如果 Alice 和 Bob 大约在同一时间通过 Carol 的转发节点向 Dan 的转发节点发送慢速转发的付款，那么 Carol 将能够同时转发两笔付款，从而减少第三方可以通过[余额探测][topic payment probes]、网络活动监控或其他技术来发现参与者的隐私泄露信息。开发者 Matt Corallo [同意][corallo delay]这是一个有趣的想法。

## 比特币核心 PR 审核俱乐部

*在这个每月一次的栏目中，我们会总结最近的一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club]会议，提炼出一些重要的问题和答案。点击下方的问题描述，就可以看到来自会议的答案。*

[addnode 手动建立仅中继区块的连接][review club 24170] 是 Martin Zumsande 的 PR，允许用户手动创建与仅中继区块（不是交易或节点地址）的节点的连接。此选项旨在帮助防止[日蚀攻击][topic eclipse attacks]，特别是对于在[隐私网络][topic anonymity networks]上运行的节点，例如 Tor。

{% include functions/details-list.md

  q0="<!--why-could-peers-that-are-only-active-on-privacy-networks-such-as-tor-be-more-susceptible-to-eclipse-attacks-compared-to-clearnet-only-peers-->为什么只在隐私网络（如 Tor）上活跃的节点比只在 clearnet 的节点更容易受到日蚀攻击？"
  a0="clearnet 上的节点可以使用 IP 地址的网络组等信息来尝试选择“不同”的节点。而反过来，很难判断一组洋葱地址是否都属于单个攻击者，因此更难在 Tor 上这样做。此外，虽然在 Tor 上运行的比特币节点集相当大，但一个在隐私网络上使用 -onlynet、有很少比特币节点连接的节点很容易被日蚀攻击，因为这些节点的选择并不多。" 
  a0link="https://bitcoincore.reviews/24170#l-42"

  q1="<!--what-is-the-difference-between-the-onetry-and-add-modes-in-the-addnode-rpc-->`addnode` RPC 中的 `onetry` 和 `add` 模式有什么区别？"
  a1="顾名思义，`onetry` 只尝试调用一次 `CConnman::OpenNetworkConnection()`，如果失败则不添加节点。反之， `addnode` 模式会让节点反复尝试连接节点直到成功。"
  a1link="https://bitcoincore.reviews/24170#l-72"

  q2="<!--the-pr-introduces-a-new-connection-type-manual-block-relay-that-combines-the-properties-of-manual-and-block-relay-peers-what-are-the-advantages-and-disadvantages-of-having-an-extra-connection-type-as-opposed-to-combining-the-logic-of-the-existing-ones-->该 PR 引入了一个新的连接类型 `MANUAL_BLOCK_RELAY`，组合了 `MANUAL` 和 `BLOCK_RELAY` 节点的属性。相比于组合现有连接类型的逻辑，拥有一个额外的连接类型有哪些优缺点？"
  a2="由于 p2p 连接的属性很多，但类型很少，与会者一致认为使用扁平化、枚举的连接类型更简单。他们还指出，使用功能和权限的组合来描述连接，可能会导致连接类型的组合爆炸和复杂的逻辑，其中会包括一些可能没有意义的组合。"
  a2link="https://bitcoincore.reviews/24170#l-97"

  q3="<!--what-types-of-attacks-that-this-pr-tries-to-mitigate-are-fixed-by-bip324-which-ones-aren-t-->该 PR 试图缓解的攻击中，哪些类型被 BIP324 修复？而哪些没有？"
  a3="[BIP324][] 通过添加伺机加密来防止窃听与网络端监视来增强隐私，但它并非旨在防止日蚀攻击。即使有一些身份验证机制，它也无助于识别节点是否诚实或识别出与其他节点不同的实体。"
  a3link="https://bitcoincore.reviews/24170#l-110"

%}

## 软件的新版本和候选版本

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到最新版本或帮助测试候选版本。*

- [BTCPay Server 1.6.1][] 是这个流行的自托管支付处理器解决方案的 1.6 分支版本，其中包括多个新功能和错误修复。

## 重大代码及文档变更

*本周内，[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 出现的重大变更。*

- [Bitcoin Core #25353][] 引入了之前在 [Newsletter #205][news205 fullrbf] 中描述的 `mempoolfullrbf` 配置选项。此选项使节点运营商能够将其节点的[交易替换行为][topic rbf]从默认的[选用 RBF (BIP125)][BIP125]切换为完全 RBF——允许在节点的内存池中替换交易而无需强制信号要求，但遵循与选用 RBF 相同的经济规则。

- [Bitcoin Core #25454][] 避免发送到同一个节点途中的多个 getheaders 消息。通过在发布新消息之前等待最多两分钟来响应先前的 getheaders 消息来减少带宽使用。

- [Core Lightning #5239][] 使用所有接收到的通知来更新 CLN 的支付中继网络内部拓扑图、但只继续中继满足 CLN gossip 速率要求的通知。通过该方法来改进 gossip 处理代码。以前，CLN 根据其速率限制丢弃传入的消息。当网络节点的速率限制较宽松（或没有）时，该更改可以让 CLN 节点更好地了解网络，而不会影响 CLN 向其对等节点发送的数据量。

- [Core Lightning #5275][] 增加了对[开启零配置通道][topic zero-conf channels]和相关短通道标识符 (SCID) 别名的支持（参见 [Newsletter #203][news203 scid]）。这包括了对 `listpeers`、`fundchannel` 和 `multifundchannel` RPC 的更新。

- [LND #5955][] 与上述合并一样，也添加了对零配置通道打开和相关 SCID 别名的支持。

- [LDK #1567][] 添加了对基本[支付探测][topic payment probes] API 的支持，应用程序可以使用该 API 来测试如果在近期发送付款，哪些支付路线更有可能成功。它包括了对构建 [HTLC][topic htlc] 方式的支持。这种方式允许发送节点在它们返回时将它们与实际支付 HTLC 分开，而不存储任何额外的状态。

- [LDK #1589][]增加了一个[安全策略][ldk security policy]，可用于安全地向 LDK 维护者报告安全漏洞。

- [BTCPay Server #3922][] 为*托管账户*添加基本的 UI。托管账户是绑定到 BTCPay 实例的账户，其中资金由托管人管理，例如比特币交易所（而不是由本地用户控制自己的私钥)。 BTCPay 实例可能同时拥有本地钱包和托管账户，这可以方便地管理这些账户间的资金，例如允许商家私下安全地接收资金到他们的钱包，但也可以快速将金额转移到要出售的交易所。

- [BDK #634][] 添加了一个 *get_block_hash* 方法，该方法返回特定高度上最佳区块链的区块头哈希。

- [BDK #614][] 避免创建从未成熟的 coinbase 输出支付的交易。未成熟的 coinbase 输出是少于 100 个确认（建立在该区块之上的区块）的矿工的 coinbase 交易输出。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25353,25454,5239,5275,5955,1567,1589,3922,634,614" %}
[btcpay server 1.6.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.6.1
[ldk security policy]: https://github.com/TheBlueMatt/rust-lightning/blob/92919c8f375311e4f9a596d64a026a172839dd0f/SECURITY.md
[nick agg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020662.html
[bip-agg]: https://github.com/ElementsProject/cross-input-aggregation/blob/master/half-aggregation.mediawiki
[blog agg]: https://blog.blockstream.com/half-aggregation-of-bip-340-signatures/
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[ruffing xonly]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020663.html
[news204 rmusig]: /en/newsletters/2022/06/15/#recursive-musig2
[todd delay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003621.html
[corallo delay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003641.html
[news203 scid]: /en/newsletters/2022/06/08/#bolts-910
[cia doc]: https://github.com/ElementsProject/cross-input-aggregation
[news205 fullrbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[review club 24170]: https://bitcoincore.reviews/24170
[BIP324]: https://gist.github.com/dhruv/5b1275751bc98f3b64bcafce7876b489
