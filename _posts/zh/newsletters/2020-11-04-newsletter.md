---
title: 'Bitcoin Optech Newsletter #122'
permalink: /zh/newsletters/2020/11/04/
name: 2020-11-04-newsletter-zh
slug: 2020-11-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于双向 LN 预付费的讨论，并传达了专家对 Taproot 激活方式偏好的小范围调查结果。此外，还包括我们常规的各个项目更新部分。

## 行动项

*本周无。*

## 新闻

- **<!--bi-directional-upfront-fees-for-ln-->****双向 LN 预付费：** 在关于预付费的 Lightning-Dev 邮件列表讨论（见 [Newsletter #120][news120 upfront]）基础上，Bastien Teinturier [提出][teinturier bidir]了一个建议，要求提供 [HTLC][topic htlc] 的一方和接收方双方都需向对方支付费用——但如果支付在指定时间内结算，接收方可获得费用的退款。例如：

  {:.center}
  ![Alice 通过 Bob 向 Carol 路由支付，使用双向预付费](/img/posts/2020-11-bi-directional-upfront.png)

  前向费用（如 Alice→Bob）可阻止垃圾信息；即使接收方拒绝中继支付，前向费用仍需支付。后向费用（如 Bob→Alice）通过设置退款期限鼓励及时结算。任何希望使用[延迟发票][topic hold invoices]的最终接收者若超出剩余时间，将需支付后向费用。任何中间跳点如果怀疑支付在期限前不会成功，也会拒绝该支付，从而允许前面的跳点在期限前结算失败的支付并获得退款。

  在对此想法的讨论中，尚未发现任何致命问题，但该提案引发的兴趣程度尚不明确。

- **<!--taproot-activation-survey-results-->****Taproot 激活方式调查结果：** Anthony Towns 收到了来自 13 位“智能开发者类型人士”的调查反馈，询问他们对使用哪种软分叉激活方式进行 Taproot 激活的偏好。[帖子][towns survey]中包含了他个人对结果的总结，简要摘录如下：

  > - 激活阈值应保持在 95% [...]
  >
  > - [...] 希望矿工在几个月内能快速响应，但计划的时间跨度应考虑到即使一切顺利也可能长达一年
  >
  > - 设置[最早的激活时间]在包含激活代码的 Bitcoin Core 版本发布后的一个月左右可能比较合适 [...]
  >
  > - 在某些情况下，几乎所有人都支持设定一个强制激活日
  >
  > - 如果有强制激活日，我们应预计这个日期在一两年之后 [...]
  >
  > - 初期可能不支持设定强制激活日 [...]
  >
  > - 几乎所有人都希望在激活后尽可能多的节点执行规则
  >
  > - 大多数人似乎愿意接受通过强制信号提前到来的强制激活日
  >
  > - 对于通过配置选项选择加入激活日的方式支持不多

  在 Bitcoin Core 开发者完成即将发布的 0.21 版本的工作后，此调查结果可能会帮助他们选择用于 Taproot 的激活参数。当然，软分叉的实际执行将取决于其在用户中的广泛支持——用户也可能选择使用其他激活方式。欢迎在 [##taproot-activation][] IRC 聊天室中进一步讨论激活参数（[日志][##taproot-activation logs]）。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [C-Lightning #4162][] 更新了日志记录以显示支付是否使用了[支付秘密][payment secret]。支付秘密作为[多路径支付][topic multipath payments]功能的一部分，已在 [BOLTs #643][] 中添加到 BOLT 11，用于防止路径上的节点进行探测攻击。支付秘密已被所有 LN 实现支持，并最终将被 C-Lightning 强制使用；记录哪些支付使用了支付秘密可以帮助开发者了解何时合理地做出该更改。

{% include references.md %}
{% include linkers/issues.md issues="643,4162" %}
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[##taproot-activation logs]: http://gnusha.org/taproot-activation/
[news120 upfront]: /zh/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[teinturier bidir]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002862.html
[towns survey]: http://www.erisian.com.au/wordpress/2020/10/26/activating-soft-forks-in-bitcoin
[payment secret]: https://github.com/lightningnetwork/lightning-rfc/commit/5776d2a7
