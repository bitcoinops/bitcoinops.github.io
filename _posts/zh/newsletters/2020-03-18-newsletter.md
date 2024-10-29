---
title: 'Bitcoin Optech Newsletter #89'
permalink: /zh/newsletters/2020/03/18/
name: 2020-03-18-newsletter-zh
slug: 2020-03-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一个关于闪电网络（LN）提议标准的更新，包含了我们常规的关于服务、客户端软件和流行比特币基础设施项目的值得注意的变化部分。

## 行动项

*本周无。*

## 新闻

- **<!--proposed-watchtower-bolt-has-been-updated-->****提议的瞭望塔 BOLT 已更新：** Sergi Delgado Segura 向 Lightning-Dev 邮件列表发送了一封[电子邮件][segura email]，其中包含一个建议的[瞭望塔][topic watchtowers]通信协议的[更新版本][watchtower bolt]。请参见 [Newsletter #75][news75 watchtower]，了解我们对此提案的初步描述。根据 Segura 的说法，此更新包括了有关“用户账户、支付方式和消息签名”的详细信息。他的电子邮件还列出了他希望添加的功能，并在邮件的后半部分对此进行了讨论。

## 服务和客户端软件的更改

*在这个月度栏目中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--coinbase-withdrawal-transactions-now-using-batching-->****Coinbase 提现交易现在使用批量处理：** Coinbase 推出[批量提现][coinbase batching blog]功能，他们预计该功能将使其对比特币网络的负载减少 50%。与每笔提现支付生成单独的链上交易不同，多个支付现在每 10 分钟会[合并为一笔交易][scaling payment batching]。

- **<!--bitstamp-supports-bech32-->****Bitstamp 支持 bech32：** Bitstamp 用户现在可以在该交易所宣布支持 [bech32 存款和提现][bitstamp bech32 blog]后，享受使用本地 [bech32][topic bech32] 地址的好处。

- **<!--deribit-supports-bech32-withdrawals-->****Deribit 支持 bech32 提现：** [Deribit 宣布][deribit bech32 withdrawal tweet]，其交易所用户现在可以将比特币提现到本地 bech32 地址。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #16902][] 更改了共识代码，以修复 `OP_IF` 及相关操作码解析中的一个低效问题。在传统和 segwit v0 脚本中，预计这一低效问题不会引起任何重大问题。然而，提议的 [tapscript][topic tapscript] 可能会让攻击者利用这一低效问题创建需要大量 CPU 验证的交易区块。现在修复该低效问题可以减少在提议的 schnorr、taproot 和 tapscript 软分叉中需要进行的更改数量。更多信息，请参见 Bitcoin Core PR 审查俱乐部的[会议记录][club #16902]。

- [LND #3821][] 为 LN 通道添加了[锚定承诺][topic anchor outputs]，并且如果通道双方的节点都支持，则默认启用锚定承诺。锚定承诺交易可以由任一方单方面增加手续费，这很有用，因为承诺交易可能会在承诺链上手续费后很长时间才广播。

- [LND #3963][] 添加了有关如何安全使用 LND 的详细[文档][lnd op safety]。

- [Eclair #1319][] 实现了与[Newsletter #85][news85 ln stuck]中描述的解决方案相同的方法，用于解决一个罕见的通道卡住问题：当通道资助者收到资金但由于余额不足无法支付支付承诺（HTLC）成本时，付款会因资金不足而被拒绝。

{% include references.md %}
{% include linkers/issues.md issues="16902,3821,3963,1319" %}
[lnd op safety]: https://github.com/lightningnetwork/lnd/blob/master/docs/safety.md
[segura email]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-March/002586.html
[watchtower bolt]: https://github.com/sr-gi/bolt13/blob/master/13-watchtowers.md
[club #16902]: https://bitcoincore.reviews/16902/
[news75 watchtower]: /zh/newsletters/2019/12/04/#proposed-watchtower-bolt
[news85 ln stuck]: /zh/newsletters/2020/02/19/#c-lightning-3500
[coinbase batching blog]: https://blog.coinbase.com/coinbase-rolls-out-bitcoin-transaction-batching-5f6d09b8b045
[bitstamp bech32 blog]: https://www.bitstamp.net/article/weve-added-support-bech32-bitcoin-addresses-bitsta/
[deribit bech32 withdrawal tweet]: https://twitter.com/DeribitExchange/status/1234904442169851909