---
title: 'Bitcoin Optech Newsletter #61'
permalink: /zh/newsletters/2019/08/28/
name: 2019-08-28-newsletter-zh
slug: 2019-08-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 询问了对 miniscript 语言的意见，发布了我们关于 bech32 发送支持部分的最终章节，包含了 Bitcoin Stack Exchange 上的热门问答，并描述了几个值得注意的比特币基础设施项目的更改。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--evaluate-miniscript-->****评估 miniscript：** 钱包开发者们被鼓励评估这一[提议的语言][miniscript code]，它可以让钱包适应新的脚本模板，而无需为每个新模板更改底层钱包代码。详情请见*新闻*部分。

## 新闻

- **<!--miniscript-request-for-comments-->****Miniscript 请求评论：** 该语言的开发者已[请求][miniscript email]社区对其初步设计进行反馈。[Miniscript][] 允许软件自动分析脚本，包括确定创建满足脚本的见证所需的数据，并允许任何被该脚本保护的比特币被花费。在 miniscript 指导钱包如何操作的情况下，钱包开发者在从一个脚本模板切换到另一个脚本模板时无需编写新代码。

  例如，如今一个钱包开发者如果想从 2-of-3 多重签名切换到带有 1-of-2 时间锁逃生条款的 2-of-2 多重签名，可能需要为新情况编写和测试一个新函数。而有了 miniscript，只要钱包知道如何为指定密钥生成签名以及如何解决时间锁，miniscript 就可以引导钱包通过各种可能的路径来解决脚本。不需要额外的花费代码。

  对于需要来自多个钱包的签名或其他数据的脚本，miniscript 可以引导钱包创建它可以提供的所有见证数据，以便这些数据可以打包到部分签名比特币交易（PSBT）中。其他钱包可以创建它们自己的 PSBT，所有这些 PSBT 都交给 PSBT 完成器。如果该完成器支持 miniscript，它可以将所有提供的 PSBT 中的见证数据排序为一个完整的见证，使花费交易有效。

  这种对 miniscript 支持的大范围脚本的自动化允许钱包在使用脚本时更加灵活，甚至可能允许用户指定自己的脚本。为了支持这种动态性，miniscript 可以使用一种易于编写的策略语言创建。策略是可组合的，允许任何有效的子表达式在比特币系统施加的某些限制范围内被另一个有效的子表达式替换。例如，假设 Alice 有一个涉及热钱包、硬件钱包和备用冷钱包的 2-of-3 策略：

  ```
  thresh(2, pk(A_hot), pk(A_hard), pk(A_cold))
  ```

  后来 Alice 被要求创建一个忠诚债券，该债券将她的一些比特币锁定 26,000 个区块。该策略的通用形式为：

  ```
  and(pk(KEY), older(26000))
  ```

  Alice 可以简单地用她的特定策略替换 `pk(KEY)`：

  ```
  and(thresh(2, pk(A_hot), pk(A_hard), pk(A_cold)), older(26000))
  ```

  Miniscript 编译器可以将该策略转换为高效的 P2WSH 脚本，并检查它是否违反了比特币的共识规则或 Bitcoin Core 的交易中继和挖矿政策。它还可以告诉 Alice 与该脚本相关的各种尺寸，以便她可以估算自己的交易费用开支。

  如果比特币协议增加了脚本更改，例如 [taproot][bip-taproot]，很可能会创建支持这些协议新增内容的新版本 miniscript，从而使得即便钱包和用户使用复杂脚本，升级也会变得更加容易。

  欲了解更多信息，请参见我们的 [miniscript 主题页面][miniscript]、[C++ miniscript 实现][miniscript code]、[Rust 实现][miniscript rust]、[Bitcoin Core 集成代码][core miniscript]，以及 Pieter Wuille 关于早期版本 miniscript 的演讲（[视频][miniscript vid]、[文字记录][miniscript xs]、[Optech 摘要][miniscript summary]）。

## Bech32 发送支持

*关于让你支付的人能够享受 segwit 所有好处的[系列][bech32 series]中的最后一部分。*

