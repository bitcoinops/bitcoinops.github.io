---
title: 'Bitcoin Optech Newsletter #59'
permalink: /zh/newsletters/2019/08/14/
name: 2019-08-14-newsletter-zh
slug: 2019-08-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 简要介绍 Bitcoin-Dev 邮件列表上的两场讨论，一场关于比特币保险库（vaults），一场关于缩小 taproot 中所用公钥的大小。此外，还包括我们常规的 bech32 发送支持部分，以及流行比特币基础设施项目中值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--optech-schnorr-taproot-workshops-taproot-workshop-->****[Optech schnorr/taproot 工作坊][taproot-workshop]：** Optech 将于 9 月 24 日在旧金山、9 月 27 日在纽约举办关于 schnorr 签名和 taproot 的工作坊。工程师将了解这些技术以及如何把它们用于自己的产品和服务，动手构建 schnorr 和 taproot 钱包实现，并有机会参与这些比特币协议改动提案的反馈过程。

  成员公司请[发邮件给我们][optech email]，为你的工程师预留席位。

## 新闻

- **<!--bitcoin-vaults-without-covenants-->****无需契约的比特币保险库：** Bryan Bishop 在 Bitcoin-Dev 邮件列表上[发帖][vault1]，描述把预签名交易支付给使用 `OP_CHECKSEQUENCEVERIFY` (CSV) 的脚本，如何让用户发现并阻止窃贼在拿到用户私钥后盗取资金的企图；这种能力此前被称为 *比特币保险库*。在详细描述了基础协议和几种可能的变体之后，Bishop 又发了第二个[帖子][vault2]，说明仍能从保险库中盗走资金的一种情况；不过他也提出了一种部分缓解方案，可把损失限制在被保护资金的一定比例内，并征集提案，希望对 Bitcoin 共识规则做最小的必要改动，以完全缓解这一风险。

- **<!--proposed-change-to-schnorr-pubkeys-->****关于 schnorr 公钥的改动提案：** Pieter Wuille 在 Bitcoin-Dev 邮件列表上发起了[讨论][pubkey32]，就一项提案征求反馈：把 [bip-schnorr][] 和 [bip-taproot][] 改用 32 字节公钥，而不再使用此前提议的 33 字节压缩公钥。压缩公钥里包含一个比特，用来告诉验证者其 Y 坐标是偶数还是奇数。配合一种算法，验证者可以从压缩公钥里的 32 字节 X 坐标确定出完整公钥可能的两个 Y 坐标。这两个坐标一奇一偶，因此奇偶位能让验证者挑出正确的那个，不必在验证时把两种组合都试一遍（那样会拖慢验证，并使批量签名验证带来的好处全部消失）。目前已提出几种 <span title="voodoo">数学</span>方案，可为这样的密钥生成签名：其 Y 坐标无需额外那一位就能推断出来（目前这一位是前缀字节中包含的唯一数据）。这样每笔支付到 taproot 输出可省下 1 个 vbyte（如果大多数用户迁移到 taproot，每个区块可能省下数千个 vbyte），脚本路径花费中每包含一个公钥可省下 0.25 个 vbyte。关于 32 字节公钥的先前讨论，请参见 [Newsletter #48][oddness byte]。

## Bech32 发送支持

*这是共 24 周的[系列][bech32 series]中的第 22 周，目的是让你支付的对象也能获得隔离见证的全部好处。*

{% include specials/bech32/zh/22-priority.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 中值得注意的变更。*

- [C-Lightning #2858][] 把每个方向待处理 HTLC 的上限设为 30（LN 规范允许的最大值为 483），并让该值可以通过 `--max-concurrent-htlcs` 选项配置。待处理的 HTLC 越少，单边关闭交易的字节数和手续费成本就越小，因为结算每个 HTLC 都会产生一个单独的输出，而花掉这种输出需要相当大的输入。

{% include linkers/issues.md issues="2858" %}
[bech32 series]: /zh/bech32-sending-support/
[oddness byte]: /zh/newsletters/2019/05/29/#move-the-oddness-byte
[vault1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017229.html
[vault2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017231.html
[pubkey32]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017247.html
[pr pubkey32]: https://github.com/sipa/bips/pull/52
[taproot-workshop]: /zh/workshops#taproot-workshop
