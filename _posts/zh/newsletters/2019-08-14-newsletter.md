---
title: 'Bitcoin Optech Newsletter #59'
permalink: /zh/newsletters/2019/08/14/
name: 2019-08-14-newsletter-zh
slug: 2019-08-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 简要描述了 Bitcoin-Dev 邮件列表中的两次讨论，一次是关于 Bitcoin vaults 的，另一次是关于减少 taproot 中使用的公钥大小的。此外，还包括我们常规的 bech32 发送支持部分和流行比特币基础设施项目的值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--optech-schnorr-taproot-workshops-taproot-workshop-->****[Optech schnorr/taproot 研讨会][taproot-workshop]：** Optech 将于 9 月 24 日在旧金山和 9 月 27 日在纽约举办关于 schnorr 签名和 taproot 的研讨会。工程师们将学习这些技术及其如何应用于自己的产品和服务，构建 schnorr 和 taproot 钱包实现，并有机会参与对这些比特币协议提案的反馈过程。

  成员公司应[发送邮件给我们][optech email]为您的工程师预留席位。

## 新闻

- **<!--bitcoin-vaults-without-covenants-->****无需契约的 Bitcoin vaults：** 在[帖子][vault1]中，Bryan Bishop 向 Bitcoin-Dev 邮件列表描述了如何使用预签名交易支付到使用 `OP_CHECKSEQUENCEVERIFY` (CSV) 的脚本，使用户能够检测并阻止窃贼通过获取用户私钥而试图窃取资金的行为，这种能力此前被称为提供 *Bitcoin vaults*。Bishop 在详细描述了基础协议和几个可能的变体后，发布了第二个[帖子][vault2]，描述了一种仍然可以从 vaults 中窃取资金的情况，尽管他也提出了一种部分缓解方案，可以将损失限制在被保护资金的一部分，并请求对比特币共识规则进行最小必要改动的提案，以完全缓解此风险。

- **<!--proposed-change-to-schnorr-pubkeys-->****对 schnorr 公钥的提议更改：** Pieter Wuille 在 Bitcoin-Dev 邮件列表上发起了一个[讨论][pubkey32]，请求对将 [bip-schnorr][] 和 [bip-taproot][] 公钥从之前提议的 33 字节压缩公钥切换为 32 字节公钥的提案进行反馈。压缩公钥包含一个位，用于指示验证者 Y 坐标是偶数还是奇数。结合某种算法，验证者可以从包含在压缩公钥中的 32 字节 X 坐标推导出完整公钥的两个可能的 Y 坐标，其中一个是奇数，另一个是偶数，因此该位可以帮助验证者选择正确的坐标，避免在验证时尝试两种组合（这会降低验证速度，并消除批量签名验证的任何优势）。已经提出了几种 <span title="voodoo">数学</span> 方案，这些方案可以为那些 Y 坐标可以无需额外位推导的密钥生成签名（当前该位是前缀字节中唯一包含的数据）。这可以为每次支付到 taproot 输出节省 1 个 vbyte（如果大多数用户迁移到 taproot，每个区块可能节省数千个 vbyte），并为每个在脚本路径支出中包含的公钥节省 0.25 个 vbyte。有关 32 字节公钥的先前讨论，请参见 [Newsletter #48][oddness byte]。

## Bech32 发送支持

*这是一个关于允许您支付对象访问 segwit 所有好处的[系列][bech32 series]中的第 22 周内容。*

{% include specials/bech32/zh/22-priority.md %}

## 值得注意的代码和文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [C-Lightning #2858][] 限制每个方向的最大待处理 HTLC 数量为 30（从 LN 规范允许的最大 483 降低），并通过 `--max-concurrent-htlcs` 选项使该值可配置。待处理 HTLC 数量越少，单边关闭交易的字节大小和费用成本就越小，因为结算每个 HTLC 会产生一个单独的输出，该输出只能由相对较大的输入来支出。

{% include linkers/issues.md issues="2858" %}
[bech32 series]: /zh/bech32-sending-support/
[oddness byte]: /zh/newsletters/2019/05/29/#move-the-oddness-byte
[vault1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017229.html
[vault2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017231.html
[pubkey32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017247.html
[pr pubkey32]: https://github.com/sipa/bips/pull/52
[taproot-workshop]: /zh/workshops#taproot-workshop
