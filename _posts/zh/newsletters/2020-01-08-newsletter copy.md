---
title: 'Bitcoin Optech Newsletter #79'
permalink: /zh/newsletters/2020/01/08/
name: 2020-01-08-newsletter-zh
slug: 2020-01-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了有组织的 Taproot 审查的最后一周，描述了关于在没有相等输入或输出的情况下进行 CoinJoin 混合的讨论，并提到了一个在终端用户界面中编码输出脚本描述符的提案。此外，还包括我们定期提供的关于流行的比特币基础设施项目的值得注意的更改部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- Bitcoin Optech 计划于 2020 年 2 月 5 日在伦敦举办第三次 Schnorr 和 Taproot 研讨会。这将涵盖与之前两次 [Schnorr/Taproot 研讨会][Schnorr/Taproot workshops] 相同的内容，相关资料可以在本网站进行自学。

  **希望派遣工程师参加研讨会的会员公司请[给 Optech 发邮件][optech email]**。

## 新闻

- **<!--final-week-of-organized-taproot-review-->****有组织的 Taproot 审查最后一周：** 12 月 17 日是 Taproot 审查小组的最后一次预定[会议][taproot meeting]。Pieter Wuille 发布了他所做的总结进展[幻灯片][wuille slides]，其中包含他认为该提案“几乎准备就绪”的文本。Wuille 还提出了一个关于 tapleaf 版本控制的[小改动][wuille suggestion]。还简要提到了由 ZmnSCPxj 在 Lightning-Dev 邮件列表上发起的关于 Taproot 如何与闪电网络集成以提高隐私性和可扩展性的[讨论][zmn post]。

- **<!--coinjoins-without-equal-value-inputs-or-outputs-->****没有相等输入或输出的 CoinJoin：** Adam Ficsor (nopara73) 在 Bitcoin-Dev 邮件列表上发起了一场[讨论][ficsor non-equal]，讨论了两篇之前发布的论文 ([1][cashfusion], [2][knapsack])，描述了没有使用相等输入或输出的 CoinJoin。之前关于不相等混合的尝试[很容易被破坏][coinjoin sudoku]，但如果能够找到改进的方法，这可能显著提高 CoinJoin 的隐私性，使其交易看起来像[支付批处理][topic payment batching]。在有报告指出某知名交易所正在调查参与 Wasabi Wallet 创建的混合型 CoinJoin 用户后，这个话题显得尤为重要。尽管讨论了几种想法，但我们认为 Lucas Ontivero 的[总结][ontivero summary]抓住了整体结论的精髓：“总的来说，不相等输入/输出的 CoinJoin [knapsack][] 是目前最好的选择（[但] 它的效果不如相等输出的交易）。”

- **<!--encoded-descriptors-->****编码描述符：** Chris Belcher 在 Bitcoin-Dev 邮件列表上[询问][belcher descriptors]关于使用 base64 编码[输出脚本描述符][topic descriptors]的反馈意见，以便它们更容易复制和粘贴（并且普通用户不必接触到其代码样的语法）。至少有一个回复反对这个想法，而其他支持该想法的回复则提出了不同的编码格式。目前的讨论尚未得出明确的结论。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [C-Lightning #3351][] 扩展了 `invoice` RPC，新增了一个 `exposeprivatechannels` 参数，允许用户请求在生成的 [BOLT11][] 发票中为私有通道添加路由提示。用户可以选择性地指定他们希望在发票中公布的通道，包括公共和私有通道。

- [LND #3647][] 将 `listinvoices` RPC 中的二进制数据显示从 base64 切换为十六进制。这是一个对使用更新字段的用户的破坏性 API 更改。

- [LND #3814][] 允许 UTXO 清算器向清算交易添加钱包输入，以确保其输出满足粉尘限制。这旨在支持提议的锚点输出功能（参见 [Newsletter #70][news70 anchor]），该功能需要向交易中添加输入，以便能够花费低价值的 UTXO。

{% include linkers/issues.md issues="3647,3814,3351" %}
[Schnorr/Taproot workshops]: /zh/schnorr-taproot-workshop/
[wuille slides]: https://prezi.com/view/AlXd19INd3isgt3SvW8g/
[wuille suggestion]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-12-17-19.01.log.html#l-8
[zmn post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002375.html
[ficsor non-equal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017538.html
[cashfusion]: https://github.com/cashshuffle/spec/blob/master/CASHFUSION.md
[knapsack]: https://www.comsys.rwth-aachen.de/fileadmin/papers/2017/2017-maurer-trustcom-coinjoin.pdf
[coinjoin sudoku]: http://www.coinjoinsudoku.com/
[belcher descriptors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017529.html
[news70 anchor]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[taproot meeting]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-12-17-19.01.html
[ontivero summary]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017544.html
