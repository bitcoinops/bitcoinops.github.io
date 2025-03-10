---
title: 'Bitcoin Optech Newsletter #168'
permalink: /zh/newsletters/2021/09/29/
name: 2021-09-29-newsletter-zh
slug: 2021-09-29-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于在 DLC 规范中实施破坏性变更的提案，探讨了仅使用 BIP32 种子恢复已关闭闪电网络通道的可能性，并描述了生成无状态闪电网络发票的构想。此外还包括我们的常规栏目：Bitcoin Stack Exchange 精选问答、为 taproot 激活做准备的思路，以及热门比特币基础设施软件的重要变更摘要。

## 新闻

- ​**<!--discussion-about-dlc-specification-breaking-changes-->****关于 DLC 规范破坏性变更的讨论：​**​ Nadav Kohen 在 DLC-dev 邮件列表中[发布][kohen post]了关于更新 [DLC][topic dlc] 规范的提案，其中包含多个可能破坏现有应用兼容性的变更。他提出了两种方案：按需更新规范并让应用声明其实现的版本；或将多个破坏性变更集中处理以最小化中断次数。邀请正在开发 DLC 软件的技术人员提供反馈。

- ​**<!--challenges-recovering-ln-close-transactions-using-only-a-seed-->****仅用种子恢复闪电网络关闭交易的挑战：​**​ Electrum Wallet 开发者 ghost43 在 Lightning-Dev 邮件列表中[发表][ghost43 post]关于仅通过扫描区块链恢复钱包通道关闭交易所面临的挑战。具体问题涉及在使用仅基于 [BIP32][] 风格[分层确定性密钥生成][topic bip32]恢复钱包时，如何处理新的[锚定输出][topic anchor outputs]协议。ghost43 分析了多种可能的方案，并推荐目前 Eclair 使用的方案作为当前最佳实践。如果实现方愿意对通道开通协议稍作修改，还可进一步改进该方案。

- ​**<!--stateless-ln-invoice-generation-->****无状态闪电网络发票生成：​**​ Joost Jager 在 Lightning-Dev 邮件列表中[提出][jager post]针对未认证用户生成闪电网络发票可能遭受拒绝服务攻击的问题。攻击者可能请求无限量发票，导致生成服务需要存储这些发票直至过期。Jager 建议对于不需要存储大量数据的小额发票，服务可在生成后立即丢弃，仅向用户提供发票参数。用户支付时提交这些参数，服务端即可重建发票、接收支付并完成订单。

  尽管有回复[认为][osuntokun reply]该方案必要性存疑——攻击者可通过其他方式发起请求洪泛，且任何解决方案都应同时解决发票请求洪泛问题——但也有观点认为该构想具有实用价值。该方案似乎无需协议变更，只需通过软件修改（或插件）实现发票生成与重建管理。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题解答的首选场所——或在闲暇时帮助好奇或困惑的用户。本栏目精选自上次更新以来得票最高的问题与答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- ​**<!--why-does-the-txid-have-256-bits-when-bitcoin-s-address-security-is-160-bit-->**[为何 TXID 采用 256 位而比特币地址安全等级是 160 位？]({{bse}}109652)
  Pieter Wuille 阐述了比特币中位长设计的三项安全考量：原像抗性、碰撞抗性与存在性伪造抗性。他进一步解释了比特币如何实现（或未实现）128 位安全等级的目标。

- ​**<!--why-are-op-return-transactions-discouraged-does-using-version-or-locktime-make-any-difference-->**[为何不鼓励使用 OP_RETURN 交易？使用版本号或锁定时间是否有影响？]({{bse}}108389)
  除在另一问题中从技术角度阐述 `OP_RETURN` 如何[销毁代币][se 109747]外，Pieter Wuille 还提供了关于使用 `OP_RETURN` 进行数据存储的见解。

- ​**<!--using-non-standard-version-numbers-in-transactions-->**[在交易中使用非标准版本号]({{bse}}108248)
  Andrew Chow 和 G. Maxwell 指出，由于 1 和 2 是唯一的标准交易版本号，即使矿工接受其他版本号，也可能导致相关输出无法花费或交易在未来共识规则下失效。

- ​**<!--is-there-historical-data-of-utxos-by-address-type-->**[是否有按地址类型统计的 UTXO 历史数据？]({{bse}}109776)
  Murch 展示了来自 [transactionfee.info][] 的几个统计图表示例。

- ​**<!--how-are-op-csv-and-op-cltv-backwards-compatible-->**[OP_CSV 和 OP_CLTV 如何实现向后兼容？]({{bse}}109834)
  Andrew Chow 回顾了 BIP65 和 BIP112 中[时间锁][topic timelocks]的[软分叉激活][topic soft fork activation]机制。

## 准备 Taproot #15：仍需 Signmessage 协议

*关于开发者和服务提供商如何为即将在区块高度 {{site.trb}} 激活的 taproot 做准备的[系列][series preparing for taproot]周更文章。*

{% include specials/taproot/zh/14-signmessage.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选版本。建议升级至新版本或协助测试候选版本。*

- [Bitcoin Core 0.21.2][bitcoin core 0.21.2] 是 Bitcoin Core 的维护版本，包含多个错误修复与小改进。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案 (BIPs)][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得关注变更。*

- [Bitcoin Core #12677][] 在钱包的 `listunspent` RPC 方法返回的交易输出信息中新增 `ancestorcount`、`ancestorsize` 和 `ancestorfees` 字段。若创建该输出的交易未确认，这些字段将显示该交易及其内存池中所有未确认祖先交易的总数量、总大小和总手续费。矿工根据祖先手续费率选择交易打包，因此了解祖先交易数据有助于用户估算确认时间或通过 [CPFP][topic cpfp] 和 [RBF][topic rbf] 提升手续费。

- [Eclair #1942][] 支持在路径寻优算法中配置基于通道容量的路由评估策略。该配置可作为[实验性参数集][news166 experiments]应用，可能提升路由成功率。*[编辑：本条目经读者 Thomas Huet 指正后修订。]*

- [LND #5101][] 新增*中间件拦截器*功能，可在每个 RPC 请求到达服务器前进行拦截和修改。这使得开发者能在 LND 外部实现跟踪或影响各类用户与自动化操作的逻辑。出于安全考虑，只有使用明确授权拦截的认证令牌（macaroon）的 RPC 才能被拦截。

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
