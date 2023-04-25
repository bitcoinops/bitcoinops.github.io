---
title: 'Bitcoin Optech Newsletter #245'
permalink: /zh/newsletters/2023/04/05/
name: 2023-04-05-newsletter-zh
slug: 2023-04-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了瞭望塔问责证明的想法，并包括我们的常规部分，其中包含新版本和候选版本的公告以及对流行的比特币基础设施软件的显着变化的描述。

## 新闻

- **<!--watchtower-accountability-proofs-->瞭望塔问责证明：** Sergi Delgado Segura 上周在 Lightning-Dev 邮件列表中[发布][segura watchtowers post]了一个关于让[瞭望塔][topic watchtowers]对未能响应他们本应检测到的协议违规行为负责的帖子。例如，Alice 向瞭望塔提供用于检测和响应旧闪电网络通道状态确认的数据；后来，该状态得到确认，但瞭望塔没有回应。Alice 希望能够通过公开证明瞭望塔操作员未能做出适当回应来追究其责任。

    基本原则是瞭望塔拥有众所周知的公钥，并使用相应的私钥为其接受的任何违规检测数据生成签名。然后，Alice 可以在未解决的违规行为后发布数据和签名，以证明瞭望塔没有尽责。然而，Delgado 指出，实际的问责制并不是那么简单：

    - *<!--data-storage-requirements-->数据存储要求：* 上述机制要求 Alice 每次向瞭望塔发送新的违规检测数据时都存储一个额外的签名。这对于活跃的闪电网络通道来说可能过于频繁。

    - *<!--no-deletion-capability-->无删除能力：* 上述机制可能需要瞭望塔永久存储违规检测数据。瞭望塔可能只想在有限的时间内存储数据，例如，他们可能会接受特定期限的付款。

    Delgado 建议基于密码学的累加器为这两个问题提供实用的解决方案。累加器允许紧凑地证明一个特定元素是一个大元素集合中的成员，并且还允许在不重建整个数据结构的情况下向集合添加新元素。一些累加器允许从集合中删除元素而无需重建。在 [gist][segura watchtowers gist] 中，Delgado 概述了几种值得考虑的不同累加器的构造。{% assign timestamp="0:36" %}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.16.0-beta][] 是这个流行的闪电网络实现的新主要版本的 beta 版。它的[发行说明][lnd rn]提到了该版本的许多新功能、错误修复和性能改进。{% assign timestamp="21:37" %}

- [BDK 1.0.0-alpha.0][] 是 [Newsletter #243][news243 bdk] 中描述的 BDK 主要变更的测试版本，并鼓励下游项目的开发人员开始集成测试。{% assign timestamp="22:06" %}

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Core Lightning #5967][] 添加了一个 `listclosedchannels` RPC，它提供有关节点关闭通道的数据，包括通道关闭的原因。目前也保留了老的对等节点的相关信息。{% assign timestamp="22:59" %}

- [Eclair #2566][] 添加了对接受要约（offer）的支持。要约必须由一个插件所注册。该插件提供一个处理器来响应与要约相关的发票请求，并接受或拒绝对该发票的付款。 Eclair 确保请求和支付满足协议要求——处理器只需要决定是否可以提供所购买的物品或服务。这允许编码要约的代码变得任意复杂，而不会影响 Eclair 的内部逻辑。 {% assign timestamp="23:43" %}

- [LDK #2062][] 实现 [BOLTs #1031][]（参见 [Newsletter #226][news226 bolts1031]）、[#1032][bolts #1032]（参见 [Newsletter #225][news225 bolts1032]），和 [#1040][bolts #1040]，允许付款的最终接收者（[HTLC][topic htlc]）接受比他们所要求的更多的金额，和比他们要求的到期时间更长的时间的支付。这使得转发节点更难微调支付参数来判断下一跳是否是接收方。合并后的 PR 还允许支付者在使用[简化版的多路径支付][topic multipath payments]时向接收者支付的金额略高于请求的金额。这种方式可带来上述益处，并且它在所选择的支付路径使用具有最小可路由量的通道的情况下也可能是必需的。例如，Alice 想将 900 聪的总金额分成两部分，但她选择的两条路径都需要 500 聪的最低数量。在此规范的变更下，她现在可以发送两笔 500 聪的付款，即多付总共 100 聪以使用她的首选路线。{% assign timestamp="24:57" %}

- [LDK #2125][] 添加辅助函数来确定发票到期前的时间。{% assign timestamp="27:18" %}

- [BTCPay Server #4826][] 允许服务钩子创建和检索 [LNURL][] 发票。这样做是为了向 BTCPay 服务器的闪电网络地址功能添加对 NIP-57 打赏的支持。{% assign timestamp="27:56" %}

- [BTCPay Server #4782][] 在每次付款的收据页面上添加[付款证明][topic proof of payment]。对于链上支付，证明是交易 ID；对于闪电网络支付，证明是 [HTLC][topic htlc] 的原像。{% assign timestamp="29:51" %}

- [BTCPay Server #4799][] 添加了以 [BIP329][] 指定格式为交易导出[钱包标签][topic wallet labels]的能力。未来的 PR 可能会增加对导出其他钱包数据的支持，例如地址标签。{% assign timestamp="30:15" %}

- [BOLTs #765][] 将[路由盲化][topic rv routing]添加到闪电网络规范中。我们在 [Newsletter #85][news85 blinding] 中首次描述的路由盲化允许节点接收付款或[洋葱消息][topic onion messages]，而无需向支付者或发送者透露其节点的标识符。其他可直接识别的信息也无需透露。路由盲化的工作原理是让接收者选择最后几跳来转发支付或消息。这些步骤像常规转发信息一样经过洋葱加密，并提供给支付者或发送者。支付者或发送者使用它们向第一跳发送付款。该跳将启动对下一跳解密的过程，将付款转发给它，并让它解密后续跳等，直到接收者接受付款而无需将其节点透露给支付者或发送者。 {% assign timestamp="31:37" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="5967,2566,2062,1031,1032,1040,2125,4826,4782,4799,765" %}
[lnd v0.16.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[segura watchtowers post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003892.html
[segura watchtowers gist]: https://gist.github.com/sr-gi/f91f007fc8d871ea96ead9b27feec3d5
[news85 blinding]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news226 bolts1031]: /zh/newsletters/2022/11/16/#bolts-1031
[news225 bolts1032]: /zh/newsletters/2022/11/09/#bolts-1032
[news243 bdk]: /zh/newsletters/2023/03/22/#bdk-793
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.16.0.md
[lnurl]: https://github.com/lnurl/luds
