---
title: 'Bitcoin Optech Newsletter #146'
permalink: /zh/newsletters/2021/04/28/
name: 2021-04-28-newsletter-zh
slug: 2021-04-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了 LN 拼接的草案规范，宣布了关于交易中继安全性的研讨会，宣布向 libsecp256k1-zkp 添加了 ECDSA 签名适配器支持，并链接了修改 BIPs 过程的提案。此外，还包括我们的定期栏目，概述了来自 Bitcoin Stack Exchange 的热门问答摘要、软件发布与候选发布的公告，以及流行比特币基础设施软件的值得注意的更改描述。

## 新闻

- **<!--draft-specification-for-ln-splicing-->****LN 拼接的草案规范：** Rusty Russell 开启了 [BOLTs #863][bolts #863] 的[拉取请求][bolts #863]，向 Lightning Specifications 仓库（“BOLTs”）提出了容纳[拼接][topic splicing]所需的协议更改。他还[在][russell splicing post] Lightning-Dev 邮件列表上发布了该 PR 的链接。拼接将允许将资金从链上输出转移到现有支付通道，或从现有支付通道转移到独立的链上输出，而无需通道参与者等待确认延迟以花费通道的其他资金。这有助于钱包向用户隐藏管理余额的技术细节。例如，Alice 的钱包可以自动通过相同的支付通道向 Bob 进行链下或链上支付——通过该支付通道使用 LN 进行链下支付，或通过该支付通道的 splice out（取款）进行链上支付。

  Russell 之前在 2018 年 [提出][russell old splice]拼接的草案规范（参见 [Newsletter #17][news17 splice]），但这个新的草案有一个优势，即能够使用作为 C-Lightning 对[双向融资][topic dual funding]实验性支持一部分的交互式资金协议。

- **<!--call-for-topics-in-layer-crossing-workshop-->****跨层次研讨会的主题征集：** Antoine Riard [在][riard workshop] Bitcoin-Dev 和 Lightning-Dev 邮件列表上发布了关于他计划主办的即将举行的基于 IRC 的研讨会的消息，旨在讨论影响 LN 等二层协议的链上交易中继的[挑战][riard zoology]。目标是与会者之间建立技术共识，确定哪些提案尤其值得深入研究，以便开发者和审查者能够在短期内专注于这些提案。

  该帖子提出的议程包括[包中继][topic package relay]、手续费赞助（参见 [Newsletter #116][news116 sponsorship]）、从 [BIP125][] 的选择性 Replace By Fee ([RBF][topic rbf]) 转向完全 RBF、改善主要是链上项目（如全节点）与主要是链下项目（如 LN 节点）之间的安全响应协调，以及定义二层协议可以合理依赖的 mempool 和中继策略。Riard 还邀请计划参加的人提出额外的主题建议，提交截止日期为 5 月 7 日。研讨会可能在六月中旬举行。

- **<!--support-for-ecdsa-signature-adaptors-added-to-libsecp256k1-zkp-->****向 libsecp256k1-zkp 添加 ECDSA 签名适配器支持：** [签名适配器][topic adaptor signatures]最初由 Andrew Poelstra 在比特币中使用基于 [schnorr][topic schnorr signatures] 的[多重签名][topic multisignature]描述。这允许单个签名同时执行最多三件事：(1) 证明其创建者拥有某个私钥的访问权限，(2) 证明知道由另一方预先选择的加密密钥，(3) 向另一方揭示预先选择的加密密钥。这允许仅通过签名就能执行我们当前用比特币脚本做的许多事情，表明适配器签名可以用来创建“无脚本脚本”。

  在 ECDSA 上实现相同的功能并不容易。然而，Lloyd Fournier [建议][fournier otves]如果我们将目标 #1（私钥证明）与目标 #2 和 #3（证明和揭示加密密钥，即适配器）分离，完成这项工作将相对简单。这需要使用一个签名对象仅作为签名，另一个签名对象用于适配器，因此它使用 `OP_CHECKMULTISIG`，不如之前的无脚本脚本那么纯粹。分离构造还需要与复合椭圆曲线迪菲赫尔曼（ECDH）密钥交换和 ElGamal 加密相关的[安全警告][ecdh warning]，涉及某些相关密钥的重用。除此之外，这种技术使得签名适配器在今天的比特币上完全可用，并且是各种 [DLC][topic dlc] 项目一直在使用的。

  2020 年 4 月，Jonas Nick 在一个草案 PR 中实现了对这些简化的 ECDSA 签名适配器的支持（参见 [Newsletter #92][news92 ecdsa adaptor]）。Jesse Posner [移植][libsecp256k1-zkp #117]并扩展了该 PR 到 libsecp256k1-zkp，这是一个支持更高级加密协议的 [libsecp256k1][] 的分支。经过详细的审查过程，该更新的 PR 现已合并，过程中涉及了几次可能对任何寻求更好理解签名适配器安全性的人员有兴趣的对话。

- **<!--problems-with-the-bips-process-->****BIPs 过程中的问题：** 在 BIPs 仓库发生一些争议（也许还有一些之前积压的挫折感）之后，邮件列表上发起了几次讨论，内容涉及添加一个[新的 BIPs 编辑][dashjr alm]、使用一个[机器人][corallo bot]来合并 BIPs PR，或完全放弃[集中式 BIPs 仓库][corallo ignore repo]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地点之一——或者当我们有一些空闲时间帮助好奇或困惑的用户时。在这个每月栏目中，我们重点介绍自上次更新以来发布的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-different-contexts-where-mtp-is-used-in-bitcoin-->**[MTP 在比特币中的不同上下文是什么？]({{bse}}105522)
  David A. Harding 定义了中位时间过去 (MTP) 并概述了 MTP 在以下方面的使用：

  1. 使用其 `nTime` 字段确定区块的有效性，控制难度调整周期的时间。

  2. 确保时间只向前移动，简化 BIP9 中的[状态转换][bip9 state]。

  3. 通过虚报当前时间，消除个别矿工确认具有最多两小时未来锁定时间的交易的动机，如 [BIP113][bip113 spec] 中固定的。

- **<!--can-taproot-be-used-to-commit-arbitrary-data-to-chain-without-any-additional-footprint-->**[Taproot 能否用于在链上提交任意数据而不留下任何额外的痕迹？]({{bse}}105346)
  Pieter Wuille 通过指出，虽然可以通过 [tapleaf][news46 complex spending] 中的 `OP_RETURN` 提交数据，但像 [pay-to-contract][pay-to-contract se] 和 [sign-to-contract][sign-to-contract blog] 这样的技术目前被 Liquid 和 [OpenTimestamps][opentimestamps] 使用，并且可能更高效。

- **<!--why-does-the-mined-block-differ-so-much-from-the-block-template-->**[为什么挖出的区块与区块模板相差这么大？]({{bse}}105694)
  用户 Andy 问为什么区块 680175 与他在同一时间通过 `getblocktemplate` RPC 输出的区块不同。Andrew Chow 和 Murch 指出 [Asicboost][asicboost se] 是版本字段不同的原因，而节点独立的 mempools 和节点正常运行时间是区块交易差异的考虑因素。

- **<!--isn-t-bitcoin-s-hash-target-supposed-to-be-a-power-of-2-->**[比特币的哈希目标难道不是应该是 2 的幂吗？]({{bse}}105618)
  Andrew Chow 解释了难度目标的“前导零”解释是一个过于简化的说法，chytrik 举例说明了具有相同前导零数量的有效和无效哈希。

## 发布与候选发布

*流行的比特币基础设施项目的新版本发布与候选发布。请考虑升级到新版本或协助测试候选发布。*

- [Bitcoin Core 0.21.1rc1][Bitcoin Core 0.21.1] 是 Bitcoin Core 版本的候选发布，包含了提议的 [taproot][topic taproot] 软分叉的激活逻辑。Taproot 使用 [schnorr 签名][topic schnorr signatures]并允许使用 [tapscript][topic tapscript]。这些分别由 BIPs [341][BIP341]、[340][BIP340] 和 [342][BIP342] 规定。此外，还包括使用 [BIP350][] 规定的 [bech32m][topic bech32] 地址支付的能力，尽管在主网上向这些地址支付的比特币在使用这些地址的软分叉（如 taproot）激活之前不会是安全的。该版本还包括错误修复和小幅改进。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中发生的值得注意的更改。*

- [Bitcoin Core #21595][] 为 `bitcoin-cli` 可执行文件添加了一个新的 `addrinfo` 命令。运行 `bitcoin-cli -addrinfo` 会返回节点已知的潜在对等方的网络地址数量，按网络类型划分。示例输出：

  ```
  $ bitcoin-cli -addrinfo
  {
    "addresses_known": {
      "ipv4": 14406,
      "ipv6": 2511,
      "torv2": 5563,
      "torv3": 2842,
      "i2p": 8,
      "total": 25330
    }
  }
  ```

- [Rust-Lightning #844][] 添加了消息签名、签名验证以及使用与 [LND][LND #192]、[C-Lightning][news69 signcheck rpc] 和 [Eclair][news110 signmessage rpc] 兼容的方案进行公钥恢复的支持。

- [BTCPay Server #2356][] 添加了使用 [WebAuthN/FIDO2][] 协议的多因素认证支持。BTCPay 中现有的使用 [U2F][] 的多因素认证仍然有效。

- [Libsecp256k1 #906][] 将计算模反元素所需的迭代次数从 724 减少到 590，使用了一种常数时间算法，该算法比可变时间算法更能抵抗侧信道攻击。该算法的正确性通过 [Coq 证明助手][coq]进行了检查，最严格的验证大约需要 66 天的运行时间。有关导致这一改进的算法进展的更多信息，请参见 [Newsletter #136][news136 safegcd]。

{% include references.md %}
{% include linkers/issues.md issues="21595,844,2356,906,863,192" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[webauthn/fido2]: https://en.wikipedia.org/wiki/FIDO2_Project
[u2f]: https://en.wikipedia.org/wiki/Universal_2nd_Factor
[russell splicing post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002999.html
[russell old splice]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[news17 splice]: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[riard workshop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/003002.html
[riard zoology]: https://github.com/ariard/L2-zoology
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[ecdh warning]: https://github.com/ElementsProject/secp256k1-zkp/pull/117/commits/6955af5ca8930aa674e5fdbc4343e722b25e0ca8#diff-0bc5e1a03ce026e8fea9bfb91a5334cc545fbd7ba78ad83ae5489b52e4e48856R14-R27
[news92 ecdsa adaptor]: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[libsecp256k1-zkp #117]: https://github.com/ElementsProject/secp256k1-zkp/pull/117
[dashjr alm]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018835.html
[corallo bot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018849.html
[corallo ignore repo]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018859.html
[news136 safegcd]: /en/newsletters/2021/02/17/#faster-signature-operations
[coq]: https://coq.inria.fr/
[news69 signcheck rpc]: /en/newsletters/2019/10/23/#c-lightning-3150
[news110 signmessage rpc]: /en/newsletters/2020/08/12/#eclair-1499
[bip9 state]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki#state-transitions
[bip113 spec]: https://github.com/bitcoin/bips/blob/master/bip-0113.mediawiki#specification
[news46 complex spending]: /en/newsletters/2019/05/14/#complex-spending-with-taproot
[opentimestamps]: https://opentimestamps.org/
[sign-to-contract blog]: https://blog.eternitywall.com/2018/04/13/sign-to-contract/
[pay-to-contract se]: https://bitcoin.stackexchange.com/a/37208/87121
[asicboost se]: https://bitcoin.stackexchange.com/a/56518/5406
