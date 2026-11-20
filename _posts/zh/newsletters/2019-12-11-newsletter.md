---
title: 'Bitcoin Optech Newsletter #76'
permalink: /zh/newsletters/2019/12/11/
name: 2019-12-11-newsletter-zh
slug: 2019-12-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 LND 发布了一个新的维护版本，总结了关于 eltoo 支付通道瞭望塔的讨论，并介绍了热门比特币基础设施项目的多项值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-lnd-0-8-2-beta-rc2-->****帮助测试 LND 0.8.2-beta RC2：** 这个[候选发布版本][lnd 0.8.2-beta] 包含了一些错误修复和小的用户体验改进，最显著的是静态通道备份的恢复改进。（其中一项改进在本 Newsletter 的[后文][lnd-3698]有详细描述。）

## 新闻

- **<!--watchtowers-for-eltoo-payment-channels-->****eltoo 支付通道的瞭望塔：** [eltoo][topic eltoo] 是为 LN 提议的一种替代支付通道层，它不要求参与者有能力生成惩罚交易。[瞭望塔][topic watchtowers]是这样一类服务：一旦检测到其客户的通道正被旧状态关闭，就广播预先编排好的交易；这样客户即使离线，也不必担心资金损失。

  Conner Fromknecht 发起了一个[讨论帖][fromknecht eltoo tower]，询问瞭望塔需要为 eltoo 存储哪些数据，以及这会如何影响瞭望塔的可扩展性或其客户的隐私。一种选项是让瞭望塔只存储最新的更新交易。这种方案可扩展性很强，因为每个通道只需常量级的存储；它也很安全，因为只有最终的结算交易才能花掉最终更新交易中的资金。离线节点可以在下次上线时广播结算交易，哪怕是在几个月乃至几年之后。

  讨论过的另一种机制是让瞭望塔同时存储结算交易。如果节点离线期间丢失了全部数据，这能提供额外保障——资金会被发送到节点指定的提现地址（例如其冷钱包中的地址）。但这会增加瞭望塔的存储需求；更糟的是，最直观的实现方式会让瞭望塔掌握足够多的数据，从而了解用户支付通道中以往支付的细节，大幅削弱用户隐私。讨论帖中有参与者谈到了如何在获得安全好处的同时减轻隐私损失，但截至本文撰写时，这个讨论帖尚未得出明确结论。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [C-Lightning #3260][] 增加了新的 `createonion` 和 `sendonion` RPC 方法，让外部工具或 C-Lightning 插件能够创建并发送节点自身未必理解的加密 LN 消息。该 PR 中给出的一些用例包括：跨链原子交换、会合路由（参见 [Newsletter #22][rendez-vous routing]）、[蹦床支付][topic trampoline payments]，以及类似 [WhatSat][] 的 LN 聊天。

- [C-Lightning #3295][] 扩展了 `listinvoices` RPC，新增一个字段，用于给出所有已支付发票的支付原像。（未支付的发票不会显示原像，以免用户在支付最终完成前不慎泄露原像，从而可能造成资金损失。）

- [C-Lightning #3155][] 新增了 `--statictor`（static tor）命令行参数，让用户可以始终以同一个 Tor v3 隐藏服务运行，而不是以每次重启都会更换地址的临时隐藏服务运行。静态地址由节点的公开标识符（公钥）推导而来，因此用户无需额外存储任何信息；不过用户也可以用 `--torblob` 参数指定用于生成静态地址的熵。

- [LND #3788][] 增加了对“支付地址”的支持，它与[上周 Newsletter][payment secrets] 中描述的“支付密钥”是同一回事。这一改动可以防止他人对收款节点做会削弱隐私的探测——这些节点正等着接收某笔[多路径支付][topic multipath payments]的其余部分。

- [LND #3767][] 阻止 LND 接受校验和有效但格式错误的 [BOLT11][] 发票。正如[此前报道][news72 bech32 mutability]的那样，以 `p` 结尾的 bech32 地址会让解码器无法以 bech32 所选 BCH 码参数所预期的高可靠度，检测出前面 `q` 字符被添加或删除。而 BOLT11 发票要求付款节点从附在发票末尾的签名中恢复收款节点的公钥——恰恰是这类未被检测到的 bech32 变异可能出现的位置，这让问题雪上加霜。根据这个已合并 PR 中的代码注释：“在极少数情况下（约 3%），[变异后的签名]仍会被视为有效签名，[因此]公钥恢复就会推导出与原本意图不同的节点。”该 PR 通过拒绝最后一个字段长度与预期不符的发票解决了这个问题。

- [LND #3698][] 在用户尝试恢复静态通道备份（SCB）时打印警告，让他们明确知道所有通道都会关闭（并产生链上手续费）。`lncli` 用户需要先确认该提示才能继续。

- [LND #3655][] 增加了对 [BOLT2][] 预先关闭脚本（upfront shutdown script）的支持：节点的提现地址在开通道前指定，并在通道的整个生命周期内锁定。如果节点之后请求把款项发到别的地址，其对手方应当拒绝该请求。这让攻陷了节点的攻击者更难把资金提到自己的链上钱包（尽管攻击者仍可能用其他方式窃取资金）。

{% include linkers/issues.md issues="3260,3295,3155,3788,3767,3698,3655" %}
[lnd 0.8.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.2-beta-rc2
[lnd-3698]: #lnd-3698
[fromknecht eltoo tower]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002349.html
[whatsat]: https://github.com/joostjager/whatsat
[rendez-vous routing]: /zh/newsletters/2018/11/20/#hidden-destinations
[payment secrets]: /zh/newsletters/2019/12/04/#c-lightning-3259
[news72 bech32 mutability]: /zh/newsletters/2019/11/13/#taproot-review-discussion-and-related-information
