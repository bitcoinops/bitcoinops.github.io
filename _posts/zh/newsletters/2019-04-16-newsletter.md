---
title: 'Bitcoin Optech Newsletter #42'
permalink: /zh/newsletters/2019/04/16/
name: 2019-04-16-newsletter-zh
slug: 2019-04-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 呼吁大家测试 Bitcoin Core 与 LND 最新的候选版本，介绍了帮助人们接收发往 bech32 地址的付款如何能降低手续费，并列出了热门比特币项目中值得注意的代码变更。

{% include references.md %}

## 行动项

- **帮助测试 Bitcoin Core 0.18.0 候选版本：** Bitcoin Core 下一个主要版本的第三个 RC 已[可供下载][0.18.0]，第四个正在准备中。我们非常欢迎参与测试。请通过[这个问题][Bitcoin Core #15555]报告反馈。

- **帮助测试 LND 0.6-beta RC4：** LND 下一个主要版本的[候选版本][lnd releases]正在陆续发布。我们鼓励组织和经验丰富的 LN 用户参与测试，以便发现可能影响正式版用户的回归问题或严重问题。如果发现问题，请[新开一个 issue][lnd issue]。

## 新闻

*本周没有值得注意的技术新闻。（注意：Optech 当初创办这份 Newsletter 时就决定，不要用凑数的文章和其他不必要的信息去填充短小的期号，因此每期长度会随当周真正重要的技术新闻量而变化。你可能见过我们偶尔发出一期非常长的 Newsletter；本周你看到的正相反。）*

## Bech32 发送支持

*第 5 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定满两周年之前，Optech Newsletter 每周都会包含这一栏目，提供信息帮助开发者和组织实现 bech32 发送支持——也就是能够向原生 segwit 地址付款。你[不需要自己实现 segwit][bech32 series]，但你付款的对象却能享受到 segwit 带来的种种好处。*

{% include specials/bech32/zh/05-fee-savings.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案 (BIPs)][bips repo] 中值得注意的变更。注意：文中描述的 Bitcoin Core 与 LND 合并都发生在各自的 master 开发分支上；其中一些也可能被向后移植到各自待发布的版本中。*

- [Bitcoin Core #15711][] 让 GUI 默认生成 bech32 地址。如果用户需要从尚未支持 bech32 付款的服务那里收款，仍可取消勾选“请求付款”页面上的一个复选框，改为生成 P2SH 包装的 segwit 地址。bitcoind 默认生成 P2SH 包装的 segwit 地址这一行为没有改变。

- [C-Lightning #2506][] 新增了 `min-capacity-sat` 配置参数，用于拒绝低于某个值的通道打开请求。这取代了此前代码中硬编码的 0.00001 BTC 最低值。

- [LND #2933][] 新增了一份文档，介绍 LND 当前的[备份与恢复选项][lnd recover]。

- [C-Lightning #2540][] 新增了一个发票钩子（invoice hook），每当“针对未支付发票的有效付款到达”时就会被调用。除了处理收到付款时可以完成的其他任务之外，插件还可以用它来实现“挂起发票（hold invoice）”——LND 此前已实现过这一功能（参见 [Newsletter #38][] 中对 [LND #2022][] 的描述）。

- [C-Lightning #2554][] 把默认的发票过期时间从 1 小时改为 1 周。过了这个时间，节点就会自动拒绝支付该发票的尝试。希望把汇率风险降到最低的服务，在使用 `invoice` RPC 时需要传入更低的 `expiry` 值。


{% include linkers/issues.md issues="15555,15711,2933,2908,2540,2554,2506,2022" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[bech32 easy]: /zh/newsletters/2019/03/19/#bech32-发送支持
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[lnd recover]: https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md
[bech32 series]: /zh/bech32-sending-support/
[newsletter #38]: /zh/newsletters/2019/03/19/#lnd-2022
