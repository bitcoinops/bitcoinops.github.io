---
title: 'Bitcoin Optech Newsletter #112'
permalink: /zh/newsletters/2020/08/26/
name: 2020-08-26-newsletter-zh
slug: 2020-08-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到关于路由式 coinswap 的讨论，并包含我们常规的栏目：Bitcoin Stack Exchange 问答摘要、发布与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--discussion-about-routed-coinswaps-->****关于路由式 coinswap 的讨论：** Chris Belcher 在 Bitcoin-Dev 邮件列表中[发布][belcher coinswap]了一份路由式多交易 coinswap 实现的设计文档，作为他五月份那篇帖子的后续（见 [Newsletter #100][news100 coinswap]）。评论主要关注协议是否安全：既看它的密码学用法，也看它能否确保预期的交易被确认，而不是被试图盗取资金的替代交易顶替。撰写本文时，讨论仍在进行中。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-motivation-for-separating-bitcoin-core-into-independent-node-wallet-and-gui-processes-->**[为什么要将 Bitcoin Core 分离为独立的节点、钱包和 GUI 进程？]({{bse}}98398) Michael Folkson 概述了 Russell Yanofsky [分离 Bitcoin Core 进程][bitcoin core process separation]的努力带来的好处，即把 Bitcoin Core 拆成 `bitcoin-node`、`bitcoin-wallet` 和 `bitcoin-gui` 三个不同进程。模块化能让用户在自己的部署中获得更多灵活性，也能给开发者带来可维护性和安全性上的好处。

- **<!--what-s-the-most-efficient-way-to-create-a-raw-transaction-with-a-specific-fee-rate-->**[创建具有特定费率的原始交易的最有效方法是什么？]({{bse}}98392) Stack Exchange 用户 Darius 询问在构建交易时 UTXO 选择与费率之间如何相互影响。Murch 概述了选币的有效价值（effective value）方法，谈到了[避免找零][bitcoin wiki change avoidance]，并提醒注意签名长度。

- **<!--will-there-be-a-testnet4-or-do-we-not-need-a-testnet-reset-once-we-have-signet-->**[会有 testnet4 吗？或者有了 signet 之后，我们就不再需要重置测试网？]({{bse}}98579) Michael Folkson 解释了围绕是否重置测试网、或者引入一个新的 [signet][topic signet] 网络的种种考量。本月一个[相关的 Stack Exchange 问题][stack exchange signet setup]还总结了使用 signet 的两种方案。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.11.0-beta][lnd 0.11.0-beta] 现已发布。这个新的主要版本允许接受[大通道][topic large channels]（该功能默认关闭），并包含许多后端功能改进，高级用户可能会感兴趣（请参阅[发布说明][lnd 0.11.0-beta]）。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #14582][] 和 [#19743][Bitcoin Core #19743] 添加了一个新的 `maxapsfee`（“max avoid partial spends fee”，即最大避免部分支出手续费）配置选项，用于指定在现有 `avoidpartialspends` 配置选项被禁用时，你最多愿意额外支付多少手续费来避免部分支出。

  启用 `avoidpartialspends` 能提高隐私性，因为每个地址只被花费一次（见 [Newsletter #6][news6 avoidpartial]），但它可能导致手续费略高：即使同一地址收到的输入中只有一部分是必需的，也会把它们全部花掉。正因如此，除非为钱包启用了 `avoid_reuse` 标志，`avoidpartialspends` 默认是禁用的（见 [Newsletter #52][news52 avoid_reuse]）。`maxapsfee` 正是为这种默认情形而设，它让用户可以在三种配置之间选择：

  1. `-maxapsfee=-1`：完全禁用部分支出避免，以便更快地计算手续费，这对拥有大量 UTXO 的超大钱包可能有用。

  2. `-maxapsfee=0`（默认值）：用两种选币算法分别计算手续费，采用较便宜的那个结果；若两者成本相同，则采用部分支出避免。

  3. `maxapsfee` 设为大于 `0`：只要部分支出避免给交易增加的额外成本不超过给定金额，就采用它。例如，`-maxapsfee=0.00001000` 表示若手续费的绝对差额最多为 1,000 sat，钱包就会避免部分支出。

- [Bitcoin Core #19550][] 添加了一个新的 `getindexinfo` RPC，它会列出每个已启用的可选索引、目前已索引了多少个区块，以及这些区块是否构成一路同步到区块链顶端的状态。

- [C-Lightning #3954][] 更新了 `fundpsbt` 和 `utxopsbt` 两个 RPC，使它们都能接受一个 `locktime` 参数，用于指定要创建的交易的 nLockTime。PR 指出，这是[双向资助][bolts #524]所必需的，因为发起方要设置 locktime。

- [BIPs #955][] 更新了 [BIP174][]，把在 [PSBT][topic psbt] 输入记录中提供哈希原像的做法标准化。这些原像字段的标准化[被认为是支持 miniscript 的终结器所必需的][psbt ext]，不过任何需要满足哈希原像挑战的 PSBT 终结器都可以使用它们（例如链上的 LN 承诺交易）。

- [BOLTs #688][] 为 LN 规范增加了对[锚定输出][topic anchor outputs]的支持。这为承诺交易增加了两个额外输出——每个对等方各一个——可用于子为父付（[CPFP][topic cpfp]）的手续费追加。有了这一更改，就可以对可能在数日或数周之前签署的承诺交易做手续费追加，而那时很难预测当前的费率。在实践中，使用锚定输出的 LN 节点通常应支付更低的手续费，因为已不再有高估手续费的动机。锚定输出还带来更高的安全性：如果费率确实涨到超出预期，节点可以对自己的承诺交易做手续费追加。多个 LN 实现已经合并了对锚定输出的不同程度的支持。

- [BOLTs #785][] 将最小 CLTV 到期差值更新为 18 个区块。为确保最新状态被记录到链上，当距离某笔 LN 支付必须结算只剩这么多个区块时，就应单方面关闭通道。然而，到期差值越高，支付就越可能在未关闭的通道中暂时卡住（无论是意外还是故意）。这导致一些 LN 实现采用优先选择 CLTV 到期差值低的路由的路由算法，而这又促使部分用户把自己的到期差值设成特别不安全的值。这个新的最小值应有助于防止缺乏经验的用户不加思索地设置不安全的值。

{% include references.md %}
{% include linkers/issues.md issues="14582,19743,19550,3954,524,955,688,785" %}
[lnd 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta
[belcher coinswap]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018080.html
[news100 coinswap]: /zh/newsletters/2020/06/03/#design-for-a-coinswap-implementation
[news52 avoid_reuse]: /zh/newsletters/2019/06/26/#bitcoin-core-13756
[news6 avoidpartial]: /zh/newsletters/2018/07/31/#bitcoin-core-12257
[bitcoin core process separation]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Process-Separation
[stack exchange signet setup]: https://bitcoin.stackexchange.com/questions/98553/how-do-i-get-set-up-on-signet/98554#98554
[bitcoin wiki change avoidance]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Change_avoidance
[psbt ext]: /zh/newsletters/2019/03/12/#extension-fields-to-partially-signed-bitcoin-transactions-psbts
[hwi]: https://github.com/bitcoin-core/HWI
