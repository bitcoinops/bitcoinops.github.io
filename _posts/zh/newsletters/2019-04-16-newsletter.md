---
title: 'Bitcoin Optech Newsletter #42'
permalink: /zh/newsletters/2019/04/16/
name: 2019-04-16-newsletter-zh
slug: 2019-04-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求测试 Bitcoin Core 和 LND 最新的发布候选版本，描述了帮助人们接受支付到 bech32 地址可以降低费用，并列出了流行比特币项目中的值得注意的代码更改。

{% include references.md %}

## 行动项

- **帮助测试 Bitcoin Core 0.18.0 发布候选版本：** Bitcoin Core 的第三个 RC 其下一个主要版本是 [可用的][0.18.0]，第四个正在准备中。非常感谢测试。请使用 [此问题][Bitcoin Core #15555] 报告反馈。

- **帮助测试 LND 0.6-beta RC4：** [发布候选版本][lnd releases] 的下一个主要版本的 LND 正在发布。鼓励组织和有经验的 LN 用户进行测试，以捕获可能影响最终用户的任何回归或严重问题。如果发现任何问题，请 [打开一个新问题][lnd issue]。

## 新闻

*本周没有值得注意的技术新闻。（注意：当我们在 Optech 开始这个 Newsletter 时，我们决定避免填充短的 Newsletter 与冗余的文章和其他不必要的信息，所以 Newsletter 的长度根据每周实际的重大技术新闻量而有所不同。你可能已经看到我们偶尔发布一份非常长的 Newsletter；本周，你会看到相反的情况。）*

## Bech32 发送支持

*第 5 周，共 24 周。直到 2019 年 8 月 24 日 segwit 软分叉锁定的第二周年，Optech Newsletter 将包含这个每周部分，为开发者和组织提供信息，以帮助他们实现 bech32 发送支持——支付原生 segwit 地址的能力。这个[不需要你自己实现 segwit][bech32 series]，但它确实允许你支付的人访问 segwit 的所有多个好处。*

{% include specials/bech32/zh/05-fee-savings.md %}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案 (BIPs)][bips repo] 中的值得注意的更改。注意：所有描述的合并到 Bitcoin Core 和 LND 的合并是到它们的主开发分支；有些也可能会被回移到它们的待定版本中。*

- [Bitcoin Core #15711][] 在 GUI 中默认生成 bech32 地址。用户仍然可以在需要从尚未提供 bech32 发送支持的服务接收钱时，通过取消选中请求支付屏幕上的一个框来生成 P2SH 包装的 segwit 地址。bitcoind 默认生成 P2SH 包装的 segwit 地址未改变。

- [C-Lightning #2506][] 添加了一个 `min-capacity-sat` 配置参数，以拒绝低于某个值的通道打开请求。这取代了以前代码中硬编码的 0.00001 BTC 的最低值。

- [LND #2933][] 添加了一个描述 LND 当前 [备份和恢复选项][lnd recover] 的文档。

- [C-Lightning #2540][] 添加了一个发票钩子，当“未支付发票的有效支付已到达”时调用。除了收到支付时可以执行的其他任务外，这可以被插件用来实现 “hold 发票”，正如先前在 LND 中实现的（请参阅我们在 [Newsletter #38][] 中对 [LND #2022][] 的描述）。

- [C-Lightning #2554][] 将默认发票过期时间从一小时更改为一周。这是节点将在此时间后自动拒绝支付发票的时间。希望将汇率风险降到最低的服务在使用 `invoice` RPC 时需要传递较低的 `expiry` 值。


{% include linkers/issues.md issues="15555,15711,2933,2908,2540,2554,2506,2022" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[bech32 easy]: /zh/newsletters/2019/03/19/#bech32-发送支持
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[lnd recover]: https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md
[bech32 series]: /zh/bech32-sending-support/
[newsletter #38]: /zh/newsletters/2019/03/19/#lnd-2022
