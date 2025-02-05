---
title: 'Bitcoin Optech Newsletter #160'
permalink: /zh/newsletters/2021/08/04/
name: 2021-08-04-newsletter-zh
slug: 2021-08-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括了我们常规的几部分内容，描述了如何为 Taproot 做准备，总结了最新的发布与候选发布，并列出了受欢迎的比特币基础设施项目中的值得注意的变更。

## 新闻

*本周没有重大新闻。*

## 准备 Taproot #7：多签

*每周连载的[系列][series preparing for taproot]，介绍开发者和服务提供者如何为即将激活的 Taproot 做准备，激活将在区块高度 {{site.trb}} 时发生。*

{% include specials/taproot/zh/06-multisignatures.md %}

## 发布与候选发布

*受欢迎的比特币基础设施项目的新发布与候选发布。请考虑升级到新版本或协助测试候选发布。*

- [C-Lightning 0.10.1rc2][C-Lightning 0.10.1] 是一个包含多个新特性、若干 bug 修复以及一些开发协议更新（包括 [Dual Funding][topic dual funding] 和 [ Offers ][topic offers] 的升级候选发布版本。

## 值得注意的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #22006][] 增加了 [文档][tracing doc]，说明了用户空间、静态定义追踪（USDT）及其前三个追踪点 - 这些功能的构建支持和宏在 [Bitcoin Core #19866][] 中进行了添加。启用 eBPF 追踪的用户可以通过提供的[示例脚本][contrib tracing doc]或编写自己的追踪脚本，轻松连接到追踪点，从而更好地观察节点在连接新块、接收入站 P2P 消息和发送出站 P2P 消息时的表现。文档中还包括了使用示例和新追踪点添加的指南。

- [Eclair #1893][] 允许分别配置[未宣布通道][topic unannounced channels]、已宣布通道以及[蹦床支付][topic trampoline payments]中继的最低手续费。本次 PR 还为未宣布通道设置了 0.01% 的默认中继手续费，相较于已宣布通道的 0.02%。

- [Rust-Lightning #967][] 增加了通过 `send_spontaneous_payment` 函数调用来进行 [keysend 风格的自发支付][keysend onion]的支持。此变更使得我们所覆盖的所有四种 LN 实现都支持 keysend。

  作者还提交了[相应的文档][BOLTs #892]（尚未合并），这份文档讲解了作为 [BLIP][news156 blips]（比特币闪电网络改进提案）的一部分，如何文档化 keysend 支付功能和最佳实践，BLIP 是一种用于记录不属于 LN BOLTs 规范的一部分的功能和最佳实践的提案方式。

{% include references.md %}
{% include linkers/issues.md issues="22006,19866,1893,967,892" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1rc2
[tracing doc]: https://github.com/bitcoin/bitcoin/blob/8f37f5c2a562c38c83fc40234ade9c301fc4e685/doc/tracing.md
[contrib tracing doc]: https://github.com/bitcoin/bitcoin/tree/8f37f5c2a562c38c83fc40234ade9c301fc4e685/contrib/tracing
[keysend onion]: /en/topics/spontaneous-payments/#add-data-to-the-routing-packet
[news156 blips]: /zh/newsletters/2021/07/07/#blips
[series preparing for taproot]: /zh/preparing-for-taproot/
