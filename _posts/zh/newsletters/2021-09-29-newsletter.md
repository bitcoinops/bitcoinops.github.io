---
title: 'Bitcoin Optech Newsletter #168'
permalink: /zh/newsletters/2021/09/29/
name: 2021-09-29-newsletter-zh
slug: 2021-09-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 总结了关于在谨慎日志合约（DLC）规范中实施破坏性变更的提案，探讨了仅使用 BIP32 种子恢复已关闭 LN 通道的可能性，并描述了生成无状态 LN 发票的构想。此外还包括我们的常规栏目：Bitcoin Stack Exchange 精选问答、为 taproot 激活做准备的思路，以及主流比特币基础设施软件的值得注意的变更说明。

## 新闻

- **<!--discussion-about-dlc-specification-breaking-changes-->****关于 DLC 规范破坏性变更的讨论：** Nadav Kohen 在 DLC-dev 邮件列表中[发布][kohen post]了关于更新 [DLC][topic dlc] 规范的提案，其中包含多个可能破坏现有应用兼容性的变更。他提出了两种方案：按需更新规范并让应用声明其实现的版本；或将多个破坏性变更集中处理以最小化中断次数。邀请正在开发 DLC 软件的技术人员提供反馈。

- **<!--challenges-recovering-ln-close-transactions-using-only-a-seed-->****仅用种子恢复 LN 关闭交易的挑战：** Electrum Wallet 开发者 ghost43 在 Lightning-Dev 邮件列表中[发帖][ghost43 post]，讨论为钱包的通道关闭交易扫描区块链时的一些挑战。一个具体问题在于：只用 [BIP32][] 风格的[分层确定性密钥生成][topic bip32]恢复钱包时，该如何应对新的[锚定输出][topic anchor outputs]协议。ghost43 分析了若干可能的方案，并推荐 Eclair 目前使用的方案，认为它是当前可行的最佳方案。如果各实现愿意略微修改通道开通协议，文中还提出了进一步的改进思路。

- **<!--stateless-ln-invoice-generation-->****无状态 LN 发票生成：** Joost Jager 在 Lightning-Dev 邮件列表中[发帖][jager post]，讨论为未认证用户生成 LN 发票的应用可能遭受的拒绝服务攻击。具体来说，攻击者可以请求数量不受限制的发票，而生成服务需要一直保存这些发票直到它们过期。Jager 建议换个做法：对于不需要太多数据的小额发票，服务可以在生成后立即将其忘掉，转而把发票参数交给发起请求的用户。用户支付时会提交这些参数，服务端据此重建发票、接受支付并完成订单。

  尽管一些回复者[担心][osuntokun reply]这个想法没有必要——用其他方式同样可以让应用被请求淹没，而且针对那些问题的任何解决方案也应当能解决发票请求洪泛——但另一些人认为这个想法有用。该构想似乎不需要任何协议变更，只需修改软件（或编写插件）来创建和管理发票的生成与重建。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-the-txid-have-256-bits-when-bitcoin-s-address-security-is-160-bit-->**[为何 TXID 采用 256 位而比特币地址安全等级是 160 位？]({{bse}}109652)
  Pieter Wuille 阐述了比特币中考虑位长时的三项安全考量：原像抗性、碰撞抗性与存在性伪造。他进一步解释了比特币如何在上述各方面实现（或未能实现）128 位安全等级的目标。

- **<!--why-are-op-return-transactions-discouraged-does-using-version-or-locktime-make-any-difference-->**[为何不鼓励使用 OP_RETURN 交易？使用版本号或锁定时间是否有影响？]({{bse}}108389)
  除在另一个问题中从技术角度阐述 `OP_RETURN` 如何[销毁币][se 109747]之外，Pieter Wuille 还给出了自己对使用 `OP_RETURN` 存储数据的看法。

- **<!--using-non-standard-version-numbers-in-transactions-->**[在交易中使用非标准版本号]({{bse}}108248)
  Andrew Chow 和 G. Maxwell 解释称，由于 1 和 2 是交易仅有的标准版本号，尽管你可以让矿工接受其他版本号，但一旦未来有针对该版本号的共识规则，就可能导致这些输出无法花费，或交易本身失效。

- **<!--is-there-historical-data-of-utxos-by-address-type-->**[是否有按地址类型统计的 UTXO 历史数据？]({{bse}}109776)
  Murch 提供了几张来自 [transactionfee.info][] 的示例图表。

- **<!--how-are-op-csv-and-op-cltv-backwards-compatible-->**[OP_CSV 和 OP_CLTV 如何实现向后兼容？]({{bse}}109834)
  Andrew Chow 介绍了 BIP65 和 BIP112 两处[时间锁][topic timelocks]历史上的[软分叉激活][topic soft fork activation]机制。

## 准备 Taproot #15：仍需 Signmessage 协议

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 taproot 做准备的[系列][series preparing for taproot]周更文章。*

{% include specials/taproot/zh/14-signmessage.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.21.2][bitcoin core 0.21.2] 是 Bitcoin Core 一个维护版本的正式发布，包含多个错误修复与小改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #12677][] 在钱包的 `listunspent` RPC 方法返回的交易输出中新增 `ancestorcount`、`ancestorsize` 和 `ancestorfees` 字段。若创建该交易输出的交易尚未确认，这些字段会给出该交易及其在内存池中所有未确认祖先交易的总数量、总大小和总手续费。矿工依据祖先费率挑选交易打包进区块，因此了解祖先交易的大小与手续费，有助于用户估算该交易的确认时间，或尝试用[子为父付（CPFP）][topic cpfp] 或 [RBF][topic rbf] 追加该交易的手续费。

- [Eclair #1942][] 允许把寻路算法配置为部分依据通道容量来评估路由。该配置可作为[实验性参数集][news166 experiments]应用，有望提升路由成功率。*[编辑：本条目在发表后已更正；感谢 Thomas Huet 指出其中的不准确之处。]*

- [LND #5101][] 新增*中间件拦截器*，它会在每个 RPC 请求发往服务器的途中接收该请求，并可对其做出修改。这使得开发者能在 LND 外部实现逻辑，以跟踪或影响各种各样的用户操作与自动化操作。出于安全考虑，只有显式使用选择启用拦截的认证令牌（macaroon）的 RPC 才能被拦截。

{% include references.md %}
{% include linkers/issues.md issues="12677,1942,5101,2842" %}
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[kohen post]: https://mailmanlists.org/pipermail/dlc-dev/2021-September/000075.html
[ghost43 post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003229.html
[jager post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003236.html
[osuntokun reply]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003252.html
[se 109747]: https://bitcoin.stackexchange.com/questions/109747/how-does-op-return-burn-coins/109748#109748
[transactionfee.info]: https://transactionfee.info/
[news166 experiments]: /zh/newsletters/2021/09/15/#eclair-1930
[series preparing for taproot]: /zh/preparing-for-taproot/
