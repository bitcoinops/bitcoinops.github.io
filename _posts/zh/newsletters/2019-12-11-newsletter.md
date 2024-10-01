---
title: 'Bitcoin Optech Newsletter #76'
permalink: /zh/newsletters/2019/12/11/
name: 2019-12-11-newsletter-zh
slug: 2019-12-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 LND 的一个新维护版本，总结了关于 eltoo 支付通道瞭望塔的讨论，并描述了多个受欢迎的比特币基础设施项目中的一些值得注意的更改。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-lnd-0-8-2-beta-rc2-->****帮助测试 LND 0.8.2-beta RC2：** 这个[候选发布版本][lnd 0.8.2-beta] 包含了一些错误修复和小的用户体验改进，最显著的是静态通道备份的恢复改进。（其中一项改进在本 Newsletter 的[后文][lnd-3698]有详细描述。）

## 新闻

- **<!--watchtowers-for-eltoo-payment-channels-->****eltoo 支付通道的瞭望塔：** [eltoo][topic eltoo] 是一种提议的 LN 支付通道替代层，不需要参与者生成惩罚交易。[瞭望塔][topic watchtowers]是一种服务，当它们检测到其客户的通道正在使用旧状态关闭时，会广播预编程的交易，这使得其客户可以下线而不必担心资金损失。

  Conner Fromknecht 发起了一个[讨论线程][fromknecht eltoo tower]，询问瞭望塔需要为 eltoo 存储哪些数据，以及这将如何影响瞭望塔的可扩展性或其客户的隐私。一种选择是让瞭望塔只存储最新的更新交易。这种方式非常可扩展，因为每个通道只需要固定量的存储，并且很安全，因为只有最终的结算交易才能从最新的更新交易中支出。下线节点可以在重新上线时随时广播结算交易，哪怕是在几个月或几年之后。

  另一种讨论中的机制是让瞭望塔也存储结算交易。这可以在节点下线期间丢失所有数据的情况下提供额外的安全性，将资金发送到节点的指定提现地址（例如节点的冷钱包地址）。然而，这将增加瞭望塔的存储需求，更糟的是，明显的实现方式将显著降低用户的隐私，因为瞭望塔会拥有足够的数据来了解用户支付通道中之前的支付详情。讨论中的一些参与者提出了在保证安全性的同时减少隐私损失的方法，但截至本文撰写时，讨论线程中尚未达成明确结论。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [C-Lightning #3260][] 增加了新的 `createonion` 和 `sendonion` RPC 方法，允许外部工具或 C-Lightning 插件创建并发送节点本身不一定理解的加密 LN 消息。在 PR 中描述的此机制的一些用例包括：跨链原子交换、会合路由（参见 [Newsletter #22][rendez-vous routing]）、[蹦床支付][topic trampoline payments]和类似于 [WhatSat][] 的 LN 上聊天功能。

- [C-Lightning #3295][] 扩展了 `listinvoices` RPC，增加了一个新字段，包含已经支付的发票的支付原像。（为了防止用户在支付完成之前意外分享支付原像，未支付的发票不显示支付原像，这可能导致资金损失。）

- [C-Lightning #3155][] 添加了 `--statictor`（静态 tor）命令行参数，允许用户始终作为同一个 Tor v3 隐藏服务运行，而不是每次重启时更改地址的临时隐藏服务。静态地址是从节点的公共标识符（公钥）派生的，因此用户不需要存储任何额外的信息，尽管用户可以使用 `--torblob` 参数指定用于生成静态地址的熵。

- [LND #3788][] 增加了对“支付地址”的支持，这与[上周 Newsletter][payment secrets] 中描述的“支付密钥”相同。此新增功能可防止隐私泄露，避免探测接收节点是否在等待[多路径支付][topic multipath payments]的其他部分。

- [LND #3767][] 阻止 LND 接受具有有效 bech32 校验和的格式错误的 [BOLT11][] 发票。正如[之前报道的][news72 bech32 mutability]那样，以 `p` 结尾的 bech32 地址不允许解码器检测到前面 `q` 字符的添加或删除，从而无法达到 bech32 选择的 BCH 码参数预期的高可靠性。此问题因 BOLT11 发票期望支付节点从发票末尾的签名中恢复接收节点的公钥而更加严重——该位置正是此类无法检测到的 bech32 变异可能发生的地方。根据该合并 PR 中的代码注释，“在极少数情况下（大约 3%），[变异的签名]仍被视为有效签名，[因此]公钥恢复会导出与原本预期的不同的节点。”该 PR 通过拒绝发票中最后一个字段的长度与预期不符的发票解决了这个问题。

- [LND #3698][] 在用户尝试恢复静态通道备份（SCB）时打印警告，确保他们知道所有通道将会关闭（产生链上费用）。`lncli` 用户在继续操作之前需要确认提示。

- [LND #3655][] 增加了对 [BOLT2][] 前置关闭脚本的支持，该脚本规定节点的提现地址在通道打开前指定，并且在通道的生命周期内该地址被锁定。如果节点稍后请求将支付发送到不同的地址，其对等方应该拒绝此请求。这使得攻击者在入侵节点后更难将资金提取到攻击者的链上钱包中（尽管攻击者仍可能尝试通过其他方式窃取资金）。

{% include linkers/issues.md issues="3260,3295,3155,3788,3767,3698,3655" %}
[lnd 0.8.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.2-beta-rc2
[lnd-3698]: #lnd-3698
[fromknecht eltoo tower]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002349.html
[whatsat]: https://github.com/joostjager/whatsat
[rendez-vous routing]: /zh/newsletters/2018/11/20/#hidden-destinations
[payment secrets]: /zh/newsletters/2019/12/04/#c-lightning-3259
[news72 bech32 mutability]: /zh/newsletters/2019/11/13/#taproot-review-discussion-and-related-information
