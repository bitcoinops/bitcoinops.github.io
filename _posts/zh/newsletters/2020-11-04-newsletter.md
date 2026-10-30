---
title: 'Bitcoin Optech Newsletter #122'
permalink: /zh/newsletters/2020/11/04/
name: 2020-11-04-newsletter-zh
slug: 2020-11-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结关于 LN 双向前置手续费的讨论，并转述一项针对专家的小范围问卷调查结果，内容是他们倾向于用哪种方式激活 taproot。此外，还包括我们常规的各个项目更新部分。

## 行动项

*本周无。*

## 新闻

- **<!--bi-directional-upfront-fees-for-ln-->****LN 双向前置手续费：** 在 Lightning-Dev 邮件列表此前关于前置手续费的讨论帖（见 [Newsletter #120][news120 upfront]）基础上，Bastien Teinturier [提出][teinturier bidir]一项建议：让提供 [HTLC][topic htlc] 的一方和收到 HTLC 的一方各自向对方支付手续费——不过，如果支付在指定时间内结算，收款方能拿回自己支付的手续费。例如：

  {:.center}
  ![Alice 通过 Bob 向 Carol 路由支付，使用双向前置手续费](/img/posts/2020-11-bi-directional-upfront.png)

  前向手续费（例如 Alice→Bob）可抑制垃圾支付；即使接收方拒绝中继这笔支付，前向手续费也必须支付。后向手续费（例如 Bob→Alice）通过退款期限来鼓励及时结算。任何想使用[挂起发票][topic hold invoices]超过剩余时间的最终收款方，现在都需要支付后向手续费。任何怀疑支付无法在期限前成功的中间跳点，现在都会拒绝该支付，从而让更前面的跳点也能在期限前结算这笔失败的支付并拿回退款。

  在对此想法的讨论中，似乎并未发现任何致命问题，但该提案引发了多大热情尚不清楚。

- **<!--taproot-activation-survey-results-->****taproot 激活方式调查结果：** Anthony Towns 收到 13 位未具名“聪明开发者型人士”的问卷反馈，内容是他们对为 taproot 选用哪种软分叉激活机制的偏好。[帖子][towns survey]中包含他个人对结果的总结，下面简要节选：

  > - 激活阈值应保持在 95%……
  >
  > - ……希望矿工能在几个月内快速响应，但计划上要考虑到即使一切顺利也可能耗时长达一年
  >
  > - 把[最早可能的激活时间]设在包含激活代码的 Bitcoin Core 版本发布后一两个月左右，可能比较合适……
  >
  > - 在某些情况下，几乎所有人都愿意接受设立强制激活日（flag day）
  >
  > - 如果要设强制激活日，应当预计它在一两年之后……
  >
  > - 一开始大概没人支持直接设定强制激活日……
  >
  > - 几乎所有人都希望激活后尽可能多的节点强制执行规则
  >
  > - 大多数人似乎愿意接受通过强制信令把强制激活日提前
  >
  > - 对于通过设置配置选项来自愿启用强制激活日，支持者不多

  在 Bitcoin Core 开发者完成即将发布的 0.21 版本的工作之后，这次调查的结果很可能会帮助他们选定后续版本中 taproot 将要采用的激活参数。当然，软分叉能否真正强制执行，取决于它能否获得用户的广泛支持——用户也可能决定采用别的激活机制。欢迎在 [##taproot-activation][] IRC 聊天室中进一步讨论激活参数（[日志][##taproot-activation logs]）。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [C-Lightning #4162][] 更新了日志输出，使其记录一笔支付是否使用了[支付秘密][payment secret]。支付秘密是[多路径支付][topic multipath payments]功能的一部分，已在 [BOLTs #643][] 中加入 BOLT 11，用于防止支付路径上的节点发起探测攻击。所有 LN 实现都已支持支付秘密，C-Lightning 最终也会强制要求使用；记录哪些支付使用了支付秘密，有助于开发者判断何时适合推行这项变更。

{% include references.md %}
{% include linkers/issues.md issues="643,4162" %}
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[##taproot-activation logs]: http://gnusha.org/taproot-activation/
[news120 upfront]: /zh/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[teinturier bidir]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002862.html
[towns survey]: http://www.erisian.com.au/wordpress/2020/10/26/activating-soft-forks-in-bitcoin
[payment secret]: https://github.com/lightningnetwork/lightning-rfc/commit/5776d2a7
