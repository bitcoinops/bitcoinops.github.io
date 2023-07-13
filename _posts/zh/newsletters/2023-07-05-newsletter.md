---
title: 'Bitcoin Optech Newsletter #258'
permalink: /zh/newsletters/2023/07/05/
name: 2023-07-05-newsletter-zh
slug: 2023-07-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报包含了我们的交易池规则限定周刊系列的新一篇文章，还有我们的常规栏目：软件的新版本和候选版本快报，以及热门比特币基础设施软件重大变更的简述。

## 新闻

*本周内，Bitcoin-Dev 邮件组和 Lightning-Dev 邮件组中没有出现重大新闻。*

## 等待确认 #8：交易池规则是个接口

*关于交易转发、交易池接纳和挖矿交易选择的限定[周刊][policy series] —— 解释了为什么 Bitcoin Core 的交易池规则比共识规则更严格，以及钱包可以如何更高效地利用这些规则。*

{% include specials/policy/zh/08-interface.md %} {% assign timestamp="0:30" %}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试旧版本。*

- [Core Lightning 23.05.2][] 是这个闪电节点软件的维护版本，修复了多个可能影响生产环境用户的 bug。{% assign timestamp="10:27" %}

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #24914][] 将按照类型按顺序加载钱包数据记录，而不是迭代整个数据库两次以确定依赖。在此更改之后，一些记录已经损坏的钱包可能不再能加载，但可以在之前版本的 Bitcoin Core 上加载，然后导出成为一个新钱包。{% assign timestamp="22:03" %}

- [Bitcoin Core #27896][] 移除了实验性的系统调用（syscall）沙盒特性（见[周报 #170][news170 syscall]）。一个[相关的 issue][Bitcoin Core #24771] 和后续的评论指出，这个特性的缺点包括可维护性（包括 syscall 白名单和操作系统支持两个方面）、有得到更好支持的替代方案，而且考虑支持哪种 syscall 沙盒将变成 Bitcoin Core 的责任。{% assign timestamp="24:47" %}

- [Core Lightning #6334][] 升级和扩展了 CLN 对 “[锚点输出][topic anchor outputs]” 的实验性支持（见[周报 #111][news111 cln anchor] 中关于 CLN 的初始实现的部分）。该 PR 的中的升级还包括：启用对零手续费的 [HTLC][topic htlc] 锚点的实验性支持、添加了可配置的检查以保证节点至少拥有操作一条锚点通道所需的紧急资金。{% assign timestamp="27:51" %}

- [BIPs #1452][] 更新了关于[钱包备注][topic wallet labels]导出格式的[BIP329][]规范，加入了一个新的可选的  `spendable` 标签，暗示相关的输出是否可被一个钱包花费。许多钱包实现了 *钱币控制* 特性，允许用户告诉[钱币选择][topic coin selection]算法不要花费某些输出，比如可能降低用户隐私性的输出。{% assign timestamp="31:08" %}

- [BIPs #1354][] 为 [BIP389][] 加入了 [Newsletter #211][news211 desc] 所述的多种派生路径的[描述符][topic descriptors]。这允许一个描述符指定两条相关的 BIP32 路径用于层级式密钥生成 —— 第一条路径用于接收支付，第二条路径用于钱包的内部支付（例如找零）。{% assign timestamp="33:55" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="24914,27896,6334,1452,1354,24771" %}
[policy series]: /zh/blog/waiting-for-confirmation/
[news111 cln anchor]: /en/newsletters/2020/08/19/#c-lightning-3830
[news211 desc]: /zh/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[core lightning 23.05.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.2
[news170 syscall]: /en/newsletters/2021/10/13/#bitcoin-core-20487
