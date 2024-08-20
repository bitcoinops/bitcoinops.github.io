---
title: 'Bitcoin Optech Newsletter #12'
permalink: /zh/newsletters/2018/09/11/
name: 2018-09-11-newsletter-zh
slug: 2018-09-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周 Newsletter 提到关于 BIP151 加密的点对点网络协议的讨论、提供关于比特币和 W3C Web 支付草案规范之间兼容性的更新并简要描述了在流行的比特币基础设施项目中一些值得注意的合并。

## 行动项

- **<!--allocate-time-to-test-bitcoin-core-0-17rc3-->****分配时间测试 Bitcoin Core 0.17RC3：** Bitcoin Core 已上传 0.17RC3 的[二进制文件][bcc 0.17]。测试非常受欢迎，可以帮助确保最终版本的质量。

- **<!--workshop-->**第二次 Optech [研讨会][workshop]的计划正在进展中，日期和地点已确认为 11 月 12-13 日在巴黎举行。暂定的议题列表包括：
    - 作为费用替代技术的 Replace-by-fee 与 Child-pays-for-parent
    - 部分签名的比特币交易（BIP 174）
    - 钱包互操作性的输出脚本描述符（gist）
    - 闪电网络钱包集成和交易所的应用
    - 币选择与合并的方法

  **希望派遣工程师参加研讨会的会员公司应[电邮 Optech][optech email]**。

## 新闻

- **<!--bip151-discussion-->****BIP151 讨论：** 如 [Newsletter #10][news10 news] 中提到的，Jonas Schnelli 已[提出][schnelli bip151]点对点网络协议的 BIP151 加密的更新草案。密码学家 Tim Ruffing 本周在 Bitcoin-Dev 邮件列表上提供了对草案的[建设性批评][ruffing bip151]，Schnelli 和 Gregory Maxwell 也提供了建设性的反驳。这些帖子对于想了解协议中特定密码学选择背后的原因的人来说可能是有趣的阅读，例如使用 NewHope 量子计算抗性密钥交换的原因。

- **<!--w3c-web-payments-working-group-update-->****W3C Web 支付工作组更新：** 闪电网络开发者 Christian Decker 是该组的成员，该组试图为基于 Web 的支付创建标准。Decker 在发送到 Lightning-Dev 邮件列表的[回复][decker w3c]中解释了他为什么认为当前的草案规范将与比特币地址的支付和闪电网络支付基本兼容。草案甚至明确为比特币分配了 XBT 货币代码。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的值得注意的提交。提醒：新合并到 Bitcoin Core 的代码是提交到其主开发分支的，不太可能成为即将发布的 0.17 版本的一部分——您可能需要等待大约六个月后的 0.18 版本。*

- [Bitcoin Core #12775][] 为 Bitcoin Core 添加对 RapidCheck（一个 [QuickCheck][] 重新实现）的支持，提供一套基于属性的测试套件，它根据程序员告诉它的函数属性（例如，它接受什么作为输入并返回什么作为输出）自动生成自己的测试。

- [Bitcoin Core #12490][] 从主开发分支中移除 `signrawtransaction` RPC。此 RPC 在即将发布的 0.17 版本中被标记为已弃用，当用户提供自己的私钥进行签名时，鼓励使用 `signrawtransactionwithkey` RPC，当他们希望内置钱包自动提供私钥时，使用 `signrawtransactionwithwallet` RPC。

- [Bitcoin Core #14096][] 提供[输出脚本描述符的文档][documentation for output script descriptors]，这些描述符用于 Bitcoin Core 0.17 中的新 `scantxoutset` RPC，并预计将来用于与钱包的其他交互。

- **<!--lnd-->****LND** 在过去一周进行近 30 次合并，其中许多合并对其自动导航设施进行小的增强或修复——它能够允许用户选择自动与自动选择的对等方开启新通道。几次合并还更新了 LND 依赖的库版本。

- [C-Lightning #1899][] 本周向其仓库添加了数百行文档，大部分是内联代码文档或其 [/doc 目录][c-lightning docs] 中文件的更新。

{% include references.md %}
{% include linkers/issues.md issues="12775,12490,14096,1899" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[workshop]: /en/workshops
[documentation for output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[news10 news]: /zh/newsletters/2018/08/28/#新闻
[decker w3c]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-August/001404.html
[schnelli bip151]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016355.html
[ruffing bip151]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016372.html
[quickcheck]: https://en.wikipedia.org/wiki/QuickCheck
[c-lightning docs]: https://github.com/ElementsProject/lightning/tree/master/doc
