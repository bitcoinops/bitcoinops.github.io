---
title: 'Bitcoin Optech Newsletter #9'
permalink: /zh/newsletters/2018/08/21/
name: 2018-08-21-newsletter-zh
slug: 2018-08-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的 Newsletter 包括请求帮助测试下一个版本的 Bitcoin Core、
Bitcoin Core 贡献者正在进行的项目的简短描述以及过去一周的值得注意的合并列表。

## 行动项

- **<!--allocate-time-to-test-bitcoin-core-0-17-release-candidates-->****分配时间测试 Bitcoin Core 0.17 发布候选版本：**
  在接下来的几天里，Bitcoin Core 将开始发布版本 0.17.0 的发布候选版本（RC）。鼓励计划使用 0.17 的组织和个人用户测试 RC，以确保它们包含您需要的所有功能，并且没有任何会影响您操作的错误。对于这样的主要版本，通常有多个 RC，但每个 RC 理论上都可能是最终 RC，因此我们鼓励您尽早测试。

## 新闻

上周没有在 bitcoin-dev 或 lightning-dev 邮件列表上发布重要新闻，所以本周新闻集中在 Bitcoin Core 周会议期间讨论的项目上。

Bitcoin Core 和大多数自由和开源软件项目一样，是自下而上组织的，每个贡献者都在处理他们认为重要的事情，而不是自上而下的由项目领导者指导工作，所以偶尔——就像上周发生的那样——开发者会简要地彼此总结他们未来正在进行的工作。这些倡议中的一些可能会失败，但也有可能一些会成为 Bitcoin Core 的未来部分。以下是讨论的项目摘要：

- **<!--p2p-protocol-encryption-->****P2P 协议加密**，由 Jonas Schnelli 正在进行，短期重点是未经认证的加密，采用 [BIP151][] 风格（但可能使用与该BIP描述不同的机制）。节点认证（例如 [BIP150]）可能更遥远，因为对它的一项批评是，实现它最简单的方法容易对特定节点进行指纹识别，从而降低隐私性——因此对于需要它的情况，希望有一种更高级的机制。

- **<!--output-script-descriptors-enhancements-->****输出脚本描述符增强**，由Pieter Wuille正在进行。这个的基本思想在 [Newsletter #5][news5 news] 中有描述，但 Wuille 正在调查添加对嵌套和阈值构造的支持，例如：“将 `and(xpub/...,or(xpub/...,xpub/...))` 导入到您的钱包作为仅观察链，例如，并获取 [PSBT][BIP174] 为它签名。”这将使添加硬件钱包支持到 Bitcoin Core 变得更容易。该支持还将与时锁和哈希锁兼容，以用于与 LN 兼容的钱包（硬件或软件）。

- **<!--risc-v-support-->****RISC-V 支持** 正在由 Wladimir van der Laan 进行开发。这是一种 CPU 架构，由于其开源的 CPU 设计，正迅速增长其受欢迎度，成为潜在的与基于 ARM 的芯片组的竞争者，尤其是在业余爱好者中间。Van der Laan 等几位开发者的一个项目，最终通过使用 RISC-V 交叉编译产生的 Bitcoin Core 二进制文件的确定性生成的哈希值，以确保流行的 x86_64 芯片组中已知的问题和后门不被用于危害 Bitcoin Core 二进制构建。Van der Laan 近期取得了几项成就，并启动了“世界上可能的第一个 RISC-V 比特币节点”，该节点已同步了链的一部分。

- **<!--bandwidth-efficient-set-reconciliation-protocol-for-transactions-->****交易的高效带宽集合对账协议** 正在由 Gregory Maxwell、Gleb Naumenko 和 Pieter Wuille 开发。这可能允许一个节点通过发送“等于差异本身预期大小”的数据的方式，告诉另一个节点关于它内存池的新交易的信息。与当前协议相比，节点通过发送一个 32 字节的哈希值来告知一个交易的存在。连接良好的节点在处理每个中位数大小 224 字节的交易时，可以接收或发送超过一百个这样的通知，导致大量长期节点的带宽被浪费（根据 Naumenko 的测量，高达 90% [参考][nmnkgl relay]，尽管 Bitcoin Core 的最近改进可能已经降低了这一数字）。Maxwell 还在努力使得一个新启动的（或长时间断开的）节点能够使用这一相同的基本机制，高效地从其节点同步内存池中的高费率部分。

- **<!--dandelion-protocol-dos-resistant-stem-routing-->****蒲公英协议抵抗 DoS 的“茎”路由** 正在由 Suhas Daftuar 进行开发。[蒲公英协议][Dandelion protocol]旨在使对手极难确定创建比特币交易的任何程序的 IP 地址（即使他们不使用 Tor），但在“茎”阶段暂时私下处理未确认交易的新方法必须防止可能浪费节点带宽和内存的攻击。

如需更多详细信息，请参阅[会议记录][2018-08-16 meeting log]。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的值得注意的提交。*

{% comment %}<!-- 依我看来，c-lightning 本周只有 6 次提交，主要是小的文档更新，因此没有新闻报道。我仍然会在上面提及它们，以便下周易于复制/粘贴。-harding -->{% endcomment %}

- Bitcoin Core 0.17 分支：这允许开发者专注于确保稳定性、翻译完整性和其他发布特性，而新特性的开发继续在主分支上进行。本值得注意的提交部分仅关注每个项目的主开发分支，因此从此时起提及的提交不太可能包含在 Bitcoin Core 0.17 版本中，且不应期待在 0.18 版本之前出现。

- [Bitcoin Core #13917][] 和 [Bitcoin Core #13960][] 在歧义情况下改进了 [BIP174][] 部分签名比特币交易（PSBT）的处理。

- [Bitcoin Core #11526][] 使得使用 Microsoft Visual Studio 2017 构建 Bitcoin Core 变得更加容易，包括能够使用 Visual Studio 调试器。

- [Bitcoin Core #13918][] 为几个月前引入到主开发分支的 `getblockstats` RPC 提供了一个历史区块的第 10、25、50、75 和 90 百分位的费率。

- [LND #1693][] 允许 LND 的自动驾驶资金机制可选地使用其自身的未确认更改输出进行资金交易，从而可能在下一个区块中打开多个通道。

    注意：这只是本周合并到自动驾驶功能的几个小（但有用）改进中最显著的一个。

- [LND #1460][] 现在，payinvoice 和 sendpayment 命令需要额外的确认，尽管可以通过 `--force` 或 `-f` 参数绕过此要求。

{% include references.md %}
{% include linkers/issues.md issues="13917,11526,13918,1693,1460,13960" %}

[news5 news]: /zh/newsletters/2018/07/24/#新闻
[dandelion protocol]: https://arxiv.org/abs/1701.04439
[2018-08-16 meeting log]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-08-16-19.03.log.html
[nmnkgl relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-April/015863.html
