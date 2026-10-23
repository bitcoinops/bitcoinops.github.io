---
title: 'Bitcoin Optech Newsletter #79'
permalink: /zh/newsletters/2020/01/08/
name: 2020-01-08-newsletter-zh
slug: 2020-01-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结有组织的 taproot 审查的最后一周，介绍一场关于既无等值输入、也无等值输出的 coinjoin 混币的讨论，并提到一项把输出脚本描述符编码后放进终端用户界面的提案。此外还有我们关于热门比特币基础设施项目值得注意的变更的常规栏目。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- Bitcoin Optech 计划于 2020 年 2 月 5 日在伦敦举办第三场 Schnorr 与 Taproot 工作坊。内容与前两次 [Schnorr/Taproot 工作坊][Schnorr/Taproot workshops]相同，相关材料已发布在本站，可供自学。

  **希望派工程师参加工作坊的会员公司，请[发邮件联系 Optech][optech email]**。

## 新闻

- **<!--final-week-of-organized-taproot-review-->****有组织的 taproot 审查的最后一周：** 12 月 17 日是 taproot 审查小组最后一次预定的[会议][taproot meeting]。Pieter Wuille 发布了他一次总结进展的演讲所用的[幻灯片][wuille slides]，其中的文字表明他认为该提案“接近就绪”。Wuille 还针对 tapleaf 的版本机制提出了一个[小改动][wuille suggestion]。文中还简要提到 ZmnSCPxj 在 Lightning-Dev 邮件列表上发起的[讨论][zmn post]：taproot 究竟该如何与 LN 集成，才能带来更好的隐私和可扩展性。

- **<!--coinjoins-without-equal-value-inputs-or-outputs-->****输入输出都不等值的 coinjoin：** Adam Ficsor（nopara73）在 Bitcoin-Dev 邮件列表上发起了一个[讨论][ficsor non-equal]，涉及两篇此前发表的论文（[1][cashfusion]、[2][knapsack]），它们描述的都是输入或输出不必等值的 coinjoin。以往的不等值混币尝试[很容易被破解][coinjoin sudoku]，但如果能找到更好的方法，让这类交易看起来像[支付批处理][topic payment batching]，就能显著提升 coinjoin 的隐私性。在有人报告某家热门交易所正在调查参与 Wasabi Wallet 那种 Chaumian 式 coinjoin 的用户之后，这个话题显得格外相关。虽然讨论中提出了好几种想法，但我们认为 Lucas Ontivero 的[总结][ontivero summary]抓住了整体结论的要旨：“总的来说，输入/输出不等值的 coinjoin（[knapsack][]）是我们目前手上最好的办法（[但]它没有输出等值的交易那么有效）。”

- **<!--encoded-descriptors-->****编码后的描述符：** Chris Belcher 在 Bitcoin-Dev 邮件列表上[征询][belcher descriptors]对 Base64 编码[输出脚本描述符][topic descriptors]的意见，目的是让描述符更容易复制粘贴（同时也让普通用户不必直面它那种类似代码的语法）。至少有一份回复反对这个想法；支持该想法的其他回复则各自提出了不同的编码格式。到目前为止，讨论没有得出明确结论。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT][bolts repo] 中值得注意的变更。*

- [C-Lightning #3351][] 扩展了 `invoice` RPC，新增 `exposeprivatechannels` 参数，允许用户要求在生成的 [BOLT11][] 发票中为私有通道加入路由提示。用户还可以自行指定希望在发票中宣传哪些通道，公共通道和私有通道均可。

- [LND #3647][] 把 `listinvoices` RPC 中二进制数据的显示方式从 base64 改为十六进制。对于用到任何被改动字段的用户来说，这是一次破坏性的 API 变更。

- [LND #3814][] 允许 UTXO 清扫器（sweeper）向清扫交易中添加钱包输入，以确保其输出达到粉尘下限。这是为了支持尚在提议中的锚定输出功能（参见 [Newsletter #70][news70 anchor]）——该功能需要向交易中添加输入，才能花掉价值很低的 UTXO。

{% include linkers/issues.md issues="3647,3814,3351" %}
[Schnorr/Taproot workshops]: /zh/schnorr-taproot-workshop/
[wuille slides]: https://prezi.com/view/AlXd19INd3isgt3SvW8g/
[wuille suggestion]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-12-17-19.01.log.html#l-8
[zmn post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002375.html
[ficsor non-equal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017538.html
[cashfusion]: https://github.com/cashshuffle/spec/blob/master/CASHFUSION.md
[knapsack]: https://www.comsys.rwth-aachen.de/fileadmin/papers/2017/2017-maurer-trustcom-coinjoin.pdf
[coinjoin sudoku]: http://www.coinjoinsudoku.com/
[belcher descriptors]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017529.html
[news70 anchor]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[taproot meeting]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-12-17-19.01.html
[ontivero summary]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017544.html
