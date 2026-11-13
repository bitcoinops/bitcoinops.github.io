---
title: 'Bitcoin Optech Newsletter #173'
permalink: /zh/newsletters/2021/11/03/
name: 2021-11-03-newsletter-zh
slug: 2021-11-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 总结了关于直接向矿工提交交易的讨论，链接到一套推荐给钱包实现的 taproot 测试向量，并包含我们关于为 taproot 做准备、新版本与候选发布，以及主流比特币基础设施项目值得注意的变更的常规栏目。

## 新闻

- **<!--submitting-transactions-directly-to-miners-->****向矿工直接提交交易：**
  Lisa Neigut 在 Bitcoin-Dev 邮件列表发起[讨论][neigut relay]，探讨是否废除 P2P 交易中继网络，让用户直接向矿工提交交易。这种运行方式设想的好处包括：降低带宽需求、改善隐私、消除[手续费替换（RBF）][topic rbf]与[子为父付（CPFP）][topic cpfp]的交易包规则中的复杂性，以及更好地沟通下一区块的费率。不过，有几个人并不认同：

  - **<!--bandwidth-requirements-->****带宽需求：** 多个回复指出，自 2016 年起使用的[紧凑区块中继][topic compact block relay]，让收到过某笔未确认交易的节点可以在该交易被打包进区块时跳过重复接收，只带来极小的带宽开销。未来提议的改进（例如 [erlay][topic erlay]）会进一步把未确认交易中继带来的带宽开销降到最低。

  - **<!--improved-privacy-->****改善隐私：** 尽管只把交易提交给矿工，可以让这些交易在确认前不被公众看到，但 Pieter Wuille [指出][wuille relay]，这样做同时也让矿工获得了对网络的特权视角。公开透明似乎更可取。

  - **<!--rbf-cpfp-and-package-complexity-->****RBF、CPFP 与交易包的复杂性：** 节点运营者确实比矿工对浪费资源的攻击更敏感，但 Gloria Zhao [指出][zhao relay]，这很大程度上只是程度上的差别。同样的攻击如果规模更大，也会影响到矿工，因此矿工依然需要节点已经在用的那些防御措施。

  - **<!--feerate-communication-->****费率沟通：** Bitcoin Core 目前估算费率的方法，是基于接收未确认交易、再看它们过多久才出现在已确认的区块中。这确实滞后于实时的费率信息，但 Pieter Wuille [建议][wuille relay]，可以改用其他此前已提出的方法来改进，例如让矿工广播弱区块——即工作量证明不足以被加入区块链的区块。弱区块比符合工作量证明的区块出现得更频繁，因此能提供更近期的信息，说明矿工当前正在处理哪些交易。

  除了一一反驳之外，讨论还提到了现有系统的若干优势：

  - **<!--miner-anonymity-->****矿工匿名性：** 如今有 5 万个或更多节点都在中继交易，矿工只要悄悄运行其中一个节点，就能轻松拿到所需的全部信息。化名开发者 ZmnSCPxj [提出][zmnscpxj relay]，如果强迫矿工维持一个持久身份——哪怕是在 Tor 这类匿名网络上的身份——反而会让人更容易识别出矿工，并胁迫他们审查某些交易。

  - **<!--censorship-resistance-->****抗审查性：** 如今任何人都可以用基本上任何一台电脑启动节点来接收中继的交易，接上矿机就能开始挖矿。Pieter Wuille [指出][wuille relay]，若改为直接向矿工提交交易，情况就不是这样了。新矿工必须公开宣传自己的节点才能收到交易，但目前并没有一种易于使用、又能同时抵御审查和[女巫攻击][sybil attacks]的做法。Wuille 特别提到：“让矿工在链上公布其[提交 URL] 的机制构想帮不上忙；那[将]取决于其他矿工不去审查这一公布。”

  - **<!--centralization-resistance-->****抗中心化：** Wuille 还指出：“额外增加一个提交途径的成本与复杂度，与[每个矿工]的算力无关，但收益与算力成正比。”这将让“大多数钱包干脆把[交易]提交给最大的几家矿池”变得“容易得多”，从而助长中心化。

