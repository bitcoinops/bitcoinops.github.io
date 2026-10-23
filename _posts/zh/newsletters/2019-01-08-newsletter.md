---
title: 'Bitcoin Optech Newsletter #28'
permalink: /zh/newsletters/2019/01/08/
name: 2019-01-08-newsletter-zh
slug: 2019-01-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 Bitcoin Core 的一个新维护版本，描述了关于新签名哈希的持续讨论，并链接到一篇关于 LN 支付跨不同货币时可能存在的经济障碍的文章。文中还介绍了热门比特币基础设施项目中值得注意的代码变更。

## 行动项

- **<!--upgrade-to-bitcoin-core-0-17-1-->****升级到 Bitcoin Core 0.17.1：**这个新的[次要][maintenance]版本于 12 月 25 日发布，恢复了一些之前被弃用的 `listtransactions` RPC 功能，并包含错误修复和其他改进。建议你阅读[发行说明][0.17.1 notes]并[升级][0.17.1 bin]。

## 新闻

- **<!--continued-sighash-discussion-->****持续的签名哈希讨论：**如 [Newsletter #25][] 的新闻部分所述，Bitcoin-Dev 邮件列表上的开发者讨论了可以如何修改签名哈希，让交易获得新的能力。签名哈希让付款方能够允许自己的交易在签名之后按指定方式被修改——例如，两个共同开设支付通道的人可以使用特定类型的签名哈希，让其中任何一方都能单方面为通道关闭交易追加额外的手续费。

  这个讨论帖已有近 70 个帖子，最近的讨论主要围绕新签名哈希标志的边缘情况，特别是类似 BIP118 的 `SIGHASH_NOINPUT_UNSAFE`。作为讨论的一部分，协议开发者 Johnson Lau 描述了一种针对基于 Eltoo 的支付通道的[优化][lau bip68]。讨论中还涉及[是否][rm codesep]应该在支持 MAST（例如通过 Taproot）的脚本更新中禁用 `OP_CODESEPARATOR` 操作码。该操作码并不常用，但如果你计划在未来的 Script 版本中使用它，就应该在讨论帖中发表意见。

- **<!--cross-chain-ln-as-an-options-contract-->****跨链 LN 作为期权合约：**化名 LN 贡献者 ZmnSCPxj 在 Lightning-Dev 邮件列表发起讨论，指出用户可以通过延迟支付结算，滥用跨货币支付来创建几乎免费的[短期期权合约][short-term options contracts]。2018 年 5 月 Corné Plooy 的[一个讨论帖][cjp risk]描述了同样的事情。

  例如，Mallory 得知 Bob 愿意路由从比特币到莱特币的支付，于是她从一个自己的比特币节点出发，通过 Bob 向自己的某个莱特币节点发送一笔支付。如果是正常支付，她会通过公开这笔支付哈希锁的原像来立即结算——但她没有，而是让自己的节点等上 24 小时，等着汇率变化。如果汇率朝有利于莱特币的方向变化，Mallory 就结算这笔支付，以昨天的汇率拿到今天的莱特币。如果汇率不变或朝有利于比特币的方向变化，Mallory 就让支付失败，拿回自己的比特币。由于失败的支付不收手续费，Mallory 就等于不花什么代价就获得了临时锁定莱特币价格的机会，唯一的成本只是持有她本会用于交易的这些比特币。

  目前还没有已知的跨货币 LN 节点，但这种手法的存在意味着，将来这类节点可能被用于投机，而不是用于支付路由。如果这真的成为现实问题，又找不到可接受的解决方案，那么不同货币的支付通道网络可能会彼此隔离。

## 值得注意的代码变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14565][] 显著改进了 `importmulti` RPC 的错误处理：每次尝试导入时都会返回一个 `warnings` 字段，其中是描述该次导入存在哪些问题的字符串数组（只有在确实存在问题时才返回）。

- [Bitcoin Core #14811][] 更新了 [getblocktemplate][rpc getblocktemplate] RPC，要求必须传入 segwit 标志。这有助于防止矿工意外不使用 segwit，从而减少自己的手续费收入。关于最近一家大型矿池可能发生过这种情况的实例，请参阅 [Newsletter #20][]。

- [C-Lightning #2172][] 允许 `lightningd` 正常关闭，即使它作为主进程（PID 1）运行，这在 Docker 容器中很有用。例如，开源的 [BTCPay][] 服务器就是这样运行 C-Lightning 的。

- [C-Lightning #2188][] 新增了可供插件使用的通知订阅处理程序，初步支持“节点连接到新对等节点”和“与现有对等节点断开连接”这两类通知。[插件文档][cl plugin event]和[示例插件][cl helloworld.py]已针对这些处理程序更新。

- [LND #2374][] 提高了 `lncli` 工具能接受的 gRPC 消息最大大小，从 4 MB 提升到 50 MB。这修复了一些节点遇到的问题：网络已经增长到消息超过该上限，导致 `describegraph` RPC 失败。直接使用 gRPC 的开发者需要调高自己客户端的最大消息大小设置——具体做法的说明已作为评论补充到该 PR 中，分别覆盖 Python 和 Node.js。最终预计网络会增长到连这个新上限也不够用，因此开发者计划改造相关 RPC 来应对这种情况。

- [LND #2354][] 新增了 `invoicestate` 字段，并在用于获取发票信息的 RPC 中弃用了原来的 `settled` 字段。`settled` 是布尔值，而新的状态字段可以支持多个取值。目前只有“open”和“settled”两种，但计划将来增加更多状态。


{% include references.md %}
{% include linkers/issues.md issues="14565,14811,2172,2188,2374,2354" %}

[0.17.1 bin]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[0.17.1 notes]: https://bitcoincore.org/en/releases/0.17.1/
[maintenance]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[lau bip68]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016574.html
[rm codesep]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016581.html
[short-term options contracts]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001752.html
[cjp risk]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001292.html
[cl plugin event]: https://github.com/ElementsProject/lightning/blob/master/doc/PLUGINS.md#event-notifications
[cl helloworld.py]: https://github.com/ElementsProject/lightning/blob/master/contrib/plugins/helloworld.py
[btcpay]: https://github.com/btcpayserver/btcpayserver
[newsletter #25]: /zh/newsletters/2018/12/11/#sighash-options-for-covering-transaction-weight
[newsletter #20]: /zh/newsletters/2018/11/06/#temporary-reduction-in-segwit-block-production
