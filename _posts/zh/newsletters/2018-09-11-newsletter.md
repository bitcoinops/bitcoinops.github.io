---
title: 'Bitcoin Optech Newsletter #12'
permalink: /zh/newsletters/2018/09/11/
name: 2018-09-11-newsletter-zh
slug: 2018-09-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周 Newsletter 提到一场关于点对点网络协议 BIP151 加密的讨论，介绍了比特币与 W3C Web 支付草案规范兼容性的最新进展，并简要描述了一些流行比特币基础设施项目中值得注意的合并。

## 行动项

- **<!--allocate-time-to-test-bitcoin-core-0-17rc3-->****安排时间测试 Bitcoin Core 0.17 RC3：** Bitcoin Core 已上传 0.17 候选版本（RC）3 的[二进制文件][bcc 0.17]。我们非常欢迎你参与测试，这有助于保证最终版本的质量。

- **<!--workshop-->**第二次 Optech [工作坊][workshop]的筹备工作正在推进，日期和地点已确定为 11 月 12 日至 13 日在巴黎举行。暂定的议题包括：
    - 手续费替代技术：手续费替换（RBF）与子为父付（CPFP）的对比
    - 部分签名比特币交易（PSBT，BIP 174）
    - 用于钱包互操作性的输出脚本描述符（descriptor）（gist）
    - 闪电网络钱包集成，以及面向交易所的应用
    - 选币（coin selection）与合并（consolidation）的思路

  **希望派工程师参加工作坊的会员公司，请[给 Optech 发邮件][optech email]**。

## 新闻

- **<!--bip151-discussion-->****BIP151 讨论：** 如 [Newsletter #10][news10 news] 中提到的，Jonas Schnelli 已[提出][schnelli bip151]点对点网络协议 [BIP151][] 加密的更新草案。密码学家 Tim Ruffing 本周在 Bitcoin-Dev 邮件列表上对草案提出了[建设性批评][ruffing bip151]，Schnelli 和 Gregory Maxwell 也作出了同样有建设性的反驳。任何想了解协议为何做出某些密码学选择（例如采用抗量子计算的 NewHope 密钥交换）的人，都值得一读这些帖子。

- **<!--w3c-web-payments-working-group-update-->****W3C Web 支付工作组更新：** 闪电网络开发者 Christian Decker 是该组成员，这个小组正尝试为基于 Web 的支付制定标准。Decker 在发送到 Lightning-Dev 邮件列表的[回复][decker w3c]中解释了他为什么认为当前的草案规范与向比特币地址付款以及闪电网络支付都基本兼容。草案甚至明确把 XBT 货币代码分配给了比特币。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的提交。提醒：Bitcoin Core 的新合并都进入主开发分支，不太可能成为即将发布的 0.17 版本的一部分——你大概要等到约六个月后的 0.18 版本。*

- [Bitcoin Core #12775][] 为 Bitcoin Core 添加对 RapidCheck（[QuickCheck][] 的一个重新实现）的支持，提供了一套基于属性的测试框架，它会根据程序员声明的函数属性（例如函数接受什么输入、返回什么输出）自行生成测试。

- [Bitcoin Core #12490][] 从主开发分支中移除 `signrawtransaction` RPC。此 RPC 在即将发布的 0.17 版本中被标记为已弃用：如果你自己提供私钥签名，鼓励改用 `signrawtransactionwithkey` RPC；如果你希望内置钱包自动提供私钥，则使用 `signrawtransactionwithwallet` RPC。

- [Bitcoin Core #14096][] 提供[输出脚本描述符的文档][documentation for output script descriptors]。这些描述符用于 Bitcoin Core 0.17 新增的 `scantxoutset` RPC，预计今后还会用于与钱包的其他交互。

- **<!--lnd-->****LND** 在过去一周完成了近 30 次合并，其中许多是对其自动巡航（autopilot）功能的小幅增强或错误修复——该功能让用户可以选择自动与自动挑选出的对等节点开启新通道。另有几次合并更新了 LND 所依赖的库版本。

- [C-Lightning #1899][] 本周向其仓库添加了数百行文档，大部分是内联代码文档或其 [/doc 目录][c-lightning docs] 中文件的更新。

{% include references.md %}
{% include linkers/issues.md issues="12775,12490,14096,1899" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[workshop]: /en/workshops
[documentation for output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[news10 news]: /zh/newsletters/2018/08/28/#新闻
[decker w3c]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-August/001404.html
[schnelli bip151]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016355.html
[ruffing bip151]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016372.html
[quickcheck]: https://en.wikipedia.org/wiki/QuickCheck
[c-lightning docs]: https://github.com/ElementsProject/lightning/tree/master/doc