{% include specials/bech32/zh/24-conclusion.md %}

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找答案的首选之一——或者当我们有空闲时间时，我们也会帮助好奇或困惑的用户。在这个月度特色栏目中，我们会重点介绍自上次更新以来的一些高票问答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-key-differences-between-regtest-and-the-proposed-signet-->**[regtest 和提议的 signet 之间的主要区别是什么？]({{bse}}89640) Pieter Wuille 和 Andrew Chow 解释说，虽然 regtest 适用于本地自动化集成测试，但 signet 更类似于 testnet，它允许测试节点发现、传播和交易选择等功能。Signet 允许比 testnet 更好地控制区块生产时间，并且可以存在多个 signet 来测试不同的场景。

- **<!--can-hardware-wallets-actually-display-the-amount-of-funds-leaving-your-control-->**[硬件钱包能实际显示离开你控制的资金数量吗？]({{bse}}89508) Andrew Chow 解释说，由于硬件钱包不是一个全节点，它需要从其他地方获取其交易金额信息。对于非 segwit 输入，通常通过将先前的交易发送到设备，由主机计算机或其他钱包提供给硬件签名设备。在 segwit 输入的情况下，正在签名的输入金额必须始终提供，因为它是签名和验证所需数据的必备部分。

- **<!--how-does-one-prove-that-they-sent-bitcoins-to-an-unspendable-wallet-->**[如何证明他们将比特币发送到不可花费的钱包？]({{bse}}89554) JBaczuk 解释说，你可以通过将比特币发送到 OP_RETURN 输出或另一个始终返回 false 的脚本，或者将比特币发送到从人为设计、非随机脚本哈希派生的地址来证明这些币是不可花费的。

- **<!--why-is-proof-of-work-required-in-bitcoin-->**[为什么比特币需要工作量证明？]({{bse}}89972) Pieter Wuille 解释说，PoW 并不创建信任，而是为矿工合作构建其他矿工的区块创造了激励。PoW 还用于调节区块时间（因此可以防止拒绝服务攻击），因为难度调整使得可靠地生产区块的成本高昂，平均而言不超过每 10 分钟一个。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]的一些值得注意的更改。*

- [LND #2203][] 添加了一个 `rejecthtlc` 配置选项，该选项将阻止节点为其他节点转发支付，但仍允许其接收传入支付和发送传出支付。

- [LND #3256][] 增加了 LND 从路由失败中得出的推论数量，并使用这些信息调整后续路由。例如，如果某个节点在交易中的特定角色（如中间节点或最终节点）不应生成错误消息，但却生成了错误消息，则该节点在路由优选数据库中会被惩罚。

- [BOLTs #608][] 提供了对 [BOLT4][] 的隐私更新，使路由节点更难识别最终接收支付的节点。此前，如果最终节点收到即将到期的支付，它会发送 `final_expiry_too_soon` 错误。而其他非最终节点则会报告它们不识别该支付。这使得可以通过探测各种通道来确定接收方。更新后的 BOLT 现在建议最终节点即使知道问题是即将到期，也发送通用的 `incorrect_or_unknown_payment_details` 消息。这与[上周的 newsletter][lnd3391] 中描述的错误金额问题和解决方案是类似的基本隐私泄露和解决方案。

## 特别感谢

我们感谢 Pieter Wuille 和 Sanket Kanjalkar 审阅了本期 Newsletter 的草稿，并帮助我们理解 miniscript 的全部功能。如果仍有任何错误，均为 Newsletter 作者的责任。

{% include linkers/issues.md issues="16647,3256,608,2203" %}
[bech32 series]: /zh/bech32-sending-support/
[lnd3391]: /zh/newsletters/2019/08/21#lnd-3391
[miniscript code]: https://github.com/sipa/miniscript
[miniscript email]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017270.html
[core miniscript]: https://github.com/sipa/miniscript/tree/master/bitcoin/script
[miniscript rust]: https://github.com/apoelstra/rust-miniscript
[miniscript vid]: https://www.youtube.com/watch?v=XM1lzN4Zfks
[miniscript xs]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/miniscript/
[miniscript summary]: /zh/newsletters/2019/02/05#miniscript
[miniscript]: /en/topics/miniscript/
