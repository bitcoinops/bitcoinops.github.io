---
title: 'Bitcoin Optech Newsletter #61'
permalink: /zh/newsletters/2019/08/28/
name: 2019-08-28-newsletter-zh
slug: 2019-08-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 就 miniscript 语言征求反馈，刊出 bech32 发送支持系列的最后一篇，收录 Bitcoin Stack Exchange 上的热门问答，并介绍流行比特币基础设施项目的几处值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--evaluate-miniscript-->****评估 miniscript：** 我们鼓励钱包开发者评估这项[提案中的语言][miniscript code]，它可以让钱包适应新的脚本模板，而无需为每个新模板改动底层钱包代码。详情请见*新闻*部分。

## 新闻

- **<!--miniscript-request-for-comments-->****Miniscript 征求反馈：** 该语言的开发者已[请求][miniscript email]社区对其初步设计提供反馈。[Miniscript][] 能让软件自动分析脚本，包括判断需要哪些数据才能构造出满足脚本的见证——有了这样的见证，受该脚本保护的比特币就能被花掉。有了 miniscript 告诉钱包该做什么，钱包开发者从一个脚本模板切换到另一个脚本模板时就不必再写新代码。

  例如，如今一个钱包开发者如果想从 2-of-3 多重签名切换到带有 1-of-2 时间锁逃生条款的 2-of-2 多重签名，可能需要为新情况编写和测试一个新函数。而有了 miniscript，只要钱包知道如何为指定密钥生成签名、如何处理时间锁，miniscript 就能引导钱包走遍各种可能的路径去解开该脚本。不需要写新的支出代码。

  对于需要来自多个钱包的签名或其他数据的脚本，miniscript 可以引导钱包尽可能创建出它能创建的见证数据，以便把这些数据打包进一个部分签名比特币交易（PSBT）。其他钱包可以各自创建自己的 PSBT，所有这些 PSBT 都交给 PSBT 终结器（finalizer）。如果该终结器支持 miniscript，它就能把所有传入 PSBT 中的见证数据整理成一个完整的见证，使这笔支出交易有效。

  Miniscript 支持的脚本种类很多，这种自动化让钱包在选择脚本时可以灵活得多，甚至可能让用户指定自己的脚本。为了支持这种灵活性，miniscript 可以用一种易写的策略语言来编写。策略是可组合的，可以把任何一个有效的子表达式替换成另一个有效的子表达式（前提是不超出 Bitcoin 系统设定的某些限制）。例如，假设 Alice 有一个涉及热钱包、硬件钱包和备用冷钱包的 2-of-3 策略：

  ```
  thresh(2, pk(A_hot), pk(A_hard), pk(A_cold))
  ```

  后来 Alice 被要求创建一份忠诚债券（fidelity bond），把她的一部分比特币时间锁定 26,000 个区块。该策略的通用形式是：

  ```
  and(pk(KEY), older(26000))
  ```

  Alice 可以简单地用她的特定策略替换 `pk(KEY)`：

  ```
  and(thresh(2, pk(A_hot), pk(A_hard), pk(A_cold)), older(26000))
  ```

  Miniscript 编译器可以把该策略转换成高效的 P2WSH 脚本，并确认它不会违反比特币的任何共识规则，也不违反 Bitcoin Core 的交易中继与挖矿策略。它还能告诉 Alice 与该脚本相关的各种大小，方便她估算这笔交易的手续费开销。

  如果比特币协议日后加入对脚本的改动，例如 [taproot][bip-taproot]，很可能会推出支持这些协议新增内容的新版 miniscript，让钱包和用户即使使用复杂脚本也能轻松升级。

  欲了解更多信息，请参见我们的 [miniscript 主题页面][miniscript]、[C++ miniscript 实现][miniscript code]、[Rust 实现][miniscript rust]、[Bitcoin Core 集成代码][core miniscript]，以及 Pieter Wuille 关于早期版本 miniscript 的演讲（[视频][miniscript vid]、[文字记录][miniscript xs]、[Optech 摘要][miniscript summary]）。

## Bech32 发送支持

