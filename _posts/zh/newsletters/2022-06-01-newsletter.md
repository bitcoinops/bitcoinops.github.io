---
title: 'Bitcoin Optech Newsletter #202'
permalink: /zh/newsletters/2022/06/01/
name: 2022-06-01-newsletter-zh
slug: 2022-06-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 介绍了开发者在静默支付上的实验，并照例列出了新版本发布与候选发布的摘要，以及热门比特币基础设施软件的值得注意的更改。

## 新闻

- **<!--n1-->****关于静默支付的实验：** 根据 [Newsletter #194][news194 silent] 的描述，静默支付使得可以向某个公共标识符（“地址”）付款，而不会在公共记录中暴露该地址被付款的事实。本周，开发者 w0xlt 在 Bitcoin-Dev 邮件列表上[发布][w0xlt post]了一篇针对默认 [signet][topic signet] 生成静默支付地址的[教程][sp tutorial]，该教程基于 Bitcoin Core 的一个[概念验证实现][bitcoin core #24897]。包括流行钱包作者在内的多位开发者正在讨论该提案的其他细节，其中包括[为其创建地址格式][sp address]。

## 发布与候选发布

*针对流行比特币基础设施项目的新版本与候选版本。请考虑升级到新版本或协助测试候选版本。*

- [HWI 2.1.1][HWI 2.1.1] 修复了影响 Ledger 和 Trezor 设备的两个小问题，并新增对 Ledger Nano S Plus 的支持。

- [LND 0.15.0-beta.rc3][LND 0.15.0-beta.rc3] 是这一流行 LN 节点的下一个主要版本的候选发布。

## 值得注意的代码与文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]上的值得注意的更改。*

- [BTCPay Server #3772][BTCPay Server #3772] 允许用户在发布前为线上测试启用实验性功能。

- [BTCPay Server #3744][BTCPay Server #3744] 新增一项功能，可将钱包交易导出为 CSV 或 JSON 格式。

- [BOLTs #968][BOLTs #968] 为使用 Bitcoin testnet 和 signet 的节点添加了默认的 TCP 端口。


{% include references.md %}
{% include linkers/issues.md v=2 issues="3772,3744,968,24897" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[hwi 2.1.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.1.1
[news194 silent]: /zh/newsletters/2022/04/06/#delinked-reusable-addresses
[w0xlt post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020513.html
[sp tutorial]: https://gist.github.com/w0xlt/72390ded95dd797594f80baba5d2e6ee
[sp address]: https://gist.github.com/RubenSomsen/c43b79517e7cb701ebf77eec6dbb46b8?permalink_comment_id=4177027#gistcomment-4177027
