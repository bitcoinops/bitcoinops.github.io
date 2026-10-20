---
title: 'Bitcoin Optech Newsletter #160'
permalink: /zh/newsletters/2021/08/04/
name: 2021-08-04-newsletter-zh
slug: 2021-08-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包括我们的几个常规栏目：如何为 Taproot 做准备、最新版本与候选版本汇总，以及热门比特币基础设施项目中值得注意的变更。

## 新闻

*本周没有重大新闻。*

## 准备 Taproot #7：多重签名

*每周连载的[系列][series preparing for taproot]，介绍开发者和服务提供者如何为即将激活的 Taproot 做准备，激活将在区块高度 {{site.trb}} 时发生。*

{% include specials/taproot/zh/06-multisignatures.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.10.1rc2][C-Lightning 0.10.1] 是一次升级的候选版本，包含多个新功能、若干错误修复，以及若干处对仍在开发中的协议的更新（包括[双向资助][topic dual funding]和[offers][topic offers]）。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #22006][] 新增了一份[文档][tracing doc]，介绍用户空间静态定义追踪（USDT）以及最初的三个追踪点；这些追踪点的构建支持与宏是在 [Bitcoin Core #19866][] 中加入的。以启用 eBPF 追踪的方式构建 Bitcoin Core 的用户，可以用文档提供的[示例脚本][contrib tracing doc]挂接到这些追踪点，也可以自行编写追踪脚本，从而更好地观测节点在连接新区块、接收入站 P2P 消息和发送出站 P2P 消息时的行为。该文档还包含用法示例，以及新增追踪点时需遵循的准则。

- [Eclair #1893][] 允许分别配置[未公开通道][topic unannounced channels]、已公开通道以及[蹦床支付][topic trampoline payments]中继的最低费率。该 PR 还为未公开通道设定了与已公开通道不同的默认中继费率：前者为 0.01%，后者为 0.02%。

- [Rust-Lightning #967][] 新增了对通过 `send_spontaneous_payment` 函数调用发起 [keysend 风格自发支付][keysend onion]的支持。经过这一变更，我们跟踪的全部四个 LN 实现都支持 keysend。

  作者还提交了[相应的文档][BOLTs #892]（尚未合并），以 [BLIP][news156 blips]（Bitcoin Lightning Improvement Proposals，比特币闪电网络改进提案）的形式记录 keysend 支付。BLIP 是一种拟议的记录方式，用于记录那些不属于闪电网络 BOLTs 规范的功能与最佳实践。

{% include references.md %}
{% include linkers/issues.md issues="22006,19866,1893,967,892" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1rc2
[tracing doc]: https://github.com/bitcoin/bitcoin/blob/8f37f5c2a562c38c83fc40234ade9c301fc4e685/doc/tracing.md
[contrib tracing doc]: https://github.com/bitcoin/bitcoin/tree/8f37f5c2a562c38c83fc40234ade9c301fc4e685/contrib/tracing
[keysend onion]: /en/topics/spontaneous-payments/#add-data-to-the-routing-packet
[news156 blips]: /zh/newsletters/2021/07/07/#blips
[series preparing for taproot]: /zh/preparing-for-taproot/
