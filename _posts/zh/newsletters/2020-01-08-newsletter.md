---
title: 'Bitcoin Optech Newsletter #79'
permalink: /zh/newsletters/2020/01/08/
name: 2020-01-08-newsletter-zh
slug: 2020-01-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了有组织的 Taproot 审查的最后一周，描述了关于 Coinjoin 混合无需相等输入或输出的讨论，并提到了一项在终端用户界面中编码输出脚本描述符的提案。还包括我们关于比特币基础设施项目的常规值得注意的变化部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- Bitcoin Optech 计划于 2020 年 2 月 5 日在伦敦举行第三次 Schnorr 和 Taproot 研讨会工作坊。此次工作坊将涵盖与前两次 [Schnorr/Taproot 工作坊][Schnorr/Taproot workshops] 相同的内容，这些内容可以在本网站上进行自学。

  **希望派遣工程师参加工作坊的会员公司请[通过电子邮件联系 Optech][optech email]**。

## 新闻

- **<!--final-week-of-organized-taproot-review-->****有组织的 Taproot 审查的最后一周：** 12 月 17 日是 Taproot 审查小组的最后一次[会议][taproot meeting]。Pieter Wuille 发布了他总结进展的[演示幻灯片][wuille slides]，其中的文字表明他认为提案“已接近准备就绪”。Wuille 还提出了一个[小修改建议][wuille suggestion]，涉及 tapleaf 的版本控制。ZmnSCPxj 在 Lightning-Dev 邮件列表上发起的关于如何精确地将 Taproot 集成到闪电网络以提高隐私性和可扩展性的[讨论][zmn post]也被简要提及。

- **<!--coinjoins-without-equal-value-inputs-or-outputs-->****无需相等输入或输出的 Coinjoin：** Adam Ficsor（nopara73）在 Bitcoin-Dev 邮件列表上发起了一个[讨论][ficsor non-equal]，讨论了两篇之前发布的论文 ([1][cashfusion]、[2][knapsack])，它们描述了无需相等输入或输出的 Coinjoin。先前的非相等混合尝试[很容易被破坏][coinjoin sudoku]，但如果找到改进的方法，它可能会通过让交易看起来像[支付批处理][topic payment batching]大大提高 Coinjoin 的隐私性。这一讨论显得尤为重要，尤其是在报告称一个流行的交易所正在调查参与 Wasabi Wallet 生成的 Chaumian 风格 Coinjoin 的用户之后。虽然讨论了几个想法，但我们认为 Lucas Ontivero 的[总结][ontivero summary]抓住了整体结论的精髓：“总的来说，非相等输入/输出的 Coinjoin [knapsack][] 是目前我们最好的选择（[但]它并不像相等输出交易那么有效）。”

- **<!--encoded-descriptors-->****编码描述符：** Chris Belcher 在 Bitcoin-Dev 邮件列表上[询问][belcher descriptors]关于将[输出脚本描述符][topic descriptors]编码为 base64 的反馈意见，以便更容易复制粘贴（同时也为了使普通用户不必暴露于类代码语法）。至少有一份回复反对这个想法，其他支持该想法的回复则各自提出了不同的编码格式。目前的讨论尚未得出明确结论。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]的一些值得注意的变化。*

- [C-Lightning #3351][] 扩展了 `invoice` RPC，增加了一个新的 `exposeprivatechannels` 参数，允许用户请求为生成的 [BOLT11][] 发票添加私有通道的路由提示。用户可以选择指定他们希望在发票中宣传的通道，包括公共和私有通道。

- [LND #3647][] 将二进制数据在 `listinvoices` RPC 中的显示方式从 base64 改为十六进制。这是对更新字段的用户的 API 重大变更。

- [LND #3814][] 允许 UTXO 清扫器向清扫交易中添加钱包输入，以确保其输出满足粉尘限制。这旨在帮助支持提议的锚定输出功能（参见 [Newsletter #70][news70 anchor]），该功能需要向交易中添加输入，以便能够花费低价值 UTXO。

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