- **<!--taproot-test-vectors-->****Taproot 测试向量集：**
  Pieter Wuille 向 Bitcoin-Dev 邮件列表[发布][wuille test]了一套他提议加入 [BIP341][] 中 [taproot][topic taproot] 规范的[测试向量][bips #1225]。这些向量重点关注“钱包实现，涵盖从密钥/脚本计算默克尔根、调整量与 scriptPubKey，密钥路径支出的 sigmsg/sighash/签名计算，以及脚本路径支出的控制区块计算”。

  对于正在开发实现、并希望在[激活后不久][p4tr waiting]就能用上 taproot 的开发者，这些测试向量应该特别有用。

## 准备 Taproot #20：激活时会发生什么？

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 taproot 做准备的[系列][series preparing for taproot]周更。*

{% include specials/taproot/zh/20-activation.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.20.2][] 是 Bitcoin Core 先前分支的维护版本，[包含][bcc0.20.2 rn]次要功能与漏洞修复。

- [C-Lightning 0.10.2rc2][] 是候选发布，[包含][decker tweet]对[不经济输出安全问题][news170 unec bug]的修复、更小的数据库体积，以及 `pay` 命令有效性的提升（详见下文*值得注意的变更*章节）。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #23306][] 让地址管理器支持每个 IP 地址对应多个端口。历史上，Bitcoin Core 一直使用固定端口 8333，并在发起自动出站连接时强烈偏好使用该端口的地址。虽然有人提出，这种行为或许有助于防止有人利用比特币节点对非比特币服务发起 DoS 攻击（办法是在比特币网络上散布那些服务的地址），但它同时也让人可以通过观察网络流量轻易识别出比特币节点。把每个（IP, 端口）组合都当成一个独立地址，为将来朝着更统一的地址处理方式演进打下了基础。

- [C-Lightning #4837][] 新增 `--max-dust-htlc-exposure-msat` 配置选项，限制金额低于粉尘限额的待处理 HTLC 的总余额。详见我们[之前的文章][news162 mdhemsat]对 Rust-Lightning 中同类选项的介绍。

- [Eclair #1982][] 引入一个新的日志文件，用于收集需要节点运营者采取行动的重要通知。随附的发布说明指出，节点运营者应当监控 `notifications.log`。

- [LND #5803][] 允许向同一张[原子化多路径支付（AMP）][topic multipath payments]发票发起多笔[自发支付][topic spontaneous payments]，无需付款用户为重复支付执行额外步骤。可以向同一张发票多次付款是 AMP 的一项特性，现有的[简化多路径支付][topic multipath payments]实现无法做到。

- [BTCPay Server #2897][] 新增对 [LNURL-Pay][] 支付方式的支持，同时也支持 [Lightning Address][news167 lightning addresses]。

{% include references.md %}
{% include linkers/issues.md issues="23306,4837,1982,5803,2897,1225" %}
[c-lightning 0.10.2rc2]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2rc2
[neigut relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019572.html
[wuille relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019578.html
[zhao relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019579.html
[zmnscpxj relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019573.html
[sybil attacks]: https://en.wikipedia.org/wiki/Sybil_attack
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[news170 unec bug]: /zh/newsletters/2021/10/13/#ln-spend-to-fees-cve
[bitcoin core 0.20.2]: https://bitcoincore.org/bin/bitcoin-core-0.20.2/
[bcc0.20.2 rn]: https://bitcoincore.org/en/releases/0.20.2/
[wuille test]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019587.html
[p4tr waiting]: /zh/preparing-for-taproot/#我们为什么要等待
[LNURL-Pay]: https://github.com/fiatjaf/lnurl-rfc/blob/luds/06.md
[news167 lightning addresses]: /zh/newsletters/2021/09/22/#lightning-address-identifiers-announced
[news162 mdhemsat]: /zh/newsletters/2021/08/18/#rust-lightning-1009
[series preparing for taproot]: /zh/preparing-for-taproot/
