---
title: 'Bitcoin Optech Newsletter #9'
permalink: /zh/newsletters/2018/08/21/
name: 2018-08-21-newsletter-zh
slug: 2018-08-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的 Newsletter 包括请求帮助测试下一个版本的 Bitcoin Core、Bitcoin Core 贡献者正在进行的项目简介，以及过去一周值得注意的合并一览。

## 行动项

- **<!--allocate-time-to-test-bitcoin-core-0-17-release-candidates-->****安排时间测试 Bitcoin Core 0.17 发布候选版本：**
  未来几天，Bitcoin Core 将开始发布 0.17.0 版的发布候选版本（RC）。我们鼓励计划使用 0.17 的组织和个人用户测试这些 RC，确认它们包含你需要的全部功能，并且没有会影响你运营的缺陷。像这样的大版本通常会有多个 RC，但理论上每个 RC 都可能是最后一个，所以我们鼓励你尽早测试。

## 新闻

上周 bitcoin-dev 和 lightning-dev 邮件列表上都没有发布重要新闻，所以本周新闻聚焦于 Bitcoin Core 周会上讨论的一些项目。

Bitcoin Core 与大多数自由和开源软件项目一样，采用自下而上的组织方式：每个贡献者做自己认为重要的事，而不是自上而下由项目领导者分派工作。因此偶尔——就像上周那样——开发者会互相简单介绍自己未来打算做的工作。这些设想中有些可能会失败，但也有些将来可能成为 Bitcoin Core 的一部分。以下是所讨论项目的摘要：

- **<!--p2p-protocol-encryption-->****P2P 协议加密**，由 Jonas Schnelli 负责，短期重点是采用 [BIP151][] 风格的未认证加密（但可能使用与该 BIP 描述不同的机制）。对等节点认证（例如 [BIP150][]）可能还要更晚，因为对它的批评之一是：实现它的最简单做法容易让人对特定的对等节点进行指纹识别，从而削弱隐私——所以对于确有需要的场景，人们希望采用更高级的机制。

- **<!--output-script-descriptors-enhancements-->****输出脚本描述符增强**，由 Pieter Wuille 负责。其基本思路在 [Newsletter #5][news5 news] 中已有介绍，不过 Wuille 正在研究增加对嵌套构造和阈值构造的支持，例如：“把 `and(xpub/...,or(xpub/...,xpub/...))` 作为仅观察（watch-only）链导入你的钱包，并让 [PSBT][BIP174] 为它签名。”这将让 Bitcoin Core 更容易加入硬件钱包支持。该支持还会兼顾时间锁和哈希锁，从而可用于兼容 LN 的钱包（硬件或软件）。

- **<!--risc-v-support-->****RISC-V 支持** 正在由 Wladimir van der Laan 开发。这是一种 CPU 架构，有可能与基于 ARM 的芯片组竞争，且由于其设计开源，在爱好者当中人气正迅速上升。包括 Van der Laan 在内的几位开发者共同推进的一个项目，最终目标是为用 RISC-V 交叉编译产生的 Bitcoin Core 二进制文件提供确定性生成的哈希值，以确保主流 x86_64 芯片组中已知的问题和后门不会被用来破坏 Bitcoin Core 的二进制构建。Van der Laan 近期取得了数项进展，还启动了“大概世界上第一个 RISC-V 比特币节点”，该节点已经同步了部分链数据。

- **<!--bandwidth-efficient-set-reconciliation-protocol-for-transactions-->****面向交易的带宽高效集合对账协议** 正在由 Gregory Maxwell、Gleb Naumenko 和 Pieter Wuille 开发。有了它，内存池中有新交易的节点只需传输“与差异本身的预期大小相当”的数据量，就能把这些交易告知对等节点。相比之下，当前协议中节点要向对等节点发送交易的 32 字节哈希，以此告知该交易的存在。连接良好的节点每处理一笔中位数大小 224 字节的交易，就可能收发一百多个这类通知，导致长期在线节点的大量带宽被浪费（根据 Naumenko 的测量高达 90%[参考][nmnkgl relay]，不过 Bitcoin Core 近期的改进可能已经降低了这一数字）。Maxwell 还在努力让新启动（或长时间断开）的节点能借助同一基本机制，从对等节点高效同步内存池中费率较高的那部分。

- **<!--dandelion-protocol-dos-resistant-stem-routing-->****蒲公英协议抗 DoS 的“茎”路由** 正在由 Suhas Daftuar 开发。[蒲公英协议][Dandelion protocol]有望让对手极难确定任何发起比特币交易的程序的 IP 地址（即使这些程序不使用 Tor），但在“茎”阶段暂时私下处理未确认交易的新方法，必须能抵御会浪费节点带宽和内存的攻击。

如需更多详细信息，请参阅[会议记录][2018-08-16 meeting log]。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的值得注意的提交。*

{% comment %}<!-- 依我看来，c-lightning 本周只有 6 次提交，主要是小的文档更新，因此没有新闻报道。我仍然会在上面提及它们，以便下周易于复制/粘贴。-harding -->{% endcomment %}

- Bitcoin Core 0.17 已分出分支：这样开发者就能在该分支上专注保证稳定性、翻译完整性及其他发布相关事项，同时新功能的开发继续在主分支上进行。本栏只关注各项目的主开发分支，因此从现在起提到的提交都不太可能进入 Bitcoin Core 0.17 版本，预计最早也要到 0.18 版本才会出现。

- [Bitcoin Core #13917][] 和 [Bitcoin Core #13960][] 在歧义情况下改进了 [BIP174][] 部分签名比特币交易（PSBT）的处理。

- [Bitcoin Core #11526][] 使得使用 Microsoft Visual Studio 2017 构建 Bitcoin Core 变得更加容易，包括能够使用 Visual Studio 调试器。

- [Bitcoin Core #13918][]：`getblockstats` RPC 几个月前才引入主开发分支，现在它能为历史区块返回第 10、25、50、75 和 90 百分位的费率。

- [LND #1693][]：允许 LND 的自动巡航（autopilot）资金机制选择性地使用自身尚未确认的找零输出为交易提供资金，从而有可能在下一个区块中打开多个通道。

    注意：这只是本周合并的自动巡航功能若干小改进（但很实用）中最值得注意的一项。

- [LND #1460][] 现在，payinvoice 和 sendpayment 命令需要额外的确认，尽管可以通过 `--force` 或 `-f` 参数绕过此要求。

{% include references.md %}
{% include linkers/issues.md issues="13917,11526,13918,1693,1460,13960" %}

[news5 news]: /zh/newsletters/2018/07/24/#新闻
[dandelion protocol]: https://arxiv.org/abs/1701.04439
[2018-08-16 meeting log]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-08-16-19.03.log.html
[nmnkgl relay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-April/015863.html
