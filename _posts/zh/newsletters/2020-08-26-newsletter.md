---
title: 'Bitcoin Optech Newsletter #112'
permalink: /zh/newsletters/2020/08/26/
name: 2020-08-26-newsletter-zh
slug: 2020-08-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到关于路由化 Coinswap 的讨论，并包含我们常规的 Bitcoin Stack Exchange 问答摘要、发布与候选发布以及流行比特币基础设施软件的显著更改。

## 行动项

*本周无。*

## 新闻

- **<!--discussion-about-routed-coinswaps-->****关于路由化 Coinswap 的讨论：** Chris Belcher 在 Bitcoin-Dev 邮件列表中[发布][belcher coinswap]了一份用于路由化多交易 Coinswap 实现的设计文档，作为他五月份前一篇帖子（见 [Newsletter #100][news100 coinswap]）的后续。评论集中在确保协议在使用密码学和确认预期交易（而非尝试窃取的替代交易）方面是安全的。撰写本文时讨论仍在进行中。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者在有问题或空闲时间帮助好奇或困惑用户时首选的解答平台。在此每月特刊中，我们会精选一些自上次更新以来投票数较高的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-is-the-motivation-for-separating-bitcoin-core-into-independent-node-wallet-and-gui-processes-->**[为什么要将 Bitcoin Core 分离为独立的节点、钱包和 GUI 进程？]({{bse}}98398) Michael Folkson 概述了 Russell Yanofsky [分离 Bitcoin Core 进程][bitcoin core process separation]的努力带来的好处。模块化将为用户提供更多配置灵活性，并为开发者带来可维护性和安全性提升。

- **<!--what-s-the-most-efficient-way-to-create-a-raw-transaction-with-a-specific-fee-rate-->**[创建具有特定费率的原始交易的最有效方法是什么？]({{bse}}98392) Stack Exchange 用户 Darius 询问在构建交易时 UTXO 选择与费率之间的关系。Murch 概述了使用有效价值选择 UTXO 的方法，提到了[避免找零][bitcoin wiki change avoidance]以及签名长度的考量。

- **<!--will-there-be-a-testnet4-or-do-we-not-need-a-testnet-reset-once-we-have-signet-->**[会有 testnet4 吗？或者在有 Signet 后我们不再需要重置测试网？]({{bse}}98579) Michael Folkson 解释了关于重置测试网或引入新的 [signet][topic signet] 网络的考量。本月的[相关 Stack Exchange 问题][stack exchange signet setup]也总结了使用 signet 的两种方案。

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.11.0-beta][lnd 0.11.0-beta] 已发布。此新的重要版本允许接受[大通道][topic large channels]（默认关闭）并包含对后端功能的多项改进，可能引起高级用户的兴趣（请参阅[发布说明][lnd 0.11.0-beta]）。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #14582][] 和 [#19743][Bitcoin Core #19743] 添加了一个新的 `maxapsfee`（“最大避免部分支出手续费”）配置选项，用于指定在禁用现有 `avoidpartialspends` 配置选项时，您愿意为避免部分支出而支付的最大额外费用。

  启用 `avoidpartialspends` 通过仅一次性使用地址来提高隐私性（见 [Newsletter #6][news6 avoidpartial]），但可能因同一地址接收到的所有输入都被支出而产生稍高的费用，即使其中只需要部分输入。出于此原因，`avoidpartialspends` 默认禁用，除非为钱包启用了 `avoid_reuse` 标志（见 [Newsletter #52][news52 avoid_reuse]）。`maxapsfee` 正是为此默认情况而设，为用户提供了三种配置选项：

  1. `-maxapsfee=-1`：完全禁用部分支出避免，以优化较快的手续费计算，这对于有大量 UTXO 的钱包可能有用。

  2. `-maxapsfee=0`（默认值）：使用两种选择算法进行手续费计算，选择较便宜的结果；若两者费用相同，则使用部分支出避免。

  3. `maxapsfee` 大于 `0`：当额外费用不超过指定值时使用部分支出避免。例如，`-maxapsfee=0.00001000` 意味着如果手续费差额在 1,000 聪以内，钱包将避免部分支出。

- [Bitcoin Core #19550][] 添加了一个新的 `getindexinfo` RPC，它列出了启用的每个可选索引，已索引的区块数，以及这些区块是否已同步到区块链的最新状态。

- [C-Lightning #3954][] 更新了 `fundpsbt` 和 `utxopsbt` 两个 RPC，以允许它们接受一个 `locktime` 参数，该参数指定要创建的交易的 nLockTime。PR 提到这是[双重资助][bolts #524]所需的，由发起方设置。

- [BIPs #955][] 更新了 [BIP174][]，标准化在 [PSBT][topic psbt] 输入记录中提供哈希前映像。标准化这些前映像字段被认为对支持 miniscript 的最终确定器必要，尽管它们可以被任何需要满足哈希前映像挑战的 PSBT 最终确定器使用（例如链上 LN 承诺交易）。

- [BOLTs #688][] 为 LN 规范增加了对[锚定输出][topic anchor outputs]的支持。这为承诺交易增加了两个额外输出——每个对等方各一个——用于子付父（[CPFP][topic cpfp]）的手续费提升。此更改使得可以为可能在数日前或数周前签署的承诺交易增加手续费，这种情况下当前的手续费率难以预测。在实际操作中，使用锚定输出的 LN 节点通常支付较低的费用，因为没有必要高估费用。锚定输出还提高了安全性，因为如果手续费率超出预期，节点可以为其承诺交易增加手续费。多个 LN 实现已合并对锚定输出的不同程度支持。

- [BOLTS #785][] 将最小 CLTV 到期差更新为 18 个区块。为确保最新状态记录在链上，应在 LN 支付需结算前仅剩此多区块时单方面关闭通道。然而，过高的到期时间可能导致支付暂时在开放通道中卡住（无论是意外还是故意）。这导致一些 LN 实现使用优化低 CLTV 到期差的路由算法，而这又促使部分用户将其到期差设置为特别不安全的值。此新最小值应有助于防止缺乏经验的用户轻率地设置不安全的值。

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