*这是共 24 周的[系列][bech32 series]中的最后一篇，目的是让你支付的对象也能获得隔离见证的全部好处。*

{% include specials/bech32/zh/24-conclusion.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-key-differences-between-regtest-and-the-proposed-signet-->**[regtest 和提议中的 signet 之间有哪些关键区别？]({{bse}}89640) Pieter Wuille 和 Andrew Chow 解释说，regtest 适合做本地自动化集成测试，而 signet 更接近测试网（testnet）：可以测试节点发现、消息传播、交易选择这类东西。相比测试网，signet 能更好地控制出块时间，而且可以同时存在多个 signet，用于测试不同场景。

- **<!--can-hardware-wallets-actually-display-the-amount-of-funds-leaving-your-control-->**[硬件钱包真的能显示离开你掌控的资金数额吗？]({{bse}}89508) Andrew Chow 解释说，硬件钱包不是全节点，因此只能从别处获取交易金额信息。对于非 segwit 输入，通常由主机电脑或其他钱包把前一笔交易发送给该设备，从而把金额提供给硬件签名设备。对于 segwit 输入，正在签名的那个输入的金额必须始终提供，因为它是签名和验证所依据数据中必不可少的一部分。

- **<!--how-does-one-prove-that-they-sent-bitcoins-to-an-unspendable-wallet-->**[如何证明他们将比特币发送到不可花费的钱包？]({{bse}}89554) JBaczuk 解释说，你可以通过将比特币发送到 OP_RETURN 输出或另一个始终返回 false 的脚本，或者将比特币发送到从人为设计、非随机脚本哈希派生的地址来证明这些币是不可花费的。

- **<!--why-is-proof-of-work-required-in-bitcoin-->**[为什么比特币需要工作量证明？]({{bse}}89972) Pieter Wuille 解释说，PoW 并不创造信任，而是激励矿工与其他矿工合作，在他们的区块之上继续构建。PoW 还用来调节出块时间（从而防止拒绝服务攻击）：难度调整使得想要稳定地以高于平均每 10 分钟一块的频率出块，代价会高得难以承受。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 中值得注意的变更。*

- [LND #2203][] 添加了一个 `rejecthtlc` 配置选项，该选项将阻止节点为其他节点转发支付，但仍允许其接收传入支付和发送传出支付。

- [LND #3256][] 增加了 LND 从路由失败中得出的推断数量，并利用这些信息调整后续路由。例如，某个节点在交易中扮演特定角色（如中间节点或最终节点）时本不该产生某条错误消息，却产生了，那么它就会在路由偏好数据库中受到惩罚。

- [BOLTs #608][] 对 [BOLT4][] 做了一项隐私改进，使路由节点更难判断最终是哪个节点在收款。此前，最终节点如果收到一笔在未来太短时间内就会过期的支付，会发送 `final_expiry_too_soon` 错误；其他非最终节点则只报告自己不认识该支付。这就让人可以探测各个通道，从而确定收款方。更新后的 BOLT 现在建议最终节点即使知道问题是过期时间太近，也发送通用的 `incorrect_or_unknown_payment_details` 消息。这与[上周的 Newsletter][lnd3391] 中就金额错误问题描述的基本隐私泄露及应对办法是同一回事。

## 特别感谢

我们感谢 Pieter Wuille 和 Sanket Kanjalkar 审阅了本期 Newsletter 的草稿，并帮助我们理解 miniscript 的全部功能。如果仍有任何错误，均为 Newsletter 作者的责任。

{% include linkers/issues.md issues="16647,3256,608,2203" %}
[bech32 series]: /zh/bech32-sending-support/
[lnd3391]: /zh/newsletters/2019/08/21#lnd-3391
[miniscript code]: https://github.com/sipa/miniscript
[miniscript email]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017270.html
[core miniscript]: https://github.com/sipa/miniscript/tree/master/bitcoin/script
[miniscript rust]: https://github.com/apoelstra/rust-miniscript
[miniscript vid]: https://www.youtube.com/watch?v=XM1lzN4Zfks
[miniscript xs]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/miniscript/
[miniscript summary]: /zh/newsletters/2019/02/05#miniscript
[miniscript]: /en/topics/miniscript/
