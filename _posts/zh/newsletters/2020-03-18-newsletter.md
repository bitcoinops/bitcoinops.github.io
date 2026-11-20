---
title: 'Bitcoin Optech Newsletter #89'
permalink: /zh/newsletters/2020/03/18/
name: 2020-03-18-newsletter-zh
slug: 2020-03-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一项针对 LN 提议标准的更新，此外还包括我们的常规部分：服务、客户端软件，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--proposed-watchtower-bolt-has-been-updated-->****提议的瞭望塔 BOLT 已更新：** Sergi Delgado Segura 向 Lightning-Dev 邮件列表发送了一封[电子邮件][segura email]，其中包含一个建议的[瞭望塔][topic watchtowers]通信协议的[更新版本][watchtower bolt]。请参见 [Newsletter #75][news75 watchtower]，了解我们对此提案的初步描述。根据 Segura 的说法，此更新包括了有关“用户账户、支付方式和消息签名”的详细信息。他的电子邮件还列出了他希望添加的功能，邮件末尾对每一项都作了讨论。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--coinbase-withdrawal-transactions-now-using-batching-->****Coinbase 提现交易现在使用批量处理：** Coinbase 推出了[批量提现][coinbase batching blog]功能，该公司估计这将使其对比特币网络的负载减少 50%。以前每笔提现支付都会生成一笔单独的链上交易，现在多笔支付会每 10 分钟[合并为一笔交易][scaling payment batching]。

- **<!--bitstamp-supports-bech32-->****Bitstamp 支持 bech32：** 在该交易所宣布支持 [bech32 存款和提现][bitstamp bech32 blog]之后，Bitstamp 用户现在可以使用原生 [bech32][topic bech32] 地址并从中受益。

- **<!--deribit-supports-bech32-withdrawals-->****Deribit 支持 bech32 提现：** [Deribit 宣布][deribit bech32 withdrawal tweet]，其交易所用户现在可以把比特币提现到原生 bech32 地址。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #16902][] 修改了共识代码，修复 `OP_IF` 及相关操作码解析中的一处低效。在 legacy 脚本和 segwit v0 脚本中，这一低效据信不会造成任何重大问题。但按 [tapscript][topic tapscript] 的提案，攻击者可能利用这一低效构造出这样的区块：其中的交易需要耗费大量 CPU 才能验证。现在修掉这处低效，就能减少提议的 schnorr、taproot 与 tapscript 软分叉中需要做的改动。更多信息，请参见 Bitcoin Core PR 审查俱乐部有关该 PR 的[会议记录][club #16902]。

- [LND #3821][] 为 LN 通道添加了[锚点承诺][topic anchor outputs]，并且在通道双方节点都表示支持时默认启用。锚点承诺交易可以由任一方单方面追加手续费，这很有用，因为承诺交易可能在其确定链上费率很久之后才被广播。

- [LND #3963][] 添加了有关如何安全使用 LND 的详细[文档][lnd op safety]。

- [Eclair #1319][] 实现了与 [Newsletter #85][news85 ln stuck] 所述相同的解决方案，用于处理一个罕见的通道卡住问题：通道资助者正在收款，但余额不足以承担这笔支付的承诺（HTLC）成本，于是付款因资金不足被拒绝。

{% include references.md %}
{% include linkers/issues.md issues="16902,3821,3963,1319" %}
[lnd op safety]: https://github.com/lightningnetwork/lnd/blob/master/docs/safety.md
[segura email]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-March/002586.html
[watchtower bolt]: https://github.com/sr-gi/bolt13/blob/master/13-watchtowers.md
[club #16902]: https://bitcoincore.reviews/16902/
[news75 watchtower]: /zh/newsletters/2019/12/04/#proposed-watchtower-bolt
[news85 ln stuck]: /zh/newsletters/2020/02/19/#c-lightning-3500
[coinbase batching blog]: https://blog.coinbase.com/coinbase-rolls-out-bitcoin-transaction-batching-5f6d09b8b045
[bitstamp bech32 blog]: https://www.bitstamp.net/article/weve-added-support-bech32-bitcoin-addresses-bitsta/
[deribit bech32 withdrawal tweet]: https://twitter.com/DeribitExchange/status/1234904442169851909
