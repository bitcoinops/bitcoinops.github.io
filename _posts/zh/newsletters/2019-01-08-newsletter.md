---
title: 'Bitcoin Optech Newsletter #28'
permalink: /zh/newsletters/2019/01/08/
name: 2019-01-08-newsletter-zh
slug: 2019-01-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 Bitcoin Core 的一个新维护版本，描述了关于新签名哈希的持续讨论，并链接到一篇关于闪电网络 (LN) 支付跨不同货币时可能存在的经济障碍的文章。还提供了流行的比特币基础设施项目中值得注意的代码变更描述。

## 行动项

- **<!--upgrade-to-bitcoin-core-0-17-1-->****升级到 Bitcoin Core 0.17.1：**这个新的[小][maintenance]版本于 12 月 25 日发布，恢复了一些之前弃用的 `listtransactions` RPC 功能，并包括错误修复和其他改进。建议阅读[发行说明][0.17.1 notes]和[升级指南][0.17.1 bin]。

## 新闻

- **<!--continued-sighash-discussion-->****持续的签名哈希讨论：**如 [Newsletter #25][] 的新闻部分所述，Bitcoin-Dev 邮件列表上的开发者讨论了如何修改签名哈希以使交易能够获得新的功能。签名哈希使得花费者能够允许他们的交易在签名后以指定的方式进行修改——例如，两个一起开设支付通道的人可以使用特定类型的签名哈希，使他们中的任何一个都可以单方面为通道关闭交易附加额外的交易费用。

  最近的这次讨论涉及了几乎 70 个帖子，主要讨论了新的签名哈希标志的边缘情况，特别是类似 BIP118 的 `SIGHASH_NOINPUT_UNSAFE`。作为讨论的一部分，协议开发者 Johnson Lau 描述了一种[基于 Eltoo 的支付通道优化][lau bip68]。还[讨论了][rm codesep]是否应该在支持 MAST（例如通过 Taproot）的脚本更新中禁用 `OP_CODESEPARATOR` 操作码。该操作码不常用，但如果你计划在未来的脚本版本中使用它，你应该在这个线程中发表评论。

- **<!--cross-chain-ln-as-an-options-contract-->****跨链 LN 作为期权合约：**匿名 LN 贡献者 ZmnSCPxj 在 Lightning-Dev 邮件列表中发起了一个讨论，指出用户可以通过延迟支付结算来滥用跨货币支付，从而创建几乎免费的[短期期权合约][short-term options contracts]。2018 年 5 月，Corné Plooy 的一个[之前的帖子][cjp risk]描述了同样的事情。

  例如，Mallory 了解到 Bob 愿意从比特币路由到莱特币支付，所以她从一个比特币节点通过 Bob 向她的一个莱特币节点发送付款。如果这是正常支付，她会通过释放支付哈希锁的前图像立即结算它——但相反，她的节点等待 24 小时，等待汇率变化。如果汇率朝着对莱特币有利的方向变化，Mallory 结算支付，并以昨天的汇率今天获得莱特币。如果汇率保持不变或朝着对比特币有利的方向变化，Mallory 使支付失败并取回她的比特币。由于失败的支付不收取费用，Mallory 获得了一个临时锁定莱特币价格的机会，唯一的成本是她本来会交易的比特币。

  目前没有已知的跨货币 LN 节点，但这个技巧的可用性意味着未来这样的节点可能会被滥用于投机而不是支付路由。如果这确实成为一个现实问题，并且找不到可接受的解决方案，可能会导致不同货币的支付通道网络彼此隔离。

## 值得注意的代码变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14565][] 显著改进了 `importmulti` RPC 的错误处理，并将在每次尝试导入时返回一个 `warnings` 字段，其中包含描述该导入问题的字符串数组（如果存在问题）。

- [Bitcoin Core #14811][] 更新了 [getblocktemplate][rpc getblocktemplate] RPC，要求传递 segwit 标志。这有助于防止矿工意外不使用 segwit，从而减少他们的费用收入。请参阅 [Newsletter #20][]，了解最近一个大型矿池可能发生的实例。

- [C-Lightning #2172][] 允许 `lightningd` 正常关闭，即使它作为主要进程（PID 1）运行，这在 Docker 容器中很有用。例如，开源的 [BTCPay][] 服务器就是这样运行 C-Lightning 的。

- [C-Lightning #2188][] 添加了可由插件使用的通知订阅处理程序，初步支持节点已连接到新对等点或已断开与现有对等点连接的通知。 [插件文档][cl plugin event] 和 [示例插件][cl helloworld.py] 已更新以支持这些处理程序。

- [LND #2374][] 增加了 `lncli` 工具将接受的 gRPC 消息的最大大小，从 4 MB 提高到 50 MB。这修复了一些节点遇到的问题，这些节点由于网络增长如此之大，消息超出了这个限制，导致 `describegraph` RPC 失败。直接使用 gRPC 的开发者需要增加他们的客户端最大消息大小设置——关于如何做到这一点的描述已经作为评论添加到 Python 和 Nodejs 的 PR 中。最终预计网络将增长到甚至超出这个新最大值，因此开发者计划改造相关的 RPC 以应对这种情况。

- [LND #2354][] 添加了一个新的 `invoicestate` 字段，并弃用了之前的 `settled` 字段，该字段在获取发票信息的 RPC 中。已结算字段是布尔值，但新状态字段可以支持多个值。目前这只是“open”或“settled”，但计划将来添加更多状态。


{% include references.md %}
{% include linkers/issues.md issues="14565,14811,2172,2188,2374,2354" %}

[0.17.1 bin]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[0.17.1 notes]: https://bitcoincore.org/en/releases/0.17.1/
[maintenance]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[lau bip68]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016574.html
[rm codesep]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016581.html
[short-term options contracts]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001752.html
[cjp risk]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001292.html
[cl plugin event]: https://github.com/ElementsProject/lightning/blob/master/doc/PLUGINS.md#event-notifications
[cl helloworld.py]: https://github.com/ElementsProject/lightning/blob/master/contrib/plugins/helloworld.py
[btcpay]: https://github.com/btcpayserver/btcpayserver
[newsletter #25]: /zh/newsletters/2018/12/11/#sighash-options-for-covering-transaction-weight
[newsletter #20]: /zh/newsletters/2018/11/06/#temporary-reduction-in-segwit-block-production
