---
title: 'Bitcoin Optech Newsletter #146'
permalink: /zh/newsletters/2021/04/28/
name: 2021-04-28-newsletter-zh
slug: 2021-04-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍 LN 拼接的草案规范，宣布一场关于交易中继安全性的工作坊，宣布 libsecp256k1-zkp 加入 ECDSA 签名适配器支持，并给出修改 BIPs 流程的提案链接。此外还包括我们的固定栏目：Bitcoin Stack Exchange 热门问答摘要、软件发布与候选发布公告，以及热门比特币基础设施软件值得注意的代码与文档变更。

## 新闻

- **<!--draft-specification-for-ln-splicing-->****LN 拼接的草案规范：** Rusty Russell 向闪电网络规范仓库（“BOLTs”）提交了一个[拉取请求][bolts #863]，提出了为容纳[拼接][topic splicing]所需的协议更改。他还[在][russell splicing post] Lightning-Dev 邮件列表上发帖给出了该 PR 的链接。拼接允许把资金从链上输出转入现有支付通道，或从现有支付通道转到独立的链上输出，而通道参与者无需等待一段确认延迟就能花掉通道里的其他资金。这有助于钱包向用户隐藏管理余额的技术细节。例如，Alice 的钱包可以自动从同一个支付通道向 Bob 付款，链下或链上都行——链下是通过该通道走 LN，链上则是通过该通道做拼接退出（splice out，即取款）。

  Russell 曾在 2018 年[提出][russell old splice]过一份拼接的草案规范（参见 [Newsletter #17][news17 splice]），但这份新草案有一个优势：可以使用 C-Lightning 对[双向资助][topic dual funding]的实验性支持中所包含的交互式资金协议。

- **<!--call-for-topics-in-layer-crossing-workshop-->****跨层次工作坊的主题征集：** Antoine Riard [在][riard workshop] Bitcoin-Dev 和 Lightning-Dev 两个邮件列表上发帖，介绍了他计划主办的一场即将举行的 IRC 工作坊，讨论影响 LN 等二层协议的链上交易中继[挑战][riard zoology]。目标是在与会者之间建立技术共识，明确哪些提案尤其值得推进，以便开发者和审查者短期内能把精力集中在这些提案上。

  该帖子提出的议程包括[交易包中继][topic package relay]、手续费赞助（参见 [Newsletter #116][news116 sponsorship]）、从 [BIP125][] 的选择性手续费替换（[RBF][topic rbf]）转向完全 RBF、改善以链上为主的项目（如全节点）与以链下为主的项目（如 LN 节点）之间的安全响应协调，以及界定二层协议可以合理依赖哪些内存池与中继策略。Riard 还向打算参加的人征集更多主题，提交截止日期为 5 月 7 日。工作坊很可能在 6 月中旬举行。

- **<!--support-for-ecdsa-signature-adaptors-added-to-libsecp256k1-zkp-->****libsecp256k1-zkp 加入 ECDSA 签名适配器支持：** [签名适配器][topic adaptor signatures]最初是 Andrew Poelstra 针对比特币提出的，用的是基于 [schnorr][topic schnorr signatures] 的[多重签名][topic multisignature]。这样单个签名可以同时做最多三件事：(1) 证明其创建者能够访问某个私钥；(2) 证明其知道由另一方预先选定的加密密钥；(3) 向另一方揭示预设的加密密钥。这让仅凭一个签名就能完成目前需要用比特币脚本完成的许多事情，说明适配器签名可以用来构造“无脚本脚本”。

  要在 ECDSA 上做到同样的事并不容易。不过，Lloyd Fournier [建议][fournier otves]，如果把目标 #1（证明私钥）与目标 #2 和 #3（证明并揭示加密密钥，即适配器）分开，做起来会相对简单。这需要用到一个签名对象只作签名之用，另用一签名对象承载适配器，因此要用 `OP_CHECKMULTISIG`，也就不像之前那样完全“无脚本”了。这种拆分构造还需要附带一条[安全警告][ecdh warning]：在椭圆曲线迪菲–赫尔曼（ECDH）密钥交换和 ElGamal 加密中会复用其中部分密钥。除此之外，这种技术让签名适配器在今天就能完全用在比特币上，也是多个[谨慎日志合约（DLC）][topic dlc]项目一直在用的做法。

  2020 年 4 月，Jonas Nick 在一个草案 PR 中实现了对这些简化版 ECDSA 签名适配器的支持（参见 [Newsletter #92][news92 ecdsa adaptor]）。Jesse Posner [将其移植][libsecp256k1-zkp #117]并扩展到 libsecp256k1-zkp——这是 [libsecp256k1][] 的一个分支，支持更高级的密码协议。经过详细的审查之后，这个更新后的 PR 现已合并；审查过程中进行了多次讨论，对任何想深入理解签名适配器安全性的人可能都有参考价值。

- **<!--problems-with-the-bips-process-->****BIPs 流程中的问题：** 在 BIPs 仓库发生了一些风波（也许还有此前积压的不满）之后，邮件列表上开始了多次讨论：增设一名[新的 BIPs 编辑][dashjr alm]、用一个[机器人][corallo bot]来合并 BIPs 的 PR，或者干脆放弃[中心化的 BIPs 仓库][corallo ignore repo]。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-different-contexts-where-mtp-is-used-in-bitcoin-->**[MTP 在比特币中都用在哪些不同场合？]({{bse}}105522)
  David A. Harding 定义了过去中位时间（Median Time Past，MTP），并概述了 MTP 在以下几个方面的用途：

  1. 借助区块的 `nTime` 字段判断区块有效性，从而控制难度调整周期的起止时间。

  2. 确保时间只向前推进，简化 BIP9 中的[状态转换][bip9 state]。

  3. 消除个别矿工通过谎报当前时间，去确认锁定时间最远为未来两小时的交易的动机，这一点由 [BIP113][bip113 spec] 修正。

- **<!--can-taproot-be-used-to-commit-arbitrary-data-to-chain-without-any-additional-footprint-->**[Taproot 能否用来向链上提交任意数据而不增加任何额外足迹？]({{bse}}105346)
  Pieter Wuille 回答说，虽然在 [tapleaf][news46 complex spending] 里通过 `OP_RETURN` 提交数据是可行的，但像 [pay-to-contract][pay-to-contract se] 和 [sign-to-contract][sign-to-contract blog] 这样的技术目前已被 Liquid 和 [OpenTimestamps][opentimestamps] 采用，而且可能更高效。

- **<!--why-does-the-mined-block-differ-so-much-from-the-block-template-->**[为什么挖出的区块与区块模板相差这么大？]({{bse}}105694)
  用户 Andy 问，为什么区块 680175 与该区块被挖出的差不多同一时间他用 `getblocktemplate` RPC 得到的区块模板不一样。Andrew Chow 和 Murch 指出，版本字段不同是 [Asicboost][asicboost se] 造成的；而各节点的内存池相互独立、节点运行时长不同，则是区块中交易存在差异的原因。

- **<!--isn-t-bitcoin-s-hash-target-supposed-to-be-a-power-of-2-->**[比特币的哈希目标难道不该是 2 的幂吗？]({{bse}}105618)
  Andrew Chow 解释说，用“前导零”来解释难度目标的说法过于简化；chytrik 则举例说明了前导零个数相同的有效哈希和无效哈希。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.21.1rc1][Bitcoin Core 0.21.1] 是 Bitcoin Core 某个版本的候选发布，该版本包含所提议的 [taproot][topic taproot] 软分叉的激活逻辑。Taproot 使用 [schnorr 签名][topic schnorr signatures]，并允许使用 [tapscript][topic tapscript]。这三者分别由 BIPs [341][BIP341]、[340][BIP340] 和 [342][BIP342] 规定。此外，该版本还包含向 [BIP350][] 规定的 [bech32m][topic bech32] 地址付款的能力，尽管在主网上付给这类地址的比特币，在使用这类地址的软分叉（如 taproot）激活之前并不安全。该版本还包括错误修复和小幅改进。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

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

- [Libsecp256k1 #906][] 在使用常数时间算法时，把计算模逆元所需的迭代次数从 724 减少到 590；这种算法应当比可变时间算法更能抵御侧信道攻击。该算法的正确性借助 [Coq 证明助手][coq]做了验证，其中最严格的验证运行了大约 66 天。有关促成这一改进的算法进展，详见 [Newsletter #136][news136 safegcd]。

{% include references.md %}
{% include linkers/issues.md issues="21595,844,2356,906,863,192" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[webauthn/fido2]: https://en.wikipedia.org/wiki/FIDO2_Project
[u2f]: https://en.wikipedia.org/wiki/Universal_2nd_Factor
[russell splicing post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002999.html
[russell old splice]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[news17 splice]: /zh/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[riard workshop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/003002.html
[riard zoology]: https://github.com/ariard/L2-zoology
[news116 sponsorship]: /zh/newsletters/2020/09/23/#transaction-fee-sponsorship
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[ecdh warning]: https://github.com/ElementsProject/secp256k1-zkp/pull/117/commits/6955af5ca8930aa674e5fdbc4343e722b25e0ca8#diff-0bc5e1a03ce026e8fea9bfb91a5334cc545fbd7ba78ad83ae5489b52e4e48856R14-R27
[news92 ecdsa adaptor]: /zh/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[libsecp256k1-zkp #117]: https://github.com/ElementsProject/secp256k1-zkp/pull/117
[dashjr alm]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018835.html
[corallo bot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018849.html
[corallo ignore repo]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018859.html
[news136 safegcd]: /zh/newsletters/2021/02/17/#faster-signature-operations
[coq]: https://coq.inria.fr/
[news69 signcheck rpc]: /zh/newsletters/2019/10/23/#c-lightning-3150
[news110 signmessage rpc]: /zh/newsletters/2020/08/12/#eclair-1499
[bip9 state]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki#state-transitions
[bip113 spec]: https://github.com/bitcoin/bips/blob/master/bip-0113.mediawiki#specification
[news46 complex spending]: /zh/newsletters/2019/05/14/#使用-taproot-的复杂支出
[opentimestamps]: https://opentimestamps.org/
[sign-to-contract blog]: https://blog.eternitywall.com/2018/04/13/sign-to-contract/
[pay-to-contract se]: https://bitcoin.stackexchange.com/a/37208/87121
[asicboost se]: https://bitcoin.stackexchange.com/a/56518/5406
